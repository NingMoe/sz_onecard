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
using TM;

public partial class ASP_PersonalBusiness_PB_ChangeCardRollback : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            setReadOnly(OsDate, ODeposit, OldcMoney,ReasonType, LabCardtype, NsDate, NewcMoney, NDeposit);
            if (!context.s_Debugging) txtNCardno.Attributes["readonly"] = "true";

            initLoad(sender, e);
        }
    }

    protected void initLoad(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从前台业务交易费用表中读取售卡费用数据
        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "A3";

        TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001004139", "TD_M_TRADEFEE", null);

        for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        {
            //费用类型为押金
            if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "00")
                hiddenDepositFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为卡费
            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "10")
                hiddenCardcostFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为手续费
            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "03")
                hidProcedureFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为其他费用
            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "99")
                hidOtherFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        }

        DepositFee.Text = hiddenDepositFee.Value;
        CardcostFee.Text = hiddenCardcostFee.Value;
        ProcedureFee.Text = hidProcedureFee.Value;
        OtherFee.Text = hidOtherFee.Value;
        Total.Text = (Convert.ToDecimal(DepositFee.Text) + Convert.ToDecimal(CardcostFee.Text) 
            + Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");
        ReturnSupply.Text = Total.Text;
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        // txtOCardno.Text = hiddentxtCardno.Value;
        readChangeInfo(sender, e);
        if (context.hasError())
            return;
        OldcMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / 100).ToString("0.00");
        btnReadNCard.Enabled = true;

        btnPrintPZ.Enabled = false;
        
    }

    protected void readChangeInfo(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从IC卡资料表中读取数据
        TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
        ddoTF_F_CARDRECIn.CARDNO = txtOCardno.Text;
        TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

        if (ddoTF_F_CARDRECOut == null)
        {
            context.AddError("A001022103");
            return;
        }
        ODeposit.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT) / 100).ToString("0.00");
        OsDate.Text = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString("yyyy-MM-dd");

        //从业务台帐主表中读取数据
        TF_B_TRADETDO ddoTF_B_TRADEIn = new TF_B_TRADETDO();
        ddoTF_B_TRADEIn.OLDCARDNO = txtOCardno.Text;
        ddoTF_B_TRADEIn.TRADETYPECODE = "03";
        TF_B_TRADETDO ddoTF_B_TRADEOut = (TF_B_TRADETDO)tmTMTableModule.selByPK(context, ddoTF_B_TRADEIn, typeof(TF_B_TRADETDO), null, "TF_B_TRADE_ROLLBACK_TIME", null);

        if (ddoTF_B_TRADEOut == null)
        {
            context.AddError("A001022102");
            return;
        }
        hiddenChangeCardno.Value = ddoTF_B_TRADEOut.CARDNO;
        hiddenCardstate.Value = ddoTF_B_TRADEOut.CARDSTATE;
        hiddenSerstaketag.Value = ddoTF_B_TRADEOut.SERSTAKETAG;
        hiddenTradeid.Value = ddoTF_B_TRADEOut.TRADEID;
        hiddenREASONCODE.Value = ddoTF_B_TRADEOut.REASONCODE;

        //从退换卡原因编码表中读取数据
        TD_M_REASONTYPETDO ddoTD_M_REASONTYPEIn = new TD_M_REASONTYPETDO();
        ddoTD_M_REASONTYPEIn.REASONCODE = ddoTF_B_TRADEOut.REASONCODE;
        TD_M_REASONTYPETDO ddoTD_M_REASONTYPEOut = (TD_M_REASONTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_REASONTYPEIn, typeof(TD_M_REASONTYPETDO), null, "TD_M_REASONTYPE_Destroy", null);

        ReasonType.Text = ddoTD_M_REASONTYPEOut.REASON;

        //验证卡片是否世乒卡(51)，如果是旅游年卡，则不允许在该页面售出
        bool cardTypeOk = CommonHelper.allowCardtype(context, txtOCardno.Text, "5103");
        if (cardTypeOk == false)
        {
            return;
        }
    }

    private Boolean readValidation()
    {
        //对卡号进行非空、长度、数字检验
        if (txtOCardno.Text.Trim() == "")
            context.AddError("A001004113", txtOCardno);
        else
        {
            if ((txtOCardno.Text.Trim()).Length != 16)
                context.AddError("A001004114", txtOCardno);
            else if (!Validation.isNum(txtOCardno.Text.Trim()))
                context.AddError("A001004115", txtOCardno);
        }

        return !(context.hasError());
    }

    protected void btnDBRead_Click(object sender, EventArgs e)
    {
        if (!readValidation())
            return;

        TMTableModule tmTMTableModule = new TMTableModule();

        readChangeInfo(sender, e);
        if (context.hasError())
            return;

        //从IC卡电子钱包账户表中读取数据
        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtOCardno.Text;
        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null, "TF_F_CARDEWALLETACC", null);

        if (ddoTF_F_CARDEWALLETACCOut == null)
        {
            context.AddError("A001022103");
            return;
        }
        OldcMoney.Text = (Convert.ToDecimal(ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY) / (Convert.ToDecimal(100))).ToString("0.00");

        btnReadNCard.Enabled = true;
        btnPrintPZ.Enabled = false;
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")
        {
            btnRollback.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            AddMessage("前台写卡成功");
            #region 换卡返销成功，张家港衍生卡信息同步
            //张家港衍生卡信息同步
            if (hidOldCardIDZJG.Value.Length >= 6 && hidNewCardIDZJG.Value.Length >= 6 && hidOldCardIDZJG.Value.Substring(0, 6) == "215061" && hidNewCardIDZJG.Value.Substring(0, 6) == "215061")
            {
                string tradeID = hidTradeIDZJG.Value;
                string syncCardID = hidNewCardIDZJG.Value;
                string[] parm = new string[2];
                parm[0] = tradeID;
                parm[1] = syncCardID;
                DataTable syncData = SPHelper.callQuery("SP_RC_QUERY", context, "QueryCardChangeRollbackInfoSync", parm);
                //姓名，证件号码解密
                CommonHelper.AESDeEncrypt(syncData, new List<string>(new string[] { "NAME", "PAPER_NO" }));
                //证件类型转换
                string npaperType = syncData.Rows[0]["PAPER_TYPE"].ToString();
                switch (npaperType)
                {
                    case "00": syncData.Rows[0]["PAPER_TYPE"] = "0"; break;//身份证
                    case "01": syncData.Rows[0]["PAPER_TYPE"] = "8"; break;//学生证
                    case "02": syncData.Rows[0]["PAPER_TYPE"] = "6"; break;//军官证
                    case "05": syncData.Rows[0]["PAPER_TYPE"] = "2"; break;//护照
                    case "06": syncData.Rows[0]["PAPER_TYPE"] = "3"; break;//港澳居民来往内地通行证
                    case "07": syncData.Rows[0]["PAPER_TYPE"] = "1"; break;//户口簿
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
            clearCustInfo(txtOCardno, txtNCardno);
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

        hidOldCardIDZJG.Value = "";
        hidTradeIDZJG.Value = "";
        hidNewCardIDZJG.Value = "";//add by hzl 20131205
    }

    protected void btnReadNCard_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        // txtNCardno.Text = hiddentxtCardno.Value;
        if (txtNCardno.Text != hiddenChangeCardno.Value)
        {
            context.AddError("A001022101");
            return;
        }
        //验证卡片是否世乒卡(51)，如果是旅游年卡，则不允许在该页面售出
        bool cardTypeOk = CommonHelper.allowCardtype(context, txtNCardno.Text, "5103");
        if (cardTypeOk == false)
        {
            return;
        }
        //卡账户有效性检验
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtNCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据
            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
            ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;
            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

            LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
            NewcMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / (Convert.ToDecimal(100))).ToString("0.00");

            //从IC卡资料表中读取数据
            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtNCardno.Text;
            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

            NDeposit.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT) / (Convert.ToDecimal(100))).ToString("0.00");
            NsDate.Text = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString("yyyy-MM-dd");


            //从现金台帐主表中读取换卡费用
            TF_B_TRADEFEETDO ddoTF_B_TRADEFEEIn = new TF_B_TRADEFEETDO();
            ddoTF_B_TRADEFEEIn.TRADEID = hiddenTradeid.Value;
            TF_B_TRADEFEETDO ddoTF_B_TRADEFEEOut = (TF_B_TRADEFEETDO)tmTMTableModule.selByPK(context, ddoTF_B_TRADEFEEIn, typeof(TF_B_TRADEFEETDO), null,"TF_B_TRADEFEE_ROLLBACK",null );

            if (ddoTF_B_TRADEFEEOut == null)
            {
                context.AddError("A001022104");
                return;
            }

            DepositFee.Text = (Convert.ToDecimal(hiddenDepositFee.Value) - Convert.ToDecimal(ddoTF_B_TRADEFEEOut.CARDDEPOSITFEE) / (Convert.ToDecimal(100))).ToString("0.00");
            CardcostFee.Text = (Convert.ToDecimal(hiddenCardcostFee.Value) - Convert.ToDecimal(ddoTF_B_TRADEFEEOut.CARDSERVFEE) / (Convert.ToDecimal(100))).ToString("0.00");
            Total.Text = (Convert.ToDecimal(DepositFee.Text) + Convert.ToDecimal(CardcostFee.Text) + Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");
            ReturnSupply.Text = Total.Text;

            btnRollback.Enabled = true;
            btnPrintPZ.Enabled = false;
        }

    }

    protected void btnRollback_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //查询是否当天当操作员进行的换卡
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

        //查询换卡操作是否最新的一次业务操作
        string strSale = " Select TRADETYPECODE From TF_B_TRADE WHERE CARDNO = '" + txtNCardno.Text + "' " +
                         " And OPERATETIME > (SELECT OPERATETIME FROM TF_B_TRADE WHERE CARDNO = '" + txtNCardno.Text + "' " +
                         " AND TRADETYPECODE = '03' AND CANCELTAG = '0') "+
                         " And CANCELTAG = '0' AND ASCII(TRADETYPECODE) < 65 ";
        DataTable dataSale = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strSale, 0);

        if (dataSale.Rows.Count > 0)
        {
            context.AddError("A001022105");
            return;
        }
        //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据

        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
        ddoTF_F_CUSTOMERRECIn.CARDNO = txtNCardno.Text;

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

        //证件类型赋值

        if (ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE != "")
        {
            hidPapertype.Value = ddoTD_M_PAPERTYPEOut.PAPERTYPENAME;
        }
        else hidPapertype.Value = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

        hidCustname.Value = ddoTF_F_CUSTOMERRECOut.CUSTNAME;
        hidPaperno.Value = ddoTF_F_CUSTOMERRECOut.PAPERNO;
        //存储过程赋值

        SP_PB_ChangeCardRollback_COMPDO pdo = new SP_PB_ChangeCardRollback_COMPDO();
        pdo.ID = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
        //pdo.ID = hiddentradeno.Value + DateTime.Now.ToString("MMddhhmmss") + hiddenAsn.Value.Substring(16, 4);
        pdo.OLDCARDNO = txtOCardno.Text;
        pdo.NEWCARDNO = txtNCardno.Text;
        pdo.TRADETYPECODE = "04";
        pdo.CARDTRADENO = hiddentradeno.Value;
        pdo.CANCELTRADEID = hiddenTradeid.Value;
        pdo.REASONCODE = hiddenREASONCODE.Value;
        pdo.TRADEPROCFEE = Convert.ToInt32(Convert.ToDecimal(ProcedureFee.Text) * 100);
        pdo.OTHERFEE = Convert.ToInt32(Convert.ToDecimal(OtherFee.Text) * 100);
        pdo.CARDSTATE = hiddenCardstate.Value;
        pdo.SERSTAKETAG = hiddenSerstaketag.Value;
        pdo.TERMNO = "112233445566";
        pdo.OPERCARDNO = context.s_CardID;
        hidSupplyMoney.Value = hiddencMoney.Value;
      
        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);
    
        if (ok)
        {
            //换卡返销成功时提示
            //AddMessage("M001022100");
            //写卡
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                    "changeCardRollback();", true);
            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtOCardno.Text, hidCustname.Value, "换卡返销", "0.00"
            , ReturnSupply.Text, txtNCardno.Text, hidPaperno.Value, (Convert.ToDecimal(hiddencMoney.Value) / (Convert.ToDecimal(100))).ToString("0.00"),
             "", ReturnSupply.Text, context.s_UserID, context.s_DepartName, hidPapertype.Value, ProcedureFee.Text, "0.00");

             //张家港衍生卡信息同步
            if (pdo.NEWCARDNO.Substring(0, 6) == "215061" && pdo.OLDCARDNO.Substring(0, 6) == "215061")
            {
                string tradeID = ((SP_PB_ChangeCardRollback_COMPDO)pdoOut).TRADEID;
                hidTradeIDZJG.Value = tradeID;
                hidOldCardIDZJG.Value = pdo.OLDCARDNO.ToString();
                hidNewCardIDZJG.Value = pdo.NEWCARDNO.ToString();
            }

            //换卡返销按钮不可用
            btnRollback.Enabled = false;
            //重新初始化
            initLoad(sender, e);
        }
    }
}
