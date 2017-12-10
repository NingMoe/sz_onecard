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

// 月票卡售卡
public partial class ASP_AddtionalService_AS_MonthlyCardNew : Master.FrontMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        hidReissue.Value = Request.Params["Reissue"];
        labTitle.Text = hidReissue.Value != "true" ? "月售" : "月补";
        labSubTitle.Text = hidReissue.Value != "true" ? "月票卡售卡" : "月票卡补卡";

        if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

        // 设置可读属性

        setReadOnly(txtCardBalance, txtStartDate, txtEndDate);

        // 设置焦点以及按键事件
        txtRealRecv.Attributes["onfocus"] = "this.select();";
        txtRealRecv.Attributes["onkeyup"] = "realRecvChanging(this);";
        
        // 初始化月票类型
        ASHelper.initMonthlyCardTypeList(selMonthlyCardType);

        // 行政区域
        selMonthlyCardDistrict.Items.Add(new ListItem("---请选择---", ""));

        // 初始化证件类型
        ASHelper.initPaperTypeList(context, selPaperType);
        
        // 初始化性别
        ASHelper.initSexList(selCustSex);
        
        // 初始化费用列表
        initGridView();
    }

    // 初始化费用项gridview
    private void initGridView()
    {
        // 业务类型编码表：31学生月票开卡，32老人月票开卡 23高龄开卡 7A残疾人月票开卡
        string type = selMonthlyCardType.SelectedValue;

        // 根据月票类型得到换卡的业务类型编码
        if (hidReissue.Value != "true")
        {
            hidTradeTypeCode.Value
                = type == "01" ? "31" // 学生月票售卡
                : type == "02" ? "32" // 老人月票售卡
                : type == "03" ? "23" // 高龄卡售卡
                : type == "04" ? "7A" // 残疾人月票售卡
                : "";
        }
        else
        {
            hidTradeTypeCode.Value
                = type == "01" ? "70" // 学生月票补卡
                : type == "02" ? "71" // 老人月票补卡
                : type == "03" ? "72" // 高龄卡补卡
                : type == "04" ? "7B" // 残疾人月票补卡
                : "";
        }

        initFeeItem(gvResult, hidTradeTypeCode.Value, hidDeposit, 
            hidCardPost, hidOtherFee, hidAccRecv,
            txtRealRecv, false, 0, 0);
    }

    // 读卡处理
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
        checkCardState(txtCardNo.Text);

        // 检查新卡卡内余额
        if (txtCardBalance.Text != "0.00")
        {
            context.AddError("A001001144");
        }
        
        btnPrintSJ.Enabled = false;

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
            clearCustInfo(selMonthlyCardType, selMonthlyCardDistrict,
               txtCardNo, txtCustName, txtCustBirth, selPaperType, txtPaperNo,
               selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);

            AddMessage(hidReissue.Value != "true" 
                ? "D005090002: 月票卡前台写卡成功，月票卡售卡成功"
                : "D005100002: 月票卡前台写卡成功，月票卡补卡成功");

            #region add by liuhe  20120104 添加对代理营业厅预付款的验证,扣费后如果超过预警额度则提示
            int opMoney = Convert.ToInt32(Double.Parse(hidAccRecv.Value) * 100);
            DeptBalunitHelper.ValdatePrepay(context, opMoney, "1");
            #endregion 
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {           
            context.AddError(hidReissue.Value != "true"  
                ?"A00509C001: 月票卡前台写卡失败，月票卡售卡失败"
                : "A00510C001: 月票卡前台写卡失败，月票卡补卡失败");
        }

        if (chkShouju.Checked && btnPrintSJ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printShouJu();", true);
        }

        hidWarning.Value = ""; // 清除警告信息
    }

    // 提交判断
    private void submitValidate()
    {
        // 校验客户信息
        custInfoValidate(txtCustName, txtCustBirth,
            selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost,
            txtCustAddr, txtEmail, txtRemark);

        Validation valid = new Validation(context);
        valid.check(selMonthlyCardType.SelectedValue != "", "A005090001: 月票类型必须选择", selMonthlyCardType);
        valid.check(selMonthlyCardDistrict.SelectedValue != "", "A005090002: 行政区域必须选择", selMonthlyCardDistrict);
        valid.check(selCustSex.SelectedValue != "", "A005090003: 性别必须选择", selCustSex);
    }

    // 月票卡售卡提交
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        #region add by liuhe 20120104 添加对代理营业厅预付款的验证,提交前如果扣费后不足最低额度则返回
        int opMoney = Convert.ToInt32(Double.Parse(hidAccRecv.Value) * 100);
        if (DeptBalunitHelper.ValdatePrepay(context, opMoney, "2") == false)
        {
            return;
        }
        #endregion 


        submitValidate();
        checkCardState(txtCardNo.Text);

        if (context.hasError()) return;


        // 调用月票卡售卡存储过程
        SP_AS_MonthlyCardNewPDO pdo = new SP_AS_MonthlyCardNewPDO();
        pdo.ID = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        pdo.cardNo = txtCardNo.Text;

        pdo.deposit = (int)(Double.Parse(hidDeposit.Value) * 100);
        pdo.cardCost = (int)(Double.Parse(hidCardPost.Value) * 100);
        pdo.otherFee = (int)(Double.Parse(hidOtherFee.Value) * 100); 

        pdo.cardTradeNo = hidTradeNo.Value;
        pdo.asn = hidAsn.Value.Substring(4, 16);
        pdo.cardMoney = (int)(Double.Parse(txtCardBalance.Text) * 100);
        pdo.sellChannelCode = "01";
        pdo.serTakeTag = "3";
        pdo.tradeTypeCode = hidTradeTypeCode.Value;
        pdo.terminalNo = "112233445566";   // 目前固定写成112233445566

        //加密 ADD BY JIANGBB 2012-04-19
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustName.Text, ref strBuilder);
        pdo.custName = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustPhone.Text, ref strBuilder);
        pdo.custPhone = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustAddr.Text, ref strBuilder);
        pdo.custAddr = strBuilder.ToString();

        pdo.custBirth = txtCustBirth.Text;
        pdo.paperType = selPaperType.SelectedValue;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtPaperNo.Text,ref strBuilder);
        pdo.paperNo = strBuilder.ToString();
        pdo.custSex = selCustSex.SelectedValue;
        pdo.custPost = txtCustPost.Text;
        pdo.custEmail = txtEmail.Text;
        pdo.remark = txtRemark.Text;

        pdo.custRecTypeCode = "0";
        pdo.appType = selMonthlyCardType.SelectedValue;
        pdo.assignedArea = selMonthlyCardDistrict.SelectedValue;

        pdo.currCardNo = context.s_CardID;

        hidMonthlyFlag.Value = pdo.assignedArea + (pdo.custSex == "0" ? "C1" : "C0");

        // 执行存储过程
        bool ok = TMStorePModule.Excute(context, pdo);
        btnSubmit.Enabled = false;

        // 存储过程执行成功，显示成功消息
        if (ok)
        {            
            // 准备收据打印数据
            ASHelper.prepareShouJu(ptnShouJu, txtCardNo.Text, context.s_UserName, hidAccRecv.Value);
            btnPrintSJ.Enabled = true;

            // AddMessage("D005090001: 月票卡后台开卡成功，等待写卡操作");
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "startMonthlyInfo();", true);
        }
    }

    // 刷新行政区域选择
    protected void selMonthlyCardType_SelectedIndexChanged(object sender, EventArgs e)
    {
        // 初始化行政区域
        ASHelper.SelectDistricts(context,
            selMonthlyCardDistrict, selMonthlyCardType.SelectedValue);

        initGridView();
    }
}
