using System.Collections.Generic;
using System.Data;
using TM;
using System;
using Common;
using TDO.BusinessCode;
using System.Text;
using System.Web.UI;
using TDO.ResourceManager;
using PDO.PersonalBusiness;
using System.Globalization;
using System.Web.UI.WebControls;

// 月票卡换卡
public partial class ASP_AddtionalService_AS_MonthlyCardChange : Master.FrontMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            hidReissue.Value = Request.Params["Reissue"];

            if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

            // 设置可读属性
            setReadOnly(txtCardBalance, txtStartDate, txtEndDate);

            // 设置焦点以及按键事件
            txtRealRecv.Attributes["onfocus"] = "this.select();";
            txtRealRecv.Attributes["onkeyup"] = "realRecvChanging(this);";

            // 行政区域
            selMonthlyCardDistrict.Items.Add(new ListItem("---请选择---", ""));

            // 初始化证件类型
            ASHelper.initPaperTypeList(context, selPaperType);

            // 初始化性别
            ASHelper.initSexList(selCustSex);

            //初始化已开通月份信息
            DateTime dt = DateTime.Now;
            Month1.Text = dt.ToString("yyyy-MM");
            Month2.Text = dt.AddMonths(1).ToString("yyyy-MM");
            Month3.Text = dt.AddMonths(2).ToString("yyyy-MM");
            Month4.Text = dt.AddMonths(3).ToString("yyyy-MM");

            //初始化最近13年
            string year = System.DateTime.Today.ToString("yyyy");
            selDate.Items.Add(new ListItem("-----请选择-----", ""));
            for (int i = 0; i < 13; i++)
            {
                selDate.Items.Add(new ListItem(year + "年9月30日", year));

                year = (Convert.ToInt32(year) + 1).ToString();
            }
            //获取token
            string token;
            string sql = "SELECT SYSDATE FROM DUAL";

            TMTableModule tm = new TMTableModule();
            DataTable dt1 = tm.selByPKDataTable(context, sql, 1);
            DateTime now = (DateTime)dt1.Rows[0].ItemArray[0];
            TimeSpan epochTime = (now.ToUniversalTime() - new DateTime(1970, 1, 1));
            token = Token.createToken(context.s_CardID, (uint)epochTime.TotalSeconds);

            hidCardReaderToken1.Value = token;

            // 初始化费用列表
            ThisYear.Visible = false;
            NextYear.Visible = false;
            Insurance.Text = "0.00";
            ChargeFee.Text = "0.00";
            Total.Text = "0.00";
            ThisYear.Text = DateTime.Now.Year + "年12月31日";
            NextYear.Text = (DateTime.Now.Year + 1) + "年12月31日";
        }
        ScriptManager.RegisterStartupScript(this, GetType(), "reloadEnterToTab", "changeEnterToTab();", true);
    }

    // 初始化费用项gridview
    private void InitGridView()
    {
        // 业务类型编码表：
        string type = selMonthlyCardType.SelectedValue;

        // 根据月票类型得到补卡的业务类型编码
        hidTradeTypeCode.Value
                = type == "02" ? "74" // 老人月票换卡
                : type == "03" ? "75" // 高龄卡换卡
                : type == "01" ? "73" // 学生月票卡换卡
                : "";

        if (Convert.ToInt32(DateTime.Now.Month) >= 10)
        {
            NextYear.Visible = true;
        }

        ThisYear.Visible = true;
        ThisYear.Checked = false;
        NextYear.Checked = false;
        Insurance.Text = "0.00";
        Total.Text = (Convert.ToDecimal(Insurance.Text)).ToString("0.00");
        txtRealRecv.Text = Total.Text;
        hidAccRecv.Value = Total.Text;

    }
    /// <summary>
    /// 读卡处理
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        #region add by liuhe 20120104 添加对代理营业厅预付款的验证
        if (DeptBalunitHelper.ValdatePrepay(context) == false)
        {
            return;
        }
        #endregion

        // 读取卡片类型
        readCardType(txtCardNo.Text, labCardType);

        // 读取卡片状态
        ASHelper.readCardState(context, txtCardNo.Text, txtCardState);
        if (txtCardState.Text.Trim() != "售出" && txtCardState.Text.Trim() != "换卡售出")
        {
            context.AddError("新卡不是售出状态！");
            return;
        }

        //根据读取的卡内信息填充页面
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_APPAREATDO ddoTD_M_APPAREAIn = new TD_M_APPAREATDO();
        ddoTD_M_APPAREAIn.AREACODE = HidYPFlag.Value;
        TD_M_APPAREATDO ddoTD_M_APPAREAOut = (TD_M_APPAREATDO)tmTMTableModule.selByPK(context, ddoTD_M_APPAREAIn, typeof(TD_M_APPAREATDO), null);

        if (ddoTD_M_APPAREAOut != null)
        {
            hidWarning.Value = "已经开通了" + ddoTD_M_APPAREAOut.AREANAME + "!<br><br>是否继续换卡?";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "warnScript", "warnConfirm();", true);

        }

        //从用户卡库存表(TL_R_ICUSER)中读取数据
        TMTableModule tmTmTableModule = new TMTableModule();
        TL_R_ICUSERTDO ddoTlRIcuserIn = new TL_R_ICUSERTDO();
        ddoTlRIcuserIn.CARDNO = txtCardNo.Text;

        TL_R_ICUSERTDO ddoTlRIcuserOut = (TL_R_ICUSERTDO)tmTmTableModule.selByPK(context, ddoTlRIcuserIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

        if (ddoTlRIcuserOut == null)
        {
            context.AddError("A001004128");
            return;
        }
        ReadCustInfo(txtCardNo.Text);

        //重置重置栏
        Month1.Checked = false;
        Month2.Checked = false;
        Month3.Checked = false;
        Month4.Checked = false;

        btnPrintPZ.Enabled = false;
        btnSubmit.Enabled = !context.hasError();
        ScriptManager1.SetFocus(btnSubmit);
    }

    /// <summary>
    /// 读二代证后台按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void txtReadPaper_Click(object sender, EventArgs e)
    {
        ScriptManager1.SetFocus(btnSubmit);
    }

    /// <summary>
    /// 读取客户信息
    /// </summary>
    /// <param name="cardno"></param>
    private void ReadCustInfo(string cardno)
    {
        DataTable data = ASHelper.callQuery(context, "QueryCustInfo", cardno);
        if (data.Rows.Count == 0)
        {
            context.AddError("A00501A002: 无法读取卡片客户资料");
            return;
        }

        //add by jiangbb 解密
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

    /// <summary>
    /// 确认对话框确认处理
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")    // 是否继续
        {
            btnSubmit.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess") // 写卡成功
        {
            clearCustInfo(selMonthlyCardType,
               txtCardNo, txtCustName, txtCustBirth, selPaperType, txtPaperNo,
               selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);

            AddMessage("月票卡前台写卡成功，月票卡换卡成功");

        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("月票卡前台写卡失败，月票卡换卡失败");
        }

        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }

        hidWarning.Value = ""; // 清除警告信息
    }

    /// <summary>
    /// 提交判断
    /// </summary>
    private void SubmitValidate()
    {
        string custPaperNo = CommonHelper.GetPaperNo(hidForPaperNo.Value) == txtPaperNo.Text.Trim().ToUpper() ? hidForPaperNo.Value : txtPaperNo.Text.Trim().ToUpper();
        string custPhone = CommonHelper.GetCustPhone(hidForPhone.Value) == txtCustPhone.Text.Trim() ? hidForPhone.Value : txtCustPhone.Text.Trim();
        string custAddr = CommonHelper.GetCustAddress(hidForAddr.Value) == txtCustAddr.Text.Trim() ? hidForAddr.Value : txtCustAddr.Text.Trim();

        // 校验客户信息
        //对用户姓名进行非空、长度检验
        if (txtCustName.Text.Trim() == "")
            context.AddError("A001001111", txtCustName);
        else if (Validation.strLen(txtCustName.Text.Trim()) > 50)
            context.AddError("A001001113", txtCustName);

        //对证件类型进行非空检验
        if (selPaperType.SelectedValue == "")
            context.AddError("A001001117", selPaperType);

        //对出生日期进行日期格式检验
        String cDate = txtCustBirth.Text.Trim();
        if (cDate != "")
            if (!Validation.isDate(txtCustBirth.Text.Trim(), "yyyyMMdd"))
                context.AddError("A001001115", txtCustBirth);

        //对联系电话进行非空、长度、数字检验
        if (custPhone != "")
            if (Validation.strLen(custPhone) > 20)
                context.AddError("A001001126", txtCustPhone);
            else if (!Validation.isNum(custPhone))
                context.AddError("A001001125", txtCustPhone);

        //对证件号码进行非空、长度、英数字检验
        if (custPaperNo == "")
            context.AddError("A001001121", txtPaperNo);
        else if (!Validation.isCharNum(custPaperNo))
            context.AddError("A001001122", txtPaperNo);
        else if (Validation.strLen(custPaperNo) > 20)
            context.AddError("A001001123", txtPaperNo);

        if (selPaperType.SelectedValue == "00" && !Validation.CheckIDCard(custPaperNo))
        {
            context.AddError("A001001131:身份证号码无效", txtPaperNo);
        }

        //对邮政编码进行非空、长度、数字检验
        if (txtCustPost.Text.Trim() != "")
        {
            if (Validation.strLen(txtCustPost.Text.Trim()) != 6)
                context.AddError("A001001120", txtCustPost);
            else if (!Validation.isNum(txtCustPost.Text.Trim()))
                context.AddError("A001001119", txtCustPost);
        }

        //对联系地址进行非空、长度检验
        if (txtCustAddr.Text.Trim() != "")
        {
            if (Validation.strLen(custAddr) > 50)
                context.AddError("A001001128", txtCustAddr);
        }

        //对备注进行长度检验
        if (txtRemark.Text.Trim() != "")
            if (Validation.strLen(txtRemark.Text.Trim()) > 50)
                context.AddError("A001001129", txtRemark);

        //对电子邮件进行格式检验
        if (txtEmail.Text.Trim() != "")
            new Validation(context).isEMail(txtEmail);

        Validation valid = new Validation(context);
        valid.check(selMonthlyCardType.SelectedValue != "", "A005090001: 月票类型必须选择", selMonthlyCardType);
        valid.check(selMonthlyCardDistrict.SelectedValue != "", "A005090002: 行政区域必须选择", selMonthlyCardDistrict);
        valid.check(txtCustName.Text != "", "A005090003: 客户姓名必填", txtCustName);
        valid.check(selPaperType.SelectedValue != "", "A005090004: 证件类型必须选择", selPaperType);
        valid.check(selCustSex.SelectedValue != "", "A005090005: 性别必须选择", selCustSex);
        valid.check(txtPaperNo.Text != "", "A005090006:身份证号码必填 ", txtPaperNo);

    }
    /// <summary>
    /// 获取月份字段
    /// </summary>
    /// <param name="month"></param>
    /// <returns></returns>
    private int DigitByMonth(string month)
    {
        int mon = Convert.ToInt32(month);
        int digit = mon == 1 ? 0
                  : mon == 2 ? 2
                  : mon == 3 ? 8
                  : mon == 4 ? 10
                  : mon == 5 ? 16
                  : mon == 6 ? 18
                  : mon == 7 ? 24
                  : mon == 8 ? 26
                  : mon == 9 ? 32
                  : mon == 10 ? 34
                  : mon == 11 ? 40
                  : mon == 12 ? 42
                  : 1;
        return digit;
    }
    /// <summary>
    /// 获取月份简化值
    /// </summary>
    /// <param name="mon"></param>
    /// <returns></returns>
    public static string SimMonth(string mon)
    {
        string sim = mon == "01" ? "1"
                   : mon == "02" ? "2"
                   : mon == "03" ? "3"
                   : mon == "04" ? "4"
                   : mon == "05" ? "5"
                   : mon == "06" ? "6"
                   : mon == "07" ? "7"
                   : mon == "08" ? "8"
                   : mon == "09" ? "9"
                   : mon == "10" ? "A"
                   : mon == "11" ? "B"
                   : mon == "12" ? "C"
                   : "";
        return sim;

    }



    /// <summary>
    /// 月票卡售卡提交
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if ((selMonthlyCardType.SelectedValue)=="")
        {
            context.AddError("请选择月票类型！");
            return;
        }
        if (!ThisYear.Checked && !NextYear.Checked && selDate.SelectedValue == "")
        {
            context.AddError("请选择年审时间！");
            return;
        }
        #region add by liuhe 20120104 添加对代理营业厅预付款的验证,提交前如果扣费后不足最低额度则返回
        int opMoney = Convert.ToInt32(Double.Parse(hidAccRecv.Value) * 100);
        if (DeptBalunitHelper.ValdatePrepay(context, opMoney, "2") == false)
        {
            return;
        }
        #endregion



        SubmitValidate();

        //设置年审控件参数
        string type = selMonthlyCardType.SelectedValue;
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

        //今年明年年审
        if (ThisYear.Checked && NextYear.Checked)
        {
            HidYearInfo.Value = nextyear + "1231";
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
        else if (ThisYear.Checked && NextYear.Checked == false)
        {
            HidYearInfo.Value = thisyear + "1231";
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
        else if (NextYear.Checked && ThisYear.Checked == false)
        {
            HidYearInfo.Value = nextyear + "1231";
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
            if (selMonthlyCardType.SelectedValue == "01")
            {
                HidYearInfo.Value = selDate.SelectedValue + "0930";
                HidNewPriIndex1.Value = HidPriIndex1.Value;
            }
            else
            {
                context.AddError("请选择年审时间！");
            }
        }
        //获取充值字段
        string CZYear1 = Month1.Checked ? Month1.Text.Substring(2, 2) : null;
        string CZMonth1 = Month1.Checked ? Month1.Text.Substring(5, 2) : null;
        string CZYear2 = Month2.Checked ? Month2.Text.Substring(2, 2) : null;
        string CZMonth2 = Month2.Checked ? Month2.Text.Substring(5, 2) : null;
        string CZYear3 = Month3.Checked ? Month3.Text.Substring(2, 2) : null;
        string CZMonth3 = Month3.Checked ? Month3.Text.Substring(5, 2) : null;
        string CZYear4 = Month4.Checked ? Month4.Text.Substring(2, 2) : null;
        string CZMonth4 = Month4.Checked ? Month4.Text.Substring(5, 2) : null;
        string oldflag = "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
        string KTMonthHZ = null;
        if (Month1.Checked)
        {
                oldflag = oldflag.Remove(DigitByMonth(CZMonth1), 2);
                oldflag = oldflag.Insert(DigitByMonth(CZMonth1), CZYear1);
                oldflag = oldflag.Remove(DigitByMonth(CZMonth1) + 4, 2);
                oldflag = oldflag.Insert(DigitByMonth(CZMonth1) + 4,SimMonth(CZMonth1) + "2");
                KTMonthHZ = CZMonth1 + ".";
        }
        if (Month2.Checked)
        {
            
                oldflag = oldflag.Remove(DigitByMonth(CZMonth2), 2);
                oldflag = oldflag.Insert(DigitByMonth(CZMonth2), CZYear2);
                oldflag = oldflag.Remove(DigitByMonth(CZMonth2) + 4, 2);
                oldflag = oldflag.Insert(DigitByMonth(CZMonth2) + 4, SimMonth(CZMonth2) + "2");
                KTMonthHZ += CZMonth2 + ".";
        }
        if (Month3.Checked)
        {
                oldflag = oldflag.Remove(DigitByMonth(CZMonth3), 2);
                oldflag = oldflag.Insert(DigitByMonth(CZMonth3), CZYear3);
                oldflag = oldflag.Remove(DigitByMonth(CZMonth3) + 4, 2);
                oldflag = oldflag.Insert(DigitByMonth(CZMonth3) + 4, SimMonth(CZMonth3) + "2");
                KTMonthHZ += CZMonth3 + ".";
        }
        if (Month4.Checked)
        {
                oldflag = oldflag.Remove(DigitByMonth(CZMonth4), 2);
                oldflag = oldflag.Insert(DigitByMonth(CZMonth4), CZYear4);
                oldflag = oldflag.Remove(DigitByMonth(CZMonth4) + 4, 2);
                oldflag = oldflag.Insert(DigitByMonth(CZMonth4) + 4, SimMonth(CZMonth4) + "2");
                KTMonthHZ += CZMonth4 + ".";
        }
        HidPriIndex.Value = oldflag;


        string custPaperNo = txtPaperNo.Text.Trim().ToUpper();
        string custPhone = txtCustPhone.Text.Trim();
        string custAddr = txtCustAddr.Text.Trim();
        if (context.hasError()) return;


        //年检字段获取
        string hidPriType = null;
        if (selMonthlyCardType.SelectedValue == "01" || selMonthlyCardType.SelectedValue == "02")
        {
            hidPriType = "01";
        }
        else
        {
            hidPriType = "04";
        }
        //写卡功能编码赋值
        hidMonthlyFlag.Value = selMonthlyCardDistrict.SelectedValue + (selCustSex.SelectedValue == "0" ? "C1" : "C0") + hidPriType;
        hidMonthlyFlagYearCheck.Value = HidYearInfo.Value + HidNewPriIndex1.Value;
        hidMonthlyFlagChange.Value = HidPriIndex.Value;

        // 调用月票卡换卡存储过程
        context.SPOpen();
        context.AddField("p_ID").Value = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        context.AddField("p_cardNo").Value = txtCardNo.Text;
        context.AddField("p_otherFee").Value = (int)(Double.Parse(Insurance.Text) * 100);
        context.AddField("p_cardTradeNo").Value = hidTradeNo.Value;
        context.AddField("p_asn").Value = hidAsn.Value.Substring(4, 16);
        context.AddField("p_cardMoney").Value = (int)(Double.Parse(txtCardBalance.Text) * 100);
        context.AddField("p_sellChannelCode").Value = "01";
        context.AddField("p_serTakeTag").Value = "0";
        context.AddField("p_tradeTypeCode").Value = hidTradeTypeCode.Value;
        context.AddField("p_terminalNo").Value = "112233445566";   // 目前固定写成112233445566

        context.AddField("p_hidMonthlyFlag").Value = selMonthlyCardDistrict.SelectedValue + (selCustSex.SelectedValue == "0" ? "C1" : "C0") + hidPriType;
        context.AddField("p_hidMonthlyFlagYearCheck").Value = HidYearInfo.Value + HidNewPriIndex1.Value;
        context.AddField("p_hidMonthlyFlagChange").Value = HidPriIndex.Value;

        string chargecode = selMonthlyCardType.SelectedValue == "01" ? "3M"
                          : selMonthlyCardType.SelectedValue == "02" ? "3L"
                          :  "";
        //充值日期
        context.AddField("p_chargeFee", "Int32").Value = MonthFeeOrNot.SelectedValue == "1" ? 2000 : 0;                   //充值类型
        context.AddField("p_chargeCode").Value = chargecode;                            //充值费用
        context.AddField("p_chargeMonth1").Value = Month1.Checked ? Month1.Text.Remove(4, 1) : "";//充值月份
        context.AddField("p_chargeMonth2").Value = Month2.Checked ? Month2.Text.Remove(4, 1) : "";
        context.AddField("p_chargeMonth3").Value = Month3.Checked ? Month3.Text.Remove(4, 1) : "";
        context.AddField("p_chargeMonth4").Value = Month4.Checked ? Month4.Text.Remove(4, 1) : "";

        //加密 ADD BY JIANGBB 2012-04-19
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustName.Text.Replace(" ", ""), ref strBuilder);
        context.AddField("p_custName").Value = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPhone, ref strBuilder);
        context.AddField("p_custPhone").Value = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custAddr, ref strBuilder);
        context.AddField("p_custAddr").Value = strBuilder.ToString();

        context.AddField("p_custBirth").Value = txtCustBirth.Text;
        context.AddField("p_paperType").Value = selPaperType.SelectedValue;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPaperNo, ref strBuilder);
        context.AddField("p_paperNo").Value = strBuilder.ToString();

        context.AddField("p_custSex").Value = selCustSex.SelectedValue;
        context.AddField("p_custPost").Value = txtCustPost.Text;
        context.AddField("p_custEmail").Value = txtEmail.Text;
        context.AddField("p_remark").Value = txtRemark.Text;

        context.AddField("p_custRecTypeCode").Value = "1";//记名卡

        context.AddField("p_appType").Value = selMonthlyCardType.SelectedValue;

        context.AddField("p_endtime").Value = HidYearInfo.Value;

        context.AddField("p_assignedArea").Value = selMonthlyCardDistrict.SelectedValue;
        context.AddField("p_currCardNo").Value = context.s_CardID;
        if (!ThisYear.Checked)
        {
            thisyear = "";
        }

        if (!NextYear.Checked)
        {
            nextyear = "";
        }
        context.AddField("p_checkdate1").Value = thisyear;
        context.AddField("p_checkdate2").Value = nextyear;
        context.AddField("p_feeornot").Value = feeOrNot.SelectedValue;

        //学生卡年检相关
        context.AddField("p_isStudent").Value = selMonthlyCardType.SelectedValue == "01" ? "1" : "0";
        context.AddField("p_checkdate3").Value = selDate.SelectedValue;



        //卡押金写卡
        hiddenDeposit.Value = Double.Parse(hidDeposit.Value).ToString(CultureInfo.InvariantCulture);
        // 执行存储过程
        bool ok = context.ExecuteSP("SP_AS_MonthlyCardChange");
        btnSubmit.Enabled = false;



        // 存储过程执行成功，显示成功消息
        if (ok)
        {
            context.AddMessage("月票换卡成功");
            // 准备收据打印数据
            ASHelper.preparePingZheng(ptnPingZheng, txtCardNo.Text, txtCustName.Text, "月票卡换卡", "", "", "",
                ASHelper.GetPaperNo(txtPaperNo.Text), "月份" + KTMonthHZ, "0.00", Total.Text, context.s_UserID, context.s_DepartName,
                selPaperType.SelectedValue == "" ? "" : selPaperType.SelectedItem.Text, "0.00", "0.00");

            btnPrintPZ.Enabled = true;

            if (selMonthlyCardType.SelectedValue == "03")
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "writeCardScript", "startMonthlyMakeUp();", true);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "writeCardScript", "startMonthlyChange();", true);
            }

            clearCustInfo(selMonthlyCardType,
              txtCardNo, txtCustName, txtCustBirth, selPaperType, txtPaperNo,
              selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);
        }
    }

    /// <summary>
    /// 选择月票类型变更事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void selMonthlyCardType_SelectedIndexChanged(object sender, EventArgs e)
    {
        ASHelper.SelectDistricts(context, selMonthlyCardDistrict, selMonthlyCardType.SelectedValue);

        ScriptManager1.SetFocus(selMonthlyCardType);

        // 初始化费用
        InitGridView();

        //高龄卡隐藏充值栏
        if (selMonthlyCardType.SelectedValue == "03")
        {
            Month1.Visible = false;
            Month2.Visible = false;
            Month3.Visible = false;
            Month4.Visible = false;
            MonthFeeOrNot.Visible = false;
            selDate.Visible = false;
            ThisYear.Visible = true;
        }
        else
        {
            Month1.Visible = true;
            Month2.Visible = true;
            Month3.Visible = true;
            Month4.Visible = true;
            MonthFeeOrNot.Visible = true;
            if (selMonthlyCardType.SelectedValue == "01")
            {
                selDate.Visible = true;
                ThisYear.Visible = false;
            }
            else
            {
                selDate.Visible = false;
                ThisYear.Visible = true;
            }
        }
    }


    protected void Year_CheckedChanged(object sender, EventArgs e)
    {
        if (feeOrNot.SelectedValue == "1")
        {
            ChangeFee();
        }
    }

    private void ChangeFee()
    {
        HidYearInfo.Value = NextYear.Text.Substring(0, 4) + "1231";
        if (ThisYear.Checked && NextYear.Checked)
        {
            Insurance.Text = "20.00";
        }
        else if (ThisYear.Checked && NextYear.Checked == false)
        {
            Insurance.Text = "10.00";
        }
        else if (NextYear.Checked && ThisYear.Checked == false)
        {
            Insurance.Text = "10.00";
        }
        else
        {
            Insurance.Text = "0.00";
        }
        Total.Text = (Convert.ToDecimal(ChargeFee.Text) + Convert.ToDecimal(Insurance.Text)).ToString("0.00");
        hidAccRecv.Value = Total.Text;
        txtRealRecv.Text = Total.Text;
    }

    private void ChangeChargeFee()
    {
        string munNum = (Convert.ToInt32(Month1.Checked) + Convert.ToInt32(Month2.Checked) + Convert.ToInt32(Month3.Checked) + Convert.ToInt32(Month4.Checked)).ToString();
        int a = 20;
        int b = Convert.ToInt32(munNum);
        ChargeFee.Text = (a * b).ToString()+".00";
        Total.Text = (Convert.ToDecimal(ChargeFee.Text) + Convert.ToDecimal(Insurance.Text)).ToString("0.00");
        hidAccRecv.Value = Total.Text;
        txtRealRecv.Text = Total.Text;

    }

    /// <summary>
    /// 选择是否收费类型变更事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void feeOrNot_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (feeOrNot.SelectedValue == "1")
        {
            ChangeFee();
        }
        else
        {
            Insurance.Text = "0.00";
            Total.Text = (Convert.ToDecimal(ChargeFee.Text) + Convert.ToDecimal(Insurance.Text)).ToString("0.00");
            hidAccRecv.Value = Total.Text;
            txtRealRecv.Text = Total.Text;
        }

    }

    protected void monthFeeOrNot_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (MonthFeeOrNot.SelectedValue == "1")
        {
            ChangeChargeFee();
        }
        else
        {
            ChargeFee.Text = "0.00";
            Total.Text = (Convert.ToDecimal(ChargeFee.Text)+ Convert.ToDecimal(Insurance.Text)).ToString("0.00");
            hidAccRecv.Value = Total.Text;
            txtRealRecv.Text = Total.Text;
        }
    }
    protected void Month1_CheckedChanged(object sender, EventArgs e)
    {
        if (MonthFeeOrNot.SelectedValue == "1")
        {
            ChangeChargeFee();
        }
        else
        {
            ChargeFee.Text = "0.00";
            Total.Text = (Convert.ToDecimal(ChargeFee.Text) + Convert.ToDecimal(Insurance.Text)).ToString("0.00");
            hidAccRecv.Value = Total.Text;
            txtRealRecv.Text = Total.Text;
        }
    }
}