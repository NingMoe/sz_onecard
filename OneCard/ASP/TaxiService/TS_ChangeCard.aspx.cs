using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using PDO.TaxiService;
using TDO.BalanceChannel;
using TDO.CardManager;
using TM;

public partial class ASP_TaxiService_TS_ChangeCard : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化开户银行
            TMTableModule tm = new TMTableModule();
            ControlDeal cd = new ControlDeal(tm, context);

            // 初始化银行列表
            //cd.SelectWithEmpty(typeof(TD_M_BANKTDO), selHouseBank, "BANK", "BANKCODE", "S003100112");

            //初始银行为农行
            selHouseBank.Items.Add(new ListItem("A059:中国农业银行苏州南门支行", "A059"));

            //初始化初始状态
            TSHelper.initInitState(selInitState);

            TSHelper.initUseState(selUseState);

            if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

            //设置卡内信息为只读
            inStaffno.Attributes["readonly"] = "true";
            inTaxiNo.Attributes["readonly"] = "true";


            //启用读卡按钮
            btnReadCard.Enabled = true;

            //确定按钮不启用
            btnChangeCard.Enabled = false;       
        }
    }

    protected void btnQueryByStuffNo_Click(object sender, EventArgs e)
    {
        ClearTaxiInfo();

        Validation valid = new Validation(context);

        //对司机工号进行非空、长度、数字检验
        if (Validation.isEmpty(txtDriverStaffNo))
            context.AddError("A003100001", txtDriverStaffNo);

        else if (Validation.strLen(txtDriverStaffNo.Text) != 6)
            context.AddError("A003100003", txtDriverStaffNo);

        else if (!Validation.isNum(txtDriverStaffNo.Text))
            context.AddError("A003100002", txtDriverStaffNo);
        

        if(context.hasError())
            return;

        hidStaffNo.Value = txtDriverStaffNo.Text.Trim();

        //查询司机工号对应的信息
        String sql = "SELECT staff.CARNO,bal.BANKACCNO,bal.BANKCODE," +
                     "staff.STAFFNAME,staff.STAFFSEX,staff.STAFFPHONE," +
                     "staff.STAFFMOBILE,staff.STAFFPAPERTYPECODE," +
                     "staff.STAFFPAPERNO,staff.STAFFPOST,staff.DIMISSIONTAG," +
                     "staff.STAFFADDR,staff.STAFFEMAIL," +
                     "bal.CORPNO,bal.DEPARTNO,staff.POSID," +
                     "staff.COLLECTCARDNO,staff.COLLECTCARDPWD,staff.OPERCARDNO " +
                     "FROM TD_M_CALLINGSTAFF staff,TF_TRADE_BALUNIT bal " +
                     "WHERE	bal.CALLINGSTAFFNO  = '" + txtDriverStaffNo.Text.Trim() + "' " +
                     "AND staff.STAFFNO =  bal.CALLINGSTAFFNO AND staff.CALLINGNO = '02' "+
                     "AND bal.BALUNITTYPECODE = '03' ";

        TMTableModule tm = new TMTableModule();
        DataTable data = null;
        data = tm.selByPKDataTable(context, sql, 0);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            context.AddError("A003101012");
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;
            labCardNo.Text = getCellValue(row[18]);
            labCarNo.Text = getCellValue(row[0]);
            labBankAccount.Text = getCellValue(row[1]);

            hidBankCode.Value = getCellValue(row[2]);

            // strBankCode = getCellValue(row[2]);
            labStaffName.Text = getCellValue(row[3]);

            if (getCellValue(row[4]) != "")
                labStaffSex.Text = getCellValue(row[4]) == "0" ? "男" : "女"; 

            labContactPhone.Text = getCellValue(row[5]);
            labCarPhone.Text = getCellValue(row[6]);

            hidPaperTypeNo.Value = getCellValue(row[7]);

            labPaperNo.Text= getCellValue(row[8]);
            labPostCode.Text = getCellValue(row[9]);

            if (getCellValue(row[10]) != "")
                labDimssionTag.Text = getCellValue(row[10]) == "1" ? "在职" : "离职";
        

            labContactAddr.Text = getCellValue(row[11]);
            labEmailAddr.Text = getCellValue(row[12]);


            hidCorpNo.Value = getCellValue(row[13]);

            // strCorpNo  = getCellValue(row[13]);
            hidDepartNo.Value = getCellValue(row[14]);
            // strDepartNo = getCellValue(row[14]);

            labPosID.Text = getCellValue(row[15]);
            labCollectCardNo.Text = getCellValue(row[16]);
            labCollectCardPass.Text = getCellValue(row[17]);

            //查询银行,单位,部门,证件类型名称
            QueryNameByCode(hidBankCode.Value, hidCorpNo.Value, hidDepartNo.Value,hidPaperTypeNo.Value);

            //启用读卡按钮不启用
            //btnReadCard.Enabled = true;

        }
    }

    private string getCellValue(Object obj)
    {
        return (obj == DBNull.Value ? "" : ((string)obj).Trim());
    }

    private void QueryNameByCode(string strBankCode,string strCorpNo, string strDepartNo,string strPaperTypeNo)
    {
        TMTableModule tm = new TMTableModule();
        DataTable data = null;

        //查询银行代码对应的银行名称
        string bankSql = "select BANK from TD_M_BANK where BANKCODE ='" + strBankCode + "'";
       
        data = tm.selByPKDataTable(context, bankSql, 0);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            context.AddError("A003101013");
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;
            labHouseBank.Text = getCellValue(row[0]);
        }

        //查询单位代码对应的单位名称        string corpSql = "select CORP from TD_M_CORP where CORPNO ='" + strCorpNo + "'";

        data = tm.selByPKDataTable(context, corpSql, 0);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            context.AddError("A003101014");
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;
            labUnitName.Text = getCellValue(row[0]);
        }

        //查询部门代码对应的部门名称

        if (strDepartNo.Trim() != "")
        {
            string departSql = "select DEPART from TD_M_DEPART where DEPARTNO ='" + strDepartNo + "'";

            data = tm.selByPKDataTable(context, departSql, 0);
            if (data == null || data.Rows.Count == 0) // 无记录
            {
                context.AddError("A003101015");
            }
            else
            {
                Object[] row = data.Rows[0].ItemArray;
                labDeptName.Text = getCellValue(row[0]);
            }

        }
        //查询证件类型代码对应的证件类型名称
        string paperTypeSql = "select PAPERTYPENAME from TD_M_PAPERTYPE where PAPERTYPECODE ='" + strPaperTypeNo + "'"; 
    
        data = tm.selByPKDataTable(context, paperTypeSql, 0);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            context.AddError("A003101016");
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;
            labPaperType.Text = getCellValue(row[0]);
        }

    }


    private void SubmitValidate()
    {
        //判断是否读取旧卡信息
        if (labCardNo.Text.Trim() == "")
        {
            context.AddError("A003101004");
            return;
        }

        //是否读出新卡号
        if (txtCardNo.Text.Trim() == "")
        {
            context.AddError("A003101005");
            return;
        }

        //新卡卡号等于旧卡卡号
        if (txtCardNo.Text.Trim() == labCardNo.Text.Trim())
            context.AddError("A003101404", txtCardNo);

        Validation valid = new Validation(context);

        //新卡银行编码是否为空的检测
        if (selHouseBank.SelectedValue == "")
            context.AddError("A003101006", selHouseBank);

        //银行账号
        bool b = valid.notEmpty(txtBankAccount, "A003101007");

        //银行帐号数字类型的判断
        if (b)
        {
            if (Validation.strLen(txtBankAccount.Text.Trim()) > 30)
                context.AddError("A003101017", txtBankAccount);

            //else if (!Validation.isNum(txtBankAccount.Text))
            //    context.AddError("A003101008", txtBankAccount);
         
        }

        // 银行账号确认
        b = valid.notEmpty(txtBankAccountConfirm, "A003101009");
        if (b && txtBankAccount.Text != txtBankAccountConfirm.Text)
            context.AddError("A003101010", txtBankAccountConfirm);

        //备注
        txtRemark.Text = txtRemark.Text.Trim();
        b = txtRemark.Text.Length > 0;
        if (b && Validation.strLen(txtRemark.Text.Trim()) > 100)
            context.AddError("A003101018", txtRemark);

        //司机工号修改后,重新查询才可补换卡
        if (txtDriverStaffNo.Text.Trim() != hidStaffNo.Value)
            context.AddError("A003103046", txtDriverStaffNo);


    }

    protected void btnChangeCard_Click(object sender, EventArgs e)
    {

        SubmitValidate();
        if (context.hasError()) return;

        //调用补换卡的存储过程

        SP_TS_ChangeCardPDO pdo = new SP_TS_ChangeCardPDO();
        
        pdo.CALLINGSTAFFNO =  hidStaffNo.Value.Trim();
        pdo.NewCardNo   = txtCardNo.Text.Trim();                 
        pdo.OldCardNo   =  labCardNo.Text.Trim();                        
        pdo.CARNO       =  labCarNo.Text.Trim();
        pdo.strState    =  selInitState.SelectedValue;

        pdo.BANKCODE    =  selHouseBank.SelectedValue;  //新的开户银行
        pdo.BANKACCNO   =  txtBankAccount.Text.Trim();             
        pdo.STAFFNAME   =  labStaffName.Text.Trim();

        pdo.STAFFSEX = labStaffSex.Text == "男" ? "0" : "1";   
            
        pdo.STAFFPHONE  =  labContactPhone.Text.Trim();               
        pdo.STAFFMOBILE        =  labCarPhone.Text.Trim();
        pdo.STAFFPAPERTYPECODE = hidPaperTypeNo.Value.Trim();             
        pdo.STAFFPAPERNO   =  labPaperNo.Text.Trim();               
        pdo.STAFFPOST      =  labPostCode.Text.Trim();                    
        pdo.STAFFADDR      =  labContactAddr.Text.Trim();                 
        pdo.STAFFEMAIL     =  labEmailAddr.Text.Trim();                  
        pdo.CORPNO         =  hidCorpNo.Value.Trim();                                       
        pdo.DEPARTNO       =  hidDepartNo.Value.Trim();

        pdo.POSID          = labPosID.Text.Trim();

        pdo.COLLECTCARDNO  =  txtCardNo.Text.Trim();  //采集卡号
        pdo.COLLECTCARDPWD =  labCollectCardPass.Text.Trim();

        pdo.DIMISSIONTAG   = labDimssionTag.Text == "在职" ? "1" : "0";
        pdo.REMARK         =  txtRemark.Text.Trim();
        pdo.operCardNo     =  context.s_CardID;

        hidState.Value = selInitState.SelectedValue ;
        hidCarNo.Value = OperdStr("E" + labCarNo.Text.Trim());

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            //hidCardReaderToken.Value = cardReader.createToken(context);
            //向新卡中写入司机工号,车号,初始状态信息
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                      "newDriverCard();", true);

            ClearTaxiInfo();
            //确定按钮不启用
            btnChangeCard.Enabled = false;

        }
        //清空卡内信息显示
        ClearCardInfo();
    }



    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "writeSuccess")   // 写卡成功
        {
            AddMessage("M003101114");
            txtCardNo.Text = "";
        }

        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("A003100114");
        }

        hidWarning.Value = ""; // 清除警告信息
    }


    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        ////判断是否读取旧卡信息
        //if (labCardNo.Text.Trim() == "")
        //{
        //    ClearCardInfo();
        //    context.AddError("A003101004");
        //    return;
        //}

        //新卡与旧卡信息相同
        if (labCardNo.Text.Trim() == txtCardNo.Text.Trim() && (labCardNo.Text.Trim() != ""))
        {
            ClearCardInfo();
            context.AddError("A003101404");
            return;
        }

        //检测该卡是否开通电子钱包
        if (!chkSaleCard(txtCardNo.Text)) return;

        //启用确定按钮
        btnChangeCard.Enabled = true;
    }

    private void ClearCardInfo()
    {

        txtCardNo.Text = "";
        inTaxiNo.Text = "";
        selUseState.SelectedValue = "";
        inStaffno.Text = "";
    }


    private Boolean chkSaleCard(String strCardNo)
    {

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

    private void ClearTaxiInfo()
    {
       // txtDriverStaffNo.Text = "";
       // hidStaffNo.Value = "";
        labCardNo.Text = "";
        
        labCarNo.Text = "";
        labHouseBank.Text = "";
        labBankAccount.Text = "";
        hidBankCode.Value = "";
        labStaffName.Text = "";
        labStaffSex.Text = "";
        labContactPhone.Text = "";
        labCarPhone.Text = "";
        labPaperType.Text = "";
        labPaperNo.Text = "";
        labPostCode.Text = "";
        labDimssionTag.Text = "";
        labContactAddr.Text = "";
        labEmailAddr.Text = "";
        hidCorpNo.Value = "";
        hidDepartNo.Value = "";
        labUnitName.Text = "";
        labDeptName.Text = "";
        labPosID.Text = "";
        labCollectCardNo.Text = "";
        labCollectCardPass.Text = "";

        txtCardNo.Text = "";

        selHouseBank.SelectedValue = "A059";
        txtBankAccount.Text = "";
        txtBankAccountConfirm.Text = "";
        selInitState.SelectedValue = "0B";
        txtRemark.Text = "";




    }

    private string OperdStr(string strOper)
    {
        //先把司机卡号转换为ASCII,再把ASCII转换为16进制,才能写卡
        string tmpCardNo = "";
        foreach (char c in strOper)
        {
            int tmp = c;
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
