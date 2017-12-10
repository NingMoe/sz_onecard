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


/***************************************************************
 * 功能名: 附加业务_旅游卡-售卡
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2013/09/03    liuhe			初次开发
 ****************************************************************/
public partial class ASP_AddtionalService_AS_SZTravelCardSale : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";
            setReadOnly(LabAsn, RESSTATE, LabCardtype, sDate, eDate, cMoney);

            CardcostFee.Attributes["onfocus"] = "this.select();";
            CardcostFee.Attributes["onkeyup"] = "RecvChanging(this, 'TotalFee', 'txtRealRecv', 'test', 'hidAccRecv');";

            SupplyMoney.Attributes["onfocus"] = "this.select();";
            SupplyMoney.Attributes["onkeyup"] = "changemoneySupply(this);";
            SupplyMoney.Attributes["onkeydown"] = "focusSubmit();";

            ASHelper.initSexList(selCustsex);
            initLoad(sender, e);

            TMTableModule tmTMTableModule = new TMTableModule();

        }
    }

    protected void initLoad(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从证件类型编码表(TD_M_PAPERTYPE)中读取数据，放入下拉列表中

        ASHelper.initPaperTypeList(context, selPapertype);

        //从前台业务交易费用表中读取售卡费用数据
        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "7H";

        TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001001137", "TD_M_TRADEFEE", null);

        for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        {
            //"00"为卡押金
            if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "00")
                hiddenDepositFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //"03"为手续费
            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "03")
                hiddenCardcostFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        }

        CardcostFee.Text = Convert.ToDecimal(hiddenCardcostFee.Value).ToString();
        DepositFee.Text = hiddenDepositFee.Value;

        #region 查询当前操作员充值默认值
        if (SupplyMoney.Text.Trim().Length == 0)
        {
            TD_M_INSIDESTAFFPARAMETERTDO tdoTD_M_INSIDESTAFFPARAMETERIn = new TD_M_INSIDESTAFFPARAMETERTDO();
            tdoTD_M_INSIDESTAFFPARAMETERIn.STAFFNO = context.s_UserID;

            TD_M_INSIDESTAFFPARAMETERTDO tdoTD_M_INSIDESTAFFPARAMETEROut = (TD_M_INSIDESTAFFPARAMETERTDO)tmTMTableModule.selByPK(context, tdoTD_M_INSIDESTAFFPARAMETERIn, typeof(TD_M_INSIDESTAFFPARAMETERTDO), null, "TD_M_INSIDESTAFFPARAMETER", null);

            if (tdoTD_M_INSIDESTAFFPARAMETEROut == null)
            {
                SupplyMoney.Text = "0";
                SupplyFee.Text = "0.00";
                hidSupplyFee.Value = "0.00";
            }
            else if (tdoTD_M_INSIDESTAFFPARAMETEROut.SUPPLEMONEY != -1)
            {
                SupplyMoney.Text = Convert.ToString((Convert.ToDecimal(tdoTD_M_INSIDESTAFFPARAMETEROut.SUPPLEMONEY)) / (Convert.ToDecimal(100)));
                SupplyFee.Text = ((Convert.ToDecimal(tdoTD_M_INSIDESTAFFPARAMETEROut.SUPPLEMONEY)) / (Convert.ToDecimal(100))).ToString("0.00");
                hidSupplyFee.Value = ((Convert.ToDecimal(tdoTD_M_INSIDESTAFFPARAMETEROut.SUPPLEMONEY)) / (Convert.ToDecimal(100))).ToString("0.00");
            }
        }
        #endregion

        TotalFee.Text = (Convert.ToDecimal(SupplyFee.Text)
                     + Convert.ToDecimal(DepositFee.Text) +
                     Convert.ToDecimal(CardcostFee.Text)).ToString("0.00");
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

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        #region add by liuhe 20111231 添加对代理营业厅预付款的验证
        if (DeptBalunitHelper.ValdatePrepay(context) == false)
        {
            return;
        }
        #endregion

        //判断卡状态与卡归属
        CheckTravelCardState(txtCardno.Text);

        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;

        //if (hiddenLabCardtype.Value != "5101")
        //{
        //    context.AddError("A001001901：非旅游卡不能在此页面售卡");
        //    ScriptManager2.SetFocus(btnReadCard);
        //    return;
        //}
        if (txtCardno.Text.Substring(4, 4).ToString() != "5101")
        {
            context.AddError("A001001901：非旅游卡不能在此页面售卡");
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
        cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / 100).ToString("0.00");

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

        if (Convert.ToDecimal(hiddencMoney.Value) != 0)
        {
            context.AddError("A001001144");
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

        ScriptManager2.SetFocus(SupplyMoney);
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "CashChargeConfirm")
        {
            btnSale_Click(sender, e);
            hidWarning.Value = "";
            return;
        }

        if (hidWarning.Value == "yes")
        {
            btnSale.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            AddMessage("前台写卡成功");

            #region add by liuhe 20111231 添加对代理营业厅预付款的验证,扣费后如果超过预警额度则提示
            int opMoney = Convert.ToInt32(Convert.ToDecimal(DepositFee.Text) * 100)
                + Convert.ToInt32(Convert.ToDecimal(CardcostFee.Text) * 100)
                + Convert.ToInt32(Convert.ToDecimal(SupplyMoney.Text) * 100);

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

    #region 售卡充值按钮提交
    /// <summary>
    /// 售卡充值
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSale_Click(object sender, EventArgs e)
    {
        #region add by liuhe 20111231 添加对代理营业厅预付款的验证,提交前如果扣费后不足最低额度则返回
        int opMoney = Convert.ToInt32(Convert.ToDecimal(DepositFee.Text) * 100)
                    + Convert.ToInt32(Convert.ToDecimal(CardcostFee.Text) * 100)
                    + Convert.ToInt32(Convert.ToDecimal(SupplyMoney.Text) * 100);
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

        context.SPOpen();
        context.AddField("p_ID").Value = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
        context.AddField("p_CARDNO").Value = txtCardno.Text;
        context.AddField("p_DEPOSIT", "Int32").Value = (int)(Double.Parse(hiddenDepositFee.Value) * 100);
        context.AddField("p_TRADEPROCFEE", "Int32").Value = (int)(Double.Parse(hiddenCardcostFee.Value) * 100);
        context.AddField("p_SUPPLYMONEY", "Int32").Value = (int)(Double.Parse(SupplyMoney.Text) * 100);
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

        hidSupplyMoney.Value = "" + context.GetFieldValue("p_SUPPLYMONEY").ToString();


        bool ok = context.ExecuteSP("SP_AS_SZTravelCardSale");

        if (ok)
        {
            //售卡成功时提示
            //AddMessage("M001001001");
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
            string totleFee = (Convert.ToDecimal(SupplyFee.Text)
               + Convert.ToDecimal(DepositFee.Text) +
               Convert.ToDecimal(CardcostFee.Text)).ToString("0.00");

            //售卡打印凭证
            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, txtCusname.Text, "旅游卡售卡", totleFee,
                    DepositFee.Text, "", ASHelper.GetPaperNo(txtCustpaperno.Text), SupplyFee.Text,
                    "", totleFee, context.s_UserID, context.s_DepartName, paperName, CardcostFee.Text, "0.00");
            btnPrintPZ.Enabled = true;

            //写卡
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "changeCard();", true);


            //售卡按钮不可用
            btnSale.Enabled = false;
            //重新初始化
            initLoad(sender, e);
            btnSale.Enabled = false;

        }
    }
    #endregion

    //输入金额改变时更新费用信息
    protected void SupplyMoney_Changed(object sender, EventArgs e)
    {
        SupplyFee.Text = ((Convert.ToDecimal(SupplyMoney.Text))).ToString("0.00");
    }

    //对输入金额进行非空、非零、数字、金额格式判断
    private Boolean inportValidation()
    {
        if (!Validation.isNum(SupplyMoney.Text.Trim()))
            context.AddError("A001002100", SupplyMoney);
        else if (SupplyMoney.Text.Trim() == "" || Convert.ToInt32(SupplyMoney.Text.Trim()) == 0)
            context.AddError("A001002126", SupplyMoney);
        else if (!Validation.isPosRealNum(SupplyMoney.Text.Trim()))
            context.AddError("A001002127", SupplyMoney);
        else if (Convert.ToDecimal(SupplyMoney.Text.Trim()) > 20000)
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
        ScriptManager2.SetFocus(SupplyMoney);
    }
}
