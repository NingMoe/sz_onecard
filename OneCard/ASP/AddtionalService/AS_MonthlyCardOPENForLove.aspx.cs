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
using TDO.CardManager;
using System.Collections.Generic;
using Master;

/// <summary>
/// 月票卡开通，对于已经售出的卡开通月票

/// </summary>
public partial class ASP_AddtionalService_AS_MonthlyCardOPENForLove : Master.FrontMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        hidReissue.Value = Request.Params["Reissue"];
        labSubTitle.Text = "月票卡爱心卡开通";

        if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

        // 设置可读属性


        setReadOnly(txtCardBalance, txtStartDate, txtEndDate);



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

                : type == "06" ? "7M" // 教育卡售卡  add by youyue 20140611新增教育卡
                : "";
        }
        else
        {
            hidTradeTypeCode.Value
                = type == "01" ? "70" // 学生月票补卡
                : type == "02" ? "71" // 老人月票补卡
                : type == "03" ? "72" // 高龄卡补卡

                : type == "04" ? "7B" // 残疾人月票补卡
                : type == "06" ? "7N" // 教育卡补卡  add by youyue 20140611新增教育卡

                : "";
        }


    }

    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        #region add by shil 20130909,如果是旅游年卡，则不允许在该页面办理业务
        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面办理业务

        bool cardTypeOk = CommonHelper.allowCardtype(context, txtCardNo.Text, "5101", "5103");
        if (cardTypeOk == false)
        {
            return;
        }

        #endregion

        // 读取卡片类型
        readCardType(txtCardNo.Text, labCardType);

        // 读取卡片状态
        ASHelper.readCardState(context, txtCardNo.Text, txtCardState);

        TMTableModule tmTMTableModule = new TMTableModule();
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

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtPaperNo.Text = CommonHelper.GetPaperNo(txtPaperNo.Text);
            txtCustPhone.Text = CommonHelper.GetCustPhone(txtCustPhone.Text);
            txtCustAddr.Text = CommonHelper.GetCustAddress(txtCustAddr.Text);
        }

        // 查询卡片是否是月票卡
        CheckMonthlyCard();

        //add by jiangbb 2012-10-09 市民卡不能修改客户资料
        if (!context.hasError() && txtCardNo.Text.Substring(4, 2).ToString() == "18")
        {
            context.AddMessage("提示：开卡卡号为市民卡，客户资料不会被修改");
        }

        btnPrintPZ.Enabled = false;
        btnSubmit.Enabled = !context.hasError();
    }

    // 检查月票卡信息
    private void CheckMonthlyCard()
    {
        // 查询月票卡应用类型，区域名称，区域代码

        DataTable data = ASHelper.callQuery(context, "CardAppInfo", txtCardNo.Text);
        if (data.Rows.Count != 1)
        {
            selMonthlyCardType.SelectedIndex = 0;
        }
        else
        {
            string type = (string)(data.Rows[0].ItemArray[0]);
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
        }
    }

    // 读取客户信息
    private void readCustInfo()
    {
        DataTable data = ASHelper.callQuery(context, "QueryCustInfo", txtCardNo.Text);
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

    // 确认对话框确认处理

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

            AddMessage("月票卡开通成功");

        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            AddMessage("月票卡开通失败");
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
                "printShouJu();", true);
        }

        hidWarning.Value = ""; // 清除警告信息
    }

    // 提交判断
    private void submitValidate()
    {
        // 校验客户信息
        custInfoForValidate(txtCustName, txtCustBirth, selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);

        Validation valid = new Validation(context);
        valid.check(selMonthlyCardType.SelectedValue != "", "A005090001: 月票类型必须选择", selMonthlyCardType);
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

    // 月票卡售卡提交
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        submitValidate();

        //卡账户有效性检验
        SP_AccCheckPDO pdo2 = new SP_AccCheckPDO();
        pdo2.CARDNO = txtCardNo.Text;
        TMStorePModule.Excute(context, pdo2);

        if (context.hasError()) return;

        string sql = "";
        sql = "select saletype from tl_r_icuser where cardno = '" + txtCardNo.Text + "'";
        context.DBOpen("Select");
        DataTable datasql = context.ExecuteReader(sql);
        if (datasql.Rows[0][0].ToString() == "02")//如果是押金
        {
            if (!HasOperPower("201007", context.s_UserID))//如果当前操作员工不是网点主管
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "radioTagScript", "DeptManagerCheck();", true);
                return;
            }
        }

        OpenSummit();
    }
    private void OpenSummit()
    {
        //add by jiangbb 2012-10-17 判断页面上的证件号码、联系电话、联系地址是否修改 并取值
        string custPaperNo = CommonHelper.GetPaperNo(hidForPaperNo.Value) == txtPaperNo.Text.Trim() ? hidForPaperNo.Value : txtPaperNo.Text.Trim();
        string custPhone = CommonHelper.GetCustPhone(hidForPhone.Value) == txtCustPhone.Text.Trim() ? hidForPhone.Value : txtCustPhone.Text.Trim();
        string custAddr = CommonHelper.GetCustAddress(hidForAddr.Value) == txtCustAddr.Text.Trim() ? hidForAddr.Value : txtCustAddr.Text.Trim();

        // 调用月票卡售卡存储过程  

        context.SPOpen();
        context.AddField("p_ID").Value = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        context.AddField("p_cardNo").Value = txtCardNo.Text;
        context.AddField("p_deposit", "Int32").Value = (int)(Double.Parse(hidDeposit.Value) * 100);
        context.AddField("p_cardCost", "Int32").Value = (int)(Double.Parse(hidCardPost.Value) * 100);
        context.AddField("p_otherFee", "Int32").Value = (int)(Double.Parse(hidOtherFee.Value) * 100);
        context.AddField("p_cardTradeNo").Value = hidTradeNo.Value;
        context.AddField("p_cardMoney", "Int32").Value = (int)(Double.Parse(txtCardBalance.Text) * 100);
        context.AddField("p_tradeTypeCode").Value = "3E";
        context.AddField("p_terminalNo").Value = "112233445566";   // 目前固定写成112233445566

        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustName.Text, ref strBuilder);
        context.AddField("p_custName").Value = strBuilder.ToString();
        context.AddField("p_custSex").Value = selCustSex.SelectedValue;
        context.AddField("p_custBirth").Value = txtCustBirth.Text;
        context.AddField("p_paperType").Value = selPaperType.SelectedValue;

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
        context.AddField("p_appType").Value = selMonthlyCardType.SelectedValue;
        context.AddField("p_assignedArea").Value = selMonthlyCardDistrict.SelectedValue;
        bool ok = context.ExecuteSP("SP_AS_MonthlyCardOpenForLove");

        hidMonthlyFlag.Value = selMonthlyCardDistrict.SelectedValue + (selCustSex.SelectedValue == "0" ? "C1" : "C0");

        // 执行存储过程
        //bool ok = TMStorePModule.Excute(context, pdo);
        btnSubmit.Enabled = false;

        // 存储过程执行成功，显示成功消息

        if (ok)
        {
            // 准备收据打印数据
            ASHelper.preparePingZheng(ptnPingZheng, txtCardNo.Text, txtCustName.Text, "月票卡开通", "0.00"
                , "0.00", "", txtPaperNo.Text, "0.00", "0.00", "0.00", context.s_UserID,
                context.s_DepartName,
                selPaperType.SelectedValue == "" ? "" : selPaperType.SelectedItem.Text, "0.00", "0.00");

            // AddMessage("D005090001: 月票卡后台开卡成功，等待写卡操作");
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "startMonthlyInfoForLove();", true);
        }
    }

    // 刷新行政区域选择
    protected void selMonthlyCardType_SelectedIndexChanged(object sender, EventArgs e)
    {
        // 初始化行政区域

        ASHelper.SelectDistricts(context,
            selMonthlyCardDistrict, selMonthlyCardType.SelectedValue);


        if (selMonthlyCardType.SelectedValue == "05")
        {
            selMonthlyCardDistrict.SelectedValue = "A6";
        }
        if (selMonthlyCardType.SelectedValue == "07")
        {
            selMonthlyCardDistrict.SelectedValue = "A7";
        }

        initGridView();
    }
}
