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
using Master;
using Common;
using TM;
using TDO.BalanceChannel;
using TDO.BusinessCode;
using PDO.TaxiService;
using TDO.CardManager;
using TDO.UserManager;

public partial class ASP_TaxiService_TS_ChangeInfo : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            TMTableModule tmTMTableModule = new TMTableModule();
            // 初始化银行列表


            ////初始化转出银行,开户银行下拉列表值

            //TD_M_BANKTDO ddoTD_M_BANKIn = new TD_M_BANKTDO();
            //TD_M_BANKTDO[] ddoTD_M_BANKOutArr = (TD_M_BANKTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_BANKIn, typeof(TD_M_BANKTDO), "S003100112", "", null);
            //ControlDeal.SelectBoxFill(selHouseBank.Items, ddoTD_M_BANKOutArr, "BANK", "BANKCODE", true);

            //初始银行为农行
            selHouseBank.Items.Add(new ListItem("---请选择---", ""));
            selHouseBank.Items.Add(new ListItem("A059:中国农业银行苏州南门支行", "A059"));
            selHouseBank.SelectedValue = "A059";

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

            //离职标志
            TSHelper.initDismissionTag(selDimissionTag);

            TSHelper.initInitState2(selState, false);

            //add by jiangbb 2012-07-03 初始化收款人账户类型下拉框列表框值
            selPurPoseType.Items.Add(new ListItem("---请选择---", ""));
            selPurPoseType.Items.Add(new ListItem("1:对公", "1"));
            selPurPoseType.Items.Add(new ListItem("2:对私", "2"));

            //初始化操作标志

            hidQueryFlag.Value = "false";
            hidReadCardFlag.Value = "false";
            hidReadNewCardNoFlag.Value = "false";

            btnSubmit.Enabled = false;
            btnUpdate.Enabled = false;


            //正式发布是IC卡号改为只读
            if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

            //采集卡号和采集密码改为只读

            txtCollectCardNo.Attributes.Add("readonly", "true");
            //txtCollectCardPass.Attributes.Add("readonly", "true");

            inTaxiNo.Attributes.Add("readonly", "true");

            TSHelper.initUseState(selUseState);

            TSHelper.initInitState2(selInState, true);

            //设置商户经理编码
            //从内部员工编码表(TD_M_INSIDESTAFF)中读取数据，放入选定集团客户信息的客户经理下拉列表中
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), "S008111111", "TD_M_INSIDESTAFF_SVR", null);

            ControlDeal.SelectBoxFill(selServerMgr.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);


        }

    }

    private Boolean ValidationStaffNo()
    {
        //对司机工号进行非空、长度、数字检验

        if (Validation.isEmpty(txtDriverStaffNo))
            context.AddError("A003100001", txtDriverStaffNo);

        else if (Validation.strLen(txtDriverStaffNo.Text) != 6)
            context.AddError("A003100003", txtDriverStaffNo);

        else if (!Validation.isNum(txtDriverStaffNo.Text))
            context.AddError("A003100002", txtDriverStaffNo);

        if (context.hasError())
            return false;
        else
            return true;

    }

    private Boolean ValidationCardNo()
    {
        //IC卡号空的判断
        if (Validation.isEmpty(txtCardNo))
            context.AddError("A003103004", txtCardNo);

        else if (Validation.strLen(txtCardNo.Text.Trim()) != 16)
            context.AddError("A003100048", txtCardNo);

        else if (!Validation.isNum(txtCardNo.Text.Trim()))
            context.AddError("A003100029", txtCardNo);

        if (context.hasError())
            return false;
        else
            return true;
    }


    protected void btnQuery_Click(object sender, EventArgs e)
    {
        ClearDriverInfo();

        //司机工号的验证

        if (!ValidationStaffNo()) return;

        hidStaffNo.Value = txtDriverStaffNo.Text.Trim();

        //清空卡号
        txtCardNo.Text = "";
        hidCardNo.Value = "";

        //ClearDriverInfo();

        //查询司机信息
        String sql = "SELECT staff.CARNO,bal.BANKACCNO,bal.BANKCODE," +
                     "staff.STAFFNAME,staff.STAFFSEX,staff.STAFFPHONE," +
                     "staff.STAFFMOBILE,staff.STAFFPAPERTYPECODE," +
                     "staff.STAFFPAPERNO,staff.STAFFPOST,staff.DIMISSIONTAG," +
                     "staff.STAFFADDR,staff.STAFFEMAIL," +
                     "bal.CORPNO,bal.DEPARTNO,staff.POSID," +
                     "staff.COLLECTCARDNO,staff.COLLECTCARDPWD,staff.OPERCARDNO, staff.STAFFNO, " +
                     "staff.UPDATESTAFFNO, staff.UPDATETIME , bal.SERMANAGERCODE ,bal.PURPOSETYPE " +
                     "FROM TD_M_CALLINGSTAFF staff,TF_TRADE_BALUNIT bal ";

        ArrayList list = new ArrayList();
        list.Add(" staff.STAFFNO =  bal.CALLINGSTAFFNO ");
        list.Add(" bal.BALUNITTYPECODE = '03'");
        list.Add(" staff.CALLINGNO = '02' ");
        list.Add("staff.STAFFNO ='" + txtDriverStaffNo.Text.Trim() + "'");
        sql += DealString.ListToWhereStr(list);

        QueryTaxiDriverInfo(sql);

        hidQueryFlag.Value = "true";
        hidReadCardFlag.Value = "false";

        btnUpdate.Enabled = true;
        btnSubmit.Enabled = false;

    }





    private void QueryTaxiDriverInfo(string sql)
    {
        //查询司机信息
        TMTableModule tm = new TMTableModule();
        DataTable data = null;
        data = tm.selByPKDataTable(context, sql, 0);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            context.AddError("A003103007");
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;

            txtCardNo.Text = getCellValue(row[18]);
            hidCardNo.Value = getCellValue(row[18]);


            txtBankAccount.Text = getCellValue(row[1]);

            try
            {
                getBank(selHouseBank, row[2].ToString());
                //selHouseBank.SelectedValue = getCellValue(row[2]);
            }
            catch (Exception)
            {
                selHouseBank.SelectedValue = "";
            }

            txtStaffName.Text = getCellValue(row[3]);

            selStaffSex.SelectedValue = getCellValue(row[4]);

            txtContactPhone.Text = getCellValue(row[5]);
            txtCarPhone.Text = getCellValue(row[6]);

            selPaperType.SelectedValue = getCellValue(row[7]);


            txtPaperNo.Text = getCellValue(row[8]);

            txtPostCode.Text = getCellValue(row[9]);

            selDimissionTag.SelectedValue = getCellValue(row[10]);


            txtContactAddr.Text = getCellValue(row[11]);
            txtEmailAddr.Text = getCellValue(row[12]);

            selUnitName.SelectedValue = getCellValue(row[13]);


            //初始化该单位信息的部门,并显示当前部门名称


            InitDepartName();

            selDeptName.SelectedValue = getCellValue(row[14]);

            txtPosID.Text = getCellValue(row[15]);
            txtCollectCardNo.Text = getCellValue(row[16]);
            //txtCollectCardPass.Text = getCellValue(row[17]);

            hidStaffNo.Value = getCellValue(row[19]);
            txtDriverStaffNo.Text = getCellValue(row[19]);
            hidCarNo.Value = getCellValue(row[0]).Trim();
            txtCarNo.Text = hidCarNo.Value;

            hidState.Value = selState.SelectedValue;


            QueryNameByCode(getCellValue(row[20]).Trim());

            if (row[21].ToString() != "")
                txtUpdTime.Text = ((DateTime)row[21]).ToString("yyyy-MM-dd HH:mm:ss");

            try
            {
                //设置商户经理
                selServerMgr.SelectedValue = getCellValue(row[22]);
            }
            catch (Exception)
            {
                selServerMgr.SelectedValue = "";
            }

            try
            {
                selPurPoseType.SelectedValue = getCellValue(row[23]);
            }
            catch (Exception)
            {
                selPurPoseType.SelectedValue = "";
            }

            chkPatchState.Checked = false;

            txtBankAccount.Enabled = true;
            txtBankAccountConfirm.Enabled = true;


        }

    }

    /// <summary>
    /// 选择银行信息，初始化银行下拉列表
    /// </summary>
    /// <param name="ddlist"></param>
    /// <param name="bankCode"></param>
    protected void getBank(DropDownList ddlist, string bankCode)
    {
        context.DBOpen("Select");
        System.Text.StringBuilder sql = new System.Text.StringBuilder();

        sql.Append("SELECT BANK, BANKCODE FROM TD_M_BANK WHERE  ");
        if (bankCode.Length != 0)
        {
            sql.Append(" BANKCODE = '" + bankCode + "'");
        }

        System.Data.DataTable table = context.ExecuteReader(sql.ToString());
        GroupCardHelper.fill(ddlist, table, true);
        ddlist.SelectedValue = bankCode;
    }

    private void InitDepartName()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //从部门编码表(TD_M_CDEPART)中读取数据，放入下拉列表中


        TD_M_DEPARTTDO tdoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
        tdoTD_M_DEPARTIn.CORPNO = selUnitName.SelectedValue;

        TD_M_DEPARTTDO[] tdoTD_M_DEPARTOutArr = (TD_M_DEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null);
        ControlDeal.SelectBoxFill(selDeptName.Items, tdoTD_M_DEPARTOutArr, "DEPART", "DEPARTNO", true);

    }

    private string getCellValue(Object obj)
    {
        return (obj == DBNull.Value ? "" : ((string)obj).Trim());
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        ClearDriverInfo();

        //查询卡号对应的司机信息

        String sql = "SELECT staff.CARNO,bal.BANKACCNO,bal.BANKCODE," +
                     "staff.STAFFNAME,staff.STAFFSEX,staff.STAFFPHONE," +
                     "staff.STAFFMOBILE,staff.STAFFPAPERTYPECODE," +
                     "staff.STAFFPAPERNO,staff.STAFFPOST,staff.DIMISSIONTAG," +
                     "staff.STAFFADDR,staff.STAFFEMAIL," +
                     "bal.CORPNO,bal.DEPARTNO,staff.POSID," +
                     "staff.COLLECTCARDNO,staff.COLLECTCARDPWD,staff.OPERCARDNO, staff.STAFFNO, " +
                     "staff.UPDATESTAFFNO, staff.UPDATETIME, bal.SERMANAGERCODE, " +
                     "bal.PURPOSETYPE " +
                     "FROM TD_M_CALLINGSTAFF staff,TF_TRADE_BALUNIT bal " +
                     "WHERE	staff.STAFFNO  = '" + txtDriverStaffNo.Text + "' " +
                     "AND staff.STAFFNO =  bal.CALLINGSTAFFNO AND  staff.CALLINGNO = '02' " +
                     "AND bal.BALUNITTYPECODE = '03'";

        QueryTaxiDriverInfo(sql);

        hidReadCardFlag.Value = "true";

        //设置更新&写卡按钮不可用

        btnUpdate.Enabled = true;
        // btnSubmit.Enabled = true;

    }

    protected void btnReadNewCard_Click(object sender, EventArgs e)
    {
        //读新卡卡号,判该卡是否开通电子钱包

        btnUpdate.Enabled = false;

        txtCollectCardNo.Text = "";

        TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
        ddoTF_F_CARDRECIn.CARDNO = txtCardNo.Text;
        hidReadNewCardNo.Value = txtCardNo.Text;

        TMTableModule tmTMTableModule = new TMTableModule();
        TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn,
            typeof(TF_F_CARDRECTDO), null, "TF_F_CARDREC_QUERY_BYCARDNO", null);

        if (ddoTF_F_CARDRECOut == null)
        {
            context.AddError("A003100035");
            hidReadNewCardNo.Value = "";
            return;
        }

        if (hidCardNo.Value == ddoTF_F_CARDRECOut.CARDNO)
        {
            context.AddError("A003101404");
            return;
        }

        txtCollectCardNo.Text = hidReadNewCardNo.Value;
        //txtCollectCardPass.Text = "";


        //设置更新按钮不可用

        btnSubmit.Enabled = true;

    }



    protected void selUnitName_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择单位后,初始化部门信息

        if (selUnitName.SelectedValue == "")
        {
            selDeptName.Items.Clear();
            return;
        }

        InitDepartName();
    }


    private Boolean SubmitValidation()
    {
        Validation valid = new Validation(context);


        // 车牌号

        bool b = valid.notEmpty(txtCarNo, "A003100006");

        if (b && Validation.strLen(txtCarNo.Text.Trim()) != 5)
            context.AddError("A003100037", txtCarNo);
        else if (b && !Validation.isCharNum(txtCarNo.Text.Trim()))
            context.AddError("A003100049", txtCarNo);

        // 银行编码
        valid.notEmpty(selHouseBank, "A003100008");


        if (!chkPatchState.Checked)
        {
            // 银行账号
            b = valid.notEmpty(txtBankAccount, "A003100009");

            // 银行账号数字字符的判断(待确认)
            if (b)
            {
                if (Validation.strLen(txtBankAccount.Text) > 30)
                    context.AddError("A003100038", txtBankAccount);
            }

            // 银行账号确认
            b = valid.notEmpty(txtBankAccountConfirm, "A003100011");

            if (b && txtBankAccount.Text != txtBankAccountConfirm.Text)
                context.AddError("A003100012", txtBankAccountConfirm);
        }

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
        if (b && Validation.strLen(txtPaperNo.Text) > 20)
            context.AddError("A003100042", txtPaperNo);
        else if (b && !Validation.isCharNum(txtPaperNo.Text.Trim()))
            context.AddError("A003100020", txtPaperNo);
        else if (b &&selPaperType.SelectedValue=="00" && !Validation.isPaperNo(txtPaperNo.Text.Trim()))
            context.AddError("A003100021:证件号码验证不通过", txtPaperNo);

        // 单位编号
        valid.notEmpty(selUnitName, "A003100021");

        // 部门编号
        //valid.notEmpty(selDeptName, "A003100022");

        // POS编号
        // b = valid.notEmpty(txtPosID, "A003100401");

        if (txtPosID.Text.Trim() != "")
        {
            if (Validation.strLen(txtPosID.Text.Trim()) > 8)
                context.AddError("A003100404", txtPosID);
            else if (!Validation.isNum(txtPosID.Text.Trim()))
                context.AddError("A003100402", txtPosID);
        }

        // 电子邮件
        new Validation(context).isEMail(txtEmailAddr);

        // 联系地址
        txtContactAddr.Text = txtContactAddr.Text.Trim();
        b = txtContactAddr.Text.Length > 0;
        if (b && Validation.strLen(txtContactAddr.Text) > 50)
            context.AddError("A003100045", txtContactAddr);

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

        //收款人账户类型
        if (selPurPoseType.SelectedValue == "")
        {
            context.AddError("A008100020", selPurPoseType);
        }

        //商户经理
        if (selServerMgr.SelectedValue == "")
            context.AddError("A003100136", selServerMgr);


        //检测是否修改了查询的司机工号

        if (hidStaffNo.Value != txtDriverStaffNo.Text.Trim())
        {
            context.AddError("A003103046", txtDriverStaffNo);
        }
        if (context.hasError()) return false;
        else return true;

    }


    protected void btnUpdate_Click(object sender, EventArgs e)
    {
        if (!ValidationStaffNo()) return;

        //检测IC卡号
        if (!ValidationCardNo()) return;

        //确定的输入验证

        if (!SubmitValidation()) return;

        //调用确定的存储过程

        SP_TS_ChangeInfoPDO pdo = new SP_TS_ChangeInfoPDO();

        pdo.DIMISSIONTAG = selDimissionTag.SelectedValue;

        pdo.TradeTypeCode = "42";

        pdo.CALLINGSTAFFNO = txtDriverStaffNo.Text.Trim();
        pdo.CARDNO = txtCardNo.Text.Trim();
        pdo.CARNO = txtCarNo.Text.Trim();

        pdo.strState = selState.SelectedValue;
        pdo.BANKCODE = selHouseBank.SelectedValue;

        if (chkPatchState.Checked)
        {
            pdo.BANKACCNO = "F"; //补办中时,银行帐号设置为F
        }
        else
        {
            pdo.BANKACCNO = txtBankAccount.Text.Trim();
        }

        pdo.STAFFNAME = txtStaffName.Text.Trim();
        pdo.STAFFSEX = selStaffSex.SelectedValue;
        pdo.STAFFPHONE = txtContactPhone.Text.Trim();
        pdo.STAFFMOBILE = txtCarPhone.Text.Trim();
        pdo.STAFFPAPERTYPECODE = selPaperType.SelectedValue;
        pdo.STAFFPAPERNO = txtPaperNo.Text.Trim();
        pdo.STAFFPOST = txtPostCode.Text.Trim();
        pdo.STAFFADDR = txtContactAddr.Text.Trim();
        pdo.STAFFEMAIL = txtEmailAddr.Text.Trim();
        pdo.CORPNO = selUnitName.SelectedValue;
        pdo.DEPARTNO = selDeptName.SelectedValue;

        pdo.POSID = txtPosID.Text.Trim();
        pdo.COLLECTCARDNO = txtCardNo.Text.Trim();
        pdo.COLLECTCARDPWD = "";
        pdo.operCardNo = context.s_CardID;
        pdo.writeCardUseTag = "0";

        pdo.SERMANAGERCODE = selServerMgr.SelectedValue;
        
        //add by jiangbb 2012-07-03 收款人账户类型
        pdo.PURPOSETYPE = selPurPoseType.SelectedValue;

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M003103114");
            ClearDriverInfo();
            txtDriverStaffNo.Text = "";
            txtCardNo.Text = "";

            btnSubmit.Enabled = false;
            btnUpdate.Enabled = false;
        }

        ClearCardInfo();
    }

    //更新&写卡

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (!ValidationStaffNo()) return;

        //检测IC卡号
        if (!ValidationCardNo()) return;

        if (hidReadNewCardNo.Value == hidCardNo.Value)
        {
            //新卡号与查询卡号一致时
            context.AddError("A003103104");
            return;
        }

        //确定的输入验证

        if (!SubmitValidation()) return;

        //调用确定的存储过程

        SP_TS_ChangeInfoPDO pdo = new SP_TS_ChangeInfoPDO();

        pdo.DIMISSIONTAG = selDimissionTag.SelectedValue;

        pdo.TradeTypeCode = "42";

        pdo.CALLINGSTAFFNO = txtDriverStaffNo.Text.Trim();
        pdo.CARDNO = txtCardNo.Text;
        pdo.CARNO = txtCarNo.Text.Trim();

        pdo.strState = selState.SelectedValue;
        pdo.BANKCODE = selHouseBank.SelectedValue;

        if (chkPatchState.Checked)
        {
            pdo.BANKACCNO = "F"; //补办中时,银行帐号设置为F
        }
        else
        {
            pdo.BANKACCNO = txtBankAccount.Text.Trim();
        }

        pdo.STAFFNAME = txtStaffName.Text.Trim();
        pdo.STAFFSEX = selStaffSex.SelectedValue;
        pdo.STAFFPHONE = txtContactPhone.Text.Trim();
        pdo.STAFFMOBILE = txtCarPhone.Text.Trim();
        pdo.STAFFPAPERTYPECODE = selPaperType.SelectedValue;
        pdo.STAFFPAPERNO = txtPaperNo.Text.Trim();
        pdo.STAFFPOST = txtPostCode.Text.Trim();
        pdo.STAFFADDR = txtContactAddr.Text.Trim();
        pdo.STAFFEMAIL = txtEmailAddr.Text.Trim();
        pdo.CORPNO = selUnitName.SelectedValue;
        pdo.DEPARTNO = selDeptName.SelectedValue;
        pdo.POSID = txtPosID.Text.Trim();
        pdo.COLLECTCARDNO = txtCardNo.Text.Trim();
        pdo.COLLECTCARDPWD = "";
        pdo.operCardNo = context.s_CardID;
        pdo.writeCardUseTag = "1";

        //add by jiangbb 2012-07-03 收款人账户类型
        pdo.PURPOSETYPE = selPurPoseType.SelectedValue;
        pdo.SERMANAGERCODE = selServerMgr.SelectedValue;

        bool ok = TMStorePModule.Excute(context, pdo);
        hidCarNo.Value = OperdStr("E" + txtCarNo.Text.Trim());

        if (ok)
        {


            //写卡片信息

            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                           "newDriverCard();", true);

            ClearDriverInfo();

            btnSubmit.Enabled = false;
            btnUpdate.Enabled = false;

        }

        ClearCardInfo();

    }

    private void ClearCardInfo()
    {
        inTaxiNo.Text = "";
        selInState.SelectedValue = "";
        selUseState.SelectedValue = "";

    }


    // 确认对话框确认处理


    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "writeSuccess")   // 写卡成功
        {
            AddMessage("M003103115");
            txtCardNo.Text = "";
            txtDriverStaffNo.Text = "";
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("A003100114");
        }

        hidWarning.Value = ""; // 清除警告信息
    }


    private void ClearDriverInfo()
    {
        // txtDriverStaffNo.Text = ""
        //txtCardNo.Text = "";
        //hidCardNo.Value = "";

        txtBank.Text = "";
        selHouseBank.SelectedValue = "";
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
        txtCarNo.Text = "";
        txtCollectCardNo.Text = "";
        //txtCollectCardPass.Text = "";
        txtUpdStaff.Text = "";
        txtUpdTime.Text = "";
        selState.SelectedValue = "0B";
        selServerMgr.SelectedValue = "";

        chkPatchState.Checked = false;

        txtBankAccount.Enabled = true;
        txtBankAccountConfirm.Enabled = true;
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

    private void QueryNameByCode(string strStaffNo)
    {
        TMTableModule tm = new TMTableModule();
        DataTable data = null;

        //查询更新员工代码对应的姓名


        if (strStaffNo.Trim() != "")
        {
            string staffSql = "select STAFFNAME from td_m_insidestaff where STAFFNO ='" + strStaffNo + "'";

            data = tm.selByPKDataTable(context, staffSql, 0);
            if (data == null || data.Rows.Count == 0) // 无记录
            {
                txtUpdStaff.Text = strStaffNo;
            }
            else
            {
                Object[] row = data.Rows[0].ItemArray;
                txtUpdStaff.Text = getCellValue(row[0]);
            }
        }

    }

    protected void chkPatchState_CheckedChanged(object sender, EventArgs e)
    {
        //选择补办中 
        if (chkPatchState.Checked)
        {
            txtBankAccount.Text = "";
            txtBankAccountConfirm.Text = "";
            txtBankAccount.Enabled = false;
            txtBankAccountConfirm.Enabled = false;
        }

        else
        {
            txtBankAccount.Enabled = true;
            txtBankAccountConfirm.Enabled = true;
        }
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
