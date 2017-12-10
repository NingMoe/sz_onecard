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
using NPOI.HSSF.Record.Formula.Functions;

public partial class ASP_AddtionalService_AS_MonthlyCardCharge : Master.FrontMaster
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


        //初始化已开通月份信息
        DateTime dt = DateTime.Now;
        KTMonth1.Text = dt.ToString("yyyy-MM");
        KTMonth2.Text = dt.AddMonths(1).ToString("yyyy-MM");
        KTMonth3.Text = dt.AddMonths(2).ToString("yyyy-MM");
        KTMonth4.Text = dt.AddMonths(3).ToString("yyyy-MM");

        //初始化需开通月份信息

        Month1.Text = KTMonth1.Text;
        Month2.Text = KTMonth2.Text;
        Month3.Text = KTMonth3.Text;
        Month4.Text = KTMonth4.Text;

        // 初始化证件类型

        ASHelper.initPaperTypeList(context, selPaperType);
        //获取token
        string token;
        string sql = "SELECT SYSDATE FROM DUAL";

        TMTableModule tm = new TMTableModule();
        DataTable dt1 = tm.selByPKDataTable(context, sql, 1);
        DateTime now = (DateTime)dt1.Rows[0].ItemArray[0];
        TimeSpan epochTime = (now.ToUniversalTime() - new DateTime(1970, 1, 1));
        token = Token.createToken(context.s_CardID, (uint)epochTime.TotalSeconds);

        hidCardReaderToken1.Value = token;
        // 初始化性别
        ASHelper.initSexList(selCustSex);

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
                               : "";
        //充值仅针对学生卡及老人卡
        if(HidAppType.Value != "01"&& HidAppType.Value != "02")
        {
            context.AddError("该月票类型无需充值");
            return;
        }

        selMonthlyCardDistrict.Text = ddoTD_M_APPAREAOut.AREANAME;

        txtLastYear.Text = HidYearInfo.Value;

        //选中已充值月份
        string mon1 = KTMonth1.Text.Substring(5, 2);
        string mon2 = KTMonth2.Text.Substring(5, 2);
        string mon3 = KTMonth3.Text.Substring(5, 2);
        string mon4 = KTMonth4.Text.Substring(5, 2);

        HidOldPriIndex.Value = HidPriIndex1.Value + HidPriIndex2.Value + HidPriIndex3.Value + HidPriIndex4.Value + HidPriIndex5.Value + HidPriIndex6.Value;

        string year = DateTime.Today.ToString("yyyy");
        string yearlast = year.Substring(2, 2);

        if (IsOdd(Convert.ToInt32(mon1)) == 1)
        {
            if (HidOldPriIndex.Value.Substring((Convert.ToInt32(mon1) - 1)*4, 2) == KTMonth1.Text.Substring(2, 2) &&
                HidOldPriIndex.Value.Substring(((Convert.ToInt32(mon1) - 1)*4) + 4, 2) == SimMonth(mon1) + "2")
            {
                KTMonth1.Checked = true;
                Month1.Checked = false;
                Month1.Enabled = false;
            }
            else
            {
                KTMonth1.Checked = false;
                Month1.Checked = false;
                Month1.Enabled = true;
            }
            if (HidOldPriIndex.Value.Substring((Convert.ToInt32(mon3) - 1)*4, 2) == KTMonth3.Text.Substring(2, 2) &&
                HidOldPriIndex.Value.Substring(((Convert.ToInt32(mon3) - 1)*4) + 4, 2) == SimMonth(mon3) + "2")
            {
                KTMonth3.Checked = true;
                Month3.Checked = false;
                Month3.Enabled = false;
            }
            else
            {
                KTMonth3.Checked = false;
                Month3.Checked = false;
                Month3.Enabled = true;
            }
            if (HidOldPriIndex.Value.Substring((Convert.ToInt32(mon2)*4) - 6, 2) == KTMonth2.Text.Substring(2, 2) &&
                HidOldPriIndex.Value.Substring((Convert.ToInt32(mon2)*4) - 2, 2) == SimMonth(mon2) + "2")
            {
                KTMonth2.Checked = true;
                Month2.Checked = false;
                Month2.Enabled = false;
            }
            else
            {
                KTMonth2.Checked = false;
                Month2.Checked = false;
                Month2.Enabled = true;
            }
            if (HidOldPriIndex.Value.Substring((Convert.ToInt32(mon4)*4) - 6, 2) == KTMonth4.Text.Substring(2, 2) &&
                HidOldPriIndex.Value.Substring((Convert.ToInt32(mon4)*4) - 2, 2) == SimMonth(mon4) + "2")
            {
                KTMonth4.Checked = true;
                Month4.Checked = false;
                Month4.Enabled = false;
            }
            else
            {
                KTMonth4.Checked = false;
                Month4.Checked = false;
                Month4.Enabled = true;
            }
        }
        else
        {
            if (HidOldPriIndex.Value.Substring((Convert.ToInt32(mon2) - 1) * 4, 2) == KTMonth2.Text.Substring(2, 2) &&
               HidOldPriIndex.Value.Substring(((Convert.ToInt32(mon2) - 1) * 4) + 4, 2) == SimMonth(mon2) + "2")
            {
                KTMonth2.Checked = true;
                Month2.Checked = false;
                Month2.Enabled = false;
            }
            else
            {
                KTMonth2.Checked = false;
                Month2.Checked = false;
                Month2.Enabled = true;
            }
            if (HidOldPriIndex.Value.Substring((Convert.ToInt32(mon4) - 1) * 4, 2) == KTMonth4.Text.Substring(2, 2) &&
                HidOldPriIndex.Value.Substring(((Convert.ToInt32(mon4) - 1) * 4) + 4, 2) == SimMonth(mon4) + "2")
            {
                KTMonth4.Checked = true;
                Month4.Checked = false;
                Month4.Enabled = false;
            }
            else
            {
                KTMonth4.Checked = false;
                Month4.Checked = false;
                Month4.Enabled = true;
            }
            if (HidOldPriIndex.Value.Substring((Convert.ToInt32(mon1) * 4) - 6, 2) == KTMonth1.Text.Substring(2, 2) &&
                HidOldPriIndex.Value.Substring((Convert.ToInt32(mon1) * 4) - 2, 2) == SimMonth(mon1) + "2")
            {
                KTMonth1.Checked = true;
                Month1.Checked = false;
                Month1.Enabled = false;
            }
            else
            {
                KTMonth1.Checked = false;
                Month1.Checked = false;
                Month1.Enabled = true;
            }
            if (HidOldPriIndex.Value.Substring((Convert.ToInt32(mon3) * 4) - 6, 2) == KTMonth3.Text.Substring(2, 2) &&
                HidOldPriIndex.Value.Substring((Convert.ToInt32(mon3) * 4) - 2, 2) == SimMonth(mon3) + "2")
            {
                KTMonth3.Checked = true;
                Month3.Checked = false;
                Month3.Enabled = false;
            }
            else
            {
                KTMonth3.Checked = false;
                Month3.Checked = false;
                Month3.Enabled = true;
            }
        }
      
        //市民卡不能修改客户资料
        if (!context.hasError() && txtCardNo.Text.Substring(4, 2).ToString() == "18")
        {
            context.AddMessage("提示：开卡卡号为市民卡，客户资料不会被修改");
        }

        btnPrintPZ.Enabled = false;
        btnSubmit.Enabled = !context.hasError();
    }
    //判断奇偶数
    public static int IsOdd(int n)
    {
        while (true)
        {
            switch (n)
            {
                case 1: return 1;
                case 0: return 0;
            }
            n -= 2;
        }
    }
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

            AddMessage("月票卡充值成功");

        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            AddMessage("月票卡充值失败");
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
    private void submitValidate()
    {
        // 校验客户信息
        custInfoForValidate(txtCustName, txtCustBirth, selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);

        Validation valid = new Validation(context);
        if (selMonthlyCardType.Text != "学生月票卡" && selMonthlyCardType.Text != "老人月票卡")
        {
            context.AddError("该月票卡类型无需充值！");
        }
        else
        {
            valid.check(Month1.Checked || Month2.Checked || Month3.Checked || Month4.Checked, "请选择充值月份");

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

            if (CommonHelper.HasOperPower(context) ||
                CommonHelper.GetPaperNo(hidForPaperNo.Value) != txtPaperNo.Text.Trim())
            {
                if (b)
                {
                    valid.beAlpha(txtPaperNo, "A005010007: 证件号码必须是英文或者数字");
                }
            }
        }
    }
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

    private void OpenSummit()
    {
        if (HidYearInfo.Value == "FFFFFFFF"|| HidYearInfo.Value == "00000000")
        {
            context.AddError("该卡尚未年审！");
            return;
            
        }
        if (!Validation.isNum(HidYearInfo.Value))
        {
            context.AddError("该卡年审标志错误！");
            return;
        }
        if (IsDate(HidYearInfo.Value)==false)
        {
            context.AddError("该卡年审标志非正常时间格式，请重新年审！");
            return;
        }
        if (
            Convert.ToDateTime(HidYearInfo.Value.Substring(0, 4) + "/" + HidYearInfo.Value.Substring(4, 2) + "/" +
                               HidYearInfo.Value.Substring(6, 2) + " 23:59:59") < System.DateTime.Now)
        {
            context.AddError("该卡年审时间已过！");
            return;
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
        string oldflag = HidOldPriIndex.Value;
        string KTMonthHZ = null;
        if (Month1.Checked)
        {
            if (Convert.ToDateTime( Month1.Text.Substring(0, 4) +" / "+ CZMonth1.Substring(0,2)+"/"+"01"+" 00:00:00") <= Convert.ToDateTime(HidYearInfo.Value.Substring(0,4)+"/"+ HidYearInfo.Value.Substring(4, 2)+"/"+ HidYearInfo.Value.Substring(6, 2)+" 00:00:00"))
            {
                oldflag = oldflag.Remove(DigitByMonth(CZMonth1), 2);
                oldflag = oldflag.Insert(DigitByMonth(CZMonth1), CZYear1);
                oldflag = oldflag.Remove(DigitByMonth(CZMonth1) + 4, 2);
                oldflag = oldflag.Insert(DigitByMonth(CZMonth1) + 4,SimMonth(CZMonth1) + "2");
            }
            else
            {
                context.AddError("充值月份超过年审时间！");

            }
            KTMonthHZ = CZMonth1 + ".";
        }
        if (Month2.Checked)
        {
            if (Convert.ToDateTime(Month2.Text.Substring(0, 4) + " / " + CZMonth2.Substring(0, 2) + "/" + "01" + " 00:00:00") <= Convert.ToDateTime(HidYearInfo.Value.Substring(0, 4) + "/" + HidYearInfo.Value.Substring(4, 2) + "/" + HidYearInfo.Value.Substring(6, 2) + " 00:00:00"))
            {
                oldflag = oldflag.Remove(DigitByMonth(CZMonth2), 2);
                oldflag = oldflag.Insert(DigitByMonth(CZMonth2), CZYear2);
                oldflag = oldflag.Remove(DigitByMonth(CZMonth2) + 4, 2);
                oldflag = oldflag.Insert(DigitByMonth(CZMonth2) + 4, SimMonth(CZMonth2) + "2");
            }
            else
            {
                context.AddError("充值月份超过年审时间！");

            }
            KTMonthHZ += CZMonth2 + ".";
        }
        if (Month3.Checked)
        {
            if (Convert.ToDateTime(Month3.Text.Substring(0, 4) + " / " + CZMonth3.Substring(0, 2) + "/" + "01" + " 00:00:00") <= Convert.ToDateTime(HidYearInfo.Value.Substring(0, 4) + "/" + HidYearInfo.Value.Substring(4, 2) + "/" + HidYearInfo.Value.Substring(6, 2) + " 00:00:00"))
            {
                oldflag = oldflag.Remove(DigitByMonth(CZMonth3), 2);
                oldflag = oldflag.Insert(DigitByMonth(CZMonth3), CZYear3);
                oldflag = oldflag.Remove(DigitByMonth(CZMonth3) + 4, 2);
                oldflag = oldflag.Insert(DigitByMonth(CZMonth3) + 4, SimMonth(CZMonth3) + "2");
            }
            else
            {
                context.AddError("充值月份超过年审时间！");

            }
            KTMonthHZ += CZMonth3 + ".";
        }
        if (Month4.Checked)
        {
            if (Convert.ToDateTime(Month4.Text.Substring(0, 4) + " / " + CZMonth4.Substring(0, 2) + "/" + "01" + " 00:00:00") <= Convert.ToDateTime(HidYearInfo.Value.Substring(0, 4) + "/" + HidYearInfo.Value.Substring(4, 2) + "/" + HidYearInfo.Value.Substring(6, 2) + " 00:00:00"))
            {
                oldflag = oldflag.Remove(DigitByMonth(CZMonth4), 2);
                oldflag = oldflag.Insert(DigitByMonth(CZMonth4), CZYear4);
                oldflag = oldflag.Remove(DigitByMonth(CZMonth4) + 4, 2);
                oldflag = oldflag.Insert(DigitByMonth(CZMonth4) + 4, SimMonth(CZMonth4) + "2");
            }
            else
            {
                context.AddError("充值月份超过年审时间！");

            }
            KTMonthHZ += CZMonth4 + ".";
        }
        HidNewPriIndex.Value = oldflag;
        hidMonthlyFlag.Value = HidNewPriIndex.Value;
        string tradetypecode = null;
        if (HidAppType.Value == "01")
        {
            tradetypecode = "3M";
        }
        else if (HidAppType.Value == "02")
        {
            tradetypecode = "3L";
        }
        else
        {
            context.AddError("月票类型错误！");
        }

        if (context.hasError()) return;
        //判断页面上的证件号码、联系电话、联系地址是否修改 并取值

        string custPaperNo = CommonHelper.GetPaperNo(hidForPaperNo.Value) == txtPaperNo.Text.Trim() ? hidForPaperNo.Value : txtPaperNo.Text.Trim();
        string custPhone = CommonHelper.GetCustPhone(hidForPhone.Value) == txtCustPhone.Text.Trim() ? hidForPhone.Value : txtCustPhone.Text.Trim();
        string custAddr = CommonHelper.GetCustAddress(hidForAddr.Value) == txtCustAddr.Text.Trim() ? hidForAddr.Value : txtCustAddr.Text.Trim();

        // 调用月票卡充值存储过程  

        context.SPOpen();
        context.AddField("p_ID").Value = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        context.AddField("p_cardNo").Value = txtCardNo.Text;
        context.AddField("p_chargeFee", "Int32").Value = 2000;                   //充值费用
        context.AddField("p_cardTradeNo").Value = hidTradeNo.Value;
        context.AddField("p_tradeTypeCode").Value = tradetypecode;
        context.AddField("p_terminalNo").Value = "112233445566";   // 目前固定写成112233445566
        context.AddField("p_cardMoney", "Int32").Value = (int)(Double.Parse(txtCardBalance.Text) * 100);//卡内余额
        context.AddField("p_yearCheckFlag").Value = HidYearInfo.Value;//年审时间

        context.AddField("p_hidMonthlyFlag").Value = HidNewPriIndex.Value;

        context.AddField("p_chargeMonth1").Value = Month1.Checked ? Month1.Text.Remove(4, 1) : "";//充值月份
        context.AddField("p_chargeMonth2").Value = Month2.Checked ? Month2.Text.Remove(4, 1) : "";
        context.AddField("p_chargeMonth3").Value = Month3.Checked ? Month3.Text.Remove(4, 1) : "";
        context.AddField("p_chargeMonth4").Value = Month4.Checked ? Month4.Text.Remove(4, 1) : "";


        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustName.Text, ref strBuilder);
        context.AddField("p_custName").Value = strBuilder.ToString();
        context.AddField("p_custSex").Value = selCustSex.SelectedValue;
        context.AddField("p_custBirth").Value = txtCustBirth.Text;
        context.AddField("p_paperType").Value = selPaperType.SelectedValue;

        //新旧标识位
        context.AddField("p_oldFlag").Value = HidOldPriIndex.Value;
        context.AddField("p_newFlag").Value = HidNewPriIndex.Value;

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
        bool ok = context.ExecuteSP("SP_AS_MonthlyCardCharge");

        // 执行存储过程
        btnSubmit.Enabled = false;

        
        


        // 存储过程执行成功，显示成功消息
        if (ok)
        {
            // 准备收据打印数据
            btnPrintPZ.Enabled = true;
            ASHelper.preparePingZheng(ptnPingZheng, txtCardNo.Text, txtCustName.Text, "月票卡充值", Total.Text
                , "月份" + KTMonthHZ, "", txtPaperNo.Text, "0.00", "0.00", Total.Text, context.s_UserID,
                context.s_DepartName,
                selPaperType.SelectedValue == "" ? "" : selPaperType.SelectedItem.Text, "0.00", "0.00");

            // AddMessage("D005090001: 月票卡后台充值成功，等待写卡操作");
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "startMonthlyCharge();", true);
        }
    }

    protected void Month1_CheckedChanged(object sender, EventArgs e)
    {
        monNum.Text = (Convert.ToInt32(Month1.Checked)+ Convert.ToInt32(Month2.Checked) + Convert.ToInt32(Month3.Checked) + Convert.ToInt32(Month4.Checked)).ToString();
        int a = 20;
        int b = Convert.ToInt32(monNum.Text);
        Total.Text = (a*b).ToString();
        hidAccRecv.Value = Total.Text;
    }

    public static bool IsDate(string date)
    {

            //对8位纯数字进行解析
            if (date.Length == 8)
            {
                //获取年月日
                string year = date.Substring(0, 4);
                string month = date.Substring(4, 2);
                string day = date.Substring(6, 2);
                //验证合法性
                if (Convert.ToInt32(year) < 1900 || Convert.ToInt32(year) > 2100)
                {
                    return false;
                }
                if (Convert.ToInt32(month) > 12 || Convert.ToInt32(day) > 31)
                {
                    return false;
                }
                if (Convert.ToInt32(month) == 0 || Convert.ToInt32(day) == 0)
                {
                    return false;
                }
                return true;
            }
        return false;
    }
}