using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using Common;
using DataExchange;
using Master;
using PDO.PersonalBusiness;
using TDO.BusinessCode;
using TDO.CardManager;
using TDO.ResourceManager;
using TDO.UserManager;
using TM;
using PDO.AdditionalService;

public partial class ASP_PersonalBusiness_PB_ReturnCard : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (!context.s_Debugging) setReadOnly(txtCardno);
            setReadOnly(LabAsn, sDate, eDate, cMoney);
            //btnDBRead.Attributes["onclick"] = "warnCheck()";

            TMTableModule tmTMTableModule = new TMTableModule();

            //从退换卡原因编码表(TD_M_REASONTYPE)中读取数据，放入下拉列表中

            TD_M_REASONTYPETDO tdoTD_M_REASONTYPEIn = new TD_M_REASONTYPETDO();
            TD_M_REASONTYPETDO[] tdoTD_M_REASONTYPEOutArr = (TD_M_REASONTYPETDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_REASONTYPEIn, typeof(TD_M_REASONTYPETDO), "S001007122");

            ControlDeal.SelectBoxFill(selReasonType.Items, tdoTD_M_REASONTYPEOutArr, "REASON", "REASONCODE", false);

            initLoad(sender, e);
        }
    }

    protected void initLoad(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从前台业务交易费用表中读取数据

        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "05";

        TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001001137", "TD_M_TRADEFEE", null);

        for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        {
            //费用类型为押金

            if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "00")
                hidCancelDepositFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为充值

            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "01")
                hidCancelSupplyFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为手续费
            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "03")
                ProcedureFee.Text = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为其他费用

            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "99")
                OtherFee.Text = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        }

        CancelDepositFee.Text = hidCancelDepositFee.Value;
        CancelSupplyFee.Text = hidCancelSupplyFee.Value;
        Total.Text = (Convert.ToDecimal(CancelDepositFee.Text) + Convert.ToDecimal(CancelSupplyFee.Text) + Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");
        ReturnSupply.Text = Total.Text;
    }

    //退卡类型改变时,读卡和读数据库按钮是否可用改变
    protected void selReasonType_SelectedIndexChanged(object sender, EventArgs e)
    {
        //foreach (Control con in this.Page.Controls)
        //{
        //    ClearControl(con);
        //}

        initLoad(sender, e);

        //退卡类型为可读卡时,读卡按钮可用,读数据库按钮不可用

        if (selReasonType.SelectedValue == "11" || selReasonType.SelectedValue == "12" || selReasonType.SelectedValue == "13")
        {
            if (!context.s_Debugging) setReadOnly(txtCardno);
            //txtCardno.ReadOnly = true;
            btnReadCard.Enabled = true;
            txtCardno.CssClass = "labeltext";
            btnDBRead.Enabled = false;
        }
        //退卡类型为不可读卡时,读卡按钮不可用,读数据库按钮可用
        else if (selReasonType.SelectedValue == "14" || selReasonType.SelectedValue == "15")
        {
            txtCardno.Attributes.Remove("readonly");
            //txtCardno.ReadOnly = false;
            btnReadCard.Enabled = false;
            btnDBRead.Enabled = true;
            txtCardno.CssClass = "input";
        }
    }

    protected void readInfo(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据

        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
        ddoTF_F_CUSTOMERRECIn.CARDNO = txtCardno.Text;

        DDOBase ddoBase=(DDOBase)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);;
        
        //解密
        ddoBase =CommonHelper.AESDeEncrypt(ddoBase);

        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)ddoBase;


        if (ddoTF_F_CUSTOMERRECOut == null)
        {
            context.AddError("A001002111");
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


        //DataTable dt = SPHelper.callPBQuery(context, "CheckParkInfoWhenSale", txtCardno.Text);//mod by liuhe 20120731去掉对园林卡的验证 SZCIC-XQ-20120719-001
        //if (dt != null && dt.Rows.Count > 0)
        //{
        //    context.AddError("自2008年11月1日起出售的苏州通卡片，凡是开通园林或休闲功能的，不允许退卡。");
        //}
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        #region add by gl 2015-01-16 图书馆验证
        SP_AS_QueryPDO pdolib = new SP_AS_QueryPDO();
        pdolib.funcCode = "QUERYCARDOPENLIB";
        pdolib.var1 = txtCardno.Text.Trim();
        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdolib);

        if (data.Rows.Count > 0)
        {
            string retMsg = LibraryHelper.cancelCardCheck(txtCardno.Text.Trim());
            if (retMsg != "0000")
            {
                context.AddError(retMsg);
                return;
            }
        }
        #endregion


        TMTableModule tmTMTableModule = new TMTableModule();

        //添加对市民卡的验证
        SP_SmkCheckPDO smkpdo = new SP_SmkCheckPDO();
        smkpdo.CARDNO = txtCardno.Text;
        bool smkok = TMStorePModule.Excute(context, smkpdo);
        if (smkok == false)
        {
            return;
        }

        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面退卡
        bool cardTypeOk = CommonHelper.allowCardtype(context, txtCardno.Text, "5101");
        if (cardTypeOk == false)
        {
            return;
        }

        //卡账户有效性检验

        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
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

            //页面显示项赋值

            //txtCardno.Text = hiddentxtCardno.Value;
            LabAsn.Text = hiddenAsn.Value.Substring(4, 16);
            sDate.Text = hiddensDate.Value.Substring(0, 4) + "-" + hiddensDate.Value.Substring(4, 2) + "-" + hiddensDate.Value.Substring(6, 2);
            eDate.Text = hiddeneDate.Value.Substring(0, 4) + "-" + hiddeneDate.Value.Substring(4, 2) + "-" + hiddeneDate.Value.Substring(6, 2);
            cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / 100).ToString("0.00");

            PBHelper.openFunc(context, openFunc, txtCardno.Text);
            
            readInfo(sender, e);

            //从卡资料表(TF_F_CARDREC)中读取数据

            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text;

            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

            sellTime.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");
            hidSERSTAKETAG.Value = ddoTF_F_CARDRECOut.SERSTAKETAG;
            hidDEPOSIT.Value = (-Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT)/100).ToString("0.00");
            hidService.Value = (Convert.ToDecimal(ddoTF_F_CARDRECOut.SERVICEMONEY) / 100).ToString("0.00");
            //当天出售的卡不能退卡

            if (ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyyMMdd") == DateTime.Now.ToString("yyyyMMdd"))
            {
                context.AddError("A001007129");
                return;
            }

            //退卡类型为自然损坏卡时,计算退押金
            int a = ddoTF_F_CARDRECOut.DEPOSIT - ddoTF_F_CARDRECOut.SERVICEMONEY;
            
            if (selReasonType.SelectedValue == "11" || selReasonType.SelectedValue == "13")
            {
                if (a > 0)
                {
                    CancelDepositFee.Text = (Convert.ToDecimal(hidCancelDepositFee.Value) - Convert.ToDecimal(a) / 100).ToString("0.00");
                }
                else CancelDepositFee.Text = "0.00";
            }

            //从IC卡电子钱包退值表中读取数据

            TF_F_CARDEWALLETACC_BACKTDO ddoTF_F_CARDEWALLETACC_BACKIn = new TF_F_CARDEWALLETACC_BACKTDO();
            ddoTF_F_CARDEWALLETACC_BACKIn.CARDNO = txtCardno.Text;
            ddoTF_F_CARDEWALLETACC_BACKIn.USETAG = "0";

            TF_F_CARDEWALLETACC_BACKTDO ddoTF_F_CARDEWALLETACC_BACKOut = (TF_F_CARDEWALLETACC_BACKTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACC_BACKIn, typeof(TF_F_CARDEWALLETACC_BACKTDO), null, "TF_F_CARDEWALLETACC_BACK", null);
            //IC卡电子钱包退值表中没有记录时,计算退充值

            if (ddoTF_F_CARDEWALLETACC_BACKOut == null)
            {
                CancelSupplyFee.Text = (Convert.ToDecimal(hidCancelSupplyFee.Value) - Convert.ToDecimal(cMoney.Text)).ToString("0.00");
            }

            Total.Text = (Convert.ToDecimal(CancelDepositFee.Text) + Convert.ToDecimal(CancelSupplyFee.Text) + Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");
            ReturnSupply.Text = Total.Text;

            //从系统参数表中读取数据

            TD_M_TAGTDO ddoTD_M_TAGIn = new TD_M_TAGTDO();
            ddoTD_M_TAGIn.TAGCODE = "MONEY_REMIND";
            TD_M_TAGTDO ddoTD_M_TAGOut = (TD_M_TAGTDO)tmTMTableModule.selByPK(context, ddoTD_M_TAGIn, typeof(TD_M_TAGTDO), null, "TD_M_TAG", null);
            //判断是否超过最大退充值金额

            if (-Convert.ToDecimal(CancelSupplyFee.Text) * 100 > Convert.ToDecimal(ddoTD_M_TAGOut.TAGVALUE))
            {
                hidWarning.Value = "余额过大!<br><br>是否继续退卡?";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "warnScript", "warnConfirm();", true);
            }

            btnReturnCard.Enabled = !context.hasError() ;

            btnPrintPZ.Enabled = false;
        }

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
        if (hidWarning.Value == "yes")
        {
            btnReturnCard.Enabled = true;
            return;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
               AddMessage("退卡成功");
               #region 退卡成功，张家港衍生卡信息同步
               if (hidCardIDZJG.Value.Length >= 6 && hidCardIDZJG.Value.Substring(0, 6) == "215061")
               {
                   string tradeID = hidTradeIDZJG.Value;
                   string syncCardID = hidCardIDZJG.Value;
                   string[] parm = new string[2];
                   parm[0] = tradeID;
                   parm[1] = syncCardID;
                   DataTable syncData = SPHelper.callQuery("SP_RC_QUERY", context, "QueryCardReturnInfoSync", parm);
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
        else if (hidWarning.Value == "submit")
        {
            btnDBRead_Click(sender, e);
        }
        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }
      
        hidTradeIDZJG.Value = "";
        hidCardIDZJG.Value = "";//add by hzl 20131205
    }

    private Boolean DBreadValidation()
    {
        //对卡号进行非空、长度、数字检验


        if (txtCardno.Text.Trim() == "")
            context.AddError("A001008100", txtCardno);
        else
        {
            if ((txtCardno.Text.Trim()).Length != 16)
                context.AddError("A001008101", txtCardno);
            else if (!Validation.isNum(txtCardno.Text.Trim()))
                context.AddError("A001008102", txtCardno);
        }

        return !(context.hasError());
    }

    protected void btnDBRead_Click(object sender, EventArgs e)
    {
        //对输入卡号进行检验
        if (!DBreadValidation())
            return;
        #region add by gl 2015-01-16 图书馆验证
        SP_AS_QueryPDO pdolib = new SP_AS_QueryPDO();
        pdolib.funcCode = "QUERYCARDOPENLIB";
        pdolib.var1 = txtCardno.Text.Trim();
        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdolib);

        if (data.Rows.Count > 0)
        {
            string retMsg = LibraryHelper.cancelCardCheck(txtCardno.Text.Trim());
            if (retMsg != "0000")
            {
                context.AddError(retMsg);
                return;
            }
        }
        #endregion

        //添加对市民卡的验证
        SP_SmkCheckPDO smkpdo = new SP_SmkCheckPDO();
        smkpdo.CARDNO = txtCardno.Text;
        bool smkok = TMStorePModule.Excute(context, smkpdo);
        if (smkok == false)
        {
            return;
        }

        #region add by shil 20130909,如果是旅游年卡，则不允许在该页面办理业务
        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面退卡
        bool cardTypeOk = CommonHelper.allowCardtype(context, txtCardno.Text, "5101");
        if (cardTypeOk == false)
        {
            return;
        }
        #endregion

        TMTableModule tmTMTableModule = new TMTableModule();

        //卡账户有效性检验
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
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

            //从卡资料表(TF_F_CARDREC)中读取数据

            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text.Trim();

            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);
            sellTime.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");

            hidDEPOSIT.Value = (-Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT) / 100).ToString("0.00");
            hidService.Value = (Convert.ToDecimal(ddoTF_F_CARDRECOut.SERVICEMONEY) / 100).ToString("0.00");
            //当天出售的卡不能退卡

            if (ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyyMMdd") == DateTime.Now.ToString("yyyyMMdd"))
            {
                context.AddError("A001007129");
                return;
            }

            //从IC卡电子钱包帐户表(TF_F_CARDEWALLETACC)中读取数据

            TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
            ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text.Trim();

            TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);

            //给页面显示项赋值

            hidSERSTAKETAG.Value = ddoTF_F_CARDRECOut.SERSTAKETAG;
            hiddenLabCardtype.Value = ddoTF_F_CARDRECOut.CARDTYPECODE;
            LabAsn.Text = ddoTF_F_CARDRECOut.ASN;
            sDate.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");

            String Vdate = ddoTF_F_CARDRECOut.VALIDENDDATE;
            eDate.Text = Vdate.Substring(0, 4) + "-" + Vdate.Substring(4, 2) + "-" + Vdate.Substring(6, 2);

            Decimal cardMoney = Convert.ToDecimal(ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY);
            cMoney.Text = (cardMoney / 100).ToString("0.00");

            //退卡类型为不可读自然损坏卡时,计算退押金
            int a = ddoTF_F_CARDRECOut.DEPOSIT - ddoTF_F_CARDRECOut.SERVICEMONEY;
            if (selReasonType.SelectedValue == "15" && a > 0)
            {
                CancelDepositFee.Text = (Convert.ToDecimal(hidCancelDepositFee.Value) - Convert.ToDecimal(a) / 100).ToString("0.00");
                Total.Text = (Convert.ToDecimal(CancelDepositFee.Text) + Convert.ToDecimal(CancelSupplyFee.Text) + Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");
                ReturnSupply.Text = Total.Text;
            }
            else CancelDepositFee.Text = "0.00";

            PBHelper.openFunc(context, openFunc, txtCardno.Text);

            readInfo(sender, e);

            if (context.hasError())
            {
                return;
            }
            //从系统参数表中读取数据

            TD_M_TAGTDO ddoTD_M_TAGIn = new TD_M_TAGTDO();
            ddoTD_M_TAGIn.TAGCODE = "MONEY_REMIND";
            TD_M_TAGTDO ddoTD_M_TAGOut = (TD_M_TAGTDO)tmTMTableModule.selByPK(context, ddoTD_M_TAGIn, typeof(TD_M_TAGTDO), null, "TD_M_TAG", null);
            //判断是否超过退充值金额

            if (Convert.ToDecimal(cMoney.Text) * 100 > Convert.ToDecimal(ddoTD_M_TAGOut.TAGVALUE))
            {
                hidWarning.Value = "余额过大!<br><br>是否继续退卡?";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "warnScript", "warnConfirm();", true);
                btnReturnCard.Enabled = (hidWarning.Value.Length == 0);
            }
            btnReturnCard.Enabled = !context.hasError();

            btnPrintPZ.Enabled = false;
        }

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
            Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
            Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
        }
    }
    
    protected void btnReturnCard_Click(object sender, EventArgs e)
    {
        //判断卡号是否为空
        if (txtCardno.Text.Trim() == "")
        {
            context.AddError("A001008100", txtCardno);
            return;
        }

        

        //库内余额为负时,不能进行退卡

        if (Convert.ToDecimal(ReturnSupply.Text)>0)
        {
            context.AddError("A001008115");
            return;
        }

        TMTableModule tmTMTableModule = new TMTableModule();

        //读取审核员工信息
        TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        ddoTD_M_INSIDESTAFFIn.OPERCARDNO = hiddenCheck.Value;

        TD_M_INSIDESTAFFTDO[] ddoTD_M_INSIDESTAFFOut = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_CHECK", null);
        SP_PB_ReturnCardPDO pdo = new SP_PB_ReturnCardPDO();
        //存储过程赋值

        pdo.CARDNO = txtCardno.Text;
        pdo.ASN = LabAsn.Text;
        pdo.CARDTYPECODE = hiddenLabCardtype.Value;
        pdo.REASONCODE = selReasonType.SelectedValue;
        pdo.CARDMONEY = Convert.ToInt32(Convert.ToDecimal(cMoney.Text) * 100);
        pdo.REFUNDMONEY = Convert.ToInt32(Convert.ToDecimal(CancelSupplyFee.Text) * 100);
        pdo.REFUNDDEPOSIT = Convert.ToInt32(Convert.ToDecimal(CancelDepositFee.Text) * 100);
        pdo.TRADEPROCFEE = Convert.ToInt32(Convert.ToDecimal(ProcedureFee.Text) * 100);
        pdo.OTHERFEE = Convert.ToInt32(Convert.ToDecimal(OtherFee.Text) * 100);
        pdo.OPERCARDNO = context.s_CardID;
        pdo.TERMNO = "112233445566";

        //退卡类型为不可读人为损坏卡
        if (selReasonType.SelectedValue == "14" )
        {
            pdo.CARDTRADENO = LabAsn.Text.Substring(12, 4);
            pdo.ID = DealString.GetRecordID(txtCardno.Text.Substring(12, 4), txtCardno.Text);
            //pdo.ID = txtCardno.Text.Substring(12,4) + DateTime.Now.ToString("MMddhhmmss") + LabAsn.Text.Substring(12, 4);
            pdo.SERSTAKETAG = (hidSERSTAKETAG.Value != "3")?"2":"3";
            if (ddoTD_M_INSIDESTAFFOut == null || ddoTD_M_INSIDESTAFFOut.Length == 0)
            {
                context.AddError("A001010108");
                return;
            }
            pdo.CHECKSTAFFNO = ddoTD_M_INSIDESTAFFOut[0].STAFFNO;
            pdo.CHECKDEPARTNO = ddoTD_M_INSIDESTAFFOut[0].DEPARTNO;
        }
        //退卡类型为不可读自然损坏卡
        else if (selReasonType.SelectedValue == "15")
        {
            pdo.CARDTRADENO = LabAsn.Text.Substring(12, 4);
            pdo.ID = DealString.GetRecordID(txtCardno.Text.Substring(12, 4), txtCardno.Text);
            //pdo.ID = txtCardno.Text.Substring(12, 4) + DateTime.Now.ToString("MMddhhmmss") + LabAsn.Text.Substring(12, 4);
            pdo.SERSTAKETAG = "3";
            if (ddoTD_M_INSIDESTAFFOut == null || ddoTD_M_INSIDESTAFFOut.Length == 0)
            {
                context.AddError("A001010108");
                return;
            }
            pdo.CHECKSTAFFNO = ddoTD_M_INSIDESTAFFOut[0].STAFFNO;
            pdo.CHECKDEPARTNO = ddoTD_M_INSIDESTAFFOut[0].DEPARTNO;
        }
        //退卡类型为可读人为损坏卡

        else if (selReasonType.SelectedValue == "12")
        {
            pdo.CARDTRADENO = hiddentradeno.Value;
            pdo.ID = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
            //pdo.ID = hiddentradeno.Value + DateTime.Now.ToString("MMddhhmmss") + hiddenAsn.Value.Substring(16, 4);
            pdo.SERSTAKETAG = (hidSERSTAKETAG.Value != "3") ? "2" : "3";
            pdo.CHECKSTAFFNO = context.s_UserID;
            pdo.CHECKDEPARTNO = context.s_DepartID;
        }
        //退卡类型为可读正常卡或可读自然损坏卡

        else if (selReasonType.SelectedValue == "11" || selReasonType.SelectedValue == "13")
        {
            pdo.CARDTRADENO = hiddentradeno.Value;
            pdo.ID = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
            //pdo.ID = hiddentradeno.Value + DateTime.Now.ToString("MMddhhmmss") + hiddenAsn.Value.Substring(16, 4);
            pdo.SERSTAKETAG = "3";
            pdo.CHECKSTAFFNO = context.s_UserID;
            pdo.CHECKDEPARTNO = context.s_DepartID;
        }
        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo,out pdoOut);

        if (ok)
        {
            //AddMessage("M001007001");
            
            if (pdo.REASONCODE == "11" || pdo.REASONCODE == "12" || pdo.REASONCODE == "13")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript", "lockReturnCard();", true);
            }
            else if (selReasonType.SelectedValue == "14" || selReasonType.SelectedValue == "15")
            {
                AddMessage("退卡成功,请于" + DateTime.Today.AddDays(7).ToString("yyyy-MM-dd") + "后来办理销户业务!");
            }
            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, CustName.Text, "退卡", CancelSupplyFee.Text
                , hidDEPOSIT.Value, "", Paperno.Text, "0.00", hidService.Value,
                Total.Text, context.s_UserID, context.s_DepartName, Papertype.Text, ProcedureFee.Text, "0.00");
            
            //张家港衍生卡信息同步,不可读卡退卡直接调用，可读卡退卡写卡成功后再调用
            if (selReasonType.SelectedValue == "14" || selReasonType.SelectedValue == "15")
            {
                if (pdo.CARDNO.Substring(0, 6) == "215061")
                {
                    string tradeID = ((SP_PB_ReturnCardPDO)pdoOut).TRADEID;
                    string syncCardID = pdo.CARDNO.ToString();
                    string[] parm = new string[2];
                    parm[0] = tradeID;
                    parm[1] = syncCardID;
                    DataTable syncData = SPHelper.callQuery("SP_RC_QUERY", context, "QueryCardReturnInfoSync", parm);
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
                        bool succ = DataExchangeHelp.Sync(syncRequest, out syncResponse, out msg);
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
            }
            else
            {
                if (pdo.CARDNO.Substring(0, 6) == "215061")
                {
                    string tradeID = ((SP_PB_ReturnCardPDO)pdoOut).TRADEID;
                    hidTradeIDZJG.Value = tradeID;
                    hidCardIDZJG.Value = pdo.CARDNO.ToString();
                }
            }

            //foreach (Control con in this.Page.Controls)
            //{
            //    ClearControl(con);
            //}
            initLoad(sender, e);
            btnReturnCard.Enabled = false;
        }
    }
    
}
