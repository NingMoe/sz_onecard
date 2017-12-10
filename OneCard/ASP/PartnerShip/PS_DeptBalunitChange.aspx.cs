using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Common;
using TM;
using TDO.PartnerShip;
using TDO.BalanceChannel;
using TDO.UserManager;


/***************************************************************
 * 功能名: 网点结算单元维护
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2011/12/26    liuh			初次开发
 ****************************************************************/
public partial class ASP_PartnerShip_PS_DeptBalunitChange : Master.Master
{

    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            //设置GridView绑定的DataTable
            lvwBalUnits.DataSource = new DataTable();
            lvwBalUnits.DataBind();
            lvwBalUnits.SelectedIndex = -1;

            InitControls();
        }
    }

    /// <summary>
    /// 页面控件初始化
    /// </summary>
    private void InitControls()
    {
        //网点结算单元
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_DEPT_BALUNITTDO[] tdoTF_DEPT_BALUNITTDOOutArr = null;
        TF_DEPT_BALUNITTDO tdoTF_TRADE_BALUNITIn = new TF_DEPT_BALUNITTDO();
        tdoTF_DEPT_BALUNITTDOOutArr = (TF_DEPT_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_DEPT_BALUNITTDO), null, null, null);
        ControlDeal.SelectBoxFill(selBalUnit.Items, tdoTF_DEPT_BALUNITTDOOutArr, "DBALUNIT", "DBALUNITNO", true);

        this.txtBalUnitNo.Text = this.GetDbalnuitno();

        //初始化转出银行,开户银行下拉列表值
        //TD_M_BANKTDO ddoTD_M_BANKIn = new TD_M_BANKTDO();
        //TD_M_BANKTDO[] ddoTD_M_BANKOutArr = (TD_M_BANKTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_BANKIn, typeof(TD_M_BANKTDO), "S008107211", "", null);

        //ControlDeal.SelectBoxFill(selBank.Items, ddoTD_M_BANKOutArr, "BANK", "BANKCODE", true);
        //ControlDeal.SelectBoxFill(selFinBank.Items, ddoTD_M_BANKOutArr, "BANK", "BANKCODE", true);

        //初始化转账类型下拉列表框值
        selFinType.Items.Add(new ListItem("---请选择---", ""));
        selFinType.Items.Add(new ListItem("0:财务部门转账", "0"));
        selFinType.Items.Add(new ListItem("1:结入预付款", "1"));

        //初始化结算周期类型下拉列表值
        selBalCyclType.Items.Add(new ListItem("---请选择---", ""));
        selBalCyclType.Items.Add(new ListItem("00:小时", "00"));
        selBalCyclType.Items.Add(new ListItem("01:天", "01"));
        selBalCyclType.Items.Add(new ListItem("02:周", "02"));
        selBalCyclType.Items.Add(new ListItem("03:固定月", "03"));
        selBalCyclType.Items.Add(new ListItem("04:自然月", "04"));
        selBalCyclType.Items[2].Selected = true;

        //初始化划账周期类型下拉列表值
        selFinCyclType.Items.Add(new ListItem("---请选择---", ""));
        selFinCyclType.Items.Add(new ListItem("00:小时", "00"));
        selFinCyclType.Items.Add(new ListItem("01:天", "01"));
        selFinCyclType.Items.Add(new ListItem("02:周", "02"));
        selFinCyclType.Items.Add(new ListItem("03:固定月", "03"));
        selFinCyclType.Items.Add(new ListItem("04:自然月", "04"));
        selFinCyclType.Items[5].Selected = true;

        txtBalInterval.Text = "1";
        txtFinInterval.Text = "1";

        //初始化有效标志下拉列表框值
        TSHelper.initUseTag(selUseTag);

        TD_M_TAGTDO ddoTD_M_TAGIn = new TD_M_TAGTDO();
        ddoTD_M_TAGIn.TAGCODE = "DBALUNIT_WARNLINE";
        TD_M_TAGTDO ddoTD_M_TAGOut = (TD_M_TAGTDO)tmTMTableModule.selByPK(context, ddoTD_M_TAGIn, typeof(TD_M_TAGTDO), null, "TD_M_TAG", null);

        if (ddoTD_M_TAGOut != null)
        {
            this.txtWarnline.Text = ((Convert.ToDecimal(ddoTD_M_TAGOut.TAGVALUE)) / 100).ToString();
        }

        ddoTD_M_TAGIn.TAGCODE = "DBALUNIT_LIMITLINE";
        ddoTD_M_TAGOut = (TD_M_TAGTDO)tmTMTableModule.selByPK(context, ddoTD_M_TAGIn, typeof(TD_M_TAGTDO), null, "TD_M_TAG", null);

        if (ddoTD_M_TAGOut != null)
        {
            this.txtLimitline.Text = ((Convert.ToDecimal(ddoTD_M_TAGOut.TAGVALUE)) / 100).ToString();
        }


        //指定GridView  lvwBalUnits DataKeyNames
        lvwBalUnits.DataKeyNames = new string[] 
       {
           "DBALUNITNO", "DBALUNIT", "DEPTTYPECODE", "TRADEID",
            "FINBANKCODE", "BANKCODE",           
           "BANKACCNO", "BALCYCLETYPECODE", "BALINTERVAL",             
           "FINCYCLETYPECODE", "FININTERVAL", "FINTYPECODE",  "UNITEMAIL",                     
           "PREPAYWARNLINE",  "PREPAYLIMITLINE", "USETAG",
           "LINKMAN", "UNITADD", "UNITPHONE", "REMARK","APRVSTATE"
       };
    }

    #region 页面控件事件
    /// <summary>
    /// 查询按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        List<string> vars = new List<string>();
        vars.Add(selBalUnit.SelectedValue);
        vars.Add(selAprvState.SelectedValue);
        vars.Add(ddlBalType.SelectedValue);

        //查询结算单元信息
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryDeptBalUnit", vars.ToArray());

        UserCardHelper.resetData(lvwBalUnits, data);


        ClearBalUnit();
    }

    protected void lvwBalUnits_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwBalUnits','Select$" + e.Row.RowIndex + "')");
        }
    }

    public void lvwBalUnits_SelectedIndexChanged(object sender, EventArgs e)
    {
        try
        {
            txtBalUnitNo.Text = getDataKeys("DBALUNITNO");
            txtBalUnit.Text = getDataKeys("DBALUNIT");
            selBalType.SelectedValue = getDataKeys("DEPTTYPECODE");
            //selFinBank.SelectedValue = getDataKeys("FINBANKCODE");
            //selBank.SelectedValue = getDataKeys("BANKCODE");
            getBank(selFinBank, getDataKeys("FINBANKCODE").Trim());
            getBank(selBank, getDataKeys("BANKCODE").Trim());
            txtBankAccNo.Text = getDataKeys("BANKACCNO");
            selBalCyclType.SelectedValue = getDataKeys("BALCYCLETYPECODE");
            txtBalInterval.Text = getDataKeys("BALINTERVAL");
            selFinCyclType.SelectedValue = getDataKeys("FINCYCLETYPECODE");
            txtFinInterval.Text = getDataKeys("FININTERVAL");
            selFinType.SelectedValue = getDataKeys("FINTYPECODE");
            selUseTag.SelectedValue = getDataKeys("USETAG");
            txtLinkMan.Text = getDataKeys("LINKMAN");
            txtAddress.Text = getDataKeys("UNITADD");
            txtPhone.Text = getDataKeys("UNITPHONE");
            txtEmail.Text = getDataKeys("UNITEMAIL");
            txtRemark.Text = getDataKeys("REMARK");
            this.txtWarnline.Text = ((Convert.ToDecimal(getDataKeys("PREPAYWARNLINE")))).ToString();
            this.txtLimitline.Text = ((Convert.ToDecimal(getDataKeys("PREPAYLIMITLINE")))).ToString();

            //选择列表框一行记录后,显示结算单元信息
            //选择记录结算单元为有效时,可以修改
            if (getDataKeys("USETAG") == "1")
            {
                btnModify.Enabled = true;
            }
            else
            {
                btnModify.Enabled = false;
            }
        }
        catch (Exception)
        {
            ClearBalUnit();
            context.AddError("页面赋值出错");
        }

    }

    /// <summary>
    /// 增加按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        //调用结算单元输入判断
        if (!BalUnitInputValidation())
        {
            return;
        }

        //对有效是否为有效的判断
        string strUseTag = selUseTag.SelectedValue;
        if (strUseTag == "0")
        {
            context.AddError("A008107041", selUseTag);
            return;
        }

        context.SPOpen();
        context.AddField("P_BALUNITNO").Value = this.txtBalUnitNo.Text.Trim();
        context.AddField("P_BALUNIT").Value = this.txtBalUnit.Text.Trim();
        context.AddField("P_BALTYPE").Value = this.selBalType.SelectedValue;
        context.AddField("P_BANKCODE").Value = this.selBank.Text.Trim();
        context.AddField("P_BANKACCNO").Value = this.txtBankAccNo.Text.Trim();

        context.AddField("P_BALCYCLETYPECODE").Value = this.selBalCyclType.SelectedValue;
        context.AddField("P_BALINTERVAL").Value = this.txtBalInterval.Text.Trim();
        context.AddField("P_FINCYCLETYPECODE").Value = this.selFinCyclType.Text.Trim();

        context.AddField("P_FININTERVAL").Value = this.txtFinInterval.Text.Trim();
        context.AddField("P_FINTYPECODE").Value = this.selFinType.SelectedValue;
        context.AddField("P_FINBANKCODE").Value = this.selFinBank.SelectedValue;

        context.AddField("P_WARNLINE").Value = Convert.ToInt32(Convert.ToDecimal(txtWarnline.Text) * 100);
        context.AddField("P_LIMITLINE").Value = Convert.ToInt32(Convert.ToDecimal(txtLimitline.Text) * 100);
        context.AddField("P_LINKMAN").Value = this.txtLinkMan.Text.Trim();
        context.AddField("P_UNITPHONE").Value = this.txtPhone.Text.Trim();
        context.AddField("P_UNITADD").Value = this.txtAddress.Text.Trim();
        context.AddField("P_UNITEMAIL").Value = this.txtEmail.Text.Trim();
        context.AddField("P_REMARK").Value = this.txtRemark.Text.Trim();

        bool ok = context.ExecuteSP("SP_PS_DEPTBALUNITADD");

        if (ok)
        {
            AddMessage("M008107113");

            btnQuery_Click(sender, e);

            txtBalUnitNo.Text = GetDbalnuitno();
        }
    }

    /// <summary>
    /// 修改按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnModify_Click(object sender, EventArgs e)
    {

        //调用修改的判断处理
        Boolean keyInfoChanged;
        if (!BalUnitModifyValidation(out keyInfoChanged)) return;


        context.SPOpen();
        context.AddField("P_BALUNITNO").Value = this.txtBalUnitNo.Text.Trim();
        context.AddField("P_BALUNIT").Value = this.txtBalUnit.Text.Trim();
        context.AddField("P_BALTYPE").Value = this.selBalType.SelectedValue;
        context.AddField("P_BANKCODE").Value = this.selBank.Text.Trim();
        context.AddField("P_BANKACCNO").Value = this.txtBankAccNo.Text.Trim();
        context.AddField("P_BALCYCLETYPECODE").Value = this.selBalCyclType.SelectedValue;
        context.AddField("P_BALINTERVAL").Value = this.txtBalInterval.Text.Trim();
        context.AddField("P_FINCYCLETYPECODE").Value = this.selFinCyclType.Text.Trim();
        context.AddField("P_FININTERVAL").Value = this.txtFinInterval.Text.Trim();
        context.AddField("P_FINTYPECODE").Value = this.selFinType.SelectedValue;
        context.AddField("P_FINBANKCODE").Value = this.selFinBank.SelectedValue;
        context.AddField("P_WARNLINE").Value = Convert.ToInt32(Convert.ToDecimal(txtWarnline.Text) * 100);
        context.AddField("P_LIMITLINE").Value = Convert.ToInt32(Convert.ToDecimal(txtLimitline.Text) * 100);
        context.AddField("P_LINKMAN").Value = this.txtLinkMan.Text.Trim();
        context.AddField("P_UNITPHONE").Value = this.txtPhone.Text.Trim();
        context.AddField("P_UNITADD").Value = this.txtAddress.Text.Trim();
        context.AddField("P_UNITEMAIL").Value = this.txtEmail.Text.Trim();
        context.AddField("P_REMARK").Value = this.txtRemark.Text.Trim();

        context.AddField("P_USETAG").Value = selUseTag.SelectedValue;
        context.AddField("P_APRVSTATE").Value = getDataKeys("APRVSTATE");
        context.AddField("P_SEQNO").Value = getDataKeys("TRADEID");

        context.AddField("P_KEYINFOCHANGED").Value = getDataKeys("APRVSTATE") == "0" && keyInfoChanged == false ? "N" : "Y";

        bool ok = context.ExecuteSP("SP_PS_DEPTBALUNITMODIFY");

        if (ok)
        {
            AddMessage("M008107111");
            btnQuery_Click(sender, e);

            txtBalUnitNo.Text = GetDbalnuitno();
        }
    }

    /// <summary>
    /// 查询区单元类型选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ddlBalType_SelectedIndexChanged(object sender, EventArgs e)
    {
        selBalUnit.Items.Clear();

        context.DBOpen("Select");
        System.Text.StringBuilder sql = new System.Text.StringBuilder();
        sql.Append("SELECT DBALUNIT, DBALUNITNO	FROM TF_DEPT_BALUNIT WHERE USETAG = '1'");
        if (ddlBalType.SelectedIndex > 0)
        {
            sql.Append("AND DEPTTYPE = '" + ddlBalType.SelectedValue + "'");
        }
        sql.Append("ORDER BY DBALUNITNO");

        System.Data.DataTable table = context.ExecuteReader(sql.ToString());
        GroupCardHelper.fill(selBalUnit, table, true);
    }
    /// <summary>
    /// 录入区单元类型选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void selBalType_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (this.btnModify.Enabled == false && this.txtBalUnitNo.Text.Trim().Length == 8)
        {
            if (this.selBalType.SelectedValue == "2")
            {
                this.txtBalUnitNo.Text = this.txtBalUnitNo.Text.Trim().Replace("DL","SH");
            }
            else
            {
                this.txtBalUnitNo.Text = this.txtBalUnitNo.Text.Trim().Replace("SH", "DL");
            }
        }
    }
    #endregion

    #region  验证与判断
    /// <summary>
    /// 修改结算单元验证
    /// </summary>
    /// <param name="keyInfoChanged"></param>
    /// <returns></returns>
    private Boolean BalUnitModifyValidation(out Boolean keyInfoChanged)
    {
        keyInfoChanged = true;
        //判断是否选择了需要修改的结算单元
        if (lvwBalUnits.SelectedIndex == -1)
        {
            context.AddError("A008107052");
            return false;
        }

        //若结算单元为无效时,修改后的有效标志还是为无效时
        if (selUseTag.SelectedValue == "0" && getDataKeys("USETAG") == "0")
        {
            //无效的结算单元,没有修改为有效时,不能提交修改
            context.AddError("A008107079", selUseTag);
            return false;
        }

        //网点和商户不能互转
        string strDepttype = getDataKeys("DEPTTYPECODE").Trim();
        if ((selBalType.SelectedValue == "0" || selBalType.SelectedValue == "1")
            && strDepttype == "2")
        {
            context.AddError("A008107090:商户结算单元不能修改为网点结算单元", selBalType);
            return false;
        }
        else if (selBalType.SelectedValue == "2"
            && (strDepttype == "0" || strDepttype == "1"))
        {
            context.AddError("A008107091:网点结算单元不能修改为商户结算单元", selBalType);
            return false;
        }

        //当选择结算单元所有信息都没有修改时,不能执行修改
        keyInfoChanged = isKeyInfoChanged();
        if (!keyInfoChanged && !isTrivialInfoChanged())
        {
            context.AddError("A008107066");
            return false;
        }

        //调用结算单元输入判断
        if (!BalUnitInputValidation())
        {
            return false;
        }

        //检验结算单元编码是否修改
        if (txtBalUnitNo.Text.Trim() != getDataKeys("DBALUNITNO"))
        {
            context.AddError("A008107108", txtBalUnitNo);
            return false;
        }

        return true;
    }

    /// <summary>
    /// 判断是否需要审批（如果只修改了联系人，联系电话，联系地址，电子邮件时，不需要审批）
    /// </summary>
    /// <returns></returns>
    private bool isKeyInfoChanged()
    {
        return
            txtBalUnitNo.Text.Trim() != getDataKeys("DBALUNITNO") ||
            txtBalUnit.Text.Trim() != getDataKeys("DBALUNIT") ||
            selBalType.SelectedValue != getDataKeys("DEPTTYPECODE") ||
            selFinBank.SelectedValue != getDataKeys("FINBANKCODE") ||
            selBank.SelectedValue != getDataKeys("BANKCODE") ||
            txtBankAccNo.Text.Trim() != getDataKeys("BANKACCNO") ||
            txtWarnline.Text != ((Convert.ToDecimal(getDataKeys("PREPAYWARNLINE")))).ToString() ||
            txtLimitline.Text != ((Convert.ToDecimal(getDataKeys("PREPAYLIMITLINE")))).ToString() ||
            selBalCyclType.SelectedValue != getDataKeys("BALCYCLETYPECODE") ||
            txtBalInterval.Text.Trim() != getDataKeys("BALINTERVAL") ||
            selFinCyclType.SelectedValue != getDataKeys("FINCYCLETYPECODE") ||
            txtFinInterval.Text.Trim() != getDataKeys("FININTERVAL") ||
            selFinType.SelectedValue != getDataKeys("FINTYPECODE") ||
            selUseTag.SelectedValue != getDataKeys("USETAG");
    }

    /// <summary>
    /// 判断联系人，联系电话，联系地址，电子邮件是否进行了修改
    /// </summary>
    /// <returns></returns>
    private bool isTrivialInfoChanged()
    {
        return
            txtLinkMan.Text.Trim() != getDataKeys("LINKMAN") ||
            txtAddress.Text.Trim() != getDataKeys("UNITADD") ||
            txtPhone.Text.Trim() != getDataKeys("UNITPHONE") ||
            txtEmail.Text.Trim() != getDataKeys("UNITEMAIL") ||
            txtRemark.Text.Trim() != getDataKeys("REMARK");
    }

    /// <summary>
    /// 输入信息验证
    /// </summary>
    /// <returns></returns>
    private Boolean BalUnitInputValidation()
    {
        //对结算单元输入信息的判断处理

        //结算单元非空,长度,数字的判断

        string strBalUnitNo = txtBalUnitNo.Text.Trim();
        if (strBalUnitNo == "")
            context.AddError("A008107105", txtBalUnitNo);
        else if (Validation.strLen(strBalUnitNo) != 8)
            context.AddError("A008107106", txtBalUnitNo);
        else if (!Validation.isCharNum(strBalUnitNo))
            context.AddError("A008107107", txtBalUnitNo);

        //对结算单元名称进行非空,长度校验
        string strBalUnit = txtBalUnit.Text.Trim();
        if (strBalUnit == "")
        {
            context.AddError("A008107005", txtBalUnit);
        }

        else if (Validation.strLen(strBalUnit) > 50)
        {
            context.AddError("A008107006", txtBalUnit);
        }

        string strBalUnitType = selBalType.SelectedValue;
        if (strBalUnitType == "")
        {
            context.AddError("A008107047", selBalType);
        }


        //对转出银行进行非空检测

        string strFinBank = selFinBank.SelectedValue;
        if (strFinBank == "")
            context.AddError("A008107051", selFinBank);

        //对开户银行进行非空检测

        string strBank = selBank.SelectedValue;
        if (strBank == "")
            context.AddError("A008107007", selBank);

        //对开户银行账号的检测

        string strBankAccNo = txtBankAccNo.Text.Trim();
        if (strBankAccNo != "")
        {
            if (Validation.strLen(strBankAccNo) > 30)
            {
                context.AddError("A008107010", txtBankAccNo);
            }
        }


        //对结算周期类型非空的检测

        string strBalCycType = selBalCyclType.SelectedValue;
        if (strBalCycType == "")
        {
            context.AddError("A008107012", selBalCyclType);
        }


        //对结算周期跨度的检测

        string strBalInterval = txtBalInterval.Text.Trim();
        if (strBalInterval == "")
        {
            context.AddError("A008107013", txtBalInterval);
        }
        else if (!isIntegerPlus(strBalInterval))
        {
            //判断正整数
            context.AddError("A008107014", txtBalInterval);
        }

        //对划账周期类型非空的检测

        string strFinCyclType = selFinCyclType.SelectedValue;
        if (strFinCyclType == "")
        {
            context.AddError("A008107015", selFinCyclType);
        }

        //对划账周期跨度的检测

        string strFinInterval = txtFinInterval.Text.Trim();
        if (strFinInterval == "")
        {
            context.AddError("A008107016", txtFinInterval);
        }
        else if (!isIntegerPlus(strFinInterval))
        {
            //判断正整数

            context.AddError("A008107017", txtFinInterval);
        }

        //对转账类型非空的检测

        string strFinType = selFinType.SelectedValue;
        if (strFinType == "")
        {
            context.AddError("A008107018", selFinType);
        }


        //对有效标志进行非空检验

        String strUseTag = selUseTag.SelectedValue;
        if (strUseTag == "")
            context.AddError("A008100014", selUseTag);


        if (txtWarnline.Text.Trim() == "")
        {
            context.AddError("A008100051:预警额度为空", txtWarnline);
        }
        else if (!isInteger(txtWarnline.Text.Trim()))
        {
            //判断正整数
            context.AddError("A008100053:预警额度不是整数", txtWarnline);
        }


        if (txtLimitline.Text.Trim() == "")
        {
            context.AddError("A008100052:最低额度为空", txtLimitline);
        }
        else if (!isInteger(txtLimitline.Text.Trim()))
        {
            //判断正整数
            context.AddError("A008100054:预警额度不是整数", txtLimitline);
        }


        //对联系人进行非空,长度校验
        String strLinkMan = txtLinkMan.Text.Trim();
        if (strLinkMan == "")
            context.AddError("A008100004", txtLinkMan);
        else if (Validation.strLen(strLinkMan) > 10)
            context.AddError("A008100005", txtLinkMan);

        //对联系地址进行非空,长度校验
        string strAddr = txtAddress.Text.Trim();
        if (strAddr == "")
            context.AddError("A008100008", txtAddress);
        else if (Validation.strLen(strAddr) > 50)
            context.AddError("A008100009", txtAddress);


        //对联系电话进行非空,长度校验
        string strPhone = txtPhone.Text.Trim();
        if (strPhone == "")
            context.AddError("A008100006", txtPhone);
        else if (Validation.strLen(strPhone) > 20)
            context.AddError("A008107024", txtPhone);


        //对备注进行长度校验
        string strRemrk = txtRemark.Text.Trim();
        if (strRemrk != "")
        {
            if (Validation.strLen(strRemrk) > 50)
                context.AddError("A008100011", txtRemark);
        }

        //对电子邮件的校验
        string strEmail = txtEmail.Text.Trim();
        String[] fieldsEMail = null;
        String email;
        bool ret = false;
        if (strEmail != "")
        {
            if (Validation.strLen(strEmail) > 200)
                context.AddError("A008107078", txtEmail);
            else
            {
                fieldsEMail = strEmail.Split(new char[1] { ';' });
                for (int i = 0; i < fieldsEMail.Length; i++)
                {
                    email = fieldsEMail[i].Trim();
                    ret = Validation.reg1.IsMatch(fieldsEMail[i].Trim());
                    if (!ret)
                        context.AddError("A003100028", txtEmail);
                }
            }
        }

        //对context的error检测 
        if (context.hasError())
            return false;
        else
            return true;
    }

    /// <summary>
    /// 正整数
    /// </summary>
    /// <param name="strInput"></param>
    /// <returns></returns>
    private Boolean isIntegerPlus(string strInput)
    {
        System.Text.RegularExpressions.Regex reg1
                          = new System.Text.RegularExpressions.Regex(@"^[1-9][0-9]*$");

        return reg1.IsMatch(strInput);
    }

    /// <summary>
    /// 整数
    /// </summary>
    /// <param name="strInput"></param>
    /// <returns></returns>
    private Boolean isInteger(string strInput)
    {
        System.Text.RegularExpressions.Regex reg1
                        = new System.Text.RegularExpressions.Regex(@"^-?\d+$");

        return reg1.IsMatch(strInput);
    }

    #endregion

    #region 其他公用方法
    public String getDataKeys(string keysname)
    {
        try
        {
            string value = lvwBalUnits.DataKeys[lvwBalUnits.SelectedIndex][keysname].ToString();

            return value.Trim();
        }
        catch
        {
            return "";
        }
    }

    /// <summary>
    /// 清空页面控件值
    /// </summary>
    private void ClearBalUnit()
    {
        lvwBalUnits.SelectedIndex = -1;
        txtBalUnit.Text = "";
        selBalType.SelectedValue = "";

        selFinBank.SelectedValue = "";
        selBank.SelectedValue = "";
        txtBankAccNo.Text = "";

        selBalCyclType.SelectedValue = "";
        txtBalInterval.Text = "";
        selFinCyclType.SelectedValue = "";
        txtFinInterval.Text = "";
        selFinType.SelectedValue = "";
        selUseTag.SelectedValue = "";

        txtLinkMan.Text = "";
        txtAddress.Text = "";
        txtPhone.Text = "";
        txtRemark.Text = "";
        txtEmail.Text = "";

    }

    /// <summary>
    /// 获取结算单元编码
    /// </summary>
    /// <returns></returns>
    protected string GetDbalnuitno()
    {
        string dBalunitNo = "";

        context.SPOpen();
        context.AddField("p_step").Value = "1";//步长
        context.AddField("p_type").Value = "D1";//D1:网点结算单元--结算单元编码取值
        context.AddField("p_Len").Value = "6";//取得编码长度
        context.AddField("p_code", "String", "output", "8", null);
        context.ExecuteReader("SP_GetBizAppCodeCommit");
        dBalunitNo = "DL" + context.GetFieldValue("p_code").ToString();

        return dBalunitNo;
    }
    #endregion

    /// <summary>
    /// 选择银行信息，初始化银行下拉列表
    /// </summary>
    /// <param name="ddlist"></param>
    /// <param name="bankCode"></param>
    protected void getBank(DropDownList ddlist, string bankCode)
    {
        context.DBOpen("Select");
        System.Text.StringBuilder sql = new System.Text.StringBuilder();

        sql.Append("SELECT BANK, BANKCODE FROM TD_M_BANK WHERE  ");
        if (bankCode.Length != 0)
        {
            sql.Append(" BANKCODE = '" + bankCode + "'");
        }

        System.Data.DataTable table = context.ExecuteReader(sql.ToString());
        GroupCardHelper.fill(ddlist, table, true);
        ddlist.SelectedValue = bankCode;
    }

    /// <summary>
    /// 根据输入的开户银行初始化开户银行下拉列表
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void txtBank_Changed(object sender, EventArgs e)
    {

        if (string.IsNullOrEmpty(txtBank.Text.Trim()))
        {
            return;
        }

        selBank.Items.Clear();

        context.DBOpen("Select");
        System.Text.StringBuilder sql = new System.Text.StringBuilder();

        sql.Append("SELECT BANK, BANKCODE FROM TD_M_BANK WHERE BANKNUMBER IS NOT NULL AND ");
        //模糊查询银行名称，并在列表中赋值
        string strBalname = txtBank.Text.Trim().Replace('\'', '\"');
        if (strBalname.Length != 0)
        {
            sql.Append(" BANK LIKE '%" + strBalname + "%'");
        }
        sql.Append("ORDER BY BANKCODE");

        System.Data.DataTable table = context.ExecuteReader(sql.ToString());
        GroupCardHelper.fill(selBank, table, true);
    }

    /// <summary>
    /// 根据输入的转出银行初始化转出银行下拉列表
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void txtFinBank_Changed(object sender, EventArgs e)
    {

        if (string.IsNullOrEmpty(txtFinBank.Text.Trim()))
        {
            return;
        }

        selFinBank.Items.Clear();

        context.DBOpen("Select");
        System.Text.StringBuilder sql = new System.Text.StringBuilder();

        sql.Append("SELECT BANK, BANKCODE	FROM TD_M_BANK WHERE BANKNUMBER IS NOT NULL AND ");
        //模糊查询银行名称，并在列表中赋值
        string strBalname = txtFinBank.Text.Trim().Replace('\'', '\"');
        if (strBalname.Length != 0)
        {
            sql.Append(" BANK LIKE '%" + strBalname + "%'");
        }
        sql.Append("ORDER BY BANKCODE");

        System.Data.DataTable table = context.ExecuteReader(sql.ToString());
        GroupCardHelper.fill(selFinBank, table, true);
    }
}
