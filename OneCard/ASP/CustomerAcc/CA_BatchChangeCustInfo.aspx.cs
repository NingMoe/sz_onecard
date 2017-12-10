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
 * 功能名: 专有账户_批量修改资料
 * 更改日期      姓名           摘要 
 * ----------    -----------    --------------------------------
 * 2011/07/22    董翔			初次开发
 ****************************************************************/
public partial class ASP_CustomerAcc_CA_BatchChangeCustInfo : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 首先清空临时表
        GroupCardHelper.clearTempCustInfoTable(context);
        // 清除gridview数据
        clearGridViewData();
    }

    // 输入校验
    private void SubmitValidate()
    {
        Validation valid = new Validation(context);
    }

    private void createCustInfoGrid()
    {
        btnSubmit.Enabled = true;

        DataTable data = SPHelper.callQuery("SP_CA_Query", context, "BatchChangeCustInfoChecks", Session.SessionID);
        UserCardHelper.resetData(gvResult, data);

        data = SPHelper.callQuery("SP_CA_Query", context, "BadItems", Session.SessionID);

        if (data != null && data.Rows.Count > 0 && ((decimal)data.Rows[0].ItemArray[0]) > 0)
        {
            context.AddError("共有" + data.Rows[0].ItemArray[0] + "张卡片没有通过检验，详见下面列表");
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
        context.AddField("P_sessionID").Value = Session.SessionID;
        bool ok = context.ExecuteSP("SP_CA_BATCHCHANGECUSTINFO");
        if (ok)
        {
            AddMessage("D006023001: 批量修改资料成功");
        }

        clearGridViewData();
        GroupCardHelper.clearTempCustInfoTable(context);
    }

    //  文件上传处理

    protected void btnUpload_Click(object sender, EventArgs e)
    {
        clearGridViewData();
        CAHelper.UploadCustInfoFile(context, FileUpload1, false, "");
        if (context.hasError()) return;

        createCustInfoGrid();
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string result = gvResult.DataKeys[e.Row.RowIndex]["RESULT1"].ToString();
            if (e.Row.Cells[0].Text != "OK") // not ok
            {
                e.Row.Cells[0].CssClass = "error";
            }
            if (result == "0")
            {
                btnSubmit.Enabled = false;
            }
            e.Row.Cells[2].Text = DeEncrypt(e.Row.Cells[2].Text);
            e.Row.Cells[6].Text = DeEncrypt(e.Row.Cells[6].Text);
            if (e.Row.Cells[7].Text == "&nbsp;")
            {
                e.Row.Cells[7].Text = "";
            }
            e.Row.Cells[7].Text = DeEncrypt(e.Row.Cells[7].Text);
            if (e.Row.Cells[9].Text == "&nbsp;")
            {
                e.Row.Cells[9].Text = "";
            }
            e.Row.Cells[9].Text = DeEncrypt(e.Row.Cells[9].Text);
            if (e.Row.Cells[10].Text == "&nbsp;")
            {
                e.Row.Cells[10].Text = "";
            }
            e.Row.Cells[10].Text = DeEncrypt(e.Row.Cells[10].Text);
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