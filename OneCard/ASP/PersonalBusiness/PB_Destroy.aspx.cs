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
using TDO.CardManager;
using TDO.BusinessCode;
using TDO.PersonalTrade;
using TDO.UserManager;
using Common;
using Master;
using TM;
using TDO.BalanceChannel;
using PDO.PersonalBusiness;

public partial class ASP_PersonalBusiness_PB_Destroy : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            initLoad(sender, e);
        }

    }

    protected void initLoad(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从前台业务交易费用表中读取数据

        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "06";

        TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001001137", "TD_M_TRADEFEE", null);

        for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        {
            //费用类型为押金

            if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "00")
                CancelDepositFee.Text = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为充值

            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "01")
                hiddenCancelSupplyFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为维护费
            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "02")
                hiddenMaintenanceFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为手续费
            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "03")
                hiddenProcedureFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为其他费用

            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "99")
                hiddenOtherFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        }
        CancelSupplyFee.Text = hiddenCancelSupplyFee.Value;
        MaintenanceFee.Text = hiddenMaintenanceFee.Value;
        ProcedureFee.Text = hiddenProcedureFee.Value;
        OtherFee.Text = hiddenOtherFee.Value;
        Total.Text = (Convert.ToDecimal(CancelDepositFee.Text) + Convert.ToDecimal(hiddenCancelSupplyFee.Value) + Convert.ToDecimal(hiddenMaintenanceFee.Value) + Convert.ToDecimal(hiddenProcedureFee.Value) + Convert.ToDecimal(hiddenOtherFee.Value)).ToString("0.00");
        ReturnSupply.Text = Total.Text;
    }

    private Boolean DestroyDBreadValidation()
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

    protected void btnDestroyDBread_Click(object sender, EventArgs e)
    {
        //对卡号进行检验

        if (!DestroyDBreadValidation())
            return;

        TMTableModule tmTMTableModule = new TMTableModule();

        //从卡资料表(TF_F_CARDREC)中读取数据

        TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
        ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text.Trim();

        TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);
        if (ddoTF_F_CARDRECOut == null)
        {
            context.AddError("A001008103");
            return;
        }
        //从IC卡电子钱包帐户表(TF_F_CARDEWALLETACC)中读取数据

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text.Trim();

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);
        if (ddoTF_F_CARDEWALLETACCOut == null)
        {
            context.AddError("A001008103");
            return;
        }

        //从业务台帐主表(TF_B_TRADE)中读取数据

        TF_B_TRADETDO ddoTF_B_TRADEIn = new TF_B_TRADETDO();
        ddoTF_B_TRADEIn.CARDNO = txtCardno.Text.Trim();
        ddoTF_B_TRADEIn.TRADETYPECODE = "05";

        TF_B_TRADETDO ddoTF_B_TRADEOut = (TF_B_TRADETDO)tmTMTableModule.selByPK(context, ddoTF_B_TRADEIn, typeof(TF_B_TRADETDO), null, "TF_B_TRADE", null);
        if (ddoTF_B_TRADEOut == null)
        {
            context.AddError("A001008104");
            return;
        }

        //从退换卡原因编码表(TD_M_REASONTYPE)中读取数据

        TD_M_REASONTYPETDO ddoTD_M_REASONTYPEIn = new TD_M_REASONTYPETDO();
        ddoTD_M_REASONTYPEIn.REASONCODE = ddoTF_B_TRADEOut.REASONCODE;

        TD_M_REASONTYPETDO ddoTD_M_REASONTYPEOut = (TD_M_REASONTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_REASONTYPEIn, typeof(TD_M_REASONTYPETDO), null,"TD_M_REASONTYPE_Destroy",null);

        //从现金台帐主表(TF_B_TRADEFEE)中读取数据

        TF_B_TRADEFEETDO ddoTF_B_TRADEFEEIn = new TF_B_TRADEFEETDO();
        ddoTF_B_TRADEFEEIn.ID = ddoTF_B_TRADEOut.ID;

        TF_B_TRADEFEETDO ddoTF_B_TRADEFEEOut = (TF_B_TRADEFEETDO)tmTMTableModule.selByPK(context, ddoTF_B_TRADEFEEIn, typeof(TF_B_TRADEFEETDO), null, "TF_B_TRADEFEE_DESTROY", null);
        
        if (ddoTF_B_TRADEFEEOut == null )
        {
            context.AddError("A001008113");
            return;
        }
        
        //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据

        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
        ddoTF_F_CUSTOMERRECIn.CARDNO = txtCardno.Text.Trim();

        //UPDATE BY JIANGBB 2012-04-19解密
        DDOBase ddoBase = (DDOBase)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

        ddoBase = CommonHelper.AESDeEncrypt(ddoBase);
        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)ddoBase;
        //TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);
        if (ddoTF_F_CUSTOMERRECOut == null)
        {
            context.AddError("A001002111");
            return;
        }

        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据

        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = ddoTF_F_CARDRECOut.CARDTYPECODE;

        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

        //从证件类型编码表(TD_M_PAPERTYPE)中读取数据

        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
        ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);

        //从内部员工编码表(TD_M_INSIDESTAFF)中读取数据

        TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        ddoTD_M_INSIDESTAFFIn.STAFFNO = ddoTF_B_TRADEOut.OPERATESTAFFNO;

        TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFOut = (TD_M_INSIDESTAFFTDO)tmTMTableModule.selByPK(context, ddoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_Destroy", null);
       
        //给页面各显示项附值

        hiddenLabAsn.Value = ddoTF_F_CARDRECOut.ASN;
        hiddenCardtype.Value = ddoTF_F_CARDRECOut.CARDTYPECODE;
        LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
        Reasontype.Text = ddoTD_M_REASONTYPEOut.REASON;
        sDate.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");
        ReturnDate.Text = ddoTF_B_TRADEOut.OPERATETIME.ToString("yyyy-MM-dd");

        Decimal aMoney = Convert.ToDecimal(ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY);
        accMoney.Text = (aMoney / (Convert.ToDecimal(100))).ToString("0.00");

        //Double dMoney = Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT);
        Deposit.Text = (ddoTF_B_TRADEFEEOut.CARDDEPOSITFEE / (Convert.ToDecimal(100))).ToString("0.00");

        Decimal rMoney = Convert.ToDecimal(ddoTF_B_TRADEFEEOut.CARDDEPOSITFEE);
        ReturnDeposit.Text = (rMoney / (Convert.ToDecimal(100))).ToString("0.00");

        ReturnStaff.Text = ddoTD_M_INSIDESTAFFOut.STAFFNAME;
        CustName.Text = ddoTF_F_CUSTOMERRECOut.CUSTNAME;
        //性别赋值

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

        //修改合计费用信息
        Decimal backMoney = 0 - aMoney/100;
        CancelSupplyFee.Text = backMoney.ToString("0.00");
        Total.Text = (Convert.ToDecimal(CancelDepositFee.Text) + Convert.ToDecimal(hiddenCancelSupplyFee.Value) + 
            Convert.ToDecimal(hiddenMaintenanceFee.Value) + Convert.ToDecimal(hiddenProcedureFee.Value) + 
            Convert.ToDecimal(hiddenOtherFee.Value) + backMoney).ToString("0.00");
        ReturnSupply.Text = Total.Text;

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
            Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
            Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
        }

        //检验是否做过销户

        if (!DestroyExistValidation())
            return;

        btnDestroy.Enabled = true;
        btnPrintPZ.Enabled = false;

    }

    private Boolean DestroyDateValidation()
    {
        //String[] arr = (ReturnDate.Text).Split('-');
        DateTime rDate = Convert.ToDateTime(ReturnDate.Text);

        //检查是否超过7天

        if (rDate.AddDays(7)>DateTime.Now)
            context.AddError("A001008114");

        return !(context.hasError());
    }

    private Boolean DestroyExistValidation()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //检查是否已做过销户

        TF_B_TRADETDO ddoTF_B_TRADEIn = new TF_B_TRADETDO();

        string str = " Select CARDNO From TF_B_TRADE Where CARDNO = '" + txtCardno.Text + "' And TRADETYPECODE = '06' AND CANCELTAG = '0'";
        DataTable datastr = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, str, 0);

        if (datastr.Rows.Count != 0)
            context.AddError("A001008108");

        return !(context.hasError());
    }

    protected void btnDestroy_Click(object sender, EventArgs e)
    {
        //对输入卡号进行判断

        if (!DestroyDBreadValidation())
            return;
        //判断是否超过7天

        if (!DestroyDateValidation())
            return;

        //库内余额为负时,不能进行销户

        if (Convert.ToDecimal(ReturnSupply.Text) > 0)
        {
            context.AddError("A001008115");
            return;
        }
        SP_PB_DestroyPDO pdo = new SP_PB_DestroyPDO();
        //存储过程赋值

        pdo.ID = DealString.GetRecordID(txtCardno.Text.Substring(12, 4), txtCardno.Text);
        //pdo.ID = txtCardno.Text.Substring(12, 4) + DateTime.Now.ToString("MMddhhmmss") + txtCardno.Text.Substring(12, 4);
        pdo.CARDNO = txtCardno.Text.Trim();
        pdo.ASN = hiddenLabAsn.Value;
        pdo.CARDTYPECODE = hiddenCardtype.Value;
        pdo.CARDACCMONEY = Convert.ToInt32(Convert.ToDecimal(accMoney.Text) * 100);
        pdo.RDFUNDMONEY = Convert.ToInt32(Convert.ToDecimal(CancelSupplyFee.Text) * 100);

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M001008001");
            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, CustName.Text, "销户", CancelSupplyFee.Text,"0.00"
                , "", Paperno.Text, "", "", Total.Text, context.s_UserID, context.s_DepartName, Papertype.Text,
                ProcedureFee.Text, "0.00");

            if (chkPingzheng.Checked && btnPrintPZ.Enabled)
            {
                ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "printInvoice();", true);
            }

            //foreach (Control con in this.Page.Controls)
            //{
            //    ClearControl(con);
            //}
            initLoad(sender, e);
            btnDestroy.Enabled = false;
        }
    }
}
