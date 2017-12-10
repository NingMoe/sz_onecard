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
using TM;
using TDO.BusinessCode;
using PDO.AdditionalService;
using Master;
using PDO.PersonalBusiness;
using System.Collections.Generic;
using System.Text;

public partial class ASP_AddtionalService_AS_WJLYCardChange : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 设置可读属性

        if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

        setReadOnly(txtCardBalance, txtStartDate);

        // 初始化证件类型
        ASHelper.initPaperTypeList(context, selPaperType);

        // 初始化性别
        ASHelper.initSexList(selCustSex);

        // 初始化费用列表
        decimal total = initFeeList(gvResult, "6B");
        hidAccRecv.Value = total.ToString("n");

        // 初始化旧卡信息查询结果gridview
        UserCardHelper.resetData(gvOldCardInfo, null);
    }

    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        btnPrintPZ.Enabled = false;

        #region add by shil 20130909,如果是旅游年卡，则不允许在该页面办理业务
        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面办理业务

        bool cardTypeOk = CommonHelper.allowCardtype(context, txtCardNo.Text, "5101", "5103");
        if (cardTypeOk == false)
        {
            return;
        }
       
        #endregion

        // 检查帐户信息
        checkAccountInfo(txtCardNo.Text);

        // 检查吴江旅游年卡特征值
        checkGardenFeature();

        // 读取卡片类型
        readCardType(txtCardNo.Text, labCardType);

        //add by jiangbb 2012-10-09  加入判断 旧卡或新卡为市民卡不会修改客户资料 
        if (!context.hasError() && txtCardNo.Text.Substring(4, 2).ToString() == "18")
        {
            context.AddMessage("提示：新卡卡号为市民卡，客户资料不会被修改");
        }

        hidReadCardOK.Value = !context.hasError() && txtCardNo.Text.Length > 0 ? "ok" : "fail";

        btnSubmit.Enabled = hidReadCardOK.Value == "ok"
            && gvOldCardInfo.SelectedIndex >= 0;

    }

    // 对话框确认处理

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "writeSuccess")  // 写卡成功
        {
            clearCustInfo(txtCardNo, txtCustName, txtCustBirth, selPaperType, txtPaperNo,
                selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);
            AddMessage("A094570070: 吴江旅游年卡前台写卡成功，补换卡成功");
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("A094570071: 吴江旅游年卡前台写卡失败，补换卡失败");
        }

        hidWarning.Value = "";       // 清除警告信息

        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        // 输入项判断处理（证件号码、旧卡号码、客户姓名、电话）

        if (!queryValidation()) return;

        // 从吴江旅游年卡账户表中查询
        string strValue = txtCondition.Text;
        if (selQueryType.SelectedValue == "02" || selQueryType.SelectedValue == "03" || selQueryType.SelectedValue == "04")   //证件号码
        {
            StringBuilder strBuilder = new StringBuilder();
            AESHelp.AESEncrypt(strValue, ref strBuilder);
            strValue = strBuilder.ToString();
        }
        DataTable data = ASHelper.callQuery(context, "QueryOldWJTourCards", selQueryType.SelectedValue,
            strValue);


        if (data == null || data.Rows.Count == 0)
        {
            UserCardHelper.resetData(gvOldCardInfo, data);
            AddMessage("N005030001: 查询结果为空");
        }
        else
        {

            //add by jiangbb 解密 2012-06-08
            CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" }));

            UserCardHelper.resetData(gvOldCardInfo, data);

            gvOldCardInfo.SelectedIndex = 0;
            gvOldCardInfo_SelectedIndexChanged(sender, e);
        }
    }

    protected Boolean queryValidation()
    {
        if (txtCondition.Text.Trim() != "")
        {
            if (selQueryType.SelectedValue.Equals("01")) //校验卡号
            {
                if (Validation.strLen(txtCondition.Text.Trim()) != 16)
                    context.AddError("A094570053：卡号必须为16位", txtCondition);
                else if (!Validation.isNum(txtCondition.Text.Trim()))
                    context.AddError("A094570054：卡号必须为数字", txtCondition);
            }
            if (selQueryType.SelectedValue.Equals("02")) //校验证件
            {

                if (!Validation.isCharNum(txtCondition.Text.Trim()))
                    context.AddError("A094570055：证件号码必须为英数", txtCondition);
                else if (Validation.strLen(txtCondition.Text.Trim()) > 20)
                    context.AddError("A094570056：证件号码长度不能超过20位", txtCondition);
            }
            if (selQueryType.SelectedValue.Equals("03")) //校验姓名
            {
                if (Validation.strLen(txtCondition.Text.Trim()) > 25)
                    context.AddError("A094570057:姓名长度不能超过25位", txtCondition);
            }
            if (selQueryType.SelectedValue.Equals("04")) //校验电话
            {
                if (Validation.strLen(txtCondition.Text.Trim()) > 40)
                    context.AddError("A094570058：电话号码长度不能超过40位", txtCondition);
            }
        }
        return !(context.hasError());
    }

    // 检查吴江旅游年卡特征值

    void checkGardenFeature()
    {
        // 从吴江旅游年卡资料表中检查USETAG值

        DataTable data = ASHelper.callQuery(context, "WJTourCardUseTag", txtCardNo.Text);
        if (data.Rows.Count > 0)
        {
            context.AddError("A094570050: 当前卡已经是吴江旅游年卡");
        }
    }

    // 旧卡信息查询结果gridview行创建事件

    protected void gvOldCardInfo_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvOldCardInfo','Select$" + e.Row.RowIndex + "')");
        }
    }

    //没有客户信息查看权则证件号码加*显示
    protected void gvOldCardInfo_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (!CommonHelper.HasOperPower(context))
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Cells[5].Text = CommonHelper.GetPaperNo(e.Row.Cells[5].Text);
            }
        }
    }

    // 旧卡信息查询结果行选择事件
    public void gvOldCardInfo_SelectedIndexChanged(object sender, EventArgs e)
    {
        // 得到选择行

        GridViewRow selectRow = gvOldCardInfo.SelectedRow;

        // 根据选择行卡号读取用户信息

        readCustInfo(selectRow.Cells[0].Text, txtCustName, txtCustBirth,
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

        hidEndDate.Value = selectRow.Cells[1].Text;
        hidUsabelTimes.Value = selectRow.Cells[3].Text;

        if (!context.hasError() && gvOldCardInfo.SelectedRow.Cells[0].Text.Substring(4, 2).ToString() == "18")
        {
            context.AddMessage("提示：旧卡卡号为市民卡，客户资料不会被修改");
        }

        btnSubmit.Enabled = !context.hasError() && hidReadCardOK.Value == "ok";
    }

    // 提交前输入项校验
    private void submitValidate()
    {
        // 用户信息校验
        custInfoParkValidate(txtCustName, txtCustBirth,
            selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost,
            txtCustAddr, txtEmail, txtRemark);
    }


    //客户信息校验
    protected void custInfoParkValidate(TextBox txtCustName, TextBox txtCustBirth,
           DropDownList selPaperType, TextBox txtPaperNo,
           DropDownList selCustSex, TextBox txtCustPhone,
           TextBox txtCustPost, TextBox txtCustAddr, TextBox txtCustEmail, TextBox txtRemark)
    {
        Validation valid = new Validation(context);
        txtCustName.Text = txtCustName.Text.Trim();
        valid.check(Validation.strLen(txtCustName.Text) <= 50, "A005010001, 客户姓名长度不能超过50", txtCustName);
        valid.check(!Validation.isEmpty(txtCustName), "客户姓名不能为空", txtCustName);

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
        if (selPaperType.SelectedValue == "")
        {
            context.AddError("证件类型不能为空", selPaperType);
        }
        b = Validation.isEmpty(txtPaperNo);
        valid.check(!b, "证件号码不能为空", txtPaperNo);
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

    // 吴江旅游年卡补换卡提交处理

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 提交前输入校验

        submitValidate();
        if (context.hasError()) return;

        //add by jiangbb 2012-10-17 判断页面上的证件号码、联系电话、联系地址是否修改 并取值
        string custPaperNo = CommonHelper.GetPaperNo(hidForPaperNo.Value) == txtPaperNo.Text.Trim() ? hidForPaperNo.Value : txtPaperNo.Text.Trim();
        string custPhone = CommonHelper.GetCustPhone(hidForPhone.Value) == txtCustPhone.Text.Trim() ? hidForPhone.Value : txtCustPhone.Text.Trim();
        string custAddr = CommonHelper.GetCustAddress(hidForAddr.Value) == txtCustAddr.Text.Trim() ? hidForAddr.Value : txtCustAddr.Text.Trim();

        // 调用吴江旅游年卡补换卡存储过程

        SP_AS_WJTourCardChangePDO pdo = new SP_AS_WJTourCardChangePDO();
        pdo.ID = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        pdo.oldCardNo = gvOldCardInfo.SelectedRow.Cells[0].Text;
        pdo.newCardNo = txtCardNo.Text;
        pdo.asn = hidAsn.Value.Substring(4, 16);
        pdo.operCardNo = context.s_CardID; // 操作员卡
        pdo.terminalNo = "112233445566";   // 目前固定写成112233445566

        int usableTimes = int.Parse(hidUsabelTimes.Value);

        // 12位,年月日8位+标志位2位+次数2位

        // 吴江旅游年卡的标志位为'03'.次数是16进制.
        pdo.endDateNum = "03" + hidEndDate.Value + usableTimes.ToString("X2");
        hidParkInfo.Value = pdo.endDateNum;

        //add by jiangbb 加密 2012-06-08
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustName.Text, ref strBuilder);

        pdo.custName = strBuilder.ToString();
        pdo.custBirth = txtCustBirth.Text;
        pdo.paperType = selPaperType.SelectedValue;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPaperNo, ref strBuilder);
        pdo.paperNo = strBuilder.ToString();

        pdo.custSex = selCustSex.SelectedValue;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custPhone, ref strBuilder);
        pdo.custPhone = strBuilder.ToString();
        pdo.custPost = txtCustPost.Text;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custAddr, ref strBuilder);
        pdo.custAddr = strBuilder.ToString();
        pdo.custEmail = txtEmail.Text;
        pdo.remark = txtRemark.Text;

        // 执行存储过程
        bool ok = TMStorePModule.Excute(context, pdo);

        txtCardNo.Text = "";
        hidReadCardOK.Value = "fail";
        UserCardHelper.resetData(gvOldCardInfo, null);
        gvOldCardInfo.SelectedIndex = -1;
        btnSubmit.Enabled = false;

        // 调用成功，显示成功信息

        if (ok)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "startWjLvyou();", true);

            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, pdo.oldCardNo, txtCustName.Text, "吴江旅游年卡补换卡", "0.00"
                , "0.00", pdo.newCardNo, txtPaperNo.Text, "0.00", "0.00", hidAccRecv.Value, context.s_UserID,
                context.s_DepartName,
                selPaperType.SelectedValue == "" ? "" : selPaperType.SelectedItem.Text, "0.00", hidAccRecv.Value);
        }
    }
}