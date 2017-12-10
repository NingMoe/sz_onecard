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

            //��ʼ����������
            ASHelper.setChangeReason(selReasonType, false);

            initLoad(sender, e);
            hidAccRecv.Value = Total.Text;
        }

    }

    protected void initLoad(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //��ǰ̨ҵ���׷��ñ��ж�ȡ�ۿ���������
        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "03";

        TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001004139", "TD_M_TRADEFEE", null);

        for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        {
            //��������ΪѺ��
            if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "00")
                hiddenDepositFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //��������Ϊ����
            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "10")
                hiddenCardcostFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //��������Ϊ������
            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "03")
                hidProcedureFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //��������Ϊ��������
            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "99")
                hidOtherFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        }
        //���ø�ֵ
        DepositFee.Text = hiddenDepositFee.Value;
        CardcostFee.Text = hiddenCardcostFee.Value;
        ProcedureFee.Text = hidProcedureFee.Value;
        OtherFee.Text = hidOtherFee.Value;
        Total.Text = (Convert.ToDecimal(DepositFee.Text) + Convert.ToDecimal(CardcostFee.Text) + Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");
        //����ѡ��ɼ�,Ѻ��ѡ��,���¿���ť������,������ť������
        Cardcost.Visible = false;
        Deposit.Checked = true;
        btnReadNCard.Enabled = false;
        Change.Enabled = false;
    }

    //�������͸ı�ʱ,�����Ͷ����ݿⰴť�Ƿ���øı�
    protected void selReasonType_SelectedIndexChanged(object sender, EventArgs e)
    {
        //foreach (Control con in this.Page.Controls)
        //{
        //    ClearControl(con);
        //}

        initLoad(sender, e);
        //��������Ϊ�ɶ���ʱ,�����ݿⰴť������,������ť����
        if (selReasonType.SelectedValue == "13" || selReasonType.SelectedValue == "12")
        {
            if (!context.s_Debugging) setReadOnly(txtOCardno);
            btnReadCard.Enabled = true;
            btnDBRead.Enabled = false;
            txtOCardno.CssClass = "labeltext";
        }
        //��������Ϊ���ɶ���ʱ,����������,�����ݿ����
        else if (selReasonType.SelectedValue == "14" || selReasonType.SelectedValue == "15")
        {
            txtOCardno.Attributes.Remove("readonly");
            btnReadCard.Enabled = false;
            btnDBRead.Enabled = true;
            txtOCardno.CssClass = "input";
        }
    }

    //�ж��Ƿ������,�������ʱ��ʾ���ѿ�Ѻ��ѡ��
    protected void GroupJudge(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        TF_F_CUST_ACCTTDO ddoTF_F_CUST_ACCTIn = new TF_F_CUST_ACCTTDO();
        ddoTF_F_CUST_ACCTIn.ICCARD_NO = txtOCardno.Text;
        TF_F_CUST_ACCTTDO ddoTF_F_CUST_ACCTOut = (TF_F_CUST_ACCTTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUST_ACCTIn, typeof(TF_F_CUST_ACCTTDO), null, "TF_F_CUST_ACCT", null);
        if (ddoTF_F_CUST_ACCTOut != null)
            Cardcost.Visible = true;

        //��������ɳ�ֵ�˻����ж�ȡ����
        //TF_F_CARDOFFERACCTDO ddoTF_F_CARDOFFERACCIn = new TF_F_CARDOFFERACCTDO();
        //ddoTF_F_CARDOFFERACCIn.CARDNO = txtOCardno.Text;
        //ddoTF_F_CARDOFFERACCIn.USETAG = "1";

        //TF_F_CARDOFFERACCTDO ddoTF_F_CARDOFFERACCOut = (TF_F_CARDOFFERACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDOFFERACCIn, typeof(TF_F_CARDOFFERACCTDO), null);

        //if (ddoTF_F_CARDOFFERACCOut != null)
        //    Cardcost.Visible = true;
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        //�⽭B���ж�
        if (txtOCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("�����⽭B��,�����ڱ�ҵ��������");
            return;
        }
        
        TMTableModule tmTMTableModule = new TMTableModule();

        //���˻���Ч�Լ���
        // txtOCardno.Text = hiddentxtCardno.Value;
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtOCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //��IC�����ϱ��ж�ȡ����
            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtOCardno.Text;
            
            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

            //���û�������(TL_R_ICUSER)�ж�ȡ����
            TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
            ddoTL_R_ICUSERIn.CARDNO = txtOCardno.Text;

            TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

            if (ddoTL_R_ICUSEROut == null)
            {
                context.AddError("A001001101");
                return;
            }

            //��ȡ�ɿ��ۿ���ʽ
            hidOSaletype.Value = ddoTL_R_ICUSEROut.SALETYPE;

            if (hidOSaletype.Value == "01")
            {
                context.AddError("�⽭B���������ѿ�����");
                return;
            }

            //����Դ״̬������ж�ȡ����
            TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEIn = new TD_M_RESOURCESTATETDO();
            ddoTD_M_RESOURCESTATEIn.RESSTATECODE = ddoTL_R_ICUSEROut.RESSTATECODE;

            TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEOut = (TD_M_RESOURCESTATETDO)tmTMTableModule.selByPK(context, ddoTD_M_RESOURCESTATEIn, typeof(TD_M_RESOURCESTATETDO), null, "TD_M_RESOURCESTATE", null);

            if (ddoTD_M_RESOURCESTATEOut == null)
                RESSTATE.Text = ddoTL_R_ICUSEROut.RESSTATECODE;
            else
                RESSTATE.Text = ddoTD_M_RESOURCESTATEOut.RESSTATE;

            //��ҳ����ʾ�ֵ
            hidOldCardcost.Value = ddoTF_F_CARDRECOut.CARDCOST.ToString();
            SERTAKETAG.Value = ddoTF_F_CARDRECOut.SERSTAKETAG;
            OSERVICEMOENY.Value = ddoTF_F_CARDRECOut.SERVICEMONEY.ToString();
            SERSTARTIME.Value = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString();
            CUSTRECTYPECODE.Value = ddoTF_F_CARDRECOut.CUSTRECTYPECODE;
            //txtOCardno.Text = hiddentxtCardno.Value;
            ODeposit.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT) / (Convert.ToDecimal(100))).ToString("0.00");
            OsDate.Text = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString("yyyy-MM-dd");
            OldcMoney.Text = (Convert.ToDecimal(hiddencMoney.Value) / (Convert.ToDecimal(100))).ToString("0.00");

            //��ѯ��Ƭ��ͨ���ܲ���ʾ
            PBHelper.openFunc(context, openFunc, txtOCardno.Text);

            hidCardnoForCheck.Value = txtOCardno.Text;//add by liuhe 20111104����д��ǰ��֤ҳ���ϵĿ��źͶ������ϵĿ��Ƿ�һ��

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
                AddMessage("�ɿ������ɹ�");
            }
            else
            {
                if (selReasonType.SelectedValue == "14" || selReasonType.SelectedValue == "15")
                {
                    AddMessage("�����ɹ�,����" + DateTime.Today.AddDays(7).ToString("yyyy-MM-dd") + "��������תֵҵ��!");
                }
                else
                {
                    AddMessage("ǰ̨д���ɹ�");
                }
                clearCustInfo(txtOCardno, txtNCardno);
            }
        }
        else if (hidWarning.Value == "writeFail")
        {
            context.AddError("ǰ̨д��ʧ��");
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
        hidCardnoForCheck.Value = "";//add by liuhe 20111104����д��ǰ��֤ҳ���ϵĿ��źͶ������ϵĿ��Ƿ�һ��
    }

    private Boolean DBreadValidation()
    {
        //�Կ��Ž��зǿա����ȡ����ּ���
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
        //�⽭B���ж�
        if (txtOCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("�����⽭B��,�����ڱ�ҵ��������");
            return;
        }
        
        //�����뿨�Ž��м���
        if (!DBreadValidation())
            return;

        TMTableModule tmTMTableModule = new TMTableModule();
        //���˻���Ч�Լ���
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtOCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //��IC�����ϱ��ж�ȡ����
            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtOCardno.Text;
           
            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

            //��IC������Ǯ���˻����ж�ȡ����
            TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
            ddoTF_F_CARDEWALLETACCIn.CARDNO = txtOCardno.Text;

            TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);

            //���û�������(TL_R_ICUSER)�ж�ȡ����
            TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
            ddoTL_R_ICUSERIn.CARDNO = txtOCardno.Text;

            TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

            if (ddoTL_R_ICUSEROut == null)
            {
                context.AddError("A001001101");
                return;
            }

            //��ȡ�ɿ��ۿ���ʽ
            hidOSaletype.Value = ddoTL_R_ICUSEROut.SALETYPE;

            if (hidOSaletype.Value == "01")
            {
                context.AddError("�⽭B���������ѿ�����");
                return;
            }

            //����Դ״̬������ж�ȡ����
            TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEIn = new TD_M_RESOURCESTATETDO();
            ddoTD_M_RESOURCESTATEIn.RESSTATECODE = ddoTL_R_ICUSEROut.RESSTATECODE;

            TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEOut = (TD_M_RESOURCESTATETDO)tmTMTableModule.selByPK(context, ddoTD_M_RESOURCESTATEIn, typeof(TD_M_RESOURCESTATETDO), null, "TD_M_RESOURCESTATE", null);

            if (ddoTD_M_RESOURCESTATEOut == null)
                RESSTATE.Text = ddoTL_R_ICUSEROut.RESSTATECODE;
            else
                RESSTATE.Text = ddoTD_M_RESOURCESTATEOut.RESSTATE;

            //��ҳ����ʾ�ֵ
            hidOldCardcost.Value = ddoTF_F_CARDRECOut.CARDCOST.ToString();
            hiddenAsn.Value = ddoTF_F_CARDRECOut.ASN;
            SERTAKETAG.Value = ddoTF_F_CARDRECOut.SERSTAKETAG;
            OSERVICEMOENY.Value = ddoTF_F_CARDRECOut.SERVICEMONEY.ToString();
            SERSTARTIME.Value = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString();
            CUSTRECTYPECODE.Value = ddoTF_F_CARDRECOut.CUSTRECTYPECODE;
            ODeposit.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT) / 100).ToString("0.00");
            OsDate.Text = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString("yyyy-MM-dd");
            OldcMoney.Text = (Convert.ToDecimal(ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY) / 100).ToString("0.00");

            //��ѯ��Ƭ��ͨ���ܲ���ʾ
            PBHelper.openFunc(context, openFunc, txtOCardno.Text);

            hiddentxtCardno.Value = txtOCardno.Text;
            GroupJudge(sender, e);

            //���¿���ť����
            btnReadNCard.Enabled = true;

            btnPrintPZ.Enabled = false;
            //btnPrintSJ.Enabled = false;
        }
    }

    protected void btnReadNCard_Click(object sender, EventArgs e)
    {
        //�⽭B���ж�
        if (txtNCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("�����⽭B��,�����ڱ�ҵ��������");
            return;
        }
       
        TMTableModule tmTMTableModule = new TMTableModule();

        //��IC�����ͱ����(TD_M_CARDTYPE)�ж�ȡ����
        // txtNCardno.Text = hiddentxtCardno.Value;
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;

        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

        //���û�������(TL_R_ICUSER)�ж�ȡ����
        TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
        ddoTL_R_ICUSERIn.CARDNO = txtNCardno.Text;

        TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

        if (ddoTL_R_ICUSEROut == null)
        {
            context.AddError("A001004128");
            return;
        }

        //��ȡ�ɿ��ۿ���ʽ
        hidSaletype.Value = ddoTL_R_ICUSEROut.SALETYPE;

        if (hidSaletype.Value == "01")
        {
            context.AddError("�⽭B��������������ѿ�");
            return;
        }

        //��ҳ����ʾ�ֵ
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

        //������ť����
        Change.Enabled = true;

        btnPrintPZ.Enabled = false;
        //btnPrintSJ.Enabled = false;
    }

    //���ݻ������ͺ�ѡ��Ѻ������ȷ������
    protected void FeeCount(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_CALLINGSTAFFTDO ddoTD_M_CALLINGSTAFFIn = new TD_M_CALLINGSTAFFTDO();
        ddoTD_M_CALLINGSTAFFIn.OPERCARDNO = txtOCardno.Text;
        TD_M_CALLINGSTAFFTDO[] ddoTD_M_CALLINGSTAFFOut = (TD_M_CALLINGSTAFFTDO[])tmTMTableModule.selByPKArr(context, 
            ddoTD_M_CALLINGSTAFFIn, typeof(TD_M_CALLINGSTAFFTDO),null, "TD_M_CALLINGSTAFF_BY_CARDNO", null);

        //�Ͽ�����˾����
        if (ddoTD_M_CALLINGSTAFFOut == null || ddoTD_M_CALLINGSTAFFOut.Length == 0)
        {
            //��������Ϊ��Ȼ�𻵿�ʱ
            if (selReasonType.SelectedValue == "13" || selReasonType.SelectedValue == "15")
            {
                DepositFee.Text = hiddenDepositFee.Value;
                CardcostFee.Text = hiddenCardcostFee.Value;
            }
            //��������Ϊ��Ϊ�𻵿�ʱ
            else if (selReasonType.SelectedValue == "12" || selReasonType.SelectedValue == "14")
            {
                //ѡ��Ѻ��
                if (Deposit.Checked == true)
                {
                    DepositFee.Text = (Convert.ToDecimal(hiddenDepositFee.Value) + Convert.ToDecimal(hidCardprice.Value) / 100).ToString("0.00");
                    CardcostFee.Text = hiddenCardcostFee.Value;
                }
                //ѡ�񿨷�
                else if (Cardcost.Checked == true)
                {
                    DepositFee.Text = hiddenDepositFee.Value;
                    CardcostFee.Text = (Convert.ToDecimal(hiddenDepositFee.Value) + Convert.ToDecimal(hidCardprice.Value) / 100).ToString("0.00");
                }
            }
        }
        //�Ͽ���˾����
        else if (ddoTD_M_CALLINGSTAFFOut.Length > 0)
        {
            //��������Ϊ��Ȼ�𻵿�
            if (selReasonType.SelectedValue == "13" || selReasonType.SelectedValue == "15")
            {
                DepositFee.Text = hiddenDepositFee.Value;
                CardcostFee.Text = hiddenCardcostFee.Value;
            }
            //��������Ϊ��Ϊ�𻵿�
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

    //����Ѻ������ʱ���·�����Ϣ
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

    //���Ŀ���������ʱ,�ı����
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
        //�⽭B���ж�
        if (txtOCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("�ɿ������⽭B��,�����ڱ�ҵ��������");
            return;
        }
        
        //�⽭B���ж�
        if (txtNCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("�¿������⽭B��,�����ڱ�ҵ��������");
            return;
        }
        
        //�ж��ۿ�Ȩ��
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

        //��ȡ���Ա����Ϣ
        TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        //ddoTD_M_INSIDESTAFFIn.OPERCARDNO = hiddenCheck.Value;
        ddoTD_M_INSIDESTAFFIn.OPERCARDNO = context.s_CardID;

        TD_M_INSIDESTAFFTDO[] ddoTD_M_INSIDESTAFFOut = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_CHECK", null);

        SP_PB_ChangeCard_COMMITPDO pdo = new SP_PB_ChangeCard_COMMITPDO();
        //�洢���̸�ֵ
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
        //�������ֵʵ�����Ϊ���ν���ǰ�������
        pdo.SUPPLYREALMONEY = 0; 
        //��������Ϊ�ɶ���Ȼ�𻵿�
        if (selReasonType.SelectedValue == "13")
        {
            pdo.DEPOSIT = Convert.ToInt32(Convert.ToDecimal(ODeposit.Text) * 100);
            pdo.SERSTARTTIME = Convert.ToDateTime(SERSTARTIME.Value);
            pdo.SERVICEMONE = Convert.ToInt32(OSERVICEMOENY.Value);
            pdo.CARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;//�ɶ������������Կ����˻����˻� wdx 20130730 Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.NEWSERSTAKETAG = SERTAKETAG.Value;
            //pdo.SUPPLYREALMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.TOTALSUPPLYMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;//�ɶ������������Կ����˻����˻� wdx 20130730 Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.OLDDEPOSIT = Convert.ToInt32(Convert.ToDecimal(ODeposit.Text) * 100 - Convert.ToDecimal(OSERVICEMOENY.Value));
            pdo.SERSTAKETAG = "3";
            pdo.NEXTMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100 + Convert.ToDecimal(NewcMoney.Text) * 100);
            pdo.CURRENTMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.CHECKSTAFFNO = context.s_UserID;
            pdo.CHECKDEPARTNO = context.s_DepartID;
        }
        //��������Ϊ�ɶ���Ϊ�𻵿�
        else if (selReasonType.SelectedValue == "12")
        {
            pdo.DEPOSIT = Convert.ToInt32(Convert.ToDecimal(DepositFee.Text)*100);
            pdo.SERSTARTTIME = DateTime.Now;
            pdo.SERVICEMONE = 0;
            pdo.CARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;//�ɶ������������Կ����˻����˻� wdx 20130730 Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.NEWSERSTAKETAG = "0";
            //pdo.SUPPLYREALMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.TOTALSUPPLYMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;//�ɶ������������Կ����˻����˻� wdx 20130730  Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.OLDDEPOSIT = 0;
            pdo.SERSTAKETAG = "2";
            pdo.NEXTMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100 + Convert.ToDecimal(NewcMoney.Text) * 100);
            pdo.CURRENTMONEY = Convert.ToInt32(Convert.ToDecimal(OldcMoney.Text) * 100);
            pdo.CHECKSTAFFNO = context.s_UserID;
            pdo.CHECKDEPARTNO = context.s_DepartID;
        }
        //��������Ϊ���ɶ���Ϊ�𻵿�
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
        //��������Ϊ���ɶ���Ȼ�𻵿�
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

        //�ӳֿ������ϱ�(TF_F_CUSTOMERREC)�ж�ȡ����

        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
        ddoTF_F_CUSTOMERRECIn.CARDNO = txtOCardno.Text;

        //UPDATE BY JIANGBB 2012-04-19����
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

        //��֤�����ͱ����(TD_M_PAPERTYPE)�ж�ȡ����

        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
        ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);

        //֤�����͸�ֵ

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

            hidCardnoForCheck.Value = txtNCardno.Text;//add by liuhe 20111104����д��ǰ��֤ҳ���ϵĿ��źͶ������ϵĿ��Ƿ�һ��

            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                    "changeCard();", true);
            btnPrintPZ.Enabled = true;
            //btnPrintSJ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtOCardno.Text, hidCustname.Value, "����", "0.00"
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
