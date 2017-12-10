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
using Common;
using TDO.UserManager;
using TDO.ResourceManager;
using TDO.CardManager;
using PDO.PersonalBusiness;
using Master;
using System.Text;


/**********************************
 * 世乒旅游卡售卡
 * 2015-3-30
 * gl
 * 初次编写
 * ********************************/
public partial class ASP_AddtionalService_AS_SPTravelCardSale : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";
            setReadOnly(LabAsn, RESSTATE, LabCardtype, sDate, eDate);

            txtRealRecv.Attributes["onfocus"] = "this.select();";
            txtRealRecv.Attributes["onkeyup"] = "realRecvChanging(this);";

            ASHelper.initSexList(selCustsex);
            initLoad(sender, e);
        }
    }

    protected void initLoad(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从证件类型编码表(TD_M_PAPERTYPE)中读取数据，放入下拉列表中

        ASHelper.initPaperTypeList(context, selPapertype);

        //从前台业务交易费用表中读取售卡费用数据
        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "E1";

        //TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001001137", "TD_M_TRADEFEE", null);

        //for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        //{
        //    //"10"为卡费
        //    if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "10")
        //        hiddenCardcostFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        //}
        hiddenCardcostFee.Value = "0.00";
        FunctionFee.Text  = "0.00";
        CardcostFee.Text = hiddenCardcostFee.Value;

        //从套餐表里面读套餐的功能费
        DataTable dt = ASHelper.callQuery(context,"SPTRAVELCARDLINES");
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            if (dt.Rows[i]["PACKAGETYPECODE"].ToString() == "01")
            {
                hiddenLineMoney.Value = ((Convert.ToDecimal(dt.Rows[i]["PACKAGEFEE"])) / 100).ToString("0.00");
            }
            else if (dt.Rows[i]["PACKAGETYPECODE"].ToString() == "02")
            {
                hiddenXXLineMoney.Value = ((Convert.ToDecimal(dt.Rows[i]["PACKAGEFEE"])) / 100).ToString("0.00");
            }
        }
       
        decimal total = Convert.ToDecimal(CardcostFee.Text) + Convert.ToDecimal(FunctionFee.Text);
        TotalFee.Text = total.ToString("0.00");

        txtRealRecv.Text = total.ToString("0");
        hidAccRecv.Value = total.ToString("n");

        chbGeneral.Checked = false;
        chbXXGeneral.Checked = false;
    }

    //对售卡用户信息进行检验
    private Boolean SaleInfoValidation()
    {

        //对用户姓名进行长度检验
        if (txtCusname.Text.Trim() != "")
            if (Validation.strLen(txtCusname.Text.Trim()) > 50)
                context.AddError("A001001113", txtCusname);

        //对出生日期进行日期格式检验
        String cDate = txtCustbirth.Text.Trim();
        if (cDate != "")
            if (!Validation.isDate(txtCustbirth.Text.Trim()))
                context.AddError("A001001115", txtCustbirth);

        //对联系电话进行长度检验
        if (txtCustphone.Text.Trim() != "")
            if (Validation.strLen(txtCustphone.Text.Trim()) > 20)
                context.AddError("A001001126", txtCustphone);
            else if (!Validation.isNum(txtCustphone.Text.Trim()))
                context.AddError("A001001125", txtCustphone);

        //对证件号码进行长度、英数字检验
        if (txtCustpaperno.Text.Trim() != "")
            if (!Validation.isCharNum(txtCustpaperno.Text.Trim()))
                context.AddError("A001001122", txtCustpaperno);
            else if (Validation.strLen(txtCustpaperno.Text.Trim()) > 20)
                context.AddError("A001001123", txtCustpaperno);

        //对邮政编码进行长度、数字检验
        if (txtCustpost.Text.Trim() != "")
            if (Validation.strLen(txtCustpost.Text.Trim()) != 6)
                context.AddError("A001001120", txtCustpost);
            else if (!Validation.isNum(txtCustpost.Text.Trim()))
                context.AddError("A001001119", txtCustpost);

        //对联系地址进行长度检验
        if (txtCustaddr.Text.Trim() != "")
            if (Validation.strLen(txtCustaddr.Text.Trim()) > 50)
                context.AddError("A001001128", txtCustaddr);

        //对电子邮件进行格式检验
        if (txtEmail.Text.Trim() != "")
            new Validation(context).isEMail(txtEmail);

        //对备注进行长度检验
        if (txtRemark.Text.Trim() != "")
            if (Validation.strLen(txtRemark.Text.Trim()) > 50)
                context.AddError("A001001129", txtRemark);


        return !(context.hasError());
    }

    //重置收款信息和费用信息

    private void clearRadio(object sender, EventArgs e)
    {
        initLoad(sender, e);
        txtChanges.InnerHtml = "0.00";
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        #region add by liuhe 20111231 添加对代理营业厅预付款的验证
        if (DeptBalunitHelper.ValdatePrepay(context) == false)
        {
            return;
        }
        #endregion

        clearRadio(sender, e);

        //判断卡状态与卡归属
        CheckTravelCardState(txtCardno.Text);

        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;

        if (txtCardno.Text.Substring(4, 4).ToString() != "5103")
        {
            context.AddError("非世乒旅游卡不能在此页面售卡");
            ScriptManager2.SetFocus(btnReadCard);
            return;
        }

        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

        //给页面显示项赋值
        // txtCardno.Text = hiddentxtCardno.Value;
        LabAsn.Text = hiddenAsn.Value.Substring(4, 16);
        LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
        sDate.Text = hiddensDate.Value.Substring(0, 4) + "-" + hiddensDate.Value.Substring(4, 2) + "-" + hiddensDate.Value.Substring(6, 2);
        eDate.Text = hiddeneDate.Value.Substring(0, 4) + "-" + hiddeneDate.Value.Substring(4, 2) + "-" + hiddeneDate.Value.Substring(6, 2);
        cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / 100).ToString("0.00"); //卡内余额

        //从用户卡库存表(TL_R_ICUSER)中读取数据
        TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
        ddoTL_R_ICUSERIn.CARDNO = txtCardno.Text;

        TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

        if (ddoTL_R_ICUSEROut == null)
        {
            context.AddError("A001001101");
            ScriptManager2.SetFocus(btnReadCard);
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

        //计算费用

        CardcostFee.Text = (Convert.ToDecimal(hiddenCardcostFee.Value) + (Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE)) / 100).ToString("0.00");

        TotalFee.Text = (Convert.ToDecimal(CardcostFee.Text)+Convert.ToDecimal(FunctionFee.Text)).ToString();

        hidAccRecv.Value = TotalFee.Text;
        txtRealRecv.Text = Convert.ToInt32(Convert.ToDecimal(TotalFee.Text)).ToString();

        if (Convert.ToDecimal(hiddencMoney.Value) != 0)
        {
            context.AddError("A001001144");
            ScriptManager2.SetFocus(btnReadCard);
            return;
        }

        //新卡应该没有绑定套餐
        DataTable dt = ASHelper.callQuery(context, "QUERYSPTRAVELCARDINFOS", txtCardno.Text);
        if (dt.Rows.Count > 0)
        {
            context.AddError("该卡已经开通过世乒卡业务,无须售卡");
            ScriptManager2.SetFocus(btnReadCard);
            return;
        }

        //卡库存状态为出库或分配时,售卡按钮可用
        if (ddoTL_R_ICUSEROut.RESSTATECODE == "01" || ddoTL_R_ICUSEROut.RESSTATECODE == "05")
        {
            btnSale.Enabled = true;
        }
        else if (ddoTL_R_ICUSEROut.RESSTATECODE == "12")
        {
            context.AddError("A001001141");
            ScriptManager2.SetFocus(btnReadCard);
            return;
        }
        if (context.hasError())
        {
            ScriptManager2.SetFocus(btnReadCard);
            return;
        }

        hidIsJiMing.Value = "0";

        btnPrintPZ.Enabled = false;
        btnSale.Enabled = true;

        ScriptManager2.SetFocus(txtRealRecv);


    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "rewriteCard") // 重新写卡，生产新的令牌
        {
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "writeShiPing();", true);
        }
        
        if (hidWarning.Value == "yes")
        {
            btnSale.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            AddMessage("前台写卡成功");

            #region add by liuhe 20111231 添加对代理营业厅预付款的验证,扣费后如果超过预警额度则提示
            int opMoney = Convert.ToInt32(Convert.ToDecimal(CardcostFee.Text) * 100)
                + Convert.ToInt32(Convert.ToDecimal(FunctionFee.Text) * 100);

            DeptBalunitHelper.ValdatePrepay(context, opMoney, "1");
            #endregion

            clearCustInfo(txtCardno, txtCusname, txtCustbirth, selPapertype, txtCustpaperno, selCustsex, txtCustphone,
                txtCustpost, txtCustaddr, txtEmail, txtRemark);

        }
        else if (hidWarning.Value == "writeFail")
        {
            context.AddError("前台写卡失败");
        }

        if (chkPingzheng.Checked)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }
        hidWarning.Value = "";

        ScriptManager2.SetFocus(btnReadCard);
    }

    #region 售卡按钮提交
    /// <summary>
    /// 售卡
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSale_Click(object sender, EventArgs e)
    {
        #region add by liuhe 20111231 添加对代理营业厅预付款的验证,提交前如果扣费后不足最低额度则返回
        int opMoney = Convert.ToInt32(Convert.ToDecimal(CardcostFee.Text) * 100)
                    + Convert.ToInt32(Convert.ToDecimal(FunctionFee.Text) * 100);
        if (DeptBalunitHelper.ValdatePrepay(context, opMoney, "2") == false)
        {
            return;
        }
        #endregion

        //判断售卡权限
        CheckTravelCardState(txtCardno.Text);
        if (context.hasError()) return;

        //用户信息判断
        if (!SaleInfoValidation())
            return;

        string packagetypecode = "";
        if (chbGeneral.Checked == true && chbXXGeneral.Checked != true)
        {
            packagetypecode = "01";
            hiddenShiPingTag.Value = "15053101010101FFFFFF";
        }
        else if (chbGeneral.Checked != true && chbXXGeneral.Checked == true)
        {
            packagetypecode = "02";
            hiddenShiPingTag.Value = "150531FFFFFFFF010101";
        }
        else if (chbGeneral.Checked == true && chbXXGeneral.Checked == true)
        {
            packagetypecode = "03";
            hiddenShiPingTag.Value = "15053101010101010101";
        }
        else
        {
            context.AddError("请至少选中一条线路");
            return;
        }

        context.SPOpen();
        context.AddField("p_ID").Value = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
        context.AddField("p_CARDNO").Value = txtCardno.Text;
        context.AddField("p_CARDCOST", "Int32").Value = (int)(Double.Parse(CardcostFee.Text) * 100);//卡费
       

        context.AddField("p_CARDTRADENO").Value = hiddentradeno.Value;

        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCusname.Text, ref strBuilder);
        context.AddField("p_CUSTNAME").Value = strBuilder.ToString();
        context.AddField("p_CUSTSEX").Value = selCustsex.SelectedValue;
        context.AddField("p_CUSTBIRTH").Value = txtCustbirth.Text;
        context.AddField("p_PAPERTYPECODE").Value = selPapertype.SelectedValue;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustpaperno.Text.Trim(), ref strBuilder);
        context.AddField("p_PAPERNO").Value = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustaddr.Text.Trim(), ref strBuilder);
        context.AddField("p_CUSTADDR").Value = strBuilder.ToString();
        context.AddField("p_CUSTPOST").Value = txtCustpost.Text;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustphone.Text.Trim(), ref strBuilder);
        context.AddField("p_CUSTPHONE").Value = strBuilder.ToString();
        context.AddField("p_CUSTEMAIL").Value = txtEmail.Text;
        context.AddField("p_REMARK").Value = txtRemark.Text;
        context.AddField("p_OPERCARDNO").Value = context.s_CardID;
        context.AddField("p_TRADEID", "String", "Output","16");
        context.AddField("p_PACKAGETYPECODE").Value = packagetypecode;
        string writeCardScript = "startSPTRAVELCard('" + DateTime.Now.ToString("yyyyMMdd")
              + "', " + hiddenShiPingTag.Value
              + ");";
        context.AddField("p_WRITECARDSCRIPT").Value = writeCardScript;
        bool ok = context.ExecuteSP("SP_AS_SPTravelCardSale");

        if (ok)
        {
            //售卡成功时提示
            hidCardnoForCheck.Value = txtCardno.Text;//用于写卡前验证页面上的卡号和读卡器上的卡是否一致

            //证件类型
            string paperName = string.Empty;
            if (selPapertype.SelectedItem.Text.Contains(":"))
            {
                paperName = selPapertype.SelectedItem.Text.Substring(selPapertype.SelectedItem.Text.IndexOf(":") + 1, selPapertype.SelectedItem.Text.Length - selPapertype.SelectedItem.Text.IndexOf(":") - 1);
            }
            else
            {
                paperName = "";
            }

            string totalFee = (Convert.ToDecimal(CardcostFee.Text) +
               Convert.ToDecimal(FunctionFee.Text)).ToString("0.00");
            //售卡打印凭证
            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, txtCusname.Text, "世乒旅游-售卡", totalFee,
                    "", "", ASHelper.GetPaperNo(txtCustpaperno.Text), "",
                    "", totalFee, context.s_UserID, context.s_DepartName, paperName, CardcostFee.Text, "0.00");
            btnPrintPZ.Enabled = true;

            //写卡---需要开通功能
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "writeShiPing();", true);


            //售卡按钮不可用
            btnSale.Enabled = false;
            //重新初始化
            initLoad(sender, e);
            btnSale.Enabled = false;

        }
    }
    #endregion

   

    //对输入金额进行非空、非零、数字、金额格式判断
    private Boolean inportValidation()
    {
        if (!Validation.isNum(txtRealRecv.Text.Trim()))
            context.AddError("A001002100", txtRealRecv);
        else if (txtRealRecv.Text.Trim() == "" || Convert.ToInt32(txtRealRecv.Text.Trim()) == 0)
            context.AddError("A001002126", txtRealRecv);
        else if (!Validation.isPosRealNum(txtRealRecv.Text.Trim()))
            context.AddError("A001002127", txtRealRecv);
        else if (Convert.ToDecimal(txtRealRecv.Text.Trim()) > 20000)
            context.AddError("充值金额过大");

        return !(context.hasError());
    }

    private void CheckTravelCardState(string cardNo)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从用户卡库存表中读取数据
        TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
        ddoTL_R_ICUSERIn.CARDNO = cardNo;

        TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);
        if (ddoTL_R_ICUSEROut == null)
        {
            context.AddError("A001001101");
            return;
        }
        

        if (ddoTL_R_ICUSEROut.SALETYPE != "01" && ddoTL_R_ICUSEROut.SALETYPE != "02")
        {
            context.AddError("未找到正确的售卡方式");
            return;
        }

        if (ddoTL_R_ICUSEROut.SALETYPE != "01")
        {
            context.AddError("世乒卡为卡费售卡,新卡不是正确的售卡方式");
        }

        if (ddoTL_R_ICUSEROut.RESSTATECODE != "01"
            && ddoTL_R_ICUSEROut.RESSTATECODE != "05"
            && ddoTL_R_ICUSEROut.RESSTATECODE != "04")
        {

            context.AddError("A001001198:卡片库存状态不是出库或者回收状态");
        }

        if (ddoTL_R_ICUSEROut.ASSIGNEDDEPARTID != context.s_DepartID)
            context.AddError("A001004193:卡所属部门不是当前操作员所属部门");

    }

    protected void txtReadPaper_Click(object sender, EventArgs e)
    {
        ScriptManager2.SetFocus(txtRealRecv);
    }
}
