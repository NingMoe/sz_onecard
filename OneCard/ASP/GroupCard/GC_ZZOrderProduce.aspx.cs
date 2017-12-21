using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TDO.BusinessCode;
using TM;
using TDO.ResourceManager;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;
using PDO.PersonalBusiness;
using TDO.CardManager;
using Master;

//description 休闲订单制卡
//creater     蒋兵兵
//date        2015-04-17


public partial class ASP_GroupCard_GC_ZZOrderProduce : Master.FrontMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            gvOrderList.DataSource = new DataTable();
            gvOrderList.DataBind();

            previousLink.Visible = false;
            nextLink.Visible = false;
        }
    }

    /// <summary>
    /// 查询验证
    /// </summary>
    /// <returns></returns>
    private bool ValidInput()
    {
        //校验联系人长度
        if (!string.IsNullOrEmpty(txtOrderNo.Text) && !Validation.isCharNum(txtOrderNo.Text))
        {
            context.AddError("A094780090:订单号只能为英数");
        }

        //对开始日期和结束日期的判断

        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, false);
        return !(context.hasError());
    }

    /// <summary>
    /// 查询订单按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {

        if (!ValidInput())
            return;

        gvOrderList.DataSource = new DataTable();
        gvOrderList.DataBind();

        string fromDate = txtFromDate.Text.Trim();
        string endDate = txtToDate.Text.Trim();

        previousLink.Visible = true;
        nextLink.Visible = true;
        ShowFileContent();
    }

    //Data绑定
    protected void gvOrderList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            Image imgP = (Image)e.Row.FindControl("imgPerson");
            imgP.ImageUrl = "GC_ZZShowGetPicture.aspx?orderDetailId=" + e.Row.Cells[14].Text;

            switch (e.Row.Cells[4].Text)
            {
                case "0":
                    e.Row.Cells[4].Text = "未处理";
                    break;
                case "1":
                    e.Row.Cells[4].Text = "已制卡";
                    break;
                case "2":
                    e.Row.Cells[4].Text = "已发货";
                    break;
                default:
                    e.Row.Cells[4].Text = "状态异常";
                    break;
            }

            switch (e.Row.Cells[7].Text)
            {
                case "Z1":
                    e.Row.Cells[7].Text = "24小时套餐";
                    break;
                case "Z2":
                    e.Row.Cells[7].Text = "48小时套餐";
                    break;
                default:
                    e.Row.Cells[7].Text = "套餐类型异常";
                    break;
            }

            Button btnProduce = (Button)e.Row.FindControl("btnProduce");
            switch (e.Row.Cells[5].Text)
            {
                case "":
                    btnProduce.Visible = true;
                    break;
                default:
                    btnProduce.Visible = false;
                    break;
            }
            Button btnCharge = (Button)e.Row.FindControl("btnCharge");
            switch (e.Row.Cells[2].Text)
            {
                case "0":
                    e.Row.Cells[2].Text = "0";
                    btnCharge.Visible = false;
                    break;
                default:
                    e.Row.Cells[2].Text = (Convert.ToDecimal(e.Row.Cells[2].Text) / 100).ToString();
                    break;
            }
        }
    }

    //分页
    protected void Link_Click(object sender, CommandEventArgs e)
    {
        ViewState["page"] = e.CommandArgument.ToString();
        ShowFileContent();
    }

    private Dictionary<string, string> DeclarePost(int begin, int end)
    {
        Dictionary<string, string> postData = new Dictionary<string, string>();
        postData.Add("channelCode", "ONECARD");
        postData.Add("orderNo", txtOrderNo.Text);
        postData.Add("fromDate", txtFromDate.Text);
        postData.Add("toDate", txtToDate.Text);
        postData.Add("rejectType", "");
        postData.Add("payCanal", selPayCanal.SelectedValue);
        postData.Add("beginIndex", begin.ToString());
        postData.Add("endIndex", end.ToString());
        postData.Add("orderState", "0");
        postData.Add("fetchType", "");

        return postData;
    }

    //显示文件内容
    public void ShowFileContent()
    {
        // 指定的页数
        int page = 1;
        if (ViewState["page"] != null && !string.IsNullOrEmpty(ViewState["page"].ToString()))
            page = Int32.Parse(ViewState["page"].ToString());

        //总数
        int iCount = 0;
        //每页数量
        int iPerPage = 9;
        int begin = (page - 1) * iPerPage + 1;
        int end = page * iPerPage + 1;


        iCount = GetListCount(HttpHelper.TradeType.ZZOrderCardCount, DeclarePost(begin, end));
        DataTable table = fillDataTable(HttpHelper.TradeType.ZZOrderCardQuery, DeclarePost(begin, end));
        if (table.Rows.Count > 0)
        {
            gvOrderList.DataSource = GetTableCard(table);
            gvOrderList.DataBind();
        }
        // 页数
        int iPagecount = 1;
        iPagecount = (int)Math.Ceiling((double)iCount / (double)iPerPage);
        // 显示页控件
        // 设置页
        if (iPagecount > 1)
        {
            int currentPage = page;
            // 前一页
            if (currentPage == 1)
            {
                previousLink.Enabled = false;
            }
            else
            {
                previousLink.Enabled = true;
                previousLink.CommandArgument = (currentPage - 1).ToString();
            }
            // 下一页
            if (currentPage == iPagecount)
            {
                nextLink.Enabled = false;
            }
            else
            {
                nextLink.Enabled = true;
                nextLink.CommandArgument = (currentPage + 1).ToString();
            }
        }
        else
        {
            previousLink.Visible = false;
            nextLink.Visible = false;
        }
    }

    private DataTable GetTableCard(DataTable data)
    {
        foreach (DataRow item in data.Rows)
        {
            DataTable dt = GroupCardHelper.callQuery(context, "GetTableCard", item["DETAILNO"].ToString());
            if (dt != null && dt.Rows.Count != 0)
            {
                item["CARDNO"] = dt.Rows[0][0].ToString();
            }

        }
        return data;
    }

    private int GetListCount(HttpHelper.TradeType tradetype, Dictionary<string, string> postData)
    {
        string jsonResponse = HttpHelper.ZZPostRequest(tradetype, postData);

        string code = "";
        string message = "";
        string listCount = "";
        JObject deserObject = (JObject)JsonConvert.DeserializeObject(jsonResponse);
        foreach (JProperty itemProperty in deserObject.Properties())
        {
            string propertyName = itemProperty.Name;
            if (propertyName == "respCode")
            {
                code = itemProperty.Value.ToString();
            }
            else if (propertyName == "respDesc")
            {
                message = itemProperty.Value.ToString();
            }
            else if (propertyName == "listCount")
            {
                listCount = itemProperty.Value.ToString();
            }
        }
        int count = 0;
        if (code == "0000") //表示成功
        {
            count = Int32.Parse(listCount);
        }
        return count;
    }

    private DataTable initEmptyDataTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("DETAILNO", typeof(string));//子订单号
        dt.Columns.Add("ORDERNO", typeof(string));//订单号
        dt.Columns.Add("ORDERSTATE", typeof(string));//订单类型
        dt.Columns.Add("REJECTTYPE", typeof(string));//驳回状态
        dt.Columns.Add("CARDNO", typeof(string));//卡号
        dt.Columns.Add("PACKAGENAME", typeof(string));//套餐类型
        dt.Columns.Add("RECEIVECUSTNAME", typeof(string));//收件人
        dt.Columns.Add("RECEIVEADDRESS", typeof(string));//收货地址
        dt.Columns.Add("RECEIVECUSTPHONE", typeof(string));//收件人电话
        dt.Columns.Add("CUSTNAME", typeof(string));//持卡人姓名
        dt.Columns.Add("PAPERNO", typeof(string));//持卡人证件号码
        dt.Columns.Add("CUSTPHONE", typeof(string));//持卡人电话
        dt.Columns.Add("SUPPLYMONEY", typeof(string));//充值金额

        dt.Columns["DETAILNO"].MaxLength = 10000;
        dt.Columns["ORDERNO"].MaxLength = 10000;
        dt.Columns["ORDERSTATE"].MaxLength = 10000;
        dt.Columns["REJECTTYPE"].MaxLength = 10000;
        dt.Columns["CARDNO"].MaxLength = 10000;
        dt.Columns["PACKAGENAME"].MaxLength = 10000;
        dt.Columns["RECEIVECUSTNAME"].MaxLength = 10000;
        dt.Columns["RECEIVEADDRESS"].MaxLength = 10000;
        dt.Columns["RECEIVECUSTPHONE"].MaxLength = 10000;
        dt.Columns["CUSTNAME"].MaxLength = 10000;
        dt.Columns["PAPERNO"].MaxLength = 10000;
        dt.Columns["CUSTPHONE"].MaxLength = 10000;
        dt.Columns["SUPPLYMONEY"].MaxLength = 10000;

        return dt;
    }

    private DataTable fillDataTable(HttpHelper.TradeType tradetype, Dictionary<string, string> postData)
    {
        string jsonResponse = HttpHelper.ZZPostRequest(tradetype, postData);
        //解析json
        DataTable dt = initEmptyDataTable();
        JObject deserObject = (JObject)JsonConvert.DeserializeObject(jsonResponse);
        string code = "";
        string message = "";
        foreach (JProperty itemProperty in deserObject.Properties())
        {
            string propertyName = itemProperty.Name;
            if (propertyName == "respCode")
            {
                code = itemProperty.Value.ToString();
            }
            else if (propertyName == "respDesc")
            {
                message = itemProperty.Value.ToString();
            }
            else if (propertyName == "orderCardList")
            {
                if (itemProperty.Value == null)
                {
                    context.AddMessage("查询结果为空");
                    return null;
                }
            }
        }

        if (code == "0000") //表示成功
        {
            foreach (JProperty itemProperty in deserObject.Properties())
            {
                string propertyName = itemProperty.Name;
                if (propertyName == "orderCardList")
                {
                    //DataTable赋值
                    JArray detailArray = new JArray();
                    try
                    {
                        detailArray = (JArray)itemProperty.Value;
                    }
                    catch (Exception)
                    {
                        context.AddMessage("查询结果为空");
                        return new DataTable();
                    }
                    foreach (JObject subItem in detailArray)
                    {
                        DataRow newRow = dt.NewRow();
                        //newRow["AccountId"] = hidAccountId.Value;
                        foreach (JProperty subItemJProperty in subItem.Properties())
                        {
                            newRow[subItemJProperty.Name] = subItemJProperty.Value.ToString();
                        }
                        dt.Rows.Add(newRow);
                    }
                }
            }
        }
        else
        {
            context.AddError(message);
        }
        return dt;
    }

    /// <summary>
    /// 提交同步信息
    /// </summary>
    /// <param name="orderType"></param>
    private void synMsg(object sender, EventArgs e, string orderNo, string detailNo, string cardNo, string orderType, ref string code, ref string message)
    {

        string orderid = orderNo;
        string detailid = detailNo;
        string cardno = cardNo;
        string orderState = orderType;
        string rejectType = "";
        string logisticsCompany = "";
        string trackingNo = "";
        string operateStaffNo = context.s_UserID;
        string operateDepartId = context.s_DepartID;
        string remark = "";

        Dictionary<string, string> postData = new Dictionary<string, string>();
        postData.Add("channelCode", "ONECARD");
        postData.Add("orderNo", orderid);
        postData.Add("detailNo", detailid);
        postData.Add("cardNo", cardno);
        postData.Add("orderState", orderState);
        postData.Add("rejectType", rejectType);
        postData.Add("logisticsCompany", logisticsCompany);
        postData.Add("trackingNo", trackingNo);
        postData.Add("operateStaffNo", operateStaffNo);
        postData.Add("operateDepartId", operateDepartId);
        postData.Add("remark", remark);

        string jsonResponse = HttpHelper.ZZPostRequest(HttpHelper.TradeType.ZZOrderChange, postData);

        JObject deserObject = (JObject)JsonConvert.DeserializeObject(jsonResponse);
        foreach (JProperty itemProperty in deserObject.Properties())
        {
            string propertyName = itemProperty.Name;
            if (propertyName == "respCode")
            {
                code = itemProperty.Value.ToString();
            }
            else if (propertyName == "respDesc")
            {
                message = itemProperty.Value.ToString();
            }
        }

        if (code == "0000") //表示成功
        {
            context.AddMessage("处理成功");
        }
        else
        {
            context.AddMessage("处理失败,失败原因：" + message);
        }
    }

    //记录同步信息
    private void UpdateSyncType(string operateType, string tradeType, string syncCode, string syncMsg)
    {
        //operateType 01新增 02修改
        //tradeType 01售卡 02充值 03配送
        context.SPOpen();
        context.AddField("P_TRADEID").Value = hidTradeNo.Value;
        context.AddField("P_ORDERNO").Value = hidOrderNo.Value;
        context.AddField("P_DETAILNO").Value = hidDetailNo.Value;
        context.AddField("P_CARDNO").Value = txtCardno.Text;
        context.AddField("P_SYNCTYPE").Value = syncCode == "0000" ? "02" : "03";
        context.AddField("P_SYNCMSG").Value = syncMsg;
        context.AddField("P_OPERATETYPE").Value = operateType;
        context.AddField("P_TRADETYPE").Value = tradeType;
        context.ExecuteSP("SP_GC_ZZUpdateSync");
    }

    /// <summary>
    /// 售卡费用相关信息
    /// </summary>
    private void GetTradeFee()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //从前台业务交易费用表中读取售卡费用数据

        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "01";

        TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001001137", "TD_M_TRADEFEE", null);

        for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        {
            //"00"为卡押金
            if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "00")
                hiddenDepositFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //"10"为卡费

            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "10")
                hiddenCardcostFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //"99"为其他费用

            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "99")
                hidOtherFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        }

        //从用户卡库存表(TL_R_ICUSER)中读取数据

        TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
        ddoTL_R_ICUSERIn.CARDNO = txtCardno.Text;

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
            hiddenCardcostFee.Value = (Convert.ToDecimal(hiddenCardcostFee.Value) + (Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE)) / 100).ToString("0.00");
            hiddenDepositFee.Value = Convert.ToDecimal(hiddenDepositFee.Value).ToString();
        }
        //售卡方式为押金方式
        if (hidSaletype.Value.Equals("02"))
        {
            hiddenCardcostFee.Value = Convert.ToDecimal(hiddenCardcostFee.Value).ToString();
            hiddenDepositFee.Value = (Convert.ToDecimal(hiddenDepositFee.Value) + (Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE)) / 100).ToString("0.00");
        }
    }

    /// <summary>
    /// 绑定按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvOrderList_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int index = Convert.ToInt32(e.CommandArgument.ToString());
        if (e.CommandName == "Produce")
        {

            //ScriptManager.RegisterStartupScript(this, this.GetType(),
            //            "js", "ReadCardInfo()", true);

            hidMoney.Value = gvOrderList.Rows[index].Cells[2].Text;
            //验证卡状态
            checkCardState(txtCardno.Text);

            //校验用户相关信息
            SaleInfoValidation(index);

            //获取卡相关资费
            GetTradeFee();
            if (context.hasError())
                return;

            //return;
            //售卡-休闲开通
            ProduceCard(sender, e, "");

        }

        if (e.CommandName == "Charge")
        {
            hidOrderCardNo.Value = gvOrderList.Rows[index].Cells[5].Text;
            hidMoney.Value = gvOrderList.Rows[index].Cells[2].Text;

            //读卡验证卡号
            //ScriptManager.RegisterStartupScript(this, this.GetType(),
            //            "js", "SupplyAndReadCardForCheck()", true);

            //验证卡状态
            //checkCardState(txtCardno.Text);

            //获取卡相关资费
            GetTradeFee();
            if (context.hasError())
                return;

            ////充值前余额验证
            //ScriptManager.RegisterStartupScript(this, this.GetType(),
            //            "js", "ChargeCardChargeCheck()", true);
            btnSupply_Click(sender, e);
        }
    }


    #region 售卡用户信息进行检验
    /// <summary>
    /// 售卡用户信息进行检验
    /// </summary>
    /// <param name="orderDetailId">子订单ID</param>
    /// <param name="funcFee">功能费</param>
    /// <param name="packageTypeCode">套餐类型</param>
    /// <returns></returns>
    private Boolean SaleInfoValidation(int rowIndex)
    {
        GridViewRow gvRow = gvOrderList.Rows[rowIndex];
        hidcustName.Value = gvRow.Cells[11].Text.ToString().Trim();
        hidpaperType.Value = "00";  //默认身份证
        hidpaperNo.Value = gvRow.Cells[12].Text.ToString().Trim();
        hidcustPhone.Value = gvRow.Cells[13].Text.ToString().Trim();
        hidaddress.Value = "";
        hidcustPost.Value = "";
        hidcustSex.Value = "";
        hidcustBirth.Value = "";
        hidcustEmail.Value = "";
        hidOrderNo.Value = gvRow.Cells[3].Text.ToString().Trim();
        hidDetailNo.Value = gvRow.Cells[14].Text.ToString().Trim();

        //对用户姓名进行非空、长度检验

        if (hidcustName.Value == "")
            context.AddError("A001001111");
        else if (Validation.strLen(hidcustName.Value) > 50)
            context.AddError("A001001113");

        //对联系电话进行非空、长度、数字检验

        if (hidcustPhone.Value == "")
            context.AddError("A001001124");
        else if (Validation.strLen(hidcustPhone.Value) > 20)
            context.AddError("A001001126");
        else if (!Validation.isNum(hidcustPhone.Value))
            context.AddError("A001001125");

        //对证件号码进行非空、长度、英数字检验

        if (hidpaperNo.Value == "")
            context.AddError("A001001121");
        else if (!Validation.isCharNum(hidpaperNo.Value))
            context.AddError("A001001122");
        else if (Validation.strLen(hidpaperNo.Value) > 20)
            context.AddError("A001001123");

        return !(context.hasError());
    }
    #endregion

    /// <summary>
    /// 制卡功能
    /// </summary>
    protected void ProduceCard(object sender, EventArgs e, string orderType)
    {
        StringBuilder strBuilder = new StringBuilder();
        context.SPOpen();
        context.AddField("P_DETAILNO").Value = hidDetailNo.Value;      //子订单号
        context.AddField("P_ORDERNO").Value = hidDetailNo.Value;      //子订单号
        context.AddField("P_ID").Value = DealString.GetRecordID(hiddentradeno.Value, "00215000" + txtCardno.Text.Substring(8, 8));
        //context.AddField("P_ID").Value = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value.Substring(4, 16));
        context.AddField("P_CARDNO").Value = txtCardno.Text;
        context.AddField("P_DEPOSIT").Value = 0;
        context.AddField("P_CARDCOST").Value = 0;       //卡费暂定零
        context.AddField("P_OTHERFEE").Value = 0;
        context.AddField("P_CARDTRADENO").Value = hiddentradeno.Value;
        context.AddField("P_CARDTYPECODE").Value = hiddenLabCardtype.Value;
        context.AddField("P_CARDMONEY").Value = 0;
        context.AddField("P_SELLCHANNELCODE").Value = "01";
        context.AddField("P_SERSTAKETAG").Value = "0";
        context.AddField("P_TRADETYPECODE").Value = "01";

        AESHelp.AESEncrypt(hidcustName.Value, ref strBuilder);
        context.AddField("P_CUSTNAME").Value = strBuilder.ToString();
        context.AddField("P_CUSTSEX").Value = hidcustSex.Value;
        context.AddField("P_CUSTBIRTH").Value = hidcustBirth.Value;
        context.AddField("P_PAPERTYPECODE").Value = hidpaperType.Value;

        AESHelp.AESEncrypt(hidpaperNo.Value, ref strBuilder);
        context.AddField("P_PAPERNO").Value = strBuilder.ToString();

        AESHelp.AESEncrypt(hidaddress.Value, ref strBuilder);
        context.AddField("P_CUSTADDR").Value = strBuilder.ToString();
        context.AddField("P_CUSTPOST").Value = hidcustPost.Value;

        AESHelp.AESEncrypt(hidcustPhone.Value, ref strBuilder);
        context.AddField("P_CUSTPHONE").Value = strBuilder.ToString();
        context.AddField("P_CUSTEMAIL").Value = hidcustEmail.Value;
        context.AddField("P_REMARK").Value = "";
        context.AddField("P_CUSTRECTYPECODE").Value = "1";
        context.AddField("P_TERMNO").Value = "112233445566";
        context.AddField("P_OPERCARDNO").Value = context.s_CardID;
        context.AddField("P_CURRENTTIME", "DateTime", "output", "", null);
        context.AddField("P_SALECARDTRADEID", "string", "output", "16", null);
        //return;
        bool ok = context.ExecuteSP("SP_GC_ZZSALECARD");
        if (ok)
        {
            hidTradeNo.Value = "" + context.GetFieldValue("P_SALECARDTRADEID");
            //记录同步信息
            UpdateSyncType("01", "01", "", "");
            context.AddMessage("制卡完成！");
            //充值金额不为零则同步接口
            if (hidMoney.Value != "0")
            {
                string code = "";
                string message = "";
                //调用同步接口
                synMsg(sender, e, hidOrderNo.Value, hidDetailNo.Value, txtCardno.Text, "1", ref code, ref message);

                //更新同步信息
                UpdateSyncType("02", "01", code, message);
            }
        }
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "CashChargeConfirm")
        {
            btnSupply_Click(sender, e);
            hidWarning.Value = "";
            return;
        }

        if (hidWarning.Value == "yes")
        {
            //btnSupply.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {

            SP_PB_updateCardTradePDO pdo = new SP_PB_updateCardTradePDO();
            pdo.CARDTRADENO = hiddentradeno.Value;
            pdo.TRADEID = hidoutTradeid.Value;

            bool ok = TMStorePModule.Excute(context, pdo);

            if (ok)
            {
                string code = "";
                string message = "";
                //调用同步接口
                synMsg(sender, e, hidOrderNo.Value, hidDetailNo.Value, txtCardno.Text, "1", ref code, ref message);

                //更新同步信息
                UpdateSyncType("02", "02", code, message);
                AddMessage("前台写卡成功");
                btnQuery_Click(sender, e);
            }
        }
        else if (hidWarning.Value == "writeFail")
        {
            context.AddError("前台写卡失败");
        }
        hidWarning.Value = "";
        hidCardnoForCheck.Value = "";//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致
    }


    protected void btnSupply_Click(object sender, EventArgs e)
    {
        //对输入金额或充值卡密码有效性进行检验


        if (!inportValidation())
            return;

        TMTableModule tmTMTableModule = new TMTableModule();

        //从IC卡电子钱包账户表中读取数据


        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text;

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null, "TF_F_CARDEWALLETACC", null);

        hidCardnoForCheck.Value = txtCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致

        //充值类型为现金
        SP_PB_ChargePDO pdo = new SP_PB_ChargePDO();

        //pdo.ID = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value.Substring(4, 16));
        pdo.ID = DealString.GetRecordID(hiddentradeno.Value, "00215000" + txtCardno.Text.Substring(8, 8));
        //pdo.ID = hiddentradeno.Value + DateTime.Now.ToString("MMddhhmmss") + LabAsn.Text.Substring(12, 4);
        pdo.CARDNO = txtCardno.Text;
        pdo.CARDTRADENO = hiddentradeno.Value;
        pdo.CARDMONEY = Convert.ToInt32(Convert.ToDecimal(hidMoney.Value) * 100);
        pdo.CARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;
        pdo.ASN = hiddenAsn.Value;
        pdo.CARDTYPECODE = hiddenLabCardtype.Value;
        pdo.TRADETYPECODE = "02";
        pdo.SUPPLYMONEY = Convert.ToInt32((Convert.ToDecimal(hidMoney.Value)) * 100);
        hidSupplyMoney.Value = "" + pdo.SUPPLYMONEY;
        hiddenSupply.Value = hidMoney.Value;
        pdo.OPERCARDNO = context.s_CardID;
        pdo.TERMNO = "112233445566";
        pdo.OTHERFEE = 0;
        pdo.CHARGETYPE = "";
        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);
        if (ok)
        {
            hidTradeNo.Value = "" + ((SP_PB_ChargePDO)pdoOut).TRADEID;

            //记录同步信息
            UpdateSyncType("01", "02", "", "");
            //AddMessage("M001002001");
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                "writeCardScript", "chargeCard();", true);
        }
    }

    private bool inportValidation()
    {
        if (!Validation.isNum(hidMoney.Value.Trim()))
            context.AddError("A001002100");
        else if (hidMoney.Value.Trim() == "" || Convert.ToDecimal(hidMoney.Value.Trim()) == 0)
            context.AddError("A001002126");
        else if (!Validation.isPosRealNum(hidMoney.Value.Trim()))
            context.AddError("A001002127");

        return !(context.hasError());
    }
}
