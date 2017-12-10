using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TM;
using TDO.BusinessCode;
using TDO.CardManager;
using PDO.PersonalBusiness;
using TDO.ResourceManager;
using TDO.BalanceChannel;
using TDO.UserManager;
using PDO.CashGift;
using Common;
using Master;

public partial class ASP_CashGift_CG_CashGiftChange : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            // btnDBRead.Attributes["onclick"] = "warnCheck()";

            setReadOnly(OsDate, ODeposit, OldcMoney, LabRESSTATE, NsDate, NewcMoney, NDeposit, RESSTATE);

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
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "54";

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
        btnReadNCard.Enabled = false;
        Change.Enabled = false;
    }

    //换卡类型改变时,读卡和读数据库按钮是否可用改变
    protected void selReasonType_SelectedIndexChanged(object sender, EventArgs e)
    {
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

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        #region add by yin 20110104 添加对代理营业厅预付款的验证
        if (DeptBalunitHelper.ValdatePrepay(context) == false)
        {
            return;
        }
        #endregion 
        

        TMTableModule tmTMTableModule = new TMTableModule();
        txtOCardno.Text = hiddenCardno.Value;
        if (hiddenWallet2.Value != "10.00")
        {
            context.AddError("电子钱包账户不为10元,不能换卡");
            return;
        }

        //卡账户有效性检验
        checkCashGiftAccountInfo(txtOCardno.Text);

        if (!context.hasError())
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
            
            ODeposit.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT) / (Convert.ToDecimal(100))).ToString("0.00");
            OsDate.Text = hiddeneDate.Value;
            OldcMoney.Text = (Convert.ToDecimal(hiddencMoney.Value) / (Convert.ToDecimal(100))).ToString("0.00");

            hidCardnoForCheck.Value = txtOCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致

            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                "lockCard();", true);

            //btnReadNCard.Enabled = (hidWarning.Value.Length == 0);
            btnReadNCard.Enabled = true;

            btnPrintPZ.Enabled = false;
            btnPrintSJ.Enabled = false;

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

                    #region add by yin 20120104 添加对代理营业厅预付款的验证,扣费后如果超过预警额度则提示
                    int opMoney = Convert.ToInt32(Convert.ToDecimal(DepositFee.Text) * 100)
                        + Convert.ToInt32(Convert.ToDecimal(CardcostFee.Text) * 100)
                        + Convert.ToInt32((Convert.ToDecimal(ProcedureFee.Text)) * 100)
                        + Convert.ToInt32((Convert.ToDecimal(OtherFee.Text)) * 100);

                    DeptBalunitHelper.ValdatePrepay(context, opMoney, "1");
                    #endregion 
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

        if (chkPingzheng.Checked && btnPrintPZ.Enabled && chkShouju.Checked && btnPrintSJ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printAll();", true);
        }
        else if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }
        else if (chkShouju.Checked && btnPrintSJ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printShouJu();", true);
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

        //对输入卡号进行检验
        if (!DBreadValidation())
            return;

        #region add by yin 20110104 添加对代理营业厅预付款的验证
        if (DeptBalunitHelper.ValdatePrepay(context) == false)
        {
            return;
        }
        #endregion 

        TMTableModule tmTMTableModule = new TMTableModule();
        //卡账户有效性检验
        checkCashGiftAccountInfo(txtOCardno.Text);

        if (!context.hasError())
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
            if (ddoTF_F_CARDRECOut.DEPOSIT != ddoTL_R_ICUSEROut.CARDPRICE)
            {
                context.AddError("电子钱包2不为10元,不能换卡");
                return;
            }

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

            //给页面显示项赋值
            hidOldCardcost.Value = ddoTF_F_CARDRECOut.CARDCOST.ToString();
            hiddenASn.Value = ddoTF_F_CARDRECOut.ASN;
            SERTAKETAG.Value = ddoTF_F_CARDRECOut.SERSTAKETAG;
            OSERVICEMOENY.Value = ddoTF_F_CARDRECOut.SERVICEMONEY.ToString();
            SERSTARTIME.Value = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString();
            CUSTRECTYPECODE.Value = ddoTF_F_CARDRECOut.CUSTRECTYPECODE;
            ODeposit.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT) / 100).ToString("0.00");
            OsDate.Text = ddoTF_F_CARDRECOut.VALIDENDDATE;
            OldcMoney.Text = (Convert.ToDecimal(ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY) / 100 - Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT) / 100).ToString("0.00");

            //读新卡按钮可用
            btnReadNCard.Enabled = true;

            btnPrintPZ.Enabled = false;
            btnPrintSJ.Enabled = false;
        }
    }

    protected void btnReadNCard_Click(object sender, EventArgs e)
    {
        #region add by liuhe 20111231 添加对代理营业厅预付款的验证
        if (DeptBalunitHelper.ValdatePrepay(context) == false)
        {
            return;
        }
        #endregion 

        TMTableModule tmTMTableModule = new TMTableModule();
        txtNCardno.Text  = hiddenCardno.Value;
        
        //从用户卡库存表(TL_R_ICUSER)中读取数据
        TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
        ddoTL_R_ICUSERIn.CARDNO = txtNCardno.Text;
        
        TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);
        if (Convert.ToDecimal(hiddenWallet2.Value) * 100 != ddoTL_R_ICUSEROut.CARDPRICE)
        {
            context.AddError("电子钱包2不为10元,不能换卡");
            return;
        }

        if (ddoTL_R_ICUSEROut == null)
        {
            context.AddError("A001004128");
            return;
        }

        //从资源状态编码表中读取数据
        TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEIn = new TD_M_RESOURCESTATETDO();
        ddoTD_M_RESOURCESTATEIn.RESSTATECODE = ddoTL_R_ICUSEROut.RESSTATECODE;

        TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEOut = (TD_M_RESOURCESTATETDO)tmTMTableModule.selByPK(context, ddoTD_M_RESOURCESTATEIn, typeof(TD_M_RESOURCESTATETDO), null, "TD_M_RESOURCESTATE", null);

        if (ddoTD_M_RESOURCESTATEOut == null)
            LabRESSTATE.Text = ddoTL_R_ICUSEROut.RESSTATECODE;
        else
            LabRESSTATE.Text = ddoTD_M_RESOURCESTATEOut.RESSTATE;

        //给页面显示项赋值
        hidCardprice.Value = ddoTL_R_ICUSEROut.CARDPRICE.ToString();
        NDeposit.Text = (Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE) / 100).ToString("0.00");
        NsDate.Text = hiddeneDate.Value;
        NewcMoney.Text = (Convert.ToDecimal(hiddencMoney.Value) / 100).ToString("0.00");

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
        btnPrintSJ.Enabled = false;
    }

    //根据换卡类型和选择押金类型确定费用
    protected void FeeCount(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        
        //换卡类型为自然损坏卡时
        if (selReasonType.SelectedValue == "13" || selReasonType.SelectedValue == "15")
        {
            DepositFee.Text = hiddenDepositFee.Value;
            CardcostFee.Text = hiddenCardcostFee.Value;
        }
        //换卡类型为人为损坏卡时
        else
        {
            DepositFee.Text = (Convert.ToDecimal(hiddenDepositFee.Value) + Convert.ToDecimal(hidCardprice.Value) / 100).ToString("0.00");
            CardcostFee.Text = hiddenCardcostFee.Value;
        }
        
        ProcedureFee.Text = hidProcedureFee.Value;
        OtherFee.Text = hidOtherFee.Value;
        Total.Text = (Convert.ToDecimal(DepositFee.Text) + Convert.ToDecimal(CardcostFee.Text) + Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");

    }

    protected void Change_Click(object sender, EventArgs e)
    {
        //判断售卡权限
        checkCardState(txtNCardno.Text);
        if (context.hasError()) return;

        if (txtRealRecv.Text == null)
        {
            context.AddError("A001001143");
            return;
        }

        #region add by yin 20120104 添加对代理营业厅预付款的验证,提交前如果扣费后不足最低额度则返回
        int opMoney = Convert.ToInt32(Convert.ToDecimal(DepositFee.Text) * 100)
                    + Convert.ToInt32(Convert.ToDecimal(CardcostFee.Text) * 100)
                    + Convert.ToInt32((Convert.ToDecimal(ProcedureFee.Text)) * 100)
                    + Convert.ToInt32((Convert.ToDecimal(OtherFee.Text)) * 100);
        if (DeptBalunitHelper.ValdatePrepay(context, opMoney, "2") == false)
        {
            return;
        }
        #endregion 

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
        ddoTD_M_INSIDESTAFFIn.OPERCARDNO = hiddenCheck.Value;

        TD_M_INSIDESTAFFTDO[] ddoTD_M_INSIDESTAFFOut = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_CHECK", null);

        SP_CG_ChangeCardPDO pdo = new SP_CG_ChangeCardPDO();
        //存储过程赋值
        pdo.ID = DealString.GetRecordID(hiddentradeno.Value, hiddenASn.Value);
        pdo.CUSTRECTYPECODE = CUSTRECTYPECODE.Value;
        pdo.CARDCOST = Convert.ToInt32(hidOldCardcost.Value);
        pdo.NEWCARDNO = txtNCardno.Text;
        pdo.OLDCARDNO = txtOCardno.Text;
        pdo.ONLINECARDTRADENO = hiddentradeno.Value;
        pdo.CHANGECODE = selReasonType.SelectedValue;
        pdo.ASN = hiddenASn.Value.Substring(4, 16);
        pdo.CARDTYPECODE = txtNCardno.Text.Substring(4, 2);
        pdo.SELLCHANNELCODE = "01";
        pdo.TRADETYPECODE = "54";
        pdo.PREMONEY = Convert.ToInt32(Convert.ToDecimal(NewcMoney.Text) * 100);
        pdo.SERSTARTTIME = Convert.ToDateTime(SERSTARTIME.Value);
        pdo.TERMNO = "112233445566";
        pdo.OPERCARDNO = context.s_CardID;
        pdo.SERSTAKETAG = "6";
        pdo.NEWSERSTAKETAG = "5";
        pdo.DEPOSIT = Convert.ToInt32(Convert.ToDecimal(NDeposit.Text) * 100);
        pdo.SERVICEMONE = 0;

        //最近卡充值实际余额为本次交易前卡内余额
        pdo.SUPPLYREALMONEY = 0;

        //换卡类型为可读自然损坏卡
        if (selReasonType.SelectedValue == "13")
        {
            pdo.CARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;//可读卡换卡，卡对卡，账户对账户 wdx 20130729 Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.TOTALSUPPLYMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;//可读卡换卡，卡对卡，账户对账户 wdx 20130729 Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.OLDDEPOSIT = Convert.ToInt32(Convert.ToDecimal(ODeposit.Text) * 100 - Convert.ToDecimal(OSERVICEMOENY.Value));        
            pdo.NEXTMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100 + Convert.ToDecimal(NewcMoney.Text) * 100);
            pdo.CURRENTMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.CHECKSTAFFNO = context.s_UserID;
            pdo.CHECKDEPARTNO = context.s_DepartID;
        }
        //换卡类型为可读人为损坏卡
        else if (selReasonType.SelectedValue == "12")
        {
            pdo.CARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;//可读卡换卡，卡对卡，账户对账户 wdx 20130729 Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.TOTALSUPPLYMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;//可读卡换卡，卡对卡，账户对账户 wdx 20130729 Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.OLDDEPOSIT = 0;
            pdo.NEXTMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100 + Convert.ToDecimal(NewcMoney.Text) * 100);
            pdo.CURRENTMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.CHECKSTAFFNO = context.s_UserID;
            pdo.CHECKDEPARTNO = context.s_DepartID;
        }
        //换卡类型为不可读人为损坏卡
        else if (selReasonType.SelectedValue == "14")
        {
            pdo.CARDACCMONEY = 0;
           
            pdo.TOTALSUPPLYMONEY = 0;
            pdo.OLDDEPOSIT = 0;
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
            pdo.CARDACCMONEY = 0;
            pdo.TOTALSUPPLYMONEY = 0;
            pdo.OLDDEPOSIT = Convert.ToInt32(Convert.ToDecimal(ODeposit.Text) * 100 - Convert.ToDecimal(OSERVICEMOENY.Value));
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

        string writeCardScript = "startCashGiftCard('" + DateTime.Now.ToString("yyyyMMdd")
                + "', '20500101', " + (pdo.CURRENTMONEY > 0 ? pdo.CURRENTMONEY : 0)
                + ");";

        pdo.writeCardScript = writeCardScript;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            hidCardnoForCheck.Value = txtNCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致
            //AddMessage("M001004001");
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript", writeCardScript, true);

            btnPrintPZ.Enabled = true;
            btnPrintSJ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtOCardno.Text, hidCustname.Value, "利金卡换卡", "0.00"
                , DepositFee.Text, txtNCardno.Text, hidPaperno.Value, (Convert.ToDecimal(pdo.NEXTMONEY) / (Convert.ToDecimal(100))).ToString("0.00"),
                "", Total.Text, context.s_UserID, context.s_DepartName, hidPapertype.Value, ProcedureFee.Text, "0.00");

            ASHelper.prepareShouJu(ptnShouJu, txtNCardno.Text, context.s_UserName, (Convert.ToDecimal(pdo.DEPOSIT) / (Convert.ToDecimal(100))).ToString("0.00"));

            initLoad(sender, e);
            Change.Enabled = false;
        }
    }


}