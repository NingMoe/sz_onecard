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
using Master;
using Common;
using TDO.CardManager;
using TDO.BusinessCode;
using TDO.ResourceManager;
using PDO.PersonalBusiness;

public partial class ASP_PersonalBusiness_PB_CardToCardOut : Master.Master
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
        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }
        hidWarning.Value = "";        
    }

    private int Vcardmoney = 0;
    private int Vsupplymoney = 0;

    protected void btnLoad_Click(object sender, EventArgs e)
    {
        //有效性校验
        if (!loadValidation()) return;

        //查询该卡号有无失败记录
        string strSql = " Select t.TRADEID,t.TRADETYPECODE From TF_B_TRADE t,TF_B_CARDTOCARDREG b WHERE "+
                       " t.TRADEID=b.TRADEID AND t.TRADETYPECODE='5A' AND b.TRANSTATE='2' AND t.canceltag='0' " +
                       " AND t.CARDNO = '" + txtCardno.Text + "'" ;
        context.DBOpen("Select");
        DataTable data = context.ExecuteReader(strSql);
        if (data.Rows.Count > 0)
        {
            context.AddError("A094570006:该卡号有卡卡圈提失败,请先补写卡");
            return;
        }

        //调用圈提存储过程
        Vcardmoney = Convert.ToInt32(Convert.ToDecimal(cMoney.Text.Trim()) * 100);
        Vsupplymoney = Convert.ToInt32(Convert.ToDecimal(txtDealMoney.Text.Trim()) * 100);

        SP_PB_CardToCardOutPDO pdo = new SP_PB_CardToCardOutPDO();
        pdo.ID = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
        pdo.OUTCARDNO = txtCardno.Text.Trim();
        pdo.TRADETYPECODE = "5A";
        pdo.CARDTRADENO = hiddentradeno.Value;
        pdo.SUPPLYMONEY = Vsupplymoney;
        pdo.CARDMONEY = Vcardmoney;
        pdo.REMARK = txtReMark.Text.Trim();
        pdo.OPERCARDNO = context.s_CardID;
        pdo.TERMNO = "112233445566";
        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (ok)
        {
            hidoutTradeid.Value = "" + ((SP_PB_CardToCardOutPDO)pdoOut).TRADEID;
            //第一次写库成功后写卡
            hiddencMoney.Value = "" + Convert.ToInt32(Convert.ToDecimal(cMoney.Text) * 100);
            hidUnSupplyMoney.Value = "" + Convert.ToInt32(Convert.ToDecimal(txtDealMoney.Text) * 100);
            //写卡
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "UnloadCheck();", true);
        }
        
    }

    //写卡成功后，将卡卡转账记录台账表的转账状态由2、圈提待写卡，改为0、圈提待转账
    protected void LoadForExecute(object sender, EventArgs e)
    {
        //调用更新卡卡转账记录台账表存储过程
        context.SPOpen();
        context.AddField("p_TRADEID").Value = hidoutTradeid.Value;
        bool ok = context.ExecuteSP("SP_PB_UpdateCardToCardReg");

        if (ok)
        {
            hidSupplyMoney.Value = "" + (Convert.ToDecimal(txtDealMoney.Text.Trim()) * 100).ToString();
            hiddenSupply.Value = (Convert.ToDecimal(hidSupplyMoney.Value) / (Convert.ToDecimal(100))).ToString("0.00");
            AddMessage("前台写卡成功");

            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, CustName.Text, "卡卡转账圈提",
            hiddenSupply.Value, "", "", Paperno.Text,
            Convert.ToString((Vcardmoney - Vsupplymoney) / 100.0), "", hiddenSupply.Value, context.s_UserID,
            context.s_DepartName, Papertype.Text, "0.00", "");

            btnLoad.Enabled = false;

            txtCardno.Text = "";
        }
    }

    protected Boolean loadValidation()
    {
        //对交易金额的校验
        if (txtDealMoney.Text.Trim() == "" || txtDealMoney.Text.Trim() == "0")
            context.AddError("A094570001:交易金额不能为0或空", txtDealMoney);
        else if (!Validation.isPosRealNum(txtDealMoney.Text.Trim()))
            context.AddError("A094570002:交易金额必须为正数,只允许两位小数", txtDealMoney);
        else if (Convert.ToDecimal(txtDealMoney.Text.Trim()) > Convert.ToDecimal(cMoney.Text.Trim()))
            context.AddError("A094570003:圈提金额不能大于卡内余额", txtDealMoney);
        //对备注的校验
        if (txtReMark.Text.Trim() != "")
            if (Validation.strLen(txtReMark.Text.Trim()) > 50)
                context.AddError("A094570004:备注长度不能超过50位", txtReMark);

        //查询库里余额
        TMTableModule tmTMTableModule = new TMTableModule();


        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text.Trim();

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);

        Double cardMoney = Convert.ToDouble(ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY);

        //如果库余额小于卡余额,也小于圈提金额做提示
        if ((Convert.ToDecimal(cardMoney / 100) < Convert.ToDecimal(cMoney.Text.Trim())) &&
            (Convert.ToDecimal(cardMoney / 100) < Convert.ToDecimal(txtDealMoney.Text.Trim())))
        {
            context.AddMessage("A094570005:当前库余额小于卡余额,可能造成数据错误");
        }

        return !(context.hasError());
    }
}