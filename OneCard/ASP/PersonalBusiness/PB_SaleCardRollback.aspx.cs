using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using DataExchange;
using Master;
using PDO.PersonalBusiness;
using TDO.BusinessCode;
using TDO.CardManager;
using TDO.PersonalTrade;
using TDO.ResourceManager;
using TDO.UserManager;
using TM;

public partial class ASP_PersonalBusiness_PB_SaleCardRollback : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            LabAsn.Attributes["readonly"] = "true";
            LabCardtype.Attributes["readonly"] = "true";
            RESSTATE.Attributes["readonly"] = "true";
            cMoney.Attributes["readonly"] = "true";
            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";
            initLoad(sender, e);
        }

    }
    protected void initLoad(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从前台业务交易费用表中读取售卡费用数据

        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "A1";

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
        Total.Text = (Convert.ToDecimal(DepositFee.Text) + Convert.ToDecimal(CardcostFee.Text) + Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");
        ReturnSupply.Text = Total.Text;
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //卡账户有效性检验

        //验证卡片是否世乒卡(51)，如果是旅游年卡，则不允许在该页面售出
        bool cardTypeOk = CommonHelper.allowCardtype(context, txtCardno.Text,  "5103");
        if (cardTypeOk == false)
        {
            return;
        }

        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据


            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
            ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;

            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

            //从用户卡库存表(TL_R_ICUSER)中读取数据

            TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
            ddoTL_R_ICUSERIn.CARDNO = txtCardno.Text;

            TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

            if (ddoTL_R_ICUSEROut == null)
            {
                context.AddError("A001001101");
                return;
            }

            //从资源状态编码表中读取数据

            TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEIn = new TD_M_RESOURCESTATETDO();
            ddoTD_M_RESOURCESTATEIn.RESSTATECODE = ddoTL_R_ICUSEROut.RESSTATECODE;

            TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEOut = (TD_M_RESOURCESTATETDO)tmTMTableModule.selByPK(context, ddoTD_M_RESOURCESTATEIn, typeof(TD_M_RESOURCESTATETDO), null, "TD_M_RESOURCESTATE", null);

            if (ddoTD_M_RESOURCESTATEOut == null)
                RESSTATE.Text = ddoTL_R_ICUSEROut.RESSTATECODE;
            else
                RESSTATE.Text = ddoTD_M_RESOURCESTATEOut.RESSTATE;

            //从IC卡资料表中读取数据

            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text;
            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

            SaleDate.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");
            //更新费用显示信息
            DepositFee.Text = (Convert.ToDecimal(hiddenDepositFee.Value) - Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT)/100).ToString("0.00");
            CardcostFee.Text = (Convert.ToDecimal(hiddenCardcostFee.Value) - Convert.ToDecimal(ddoTF_F_CARDRECOut.CARDCOST)/100).ToString("0.00");
            Total.Text = (Convert.ToDecimal(DepositFee.Text) + Convert.ToDecimal(CardcostFee.Text) + Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");
            ReturnSupply.Text = Total.Text;

            //从内部员工编码表(TD_M_INSIDESTAFF)中读取数据

            TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            ddoTD_M_INSIDESTAFFIn.STAFFNO = ddoTF_F_CARDRECOut.STAFFNO;

            TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFOut = (TD_M_INSIDESTAFFTDO)tmTMTableModule.selByPK(context, ddoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_Destroy", null);

            SaleStaff.Text = ddoTD_M_INSIDESTAFFOut.STAFFNAME;
            //给页面显示项赋值

            LabAsn.Text = hiddenAsn.Value.Substring(4, 16);
            LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
            cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / 100).ToString("0.00");

            //读取客户资料
            readInfo(sender, e);

            //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
            if (!CommonHelper.HasOperPower(context))
            {
                Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
                Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
                Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
            }

            //查询开通功能

            PBHelper.openFunc(context, openFunc, txtCardno.Text);

            btnRollback.Enabled = true;

            btnPrintPZ.Enabled = false;
        }
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
        hidCustPaperType.Value = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;//保存证件类型编码

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
            #region 写卡成功，张家港衍生卡信息同步
            if (hidCardIDZJG.Value.Length>=6&&hidCardIDZJG.Value.Substring(0, 6) == "215061")
            {
                string tradeID = hidTradeIDZJG.Value;
                string syncCardID = hidCardIDZJG.Value;
                string[] parm = new string[2];
                parm[0] = tradeID;
                parm[1] = syncCardID;
                DataTable syncData = SPHelper.callQuery("SP_RC_QUERY", context, "QueryCardSaleRollbackInfoSync", parm);
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
                //姓名，证件号码解密
                CommonHelper.AESDeEncrypt(syncData, new List<string>(new string[] { "NAME", "PAPER_NO" }));

                //调用后台接口
                SyncRequest syncRequest;
                bool sync = DataExchangeHelp.ParseFormDataTable(syncData, tradeID, out syncRequest);
                if (sync == true)
                {
                    SyncRequest syncResponse;
                    string msg;
                    bool succ = DataExchangeHelp.Sync(syncRequest, out syncResponse, out msg);
                    if (!succ)
                    {
                        context.AddError("调用接口失败:" + msg);
                    }
                    else
                    {
                        AddMessage("接口调用成功!");
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

        hidCardIDZJG.Value = "";
        hidTradeIDZJG.Value = "";
    }

    protected void btnRollback_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //查询是否当天当操作员进行的售卡

        TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();

        string str = " Select SELLTIME,STAFFNO From TF_F_CARDREC WHERE CARDNO = '"+txtCardno.Text+"' "+
                     " And SELLTIME BETWEEN Trunc(sysdate,'dd') AND sysdate" +
                     " And STAFFNO = '"+context.s_UserID+"' ";
        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTF_F_CARDRECIn, null, str, 0);

        if (data.Rows.Count == 0)
        {
            context.AddError("A001020100");
            return;
        }

        //查询售卡操作是否最新的一次业务操作

        TF_B_TRADETDO ddoTF_B_TRADEIn = new TF_B_TRADETDO();
        string strSale = " Select TRADETYPECODE From TF_B_TRADE WHERE CARDNO = '" + txtCardno.Text + "' " +
                         " And OPERATETIME > (SELECT SELLTIME FROM TF_F_CARDREC WHERE CARDNO = '" + txtCardno.Text + "') "+
                         " And CANCELTAG = '0' AND (ASCII(TRADETYPECODE) < 65 AND TRADETYPECODE NOT IN ('3A','3B')) ";
        DataTable dataSale = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strSale, 0);

        if (dataSale.Rows.Count > 0)
        {
            context.AddError("A001020108");
            return;
        }
        string strTradeid = "Select TRADEID From TF_B_TRADE WHERE CARDNO = '" + txtCardno.Text + "' " +
                            " And TRADETYPECODE = '01' AND CANCELTAG = '0' ";

        DataTable dataTradeid = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strTradeid, 0);
 
        //存储过程赋值


        SP_PB_SaleCardRollback_COMMITPDO pdo = new SP_PB_SaleCardRollback_COMMITPDO();
        pdo.ID = DealString.GetRecordID(hiddentradeno.Value, LabAsn.Text);
        //pdo.ID = hiddentradeno.Value + DateTime.Now.ToString("MMddhhmmss") + LabAsn.Text.Substring(12, 4);
        pdo.CARDNO = txtCardno.Text;
        pdo.CARDTRADENO = hiddentradeno.Value;
        pdo.CARDMONEY = Convert.ToInt32(Convert.ToDecimal(cMoney.Text) * 100);
        pdo.DEPOSIT = Convert.ToInt32(Convert.ToDecimal(DepositFee.Text) * 100);
        pdo.CARDCOST = Convert.ToInt32(Convert.ToDecimal(CardcostFee.Text) * 100);
        pdo.CANCELTRADEID = dataTradeid.Rows[0][0].ToString();
        //pdo.TRADETYPECODE = "A1";
        pdo.TRADEPROCFEE = Convert.ToInt32(Convert.ToDecimal(ProcedureFee.Text) * 100);
        pdo.OTHERFEE = Convert.ToInt32(Convert.ToDecimal(OtherFee.Text) * 100);
        pdo.TERMNO = "112233445566";
        pdo.OPERCARDNO = context.s_CardID;

       
       
        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (ok)
        {
            //售卡返销成功时提示

            //AddMessage("M001020100");
            //写卡
            hidCardReaderToken.Value = cardReader.createToken(context); 
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                "writeCardScript", "saleRollback();", true);
            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, CustName.Text, "售卡返销", "0.00"
                , DepositFee.Text, "", Paperno.Text, "0.00", "0.00",
                Total.Text, context.s_UserID, context.s_DepartName, Papertype.Text, ProcedureFee.Text, "0.00");

            //张家港衍生卡信息同步
            if (pdo.CARDNO.Substring(0, 6) == "215061")
            {
                string tradeID = ((SP_PB_SaleCardRollback_COMMITPDO)pdoOut).TRADEID;
                hidTradeIDZJG.Value = tradeID;
                hidCardIDZJG.Value = pdo.CARDNO.ToString();
            }

            //售卡返销按钮不可用

            btnRollback.Enabled = false;
            //重新初始化

            initLoad(sender, e);
            btnPrintPZ.Enabled = true;
        }
    }
}
