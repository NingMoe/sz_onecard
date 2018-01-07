using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using Common;
using DataExchange;
using Master;
using PDO.PersonalBusiness;
using TDO.BusinessCode;
using TDO.CardManager;
using TDO.ResourceManager;
using TDO.UserManager;
using TM;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;

public partial class ASP_GroupCard_GC_ZZReceiveCard : Master.FrontMaster
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

            ASHelper.initSexList(selCustsex);
            initLoad(sender, e);
            hidAccRecv.Value = Total.Text;

            TMTableModule tmTMTableModule = new TMTableModule();

            //查询当前操作员是否具有售卡充值显示权限

            TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
            string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '201002' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
            DataTable dataSupply = tmTMTableModule.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);

            //查询是否出租车部门
            TD_M_INSIDESTAFFROLETDO ddoTD_M_INSIDESTAFFROLEIn = new TD_M_INSIDESTAFFROLETDO();
            string taix = " Select * from TD_M_INSIDESTAFFROLE where staffno = '" + context.s_UserID + "' " +
                            " And ( roleno = '1100' or roleno = '1110' )";
            DataTable datataix = tmTMTableModule.selByPKDataTable(context, ddoTD_M_INSIDESTAFFROLEIn, null, taix, 0);

            if (datataix.Rows.Count == 0)
            {
                CardcostFee.Attributes["readonly"] = "true";
            }
            //查询用户打印方式 add by youyue 20140722
            string sql = "select PRINTMODE from TD_M_INSIDESTAFFPRINT where STAFFNO = '" + context.s_UserID + "'";
            context.DBOpen("Select");
            DataTable dt = context.ExecuteReader(sql);
            if (dt.Rows.Count == 1 && dt.Rows[0]["PRINTMODE"].ToString().Trim() == "1")
            {
                chkPingzheng.Checked = true;//打印方式是针式打印
            }
            else if (dt.Rows.Count == 1 && dt.Rows[0]["PRINTMODE"].ToString().Trim() == "2")
            {
                chkPingzhengRemin.Checked = true;//打印方式是热敏打印
            }
            else
            {
                chkPingzheng.Checked = true;//如果没有设置则默认是针式打印
            }


        }
    }

    protected void initLoad(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //hidFlagcost.Value = "0";
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

        #region 原押金收取方式
        ////查询当前操作员卡费不收取权

        //TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();

        //string strPow = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '201003' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
        //DataTable dataPower = tmTMTableModule.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strPow, 0);

        ////当前操作员有卡费不收取权
        //if (dataPower.Rows.Count != 0)
        //{
        //    DepType.Text = "卡费";
        //    Costacp.Visible = true;
        //    hidCardcostFee.Value = hiddenCardcostFee.Value;
        //    hidDepositFee.Value = hiddenDepositFee.Value;
        //    hidFlagcost.Value = "1";
        //}

        ////当前操作员没有卡费不收取权

        //else if (dataPower.Rows.Count == 0)
        //{
        //    TD_M_INSIDESTAFFPARAMETERTDO ddoTD_M_INSIDESTAFFPARAMETERIn = new TD_M_INSIDESTAFFPARAMETERTDO();
        //    ddoTD_M_INSIDESTAFFPARAMETERIn.STAFFNO = context.s_UserID;

        //    TD_M_INSIDESTAFFPARAMETERTDO ddoTD_M_INSIDESTAFFPARAMETEROut = (TD_M_INSIDESTAFFPARAMETERTDO)tmTMTableModule.selByPK(context, ddoTD_M_INSIDESTAFFPARAMETERIn, typeof(TD_M_INSIDESTAFFPARAMETERTDO), null, "TD_M_INSIDESTAFFPARAMETER", null);
        //    //无记录时售卡费用为卡押金
        //    if (ddoTD_M_INSIDESTAFFPARAMETEROut == null)
        //    {
        //        DepType.Text = "卡押金";
        //        hidCardcostFee.Value = hiddenCardcostFee.Value;
        //        hidDepositFee.Value = hiddenDepositFee.Value;
        //    }
        //    //当前操作员卡费修改类型为卡费
        //    else if (ddoTD_M_INSIDESTAFFPARAMETEROut.CARDCOSTSTAT == "1")
        //    {
        //        DepType.Text = "卡费";
        //        hidDepositFee.Value = "0.00";
        //        //卡费默认值不为空
        //        if (ddoTD_M_INSIDESTAFFPARAMETEROut.CARDCOST != -1)
        //        {
        //            hidCardcostFee.Value = (Convert.ToDecimal(hiddenCardcostFee.Value) + (Convert.ToDecimal(ddoTD_M_INSIDESTAFFPARAMETEROut.CARDCOST)) / 100).ToString("0.00");
        //            hidFlagcost.Value = "3";
        //        }
        //        //卡费默认值为空

        //        else
        //        {
        //            hidCardcostFee.Value = hiddenCardcostFee.Value;
        //            hidFlagcost.Value = "4";
        //        }
        //    }

        //   //当前操作员卡费修改类型为卡押金

        //    else if (ddoTD_M_INSIDESTAFFPARAMETEROut.CARDCOSTSTAT == "2")
        //    {
        //        DepType.Text = "卡押金";
        //        hidCardcostFee.Value = "0.00";

        //        if (ddoTD_M_INSIDESTAFFPARAMETEROut.CARDCOST != -1)
        //        {
        //            hidDepositFee.Value = (Convert.ToDecimal(hiddenDepositFee.Value) + (Convert.ToDecimal(ddoTD_M_INSIDESTAFFPARAMETEROut.CARDCOST)) / 100).ToString("0.00");
        //            hidFlagcost.Value = "2";
        //        }
        //        else
        //        {
        //            hidDepositFee.Value = hiddenDepositFee.Value;
        //            hidFlagcost.Value = "0";
        //        }
        //    }
        //}
        #endregion
        CardcostFee.Text = Convert.ToDecimal(hiddenCardcostFee.Value).ToString();
        DepositFee.Text = hiddenDepositFee.Value;
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

            if (txtCusname.Text.Trim() == "")
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

        //添加对市民卡的验证
        SP_SmkCheckPDO pdo = new SP_SmkCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok == false)
        {
            return;
        }

        #region add by shil 20130909,如果是旅游年卡，则不允许在该页面办理业务
        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面售出
        bool cardTypeOk = CommonHelper.allowCardtype(context, txtCardno.Text, "5101", "5103");
        if (cardTypeOk == false)
        {
            return;
        }

        #endregion

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

        //获取卡售卡方式
        hidSaletype.Value = ddoTL_R_ICUSEROut.SALETYPE;

        if (hidSaletype.Value != "01" && hidSaletype.Value != "02")
        {
            context.AddError("未找到正确的售卡方式");
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
        //售卡方式为卡费方式
        if (hidSaletype.Value.Equals("01"))
        {
            DepType.Text = "卡费";
            CardcostFee.Text = (Convert.ToDecimal(hiddenCardcostFee.Value) + (Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE)) / 100).ToString("0.00");
            DepositFee.Text = Convert.ToDecimal(hiddenDepositFee.Value).ToString();
        }
        //售卡方式为押金方式
        if (hidSaletype.Value.Equals("02"))
        {
            DepType.Text = "卡押金";
            CardcostFee.Text = Convert.ToDecimal(hiddenCardcostFee.Value).ToString();
            DepositFee.Text = (Convert.ToDecimal(hiddenDepositFee.Value) + (Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE)) / 100).ToString("0.00");
        }

        #region 原有押金卡费计算
        ////当前操作员有卡费不收取权
        //if (hidFlagcost.Value == "1")
        //{
        //    if (Costacp.Checked == true)
        //        CardcostFee.Text = "0";
        //    else CardcostFee.Text = ((Convert.ToDecimal(hidCardcostFee.Value) + ((Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE)) / 100))).ToString();
        //}
        ////当前操作员售卡费用类型为卡押金,且费用不为空
        //else if (hidFlagcost.Value == "2")
        //    DepositFee.Text = hidDepositFee.Value;
        ////当前操作员售卡费用类型为卡费,且费用不为空
        //else if (hidFlagcost.Value == "3")
        //    CardcostFee.Text = Convert.ToDecimal(hidCardcostFee.Value).ToString();
        ////当前操作员售卡费用类型为卡费,且费用为空

        //else if (hidFlagcost.Value == "4")
        //    CardcostFee.Text = ((Convert.ToDecimal(hidCardcostFee.Value)) + ((Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE)) / 100)).ToString();
        //else
        //    DepositFee.Text = ((Convert.ToDecimal(hidDepositFee.Value)) + ((Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE)) / 100)).ToString("0.00");
        #endregion

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

            //判断是否记名卡
            CommonHelper.readCardJiMingState(context, txtCardno.Text, hidIsJiMing);

        }
        else if (ddoTL_R_ICUSEROut.RESSTATECODE == "12")
        {
            context.AddError("A001001141");
            return;
        }

        btnPrintSKPZ.Enabled = false;

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

                #region add by liuhe 20111231 添加对代理营业厅预付款的验证,扣费后如果超过预警额度则提示
                int opMoney = Convert.ToInt32(Convert.ToDecimal(DepositFee.Text) * 100)
                    + Convert.ToInt32(Convert.ToDecimal(CardcostFee.Text) * 100)
                    + Convert.ToInt32((Convert.ToDecimal(OtherFee.Text)) * 100);

                DeptBalunitHelper.ValdatePrepay(context, opMoney, "1");
                #endregion 

                #region 写卡成功，张家港衍生卡信息同步

                if (hidCardIDZJG.Value.Length >= 6 && hidCardIDZJG.Value.Substring(0, 6) == "215061")
                {
                    string tradeID = hidTradeIDZJG.Value;
                    string syncCardID = hidCardIDZJG.Value;
                    string[] parm = new string[2];
                    parm[0] = tradeID;
                    parm[1] = syncCardID;
                    DataTable syncData = SPHelper.callQuery("SP_RC_QUERY", context, "QueryCardSaleInfoSync", parm);
                    //证件类型转换
                    string npaperType = syncData.Rows[0]["PAPER_TYPE"].ToString();
                    switch (npaperType)
                    {
                        case "00": syncData.Rows[0]["PAPER_TYPE"] = "0"; break;//身份证

                        case "01": syncData.Rows[0]["PAPER_TYPE"] = "8"; break;//学生证

                        case "02": syncData.Rows[0]["PAPER_TYPE"] = "6"; break;//军官证

                        case "05": syncData.Rows[0]["PAPER_TYPE"] = "2"; break;//护照
                        case "06": syncData.Rows[0]["PAPER_TYPE"] = "3"; break;//港澳居民来往内地通行证

                        case "07": syncData.Rows[0]["PAPER_TYPE"] = "1"; break;//户口簿

                        case "08": syncData.Rows[0]["PAPER_TYPE"] = "8"; break;//武警证

                        case "09": syncData.Rows[0]["PAPER_TYPE"] = "4"; break;//台湾同胞来往内地通行证

                        case "99": syncData.Rows[0]["PAPER_TYPE"] = "8"; break;//其它类型证件
                        default: break;
                    }
                    //姓名，证件号码解密

                    CommonHelper.AESDeEncrypt(syncData, new List<string>(new string[] { "NAME", "PAPER_NO" }));

                    //调用后台接口
                    SyncRequest syncRequest;
                    bool sync = DataExchangeHelp.ParseFormDataTable(syncData, tradeID, out syncRequest);
                    if (sync == true)
                    {
                        SyncRequest syncResponse;
                        string msg;
                        bool succ = DataExchangeHelp.Sync(syncRequest, out syncResponse, out msg);
                        if (!succ)
                        {
                            context.AddError("调用接口失败:" + msg);
                        }
                        else
                        {
                            AddMessage("接口调用成功!");
                        }
                    }
                    else
                    {
                        context.AddError("调用接口转换错误!");
                    }
                }
                #endregion

                clearCustInfo(txtCardno, txtCusname, txtCustbirth, selPapertype, txtCustpaperno, selCustsex, txtCustphone,
                    txtCustpost, txtCustaddr, txtEmail, txtRemark);
            }
            else if (hidWarning.Value == "writeFail")
            {
                context.AddError("前台写卡失败");
            }

            if (chkPingzheng.Checked && btnPrintSKPZ.Enabled)
            {
                ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "printInvoice();", true);
            }
            if (chkPingzhengRemin.Checked && btnPrintSKPZ.Enabled) //add by youyue  增加热敏打印方式
            {
                ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "printRMInvoice();", true);
            }
            hidWarning.Value = "";

            hidCardIDZJG.Value = "";
            hidTradeIDZJG.Value = "";
        }
    }

    //售卡
    protected void btnSale_Click(object sender, EventArgs e)
    {
        #region add by liuhe 20111231 添加对代理营业厅预付款的验证,提交前如果扣费后不足最低额度则返回
        int opMoney = Convert.ToInt32(Convert.ToDecimal(DepositFee.Text) * 100)
                    + Convert.ToInt32(Convert.ToDecimal(CardcostFee.Text) * 100)
                    + Convert.ToInt32((Convert.ToDecimal(OtherFee.Text)) * 100);
        if (DeptBalunitHelper.ValdatePrepay(context, opMoney, "2") == false)
        {
            return;
        }
        #endregion 

        //验证取件码
        if (txtFetchCode.Text.Trim() == "")
            context.AddError("A009422102:取件码为空", txtFetchCode);
        else if (Validation.strLen(txtFetchCode.Text.Trim()) != 14)
            context.AddError("A009422103:取件码长度不为14位", txtFetchCode);

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

        //调用激活领卡接口
        Dictionary<string, string> postData = new Dictionary<string, string>();
        postData.Add("channelCode", "ONECARD");
        postData.Add("fetchCode", txtFetchCode.Text);
        postData.Add("posNo", "");
        postData.Add("psamNo", "");
        postData.Add("cardNo", txtCardno.Text);
        postData.Add("remark", context.s_DepartID + context.s_UserID);

        string jsonResponse = HttpHelper.ZZPostRequest(HttpHelper.TradeType.ZZActivationCard, postData);

        string code = "";
        string message = "";
        string tradeState = "";
        string fetchCodeState = "";
        string cardState = "";
        string endTime = "";
        JObject deserObject = (JObject)JsonConvert.DeserializeObject(jsonResponse);
        foreach (JProperty itemProperty in deserObject.Properties())
        {
            string propertyName = itemProperty.Name;
            if (propertyName == "respCode")
            {
                code = itemProperty.Value.ToString();
            }
            else if (propertyName == "respDesc")
            {
                message = itemProperty.Value.ToString();
            }
            else if (propertyName == "tradeState")
            {
                tradeState = itemProperty.Value.ToString();
            }
            else if (propertyName == "fetchCodeState")
            {
                fetchCodeState = itemProperty.Value.ToString();
            }
            else if (propertyName == "cardState")
            {
                cardState = itemProperty.Value.ToString();
            }
            else if (propertyName == "endTime")
            {
                endTime = itemProperty.Value.ToString();
            }
        }

        if (code == "0000") //表示成功
        {
            context.AddMessage("处理成功");

            context.SPOpen();
            context.AddField("p_paperTypeCode").Value = selPapertype.SelectedValue;
            StringBuilder strBuilder = new StringBuilder();
            AESHelp.AESEncrypt(txtCustpaperno.Text.Trim(), ref strBuilder);
            context.AddField("p_paperNo").Value = strBuilder.ToString();
            strBuilder = new StringBuilder();
            AESHelp.AESEncrypt(txtCusname.Text.Trim(), ref strBuilder);
            context.AddField("p_custName").Value = strBuilder.ToString();
            context.AddField("p_operName").Value = context.s_UserName;
            context.AddField("p_deptName").Value = context.s_DepartName;
            bool warnok = context.ExecuteSP("SP_WA_SaleCardForWarn");
            if (!warnok)
            {
                context.ErrorMessage.Clear();
            }

            //售卡成功时提示

            hidCardnoForCheck.Value = txtCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致

            btnPrintSKPZ.Enabled = true;

            //add by jiangbb 2012-05-14
            string dePosit = string.Empty;
            if (hidSaletype.Value == "01")   //售卡方式为卡费
            {
                dePosit = CardcostFee.Text + "(卡费)";
            }
            else
            {
                dePosit = DepositFee.Text;
            }

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

            //add by jiangbb 2012-05-14 售卡打印凭证
            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, txtCusname.Text, "售卡", txtRealRecv.Text,
                    dePosit, "", txtCustpaperno.Text, cMoney.Text,
                    "", txtRealRecv.Text, context.s_UserID, context.s_DepartName, paperName, "0.00", "");
            //add by youyue 20140718 售卡热敏打印凭证数据准备
            ASHelper.preparePingZheng(PrintRMPingZheng, txtCardno.Text, txtCusname.Text, "售卡", txtRealRecv.Text,
                    dePosit, "", txtCustpaperno.Text, cMoney.Text,
                    "", txtRealRecv.Text, context.s_UserID, context.s_DepartName, paperName, "0.00", "");
            //写卡
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "saleCard();", true);

            ptnShouJu.Enabled = true;

            //售卡按钮不可用

            btnSale.Enabled = false;
            //重新初始化

            initLoad(sender, e);
            
        }
        else
        {
            context.AddMessage("处理失败,失败原因：" + message);
        }
        
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

        return !(context.hasError());
    }

    protected void btnbadCard_Click(object sender, EventArgs e)
    {
        //对输入卡号进行检验

        if (!badCardbookinValidation())
            return;

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
        }
    }


}
