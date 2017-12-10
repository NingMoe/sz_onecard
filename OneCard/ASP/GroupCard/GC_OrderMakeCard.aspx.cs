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
using PDO.GroupCard;
using TDO.UserManager;
using PDO.PersonalBusiness;
using TDO.CardManager;
using TDO.ResourceManager;
using TDO.BusinessCode;

public partial class ASP_GroupCard_GC_OrderMakeCard : Master.FrontMaster
{
    #region 初始化
    //充值卡datatable
    private DataTable ChargeCardTable
    {
        set
        {
            ViewState["ChargeCardTable"] = value;
        }
        get
        {
            return (DataTable)ViewState["ChargeCardTable"];
        }
    }
    //读卡器datatable
    private DataTable ReaderTable
    {
        set
        {
            ViewState["ReaderTable"] = value;
        }
        get
        {
            return (DataTable)ViewState["ReaderTable"];
        }
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack)
        {
            if (gvOrderList.SelectedIndex >= 0)
            {
                string isrelated = getDataKeys("ISRELATED") == "1:制卡关联" ? "1" : "0";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showdivPost", "ShowIsRelated(" + isrelated + ");", true);
            }
            return;
        }

        if (!context.s_Debugging)
        {
            txtCashGiftCardNo.Attributes["readonly"] = "true";
            txtSZTCardNo.Attributes["readonly"] = "true";
        }

        //初始化部门
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
        TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
        ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
        //selDept.SelectedValue = context.s_DepartID;
        //初始化经办人
        InitStaffList(selStaff, context.s_DepartID);
        //selStaff.SelectedValue = context.s_UserID;

        //审核员工
        InitStaffList(ddlApprover, "0001");

        gvOrderList.DataKeyNames = new string[] { "ORDERNO", "GROUPNAME", "NAME", "PHONE", "IDCARDNO", "TOTALMONEY", 
            "TRANSACTOR", "INPUTTIME", "FINANCEAPPROVERNO", "FINANCEAPPROVERTIME", "ISRELATED","ORDERSTATE" ,"CASHGIFTMONEY",
            "CHARGECARDMONEY","SZTCARDMONEY","LVYOUMONEY","CUSTOMERACCMONEY","CUSTOMERACCHASMONEY","READERMONEY","GARDENCARDMONEY","RELAXCARDMONEY"};

        //初始化订单表格
        gvOrderList.DataSource = new DataTable();
        gvOrderList.DataBind();

        //充值卡表格
        if (ChargeCardTable == null)
        {
            ChargeCardTable = new DataTable();
            DataColumn col1 = new DataColumn("FromCardNo");
            DataColumn col2 = new DataColumn("ToCardNo");
            DataColumn col3 = new DataColumn("ChargeCardValue");
            DataColumn col4 = new DataColumn("ChargeCardNum");
            ChargeCardTable.Columns.Add(col1);
            ChargeCardTable.Columns.Add(col2);
            ChargeCardTable.Columns.Add(col3);
            ChargeCardTable.Columns.Add(col4);
            DataRow row = ChargeCardTable.NewRow();
            row["FromCardNo"] = null;
            row["ToCardNo"] = null;
            row["ChargeCardValue"] = null;
            row["ChargeCardNum"] = null;
            ChargeCardTable.Rows.Add(row);
            gvChargeCard.DataSource = ChargeCardTable;
            gvChargeCard.DataBind();
        }

        //读卡器表格
        if (ReaderTable == null)
        {
            ReaderTable = new DataTable();
            DataColumn col1 = new DataColumn("BeginCardNo");
            DataColumn col2 = new DataColumn("EndCardNo");
            DataColumn col3 = new DataColumn("ReaderValue");
            DataColumn col4 = new DataColumn("ReaderNum");
            ReaderTable.Columns.Add(col1);
            ReaderTable.Columns.Add(col2);
            ReaderTable.Columns.Add(col3);
            ReaderTable.Columns.Add(col4);
            DataRow row = ReaderTable.NewRow();
            row["BeginCardNo"] = null;
            row["EndCardNo"] = null;
            row["ReaderValue"] = null;
            row["ReaderNum"] = null;
            ReaderTable.Rows.Add(row);
            gvReader.DataSource = ReaderTable;
            gvReader.DataBind();
        }
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
    /// 部门选择时间，查询部门所属员工
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selStaff, selDept.SelectedValue);
    }
    #endregion
    /// <summary>
    /// 查询按钮点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //查询输入校验
        if (!ValidInput()) return;

        string money = "";
        if (txtTotalMoney.Text.Trim().Length > 0)
        {
            money = (Convert.ToDecimal(txtTotalMoney.Text.Trim()) * 100).ToString();
        }

        DataTable dt = GroupCardHelper.callOrderQuery(context, "QueryOrderForMakeOrComfirm", txtGroupName.Text.Trim(), txtName.Text.Trim(), money,
            selDept.SelectedValue, selStaff.SelectedValue, txtFromDate.Text.Trim(), txtToDate.Text.Trim(), ddlApprover.SelectedValue,
            selIsRelation.SelectedValue, context.s_DepartID);
        if (dt == null || dt.Rows.Count < 1)
        {
            gvOrderList.DataSource = new DataTable();
            gvOrderList.DataBind();
            context.AddError("未查出有效记录");
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

    protected void gvOrderList_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvOrderList','Select$" + e.Row.RowIndex + "')");
        }
    }
    /// <summary>
    /// 分页事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvOrderList_Page(object sender, GridViewPageEventArgs e)
    {
        gvOrderList.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
        if (gvOrderList.PageIndex.ToString() == hidPageIndex.Value)
        {
            gvOrderList.SelectedIndex = Convert.ToInt32(hidRowIndex.Value);
        }
        else
        {
            gvOrderList.SelectedIndex = -1;
        }
    }
    /// <summary>
    /// GridView行单击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvOrderList_SelectedIndexChanged(object sender, EventArgs e)
    {
        //记录行数和页数
        if (gvOrderList.SelectedIndex > -1)
        {
            hidRowIndex.Value = gvOrderList.SelectedIndex.ToString();
        }
        hidPageIndex.Value = gvOrderList.PageIndex.ToString(); 
        divInfo.InnerHtml = GetOrderMakeOrComfirmHtml(getDataKeys("ORDERNO"), getDataKeys("GROUPNAME"), getDataKeys("NAME"),
            getDataKeys("TOTALMONEY"), getDataKeys("ORDERSTATE"), getDataKeys("INPUTTIME"),
            (Convert.ToDecimal(getDataKeys("CASHGIFTMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("SZTCARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("LVYOUMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CHARGECARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CUSTOMERACCMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CUSTOMERACCHASMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("READERMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("GARDENCARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("RELAXCARDMONEY")) / 100).ToString());
        showCashGift.Value = getDataKeys("CASHGIFTMONEY") == "0" ? "0" : "1";
        showSZTCard.Value = getDataKeys("SZTCARDMONEY") == "0" ? "0" : "1";
        showLvYou.Value = getDataKeys("LVYOUMONEY") == "0" ? "0" : "1";
        showChargeCard.Value = getDataKeys("CHARGECARDMONEY") == "0" ? "0" : "1";
        showCutomerAcc.Value = getDataKeys("CUSTOMERACCMONEY") == "0" ? "0" : "1";
        showReader.Value = getDataKeys("READERMONEY") == "0" ? "0" : "1";

        if (getDataKeys("ISRELATED") == "1:制卡关联")
        {
            //关联卡
            ScriptManager.RegisterStartupScript(this, this.GetType(), "showdiv", "ShowIsRelated(1);", true);
            //不关联确认按钮隐藏
            btnComfirmNotRelation.Visible = false;
        }
        else
        {
            //关联卡
            ScriptManager.RegisterStartupScript(this, this.GetType(), "showdiv", "ShowIsRelated(0);", true);
            //不关联确认按钮显示
            btnComfirmNotRelation.Visible = true;
        }

        //重置市民卡B卡和利金卡
        txtSZTCardNo.Text = "";
        labSZTCardType.Text = "";
        labSZTCardChargeMoney.Text = "";
        labSZTCardOrderNum.Text = "";
        labSZTCardLeftNum.Text = "";
        txtCashGiftCardNo.Text = "";
        labCashGiftValue.Text = "";
        labCashGiftOrderNum.Text = "";
        labCashGiftLeftNum.Text = "";

        //重置充值卡
        ChargeCardTable.Rows.Clear();
        DataRow chargeCardrow = ChargeCardTable.NewRow();
        chargeCardrow["FromCardNo"] = null;
        chargeCardrow["ToCardNo"] = null;
        chargeCardrow["ChargeCardValue"] = null;
        chargeCardrow["ChargeCardNum"] = null;
        ChargeCardTable.Rows.Add(chargeCardrow);
        gvChargeCard.DataSource = ChargeCardTable;
        gvChargeCard.DataBind();

        //如果订单中有读卡器，查询读卡器单价
        string readerPrice = "";
        if (showReader.Value == "1")
        {
            //获取读卡器信息
            DataTable data = GroupCardHelper.callOrderQuery(context, "ReaderOrderInfo", getDataKeys("ORDERNO"));
            readerPrice = data.Rows.Count > 0 ? (Convert.ToInt32(data.Rows[0]["VALUE"].ToString()) / 100.0).ToString() : "";
        }

        //重置读卡器
        ReaderTable.Rows.Clear();
        DataRow readerRow = ReaderTable.NewRow();
        readerRow["BeginCardNo"] = null;
        readerRow["EndCardNo"] = null;
        readerRow["ReaderValue"] = readerPrice;
        readerRow["ReaderNum"] = null;
        ReaderTable.Rows.Add(readerRow);
        gvReader.DataSource = ReaderTable;
        gvReader.DataBind();

        //市民卡B卡旧卡关联不可用
        btnOldSZTCardMake.Enabled = false;
    }

    /// <summary>
    /// 获取关键字的值
    /// </summary>
    /// <param name="keysname"></param>
    /// <returns></returns>
    public String getDataKeys(String keysname)
    {
        return gvOrderList.DataKeys[gvOrderList.SelectedIndex][keysname].ToString();
    }
    #region 订单详细信息HTML
    public string GetOrderMakeOrComfirmHtml(string orderno, string groupName, string name,
        string totalMoney, string orderstate, string inputtime, string cashgiftmoney, string sztcardmoney,string lvyoumoney,
        string chargecardmoney, string customeraccmoney, string customeracchasmoney,string readermoney,
        string gardenCardmoney,string relaxCardmoney)
    {
        string CashGiftInfoHtml = GetOrderCashGiftInfoHtml(orderno);
        string SZTCardInfoHtml = GetOrderSZTCardInfoHtml(orderno);
        string LvYouInfoHtml = GetOrderLvYouInfoHtml(orderno);
        string ChargeCardInfoHtml = GetOrderChargeCardInfoHtml(orderno);
        string ReaderInfoHtml = GetOrderReaderInfoHtml(orderno);
        string GardenCardInfoHtml = GetOrderGardenCardInfoHtml(orderno);
        string RelaxCardInfoHtml = GetOrderRelaxCardInfoHtml(orderno);
        string CustomerAccHtml = "";
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
                                            <td style='text-align:right'>旅游卡总金额:</td>
		                                    <td> {20}</td>
		                                    <td style='text-align:right'>充值卡总金额:</td>
		                                    <td> {7} </td>
		                                    <td style='text-align:right'>专有账户总金额:</td>
		                                    <td> {8} </td>
	                                     </tr>
                                         <tr height=23px>
                                             <td style='text-align:right'>读卡器总金额</td>
		                                    <td> {13} </td>
		                                    <td style='text-align:right'>园林年卡总金额:</td>
		                                    <td> {14} </td>
		                                    <td style='text-align:right'>休闲年卡总金额:</td>
		                                    <td> {15} </td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
	                                     </tr>
                                            {9}
                                            {10}
                                            {19}
                                            {11}
                                            {12}
                                            {16}
                                            {17}
                                            {18}
                                    </table>", groupName, name, totalMoney, orderstate, inputtime, cashgiftmoney, sztcardmoney, chargecardmoney, customeraccmoney,
                                             CashGiftInfoHtml, SZTCardInfoHtml, ChargeCardInfoHtml, CustomerAccHtml, readermoney, gardenCardmoney, relaxCardmoney,
                                             ReaderInfoHtml, GardenCardInfoHtml, RelaxCardInfoHtml, LvYouInfoHtml, lvyoumoney);
         return html;
    }
    public string GetOrderCashGiftInfoHtml(string orderno)
    {
        //获取利金卡信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "CashOrderInfo", orderno);
        string html = "";
        if (data != null && data.Rows.Count > 0)
        {
            selCashGiftValue.Items.Clear();
            selCashGiftValue.Items.Add(new ListItem("---请选择---", ""));

            string cashGiftType = "";
            string ordernum = "";
            string haveMakenum = "";
            string leftnum = "";
            html += "<tr><td colspan = '10'><hr></td></tr>";
            for (int i = 0; i < data.Rows.Count; i++)
            {
                cashGiftType = (Convert.ToInt32(data.Rows[i]["VALUE"].ToString()) / 100).ToString();
                //初始化利金卡面额下拉选框
                selCashGiftValue.Items.Add(new ListItem(cashGiftType + "元", cashGiftType));
                ordernum = data.Rows[i]["COUNT"].ToString();
                haveMakenum = (Convert.ToInt32(data.Rows[i]["COUNT"].ToString()) - Convert.ToInt32(data.Rows[i]["LEFTQTY"].ToString())).ToString();
                leftnum = data.Rows[i]["LEFTQTY"].ToString();
                html += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>利金卡类型:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>订购数量:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'>已制卡数量:</td>
		                                    <td> {2} </td>
		                                    <td style='text-align:right'>剩余数量:</td>
		                                    <td> {3} </td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
                                        </tr>", cashGiftType, ordernum, haveMakenum, leftnum);
            }
        }
        return html;
    }
    public string GetOrderSZTCardInfoHtml(string orderno)
    {
        //获取市民卡B卡信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "SZTCardOrderInfo", orderno);
        string html = "";
        if (data != null && data.Rows.Count > 0)
        {
            selSZTCardType.Items.Clear();
            selSZTCardType.Items.Add(new ListItem("---请选择---", ""));
            string SZTType = "";
            string ordernum = "";
            string haveMakenum = "";
            string leftnum = "";
            string chargemoney = "";
            html += "<tr><td colspan = '10'><hr></td></tr>";
            for (int i = 0; i < data.Rows.Count; i++)
            {
                SZTType = data.Rows[i]["CARDTYPECODE"].ToString() + ":" + data.Rows[i]["CARDSURFACENAME"].ToString();
                //初始化市民卡B卡卡类型下拉选框
                selSZTCardType.Items.Add(new ListItem(SZTType, data.Rows[i]["CARDTYPECODE"].ToString()));

                ordernum = data.Rows[i]["COUNT"].ToString();
                haveMakenum = (Convert.ToInt32(data.Rows[i]["COUNT"].ToString()) - Convert.ToInt32(data.Rows[i]["LEFTQTY"].ToString())).ToString();
                leftnum = data.Rows[i]["LEFTQTY"].ToString();
                //单张充值金额
                if (ordernum.Trim() == "0")
                {
                    chargemoney = "0";
                }
                else
                {
                    chargemoney = (Convert.ToInt32(data.Rows[i]["TOTALCHARGEMONEY"].ToString()) / Convert.ToInt32(ordernum) / 100.0).ToString();
                }
                html += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>市民卡B卡类型:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>订购数量:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'>已制卡数量:</td>
		                                    <td> {2} </td>
		                                    <td style='text-align:right'>剩余数量:</td>
		                                    <td> {3} </td>
		                                    <td style='text-align:right'>充值金额</td>
		                                    <td> {4} </td>
                                        </tr>", SZTType, ordernum, haveMakenum, leftnum, chargemoney);
            }
        }
        return html;
    }

    //DONE:修改旅游卡 前台增加旅游卡DIV 
    public string GetOrderLvYouInfoHtml(string orderno)
    {
        //获取旅游卡信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "LvYouOrderInfo", orderno);
        string html = "";
        if (data != null && data.Rows.Count > 0)
        {
            selLvYouType.Items.Clear();
            selLvYouType.Items.Add(new ListItem("---请选择---", ""));
            string LvYouType = "";
            string ordernum = "";
            string haveMakenum = "";
            string leftnum = "";
            string chargemoney = "";
            html += "<tr><td colspan = '10'><hr></td></tr>";
            for (int i = 0; i < data.Rows.Count; i++)
            {
                LvYouType = data.Rows[i]["CARDTYPECODE"].ToString() + ":" + data.Rows[i]["CARDSURFACENAME"].ToString();
                //初始化市民卡B卡卡类型下拉选框
                selLvYouType.Items.Add(new ListItem(LvYouType, data.Rows[i]["CARDTYPECODE"].ToString()));
                ordernum = data.Rows[i]["COUNT"].ToString();
                haveMakenum = (Convert.ToInt32(data.Rows[i]["COUNT"].ToString()) - Convert.ToInt32(data.Rows[i]["LEFTQTY"].ToString())).ToString();
                leftnum = data.Rows[i]["LEFTQTY"].ToString();
                //单张充值金额
                if (ordernum.Trim() == "0")
                {
                    chargemoney = "0";
                }
                else
                {
                    chargemoney = (Convert.ToInt32(data.Rows[i]["TOTALCHARGEMONEY"].ToString()) / Convert.ToInt32(ordernum) / 100.0).ToString();
                }
                html += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>旅游卡:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>订购数量:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'>已制卡数量:</td>
		                                    <td> {2} </td>
		                                    <td style='text-align:right'>剩余数量:</td>
		                                    <td> {3} </td>
		                                    <td style='text-align:right'>充值金额</td>
		                                    <td> {4} </td>
                                        </tr>",LvYouType, ordernum, haveMakenum, leftnum, chargemoney);
            }
        }
        return html;
    }

    public string GetOrderChargeCardInfoHtml(string orderno)
    {
        //获取充值卡信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "ChargeCardOrderInfo", orderno);
        string html = "";
        if (data != null && data.Rows.Count > 0)
        {
            string chargeCardType = "";
            string ordernum = "";
            string haveMakenum = "";
            string leftnum = "";
            html += "<tr><td colspan = '10'><hr></td></tr>";
            for (int i = 0; i < data.Rows.Count; i++)
            {
                chargeCardType = data.Rows[i]["VALUECODE"].ToString() + ":" + data.Rows[i]["VALUENAME"].ToString();
                ordernum = data.Rows[i]["COUNT"].ToString();
                haveMakenum = (Convert.ToInt32(data.Rows[i]["COUNT"].ToString()) - Convert.ToInt32(data.Rows[i]["LEFTQTY"].ToString())).ToString();
                leftnum = data.Rows[i]["LEFTQTY"].ToString();
                html += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>充值卡类型:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>订购数量:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'>已制卡数量:</td>
		                                    <td> {2} </td>
		                                    <td style='text-align:right'>剩余数量:</td>
		                                    <td> {3} </td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
                                        </tr>", chargeCardType, ordernum, haveMakenum, leftnum);
            }
        }

        return html;
    }
    public string GetOrderReaderInfoHtml(string orderno)
    {
        //获取读卡器信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "ReaderOrderInfo", orderno);
        string html = "";
        if (data != null && data.Rows.Count > 0)
        {
            string ordernum = "";
            string orderprice = "";
            string haveMakenum = "";
            string leftnum = "";
            html += "<tr><td colspan = '10'><hr></td></tr>";
            for (int i = 0; i < data.Rows.Count; i++)
            {
                ordernum = data.Rows[i]["COUNT"].ToString();
                orderprice = (Convert.ToInt32(data.Rows[i]["VALUE"].ToString())/100.0).ToString();
                haveMakenum = (Convert.ToInt32(data.Rows[i]["COUNT"].ToString()) - Convert.ToInt32(data.Rows[i]["LEFTQTY"].ToString())).ToString();
                leftnum = data.Rows[i]["LEFTQTY"].ToString();
                html += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>读卡器订购数量:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>单价:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'>已关联数量:</td>
		                                    <td> {2} </td>
		                                    <td style='text-align:right'>剩余数量:</td>
		                                    <td> {3} </td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
                                        </tr>", ordernum, orderprice, haveMakenum, leftnum);
            }
        }

        return html;
    }
    public string GetOrderGardenCardInfoHtml(string orderno)
    {
        //获取园林年卡信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "GardenCardOrderInfo", orderno);
        string html = "";
        if (data != null && data.Rows.Count > 0)
        {
            string ordernum = "";
            string orderprice = "";
            html += "<tr><td colspan = '10'><hr></td></tr>";
            for (int i = 0; i < data.Rows.Count; i++)
            {
                ordernum = data.Rows[i]["COUNT"].ToString();
                orderprice = (Convert.ToInt32(data.Rows[i]["VALUE"].ToString()) / 100.0).ToString();
                html += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>园林年卡订购数量:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>单价:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
                                        </tr>", ordernum, orderprice);
            }
        }

        return html;
    }
    public string GetOrderRelaxCardInfoHtml(string orderno)
    {
        //获取休闲年卡信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "RelaxCardOrderInfo", orderno);
        string html = "";
        if (data != null && data.Rows.Count > 0)
        {
            string ordernum = "";
            string orderprice = "";
            html += "<tr><td colspan = '10'><hr></td></tr>";
            for (int i = 0; i < data.Rows.Count; i++)
            {
                ordernum = data.Rows[i]["COUNT"].ToString();
                orderprice = (Convert.ToInt32(data.Rows[i]["VALUE"].ToString()) / 100.0).ToString();
                html += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>休闲年卡订购数量:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>单价:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
                                        </tr>", ordernum, orderprice);
            }
        }

        return html;
    }
    #endregion

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidMaketype.Value == "01")//市民卡B卡售卡
        {
            if (hidWarning.Value == "writeSuccess")
            {
                #region 添加对代理营业厅预付款的验证,扣费后如果超过预警额度则提示
                int opMoney = Convert.ToInt32(hidCardcostFee.Value)
                    + Convert.ToInt32(hidCardcostFee.Value);

                DeptBalunitHelper.ValdatePrepay(context, opMoney, "1");
                #endregion

                //市民卡B卡充值
                hidMaketype.Value = "02";

                AddMessage("售卡成功!");
                hidCardnoForCheck.Value = txtSZTCardNo.Text;//用于写卡前验证页面上的卡号和读卡器上的卡是否一致
                //充值写卡
                ScriptManager.RegisterStartupScript(this, this.GetType(),
                        "writeCardScript", "chargeCard();", true);
            }
            else if (hidWarning.Value == "writeFail")
            {
                context.AddError("售卡写卡失败");
            }

            hidWarning.Value = "";
        }
        else if (hidMaketype.Value == "02")//市民卡B卡充值
        {
            if (hidWarning.Value == "CashChargeConfirm")
            {
                //btnSupply_Click(sender, e);
            }
            else if (hidWarning.Value == "rewriteCard") // 重新写卡，生产新的令牌
            {
                hidCardReaderToken.Value = cardReader.createToken(context);
                ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "writeCardWithCheck();", true);
            }
            else if (hidWarning.Value == "writeSuccess")
            {
                SP_PB_updateCardTradePDO pdo = new SP_PB_updateCardTradePDO();
                pdo.CARDTRADENO = hiddentradeno.Value;
                pdo.TRADEID = hidoutTradeid.Value;

                bool ok = TMStorePModule.Excute(context, pdo);

                if (ok)
                {
                    AddMessage("市民卡B卡制卡成功");

                    #region 添加对代理营业厅预付款的验证,扣费后如果超过预警额度则提示
                    int opMoney = Convert.ToInt32(Convert.ToDecimal(labSZTCardChargeMoney.Text) * 100);
                    DeptBalunitHelper.ValdatePrepay(context, opMoney, "1");
                    #endregion
                }
            }
            else if (hidWarning.Value == "writeFail")
            {
                context.AddError("充值写卡失败");
            }


            hidCardnoForCheck.Value = "";//用于写卡前验证页面上的卡号和读卡器上的卡是否一致
            hidWarning.Value = "";
        }
        else if (hidMaketype.Value == "03")//利金卡
        {
            if (hidWarning.Value == "writeSuccess") // 写卡成功
            {
                #region 添加对代理营业厅预付款的验证,扣费后如果超过预警额度则提示
                int opMoney = Convert.ToInt32(Convert.ToDecimal(selCashGiftValue.SelectedValue) * 100);
                DeptBalunitHelper.ValdatePrepay(context, opMoney, "1");
                #endregion

                context.SPOpen();
                context.AddField("p_TRADEID").Value = hidSeqNo.Value;
                context.AddField("p_CARDTRADENO").Value = hidTradeNo.Value;
                bool ok = context.ExecuteSP("SP_PB_updateCardTrade");

                if (ok)
                {
                    AddMessage("利金卡制卡成功");
                }
            }
            else if (hidWarning.Value == "writeFail") // 写卡失败
            {
                context.AddError("利金卡写卡失败");
            }

            hidCardnoForCheck.Value = "";//用于写卡前验证页面上的卡号和读卡器上的卡是否一致
            hidWarning.Value = "";
        }
        else if (hidMaketype.Value == "05")//旅游卡售卡
        {
            if (hidWarning.Value == "writeSuccess")
            {
                #region 添加对代理营业厅预付款的验证,扣费后如果超过预警额度则提示
                int opMoney = Convert.ToInt32(hidCardcostFee.Value)
                    + Convert.ToInt32(hidCardcostFee.Value);

                DeptBalunitHelper.ValdatePrepay(context, opMoney, "1");
                #endregion
                AddMessage("售卡成功!");
                hidCardnoForCheck.Value = "";//用于写卡前验证页面上的卡号和读卡器上的卡是否一致
                hidWarning.Value = "";
            }
            else if (hidWarning.Value == "writeFail")
            {
                context.AddError("售卡写卡失败");
            }

            hidWarning.Value = "";
        }

    }
    #region 利金卡制卡
    /// <summary>
    /// 利金卡DropDownList选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void selCashGiftValue_Changed(object sender, EventArgs e)
    {
        hidCashGiftValue.Value = selCashGiftValue.SelectedValue;
        if (selCashGiftValue.SelectedValue == "")
        {
            //清空
            labCashGiftValue.Text = "";
            labCashGiftOrderNum.Text = "";
            labCashGiftLeftNum.Text = "";
        }
        else
        {
            //制卡数据准备
            string sql = "select t.COUNT,t.LEFTQTY from tf_f_cashgiftorder t where "
                         + "t.orderno = '" + getDataKeys("ORDERNO") + "' and t.VALUE = '" + Convert.ToDecimal(selCashGiftValue.SelectedValue) * 100 + "'";
            context.DBOpen("Select");
            DataTable data = context.ExecuteReader(sql);

            if (data.Rows.Count > 0)
            {
                labCashGiftValue.Text = selCashGiftValue.SelectedItem.ToString();
                labCashGiftOrderNum.Text = data.Rows[0]["COUNT"].ToString();
                labCashGiftLeftNum.Text = data.Rows[0]["LEFTQTY"].ToString();
                //利金卡制卡按钮可用
                btnCashGiftMake.Enabled = true;
            }
        }
    }
    /// <summary>
    /// 利金卡制卡按钮点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnCashGiftMake_Click(object sender, EventArgs e)
    {
        if (selCashGiftValue.SelectedValue == "")
        {
            context.AddError("请选择利金卡面额");
            return;
        }

        if (labCashGiftLeftNum.Text.Trim() == "0")
        {
            context.AddError("此面额利金卡已完成制卡");
            return;
        }

        if (string.IsNullOrEmpty(txtCashGiftCardNo.Text.Trim()))
        {
            context.AddError("读卡失败");
            return;
        }

        //string sql = "select orderno from TF_F_CASHGIFTRELATION where CARDNO = '" + txtCashGiftCardNo.Text.Trim() + "'";
        //context.DBOpen("Select");
        //DataTable data = context.ExecuteReader(sql);
        //if (data.Rows.Count > 0)
        //{
        //    context.AddError("该卡已关联");
        //    return;
        //}
        //执行制卡存储过程
        context.SPOpen();
        context.AddField("p_ORDERNO").Value = getDataKeys("ORDERNO"); // 提交售卡
        context.AddField("P_CARDNO").Value = txtCashGiftCardNo.Text;
        context.AddField("P_VALUE").Value = Convert.ToInt32(selCashGiftValue.SelectedValue) * 100;
        context.AddField("P_WALLET1").Value = (int)(Convert.ToDecimal(hidCardBalance.Value) * 100);
        context.AddField("P_WALLET2").Value = (int)(Convert.ToDecimal(hidWallet2.Value) * 100);
        context.AddField("P_STARTDATE").Value = hidStartDate.Value;
        context.AddField("P_ENDDATE").Value = hidEndDate.Value;

        context.AddField("P_EXPIREDDATE").Value = "20501231";

        int saleMoney = Convert.ToInt32(selCashGiftValue.SelectedValue) * 100;
        context.AddField("P_SALEMONEY").Value = saleMoney;

        context.AddField("P_ID").Value = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        context.AddField("P_CARDTRADENO").Value = hidTradeNo.Value;
        context.AddField("P_ASN").Value = hidAsn.Value.Substring(4, 16);

        context.AddField("P_SELLCHANNELCODE").Value = "01";
        context.AddField("P_TERMINALNO").Value = "112233445566";   // 目前固定写成112233445566

        context.AddField("P_CURRCARDNO").Value = context.s_CardID;
        context.AddField("p_cardPrice", "Int32", "output", "");
        context.AddField("P_SEQNO", "String", "output", "16");
        context.AddField("P_WRITECARDSCRIPT", "string", "output", "1024");

        bool ok = context.ExecuteSP("SP_GC_ORDERMAKECASHGIFTCARD");

        if (ok)
        {
            hidSeqNo.Value = "" + context.GetField("P_SEQNO").Value;
            string writeCardScripts = "" + context.GetField("P_WRITECARDSCRIPT").Value;

            //完成制卡
            CompleteMake();
            if (context.hasError())
            {
                return;
            }

            //利金卡
            hidMaketype.Value = "03";
            hidCardnoForCheck.Value = txtCashGiftCardNo.Text;//用于写卡前验证页面上的卡号和读卡器上的卡是否一致
            //校验
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "CardAndReadCardForCheck", "CardAndReadCardForCheck();", true);

            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript", writeCardScripts, true);

            //刷新页面
            divInfo.InnerHtml = GetOrderMakeOrComfirmHtml(getDataKeys("ORDERNO"), getDataKeys("GROUPNAME"), getDataKeys("NAME"),
            getDataKeys("TOTALMONEY"), getDataKeys("ORDERSTATE"), getDataKeys("INPUTTIME"),
            (Convert.ToDecimal(getDataKeys("CASHGIFTMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("SZTCARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("LVYOUMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CHARGECARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CUSTOMERACCMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CUSTOMERACCHASMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("READERMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("GARDENCARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("RELAXCARDMONEY")) / 100).ToString());

            if (getDataKeys("ISRELATED") == "1:制卡关联")
            {
                //关联卡
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showdiv", "ShowIsRelated(1);", true);
            }
            else
            {
                //关联卡
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showdiv", "ShowIsRelated(0);", true);
            }

            selSZTCardType.SelectedValue = hidSZTCardtype.Value;
            selCashGiftValue.SelectedValue = hidCashGiftValue.Value;
            selCashGiftValue_Changed(sender, e);
        }
    }
    #endregion
    #region 市民卡B卡制卡
    /// <summary>
    /// 市民卡B卡DropDownList选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void selSZTCardType_Changed(object sender, EventArgs e)
    {
        hidSZTCardtype.Value = selSZTCardType.SelectedValue;
        if (selSZTCardType.SelectedValue == "")
        {
            //清空
            labSZTCardType.Text = "";
            labSZTCardChargeMoney.Text = "";
            labSZTCardOrderNum.Text = "";
            labSZTCardLeftNum.Text = "";
        }
        else
        {
            //制卡数据准备 加上条件t.COUNT不等于0
            string sql = "select t.COUNT,t.TOTALCHARGEMONEY,t.LEFTQTY  from tf_f_sztcardorder t where t.COUNT<>0 "
                         + "and t.orderno = '" + getDataKeys("ORDERNO") + "' and t.CARDTYPECODE = '" + selSZTCardType.SelectedValue + "'";
            context.DBOpen("Select");
            DataTable data = context.ExecuteReader(sql);

            if (data.Rows.Count > 0)
            {
                labSZTCardType.Text = selSZTCardType.SelectedItem.ToString();
                if (data.Rows[0]["COUNT"].ToString() == "0")
                {
                    labSZTCardChargeMoney.Text = "0";
                }
                else
                {
                    labSZTCardChargeMoney.Text = (Convert.ToInt32(data.Rows[0]["TOTALCHARGEMONEY"].ToString()) / 100 / Convert.ToInt32(data.Rows[0]["COUNT"].ToString())).ToString();
                }
                labSZTCardOrderNum.Text = data.Rows[0]["COUNT"].ToString();
                labSZTCardLeftNum.Text = data.Rows[0]["LEFTQTY"].ToString();
                //利金卡制卡按钮可用
                btnSZTCardMake.Enabled = true;   
            }

            //显示市民卡B卡旧卡关联 add by youyue 20130927
            string sql2 = "select * from tf_f_sztcardorder t where t.count = 0 and t.unitprice = 0 and t.totalmoney<>0  "
                         + "and t.orderno = '" + getDataKeys("ORDERNO") + "' and t.CARDTYPECODE = '" + selSZTCardType.SelectedValue + "'";
            context.DBOpen("Select");
            DataTable data2 = context.ExecuteReader(sql2);
            if (data2.Rows.Count > 0)
            {
                //市民卡B卡旧卡关联可用
                btnOldSZTCardMake.Enabled = true;
            }
        }
    }
    /// <summary>
    /// 市民卡B卡制卡按钮点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSZTCardMake_Click(object sender, EventArgs e)
    {
        if (selSZTCardType.SelectedValue == "")
        {
            context.AddError("请选择市民卡B卡卡类型");
            return;
        }

        if (labSZTCardLeftNum.Text.Trim() == "0")
        {
            context.AddError("此类型市民卡B卡已完成制卡");
            return;
        }

        if (string.IsNullOrEmpty(txtSZTCardNo.Text.Trim()))
        {
            context.AddError("读卡失败");
            return;
        }
        if (txtSZTCardNo.Text.Trim().Substring(4, 4) != selSZTCardType.SelectedValue)
        {
            context.AddError("此卡与选择制卡的卡类型不匹配");
            return;
        }
        string sql = "select orderno from TF_F_SZTCARDRELATION where CARDNO = '" + txtSZTCardNo.Text.Trim() + "'";
        context.DBOpen("Select");
        DataTable data = context.ExecuteReader(sql);
        if (data.Rows.Count > 0)
        {
            context.AddError("该卡已关联");
            return;
        }

        #region 添加对代理营业厅预付款的验证,提交前如果扣费后不足最低额度则返回
        int opMoney = Convert.ToInt32(Convert.ToDecimal(labSZTCardChargeMoney.Text) * 100);
        if (DeptBalunitHelper.ValdatePrepay(context, opMoney, "2") == false)
        {
            return;
        }
        #endregion

        TMTableModule tmTMTableModule = new TMTableModule();

        //从用户卡库存表(TL_R_ICUSER)中读取数据
        TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
        ddoTL_R_ICUSERIn.CARDNO = txtSZTCardNo.Text;

        TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

        if (ddoTL_R_ICUSEROut == null)
        {
            context.AddError("A001001101");
            return;
        }

        //获取卡售卡方式
        hidSaletype.Value = ddoTL_R_ICUSEROut.SALETYPE;

        if (hidSaletype.Value != "01" && hidSaletype.Value != "02")
        {
            context.AddError("未找到正确的售卡方式");
            return;
        }

        //计算费用
        //售卡方式为卡费方式
        if (hidSaletype.Value.Equals("01"))
        {
            hidCardcostFee.Value = ddoTL_R_ICUSEROut.CARDPRICE.ToString();
            hidDepositFee.Value = "0";
        }
        //售卡方式为押金方式
        if (hidSaletype.Value.Equals("02"))
        {
            hidCardcostFee.Value = "0";
            hidDepositFee.Value = ddoTL_R_ICUSEROut.CARDPRICE.ToString();
        }

        context.SPOpen();
        context.AddField("p_ORDERNO").Value = getDataKeys("ORDERNO"); // 订单号
        context.AddField("P_CARDNO").Value = txtSZTCardNo.Text.Trim(); // 卡号
        context.AddField("P_CARDTYPECODE").Value = selSZTCardType.SelectedValue; // 卡面类型
        context.AddField("p_ID1").Value = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value.Substring(4, 16)); // ID
        string addnowtime = DateTime.Now.AddSeconds(1).ToString("MMddHHmmss");
        string ID2 = addnowtime + hiddenAsn.Value.Substring(hiddenAsn.Value.Length - 8, 8);
        context.AddField("p_ID2").Value = ID2;
        context.AddField("p_SALETRADETYPECODE").Value = "01"; // 售卡业务类型
        context.AddField("p_DEPOSIT").Value = Convert.ToInt32(hidDepositFee.Value); // 押金
        context.AddField("p_CARDCOST").Value = Convert.ToInt32(hidCardcostFee.Value); // 卡费
        context.AddField("p_SALEOTHERFEE").Value = 0; // 售卡其他费用
        context.AddField("p_CARDTRADENO").Value = hiddentradeno.Value; // 联机交易序号
        context.AddField("p_SELLCHANNELCODE").Value = "01"; // 售卡渠道
        context.AddField("p_SERSTAKETAG").Value = "0"; // 卡服务费收取标志
        context.AddField("p_CUSTRECTYPECODE").Value = "0"; // 是否记名卡

        context.AddField("p_CARDMONEY").Value = Convert.ToInt32(hiddencMoney.Value); // 卡内余额
        context.AddField("p_CARDACCMONEY").Value = 0; // 卡账户金额
        context.AddField("p_ASN").Value = hiddenAsn.Value.Substring(4, 16); // ASN号
        context.AddField("p_SUPPLYMONEY").Value = Convert.ToInt32(Convert.ToDecimal(labSZTCardChargeMoney.Text) * 100); // 充值金额
        context.AddField("p_CHARGEOTHERFEE").Value = 0; // 充值其他费用
        context.AddField("p_CHARGETRADETYPECODE").Value = "02"; // 售卡业务类型编码

        context.AddField("p_TERMNO").Value = "112233445566"; // 终端号
        context.AddField("p_OPERCARDNO").Value = context.s_CardID; // 操作员卡号
        context.AddField("p_CHARGETYPE").Value = ""; // 充值营销模式
        context.AddField("p_TRADEID1", "String", "output", "16", null);
        context.AddField("p_TRADEID2", "String", "output", "16", null);

        hidSupplyMoney.Value = (Convert.ToInt32(Convert.ToDecimal(labSZTCardChargeMoney.Text) * 100)).ToString();
        bool ok = context.ExecuteSP("SP_GC_ORDERMAKESZTCARD");

        if (ok)
        {
            hidoutTradeid.Value = "" + context.GetField("p_TRADEID1").Value;

            //完成制卡
            CompleteMake();
            if (context.hasError())
            {
                return;
            }

            //市民卡B卡售卡
            hidMaketype.Value = "01";

            hidCardReaderToken.Value = cardReader.createToken(context);
            hidCardnoForCheck.Value = txtSZTCardNo.Text;//用于写卡前验证页面上的卡号和读卡器上的卡是否一致

            //售卡写卡
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "saleCard();", true);

            //刷新页面
            divInfo.InnerHtml = GetOrderMakeOrComfirmHtml(getDataKeys("ORDERNO"), getDataKeys("GROUPNAME"), getDataKeys("NAME"),
            getDataKeys("TOTALMONEY"), getDataKeys("ORDERSTATE"), getDataKeys("INPUTTIME"),
            (Convert.ToDecimal(getDataKeys("CASHGIFTMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("SZTCARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("LVYOUMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CHARGECARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CUSTOMERACCMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CUSTOMERACCHASMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("READERMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("GARDENCARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("RELAXCARDMONEY")) / 100).ToString());

            if (getDataKeys("ISRELATED") == "1:制卡关联")
            {
                //关联卡
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showdiv", "ShowIsRelated(1);", true);
            }
            else
            {
                //关联卡
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showdiv", "ShowIsRelated(0);", true);
            }

            selCashGiftValue.SelectedValue = hidCashGiftValue.Value;
            selSZTCardType.SelectedValue = hidSZTCardtype.Value;
            selSZTCardType_Changed(sender, e);

        }
    }
    #endregion

    #region 旅游卡制卡
    /// <summary>
    /// 旅游卡DropDownList选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void selLvYouType_Changed(object sender, EventArgs e)
    {
        //DONE: 修改绑定旅游卡
        hideLvYouCardtype.Value = selLvYouType.SelectedValue;
        if (selLvYouType.SelectedValue == "")
        {
            //清空
            labLvYouType.Text = "";
            labLvYouChargeMoney.Text = "";
            labLvYouOrderNum.Text = "";
            labLvYouLeftNum.Text = "";
        }
        else
        {
            //制卡数据准备 加上条件t.COUNT不等于0
            string sql = "select t.COUNT,t.TOTALCHARGEMONEY,t.LEFTQTY  from tf_f_sztcardorder t where t.COUNT<>0 "
                         + "and t.orderno = '" + getDataKeys("ORDERNO") + "' and t.CARDTYPECODE = '" + selLvYouType.SelectedValue + "'";
            context.DBOpen("Select");
            DataTable data = context.ExecuteReader(sql);

            if (data.Rows.Count > 0)
            {
                labLvYouType.Text = selLvYouType.SelectedItem.ToString();
                if (data.Rows[0]["COUNT"].ToString() == "0")
                {
                    labLvYouChargeMoney.Text = "0";
                }
                else
                {
                    labLvYouChargeMoney.Text = (Convert.ToInt32(data.Rows[0]["TOTALCHARGEMONEY"].ToString()) / 100 / Convert.ToInt32(data.Rows[0]["COUNT"].ToString())).ToString();
                }
                labLvYouOrderNum.Text = data.Rows[0]["COUNT"].ToString();
                labLvYouLeftNum.Text = data.Rows[0]["LEFTQTY"].ToString();
                //制卡按钮可用
                btnLvYouMake.Enabled = true;
            }
        }
    }
    /// <summary>
    /// 旅游卡制卡按钮点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnLvYouMake_Click(object sender, EventArgs e)
    {
        if (selLvYouType.SelectedValue == "")
        {
            context.AddError("请选择旅游卡类型");
            return;
        }

        if (labLvYouLeftNum.Text.Trim() == "0")
        {
            context.AddError("此类型旅游卡已完成制卡");
            return;
        }

        if (string.IsNullOrEmpty(txtLvYouNo.Text.Trim()))
        {
            context.AddError("读卡失败");
            return;
        }
        if (txtLvYouNo.Text.Trim().Substring(4, 4) != selLvYouType.SelectedValue)
        {
            context.AddError("此卡与选择制卡的卡类型不匹配");
            return;
        }
        string sql = "select orderno from TF_F_SZTCARDRELATION where CARDNO = '" + txtLvYouNo.Text.Trim() + "'";
        context.DBOpen("Select");
        DataTable data = context.ExecuteReader(sql);
        if (data.Rows.Count > 0)
        {
            context.AddError("该卡已关联");
            return;
        }

        if (Convert.ToDecimal(hiddencMoney.Value) != 0)
        {
            context.AddError("A001001144");
            return;
        }

        #region 添加对代理营业厅预付款的验证,提交前如果扣费后不足最低额度则返回
        int opMoney = Convert.ToInt32(Convert.ToDecimal(labLvYouChargeMoney.Text) * 100);
        if (DeptBalunitHelper.ValdatePrepay(context, opMoney, "2") == false)
        {
            return;
        }
        #endregion

        TMTableModule tmTMTableModule = new TMTableModule();

        //从用户卡库存表(TL_R_ICUSER)中读取数据
        TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
        ddoTL_R_ICUSERIn.CARDNO = txtLvYouNo.Text;

        TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

        if (ddoTL_R_ICUSEROut == null)
        {
            context.AddError("A001001101");
            return;
        }

        //获取卡售卡方式
        hidSaletype.Value = ddoTL_R_ICUSEROut.SALETYPE;

        if (hidSaletype.Value != "01" && hidSaletype.Value != "02")
        {
            context.AddError("未找到正确的售卡方式");
            return;
        }

        //计算费用
        //从前台业务交易费用表中读取售卡费用数据
        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "7H";

        TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001001137", "TD_M_TRADEFEE", null);
        hidDepositFee.Value = "0";
        hidCardcostFee.Value = "0";
        for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        {
            //"00"为卡押金
            if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "00")
                hidDepositFee.Value = Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE).ToString();
            //"03"为手续费
            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "03")
                hidCardcostFee.Value = Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE).ToString();
        }
        //DONE:根据旅游卡售卡页面重写
        context.SPOpen();
        context.AddField("p_ORDERNO").Value = getDataKeys("ORDERNO"); // 订单号
        context.AddField("P_CARDNO").Value = txtLvYouNo.Text.Trim(); // 卡号
        context.AddField("P_CARDTYPECODE").Value = selLvYouType.SelectedValue; // 卡面类型
        context.AddField("p_ID1").Value = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value.Substring(4, 16)); // ID
        string addnowtime = DateTime.Now.AddSeconds(1).ToString("MMddHHmmss");
        string ID2 = addnowtime + hiddenAsn.Value.Substring(hiddenAsn.Value.Length - 8, 8);
        context.AddField("p_ID2").Value = ID2;
        context.AddField("p_SALETRADETYPECODE").Value = "01"; // 售卡业务类型
        context.AddField("p_DEPOSIT").Value = Convert.ToInt32(hidDepositFee.Value); // 押金
        context.AddField("p_CARDCOST").Value = Convert.ToInt32(hidCardcostFee.Value); // 卡费
        context.AddField("p_SALEOTHERFEE").Value = 0; // 售卡其他费用
        context.AddField("p_CARDTRADENO").Value = hiddentradeno.Value; // 联机交易序号
        context.AddField("p_SELLCHANNELCODE").Value = "01"; // 售卡渠道
        context.AddField("p_SERSTAKETAG").Value = "0"; // 卡服务费收取标志
        context.AddField("p_CUSTRECTYPECODE").Value = "0"; // 是否记名卡

        context.AddField("p_CARDMONEY").Value = Convert.ToInt32(hiddencMoney.Value); // 卡内余额
        context.AddField("p_CARDACCMONEY").Value = 0; // 卡账户金额
        context.AddField("p_ASN").Value = hiddenAsn.Value.Substring(4, 16); // ASN号
        context.AddField("p_SUPPLYMONEY").Value = Convert.ToInt32(Convert.ToDecimal(labLvYouChargeMoney.Text) * 100); // 充值金额
        context.AddField("p_CHARGEOTHERFEE").Value = 0; // 充值其他费用
        context.AddField("p_CHARGETRADETYPECODE").Value = "02"; // 售卡业务类型编码

        context.AddField("p_TERMNO").Value = "112233445566"; // 终端号
        context.AddField("p_OPERCARDNO").Value = context.s_CardID; // 操作员卡号
        context.AddField("p_CHARGETYPE").Value = ""; // 充值营销模式
        context.AddField("p_TRADEID1", "String", "output", "16", null);
        context.AddField("p_TRADEID2", "String", "output", "16", null);

        hidSupplyMoney.Value = (Convert.ToInt32(Convert.ToDecimal(labLvYouChargeMoney.Text) * 100)).ToString();
        bool ok = context.ExecuteSP("SP_GC_ORDERMAKELVYOU");

        if (ok)
        {
            hidoutTradeid.Value = "" + context.GetField("p_TRADEID1").Value;

            //完成制卡
            CompleteMake();
            if (context.hasError())
            {
                return;
            }

            //旅游卡售卡
            hidMaketype.Value = "05";

            hidCardReaderToken.Value = cardReader.createToken(context);
            hidCardnoForCheck.Value = txtLvYouNo.Text;//用于写卡前验证页面上的卡号和读卡器上的卡是否一致

            //售卡写卡
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "changeCard();", true);

            //刷新页面
            divInfo.InnerHtml = GetOrderMakeOrComfirmHtml(getDataKeys("ORDERNO"), getDataKeys("GROUPNAME"), getDataKeys("NAME"),
            getDataKeys("TOTALMONEY"), getDataKeys("ORDERSTATE"), getDataKeys("INPUTTIME"),
            (Convert.ToDecimal(getDataKeys("CASHGIFTMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("SZTCARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("LVYOUMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CHARGECARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CUSTOMERACCMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CUSTOMERACCHASMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("READERMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("GARDENCARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("RELAXCARDMONEY")) / 100).ToString());

            if (getDataKeys("ISRELATED") == "1:制卡关联")
            {
                //关联卡
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showdiv", "ShowIsRelated(1);", true);
            }
            else
            {
                //关联卡
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showdiv", "ShowIsRelated(0);", true);
            }

            selCashGiftValue.SelectedValue = hidCashGiftValue.Value;
            selLvYouType.SelectedValue = hideLvYouCardtype.Value;
            selLvYouType_Changed(sender, e);
            

        }
    }
    #endregion



    #region 充值卡关联
    #region 充值卡表格所有事件
    protected void btnChargeCardAdd_Click(object sender, EventArgs e)
    {
        //更新 CashGiftTable
        UpdateChargeCardTable();

        DataRow row = ChargeCardTable.NewRow();
        row["FromCardNo"] = null;
        row["ToCardNo"] = null;
        row["ChargeCardValue"] = null;
        row["ChargeCardNum"] = null;
        ChargeCardTable.Rows.Add(row);
        gvChargeCard.DataSource = ChargeCardTable;
        gvChargeCard.DataBind();

    }
    private void UpdateChargeCardTable()
    {
        for (int i = 0; i < gvChargeCard.Rows.Count; i++)
        {

            TextBox txtFromCardNo = (TextBox)gvChargeCard.Rows[i].FindControl("txtFromCardNo");
            ChargeCardTable.Rows[i]["FromCardNo"] = txtFromCardNo.Text;
            TextBox txtToCardNo = (TextBox)gvChargeCard.Rows[i].FindControl("txtToCardNo");
            ChargeCardTable.Rows[i]["ToCardNo"] = txtToCardNo.Text;
            TextBox txtValue = (TextBox)gvChargeCard.Rows[i].FindControl("txtChargeCardValue");
            ChargeCardTable.Rows[i]["ChargeCardValue"] = txtValue.Text;
            TextBox txtNum = (TextBox)gvChargeCard.Rows[i].FindControl("txtChargeCardNum");
            ChargeCardTable.Rows[i]["ChargeCardNum"] = txtNum.Text;
        }
    }
    protected void gvChargeCard_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        //更新CashGiftTable
        UpdateChargeCardTable();
        if (e.CommandName == "delete")
        {
            int index = Convert.ToInt32(e.CommandArgument.ToString());
            ChargeCardTable.Rows[index].Delete();
        }
    }
    protected void gvChargeCard_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        gvChargeCard.DataSource = ChargeCardTable;
        gvChargeCard.DataBind();
    }
    #endregion
    /// <summary>
    /// 充值卡关联按钮点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnChargeCardMake_Click(object sender, EventArgs e)
    {
        Validation valid = new Validation(context);
        ValidChargeCardInput(valid);

        string sql = "select a.LEFTQTY,b.MONEY/100 MONEY from TF_F_CHARGECARDORDER a,TP_XFC_CARDVALUE b where a.VALUECODE = b.VALUECODE and a.ORDERNO = '" + getDataKeys("ORDERNO") + "'";
        context.DBOpen("Select");
        DataTable data = context.ExecuteReader(sql);

        if (data.Rows.Count <= 0)
        {
            context.AddError("未找到该订单充值卡明细");
        }
        if (context.hasError())
        {
            return;
        }
        //清空临时表
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_ORDER");
        context.DBCommit();
        //简历充值卡面额与数量二维数组
        string[,] valuenum = new string[10, 2];
        //赋值
        valuenum[0, 0] = "20";
        valuenum[1, 0] = "30";
        valuenum[2, 0] = "50";
        valuenum[3, 0] = "100";
        valuenum[4, 0] = "500";
        valuenum[5, 0] = "200";
        valuenum[6, 0] = "0.01";
        valuenum[7, 0] = "0.02";
        valuenum[8, 0] = "1000";
        valuenum[9, 0] = "1";
        for (int i = 0; i < 10; i++)
        {
            valuenum[i, 1] = "0";
        }
        bool hasvalue = false;
        context.DBOpen("Insert");
        //充值卡数据入临时表
        //遍历充值卡列表
        for (int i = 0; i < gvChargeCard.Rows.Count; i++)
        {
            TextBox txtFromCardNo = (TextBox)gvChargeCard.Rows[i].FindControl("txtFromCardNo");
            TextBox txtToCardNo = (TextBox)gvChargeCard.Rows[i].FindControl("txtToCardNo");
            TextBox txtValue = (TextBox)gvChargeCard.Rows[i].FindControl("txtChargeCardValue");
            TextBox txtNum = (TextBox)gvChargeCard.Rows[i].FindControl("txtChargeCardNum");
            //string ChargeCardValue = gvChargeCard.Rows[i].Cells[2].Text;
            //string ChargeCardNum = gvChargeCard.Rows[i].Cells[3].Text;

            for (int j = 0; j < data.Rows.Count; j++)
            {
                if (data.Rows[j]["MONEY"].ToString() == txtValue.Text)
                {
                    hasvalue = true;
                }
            }

            if (hasvalue == false)
            {
                context.AddError("第" + (i + 1) + "行关联的充值卡不是订单要求的充值卡");
                return;
            }

            //遍历数组，如果数组的金额值与充值卡列表中的面额一致，则累加该面额充值卡数量
            for (int m = 0; m < 10; m++)
            {
                if (valuenum[m, 0] == txtValue.Text)
                {
                    valuenum[m, 1] = (Convert.ToInt32(valuenum[m, 1]) + Convert.ToInt32(txtNum.Text)).ToString();
                }
            }
            if (txtFromCardNo.Text.Trim().Length > 0 && txtToCardNo.Text.Trim().Length > 0 &&
                txtValue.Text.Trim().Length > 0 && txtNum.Text.Trim().Length > 0)
            {
                context.ExecuteNonQuery("insert into TMP_ORDER(F0, F1, F2, F3, F4) values('"
                        + Session.SessionID + "','" + txtFromCardNo.Text.Trim()
                        + "','" + txtToCardNo.Text.Trim() + "','" + txtFromCardNo.Text.Trim().Substring(4, 1) + "','" + txtNum.Text.Trim() + "')");
            }
        }

        context.DBCommit();

        //遍历充值卡订单明细表
        for (int j = 0; j < data.Rows.Count; j++)
        {
            //遍历数组，如果数组中金额值与充值卡订单明细表中的金额值一致，并且列表中累加的改面额充值卡数量超过了订单剩余数量，则不允许关联
            for (int n = 0; n < 10; n++)
            {
                if (data.Rows[j]["MONEY"].ToString() == valuenum[n, 0])
                {
                    if (Convert.ToInt32(valuenum[n, 1]) > Convert.ToInt32(data.Rows[j]["LEFTQTY"].ToString()))
                    {
                        context.AddError("关联第" + (j + 1).ToString() + "行充值卡后，该面额关联的总数量超过了订单要求的数量");
                        return;
                    }
                }
            }
        }

        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        context.AddField("p_ORDERNO").Value = getDataKeys("ORDERNO"); // 订单号
        bool ok = context.ExecuteSP("SP_GC_ORDERMAKECHARGECARD");

        if (ok)
        {
            //完成制卡
            CompleteMake();
            if (context.hasError())
            {
                return;
            }

            AddMessage("关联充值卡成功");

            ChargeCardTable.Clear();
            DataRow row = ChargeCardTable.NewRow();
            row["FromCardNo"] = null;
            row["ToCardNo"] = null;
            row["ChargeCardValue"] = null;
            row["ChargeCardNum"] = null;
            ChargeCardTable.Rows.Add(row);
            gvChargeCard.DataSource = ChargeCardTable;
            gvChargeCard.DataBind();

            //刷新页面
            divInfo.InnerHtml = GetOrderMakeOrComfirmHtml(getDataKeys("ORDERNO"), getDataKeys("GROUPNAME"), getDataKeys("NAME"),
            getDataKeys("TOTALMONEY"), getDataKeys("ORDERSTATE"), getDataKeys("INPUTTIME"),
            (Convert.ToDecimal(getDataKeys("CASHGIFTMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("SZTCARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("LVYOUMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CHARGECARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CUSTOMERACCMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CUSTOMERACCHASMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("READERMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("GARDENCARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("RELAXCARDMONEY")) / 100).ToString());

            if (getDataKeys("ISRELATED") == "1:制卡关联")
            {
                //关联卡
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showdiv", "ShowIsRelated(1);", true);
            }
            else
            {
                //关联卡
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showdiv", "ShowIsRelated(0);", true);
            }

            selCashGiftValue.SelectedValue = hidCashGiftValue.Value;
            selSZTCardType.SelectedValue = hidSZTCardtype.Value;
        }
    }
    /// <summary>
    /// 充值卡有效性校验
    /// </summary>
    /// <param name="valid"></param>
    private void ValidChargeCardInput(Validation valid)
    {
        for (int i = 0; i < gvChargeCard.Rows.Count; i++)
        {
            TextBox txtFromCardNo = (TextBox)gvChargeCard.Rows[i].FindControl("txtFromCardNo");
            TextBox txtToCardNo = (TextBox)gvChargeCard.Rows[i].FindControl("txtToCardNo");
            TextBox txtValue = (TextBox)gvChargeCard.Rows[i].FindControl("txtChargeCardValue");
            TextBox txtNum = (TextBox)gvChargeCard.Rows[i].FindControl("txtChargeCardNum");

            if (txtFromCardNo.Text.Trim().Length > 0 || txtToCardNo.Text.Trim().Length > 0 ||
                txtValue.Text.Trim().Length > 0 || txtNum.Text.Trim().Length > 0)
            {
                if (txtFromCardNo.Text.Trim().Length < 1)
                {
                    context.AddError("起始卡号不能为空", txtFromCardNo);
                }
                if (txtToCardNo.Text.Trim().Length < 1)
                {
                    context.AddError("终止卡号不能为空", txtToCardNo);
                }
                if (txtValue.Text.Trim().Length < 1)
                {
                    context.AddError("面额不能为空", txtValue);
                }
                else if (!Validation.isPosRealNum(txtValue.Text.Trim()))
                {
                    context.AddError("面额必须是正数", txtValue);
                }
                if (txtNum.Text.Trim().Length < 1)
                {
                    context.AddError("购卡数量不能为空", txtNum);
                }
                if (context.hasError())
                {
                    return;
                }
            }
            if (txtValue.Text.Trim().Length > 0 && txtNum.Text.Trim().Length > 0 && txtFromCardNo.Text.Trim().Length > 0 && txtToCardNo.Text.Trim().Length > 0)
            {
                long quantity = ChargeCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo);
                bool b = ChargeCardHelper.hasSameFaceValue(context, txtFromCardNo, txtToCardNo);
                if (!b)
                {
                    context.ErrorMessage.Clear();
                    context.AddError("第" + (i + 1).ToString() + "行起始卡号和终止卡号之间的充值卡不具有相同面值，请重新选择起讫卡号", txtFromCardNo);
                    return;
                }
                if (quantity != Convert.ToInt64(txtNum.Text.Trim()))
                {
                    context.AddError("购卡数量和卡号号段内卡号总数不一致", txtNum);
                }
                if (txtFromCardNo.Text.Trim().Substring(0, 6) != txtToCardNo.Text.Trim().Substring(0, 6))
                {
                    context.AddError("起始卡号和终止卡号月份批次号必须一致", txtFromCardNo);
                }
            }


        }
    }
    #endregion

    #region 读卡器关联
    #region 读卡器表格所有事件
    protected void btnReaderAdd_Click(object sender, EventArgs e)
    {
        //更新 ReaderTable
        UpdateReaderTable();

        //获取读卡器信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "ReaderOrderInfo", getDataKeys("ORDERNO"));
        string readerPrice = data.Rows.Count > 0 ? (Convert.ToInt32(data.Rows[0]["VALUE"].ToString()) / 100.0).ToString() : "";

        DataRow row = ReaderTable.NewRow();
        row["BeginCardNo"] = null;
        row["EndCardNo"] = null;
        row["ReaderValue"] = readerPrice;
        row["ReaderNum"] = null;
        ReaderTable.Rows.Add(row);
        gvReader.DataSource = ReaderTable;
        gvReader.DataBind();

    }
    private void UpdateReaderTable()
    {
        

        for (int i = 0; i < gvReader.Rows.Count; i++)
        {

            TextBox txtBeginCardNo = (TextBox)gvReader.Rows[i].FindControl("txtBeginCardNo");
            ReaderTable.Rows[i]["BeginCardNo"] = txtBeginCardNo.Text;
            TextBox txtEndCardNo = (TextBox)gvReader.Rows[i].FindControl("txtEndCardNo");
            ReaderTable.Rows[i]["EndCardNo"] = txtEndCardNo.Text;
            TextBox txtReaderValue = (TextBox)gvReader.Rows[i].FindControl("txtReaderValue");
            ReaderTable.Rows[i]["ReaderValue"] = txtReaderValue.Text;
            TextBox txtReaderNum = (TextBox)gvReader.Rows[i].FindControl("txtReaderNum");
            ReaderTable.Rows[i]["ReaderNum"] = txtReaderNum.Text;
        }
    }
    protected void gvReader_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        //更新ReaderTable
        UpdateReaderTable();
        if (e.CommandName == "delete")
        {
            int index = Convert.ToInt32(e.CommandArgument.ToString());
            ReaderTable.Rows[index].Delete();
        }
    }
    protected void gvReader_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        gvReader.DataSource = ReaderTable;
        gvReader.DataBind();
    }
    #endregion
    /// <summary>
    /// 读卡器关联按钮点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReaderMake_Click(object sender, EventArgs e)
    {
        Validation valid = new Validation(context);
        ValidReaderInput(valid);

        //清空临时表
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_ORDER");
        context.DBCommit();
        
        context.DBOpen("Insert");
        //读卡器数据入临时表
        for (int i = 0; i < gvReader.Rows.Count; i++)
        {
            TextBox txtBeginCardNo = (TextBox)gvReader.Rows[i].FindControl("txtBeginCardNo");
            TextBox txtEndCardNo = (TextBox)gvReader.Rows[i].FindControl("txtEndCardNo");
            TextBox txtValue = (TextBox)gvReader.Rows[i].FindControl("txtReaderValue");
            TextBox txtNum = (TextBox)gvReader.Rows[i].FindControl("txtReaderNum");

            hasPower(txtBeginCardNo.Text.Trim(), txtEndCardNo.Text.Trim());
            if (context.hasError())
            {
                //如果操作员不具备出售此读卡器，则退出提示错误
                return;
            }

            if (txtBeginCardNo.Text.Trim().Length > 0 && txtEndCardNo.Text.Trim().Length > 0 &&
                txtValue.Text.Trim().Length > 0 && txtNum.Text.Trim().Length > 0)
            {
                context.ExecuteNonQuery("insert into TMP_ORDER(F0, F1, F2, F3, F4) values('"
                        + Session.SessionID + "','" + txtBeginCardNo.Text.Trim()
                        + "','" + txtEndCardNo.Text.Trim() + "','" + (Convert.ToDecimal(txtValue.Text.Trim())*100).ToString() + "','" + txtNum.Text.Trim() + "')");
            }
        }

        context.DBCommit();

        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        context.AddField("p_ORDERNO").Value = getDataKeys("ORDERNO"); // 订单号
        bool ok = context.ExecuteSP("SP_GC_ORDERMAKEREADER");

        if (ok)
        {
            //完成制卡
            CompleteMake();
            if (context.hasError())
            {
                return;
            }

            AddMessage("关联读卡器成功");

            ReaderTable.Clear();
            DataRow row = ReaderTable.NewRow();
            row["BeginCardNo"] = null;
            row["EndCardNo"] = null;
            row["ReaderValue"] = null;
            row["ReaderNum"] = null;
            ReaderTable.Rows.Add(row);
            gvReader.DataSource = ReaderTable;
            gvReader.DataBind();

            //刷新页面
            divInfo.InnerHtml = GetOrderMakeOrComfirmHtml(getDataKeys("ORDERNO"), getDataKeys("GROUPNAME"), getDataKeys("NAME"),
            getDataKeys("TOTALMONEY"), getDataKeys("ORDERSTATE"), getDataKeys("INPUTTIME"),
            (Convert.ToDecimal(getDataKeys("CASHGIFTMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("SZTCARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("LVYOUMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CHARGECARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CUSTOMERACCMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CUSTOMERACCHASMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("READERMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("GARDENCARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("RELAXCARDMONEY")) / 100).ToString());

            if (getDataKeys("ISRELATED") == "1:制卡关联")
            {
                //关联卡
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showdiv", "ShowIsRelated(1);", true);
            }
            else
            {
                //关联卡
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showdiv", "ShowIsRelated(0);", true);
            }

            selCashGiftValue.SelectedValue = hidCashGiftValue.Value;
            selSZTCardType.SelectedValue = hidSZTCardtype.Value;
        }
    }
    protected void hasPower(string beginReader, string endReader)
    {
        context.DBCommit();       

        string sql = " SELECT ASSIGNEDDEPARTID FROM TL_R_READER " +
                   " WHERE SERIALNUMBER BETWEEN '" + beginReader + "' AND '" + endReader + "' " +
                   " AND READERSTATE IN ('1','4') GROUP BY ASSIGNEDDEPARTID";
        context.DBOpen("Select");
        DataTable data = context.ExecuteReader(sql);

        if (data.Rows.Count < 1)
            //未查询出结果时
            context.AddError("出售读卡器不是出库或回收状态");
        else if (data.Rows.Count > 1)
            //返回多个部门
            context.AddError("出售的读卡器属于不同的部门！");
        else
            //比较所属员工和当前员工部门
            if (data.Rows[0][0].ToString() != context.s_DepartID)
                context.AddError("读卡器所属部门与当前员工部门不符，不允许出售！");
    }
    /// <summary>
    /// 读卡器有效性校验
    /// </summary>
    /// <param name="valid"></param>
    private void ValidReaderInput(Validation valid)
    {
        for (int i = 0; i < gvReader.Rows.Count; i++)
        {
            TextBox txtBeginCardNo = (TextBox)gvReader.Rows[i].FindControl("txtBeginCardNo");
            TextBox txtEndCardNo = (TextBox)gvReader.Rows[i].FindControl("txtEndCardNo");
            TextBox txtValue = (TextBox)gvReader.Rows[i].FindControl("txtReaderValue");
            TextBox txtNum = (TextBox)gvReader.Rows[i].FindControl("txtReaderNum");

            if (txtBeginCardNo.Text.Trim().Length > 0 || txtEndCardNo.Text.Trim().Length > 0 ||
                txtValue.Text.Trim().Length > 0 || txtNum.Text.Trim().Length > 0)
            {
                if (txtBeginCardNo.Text.Trim().Length < 1)
                {
                    context.AddError("起始序列号不能为空", txtBeginCardNo);
                }
                else if (txtBeginCardNo.Text.Trim().Length != 16)
                {
                    context.AddError("起始序列号必须为16位", txtBeginCardNo);
                }
                else if (!Validation.isNum(txtBeginCardNo.Text.Trim()))
                {
                    context.AddError("起始序列号必须是数字", txtBeginCardNo);
                }
                if (txtEndCardNo.Text.Trim().Length < 1)
                {
                    context.AddError("结束序列号不能为空", txtEndCardNo);
                }
                else if (txtEndCardNo.Text.Trim().Length != 16)
                {
                    context.AddError("结束序列号必须为16位", txtEndCardNo);
                }
                else if (!Validation.isNum(txtEndCardNo.Text.Trim()))
                {
                    context.AddError("结束序列号必须是数字", txtEndCardNo);
                }
                if (context.hasError())
                {
                    return;
                }
                if (Convert.ToInt64(txtEndCardNo.Text.Trim()) < Convert.ToInt64(txtBeginCardNo.Text.Trim()))
                {
                    context.AddError("起始序列号不能大于结束序列号", txtEndCardNo);
                }

                if (txtValue.Text.Trim().Length < 1)
                {
                    context.AddError("单价不能为空", txtValue);
                }
                else if (!Validation.isNum(txtValue.Text.Trim()))
                {
                    context.AddError("单价必须是数字", txtValue);
                }
                if (txtNum.Text.Trim().Length < 1)
                {
                    context.AddError("数量不能为空", txtNum);
                }
                else if (!Validation.isNum(txtNum.Text.Trim()))
                {
                    context.AddError("数量必须是数字", txtNum);
                }
                if (context.hasError())
                {
                    return;
                }
            }
        }
    }
    #endregion

    #region 专有账户关联
    /// <summary>
    /// 专有账户关联按钮点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnCustomerAccMake_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(txtCustomerAccBatchNo.Text.Trim()))
        {
            context.AddError("批量充值批次号不能为空");
        }
        else if (Validation.strLen(txtCustomerAccBatchNo.Text.Trim()) != 16)
        {
            context.AddError("批量充值批次号必须为16位");
        }
        else if (!Validation.isNum(txtCustomerAccBatchNo.Text.Trim()))
        {
            context.AddError("批量充值批次号必须为数字");
        }

        if (context.hasError())
        {
            return;
        }
        context.SPOpen();
        context.AddField("p_ORDERNO").Value = getDataKeys("ORDERNO"); // 订单号
        context.AddField("P_BATCH").Value = txtCustomerAccBatchNo.Text.Trim(); // 批次号
        bool ok = context.ExecuteSP("SP_GC_ORDERMAKECUSTOMERACC");

        if (ok)
        {
            //完成制卡
            CompleteMake();
            if (context.hasError())
            {
                return;
            }

            AddMessage("关联专有账户充值批次" + txtCustomerAccBatchNo.Text + "成功");

            //重新查询专有账户已充值金额
            string sql = "SELECT CUSTOMERACCHASMONEY FROM TF_F_ORDERFORM WHERE ORDERNO = '" + getDataKeys("ORDERNO") + "'";
            context.DBOpen("Select");
            DataTable data = context.ExecuteReader(sql);

            //刷新页面
            divInfo.InnerHtml = GetOrderMakeOrComfirmHtml(getDataKeys("ORDERNO"), getDataKeys("GROUPNAME"), getDataKeys("NAME"),
            getDataKeys("TOTALMONEY"), getDataKeys("ORDERSTATE"), getDataKeys("INPUTTIME"),
            (Convert.ToDecimal(getDataKeys("CASHGIFTMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("SZTCARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("LVYOUMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CHARGECARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CUSTOMERACCMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CUSTOMERACCHASMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("READERMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("GARDENCARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("RELAXCARDMONEY")) / 100).ToString());

            if (getDataKeys("ISRELATED") == "1:制卡关联")
            {
                //关联卡
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showdiv", "ShowIsRelated(1);", true);
            }
            else
            {
                //关联卡
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showdiv", "ShowIsRelated(0);", true);
            }

            selCashGiftValue.SelectedValue = hidCashGiftValue.Value;
            selSZTCardType.SelectedValue = hidSZTCardtype.Value;

            txtCustomerAccBatchNo.Text = "";
        }
    }
    #endregion
    #region 不关联确认
    /// <summary>
    /// 不关联确认按钮点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnComfirmNotRelation_Click(object sender, EventArgs e)
    {
        context.SPOpen();
        context.AddField("p_ORDERNO").Value = getDataKeys("ORDERNO"); // 订单号
        bool ok = context.ExecuteSP("SP_GC_ORDERCOMFIRMUNRELATED");

        if (ok)
        {
            AddMessage("领卡关联确认完成");
        }
    }

    /// <summary>
    /// 完成制卡，判断是否完成制卡，如果是则更改订单状态为完成制卡
    /// </summary>
    protected void CompleteMake()
    {
        //string sql = " select nvl(sum(a.LEFTQTY),0),nvl(sum(b.LEFTQTY)),0),nvl(sum(c.LEFTQTY)),0),nvl(d.CUSTOMERACCMONEY),0),nvl(d.CUSTOMERACCHASMONEY),0) " +
        //             " from TF_F_CASHGIFTORDER a, TF_F_CHARGECARDORDER b, TF_F_SZTCARDORDER c, TF_F_ORDERFORM d" +
        //             " where a.ORDERNO = d.ORDERNO" +
        //             " and   b.ORDERNO = d.ORDERNO" +
        //             " and   c.ORDERNO = d.ORDERNO" +
        //             " and   d.ORDERNO = '" + getDataKeys("ORDERNO") + "'" +
        //             " group by d.CUSTOMERACCMONEY,d.CUSTOMERACCHASMONEY";
        string sqlcashgift = " select sum(nvl(a.LEFTQTY,0)) from TF_F_CASHGIFTORDER a where ORDERNO = '" + getDataKeys("ORDERNO") + "'";
        string sqlchargecard = " select sum(nvl(a.LEFTQTY,0)) from TF_F_CHARGECARDORDER a where ORDERNO = '" + getDataKeys("ORDERNO") + "'";
        string sqlsztcard = " select sum(nvl(a.LEFTQTY,0)+nvl(a.ischarge,0)) from TF_F_SZTCARDORDER a where ORDERNO = '" + getDataKeys("ORDERNO") + "'";
        string sqlcustomeracc = " select nvl(CUSTOMERACCMONEY,0),nvl(CUSTOMERACCHASMONEY,0) from TF_F_ORDERFORM where ORDERNO = '" + getDataKeys("ORDERNO") + "'";
        string sqlreader = " select sum(nvl(a.LEFTQTY,0)) from TF_F_READERORDER a where ORDERNO = '" + getDataKeys("ORDERNO") + "'";

        context.DBOpen("Select");
        DataTable datacashgift = context.ExecuteReader(sqlcashgift);
        DataTable datachargecard = context.ExecuteReader(sqlchargecard);
        DataTable datasztcard = context.ExecuteReader(sqlsztcard);
        DataTable datacustomeracc = context.ExecuteReader(sqlcustomeracc);
        DataTable datareader = context.ExecuteReader(sqlreader);
        bool cashgift;
        bool chargecard;
        bool sztcard;
        bool customeracc;
        bool reader;
        //是否完成利金卡
        if (datacashgift.Rows.Count > 0)
        {

            cashgift = datacashgift.Rows[0][0].ToString() == "" || datacashgift.Rows[0][0].ToString() == "0" ? true : false;
        }
        else
        {
            cashgift = true;
        }
        //是否完成充值卡
        if (datachargecard.Rows.Count > 0)
        {

            chargecard = datachargecard.Rows[0][0].ToString() == "" || datachargecard.Rows[0][0].ToString() == "0" ? true : false;
        }
        else
        {
            chargecard = true;
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
        //是否完成专有账户
        if (datacustomeracc.Rows.Count > 0)
        {

            customeracc = datacustomeracc.Rows[0][0].ToString() == datacustomeracc.Rows[0][1].ToString() ? true : false;
        }
        else
        {
            customeracc = true;
        }
        //是否完成读卡器
        if (datareader.Rows.Count > 0)
        {

            reader = datareader.Rows[0][0].ToString() == "" || datareader.Rows[0][0].ToString() == "0" ? true : false;
        }
        else
        {
            reader = true;
        }

        //如果全部完成
        if (cashgift && chargecard && sztcard && customeracc && reader)
        {
            context.SPOpen();
            context.AddField("P_FUNCCODE").Value = "SETCOMPLETEMAKE";
            context.AddField("p_ORDERNO").Value = getDataKeys("ORDERNO");

            bool ok = context.ExecuteSP("SP_GC_SETORDERSTATE");
            if (ok)
            {
                AddMessage("订单完成制卡");
                //完成制卡标记置为1
                hidIsCompleted.Value = "1";
            }
        }
    }
    #endregion
    /// <summary>
    /// 市民卡B卡旧卡充值确认完成
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnOldSZTCardMake_Click(object sender, EventArgs e)
    {
        if (selSZTCardType.SelectedValue == "")
        {
            context.AddError("请选择市民卡B卡卡类型");
            return;
        }
        string sql = "select orderno from TF_F_SZTCARDORDER where CARDTYPECODE='" + selSZTCardType.SelectedValue + "' AND ORDERNO = '" + getDataKeys("ORDERNO") + "' AND ISCHARGE=0";
        context.DBOpen("Select");
        DataTable data = context.ExecuteReader(sql);
        if (data.Rows.Count > 0)
        {
            context.AddError("该类型卡已完成充值");
            return;
        }
        context.SPOpen();
        context.AddField("P_ORDERNO").Value = getDataKeys("ORDERNO"); // 订单号
        context.AddField("P_CARDTYPECODE").Value = selSZTCardType.SelectedValue; // 市民卡B卡卡类型
        bool ok = context.ExecuteSP("SP_GC_ORDERMAKEOLDSZTCARD");
        if (ok)
        {
            //完成制卡
            CompleteMake();
            if (context.hasError())
            {
                return;
            }
            //刷新页面
            divInfo.InnerHtml = GetOrderMakeOrComfirmHtml(getDataKeys("ORDERNO"), getDataKeys("GROUPNAME"), getDataKeys("NAME"),
            getDataKeys("TOTALMONEY"), getDataKeys("ORDERSTATE"), getDataKeys("INPUTTIME"),
            (Convert.ToDecimal(getDataKeys("CASHGIFTMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("SZTCARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("LVYOUMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CHARGECARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CUSTOMERACCMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("CUSTOMERACCHASMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("READERMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("GARDENCARDMONEY")) / 100).ToString(),
            (Convert.ToDecimal(getDataKeys("RELAXCARDMONEY")) / 100).ToString());

            if (getDataKeys("ISRELATED") == "1:制卡关联")
            {
                //关联卡
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showdiv", "ShowIsRelated(1);", true);
            }
            else
            {
                //关联卡
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showdiv", "ShowIsRelated(0);", true);
            }

            selCashGiftValue.SelectedValue = hidCashGiftValue.Value;
            selSZTCardType.SelectedValue = hidSZTCardtype.Value;
        }
    }
}