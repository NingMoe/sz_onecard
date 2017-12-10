using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using Common;
using DataExchange;
using Master;
using PDO.PersonalBusiness;
using TDO.BusinessCode;
using TDO.CardManager;
using TDO.PersonalTrade;
using TDO.UserManager;
using TM;

public partial class ASP_PersonalBusiness_PB_ReturnCardRollback : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            LabCardtype.Attributes["readonly"] = "true";

            initLoad(sender, e);
        }
    }
    protected void initLoad(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从前台业务交易费用表中读取售卡费用数据

        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "A5";

        TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001004139", "TD_M_TRADEFEE", null);

        for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        {
            //费用类型为押金

            if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "00")
                hiddenDepositFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为充值

            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "01")
                hiddenSupplyFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为手续费
            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "03")
                hidProcedureFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为其他费用

            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "99")
                hidOtherFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        }

        DepositFee.Text = hiddenDepositFee.Value;
        SupplyFee.Text = hiddenSupplyFee.Value;
        ProcedureFee.Text = hidProcedureFee.Value;
        OtherFee.Text = hidOtherFee.Value;
        Total.Text = (Convert.ToDecimal(DepositFee.Text) + Convert.ToDecimal(SupplyFee.Text) + Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");
        ReturnSupply.Text = Total.Text;
    }
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据


        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;

        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

        LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;

        //查询退卡信息

        readReturnInfo(sender, e);

        if (context.hasError()) return;
        //读取客户信息
        readInfo(sender, e);

        if (context.hasError()) return;

        btnRollback.Enabled = true;

        btnPrintPZ.Enabled = false;
        hiddenreadtype.Value = "0";

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
            Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
            Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
        }
    }

    protected void readReturnInfo(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从IC卡资料表中读取数据

        TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
        ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text;
        TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

        if (ddoTF_F_CARDRECOut == null)
        {
            context.AddError("A001008103");
            return;
        }

        SaleDate.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");
        Deposit.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT) / 100).ToString("0.00");

        //从业务台帐主表中读取数据
        TF_B_TRADETDO ddoTF_B_TRADEIn = new TF_B_TRADETDO();
        ddoTF_B_TRADEIn.CARDNO = txtCardno.Text;
        ddoTF_B_TRADEIn.TRADETYPECODE = "05";
        TF_B_TRADETDO ddoTF_B_TRADEOut = (TF_B_TRADETDO)tmTMTableModule.selByPK(context, ddoTF_B_TRADEIn, typeof(TF_B_TRADETDO), null, "TF_B_TRADE", null);

        if (ddoTF_B_TRADEOut == null)
        {
            context.AddError("A001008104");
            return;
        }
        hiddenCardstate.Value = ddoTF_B_TRADEOut.CARDSTATE;
        hiddenSerstaketag.Value = ddoTF_B_TRADEOut.SERSTAKETAG;
        hiddenTradeid.Value = ddoTF_B_TRADEOut.TRADEID;
        ReturnDate.Text = ddoTF_B_TRADEOut.OPERATETIME.ToString("yyyy-MM-dd");
        hiddenREASONCODE.Value = ddoTF_B_TRADEOut.REASONCODE;

        //从退换卡原因编码表中读取数据
        TD_M_REASONTYPETDO ddoTD_M_REASONTYPEIn = new TD_M_REASONTYPETDO();
        ddoTD_M_REASONTYPEIn.REASONCODE = ddoTF_B_TRADEOut.REASONCODE;
        TD_M_REASONTYPETDO ddoTD_M_REASONTYPEOut = (TD_M_REASONTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_REASONTYPEIn, typeof(TD_M_REASONTYPETDO), null, "TD_M_REASONTYPE_Destroy", null);

        Reasontype.Text = ddoTD_M_REASONTYPEOut.REASON;

        //可读卡退卡返销，从写卡台账读取数据
        if (hiddenREASONCODE.Value == "11" || hiddenREASONCODE.Value == "12" || hiddenREASONCODE.Value == "13")
        {
            TF_CARD_TRADETDO ddoTF_CARD_TRADEIn = new TF_CARD_TRADETDO();
            ddoTF_CARD_TRADEIn.TRADEID = ddoTF_B_TRADEOut.TRADEID;
            TF_CARD_TRADETDO ddoTF_CARD_TRADEOut = (TF_CARD_TRADETDO)tmTMTableModule.selByPK(context, ddoTF_CARD_TRADEIn, typeof(TF_CARD_TRADETDO), null, "TF_CARD_TRADE_ROLLBACK", null);

            if (ddoTF_CARD_TRADEOut == null)
            {
                context.AddError("A001008112");
                return;
            }
            hidChargeMoney.Value = ddoTF_CARD_TRADEOut.lOldMoney.ToString();
        }
        else
        {
            //不可读退卡返销,卡内余额为零 初始化
            hidChargeMoney.Value = "0";
        }
        
        //从内部员工编码表中读取数据
        TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        ddoTD_M_INSIDESTAFFIn.STAFFNO = ddoTF_B_TRADEOut.OPERATESTAFFNO;
        TD_M_INSIDESTAFFTDO ddoD_M_INSIDESTAFFOut = (TD_M_INSIDESTAFFTDO)tmTMTableModule.selByPK(context, ddoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_Destroy", null);

        ReturnStaff.Text = ddoD_M_INSIDESTAFFOut.STAFFNAME;

        //从现金台帐主表中读取数据
        TF_B_TRADEFEETDO ddoTF_B_TRADEFEEIn = new TF_B_TRADEFEETDO();
        ddoTF_B_TRADEFEEIn.TRADEID = ddoTF_B_TRADEOut.TRADEID;
        TF_B_TRADEFEETDO ddoTF_B_TRADEFEEOut = (TF_B_TRADEFEETDO)tmTMTableModule.selByPK(context, ddoTF_B_TRADEFEEIn, typeof(TF_B_TRADEFEETDO), null, "TF_B_TRADEFEE_ROLLBACK", null);

        if (ddoTF_B_TRADEFEEOut == null)
        {
            context.AddError("A001008113");
            return;
        }

        ReturnDeposit.Text = (Convert.ToDecimal(Convert.ToDecimal(hiddenDepositFee.Value) - Convert.ToDecimal(ddoTF_B_TRADEFEEOut.CARDDEPOSITFEE) / 100)).ToString("0.00");
        ReturnMoney.Text = (Convert.ToDecimal(Convert.ToDecimal(hiddenSupplyFee.Value)-Convert.ToDecimal(ddoTF_B_TRADEFEEOut.SUPPLYMONEY) / 100)).ToString("0.00");

        DepositFee.Text = ReturnDeposit.Text;
        SupplyFee.Text = ReturnMoney.Text;
        Total.Text = (Convert.ToDecimal(DepositFee.Text) + Convert.ToDecimal(SupplyFee.Text) + Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");
        ReturnSupply.Text = Total.Text;

    }

    protected void readInfo(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据

        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
        ddoTF_F_CUSTOMERRECIn.CARDNO = txtCardno.Text;

        //UPDATE BY JIANGBB 2012-04-19解密
        DDOBase ddoBase = (DDOBase)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

        ddoBase = CommonHelper.AESDeEncrypt(ddoBase);
        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)ddoBase;
        //TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

        if (ddoTF_F_CUSTOMERRECOut == null)
        {
            context.AddError("A001107112");
            return;
        }

        //从证件类型编码表(TD_M_PAPERTYPE)中读取数据

        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
        ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);

        //给页面显示项赋值

        CustName.Text = ddoTF_F_CUSTOMERRECOut.CUSTNAME;

        if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "0")
            Custsex.Text = "男";
        else if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "1")
            Custsex.Text = "女";
        else Custsex.Text = "";
        //出生日期赋值

        if (ddoTF_F_CUSTOMERRECOut.CUSTBIRTH != "")
        {
            String Bdate = ddoTF_F_CUSTOMERRECOut.CUSTBIRTH;
            if (Bdate.Length == 8)
            {
                CustBirthday.Text = Bdate.Substring(0, 4) + "-" + Bdate.Substring(4, 2) + "-" + Bdate.Substring(6, 2);
            }
            else CustBirthday.Text = Bdate;
        }
        else CustBirthday.Text = ddoTF_F_CUSTOMERRECOut.CUSTBIRTH;
        //证件类型赋值

        if (ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE != "")
        {
            Papertype.Text = ddoTD_M_PAPERTYPEOut.PAPERTYPENAME;
        }
        else Papertype.Text = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

        Paperno.Text = ddoTF_F_CUSTOMERRECOut.PAPERNO;
        Custaddr.Text = ddoTF_F_CUSTOMERRECOut.CUSTADDR;
        Custpost.Text = ddoTF_F_CUSTOMERRECOut.CUSTPOST;
        Custphone.Text = ddoTF_F_CUSTOMERRECOut.CUSTPHONE;
        txtEmail.Text = ddoTF_F_CUSTOMERRECOut.CUSTEMAIL;
        Remark.Text = ddoTF_F_CUSTOMERRECOut.REMARK;

    }
    private Boolean CardNoValidation()
    {
        //对卡号进行非空、长度、数字检验

        if (txtCardno.Text.Trim() == "")
            context.AddError("A001004113", txtCardno);
        else
        {
            if (Validation.strLen(txtCardno.Text.Trim()) != 16)
                context.AddError("A001004114", txtCardno);
            else if (!Validation.isNum(txtCardno.Text.Trim()))
                context.AddError("A001004115", txtCardno);
        }

        return !(context.hasError());
    }

    protected void btnDBread_Click(object sender, EventArgs e)
    {
        //对输入卡号进行检验

        if (!CardNoValidation())
            return;

        TMTableModule tmTMTableModule = new TMTableModule();

        //从IC卡资料表中读取数据

        TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
        ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text;
        TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

        if (ddoTF_F_CARDRECOut == null)
        {
            context.AddError("A001008103");
            return;
        }

        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据

        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = ddoTF_F_CARDRECOut.CARDTYPECODE;
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

        LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;

        readReturnInfo(sender, e);
        if (context.hasError()) return;
        readInfo(sender, e);
        if (context.hasError()) return;
        btnRollback.Enabled = true;
        hiddenreadtype.Value = "1";

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
            Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
            Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
        }
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "rewriteCard") // 重新写卡，生产新的令牌

        {
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "writeCard();", true);
        }
        else if (hidWarning.Value == "yes")
        {
            btnRollback.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            AddMessage("前台写卡成功");
            #region 退卡返销成功，张家港衍生卡信息同步
            if (hidCardIDZJG.Value.Length>=6&&hidCardIDZJG.Value.Substring(0, 6) == "215061")
            {
                string tradeID = hidTradeIDZJG.Value;
                string syncCardID = hidCardIDZJG.Value;
                string[] parm = new string[2];
                parm[0] = tradeID;
                parm[1] = syncCardID;
                DataTable syncData = SPHelper.callQuery("SP_RC_QUERY", context, "QueryCardReturnRollbackInfoSync", parm);
                //姓名，证件号码解密
                CommonHelper.AESDeEncrypt(syncData, new List<string>(new string[] { "NAME", "PAPER_NO" }));
                //证件类型转换
                string npaperType = syncData.Rows[0]["PAPER_TYPE"].ToString();
                switch (npaperType)
                {
                    case "00": syncData.Rows[0]["PAPER_TYPE"] = "0"; break;//身份证
                    case "01": syncData.Rows[0]["PAPER_TYPE"] = "3"; break;//港澳居民来往内地通行证
                    case "07": syncData.Rows[0]["PAPER_TYPE"] = "8"; break;//学生证
                    case "02": syncData.Rows[0]["PAPER_TYPE"] = "6"; break;//军官证
                    case "05": syncData.Rows[0]["PAPER_TYPE"] = "2"; break;//护照
                    case "06": syncData.Rows[0]["PAPER_TYPE"] = "1"; break;//户口簿
                    case "08": syncData.Rows[0]["PAPER_TYPE"] = "8"; break;//武警证
                    case "09": syncData.Rows[0]["PAPER_TYPE"] = "4"; break;//台湾同胞来往内地通行证
                    case "99": syncData.Rows[0]["PAPER_TYPE"] = "8"; break;//其它类型证件
                    default: break;
                }

                //调用后台接口
                SyncRequest syncRequest;
                bool sync = DataExchangeHelp.ParseFormDataTable(syncData, tradeID, out syncRequest);
                if (sync == true)
                {
                    SyncRequest syncResponse;
                    string msg;
                    bool succ = DataExchangeHelp.Sync(syncRequest, out syncResponse,out msg);
                    if (!succ)
                    {
                        context.AddError("调用接口失败:" + msg);
                    }
                    else
                    {
                        context.AddMessage("调用接口成功!");
                    }
                }
                else
                {
                    context.AddError("调用接口转换错误!");
                }
            }
            #endregion
            clearCustInfo(txtCardno);
        }
        else if (hidWarning.Value == "writeFail")
        {
            context.AddError("前台写卡失败");
        }
        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }
        hidWarning.Value = "";

        hidTradeIDZJG.Value = "";
        hidCardIDZJG.Value = "";//add by hzl 20131205
    }

    protected void btnRollback_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //查询是否当天当操作员进行的退卡

        TF_B_TRADETDO ddoTF_B_TRADEIn = new TF_B_TRADETDO();

        string str = " Select CARDNO From TF_B_TRADE WHERE TRADEID = '" + hiddenTradeid.Value + "' " +
                     " And OPERATETIME BETWEEN Trunc(sysdate,'dd') AND sysdate" +
                     " And OPERATESTAFFNO = '" + context.s_UserID + "' ";
        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, str, 0);

        if (data.Rows.Count == 0)
        {
            context.AddError("A001021100");
            return;
        }

        //查询退卡操作是否最新的一次业务操作

        string strSale = " Select TRADETYPECODE From TF_B_TRADE WHERE CARDNO = '" + txtCardno.Text + "' " +
                         " And OPERATETIME > (SELECT OPERATETIME FROM TF_B_TRADE WHERE CARDNO = '" + txtCardno.Text + "' "+
                         " AND TRADETYPECODE = '05' AND CANCELTAG = '0') " +
                         " And CANCELTAG = '0' AND ASCII(TRADETYPECODE) < 65 ";
        DataTable dataSale = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strSale, 0);

        if (dataSale.Rows.Count > 0)
        {
            context.AddError("A001021101");
            return;
        }

        //存储过程赋值

        SP_PB_ReturnCardRollbackPDO pdo = new SP_PB_ReturnCardRollbackPDO();
        pdo.CANCELTRADEID = hiddenTradeid.Value;
        pdo.CARDNO = txtCardno.Text;
        pdo.REASONCODE = hiddenREASONCODE.Value;
        pdo.TRADETYPECODE = "A5";
        pdo.REFUNDMONEY = Convert.ToInt32(Convert.ToDecimal(ReturnMoney.Text) * 100);
        pdo.CARDMONEY = Convert.ToInt32(hidChargeMoney.Value);
        pdo.REFUNDDEPOSIT = Convert.ToInt32(Convert.ToDecimal(ReturnDeposit.Text) * 100);
        pdo.TRADEPROCFEE = Convert.ToInt32(Convert.ToDecimal(ProcedureFee.Text) * 100);
        pdo.OTHERFEE = Convert.ToInt32(Convert.ToDecimal(OtherFee.Text) * 100);
        pdo.CARDSTATE = hiddenCardstate.Value;
        pdo.SERSTAKETAG = hiddenSerstaketag.Value;
        pdo.TERMNO = "112233445566";
        pdo.OPERCARDNO = context.s_CardID;
        if (hiddenreadtype.Value == "0")
        {
            pdo.CARDTRADENO = hiddentradeno.Value;
            pdo.ID = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
        }
        else if (hiddenreadtype.Value == "1")
        {
            pdo.CARDTRADENO = txtCardno.Text.Substring(12, 4);
            pdo.ID = DealString.GetRecordID(txtCardno.Text.Substring(12, 4), txtCardno.Text);
        }
        //if (pdo.REASONCODE == "11" || pdo.REASONCODE == "12" || pdo.REASONCODE == "13")
        //{
        //    pdo.CARDTRADENO = hiddentradeno.Value;
        //    pdo.ID = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
        //    //pdo.ID = hiddentradeno.Value + DateTime.Now.ToString("MMddhhmmss") + hiddenAsn.Value.Substring(16, 4);
        //}
        //else if (pdo.REASONCODE == "14" || pdo.REASONCODE == "15")
        //{
        //    pdo.ID = DealString.GetRecordID(txtCardno.Text.Substring(12, 4), txtCardno.Text);
        //    //pdo.ID = txtCardno.Text.Substring(12, 4) + DateTime.Now.ToString("MMddhhmmss") + txtCardno.Text.Substring(12, 4);
        //    pdo.CARDTRADENO = txtCardno.Text.Substring(12, 4);
        //}

        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (ok)
        {
            //退卡返销成功时提示

            AddMessage("M001021100");
            //写卡
            if (hiddenREASONCODE.Value == "11" || hiddenREASONCODE.Value =="12" || hiddenREASONCODE.Value == "13")
            {
                hidCardReaderToken.Value = cardReader.createToken(context); 
                ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                       "unlockReturnCard();", true);
            }
            btnPrintPZ.Enabled = true;
            if (chkPingzheng.Checked && btnPrintPZ.Enabled)
            {
                ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "printInvoice();", true);
            }
            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, CustName.Text, "退卡返销", SupplyFee.Text
                , DepositFee.Text, "", Paperno.Text, "0.00", "",
                Total.Text, context.s_UserID, context.s_DepartName, Papertype.Text, ProcedureFee.Text, OtherFee.Text);

              //张家港衍生卡信息同步

            if (pdo.CARDNO.Substring(0, 6) == "215061")
            {
                string tradeID = ((SP_PB_ReturnCardRollbackPDO)pdoOut).TRADEID;
                hidTradeIDZJG.Value = tradeID;
                hidCardIDZJG.Value = pdo.CARDNO.ToString();
            }
            btnRollback.Enabled = false;
            //重新初始化

            initLoad(sender, e);

            
        }
    }
}
