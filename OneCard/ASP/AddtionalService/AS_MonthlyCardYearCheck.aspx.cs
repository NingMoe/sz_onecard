using System;
using System.Data;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;
using TDO.BusinessCode;
using Common;
using TM;
using System.Text;
using PDO.PersonalBusiness;
using TDO.UserManager;
using System.Collections.Generic;
using Master;
/// <summary>
/// 月票卡年检  对开通功能的卡进行年检
/// </summary>
public partial class ASP_AddtionalService_AS_MonthlyCardYearCheck : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

        txtRealRecv.Attributes["onfocus"] = "this.select();";
        txtRealRecv.Attributes["onkeyup"] = "realRecvChanging(this, 'test', 'hidAccRecv');";

        hidAccRecv.Value = Total.Text;
        // 设置可读属性
        setReadOnly(txtCardBalance, txtStartDate, txtEndDate);


        //初始化年检日期
        string year = System.DateTime.Today.ToString("yyyy");

        //初始化最近13年

        selDate.Items.Add(new ListItem("-----请选择-----", ""));
        for (int i = 0; i < 13; i++)
        {
            selDate.Items.Add(new ListItem(year + "年9月30日", year));

            year = (Convert.ToInt32(year) + 1).ToString();
        }

        toDate1.Text = DateTime.Now.Year.ToString() + "年12月31日";
        toDate2.Text = (DateTime.Now.Year + 1).ToString() + "年12月31日";

        //获取token
        string token;
        string sql = "SELECT SYSDATE FROM DUAL";

        TMTableModule tm = new TMTableModule();
        DataTable dt = tm.selByPKDataTable(context, sql, 1);
        DateTime now = (DateTime)dt.Rows[0].ItemArray[0];
        TimeSpan epochTime = (now.ToUniversalTime() - new DateTime(1970, 1, 1));
        token = Token.createToken(context.s_CardID, (uint)epochTime.TotalSeconds);

        hidCardReaderToken1.Value = token;
        //获取劳模卡年审日期
        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_TAGTDO ddoTD_M_TAGTDOIn = new TD_M_TAGTDO();
        ddoTD_M_TAGTDOIn.TAGCODE = "LMCARD_YEARCHECK";

        TD_M_TAGTDO[] ddoTD_M_TAGTDOOutArr = (TD_M_TAGTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TAGTDOIn, "S001002125");

        if (ddoTD_M_TAGTDOOutArr[0].TAGVALUE != null)
        {
            toDateForLM.Text = ddoTD_M_TAGTDOOutArr[0].TAGVALUE.Substring(0,4)+"年12月31日";
        }

        // 初始化证件类型

        ASHelper.initPaperTypeList(context, selPaperType);

        // 初始化性别
        ASHelper.initSexList(selCustSex);

        //年检信息不可见
        selDate.Visible = false;
        toDate1.Visible = false;
        toDate2.Visible = false;
        toDateForLM.Visible = false;
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面办理业务
        bool cardTypeOk = CommonHelper.allowCardtype(context, txtCardNo.Text, "5101", "5103");
        if (cardTypeOk == false)
        {
            return;
        }
        // 读取卡片类型
        readCardType(txtCardNo.Text, labCardType);

        // 读取卡片状态
        ASHelper.readCardState(context, txtCardNo.Text, txtCardState);

        //卡账户有效性检验
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardNo.Text;
        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);
        //checkCardState(txtCardNo.Text);

        // 卡账户有效性检验 黑名单卡则锁卡
        if (pdoOut.retCode == "A001107199")
        {//验证如果是黑名单卡，锁卡
            this.LockBlackCard(txtCardNo.Text);
            this.hidLockBlackCardFlag.Value = "yes";
            return;
        }

        //读取数据库获取数据，填充页面textbox
        readCustInfo();

        hidForPaperNo.Value = txtPaperNo.Text.Trim();
        hidForPhone.Value = txtCustPhone.Text.Trim();
        hidForAddr.Value = txtCustAddr.Text.Trim();

        //根据读取的卡内信息填充页面
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_APPAREATDO ddoTD_M_APPAREAIn = new TD_M_APPAREATDO();
        ddoTD_M_APPAREAIn.AREACODE = HidYPFlag.Value;
        TD_M_APPAREATDO ddoTD_M_APPAREAOut = (TD_M_APPAREATDO)tmTMTableModule.selByPK(context, ddoTD_M_APPAREAIn, typeof(TD_M_APPAREATDO), null);

        if (ddoTD_M_APPAREAOut == null)
        {
            context.AddError("未开通月票功能");
            return;
        }
        HidAppType.Value = ddoTD_M_APPAREAOut.APPTYPE;
        selMonthlyCardType.Text= HidAppType.Value == "01" ? "学生月票卡" // 学生月票卡
                               : HidAppType.Value == "02" ? "老人月票卡" // 老人月票卡
                               : HidAppType.Value == "03" ? "高龄卡"     // 高龄卡
                               : HidAppType.Value == "04" ? "爱心卡"     // 残疾人爱心卡
                               : HidAppType.Value == "05" ? "劳模卡"     // 劳模卡
                               : HidAppType.Value == "06" ? "教育E卡通"  // 教育卡
                               : HidAppType.Value == "07" ? "献血卡"     //献血卡
                               : "";
        if( HidAppType.Value == "04" )
        {
            context.AddError("爱心卡不可年审！");
            return;
        }
        if( HidAppType.Value == "06")
        {
            context.AddError("教育E卡通不可年审！");
            return;
        }
        string year = System.DateTime.Today.ToString("yyyy");

        if (HidYearInfo.Value.Substring(0, 4) == toDate1.Text.Substring(0, 4))
        {
            toDate1.Enabled = false;
        }
        if (HidYearInfo.Value.Substring(0, 4) == toDate2.Text.Substring(0, 4))
        {
            toDate2.Enabled = false;
        }
        if (HidYearInfo.Value.Substring(0, 4) == toDateForLM.Text.Substring(0, 4))
        {
            toDateForLM.Enabled = false;
        }
        selMonthlyCardDistrict.Text = ddoTD_M_APPAREAOut.AREANAME;

        txtLastYear.Text = HidYearInfo.Value;

        //显示对应年检信息
        if (ddoTD_M_APPAREAOut.APPTYPE == "01")
        {
            inMoney.Text = "0";
            selDate.Visible = true;
            toDate1.Visible = false;
            toDate2.Visible = false;
            toDateForLM.Visible = false;
        }
        else if (ddoTD_M_APPAREAOut.APPTYPE == "05")
        {
            inMoney.Text = "0";
            selDate.Visible = false;
            toDate1.Visible = false;
            toDate2.Visible = false;
            toDateForLM.Visible = true;
        }
        else
        {
            if (ddoTD_M_APPAREAOut.APPTYPE == "02" || ddoTD_M_APPAREAOut.APPTYPE == "03")
            {
                inMoney.Text = "10";
            }
            else
            {
                inMoney.Text = "0";
            }
            selDate.Visible = false;
            toDate1.Visible = true;
            //判断是否显示明年年审信息
            string a = year + " - 10 - 01 00: 00: 00";
            DateTime dt;
            dt = DateTime.Now;
            if (dt <= Convert.ToDateTime(a))
            {
                toDate2.Visible = false;
            }
            else
            {
                toDate2.Visible = true;
            }
            toDateForLM.Visible = false;
        }
       
       

        //市民卡不能修改客户资料
        if (!context.hasError() && txtCardNo.Text.Substring(4, 2).ToString() == "18")
        {
            context.AddMessage("提示：开卡卡号为市民卡，客户资料不会被修改");
        }

        btnPrintPZ.Enabled = false;
        btnSubmit.Enabled = !context.hasError();
    }
    private void readCustInfo()
    {
        DataTable data = ASHelper.callQuery(context, "QueryCustInfo", txtCardNo.Text);
        if (data.Rows.Count == 0)
        {
            context.AddError("A00501A002: 无法读取卡片客户资料");
            return;
        }

        //解密
        CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" }));

        Object[] row = data.Rows[0].ItemArray;

        txtCustName.Text = ASHelper.getCellValue(row[0]);
        string paperType = (ASHelper.getCellValue(row[2])).Trim();
        selPaperType.SelectedValue = paperType;

        string sex = (ASHelper.getCellValue(row[4])).Trim();
        selCustSex.SelectedValue = sex;

        txtCustBirth.Text = ASHelper.getCellValue(row[1]);
        txtPaperNo.Text = ASHelper.getCellValue(row[3]);
        txtCustPhone.Text = ASHelper.getCellValue(row[5]);
        txtCustPost.Text = ASHelper.getCellValue(row[6]);
        txtCustAddr.Text = ASHelper.getCellValue(row[7]);
        txtEmail.Text = ASHelper.getCellValue(row[9]);
        txtRemark.Text = ASHelper.getCellValue(row[8]);
    }
    private bool HasOperPower(string powerCode, string operCardno)
    {
        //TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
        string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + operCardno + "')";
        DataTable dataSupply = tm.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
        if (dataSupply.Rows.Count > 0)
            return true;
        else
            return false;
    }
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")    // 是否继续
        {
            btnSubmit.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess") // 写卡成功
        {

            #region 如果是前台黑名单锁卡
            //前台锁卡没有写写卡台账

            if (this.hidLockBlackCardFlag.Value == "yes")
            {
                AddMessage("黑名单卡已锁");
                clearCustInfo(txtCardNo);
                this.hidLockBlackCardFlag.Value = "";
                return;
            }
            #endregion

            clearCustInfo(selMonthlyCardType, selMonthlyCardDistrict,
               txtCardNo, txtCustName, txtCustBirth, selPaperType, txtPaperNo,
               selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);

            AddMessage("月票卡年审成功");

        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            AddMessage("月票卡年审失败");
        }
        else if (hidWarning.Value == "checkOperCardno")
        {
            //查询操作员工卡所属员工的员工编码
            string sql = "select staffno from td_m_insidestaff where opercardno = '" + hiddenCheck.Value + "'";
            context.DBOpen("Select");
            DataTable sqldata = context.ExecuteReader(sql);

            if (sqldata.Rows.Count > 0)
            {
                //判断插入操作员工卡是否为网店主管的操作员工卡
                if (HasOperPower("201007", sqldata.Rows[0][0].ToString()))//如果当前操作员工不是网点主管
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "radioTagScript", "RecoverOperCardCheck();", true);
                }
                else
                {
                    context.AddError("插入的卡片不是网点主管操作员卡！");
                    return;
                }
            }
            else
            {
                context.AddError("未找到该卡所属员工！");
            }

        }
        else if (hidWarning.Value == "submit")
        {
            OpenSummit();
        }

        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice(); ", true);
        }

        hidWarning.Value = ""; // 清除警告信息
    }
    //提交前判断
    private void submitValidate()
    {
        // 校验客户信息
        custInfoForValidate(txtCustName, txtCustBirth, selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);

        Validation valid = new Validation(context);
        valid.check(!string.IsNullOrEmpty(txtCustName.Text), "请输入用户姓名！", txtCustName);
        valid.check(!string.IsNullOrEmpty(selPaperType.SelectedValue), "请选择证件类型！", selPaperType);
        valid.check(!string.IsNullOrEmpty(txtPaperNo.Text), "请输入身份证号码！", txtPaperNo);
        valid.check(selCustSex.SelectedValue != "", " 性别必须选择！", selCustSex);

        if (selMonthlyCardType.Text == "学生月票卡")
        {
            valid.check(selDate.SelectedValue != null|| selDate.SelectedValue != "" || selDate.SelectedValue != "-----请选择-----", "请选择学生卡年检日期参数", selDate);
        }
        else if (selMonthlyCardType.Text == "劳模卡")
        {
            valid.check(toDateForLM.Checked , "请选择劳模卡年检日期参数", toDateForLM);
        }
        else
        {
            valid.check(toDate1.Checked  || toDate2.Checked  , "请选择年检日期参数", toDate1);
            valid.check(toDate1.Checked || toDate2.Checked, "请选择年检日期参数", toDate2);

        }
    }
    private void custInfoForValidate(TextBox txtCustName, TextBox txtCustBirth,
            DropDownList selPaperType, TextBox txtPaperNo,
            DropDownList selCustSex, TextBox txtCustPhone,
            TextBox txtCustPost, TextBox txtCustAddr, TextBox txtCustEmail, TextBox txtRemark)
    {
        Validation valid = new Validation(context);
        txtCustName.Text = txtCustName.Text.Trim();
        valid.check(Validation.strLen(txtCustName.Text) <= 50, "A005010001, 客户姓名长度不能超过50", txtCustName);

        bool b = Validation.isEmpty(txtCustBirth);
        if (!b)
        {
            b = valid.fixedLength(txtCustBirth, 8, "A005010002: 出生日期必须为8位");
            if (b)
            {
                valid.beDate(txtCustBirth, "A005010003: 出生日期格式必须是yyyyMMdd");
            }
        }

        b = Validation.isEmpty(txtCustPost);
        if (!b)
        {
            b = valid.fixedLength(txtCustPost, 6, "A005010004: 邮政编码必须为6位");
            if (b)
            {
                valid.beNumber(txtCustPost, "A005010005: 邮政编码必须是数字");
            }
        }

        b = Validation.isEmpty(txtPaperNo);
        if (!b)
        {
            b = valid.check(Validation.strLen(txtPaperNo.Text) <= 20, "A005010006: 证件号码位数必须小于等于20", txtPaperNo);
            //判断是否有客户信息查看权限
            if (CommonHelper.HasOperPower(context) || CommonHelper.GetPaperNo(hidForPaperNo.Value) != txtPaperNo.Text.Trim())
            {
                if (b)
                {
                    valid.beAlpha(txtPaperNo, "A005010007: 证件号码必须是英文或者数字");
                }
            }
        }

        b = Validation.isEmpty(txtCustPhone);
        if (!b)
        {
            b = valid.check(Validation.strLen(txtCustPhone.Text) <= 20, "A005010008: 联系电话位数必须小于等于20", txtCustPhone);
            //if (b)
            //{
            //    valid.beNumber(txtCustPhone, "A005010009: 联系电话必须是数字");
            //}
        }
        b = Validation.isEmpty(txtCustAddr);
        if (!b)
        {
            valid.check(Validation.strLen(txtCustAddr.Text) <= 50, "A005010010: 联系地址位数必须小于等于50", txtCustAddr);
        }

        valid.isEMail(txtCustEmail);

        b = Validation.isEmpty(txtRemark);
        if (!b)
        {
            valid.check(Validation.strLen(txtRemark.Text) <= 100, "A005010011: 备注位数必须小于等于100", txtRemark);
        }
    }
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        submitValidate();

        //卡账户有效性检验
        SP_AccCheckPDO pdo2 = new SP_AccCheckPDO();
        pdo2.CARDNO = txtCardNo.Text;
        TMStorePModule.Excute(context, pdo2);

        if (context.hasError()) return;

        OpenSummit();
    }
    private void OpenSummit()
    {
        //设置年审控件参数
        string type = HidAppType.Value;
        //判断今年奇数偶数
        int temp = DateTime.Now.Year % 2;
        //今年后两位
        string thisyearsub = DateTime.Now.Year.ToString(CultureInfo.InvariantCulture).Substring(2, 2);
        //明年后两位
        string nextyearsub = (DateTime.Now.Year + 1).ToString(CultureInfo.InvariantCulture).Substring(2, 2);
        string thisyear = DateTime.Now.Year.ToString(CultureInfo.InvariantCulture);
        string nextyear = (DateTime.Now.Year + 1).ToString(CultureInfo.InvariantCulture);
        string indexpre02 = HidPriIndex1.Value.Substring(0, 2);
        string indexpre22 = HidPriIndex1.Value.Substring(2, 2);
        string indexpre42 = HidPriIndex1.Value.Substring(4, 2);
        string indexpre62 = HidPriIndex1.Value.Substring(6, 2);
        //学生卡
        if (type == "01")
        {
            if (string.IsNullOrEmpty(selDate.SelectedValue))
            {
                context.AddError("A005020003:学生卡有效日期不能为空", selDate);
                return;
            }
            HidNewYearInfo.Value = selDate.SelectedValue + "0930";
            HidNewPriIndex1.Value = HidPriIndex1.Value;
        }
        //老人卡
        else if (type == "02")
        {
            if (toDate2.Checked)
            {
                HidNewYearInfo.Value = nextyear + "1231";
                HidNewPriIndex1.Value = HidPriIndex1.Value;
            }
            else
            {
                HidNewYearInfo.Value = thisyear + "1231";
                HidNewPriIndex1.Value = HidPriIndex1.Value;
            }
            
        }
        //劳模卡
        else if (type == "05")
        {
            if (toDateForLM.Checked)
            {
                HidNewYearInfo.Value = toDateForLM.Text.Substring(0,4)+"1231";
                HidNewPriIndex1.Value = "1718C2C2";
            }
            else
            {
                context.AddError("劳模卡有效日期不能为空");
                return;
            }
        }
        //其他卡类型
        else
        {
            //今年明年年审
            if (toDate1.Checked && toDate2.Checked)
            {
                HidNewYearInfo.Value = nextyear + "1231";
                if (temp == 0)
                {
                    HidNewPriIndex1.Value = nextyearsub + thisyearsub + "C2C2";
                }
                else
                {
                    HidNewPriIndex1.Value = thisyearsub + nextyearsub + "C2C2";
                }
            }
            //今年年审
            else if (toDate1.Checked && toDate2.Checked == false)
            {
                HidNewYearInfo.Value = thisyear + "1231";
                if (temp == 0)
                {
                    HidNewPriIndex1.Value = indexpre02 + thisyearsub + indexpre42 + "C2";
                }
                else
                {
                    HidNewPriIndex1.Value = thisyearsub + indexpre22 + "C2" + indexpre62;
                }
            }
            //明年年审
            else if (toDate2.Checked && toDate1.Checked == false)
            {
                HidNewYearInfo.Value = nextyear + "1231";
                if (temp == 0)
                {
                    HidNewPriIndex1.Value = nextyearsub + indexpre22 + "C2" + indexpre62;
                }
                else
                {
                    HidNewPriIndex1.Value = indexpre02 + nextyearsub + indexpre42 + "C2";
                }
            }
            else
            {
                context.AddError("请选择年审时间！");
            }
        }
        //判断页面上的证件号码、联系电话、联系地址是否修改 并取值
        string custPaperNo = CommonHelper.GetPaperNo(hidForPaperNo.Value) == txtPaperNo.Text.Trim() ? hidForPaperNo.Value : txtPaperNo.Text.Trim();
        string custPhone = CommonHelper.GetCustPhone(hidForPhone.Value) == txtCustPhone.Text.Trim() ? hidForPhone.Value : txtCustPhone.Text.Trim();
        string custAddr = CommonHelper.GetCustAddress(hidForAddr.Value) == txtCustAddr.Text.Trim() ? hidForAddr.Value : txtCustAddr.Text.Trim();

        // 调用月票卡年审存储过程  

        context.SPOpen();
        context.AddField("p_ID").Value = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        context.AddField("p_cardNo").Value = txtCardNo.Text;
        int insuranceFee = (Convert.ToInt32(inMoney.Text))*100;
        context.AddField("p_insuranceFee", "Int32").Value = insuranceFee;//每年保险费
        context.AddField("p_cardTradeNo").Value = hidTradeNo.Value;
        context.AddField("p_tradeTypeCode").Value = "3G";
        context.AddField("p_terminalNo").Value = "112233445566";   // 目前固定写成112233445566
        context.AddField("p_cardMoney", "Int32").Value = (int)(Double.Parse(txtCardBalance.Text) * 100);//卡内余额
        context.AddField("p_yearCheckFlag").Value = HidNewYearInfo.Value.Substring(0,4);

        context.AddField("p_hidMonthlyFlag").Value = HidNewYearInfo.Value + HidNewPriIndex1.Value;


        context.AddField("p_checkdate1").Value = selDate.SelectedValue;
        if (!toDate1.Checked)
        {
            thisyear = "";
        }

        if (!toDate2.Checked)
        {
            nextyear = "";
        }
        context.AddField("p_checkdate2").Value = thisyear;
        context.AddField("p_checkdate3").Value = nextyear;
        context.AddField("p_checkdate4").Value = toDateForLM.Text.Substring(0,4);


        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustName.Text, ref strBuilder);
        context.AddField("p_custName").Value = strBuilder.ToString();
        context.AddField("p_custSex").Value = selCustSex.SelectedValue;
        context.AddField("p_custBirth").Value = txtCustBirth.Text;
        context.AddField("p_paperType").Value = selPaperType.SelectedValue;

        //新旧标识位
        context.AddField("p_oldFlag").Value =  HidYPFlag.Value+ HidPrivilege.Value+ HidAppRange.Value+ HidYearInfo.Value+ HidPriIndex1.Value+ HidPriIndex2.Value + HidPriIndex3.Value + HidPriIndex4.Value + HidPriIndex5.Value + HidPriIndex6.Value + HidCRCCheck.Value;
        context.AddField("p_newFlag").Value =  HidYPFlag.Value + HidPrivilege.Value + HidAppRange.Value + HidNewYearInfo.Value + HidNewPriIndex1.Value + HidPriIndex2.Value + HidPriIndex3.Value + HidPriIndex4.Value + HidPriIndex5.Value + HidPriIndex6.Value + HidCRCCheck.Value;

        context.AddField("p_appType").Value = HidAppType.Value;
        context.AddField("p_assignedArea").Value = HidYPFlag.Value;


        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPaperNo, ref strBuilder);
        context.AddField("p_paperNo").Value = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custAddr, ref strBuilder);
        context.AddField("p_custAddr").Value = strBuilder.ToString();
        context.AddField("p_custPost").Value = txtCustPost.Text;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPhone, ref strBuilder);
        context.AddField("p_custPhone").Value = strBuilder.ToString();
        context.AddField("p_custEmail").Value = txtEmail.Text;
        context.AddField("p_remark").Value = txtRemark.Text;
        context.AddField("p_custRecTypeCode").Value = "0";
        bool ok = context.ExecuteSP("SP_AS_MonthlyCardYearCheck");

        // 执行存储过程
        btnSubmit.Enabled = false;


        //年检字段获取
        hidMonthlyFlag.Value = HidNewYearInfo.Value+HidNewPriIndex1.Value;

        // 存储过程执行成功，显示成功消息
        if (ok)
        {

            // AddMessage("D005090001: 月票卡后台年检成功，等待写卡操作");
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "startMonthlyYearCheck();", true);

            btnPrintPZ.Enabled = true;
            // 准备收据打印数据
            ASHelper.preparePingZheng(ptnPingZheng, txtCardNo.Text, txtCustName.Text, "月票卡年审", Total.Text
                , "0.00", "", txtPaperNo.Text, "0.00", "0.00", Total.Text, context.s_UserID,
                context.s_DepartName,
                selPaperType.SelectedValue == "" ? "" : selPaperType.SelectedItem.Text, "0.00", "0.00");

        }
    }


    protected void selDate_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (selDate.SelectedIndex != 0)
        {
            string year = System.DateTime.Today.ToString("yyyy");
            int a = (Convert.ToInt32(selDate.SelectedValue) - Convert.ToInt32(year)) + 1;
            yearNum.Text = a.ToString();
            Total.Text = "0.00";
        }
        else
        {
            yearNum.Text = "0";
            Total.Text = "0.00";
        }
        hidAccRecv.Value = Total.Text;
    }

    protected void toDate1_CheckedChanged(object sender, EventArgs e)
    {
        if (HidAppType.Value == "02" || HidAppType.Value == "03")
        {
            if (toDate2.Checked && toDate1.Checked)
            {
                yearNum.Text = "2";
                Total.Text = "20";
            }
            else if (toDate1.Checked && toDate2.Checked == false)
            {
                yearNum.Text = "1";
                Total.Text = "10";
            }
            else if (toDate2.Checked && toDate1.Checked == false)
            {
                yearNum.Text = "1";
                Total.Text = "10";
            }
            else
            {
                yearNum.Text = "0";
                Total.Text = "0";
            }
            hidAccRecv.Value = Total.Text;
        }
        else
        {
            if (toDate2.Checked && toDate1.Checked)
            {
                yearNum.Text = "2";
                Total.Text = "0";
            }
            else if (toDate1.Checked && toDate2.Checked == false)
            {
                yearNum.Text = "1";
                Total.Text = "0";
            }
            else if (toDate2.Checked && toDate1.Checked == false)
            {
                yearNum.Text = "1";
                Total.Text = "0";
            }
            else
            {
                yearNum.Text = "0";
                Total.Text = "0";
            }
            hidAccRecv.Value = Total.Text;
        }
    }

    protected void toDateForLM_CheckedChanged(object sender, EventArgs e)
    {
        int year = System.DateTime.Today.Year;
        if (toDateForLM.Checked)
        {
            if (Convert.ToInt32(toDateForLM.Text.Substring(0, 4)) >= year)
            {
                yearNum.Text = ((Convert.ToInt32(toDateForLM.Text.Substring(0, 4)) - year) + 1).ToString();
                Total.Text = "0";
            }
            else
            {
                context.AddError("当前时间已过该类卡年检期限");
            }
        }
        else
        {
            yearNum.Text = "0";
            Total.Text = "0";
        }
        hidAccRecv.Value = Total.Text;
    }
}