using System;
using System.Web.UI;
using System.Data;
using TM;
using Master;
using Common;
using TDO.CardManager;
using TDO.BusinessCode;
using TDO.ResourceManager;
using PDO.PersonalBusiness;

public partial class ASP_PersonalBusiness_PB_CardToCardOutRetrade : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            cMoney.Attributes["readonly"] = "true";
            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";
        }
    }

    protected void readInfo(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据


        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
        ddoTF_F_CUSTOMERRECIn.CARDNO = txtCardno.Text;

        //UPDATE BY JIANGBB 2012-06-07解密
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

    //private bool isWriteSuccess = true;

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //卡账户有效性检验

        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            cMoney.Text = ((Convert.ToDouble(hiddencMoney.Value)) / 100).ToString("0.00");

            hidCardnoForCheck.Value = txtCardno.Text;

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

            hiddenState.Value = ddoTL_R_ICUSEROut.RESSTATECODE;
            TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEOut = (TD_M_RESOURCESTATETDO)tmTMTableModule.selByPK(context, ddoTD_M_RESOURCESTATEIn, typeof(TD_M_RESOURCESTATETDO), null, "TD_M_RESOURCESTATE", null);

            if (ddoTD_M_RESOURCESTATEOut == null)
                RESSTATE.Text = ddoTL_R_ICUSEROut.RESSTATECODE;
            else
                RESSTATE.Text = ddoTD_M_RESOURCESTATEOut.RESSTATE;

            //读取客户资料
            readInfo(sender, e);
            btnPrintPZ.Enabled = false;
            btnLoad.Enabled = true;
        }

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
            Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
            Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
        }

        //判断圈提时写卡是否成功
        string strSql = " select a.TRADEID,a.CARDTRADENO,a.PREMONEY,b.MONEY,b.REMARK " +
                        " from TF_B_TRADE a,TF_B_CARDTOCARDREG b " +
                        " where a.cardno = '" + txtCardno.Text + "'" +
                        " and   a.TRADEID = b.TRADEID" +
                        " and   a.TRADETYPECODE = '5A'" +
                        " and   b.TRANSTATE = '2'" +
                        " order by a.operatetime desc";
        context.DBOpen("Select");

        DataTable data = context.ExecuteReader(strSql);

        if (data.Rows.Count > 0)
        {
            hidTradeid.Value = data.Rows[0]["TRADEID"].ToString();

            string preTradeno = data.Rows[0]["CARDTRADENO"].ToString();
            string curTradeno = hiddentradeno.Value;
            string nextTradeno = (Convert.ToInt32(preTradeno, 16) + 1).ToString("X4");
            string nextMoney = (Convert.ToInt32(data.Rows[0]["PREMONEY"].ToString()) - Convert.ToInt32(data.Rows[0]["MONEY"].ToString())).ToString();

            //如果圈提写卡前联机交易序号与当前卡内联机交易需要相同,且卡内余额与圈提写卡前卡内余额一致，则说明写卡失败
            if (curTradeno == preTradeno && hiddencMoney.Value == data.Rows[0]["PREMONEY"].ToString())
            {
                //isWriteSuccess = false;
                hidisWriteSuccess.Value = "false";
                AddMessage("圈提写卡失败，同时补写卡和库");
            }
            else if (curTradeno == nextTradeno && hiddencMoney.Value == nextMoney)
            {
                //isWriteSuccess = true;
                hidisWriteSuccess.Value = "true";
                AddMessage("圈提写卡成功，只补写库");
            }
            else
            {
                context.AddError("圈提后该卡又进行了充值或其他写卡操作，联机交易序号或金额不正确，无法补圈提");
                return;
            }

            txtDealMoney.Text = ((Convert.ToDouble(data.Rows[0]["MONEY"].ToString())) / 100).ToString("0.00");
            txtReMark.Text = data.Rows[0]["REMARK"].ToString();

            btnPrintPZ.Enabled = true;
            btnLoad.Enabled = true;

        }
        else
        {
            context.AddError("未找到可不写的圈提记录");
        }
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")
        {
            btnLoad.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            LoadForExecute(sender, e);
            hidCardnoForCheck.Value = "";
            //AddMessage("前台写卡成功");
        }
        else if (hidWarning.Value == "writeFail")
        {
            context.AddError("前台写卡失败");
        }
        else if (hidWarning.Value == "RevocerConfirm")
        {
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                    "unchargeCard();", true);
        }
        hidWarning.Value = "";
    }

    protected void btnLoad_Click(object sender, EventArgs e)
    {
        //如果圈提时写卡失败了
        if (hidisWriteSuccess.Value.Equals("false"))
        {
            hiddencMoney.Value = "" + Convert.ToInt32(Convert.ToDecimal(cMoney.Text) * 100);
            hidUnSupplyMoney.Value = "" + Convert.ToInt32(Convert.ToDecimal(txtDealMoney.Text) * 100);
            //写卡
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "UnloadCheck();", true);
        }
        //如果写卡成功了，补写库，更改卡卡转账台账转账状态
        else
        {
            LoadForExecute(sender, e);
        }
    }

    protected void LoadForExecute(object sender, EventArgs e)
    {
        int Vcardmoney = Convert.ToInt32(Convert.ToDecimal(cMoney.Text.Trim()) * 100);
        int Vsupplymoney = Convert.ToInt32(Convert.ToDecimal(txtDealMoney.Text.Trim()) * 100);

        //调用圈提存储过程
        context.SPOpen();
        context.AddField("P_ID").Value = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
        context.AddField("P_OUTCARDNO").Value = txtCardno.Text.Trim();
        context.AddField("P_TRADETYPECODE").Value = "5F";
        context.AddField("P_CARDTRADENO").Value = hiddentradeno.Value;
        context.AddField("P_SUPPLYMONEY").Value = Vsupplymoney;
        context.AddField("P_CARDMONEY").Value = Vcardmoney;
        context.AddField("P_REMARK").Value = txtReMark.Text.Trim();
        context.AddField("P_OPERCARDNO").Value = context.s_CardID;
        context.AddField("P_TERMNO").Value = "112233445566";
        context.AddField("p_TRADEID").Value = hidTradeid.Value;

        bool ok = context.ExecuteSP("SP_PB_CardToCardOutRetrade");

        if (ok)
        {
            hidSupplyMoney.Value = "" + (Convert.ToDecimal(txtDealMoney.Text.Trim()) * 100).ToString();
            hiddenSupply.Value = (Convert.ToDecimal(hidSupplyMoney.Value) / (Convert.ToDecimal(100))).ToString("0.00");
            AddMessage("前台写卡成功");

            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, CustName.Text, "卡卡转账圈提补写",
            hiddenSupply.Value, "", "", Paperno.Text,
            Convert.ToString((Vcardmoney - Vsupplymoney) / 100.0), "", hiddenSupply.Value, context.s_UserID,
            context.s_DepartName, Papertype.Text, "0.00", "");

            //自动打印凭证
            if (chkPingzheng.Checked && btnPrintPZ.Enabled)
            {
                ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "printInvoice();", true);
            }

            btnLoad.Enabled = false;

            txtCardno.Text = "";
        }
    }
}