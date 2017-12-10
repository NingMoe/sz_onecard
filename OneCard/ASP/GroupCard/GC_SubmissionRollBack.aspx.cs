using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using TM;
using TDO.UserManager;
using Common;
using TDO.CustomerAcc;

public partial class ASP_GroupCard_GC_SubmissionRollBack : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
        //初始化部门

        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
        TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
        ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
        //selDept.SelectedValue = context.s_DepartID;
        InitStaffList(context.s_DepartID);
        //selStaff.SelectedValue = context.s_UserID;
        gvOrderList.DataKeyNames = new string[] { "ORDERNO", "GROUPNAME", "NAME", "PHONE", "IDCARDNO", "TOTALMONEY", 
            "TRANSACTOR", "INPUTTIME", "FINANCEAPPROVERNO",  "financeremark",
            "ORDERSTATE","REMARK","cashgiftmoney","CUSTOMERACCMONEY"};
    }

    private void InitStaffList(string deptNo)
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
                GroupCardHelper.fill(selStaff, table, true);
                return;
            }
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";
            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);
            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
            selStaff.SelectedValue = context.s_UserID;
        }
        else
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";
            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
    }

    //查询单位名称
    protected void queryCompany(object sender, EventArgs e)
    {
        OrderHelper.queryCompany(context, txtCompany, selCompany);
    }

    /// <summary>
    /// 查询验证
    /// </summary>
    /// <returns></returns>
    private bool ValidInput()
    {
        //校验单位名称长度
        if (!string.IsNullOrEmpty(txtCompany.Text.Trim()))
        {
            if (txtCompany.Text.Trim().Length > 50)
            {
                context.AddError("单位名称长度不能超过50个字符长度");
            }
        }
        //校验联系人长度

        if (!string.IsNullOrEmpty(txtName.Text.Trim()))
        {
            if (txtName.Text.Trim().Length > 50)
            {
                context.AddError("联系人长度不能超过25个字符长度");
            }
        }

        if (txtTotalMoney.Text.Trim().Length > 0) //金额不为空时
        {
            if (!Validation.isPrice(txtTotalMoney.Text.Trim()))
            {
                context.AddError("金额输入不正确", txtTotalMoney);
            }
            else if (Convert.ToDecimal(txtTotalMoney.Text.Trim()) <= 0)
            {
                context.AddError("金额必须是正数", txtTotalMoney);
            }
        }
        //对开始日期和结束日期的判断

        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, false);
        return !(context.hasError());
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!ValidInput())
        {
            return;
        }
        string groupName = txtCompany.Text.Trim();
        string name = txtName.Text.Trim();
        string staff = "";
        if (selStaff.SelectedIndex > 0)
        {
            staff = selStaff.SelectedValue;
        }
        string money = "";
        if (txtTotalMoney.Text.Trim().Length > 0)
        {
            money = (Convert.ToDecimal(txtTotalMoney.Text.Trim()) * 100).ToString();
        }
        string fromDate = txtFromDate.Text.Trim();
        string endDate = txtToDate.Text.Trim();

        DataTable dt = GroupCardHelper.callOrderQuery(context, "ConfirmOrderQuery", groupName, name, staff, money, fromDate, endDate, selDept.SelectedValue, context.s_DepartID);
        if (dt == null || dt.Rows.Count < 1)
        {
            gvOrderList.DataSource = new DataTable();
            gvOrderList.DataBind();
            context.AddError("未查出领用完成的记录");
            return;
        }
        gvOrderList.DataSource = dt;
        gvOrderList.DataBind();
    }

    protected void gvOrderList_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvOrderList','Select$" + e.Row.RowIndex + "')");
        }
    }

    protected void gvOrderList_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择员工GRIDVIEW中的一行记录

        string orderno = getDataKeys2("ORDERNO");
        ViewState["orderno"] = orderno;
        string groupName = getDataKeys2("GROUPNAME");
        string name = getDataKeys2("NAME");
        string phone = getDataKeys2("PHONE");
        string idCardNo = getDataKeys2("IDCARDNO");
        string totalMoney = getDataKeys2("TOTALMONEY");
        string transactor = getDataKeys2("TRANSACTOR");
        string remark = getDataKeys2("REMARK");
        string totalCashGiftChargeMoney = getDataKeys2("cashgiftmoney");
        string customeraccmoney = getDataKeys2("CUSTOMERACCMONEY");
        string financeRemark = getDataKeys2("financeremark");
        string approver = getDataKeys2("FINANCEAPPROVERNO");
        divInfo.InnerHtml = OrderHelper.GetOrderHtmlString(context, orderno, groupName,
            name, phone, idCardNo, totalMoney, transactor,
            remark, "0", financeRemark, totalCashGiftChargeMoney, approver, customeraccmoney, "", "", false, false);
    }

    public String getDataKeys2(String keysname)
    {
        return gvOrderList.DataKeys[gvOrderList.SelectedIndex][keysname].ToString();
    }

    protected void btnRollBack_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        if (gvOrderList.SelectedIndex < 0)
        {
            context.AddError("A007P02020: 请选择一个订单");
            return;
        }
        string orderno = getDataKeys2("ORDERNO");
        context.SPOpen();
        context.AddField("p_orderNo").Value = orderno;
        bool ok = context.ExecuteSP("SP_GC_SubmissionRollBack");
        if (ok)
        {
            context.AddMessage("A007P02021:订单完成确认返销成功");
            btnQuery_Click(sender, e);
        }
    }

}