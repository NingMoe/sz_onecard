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
using TM;
using TDO.ResourceManager;
using TDO.UserManager;
using TDO.BusinessCode;
using TDO.CardManager;
using PDO.PersonalBusiness;
using Common;
using TDO.BalanceChannel;
using Master;
using TDO.CustomerAcc;

public partial class ASP_PersonalBusiness_PB_B_Card_ChangeCard : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            // btnDBRead.Attributes["onclick"] = "warnCheck()";

            setReadOnly(OsDate, ODeposit, OldcMoney, LabCardtype, NsDate, NewcMoney, NDeposit);

            txtRealRecv.Attributes["onfocus"] = "this.select();";
            txtRealRecv.Attributes["onkeyup"] = "realRecvChanging(this,'test', 'hidAccRecv');";
            if (!context.s_Debugging) setReadOnly(txtOCardno);
            if (!context.s_Debugging) txtNCardno.Attributes["readonly"] = "true";

            //初始化换卡类型
            ASHelper.setChangeReason(selReasonType, false);

            initLoad(sender, e);
            hidAccRecv.Value = Total.Text;
        }

    }

    protected void initLoad(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从前台业务交易费用表中读取售卡费用数据
        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "03";

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
        //费用赋值
        DepositFee.Text = hiddenDepositFee.Value;
        CardcostFee.Text = hiddenCardcostFee.Value;
        ProcedureFee.Text = hidProcedureFee.Value;
        OtherFee.Text = hidOtherFee.Value;
        Total.Text = (Convert.ToDecimal(DepositFee.Text) + Convert.ToDecimal(CardcostFee.Text) + Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");
        //卡费选项不可见,押金选中,读新卡按钮不可用,换卡按钮不可用
        Cardcost.Visible = false;
        Deposit.Checked = true;
        btnReadNCard.Enabled = false;
        Change.Enabled = false;
    }

    //换卡类型改变时,读卡和读数据库按钮是否可用改变
    protected void selReasonType_SelectedIndexChanged(object sender, EventArgs e)
    {
        //foreach (Control con in this.Page.Controls)
        //{
        //    ClearControl(con);
        //}

        initLoad(sender, e);
        //换卡类型为可读卡时,读数据库按钮不可用,读卡按钮可用
        if (selReasonType.SelectedValue == "13" || selReasonType.SelectedValue == "12")
        {
            if (!context.s_Debugging) setReadOnly(txtOCardno);
            btnReadCard.Enabled = true;
            btnDBRead.Enabled = false;
            txtOCardno.CssClass = "labeltext";
        }
        //换卡类型为不可读卡时,读卡不可用,读数据库可用
        else if (selReasonType.SelectedValue == "14" || selReasonType.SelectedValue == "15")
        {
            txtOCardno.Attributes.Remove("readonly");
            btnReadCard.Enabled = false;
            btnDBRead.Enabled = true;
            txtOCardno.CssClass = "input";
        }
    }

    //判断是否企服卡,是企服卡时显示卡费卡押金选项
    protected void GroupJudge(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        TF_F_CUST_ACCTTDO ddoTF_F_CUST_ACCTIn = new TF_F_CUST_ACCTTDO();
        ddoTF_F_CUST_ACCTIn.ICCARD_NO = txtOCardno.Text;
        TF_F_CUST_ACCTTDO ddoTF_F_CUST_ACCTOut = (TF_F_CUST_ACCTTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUST_ACCTIn, typeof(TF_F_CUST_ACCTTDO), null, "TF_F_CUST_ACCT", null);
        if (ddoTF_F_CUST_ACCTOut != null)
            Cardcost.Visible = true;

        //从企服卡可充值账户表中读取数据
        //TF_F_CARDOFFERACCTDO ddoTF_F_CARDOFFERACCIn = new TF_F_CARDOFFERACCTDO();
        //ddoTF_F_CARDOFFERACCIn.CARDNO = txtOCardno.Text;
        //ddoTF_F_CARDOFFERACCIn.USETAG = "1";

        //TF_F_CARDOFFERACCTDO ddoTF_F_CARDOFFERACCOut = (TF_F_CARDOFFERACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDOFFERACCIn, typeof(TF_F_CARDOFFERACCTDO), null);

        //if (ddoTF_F_CARDOFFERACCOut != null)
        //    Cardcost.Visible = true;
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        //吴江B卡判断
        if (txtOCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("不是吴江B卡,不能在本业务界面操作");
            return;
        }
        
        TMTableModule tmTMTableModule = new TMTableModule();

        //卡账户有效性检验
        // txtOCardno.Text = hiddentxtCardno.Value;
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtOCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //从IC卡资料表中读取数据
            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtOCardno.Text;
            
            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

            //从用户卡库存表(TL_R_ICUSER)中读取数据
            TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
            ddoTL_R_ICUSERIn.CARDNO = txtOCardno.Text;

            TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

            if (ddoTL_R_ICUSEROut == null)
            {
                context.AddError("A001001101");
                return;
            }

            //获取旧卡售卡方式
            hidOSaletype.Value = ddoTL_R_ICUSEROut.SALETYPE;

            if (hidOSaletype.Value == "01")
            {
                context.AddError("吴江B卡不允许卡费卡更换");
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

            //给页面显示项赋值
            hidOldCardcost.Value = ddoTF_F_CARDRECOut.CARDCOST.ToString();
            SERTAKETAG.Value = ddoTF_F_CARDRECOut.SERSTAKETAG;
            OSERVICEMOENY.Value = ddoTF_F_CARDRECOut.SERVICEMONEY.ToString();
            SERSTARTIME.Value = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString();
            CUSTRECTYPECODE.Value = ddoTF_F_CARDRECOut.CUSTRECTYPECODE;
            //txtOCardno.Text = hiddentxtCardno.Value;
            ODeposit.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT) / (Convert.ToDecimal(100))).ToString("0.00");
            OsDate.Text = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString("yyyy-MM-dd");
            OldcMoney.Text = (Convert.ToDecimal(hiddencMoney.Value) / (Convert.ToDecimal(100))).ToString("0.00");

            //查询卡片开通功能并显示
            PBHelper.openFunc(context, openFunc, txtOCardno.Text);

            hidCardnoForCheck.Value = txtOCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致

            GroupJudge(sender, e);
            hidCardReaderToken.Value = cardReader.createToken(context); 
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                "lockCard();", true);

            //btnReadNCard.Enabled = (hidWarning.Value.Length == 0);
            btnReadNCard.Enabled = true;

            btnPrintPZ.Enabled = false;
            //btnPrintSJ.Enabled = false;

            hidLockFlag.Value = "true";
        }
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")
        {
            btnReadNCard.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            if (hidLockFlag.Value == "true")
            {
                AddMessage("旧卡锁定成功");
            }
            else
            {
                if (selReasonType.SelectedValue == "14" || selReasonType.SelectedValue == "15")
                {
                    AddMessage("换卡成功,请于" + DateTime.Today.AddDays(7).ToString("yyyy-MM-dd") + "后来办理转值业务!");
                }
                else
                {
                    AddMessage("前台写卡成功");
                }
                clearCustInfo(txtOCardno, txtNCardno);
            }
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
        hidLockFlag.Value = "";
        hidWarning.Value = "";
        hidCardnoForCheck.Value = "";//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致
    }

    private Boolean DBreadValidation()
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
        //吴江B卡判断
        if (txtOCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("不是吴江B卡,不能在本业务界面操作");
            return;
        }
        
        //对输入卡号进行检验
        if (!DBreadValidation())
            return;

        TMTableModule tmTMTableModule = new TMTableModule();
        //卡账户有效性检验
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtOCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //从IC卡资料表中读取数据
            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtOCardno.Text;
           
            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

            //从IC卡电子钱包账户表中读取数据
            TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
            ddoTF_F_CARDEWALLETACCIn.CARDNO = txtOCardno.Text;

            TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);

            //从用户卡库存表(TL_R_ICUSER)中读取数据
            TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
            ddoTL_R_ICUSERIn.CARDNO = txtOCardno.Text;

            TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

            if (ddoTL_R_ICUSEROut == null)
            {
                context.AddError("A001001101");
                return;
            }

            //获取旧卡售卡方式
            hidOSaletype.Value = ddoTL_R_ICUSEROut.SALETYPE;

            if (hidOSaletype.Value == "01")
            {
                context.AddError("吴江B卡不允许卡费卡更换");
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

            //给页面显示项赋值
            hidOldCardcost.Value = ddoTF_F_CARDRECOut.CARDCOST.ToString();
            hiddenAsn.Value = ddoTF_F_CARDRECOut.ASN;
            SERTAKETAG.Value = ddoTF_F_CARDRECOut.SERSTAKETAG;
            OSERVICEMOENY.Value = ddoTF_F_CARDRECOut.SERVICEMONEY.ToString();
            SERSTARTIME.Value = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString();
            CUSTRECTYPECODE.Value = ddoTF_F_CARDRECOut.CUSTRECTYPECODE;
            ODeposit.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT) / 100).ToString("0.00");
            OsDate.Text = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString("yyyy-MM-dd");
            OldcMoney.Text = (Convert.ToDecimal(ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY) / 100).ToString("0.00");

            //查询卡片开通功能并显示
            PBHelper.openFunc(context, openFunc, txtOCardno.Text);

            hiddentxtCardno.Value = txtOCardno.Text;
            GroupJudge(sender, e);

            //读新卡按钮可用
            btnReadNCard.Enabled = true;

            btnPrintPZ.Enabled = false;
            //btnPrintSJ.Enabled = false;
        }
    }

    protected void btnReadNCard_Click(object sender, EventArgs e)
    {
        //吴江B卡判断
        if (txtNCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("不是吴江B卡,不能在本业务界面操作");
            return;
        }
       
        TMTableModule tmTMTableModule = new TMTableModule();

        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据
        // txtNCardno.Text = hiddentxtCardno.Value;
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;

        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

        //从用户卡库存表(TL_R_ICUSER)中读取数据
        TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
        ddoTL_R_ICUSERIn.CARDNO = txtNCardno.Text;

        TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

        if (ddoTL_R_ICUSEROut == null)
        {
            context.AddError("A001004128");
            return;
        }

        //获取旧卡售卡方式
        hidSaletype.Value = ddoTL_R_ICUSEROut.SALETYPE;

        if (hidSaletype.Value == "01")
        {
            context.AddError("吴江B卡不允许更换卡费卡");
            return;
        }

        //给页面显示项赋值
        hidCardprice.Value = ddoTL_R_ICUSEROut.CARDPRICE.ToString();
        txtNCardno.Text = txtNCardno.Text;
        NDeposit.Text = (Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE)/100).ToString("0.00");
        LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
        NsDate.Text = hiddensDate.Value.Substring(0, 4) + "-" + hiddensDate.Value.Substring(4, 2) + "-" + hiddensDate.Value.Substring(6, 2);
        NewcMoney.Text = (Convert.ToDecimal(hiddencMoney.Value)/100).ToString("0.00");

        FeeCount(sender, e);

        hidAccRecv.Value = Total.Text;
        txtRealRecv.Text = Convert.ToInt32(Convert.ToDecimal(Total.Text)).ToString();

        if (Convert.ToDecimal(hiddencMoney.Value) != 0)
        {
            context.AddError("A001001144");
            return;
        }

        //换卡按钮可用
        Change.Enabled = true;

        btnPrintPZ.Enabled = false;
        //btnPrintSJ.Enabled = false;
    }

    //根据换卡类型和选择押金类型确定费用
    protected void FeeCount(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_CALLINGSTAFFTDO ddoTD_M_CALLINGSTAFFIn = new TD_M_CALLINGSTAFFTDO();
        ddoTD_M_CALLINGSTAFFIn.OPERCARDNO = txtOCardno.Text;
        TD_M_CALLINGSTAFFTDO[] ddoTD_M_CALLINGSTAFFOut = (TD_M_CALLINGSTAFFTDO[])tmTMTableModule.selByPKArr(context, 
            ddoTD_M_CALLINGSTAFFIn, typeof(TD_M_CALLINGSTAFFTDO),null, "TD_M_CALLINGSTAFF_BY_CARDNO", null);

        //老卡不是司机卡
        if (ddoTD_M_CALLINGSTAFFOut == null || ddoTD_M_CALLINGSTAFFOut.Length == 0)
        {
            //换卡类型为自然损坏卡时
            if (selReasonType.SelectedValue == "13" || selReasonType.SelectedValue == "15")
            {
                DepositFee.Text = hiddenDepositFee.Value;
                CardcostFee.Text = hiddenCardcostFee.Value;
            }
            //换卡类型为人为损坏卡时
            else if (selReasonType.SelectedValue == "12" || selReasonType.SelectedValue == "14")
            {
                //选择卡押金
                if (Deposit.Checked == true)
                {
                    DepositFee.Text = (Convert.ToDecimal(hiddenDepositFee.Value) + Convert.ToDecimal(hidCardprice.Value) / 100).ToString("0.00");
                    CardcostFee.Text = hiddenCardcostFee.Value;
                }
                //选择卡费
                else if (Cardcost.Checked == true)
                {
                    DepositFee.Text = hiddenDepositFee.Value;
                    CardcostFee.Text = (Convert.ToDecimal(hiddenDepositFee.Value) + Convert.ToDecimal(hidCardprice.Value) / 100).ToString("0.00");
                }
            }
        }
        //老卡是司机卡
        else if (ddoTD_M_CALLINGSTAFFOut.Length > 0)
        {
            //换卡类型为自然损坏卡
            if (selReasonType.SelectedValue == "13" || selReasonType.SelectedValue == "15")
            {
                DepositFee.Text = hiddenDepositFee.Value;
                CardcostFee.Text = hiddenCardcostFee.Value;
            }
            //换卡类型为人为损坏卡
            else if (selReasonType.SelectedValue == "12" || selReasonType.SelectedValue == "14")
            {
                DepositFee.Text = hiddenDepositFee.Value;
                CardcostFee.Text = (Convert.ToDecimal(hidOldCardcost.Value) / 100).ToString("0.00");
            } 
        }
        ProcedureFee.Text = hidProcedureFee.Value;
        OtherFee.Text = hidOtherFee.Value;
        Total.Text = (Convert.ToDecimal(DepositFee.Text) + Convert.ToDecimal(CardcostFee.Text) + Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");

    }

    //更改押金类型时更新费用信息
    protected void Deposit_Changed(object sender, EventArgs e)
    {
        string change;
        if (Deposit.Checked == true)
        {
            change = CardcostFee.Text;
            CardcostFee.Text = DepositFee.Text;
            DepositFee.Text = change;
        }
    }

    //更改卡费用类型时,改变费用
    protected void Cardcost_Changed(object sender, EventArgs e)
    {
        string change;
        if ( Cardcost.Checked == true)
        {
            change = DepositFee.Text;
            DepositFee.Text = CardcostFee.Text;
            CardcostFee.Text = change;
        }
    }

    protected void Change_Click(object sender, EventArgs e)
    {
        //吴江B卡判断
        if (txtOCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("旧卡不是吴江B卡,不能在本业务界面操作");
            return;
        }
        
        //吴江B卡判断
        if (txtNCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("新卡不是吴江B卡,不能在本业务界面操作");
            return;
        }
        
        //判断售卡权限
        checkCardState(txtNCardno.Text);
        if (context.hasError()) return;

        if (txtRealRecv.Text == null)
        {
            context.AddError("A001001143");
            return;
        }

        TMTableModule tmTMTableModule = new TMTableModule();


        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtOCardno.Text;

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);

        if (ddoTF_F_CARDEWALLETACCOut == null)
        {
            context.AddError("A001008103");
            return;
        }

        //读取审核员工信息
        TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        //ddoTD_M_INSIDESTAFFIn.OPERCARDNO = hiddenCheck.Value;
        ddoTD_M_INSIDESTAFFIn.OPERCARDNO = context.s_CardID;

        TD_M_INSIDESTAFFTDO[] ddoTD_M_INSIDESTAFFOut = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_CHECK", null);

        SP_PB_ChangeCard_COMMITPDO pdo = new SP_PB_ChangeCard_COMMITPDO();
        //存储过程赋值
        pdo.ID = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
        //pdo.ID = hiddentradeno.Value + DateTime.Now.ToString("MMddhhmmss") + hiddenASn.Value.Substring(16, 4);
        pdo.CUSTRECTYPECODE = CUSTRECTYPECODE.Value;
        pdo.CARDCOST = Convert.ToInt32(Convert.ToDecimal(CardcostFee.Text) * 100);
        pdo.NEWCARDNO = txtNCardno.Text;
        pdo.OLDCARDNO = txtOCardno.Text;
        pdo.ONLINECARDTRADENO = hiddentradeno.Value;
        pdo.CHANGECODE = selReasonType.SelectedValue;
        pdo.ASN = hiddenAsn.Value.Substring(4, 16);
        pdo.CARDTYPECODE = hiddenLabCardtype.Value;
        pdo.SELLCHANNELCODE = "01";
        pdo.TRADETYPECODE = "03";
        pdo.PREMONEY = Convert.ToInt32(Convert.ToDecimal(NewcMoney.Text) * 100);
        pdo.TERMNO = "112233445566";
        pdo.OPERCARDNO = context.s_CardID;
        //最近卡充值实际余额为本次交易前卡内余额
        pdo.SUPPLYREALMONEY = 0; 
        //换卡类型为可读自然损坏卡
        if (selReasonType.SelectedValue == "13")
        {
            pdo.DEPOSIT = Convert.ToInt32(Convert.ToDecimal(ODeposit.Text) * 100);
            pdo.SERSTARTTIME = Convert.ToDateTime(SERSTARTIME.Value);
            pdo.SERVICEMONE = Convert.ToInt32(OSERVICEMOENY.Value);
            pdo.CARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;//可读卡换卡，卡对卡，账户对账户 wdx 20130730 Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.NEWSERSTAKETAG = SERTAKETAG.Value;
            //pdo.SUPPLYREALMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.TOTALSUPPLYMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;//可读卡换卡，卡对卡，账户对账户 wdx 20130730 Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.OLDDEPOSIT = Convert.ToInt32(Convert.ToDecimal(ODeposit.Text) * 100 - Convert.ToDecimal(OSERVICEMOENY.Value));
            pdo.SERSTAKETAG = "3";
            pdo.NEXTMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100 + Convert.ToDecimal(NewcMoney.Text) * 100);
            pdo.CURRENTMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.CHECKSTAFFNO = context.s_UserID;
            pdo.CHECKDEPARTNO = context.s_DepartID;
        }
        //换卡类型为可读人为损坏卡
        else if (selReasonType.SelectedValue == "12")
        {
            pdo.DEPOSIT = Convert.ToInt32(Convert.ToDecimal(DepositFee.Text)*100);
            pdo.SERSTARTTIME = DateTime.Now;
            pdo.SERVICEMONE = 0;
            pdo.CARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;//可读卡换卡，卡对卡，账户对账户 wdx 20130730 Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.NEWSERSTAKETAG = "0";
            //pdo.SUPPLYREALMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.TOTALSUPPLYMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;//可读卡换卡，卡对卡，账户对账户 wdx 20130730  Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.OLDDEPOSIT = 0;
            pdo.SERSTAKETAG = "2";
            pdo.NEXTMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100 + Convert.ToDecimal(NewcMoney.Text) * 100);
            pdo.CURRENTMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.CHECKSTAFFNO = context.s_UserID;
            pdo.CHECKDEPARTNO = context.s_DepartID;
        }
        //换卡类型为不可读人为损坏卡
        else if (selReasonType.SelectedValue == "14")
        {
            pdo.DEPOSIT = Convert.ToInt32(Convert.ToDecimal(DepositFee.Text) * 100);
            pdo.SERSTARTTIME = DateTime.Now;
            pdo.SERVICEMONE = 0;
            pdo.CARDACCMONEY = 0;
            pdo.NEWSERSTAKETAG = "0";
            //pdo.SUPPLYREALMONEY = 0;
            pdo.TOTALSUPPLYMONEY = 0;
            pdo.OLDDEPOSIT = 0;
            pdo.SERSTAKETAG = "2";
            pdo.NEXTMONEY = Convert.ToInt32(Convert.ToDecimal(NewcMoney.Text) * 100);
            pdo.CURRENTMONEY = Convert.ToInt32(Convert.ToDecimal(NewcMoney.Text) * 100);
            if (ddoTD_M_INSIDESTAFFOut == null || ddoTD_M_INSIDESTAFFOut.Length == 0)
            {
                context.AddError("A001010108");
                return;
            }
            pdo.CHECKSTAFFNO = ddoTD_M_INSIDESTAFFOut[0].STAFFNO;
            pdo.CHECKDEPARTNO = ddoTD_M_INSIDESTAFFOut[0].DEPARTNO;
        }
        //换卡类型为不可读自然损坏卡
        else if (selReasonType.SelectedValue == "15")
        {
            pdo.DEPOSIT = Convert.ToInt32(Convert.ToDecimal(ODeposit.Text) * 100);
            pdo.SERSTARTTIME = Convert.ToDateTime(SERSTARTIME.Value);
            pdo.SERVICEMONE = Convert.ToInt32(OSERVICEMOENY.Value);
            pdo.CARDACCMONEY = 0;
            pdo.NEWSERSTAKETAG = SERTAKETAG.Value;
            //pdo.SUPPLYREALMONEY = 0;
            pdo.TOTALSUPPLYMONEY = 0;
            pdo.OLDDEPOSIT = Convert.ToInt32(Convert.ToDecimal(ODeposit.Text) * 100 - Convert.ToDecimal(OSERVICEMOENY.Value));
            pdo.SERSTAKETAG = "3";
            pdo.NEXTMONEY = Convert.ToInt32(Convert.ToDecimal(NewcMoney.Text) * 100);
            pdo.CURRENTMONEY = Convert.ToInt32(Convert.ToDecimal(NewcMoney.Text) * 100);
            if (ddoTD_M_INSIDESTAFFOut == null || ddoTD_M_INSIDESTAFFOut.Length == 0)
            {
                context.AddError("A001010108");
                return;
            }
            pdo.CHECKSTAFFNO = ddoTD_M_INSIDESTAFFOut[0].STAFFNO;
            pdo.CHECKDEPARTNO = ddoTD_M_INSIDESTAFFOut[0].DEPARTNO;
        }

        //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据

        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
        ddoTF_F_CUSTOMERRECIn.CARDNO = txtOCardno.Text;

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
        hidCustname.Value = ddoTF_F_CUSTOMERRECOut.CUSTNAME;
        hidPaperno.Value = ddoTF_F_CUSTOMERRECOut.PAPERNO;

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


        hidSupplyMoney.Value = "" + pdo.CURRENTMONEY;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //AddMessage("M001004001");

            hidCardnoForCheck.Value = txtNCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致

            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                    "changeCard();", true);
            btnPrintPZ.Enabled = true;
            //btnPrintSJ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtOCardno.Text, hidCustname.Value, "换卡", "0.00"
                , DepositFee.Text, txtNCardno.Text, hidPaperno.Value, (Convert.ToDecimal(pdo.NEXTMONEY) / (Convert.ToDecimal(100))).ToString("0.00"),
                "", Total.Text, context.s_UserID, context.s_DepartName, hidPapertype.Value, ProcedureFee.Text, "0.00");

            ASHelper.prepareShouJu(ptnShouJu, txtNCardno.Text, context.s_UserName, (Convert.ToDecimal(pdo.DEPOSIT) / (Convert.ToDecimal(100))).ToString("0.00"));

            //foreach (Control con in this.Page.Controls)
            //{
            //    ClearControl(con);
            //}
            initLoad(sender, e);
            Change.Enabled = false;
        }
    }

    
}
