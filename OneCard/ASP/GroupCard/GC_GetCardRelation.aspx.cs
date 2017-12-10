using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TM;
using PDO.GroupCard;
using TDO.UserManager;
using TDO.BusinessCode;
using System.Data;
using Master;

public partial class ASP_GroupCard_GC_GetCardRelation : Master.Master
{
    
    //市民卡B卡datatable
    private DataTable SZTCardTable
    {
        set
        {
            ViewState["SZTCardTable"] = value;
        }
        get
        {
            return (DataTable)ViewState["SZTCardTable"];
        }
    }
    //利金卡datatable
    private DataTable CashGiftCardTable
    {
        set
        {
            ViewState["CashGiftCardTable"] = value;
        }
        get
        {
            return (DataTable)ViewState["CashGiftCardTable"];
        }
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
        //初始化日期
        DateTime date = new DateTime();
        date = DateTime.Today;
        txtFromDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");
        txtSaleFromDate.Text = DateTime.Today.ToString("yyyyMMdd");
        txtSaleToDate.Text = DateTime.Today.ToString("yyyyMMdd");
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
        TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
        ControlDeal.SelectBoxFill(selMakeDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);//初始化制卡部门
        InitStaffList(selMakeOperator, "");//初始化制卡员工
        ControlDeal.SelectBoxFill(ddlSaleDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);//初始化售卡部门
        InitStaffList(ddlSaleStaff, "");//初始化售卡员工
        ddlSaleDept.SelectedValue = context.s_DepartID;//默认售卡部门是当前操作员工部门
        gvOrderList.DataKeyNames = new string[] { "ORDERNO", "GROUPNAME", "NAME", "PHONE", "IDCARDNO", "TOTALMONEY","cashgiftmoney",
            "TRANSACTOR", "INPUTTIME","ORDERSTATE" ,"CHARGECARDMONEY","SZTCARDMONEY","CUSTOMERACCMONEY","CUSTOMERACCHASMONEY","readermoney","ISRELATED" };

        //市民卡B卡表格
        if (SZTCardTable == null)
        {
            SZTCardTable = new DataTable();
            DataColumn col1 = new DataColumn("FromCardNo");
            DataColumn col2 = new DataColumn("ToCardNo");
            DataColumn col3 = new DataColumn("SZTCardNum");
            SZTCardTable.Columns.Add(col1);
            SZTCardTable.Columns.Add(col2);
            SZTCardTable.Columns.Add(col3);
            DataRow row = SZTCardTable.NewRow();
            row["FromCardNo"] = null;
            row["ToCardNo"] = null;
            row["SZTCardNum"] = null;
            SZTCardTable.Rows.Add(row);
            gvSZTCard.DataSource = SZTCardTable;
            gvSZTCard.DataBind();
        }
        //利金卡表格
        if (CashGiftCardTable == null)
        {
            CashGiftCardTable = new DataTable();
            DataColumn col1 = new DataColumn("CashFromCardNo");
            DataColumn col2 = new DataColumn("CashToCardNo");
            DataColumn col4 = new DataColumn("CashCardNum");
            CashGiftCardTable.Columns.Add(col1);
            CashGiftCardTable.Columns.Add(col2);
            CashGiftCardTable.Columns.Add(col4);
            DataRow row = CashGiftCardTable.NewRow();
            row["CashFromCardNo"] = null;
            row["CashToCardNo"] = null;
            row["CashCardNum"] = null;
            CashGiftCardTable.Rows.Add(row);
            gvCashGiftCard2.DataSource = CashGiftCardTable;
            gvCashGiftCard2.DataBind();
        }
        makeCashGiftCard.Visible = false;
        makeSZTCard.Visible = false;
        btnComfirmNotRelation.Visible = false;
        hidCashValue.Value = "";
        hidCashLeftNum.Value = "";
        hidSZTValue.Value = "";
        hidSZTLeftNum.Value = "";
    }
    protected void gvOrderList_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvOrderList','Select$" + e.Row.RowIndex + "')");
        }
    }
    //分页
    protected void gvOrderList_Page(object sender, GridViewPageEventArgs e)
    {
        gvOrderList.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!ValidInput()) return;
        string orderno = txtOrderNo.Text.Trim();//订单号
        string groupName = ""; //单位名称
        groupName = txtGroupName.Text.Trim();
        string fromDate = txtFromDate.Text.Trim();
        string endDate = txtToDate.Text.Trim();
        DataTable dt = GroupCardHelper.callOrderQuery(context, "QueryCardRelationInfo", orderno, groupName, fromDate, endDate, selMakeDept.SelectedValue, selMakeOperator.SelectedValue);//查找需要补关联卡的订单
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
       
        //对开始日期和结束日期的判断
        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, false);
        return !(context.hasError());
    }
    protected void selMakeDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selMakeOperator, selMakeDept.SelectedValue);
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
    protected void gvOrderList_SelectedIndexChanged(object sender, EventArgs e)
    {
        int index = gvOrderList.SelectedIndex;
        divInfo.InnerHtml = GetOrderMakeOrComfirmHtml(getDataKeys2("ORDERNO", index), getDataKeys2("GROUPNAME", index), getDataKeys2("NAME", index),
          getDataKeys2("TOTALMONEY", index), getDataKeys2("ORDERSTATE", index), getDataKeys2("INPUTTIME", index), getDataKeys2("cashgiftmoney", index),
         getDataKeys2("SZTCARDMONEY", index), getDataKeys2("CHARGECARDMONEY", index), getDataKeys2("CUSTOMERACCMONEY", index), getDataKeys2("CUSTOMERACCHASMONEY", index), getDataKeys2("readermoney", index));
        showCashGiftCard.Value = getDataKeys2("cashgiftmoney", index) == "0" ? "0" : "1";
        showSZTCard.Value = getDataKeys2("SZTCARDMONEY", index)== "0" ? "0" : "1";
        gvCashGiftCard.DataSource = new DataTable();
        gvCashGiftCard.DataBind();
        //重置市民卡B卡
        SZTCardTable.Rows.Clear();
        DataRow sztcardrow = SZTCardTable.NewRow();
        sztcardrow["FromCardNo"] = null;
        sztcardrow["ToCardNo"] = null;
        sztcardrow["SZTCardNum"] = null;
        SZTCardTable.Rows.Add(sztcardrow);
        //重置利金卡
        CashGiftCardTable.Rows.Clear();
        DataRow cashcardrow = CashGiftCardTable.NewRow();
        cashcardrow["CashFromCardNo"] = null;
        cashcardrow["CashToCardNo"] = null;
        cashcardrow["CashCardNum"] = null;
        CashGiftCardTable.Rows.Add(cashcardrow);
        if (getDataKeys2("ORDERSTATE", index) == "10:领卡补关联") //完成领卡补关联的就允许显示确认不关联按钮
        {
            btnComfirmNotRelation.Visible = true;
            showCashGiftCard.Value = "0";//不显示利金卡
            showSZTCard.Value = "0";//不显示市民卡B卡
            makeCashGiftCard.Visible = false;
            makeSZTCard.Visible = false;

        }
        else
        {
            btnComfirmNotRelation.Visible = false;
            if (showCashGiftCard.Value == "1")
            {
                makeCashGiftCard.Visible = true;

            }
            else
            {
                makeCashGiftCard.Visible = false;
            }
            if (showSZTCard.Value == "1")
            {
                makeSZTCard.Visible = true;
                gvSZTCard.DataSource = SZTCardTable;
                gvSZTCard.DataBind();
            }
            else
            {
                makeSZTCard.Visible = false;
            }
        }
       
    }
    public string GetOrderMakeOrComfirmHtml(string orderno, string groupName, string name,
      string totalMoney, string orderstate, string inputtime, string cashgiftmoney, string sztcardmoney,
      string chargecardmoney, string customeraccmoney, string customeracchasmoney, string readermoney)
    {

        string CustomerAccHtml = "";
        string ChargeCardInfoHtml = GetOrderCashGiftInfoHtml(orderno);
        string SZTCardInfoHtml = GetOrderSZTCardInfoHtml(orderno);
        if (!string.IsNullOrEmpty(customeraccmoney))
        {
            CustomerAccHtml += "<tr><td colspan = '10'><hr></td></tr>";
            CustomerAccHtml += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>专有账户充值总金额:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>已充值金额:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'>未充值金额:</td>
		                                    <td> {2} </td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
                                        </tr>", customeraccmoney, customeracchasmoney,
                                              (Convert.ToDecimal(customeraccmoney) - Convert.ToDecimal(customeracchasmoney)).ToString());
        }
        string html = string.Format(@"<table border=0px cellpadding=0 cellspacing=0 width='100%' align='center' style='border-style:solid' class='data'>
	                                     <tr height=23px>
		                                    <td style='text-align:right' width ='12%'>单位名称:</td>
		                                    <td width ='18%'> {0} </td>
		                                    <td style='text-align:right' width ='10%'>联系人:</td>
		                                    <td width ='6%'> {1} </td>
		                                    <td style='text-align:right' width ='10%'>订单总金额:</td>
		                                    <td width ='6%'> {2}元 </td>
		                                    <td style='text-align:right' width ='10%'>订单状态:</td>
		                                    <td width ='8%'> {3} </td>
		                                    <td style='text-align:right' width ='10%'>录入时间:</td>
		                                    <td width ='10%'> {4} </td>
	                                     </tr>
                                         <tr height=23px>
		                                    <td style='text-align:right'>利金卡总金额:</td>
		                                    <td> {5} </td>
		                                    <td style='text-align:right'>苏州通卡总金额:</td>
		                                    <td> {6} </td>
		                                    <td style='text-align:right'>充值卡总金额:</td>
		                                    <td> {7} </td>
		                                    <td style='text-align:right'>专有账户总金额:</td>
		                                    <td> {8} </td>
		                                    <td style='text-align:right'>读卡器总金额:</td>
		                                    <td> {9} </td>
	                                     </tr>
                                           {10}
                                           {11}
                                    </table>", groupName, name, totalMoney, orderstate, inputtime, cashgiftmoney, sztcardmoney, chargecardmoney, customeraccmoney, readermoney,
                                             ChargeCardInfoHtml, SZTCardInfoHtml
                                             );
        
        return html;
    }

    

    public string GetOrderCashGiftInfoHtml(string orderno)
    {
        hidCashValue.Value = "";
        hidCashLeftNum.Value = "";
        //获取利金卡信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "CashOrderInfo", orderno);
        string html = "";
        if (data != null && data.Rows.Count > 0)
        { 
            string cashGiftType = "";
            string ordernum = "";
            string haveMakenum = "";
            string leftnum = "";
            html += "<tr><td colspan = '10'><hr></td></tr>";
            for (int i = 0; i < data.Rows.Count; i++)
            {
                cashGiftType = (Convert.ToInt32(data.Rows[i]["VALUE"].ToString()) / 100).ToString();
                ordernum = data.Rows[i]["COUNT"].ToString();
                haveMakenum = (Convert.ToInt32(data.Rows[i]["COUNT"].ToString()) - Convert.ToInt32(data.Rows[i]["LEFTQTY"].ToString())).ToString();
                leftnum = data.Rows[i]["LEFTQTY"].ToString();
                html += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>利金卡类型:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>订购数量:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'>已关联数量:</td>
		                                    <td> {2} </td>
		                                    <td style='text-align:right'>剩余数量:</td>
		                                    <td> {3} </td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
                                        </tr>", cashGiftType, ordernum, haveMakenum, leftnum);
               
                hidCashValue.Value += cashGiftType + ",";
                hidCashLeftNum.Value += leftnum + ",";
            }
        }
        return html;
    }
    public string GetOrderSZTCardInfoHtml(string orderno)
    {
        hidSZTValue.Value = "";
        hidSZTLeftNum.Value = "";
        hidSZTCardType.Value = "";
        //获取市民卡B卡信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "SZTCardOrderAllInfo", orderno);
        string html = "";
        if (data != null && data.Rows.Count > 0)
        {
            ////市民卡B卡面额和剩余数量二维数组
            //string[,] sztvaluenum = new string[data.Rows.Count, 2];
            string SZTType = "";
            string ordernum = "";
            string haveMakenum = "";
            string leftnum = "";
            string chargemoney = "";
            string totalmoney = "";//总金额
            html += "<tr><td colspan = '10'><hr></td></tr>";
            for (int i = 0; i < data.Rows.Count; i++)
            {
                SZTType = data.Rows[i]["CARDTYPECODE"].ToString() + ":" + data.Rows[i]["CARDSURFACENAME"].ToString();
                ordernum = data.Rows[i]["COUNT"].ToString();
                haveMakenum = (Convert.ToInt32(data.Rows[i]["COUNT"].ToString()) - Convert.ToInt32(data.Rows[i]["LEFTQTY"].ToString())).ToString();
                leftnum = data.Rows[i]["LEFTQTY"].ToString();
                totalmoney = (Convert.ToInt32(data.Rows[i]["TOTALMONEY"].ToString()) / 100.0).ToString();//总金额
                //单张充值金额
                if (ordernum.Trim() == "0")
                {
                    chargemoney = "0";
                }
                else
                {
                    chargemoney = (Convert.ToInt32(data.Rows[i]["TOTALCHARGEMONEY"].ToString())/ 100.0).ToString();//总充值金额
                }
                html += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>市民卡B卡类型:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>订购数量:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'>已关联数量:</td>
		                                    <td> {2} </td>
		                                    <td style='text-align:right'>剩余数量:</td>
		                                    <td> {3} </td>
		                                    <td style='text-align:right'>总充值金额</td>
		                                    <td> {4} </td>
                                        </tr>", SZTType, ordernum, haveMakenum, leftnum, chargemoney);
                hidSZTCardType.Value += SZTType.Substring(0, 4) + ",";
                if (!chargemoney.Equals("0"))//总充值金额不为0时
                {
                     hidSZTValue.Value += chargemoney + ",";
                }
                else
                {
                    hidSZTValue.Value += totalmoney + ",";
                }
                hidSZTLeftNum.Value += leftnum + ",";
            }
        }
        return html;
    }
    public String getDataKeys2(String keysname, int selectindex)
    {
        return gvOrderList.DataKeys[selectindex][keysname].ToString();
    }
    
    private void UpdateSZTCardTable()
    {
        for (int i = 0; i < gvSZTCard.Rows.Count; i++)
        {
            TextBox txtFromCardNo = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTFromCardNo");
            SZTCardTable.Rows[i]["FromCardNo"] = txtFromCardNo.Text;
            TextBox txtToCardNo = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTToCardNo");
            SZTCardTable.Rows[i]["ToCardNo"] = txtToCardNo.Text;
            TextBox txtNum = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardNum");
            SZTCardTable.Rows[i]["SZTCardNum"] = txtNum.Text;
        }
    }
    private void UpdateCashCardTable()
    {
        for (int i = 0; i < gvCashGiftCard2.Rows.Count; i++)
        {
            TextBox txtFromCardNo = (TextBox)gvCashGiftCard2.Rows[i].FindControl("txtCashFromCardNo");
            CashGiftCardTable.Rows[i]["CashFromCardNo"] = txtFromCardNo.Text;
            TextBox txtToCardNo = (TextBox)gvCashGiftCard2.Rows[i].FindControl("txtCashToCardNo");
            CashGiftCardTable.Rows[i]["CashToCardNo"] = txtToCardNo.Text;
            TextBox txtNum = (TextBox)gvCashGiftCard2.Rows[i].FindControl("txtCashCardNum");
            CashGiftCardTable.Rows[i]["CashCardNum"] = txtNum.Text;
        }
    }
   
    protected void gvSZTCard_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        UpdateSZTCardTable();
        if (e.CommandName == "delete")
        {
            int index = Convert.ToInt32(e.CommandArgument.ToString());
            SZTCardTable.Rows[index].Delete();
        }
    }
    protected void gvSZTCard_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        gvSZTCard.DataSource = SZTCardTable;
        gvSZTCard.DataBind();
    }
    protected void btnSZTCardAdd_Click(object sender, EventArgs e)
    {
        UpdateSZTCardTable();
        DataRow row = SZTCardTable.NewRow();
        row["FromCardNo"] = null;
        row["ToCardNo"] = null;
        row["SZTCardNum"] = null;
        SZTCardTable.Rows.Add(row);
        gvSZTCard.DataSource = SZTCardTable;
        gvSZTCard.DataBind();
    }
    protected void gvCashGiftCard2_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        UpdateCashCardTable();
        if (e.CommandName == "delete")
        {
            int index = Convert.ToInt32(e.CommandArgument.ToString());
            CashGiftCardTable.Rows[index].Delete();
        }
    }
    protected void gvCashGiftCard2_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        gvCashGiftCard2.DataSource = CashGiftCardTable;
        gvCashGiftCard2.DataBind();
    }
    protected void btnCashCardAdd_Click(object sender, EventArgs e)
    {
        UpdateCashCardTable();
        DataRow row = CashGiftCardTable.NewRow();
        row["CashFromCardNo"] = null;
        row["CashToCardNo"] = null;
        row["CashCardNum"] = null;
        CashGiftCardTable.Rows.Add(row);
        gvCashGiftCard2.DataSource = CashGiftCardTable;
        gvCashGiftCard2.DataBind();
    }
   
    //利金卡查询
    protected void btnCashGiftCardQuery_Click(object sender, EventArgs e)
    {
        if (!validCashInput()) return; 
        DataTable dt = GroupCardHelper.callOrderQuery(context, "QuerySaleCashGiftCard", ddlSaleDept.SelectedValue, ddlSaleStaff.SelectedValue, txtSaleFromDate.Text.Trim(), txtSaleToDate.Text.Trim(), txtCashGiftCardType.Text.Trim());
        if (dt == null || dt.Rows.Count < 1)
        {
            gvCashGiftCard.DataSource = new DataTable();
            gvCashGiftCard.DataBind();
            context.AddError("未查出订单记录");
            return;
        }
        gvCashGiftCard.DataSource = dt;
        gvCashGiftCard.DataBind();
    }
    private bool validCashInput()
    {
        if (txtCashGiftCardType.Text.Trim().Length > 0) //礼金卡面值不为空时
        {
            if (!Validation.isPrice(txtCashGiftCardType.Text.Trim()))
            {
                context.AddError("利金卡面值输入不正确", txtCashGiftCardType);
            }
            else if (Convert.ToDecimal(txtCashGiftCardType.Text.Trim()) <= 0)
            {
                context.AddError("利金卡面值必须是正数", txtCashGiftCardType);
            }
        }
        //对开始日期和结束日期的判断
        UserCardHelper.validateDateRange(context, txtSaleFromDate, txtSaleToDate, false);
        return !(context.hasError());
    }
    protected void gvCashGiftCard_Page(object sender, GridViewPageEventArgs e)
    {
        gvCashGiftCard.PageIndex = e.NewPageIndex;
        btnCashGiftCardQuery_Click(sender, e);
    }
    protected void ddlSaleDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(ddlSaleStaff, ddlSaleDept.SelectedValue);
    }
    /// <summary>
    /// 验证提交
    /// </summary>
    private void ValidSubmit()
    {
        int count = 0;
        for (int index = 0; index < gvCashGiftCard.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvCashGiftCard.Rows[index].FindControl("ItemCheckBox");
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
        for (int index = 0; index < gvCashGiftCard.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvCashGiftCard.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                string cardno = gvCashGiftCard.Rows[index].Cells[1].Text.Trim();//卡号
                string price = gvCashGiftCard.Rows[index].Cells[2].Text.Trim();//面值
                //F0：SessionID,F1:卡号，F2:面值
                context.ExecuteNonQuery(@"insert into TMP_ORDER (f0,f1,f2)
                                values('" + sessionID + "','" + cardno + "','" + price + "')");
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
    //关联礼金卡
    protected void btnCashGiftCardMake_Click(object sender, EventArgs e)
    {
        
        string sessionID = Session.SessionID;
        ValidSubmit();
        //清空临时表
        clearTempTable();
        string cardvalue = "";
        string leftnum = "";
        if (hidCashValue.Value != "" && hidCashLeftNum.Value != "")
        {
            cardvalue = hidCashValue.Value.Remove(hidCashValue.Value.LastIndexOf(","), 1);
            leftnum = hidCashLeftNum.Value.Remove(hidCashLeftNum.Value.LastIndexOf(","), 1);
        }
        string[] value = cardvalue.Split(',');
        string[] num = leftnum.Split(',');
        int length = value.Length;
        //利金卡面额和剩余数量二维数组
        string[,] cashvaluenum = new string[length, 2];
        for (int i = 0; i < length; i++)
        {
            cashvaluenum[i, 0] = value[i];//面值
            cashvaluenum[i, 1] = num[i];//剩余数量
        }
        bool hasvalue = false;
       
     
        //遍历选中的利金卡列表
        for (int index = 0; index < gvCashGiftCard.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvCashGiftCard.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                for (int i = 0; i < length; i++)
                {
                    if (cashvaluenum[i, 0] == gvCashGiftCard.Rows[index].Cells[2].Text)
                    {
                        hasvalue = true;
                        cashvaluenum[i, 1] = (Convert.ToInt32(cashvaluenum[i, 1]) - 1).ToString();
                    }
                    else
                    {
                        continue;
                    }
                    if (hasvalue == false)
                    {
                        context.AddError("第" + (index + 1) + "行关联的利金卡不是订单要求的利金卡");
                        return;
                    }
                    if (Convert.ToInt32(cashvaluenum[i, 1]) < 0)//剩余数量小于0
                    {
                        context.AddError("关联第" + (index + 1) + "行利金卡后，该面额关联的总数量超过了订单要求的数量");
                        return;
                    }
                }
            }
        }
        if (context.hasError())
            return;
        FillTempTable(sessionID);
        context.SPOpen();
        context.AddField("p_sessionID").Value = sessionID;
        string orderno = getDataKeys2("ORDERNO", gvOrderList.SelectedIndex);
        context.AddField("p_ORDERNO").Value = orderno; // 订单号
        bool ok = context.ExecuteSP("SP_GC_CASHGIFTCARDRELATION");
        if (ok)
        {
            //订单补关联完成
            CompleteMake();
            if (context.hasError())
            {
                return;
            }
            AddMessage("关联成功");
            btnQuery_Click(sender, e);
            btnCashGiftCardQuery_Click(sender, e);//增加利金卡查询的刷新 add by youyue 
            //刷新页面
            int index = gvOrderList.SelectedIndex;
            divInfo.InnerHtml = GetOrderMakeOrComfirmHtml(getDataKeys2("ORDERNO", index), getDataKeys2("GROUPNAME", index), getDataKeys2("NAME", index),
              getDataKeys2("TOTALMONEY", index), getDataKeys2("ORDERSTATE", index), getDataKeys2("INPUTTIME", index), getDataKeys2("cashgiftmoney", index),
             getDataKeys2("SZTCARDMONEY", index), getDataKeys2("CHARGECARDMONEY", index), getDataKeys2("CUSTOMERACCMONEY", index), getDataKeys2("CUSTOMERACCHASMONEY", index), getDataKeys2("readermoney", index));
        }
        //清空临时表
        clearTempTable();
        
    }
    //关联市民卡B卡
    protected void btnSZTCardMake_Click(object sender, EventArgs e)
    {
        string sessionID = Session.SessionID;
        ValidSZTCardInput();
        if (context.hasError())
            return;
        string cardtype = "";
        string cardvalue = "";
        string leftnum = "";
        //清空临时表
        clearTempTable();
        if (hidSZTCardType.Value != "" && hidSZTValue.Value != "" && hidSZTLeftNum.Value != "")
        {
            cardtype = hidSZTCardType.Value.Remove(hidSZTCardType.Value.LastIndexOf(","), 1);
            cardvalue = hidSZTValue.Value.Remove(hidSZTValue.Value.LastIndexOf(","), 1);
            leftnum = hidSZTLeftNum.Value.Remove(hidSZTLeftNum.Value.LastIndexOf(","), 1);
        }
        string[] type = cardtype.Split(',');//卡片类型
        string[] value = cardvalue.Split(',');//总充值金额
        string[] num = leftnum.Split(',');//剩余数量
        int length = value.Length;
        //市民卡B卡卡片类型、充值金额和剩余数量的二维数组
        string[,] szt = new string[length,3];
        string[,] chargeright = new string[length, 3];//市民卡B卡类型，总充值金额是否正确
        for (int i = 0; i < length; i++)
        {
            szt[i, 0] = type[i];//类型
            szt[i, 1] = value[i];//总金额
            szt[i, 2] = num[i];//剩余数量
            chargeright[i, 0] = type[i];//类型
            chargeright[i, 1] = "0";//充值金额
            if (num[i].ToString().Equals("0"))//此类型的卡已完成关联
            {
                chargeright[i, 2] = "1";//总充值金额默认为已完成
            }
            else
            {
                chargeright[i, 2] = "0";//总充值金额默认为未完成
            }
        }
        bool hasvalue = false;
        //遍历市民卡B卡
        for (int i = 0; i < gvSZTCard.Rows.Count; i++)
        {
            TextBox txtFromCardNo = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTFromCardNo");
            TextBox txtToCardNo = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTToCardNo");
            TextBox txtNum = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardNum");
            for (int j = 0; j < length; j++)
            {
                if (szt[j, 0] == txtFromCardNo.Text.Trim().Substring(4, 4))//卡片类型及充值金额相同&& szt[j, 1] == txtValue.Text.Trim()
                {
                    hasvalue = true;
                    szt[j, 2] = (Convert.ToInt32(szt[j, 2]) - Convert.ToInt32(txtNum.Text.Trim())).ToString();//剩余数量
                    chargeright[j, 1] = (int.Parse(chargeright[j, 1]) + SumValue(txtFromCardNo, txtToCardNo, txtNum)).ToString();//积累相同类型B卡的充值金额
                }
                else
                {
                    continue;
                }
                if (hasvalue == false)
                {
                    context.AddError("第" + (i + 1) + "行关联的市民卡B卡不是订单要求的市民卡B卡");
                    return;
                }
              
                if (Convert.ToInt32(szt[j, 2]) < 0)//剩余数量小于0
                {
                    context.AddError("关联第" + (i + 1) + "行市民卡B卡后，该类型市民卡B卡关联的总数量超过了订单要求的数量");
                    return;
                }

                if (chargeright[j, 1].ToString().Equals(szt[j, 1].ToString()))
                {
                    chargeright[j, 2] = "1";//总充值金额正确标识
                }                
            }
        }
        //判断总充值金额是否符合订单的要求
        for (int k = 0; k < length; k++)
        {   
            if ( chargeright[k, 2].Equals("0"))//充值未完成时，判断总充值金额是否正确
            {
                if (!chargeright[k, 1].Equals("0"))//某类型的市民卡B卡实际充值或售卡金额不为0时
                {
                    if (chargeright[k, 1] != szt[k, 1])//判断实际充值或售卡金额是否等于订单金额
                    {
                        context.AddError(chargeright[k, 0] + "类型的市民卡B卡关联的总充值金额不符合订单要求的总充值金额，必须一次性关联订单中的市民卡B卡");
                        return;
                    }
                    
                }
                else //市民卡B卡实际充值或售卡金额为0时
                {
                    context.AddError(chargeright[k, 0] + "类型的市民卡B卡关联的总充值金额不符合订单要求的总充值金额，必须一次性关联订单中的市民卡B卡");
                    return;
                }
            }           
        }
        if (context.hasError())
            return;
        FillSZTTempTable(sessionID);
        context.SPOpen();
        context.AddField("p_sessionID").Value = sessionID;
        string orderno = getDataKeys2("ORDERNO", gvOrderList.SelectedIndex);
        context.AddField("p_ORDERNO").Value = orderno; // 订单号
        bool ok = context.ExecuteSP("SP_GC_SZTCARDRELATION");
        if (ok)
        {
            //订单补关联完成
            CompleteMake();
            if (context.hasError())
            {
                return;
            }
            AddMessage("关联成功");
             //刷新页面
            int index = gvOrderList.SelectedIndex;
            divInfo.InnerHtml = GetOrderMakeOrComfirmHtml(getDataKeys2("ORDERNO", index), getDataKeys2("GROUPNAME", index), getDataKeys2("NAME", index),
              getDataKeys2("TOTALMONEY", index), getDataKeys2("ORDERSTATE", index), getDataKeys2("INPUTTIME", index), getDataKeys2("cashgiftmoney", index),
             getDataKeys2("SZTCARDMONEY", index), getDataKeys2("CHARGECARDMONEY", index), getDataKeys2("CUSTOMERACCMONEY", index), getDataKeys2("CUSTOMERACCHASMONEY", index), getDataKeys2("readermoney", index));
            btnQuery_Click(sender,e);
        }
        //清空临时表
        clearTempTable();
    }
    //累计相同类型的市民卡B卡的充值金额或售卡金额
    private int  SumValue(TextBox txtFromCardNo, TextBox txtToCardNo,TextBox txtnum)
    {
        int value=0;
        int num = int.Parse(txtnum.Text.ToString());
        long fromCardNo = Convert.ToInt64(txtFromCardNo.Text.Trim());
        string cardtype = txtFromCardNo.Text.Trim().Substring(4, 2);//卡类型
        if (cardtype != "20")//如果卡类型不是20：市民卡B卡结构-手环卡
        {
            for (int i = 0; i < num; i++)
            {
                string cardno = (fromCardNo + i).ToString();
                context.DBOpen("Select");
                string querycardno = @"select p.supplymoney/100.0 supplymoney from tl_r_icuser t,
(select Max(id) id,Max(Tradeid) tradeid,cardno from tf_b_tradefee h where h.tradetypecode='02' group by cardno)q, tf_b_tradefee p
where  t.cardtypecode in ('07','08','09') and t.resstatecode = '06'
and t.cardno = q.cardno and q.id = p.id and t.cardno = '" + cardno + "'  and p.supplymoney/100.0>0";
                DataTable data = context.ExecuteReader(querycardno);//查找充值金额
                if (data.Rows.Count < 1)
                {
                    context.DBOpen("Select");
                    string querycardno2 = @"select t.CARDPRICE/100.0  CARDPRICE from tl_r_icuser t,
(select Max(id) id,Max(Tradeid) tradeid,cardno from tf_b_tradefee h where h.tradetypecode='01' group by cardno)q, tf_b_tradefee p
where  t.cardtypecode in ('07','08','09') and t.resstatecode = '06'
and t.cardno = q.cardno and q.id = p.id and t.cardno = '" + cardno + "'  and t.CARDPRICE/100.0>0";
                    DataTable data2 = context.ExecuteReader(querycardno2);//查找售出信息
                    if (data2.Rows.Count > 0)
                    {
                        value += int.Parse(data2.Rows[0].ItemArray[0].ToString());//售卡金额
                    }
                }
                else
                {
                    value += int.Parse(data.Rows[0].ItemArray[0].ToString());//充值金额
                }

            }
            
        }
        else
        {
            for (int i = 0; i < num; i++)
            {
                string cardno = (fromCardNo + i).ToString();
                context.DBOpen("Select");
                string querycardno = @"select t.cardno,p.cardservfee/100.0 from tl_r_icuser t,
(select Max(id) id,Max(Tradeid) tradeid,cardno from tf_b_tradefee h where h.tradetypecode IN ('01') group by cardno)q, tf_b_tradefee p
where  t.cardtypecode in ('20') and t.resstatecode = '06'
and t.cardno = q.cardno and q.id = p.id and t.cardno= '" + cardno + "' and p.cardservfee>0";
                DataTable data2 = context.ExecuteReader(querycardno);//查找售出信息
                if (data2.Rows.Count > 0)
                {
                    value += int.Parse(data2.Rows[0].ItemArray[1].ToString());//售卡金额
                }
            }
        }
 
        return value;

    }
    private void FillSZTTempTable(string sessionID)
    {
        //记录入临时表
        context.DBOpen("Insert");
        for (int i = 0; i < gvSZTCard.Rows.Count; i++)
        {
            TextBox txtFromCardNo = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTFromCardNo");
            TextBox txtToCardNo = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTToCardNo");
            //TextBox txtValue = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardValue");
            TextBox txtNum = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardNum");

            //F0：SessionID,F1:起始卡号，F2:结束卡号，F3：卡片类型，F4：数量
            context.ExecuteNonQuery(@"insert into TMP_ORDER (f0,f1,f2,f3,f4)
                            values('" + sessionID + "','" + txtFromCardNo.Text.Trim() + "','" + txtToCardNo.Text.Trim() + "','"+txtFromCardNo.Text.Trim().Substring(4,4)+"','"+txtNum.Text.Trim()+"')");
           
        }
        context.DBCommit();
    }
    /// <summary>
    /// 市民卡B卡有效性校验
    /// </summary>
    /// <param name="valid"></param>
    private void ValidSZTCardInput()
    {
        for (int i = 0; i < gvSZTCard.Rows.Count; i++)
        {
            TextBox txtFromCardNo = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTFromCardNo");
            TextBox txtToCardNo = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTToCardNo");
            //TextBox txtValue = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardValue");
            TextBox txtNum = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardNum");

            if (txtFromCardNo.Text.Trim().Length > 0 || txtToCardNo.Text.Trim().Length > 0 || txtNum.Text.Trim().Length > 0)
            {
                if (txtFromCardNo.Text.Trim().Length < 1)
                {
                    context.AddError("起始卡号不能为空", txtFromCardNo);
                }
                else if (txtFromCardNo.Text.Trim().Length != 16)
                {
                    context.AddError("起始卡号必须为16位", txtFromCardNo);
                }
                else if (!Validation.isNum(txtFromCardNo.Text.Trim()))
                {
                    context.AddError("起始卡号必须是数字", txtFromCardNo);
                }
                if (txtToCardNo.Text.Trim().Length < 1)
                {
                    context.AddError("终止卡号不能为空", txtToCardNo);
                }
                else if (txtToCardNo.Text.Trim().Length != 16)
                {
                    context.AddError("终止卡号必须为16位", txtToCardNo);
                }
                else if (!Validation.isNum(txtToCardNo.Text.Trim()))
                {
                    context.AddError("终止卡号必须是数字", txtToCardNo);
                }
                //if (txtValue.Text.Trim().Length < 1)
                //{
                //    context.AddError("面额不能为空", txtValue);
                //}
                //else if (!Validation.isPosRealNum(txtValue.Text.Trim()))
                //{
                //    context.AddError("面额必须是正数", txtValue);
                //}
                if (txtNum.Text.Trim().Length < 1)
                {
                    context.AddError("购卡数量不能为空", txtNum);
                }
                if (txtNum.Text.Trim().Equals("0"))
                {
                    context.AddError("购卡数量不能为0", txtNum);
                }
                if (txtFromCardNo.Text.Trim().Length > 0 && txtToCardNo.Text.Trim().Length > 0)
                {
                    if (Convert.ToInt64(txtToCardNo.Text.Trim()) < Convert.ToInt64(txtFromCardNo.Text.Trim()))
                    {
                        context.AddError("起始卡号不能大于终止卡号", txtToCardNo);
                    }
                }
                if (context.hasError())
                {
                    return;
                }
               
            }
            if ( txtNum.Text.Trim().Length > 0 && txtFromCardNo.Text.Trim().Length > 0 && txtToCardNo.Text.Trim().Length > 0)
            {
                long quantity = GetQuantity(context, txtFromCardNo, txtToCardNo);
                if (txtFromCardNo.Text.Trim().Substring(4, 4) != txtToCardNo.Text.Trim().Substring(4, 4))
                {
                    context.AddError("第" + (i + 1).ToString() + "行起始卡号和终止卡号之间的市民卡B卡卡类型不相同，请重新选择起讫卡号", txtFromCardNo);
                    return;
                }
                if (quantity != Convert.ToInt64(txtNum.Text.Trim()))
                {
                    context.AddError("购卡数量和卡号号段内卡号总数不一致", txtNum);
                    return;
                }
                
                hasSameChargeValue(context, txtFromCardNo, txtToCardNo);//判断是否充值或售出
               
                if (context.hasError())
                {
                    return;
                }

            }
            else
            {
                context.AddError("请输入市民卡B卡信息后关联");
            }
            
        }
    }
    private long GetQuantity(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo)
    {
        Validation valid = new Validation(context);
        long fromCard = -1, toCard = -1;
        fromCard = Convert.ToInt64(txtFromCardNo.Text.Substring(8, 8));
        toCard = Convert.ToInt64(txtToCardNo.Text.Substring(8, 8));
        long quantity = 0;
        // 0 <= 终止卡号-起始卡号 <= 100000
        if (fromCard >= 0 && toCard >= 0)
        {
            quantity = toCard - fromCard + 1;
        }

        return quantity;

    }
    /// <summary>
    /// 是否有相同的充值金额    
    /// </summary>
    /// <param name="context"></param>
    /// <param name="txtFromCardNo"></param>
    /// <param name="txtToCardNo"></param>
    /// <param name="txtCardValue"></param>
    private void hasSameChargeValue(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo)
    {
        long num = GetQuantity(context, txtFromCardNo, txtToCardNo);
        long fromCardNo = Convert.ToInt64(txtFromCardNo.Text.Trim());
        string cardtype = txtFromCardNo.Text.Trim().Substring(4, 2);//卡类型
        if (cardtype != "20")//如果卡类型不是20：市民卡B卡结构-手环卡
        {
            for (int i = 0; i < num; i++)
            {
                string cardno = (fromCardNo + i).ToString();
                string querycardno = @"select t.cardno from tl_r_icuser t,
(select Max(id) id,Max(Tradeid) tradeid,cardno from tf_b_tradefee h where h.tradetypecode IN ('02','7H','7I') group by cardno)q, tf_b_tradefee p
where  t.cardtypecode in ('07','08','09','51') and t.resstatecode = '06'
and t.cardno = q.cardno and q.id = p.id and t.cardno = '" + cardno + "'  and p.supplymoney/100.0>0";
                string querycardno2 = @"select t.cardno from tl_r_icuser t,
(select Max(id) id,Max(Tradeid) tradeid,cardno from tf_b_tradefee h where h.tradetypecode IN ('01','7H','7I') group by cardno)q, tf_b_tradefee p
where  t.cardtypecode in ('07','08','09','51') and t.resstatecode = '06'
and t.cardno = q.cardno and q.id = p.id and t.cardno = '" + cardno + "'  and t.CARDPRICE/100.0>0";
                context.DBOpen("Select");
                DataTable data = context.ExecuteReader(querycardno);//查找充值信息
                DataTable data2 = context.ExecuteReader(querycardno2);//查找售出信息
                if (data.Rows.Count < 1 && data2.Rows.Count < 1)
                {
                    context.AddError("A007P01211: 此卡号" + cardno + "不是市民卡B卡，或者此卡未售出或者未充值");
                    return;
                }
            }
        }
        else
        {
            for (int i = 0; i < num; i++)
            {
                string cardno = (fromCardNo + i).ToString();
                string querycardno = @"select t.cardno,p.cardservfee from tl_r_icuser t,
(select Max(id) id,Max(Tradeid) tradeid,cardno from tf_b_tradefee h where h.tradetypecode IN ('01') group by cardno)q, tf_b_tradefee p
where  t.cardtypecode in ('20') and t.resstatecode = '06'
and t.cardno = q.cardno and q.id = p.id and t.cardno = '" + cardno + "' and p.cardservfee>0";

                context.DBOpen("Select");
                DataTable data = context.ExecuteReader(querycardno);//查找手环卡售出信息（手环卡一般是批量售卡）
                if (data.Rows.Count < 1)
                {
                    context.AddError("A007P01213: 此卡号" + cardno + "不是市民卡B卡结构-手环卡，或者此卡未售出");
                    return;
                }
               
            }
        }
       
        
    }
  
    /// <summary>
    /// 完成订单补关联，判断是否完成关联，如果是则更改订单状态为订单补关联
    /// </summary>
    protected void CompleteMake()
    {
        int index = gvOrderList.SelectedIndex;
        string sqlcashgift = " select sum(nvl(a.LEFTQTY,0)) from TF_F_CASHGIFTORDER a where ORDERNO = '" + getDataKeys2("ORDERNO",index) + "'";  
        string sqlsztcard = " select sum(nvl(a.LEFTQTY,0)) from TF_F_SZTCARDORDER a where ORDERNO = '" + getDataKeys2("ORDERNO", index) + "'";
        context.DBOpen("Select");
        DataTable datacashgift = context.ExecuteReader(sqlcashgift);
        DataTable datasztcard = context.ExecuteReader(sqlsztcard);
        bool cashgift;
        bool sztcard;
        //是否完成利金卡
        if (datacashgift.Rows.Count > 0) 
        {

            cashgift = datacashgift.Rows[0][0].ToString() == "" || datacashgift.Rows[0][0].ToString() == "0" ? true : false;
        }
        else
        {
            cashgift = true;
        }       
        //是否完成市民卡B卡
        if (datasztcard.Rows.Count > 0)
        {

            sztcard = datasztcard.Rows[0][0].ToString() == "" || datasztcard.Rows[0][0].ToString() == "0" ? true : false;
        }
        else
        {
            sztcard = true;
        } 

        //如果全部完成
        if (cashgift &&  sztcard )
        {
            context.SPOpen();
            context.AddField("P_FUNCCODE").Value = "SETCOMPLETERELATION";
            context.AddField("p_ORDERNO").Value = getDataKeys2("ORDERNO", index);
            bool ok = context.ExecuteSP("SP_GC_SETORDERSTATE");
            if (ok)
            {
                AddMessage("订单完成领卡补关联");
                //完成领卡补关联标记置为1
                hidIsCompleted.Value = "1";
            }
        }
    }
    //确认不关联
    protected void btnComfirmNotRelation_Click(object sender, EventArgs e)
    {
        int index = gvOrderList.SelectedIndex;
        context.SPOpen();
        context.AddField("p_ORDERNO").Value = getDataKeys2("ORDERNO",index); // 订单号
        bool ok = context.ExecuteSP("SP_GC_ORDERRELATEDCANCEL");

        if (ok)
        {
            AddMessage("取消补关联完成");
            btnQuery_Click(sender, e);
        }
    }

    //另一种关联利金卡的方式
    protected void btnCashCardMake_Click(object sender, EventArgs e)
    {
        string sessionID = Session.SessionID;
        ValidCashCardInput();
        if (context.hasError())
            return;
        string cardvalue = "";
        string leftnum = "";
        //清空临时表
        clearTempTable();
        if (hidCashValue.Value != "" && hidCashLeftNum.Value != "" )
        {
            cardvalue = hidCashValue.Value.Remove(hidCashValue.Value.LastIndexOf(","), 1);
            leftnum = hidCashLeftNum.Value.Remove(hidCashLeftNum.Value.LastIndexOf(","), 1);
        }
        string[] value = cardvalue.Split(',');//金额类型
        string[] num = leftnum.Split(',');//剩余数量
        int length = value.Length;
        //利金卡面额和剩余数量二维数组
        string[,] cashvaluenum = new string[length, 2];
        for (int i = 0; i < length; i++)
        {
            cashvaluenum[i, 0] = value[i];//面值
            cashvaluenum[i, 1] = num[i];//剩余数量
        }
        bool hasvalue = false;
        //遍历利金卡
        for (int i = 0; i < gvCashGiftCard2.Rows.Count; i++)
        {
            TextBox txtFromCardNo = (TextBox)gvCashGiftCard2.Rows[i].FindControl("txtCashFromCardNo");
            TextBox txtToCardNo = (TextBox)gvCashGiftCard2.Rows[i].FindControl("txtCashToCardNo");
            TextBox txtNum = (TextBox)gvCashGiftCard2.Rows[i].FindControl("txtCashCardNum");
            string sql = @"select nvl((t.CARDDEPOSITFEE+t.SUPPLYMONEY)/100.0,0) salemoney from tf_b_tradefee t,
(select Max(Tradeid) tradeid,cardno from tf_b_tradefee h where h.tradetypecode='50'or h.tradetypecode='51' group by cardno)q
where t.tradeid = q.tradeid and t.cardno = q.cardno and  t.cardno = '" + txtFromCardNo.Text.Trim() + "'";
            context.DBOpen("Select");
            DataTable data = context.ExecuteReader(sql);
            string value2 = data.Rows[0].ItemArray[0].ToString();//卡片面额
            for (int j = 0; j < length; j++)
            {
                if (cashvaluenum[j, 0] == value2)//卡片面额相同
                {
                    hasvalue = true;
                    cashvaluenum[j, 1] = (Convert.ToInt32(cashvaluenum[j, 1]) - Convert.ToInt32(txtNum.Text.Trim())).ToString();//剩余数量
                   
                }
                else
                {
                    continue;
                }
               

                if (Convert.ToInt32(cashvaluenum[j, 1]) < 0)//剩余数量小于0
                {
                    context.AddError("关联第" + (i + 1) + "行利金卡后，该类型利金卡关联的总数量超过了订单要求的数量");
                    return;
                }
  
            }
            if (hasvalue == false)
            {
                context.AddError("第" + (i + 1) + "行关联的利金卡不是订单要求的利金卡");
                return;
            }
        }
        if (context.hasError())
            return;
        FillCashTempTable(sessionID);
        context.SPOpen();
        context.AddField("p_sessionID").Value = sessionID;
        string orderno = getDataKeys2("ORDERNO", gvOrderList.SelectedIndex);
        context.AddField("p_ORDERNO").Value = orderno; // 订单号
        bool ok = context.ExecuteSP("SP_GC_CASHGIFTCARDRELATIONTWO");
        if (ok)
        {
            //订单补关联完成
            CompleteMake();
            if (context.hasError())
            {
                return;
            }
            AddMessage("关联成功");
            //刷新页面
            int index = gvOrderList.SelectedIndex;
            divInfo.InnerHtml = GetOrderMakeOrComfirmHtml(getDataKeys2("ORDERNO", index), getDataKeys2("GROUPNAME", index), getDataKeys2("NAME", index),
              getDataKeys2("TOTALMONEY", index), getDataKeys2("ORDERSTATE", index), getDataKeys2("INPUTTIME", index), getDataKeys2("cashgiftmoney", index),
             getDataKeys2("SZTCARDMONEY", index), getDataKeys2("CHARGECARDMONEY", index), getDataKeys2("CUSTOMERACCMONEY", index), getDataKeys2("CUSTOMERACCHASMONEY", index), getDataKeys2("readermoney", index));
            btnQuery_Click(sender, e);
        }
        //清空临时表
        clearTempTable();
    }
    /// <summary>
    /// 利金卡输入信息有效性校验
    /// </summary>
    /// <param name="valid"></param>
    private void ValidCashCardInput()
    {
        for (int i = 0; i < gvCashGiftCard2.Rows.Count; i++)
        {
            TextBox txtFromCardNo = (TextBox)gvCashGiftCard2.Rows[i].FindControl("txtCashFromCardNo");
            TextBox txtToCardNo = (TextBox)gvCashGiftCard2.Rows[i].FindControl("txtCashToCardNo");
            TextBox txtNum = (TextBox)gvCashGiftCard2.Rows[i].FindControl("txtCashCardNum");

            if (txtFromCardNo.Text.Trim().Length > 0 || txtToCardNo.Text.Trim().Length > 0 || txtNum.Text.Trim().Length > 0)
            {
                if (txtFromCardNo.Text.Trim().Length < 1)
                {
                    context.AddError("起始卡号不能为空", txtFromCardNo);
                }
                else if (txtFromCardNo.Text.Trim().Length != 16)
                {
                    context.AddError("起始卡号必须为16位", txtFromCardNo);
                }
                else if (!Validation.isNum(txtFromCardNo.Text.Trim()))
                {
                    context.AddError("起始卡号必须是数字", txtFromCardNo);
                }
                if (txtToCardNo.Text.Trim().Length < 1)
                {
                    context.AddError("终止卡号不能为空", txtToCardNo);
                }
                else if (txtToCardNo.Text.Trim().Length != 16)
                {
                    context.AddError("终止卡号必须为16位", txtToCardNo);
                }
                else if (!Validation.isNum(txtToCardNo.Text.Trim()))
                {
                    context.AddError("终止卡号必须是数字", txtToCardNo);
                }
                if (txtNum.Text.Trim().Length < 1)
                {
                    context.AddError("购卡数量不能为空", txtNum);
                }
                if (txtNum.Text.Trim().Equals("0"))
                {
                    context.AddError("购卡数量不能为0", txtNum);
                }
                if (txtFromCardNo.Text.Trim().Length > 0 && txtToCardNo.Text.Trim().Length > 0)
                {
                    if (Convert.ToInt64(txtToCardNo.Text.Trim()) < Convert.ToInt64(txtFromCardNo.Text.Trim()))
                    {
                        context.AddError("起始卡号不能大于终止卡号", txtToCardNo);
                    }
                }
                if (context.hasError())
                {
                    return;
                }

            }
            if (txtNum.Text.Trim().Length > 0 && txtFromCardNo.Text.Trim().Length > 0 && txtToCardNo.Text.Trim().Length > 0)
            {
                long quantity = GetQuantity(context, txtFromCardNo, txtToCardNo);
                if (txtFromCardNo.Text.Trim().Substring(0, 8) != txtToCardNo.Text.Trim().Substring(0, 8))
                {
                    context.AddError("第" + (i + 1).ToString() + "行起始卡号和终止卡号之间的市民卡B卡卡类型不相同，请重新选择起讫卡号", txtFromCardNo);
                    return;
                }
                if (quantity != Convert.ToInt64(txtNum.Text.Trim()))
                {
                    context.AddError("购卡数量和卡号号段内卡号总数不一致", txtNum);
                    return;
                }
                hasSameSaleValue(context, txtFromCardNo, txtToCardNo, quantity);//判断是否售出并且礼金卡面额一致
                if (context.hasError())
                {
                    return;
                }

            }
            else
            {
                context.AddError("请输入利金卡信息后关联");
            }

        }
    }
    private void hasSameSaleValue(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo,long num)
    {
        long fromCardNo = Convert.ToInt64(txtFromCardNo.Text.Trim());
        int value = 0;
        int value2 = 0;
        for (int i = 0; i < num; i++)
        {
            string cardno = (fromCardNo + i).ToString();
            string querycardno = @"select nvl((t.CARDDEPOSITFEE+t.SUPPLYMONEY)/100.0,0) salemoney from tf_b_tradefee t,
(select Max(Tradeid) tradeid,cardno from tf_b_tradefee h where h.tradetypecode='50'or h.tradetypecode='51' group by cardno)q,tl_r_icuser p
where t.tradeid = q.tradeid and t.cardno = q.cardno and (t.tradetypecode = '50' or t.tradetypecode = '51') and 
p.cardtypecode='05' and p.resstatecode = '06' and t.cardno = p.cardno and q.cardno = '" + cardno + "'  and t.supplymoney/100.0>0";
            context.DBOpen("Select");
            DataTable data = context.ExecuteReader(querycardno);//查找售出信息
            if (data.Rows.Count < 1)
            {
                context.AddError("A007P01211: 此卡号" + cardno + "不是利金卡，或者此卡未售出");
                return;
            }
            else
            {
                if (i == 0)
                {
                    value = int.Parse(data.Rows[0].ItemArray[0].ToString());//礼金卡面额
                }
                else
                {
                    value2 = int.Parse(data.Rows[0].ItemArray[0].ToString());//礼金卡面额
                }
                if (i>0 && value2 != value)
                {
                    context.AddError("A007P01211: 此卡号为" + cardno + "的利金卡面额和之前卡号的利金卡面额不一致");
                    return;
                }
            }
        }

    }
    private void FillCashTempTable(string sessionID)
    {
        //记录入临时表
        context.DBOpen("Insert");
        for (int i = 0; i < gvCashGiftCard2.Rows.Count; i++)
        {
            TextBox txtFromCardNo = (TextBox)gvCashGiftCard2.Rows[i].FindControl("txtCashFromCardNo");
            TextBox txtToCardNo = (TextBox)gvCashGiftCard2.Rows[i].FindControl("txtCashToCardNo");
            TextBox txtNum = (TextBox)gvCashGiftCard2.Rows[i].FindControl("txtCashCardNum");
            context.ExecuteNonQuery(@"insert into TMP_ORDER (f0,f1,f2,f3)
                            values('" + sessionID + "','" + txtFromCardNo.Text.Trim() + "','" + txtToCardNo.Text.Trim() + "','" + txtNum.Text.Trim() + "')");

        }
        context.DBCommit();
    }
}
