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
using TDO.BusinessCode;
using TM;
using TDO.CardManager;
using PDO.PersonalBusiness;
using TDO.UserManager;
using TDO.ResourceManager;
using Master;

public partial class ASP_PersonalBusiness_PB_Unlock : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //btnUnlock.Attributes["onclick"] = "warnCheck()";
            
            LabAsn.Attributes["readonly"] = "true";
            LabCardtype.Attributes["readonly"] = "true";
            sDate.Attributes["readonly"] = "true";
            eDate.Attributes["readonly"] = "true";
            accMoney.Attributes["readonly"] = "true";
            txtRealRecv.Attributes["onfocus"] = "this.select();";
            txtRealRecv.Attributes["onkeyup"] = "realRecvChanging(this, 'test', 'hidAccRecv');";
            
            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";

            initLoad(sender, e);
            hidAccRecv.Value = Total.Text;
        }
    }

    protected void initLoad(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从前台业务交易费用表(TD_M_TRADEFEE)中读取数据

        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "07";

        TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001001137", "TD_M_TRADEFEE", null);

        for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        {
            //费用类型为手续费
            if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "03")
                hiddenProceFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为其他费用

            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "99")
                hidOtherFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        }

        ProcdFee.Text = hiddenProceFee.Value;
        OtherFee.Text = hidOtherFee.Value;
        Total.Text = (Convert.ToDecimal(ProcdFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");
        txtRealRecv.Text = Convert.ToInt32(Convert.ToDecimal(Total.Text)).ToString();
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //卡账户有效性检验

        context.SPOpen();
        context.AddField("p_CARDNO").Value = txtCardno.Text;

        bool ok = context.ExecuteSP("SP_Credit_Check");

        if (ok)
        {
            //从卡资料表(TF_F_CARDREC)中读取数据

            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text;

            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

            //从IC卡电子钱包帐户表(TF_F_CARDEWALLETACC)中读取数据

            TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
            ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text;

            TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);

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
                context.AddError("A001010106");
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

            if (ddoTF_F_CUSTOMERRECOut == null)
            {
                Papertype.Text = "";
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

            //页面显示项赋值

            hiddenCardtypecode.Value = ddoTF_F_CARDRECOut.CARDTYPECODE;
            LabAsn.Text = ddoTF_F_CARDRECOut.ASN;
            LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
            sDate.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");
            eDate.Text = ddoTF_F_CARDRECOut.VALIDENDDATE.Substring(0, 4) + "-" + ddoTF_F_CARDRECOut.VALIDENDDATE.Substring(4, 2) + "-" + ddoTF_F_CARDRECOut.VALIDENDDATE.Substring(6, 2);
            Decimal aMoney = Convert.ToDecimal(ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY);
            accMoney.Text = (aMoney / (Convert.ToDecimal(100))).ToString("0.00");

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
            else Papertype.Text = "";

            Paperno.Text = ddoTF_F_CUSTOMERRECOut.PAPERNO;
            Custaddr.Text = ddoTF_F_CUSTOMERRECOut.CUSTADDR;
            Custpost.Text = ddoTF_F_CUSTOMERRECOut.CUSTPOST;
            Custphone.Text = ddoTF_F_CUSTOMERRECOut.CUSTPHONE;
            txtEmail.Text = ddoTF_F_CUSTOMERRECOut.CUSTEMAIL;
            Remark.Text = ddoTF_F_CUSTOMERRECOut.REMARK;

            //查询卡片开通功能并显示
            PBHelper.openFunc(context, openFunc, txtCardno.Text);

            hidAccRecv.Value = Total.Text;
            txtRealRecv.Text = Convert.ToInt32(Convert.ToDecimal(Total.Text)).ToString();
            btnUnlock.Enabled = true;
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
            btnUnlock.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            AddMessage("前台写卡成功");
        }
        else if (hidWarning.Value == "writeFail")
        {
            context.AddError("前台写卡失败");
        }
        else if (hidWarning.Value == "submit")
        {
            btnUnlock_Click(sender, e);
        }
        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }
        hidWarning.Value = "";
    }

    protected void btnUnlock_Click(object sender, EventArgs e)
    {       
        TMTableModule tmTMTableModule = new TMTableModule();
        //查询审核员工信息
        TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        ddoTD_M_INSIDESTAFFIn.OPERCARDNO = hiddenCheck.Value;

        TD_M_INSIDESTAFFTDO[] ddoTD_M_INSIDESTAFFOut = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_CHECK", null);

        if (ddoTD_M_INSIDESTAFFOut == null || ddoTD_M_INSIDESTAFFOut.Length == 0)
        {
            context.AddError("A001010108");
            return;
        }

        SP_PB_UnlockPDO pdo = new SP_PB_UnlockPDO();
        //存储过程赋值

        pdo.CARDNO = txtCardno.Text;
        pdo.ASN = LabAsn.Text;
        pdo.CARDTYPECODE = hiddenCardtypecode.Value;
        pdo.CHECKSTAFFNO = ddoTD_M_INSIDESTAFFOut[0].STAFFNO;
        pdo.CHECKDEPARTNO = ddoTD_M_INSIDESTAFFOut[0].DEPARTNO;
        pdo.OPERCARDNO = context.s_CardID;
        
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //AddMessage("M001010001");
            hidCardReaderToken.Value = cardReader.createToken(context); 
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript","unlockCard();", true);

            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, CustName.Text, "解锁", "0.00"
                , "", "", Paperno.Text, "", "",
                Total.Text, context.s_UserID, context.s_DepartName, Papertype.Text, ProcdFee.Text, "0.00");

            //foreach (Control con in this.Page.Controls)
            //{
            //    ClearControl(con);
            //}
            initLoad(sender, e);
            btnUnlock.Enabled = false;
        }
    }
}
