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

/**********************************
 * 世乒旅游卡换卡返销
 * 2015-3-30
 * gl
 * 初次编写
 * ********************************/
public partial class ASP_AddtionalService_AS_SPTravelCardChangeRollback : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            setReadOnly(OsDate, OCardcost, OldcMoney,ReasonType, LabCardtype, NsDate, NewcMoney, NCardcost);
            if (!context.s_Debugging) txtNCardno.Attributes["readonly"] = "true";

            initLoad(sender, e);
        }
    }

    protected void initLoad(object sender, EventArgs e)
    {
        //TMTableModule tmTMTableModule = new TMTableModule();
        ////从前台业务交易费用表中读取售卡费用数据
        //TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        //ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "E1";

        //TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001001137", "TD_M_TRADEFEE", null);

        //for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        //{
        //    //"10"为卡费
        //    if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "10")
        //        hiddenCardcostFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        //}
        hiddenCardcostFee.Value = "0.00";
        CardcostFee.Text = hiddenCardcostFee.Value;
        FunctionFee.Text = "0.00";

        Total.Text = (Convert.ToDecimal(CardcostFee.Text) + Convert.ToDecimal(FunctionFee.Text)).ToString("0.00");
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

        hiddenOShiPingTag.Value = hiddenShiPingTag.Value;//获取旧卡卡内标志
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
        OCardcost.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.CARDCOST) / 100).ToString("0.00");
        OsDate.Text = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString("yyyy-MM-dd");

        //从业务台帐主表中读取数据
        TF_B_TRADETDO ddoTF_B_TRADEIn = new TF_B_TRADETDO();
        ddoTF_B_TRADEIn.OLDCARDNO = txtOCardno.Text;
        ddoTF_B_TRADEIn.TRADETYPECODE = "E3";
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

        //读旧卡景点标志
        //从最近的一条记录中读,没有写默认值
        DataTable data = ASHelper.callQuery(context, "SPTravelTradesRight", txtOCardno.Text);
        if (data.Rows.Count > 0)
        {
            hiddenOShiPingTag.Value = data.Rows[0]["TRAVELSIGN"].ToString();
        }
        else
        {
            hiddenOShiPingTag.Value = "";//默认值
        }

        btnReadNCard.Enabled = true;
        btnPrintPZ.Enabled = false;
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "rewriteCard") // 重新写卡，生产新的令牌
        {
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "changeShiPingRollback()();", true);
        }
        if (hidWarning.Value == "yes")
        {
            btnRollback.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            AddMessage("前台写卡成功");
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
        if (txtNCardno.Text.Substring(4, 4).ToString() != "5103")
        {
            context.AddError("A001001901：非世乒旅游卡不能在此页面换卡返销");
            ScriptManager2.SetFocus(btnReadCard);
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

            NCardcost.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.CARDCOST) / (Convert.ToDecimal(100))).ToString("0.00");
            NsDate.Text = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString("yyyy-MM-dd");
            //从套餐表里面读套餐的功能费
            DataTable dt = ASHelper.callQuery(context, "QUERYSPTRAVELCARDINFOS", txtNCardno.Text);
            if (dt.Rows.Count == 0)
            {
                context.AddError("新卡没有开通世乒旅游卡不能在此页面返销");
                ScriptManager2.SetFocus(btnReadCard);
                return;
            }
            if (dt.Rows[0]["PACKAGETYPECODE"].ToString() == "01")
            {
                txtOpenLine.Text = "东线A";
                if (hiddenOShiPingTag.Value == "") 
                {
                    hiddenOShiPingTag.Value = "15053101010101FFFFFF";
                }
            }
            else if (dt.Rows[0]["PACKAGETYPECODE"].ToString() == "02")
            {
                txtOpenLine.Text = "西线B";
                if (hiddenOShiPingTag.Value == "")
                {
                    hiddenOShiPingTag.Value = "150531FFFFFFFF010101";
                }
            }
            else if (dt.Rows[0]["PACKAGETYPECODE"].ToString() == "03")
            {
                txtOpenLine.Text = "东线A和西线B";
                if (hiddenOShiPingTag.Value == "")
                {
                    hiddenOShiPingTag.Value = "15053101010101010101";
                }
            }

            //需要判断新旧卡的标志是否一致，不一致不允许返销
            if (hiddenOShiPingTag.Value != hiddenShiPingTag.Value)
            {
                context.AddError("新卡已经在景点使用不能返销。");
                return;
            }
            txtNewFunFee.Text = (Convert.ToDecimal(dt.Rows[0]["PACKAGEFEE"].ToString()) / 100).ToString("0.00");//功能费

            //从现金台帐主表中读取换卡费用
            TF_B_TRADEFEETDO ddoTF_B_TRADEFEEIn = new TF_B_TRADEFEETDO();
            ddoTF_B_TRADEFEEIn.TRADEID = hiddenTradeid.Value;
            TF_B_TRADEFEETDO ddoTF_B_TRADEFEEOut = (TF_B_TRADEFEETDO)tmTMTableModule.selByPK(context, ddoTF_B_TRADEFEEIn, typeof(TF_B_TRADEFEETDO), null,"TF_B_TRADEFEE_ROLLBACK",null );

            if (ddoTF_B_TRADEFEEOut == null)
            {
                context.AddError("A001022104");
                return;
            }

            //DepositFee.Text = (Convert.ToDecimal(hiddenDepositFee.Value) - Convert.ToDecimal(ddoTF_B_TRADEFEEOut.CARDDEPOSITFEE) / (Convert.ToDecimal(100))).ToString("0.00");
            CardcostFee.Text = (Convert.ToDecimal(hiddenCardcostFee.Value) - Convert.ToDecimal(ddoTF_B_TRADEFEEOut.CARDSERVFEE) / (Convert.ToDecimal(100))).ToString("0.00");
            Total.Text =  CardcostFee.Text;
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

        //查询世乒售卡换卡操作是否最新的一次业务操作
        string strSale = " Select TRADETYPECODE From TF_B_TRADE WHERE CARDNO = '" + txtNCardno.Text + "' " +
                         " And OPERATETIME > (SELECT OPERATETIME FROM TF_B_TRADE WHERE CARDNO = '" + txtNCardno.Text + "' " +
                         " AND TRADETYPECODE = 'E3' AND CANCELTAG = '0') "+
                         " And CANCELTAG = '0'  AND (ASCII(TRADETYPECODE) < 65 AND TRADETYPECODE NOT IN ('3A','3B','E3'))";
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
        context.SPOpen();
        context.AddField("p_ID").Value = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
        context.AddField("p_OLDCARDNO").Value = txtOCardno.Text;
        context.AddField("p_NEWCARDNO").Value = txtNCardno.Text;
        context.AddField("p_TRADETYPECODE").Value = "04";
        context.AddField("p_CANCELTRADEID").Value = hiddenTradeid.Value;
        context.AddField("p_REASONCODE").Value = hiddenREASONCODE.Value;
        context.AddField("p_CARDTRADENO").Value = hiddentradeno.Value;
      
        
        context.AddField("p_TRADEPROCFEE", "Int32").Value = 0;
        context.AddField("p_OTHERFEE").Value = 0;
        context.AddField("p_CARDSTATE").Value = hiddenCardstate.Value;
        context.AddField("p_SERSTAKETAG").Value = hiddenSerstaketag.Value;
        context.AddField("p_TERMNO").Value = "112233445566";
        context.AddField("p_OPERCARDNO").Value = context.s_CardID;
        context.AddField("p_TRADEID", "String", "Output", "16");
        hidSupplyMoney.Value = hiddencMoney.Value;
        bool ok = context.ExecuteSP("SP_AS_SPCHANGECARDROLLBACK");
        if (ok)
        {
            //换卡返销成功时提示
            //写卡 

            hiddenShiPingTag.Value = "FFFFFFFFFFFFFFFFFFFF";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                    "changeShiPingRollback();", true);
            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtOCardno.Text, hidCustname.Value, "世乒赛-换卡返销", "0.00"
            , ReturnSupply.Text, txtNCardno.Text, hidPaperno.Value, (Convert.ToDecimal(hiddencMoney.Value) / (Convert.ToDecimal(100))).ToString("0.00"),
             "", ReturnSupply.Text, context.s_UserID, context.s_DepartName, hidPapertype.Value, CardcostFee.Text, "0.00");

            //换卡返销按钮不可用

            btnRollback.Enabled = false;
            //重新初始化

            initLoad(sender, e);
        }
    }
}
