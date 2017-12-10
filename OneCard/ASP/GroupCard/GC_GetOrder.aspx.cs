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
using System.Collections;

public partial class ASP_GroupCard_GC_GetOrder : Master.Master
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
        //初始化经办人
        InitStaffList(selOperator, context.s_DepartID);
        //selOperator.SelectedValue = context.s_UserID;
        //初始化日期

        DateTime date = new DateTime();
        date = DateTime.Today;
        txtFromDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");
        //初始化订单表
        gvOrderList.DataSource = new DataTable();
        gvOrderList.DataBind();
        gvOrderList.DataKeyNames = new string[] { "ORDERNO", "GROUPNAME", "NAME", "PHONE", "IDCARDNO", "TOTALMONEY", 
            "TRANSACTOR", "INPUTTIME", "FINANCEAPPROVERNO",  "financeremark",
            "ORDERSTATE","REMARK","cashgiftmoney","CUSTOMERACCMONEY"};
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
    private void InitStaffList(DropDownList selStaffno, string deptNo)
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
                GroupCardHelper.fill(selStaffno, table, true);

                return;
            }

            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);
            ControlDeal.SelectBoxFill(selStaffno.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
            selStaffno.SelectedValue = context.s_UserID;
        }
        else
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
            ControlDeal.SelectBoxFill(selStaffno.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
    }

    /// <summary>
    /// 部门选择时间，查询部门所属员工

    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selOperator, selDept.SelectedValue);
    }

    /// <summary>
    /// 查询
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!ValidInput()) return;
        gvOrderList.DataSource = query();
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
        //校验对方帐号长度
        if (!string.IsNullOrEmpty(txtOutbank.Text.Trim()))
        {
            if (txtOutbank.Text.Trim().Length > 100)
            {
                context.AddError("对方帐号长度不能超过100个字符长度");
            }
        }
        //校验对方户名长度
        if (!string.IsNullOrEmpty(txtOutacct.Text.Trim()))
        {
            if (txtOutacct.Text.Trim().Length > 50)
            {
                context.AddError("对方户名长度不能超过50个字符长度");
            }
        }
        //对开始日期和结束日期的判断

        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, false);
        return !(context.hasError());
    }
    private ICollection query()
    {
        string companyName = "";
        if (selCompany.SelectedItem != null && selCompany.SelectedIndex > 0)
        {
            companyName = selCompany.SelectedItem.Text;
        }
        else
        {
            companyName = txtGroupName.Text.Trim();
        }
        string money = "";
        if (txtTotalMoney.Text.Trim().Length > 0)
        {
            money = (Convert.ToDecimal(txtTotalMoney.Text.Trim()) * 100).ToString();
        }
        DataTable data = GroupCardHelper.callOrderQuery(context, "QueryOrderMadeCard", companyName, txtName.Text.Trim(),
             selOperator.SelectedValue, money, txtFromDate.Text.Trim(), txtToDate.Text.Trim(), selDept.SelectedValue, context.s_DepartID);
        if (data == null || data.Rows.Count < 1)
        {
            gvOrderList.DataSource = new DataTable();
            gvOrderList.DataBind();
            context.AddError("未查出已制卡完成的记录");
        }
        return new DataView(data);
    }
    /// <summary>
    /// 领卡
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnGetCard_Click(object sender, EventArgs e)
    {
        string sessionID = Session.SessionID;
        ValidSubmit();
        if (context.hasError())
            return;
        FillTempTable(sessionID);
        context.SPOpen();
        context.AddField("p_sessionID").Value = sessionID;
        bool ok = context.ExecuteSP("SP_GC_GetOrder");
        if (ok)
        {
            AddMessage("审批通过");
        }
        //清空临时表

        clearTempTable();
        btnQuery_Click(sender, e);  
    }
    /// <summary>
    /// 验证提交
    /// </summary>
    private void ValidSubmit()
    {
        int count = 0;
        for (int index = 0; index < gvOrderList.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvOrderList.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
            }

        }
        // 没有选中任何行，则返回错误

        if (count <= 0)
        {
            context.AddError("A004P03R01: 没有选中任何行");
        }
    }
    /// <summary>
    /// 数据插入临时表

    /// </summary>
    /// <param name="sessionID"></param>
    private void FillTempTable(string sessionID)
    {
        //记录入临时表
        context.DBOpen("Insert");
        for (int index = 0; index < gvOrderList.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvOrderList.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                string orderno = gvOrderList.Rows[index].Cells[1].Text.Trim();//订单编号

                //F0:订单编号，F1：SessionID
                context.ExecuteNonQuery(@"insert into TMP_ORDER (f0,f1)
                                values('" + orderno + "','" + sessionID + "')");
            }
        }
        context.DBCommit();
    }
    /// <summary>
    /// 清空临时表

    /// </summary>
    private void clearTempTable()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_ORDER");
        context.DBCommit();
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

        DataTable data = GroupCardHelper.callOrderQuery(context, "AccountSelectByOrderNo", orderno);
        if (data != null && data.Rows.Count > 0)
        {
            for (int i = 0; i < data.Rows.Count; i++)
            {
                financeRemark += "\r\n到账银行:" + data.Rows[i]["Toaccountbank"].ToString()
                        + ", 到账账号:" + data.Rows[i]["TOACCOUNTNUMBER"].ToString()
                        + ", 日期:" + data.Rows[i]["TRADEDATE"].ToString()
                        + ", 金额:" + data.Rows[i]["MONEY"].ToString() + "元</br>";
            }
        }
        divInfo.InnerHtml = OrderHelper.GetOrderHtmlString(context, orderno, groupName,
            name, phone, idCardNo, totalMoney, transactor,
            remark, "0", financeRemark, totalCashGiftChargeMoney, approver, customeraccmoney, "", "", false, false);
    }
    public String getDataKeys2(String keysname)
    {
        return gvOrderList.DataKeys[gvOrderList.SelectedIndex][keysname].ToString();
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
}