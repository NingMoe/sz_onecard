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
using TDO.BusinessCode;
using TDO.CardManager;
using PDO.PersonalBusiness;
using TDO.ResourceManager;
using TDO.UserManager;
using TDO.PersonalTrade;
using Master;

/**********************************
 * 世乒旅游卡售卡返销
 * 2015-3-30
 * gl
 * 初次编写
 * ********************************/
public partial class ASP_AddtionalService_AS_SPTravelCardSaleRollback : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            LabAsn.Attributes["readonly"] = "true";
            LabCardtype.Attributes["readonly"] = "true";
            RESSTATE.Attributes["readonly"] = "true";
            txtOpenLine.Attributes["readonly"] = "true";
            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";
            initLoad(sender, e);
        }

    }
    protected void initLoad(object sender, EventArgs e)
    {
        //TMTableModule tmTMTableModule = new TMTableModule();
        ////从前台业务交易费用表中读取售卡费用数据
        //TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        //ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "E1";

        //TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001001137", "TD_M_TRADEFEE", null);

        //for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        //{
        //    //"10"为卡费
        //    if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "10")
        //        hiddenCardcostFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        //}

        hiddenCardcostFee.Value = "0.00";
        hiddenFunctionFee.Value = "0.00";

        CardcostFee.Text = hiddenCardcostFee.Value;
        FunctionFee.Text = hiddenFunctionFee.Value;

        Total.Text = (Convert.ToDecimal(CardcostFee.Text) + Convert.ToDecimal(FunctionFee.Text)).ToString("0.00");
        ReturnSupply.Text = Total.Text;

    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        if (txtCardno.Text.Substring(4, 4).ToString() != "5103")
        {
            context.AddError("非世乒旅游卡不能在此页面售卡返销");
            ScriptManager2.SetFocus(btnReadCard);
            return;
        }

        TMTableModule tmTMTableModule = new TMTableModule();

        //卡账户有效性检验
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据
            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
            ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;

            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

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

            cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / 100).ToString("0.00");

            //查询充值金额
            TF_B_TRADETDO ddoTF_B_TRADEIn = new TF_B_TRADETDO();
            string strTradeid = "SELECT xx.* FROM(SELECT t.*,row_number() over(ORDER BY t.operatetime DESC)AS num FROM TF_B_TRADEFEE t WHERE t.cardno = '"
                                + txtCardno.Text + "' AND TRADETYPECODE IN ('E1') AND CANCELTAG = '0'  )xx WHERE num = 1";

            DataTable dataTradeid = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strTradeid, 0);

            if (dataTradeid.Rows.Count == 0)
            {
                context.AddError("A001020191:没有查询到售卡台帐");
                return;
            }
            else
            {
                string strSupplyMoney = dataTradeid.Rows[0]["supplymoney"].ToString();
                if (strSupplyMoney.Equals(Convert.ToInt32(Convert.ToDecimal(cMoney.Text) * 100).ToString()) == false)
                {
                    context.AddError("A001020192:卡内余额不等于充值金额，可能已被使用，不允许返销");
                    return;
                }
            }
            
            //从IC卡资料表中读取数据
            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text;
            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

            SaleDate.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");

            //从套餐表里面读套餐的功能费
            DataTable dt = ASHelper.callQuery(context, "QUERYSPTRAVELCARDINFOS", txtCardno.Text);

            string  spTravelLine = "";
            if (dt.Rows.Count == 0)
            {
                context.AddError("当前卡片没有开通世乒旅游卡不能在此页面返销");
                ScriptManager2.SetFocus(btnReadCard);
                return;
            }
            if (dt.Rows[0]["PACKAGETYPECODE"].ToString() == "01")
            {
                txtOpenLine.Text = "东线A";
                spTravelLine = "15053101010101FFFFFF";
            }
            else if (dt.Rows[0]["PACKAGETYPECODE"].ToString() == "02")
            {
                txtOpenLine.Text = "西线B";
                spTravelLine = "150531FFFFFFFF010101";
            }
            else if (dt.Rows[0]["PACKAGETYPECODE"].ToString() == "03")
            {
                txtOpenLine.Text = "东线A和西线B";
                spTravelLine = "15053101010101010101";
            }

            //读卡时判断用户是否已经玩过景点,玩过则不允许返销
            if (hiddenShiPingTag.Value != spTravelLine)
            {
                context.AddError("卡片已经在景点使用不能返销。");
                return;
            }

            //更新费用显示信息
            CardcostFee.Text = (-Convert.ToDecimal(ddoTF_F_CARDRECOut.CARDCOST) / 100).ToString("0.00");
            //功能费
            FunctionFee.Text = (-Convert.ToDecimal(dt.Rows[0]["PACKAGEFEE"]) / 100).ToString("0.00");

            Total.Text = (Convert.ToDecimal(CardcostFee.Text) + Convert.ToDecimal(FunctionFee.Text)).ToString("0.00");
            ReturnSupply.Text = Total.Text;



            //从内部员工编码表(TD_M_INSIDESTAFF)中读取数据


            TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            ddoTD_M_INSIDESTAFFIn.STAFFNO = ddoTF_F_CARDRECOut.STAFFNO;

            TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFOut = (TD_M_INSIDESTAFFTDO)tmTMTableModule.selByPK(context, ddoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_Destroy", null);

            SaleStaff.Text = ddoTD_M_INSIDESTAFFOut.STAFFNAME;
            //给页面显示项赋值


            LabAsn.Text = hiddenAsn.Value.Substring(4, 16);
            LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;

            //读取客户资料
            readInfo(sender, e);

            //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
            if (!CommonHelper.HasOperPower(context))
            {
                Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
                Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
                Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
            }

            btnRollback.Enabled = true;

            btnPrintPZ.Enabled = false;
        }
    }

    protected void readInfo(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据
        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
        ddoTF_F_CUSTOMERRECIn.CARDNO = txtCardno.Text;

        //UPDATE BY JIANGBB 2012-04-19解密
        DDOBase ddoBase = (DDOBase)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);
        ddoBase = CommonHelper.AESDeEncrypt(ddoBase);
        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)ddoBase;

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

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "rewriteCard") // 重新写卡，生产新的令牌
        {
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "saleShiPingRollback()();", true);
        }
        else if (hidWarning.Value == "yes")
        {
            btnRollback.Enabled = true;
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
    }

    protected void btnRollback_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //查询是否当天当操作员进行的售卡
        TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();

        string str = " Select SELLTIME,STAFFNO From TF_F_CARDREC WHERE CARDNO = '" + txtCardno.Text + "' " +
                     " And SELLTIME BETWEEN Trunc(sysdate,'dd') AND sysdate" +
                     " And STAFFNO = '" + context.s_UserID + "' ";
        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTF_F_CARDRECIn, null, str, 0);
        if (data.Rows.Count == 0)
        {
            context.AddError("A001020100");
            return;
        }

        //查询世乒卡售卡操作是否最新的一次业务操作
        TF_B_TRADETDO ddoTF_B_TRADEIn = new TF_B_TRADETDO();
        string strSale = " Select TRADETYPECODE From TF_B_TRADE WHERE CARDNO = '" + txtCardno.Text + "' " +
                         " And OPERATETIME > (SELECT SELLTIME FROM TF_F_CARDREC WHERE CARDNO = '" + txtCardno.Text + "') " +
                         " And CANCELTAG = '0' AND (ASCII(TRADETYPECODE) < 65 AND TRADETYPECODE NOT IN ('3A','3B','E1')) ";
        DataTable dataSale = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strSale, 0);

        if (dataSale.Rows.Count > 0)
        {
            context.AddError("A001020108");
            return;
        }

        string strTradeid = "SELECT xx.* FROM(SELECT t.*,row_number() over(ORDER BY t.operatetime DESC)AS num FROM TF_B_TRADEFEE t WHERE t.cardno = '"
            + txtCardno.Text + "'AND TRADETYPECODE ='E1' AND CANCELTAG = '0'  )xx WHERE num = 1";

        DataTable dataTradeid = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strTradeid, 0);


        //存储过程赋值
        context.SPOpen();
        context.AddField("p_ID").Value = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
        context.AddField("p_CARDNO").Value = txtCardno.Text;
        context.AddField("p_CARDTRADENO").Value = hiddentradeno.Value;

        context.AddField("p_CARDSERVFEE", "Int32").Value = Convert.ToInt32(Convert.ToDecimal(CardcostFee.Text) * 100);
        context.AddField("p_FUNCFEE", "Int32").Value = Convert.ToInt32(Convert.ToDecimal(FunctionFee.Text) * 100);
        context.AddField("p_CANCELTRADEID").Value = dataTradeid.Rows[0]["tradeid"].ToString();
        context.AddField("p_TERMNO").Value = "112233445566";
        context.AddField("p_OPERCARDNO").Value = context.s_CardID;

        bool ok = context.ExecuteSP("SP_AS_SPTravelCardSaleRollback");

        if (ok)
        {
            //售卡返销成功时提示
            //写卡---需要关闭功能

            hidCardReaderToken.Value = cardReader.createToken(context);

            hiddenShiPingTag.Value = "FFFFFFFFFFFFFFFFFFFF";

            ScriptManager.RegisterStartupScript(this, this.GetType(),
                "writeCardScript", "saleShiPingRollback();", true);
            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, CustName.Text, "世乒旅游-售卡返销", Total.Text,
                                "", "", ASHelper.GetPaperNo(Paperno.Text), "0.00",
                                "", Total.Text, context.s_UserID, context.s_DepartName, Papertype.Text, CardcostFee.Text, "0.00");
            btnPrintPZ.Enabled = true;


            //售卡返销按钮不可用
            btnRollback.Enabled = false;
            //重新初始化
            initLoad(sender, e);
        }
    }
}
