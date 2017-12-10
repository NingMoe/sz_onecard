using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TM;
using PDO.GroupCard;
using TDO.UserManager;
using System.Data;
using Master;

public partial class ASP_GroupCard_GC_OrderDailyReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
        //初始化制卡部门


        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
        TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
        //ControlDeal.SelectBoxFill(selMadeDepart.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);

        FIHelper.selectDept(context, selMadeDepart, true);
        selMadeDepart.SelectedValue = context.s_DepartID;
        //初始化制卡员工


        InitStaffList(selMadeCardStaff, context.s_DepartID);
        selMadeCardStaff.SelectedValue = context.s_UserID;

        //初始化客户经理部门


        ControlDeal.SelectBoxFill(selManagerDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
        selManagerDept.SelectedValue = context.s_DepartID;
        //初始化客户经理


        InitStaffList(selManager, context.s_DepartID);
        selManager.SelectedValue = context.s_UserID;

        //初始化录入员工


        InitStaffList(selInputStaff, "");
        //初始化日期


        DateTime date = new DateTime();
        date = DateTime.Today;
        txtFromDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");
        gvOrderList.DataSource = new DataTable();
        gvOrderList.DataBind();
    }
    private void InitStaffList(DropDownList ddl, string deptNo)
    {
        if (deptNo == "")
        {
            string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
            if (dBalunitNo != "")//add by liuhe20120214添加对代理的权限处理
            {
                context.DBOpen("Select");
                string sql = @"SELECT STAFFNAME,STAFFNO FROM TD_M_INSIDESTAFF 
                             WHERE DIMISSIONTAG ='1' AND  DEPARTNO IN 
                            (SELECT DEPARTNO FROM TD_DEPTBAL_RELATION WHERE DBALUNITNO='" + dBalunitNo + "' AND USETAG='1')";
                DataTable table = context.ExecuteReader(sql);
                GroupCardHelper.fill(ddl, table, true);
                return;
            }
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";
            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);
            ControlDeal.SelectBoxFill(ddl.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
            //ddl.SelectedValue = context.s_UserID;
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

    protected void selMadeDepart_Changed(object sender, EventArgs e)
    {
        InitStaffList(selMadeCardStaff, selMadeDepart.SelectedValue);
    }

    protected void managerDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selManager, selManagerDept.SelectedValue);
    }
    /// <summary>
    /// 单位名称选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void txtGroupName_Changed(object sender, EventArgs e)
    {
        OrderHelper.queryCompany(context, txtGroupName, selCompany);
    }
    /// <summary>
    /// 单位名称全称下拉选框选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void selCompany_Changed(object sender, EventArgs e)
    {
        txtGroupName.Text = selCompany.SelectedItem.ToString();
    }
    /// <summary>
    /// 查询验证
    /// </summary>
    /// <returns></returns>
    private bool ValidInput()
    {
        //对开始日期和结束日期的判断


        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, false);
        if (txtOrderNo.Text.Trim().Length > 0)  //订单号不为空时

        {
            if (Validation.strLen(txtOrderNo.Text.Trim()) > 20)
            {
                context.AddError("订单号长度不能超过16位", txtOrderNo);
            }
        }
        return !(context.hasError());
    }
    /// <summary>
    /// 查询
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!ValidInput()) return;
        string groupName = ""; //单位名称
        if (selCompany.SelectedItem != null && selCompany.SelectedIndex > 0)
        {
            groupName = selCompany.SelectedItem.Text;
        }
        else
        {
            groupName = txtGroupName.Text.Trim();
        }
        string name = txtName.Text.Trim();//联系人


        string inputstaff = "";
        if (selInputStaff.SelectedIndex > 0)
        {
            inputstaff = selInputStaff.SelectedValue;
        }
        string madedepart = "";
        if (selMadeDepart.Text.Trim().Length > 0)
        {
            madedepart = selMadeDepart.SelectedValue;
        }
        string madestaff = "";
        if (selMadeCardStaff.Text.Trim().Length > 0)
        {
            madestaff = selMadeCardStaff.SelectedValue;
        }
        string managerdept = "";//客户经理所属部门


        if (selManagerDept.SelectedIndex > 0)
        {
            managerdept = selManagerDept.SelectedValue;
        }
        string managerstaff = "";//客户经理
        if (selManager.SelectedIndex > 0)
        {
            managerstaff = selManager.SelectedValue;
        }
        string fromDate = txtFromDate.Text.Trim();
        string endDate = txtToDate.Text.Trim();
        string cardno = txtOrderNo.Text.Trim();
        DataTable dt = GroupCardHelper.callOrderQuery(context, "QueryOrderDailyReport", groupName, name, inputstaff, txtOrderNo.Text.Trim(), fromDate, endDate, madedepart, madestaff, managerdept, managerstaff,context.s_DepartID);
        if (dt == null || dt.Rows.Count < 1)
        {
            gvOrderList.DataSource = new DataTable();
            gvOrderList.DataBind();
            context.AddError("未查出订单记录");
            return;
        }
        gvOrderList.DataSource = dt;
        gvOrderList.DataBind();

    }
    protected void gvOrderList_Page(object sender, GridViewPageEventArgs e)
    {
        gvOrderList.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    /// <summary>
    /// 导出excel
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvOrderList.Rows.Count > 0)
        {
            gvOrderList.AllowPaging = false;//不分页导出Excel modifyde by youyue
            btnQuery_Click(sender, e);
            ExportGridView(gvOrderList);
            gvOrderList.AllowPaging = true;
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }
}