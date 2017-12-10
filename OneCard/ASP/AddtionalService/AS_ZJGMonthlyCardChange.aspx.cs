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
using System.Collections.Generic;

// 月票卡换卡

public partial class ASP_AddtionalService_AS_ZJGMonthlyCardChange : Master.FrontMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 设置焦点以及按键事件
        txtRealRecv.Attributes["onfocus"] = "this.select();";
        txtRealRecv.Attributes["onkeyup"] = "realRecvChanging(this);";

        if (!context.s_Debugging)
        {
            txtOldCardNo.Attributes["readonly"] = "true";
            txtNewCardNo.Attributes["readonly"] = "true";
        }

        // 设置可读属性        setReadOnly(txtOldCardDeposit, txtOldStartDate, txtOldCardBalance);
        setReadOnly(txtNewcChangeType, txtNewCardDeposit, txtNewStartDate);
        setReadOnly(txtNewCardBalance, labMonthlyCardType);
        //setReadOnly(txtOldCardNo);
        txtOldCardNo.CssClass = "labeltext";

        // 初始化费用列表        initGridView("");

        // 设置损坏类型
        ASHelper.setChangeReason(selReasonType, false);

        // 初始化性别
        ASHelper.initSexList(selCustSex);

        // 行政区域
        //selMonthlyCardDistrict.Items.Add(new ListItem("---请选择---", ""));
    }


    // 初始化费用项列表
    private void initGridView(string type)
    {
        // 根据月票类型得到换卡的业务类型编码        hidTradeTypeCode.Value
            = type == "11" ? "8C" // 张家港残疾人爱心卡换卡

                : type == "12" ? "9C" // 张家港老年人免费卡换卡

                : type == "16" ? "9J" // 张家港老年人免费卡换卡

                : type == "17" ? "9O" // 9O张家港志愿卡换卡 add by youyue 20140610
            : "";

        // 自然损坏不收取费用        string reasonType = selReasonType.SelectedValue;
        string changeTradeCode = hidTradeTypeCode.Value;
        if (reasonType == "13"     // 可读自然损坏卡            || reasonType == "15") // 不可读自然损坏卡
        {
            // 不收费            changeTradeCode = "";
        }

        initFeeItem(gvResult, changeTradeCode,
            hidDeposit, hidCardPost, hidOtherFee, hidAccRecv,
            txtRealRecv, false, 0, 0);
    }

    // 检查月票卡信息
    private void CheckMonthlyCard()
    {
        // 查询月票卡应用类型，区域名称，区域代码        DataTable data = ASHelper.callQuery(context, "CardAppInfo", txtOldCardNo.Text);
        if (data.Rows.Count != 1)
        {
            labMonthlyCardType.Text = "非月票卡";
            context.AddError("A005110001: 当前卡片不是月票卡");
            return;
        }
        string type = (string)(data.Rows[0].ItemArray[0]);
        hidMonthlyType.Value = type;
        labMonthlyCardType.Text
            = type == "11" ? "残疾人爱心卡"
            : type == "12" ? "老年人免费卡"
            : type == "16" ? "公交公司员工卡"
            : type == "17" ? "志愿者卡"  //add by youyue 增加'17:志愿者卡'优惠票种
            : "未知月票卡";

        // 初始化费用项列表
        initGridView(type);

        // 查询押金，服务开始日期，服务费以及服务费收取标志
        data = ASHelper.callQuery(context, "CardServInfo", txtOldCardNo.Text);
        if (data.Rows.Count > 0)
        {
            txtOldCardDeposit.Text = ((decimal)data.Rows[0].ItemArray[0]).ToString("n");
            hidStartTime.Value = ((DateTime)data.Rows[0].ItemArray[1]).ToString();
            hidServiceMoney.Value = ((decimal)data.Rows[0].ItemArray[2]).ToString();
            hidSERSTAKETAG.Value = (string)data.Rows[0].ItemArray[3];
        }
        else
        {
            txtOldCardDeposit.Text = "0";
        }
    }

    // 读取客户信息
    private void readCustInfo()
    {
        DataTable data = ASHelper.callQuery(context, "QueryCustInfo", txtOldCardNo.Text);
        if (data.Rows.Count == 0)
        {
            context.AddError("A00501A002: 无法读取卡片客户资料");
            return;
        }

        //add by jiangbb 解密
        CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" }));

        Object[] row = data.Rows[0].ItemArray;

        // labCustSex.Text = ((string)row[4]).Trim() == "0" ? "男" : "女";
        try
        {
            selCustSex.SelectedValue = ((string)row[4]).Trim();
        }
        catch (Exception)
        {
            selCustSex.SelectedValue = "";
        }

        txtCustName.Text = ASHelper.getCellValue(row[0]);
        string paperType = (ASHelper.getCellValue(row[2])).Trim();
        selPaperType.Text = "";
        txtPaperNo.Text = ASHelper.getCellValue(row[3]);

        data = ASHelper.callQuery(context, "ReadPaperName", paperType);
        if (data.Rows.Count > 0)
        {
            selPaperType.Text = (string)data.Rows[0].ItemArray[0];
        }
    }

    // 根据卡片类型编码读取卡片类型名称
    private void readCardType()
    {
        DataTable data = ASHelper.callQuery(context, "ReadCardType", hidNewCardType.Value);
        if (data.Rows.Count == 0)
        {
            context.AddError("S00512A001: 无法根据卡片类型编码读取卡片类型名称");
            return;
        }

        txtNewcChangeType.Text = (string)data.Rows[0].ItemArray[1];
    }

    // 读新卡    protected void btnReadNewCard_Click(object sender, EventArgs e)
    {
        btnPrintPZ.Enabled = false;
        btnPrintSJ.Enabled = false;

        #region add by shil 20130909,如果是旅游年卡，则不允许在该页面办理业务
        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面办理业务

        bool cardTypeOk = CommonHelper.allowCardtype(context, txtNewCardNo.Text, "5101", "5103");
        if (cardTypeOk == false)
        {
            return;
        }
      
        #endregion

        txtNewStartDate.Text = txtStartDate.Value;
        txtNewCardBalance.Text = txtCardBalance.Value;

        // 读取卡片状态

        ASHelper.readCardState(context, txtNewCardNo.Text, txtNewCardState);

        // 检查新卡状态        checkCardState(txtNewCardNo.Text);

        // 读取新卡类型名称
        readCardType();

        // 新卡押金取从费用项中得到的押金值        txtNewCardDeposit.Text = hidDeposit.Value;

        // 检查新卡卡内余额        //if (txtNewCardBalance.Text != "0.00")
        //{
        //    context.AddError("A001001144");
        //}

        btnSubmit.Enabled = !context.hasError();
    }

    // 输入校验
    private void QueryValidate()
    {
        Validation valid = new Validation(context);

        // 对卡号进行非空、长度、数字检验        bool b = valid.notEmpty(txtOldCardNo, "A004P09001");
        if (b) b = valid.fixedLength(txtOldCardNo, 16, "A004P09002");
        if (b) valid.beNumber(txtOldCardNo, "A004P09003");
    }

    // 读库
    protected void btnReadDb_Click(object sender, EventArgs e)
    {
        // 校验卡号输入
        QueryValidate();

        if (context.hasError()) return;

        #region add by shil 20130909,如果是旅游年卡，则不允许在该页面办理业务
        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面办理业务

        bool cardTypeOk = CommonHelper.allowCardtype(context, txtOldCardNo.Text, "5101", "5103");
        if (cardTypeOk == false)
        {
            return;
        }
   
        #endregion

        // 读取卡片状态
        ASHelper.readCardState(context, txtOldCardNo.Text, txtOldCardState);

        // 检查旧卡帐户信息        checkAccountInfo(txtOldCardNo.Text);

        // 查询卡片是否是月票卡
        CheckMonthlyCard();

        // 读取旧卡客户信息
        readCustInfo();

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtPaperNo.Text = CommonHelper.GetPaperNo(txtPaperNo.Text);
        }

        btnReadNewCard.Enabled = true;

        // 从库中读取 折旧开始和旧卡余额以及押金
        DataTable data = ASHelper.callQuery(context, "ReadCardAcc", txtOldCardNo.Text);

        if (data.Rows.Count != 1)
        {
            return;
        }
        Object[] row = data.Rows[0].ItemArray;

        txtOldStartDate.Text = ((DateTime)row[2]).ToString("yyyy-MM-dd");
        txtOldCardBalance.Text = ((decimal)row[0]).ToString("n");
        txtOldCardDeposit.Text = ((decimal)row[1]).ToString("n");

        // 检查审核员工卡有效性        data = ASHelper.callQuery(context, "QueryCheckStaff", hiddenCheck.Value);
        if (data == null || data.Rows.Count == 0)
        {
            context.AddError("A001010108");
        }
        else
        {
            hiddenCheckStff.Value = "" + data.Rows[0].ItemArray[0];
            hiddenCheckDept.Value = "" + data.Rows[0].ItemArray[1];
        }

        if (context.hasError()) return;


    }

    // 读旧卡    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        #region add by shil 20130909,如果是旅游年卡，则不允许在该页面办理业务
        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面办理业务

        bool cardTypeOk = CommonHelper.allowCardtype(context, txtOldCardNo.Text, "5101", "5103");
        if (cardTypeOk == false)
        {
            return;
        }
     
        #endregion

        txtOldStartDate.Text = txtStartDate.Value;
        txtOldCardBalance.Text = txtCardBalance.Value;

        // 读取卡片状态

        ASHelper.readCardState(context, txtOldCardNo.Text, txtOldCardState);

        // 检查旧卡帐户信息        checkAccountInfo(txtOldCardNo.Text);

        // 查询卡片是否是月票卡
        CheckMonthlyCard();

        // 读取旧卡客户信息
        readCustInfo();

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtPaperNo.Text = CommonHelper.GetPaperNo(txtPaperNo.Text);
        }

        if (context.hasError()) return;

        ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
            "lockCard();", true);

        hidLockFlag.Value = "true";

        hiddenCheckStff.Value = "";
        hiddenCheckDept.Value = "";
    }

    // 确认对话框确认处理    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")    // 是否继续
        {
            btnSubmit.Enabled = true;
        }
        else if (hidWarning.Value == "submit") // 读数据库
        {
            btnReadDb_Click(sender, e);
        }
        else if (hidWarning.Value == "writeSuccess") // 写卡成功
        {
            if (hidLockFlag.Value == "true")
            {
                AddMessage("D005120003: 旧卡已经锁定");
                btnReadNewCard.Enabled = true;
            }
            else
            {
                clearCustInfo(selCustSex);
                AddMessage("D005120002: 月票卡前台写卡成功，月票卡换卡成功");
            }
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            if (hidLockFlag.Value != "true")
            {
                context.AddError("A00512C001: 月票卡前台写卡失败，月票卡换卡失败");
            }
        }
        if (chkPingzheng.Checked && btnPrintPZ.Enabled && chkShouju.Checked && btnPrintSJ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printAll();", true);
        }
        else if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }
        else if (chkShouju.Checked && btnPrintSJ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printShouJu();", true);
        }
        hidLockFlag.Value = "";
        hidWarning.Value = ""; // 清除警告信息
    }

    // 填充pdo信息
    private void fillinPdo(SP_AS_ZJGMonthlyCardChangePDO pdo)
    {
        if (selReasonType.SelectedValue == "13") // 可读自然损坏卡        {
            pdo.deposit = (int)(Double.Parse(txtOldCardDeposit.Text) * 100);
            pdo.serStartTime = Convert.ToDateTime(hidStartTime.Value);
            pdo.serviceMoney = Convert.ToInt32(hidServiceMoney.Value);
            pdo.cardAccMoney = (int)(Double.Parse(txtOldCardBalance.Text) * 100);
            pdo.newSersTakeTag = hidSERSTAKETAG.Value;
            pdo.supplyRealMoney = pdo.cardAccMoney;
            pdo.totalSupplyMoney = pdo.cardAccMoney;
            pdo.oldDeposit = (int)(Double.Parse(txtOldCardDeposit.Text) * 100) - pdo.serviceMoney;
            pdo.sersTakeTag = "3";
            pdo.preMoney = 0;
            pdo.nextMoney = pdo.cardAccMoney;
            pdo.currentMoney = pdo.nextMoney;

        }
        else if (selReasonType.SelectedValue == "12") // 可读人为损坏卡        {
            pdo.deposit = (int)(Double.Parse(txtNewCardDeposit.Text) * 100);
            pdo.serStartTime = DateTime.Now;
            pdo.serviceMoney = 0;
            pdo.cardAccMoney = (int)(Double.Parse(txtOldCardBalance.Text) * 100);
            pdo.newSersTakeTag = hidSERSTAKETAG.Value;
            pdo.supplyRealMoney = pdo.cardAccMoney;
            pdo.totalSupplyMoney = pdo.cardAccMoney;
            pdo.oldDeposit = 0;
            pdo.sersTakeTag = "2";
            pdo.preMoney = 0;
            pdo.nextMoney = pdo.cardAccMoney;
            pdo.currentMoney = pdo.nextMoney;
        }
        else if (selReasonType.SelectedValue == "14") // 不可读人为损坏卡
        {
            pdo.deposit = (int)(Double.Parse(txtNewCardDeposit.Text) * 100);
            pdo.serStartTime = DateTime.Now;
            pdo.serviceMoney = 0;
            pdo.cardAccMoney = 0;
            pdo.newSersTakeTag = hidSERSTAKETAG.Value;
            pdo.supplyRealMoney = 0;
            pdo.totalSupplyMoney = 0;
            pdo.oldDeposit = 0;
            pdo.sersTakeTag = "2";
            pdo.preMoney = 0;
            pdo.nextMoney = 0;
            pdo.currentMoney = 0;
        }
        else if (selReasonType.SelectedValue == "15") // 不可读自然损坏卡
        {
            pdo.deposit = (int)(Double.Parse(txtOldCardDeposit.Text) * 100);
            pdo.serStartTime = Convert.ToDateTime(hidStartTime.Value);
            pdo.serviceMoney = Convert.ToInt32(hidServiceMoney.Value);
            pdo.cardAccMoney = 0;
            pdo.newSersTakeTag = hidSERSTAKETAG.Value;
            pdo.supplyRealMoney = 0;
            pdo.totalSupplyMoney = 0;
            pdo.oldDeposit = (int)(Double.Parse(txtOldCardDeposit.Text) * 100) - pdo.serviceMoney;
            pdo.sersTakeTag = "3";
            pdo.preMoney = 0;
            pdo.nextMoney = 0;
            pdo.currentMoney = 0;
        }
    }

    // 提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        Validation valid = new Validation(context);
        //valid.check(selMonthlyCardDistrict.SelectedValue != "", "A005090002, 行政区域必须选择", selMonthlyCardDistrict);
        valid.check(selCustSex.SelectedValue != "", "A005090003, 性别必须选择", selCustSex);
        if (context.hasError()) return;


        // 调用月票卡换卡存储过程

        SP_AS_ZJGMonthlyCardChangePDO pdo = new SP_AS_ZJGMonthlyCardChangePDO();
        pdo.ID = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        pdo.custRecTypeCode = "0";
        pdo.cardCost = Convert.ToInt32(Convert.ToDecimal(hidCardPost.Value) * 100);
        pdo.newCardNo = txtNewCardNo.Text;
        pdo.oldCardNo = txtOldCardNo.Text;
        pdo.cardTradeNo = hidTradeNo.Value;
        pdo.checkStaffNo = hiddenCheckStff.Value;
        pdo.checkDeptNo = hiddenCheckDept.Value;
        pdo.changeCode = selReasonType.SelectedValue;
        pdo.asn = hidAsn.Value.Substring(4, 16);

        fillinPdo(pdo);

        pdo.sellChannelCode = "01";
        pdo.tradeTypeCode = hidTradeTypeCode.Value;

        pdo.appType = hidMonthlyType.Value;
        //pdo.assignedArea = selMonthlyCardDistrict.Text;
        pdo.custSex = selCustSex.Text;
        pdo.terminalNo = "112233445566";   // 目前固定写成112233445566
        pdo.operateCard = context.s_CardID;

        //hidZJGMonthlyFlag.Value = selMonthlyCardType.SelectedValue + pdo.ENDDATE;
        hidSupplyMoney.Value = "" + pdo.currentMoney;

        // 执行存储过程
        bool ok = TMStorePModule.Excute(context, pdo);
        txtNewCardNo.Text = "";
        txtOldCardNo.Text = "";
        btnSubmit.Enabled = false;

        // 执行成功，返回成功消息        if (ok)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "changeZJGMonthlyCard();", true);

            btnPrintPZ.Enabled = true;
            ASHelper.preparePingZheng(ptnPingZheng, txtOldCardNo.Text, txtCustName.Text, "月票卡换卡", "0.00"
                , hidAccRecv.Value, txtNewCardNo.Text, txtPaperNo.Text,
                    ((decimal)(pdo.nextMoney / 100.0)).ToString("n"), "0.00", hidAccRecv.Value, context.s_UserID,
                context.s_DepartName,
                selPaperType.Text, "0.00", "0.00");

            // 准备收据打印数据
            ASHelper.prepareShouJu(ptnShouJu, txtNewCardNo.Text, context.s_UserName, hidAccRecv.Value);
            btnPrintSJ.Enabled = true;
        }
    }

    // 更改损坏类型，为可读卡时，激活“读旧卡”按钮，否则激活“读数据库”按钮    // 可读卡时，不允许卡号输入，否则允许卡号输入    protected void selReasonType_SelectedIndexChanged(object sender, EventArgs e)
    {
        initGridView(hidMonthlyType.Value);
        btnReadDb.Enabled = selReasonType.SelectedValue == "14" || selReasonType.SelectedValue == "15";
        btnReadCard.Enabled = !btnReadDb.Enabled;

        if (btnReadDb.Enabled)
        {
            txtOldCardNo.Attributes.Remove("readonly");
        }
        else
        {
            txtOldCardNo.Attributes["readonly"] = "true";
        }
        txtOldCardNo.CssClass = btnReadDb.Enabled ? "input" : "labeltext";

    }
}
