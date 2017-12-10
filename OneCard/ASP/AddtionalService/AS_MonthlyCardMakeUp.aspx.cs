using System.Collections.Generic;
using System.Data;
using TDO.BusinessCode;
using TM;
using System;
using Common;
using System.Text;
using System.Web.UI;
using TDO.ResourceManager;
using PDO.PersonalBusiness;
using System.Globalization;
using System.Web.UI.WebControls;

public partial class ASP_AddtionalService_AS_MonthlyCardMakeUp : Master.FrontMaster
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
            Total.Text = "0.00";
            hidAccRecv.Value = Total.Text;
            hidAccRecv.Value = Total.Text;
            ThisYear.Text = DateTime.Now.Year + "年12月31日";
            NextYear.Text = (DateTime.Now.Year + 1) + "年12月31日";
        }
        ScriptManager.RegisterStartupScript(this, GetType(), "reloadEnterToTab", "changeEnterToTab();", true);
    }

    // 初始化费用项gridview
    private void InitGridView()
    {
        // 业务类型编码表：31学生月票开卡，32老人月票开卡 23高龄开卡 7A残疾人月票开卡
        string type = selMonthlyCardType.SelectedValue;

        // 根据月票类型得到补卡的业务类型编码
        hidTradeTypeCode.Value
                = type == "02" ? "71" // 老人月票补卡
                : type == "03" ? "72" // 高龄卡补卡
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
    /// 保险费内容变化
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Insurance_change(object sender, EventArgs e)
    {
        try
        {
            Total.Text = (Convert.ToDecimal(Insurance.Text)).ToString("0.00");
            txtRealRecv.Text = Total.Text;
            hidAccRecv.Value = Total.Text;
        }
        catch
        {
            context.AddError("请输入正确的保险费金额");
        }
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

        //添加对市民卡的验证
        SP_SmkCheckPDO pdo = new SP_SmkCheckPDO();
        pdo.CARDNO = txtCardNo.Text;
        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok == false)
        {
            return;
        }

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
            hidWarning.Value = "已经开通了" + ddoTD_M_APPAREAOut .AREANAME+ "!<br><br>是否继续补卡?";
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

            AddMessage("D005100002: 月票卡前台写卡成功，月票卡补卡成功");

        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("A00510C001: 月票卡前台写卡失败，月票卡补卡失败");
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

        if (selCustSex.SelectedValue=="")
        {
            context.AddError("A001001116", selCustSex);
        }
    }


    /// <summary>
    /// 月票卡售卡提交
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
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
            context.AddError("请选择年审时间！");
        }

        //类型判断   01：年票   04 ：月票
        if (selMonthlyCardType.SelectedValue == "01" || selMonthlyCardType.SelectedValue == "02")
        {
            hidPriType.Value = "01";
        }
        else
        {
            hidPriType.Value = "04";
        }
        string custPaperNo = txtPaperNo.Text.Trim().ToUpper();
        string custPhone = txtCustPhone.Text.Trim();
        string custAddr = txtCustAddr.Text.Trim();
        if (context.hasError()) return;
        // 调用月票卡售卡存储过程
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

        context.AddField("p_hidMonthlyFlagYearCheck").Value = HidYearInfo.Value + HidNewPriIndex1.Value;
        context.AddField("p_hidMonthlyFlag").Value = selMonthlyCardDistrict.SelectedValue + (selCustSex.SelectedValue == "0" ? "C1" : "C0") + hidPriType.Value;


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


        //写卡月票功能编码赋值
        hidMonthlyFlag.Value = selMonthlyCardDistrict.SelectedValue + (selCustSex.SelectedValue == "0" ? "C1" : "C0") + hidPriType.Value;

        //卡押金写卡
        hiddenDeposit.Value = Double.Parse(hidDeposit.Value).ToString(CultureInfo.InvariantCulture);
        // 执行存储过程
        bool ok = context.ExecuteSP("SP_AS_MonthlyCardMakeUp");
        btnSubmit.Enabled = false;
        //年检字段获取
        hidMonthlyFlagYearCheck.Value = HidYearInfo.Value + HidNewPriIndex1.Value;

        // 存储过程执行成功，显示成功消息
        if (ok)
        {
            context.AddMessage("月票补卡成功");
            // 准备收据打印数据
            ASHelper.preparePingZheng(ptnPingZheng, txtCardNo.Text, txtCustName.Text, "月票卡补卡", "", "", "",
                ASHelper.GetPaperNo(txtPaperNo.Text), "0.00", "0.00", txtRealRecv.Text, context.s_UserID, context.s_DepartName,
                selPaperType.SelectedValue == "" ? "" : selPaperType.SelectedItem.Text, "0.00", "0.00", txtRealRecv.Text);

            btnPrintPZ.Enabled = true;

            ScriptManager.RegisterStartupScript(this, GetType(), "writeCardScript", "startMonthlyMakeUp();", true);

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
        Total.Text = (Convert.ToDecimal(Insurance.Text)).ToString("0.00");
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
            Total.Text = (Convert.ToDecimal(Insurance.Text)).ToString("0.00");
            hidAccRecv.Value = Total.Text;
            txtRealRecv.Text = Total.Text;
        }

    }
}