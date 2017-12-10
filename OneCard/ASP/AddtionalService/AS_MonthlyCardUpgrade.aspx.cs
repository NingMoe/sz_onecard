using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Globalization;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using TDO.BusinessCode;
using Common;
using TM;
using System.Text;
using PDO.AdditionalService;
using PDO.PersonalBusiness;
using TDO.ResourceManager;
using TDO.UserManager;

// 月票卡升级（从老人卡到高领卡）
public partial class ASP_AddtionalService_AS_MonthlyCardUpgrade : Master.FrontMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 设置可读属性

        if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

        setReadOnly(txtCardBalance, txtStartDate, txtEndDate);

        // 设置焦点以及按键事件
        txtRealRecv.Attributes["onfocus"] = "this.select();";
        txtRealRecv.Attributes["onkeyup"] = "realRecvChanging(this);";

        // 初始化证件类型        ASHelper.initPaperTypeList(context, selPaperType);

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
        // 初始化行政区域
        ASHelper.SelectDistricts(context, selMonthlyCardDistrict, "03");

        // 初始化费用列表
        initGridView(0, 0);
    }

    // 初始化费用项gridview
    private void initGridView(int cardDeposit, int eldCardDeposit)
    {
        initFeeItem(gvResult, "76", hidDeposit, hidCardPost, hidOtherFee, hidAccRecv,
           txtRealRecv, true, cardDeposit, eldCardDeposit);
    }

    // 读取卡片相关信息
    private void readCardInfo()
    {
        // 读取卡片类型
        readCardType(txtCardNo.Text, labCardType);

        // 读取卡片状态
        ASHelper.readCardState(context, txtCardNo.Text, txtCardState);

        // 读取客户资料
        readCustInfo(txtCardNo.Text, txtCustName, txtCustBirth,
            selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost,
            txtCustAddr, txtEmail, txtRemark);

        hidForPaperNo.Value = txtPaperNo.Text.Trim();
        hidForPhone.Value = txtCustPhone.Text.Trim();
        hidForAddr.Value = txtCustAddr.Text.Trim();

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtPaperNo.Text = CommonHelper.GetPaperNo(txtPaperNo.Text);
            txtCustPhone.Text = CommonHelper.GetCustPhone(txtCustPhone.Text);
            txtCustAddr.Text = CommonHelper.GetCustAddress(txtCustAddr.Text);
        }

        if (context.hasError()) return;

        string sql = "";
        sql="select saletype from tl_r_icuser where cardno = '"+txtCardNo.Text+"'";
        DataTable datasql = context.ExecuteReader(sql);
        if (datasql.Rows[0][0].ToString() == "01")//如果是卡费
        {
            decimal total = 0;

            hidDeposit.Value = "0";
            hidCardPost.Value = "0";
            hidOtherFee.Value = "0";
            txtRealRecv.Text = total.ToString("0");
            hidAccRecv.Value = total.ToString("n");

            DataTable dt = new DataTable();
            dt.Columns.Add("FEETYPENAME", typeof(string));
            dt.Columns.Add("BASEFEE", typeof(string));

            for (int i=0; i < 6; ++i)
            {
                dt.Rows.Add("", "");
            }
            dt.Rows.Add("合计应收", txtRealRecv.Text);

            gvResult.DataSource = dt;
            gvResult.DataBind();
        }
        else
        {
            // 读取卡片押金
            decimal cardDeposit = 0;

            DataTable data = ASHelper.callQuery(context, "CardDeposit", txtCardNo.Text);
            if (data.Rows.Count > 0)
            {
                cardDeposit = (decimal)data.Rows[0].ItemArray[0];
            }

            // 查询高龄卡开卡押金


            data = ASHelper.callQuery(context, "OldCardDeposit");
            decimal eldCardDeposit = 0;
            if (data.Rows.Count > 0)
            {
                eldCardDeposit = (decimal)data.Rows[0].ItemArray[0];
            }
            else
            {
                context.AddError("A005110003: 高龄卡押金费用项没有配置，无法初始化高龄卡押金");
            }

            initGridView((int)cardDeposit, (int)eldCardDeposit);
        }
    }

    // 校验月票卡资料
    private void CheckMonthlyCard()
    {
        // 校验月票卡应用类型

        DataTable data = ASHelper.callQuery(context, "CardAppType", txtCardNo.Text);
        if (data.Rows.Count != 1)
        {
            labMonthlyCardType.Text = "非月票卡";
            context.AddError("A005110001: 当前卡片不是月票卡");
            return;
        }
        string type = (string)(data.Rows[0].ItemArray[0]);
        labMonthlyCardType.Text
            = type == "01" ? "学生月票卡"
            : type == "02" ? "老人月票卡"
            : type == "03" ? "高龄卡"
            : type == "05" ? "劳模卡"
             : type == "06" ? "教育卡"  //add by youyue20140612新增06:教育卡
             : type == "07" ? "献血卡"  //add by youyue20160823新增07:献血卡
            : "未知月票卡";

        if (type != "02")
        {
            context.AddError("A005110002: 当前卡片不是老人月票卡");
            return;
        }
    }

    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        btnPrintPZ.Enabled = false;

        // 校验帐户信息
        checkAccountInfo(txtCardNo.Text);

        // 查询卡片是否是月票卡或高龄卡
        CheckMonthlyCard();

        // 读取卡片相关信息
        readCardInfo();

        if (!context.hasError() && txtCardNo.Text.Substring(4, 2).ToString() == "18")
        {
            context.AddMessage("提示：卡号为市民卡，客户资料不会被修改");
        }
        //增加用户年龄不超过70岁提示信息 add by youyue 20170210
        //if (txtCustBirth.Text.Trim() != "" && selPaperType.SelectedValue!="00")//当证件类型不为身份证时，用户出生日期从出生日期栏位截取
        //{
        //    string custBirth = DateTime.ParseExact(txtCustBirth.Text.Trim(), "yyyyMMdd", CultureInfo.CurrentCulture).ToString("yyyy-MM-dd");
        //    int birth = DateTime.Parse(custBirth).Year;
        //    if (DateTime.Now.Year - birth < 70)
        //    {
        //        context.AddMessage("提示：此用户年龄不超过70岁");
        //    }
        //}
        //else if (txtCustBirth.Text.Trim() != "" && selPaperType.SelectedValue == "00")//当证件类型为身份证时，用户出生日期从身份证中截取
        //{
        //    string custBirth = DateTime.ParseExact(txtPaperNo.Text.Trim().Substring(6,8), "yyyyMMdd", CultureInfo.CurrentCulture).ToString("yyyy-MM-dd");
        //    int birth = DateTime.Parse(custBirth).Year;
        //    if (DateTime.Now.Year - birth < 70)
        //    {
        //        context.AddMessage("提示：此用户年龄不超过70岁");
        //    }
        //}


        btnSubmit.Enabled = !context.hasError();
    }

    // 确认对话框确认处理

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")    // 是否继续
        {
            btnSubmit.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess") // 写卡成功
        {
            clearCustInfo(labMonthlyCardType, selMonthlyCardDistrict,
                txtCardNo, txtCustName, txtCustBirth, selPaperType, txtPaperNo,
                selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);
            AddMessage("D005110002: 老人卡升级高龄卡前台写卡成功，升级成功");
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("A00511C001: 老人卡升级高龄卡前台写卡失败，升级失败");
        }
        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }

        hidWarning.Value = ""; // 清除警告信息
    }

    // 提交前校验

    private void submitValidate()
    {
        // 客户信息校验
        custInfoForValidate(txtCustName, txtCustBirth,
            selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost,
            txtCustAddr, txtEmail, txtRemark);

        Validation valid = new Validation(context);
        valid.check(selMonthlyCardDistrict.SelectedValue != "", "A005090002: 行政区域必须选择", selMonthlyCardDistrict);
        valid.check(selCustSex.SelectedValue != "", "A005090003: 性别必须选择", selCustSex);
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

            if (selPaperType.SelectedValue=="00" && !Validation.isPaperNo(txtPaperNo.Text.Trim()))
             {
                 context.AddError("A094570238:身份证号码验证不通过", txtPaperNo);
             }

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

    // 老人卡到高领卡升级处理

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 校验输入
        submitValidate();
        
        if (context.hasError()) return;
        string type = labMonthlyCardType.Text;
        string appType = string.Empty;
        if(type=="学生月票卡")
        {
            appType = "01";
        }
        else if (type == "老人月票卡")
        {
            appType = "02";
        }
        else if (type == "高龄卡")
        {
            appType = "03";
        }
        else if (type == "劳模卡")
        {
            appType = "05";
        }
        else if (type == "教育卡")
        {
            appType = "06";
        }
        else if (type == "献血卡")
        {
            appType = "07";
        }

        //add by jiangbb 2012-10-17 判断页面上的证件号码、联系电话、联系地址是否修改 并取值
        string custPaperNo = CommonHelper.GetPaperNo(hidForPaperNo.Value) == txtPaperNo.Text.Trim() ? hidForPaperNo.Value : txtPaperNo.Text.Trim();
        string custPhone = CommonHelper.GetCustPhone(hidForPhone.Value) == txtCustPhone.Text.Trim() ? hidForPhone.Value : txtCustPhone.Text.Trim();
        string custAddr = CommonHelper.GetCustAddress(hidForAddr.Value) == txtCustAddr.Text.Trim() ? hidForAddr.Value : txtCustAddr.Text.Trim();

        StringBuilder strBuilder = new StringBuilder();
        // 调用“老人卡到高领卡升级”存储过程

        SP_AS_MonthlyCardUpgradePDO pdo = new SP_AS_MonthlyCardUpgradePDO();
        pdo.ID = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        pdo.cardNo = txtCardNo.Text;

        pdo.deposit = (int)(Double.Parse(hidDeposit.Value) * 100);
        pdo.cardCost = (int)(Double.Parse(hidCardPost.Value) * 100);
        pdo.otherFee = (int)(Double.Parse(hidOtherFee.Value) * 100);

        pdo.cardTradeNo = hidTradeNo.Value;
        pdo.asn = hidAsn.Value.Substring(4, 16);

        pdo.operCardNo = context.s_CardID;
        pdo.terminalNo = "112233445566";   // 目前固定写成112233445566

        //加密 ADD BY JIANGBB 2012-04-19
        pdo.custName = txtCustName.Text;
        AESHelp.AESEncrypt(pdo.custName, ref strBuilder);
        pdo.custName = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPhone, ref strBuilder);
        pdo.custPhone = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custAddr, ref strBuilder);
        pdo.custAddr = strBuilder.ToString();

        pdo.custBirth = txtCustBirth.Text;
        pdo.paperType = selPaperType.SelectedValue;

        pdo.paperNo = txtPaperNo.Text;
        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPaperNo, ref strBuilder);
        pdo.paperNo = strBuilder.ToString();

        pdo.custSex = selCustSex.SelectedValue;
        pdo.custPost = txtCustPost.Text;
        pdo.custEmail = txtEmail.Text;
        pdo.remark = txtRemark.Text;

        pdo.assignedArea = selMonthlyCardDistrict.SelectedValue;
        pdo.appType = appType;

        string ktyear = HidYearInfo.Value.Substring(2, 2);
        int temp = Convert.ToInt32(ktyear) % 2;
        if (temp == 1)
        {
            hidMonthlyYearCheck.Value = HidYearInfo.Value.Substring(0,8) + ktyear + "00C200";
        }
        else
        {
            hidMonthlyYearCheck.Value = HidYearInfo.Value.Substring(0,8) + "00" + ktyear + "00C2";
        }
        hidMonthlyFlag.Value = pdo.assignedArea + (pdo.custSex == "0" ? "C1" : "C0");
        hidMonthlyUpgrade.Value = pdo.assignedArea + "0400";//add by youyue 写入39文件内容开卡

        pdo.hidMonthlyYearCheck = hidMonthlyYearCheck.Value;
        pdo.hidMonthlyUpgrade = hidMonthlyUpgrade.Value;
        pdo.hidMonthlyFlag = hidMonthlyFlag.Value;


        // 执行存储过程
        bool ok = TMStorePModule.Excute(context, pdo);
        btnSubmit.Enabled = false;



        // 存储过程执行成功，返回成功消息

        if (ok)
        {

            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "modifyMonthlyInfo();", true);
            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardNo.Text, txtCustName.Text, "老人卡转高龄卡", "0.00"
                , hidAccRecv.Value, "", txtPaperNo.Text, "0.00", "0.00", hidAccRecv.Value, context.s_UserID,
                context.s_DepartName,
                selPaperType.SelectedValue == "" ? "" : selPaperType.SelectedItem.Text, "0.00", "0.00");
        }
    }
}
