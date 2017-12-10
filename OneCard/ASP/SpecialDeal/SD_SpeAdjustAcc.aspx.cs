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
using PDO.PersonalBusiness;
using TDO.CardManager;
using TDO.PersonalTrade;
using TDO.BalanceChannel;
using TDO.UserManager;
using PDO.SpecialDeal;
using Common;
using TDO.ResourceManager;
using Master;

public partial class ASP_SpecialDeal_SD_SpeAdjustAcc : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //�������,�����ܶ�ɸ���
            txtCurrMoney.Attributes.Add("readonly", "true");
            txtAdjustMoney.Attributes.Add("readonly", "true");

            //��ʾ������ϸ��Ϣ�б�
            showAdjustAcc();

            //��ʼ����ӡƾ֤������
            btnPrintPZ.Enabled = false;

            //��ʼ�����ʰ�ť������
            btnAdjustAcc.Enabled = false;

            //����ģʽ�¿��ſ�����
            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";
        }

    }

    private void showAdjustAcc()
    {
        //��ʾ������ϸ��Ϣ�б�
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }


    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //���˻���Ч�Լ���


        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //����Чʱ
            //�����˿�����������ȡ�ɿ�����
            string cardNO = "";
            ArrayList list = new ArrayList();
            cardNO = txtCardno.Text;
            list.Add(cardNO);
            while (true)
            {
                TF_B_TRADETDO tdoTF_B_TRADEIn = new TF_B_TRADETDO();
                tdoTF_B_TRADEIn.CARDNO = cardNO;
                TF_B_TRADETDO tdoTF_B_TRADEOut = (TF_B_TRADETDO)tmTMTableModule.selByPK(context, tdoTF_B_TRADEIn, typeof(TF_B_TRADETDO), null, "TF_B_TRADE_QUERYOLDCARDNOBYCARDNO", null);

                if (tdoTF_B_TRADEOut != null && tdoTF_B_TRADEOut.OLDCARDNO != null)
                {
                    // ���ɶ���������Ҫ�����,�Ѳ��ܵ��˵ľɿ����˵�
                    //if ((tdoTF_B_TRADEOut.REASONCODE=="14"||tdoTF_B_TRADEOut.REASONCODE=="15")&& tdoTF_B_TRADEOut.OPERATETIME.AddDays(7) >= DateTime.Now)
                    //{
                    //    context.AddMessage("���ţ�" + tdoTF_B_TRADEOut.OLDCARDNO + "������7����ܵ��ˣ�");
                    //    cardNO = tdoTF_B_TRADEOut.OLDCARDNO;
                    //    continue;
                    //}
                    cardNO = tdoTF_B_TRADEOut.OLDCARDNO;
                    list.Add(cardNO);
                }
                else
                {
                    break;
                }
            }

            //��ȡ������ʿɳ�ֵ�˻���(TF_SPEADJUSTOFFERACC)�п��ĵ�����Ϣ
            int totalAdjustMoney = 0;
            for (int i = 0; i < list.Count; i++)
            {
                TF_SPEADJUSTOFFERACCTDO tdoAdjAccIn = new TF_SPEADJUSTOFFERACCTDO();
                tdoAdjAccIn.CARDNO = list[i].ToString();

                TF_SPEADJUSTOFFERACCTDO tdoAdjAccOut = (TF_SPEADJUSTOFFERACCTDO)tmTMTableModule.selByPK(context, tdoAdjAccIn, typeof(TF_SPEADJUSTOFFERACCTDO), null, "TF_SPEADJUSTOFFERACC_BYCARDNO", null);

                //û�е�����Ϣʱ

                if (tdoAdjAccOut == null || tdoAdjAccOut.OFFERMONEY <= 0)
                {
                    continue;
                }
                totalAdjustMoney += tdoAdjAccOut.OFFERMONEY;
            }

            if (totalAdjustMoney <= 0)
            {
                ClearAdjustInfo();
                context.AddError("A009113102");
                return;
            }
            //��ʾ�������
            txtCurrMoney.Text = (Convert.ToDecimal(hiddencMoney.Value) / 100).ToString("0.00");

            //��ʾ�����ܶ�
            hidAdjustMoney.Value = totalAdjustMoney.ToString();

            txtAdjustMoney.Text = (Convert.ToDecimal(totalAdjustMoney) / 100).ToString("0.00");

            //��ѯ������ϸ����ʾ��Ϣ

            //gvResult.DataSource = QueryResultColl();
            gvResult.DataSource = QueryResultColl(list);
            gvResult.DataBind();

            //��Ƭ���������ж�
            TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
            ddoTF_F_CUSTOMERRECIn.CARDNO = txtCardno.Text;
            DDOBase ddoBase = (DDOBase)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);
            ddoBase = CommonHelper.AESDeEncrypt(ddoBase);
            TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)ddoBase;
            if (!string.IsNullOrEmpty(ddoTF_F_CUSTOMERRECOut.CUSTNAME) && !string.IsNullOrEmpty(ddoTF_F_CUSTOMERRECOut.PAPERNO))
            {
                hidIsJiMing.Value = "1";                
            }
            else
            {
                string cardNo = txtCardno.Text;
                string sql = string.Format("select count(*) from tf_f_cust_acct A where A.state!='X' and A.ICCARD_NO='{0}'", cardNo);
                TMTableModule tmTMTableModule1 = new TMTableModule();
                DataTable dt = tmTMTableModule1.selByPKDataTable(context, sql, 0);
                Object obj = dt.Rows[0].ItemArray[0];
                if (Convert.ToInt32(obj) > 0) //��ͨר���˻����ܵģ���ר���˻�������Ч��
                {
                    hidIsJiMing.Value = "1";
                }
                else
                {
                    hidIsJiMing.Value = "0";
                }
            }
            //���õ��ʴ���ť
            btnAdjustAcc.Enabled = true;
            btnAdjustSale.Enabled = false;
        }

        else
        {
            //��ս�����Ϣ
            ClearAdjustInfo();
        }

    }


    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        //��ҳ���� 
        gvResult.PageIndex = e.NewPageIndex;

        btnReadCard_Click(sender, e);

    }



    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
    }


    //public ICollection QueryResultColl()
    //{
    //    //���������̨�ʱ�(TF_B_SPEADJUSTACC)�ж�ȡ����

    //    DataTable data = SPHelper.callSDQuery(context, "SpeAdjustAcc", txtCardno.Text);
    //    return new DataView(data);
    //}

    public ICollection QueryResultColl(ArrayList list)
    {
        //���������̨�ʱ�(TF_B_SPEADJUSTACC)�ж�ȡ����

        TMTableModule tmTMTableModule = new TMTableModule();
        TF_B_SPEADJUSTACCTDO tdoTF_B_SPEADJUSTACCIn = new TF_B_SPEADJUSTACCTDO();
        string strSql = "select " +
                         " tf.CARDNO ����,tf.CALLINGNO || ':' || tno.CALLING ��ҵ,tf.CORPNO || ':' || tp.CORP ��λ,tf.DEPARTNO || ':' || tt.DEPART ����," +
                         " tf.TRADEDATE ��������, tf.TRADEMONEY/100.0 ���ף�,tf.REFUNDMENT/100.0 ���ˣ�,tf.CHECKSTAFFNO || ':' || ti.STAFFNAME �����," +
                         " tf.CHECKTIME ���ʱ��," +
                         " (case when (tf.REASONCODE = '1') then '�����˻�' " +
                         " when (tf.REASONCODE = '2') then '���׳ɹ�,ǩ����δ��ӡ'" +
                         " when (tf.REASONCODE = '3') then '���ײ��ɹ�,�ۿ�'" +
                         " when (tf.REASONCODE = '4') then '��ˢ���'" +
                         " when (tf.REASONCODE = '5') then '����' end) ����ԭ��" +
                         " FROM  TF_B_SPEADJUSTACC tf, TD_M_CALLINGNO tno, TD_M_CORP tp,TD_M_DEPART tt, TD_M_INSIDESTAFF ti";
        ArrayList wherelist = new ArrayList();
        wherelist.Add("tf.TRADETYPECODE = '97'");
        wherelist.Add("tf.STATECODE = '1'");
        wherelist.Add("tf.CALLINGNO = tno.CALLINGNO(+)");
        wherelist.Add("tf.CORPNO = tp.CORPNO(+)");
        wherelist.Add("tf.DEPARTNO = tt.DEPARTNO(+)");
        wherelist.Add("tf.CHECKSTAFFNO = ti.STAFFNO(+)");
        string whereCardNo = "tf.CARDNO IN (";
        for (int i = 0; i < list.Count; i++)
        {
            whereCardNo += "'" + list[i].ToString() + "',";
        }
        whereCardNo = whereCardNo.TrimEnd(',');
        whereCardNo += ")";
        wherelist.Add(whereCardNo);
        strSql += DealString.ListToWhereStr(wherelist);

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTF_B_SPEADJUSTACCIn, null, strSql, 0);

        return new DataView(data);
    }

    private bool AdjustAccValidation()
    {
        //�Կ��ŷǿյ�У��
        txtCardno.Text = txtCardno.Text.Trim();
        if (txtCardno.Text == "")
            context.AddError("A009113001", txtCardno);

        //�Ե����ܶ�ǿյ�У��

        else if (txtAdjustMoney.Text.Trim() == "")
            context.AddError("A009113002", txtAdjustMoney);

        //��⿨�����ӵ����ܶ��Ƿ񳬹�����
        else if (Convert.ToChar(hidIsJiMing.Value) == '0' && Convert.ToDecimal(txtCurrMoney.Text)+ Convert.ToDecimal(txtAdjustMoney.Text) > 1000)
            context.AddError("���������ϵ����ܶ�ܳ���1ǧԪ,����ʧ�ܡ�");
        else if (Convert.ToChar(hidIsJiMing.Value) == '1' && Convert.ToDecimal(txtCurrMoney.Text) + Convert.ToDecimal(txtAdjustMoney.Text) > 5000)
            context.AddError("���������ϵ����ܶ�ܳ���5ǧԪ,����ʧ�ܡ�");

        return context.hasError();

    }

    private bool RecordIntoTmp(ArrayList list)
    {
        //���ռ�¼����ʱ��
        context.DBOpen("Insert");

        int count = 0;
        int tradeid = 100001;
        int iRefundMoney = 0;
        for (int i = 0; i < list.Count; i++)
        {
            ++count;
            context.ExecuteNonQuery("insert into TMP_ADJUSTACC_IMP values('" + tradeid.ToString() + "','" + list[i].ToString() + "'," + iRefundMoney + ",'" + Session.SessionID + "')");
            tradeid++;
        }

        context.DBCommit();

        // û�в����κο��ż�¼�򷵻ش���

        if (count <= 0)
        {
            context.AddError("A009113104:û�п��ż�¼");
            return false;
        }

        return true;
    }

    private void clearTempTable()//�����ʱ��
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_ADJUSTACC_IMP where SESSIONID='"
            + Session.SessionID + "'");
        context.ExecuteNonQuery("delete from TMP_ADJUSTACC_IMP where SESSIONID='"
                    + Session.SessionID + "'");
        context.DBCommit();
    }

    protected void btnAdjustAcc_Click(object sender, EventArgs e)
    {
        //���õ��˵��жϴ���

        if (AdjustAccValidation()) return;

        TMTableModule tmTMTableModule = new TMTableModule();

        //��������������ڼ����ޱ������
        string cardNO = "";
        ArrayList list = new ArrayList();
        cardNO = txtCardno.Text;
        while (true)
        {
            list.Add(cardNO);
            TF_B_TRADETDO tdoTF_B_TRADEIn = new TF_B_TRADETDO();
            tdoTF_B_TRADEIn.CARDNO = cardNO;
            TF_B_TRADETDO tdoTF_B_TRADEOut = (TF_B_TRADETDO)tmTMTableModule.selByPK(context, tdoTF_B_TRADEIn, typeof(TF_B_TRADETDO), null, "TF_B_TRADE_QUERYOLDCARDNOBYCARDNO", null);
            if (tdoTF_B_TRADEOut != null && tdoTF_B_TRADEOut.OLDCARDNO != null)
            {
                cardNO = tdoTF_B_TRADEOut.OLDCARDNO;
            }
            else
            {
                break;
            }
        }

        //��ȡ������ʿɳ�ֵ�˻���(TF_SPEADJUSTOFFERACC)�п��ĵ�����Ϣ
        int totalAdjustMoney = 0;
        for (int i = 0; i < list.Count; i++)
        {
            TF_SPEADJUSTOFFERACCTDO tdoAdjAccIn = new TF_SPEADJUSTOFFERACCTDO();
            tdoAdjAccIn.CARDNO = list[i].ToString();

            TF_SPEADJUSTOFFERACCTDO tdoAdjAccOut = (TF_SPEADJUSTOFFERACCTDO)tmTMTableModule.selByPK(context, tdoAdjAccIn, typeof(TF_SPEADJUSTOFFERACCTDO), null, "TF_SPEADJUSTOFFERACC_BYCARDNO", null);

            //û�е�����Ϣʱ

            if (tdoAdjAccOut == null || tdoAdjAccOut.OFFERMONEY <= 0)
            {
                continue;
            }
            totalAdjustMoney += tdoAdjAccOut.OFFERMONEY;
        }

        if (totalAdjustMoney <= 0 || totalAdjustMoney != Convert.ToInt32(hidAdjustMoney.Value))
        {
            ClearAdjustInfo();
            context.AddError("A009113103:�����ܶ�����");
            return;
        }

        //�����ʱ��
        clearTempTable();

        //��������ʱ��
        if (!RecordIntoTmp(list)) return;

        //��IC������Ǯ���˻����ж�ȡ����

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text;
        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null, "TF_F_CARDEWALLETACC", null);

        //���õ��˵��жϴ���

        SP_SD_SpeAdjustAccPDO pdo = new SP_SD_SpeAdjustAccPDO();

        //���ɼ�¼��ˮ��

        pdo.ID = hiddentradeno.Value + DateTime.Now.ToString("MMddhhmmss") + hiddenAsn.Value.Substring(12, 4);
        pdo.CARDNO = txtCardno.Text;
        pdo.CARDTRADENO = hiddentradeno.Value;

        pdo.CARDMONEY = Convert.ToInt32(hiddencMoney.Value);

        pdo.CARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;

        pdo.ASN = hiddenAsn.Value.Substring(4, 16);
        pdo.CARDTYPECODE = hiddenLabCardtype.Value;
        pdo.TRADETYPECODE = "98";    //������ʳ�ֵ

        pdo.TERMNO = "112233445566"; //�ն˺Ź̶�Ϊ112233445566

        pdo.ADJUSTMONEY = Convert.ToInt32(hidAdjustMoney.Value); //�����ܶ�

        string strAdjustMoney = (Convert.ToDecimal(pdo.ADJUSTMONEY) / 100).ToString("0.00");

        pdo.OPERCARDNO = context.s_CardID; //����Ա����
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            hidSupplyMoney.Value = "" + pdo.ADJUSTMONEY;

            string strIcBalance = (Convert.ToDecimal(pdo.CARDMONEY + pdo.ADJUSTMONEY) / 100).ToString("0.00");

            hidCardnoForCheck.Value = txtCardno.Text;//add by liuhe 20111104����д��ǰ��֤ҳ���ϵĿ��źͶ������ϵĿ��Ƿ�һ��

            //��ֵд��Ƭ��Ϣ
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                 "writeCardScript", "chargeCard();", true);

            btnPrintPZ.Enabled = true;

            //��ȡIC�û�������, ֤������, ֤������
            GetCustInfo();

            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, hidCustName.Value, "��ֵ", strAdjustMoney
                , "", "", hidPaperNo.Value, strIcBalance, "",
                strAdjustMoney, context.s_UserID, context.s_DepartName, hidPaperType.Value, "0.00", "");

            //��ӡ��ť����
            //btnPrintPZ.Enabled = true;

            //���ʰ�ť������
            btnAdjustAcc.Enabled = false;
        }

        //�����Ϣ
        //ClearAdjustInfo();
    }

    private void ClearAdjustInfo()
    {
        txtCardno.Text = "";
        //�������
        txtCurrMoney.Text = "";

        //��յ����ܶ�
        txtAdjustMoney.Text = "";

        //��ʾ������ϸ��Ϣ�б�
        showAdjustAcc();
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")
        {
            btnAdjustAcc.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            AddMessage("M009113201");
        }
        else if (hidWarning.Value == "writeFail")
        {
            context.AddError("A009113202");
        }
        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }
        hidWarning.Value = "";
        hidCardnoForCheck.Value = "";//add by liuhe 20111104����д��ǰ��֤ҳ���ϵĿ��źͶ������ϵĿ��Ƿ�һ��
    }

    private void GetCustInfo()
    {
        //ȡ��IC���û�������,֤������,֤������
        TF_F_CUSTOMERRECTDO ddoIn = new TF_F_CUSTOMERRECTDO();
        ddoIn.CARDNO = txtCardno.Text;
        TMTableModule tmTMTableModule = new TMTableModule();

        //TF_F_CUSTOMERRECTDO ddoOut = (TF_F_CUSTOMERRECTDO)tmTMTableModule.selByPK(context, ddoIn,
        //    typeof(TF_F_CUSTOMERRECTDO), null, "TF_F_CUSTOMERREC_QUERY_BYCARDNO", null);

        //add by jiangbb ����
        DDOBase ddoBase = (DDOBase)tmTMTableModule.selByPK(context, ddoIn, typeof(TF_F_CUSTOMERRECTDO), null, "TF_F_CUSTOMERREC_QUERY_BYCARDNO", null);
        ddoBase = CommonHelper.AESDeEncrypt(ddoBase);
        TF_F_CUSTOMERRECTDO ddoOut = (TF_F_CUSTOMERRECTDO)ddoBase;
        hidPaperNo.Value = ddoOut.PAPERNO;
        hidCustName.Value = ddoOut.CUSTNAME;

        //��ѯ֤�����ʹ����Ӧ��֤����������

        string paperTypeSql = "select PAPERTYPENAME from TD_M_PAPERTYPE where PAPERTYPECODE ='" + ddoOut.PAPERNO + "'";

        DataTable data = tm.selByPKDataTable(context, paperTypeSql, 0);
        if (data != null && data.Rows.Count != 0)
        {
            Object[] row = data.Rows[0].ItemArray;
            hidPaperType.Value = getCellValue(row[0]);
        }
    }

    private string getCellValue(Object obj)
    {
        return (obj == DBNull.Value ? "" : ((string)obj).Trim());
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //�����뿨�Ž��м���
        if (!DBreadValidation())
            return;

        TMTableModule tmTMTableModule = new TMTableModule();
        //��ȡ������ʿɳ�ֵ�˻���(TF_SPEADJUSTOFFERACC)�п��ĵ�����Ϣ

        TF_SPEADJUSTOFFERACCTDO tdoAdjAccIn = new TF_SPEADJUSTOFFERACCTDO();
        tdoAdjAccIn.CARDNO = txtCashGiftCardno.Text;

        TF_SPEADJUSTOFFERACCTDO tdoAdjAccOut = (TF_SPEADJUSTOFFERACCTDO)tmTMTableModule.selByPK(context, tdoAdjAccIn, typeof(TF_SPEADJUSTOFFERACCTDO), null, "TF_SPEADJUSTOFFERACC_BYCARDNO", null);

        //û�е�����Ϣʱ

        if (tdoAdjAccOut == null || tdoAdjAccOut.OFFERMONEY <= 0)
        {
            ClearAdjustInfo();
            context.AddError("A009113102");
            return;
        }

        //��ʾ�����ܶ�
        hidAdjustMoney.Value = tdoAdjAccOut.OFFERMONEY.ToString();

        txtAdjustMoney.Text = (Convert.ToDecimal(tdoAdjAccOut.OFFERMONEY) / 100).ToString("0.00");

        //��ѯ������ϸ����ʾ��Ϣ

        gvResult.DataSource = Query();
        gvResult.DataBind();

        btnAdjustSale.Enabled = true;
        btnAdjustAcc.Enabled = false;
    }

    private Boolean DBreadValidation()
    {
        //�Կ��Ž��зǿա����ȡ����ּ���
        if (txtCashGiftCardno.Text.Trim() == "")
            context.AddError("A001004113", txtCashGiftCardno);
        else
        {
            if ((txtCashGiftCardno.Text.Trim()).Length != 16)
                context.AddError("A001004114", txtCashGiftCardno);
            else if (!Validation.isNum(txtCashGiftCardno.Text.Trim()))
                context.AddError("A001004115", txtCashGiftCardno);
        }

        return !(context.hasError());
    }

    public ICollection Query()
    {
        //���������̨�ʱ�(TF_B_SPEADJUSTACC)�ж�ȡ����

        DataTable data = SPHelper.callSDQuery(context, "SpeAdjustAcc", txtCashGiftCardno.Text);
        return new DataView(data);
    }
    //�����ۿ�
    protected void btnAdjustSale_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //��IC�����ϱ��ж�ȡ�Ͽ�����
        TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
        ddoTF_F_CARDRECIn.CARDNO = txtCashGiftCardno.Text;

        TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

        //���û�������(TL_R_ICUSER)�ж�ȡ�¿�����
        TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
        ddoTL_R_ICUSERIn.CARDNO = hiddenCardno.Value;

        TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

        if (ddoTL_R_ICUSEROut == null)
        {
            context.AddError("A001004128");
            return;
        }

        if (ddoTL_R_ICUSEROut.RESSTATECODE != "01" && ddoTL_R_ICUSEROut.RESSTATECODE != "05")
        {
            context.AddError("A001004132");
            return;
        }

        if (Convert.ToDecimal(hiddenWallet2.Value) * 100 != ddoTL_R_ICUSEROut.CARDPRICE)
        {
            context.AddError("����Ǯ��2��Ϊ10Ԫ,����תֵ");
            return;
        }

        if ((Convert.ToDecimal(txtAdjustMoney.Text) * 100) < ddoTL_R_ICUSEROut.CARDPRICE)
        {
            context.AddError("����С�����ܽ��е����ۿ�");
            return;
        }

        SP_SD_AdjustSalePDO pdo = new SP_SD_AdjustSalePDO();

        pdo.ID = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
        pdo.OLDCARDNO = txtCashGiftCardno.Text;
        //pdo.VALIDENDDATE = DateTime.Now.AddMonths(4).AddDays(1 - DateTime.Now.AddMonths(4).Day).AddDays(-1).ToString("yyyyMMdd");
        pdo.VALIDENDDATE = "20500101";
        pdo.CARDNO = hiddenCardno.Value;
        pdo.DEPOSIT = ddoTL_R_ICUSEROut.CARDPRICE;
        pdo.CARDMONEY = Convert.ToInt32(hiddencMoney.Value);
        pdo.ADJUSTMONEY = Convert.ToInt32(Convert.ToDecimal(txtAdjustMoney.Text) * 100);
        pdo.OTHERFEE = 0;
        pdo.CARDTRADENO = hiddentradeno.Value;
        pdo.CARDTYPECODE = txtCashGiftCardno.Text.Substring(4, 2);
        pdo.SELLCHANNELCODE = "01";
        pdo.SERSTAKETAG = "5";
        pdo.TRADETYPECODE = "56";
        pdo.TERMNO = "112233445566";
        pdo.OPERCARDNO = context.s_CardID;
        pdo.currDept = context.s_DepartID;
        pdo.currOper = context.s_UserID;

        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (ok)
        {
            hidCardReaderToken.Value = cardReader.createToken(context);

            hidCardnoForCheck.Value = hiddenCardno.Value;//add by liuhe 20111104����д��ǰ��֤ҳ���ϵĿ��źͶ������ϵĿ��Ƿ�һ�� modify by wdx 20111213,д����ʾ���Ų���

            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "startCashGiftCard('" + DateTime.Now.ToString("yyyyMMdd")
                + "', '" + pdo.VALIDENDDATE
                + "', " + ((Convert.ToDecimal(txtAdjustMoney.Text) * 100) - ddoTL_R_ICUSEROut.CARDPRICE)
                + ");", true);

            btnPrintPZ.Enabled = true;

            btnAdjustSale.Enabled = false;

        }
    }
}
