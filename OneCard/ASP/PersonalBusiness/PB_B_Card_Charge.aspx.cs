using System;
using System.Collections;
using System.Web.UI;
using TM;
using TDO.CardManager;
using TDO.BusinessCode;
using Common;
using PDO.PersonalBusiness;
using TDO.ResourceManager;
using Master;
using TDO.UserManager;
using System.Data;

public partial class ASP_PersonalBusiness_PB_B_Card_Charge : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            setReadOnly(LabAsn, LabCardtype, sDate, eDate, cMoney, RESSTATE);

            Money.Attributes["onfocus"] = "this.select();";
            Money.Attributes["onkeyup"] = "changemoney(this);";

            if (!context.s_Debugging) setReadOnly(txtCardno);

            initLoad();

            ScriptManager2.SetFocus(btnReadCard);
        }
    }

    protected void initLoad()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从前台业务交易费用表中读取数据


        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "02";

        TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001002125", "TD_M_TRADEFEE", null);

        for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        {
            //费用类型为充值


            if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "01")
                hidSupplyFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为其他费用


            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "99")
                OtherFee.Text = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        }
        SupplyFee.Text = hidSupplyFee.Value;
        Total.Text = (Convert.ToDecimal(SupplyFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");

        //查询当前操作员充值默认值



        TD_M_INSIDESTAFFPARAMETERTDO tdoTD_M_INSIDESTAFFPARAMETERIn = new TD_M_INSIDESTAFFPARAMETERTDO();
        tdoTD_M_INSIDESTAFFPARAMETERIn.STAFFNO = context.s_UserID;

        TD_M_INSIDESTAFFPARAMETERTDO tdoTD_M_INSIDESTAFFPARAMETEROut = (TD_M_INSIDESTAFFPARAMETERTDO)tmTMTableModule.selByPK(context, tdoTD_M_INSIDESTAFFPARAMETERIn, typeof(TD_M_INSIDESTAFFPARAMETERTDO), null, "TD_M_INSIDESTAFFPARAMETER", null);
        //当前操作员没有充值默认值



        if (tdoTD_M_INSIDESTAFFPARAMETEROut == null)
        {
            Money.Text = "0";
        }
        //当前操作员有充值默认值



        else if (tdoTD_M_INSIDESTAFFPARAMETEROut.SUPPLEMONEY != -1)
        {
            Money.Text = Convert.ToString((Convert.ToDecimal(tdoTD_M_INSIDESTAFFPARAMETEROut.SUPPLEMONEY)) / (Convert.ToDecimal(100)));
            SupplyFee.Text = (Convert.ToDecimal(SupplyFee.Text) + (Convert.ToDecimal(tdoTD_M_INSIDESTAFFPARAMETEROut.SUPPLEMONEY)) / (Convert.ToDecimal(100))).ToString("0.00");
            Total.Text = (Convert.ToDecimal(SupplyFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");
        }

        //Cash.Checked = true;
        //XFCard.Checked = false;
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        btnReadCardProcess();

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
            Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
            Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
        }

        initLoad();

        if (context.hasError())
        {
            ScriptManager2.SetFocus(btnReadCard);
        }
        else
        {
            ScriptManager2.SetFocus(Money);
        }
    }

    protected void btnReadCardProcess()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //卡账户有效性检验


        //吴江B卡判断

        if (txtCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("不是吴江B卡,不能充值");
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

            //从证件类型编码表(TD_M_PAPERTYPE)中读取数据


            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
            ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);

            //给页面显示项赋值


            LabAsn.Text = hiddenAsn.Value.Substring(4, 16);
            LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
            sDate.Text = ASHelper.toDateWithHyphen(hiddensDate.Value);
            eDate.Text = ASHelper.toDateWithHyphen(hiddeneDate.Value);
            cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / (Convert.ToDecimal(100))).ToString("0.00");
            CustName.Text = ddoTF_F_CUSTOMERRECOut.CUSTNAME;

            //检验卡片是否已经启用


            if (String.Compare(hiddensDate.Value, DateTime.Today.ToString("yyyyMMdd")) > 0)
            {
                context.AddError("卡片尚未启用");
                return;
            }

            //性别显示
            if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "0")
                Custsex.Text = "男";
            else if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "1")
                Custsex.Text = "女";
            else Custsex.Text = "";

            //出生日期显示
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

            //证件类型显示
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

            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text;

            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);
            sellTime.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");

            //查询卡片开通功能并显示
            PBHelper.openFunc(context, openFunc, txtCardno.Text);

            btnSupply.Enabled = true;
            btnPrintPZ.Enabled = false;
        }
    }

    //充值类型改变时清空费用信息
    protected void Cash_CheckedChanged(object sender, EventArgs e)
    {
        Money.Text = "";
        SupplyFee.Text = "0.00";
        Total.Text = (Convert.ToDecimal(SupplyFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");

        if (Cash.Checked)
        {
            Money.MaxLength = 7;
            labPrompt.Text = "请输入充值金额:";
            charge50.Visible = true;
            charge60.Visible = true;
            charge100.Visible = true;
        }
        else
        {
            Money.MaxLength = 16;
            labPrompt.Text = "请输入16位充值卡密码:";
            charge50.Visible = false;
            charge60.Visible = false;
            charge100.Visible = false;
        }
        ScriptManager2.SetFocus(Money);
    }

    //输入内容有效性检查


    private Boolean inportValidation()
    {
        //对输入金额进行非空、非零、数字、金额格式判断


        if (Cash.Checked == true)
        {
            if (!Validation.isNum(Money.Text.Trim()))
                context.AddError("A001002100");
            else if (Money.Text.Trim() == "" || Convert.ToDecimal(Money.Text.Trim()) == 0)
                context.AddError("A001002126");
            else if (!Validation.isPosRealNum(Money.Text.Trim()))
                context.AddError("A001002127");
        }

        return !(context.hasError());
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "CashChargeConfirm")
        {
            btnSupply_Click(sender, e);
            hidWarning.Value = "";
            return;
        }

        if (Cash.Checked)
        {
            if (hidWarning.Value == "yes")
            {
                btnSupply.Enabled = true;
            }
            else if (hidWarning.Value == "writeSuccess")
            {
                SP_PB_updateCardTradePDO pdo = new SP_PB_updateCardTradePDO();
                pdo.CARDTRADENO = hiddentradeno.Value;
                pdo.TRADEID = hidoutTradeid.Value;

                bool ok = TMStorePModule.Excute(context, pdo);

                if (ok)
                {
                    AddMessage("前台写卡成功");
                    clearCustInfo(txtCardno);
                }
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
        }
        initLoad();
        hidWarning.Value = "";
        hidCardnoForCheck.Value = "";//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致

    }

    protected void btnSupply_Click(object sender, EventArgs e)
    {
        //对输入金额或充值卡密码有效性进行检验


        if (!inportValidation())
            return;

        //吴江B卡判断

        if (txtCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("不是吴江B卡,不能充值");
            return;
        }


        TMTableModule tmTMTableModule = new TMTableModule();

        //从IC卡电子钱包账户表中读取数据


        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text;

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null, "TF_F_CARDEWALLETACC", null);

        //充值类型为现金
        if (Cash.Checked == true)
        {

            SP_PB_ChargePDO pdo = new SP_PB_ChargePDO();

            pdo.ID = DealString.GetRecordID(hiddentradeno.Value, LabAsn.Text);
            //pdo.ID = hiddentradeno.Value + DateTime.Now.ToString("MMddhhmmss") + LabAsn.Text.Substring(12, 4);
            pdo.CARDNO = txtCardno.Text;
            pdo.CARDTRADENO = hiddentradeno.Value;
            pdo.CARDMONEY = Convert.ToInt32(Convert.ToDecimal(cMoney.Text) * 100);
            pdo.CARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;
            pdo.ASN = LabAsn.Text;
            pdo.CARDTYPECODE = hiddenLabCardtype.Value;
            pdo.TRADETYPECODE = "02";
            pdo.SUPPLYMONEY = Convert.ToInt32((Convert.ToDecimal(Money.Text)) * 100);
            hidSupplyMoney.Value = "" + pdo.SUPPLYMONEY;
            hiddenSupply.Value = Money.Text;
            pdo.OPERCARDNO = context.s_CardID;
            pdo.TERMNO = "665544332211";
            pdo.OTHERFEE = (Convert.ToInt32(Convert.ToDecimal(OtherFee.Text)) * 100);
            PDOBase pdoOut;
            bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

            if (ok)
            {
                hidoutTradeid.Value = "" + ((SP_PB_ChargePDO)pdoOut).TRADEID;

                hidCardnoForCheck.Value = txtCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致

                //AddMessage("M001002001");
                ScriptManager.RegisterStartupScript(this, this.GetType(),
                    "writeCardScript", "chargeCard();", true);

                btnPrintPZ.Enabled = true;
                Money.Text = "";
                ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, CustName.Text, "充值",
                hiddenSupply.Value, "", "", Paperno.Text,
                Convert.ToString((pdo.CARDMONEY + pdo.SUPPLYMONEY) / 100.0), "", hiddenSupply.Value, context.s_UserID,
                context.s_DepartName, Papertype.Text, "0.00", "");

                //foreach (Control con in this.Page.Controls)
                //{
                //    ClearControl(con);
                //}

                btnSupply.Enabled = false;
            }

        }

    } 

}
