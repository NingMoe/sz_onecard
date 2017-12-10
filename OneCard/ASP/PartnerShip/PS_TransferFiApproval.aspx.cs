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


public partial class ASP_PartnerShip_PS_TransferFiApproval : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
       if (!Page.IsPostBack)
       {

           //指定GridView DataKeyNames
           lvwBalUnitsFiAppral.DataKeyNames =
               new string[]{"BALUNITNO", "BALUNIT", "BALUNITTYPE", "SOURCETYPE", "CALLINGNAME", "CORPNAME",  
               "DEPARTNAME", "BANKNAME", "BANKACCNO", "CREATETIME", "BALLEVEL", "BALCYCLETYPE", "BALINTERVAL",
               "FINCYCLETYPE", "FININTERVAL", "FINTYPE", "COMFEETAKE", "FINBANK", "SERMANAGER", "BALUNITTYPECODE",
               "SOURCETYPECODE", "LINKMAN", "UNITPHONE", "UNITADD", "CHANNELNO", "REMARK", "CHECKSTAFF", "TRADEID",
               "TRADETYPECODE", "OPERTSTUFFNO", "CALLINGNO", "CORPNO", "DEPARTNO", "BANKCODE", "SERMANAGERCODE",
               "BALCYCLETYPECODE", "FINCYCLETYPECODE", "FINTYPECODE", "COMFEETAKECODE", "FINBANKCODE","UNITEMAIL","PURPOSE","PURPOSETYPE","BankChannel","BankChannelCode",
               "REGIONCODE", "REGIONNAME", "DELIVERYMODECODE", "DELIVERYMODE", "APPCALLINGCODE", "APPCALLING"};

           InitBalUnitFiAppral();

           //设置当前处理佣金规则中表头
           lvwBalComScheme.DataSource = new DataTable();
           lvwBalComScheme.DataBind();
           lvwBalComScheme.SelectedIndex = -1;

           //设置已存在佣金规则信息列表表头
           lvwExistedComScheme.DataSource = new DataTable();
           lvwExistedComScheme.DataBind();

       }
    }

    public void lvwBalUnitsFiAppral_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwBalUnitsFiAppral.PageIndex = e.NewPageIndex;
        InitBalUnitFiAppral();
        ClearBalUnit();
    }



   private void InitBalUnitFiAppral()
   {
       //查询待审核的结算单元信息
       lvwBalUnitsFiAppral.DataSource = CreateBalUnitFiAppDataSource();
       lvwBalUnitsFiAppral.DataBind();

       lvwBalUnitsFiAppral.SelectedIndex = -1;

   }


    public ICollection CreateBalUnitFiAppDataSource()
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

        //地区信息
        TD_M_REGIONCODETDO tdoTD_M_REGIONCODEIn = new TD_M_REGIONCODETDO();
        DataTable dataRegion = tmTMTableModule.selByPKDataTable(context, tdoTD_M_REGIONCODEIn, null, "TD_M_REGIONUSETAG", null, 0);

        //POS投放模式信息
        TD_M_DELIVERYMODECODETDO tdoTD_M_DELIVERYMODECODEIn = new TD_M_DELIVERYMODECODETDO();
        DataTable dataDeliveryMode = tmTMTableModule.selByPKDataTable(context, tdoTD_M_DELIVERYMODECODEIn, null, "TD_M_DELIVERYMODEUSETAG", null, 0);

        //应用行业信息
        TD_M_APPCALLINGCODETDO tdoTD_M_APPCALLINGCODEIn = new TD_M_APPCALLINGCODETDO();
        DataTable dataAppCalling = tmTMTableModule.selByPKDataTable(context, tdoTD_M_APPCALLINGCODEIn, null, "TD_M_APPCALLINGUSETAG", null, 0);


        //查询银行信息
        TD_M_BANKTDO ddoTD_M_BANKIn = new TD_M_BANKTDO();
        DataTable dataBank = tmTMTableModule.selByPKDataTable(context, ddoTD_M_BANKIn, null, "", null, 0);

        //商户经理和操作员工信息
        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        DataTable dataStuff = tmTMTableModule.selByPKDataTable(context, tdoTD_M_INSIDESTAFFIn, null, "", null, 0);


        TF_B_TRADE_BALUNITCHANGETDO ddoTF_B_TRADE_BALUNITCHANGEIn = new TF_B_TRADE_BALUNITCHANGETDO();
        string strSql = "SELECT ass.TRADETYPECODE, (case when( ass.TRADETYPECODE = '61' ) then '增加-结算单元' " +
                        " when( ass.TRADETYPECODE = '62' ) then '修改-结算单元' " +
                        " when( ass.TRADETYPECODE = '63' ) then '删除-结算单元' " +
                        " when( ass.TRADETYPECODE = '66' ) then '增加-佣金方案' " +
                        " when( ass.TRADETYPECODE = '67' ) then '修改-佣金方案' " +
                        " when( ass.TRADETYPECODE = '68' ) then '删除-佣金方案'  end) BIZTYPE," +
                        " balunit.BALUNITNO, balunit.BALUNIT, balunit.BALUNITTYPECODE, ass.TRADETYPECODE," +
                        "(case when (balunit.BALUNITTYPECODE ='00') then '行业' " +
                        " when (balunit.BALUNITTYPECODE ='01') then '单位' " +
                        " when (balunit.BALUNITTYPECODE ='02') then '部门' " +
                        " when (balunit.BALUNITTYPECODE ='04') then '合帐结算单元' end) BALUNITTYPE, " +

                        "(case when (balunit.SOURCETYPECODE = '00') then 'PSAM卡号'" +
                        " when (balunit.SOURCETYPECODE = '01') then '信息亭' end) SOURCETYPE, " +

                        "balunit.SOURCETYPECODE, balunit.CALLINGNO, '' CALLINGNAME, " +
                        "balunit.CORPNO,'' CORPNAME, balunit.DEPARTNO , '' DEPARTNAME, " +
                        "balunit.REGIONCODE, '' REGIONNAME, balunit.DELIVERYMODECODE, '' DELIVERYMODE, " +
                        "balunit.APPCALLINGCODE, '' APPCALLING, " +
                        "balunit.BANKCODE, '' BANKNAME, balunit.BANKACCNO," +
                        "balunit.CREATETIME, balunit.SERMANAGERCODE, '' SERMANAGER, " +
                        "balunit.BALLEVEL, balunit.BALCYCLETYPECODE, " +

                        "(case when (balunit.BALCYCLETYPECODE = '00') then '小时'" +
                        " when (balunit.BALCYCLETYPECODE = '01') then '天'" +
                        " when (balunit.BALCYCLETYPECODE = '02') then '周'" +
                        " when (balunit.BALCYCLETYPECODE = '03') then '固定月'" +
                        " when (balunit.BALCYCLETYPECODE = '04') then '自然月' end) BALCYCLETYPE," +

                        "balunit.BALINTERVAL, balunit.FINCYCLETYPECODE," +

                        "(case when (balunit.FINCYCLETYPECODE = '00') then '小时'" +
                        " when (balunit.FINCYCLETYPECODE = '01') then '天'" +
                        " when (balunit.FINCYCLETYPECODE = '02') then '周'" +
                        " when (balunit.FINCYCLETYPECODE = '03') then '固定月'" +
                        " when (balunit.FINCYCLETYPECODE = '04') then '自然月' end) FINCYCLETYPE," +

                        "balunit.FININTERVAL, balunit.FINTYPECODE, balunit.COMFEETAKECODE," +

                        "(case when (balunit.FINTYPECODE = '0') then '财务部门转账'" +
                        " when (balunit.FINTYPECODE = '1') then '财务不转账' end) FINTYPE," +

                        "(case when (balunit.COMFEETAKECODE = '0') then '不从转账金额扣减'" +
                        " when (balunit.COMFEETAKECODE = '1') then '直接从转账金额扣减' end) COMFEETAKE," +

                        "balunit.PURPOSETYPE, balunit.BankChannelCode," +

                        "(case when (balunit.PURPOSETYPE = '1') then '对公'" +
                        " when (balunit.PURPOSETYPE = '2') then '对私' else '' end) PURPOSE," +

                        "(case when (balunit.BankChannelCode = '1') then '跨行支付'" +
                        " when (balunit.BankChannelCode = '3') then '同城支付' else '' end) BankChannel," +

                        "balunit.FINBANKCODE, '' FINBANK, balunit.LINKMAN ,balunit.UNITPHONE, " +
                        "balunit.UNITADD, balunit.REMARK, balunit.CHANNELNO, balunit.UNITEMAIL, " +
                        "ass.TRADEID, ass.OPERATESTAFFNO CHECKSTUFFNO,'' CHECKSTAFF, ass.OPERATETIME CHECKTIME, "+
                        "assoc.OPERATESTAFFNO OPERTSTUFFNO ";

        strSql += " FROM TF_B_ASSOCIATETRADE_EXAM ass, TF_B_TRADE_BALUNITCHANGE balunit, TF_B_ASSOCIATETRADE assoc";
        strSql += " WHERE ass.TRADEID = balunit.TRADEID AND ass.TRADEID = assoc.TRADEID AND ass.STATECODE = '1' ";
        // strSql += " ORDER BY ass.OPERATETIME ";

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
        data.Columns["CHECKSTAFF"].MaxLength = 20;


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
            string ChekStuffNo = data.Rows[index]["CHECKSTUFFNO"].ToString();

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

            //取得审批员工编码对应的员工姓名
            if (ChekStuffNo != null && ChekStuffNo.Trim() != "")
            {
                dataRows = dataStuff.Select("STAFFNO = '" + ChekStuffNo + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["CHECKSTAFF"] = dataRows[0]["STAFFNAME"];
                }
            }
        }

        DataView dataView = new DataView(data);
        return dataView;

    }


    protected void lvwBalUnitsFiAppral_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwBalUnitsFiAppral','Select$" + e.Row.RowIndex + "')");
        }
    }

    public void lvwBalUnitsFiAppral_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择列表框一行记录后,显示结算单元信息
        labBalUnitNO.Text = getDataKeys("BALUNITNO");
        labBalUnit.Text   = getDataKeys("BALUNIT");

        labBalType.Text    = getDataKeys("BALUNITTYPE");
        labSourceType.Text = getDataKeys("SOURCETYPE");

        labCalling.Text = getDataKeys("CALLINGNAME");
        labCorp.Text    = getDataKeys("CORPNAME");
        labDepart.Text  = getDataKeys("DEPARTNAME");

        labBank.Text      = getDataKeys("BANKNAME");
        labBankAccNo.Text = getDataKeys("BANKACCNO");

        labSerMgr.Text     = getDataKeys("SERMANAGER");
        labCreateTime.Text = DateTime.Parse(getDataKeys("CREATETIME")).ToString("yyyy-MM-dd", null);
        //labCreateTime.Text = getDataKeys("CREATETIME").Substring(0, getDataKeys("CREATETIME").Length - 8);

        labBalLevel.Text    = getDataKeys("BALLEVEL");
        labBalCyclType.Text = getDataKeys("BALCYCLETYPE");
        labBalInterval.Text = getDataKeys("BALINTERVAL");

        labFinCyclType.Text     = getDataKeys("FINCYCLETYPE");
        labFinCyclInterval.Text = getDataKeys("FININTERVAL");
        labFinType.Text         = getDataKeys("FINTYPE");
        labComFeeTake.Text      = getDataKeys("COMFEETAKE");

        labFinBank.Text = getDataKeys("FINBANK");

        labLinkMan.Text = getDataKeys("LINKMAN");
        labPhone.Text   = getDataKeys("UNITPHONE");
        labAddress.Text = getDataKeys("UNITADD");
        labReMark.Text  = getDataKeys("REMARK");
        labCheckStuff.Text = getDataKeys("CHECKSTAFF");
        labEmail.Text      = getDataKeys("UNITEMAIL");

        //add by jiangbb 2012-05-21 收款人账户类型
        labPurPose.Text = getDataKeys("PURPOSE");

        labBankChannel.Text = getDataKeys("BankChannel");

        labRegion.Text = getDataKeys("REGIONNAME");
        labDeliveryMode.Text = getDataKeys("DELIVERYMODE");
        labAppCalling.Text = getDataKeys("APPCALLING");

        //查询该结算单元处理台帐中的佣金方案的信息
        lvwBalComScheme.DataSource = CreateBalComSchemeDataSource();
        lvwBalComScheme.DataBind();

        //查询该结算单元已有的有效佣金规则信息
        lvwExistedComScheme.DataSource = ExistedBalComSchemeDataSource();
        lvwExistedComScheme.DataBind();

    }


    public String getDataKeys(string keysname)
    {
        return lvwBalUnitsFiAppral.DataKeys[lvwBalUnitsFiAppral.SelectedIndex][keysname].ToString();
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

        string strSql = "SELECT tbcoms.BEGINTIME, tbcoms.ENDTIME, tcoms.NAME, tcoms.REMARK ";
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
        //检查是否选定要审核的结算单元信息
        if (lvwBalUnitsFiAppral.SelectedIndex == -1)
        {
            context.AddError("A008109001");
            return false;
        }
        return true;
    }

    protected void btnPass_Click(object sender, EventArgs e)
    {

        if (!isChoiceBal()) return;
     
        //当业务类型为修改时,
        //  当结算单元类型修改后,判断当前修改后的结算单元是否存在
        if (getDataKeys("TRADETYPECODE") == "62")
        {
            if (!MoidifyBalUnitChk()) return;
        }

        //当业务类型为增加时,判断结算单元是否存在
        else if (getDataKeys("TRADETYPECODE") == "61")
        {
            if (!isNotExistBalUnit()) return;
        }
      
        //调用审核通过的存储过程
        SP_PS_TransferFiApprovalPassPDO pdo = new SP_PS_TransferFiApprovalPassPDO();
                                                                   
         pdo.tradeId          =   getDataKeys("TRADEID");                                    
         pdo.tradeTypeCode    =   getDataKeys("TRADETYPECODE");     
         pdo.balUnitNo        =   getDataKeys("BALUNITNO");
         pdo.balUnit          =   getDataKeys("BALUNIT");                                        
         pdo.balUnitTypeCode  =   getDataKeys("BALUNITTYPECODE");                           
         pdo.sourceTypeCode   =   getDataKeys("SOURCETYPECODE");                                
         pdo.callingNo        =   getDataKeys("CALLINGNO");                 
         pdo.corpNo           =   getDataKeys("CORPNO");                    
         pdo.departNo         =   getDataKeys("DEPARTNO");                  
         pdo.bankCode         =   getDataKeys("BANKCODE");                  
         pdo.bankAccno        =   getDataKeys("BANKACCNO");                 
         pdo.serManagerCode   =   getDataKeys("SERMANAGERCODE");                                                     
         pdo.balLevel         =   getDataKeys("BALLEVEL");                  
         pdo.balCycleTypeCode =   getDataKeys("BALCYCLETYPECODE");          
         pdo.balInterval      =   Convert.ToInt32(getDataKeys("BALINTERVAL"));               
         pdo.finCycleTypeCode =   getDataKeys("FINCYCLETYPECODE");          
         pdo.finInterval      =   Convert.ToInt32(getDataKeys("FININTERVAL"));               
         pdo.finTypeCode      =   getDataKeys("FINTYPECODE");               
         pdo.comFeeTakeCode   =   getDataKeys("COMFEETAKECODE");            
         pdo.finBankCode      =   getDataKeys("FINBANKCODE");               
         pdo.linkMan          =   getDataKeys("LINKMAN");                   
         pdo.unitPhone        =   getDataKeys("UNITPHONE");                 
         pdo.unitAdd          =   getDataKeys("UNITADD");

         pdo.uintEmail        = getDataKeys("UNITEMAIL");
         pdo.remark           =   getDataKeys("REMARK");
         pdo.updateStuff      =   getDataKeys("OPERTSTUFFNO");
         pdo.channelNo        =   getDataKeys("CHANNELNO");
        
         //add by jiangbb 2012-05-21 添加 
         pdo.purposeType      =   getDataKeys("PURPOSETYPE");
         pdo.bankChannel      =   getDataKeys("BankChannelCode");

         pdo.RegionCode = getDataKeys("REGIONCODE");
         pdo.DeliveryModeCode = getDataKeys("DELIVERYMODECODE");
         pdo.AppCallingCode = getDataKeys("APPCALLINGCODE");

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M008109111");
            ClearBalUnit();
            InitBalUnitFiAppral();
        }
    }

    private void GenBalQuerySql(ArrayList list)
    {
        list.Add(" USETAG = '1' ");
        list.Add(" BALUNITTYPECODE ='" + getDataKeys("BALUNITTYPECODE") + "'");
       
        if (getDataKeys("BALUNITTYPECODE") == "00")
        {
            list.Add(" CALLINGNO ='" + getDataKeys("CALLINGNO") + "'");
        }
        else if (getDataKeys("BALUNITTYPECODE") == "01")
        {
            list.Add(" CALLINGNO ='" + getDataKeys("CALLINGNO") + "'");
            list.Add(" CORPNO ='" + getDataKeys("CORPNO") + "'");
        }
        else if (getDataKeys("BALUNITTYPECODE") == "02")
        {
            list.Add(" CALLINGNO ='" + getDataKeys("CALLINGNO") + "'");
            list.Add(" CORPNO ='" + getDataKeys("CORPNO") + "'");
            list.Add(" DEPARTNO ='" + getDataKeys("DEPARTNO") + "'");

        }
       
    }

    private Boolean MoidifyBalUnitChk()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //判断修改后的结算单元是否存在
        TF_TRADE_BALUNITTDO ddoTF_TRADE_BALUNITIn = new TF_TRADE_BALUNITTDO();

        string strSql = "SELECT BALUNITNO FROM TF_TRADE_BALUNIT ";
        ArrayList lists = new ArrayList();

        lists.Add(" BALUNITNO ='" + getDataKeys("BALUNITNO") + "'");

        GenBalQuerySql(lists);

        string sql = strSql + DealString.ListToWhereStr(lists);


        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTF_TRADE_BALUNITIn, null, sql, 0);

        if(data.Rows.Count == 0)
        {
            return isNotExistBalUnit();
        }

        return true;
    }


    private Boolean isNotExistBalUnit()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        string strSql = "SELECT BALUNITNO FROM TF_TRADE_BALUNIT ";

        //检查是否存在当前类型的结算单元
        TF_TRADE_BALUNITTDO ddoTF_TRADE_BALUNITInext = new TF_TRADE_BALUNITTDO();
        ArrayList listext = new ArrayList();
        GenBalQuerySql(listext);
        string sqlext = strSql + DealString.ListToWhereStr(listext);

        DataTable datas = tmTMTableModule.selByPKDataTable(context, ddoTF_TRADE_BALUNITInext, null, sqlext, 0);

        if (datas.Rows.Count != 0)
        {
            context.AddError("A008109002");
            return false;
        }

        return true;


    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        if (!isChoiceBal()) return;

        //调用审核作废的存储过程

        SP_PS_TransferFiApprovalCancelPDO pdo = new SP_PS_TransferFiApprovalCancelPDO();
        pdo.tradeId = getDataKeys("TRADEID");

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M008109112");
            ClearBalUnit();
            InitBalUnitFiAppral();
        }
    }

    private void ClearBalUnit()
    {
        labBalUnitNO.Text = "";
        labBalUnit.Text = "";
        labBalType.Text = "";
        labSourceType.Text = "";
        labCreateTime.Text = "";
        labCheckStuff.Text = "";
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

        //add by jiangbb 2012-05-21 添加收款人账户类型
        labPurPose.Text = "";
        labBankChannel.Text = "";

        labRegion.Text = "";
        labDeliveryMode.Text = "";
        labAppCalling.Text = "";
      
        //清空当前处理佣金规则信息
        lvwBalComScheme.DataSource = new DataTable();
        lvwBalComScheme.DataBind();

        //清空已存在佣金规则信息
        lvwExistedComScheme.DataSource = new DataTable();
        lvwExistedComScheme.DataBind();
    }


}
