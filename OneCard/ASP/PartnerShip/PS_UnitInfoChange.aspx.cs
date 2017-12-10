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
using Common;
using TM;
using TDO.BalanceChannel;
using PDO.PartnerShip;
using TDO.UserManager;
using System.Globalization;
using System.Text;

public partial class ASP_PartnerShip_PS_UnitInfoChange : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            TMTableModule tmTMTableModule = new TMTableModule();
            //从行业编码表(TD_M_CALLINGNO)中读取数据


            TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
            TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), "S008100211", "TD_M_CALLING_ANDNO", null);

            //放入查询输入行业名称下拉列表中

            ControlDeal.SelectBoxFillWithCode(selCalling.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);

            //设置单位信息中行业名称下拉列表值

            ControlDeal.SelectBoxFillWithCode(selCallingExt.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);

            //设置地区信息
            InitSelREGIONCODE();

            //设置有效标志下拉列表值

            TSHelper.initUseTag(selUseTag);

            //设置单位信息列表表头字段名

            lvwCorpQuery.DataSource = new DataTable();
            lvwCorpQuery.DataBind();
            lvwCorpQuery.SelectedIndex = -1;

            //指定GridView DataKeyNames
            lvwCorpQuery.DataKeyNames = new string[] { "CORPNO", "CORP", "CALLINGNO", "LINKMAN", "CORPPHONE", "CORPADD", "CORPMARK", "REMARK", "USETAG", "REGIONCODE", "COMPANYPAPERTYPE", "COMPANYPAPERNO", "CORPORATION", "COMPANYENDTIME", "PAPERTYPE", "PAPERNO", "PAPERENDDATE", "REGISTEREDCAPITAL", "SECURITYVALUE", "COMPANYMANAGERPAPERTYPE", "COMPANYMANAGERNO", "APPCALLINGNO", "MANAGEAREA" };

            selCorp.Items.Add(new ListItem("---请选择---", ""));
            //单位证件类型
            selComPapertype.Items.Add(new ListItem("---请选择---", ""));
            selComPapertype.Items.Add(new ListItem("01:组织机构代码证", "01"));
            selComPapertype.Items.Add(new ListItem("02:企业营业执照", "02"));
            selComPapertype.Items.Add(new ListItem("03:税务登记证", "03"));
            //从证件类型编码表(TD_M_PAPERTYPE)中读取数据，放入下拉列表中
            ASHelper.initPaperTypeList(context, selPapertype);

            ASHelper.initPaperTypeList(context, selHoldPaperType);

            TD_M_APPCALLINGCODETDO ddlTD_M_APPCALLINGCODEIn = new TD_M_APPCALLINGCODETDO();
            TD_M_APPCALLINGCODETDO[] ddoTD_M_APPCALLINGCODEOutArr = (TD_M_APPCALLINGCODETDO[])tmTMTableModule.selByPKArr(context, ddlTD_M_APPCALLINGCODEIn, typeof(TD_M_APPCALLINGCODETDO), "S008113033", "TD_M_APPCALLINGUSETAG", null);
            ControlDeal.SelectBoxFill(selAppCalling.Items, ddoTD_M_APPCALLINGCODEOutArr, "APPCALLING", "APPCALLINGCODE", true);

            //txtSecurityValue.Text = "0";//新增商户安全值为0
        }
    }


    public void lvwCorpQuery_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwCorpQuery.PageIndex = e.NewPageIndex;
        lvwCorpQuery.DataSource = CreateCorpQueryDataSource();
        lvwCorpQuery.DataBind();

        lvwCorpQuery.SelectedIndex = -1;
        ClearCorp();

    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        lvwCorpQuery.DataSource = CreateCorpQueryDataSource();
        lvwCorpQuery.DataBind();
        lvwCorpQuery.SelectedIndex = -1;

        ClearCorp();
        hidSecurityValue.Value = "";
    }

    public ICollection CreateCorpQueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从单位信息资料表(TD_M_CORP)中读取数据
        TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
        string strSql = "Select distinct tcorp.USETAG ,tcorp.CORPNO,tcorp.CORP," +
                        "tcalling.CALLING,tcorp.CORPADD,tcorp.CORPMARK," +
                        "tcorp.COMPANYPAPERTYPE,tcorp.COMPANYPAPERNO,tcorp.CORPORATION,tcorp.COMPANYENDTIME,tcorp.PAPERTYPE,tcorp.PAPERNO,tcorp.PAPERENDDATE,tcorp.REGISTEREDCAPITAL/1000000.0 REGISTEREDCAPITAL,tcorp.SECURITYVALUE/100.0 SECURITYVALUE," +//新增商户证件类型、商户证件号码、联系人证件类型、联系人证件号码、联系人证件有效期限、注册资金、安全值 add by youyue
                        "tcorp.COMPANYMANAGERPAPERTYPE,tcorp.COMPANYMANAGERNO,tcorp.APPCALLINGNO,tcorp.MANAGEAREA," +
                        "tcorp.LINKMAN,tcorp.CORPPHONE,tcorp.REMARK,tcorp.CALLINGNO,tregion.REGIONCODE,tregion.REGIONNAME ";
        strSql += " From TD_M_CORP tcorp,TD_M_CALLINGNO tcalling,TD_M_REGIONCODE tregion,td_m_insidedepart tmid,td_m_insidestaff  tmis,(select regioncode from td_m_insidedepart where departno = '" + context.s_DepartID + "') m,td_m_regioncode r1,td_m_regioncode r2";

        ArrayList list = new ArrayList();
        list.Add("tcorp.CALLINGNO = tcalling.CALLINGNO(+) ");
        list.Add("tcorp.REGIONCODE = tregion.REGIONCODE(+) ");

        if (selCalling.SelectedValue != "")
            list.Add("tcorp.CALLINGNO = '" + selCalling.SelectedValue + "'");

        if (selCorp.SelectedValue != "")
            list.Add("tcorp.CORPNO  = '" + selCorp.SelectedValue + "'");

        if (selEndTime.SelectedValue != "")//add by huangzl 增加证件有效期查询
        {
            if (selEndTime.SelectedValue == "1")
                list.Add("tcorp.companyendtime is null");
            else if (selEndTime.SelectedValue == "2")
                list.Add("tcorp.companyendtime < '" + DateTime.Today.ToString("yyyyMMdd") + "'");
            else if (selEndTime.SelectedValue == "3")
                list.Add("tcorp.companyendtime >= '" + DateTime.Today.ToString("yyyyMMdd") + "' and tcorp.companyendtime < '" + DateTime.Today.AddMonths(1).ToString("yyyyMMdd") + "'");
            else if (selEndTime.SelectedValue == "4")
                list.Add("tcorp.companyendtime >= '" + DateTime.Today.AddMonths(1).ToString("yyyyMMdd") + "' and tcorp.companyendtime < '" + DateTime.Today.AddMonths(2).ToString("yyyyMMdd") + "'");
            else if (selEndTime.SelectedValue == "5")
                list.Add("tcorp.companyendtime >= '" + DateTime.Today.AddMonths(2).ToString("yyyyMMdd") + "' and tcorp.companyendtime < '" + DateTime.Today.AddMonths(3).ToString("yyyyMMdd") + "'");
            else if (selEndTime.SelectedValue == "6")
                list.Add("tcorp.companyendtime >= '" + DateTime.Today.AddMonths(3).ToString("yyyyMMdd") + "' and tcorp.companyendtime < '" + DateTime.Today.AddMonths(6).ToString("yyyyMMdd") + "'");
            else if (selEndTime.SelectedValue == "7")
                list.Add("tcorp.companyendtime >= '" + DateTime.Today.AddMonths(6).ToString("yyyyMMdd") + "' and tcorp.companyendtime < '" + DateTime.Today.AddMonths(12).ToString("yyyyMMdd") + "'");
            else if (selEndTime.SelectedValue == "8")
                list.Add("tcorp.companyendtime >= '" + DateTime.Today.AddYears(1).ToString("yyyyMMdd") + "'");
        }

        list.Add("tcorp.updatestaffno = tmis.staffno");
        list.Add("tmis.departno = tmid.departno");
        list.Add("(tmid.regioncode = r1.regioncode and r1.regionname = r2.regionname and r2.regioncode = m.regioncode)or m.regioncode is null");
        strSql += DealString.ListToWhereStr(list);

        strSql += " order by tcorp.CORPNO ";
        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTD_M_CORPIn, null, strSql, 0);
        DataView dataView = new DataView(data);

        return dataView;
    }


    private void CorpInputValidation()
    {
        //对单位编码进行非空,长度,数字的校验

        string strCorpNo = txtCorpNo.Text.Trim();
        if (strCorpNo == "")
            context.AddError("A008100102", txtCorpNo);
        else if (Validation.strLen(strCorpNo) != 4)
            context.AddError("A008100103", txtCorpNo);
        else if (!Validation.isCharNum(strCorpNo))
            context.AddError("A008100104", txtCorpNo);

        //对单位名称进行非空,长度校验
        string strCorp = txtCorp.Text.Trim();
        if (strCorp == "")
            context.AddError("A008100002", txtCorp);
        else if (Validation.strLen(strCorp) > 100)
            context.AddError("A008100003", txtCorp);

        //对行业进行非空的检验

        string strCalling = selCallingExt.SelectedValue;
        if (strCalling == "")
            context.AddError("A008100013", selCallingExt);

        //对地区进行非空的检验
        string strRegion = selRegionExt.SelectedValue;
        if (strRegion == "")
            context.AddError("A008113018", selRegionExt);

        //对联系人进行非空,长度校验
        String strLinkMan = txtLinkMan.Text.Trim();
        if (strLinkMan == "")
            context.AddError("A008100004", txtLinkMan);
        else if (Validation.strLen(strLinkMan) > 10)
            context.AddError("A008100005", txtLinkMan);

        //对联系电话进行非空,长度校验
        string strPhone = txtPhone.Text.Trim();
        if (strPhone == "")
            context.AddError("A008100006", txtPhone);
        else if (Validation.strLen(strPhone) > 40)
            context.AddError("A008100007", txtPhone);
        else if (!Validation.isNum(strPhone))
            context.AddError("联系电话必须为数字", txtPhone);
        //对单位地址进行非空,长度校验
        string strAddr = txtAddr.Text.Trim();
        if (strAddr == "")
            context.AddError("A008100008", txtAddr);
        else if (Validation.strLen(strAddr) > 50)
            context.AddError("A008100009", txtAddr);

        //对单位说明进行长度校验

        string strCpRemrk = txtCpRemrk.Text.Trim();
        if (strCpRemrk != "")
        {
            if (Validation.strLen(strCpRemrk) > 50)
                context.AddError("A008100010", txtCpRemrk);
        }

        //对备注进行长度校验

        string strRemrk = txtRemark.Text.Trim();
        if (strRemrk != "")
        {
            if (Validation.strLen(strRemrk) > 100)
                context.AddError("A008100011", txtRemark);
        }

        //对有效标志进行非空检验

        String strUseTag = selUseTag.SelectedValue;
        if (strUseTag == "")
            context.AddError("A008100014", selUseTag);

        //对单位证件类型进行非空检验  add by youyue
        if (selComPapertype.SelectedValue == "")
            context.AddError("商户证件类型不能为空", selComPapertype);
        //对单位证件号码进行非空、长度、英数字检验
        if (txtComPaperNo.Text.Trim() == "")
            context.AddError("商户证件号码不能为空", txtComPaperNo);
        else if (Validation.strLen(txtComPaperNo.Text.Trim()) > 30)
            context.AddError("商户证件号码程度不能超过30位", txtComPaperNo);
        else if (!Validation.isCharNum(txtComPaperNo.Text.Trim()))
            context.AddError("商户证件号码必须为英数", txtComPaperNo);
        //对单位法人姓名进行非空、长度、英数字检验
        if (txtCorporation.Text.Trim() == "")
            context.AddError("商户法人姓名不能为空", txtCorporation);
        else if (Validation.strLen(txtCorporation.Text.Trim()) > 100)
            context.AddError("商户法人姓名程度不能超过50位", txtCorporation);
        //对证件有效期进行非空、日期格式校验
        String endDate = txtEndDate.Text.Trim();
        if (endDate == "")
            context.AddError("商户证件有效期不能为空", txtEndDate);
        else if (!Validation.isDate(txtEndDate.Text.Trim(), "yyyyMMdd"))
            context.AddError("商户证件有效期格式必须为yyyyMMdd", txtEndDate);
        //对联系人证件类型进行非空检验
        if (selPapertype.SelectedValue == "")
            context.AddError("授权办理人证件类型不能为空", selPapertype);
        //对联系人证件号码进行非空、长度、英数字检验
        if (txtCustpaperno.Text.Trim() == "")
            context.AddError("授权办理人证件号码不能为空", txtCustpaperno);
        else if (!Validation.isCharNum(txtCustpaperno.Text.Trim()))
            context.AddError("授权办理人证件号码必须为英数", txtCustpaperno);
        else if (Validation.strLen(txtCustpaperno.Text.Trim()) > 20)
            context.AddError("授权办理人证件号码长度不能超过20位", txtCustpaperno);
        else if (selPapertype.SelectedValue=="00" && !Validation.isPaperNo(txtCustpaperno.Text.Trim()))
            context.AddError("授权办理人证件号码验证不通过", txtCustpaperno);
        //联系人证件有效期检验
        if (txtAccEndDate.Text.Trim() != "")
            if (!Validation.isDate(txtAccEndDate.Text.Trim(), "yyyyMMdd"))
                context.AddError("授权办理人证件有效期格式必须为yyyyMMdd", txtAccEndDate);
        //注册资金检验
        if (txtMoney.Text.Trim() == "")
            context.AddError("注册资金不能为空", txtMoney);
        else if (!Validation.isPrice(txtMoney.Text.Trim()))
            context.AddError("注册资金必须为数字", txtMoney);
        //经营范围检验
        if (txtArea.Text.Trim() == "")
            context.AddError("经营范围不能为空", txtArea);
        else if (Validation.strLen(txtArea.Text.Trim()) > 50)
            context.AddError("经营范围长度不能超过50位", txtArea);
        //法人证件类型检验
        if (selHoldPaperType.SelectedValue == "")
            context.AddError("法人证件类型不能为空", selHoldPaperType);
        //法人证件号码检验
        if (txtHoldNo.Text.Trim() == "")
            context.AddError("法人证件号码不能为空", txtHoldNo);
        else if (!Validation.isCharNum(txtHoldNo.Text.Trim()))
            context.AddError("法人证件号码必须为英数", txtHoldNo);
        else if (Validation.strLen(txtHoldNo.Text.Trim()) > 20)
            context.AddError("法人证件号码长度不能超过20位", txtHoldNo);
        else if (selHoldPaperType.SelectedValue=="00" && !Validation.isPaperNo(txtHoldNo.Text.Trim()))
            context.AddError("法人证件号码验证不通过", txtHoldNo);
        //应用行业检验
        if (selAppCalling.SelectedValue == "")
            context.AddError("应用行业不能为空", selAppCalling);

        //安全值
        if (txtSecurityValue.Text.Trim() != "")
        {
            if (!Validation.isNum(txtSecurityValue.Text.Trim()))
                context.AddError("安全值必须是数字", txtSecurityValue);
        }
        

    }

    private Boolean CorpAddValidation()
    {
        //对输入的单位信息检验

        CorpInputValidation();

        //新增时操作员工所属区域与单位区域保持一致
        if (!HasOperPower("201307"))
        {
            if (selRegionExt.SelectedItem.Text.Split(':')[1] != GetRegionNameByCode(context.s_RegionCode) && selRegionExt.SelectedValue != "")
            {
                context.AddError("A008100022", selRegionExt);
            }
        }

        //对有效是否为有效的判断

        string strUseTag = selUseTag.SelectedValue;
        if (strUseTag != "" && strUseTag != "1")
            context.AddError("A008100016", selUseTag);

        return CheckContext();
    }

    private Boolean CorpModifyValidation()
    {
        //检查是否选定单位的信息

        if (lvwCorpQuery.SelectedIndex == -1)
        {
            context.AddError("A008100001");
            return false;
        }

        //对输入的单位信息检验

        CorpInputValidation();



        //检查是否修改了选定的单位编码

        if (txtCorpNo.Text.Trim() != getDataKeys("CORPNO"))
        {
            context.AddError("A008100105", txtCorpNo);
            return false;
        }

        if (!HasOperPower("201307"))
        {
            if (!string.IsNullOrEmpty(getDataKeys("REGIONCODE").Trim()))
            {
                if (GetRegionNameByCode(context.s_RegionCode) != GetRegionNameByCode(getDataKeys("REGIONCODE").Trim()))
                {
                    context.AddError("A008100023", txtCorpNo);
                    return false;
                }
            }
            else
            {
                if (GetRegionNameByCode(context.s_RegionCode) != GETUpdateStaffRegionName(getDataKeys("CORPNO")))
                {
                    context.AddError("A008100021", txtCorpNo);
                    return false;
                }
            }
        }

        //检查是否修改了选定单位的行业名称

        if (selCallingExt.SelectedValue != getDataKeys("CALLINGNO"))
        {
            context.AddError("A008100015", selCallingExt);
            return false;
        }

        //当修改了选定单位的单位名称,检验是否库中已存在该单位

        else if (txtCorp.Text.Trim() != getDataKeys("CORP"))
        {
            //验证是否已存在该单位名称
            return isNotExistCorpName();

        }

        return CheckContext();
    }


    private Boolean isNotExistCorpName()
    {

        TMTableModule tmTMTableModule = new TMTableModule();
        //从单位编码表中读取数据

        TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
        tdoTD_M_CORPIn.CORP = txtCorp.Text.Trim();

        TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, "TD_M_CORPNAME", null);
        if (tdoTD_M_CORPOutArr.Length != 0)
        {
            context.AddError("A008100017", txtCorp);
            return false;
        }
        return true;

    }


    private Boolean CheckContext()
    {
        //对context的error检测 
        if (context.hasError())
            return false;
        else
            return true;
    }

    private bool isExistCorpNo()
    {
        //是否已存在该单位编码
        TMTableModule tmTMTableModule = new TMTableModule();
        //从单位编码表中读取数据

        TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
        tdoTD_M_CORPIn.CORPNO = txtCorpNo.Text.Trim();

        TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, "TD_M_CORP_BYNO", null);

        if (tdoTD_M_CORPOutArr.Length != 0)
        {
            context.AddError("A008100106", txtCorpNo);
        }

        //是否存在该单位名称

        isNotExistCorpName();

        return context.hasError();
    }


    protected void btnAdd_Click(object sender, EventArgs e)
    {
        //对输入的单位信息检验

        if (!CorpAddValidation()) return;

        //判断是否存在该单位编码 
        if (isExistCorpNo()) return;


        //执行单位信息增加的存储过程

        SP_PS_UnitInfoChangeAddPDO ddoSP_PS_UnitInfoChangeAddPDOIn = new SP_PS_UnitInfoChangeAddPDO();

        ddoSP_PS_UnitInfoChangeAddPDOIn.corpNo = txtCorpNo.Text.Trim();
        ddoSP_PS_UnitInfoChangeAddPDOIn.corp = txtCorp.Text.Trim();
        ddoSP_PS_UnitInfoChangeAddPDOIn.callingNo = selCallingExt.SelectedValue;

        ddoSP_PS_UnitInfoChangeAddPDOIn.corpAdd = txtAddr.Text.Trim();
        ddoSP_PS_UnitInfoChangeAddPDOIn.corpMark = txtCpRemrk.Text.Trim();
        ddoSP_PS_UnitInfoChangeAddPDOIn.linkMan = txtLinkMan.Text.Trim();
        ddoSP_PS_UnitInfoChangeAddPDOIn.corpPhone = txtPhone.Text.Trim();
        ddoSP_PS_UnitInfoChangeAddPDOIn.remark = txtRemark.Text.Trim();
        ddoSP_PS_UnitInfoChangeAddPDOIn.regionCode = selRegionExt.SelectedValue;

        //新增商户证件类型、商户证件号码、联系人证件类型、联系人证件号码、联系人证件有效期限、注册资金、安全值 add by youyue
        ddoSP_PS_UnitInfoChangeAddPDOIn.companyPaperType = selComPapertype.SelectedValue;
        ddoSP_PS_UnitInfoChangeAddPDOIn.companyPaperNo = txtComPaperNo.Text.Trim();
        ddoSP_PS_UnitInfoChangeAddPDOIn.corporation = txtCorporation.Text.Trim();
        ddoSP_PS_UnitInfoChangeAddPDOIn.companyEndTime = txtEndDate.Text.Trim();
        ddoSP_PS_UnitInfoChangeAddPDOIn.paperType = selPapertype.SelectedValue;
        ddoSP_PS_UnitInfoChangeAddPDOIn.paperNo = txtCustpaperno.Text.Trim();
        ddoSP_PS_UnitInfoChangeAddPDOIn.paperEndDate = txtAccEndDate.Text.Trim();
        ddoSP_PS_UnitInfoChangeAddPDOIn.registeredCapital = txtMoney.Text.Trim() == "" ? 0 : (int)(Convert.ToDecimal(txtMoney.Text.Trim()) * 100*10000);    //注册资金单位改为万元
        // ddoSP_PS_UnitInfoChangeAddPDOIn.securityValue = txtSecurityValue.Text.Trim() == "" ? 0 : (int)(Convert.ToDecimal(txtMoney.Text.Trim()) * 100); ;//新商户安全值
        //增加法人证件类型、证件号码、经营范围、应用行业
        ddoSP_PS_UnitInfoChangeAddPDOIn.companymanagerpapertype = selHoldPaperType.SelectedValue;
        ddoSP_PS_UnitInfoChangeAddPDOIn.companymanagerno = txtHoldNo.Text.Trim();
        ddoSP_PS_UnitInfoChangeAddPDOIn.managearea = txtArea.Text.Trim();
        ddoSP_PS_UnitInfoChangeAddPDOIn.appcallingno = selAppCalling.SelectedValue;

        //须加密字段corpadd, linkman, corpphone, companypaperno, paperno, companymanagerno —add by hzl
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(ddoSP_PS_UnitInfoChangeAddPDOIn.corpAdd, ref strBuilder);
        ddoSP_PS_UnitInfoChangeAddPDOIn.corpAddAes = strBuilder.ToString();
        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(ddoSP_PS_UnitInfoChangeAddPDOIn.linkMan, ref strBuilder);
        ddoSP_PS_UnitInfoChangeAddPDOIn.linkManAes = strBuilder.ToString();
        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(ddoSP_PS_UnitInfoChangeAddPDOIn.corpPhone, ref strBuilder);
        ddoSP_PS_UnitInfoChangeAddPDOIn.corpPhoneAes = strBuilder.ToString();
        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(ddoSP_PS_UnitInfoChangeAddPDOIn.companyPaperNo, ref strBuilder);
        ddoSP_PS_UnitInfoChangeAddPDOIn.companyPaperNoAes = strBuilder.ToString();
        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(ddoSP_PS_UnitInfoChangeAddPDOIn.paperNo, ref strBuilder);
        ddoSP_PS_UnitInfoChangeAddPDOIn.paperNoAes = strBuilder.ToString();
        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(ddoSP_PS_UnitInfoChangeAddPDOIn.companymanagerno, ref strBuilder);
        ddoSP_PS_UnitInfoChangeAddPDOIn.companymanagernoAes = strBuilder.ToString();

        bool ok = TMStorePModule.Excute(context, ddoSP_PS_UnitInfoChangeAddPDOIn);

        if (ok)
        {
            AddMessage("M008100113");


            if (txtSecurityValue.Text.Trim() != "" && selUseTag.SelectedValue == "1")//如果填写了安全值
            {
                if (txtSecurityValue.Text.Trim() != "0")
                {
                    context.SPOpen();
                    context.AddField("P_FUNCCODE").Value = "ADD";
                    context.AddField("P_CORPNO").Value = txtCorpNo.Text.Trim();
                    context.AddField("P_SECURITYVALUE").Value = (Convert.ToDecimal(txtSecurityValue.Text.Trim()) * 100).ToString();
                    context.AddField("P_REGISTEREDCAPITAL").Value = (Convert.ToDecimal(txtMoney.Text.Trim()) * 100 * 10000).ToString();   //注册资金单位改为万元
                    context.AddField("P_APPCALLINGNO").Value = selAppCalling.SelectedValue;
                    bool ok2 = context.ExecuteSP("SP_PS_CORPSECURITYAPPROVAL");// 提交至安全值审核页面
                    if (ok2)
                    {
                        context.AddMessage("商户安全值提交至审核界面成功");
                    }
                }
            }
            //清除输入的单位信息

            //ClearCorp();

            //更新列表
            btnQuery_Click(sender, e);

        }

    }


    private void ClearCorp()
    {
        txtCorpNo.Text = "";
        txtCorp.Text = "";
        selCallingExt.SelectedValue = "";
        txtAddr.Text = "";
        txtCpRemrk.Text = "";
        txtLinkMan.Text = "";
        txtPhone.Text = "";
        selUseTag.SelectedValue = "";
        txtRemark.Text = "";

        selRegionExt.SelectedValue = "";

        selComPapertype.SelectedValue = "";
        txtComPaperNo.Text = "";
        txtCorporation.Text = "";
        txtEndDate.Text = "";
        selPapertype.SelectedValue = "";
        txtCustpaperno.Text = "";
        txtAccEndDate.Text = "";
        txtMoney.Text = "";
        txtSecurityValue.Text = "";

        selHoldPaperType.SelectedValue = "";
        txtHoldNo.Text = "";
        selAppCalling.SelectedValue = "";
        txtArea.Text = "";

    }

    protected void btnModify_Click(object sender, EventArgs e)
    {
        //对输入的单位信息检验

        if (!CorpModifyValidation()) return;

        //执行单位信息修改的存储过程


        SP_PS_UnitInfoChangeModifyPDO ddoSP_PS_UnitInfoChangeModifyPDOIn = new SP_PS_UnitInfoChangeModifyPDO();

        ddoSP_PS_UnitInfoChangeModifyPDOIn.corpNo = getDataKeys("CORPNO");
        ddoSP_PS_UnitInfoChangeModifyPDOIn.corp = txtCorp.Text.Trim();
        ddoSP_PS_UnitInfoChangeModifyPDOIn.callingNo = selCallingExt.SelectedValue;
        ddoSP_PS_UnitInfoChangeModifyPDOIn.corpAdd = txtAddr.Text.Trim();
        ddoSP_PS_UnitInfoChangeModifyPDOIn.corpMark = txtCpRemrk.Text.Trim();
        ddoSP_PS_UnitInfoChangeModifyPDOIn.linkMan = txtLinkMan.Text.Trim();
        ddoSP_PS_UnitInfoChangeModifyPDOIn.corpPhone = txtPhone.Text.Trim();
        ddoSP_PS_UnitInfoChangeModifyPDOIn.useTag = selUseTag.SelectedValue;
        ddoSP_PS_UnitInfoChangeModifyPDOIn.remark = txtRemark.Text.Trim();
        ddoSP_PS_UnitInfoChangeModifyPDOIn.regionCode = selRegionExt.SelectedValue;

        //新增商户证件类型、商户证件号码、联系人证件类型、联系人证件号码、联系人证件有效期限、注册资金、安全值、法人姓名
        ddoSP_PS_UnitInfoChangeModifyPDOIn.companyPaperType = selComPapertype.SelectedValue;
        ddoSP_PS_UnitInfoChangeModifyPDOIn.companyPaperNo = txtComPaperNo.Text.Trim();
        ddoSP_PS_UnitInfoChangeModifyPDOIn.corporation = txtCorporation.Text.Trim();
        ddoSP_PS_UnitInfoChangeModifyPDOIn.companyEndTime = txtEndDate.Text.Trim();
        ddoSP_PS_UnitInfoChangeModifyPDOIn.paperType = selPapertype.SelectedValue;
        ddoSP_PS_UnitInfoChangeModifyPDOIn.paperNo = txtCustpaperno.Text.Trim();
        ddoSP_PS_UnitInfoChangeModifyPDOIn.paperEndDate = txtAccEndDate.Text.Trim();
        ddoSP_PS_UnitInfoChangeModifyPDOIn.registeredCapital = txtMoney.Text.Trim() == "" ? 0 : (int)(Convert.ToDecimal(txtMoney.Text.Trim()) * 100 * 10000); //注册资金单位改为万元
        //ddoSP_PS_UnitInfoChangeModifyPDOIn.securityValue = txtSecurityValue.Text.Trim() == "" ? 0 : (int)(Convert.ToDecimal(txtSecurityValue.Text.Trim()) * 100);

        //增加法人证件类型、证件号码、经营范围、应用行业
        ddoSP_PS_UnitInfoChangeModifyPDOIn.companymanagerpapertype = selHoldPaperType.SelectedValue;
        ddoSP_PS_UnitInfoChangeModifyPDOIn.companymanagerno = txtHoldNo.Text.Trim();
        ddoSP_PS_UnitInfoChangeModifyPDOIn.managearea = txtArea.Text.Trim();
        ddoSP_PS_UnitInfoChangeModifyPDOIn.appcallingno = selAppCalling.SelectedValue;

        //须加密字段corpadd, linkman, corpphone, companypaperno, paperno, companymanagerno —add by hzl
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(ddoSP_PS_UnitInfoChangeModifyPDOIn.corpAdd, ref strBuilder);
        ddoSP_PS_UnitInfoChangeModifyPDOIn.corpAddAes = strBuilder.ToString();
        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(ddoSP_PS_UnitInfoChangeModifyPDOIn.linkMan, ref strBuilder);
        ddoSP_PS_UnitInfoChangeModifyPDOIn.linkManAes = strBuilder.ToString();
        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(ddoSP_PS_UnitInfoChangeModifyPDOIn.corpPhone, ref strBuilder);
        ddoSP_PS_UnitInfoChangeModifyPDOIn.corpPhoneAes = strBuilder.ToString();
        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(ddoSP_PS_UnitInfoChangeModifyPDOIn.companyPaperNo, ref strBuilder);
        ddoSP_PS_UnitInfoChangeModifyPDOIn.companyPaperNoAes = strBuilder.ToString();
        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(ddoSP_PS_UnitInfoChangeModifyPDOIn.paperNo, ref strBuilder);
        ddoSP_PS_UnitInfoChangeModifyPDOIn.paperNoAes = strBuilder.ToString();
        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(ddoSP_PS_UnitInfoChangeModifyPDOIn.companymanagerno, ref strBuilder);
        ddoSP_PS_UnitInfoChangeModifyPDOIn.companymanagernoAes = strBuilder.ToString();

        bool ok = TMStorePModule.Excute(context, ddoSP_PS_UnitInfoChangeModifyPDOIn);
        if (ok)
        {
            AddMessage("M008100111");

            if (txtSecurityValue.Text.Trim() != "" && txtSecurityValue.Text.Trim() != hidSecurityValue.Value && selUseTag.SelectedValue == "1")//如果填写并修改了安全值
            {

                context.SPOpen();
                context.AddField("P_FUNCCODE").Value = "MODIFY";
                context.AddField("P_CORPNO").Value = getDataKeys("CORPNO");
                context.AddField("P_SECURITYVALUE").Value = (Convert.ToDecimal(txtSecurityValue.Text.Trim()) * 100).ToString();
                context.AddField("P_REGISTEREDCAPITAL").Value = (Convert.ToDecimal(txtMoney.Text.Trim()) * 100 * 10000).ToString();   //注册资金单位改为万元
                context.AddField("P_APPCALLINGNO").Value = selAppCalling.SelectedValue;
                bool ok2 = context.ExecuteSP("SP_PS_CORPSECURITYAPPROVAL");// 提交至安全值审核页面
                if (ok2)
                {
                    context.AddMessage("商户安全值提交至审核界面成功");
                }

            }

            //清除输入的单位信息

            // ClearCorp();

            btnQuery_Click(sender, e);
        }
    }

    protected void selCalling_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择行业后,设置单位名称下拉列表值

        if (selCalling.SelectedValue == "")
        {
            selCorp.Items.Clear();
        }
        else
        {
            TMTableModule tmTMTableModule = new TMTableModule();
            //从单位编码表(TD_M_CORP)中读取数据，放入下拉列表中


            TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
            tdoTD_M_CORPIn.CALLINGNO = selCalling.SelectedValue;

            TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, "TD_M_CORP_USE", null);
            ControlDeal.SelectBoxFillWithCode(selCorp.Items, tdoTD_M_CORPOutArr, "CORP", "CORPNO", true);
        }

    }

    protected void selCallingExt_SelectedIndexChanged(object sender, EventArgs e)
    {
        GetNewCorpNo();
    }

    protected void selRegionExt_SelectedIndexChanged(object sender, EventArgs e)
    {
        GetNewCorpNo();
    }

    protected void lvwCorpQuery_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwCorpQuery','Select$" + e.Row.RowIndex + "')");
        }
    }

    public void lvwCorpQuery_SelectedIndexChanged(object sender, EventArgs e)
    {

        //选择列表框一行记录后,设置单位信息增加,修改区域中数据

        txtCorp.Text = getDataKeys("CORP");
        txtCorpNo.Text = getDataKeys("CORPNO");
        txtLinkMan.Text = getDataKeys("LINKMAN");
        txtPhone.Text = getDataKeys("CORPPHONE");
        txtAddr.Text = getDataKeys("CORPADD");
        txtCpRemrk.Text = getDataKeys("CORPMARK");
        txtRemark.Text = getDataKeys("REMARK");
        selUseTag.SelectedValue = getDataKeys("USETAG");

        selCallingExt.SelectedValue = getDataKeys("CALLINGNO");

        selRegionExt.SelectedValue = getDataKeys("REGIONCODE");

        //新增显示商户证件类型、商户证件号码、联系人证件类型、联系人证件号码、联系人证件有效期限、注册资金、安全值
        selComPapertype.SelectedValue = getDataKeys("COMPANYPAPERTYPE");
        txtComPaperNo.Text = getDataKeys("COMPANYPAPERNO");
        txtCorporation.Text = getDataKeys("CORPORATION");
        txtEndDate.Text = getDataKeys("COMPANYENDTIME");
        selPapertype.SelectedValue = getDataKeys("PAPERTYPE");
        txtCustpaperno.Text = getDataKeys("PAPERNO");
        txtAccEndDate.Text = getDataKeys("PAPERENDDATE");
        txtMoney.Text = getDataKeys("REGISTEREDCAPITAL");
        txtSecurityValue.Text = getDataKeys("SECURITYVALUE");
        hidSecurityValue.Value = getDataKeys("SECURITYVALUE");

        //增加法人证件类型、证件号码、经营范围、应用行业
        selHoldPaperType.SelectedValue = getDataKeys("COMPANYMANAGERPAPERTYPE");
        txtHoldNo.Text = getDataKeys("COMPANYMANAGERNO");
        txtArea.Text = getDataKeys("MANAGEAREA");
        selAppCalling.SelectedValue = getDataKeys("APPCALLINGNO");

    }

    public string getDataKeys(string keysname)
    {
        return lvwCorpQuery.DataKeys[lvwCorpQuery.SelectedIndex][keysname].ToString();
    }

    //初始化地区编码下拉列表值
    private void InitSelREGIONCODE()
    {
        selRegionExt.Items.Clear();

        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_REGIONCODETDO ddoTD_M_REGIONCODEIn = new TD_M_REGIONCODETDO();
        TD_M_REGIONCODETDO[] ddoTD_M_REGIONCODEOutArr = (TD_M_REGIONCODETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_REGIONCODEIn, typeof(TD_M_REGIONCODETDO), "S008113013", "TD_M_REGIONUSETAG", null);

        ControlDeal.SelectBoxFill(selRegionExt.Items, ddoTD_M_REGIONCODEOutArr, "REGIONNAME", "REGIONCODE", true);
    }

    private void GetNewCorpNo()
    {
        if (lvwCorpQuery.SelectedIndex == -1)
        {
            if (selCallingExt.SelectedValue != "" && selRegionExt.SelectedValue != "")
            {
                string callCode = selCallingExt.SelectedValue.Substring(1, 1);
                string regionCode = selRegionExt.SelectedValue;

                SP_PS_GetNextNoPDO pdo = new SP_PS_GetNextNoPDO();
                pdo.funcCode = "NEXTCORPNO";
                pdo.prefix = callCode + regionCode;

                StoreProScene storePro = new StoreProScene();
                DataTable data = storePro.Execute(context, pdo);

                if (string.IsNullOrEmpty(pdo.output))
                {
                    context.AddError("A008100107", txtCorpNo);
                }
                else
                {
                    txtCorpNo.Text = pdo.output;
                }

            }
            else
            {
                txtCorpNo.Text = "";
            }
        }
    }

    private string GETUpdateStaffRegionName(string balunitno)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_INSIDEDEPARTTDO ddoIn = new TD_M_INSIDEDEPARTTDO();
        ddoIn.DEPARTNO = GetUpdateStaffDept(GetUpdateStaffNo(balunitno));

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

    private string GetUpdateStaffDept(string staffno)
    {
        if (staffno == "")
            return "";

        TMTableModule tmTMTableModule = new TMTableModule();

        //从员工编码表(TD_M_INSIDESTAFF)中读取数据


        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        tdoTD_M_INSIDESTAFFIn.STAFFNO = staffno;

        TD_M_INSIDESTAFFTDO ddoOut = (TD_M_INSIDESTAFFTDO)tmTMTableModule.selByPK(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF2", null);

        if (ddoOut != null)
        {
            return ddoOut.DEPARTNO;
        }
        else
        {
            return "";
        }
    }

    private string GetUpdateStaffNo(string corpno)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_CORPTDO ddoIn = new TD_M_CORPTDO();
        ddoIn.CORPNO = corpno;

        TD_M_CORPTDO ddoOut = (TD_M_CORPTDO)tmTMTableModule.selByPK(context, ddoIn, typeof(TD_M_CORPTDO), null, "TD_M_CORP_BYNO", null);

        if (ddoOut != null)
        {
            return ddoOut.UPDATESTAFFNO;
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
    ///  新增商户的安全之设置方法：资金规模乘应用行业权值
    /// </summary>
    private void GetSecurityValue()
    {
        if (lvwCorpQuery.SelectedIndex == -1)
        {
            if (selAppCalling.SelectedValue != "" && txtMoney.Text.Trim() != "")
            {
                context.DBOpen("Select");
                string sql = @"SELECT CALLINGRIGHTVALUE FROM TD_M_CALLINGRIGHTVALUE WHERE CALLINGNO='" + selAppCalling.SelectedValue + "' AND APPLYTYPE='1'";
                DataTable table = context.ExecuteReader(sql);
                if (table != null && table.Rows.Count > 0)
                {
                    string callingrightvalue = table.Rows[0]["CALLINGRIGHTVALUE"].ToString(); //应用行业权值
                    float callingvalue = float.Parse(callingrightvalue);//转化为float类型
                    txtSecurityValue.Text = (callingvalue * Convert.ToInt32(txtMoney.Text.Trim())).ToString();
                }
                else
                {
                    txtSecurityValue.Text = "";
                }

            }

        }
    }
    protected void selAppCalling_SelectedIndexChanged(object sender, EventArgs e)
    {
        GetSecurityValue();
    }
    protected void txtMoney_TextChanged(object sender, EventArgs e)
    {
        GetSecurityValue();
    }
}
