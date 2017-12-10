using System;
using System.Text;
using System.Data;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using PDO.AdditionalService;
using Common;

public partial class ASP_AddtionalService_AS_RelaxCardCustomerRecReport : Master.ExportMaster
{
    #region Event
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");

            //初始化套餐类型
            ASHelper.initPackageTypeList(context, selPackageType);
        }
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        UserCardHelper.resetData(gvResult, null);

        validate();
        if (context.hasError()) return;

        DataTable data = ASHelper.callQuery(context, "RCCustomerRecReport", txtDate.Text,selPackageType.SelectedValue);

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        UserCardHelper.resetData(gvResult, data);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            gvResult.AllowPaging = false;
            DataTable dt = QueryInfo();
            UserCardHelper.resetData(gvResult, dt);
            ExportGridView(gvResult);
            gvResult.AllowPaging = true;
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[5].Text = GetAESDeEncryptStr(e.Row.Cells[5].Text);

            e.Row.Cells[7].Text = GetAESDeEncryptStr(e.Row.Cells[7].Text);

            e.Row.Cells[8].Text = GetAESDeEncryptStr(e.Row.Cells[8].Text);

            e.Row.Cells[9].Text = GetAESDeEncryptStr(e.Row.Cells[9].Text);
        }
    }

    public void gvResult_PageIndexChanging(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        UserCardHelper.resetData(gvResult, QueryInfo());
    }
    #endregion

    #region Private Method
    // 查询输入校验处理
    private void validate()
    {
        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtDate);

        DateTime? fromDate = null, toDate = null;
        if (b1)
        {
            context.AddError("日期必须填写");
        }
        else
        {
            if (!b1)
            {
                fromDate = valid.beDate(txtDate, "日期范围起始值格式必须为yyyyMMdd");
            }
        }

    }

    private DataTable QueryInfo()
    {
        return ASHelper.callQuery(context, "RCCustomerRecReport", txtDate.Text, selPackageType.SelectedValue);
    }

    private string GetAESDeEncryptStr(string str)
    {
        if (string.IsNullOrEmpty(str) || str == "&nbsp;")
            return "";

        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESDeEncrypt(str, ref strBuilder);

        return strBuilder.ToString();
    }
    #endregion
}