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
using PDO.Warn;
using TM;
using Common;
using System.Text;
using System.Collections.Generic;

public partial class ASP_Warn_WA_WarnCustomer : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        ASHelper.initPaperTypeList(context, selslPaperType);

        ASHelper.initPaperTypeList(context, selInPaperType);

        ASHelper.initSexList(selCustsex);
        UserCardHelper.resetData(gvResult, null);
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        StringBuilder sbCustName = new StringBuilder();
        AESHelp.AESEncrypt(txtSelCustName.Text.Trim(), ref sbCustName);

        StringBuilder sbPaperNo = new StringBuilder();
        AESHelp.AESEncrypt(txtSelPaperNo.Text.Trim(), ref sbPaperNo);

        DataTable data = SPHelper.callWAQuery(context, "QueryWarnCustomer",
                sbCustName.ToString(), selslPaperType.SelectedValue, sbPaperNo.ToString());

        CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "PAPERNO" }));

        if (data.Rows.Count == 0)
        {
            context.AddMessage("查询结果为空");
        }
        UserCardHelper.resetData(gvResult, data);
    }

    private void validate()
    {

        // 证件类型不能为空
        if (selInPaperType.SelectedValue == "")
        {
            context.AddError("A094780051:证件类型不能为空", selInPaperType);
        }

        //证件号码
        if (txtInPaperNo.Text.Trim() == "")
        {
            context.AddError("A094780052:证件号码不能为空", txtInPaperNo);
        }
        else if(txtInPaperNo.Text.Trim().Length>20)
        {
            context.AddError("A094780055:证件号码长度不能超过20位", txtInPaperNo);
        }
        else if (selInPaperType.SelectedValue == "00"&& !Validation.isPaperNo(txtInPaperNo.Text.Trim()))
            context.AddError("A094780056:证件号码验证不通过", txtInPaperNo);

        //姓名
        if (txtInName.Text.Trim() != "")
        {
            if (txtInName.Text.Trim().Length > 50)
            {
                context.AddError("A094780053:姓名长度不能超过25位", txtInName);
            }
        }

        if (txtCustbirth.Text.Trim() != "")
        {
            if (!Validation.isDate(txtCustbirth.Text.Trim(), "yyyyMMdd"))
            {
                context.AddError("A094780054:出生日期格式不正确", txtCustbirth);
            }
        }
    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        StringBuilder strBuilder = new StringBuilder();

        context.SPOpen();
        context.AddField("p_funcCode").Value = "Add";
        context.AddField("p_paperTypeCode").Value = selInPaperType.SelectedValue;

        AESHelp.AESEncrypt(txtInPaperNo.Text.Trim(), ref strBuilder);
        context.AddField("p_paperNo").Value = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtInName.Text.Trim(), ref strBuilder);
        context.AddField("p_custName").Value = strBuilder.ToString();

        context.AddField("p_custSex").Value = selCustsex.SelectedValue;

        context.AddField("p_custBir").Value = txtCustbirth.Text.Trim();

        bool ok = context.ExecuteSP("SP_WA_WarnCustomer");
        btnQuery_Click(sender, e);

        if (ok) AddMessage("新增恐怖分子黑名单成功");
    }

    protected void btnMod_Click(object sender, EventArgs e)
    {
        validate();

        if (selInPaperType.SelectedValue != hidPaperType.Value || txtInPaperNo.Text != hidPaperNo.Value)
        {
            context.AddError("S094780054:证件类型和证件号码不能修改");
        }

        if (context.hasError()) return;

        StringBuilder strBuilder = new StringBuilder();

        context.SPOpen();
        context.AddField("p_funcCode").Value = "Mod";
        context.AddField("p_paperTypeCode").Value = selInPaperType.SelectedValue;

        AESHelp.AESEncrypt(txtInPaperNo.Text.Trim(), ref strBuilder);
        context.AddField("p_paperNo").Value = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtInName.Text.Trim(), ref strBuilder);
        context.AddField("p_custName").Value = strBuilder.ToString();

        context.AddField("p_custSex").Value = selCustsex.SelectedValue;

        context.AddField("p_custBir").Value = txtCustbirth.Text.Trim();

        bool ok = context.ExecuteSP("SP_WA_WarnCustomer");
        btnQuery_Click(sender, e);

        if (ok) AddMessage("修改恐怖分子黑名单成功");
    }

    protected void btnDel_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        StringBuilder strBuilder = new StringBuilder();

        context.SPOpen();
        context.AddField("p_funcCode").Value = "Del";
        context.AddField("p_paperTypeCode").Value = selInPaperType.SelectedValue;

        AESHelp.AESEncrypt(txtInPaperNo.Text.Trim(), ref strBuilder);
        context.AddField("p_paperNo").Value = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtInName.Text.Trim(), ref strBuilder);
        context.AddField("p_custName").Value = strBuilder.ToString();

        context.AddField("p_custSex").Value = selCustsex.SelectedValue;

        context.AddField("p_custBir").Value = txtCustbirth.Text.Trim();

        bool ok = context.ExecuteSP("SP_WA_WarnCustomer");

        btnQuery_Click(sender, e);

        if (ok) AddMessage("删除恐怖分子黑名单成功");
    }

    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        // 得到选择行
        GridViewRow selectRow = gvResult.SelectedRow;
        hidPaperType.Value = selectRow.Cells[2].Text;
        hidPaperNo.Value = selectRow.Cells[4].Text;

        selInPaperType.SelectedValue = selectRow.Cells[2].Text == "&nbsp;" ? "00" : selectRow.Cells[2].Text;
        txtInPaperNo.Text = selectRow.Cells[4].Text == "&nbsp;" ? "" : selectRow.Cells[4].Text;
        txtInName.Text = selectRow.Cells[1].Text == "&nbsp;" ? "" : selectRow.Cells[1].Text;
        selCustsex.SelectedValue = selectRow.Cells[5].Text.Trim() == "男" ? "0" : "1";
        txtCustbirth.Text = selectRow.Cells[6].Text == "&nbsp;" ? "" : selectRow.Cells[6].Text;

    }

    public void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[2].Visible = false;
        }
    }

    private void ClearControl()
    {
        selInPaperType.SelectedValue = "";
        txtInPaperNo.Text = "";
        txtInName.Text = "";
        selCustsex.SelectedValue = "";
        txtCustbirth.Text = "";
    }

    // gridview换页事件
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
}
