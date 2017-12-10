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
using Common;
using TM;
using PDO.GroupCard;
using TDO.UserManager;
using TDO.BusinessCode;

public partial class ASP_GroupCard_GC_OrderReturn : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        //初始化部门

        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
        TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
        ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
        selDept.SelectedValue = context.s_DepartID;
        InitStaffList(selStaff, context.s_DepartID);//初始化录入员工

        selStaff.SelectedValue = context.s_UserID;
        //gvOrderList.DataKeyNames = new string[] { "ORDERNO", "GROUPNAME", "NAME", "PHONE", "IDCARDNO", "TOTALMONEY", "TRANSACTOR", "INPUTTIME", "REMARK", "FINANCEREMARK", "INVOICECOUNT", "INVOICETOTALMONEY", "TOTALCHARGECASHGIFT", "approver" };
        InitStaffList(ddlApprover, "0001");//初始化审核员工

        //初始化日期

        DateTime date = new DateTime();
        date = DateTime.Today;
        txtFromDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");
        if (HasOperPower("201012")) //如果是部门主管，add by shil,20120604
        {
            //可以查看本部门员工


            selStaff.Enabled = true;
        }
        if (HasOperPower("201013")) //如果是公司主管，add by shil,20120604
        {
            //可以查看所有记录


            selStaff.Enabled = true;
            selDept.Enabled = true;
        }

        gvOrderList.DataKeyNames = new string[] { "ORDERNO", "GROUPNAME", "NAME", "PHONE", "IDCARDNO", "TOTALMONEY", 
            "TRANSACTOR", "INPUTTIME", "FINANCEAPPROVERNO", "FINANCEAPPROVERTIME", "financeremark",
            "ORDERSTATE","REMARK","cashgiftmoney","CUSTOMERACCMONEY"};

        ShowNonDataGridView();
    }

    private bool HasOperPower(string powerCode)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
        string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
        DataTable dataSupply = tmTMTableModule.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
        if (dataSupply.Rows.Count > 0)
            return true;
        else
            return false;
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
    /// <summary>
    /// 初始化列表

    /// </summary>
    private void ShowNonDataGridView()
    {
        gvOrderList.DataSource = new DataTable();
        gvOrderList.DataBind();
    }
    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selStaff, selDept.SelectedValue);
    }

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

        DataTable dt = GroupCardHelper.callOrderQuery(context, "AllOrderInfoSelectForReturn", groupName, name, staff, money, fromDate, endDate, selApprovalStatus.SelectedValue, ddlApprover.SelectedValue);
        if (dt == null || dt.Rows.Count < 1)
        {
            gvOrderList.DataSource = new DataTable();
            gvOrderList.DataBind();
            context.AddError("未查出订单记录");
            return;
        }
        gvOrderList.DataSource = dt;
        gvOrderList.DataBind();
        gvOrderList.SelectedIndex = -1;
    }

    /// <summary>
    /// 查询验证
    /// </summary>
    /// <returns></returns>
    private bool ValidInput()
    {
        //校验单位名称长度
        if (!string.IsNullOrEmpty(txtGroupName.Text.Trim()))
        {
            if (txtGroupName.Text.Trim().Length > 50)
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

    /// <summary>
    /// 查询公司名

    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void queryGroupName(object sender, EventArgs e)
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
    /// grid行创建事件

    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvOrderList_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvOrderList','Select$" + e.Row.RowIndex + "')");
        }
    }

    /// <summary>
    /// gridview行单击事件

    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvOrderList_SelectedIndexChanged(object sender, EventArgs e)
    {
        btnOrderReturn.Enabled = true;
        //选择员工GRIDVIEW中的一行记录

        string orderno = getDataKeys("ORDERNO");
        ViewState["orderno"] = orderno;
        string groupName = getDataKeys("GROUPNAME");
        string name = getDataKeys("NAME");
        string phone = getDataKeys("PHONE");
        string idCardNo = getDataKeys("IDCARDNO");
        string totalMoney = getDataKeys("TOTALMONEY");
        string transactor = getDataKeys("TRANSACTOR");
        string remark = getDataKeys("REMARK");
        string totalCashGiftChargeMoney = getDataKeys("cashgiftmoney");
        string customeraccmoney = getDataKeys("CUSTOMERACCMONEY");
        string financeRemark = getDataKeys("financeremark");
        string approver = getDataKeys("FINANCEAPPROVERNO");
        divInfo.InnerHtml = OrderHelper.GetOrderHtmlString(context, orderno, groupName,
            name, phone, idCardNo, totalMoney, transactor,
            remark, "0", financeRemark, totalCashGiftChargeMoney, approver, customeraccmoney, "", "", false, false);
    }

    /// <summary>
    /// 获取关键字

    /// </summary>
    /// <param name="keysname"></param>
    /// <returns></returns>
    public String getDataKeys(String keysname)
    {
        return gvOrderList.DataKeys[gvOrderList.SelectedIndex][keysname].ToString();
    }

    protected void btnOrderReturn_Click(object sender, EventArgs e)
    {
        if (gvOrderList.SelectedIndex < 0)
        {
            context.AddError("未选中任何行");
            return;
        }
        context.SPOpen();
        context.AddField("p_ORDERNO").Value = getDataKeys("ORDERNO"); // 订单号

        context.AddField("p_HASAPPROVAL").Value = getDataKeys("ORDERSTATE") == "01:录入待审核" ? "0" : "1"; //已审核

        bool ok = context.ExecuteSP("SP_GC_RETURNORDER");

        if (ok)
        {
            AddMessage("订单" + getDataKeys("ORDERNO") + "回退成功");

            btnOrderReturn.Enabled = false;
            btnQuery_Click(sender, e);
        }
    }
}