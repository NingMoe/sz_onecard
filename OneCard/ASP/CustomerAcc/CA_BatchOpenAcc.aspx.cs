using System;
using System.Collections;
using System.Data;
using System.IO;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using Master;

/***************************************************************
 * 功能名: 专有账户_批量开户
 * 更改日期      姓名           摘要 
 * ----------    -----------    --------------------------------
 * 2011/07/20    董翔			初次开发
 ****************************************************************/
public partial class ASP_CustomerAcc_CA_BatchOpenAcc : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 首先清空临时表
        GroupCardHelper.clearTempCustInfoTable(context);
        // 清除gridview数据
        clearGridViewData();

        // 初始化集团客户
        GroupCardHelper.initGroupCustomer(context, selCorp);
        
        //初始化账户类型
        CAHelper.FillAcctType(context, ddlAcctType);
    }

    // 输入校验
    private void SubmitValidate()
    {
        Validation valid = new Validation(context);
        // 集团客户列表必须选择
        valid.notEmpty(selCorp, "A004P01I02: 集团客户必须选择");
    }

    // 选中gridview当前页所有数据
    protected void CheckAll(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (ch.Enabled)
            {
                ch.Checked = cbx.Checked;
            }
        }
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (!ch.Checked)
            {
                btnSubmit.Enabled = false;
                return;
            }
        }
        btnSubmit.Enabled = true;
    }

    protected void Check(object sender, EventArgs e)
    {
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (!ch.Checked)
            {
                btnSubmit.Enabled = false;
                return;
            }
        }
        btnSubmit.Enabled = true;
    }

    private void createCustInfoGrid()
    {
        string[] parm = new string[1];
        parm[0] = Session.SessionID;
        DataTable data = SPHelper.callQuery("SP_CA_Query", context, "BatchOpenAccChecks", parm);
        UserCardHelper.resetData(gvResult, data);

        DataTable errordata = SPHelper.callQuery("SP_CA_Query", context, "BadOpenItems", parm);
        if (errordata != null && errordata.Rows.Count > 0 && ((decimal)errordata.Rows[0].ItemArray[0]) > 0)
        {
            context.AddError("共有" + errordata.Rows[0].ItemArray[0] + "张卡片没有通过检验，请操作员确认");
            btnSubmit.Enabled = false;
            return;
        }
        else
        {
            btnSubmit.Enabled = true;
        }
    }

    // 清除gridview数据
    private void clearGridViewData()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        btnSubmit.Enabled = false;
    }

    // 提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 输入校验
        SubmitValidate();
        if (context.hasError()) return;

        // 调用批量开户存储过程

        context.DBOpen("StorePro");
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        context.AddField("p_groupCode").Value = selCorp.SelectedValue; // 集团客户编码
        context.AddField("p_oldFlag").Value = chkOldFlag.Checked ? "1" : "0";// 是否旧卡开户
        bool ok = context.ExecuteSP("SP_CA_Open");
        if (ok)
        {
            AddMessage("D006021001: 批量开户成功");
        }

        clearGridViewData();
        GroupCardHelper.clearTempCustInfoTable(context);
    }

    // 批量开户文件上传处理

    protected void btnUpload_Click(object sender, EventArgs e)
    {
        //验证账户类型必选
        if (ddlAcctType.SelectedValue.Trim().Length < 1)
        {
            context.AddError("A006012015:请选择账户类型");
            return;
        }
        clearGridViewData();
        CAHelper.UploadCustInfoFile(context, FileUpload1, false, ddlAcctType.SelectedValue);
        if (context.hasError()) return;

        createCustInfoGrid();

    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Label lbl = (Label)e.Row.Cells[0].FindControl("Label");
            CheckBox ch = (CheckBox)e.Row.FindControl("ItemCheckBox");
            string result = gvResult.DataKeys[e.Row.RowIndex]["RESULT2"].ToString();
            if (lbl.Text == "OK")
            {
                ch.Checked = true;
                ch.Enabled = false;
            }
            else if (result == "0")
            {
                ch.Checked = false;
                ch.Enabled = false;
                btnSubmit.Enabled = false;
                e.Row.Cells[0].CssClass = "error";
            }
            else if (result == "1")
            {
                ch.Checked = false;
                ch.Enabled = true;
                btnSubmit.Enabled = false;
                e.Row.Cells[0].CssClass = "error";
            }
            e.Row.Cells[3].Text = DeEncrypt(e.Row.Cells[3].Text);
            e.Row.Cells[7].Text = DeEncrypt(e.Row.Cells[7].Text);
            if (e.Row.Cells[8].Text.Trim() == "&nbsp;")
                e.Row.Cells[8].Text = "";
            e.Row.Cells[8].Text = DeEncrypt(e.Row.Cells[8].Text);
            if (e.Row.Cells[10].Text.Trim() == "&nbsp;")
                e.Row.Cells[10].Text = "";
            e.Row.Cells[10].Text = DeEncrypt(e.Row.Cells[10].Text);
            if (e.Row.Cells[11].Text.Trim() == "&nbsp;")
                e.Row.Cells[11].Text = "";
            e.Row.Cells[11].Text = DeEncrypt(e.Row.Cells[11].Text);
        }
    }
    //解密
    private string DeEncrypt(string value)
    {
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESDeEncrypt(value, ref strBuilder);
        return strBuilder.ToString();
    }

}