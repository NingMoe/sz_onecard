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
using TM;
using System.IO;
using System.Text;
using Common;
using System.Collections.Generic;

// 企服卡客户信息批量更新

public partial class ASP_GroupCard_GC_InfoUpdate : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 创建临时表

        GroupCardHelper.createTempTable(context);

        // 首先清空临时表

        GroupCardHelper.clearTempCustInfoTable(context);

        // 清空gridview数据
        clearGridViewData();
    }

    private void changeCustInfoGrid()
    {
        DataTable data = GroupCardHelper.callQuery(context, "OpenItems");

        //add by jiangbb 解密
        CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" }));

        gvResult.DataSource = data;
        gvResult.DataBind();

        btnSubmit.Enabled = data.Rows.Count > 0;
    }

    // 情况gridview数据
    private void clearGridViewData()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        btnSubmit.Enabled = false;
    }

    // 提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 调用企服卡用户信息批量更新存储过程

        context.DBOpen("StorePro");
        bool ok = context.ExecuteSP("SP_GC_InfoUpdate");

        if (ok) AddMessage("D004P07000: 资料更新成功");

        clearGridViewData();
        GroupCardHelper.clearTempCustInfoTable(context);
    }

    // 用户信息文件上传处理
    protected void btnUpload_Click(object sender, EventArgs e)
    {
        GroupCardHelper.UploadCustInfoFile(context, FileUpload1, true);
        if (context.hasError()) return;

        changeCustInfoGrid();

        if (!string.IsNullOrEmpty(hiddenSMKCount.Value))
        {
            context.AddMessage("提示：共有" + hiddenSMKCount.Value + "张卡为市民卡，客户资料不会被修改");
        }
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[0].Text.Substring(4, 2) == "18")
            {
                hiddenSMKCount.Value = ((hiddenSMKCount.Value == "" ? 0 : int.Parse(hiddenSMKCount.Value)) + 1).ToString();
                e.Row.Cells[0].CssClass = "cancelled";
            }
        }
    }
}
