using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Master;
using Common;
using TM;
using TDO.ResourceManager;
using TDO.CardManager;
using System.Text;
using PDO.UserCard;
using System.Data;
using TDO.UserManager;
using System.Collections;


public partial class ASP_AddtionalService_AS_SZTravelCardRecycleHistory : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            ShowNonDataGridView();
            Init_Page();

        }
    }
    /// <summary>
    /// 页面初始化


    /// </summary>
    protected void Init_Page()
    {

        //初始化日期


        DateTime date = new DateTime();
        date = DateTime.Today;
        txtFromDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");
        //初始化部门


        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
        TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
        ControlDeal.SelectBoxFill(selOriginalDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
        ControlDeal.SelectBoxFill(selNowDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);

        //初始化员工


        InitStaffList(selOriginalStaffs, context.s_DepartID);
        //InitStaffList(selOriginalStaffs, "");
        InitStaffList(selNowStaffs, context.s_DepartID);
        InitStaffList(ddlOperater, context.s_DepartID);
    }
    /// <summary>
    /// 初始化员工下拉选框
    /// </summary>
    /// <param name="ddl">控件名称</param>
    /// <param name="deptNo">部门编码</param>
    private void InitStaffList(DropDownList ddl, string deptNo)
    {
        if (deptNo == "")
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);
            ControlDeal.SelectBoxFill(ddl.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);

        }
        else
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
            ControlDeal.SelectBoxFill(ddl.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
    }
    /// <summary>
    /// 初始化列表


    /// </summary>
    private void ShowNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //查询输入校验
        if (!queryValidation()) return;
        gvResult.DataSource = query();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }
    /// <summary>
    /// 查询有效性校验


    /// </summary>
    /// <returns></returns>
    protected bool queryValidation()
    {
        //对开始日期和结束日期的判断


        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, false);
        //卡号输入判断
        if (!string.IsNullOrEmpty(txtcardNo.Text.Trim()))
        {
            if (Validation.strLen(txtcardNo.Text.Trim()) != 16)
                context.AddError("A094570211：卡号长度必须为16位", txtcardNo);
            else if (!Validation.isNum(txtcardNo.Text.Trim()))
                context.AddError("A094570212:卡号必须为数字", txtcardNo);
        }
        return !(context.hasError());
    }
    /// <summary>
    /// 查询统计
    /// </summary>
    /// <returns></returns>
    private ICollection query()
    {
        DataTable data = SPHelper.callQuery("SP_AS_Query", context, "TravelRecycleHistory", selOriginalDept.SelectedValue, selOriginalStaffs.SelectedValue, selNowDept.SelectedValue, selNowStaffs.SelectedValue,
            txtFromDate.Text.Trim(), txtToDate.Text.Trim(), ddlOperater.SelectedValue);
        return new DataView(data);
    }
    /// <summary>
    /// 查询明细
    /// </summary>
    /// <returns></returns>
    //private ICollection queryDetail()
    //{
    //    DataTable data = SPHelper.callQuery("SP_CG_Query", context, "CashGiftHistoryDetail",);
    //    return new DataView(data);
    //}
    protected void selOriginalDepts_SelectedIndexChanged(object sender, EventArgs e)
    {
        InitStaffList(selOriginalStaffs, selOriginalDept.SelectedValue);
    }
    protected void selNowDept_SelectedIndexChanged(object sender, EventArgs e)
    {
        InitStaffList(selNowStaffs, selNowDept.SelectedValue);
    }
    //统计分页
    //protected void gvUseCardOrder_Page(object sender, GridViewPageEventArgs e)
    //{
    //    gvResult.PageIndex = e.NewPageIndex;
    //    btnQuery_Click(sender,e);
    //}

    //明细分页
    protected void gvDetail_Page(object sender, GridViewPageEventArgs e)
    {
        gvResultDetail.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件


            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    /// <summary>
    /// 选择行


    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        GridViewRow row = gvResult.SelectedRow;
        if (row != null)
        {
            DataTable dt = SPHelper.callQuery("SP_AS_Query", context, "TravelRecycleHistoryDetail", row.Cells[0].Text.Trim().Substring(0, 4), row.Cells[1].Text.Trim().Substring(0, 6), row.Cells[2].Text.Trim().Substring(0, 4), row.Cells[3].Text.Trim().Substring(0, 6));
            gvResultDetail.DataSource = dt;
            gvResultDetail.DataBind();
            gvResultDetail.SelectedIndex = -1;
        }
    }
    private int operCount = 0;
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            operCount += Convert.ToInt32(GetTableCellValue(e.Row.Cells[4])); ;
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[4].Text = operCount.ToString();
        }
    }
    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }
}