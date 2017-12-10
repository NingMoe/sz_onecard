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

using Master;
using TDO.BalanceChannel;
using Common;
using TM;
using TDO.UserManager;
using TDO.PartnerShip;
using PDO.PartnerShip;
using TDO.BalanceParameter;


public partial class ASP_PartnerShip_PS_TransferChange : Master.Master
{
    private void getNextBalUnitNo()
    {
        //DataTable dt = ChargeCardHelper.callQuery(context, "NEXTBALUNITNO");
        //txtBalUnitNo.Text = (selCallingExt.SelectedValue == ""
        //    ? "0B00" : (selCallingExt.SelectedValue + "00")) + dt.Rows[0].ItemArray[0];

        if (lvwBalUnits.SelectedIndex == -1)
        {
            if (selCallingExt.SelectedValue != "" && selRegionExt.SelectedValue != "" 
                && selDeliveryModeExt.SelectedValue != "" && selAppCallingExt.SelectedValue != "")
            {
                string callCode = selCallingExt.SelectedValue;
                string regionCode = selRegionExt.SelectedValue;
                string deliveryModeCode = selDeliveryModeExt.SelectedValue;
                string appCallingCode = selAppCallingExt.SelectedValue;

                SP_PS_GetNextNoPDO pdo = new SP_PS_GetNextNoPDO();
                pdo.funcCode = "NEXTBALUNITNO";
                pdo.prefix = callCode + regionCode + deliveryModeCode + appCallingCode;

                StoreProScene storePro = new StoreProScene();
                DataTable data = storePro.Execute(context, pdo);

                if (string.IsNullOrEmpty(pdo.output))
                {
                    context.AddError("A008107110", txtBalUnitNo);
                }
                else
                {
                    txtBalUnitNo.Text = pdo.output;
                }

            }
            else
            {
                txtBalUnitNo.Text = "";
            }
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        UserCardHelper.resetData(lvwBalUnits, null);

        TMTableModule tmTMTableModule = new TMTableModule();
        //初始化查询输入的行业名称下拉列表框

        //从行业编码表(TD_M_CALLINGNO)中读取数据，放入查询输入行业名称下拉列表中


        TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
        TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), "S008100211");

        ControlDeal.SelectBoxFillWithCode(selCalling.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);

        //初始化结算单元信息增加修改区域的字段初始值


        //初始化行业名称下拉列表值

        ControlDeal.SelectBoxFillWithCode(selCallingExt.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);


        //初始单位类型下拉列表值
        selBalType.Items.Add(new ListItem("---请选择---", ""));
        selBalType.Items.Add(new ListItem("00:行业", "00"));
        selBalType.Items.Add(new ListItem("01:单位", "01"));
        selBalType.Items.Add(new ListItem("02:部门", "02"));
        selBalType.Items.Add(new ListItem("03:行业员工", "03"));
        selBalType.Items.Add(new ListItem("04:合帐结算单元", "04"));


        //初始来源识别类型下拉列表值
        selSourceType.Items.Add(new ListItem("---请选择---", ""));
        selSourceType.Items.Add(new ListItem("00:PSAM卡号", "00"));
        selSourceType.Items.Add(new ListItem("01:信息亭", "01"));
        selSourceType.Items.Add(new ListItem("02:司机工号", "02"));

        //从内部员工编码表(TD_M_INSIDESTAFF)中读取数据,初始化商户经理下拉列表值

        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), "S008111111", "TD_M_INSIDESTAFF_SVR", null);

        ControlDeal.SelectBoxFill(selSerMgr.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        ControlDeal.SelectBoxFill(selMsgQry.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);


        //初始化转出银行,开户银行下拉列表值

        //TD_M_BANKTDO ddoTD_M_BANKIn = new TD_M_BANKTDO();
        //TD_M_BANKTDO[] ddoTD_M_BANKOutArr = (TD_M_BANKTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_BANKIn, typeof(TD_M_BANKTDO), "S008107211", "", null);

        //ControlDeal.SelectBoxFill(selBank.Items, ddoTD_M_BANKOutArr, "BANK", "BANKCODE", true);
        //ControlDeal.SelectBoxFill(selFinBank.Items, ddoTD_M_BANKOutArr, "BANK", "BANKCODE", true);


        //初始化结算级别下拉列表值


        selBalLevel.Items.Add(new ListItem("---请选择---", ""));
        for (int i = 1; i <= 9; i++)
        {
            string str = Convert.ToString(i);
            selBalLevel.Items.Add(new ListItem(str, str));
        }
        selBalLevel.Items[2].Selected = true;

        //初始化结算周期类型下拉列表值

        selBalCyclType.Items.Add(new ListItem("---请选择---", ""));
        selBalCyclType.Items.Add(new ListItem("00:小时", "00"));
        selBalCyclType.Items.Add(new ListItem("01:天", "01"));
        selBalCyclType.Items.Add(new ListItem("02:周", "02"));
        selBalCyclType.Items.Add(new ListItem("03:固定月", "03"));
        selBalCyclType.Items.Add(new ListItem("04:自然月", "04"));
        selBalCyclType.Items[2].Selected = true;

        //getNextBalUnitNo();
        txtBalInterval.Text = "1";
        txtFinInterval.Text = "1";

        //初始化划账周期类型下拉列表值

        selFinCyclType.Items.Add(new ListItem("---请选择---", ""));
        selFinCyclType.Items.Add(new ListItem("00:小时", "00"));
        selFinCyclType.Items.Add(new ListItem("01:天", "01"));
        selFinCyclType.Items.Add(new ListItem("02:周", "02"));
        selFinCyclType.Items.Add(new ListItem("03:固定月", "03"));
        selFinCyclType.Items.Add(new ListItem("04:自然月", "04"));
        selFinCyclType.Items[5].Selected = true;



        //初始化转账类型下拉列表框值

        selFinType.Items.Add(new ListItem("---请选择---", ""));
        selFinType.Items.Add(new ListItem("0:财务部门转账", "0"));
        selFinType.Items.Add(new ListItem("1:财务不转账", "1"));


        //佣金扣减方式下拉列表框值

        selComFeeTake.Items.Add(new ListItem("---请选择---", ""));
        selComFeeTake.Items.Add(new ListItem("0:不在转账金额扣减", "0"));
        selComFeeTake.Items.Add(new ListItem("1:直接从转账金额扣减", "1"));

        //初始化有效标志下拉列表框值

        TSHelper.initUseTag(selUseTag);

        //add by jiangbb 2012-05-18 初始化收款人账户类型下拉框列表框值
        selPurPoseType.Items.Add(new ListItem("---请选择---", ""));
        selPurPoseType.Items.Add(new ListItem("对公", "1"));
        selPurPoseType.Items.Add(new ListItem("对私", "2"));

        selBankChannel.Items.Add(new ListItem("---请选择---", ""));
        selBankChannel.Items.Add(new ListItem("跨行支付", "1"));
        selBankChannel.Items.Add(new ListItem("同城支付", "3"));

        //地区
        InitSelREGIONCODE();

        //POS投放模式
        InitSelDELIVERYMODE();

        //应用行业
        InitSelAPPCALLINGCODE();

        //指定GridView  lvwBalUnits DataKeyNames
        lvwBalUnits.DataKeyNames = new string[] 
           {
               "TRADEID", "COMSCHEMENO", "BEGINTIME",  "ENDTIME",
               "BALUNITNO", "BALUNIT", "BALUNITTYPECODE", "SOURCETYPECODE", "SERMANAGERCODE",        
               "CALLINGNO", "CORPNO", "DEPARTNO", "FINBANKCODE", "BANKCODE",           
               "BANKACCNO", "BALLEVEL", "BALCYCLETYPECODE", "BALINTERVAL",             
               "FINCYCLETYPECODE", "FININTERVAL", "FINTYPECODE",  "UNITEMAIL",                     
               "COMFEETAKECODE", "USETAG", "LINKMAN", "UNITADD", "UNITPHONE", "REMARK","PURPOSETYPE","BANKCHANNELCODE", 
               "REGIONCODE", "DELIVERYMODECODE", "APPCALLINGCODE"
           };


        //初始化佣金规则名称下拉列表

        TF_TRADE_COMSCHEMETDO ddoTF_TRADE_COMSCHEMEIn = new TF_TRADE_COMSCHEMETDO();
        TF_TRADE_COMSCHEMETDO[] ddoTF_TRADE_COMSCHEMEOutArr = (TF_TRADE_COMSCHEMETDO[])tmTMTableModule.selByPKArr(context, ddoTF_TRADE_COMSCHEMEIn, typeof(TF_TRADE_COMSCHEMETDO), "S008107212", "TF_TRADE_COMSCHEME_ALL_USEAGE", null);

        ControlDeal.SelectBoxFillWithCode(selScheme.Items, ddoTF_TRADE_COMSCHEMEOutArr, "NAME", "COMSCHEMENO", true);
    }



    public void lvwBalUnits_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwBalUnits.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
        ClearBalUnit();

    }


    protected void selCalling_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择查询的行业名称后,初始化单位名称,初始化结算单元名称


        selCorp.Items.Clear();
        selDepart.Items.Clear();
        selBalUint.Items.Clear();

        InitCorp(selCalling, selCorp, "TD_M_CORPCALLUSAGE");

        //初始化结算单元(属于选择行业)名称下拉列表值

        InitBalUnit("00", selCalling);

    }
    protected void selCorp_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择查询的单位名称后,初始化部门名称,初始化结算单元名称


        //选定单位后,设置部门下拉列表数据
        if (selCorp.SelectedValue == "")
        {
            selDepart.Items.Clear();
            InitBalUnit("00", selCalling);
            return;
        }

        //初始化单位下的部门信息

        InitDepart(selCorp, selDepart, "TD_M_DEPARTUSAGE");

        //初始化结算单元(属于选择单位)名称下拉列表值

        InitBalUnit("01", selCorp);


    }
    protected void selDepart_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择查询的部门名称后,初始化结算单元名称


        //选定单位后,设置部门下拉列表数据
        if (selDepart.SelectedValue == "")
        {
            InitBalUnit("01", selCorp);
            return;
        }

        //初始化结算单元(属于选择部门)名称下拉列表值

        InitBalUnit("02", selDepart);

    }


    protected void InitCorp(DropDownList origindwls, DropDownList extdwls, String sqlCondition)
    {
        // 从单位编码表(TD_M_CORP)中读取数据，放入增加,修改区域中单位信息下拉列表中

        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
        tdoTD_M_CORPIn.CALLINGNO = origindwls.SelectedValue;

        TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, sqlCondition, null);
        ControlDeal.SelectBoxFillWithCode(extdwls.Items, tdoTD_M_CORPOutArr, "CORP", "CORPNO", true);
    }

    private void InitBalUnit(string balType, DropDownList dwls)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_TRADE_BALUNITTDO tdoTF_TRADE_BALUNITIn = new TF_TRADE_BALUNITTDO();
        TF_TRADE_BALUNITTDO[] tdoTF_TRADE_BALUNITOutArr = null;

        //查询选定行业下的结算单元
        if (balType == "00")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_BYCALLING", null);
        }

        //查询选定单位下的结算单元
        else if (balType == "01")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = selCalling.SelectedValue;
            tdoTF_TRADE_BALUNITIn.CORPNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_BYCORP", null);
        }

        //查询选定部门下的结算单元
        else if (balType == "02")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = selCalling.SelectedValue;
            tdoTF_TRADE_BALUNITIn.CORPNO = selCorp.SelectedValue;
            tdoTF_TRADE_BALUNITIn.DEPARTNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_BYDEPART", null);
        }

        ControlDeal.SelectBoxFill(selBalUint.Items, tdoTF_TRADE_BALUNITOutArr, "BALUNIT", "BALUNITNO", true);
    }


    protected void btnQuery_Click(object sender, EventArgs e)
    {
        hidAprvState.Value = selAprvState.SelectedValue;

        //查询结算单元信息
        DataTable data = SPHelper.callPSQuery(context, "QueryBalUnit", selCalling.SelectedValue,
            selCorp.SelectedValue, selDepart.SelectedValue, selBalUint.SelectedValue,
            selAprvState.SelectedValue, selMsgQry.SelectedValue,context.s_DepartID);

        UserCardHelper.resetData(lvwBalUnits, data);

        ClearBalUnit();

        // InitCorpExt();
        // InitDepart();
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


        txtBalUnitNo.Text = getDataKeys("BALUNITNO");
        txtBalUnit.Text = getDataKeys("BALUNIT").Trim();
        selBalType.SelectedValue = getDataKeys("BALUNITTYPECODE").Trim();
        selSourceType.SelectedValue = getDataKeys("SOURCETYPECODE").Trim();

        try
        {
            selSerMgr.SelectedValue = GetSerMgrCode(getDataKeys("SERMANAGERCODE").Trim());
        }
        catch (Exception)
        {
            selSerMgr.SelectedValue = "";
        }

        try
        {
            //显示行业的名称

            selCallingExt.SelectedValue = getDataKeys("CALLINGNO").Trim();

            //初始行业下的单位名称
            InitCorp(selCallingExt, selCorpExt, "TD_M_CORPCALLUSAGE");
            selCorpExt.SelectedValue = GetCorpCode(getDataKeys("CORPNO").Trim());

            //初始单位下的部门名称
            InitDepart(selCorpExt, selDepartExt, "TD_M_DEPARTUSAGE");
            selDepartExt.SelectedValue = GetDepartCode(getDataKeys("DEPARTNO").Trim());

            //初始化单位对应的地区
            InitSelREGIONCODE();
            selRegionExt.SelectedValue = getDataKeys("REGIONCODE").Trim();

        }
        catch (Exception)
        {
            selCallingExt.SelectedValue = "";
            selCorpExt.SelectedValue = "";
            selDepartExt.SelectedValue = "";
        }

        try
        {
            //selFinBank.SelectedValue = getDataKeys("FINBANKCODE").Trim();
            //selBank.SelectedValue = getDataKeys("BANKCODE").Trim();
            getBank(selFinBank, getDataKeys("FINBANKCODE").Trim());
            getBank(selBank, getDataKeys("BANKCODE").Trim());
        }
        catch (Exception)
        {
            selFinBank.SelectedValue = "";
            selBank.SelectedValue = "";
        }

        //add by jiangbb 2012-05-18 收款人账户类型
        try
        {
            selPurPoseType.SelectedValue = getDataKeys("PURPOSETYPE").Trim();
        }
        catch (Exception)
        {
            selPurPoseType.SelectedValue = "";
        }

        try
        {
            selBankChannel.SelectedValue = getDataKeys("BANKCHANNELCODE").Trim();
        }
        catch(Exception)
        {
            selBankChannel.SelectedValue = "";
        }


        txtBankAccNo.Text = getDataKeys("BANKACCNO").Trim();
        selBalLevel.SelectedValue = getDataKeys("BALLEVEL").Trim();
        selBalCyclType.SelectedValue = getDataKeys("BALCYCLETYPECODE").Trim();
        txtBalInterval.Text = getDataKeys("BALINTERVAL").Trim();
        selFinCyclType.SelectedValue = getDataKeys("FINCYCLETYPECODE").Trim();
        txtFinInterval.Text = getDataKeys("FININTERVAL").Trim();
        selFinType.SelectedValue = getDataKeys("FINTYPECODE").Trim();
        selComFeeTake.SelectedValue = getDataKeys("COMFEETAKECODE").Trim();
        selUseTag.SelectedValue = getDataKeys("USETAG").Trim();
        txtLinkMan.Text = getDataKeys("LINKMAN").Trim();
        txtAddress.Text = getDataKeys("UNITADD").Trim();
        txtPhone.Text = getDataKeys("UNITPHONE").Trim();
        txtEmail.Text = getDataKeys("UNITEMAIL").Trim();
        txtRemark.Text = getDataKeys("REMARK").Trim();

        selScheme.SelectedValue = getDataKeys("COMSCHEMENO");
        txtBeginTime.Text = getDataKeys("BEGINTIME");
        txtEndTime.Text = getDataKeys("ENDTIME");
        hidSeqNo.Value = getDataKeys("TRADEID");

        selDeliveryModeExt.SelectedValue = getDataKeys("DELIVERYMODECODE").Trim();
        selAppCallingExt.SelectedValue = getDataKeys("APPCALLINGCODE").Trim();

        txtEndTime.Enabled = true;
        chkEndDate.Checked = false;
    }

    private string GetCorpCode(string strCorpCode)
    {
        TD_M_CORPTDO ddoTD_M_CORPIn = new TD_M_CORPTDO();
        ddoTD_M_CORPIn.CORPNO = strCorpCode;

        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_CORPTDO ddoTD_M_CORPOut = (TD_M_CORPTDO)tmTMTableModule.selByPK(context, ddoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, "TD_M_CORP_BYNO", null);

        if (ddoTD_M_CORPOut == null || ddoTD_M_CORPOut.USETAG == "0")
            return "";
        else
            return strCorpCode;

    }

    private string GetDepartCode(string strDepartCode)
    {
        TD_M_DEPARTTDO ddoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
        ddoTD_M_DEPARTIn.DEPARTNO = strDepartCode;

        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_DEPARTTDO ddoTD_M_DEPARTOut = (TD_M_DEPARTTDO)tmTMTableModule.selByPK(context, ddoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null, "TD_M_DEPART_BYNO", null);

        if (ddoTD_M_DEPARTOut == null || ddoTD_M_DEPARTOut.USETAG == "0")
            return "";
        else
            return strDepartCode;

    }


    private string GetSerMgrCode(string strSerMgrCode)
    {
        TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        ddoTD_M_INSIDESTAFFIn.STAFFNO = strSerMgrCode;

        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFOut = (TD_M_INSIDESTAFFTDO)tmTMTableModule.selByPK(context, ddoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_BY_STAFFNO", null);

        if (ddoTD_M_INSIDESTAFFOut == null || ddoTD_M_INSIDESTAFFOut.DIMISSIONTAG == "0")
            return "";
        else
            return strSerMgrCode;
    }


    public String getDataKeys(string keysname)
    {
        string value = lvwBalUnits.DataKeys[lvwBalUnits.SelectedIndex][keysname].ToString();

        return value == "" ? "" : value;
    }



    protected void selCallingExt_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择增加,查询区域的行业名称后,查询对应的单位信息

        selDepartExt.Items.Clear();
        selCorpExt.Items.Clear();
        selRegionExt.Items.Clear();

        if (selCallingExt.SelectedValue != "")
            InitCorp(selCallingExt, selCorpExt, "TD_M_CORPCALLUSAGE");

        getNextBalUnitNo();
    }

    protected void selCorpExt_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择增加,查询区域的单位名称后,查询对应的部门信息


        if (selCorpExt.SelectedValue == "")
        {
            selDepartExt.Items.Clear();
            return;
        }
        InitDepart(selCorpExt, selDepartExt, "TD_M_DEPART");

        InitSelREGIONCODE();
    }

    protected void selRegionExt_SelectedIndexChanged(object sender, EventArgs e)
    {
        getNextBalUnitNo();
    }

    protected void selDeliveryModeExt_SelectedIndexChanged(object sender, EventArgs e)
    {
        getNextBalUnitNo();
    }

    protected void selAppCallingExt_changed(object sender, EventArgs e)
    {
        getNextBalUnitNo();
    }


    private void InitDepart(DropDownList origindwls, DropDownList extdwls, String sqlCondition)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //从部门编码表(TD_M_CDEPART)中读取数据，放入下拉列表中


        TD_M_DEPARTTDO tdoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
        tdoTD_M_DEPARTIn.CORPNO = origindwls.SelectedValue;

        TD_M_DEPARTTDO[] tdoTD_M_DEPARTOutArr = (TD_M_DEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null, sqlCondition, null);
        ControlDeal.SelectBoxFillWithCode(extdwls.Items, tdoTD_M_DEPARTOutArr, "DEPART", "DEPARTNO", true);
    }

    private void ClearBalUnit()
    {
        lvwBalUnits.SelectedIndex = -1;
        //getNextBalUnitNo();
        txtBalUnit.Text = "";
        selBalType.SelectedValue = "";
        selSourceType.SelectedValue = "";
        selSerMgr.SelectedValue = "";

        selCallingExt.SelectedValue = "";
        selCorpExt.SelectedValue = "";
        selDepartExt.SelectedValue = "";
        selFinBank.SelectedValue = "";
        selBank.SelectedValue = "";
        txtBankAccNo.Text = "";

        selBalLevel.SelectedValue = "";
        selBalCyclType.SelectedValue = "";
        txtBalInterval.Text = "";
        selFinCyclType.SelectedValue = "";
        txtFinInterval.Text = "";
        selFinType.SelectedValue = "";
        selComFeeTake.SelectedValue = "";
        selUseTag.SelectedValue = "";

        //add by jiangbb 2012-05-18 收款人账户类型
        selPurPoseType.SelectedValue = "";

        txtLinkMan.Text = "";
        txtAddress.Text = "";
        txtPhone.Text = "";
        txtRemark.Text = "";
        txtEmail.Text = "";

        selScheme.SelectedValue = "";
        txtBeginTime.Text = "";

        txtEndTime.Enabled = true;
        txtEndTime.Text = "";

        chkEndDate.Checked = false;

        selRegionExt.SelectedValue = "";
        selDeliveryModeExt.SelectedValue = "";
        selAppCallingExt.SelectedValue = "";

        txtBalUnitNo.Text = "";

    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        //调用增加的判断处理
        if (!BalUnitAddValidation()) return;

        if (BalUnitNoChk()) return;

        //检测佣金终止时间是否大于当前时间

        if (CompareEndTimeAndNow()) return;

        //调用增加的存储过程

        SP_PS_TransferChangeAddPDO pdo = new SP_PS_TransferChangeAddPDO();
        pdo.balUnitNo = txtBalUnitNo.Text.Trim();
        pdo.balUnit = txtBalUnit.Text.Trim();
        pdo.balUnitTypeCode = selBalType.SelectedValue.Trim();
        pdo.sourceTypeCode = selSourceType.SelectedValue.Trim();
        pdo.callingNo = selCallingExt.SelectedValue.Trim();
        pdo.corpNo = selCorpExt.SelectedValue.Trim();
        pdo.departNo = selDepartExt.SelectedValue.Trim();
        pdo.bankCode = selBank.SelectedValue.Trim();
        pdo.bankAccno = txtBankAccNo.Text.Trim();
        pdo.serManagerCode = selSerMgr.SelectedValue.Trim();
        pdo.balLevel = selBalLevel.SelectedValue.Trim();
        pdo.balCycleTypeCode = selBalCyclType.SelectedValue.Trim();
        pdo.balInterval = Convert.ToInt32(txtBalInterval.Text.Trim());
        pdo.finCycleTypeCode = selFinCyclType.SelectedValue.Trim();
        pdo.finInterval = Convert.ToInt32(txtFinInterval.Text.Trim());
        pdo.finTypeCode = selFinType.SelectedValue.Trim();
        pdo.comFeeTakeCode = selComFeeTake.SelectedValue.Trim();
        pdo.finBankCode = selFinBank.SelectedValue.Trim();
        pdo.linkMan = txtLinkMan.Text.Trim();
        pdo.unitPhone = txtPhone.Text.Trim();
        pdo.unitAdd = txtAddress.Text.Trim();
        pdo.remark = txtRemark.Text.Trim();

        pdo.uintEmail = txtEmail.Text.Trim();
        pdo.comSchemeNo = selScheme.SelectedValue.Trim();
        pdo.beginTime = txtBeginTime.Text.Trim() + "-01 00:00:00";

        pdo.endTime = GetEndTime();

        //add by jiangbb 收款人账户类型
        pdo.purposeType = selPurPoseType.SelectedValue.Trim();

        pdo.bankChannel = selBankChannel.SelectedValue.Trim();

        pdo.RegionCode = selRegionExt.SelectedValue.Trim();
        pdo.DeliveryModeCode = selDeliveryModeExt.SelectedValue.Trim();
        pdo.AppCallingCode = selAppCallingExt.SelectedValue.Trim();

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M008107113");
            //ClearBalUnit();
            btnQuery_Click(sender, e);
        }
    }

    protected void btnModify_Click(object sender, EventArgs e)
    {
        //调用修改的判断处理
        Boolean keyInfoChanged;
        if (!BalUnitModifyValidation(out keyInfoChanged)) return;

        //调用修改的存储过程
        SP_PS_TransferChangeModifyPDO pdo = new SP_PS_TransferChangeModifyPDO();

        pdo.balUnitNo = getDataKeys("BALUNITNO").Trim();
        pdo.balUnit = txtBalUnit.Text.Trim();
        pdo.balUnitTypeCode = selBalType.SelectedValue.Trim();
        pdo.sourceTypeCode = selSourceType.SelectedValue.Trim();
        pdo.callingNo = selCallingExt.SelectedValue.Trim();
        pdo.corpNo = selCorpExt.SelectedValue.Trim();
        pdo.departNo = selDepartExt.SelectedValue.Trim();
        pdo.bankCode = selBank.SelectedValue.Trim();
        pdo.bankAccno = txtBankAccNo.Text.Trim();
        pdo.serManagerCode = selSerMgr.SelectedValue.Trim();
        pdo.balLevel = selBalLevel.SelectedValue.Trim();
        pdo.balCycleTypeCode = selBalCyclType.SelectedValue.Trim();
        pdo.balInterval = Convert.ToInt32(txtBalInterval.Text.Trim());
        pdo.finCycleTypeCode = selFinCyclType.SelectedValue.Trim();
        pdo.finInterval = Convert.ToInt32(txtFinInterval.Text.Trim());
        pdo.finTypeCode = selFinType.SelectedValue.Trim();
        pdo.comFeeTakeCode = selComFeeTake.SelectedValue.Trim();
        pdo.finBankCode = selFinBank.SelectedValue.Trim();
        pdo.linkMan = txtLinkMan.Text.Trim();
        pdo.unitPhone = txtPhone.Text.Trim();
        pdo.unitAdd = txtAddress.Text.Trim();
        pdo.remark = txtRemark.Text.Trim();
        pdo.unitEmail = txtEmail.Text.Trim();
        pdo.useTag = selUseTag.SelectedValue.Trim();

        pdo.aprvState = selAprvState.SelectedValue;
        pdo.seqNo = hidSeqNo.Value;

        pdo.comSchemeNo = selScheme.SelectedValue;

        pdo.beginTime = (txtBeginTime.Text == "" ? "2050-12" : txtBeginTime.Text) + "-01 00:00:00";
        pdo.endTime = GetEndTime();
        pdo.keyInfoChanged = keyInfoChanged ? "Y" : "N";

        //add by jiangbb 收款人账户类型
        pdo.purposeType = selPurPoseType.SelectedValue.Trim();
        pdo.bankChannel = selBankChannel.SelectedValue.Trim();

        pdo.RegionCode = selRegionExt.SelectedValue.Trim();
        pdo.DeliveryModeCode = selDeliveryModeExt.SelectedValue.Trim();
        pdo.AppCallingCode = selAppCallingExt.SelectedValue.Trim();

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M008107111");
            //ClearBalUnit();
            btnQuery_Click(sender, e);
        }
    }

    private Boolean BalUnitAddValidation()
    {
        //调用结算单元输入判断
        BalUnitInputValidation();

        //新增时操作员工所属区域与结算单元区域保持一致
        RegionAddValidation();
        //if (selRegionExt.SelectedValue != context.s_RegionCode)
        //{
        //    context.AddError("A008107111", selUseTag);
        //}

        //对有效是否为有效的判断
        string strUseTag = selUseTag.SelectedValue;
        if (strUseTag == "0")
        {
            context.AddError("A008107041", selUseTag);
        }

        //判断佣金规则名称是否为空
        string strScheme = selScheme.SelectedValue;
        if (strScheme == "")
        {
            context.AddError("A008107034", selScheme);
        }

        //佣金起始终止日期有效性检查
        CheckSchemeDate(true);

        return !(context.hasError());
    }

    private Boolean RegionAddValidation()
    {
        string regionName = "";

        regionName = GetRegionNameByCode(context.s_RegionCode);

        if (!HasOperPower("201307"))
        {
            if (selRegionExt.SelectedItem.Text.Split(':')[1] != regionName)
            {
                context.AddError("A008107111", selRegionExt);
                return false;
            }
        }

        return true;
    }

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
        if (selUseTag.SelectedValue == "0" && getDataKeys("USETAG").Trim() == "0")
        {
            //无效的结算单元,没有修改为有效时,不能提交修改
            context.AddError("A008107079", selUseTag);
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
        if (txtBalUnitNo.Text.Trim() != getDataKeys("BALUNITNO"))
        {
            context.AddError("A008107108", txtBalUnitNo);
            return false;
        }

        if (!HasOperPower("201307"))
        {
            if (!string.IsNullOrEmpty(getDataKeys("REGIONCODE").Trim()))
            {
                if (GetRegionNameByCode(context.s_RegionCode) != GetRegionNameByCode(getDataKeys("REGIONCODE").Trim()))
                {
                    context.AddError("A008107113", txtBalUnitNo);
                    return false;
                }
            }
            else
            {
                if (GetRegionNameByCode(context.s_RegionCode) != GETUpdateStaffRegionName(getDataKeys("BALUNITNO")))
                {
                    context.AddError("A008107112", txtBalUnitNo);
                    return false;
                }
            }
        }

        //佣金起始终止日期有效性检查

        CheckSchemeDate(false);

        //当选定的结算单元名称修改后,检测库中是否已存在该结算单元

        //if (txtBalUnit.Text.Trim() != getDataKeys("BALUNIT"))
        //{
        //    return BalUnitNameChk();
        //}

        return true;
    }

    private Boolean BalUnitNameChk()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从结算单元编码表(TD_TRADE_BALUNIT)中读取数据


        TF_TRADE_BALUNITTDO ddoTF_TRADE_BALUNITIn = new TF_TRADE_BALUNITTDO();
        ddoTF_TRADE_BALUNITIn.BALUNIT = txtBalUnit.Text.Trim();
        TF_TRADE_BALUNITTDO[] ddoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, ddoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNIT_BY_NAME", null);

        //从合作伙伴审批台帐中读取数据
        TF_B_TRADE_BALUNITCHANGETDO ddoTF_B_TRADE_BALUNITCHANGEIn = new TF_B_TRADE_BALUNITCHANGETDO();
        ddoTF_B_TRADE_BALUNITCHANGEIn.BALUNIT = txtBalUnit.Text.Trim();
        TF_B_TRADE_BALUNITCHANGETDO[] ddoTF_B_TRADE_BALUNITCHANGEOutArr = (TF_B_TRADE_BALUNITCHANGETDO[])tmTMTableModule.selByPKArr(context, ddoTF_B_TRADE_BALUNITCHANGEIn, typeof(TF_B_TRADE_BALUNITCHANGETDO), null, "TF_B_TRADE_BALUNITCHANGE_BY_NAME", null);


        //从合作伙伴审核台帐中读取数据
        TF_B_TRADE_BALUNITCHANGETDO ddoTF_B_TRADE_BALUNITCHANGEInExt = new TF_B_TRADE_BALUNITCHANGETDO();
        ddoTF_B_TRADE_BALUNITCHANGEInExt.BALUNIT = txtBalUnit.Text.Trim();
        TF_B_TRADE_BALUNITCHANGETDO[] ddoTF_B_TRADE_BALUNITCHANGEOutArrExt = (TF_B_TRADE_BALUNITCHANGETDO[])tmTMTableModule.selByPKArr(context, ddoTF_B_TRADE_BALUNITCHANGEInExt, typeof(TF_B_TRADE_BALUNITCHANGETDO), null, "TF_B_TRADE_BALUNIT_EXAM", null);

        if (ddoTF_TRADE_BALUNITOutArr.Length != 0 ||
            ddoTF_B_TRADE_BALUNITCHANGEOutArr.Length != 0 ||
            ddoTF_B_TRADE_BALUNITCHANGEOutArrExt.Length != 0)
        {
            context.AddError("A008107063", txtBalUnit);
            return false;
        }

        return true;
    }

    private Boolean BalUnitNoChk()
    {
        //是否该结算单元编码已存在
        TMTableModule tmTMTableModule = new TMTableModule();

        //从结算单元编码表(TD_TRADE_BALUNIT)中读取数据


        TF_TRADE_BALUNITTDO ddoTF_TRADE_BALUNITIn = new TF_TRADE_BALUNITTDO();
        ddoTF_TRADE_BALUNITIn.BALUNITNO = txtBalUnitNo.Text.Trim();
        TF_TRADE_BALUNITTDO[] ddoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, ddoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNIT_BY_BALNO", null);

        //从合作伙伴审批台帐中待审批读取数据

        TF_B_TRADE_BALUNITCHANGETDO ddoTF_B_TRADE_BALUNITCHANGEIn = new TF_B_TRADE_BALUNITCHANGETDO();
        ddoTF_B_TRADE_BALUNITCHANGEIn.BALUNITNO = txtBalUnitNo.Text.Trim();
        TF_B_TRADE_BALUNITCHANGETDO[] ddoTF_B_TRADE_BALUNITCHANGEOutArr = (TF_B_TRADE_BALUNITCHANGETDO[])tmTMTableModule.selByPKArr(context, ddoTF_B_TRADE_BALUNITCHANGEIn, typeof(TF_B_TRADE_BALUNITCHANGETDO), null, "TF_B_TRADE_BALUNITCHANGE_BY_BALNO", null);


        //从合作伙伴审核台帐中待审核读取数据

        TF_B_TRADE_BALUNITCHANGETDO ddoTF_B_TRADE_BALUNITCHANGEInExt = new TF_B_TRADE_BALUNITCHANGETDO();
        ddoTF_B_TRADE_BALUNITCHANGEInExt.BALUNITNO = txtBalUnitNo.Text.Trim();
        TF_B_TRADE_BALUNITCHANGETDO[] ddoTF_B_TRADE_BALUNITCHANGEOutArrExt = (TF_B_TRADE_BALUNITCHANGETDO[])tmTMTableModule.selByPKArr(context, ddoTF_B_TRADE_BALUNITCHANGEInExt, typeof(TF_B_TRADE_BALUNITCHANGETDO), null, "TF_B_TRADE_BALUNIT_EXAM_BY_BALNO", null);

        if (ddoTF_TRADE_BALUNITOutArr.Length != 0 ||
            ddoTF_B_TRADE_BALUNITCHANGEOutArr.Length != 0 ||
            ddoTF_B_TRADE_BALUNITCHANGEOutArrExt.Length != 0)
        {
            context.AddError("A008107109", txtBalUnitNo);
        }

        //检查结算单元名称是否已存在
        //BalUnitNameChk();

        return context.hasError();

    }

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

        else if (Validation.strLen(strBalUnit) > 100)
        {
            context.AddError("A008107006", txtBalUnit);
        }

        //对单元类型的判断
        string strCalling = selCallingExt.SelectedValue;
        string strCorp = selCorpExt.SelectedValue;
        string strDepart = selDepartExt.SelectedValue;

        string strBalUnitType = selBalType.SelectedValue;
        if (strBalUnitType == "")
        {
            context.AddError("A008107047", selBalType);
        }
        else if (strBalUnitType == "00")
        {
            //判断行业名称是否为空
            if (strCalling == "")
                context.AddError("A008107031", selCallingExt);
        }
        else if (strBalUnitType == "01")
        {
            //判断行业名称是否为空 //判断单位名称是否为空
            if (strCalling == "")
                context.AddError("A008107031", selCallingExt);
            if (strCorp == "")
                context.AddError("A008107032", selCorpExt);
        }
        else if (strBalUnitType == "02")
        {
            //判断行业名称是否为空 //判断单位名称是否为空 //判断部门名称是否为空
            if (strCalling == "")
                context.AddError("A008107031", selCallingExt);
            if (strCorp == "")
                context.AddError("A008107032", selCorpExt);
            if (strDepart == "")
                context.AddError("A008107033", selDepartExt);

        }

        else if (strBalUnitType == "03")
        {
            context.AddError("A008107048", selBalType);
        }


        //对来源识别类型的判断
        string strSrcType = selSourceType.SelectedValue;
        if (strSrcType == "")
            context.AddError("A008107049", selSourceType);

        else if (strSrcType == "01")
        {
            //来源识别为信息亭时, 单元类型必须是部门

            if (strBalUnitType != "02")
                context.AddError("A008107054", selBalType);
        }

        else if (strSrcType == "02")
        {
            //来源识别类型为出租车司机工号时,不在此维护

            context.AddError("A008107050", selSourceType);
        }

        //对商户经理的判断
        if (selSerMgr.SelectedValue == "")
        {
            context.AddError("A008107053", selSerMgr);
        }


        //对出租行业的判断
        if (selBalType.SelectedValue != "04")
        {
            if (strCalling == "02")
                context.AddError("A008107046", selCallingExt);
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
            // context.AddError("A008107008", txtBankAccNo);
            if (Validation.strLen(strBankAccNo) > 30)
            {
                context.AddError("A008107010", txtBankAccNo);
            }
        }

        //else if (!Validation.isNum(strBankAccNo))
        //{
        //    context.AddError("A008107042", txtBankAccNo);
        //}

        //对结算级别非空的检测

        string strBalLevle = selBalLevel.SelectedValue;
        if (strBalLevle == "")
        {
            context.AddError("A008107011", selBalLevel);
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
        else if (!isInteger(strBalInterval))
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
        else if (!isInteger(strFinInterval))
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

        //对佣金扣减方式非空的检测

        string strComFeeTake = selComFeeTake.SelectedValue;
        if (strComFeeTake == "")
        {
            context.AddError("A008107019", selComFeeTake);
        }


        //对有效标志进行非空检验

        String strUseTag = selUseTag.SelectedValue;
        if (strUseTag == "")
            context.AddError("A008100014", selUseTag);

        //对收款人账户类型进行非空检验 add by jiangbb 2012-05-18 
        if (selPurPoseType.SelectedValue == "")
        {
            context.AddError("A008100020", selPurPoseType);
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
            if (Validation.strLen(strRemrk) > 100)
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

        //对结算单元编码的校验
        if ((strBalUnitNo.Length == 8) && strCalling != "")
        {
            if (strBalUnitNo.Substring(0, 2) != strCalling)
                context.AddError("A008107077", txtBalUnitNo);
        }

        //对地区编码进行非空校验
        if (selRegionExt.SelectedValue == "")
            context.AddError("A008113014", selRegionExt);

        //对POS投放模式进行非空校验
        if (selDeliveryModeExt.SelectedValue == "")
            context.AddError("A008113024", selDeliveryModeExt);

        //对应用行业进行非空校验
        if (selAppCallingExt.SelectedValue == "")
            context.AddError("A008113034", selAppCallingExt);

        //对context的error检测 
        if (context.hasError())
            return false;
        else
            return true;
    }

    // 判断是否需要审批（如果只修改了联系人，联系电话，联系地址，电子邮件,应用行业时，不需要审批）
    private bool isKeyInfoChanged()
    {
        return
            txtBalUnitNo.Text.Trim() != getDataKeys("BALUNITNO").Trim() ||
            txtBalUnit.Text.Trim() != getDataKeys("BALUNIT").Trim() ||
            selBalType.SelectedValue != getDataKeys("BALUNITTYPECODE").Trim() ||
            selSourceType.SelectedValue != getDataKeys("SOURCETYPECODE").Trim() ||
            selSerMgr.SelectedValue != getDataKeys("SERMANAGERCODE").Trim() ||

            selCallingExt.SelectedValue != getDataKeys("CALLINGNO").Trim() ||
            selCorpExt.SelectedValue != getDataKeys("CORPNO").Trim() ||
            selDepartExt.SelectedValue != getDataKeys("DEPARTNO").Trim() ||
            selFinBank.SelectedValue != getDataKeys("FINBANKCODE").Trim() ||
            selBank.SelectedValue != getDataKeys("BANKCODE").Trim() ||
            txtBankAccNo.Text.Trim() != getDataKeys("BANKACCNO").Trim() ||

            selBalLevel.SelectedValue != getDataKeys("BALLEVEL").Trim() ||
            selBalCyclType.SelectedValue != getDataKeys("BALCYCLETYPECODE").Trim() ||
            txtBalInterval.Text.Trim() != getDataKeys("BALINTERVAL").Trim() ||
            selFinCyclType.SelectedValue != getDataKeys("FINCYCLETYPECODE").Trim() ||
            txtFinInterval.Text.Trim() != getDataKeys("FININTERVAL").Trim() ||
            selFinType.SelectedValue != getDataKeys("FINTYPECODE").Trim() ||
            selComFeeTake.SelectedValue != getDataKeys("COMFEETAKECODE").Trim() ||
            selUseTag.SelectedValue != getDataKeys("USETAG").Trim() ||

            selPurPoseType.SelectedValue != getDataKeys("PURPOSETYPE").Trim() || //add by jiangbb 收款人账户类型
            selBankChannel.SelectedValue != getDataKeys("BANKCHANNELCODE").Trim() ||
            selRegionExt.SelectedValue != getDataKeys("REGIONCODE").Trim() ||
            selDeliveryModeExt.SelectedValue != getDataKeys("DELIVERYMODECODE").Trim();
    }

    private bool isTrivialInfoChanged()
    {
        return
            txtLinkMan.Text.Trim() != getDataKeys("LINKMAN").Trim() ||
            txtAddress.Text.Trim() != getDataKeys("UNITADD").Trim() ||
            txtPhone.Text.Trim() != getDataKeys("UNITPHONE").Trim() ||
            txtEmail.Text.Trim() != getDataKeys("UNITEMAIL").Trim() ||
            txtRemark.Text.Trim() != getDataKeys("REMARK").Trim() ||
            selAppCallingExt.SelectedValue != getDataKeys("APPCALLINGCODE").Trim();
    }

    protected void chkEndDate_CheckedChanged(object sender, EventArgs e)
    {
        //选择无效期后佣金规则的终止日期为2050-12
        if (chkEndDate.Checked)
        {
            txtEndTime.Enabled = false;
            txtEndTime.Text = "2050-12";
        }
        else
        {
            txtEndTime.Enabled = true;
            txtEndTime.Text = "";
        }
    }

    private void CheckSchemeDate(bool required)
    {
        //佣金起始日期有效性检查

        txtBeginTime.Text = txtBeginTime.Text.Trim();
        string strBeginTime = txtBeginTime.Text;
        DateTime? beginTime = null;

        if (strBeginTime == "" && !required)
        {
            strBeginTime = "2050-12";
        }

        if (strBeginTime == "")
        {
            context.AddError("A008104008", txtBeginTime);
        }

        else if (!Validation.isDate(strBeginTime, "yyyy-MM"))
        {
            context.AddError("A008104035", txtBeginTime);
        }
        else
        {
            beginTime = DateTime.ParseExact(strBeginTime, "yyyy-MM", null);
        }

        //检查是否选择了无效期
        txtEndTime.Text = txtEndTime.Text.Trim();
        string strEndTime = txtEndTime.Text;
        if (strEndTime == "" && !required)
        {
            strEndTime = "2050-12";
        }

        if (!chkEndDate.Checked)
        {
            if (strEndTime == "")
            {
                context.AddError("A008104009", txtEndTime);
            }
            else if (!Validation.isDate(strEndTime, "yyyy-MM"))
            {
                context.AddError("A008104036", txtEndTime);
            }
            else if (beginTime != null)
            {
                CompareSchemeDate(strBeginTime, strEndTime, txtEndTime);
            }
        }

        if (chkEndDate.Checked && beginTime != null)
        {
            CompareSchemeDate(strBeginTime, "2050-12", txtBeginTime);
        }
    }


    private void CompareSchemeDate(string datest, string dateend, TextBox txtBox)
    {
        DateTime begin = DateTime.ParseExact(datest, "yyyy-MM", null);
        DateTime end = DateTime.ParseExact(dateend, "yyyy-MM", null);

        if (DateTime.Compare(begin, end) > 0)
        {
            context.AddError("A008104037", txtBox);
        }

    }

    private string GetEndTime()
    {
        string endtime = txtEndTime.Text;
        if (chkEndDate.Checked)
        {
            endtime = "2050-12-31 23:59:59";
        }
        else
        {
            if (endtime == "") endtime = "2050-12";
            DateTime end = DateTime.ParseExact(endtime, "yyyy-MM", null);
            DateTime enddate = end.AddMonths(1).AddDays(-1);

            endtime = enddate.ToString("yyyy-MM-dd") + " 23:59:59";
        }

        return endtime;
    }


    private Boolean isInteger(string strInput)
    {
        System.Text.RegularExpressions.Regex reg1
                          = new System.Text.RegularExpressions.Regex(@"^[1-9][0-9]*$");

        return reg1.IsMatch(strInput);


    }


    private Boolean CompareEndTimeAndNow()
    {
        string strEndTime = GetEndTime().Replace("-", "").Replace(":", "");

        DateTime end = DateTime.ParseExact(strEndTime, "yyyyMMdd HHmmss", null);
        DateTime nowd = DateTime.Now;

        if (DateTime.Compare(nowd, end) > 0)
        {
            context.AddError("A008107125", txtEndTime);
            return true;
        }
        return false;
    }

    //初始化地区编码下拉列表值
    private void InitSelREGIONCODE()
    {
        selRegionExt.Items.Clear();

        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_REGIONCODETDO ddoTD_M_REGIONCODEIn = new TD_M_REGIONCODETDO();
        string strSql = "SELECT REGIONNAME,REGIONCODE  FROM TD_M_REGIONCODE WHERE REGIONCODE IN ";
        strSql += " (SELECT REGIONCODE FROM TD_M_CORP WHERE CORPNO = '" + selCorpExt.SelectedValue + "') And ISUSETAG = '1'";
        DataTable table = tmTMTableModule.selByPKDataTable(context, ddoTD_M_REGIONCODEIn, null, strSql, 0);

        if (table != null && table.Rows.Count > 0)
        {            
            GroupCardHelper.fill(selRegionExt, table, true);
        }
    }

    //初始化POS投放模式编码下拉列表值
    private void InitSelDELIVERYMODE()
    {
        selDeliveryModeExt.Items.Clear();

        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_DELIVERYMODECODETDO ddlTD_M_DELIVERYMODECODEIn = new TD_M_DELIVERYMODECODETDO();
        TD_M_DELIVERYMODECODETDO[] ddoTD_M_DELIVERYMODECODEOutArr = (TD_M_DELIVERYMODECODETDO[])tmTMTableModule.selByPKArr(context, ddlTD_M_DELIVERYMODECODEIn, typeof(TD_M_DELIVERYMODECODETDO), "S008113023", "TD_M_DELIVERYMODEUSETAG", null);

        ControlDeal.SelectBoxFill(selDeliveryModeExt.Items, ddoTD_M_DELIVERYMODECODEOutArr, "DELIVERYMODE", "DELIVERYMODECODE", true);
    }

    //初始化应用行业编码下拉列表值
    private void InitSelAPPCALLINGCODE()
    {
        selAppCallingExt.Items.Clear();

        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_APPCALLINGCODETDO ddlTD_M_APPCALLINGCODEIn = new TD_M_APPCALLINGCODETDO();
        TD_M_APPCALLINGCODETDO[] ddoTD_M_APPCALLINGCODEOutArr = (TD_M_APPCALLINGCODETDO[])tmTMTableModule.selByPKArr(context, ddlTD_M_APPCALLINGCODEIn, typeof(TD_M_APPCALLINGCODETDO), "S008113033", "TD_M_APPCALLINGUSETAG", null);

        ControlDeal.SelectBoxFill(selAppCallingExt.Items, ddoTD_M_APPCALLINGCODEOutArr, "APPCALLING", "APPCALLINGCODE", true);
    }

    private string GETUpdateStaffRegionName(string balunitno)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_INSIDEDEPARTTDO ddoIn = new TD_M_INSIDEDEPARTTDO();
        ddoIn.DEPARTNO = GetUpdateDeptNo(balunitno);

        TD_M_INSIDEDEPARTTDO ddoOut = (TD_M_INSIDEDEPARTTDO)tmTMTableModule.selByPK(context, ddoIn, typeof(TD_M_INSIDEDEPARTTDO), null, "TD_M_INSIDEDEPARTNO", null);

        if (ddoOut != null)
        {
            return GetRegionNameByCode(ddoOut.REGIONCODE);
        }
        else
        {
            return "";
        }
    }


    private string GetUpdateDeptNo(string balunitno)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        TF_B_ASSOCIATETRADETDO ddoIn = new TF_B_ASSOCIATETRADETDO();
        ddoIn.ASSOCIATECODE = balunitno;

        TF_B_ASSOCIATETRADETDO ddoOut = (TF_B_ASSOCIATETRADETDO)tmTMTableModule.selByPK(context, ddoIn, typeof(TF_B_ASSOCIATETRADETDO), null, "TF_B_ASSOCIATETRADE_CODE", null);

        if (ddoOut != null)
        {
            return ddoOut.OPERATEDEPARTID;
        }
        else
        {
            return "";
        }
    }

    private string GetRegionNameByCode(string regionCode)
    {
        string regionName = "";
        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_REGIONCODETDO ddoTD_M_REGIONCODEIn = new TD_M_REGIONCODETDO();
        ddoTD_M_REGIONCODEIn.REGIONCODE = regionCode;

        TD_M_REGIONCODETDO ddoTD_M_REGIONCODEOut = (TD_M_REGIONCODETDO)tmTMTableModule.selByPK(context, ddoTD_M_REGIONCODEIn, typeof(TD_M_REGIONCODETDO), null, "TD_M_REGIONCODE", null);

        if (ddoTD_M_REGIONCODEOut != null)
        {
            regionName = ddoTD_M_REGIONCODEOut.REGIONNAME;
        }

        return regionName;
    }

    private bool HasOperPower(string powerCode)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
        string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
        DataTable dataSupply = tmTMTableModule.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
        if (dataSupply.Rows.Count > 0)
            return true;
        else
            return false;
    }

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
