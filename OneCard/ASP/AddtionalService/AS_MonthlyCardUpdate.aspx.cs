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
using Common;
using TM;
using System.Text;
using PDO.AdditionalService;
using PDO.PersonalBusiness;
using TDO.ResourceManager;
using TDO.UserManager;

// 月票卡资料更新

public partial class ASP_AddtionalService_AS_MonthlyCardUpdate : Master.FrontMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

        // 设置可读属性

        setReadOnly(txtCardBalance, txtStartDate, txtEndDate);

        // 初始化证件类型

        ASHelper.initPaperTypeList(context, selPaperType);

        // 初始化性别
        ASHelper.initSexList(selCustSex);

        // 初始化行政区域

        selMonthlyCardDistrict.Items.Add(new ListItem("---请选择---", ""));
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

        hidSrcSex.Value = selCustSex.SelectedValue;

        if (context.hasError()) return;

        // 读取卡片押金
        decimal cardDeposit = 0;

        DataTable data = ASHelper.callQuery(context, "CardDeposit", txtCardNo.Text);
        if (data.Rows.Count > 0)
        {
            cardDeposit = (decimal)data.Rows[0].ItemArray[0];
        }
    }

    protected void initMonthlyCardTypeList1(DropDownList lst)
    {
        lst.Items.Clear();
        lst.Items.Add(new ListItem("01:学生月票", "01"));
        lst.Items.Add(new ListItem("02:老人月票", "02"));
        lst.Enabled = true;
    }
    protected void initMonthlyCardTypeList2(DropDownList lst)
    {
        lst.Items.Clear();
        lst.Items.Add(new ListItem("03:高龄卡", "03"));
        lst.Items.Add(new ListItem("04:残疾人爱心卡", "04"));
        lst.Items.Add(new ListItem("05:劳模卡", "05"));
        lst.Items.Add(new ListItem("06:教育卡", "06"));//add by youyue 20140611新增教育卡
        lst.Items.Add(new ListItem("07:献血卡", "07"));
        lst.Enabled = false;
    }

    // 校验月票卡资料

    private void CheckMonthlyCard()
    {
        // 查询月票卡应用类型，区域名称，区域代码

        DataTable data = ASHelper.callQuery(context, "CardAppInfo", txtCardNo.Text);
        if (data.Rows.Count != 1)
        {
            // labMonthlyCardType.Text = "非月票卡";
            context.AddError("A005110001: 当前卡片不是月票卡");
            return;
        }
        string type = (string)(data.Rows[0].ItemArray[0]);
        if (type != "01" && type != "02" && type != "03" && type != "04" && type != "05" && type != "06" && type != "07")//add by youyue 20140611新增教育卡06
        {
            context.AddError("A005110001: 当前卡片不是月票卡");
            return;
        }

        if (type == "01" || type == "02") // 学生月票与老人月票可以自由转换
        {
            initMonthlyCardTypeList1(selMonthlyCardType);
        }
        else // 高龄卡不能自由转换
        {
            initMonthlyCardTypeList2(selMonthlyCardType);
        }

        selMonthlyCardType.SelectedValue = type;

        ASHelper.SelectDistricts(context, selMonthlyCardDistrict, type);

        try
        {
            selMonthlyCardDistrict.SelectedValue = (string)(data.Rows[0].ItemArray[2]);
        }
        catch (Exception)
        {
            selMonthlyCardDistrict.SelectedValue = "";
        }

        hidSrcDistrict.Value = selMonthlyCardDistrict.SelectedValue;

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
            context.AddMessage("提示：卡号为市民卡，不可修改客户资料");
        }

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
            clearCustInfo(selMonthlyCardDistrict,
                txtCardNo, txtCustName, txtCustBirth, selPaperType, txtPaperNo,
                selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);

            AddMessage("D005130002: 月票卡资料更新成功");
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("A00513C001: 写卡失败");
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

        //add by jiangbb 2012-10-17 判断页面上的证件号码、联系电话、联系地址是否修改 并取值
        string custPaperNo = CommonHelper.GetPaperNo(hidForPaperNo.Value) == txtPaperNo.Text.Trim() ? hidForPaperNo.Value : txtPaperNo.Text.Trim();
        string custPhone = CommonHelper.GetCustPhone(hidForPhone.Value) == txtCustPhone.Text.Trim() ? hidForPhone.Value : txtCustPhone.Text.Trim();
        string custAddr = CommonHelper.GetCustAddress(hidForAddr.Value) == txtCustAddr.Text.Trim() ? hidForAddr.Value : txtCustAddr.Text.Trim();

        StringBuilder strBuilder = new StringBuilder();
        // 调用“老人卡到高领卡升级”存储过程

        SP_AS_MonthlyCardUpdatePDO pdo = new SP_AS_MonthlyCardUpdatePDO();
        pdo.ID = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        pdo.cardNo = txtCardNo.Text;
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

        pdo.appType = selMonthlyCardType.SelectedValue;
        pdo.assignedArea = selMonthlyCardDistrict.SelectedValue;
        bool needWriteCard = (pdo.assignedArea != hidSrcDistrict.Value
            || pdo.custSex != hidSrcSex.Value);
        pdo.needWriteCard = needWriteCard ? "y" : "n";

        hidMonthlyFlag.Value = pdo.assignedArea + (pdo.custSex == "0" ? "C1" : "C0");

        // 执行存储过程
        bool ok = TMStorePModule.Excute(context, pdo);
        btnSubmit.Enabled = false;

        // 存储过程执行成功，返回成功消息

        if (ok)
        {
            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardNo.Text, txtCustName.Text, "月票卡更新", "0.00"
                , "0.00", "", txtPaperNo.Text, "0.00", "0.00", "0.00", context.s_UserID,
                context.s_DepartName,
                selPaperType.SelectedValue == "" ? "" : selPaperType.SelectedItem.Text, "0.00", "0.00");

            // AddMessage("D005110001: 老人卡升级高龄卡后台操作成功，等待写卡操作");
            //if (needWriteCard)
            //{
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "modifyMonthlyInfo();", true);
            //}
            //else
            //{
            //    AddMessage("D005130002: 月票卡资料更新成功");
            //    if (chkPingzheng.Checked && btnPrintPZ.Enabled)
            //    {
            //        ScriptManager.RegisterStartupScript(
            //            this, this.GetType(), "writeCardScript",
            //            "printInvoice();", true);
            //    }
            //}

        }
    }

    // 刷新行政区域选择
    protected void selMonthlyCardType_SelectedIndexChanged(object sender, EventArgs e)
    {
        // 初始化行政区域

        ASHelper.SelectDistricts(context,
            selMonthlyCardDistrict, selMonthlyCardType.SelectedValue);

    }
}
