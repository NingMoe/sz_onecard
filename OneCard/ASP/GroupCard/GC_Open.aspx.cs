using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using TDO.CardManager;
using TM;
using Common;
using System.IO;
using System.Text;
using Master;
using System.Collections.Generic;

// 企服卡批量开卡
public partial class ASP_GroupCard_GC_Open : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 首先清空临时表
        GroupCardHelper.clearTempCustInfoTable(context);
        
        // 初始化集团客户
        GroupCardHelper.initGroupCustomer(context, selCorp);

        // 清除gridview数据
        clearGridViewData();
    }

    // 输入校验
    private void SubmitValidate()
    {
        Validation valid = new Validation(context);
        // 集团客户列表必须选择
        valid.notEmpty(selCorp, "A004P01I02: 集团客户必须选择");
    }

    private void createCustInfoGrid()
    {
        DataTable data = GroupCardHelper.callQuery(context, "GroupCardsChecks");

        //add by jiangbb 解密
        CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CustName", "CustPhone", "CustAddr", "PAPERNO" }));

        UserCardHelper.resetData(gvResult, data);

        data = GroupCardHelper.callQuery(context, "BadItems");

        if (data != null && data.Rows.Count > 0 && ((decimal)data.Rows[0].ItemArray[0]) > 0)
        {
            context.AddError("共有" + data.Rows[0].ItemArray[0] + "张卡片没有通过检验，详见下面列表");
            btnSubmit.Enabled = false;
            return;
        }

        btnSubmit.Enabled = true;
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
        if(context.hasError())return;

        // 调用企服卡批量开卡存储过程
        context.DBOpen("StorePro");
        context.AddField("p_groupCode").Value = selCorp.SelectedValue; // 集团客户编码
        context.AddField("p_oldFlag").Value = chkOldFlag.Checked ? "1" : "0";// 是否旧卡开户

        bool ok = context.ExecuteSP("SP_GC_Open");
        if (ok)
        {
            AddMessage("D004P01001: 企服卡批量开卡成功，请等待审批");
        }

        clearGridViewData();
        GroupCardHelper.clearTempCustInfoTable(context);
    }

    // 批量开户文件上传处理
    protected void btnUpload_Click(object sender, EventArgs e)
    {
        clearGridViewData();
        GroupCardHelper.UploadCustInfoFile(context, FileUpload1, false);
        if (context.hasError()) return;

        createCustInfoGrid();

        if (!string.IsNullOrEmpty(hiddenSMKCount.Value))
        {
            context.AddMessage("提示：共有" + hiddenSMKCount.Value + "张卡为市民卡，客户资料不会被修改");
        }
   }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[0].Text != "OK") // not ok
            {
                e.Row.Cells[1].CssClass = "error";
            }
            if (e.Row.Cells[1].Text.Substring(4, 2) == "18")
            {
                hiddenSMKCount.Value = ((hiddenSMKCount.Value == "" ? 0 : int.Parse(hiddenSMKCount.Value)) + 1).ToString();
                e.Row.Cells[1].CssClass = "cancelled";
            }
        }
    }
}
