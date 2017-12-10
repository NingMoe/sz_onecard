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
using TM;
using TDO.PartnerShip;
using TDO.BalanceChannel;
using TDO.UserManager;
using PDO.PartnerShip;
using TDO.BalanceParameter;
using Common;


public partial class ASP_PartnerShip_PS_TransferApproval : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            //指定GridView DataKeyNames
            lvwBalUnitsAppral.DataKeyNames =
                new string[]{"BALUNITNO","BALUNIT","BALUNITTYPE","SOURCETYPE","CALLINGNAME","CORPNAME",  
               "DEPARTNAME","BANKNAME","BANKACCNO","CREATETIME","BALLEVEL", "BALCYCLETYPE", "BALINTERVAL",
               "FINCYCLETYPE","FININTERVAL", "FINTYPE", "COMFEETAKE", "FINBANK", "SERMANAGER","UNITEMAIL","BIZTYPE",
               "LINKMAN","UNITPHONE","UNITADD", "REMARK","OPERATESTAFF","TRADEID","TRADETYPECODE","PURPOSE","BankChannel",
               "REGIONNAME","DELIVERYMODE","APPCALLING"};

            //查询待审批的结算单元信息
            InitBalUnitApral();

            //初始通道名称下拉列表框


            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_CHANNELTDO ddoTD_M_CHANNELIn = new TD_M_CHANNELTDO();
            TD_M_CHANNELTDO[] ddoTD_M_CHANNELOutArr = (TD_M_CHANNELTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_CHANNELIn, typeof(TD_M_CHANNELTDO), null, "TD_M_CHANNEL_USEFUL", null);

            ControlDeal.SelectBoxFillWithCode(selChannel.Items, ddoTD_M_CHANNELOutArr, "CHANNELNAME", "CHANNELNO", true);


            //设置当前处理佣金规则信息列表表头
            lvwBalComScheme.DataSource = new DataTable();
            lvwBalComScheme.DataBind();
            //lvwBalComScheme.SelectedIndex = -1;


            //设置已存在佣金规则信息列表表头

            lvwExistedComScheme.DataSource = new DataTable();
            lvwExistedComScheme.DataBind();
        }
    }


    public void lvwBalUnitsAppral_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwBalUnitsAppral.PageIndex = e.NewPageIndex;
        InitBalUnitApral();
        ClearBalUnit();

    }


    private void InitBalUnitApral()
    {
        lvwBalUnitsAppral.DataSource = CreateBalUnitAppDataSource();
        lvwBalUnitsAppral.DataBind();
        lvwBalUnitsAppral.SelectedIndex = -1;
    }


    public ICollection CreateBalUnitAppDataSource()
    {
        //查询待审批的结算单元信息

        //查询行业单位部门信息
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_CALLINGNOTDO ddoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
        DataTable dataCalling = tmTMTableModule.selByPKDataTable(context, ddoTD_M_CALLINGNOIn, null, "TD_M_CALLINGNO", null, 0);

        TD_M_CORPTDO ddoTD_M_CORPIn = new TD_M_CORPTDO();
        DataTable dataCorp = tmTMTableModule.selByPKDataTable(context, ddoTD_M_CORPIn, null, "TD_M_CORPUSAGE", null, 0);

        TD_M_DEPARTTDO ddoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
        DataTable dataDepart = tmTMTableModule.selByPKDataTable(context, ddoTD_M_DEPARTIn, null, "TD_M_DEPARTALLUSAGE", null, 0);


        //查询银行信息
        TD_M_BANKTDO ddoTD_M_BANKIn = new TD_M_BANKTDO();
        DataTable dataBank = tmTMTableModule.selByPKDataTable(context, ddoTD_M_BANKIn, null, "", null, 0);

        //商户经理和操作员工信息

        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        DataTable dataStuff = tmTMTableModule.selByPKDataTable(context, tdoTD_M_INSIDESTAFFIn, null, "", null, 0);

        //地区信息
        TD_M_REGIONCODETDO tdoTD_M_REGIONCODEIn = new TD_M_REGIONCODETDO();
        DataTable dataRegion = tmTMTableModule.selByPKDataTable(context, tdoTD_M_REGIONCODEIn, null, "TD_M_REGIONUSETAG", null, 0);
       
        //POS投放模式信息
        TD_M_DELIVERYMODECODETDO tdoTD_M_DELIVERYMODECODEIn = new TD_M_DELIVERYMODECODETDO();
        DataTable dataDeliveryMode = tmTMTableModule.selByPKDataTable(context, tdoTD_M_DELIVERYMODECODEIn, null, "TD_M_DELIVERYMODEUSETAG", null, 0);

        //应用行业信息
        TD_M_APPCALLINGCODETDO tdoTD_M_APPCALLINGCODEIn = new TD_M_APPCALLINGCODETDO();
        DataTable dataAppCalling = tmTMTableModule.selByPKDataTable(context, tdoTD_M_APPCALLINGCODEIn, null, "TD_M_APPCALLINGUSETAG", null, 0);

        TF_B_TRADE_BALUNITCHANGETDO ddoTF_B_TRADE_BALUNITCHANGEIn = new TF_B_TRADE_BALUNITCHANGETDO();
        string strSql = "SELECT ass.TRADETYPECODE, (case when( ass.TRADETYPECODE = '61' ) then '增加-结算单元' " +
                        " when( ass.TRADETYPECODE = '62' ) then '修改-结算单元' " +
                        " when( ass.TRADETYPECODE = '63' ) then '删除-结算单元' " +
                        " when( ass.TRADETYPECODE = '66' ) then '增加-佣金方案' " +
                        " when( ass.TRADETYPECODE = '67' ) then '修改-佣金方案' " +
                        " when( ass.TRADETYPECODE = '68' ) then '删除-佣金方案'  end) BIZTYPE," +
                        " balunit.BALUNITNO       ,balunit.BALUNIT    ," +

                        "(case when (balunit.BALUNITTYPECODE ='00') then '行业' " +
                        " when (balunit.BALUNITTYPECODE ='01') then '单位' " +
                        " when (balunit.BALUNITTYPECODE ='02') then '部门' " +
                        " when (balunit.BALUNITTYPECODE ='04') then '合帐结算单元' end) BALUNITTYPE, " +

                        "(case when (balunit.SOURCETYPECODE = '00') then 'PSAM卡号'" +
                        " when (balunit.SOURCETYPECODE = '01') then '信息亭' end) SOURCETYPE, " +

                        "balunit.CALLINGNO, '' CALLINGNAME," +
                        "balunit.CORPNO, '' CORPNAME, balunit.DEPARTNO , '' DEPARTNAME, " +
                        "balunit.REGIONCODE, '' REGIONNAME, balunit.DELIVERYMODECODE, '' DELIVERYMODE, " +
                        "balunit.APPCALLINGCODE, '' APPCALLING, " +
                        "balunit.BANKCODE , '' BANKNAME, balunit.BANKACCNO, " +
                        "balunit.CREATETIME, balunit.SERMANAGERCODE, '' SERMANAGER, " +
                        "balunit.BALLEVEL, balunit.UNITEMAIL,  " +
                        "(case when (balunit.BALCYCLETYPECODE = '00') then '小时'" +
                        " when (balunit.BALCYCLETYPECODE = '01') then '天'" +
                        " when (balunit.BALCYCLETYPECODE = '02') then '周'" +
                        " when (balunit.BALCYCLETYPECODE = '03') then '固定月'" +
                        " when (balunit.BALCYCLETYPECODE = '04') then '自然月' end) BALCYCLETYPE," +

                        "balunit.BALINTERVAL, " +

                        "(case when (balunit.FINCYCLETYPECODE = '00') then '小时'" +
                        " when (balunit.FINCYCLETYPECODE = '01') then '天'" +
                        " when (balunit.FINCYCLETYPECODE = '02') then '周'" +
                        " when (balunit.FINCYCLETYPECODE = '03') then '固定月'" +
                        " when (balunit.FINCYCLETYPECODE = '04') then '自然月' end) FINCYCLETYPE," +

                        "balunit.FININTERVAL, " +

                        "(case when (balunit.FINTYPECODE = '0') then '财务部门转账'" +
                        " when (balunit.FINTYPECODE = '1') then '财务不转账' end) FINTYPE," +

                        "(case when (balunit.COMFEETAKECODE = '0') then '不从转账金额扣减'" +
                        " when (balunit.COMFEETAKECODE = '1') then '直接从转账金额扣减' end) COMFEETAKE," +

                        "balunit.PURPOSETYPE, balunit.BankChannelCode," +

                        "(case when (balunit.PURPOSETYPE = '1') then '对公'" +
                        " when (balunit.PURPOSETYPE = '2') then '对私' else '' end) PURPOSE," +

                        "(case when (balunit.BankChannelCode = '1') then '跨行支付'" +
                        " when (balunit.BankChannelCode = '3') then '同城支付' else '' end) BankChannel," +

                        "(case when (balunit.COMFEETAKECODE = '0') then '不从转账金额扣减'" +
                        " when (balunit.COMFEETAKECODE = '1') then '直接从转账金额扣减' end) COMFEETAKE," +

                        "balunit.FINBANKCODE," +
                        "'' FINBANK            	 ,balunit.LINKMAN ,balunit.UNITPHONE	," +
                        "balunit.UNITADD		 ,balunit.REMARK  ,			            " +
                        "ass.TRADEID			 ,ass.OPERATESTAFFNO	," +
                        "'' OPERATESTAFF		 ,ass.OPERATETIME		";

        strSql += " FROM TF_B_ASSOCIATETRADE ass, TF_B_TRADE_BALUNITCHANGE balunit";
        strSql += " WHERE ass.TRADEID = balunit.TRADEID AND ";
        strSql += " ass.STATECODE = '1' ORDER  BY ass.OPERATETIME ";

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADE_BALUNITCHANGEIn, null, strSql, 0);

        DataRow[] dataRows = null;

        data.Columns["CALLINGNAME"].MaxLength = 20;
        data.Columns["CORPNAME"].MaxLength = 40;
        data.Columns["DEPARTNAME"].MaxLength = 40;

        data.Columns["REGIONNAME"].MaxLength = 40;
        data.Columns["DELIVERYMODE"].MaxLength = 20;
        data.Columns["APPCALLING"].MaxLength = 20;

        data.Columns["BANKNAME"].MaxLength = 50;
        data.Columns["FINBANK"].MaxLength = 50;

        data.Columns["SERMANAGER"].MaxLength = 20;
        data.Columns["OPERATESTAFF"].MaxLength = 20;

        //循环读取查询出的结算单元信息
        for (int index = 0; index < data.Rows.Count; index++)
        {

            string CallingNO = data.Rows[index]["CALLINGNO"].ToString();
            string CorpNo = data.Rows[index]["CORPNO"].ToString();
            string DepartNo = data.Rows[index]["DEPARTNO"].ToString();

            string RegionNo = data.Rows[index]["REGIONCODE"].ToString();
            string DeliveryModeNo = data.Rows[index]["DELIVERYMODECODE"].ToString();
            string AppCallingNo = data.Rows[index]["APPCALLINGCODE"].ToString();

            string BankNo = data.Rows[index]["BANKCODE"].ToString();
            string FinBankNo = data.Rows[index]["FINBANKCODE"].ToString();

            string SerMgrNo = data.Rows[index]["SERMANAGERCODE"].ToString();
            string OperStuffNo = data.Rows[index]["OPERATESTAFFNO"].ToString();

            //取得行业编码对应的行业名称

            if (CallingNO != null && CallingNO.Trim() != "")
            {
                dataRows = dataCalling.Select("CALLINGNO = '" + CallingNO + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["CALLINGNAME"] = dataRows[0]["CALLING"];
                }
            }

            //取得单位编码对应的单位名称

            if (CorpNo != null && CorpNo.Trim() != "")
            {
                dataRows = dataCorp.Select("CORPNO = '" + CorpNo + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["CORPNAME"] = dataRows[0]["CORP"];
                }
            }

            //取得部门编码对应的部门名称

            if (DepartNo != null && DepartNo.Trim() != "")
            {
                dataRows = dataDepart.Select("DEPARTNO = '" + DepartNo + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["DEPARTNAME"] = dataRows[0]["DEPART"];
                }
            }

            //取得地区编码对应的地区名称
            if (RegionNo != null && RegionNo.Trim() != "")
            {
                dataRows = dataRegion.Select("REGIONCODE = '" + RegionNo + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["REGIONNAME"] = dataRows[0]["REGIONNAME"];
                }
            }
            //取得POS投放模式编码对应的名称
            if (DeliveryModeNo != null && DeliveryModeNo.Trim() != "")
            {
                dataRows = dataDeliveryMode.Select("DELIVERYMODECODE = '" + DeliveryModeNo + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["DELIVERYMODE"] = dataRows[0]["DELIVERYMODE"];
                }
            }
            //取得应用行业编码对应的名称
            if (AppCallingNo != null && AppCallingNo.Trim() != "")
            {
                dataRows = dataAppCalling.Select("APPCALLINGCODE = '" + AppCallingNo + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["APPCALLING"] = dataRows[0]["APPCALLING"];
                }
            }


            //取得开户银行编码对应的银行名称
            if (BankNo != null && BankNo.Trim() != "")
            {
                dataRows = dataBank.Select("BANKCODE = '" + BankNo + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["BANKNAME"] = dataRows[0]["BANK"];
                }
            }

            //取得转出银行编码对应的银行名称

            if (FinBankNo != null && FinBankNo.Trim() != "")
            {
                dataRows = dataBank.Select("BANKCODE = '" + FinBankNo + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["FINBANK"] = dataRows[0]["BANK"];
                }
            }

            //取得商户经理编码对应的员工姓名

            if (SerMgrNo != null && SerMgrNo.Trim() != "")
            {
                dataRows = dataStuff.Select("STAFFNO = '" + SerMgrNo + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["SERMANAGER"] = dataRows[0]["STAFFNAME"];
                }
            }

            //取得操作员工对应的员工姓名

            if (OperStuffNo != null && OperStuffNo.Trim() != "")
            {
                dataRows = dataStuff.Select("STAFFNO = '" + OperStuffNo + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["OPERATESTAFF"] = dataRows[0]["STAFFNAME"];
                }
            }
        }

        DataView dataView = new DataView(data);
        return dataView;

    }


    protected void lvwBalUnitsAppral_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwBalUnitsAppral','Select$" + e.Row.RowIndex + "')");
        }
    }

    public void lvwBalUnitsAppral_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择列表框一行记录后,显示结算单元信息
        labBalUnitNO.Text = getDataKeys("BALUNITNO");
        labBalUnit.Text = getDataKeys("BALUNIT");

        labBalType.Text = getDataKeys("BALUNITTYPE");
        labSourceType.Text = getDataKeys("SOURCETYPE");

        labCalling.Text = getDataKeys("CALLINGNAME");
        labCorp.Text = getDataKeys("CORPNAME");
        labDepart.Text = getDataKeys("DEPARTNAME");

        labBank.Text = getDataKeys("BANKNAME");
        labBankAccNo.Text = getDataKeys("BANKACCNO");

        labCreateTime.Text = DateTime.Parse(getDataKeys("CREATETIME")).ToString("yyyy-MM-dd", null);
        //labCreateTime.Text = getDataKeys("CREATETIME").Substring(0, getDataKeys("CREATETIME").Length-8 );
        labSerMgr.Text = getDataKeys("SERMANAGER");

        labBalLevel.Text = getDataKeys("BALLEVEL");
        labBalCyclType.Text = getDataKeys("BALCYCLETYPE");
        labBalInterval.Text = getDataKeys("BALINTERVAL");

        labFinCyclType.Text = getDataKeys("FINCYCLETYPE");
        labFinCyclInterval.Text = getDataKeys("FININTERVAL");
        labFinType.Text = getDataKeys("FINTYPE");
        labComFeeTake.Text = getDataKeys("COMFEETAKE");

        labFinBank.Text = getDataKeys("FINBANK");

        labLinkMan.Text = getDataKeys("LINKMAN");
        labPhone.Text = getDataKeys("UNITPHONE");
        labAddress.Text = getDataKeys("UNITADD");
        labReMark.Text = getDataKeys("REMARK");
        labOpeStuff.Text = getDataKeys("OPERATESTAFF");
        labEmail.Text = getDataKeys("UNITEMAIL");

        //add by jiangbb 2012-05-21 收款人账户类型
        labPurPose.Text = getDataKeys("PURPOSE");
        labBankChannel.Text = getDataKeys("BankChannel");

        labRegion.Text = getDataKeys("REGIONNAME");
        labDeliveryMode.Text = getDataKeys("DELIVERYMODE");
        labAppCalling.Text = getDataKeys("APPCALLING");

        //当选择审批记录的业务类型为结算单元增加和修改时,设置通道名称为可选状态

        string strTradeTypeCode = getDataKeys("TRADETYPECODE");

        //结算单元增加
        if (strTradeTypeCode == "61")
        {
            selChannel.Enabled = true;
            selChannel.SelectedValue = "";
        }
        //结算单元修改
        else if (strTradeTypeCode == "62")
        {
            try
            {
                //通道名称为当前结算单元原名称
                selChannel.SelectedValue = getChannelName(getDataKeys("BALUNITNO"));
            }
            catch (Exception)
            {
                selChannel.SelectedValue = "";
            }
        }
        else
        {
            selChannel.SelectedValue = "";
            selChannel.Enabled = false;
        }



        //查询该结算单元处理台帐中的佣金方案的信息
        lvwBalComScheme.DataSource = CreateBalComSchemeDataSource();
        lvwBalComScheme.DataBind();

        //查询该结算单元已有的有效佣金规则信息
        lvwExistedComScheme.DataSource = ExistedBalComSchemeDataSource();
        lvwExistedComScheme.DataBind();





    }


    public String getDataKeys(string keysname)
    {
        return lvwBalUnitsAppral.DataKeys[lvwBalUnitsAppral.SelectedIndex][keysname].ToString();
    }


    public ICollection CreateBalComSchemeDataSource()
    {
        //查询该结算单元处理台帐中的佣金方案的信息
        TMTableModule tmTMTableModule = new TMTableModule();

        TF_TBALUNIT_COMSCHEMECHANGETDO tdoTF_TBALUNIT_COMSCHEMECHANGEIn = new TF_TBALUNIT_COMSCHEMECHANGETDO();

        string strSql = "SELECT tcoms.NAME,tcoms.REMARK, " +
                        "tbcoms.BEGINTIME,tbcoms.ENDTIME " +
                        "FROM TF_TBALUNIT_COMSCHEMECHANGE  tbcoms,  TF_TRADE_COMSCHEME  tcoms ";

        ArrayList list = new ArrayList();
        list.Add("tbcoms.COMSCHEMENO  =  tcoms.COMSCHEMENO");
        list.Add("tbcoms.TRADEID = '" + getDataKeys("TRADEID") + "'");

        strSql += DealString.ListToWhereStr(list);

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTF_TBALUNIT_COMSCHEMECHANGEIn, null, strSql, 0);

        DataView dataView = new DataView(data);
        return dataView;

    }

    public ICollection ExistedBalComSchemeDataSource()
    {
        //查询该结算单元已有的有效的佣金方案的信息
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_TBALUNIT_COMSCHEMETDO ddoTD_TBALUNIT_COMSCHEMEIn = new TD_TBALUNIT_COMSCHEMETDO();

        string strSql = "SELECT tbcoms.BEGINTIME,tbcoms.ENDTIME,tcoms.NAME ,tcoms.REMARK ";
        strSql += "FROM TF_TRADE_BALUNIT tfbal,TD_TBALUNIT_COMSCHEME tbcoms, TF_TRADE_COMSCHEME tcoms ";

        ArrayList list = new ArrayList();
        list.Add("tfbal.BALUNITNO = tbcoms.BALUNITNO");
        list.Add("tcoms.COMSCHEMENO = tbcoms.COMSCHEMENO");
        list.Add("tfbal.BALUNITNO = '" + getDataKeys("BALUNITNO") + "'");
        list.Add("tfbal.USETAG = '1'");
        list.Add("tbcoms.USETAG = '1'");

        strSql += DealString.ListToWhereStr(list);
        //strSql += " ORDER BY tbcoms.BEGINTIME DESC ";

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTD_TBALUNIT_COMSCHEMEIn, null, strSql, 0);

        DataView dataView = new DataView(data);
        return dataView;

    }



    private Boolean isChoiceBal()
    {
        //检查是否选定要审批的结算单元信息
        if (lvwBalUnitsAppral.SelectedIndex == -1)
        {
            context.AddError("A008108001");
            return false;
        }
        return true;
    }


    protected void btnPass_Click(object sender, EventArgs e)
    {
        if (!isChoiceBal()) return;

        //对通道名称的校验

        string strTradeTypeCode = getDataKeys("TRADETYPECODE");
        if ((strTradeTypeCode == "61" || strTradeTypeCode == "62") &&
             selChannel.SelectedValue == "")
        {
            context.AddError("A008108006");
            return;
        }

        //调用结算单元审批通过的存储过程

        SP_PS_TransferApprovalPassPDO pdo = new SP_PS_TransferApprovalPassPDO();

        pdo.tradeId = getDataKeys("TRADEID");
        pdo.tradeTypeCode = strTradeTypeCode;
        pdo.balUnitNo = labBalUnitNO.Text.Trim();
        pdo.channelNo = selChannel.SelectedValue;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M008108111");
            ClearBalUnit();
            InitBalUnitApral();

        }

    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        if (!isChoiceBal()) return;
        //调用结算单元作废的存储过程


        SP_PS_TransferApprovalCancelPDO pdo = new SP_PS_TransferApprovalCancelPDO();
        pdo.tradeId = getDataKeys("TRADEID");

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M008108112");
            ClearBalUnit();
            InitBalUnitApral();

        }

    }

    private void ClearBalUnit()
    {
        labBalUnitNO.Text = "";
        labBalUnit.Text = "";
        labBalType.Text = "";
        labSourceType.Text = "";
        labCreateTime.Text = "";
        labOpeStuff.Text = "";
        labCalling.Text = "";
        labCorp.Text = "";
        labDepart.Text = "";
        labBank.Text = "";
        labBankAccNo.Text = "";
        labBalLevel.Text = "";
        labBalCyclType.Text = "";
        labBalInterval.Text = "";
        labFinCyclType.Text = "";
        labFinCyclInterval.Text = "";
        labFinType.Text = "";
        labComFeeTake.Text = "";
        labSerMgr.Text = "";
        labFinBank.Text = "";
        labLinkMan.Text = "";
        labAddress.Text = "";
        labPhone.Text = "";
        labReMark.Text = "";
        labEmail.Text = "";
        selChannel.SelectedValue = "";

        labRegion.Text = "";
        labDeliveryMode.Text = "";
        labAppCalling.Text = "";

        //add by jiangbb 2012-05-21 添加收款人账户类型
        labPurPose.Text = "";

        labBankChannel.Text = "";

        //清空当前处理的佣金规则信息

        lvwBalComScheme.DataSource = new DataTable();
        lvwBalComScheme.DataBind();

        //清除已有的有效佣金规则信息

        lvwExistedComScheme.DataSource = new DataTable();
        lvwExistedComScheme.DataBind();

    }


    private string getChannelName(string channelNo)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        TF_TRADE_BALUNITTDO ddoIn = new TF_TRADE_BALUNITTDO();
        ddoIn.BALUNITNO = channelNo;

        TF_TRADE_BALUNITTDO ddoOut = (TF_TRADE_BALUNITTDO)tmTMTableModule.selByPK(context, ddoIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_BYNO", null);

        if (ddoOut != null)
            return ddoOut.CHANNELNO;
        else
            return "";
    }
}
