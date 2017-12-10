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
using PDO.SpecialDeal;
using Common;
using TM;
using PDO.Warn;

public partial class ASP_Warn_WA_WarnManage : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 显示空列表表头
        UserCardHelper.resetData(gvResult, null);
        UserCardHelper.resetData(gridDetail, null);

        // 初始化下拉选项
        SPHelper.fillDDL(context, selCond, true, "SP_WA_Query", "WarnCondDDL");
        SPHelper.fillDDL(context, selType, true, "SP_WA_Query", "WarnTypeDDL");

        selSrc.Items.Add(new ListItem("---请选择---", ""));
        selSrc.Items.Add(new ListItem("0:全局条件", "0"));
        selSrc.Items.Add(new ListItem("1:黑名单", "1"));
        selSrc.Items.Add(new ListItem("2:监控名单", "2"));

        SPHelper.fillDDL(context, selMonCond, true, "SP_WA_Query", "WarnCondDDL", "1");
        // SPHelper.fillDDL(context, selMonType, true, "SP_WA_Query", "WarnTypeDDL");
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string cardNO = e.Row.Cells[3].Text;
           
            if(isCardInTable(cardNO,"isCardInBlackTab"))
                e.Row.Cells[3].CssClass = "black";
            else if (isCardInTable(cardNO, "isCardInMonitorTab"))
                e.Row.Cells[3].CssClass = "monitor";
        }

    }

    private bool isCardInTable(string cardNO, string queryWhat)
    {
        SP_QueryPDO pdo = new SP_QueryPDO("SP_WA_Query");

        SPHelper.callQuery(pdo, context, queryWhat, cardNO);

        int count = Convert.ToInt32(pdo.var8);

        return (count > 0);
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        txtCardNO.Text = "";
        selCond.SelectedIndex = 0;
        selType.SelectedIndex = 0;
        selSrc.SelectedIndex = 0;
        txtLevel.Text = "";
        txtDetails.Text = "";
        txtTimespan.Text = "";
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!QueryValidation())
        {
            UserCardHelper.resetData(gvResult, null);
            return;
        }

        //取得查询结果
        DataTable dataView = QueryWarns();

        if (dataView.Rows.Count == 0)
        {
            AddMessage("N007P00001: 查询结果为空");
            UserCardHelper.resetData(gvResult, null);
            return;
        }

        gvResult.DataSource = dataView;
        gvResult.DataBind();

        UserCardHelper.resetData(gridDetail, null);
    }

    private DataTable QueryWarns()
    {
        DataTable data = SPHelper.callWAQuery(context, "QueryWarnTable",
            txtCardNO.Text, selCond.SelectedValue, 
            selType.SelectedValue, selSrc.SelectedValue,
            txtLevel.Text, txtDetails.Text, txtTimespan.Text);
        labCnt.Text = "" + data.Rows.Count;

        return data;
    }

    private bool QueryValidation()
    {
        UserCardHelper.validateCardNo(context, txtCardNO, true);

        if (txtLevel.Text.Trim() != "" && !isNoNegativeInteger(txtLevel.Text))
            context.AddError("A860400001", txtLevel);
        if (txtDetails.Text.Trim() != "" && !isNoNegativeInteger(txtDetails.Text))
            context.AddError("A860400002", txtDetails);
        if (txtTimespan.Text.Trim() != "" && !isNoNegativeFloat(txtTimespan.Text))
            context.AddError("A860400003", txtTimespan);

        return !context.hasError();
    }

    private Boolean isNoNegativeInteger(string strInput)
    {
        System.Text.RegularExpressions.Regex reg1
            = new System.Text.RegularExpressions.Regex("^\\d+$");
        return reg1.IsMatch(strInput);
    }

    private Boolean isNoNegativeFloat(string strInput)
    {
        System.Text.RegularExpressions.Regex reg1
            = new System.Text.RegularExpressions.Regex("^\\d+(\\.\\d+)?$");
        return reg1.IsMatch(strInput);
    }



    protected void checkAll_CheckedChanged(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            if (!gvr.Cells[1].Enabled) continue;
            CheckBox ch = (CheckBox)gvr.FindControl("checkItem");
            ch.Checked = cbx.Checked;
        }
    }

    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        btnMonCancel_Click(sender, e);

        GridViewRow selectRow = gvResult.SelectedRow;

        DataTable data = SPHelper.callWAQuery(context, "QueryWarnDetail",
            selectRow.Cells[3].Text);

        labDetailCnt.Text = "" + data.Rows.Count;

        gridDetail.DataSource = data;
        gridDetail.DataBind();
    }

    //protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    //{
    //    if (e.Row.RowType == DataControlRowType.DataRow)
    //    {
    //        //注册行双击事件
    //        e.Row.Attributes.Add("ondblclick", 
    //            "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
    //    }
    //}

    protected void btnClose_Click(object sender, EventArgs e)
    {
        clearCardTempTable();

        if (insertCardNOToTmpTable() <= 0)
        {
            context.AddError("A860400101: 未选中任何告警");
            return;
        }

        SP_WA_WarnManagePDO pdo = new SP_WA_WarnManagePDO();
        pdo.funcCode = "Close";
        pdo.backWhy = "0"; // 关闭
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok) AddMessage("D860400001: 告警关闭成功");

        btnQuery_Click(sender, e);

        clearCardTempTable();
    }
    
    protected void btnBlack_Click(object sender, EventArgs e)
    {
        clearCardTempTable();

        if (insertCardNOToTmpTable() <= 0)
        {
            context.AddError("A860400101: 未选中任何告警");
            return;
        }

        SP_WA_WarnManagePDO pdo = new SP_WA_WarnManagePDO();
        pdo.funcCode = "Black";
        pdo.backWhy = "1"; // 黑名单
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok) AddMessage("D860400002: 账户入黑名单成功");

        btnQuery_Click(sender, e);

        clearCardTempTable();
    }
    
    protected void btnMonitor_Click(object sender, EventArgs e)
    {
        area2.Visible = true;
        area1.Visible = false;
    }

    protected void btnMonCancel_Click(object sender, EventArgs e)
    {
        area2.Visible = false;
        area1.Visible = true;
    }

    protected void btnMonSubmit_Click(object sender, EventArgs e)
    {
        if (!monSubmitValidation())
            return;

        clearCardTempTable();

        if (insertCardNOToTmpTable() <= 0)
        {
            context.AddError("A860400101: 未选中任何告警");
            return;
        }

        SP_WA_WarnManagePDO pdo = new SP_WA_WarnManagePDO();
        pdo.funcCode = "Monitor";
        pdo.condCode = selMonCond.SelectedValue;
        // pdo.warnType = selMonType.SelectedValue;
        pdo.warnLevel = txtMonLevel.Text;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok) AddMessage("D860400003: 入监控名单成功");

        btnQuery_Click(sender, e);

        clearCardTempTable();
    }

    private bool monSubmitValidation()
    {
        if (selMonCond.SelectedIndex <= 0)
            context.AddError("A860400004", selMonCond);
        //if (selMonType.SelectedIndex <= 0)
        //    context.AddError("A860400005", selMonType);
        if (txtMonLevel.Text.Trim() == "" || !isNoNegativeFloat(txtMonLevel.Text))
            context.AddError("A860400001", txtMonLevel);

        return !context.hasError();
    }

    // 业务转发
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "Close")
        {
            btnClose_Click(sender, e);
        }
        else if (hidWarning.Value == "Black")
        {
            btnBlack_Click(sender, e);
        }
        else if (hidWarning.Value == "MonitorSubmit")
        {
            btnMonSubmit_Click(sender, e);
        }

        hidWarning.Value = "";
    }

    private void clearCardTempTable()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_WARN_TODAYCARDS1");
        context.DBCommit();
    }

    private int insertCardNOToTmpTable()
    {
        int count = 0;

        context.DBOpen("Insert");

        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("checkItem");

            if (cb != null && cb.Checked)
            {
                ++count;
                context.ExecuteNonQuery(
                    "insert into TMP_WARN_TODAYCARDS1 values('"
                    + gvr.Cells[3].Text + "')");
            }
        }

        if (context.hasError())
        {
            context.RollBack();
            return 0;
        }

        context.DBCommit();
        return count;
    }

    private string GridViewSortDirection
    {
        get { return ViewState["SortDirection"] as string ?? "ASC"; }
        set { ViewState["SortDirection"] = value; }
    }

    private string GridViewSortExpression
    {
        get { return ViewState["SortExpression"] as string ?? string.Empty; }
        set { ViewState["SortExpression"] = value; }
    }

    private string GetSortDirection()
    {
        switch (GridViewSortDirection)
        {
            case "ASC":
                GridViewSortDirection = "DESC";
                break;
            case "DESC":
                GridViewSortDirection = "ASC";
                break;
        }
        return GridViewSortDirection;
    }

    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        btnQuery_Click(sender, e);
        
        gvResult.DataSource = SortDataTable(gvResult.DataSource as DataTable, true);
        gvResult.PageIndex = e.NewPageIndex;
        gvResult.DataBind();
    }

    protected DataView SortDataTable(DataTable dataTable, bool isPageIndexChanging)
    {
        if (dataTable == null)
        {
            return new DataView();
        }

        DataView dataView = new DataView(dataTable);
        if (GridViewSortExpression != string.Empty)
        {
            dataView.Sort = string.Format("{0} {1}", GridViewSortExpression,
                isPageIndexChanging ? GridViewSortDirection : GetSortDirection());
        }
        return dataView;
    }

    protected void gvResult_Sorting(object sender, GridViewSortEventArgs e)
    {
        btnQuery_Click(sender, e);

        GridViewSortExpression = e.SortExpression;
        int pageIndex = gvResult.PageIndex;
        gvResult.DataSource = SortDataTable(gvResult.DataSource as DataTable, false);
        gvResult.DataBind();
        gvResult.PageIndex = pageIndex;
    }


}
