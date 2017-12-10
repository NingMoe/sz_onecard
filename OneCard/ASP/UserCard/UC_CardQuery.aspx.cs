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
using Master;
using Common;
using TM;
using TDO.ResourceManager;
using TDO.CardManager;
using System.Text;
using PDO.UserCard;

// 用户卡查询处理
public partial class ASP_UserCard_UC_CardQuery : Master.Master
{
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

    protected void gvResult_PageIndexChanging(object sender, GridViewPageEventArgs e)
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

    // 提交前的输入校验
    private void SubmitValidate()
    {
        if (txtCardPrice.Text.Trim() != "")
        {
            UserCardHelper.validatePrice(context, txtCardPrice, "A002P01009: 卡片单价不能为空", "A002P01010: 卡片单价必须是10.2的格式");
        }
        // 对起始卡号和结束卡号进行校验
        UserCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo, false, true);
    }

    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        //从资源状态编码表(TD_M_RESOURCESTATE)中读取数据，放入下拉列表中
        UserCardHelper.selectResState(context, selCardStat, true);

        //从COS类型编码表(TD_M_COSTYPE)中读取数据，放入下拉列表中
        UserCardHelper.selectCosType(context, selCosType, true);

        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据，放入下拉列表中
        UserCardHelper.selectCardType(context, selCardType, true);

        //从厂商编码表(TD_M_MANU)中读取数据，放入下拉列表中
        UserCardHelper.selectManu(context, selProducer, true);

        //从IC卡卡面编码表(TD_M_CARDSURFACE)中读取数据，放入下拉列表中
        UserCardHelper.selectCardFace(context, selFaceType, true);

        //从IC卡芯片类型编码表(TD_M_CARDCHIPTYPE)中读取数据，放入下拉列表中
        UserCardHelper.selectChipType(context, selChipType, true);

        string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
        if (dBalunitNo != "")//add by liuhe20120214添加对代理的权限处理
        {
            selDepts.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
            selDepts.SelectedValue = context.s_DepartID;
            selDepts.Enabled = false;

            UserCardHelper.selectStaffs(context, selStaffs, selDepts, true);
            selStaffs.SelectedValue = context.s_UserID;
        }
        else
        {
            // 部门
            UserCardHelper.selectDepts(context, selDepts, true);
            // 员工
            UserCardHelper.selectStaffs(context, selStaffs, selDepts, true);
        }
        UserCardHelper.resetData(gvResult, null);
    }

    // gridview分页处理
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    protected void btnShowCond_Click(object sender, EventArgs e)
    {
        panCond.Visible = btnShowCond.Text == "更多条件>>";
        btnShowCond.Text = panCond.Visible ? "更多条件<<" : "更多条件>>";
    }


    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        // 输入判断处理
        SubmitValidate();
        if (context.hasError()) return;

        // 从用户卡资料表中根据条件进行查询
        SP_UC_QueryPDO pdo = new SP_UC_QueryPDO();
        pdo.funcCode = "CardInfoQuery";
        pdo.var1 = txtFromCardNo.Text.Trim();
        pdo.var2 = txtToCardNo.Text.Trim();
        pdo.var3 = selStaffs.SelectedValue;
        pdo.var4 = selCardStat.SelectedValue;
        pdo.var5 = selCosType.SelectedValue;
        pdo.var6 = selProducer.SelectedValue;
        pdo.var7 = selCardType.SelectedValue;
        pdo.var8 = selFaceType.SelectedValue;
        pdo.var9 = selChipType.SelectedValue;
        pdo.var10 = selDepts.SelectedValue;
        pdo.var11 = txtCardPrice.Text;

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        UserCardHelper.resetData(gvResult, data);
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        SP_UC_QueryPDO pdo = new SP_UC_QueryPDO();
        pdo.funcCode = "CardUseArea";
        StoreProScene storePro = new StoreProScene();
        DataTable data;

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[2].Text == "06")
            {
                pdo.var1 = e.Row.Cells[0].Text;
                data = storePro.Execute(context, pdo);
                e.Row.Cells[2].Text = "" + data.Rows[0].ItemArray[0];
            }
            else
            {
                e.Row.Cells[2].Text = "";
            }
        }
    }
    protected void selDepts_SelectedIndexChanged(object sender, EventArgs e)
    {
        // 员工
        UserCardHelper.selectStaffs(context, selStaffs, selDepts, true);
    }
}
