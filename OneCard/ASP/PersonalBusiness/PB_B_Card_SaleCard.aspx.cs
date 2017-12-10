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

public partial class ASP_PersonalBusiness_PB_B_Card_SaleCard : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";
            setReadOnly(LabAsn, RESSTATE, LabCardtype, sDate, eDate, cMoney);
            txtRealRecv.Attributes["onfocus"] = "this.select();";
            txtRealRecv.Attributes["onkeyup"] = "realRecvChanging(this, 'test', 'hidAccRecv');";

            CardcostFee.Attributes["onfocus"] = "this.select();";
            CardcostFee.Attributes["onkeyup"] = "RecvChanging(this, 'Total', 'txtRealRecv', 'test', 'hidAccRecv');";

            SupplyMoney.Attributes["onfocus"] = "this.select();";
            SupplyMoney.Attributes["onkeyup"] = "changsaleemoney(this);";

            ASHelper.initSexList(selCustsex);
            initLoad(sender, e);
            initLoad_Supply(sender, e);
            hidAccRecv.Value = Total.Text;

            TMTableModule tmTMTableModule = new TMTableModule();

            //查询当前操作员是否具有售卡充值显示权限
            TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
            string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '201002' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
            DataTable dataSupply = tmTMTableModule.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);

            //if (dataSupply.Rows.Count != 0)
            //{
            //    SupplyA.Visible = true;
            //    SupplyB.Visible = true;
            //    chkPingzheng.Visible = true;
            //}
            
            SupplyA.Visible = false;
            SupplyB.Visible = false;
            chkPingzheng.Visible = false;
                
            //查询是否出租车部门
            TD_M_INSIDESTAFFROLETDO ddoTD_M_INSIDESTAFFROLEIn = new TD_M_INSIDESTAFFROLETDO();
            string taix = " Select * from TD_M_INSIDESTAFFROLE where staffno = '" + context.s_UserID + "' " +
                            " And ( roleno = '1100' or roleno = '1110' )";
            DataTable datataix = tmTMTableModule.selByPKDataTable(context, ddoTD_M_INSIDESTAFFROLEIn, null, taix, 0);

            if (datataix.Rows.Count == 0)
            {
                CardcostFee.Attributes["readonly"] = "true";
            }
 
        }
    }

    protected void initLoad(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        hidFlagcost.Value = "0";
        //从证件类型编码表(TD_M_PAPERTYPE)中读取数据，放入下拉列表中

        ASHelper.initPaperTypeList(context, selPapertype);

        //从前台业务交易费用表中读取售卡费用数据
        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "01";

        TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001001137", "TD_M_TRADEFEE", null);

        for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        {
            //"00"为卡押金
            if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "00")
                hiddenDepositFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //"10"为卡费
            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "10")
                hiddenCardcostFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //"99"为其他费用
            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "99")
                hidOtherFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        }

        //查询当前操作员卡费不收取权
        TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
      
        string strPow = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '201003' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
        DataTable dataPower = tmTMTableModule.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strPow, 0);

        //当前操作员有卡费不收取权
        if (dataPower.Rows.Count != 0)
        {
            DepType.Text = "卡费";
            Costacp.Visible = true;
            hidCardcostFee.Value = hiddenCardcostFee.Value;
            hidDepositFee.Value = hiddenDepositFee.Value;
            hidFlagcost.Value = "1";
        }

        //当前操作员没有卡费不收取权
        else if (dataPower.Rows.Count == 0)
        {
                TD_M_INSIDESTAFFPARAMETERTDO ddoTD_M_INSIDESTAFFPARAMETERIn = new TD_M_INSIDESTAFFPARAMETERTDO();
                ddoTD_M_INSIDESTAFFPARAMETERIn.STAFFNO = context.s_UserID;

                TD_M_INSIDESTAFFPARAMETERTDO ddoTD_M_INSIDESTAFFPARAMETEROut = (TD_M_INSIDESTAFFPARAMETERTDO)tmTMTableModule.selByPK(context, ddoTD_M_INSIDESTAFFPARAMETERIn, typeof(TD_M_INSIDESTAFFPARAMETERTDO), null, "TD_M_INSIDESTAFFPARAMETER", null);
                //无记录时售卡费用为卡押金
                if (ddoTD_M_INSIDESTAFFPARAMETEROut == null)
                {
                    DepType.Text = "卡押金";
                    hidCardcostFee.Value = hiddenCardcostFee.Value;
                    hidDepositFee.Value = hiddenDepositFee.Value;
                }
                //当前操作员卡费修改类型为卡费
                else if (ddoTD_M_INSIDESTAFFPARAMETEROut.CARDCOSTSTAT == "1")
                {
                    DepType.Text = "卡费";
                    hidDepositFee.Value = "0.00";
                    //卡费默认值不为空
                    if (ddoTD_M_INSIDESTAFFPARAMETEROut.CARDCOST != -1)
                    {
                        hidCardcostFee.Value = (Convert.ToDecimal(hiddenCardcostFee.Value) + (Convert.ToDecimal(ddoTD_M_INSIDESTAFFPARAMETEROut.CARDCOST)) / 100).ToString("0.00");
                        hidFlagcost.Value = "3";
                    }
                    //卡费默认值为空
                    else 
                    {
                        hidCardcostFee.Value = hiddenCardcostFee.Value;
                        hidFlagcost.Value = "4";
                    }
                }

               //当前操作员卡费修改类型为卡押金
                else if (ddoTD_M_INSIDESTAFFPARAMETEROut.CARDCOSTSTAT == "2")
                {
                    DepType.Text = "卡押金";
                    hidCardcostFee.Value = "0.00";

                    if (ddoTD_M_INSIDESTAFFPARAMETEROut.CARDCOST != -1)
                    {
                        hidDepositFee.Value = (Convert.ToDecimal(hiddenDepositFee.Value) + (Convert.ToDecimal(ddoTD_M_INSIDESTAFFPARAMETEROut.CARDCOST)) / 100).ToString("0.00");
                        hidFlagcost.Value = "2";
                    }
                    else 
                    {
                        hidDepositFee.Value = hiddenDepositFee.Value;
                        hidFlagcost.Value = "0";
                    }
                }
            }
        CardcostFee.Text = Convert.ToDecimal(hidCardcostFee.Value).ToString();
        DepositFee.Text = hidDepositFee.Value;
        OtherFee.Text = hidOtherFee.Value;
        Total.Text = (Convert.ToDecimal(CardcostFee.Text) + Convert.ToDecimal(DepositFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");

        }

    //对售卡用户信息进行检验
    private Boolean SaleInfoValidation()
    {
        //当选择非记名卡时
        if (Signtype.Checked == false)
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
                else if (selPapertype.SelectedValue == "00" && !Validation.isPaperNo(txtCustpaperno.Text.Trim()))
                    context.AddError("A001001130:证件号码验证不通过", txtCustpaperno);

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

        }

        //当选择记名卡时
        if (Signtype.Checked == true)
        {
            //对用户姓名进行非空、长度检验
            if ( txtCusname.Text.Trim() == "")
                context.AddError("A001001111", txtCusname);
            else if (Validation.strLen(txtCusname.Text.Trim()) > 50)
                    context.AddError("A001001113", txtCusname);

            //对用户性别进行非空检验
            if (selCustsex.SelectedValue == "")
                context.AddError("A001001116", selCustsex);

            //对证件类型进行非空检验
            if (selPapertype.SelectedValue == "")
                context.AddError("A001001117", selPapertype);

            //对出生日期进行非空、日期格式检验
            String cDate = txtCustbirth.Text.Trim();
            if (cDate == "")
                context.AddError("A001001114", txtCustbirth);
            else if (!Validation.isDate(txtCustbirth.Text.Trim()))
                context.AddError("A001001115", txtCustbirth);

            //对联系电话进行非空、长度、数字检验
            if (txtCustphone.Text.Trim() == "")
                context.AddError("A001001124", txtCustphone);
            else if (Validation.strLen(txtCustphone.Text.Trim()) > 20)
                    context.AddError("A001001126", txtCustphone);
                else if (!Validation.isNum(txtCustphone.Text.Trim()))
                    context.AddError("A001001125", txtCustphone);

            //对证件号码进行非空、长度、英数字检验
            if (txtCustpaperno.Text.Trim() == "")
                context.AddError("A001001121", txtCustpaperno);
            else if (!Validation.isCharNum(txtCustpaperno.Text.Trim()))
                    context.AddError("A001001122", txtCustpaperno);
                else if (Validation.strLen(txtCustpaperno.Text.Trim()) > 20)
                    context.AddError("A001001123", txtCustpaperno);
            else if (selPapertype.SelectedValue == "00" && !Validation.isPaperNo(txtCustpaperno.Text.Trim()))
                context.AddError("A001001130:证件号码验证不通过", txtCustpaperno);

            //对邮政编码进行非空、长度、数字检验
            if (txtCustpost.Text.Trim() == "")
                context.AddError("A001001118", txtCustpost);
            else if (Validation.strLen(txtCustpost.Text.Trim()) != 6)
                    context.AddError("A001001120", txtCustpost);
                else if (!Validation.isNum(txtCustpost.Text.Trim()))
                    context.AddError("A001001119", txtCustpost);

            //对联系地址进行非空、长度检验
            if (txtCustaddr.Text.Trim() == "")
                context.AddError("A001001127", txtCustaddr);
            else if (Validation.strLen(txtCustaddr.Text.Trim()) > 50)
                    context.AddError("A001001128", txtCustaddr);

            //对备注进行长度检验
            if (txtRemark.Text.Trim() != "")
                if (Validation.strLen(txtRemark.Text.Trim()) > 50)
                    context.AddError("A001001129", txtRemark);

            //对电子邮件进行格式检验
            if (txtEmail.Text.Trim() != "")
                new Validation(context).isEMail(txtEmail);
        }
            return  !(context.hasError());
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        //吴江B卡判断
        if (txtCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("不是吴江B卡,不能在本业务界面操作");
            return;
        }
        
        TMTableModule tmTMTableModule = new TMTableModule();
        
        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据

        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;

        if (hiddenLabCardtype.Value == "05")
        {
            context.AddError("利金卡不允许做普通售卡");
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
            return;
        }

        //获取售卡方式
        if (ddoTL_R_ICUSEROut.SALETYPE == "01")
        {
            context.AddError("吴江B卡不允许出售卡费卡");
            return;
        }

        //从资源状态编码表中读取数据
        TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEIn = new TD_M_RESOURCESTATETDO();
        ddoTD_M_RESOURCESTATEIn.RESSTATECODE = ddoTL_R_ICUSEROut.RESSTATECODE;

        TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEOut = (TD_M_RESOURCESTATETDO)tmTMTableModule.selByPK(context, ddoTD_M_RESOURCESTATEIn, typeof(TD_M_RESOURCESTATETDO), null, "TD_M_RESOURCESTATE", null);

        if (ddoTD_M_RESOURCESTATEOut == null )
            RESSTATE.Text = ddoTL_R_ICUSEROut.RESSTATECODE;
        else 
            RESSTATE.Text = ddoTD_M_RESOURCESTATEOut.RESSTATE;

        //计算费用
        //当前操作员有卡费不收取权
        if (hidFlagcost.Value == "1")
        {
            if (Costacp.Checked == true)
                CardcostFee.Text = "0";
            else CardcostFee.Text = ((Convert.ToDecimal(hidCardcostFee.Value) + ((Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE)) / 100))).ToString();
        }
        //当前操作员售卡费用类型为卡押金,且费用不为空
        else if (hidFlagcost.Value == "2")
            DepositFee.Text = hidDepositFee.Value;
        //当前操作员售卡费用类型为卡费,且费用不为空
        else if (hidFlagcost.Value == "3")
            CardcostFee.Text = Convert.ToDecimal(hidCardcostFee.Value).ToString();
        //当前操作员售卡费用类型为卡费,且费用为空
        else if (hidFlagcost.Value == "4")
            CardcostFee.Text = ((Convert.ToDecimal(hidCardcostFee.Value)) + ((Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE)) / 100)).ToString();
        else
            DepositFee.Text = ((Convert.ToDecimal(hidDepositFee.Value)) + ((Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE)) / 100)).ToString("0.00");

        Total.Text = ((Convert.ToDecimal(CardcostFee.Text)) + (Convert.ToDecimal(DepositFee.Text)) + (Convert.ToDecimal(OtherFee.Text))).ToString("0.00");
        
        hidAccRecv.Value = Total.Text;
        txtRealRecv.Text = Convert.ToInt32(Convert.ToDecimal(Total.Text)).ToString();

        if (Convert.ToDecimal(hiddencMoney.Value) != 0)
        {
            context.AddError("A001001144");
            return;
        }

        //卡库存状态为出库或分配时,售卡按钮可用
        if (ddoTL_R_ICUSEROut.RESSTATECODE == "01" || ddoTL_R_ICUSEROut.RESSTATECODE == "05")
        {
            btnSale.Enabled = true;
        }
        //卡状态为售出时,充值按钮可用
        else if (ddoTL_R_ICUSEROut.RESSTATECODE == "06")
        {
            btnSupply.Enabled = true;
        }
        else if (ddoTL_R_ICUSEROut.RESSTATECODE == "12")
        {
            context.AddError("A001001141");
            return;
        }
        btnPrintSJ.Enabled = false;
        btnPrintPZ.Enabled = false;
        
    }

    //根据是否选中不收取卡费更新费用信息
    protected void Costacp_CheckedChanged(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        if (Costacp.Checked == true)
        {
            CardcostFee.Text = "0";
            Total.Text = ((Convert.ToDecimal(CardcostFee.Text)) + (Convert.ToDecimal(DepositFee.Text)) + (Convert.ToDecimal(OtherFee.Text))).ToString("0.00");
            txtRealRecv.Text = Convert.ToInt32(Convert.ToDecimal(Total.Text)).ToString();
        }

        else if (txtCardno.Text != "")
        {
            TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
            ddoTL_R_ICUSERIn.CARDNO = txtCardno.Text;

            TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

            CardcostFee.Text = ((Convert.ToDecimal(hiddenCardcostFee.Value)) + ((Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE)) / 100)).ToString();
            Total.Text = ((Convert.ToDecimal(CardcostFee.Text)) + (Convert.ToDecimal(DepositFee.Text)) + (Convert.ToDecimal(OtherFee.Text))).ToString("0.00");
            txtRealRecv.Text = Convert.ToInt32(Convert.ToDecimal(Total.Text)).ToString();
        }

        else if (txtCardno.Text == "")
        {
            CardcostFee.Text = "0";
            Total.Text = ((Convert.ToDecimal(CardcostFee.Text)) + (Convert.ToDecimal(DepositFee.Text)) + (Convert.ToDecimal(OtherFee.Text))).ToString("0.00");
        }

    }
    //对卡费输入值进行检验
    private Boolean CardCost()
    {
        if (!Validation.isPosRealNum(CardcostFee.Text))
            context.AddError("A001001142");

        return !(context.hasError());
    }
    //卡费改变时,更新费用信息
    protected void CardcostFee_Change(object sender, EventArgs e)
    {
        if (!CardCost())
            return;

        if (txtCardno.Text != "")
        {
            Total.Text = ((Convert.ToDecimal(CardcostFee.Text)) + (Convert.ToDecimal(DepositFee.Text)) + (Convert.ToDecimal(OtherFee.Text))).ToString("0.00");
            txtRealRecv.Text = Convert.ToInt32(Convert.ToDecimal(Total.Text)).ToString();
        }

    }
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidpdotype.Value == "01")
        {
            if (hidWarning.Value == "yes")
            {
                btnSale.Enabled = true;
            }
            else if (hidWarning.Value == "writeSuccess")
            {
                AddMessage("前台写卡成功");
                clearCustInfo(txtCardno,txtCusname, txtCustbirth, selPapertype, txtCustpaperno, selCustsex, txtCustphone,
                    txtCustpost, txtCustaddr, txtEmail, txtRemark);
            }
            else if (hidWarning.Value == "writeFail")
            {
                context.AddError("前台写卡失败");
            }
            if (chkShouju.Checked && btnPrintSJ.Enabled)
            {
                //ScriptManager.RegisterStartupScript(
                //    this, this.GetType(), "writeCardScript",
                //    "printShouJu();", true);
                ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "printInvoice();", true);
            }
            hidWarning.Value = "";
        }
        else if (hidpdotype.Value == "02")
        {
            if (hidWarning.Value == "CashChargeConfirm")
            {
                btnSupply_Click(sender, e);
            }
            else if (hidWarning.Value == "rewriteCard") // 重新写卡，生产新的令牌
            {
                hidCardReaderToken.Value = cardReader.createToken(context);
                ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "writeCardWithCheck();", true);
            }
            else if (hidWarning.Value == "yes")
            {
                btnSupply.Enabled = true;
            }
            else if (hidWarning.Value == "writeSuccess")
            {
                SP_PB_updateCardTradePDO pdo = new SP_PB_updateCardTradePDO();
                pdo.CARDTRADENO = hiddentradeno.Value;
                pdo.TRADEID = hidoutTradeid.Value;

                bool ok = TMStorePModule.Excute(context, pdo);

                if (ok)
                {
                    AddMessage("前台写卡成功");
                }
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
            
        }
        hidCardnoForCheck.Value = "";//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致
    }

    //售卡
    protected void btnSale_Click(object sender, EventArgs e)
    {
        //判断售卡权限
        checkCardState(txtCardno.Text);
        if (context.hasError()) return;

        if (txtRealRecv.Text == null || txtRealRecv.Text == "")
        {
            context.AddError("A001001143");
            return;
        }
        //用户信息判断
        if (!SaleInfoValidation())
            return;

        //吴江B卡判断
        if (txtCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("不是吴江B卡,不能在本业务界面操作");
            return;
        }
        StringBuilder strBuilder = new StringBuilder();

        SP_PB_SaleCard_COMMITPDO pdo = new SP_PB_SaleCard_COMMITPDO();
        //PDO赋值
        pdo.ID = DealString.GetRecordID(hiddentradeno.Value, LabAsn.Text);
        //pdo.ID =hiddentradeno.Value + DateTime.Now.ToString("MMddhhmmss") + LabAsn.Text.Substring(12, 4);
        pdo.CARDNO = txtCardno.Text;
        pdo.CARDTYPECODE = hiddenLabCardtype.Value;
        pdo.CARDMONEY = Convert.ToInt32(Convert.ToDecimal(cMoney.Text)*100);
        pdo.DEPOSIT = Convert.ToInt32(Convert.ToDecimal(DepositFee.Text)*100);
        pdo.CARDCOST = Convert.ToInt32(Convert.ToDecimal(CardcostFee.Text)*100);
        pdo.CARDTRADENO = hiddentradeno.Value;
        pdo.SELLCHANNELCODE = "01";
        pdo.SERSTAKETAG = "0";
        pdo.TRADETYPECODE = "01";
        pdo.CUSTRECTYPECODE = (Signtype.Checked == true)? "1" : "0";

        //加密 ADD BY JIANGBB 2012-04-19
        pdo.CUSTNAME = txtCusname.Text.Trim();
        pdo.CUSTPHONE = txtCustphone.Text.Trim();
        pdo.CUSTADDR = txtCustaddr.Text.Trim();
        AESHelp.AESEncrypt(pdo.CUSTNAME, ref strBuilder);
        pdo.CUSTNAME = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(pdo.CUSTPHONE, ref strBuilder);
        pdo.CUSTPHONE = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(pdo.CUSTADDR, ref strBuilder);
        pdo.CUSTADDR = strBuilder.ToString();


        pdo.CUSTSEX = selCustsex.SelectedValue;
        if (txtCustbirth.Text.Trim() != "")
        {
            String[] arr = (txtCustbirth.Text.Trim()).Split('-');

            String cDate = arr[0] + arr[1] + arr[2];

            pdo.CUSTBIRTH = cDate;
        }

        else
        {
            pdo.CUSTBIRTH = txtCustbirth.Text.Trim();
        }

        pdo.PAPERTYPECODE = selPapertype.SelectedValue;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustpaperno.Text.Trim(),ref strBuilder);
        pdo.PAPERNO = strBuilder.ToString();

        pdo.CUSTPOST = txtCustpost.Text.Trim();
        pdo.CUSTEMAIL = txtEmail.Text.Trim();
        pdo.REMARK = txtRemark.Text.Trim();
        pdo.TERMNO = "112233445566";
        pdo.OPERCARDNO = context.s_CardID;
        pdo.OTHERFEE = Convert.ToInt32((Convert.ToDecimal(OtherFee.Text)) * 100);
        hidpdotype.Value = pdo.TRADETYPECODE;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            hidCardnoForCheck.Value = txtCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致
            //售卡成功时提示
            //AddMessage("M001001001");
            btnPrintSJ.Enabled = true;

            //ASHelper.prepareShouJu(ptnShouJu, txtCardno.Text, context.s_UserName, DepositFee.Text);
            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, txtCusname.Text, "售卡", "0.00", 
            		DepositFee.Text, "", txtCustpaperno.Text, "0.00",
                "", DepositFee.Text, context.s_UserID, context.s_DepartName, selPapertype.Text, "0.00", "");

            //写卡
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "saleCard();", true);
            
            //ptnShouJu.Enabled = true;
            ptnPingZheng.Enabled = true;

            //清除页面显示
            //foreach (Control con in this.Page.Controls)
            //{
            //    ClearControl(con);
            //}
            //售卡按钮不可用
            btnSale.Enabled = false;
            //重新初始化
            initLoad(sender, e);
            initLoad_Supply(sender, e);
            btnSupply.Enabled = false;
            
        }
    }

    protected void initLoad_Supply(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从前台业务交易费用表中读取充值费用数据
        TD_M_TRADEFEETDO tdoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        tdoTD_M_TRADEFEETDOIn.TRADETYPECODE = "02";

        TD_M_TRADEFEETDO[] tdoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001001137", "TD_M_TRADEFEE", null);

        for (int i = 0; i < tdoTD_M_TRADEFEEOutArr.Length; i++)
        {
            //"01"为充值
            if (tdoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "01")
                hidSupplyFee.Value = ((Convert.ToDecimal(tdoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //"99"为其他费用
            else if (tdoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "99")
                hidSupplyOtherFee.Value = ((Convert.ToDecimal(tdoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        }

        SupplyFee.Text = hidSupplyFee.Value;
        SupplyOtherFee.Text = hidSupplyOtherFee.Value;

        //查询当前操作员充值默认值
        TD_M_INSIDESTAFFPARAMETERTDO tdoTD_M_INSIDESTAFFPARAMETERIn = new TD_M_INSIDESTAFFPARAMETERTDO();
        tdoTD_M_INSIDESTAFFPARAMETERIn.STAFFNO = context.s_UserID;

        TD_M_INSIDESTAFFPARAMETERTDO tdoTD_M_INSIDESTAFFPARAMETEROut = (TD_M_INSIDESTAFFPARAMETERTDO)tmTMTableModule.selByPK(context, tdoTD_M_INSIDESTAFFPARAMETERIn, typeof(TD_M_INSIDESTAFFPARAMETERTDO), null, "TD_M_INSIDESTAFFPARAMETER", null);
        //当前操作员没有充值默认值
        if (tdoTD_M_INSIDESTAFFPARAMETEROut == null)
        {
            TotalSupply.Text = (Convert.ToDecimal(SupplyOtherFee.Text) + Convert.ToDecimal(SupplyOtherFee.Text)).ToString("0.00");
        }
        //当前操作员有充值默认值
        else if (tdoTD_M_INSIDESTAFFPARAMETEROut.SUPPLEMONEY != -1)
        {
            SupplyFee.Text = (Convert.ToDecimal(SupplyFee.Text) + (Convert.ToDecimal(tdoTD_M_INSIDESTAFFPARAMETEROut.SUPPLEMONEY)) / 100).ToString("0.00");
            SupplyMoney.Text = (Convert.ToDecimal(tdoTD_M_INSIDESTAFFPARAMETEROut.SUPPLEMONEY) / 100).ToString("0");
            TotalSupply.Text = (Convert.ToDecimal(SupplyFee.Text) + Convert.ToDecimal(SupplyOtherFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");
        }
        //当前操作员没有充值默认值
        else if (tdoTD_M_INSIDESTAFFPARAMETEROut.SUPPLEMONEY == -1)
        {
            TotalSupply.Text = (Convert.ToDecimal(SupplyOtherFee.Text) + Convert.ToDecimal(SupplyOtherFee.Text)).ToString("0.00");

        }
    }

    //输入金额改变时更新费用信息
    protected void SupplyMoney_Changed(object sender, EventArgs e)
    {
        SupplyFee.Text = ((Convert.ToDecimal(hidSupplyFee.Value) * 100) + (Convert.ToDecimal(SupplyMoney.Text))).ToString("0.00");
        TotalSupply.Text = (Convert.ToDecimal(SupplyFee.Text) + Convert.ToDecimal(SupplyOtherFee.Text)).ToString("0.00");        
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
    private Boolean btnReadCardProcess()
    {
    	//检验卡片是否已经启用
      if (String.Compare(hiddensDate.Value, DateTime.Today.ToString("yyyyMMdd")) > 0) 
      {
          context.AddError("卡片尚未启用");
      }
        
        return !(context.hasError());
    }

    protected void btnSupply_Click(object sender, EventArgs e)
    {
    		//卡片启用判断
        if (!btnReadCardProcess())
            return;
        
        //充值金额判断
        if (!inportValidation())
            return;

        //吴江B卡判断
        if (txtCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("不是吴江B卡,不能在本业务界面操作");
            return;
        }
        return;
        
        TMTableModule tmTMTableModule = new TMTableModule();

        //从IC卡电子钱包账户表中读取数据
        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text;

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null, "TF_F_CARDEWALLETACC", null);
        
        //调用现金充值存储过程
        SP_PB_ChargePDO pdo = new SP_PB_ChargePDO();
        pdo.ID = DealString.GetRecordID(hiddentradeno.Value, LabAsn.Text);
        //pdo.ID = hiddentradeno.Value + DateTime.Now.ToString("MMddhhmmss") + LabAsn.Text.Substring(12, 4);
        pdo.CARDNO = txtCardno.Text;
        pdo.CARDTRADENO = hiddentradeno.Value;
        pdo.CARDMONEY = Convert.ToInt32(Convert.ToDecimal(cMoney.Text) * 100);
        pdo.CARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;
        pdo.ASN = LabAsn.Text;
        pdo.CARDTYPECODE = hiddenLabCardtype.Value;
        pdo.TRADETYPECODE = "02";
        pdo.SUPPLYMONEY = (Convert.ToInt32(Convert.ToDecimal(SupplyMoney.Text.Trim())) * 100);
        pdo.OTHERFEE = Convert.ToInt32(Convert.ToDecimal(SupplyOtherFee.Text) * 100);
        pdo.TERMNO = "112233445566";
        hidSupplyMoney.Value = "" + pdo.SUPPLYMONEY;
        hidpdotype.Value = pdo.TRADETYPECODE;
        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (ok)
        {
            hidCardnoForCheck.Value = txtCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致
            //AddMessage("M001002001");
            hidoutTradeid.Value = "" + ((SP_PB_ChargePDO)pdoOut).TRADEID;
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                    "writeCardScript", "chargeCard();", true);
            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, txtCusname.Text, "充值", SupplyMoney.Text
                , "", "", txtCustpaperno.Text, (Convert.ToDecimal(pdo.CARDMONEY + pdo.SUPPLYMONEY) / 100).ToString("0.00"),
                "", SupplyMoney.Text, context.s_UserID, context.s_DepartName, selPapertype.Text, "0.00", "");
            //foreach (Control con in this.Page.Controls)
            //{
            //    ClearControl(con);
            //}
            initLoad(sender, e);
            initLoad_Supply(sender, e);
            btnSupply.Enabled = false;
        }
    }

    //坏卡登记判断
    private Boolean badCardbookinValidation()
    {
        //对卡号进行非空、长度、数字检验

        if (txtCardno.Text.Trim() == "")
            context.AddError("A001004113", txtCardno);
        else
        {
            if (Validation.strLen(txtCardno.Text.Trim()) != 16)
                context.AddError("A001004114", txtCardno);
            else if (!Validation.isNum(txtCardno.Text.Trim()))
                context.AddError("A001004115", txtCardno);
        }

        return  !(context.hasError());
    }

    protected void btnbadCard_Click(object sender, EventArgs e)
    {
        //对输入卡号进行检验
        if (!badCardbookinValidation())
            return;

        //吴江B卡判断
        if (txtCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("不是吴江B卡,不能在本业务界面操作");
            return;
        }
        
        TMTableModule tmTMTableModule = new TMTableModule();

        SP_PB_BadCardPDO pdo = new SP_PB_BadCardPDO();

        //存储过程赋值
        pdo.CARDNO = txtCardno.Text;
        pdo.TRADETYPECODE = "93";

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M001001003");
            //foreach (Control con in this.Page.Controls)
            //{
            //    ClearControl(con);
            //}
            initLoad(sender, e);
            initLoad_Supply(sender, e);
        }
    }
    
}
