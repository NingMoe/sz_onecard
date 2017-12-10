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
using Common;
using TDO.BalanceChannel;
using TM;
using TDO.BusinessCode;
using PDO.TaxiService;
using System.Text.RegularExpressions;
using TDO.CardManager;
using TDO.UserManager;
using Master;

public partial class ASP_TaxiService_TS_NewCard : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            TMTableModule tmTMTableModule = new TMTableModule();
            // 初始化银行列表

            //初始化转出银行,开户银行下拉列表值

            //TD_M_BANKTDO ddoTD_M_BANKIn = new TD_M_BANKTDO();
            //TD_M_BANKTDO[] ddoTD_M_BANKOutArr = (TD_M_BANKTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_BANKIn, typeof(TD_M_BANKTDO), "S003100112", "", null);
            //ControlDeal.SelectBoxFill(selHouseBank.Items, ddoTD_M_BANKOutArr, "BANK", "BANKCODE", true);
            //默认为银行


            //初始银行为农行
            selHouseBank.Items.Add(new ListItem("A059:中国农业银行苏州南门支行", "A059"));


            // 证件类型编码表

            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
            TD_M_PAPERTYPETDO[] ddoTD_M_PAPERTYPEOutArr = (TD_M_PAPERTYPETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), "S003100113", "", null);
            ControlDeal.SelectBoxFill(selPaperType.Items, ddoTD_M_PAPERTYPEOutArr, "PAPERTYPENAME", "PAPERTYPECODE", true);

            //默认为身份证
            selPaperType.SelectedValue = "00";

            // 单位编码
            TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
            tdoTD_M_CORPIn.CALLINGNO = "02"; // 出租行业
            TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), "S003100114", "TD_M_CORPCALLUSAGE", null);
            ControlDeal.SelectBoxFill(selUnitName.Items, tdoTD_M_CORPOutArr, "CORP", "CORPNO", true);

            // 性别
            ASHelper.initSexList(selStaffSex);

            //初始状态

            TSHelper.initInitState2(selState, false);

            // 初始化卡内状态

            TSHelper.initInitState2(selInState, true);


            // 初始化启用标志

            TSHelper.initUseState(selUseState);


            //正式综合测试时,设置生效
            if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

            txtCollectCardNo.Attributes.Add("readonly", "true");

            //设置商户经理编码
            //从内部员工编码表(TD_M_INSIDESTAFF)中读取数据，放入选定集团客户信息的客户经理下拉列表中
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), "S008111111", "TD_M_INSIDESTAFF_SVR", null);

            ControlDeal.SelectBoxFill(selServerMgr.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);

            //add by jiangbb 2012-07-03 初始化收款人账户类型下拉框列表框值
            selPurPoseType.Items.Add(new ListItem("---请选择---", ""));
            selPurPoseType.Items.Add(new ListItem("1:对公", "1"));
            selPurPoseType.Items.Add(new ListItem("2:对私", "2"));
            selPurPoseType.SelectedValue = "2";

            //设置司机信息为只读显示

            inStaffno.Attributes.Add("readonly", "true");
            inTaxiNo.Attributes.Add("readonly", "true");

            //设置提交不可用

            btnSubmit.Enabled = false;



        }
    }



    protected void selUnitName_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (selUnitName.SelectedValue == "")
        {
            selDeptName.Items.Clear();
            return;
        }
        // 选择部门名称

        TMTableModule tmTMTableModule = new TMTableModule();
        //从部门编码表(TD_M_CDEPART)中读取数据，放入下拉列表中


        TD_M_DEPARTTDO tdoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
        tdoTD_M_DEPARTIn.CORPNO = selUnitName.SelectedValue;

        TD_M_DEPARTTDO[] tdoTD_M_DEPARTOutArr = (TD_M_DEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null, "TD_M_DEPARTUSAGE", null);
        ControlDeal.SelectBoxFill(selDeptName.Items, tdoTD_M_DEPARTOutArr, "DEPART", "DEPARTNO", true);

    }

    private void SubmitValidate()
    {
        //是否读出卡号
        if (txtCardNo.Text.Trim() == "")
        {
            context.AddError("A003100032");
            return;
        }
        Validation valid = new Validation(context);

        //对司机工号进行非空、长度、数字检验


        if (Validation.isEmpty(txtDriverStaffNo))
            context.AddError("A003100001", txtDriverStaffNo);

        else if (Validation.strLen(txtDriverStaffNo.Text) != 6)
            context.AddError("A003100003", txtDriverStaffNo);

        else if (!Validation.isNum(txtDriverStaffNo.Text))
            context.AddError("A003100002", txtDriverStaffNo);


        // 司机工号确认
        bool b = false;
        b = valid.notEmpty(txtDriverStaffNoConfirm, "A003100004");
        if (b && txtDriverStaffNo.Text != txtDriverStaffNoConfirm.Text)
            context.AddError("A003100005", txtDriverStaffNoConfirm);

        // 车牌号

        b = valid.notEmpty(txtCarNo, "A003100006");

        if (b && Validation.strLen(txtCarNo.Text.Trim()) != 5)
            context.AddError("A003100037", txtCarNo);
        else if (b && !Validation.isCharNum(txtCarNo.Text.Trim()))
            context.AddError("A003100049", txtCarNo);

        // 银行编码
        valid.notEmpty(selHouseBank, "A003100008");

        // 银行账号
        b = valid.notEmpty(txtBankAccount, "A003100009");

        // 银行账号数字字符的判断(待确认)
        if (b)
        {
            if (Validation.strLen(txtBankAccount.Text) > 30)
                context.AddError("A003100038", txtBankAccount);

            //else if (!Validation.isCharNum(txtBankAccount.Text))
            //    context.AddError("A003100010", txtBankAccount);
        }

        // 银行账号确认
        b = valid.notEmpty(txtBankAccountConfirm, "A003100011");

        if (b && txtBankAccount.Text != txtBankAccountConfirm.Text)
            context.AddError("A003100012", txtBankAccountConfirm);

        // 员工姓名
        b = valid.notEmpty(txtStaffName, "A003100013");
        if (b && Validation.strLen(txtStaffName.Text) > 20)
            context.AddError("A003100039", txtStaffName);

        // 联系电话
        b = valid.notEmpty(txtContactPhone, "A003100015");
        if (b && Validation.strLen(txtContactPhone.Text) > 20)
            context.AddError("A003100040", txtContactPhone);

        // 车载电话
        b = valid.notEmpty(txtCarPhone, "A003100017");
        if (b && Validation.strLen(txtCarPhone.Text) > 15)
            context.AddError("A003100041", txtCarPhone);

        // 证件类型
        valid.notEmpty(selPaperType, "A003100014");

        // 证件号码
        b = valid.notEmpty(txtPaperNo, "A003100019");
        if (b)
        {
            //判断是否有客户信息查看权选
            if (CommonHelper.HasOperPower(context) || CommonHelper.GetPaperNo(hidForPaperNo.Value) != txtPaperNo.Text.Trim())
            {
                valid.beAlpha(txtPaperNo, "A003100020");
            }
            if (selPaperType.SelectedValue=="00" && !Validation.isPaperNo(txtPaperNo.Text.Trim()))
                context.AddError("A003100043:证件号码验证不通过", txtPaperNo);
        }
        else if (b && Validation.strLen(txtPaperNo.Text) > 20)
            context.AddError("A003100042", txtPaperNo);
       

        // 单位名称
        valid.notEmpty(selUnitName, "A003100021");

        // 部门名称
        //valid.notEmpty(selDeptName, "A003100022");

        // POS编号
        //b = valid.notEmpty(txtPosID, "A003100401");
        if (txtPosID.Text.Trim() != "")
        {
            if (Validation.strLen(txtPosID.Text) != 6)
                context.AddError("A003100403", txtPosID);
            else if (!Validation.isNum(txtPosID.Text))
                context.AddError("A003100402", txtPosID);
        }

        // 邮政编码
        txtPostCode.Text = txtPostCode.Text.Trim();
        b = txtPostCode.Text.Length > 0;
        if (b)
        {
            if (Validation.strLen(txtPostCode.Text) != 6)
                context.AddError("A003100027", txtPostCode);
            else if (!Validation.isNum(txtPostCode.Text))
                context.AddError("A003100026", txtPostCode);

        }

        //对收款人账户类型做非空校验
        if (selPurPoseType.SelectedValue == "")
        {
            context.AddError("A008100020", selPurPoseType);
        }

        // 电子邮件
        new Validation(context).isEMail(txtEmailAddr);

        // 联系地址
        txtContactAddr.Text = txtContactAddr.Text.Trim();
        b = txtContactAddr.Text.Length > 0;
        if (b && Validation.strLen(txtContactAddr.Text) > 50)
            context.AddError("A003100045", txtContactAddr);

        if (selServerMgr.SelectedValue == "")
            context.AddError("A003100136", selServerMgr);

    }


    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        //检测该卡是否开通电子钱包


        if (!chkSaleCard(txtCardNo.Text)) return;

        ClearTaxiInfo();

        //查询持卡人资料


        QueryCustomerRec(txtCardNo.Text);

        if (context.hasError()) return;

        txtCollectCardNo.Text = txtCardNo.Text;

        //启用提交按钮
        btnSubmit.Enabled = true;


    }

    private Boolean chkSaleCard(String strCardNo)
    {
        //判断卡是否已开通电子钱包


        TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
        ddoTF_F_CARDRECIn.CARDNO = strCardNo;

        TMTableModule tmTMTableModule = new TMTableModule();
        TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null, "TF_F_CARDREC_QUERY_BYCARDNO", null);

        if (ddoTF_F_CARDRECOut == null)
        {
            context.AddError("A003100035");
            return false;
        }
        return true;
    }


    private void QueryCustomerRec(String strCardNo)
    {
        //查询持卡人资料表信息
        TF_F_CUSTOMERRECTDO ddoIn = new TF_F_CUSTOMERRECTDO();
        ddoIn.CARDNO = strCardNo;
        TMTableModule tmTMTableModule = new TMTableModule();

        //TF_F_CUSTOMERRECTDO ddoOut = (TF_F_CUSTOMERRECTDO)tmTMTableModule.selByPK(context, ddoIn, 
        //    typeof(TF_F_CUSTOMERRECTDO), null, "TF_F_CUSTOMERREC_QUERY_BYCARDNO", null);

        DDOBase ddoBase = (DDOBase)tmTMTableModule.selByPK(context, ddoIn,
            typeof(TF_F_CUSTOMERRECTDO), null, "TF_F_CUSTOMERREC_QUERY_BYCARDNO", null);

        ddoBase = CommonHelper.AESDeEncrypt(ddoBase);

        TF_F_CUSTOMERRECTDO ddoOut = (TF_F_CUSTOMERRECTDO)ddoBase;
        if (ddoOut == null)
        {
            context.AddError("A003100135");
            return;
        }

        txtStaffName.Text = ddoOut.CUSTNAME;

        if (ddoOut.PAPERTYPECODE.Trim() == "00")
        {
            txtPaperNo.Text = ddoOut.PAPERNO;
        }

        txtContactPhone.Text = ddoOut.CUSTPHONE;
        txtContactAddr.Text = ddoOut.CUSTADDR;
        txtPostCode.Text = ddoOut.CUSTPOST;

        hidForPaperNo.Value = txtPaperNo.Text.Trim();
        hidForPhone.Value = txtContactPhone.Text.Trim();
        hidForAddr.Value = txtContactAddr.Text.Trim();

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtPaperNo.Text = CommonHelper.GetPaperNo(txtPaperNo.Text);
            txtContactPhone.Text = CommonHelper.GetCustPhone(txtContactPhone.Text);
            txtContactAddr.Text = CommonHelper.GetCustAddress(txtContactAddr.Text);
        }

    }


    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        SubmitValidate();
        if (context.hasError()) return;

        //add by jiangbb 2012-10-17 判断页面上的证件号码、联系电话、联系地址是否修改 并取值
        string custPaperNo = CommonHelper.GetPaperNo(hidForPaperNo.Value) == txtPaperNo.Text.Trim() ? hidForPaperNo.Value : txtPaperNo.Text.Trim();
        string custPhone = CommonHelper.GetCustPhone(hidForPhone.Value) == txtContactPhone.Text.Trim() ? hidForPhone.Value : txtContactPhone.Text.Trim();
        string custAddr = CommonHelper.GetCustAddress(hidForAddr.Value) == txtContactAddr.Text.Trim() ? hidForAddr.Value : txtContactAddr.Text.Trim();

        SP_TS_NewCardPDO pdo = new SP_TS_NewCardPDO();

        pdo.CALLINGSTAFFNO = txtDriverStaffNo.Text.Trim();
        pdo.CARDNO = txtCardNo.Text.Trim();
        pdo.CARNO = txtCarNo.Text.Trim();
        pdo.strState = selState.SelectedValue;
        pdo.BANKCODE = selHouseBank.SelectedValue;
        pdo.BANKACCNO = txtBankAccount.Text.Trim();
        pdo.STAFFNAME = txtStaffName.Text.Trim();
        pdo.STAFFSEX = selStaffSex.SelectedValue;
        pdo.STAFFPHONE = custPhone;
        pdo.STAFFMOBILE = txtCarPhone.Text.Trim();
        pdo.STAFFPAPERTYPECODE = selPaperType.SelectedValue;
        pdo.STAFFPAPERNO = custPaperNo;
        pdo.STAFFPOST = txtPostCode.Text.Trim();
        pdo.STAFFADDR = custAddr;
        pdo.STAFFEMAIL = txtEmailAddr.Text.Trim();
        pdo.CORPNO = selUnitName.SelectedValue;
        pdo.DEPARTNO = selDeptName.SelectedValue;
        pdo.POSID = txtPosID.Text.Trim();
        pdo.COLLECTCARDNO = txtCollectCardNo.Text.Trim();
        pdo.COLLECTCARDPWD = "";
        pdo.operCardNo = context.s_CardID;
        pdo.SERMANAGERCODE = selServerMgr.SelectedValue;

        //add by jiangbb 2012-07-03 收款人账户类型
        pdo.PURPOSETYPE = selPurPoseType.SelectedValue;

        hidStaffNo.Value = txtDriverStaffNo.Text.Trim();

        hidCarNo.Value = OperdStr("E" + txtCarNo.Text.Trim());

        //先把司机卡号转换为ASCILL,再把ASCILL转换为16进制,才能写卡

        hidState.Value = selState.SelectedValue;

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {

            //写卡片信息

            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                       "newDriverCard();", true);

            ClearTaxiInfo();

            //设置确定不启用

            btnSubmit.Enabled = false;

        }

        //清空卡内信息显示
        inStaffno.Text = "";
        inTaxiNo.Text = "";
        selInState.SelectedValue = "";
        selUseState.SelectedValue = "";

    }
    // 确认对话框确认处理


    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "writeSuccess")   // 写卡成功
        {
            AddMessage("M003100112");
            txtCardNo.Text = "";
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("A003100114");
        }

        hidWarning.Value = ""; // 清除警告信息
    }

    private void ClearTaxiInfo()
    {
        txtDriverStaffNo.Text = "";
        txtDriverStaffNoConfirm.Text = "";
        txtCarNo.Text = "";
        selHouseBank.SelectedValue = "A059";
        txtBankAccount.Text = "";
        txtBankAccountConfirm.Text = "";
        txtStaffName.Text = "";
        selStaffSex.SelectedValue = "";
        txtContactPhone.Text = "";
        txtCarPhone.Text = "";
        selPaperType.SelectedValue = "00";
        txtPaperNo.Text = "";
        txtPostCode.Text = "";
        txtContactAddr.Text = "";
        txtEmailAddr.Text = "";
        selUnitName.SelectedValue = "";
        selDeptName.SelectedValue = "";

        txtPosID.Text = "";
        txtCollectCardNo.Text = "";
        selServerMgr.SelectedValue = "";


    }


    private string OperdStr(string strOper)
    {
        //先把司机卡号转换为ASCII,再把ASCII转换为16进制,才能写卡
        string tmpCardNo = "";
        foreach (char c in strOper)
        {
            int tmp = c;
            //69 52 53 54 55 56
            tmpCardNo += String.Format("{0:x}", tmp);
        }
        return tmpCardNo;
    }

    /// <summary>
    /// 根据输入的银行初始化银行下拉列表
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void txtBank_Changed(object sender, EventArgs e)
    {

        if (string.IsNullOrEmpty(txtBank.Text.Trim()))
        {
            return;
        }

        selHouseBank.Items.Clear();

        context.DBOpen("Select");
        System.Text.StringBuilder sql = new System.Text.StringBuilder();

        sql.Append("SELECT BANK, BANKCODE FROM TD_M_BANK WHERE BANKNUMBER IS NOT NULL AND ");
        //模糊查询银行名称，并在列表中赋值
        string strBalname = txtBank.Text.Trim().Replace('\'', '\"');
        if (strBalname.Length != 0)
        {
            sql.Append(" BANK LIKE '%" + strBalname + "%'");
        }
        sql.Append("ORDER BY BANKCODE");

        System.Data.DataTable table = context.ExecuteReader(sql.ToString());
        GroupCardHelper.fill(selHouseBank, table, true);
    }


}
