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
using TDO.CardManager;
using TDO.BusinessCode;
using TDO.PersonalTrade;
using Common;
using PDO.GroupCard;
using PDO.PersonalBusiness;
using TDO.ResourceManager;
using Master;

public partial class ASP_GroupCard_GC_FrontCharge : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";
            //设置GridView绑定的DataTable
            lvwSELFSUPPLYQuery.DataSource = new DataTable();
            lvwSELFSUPPLYQuery.DataBind();
            //指定GridView DataKeyNames
            lvwSELFSUPPLYQuery.DataKeyNames = new string[] { "DBPREMONEY", "TRADEMONEY", "PREMONEY", "CARDTRADENO", "STAFFNAME" };
        }
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //从企服卡可充值账户表中读取数据

        ChangePw.Visible = false;
        TF_F_CARDOFFERACCTDO ddoTF_F_CARDOFFERACCIn = new TF_F_CARDOFFERACCTDO();
        ddoTF_F_CARDOFFERACCIn.CARDNO = txtCardno.Text;

        TF_F_CARDOFFERACCTDO ddoTF_F_CARDOFFERACCOut = (TF_F_CARDOFFERACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDOFFERACCIn, typeof(TF_F_CARDOFFERACCTDO), null, "TF_F_CARDOFFERACC", null);

        if (ddoTF_F_CARDOFFERACCOut == null)
        {
            context.AddError("A001107110");
            return;
        }


        //企服卡账户有效时，才允许账户到卡片的圈存。wdx 20111205
        if (ddoTF_F_CARDOFFERACCOut.USETAG != "1")
        {
            context.AddError("企服卡账户不是有效状态，不能充值");
            return;
        }
        //输入密码不正确

        if (ddoTF_F_CARDOFFERACCOut.PASSWD != DealString.encrypPass(PassWD.Text.Trim()))
        {
            context.AddError("A001107119");
            return;
        }
        //未修改过密码,提示修改密码
        if (ddoTF_F_CARDOFFERACCOut.PASSWD == DealString.encrypPass("111111"))
        {
            ChangePw.Visible = true;
            //context.AddError("A004110120");
        }

        //卡账户有效性检验
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
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

            //从证件类型编码表(TD_M_PAPERTYPE)中读取数据
            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
            ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);

            //从集团客户-企服卡对应关系表中读取数据
            TD_GROUP_CARDTDO ddoTD_GROUP_CARDIn = new TD_GROUP_CARDTDO();
            ddoTD_GROUP_CARDIn.CARDNO = txtCardno.Text;

            TD_GROUP_CARDTDO ddoTD_GROUP_CARDOut = (TD_GROUP_CARDTDO)tmTMTableModule.selByPK(context, ddoTD_GROUP_CARDIn, typeof(TD_GROUP_CARDTDO), null, "TD_GROUP_CARD", null);

            if (ddoTD_GROUP_CARDOut == null)
            {
                context.AddError("A001107110");
                return;
            }

            hiddenCorpNo.Value = ddoTD_GROUP_CARDOut.CORPNO;

            //从集团客户资料表中读取数据
            TD_GROUP_CUSTOMERTDO ddoTD_GROUP_CUSTOMERIn = new TD_GROUP_CUSTOMERTDO();
            ddoTD_GROUP_CUSTOMERIn.CORPCODE = ddoTD_GROUP_CARDOut.CORPNO;

            TD_GROUP_CUSTOMERTDO ddoTD_GROUP_CUSTOMEROut = (TD_GROUP_CUSTOMERTDO)tmTMTableModule.selByPK(context, ddoTD_GROUP_CUSTOMERIn, typeof(TD_GROUP_CUSTOMERTDO), null, "TD_GROUP_CUSTOMER_CHANGE", null);

            if (ddoTD_GROUP_CUSTOMEROut == null)
            {
                context.AddError("A004111013");
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

            cMoney.Text = (Convert.ToDecimal(hiddencMoney.Value) / (Convert.ToDecimal(100.0))).ToString("0.00");
            allowMoney.Text = (Convert.ToDecimal(ddoTF_F_CARDOFFERACCOut.OFFERMONEY) / (Convert.ToDecimal(100.0))).ToString("0.00");

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
            CorpName.Text = ddoTD_GROUP_CUSTOMEROut.CORPNAME;

            //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
            if (!CommonHelper.HasOperPower(context))
            {
                Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
                Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
                Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
            }

            CommonHelper.readCardJiMingState(context, txtCardno.Text, hidIsJiMing);
            //查询充值记录
            lvwSELFSUPPLYQuery.DataSource = CreateSELFSUPPLYQueryDataSource();
            lvwSELFSUPPLYQuery.DataBind();

            btnSupply.Enabled = true;
            btnPrintPZ.Enabled = false;
        }
    }
    //查询充值记录
    public ICollection CreateSELFSUPPLYQueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从可充金额向电子钱包充值台帐表中读取数据
        TF_GROUP_SELFSUPPLYTDO ddoTF_GROUP_SELFSUPPLYIn = new TF_GROUP_SELFSUPPLYTDO();

        string strSql = "SELECT a.DBPREMONEY/100.0 DBPREMONEY,a.TRADEMONEY/100.0 TRADEMONEY,a.PREMONEY/100.0 PREMONEY,a.CARDTRADENO,b.STAFFNAME ";
        strSql += " FROM TF_GROUP_SELFSUPPLY a , TD_M_INSIDESTAFF b WHERE a.CARDNO = '" + txtCardno.Text + "' AND b.STAFFNO = a.OPERATESTAFFNO";

        ArrayList list = new ArrayList();

        strSql += DealString.ListToWhereStr(list);

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTF_GROUP_SELFSUPPLYIn, null, strSql, 0);
        DataView dataView = new DataView(data);
        return dataView;

    }
    //对输入金额进行检验
    private Boolean inportValidation()
    {
        
        ////对输入金额进行数字检验
        //if (!Validation.isNum(Money.Text.Trim()))
        //    context.AddError("A001002100", Money);
        //    //对输入金额进行空或0检验

        //else 
        Money.Text = Money.Text.Trim();
        if (Money.Text == "" )
            context.AddError("A001002126", Money);
        //对输入金额进行金额格式检验

        else if (!Validation.isPrice(Money.Text))
            context.AddError("A001002127", Money);

        else if ( Convert.ToDouble(Money.Text) == 0)
            context.AddError("A001002126", Money);
        //对输入金额和可充金额进行大小比较检验
        else if (Convert.ToDecimal(Money.Text) > Convert.ToDecimal(allowMoney.Text))
            context.AddError("A001107101", Money);

        return !(context.hasError());
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")
        {
            btnSupply.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            AddMessage("前台写卡成功");
            clearCustInfo(txtCardno);
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
        hidWarning.Value = "";
        hidCardnoForCheck.Value = "";//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致
    }

    protected void btnSupply_Click(object sender, EventArgs e)
    {
        //对输入金额进行检验
        if (!inportValidation())
            return;
         
        TMTableModule tmTMTableModule = new TMTableModule();

        //从IC卡电子钱包账户表中读取数据
        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text;

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null, "TF_F_CARDEWALLETACC", null);

        SP_GC_FrontChargePDO pdo = new SP_GC_FrontChargePDO();
        //存储过程赋值
        pdo.CARDNO = txtCardno.Text;
        pdo.ID = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
        //pdo.ID = hiddentradeno.Value + DateTime.Now.ToString("yyyyMMddhhmmss").Substring(4, 10) + hiddenASn.Value.Substring(16, 4);
        pdo.CARDTRADENO = hiddentradeno.Value;
        pdo.CARDMONEY = Convert.ToInt32(hiddencMoney.Value);
        pdo.CARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;
        pdo.ASN = hiddenAsn.Value.Substring(4, 16);
        pdo.CARDTYPECODE = hiddenLabCardtype.Value;
        pdo.SUPPLYMONEY = Convert.ToInt32(Convert.ToDecimal(Money.Text) * 100);
        hidSupplyMoney.Value = "" + pdo.SUPPLYMONEY;
        pdo.TRADETYPECODE = "21";
        pdo.CORPNO = hiddenCorpNo.Value;
        pdo.OPERCARDNO = context.s_CardID;
        pdo.TERMNO = "112233445566";
        pdo.DBMONEY = Convert.ToInt32(Convert.ToDecimal(allowMoney.Text) * 100);

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //AddMessage("M004110001");
            hidCardnoForCheck.Value = txtCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致

            hidCardReaderToken.Value = cardReader.createToken(context); 
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "chargeCard();", true);

            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, CustName.Text, "企服卡充值",
                (Convert.ToDecimal(pdo.SUPPLYMONEY) / (Convert.ToDecimal(100.0))).ToString("0.00")
                , "", "", Paperno.Text, (Convert.ToDecimal(pdo.CARDMONEY + pdo.SUPPLYMONEY) / (Convert.ToDecimal(100.0))).ToString("0.00"),
                "", (Convert.ToDecimal(pdo.SUPPLYMONEY) / (Convert.ToDecimal(100.0))).ToString("0.00"), context.s_UserID, context.s_DepartName,
                Papertype.Text, "0.00", "0.00");

            btnPrintPZ.Enabled = true;
            btnSupply.Enabled = false;

            //foreach (Control con in this.Page.Controls)
            //{
            //    ClearControl(con);
            //}
            lvwSELFSUPPLYQuery.DataSource = new DataTable();
            lvwSELFSUPPLYQuery.DataBind();
        }
    }
}
