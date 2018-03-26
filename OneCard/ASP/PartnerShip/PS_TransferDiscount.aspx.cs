using System;
using System.Data;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using PDO.PartnerShip;
using TDO.BalanceChannel;
using TDO.UserManager;
using TDO.PartnerShip;
using TM;

public partial class ASP_PartnerShip_PS_TransferDiscount : Master.Master
{
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

        //从内部员工编码表(TD_M_INSIDESTAFF)中读取数据,初始化商户经理下拉列表值

        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), "S008111111", "TD_M_INSIDESTAFF_SVR", null);

        //ControlDeal.SelectBoxFill(selMsgQry.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);

        //指定GridView  lvwBalUnits DataKeyNames
        lvwBalUnits.DataKeyNames = new string[] 
           {
               "BALUNITNO", "BALUNIT", "DISCOUNT","PREFERENTIALCODE","USETAG",
               "CALLINGNO","CORPNO","DEPARTNO","BEGINDATE","ENDDATE","PREFERENTIALUPPER","ISSPECIAL","comschemeno","balunittypename"
               
           };
        //初始化优惠折扣
        //从优惠折扣编码表(TF_BALUNIT_DISCOUNT)中读取数据
        TF_BALUNIT_DISCOUNTTDO tdoTF_BALUNIT_DISCOUNTIn = new TF_BALUNIT_DISCOUNTTDO();
        TF_BALUNIT_DISCOUNTTDO[] tdoTF_BALUNIT_DISCOUNTOutArr = (TF_BALUNIT_DISCOUNTTDO[])tmTMTableModule.selByPKArr(context, tdoTF_BALUNIT_DISCOUNTIn, typeof(TF_BALUNIT_DISCOUNTTDO), "S008100214");

        ControlDeal.SelectBoxFillWithCode(selDiscount.Items, tdoTF_BALUNIT_DISCOUNTOutArr, "RATE", "CODEDATE", true);

        TF_WG_COMSCHEMETDO tdoTrComs = new TF_WG_COMSCHEMETDO();
        TF_WG_COMSCHEMETDO[] tdoTrComsArr = (TF_WG_COMSCHEMETDO[])tmTMTableModule.selByPKArr(context,
            tdoTrComs, typeof(TF_WG_COMSCHEMETDO), null, "TF_WG_COMSCHEMEUSAGE", null);
        ControlDeal.SelectBoxFillWithCode(selComScheme.Items, tdoTrComsArr, "NAME", "COMSCHEMENO", true);

        context.DBOpen("Select");
        string sql = @"select t.balunittype,t.name from td_m_balunittype t where t.usetage='1'";
        DataTable table = context.ExecuteReader(sql);
        cblType.DataSource = table;//绑定多选框值
        cblType.DataTextField = "NAME";
        cblType.DataValueField = "BALUNITTYPE";
        cblType.DataBind();
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
    private void InitDepart(DropDownList origindwls, DropDownList extdwls, String sqlCondition)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //从部门编码表(TD_M_CDEPART)中读取数据，放入下拉列表中



        TD_M_DEPARTTDO tdoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
        tdoTD_M_DEPARTIn.CORPNO = origindwls.SelectedValue;

        TD_M_DEPARTTDO[] tdoTD_M_DEPARTOutArr = (TD_M_DEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null, sqlCondition, null);
        ControlDeal.SelectBoxFillWithCode(extdwls.Items, tdoTD_M_DEPARTOutArr, "DEPART", "DEPARTNO", true);
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

    // 查询输入校验处理
    private void validate()
    {
        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtBeginDate);
        bool b2 = Validation.isEmpty(txtEndDate);
        DateTime? fromDate = null, toDate = null;

        if (!b1)
        {
            fromDate = valid.beDate(txtBeginDate, "开始日期范围起始值格式必须为yyyyMMdd");
        }
        if (!b2)
        {
            toDate = valid.beDate(txtEndDate, "结束日期范围终止值格式必须为yyyyMMdd");
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        }

       
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {

        validate();
        if (context.hasError()) return;
        //查询结算单元信息
        DataTable data = SPHelper.callPSQuery(context, "QueryUnitDiscount", selCalling.SelectedValue,
            selCorp.SelectedValue, selDepart.SelectedValue, selBalUint.SelectedValue,
           txtBeginDate.Text,txtEndDate.Text, context.s_DepartID,selHasDiscount.SelectedValue);
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        UserCardHelper.resetData(lvwBalUnits, data);

        ClearBalUnit();
        ClearData();

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
        
        try
        {
            selDiscount.SelectedValue = getDataKeys("PREFERENTIALCODE").Trim();
            txtMax.Text = getDataKeys("PREFERENTIALUPPER").Trim();
            txtFromDate.Text = Convert.ToDateTime(getDataKeys("BEGINDATE")).ToString("yyyyMMdd");

            txtToDate.Text = Convert.ToDateTime(getDataKeys("ENDDATE")).ToString("yyyyMMdd");
            if (getDataKeys("ISSPECIAL").Trim() == "1")
            {
                isSpecial.Checked = true;
            }
            else
            {
                isSpecial.Checked = false;
            }
            BindCheckBox(cblType);
            selComScheme.SelectedValue = getDataKeys("comschemeno").Trim();
        }
        catch (Exception)
        {
            selDiscount.SelectedValue = "";
            txtMax.Text = "";
            txtFromDate.Text = "";
            txtToDate.Text = "";
            isSpecial.Checked = false;
            selComScheme.SelectedValue= "";
            ClearCheckBox();
        }

       

       
    }
    public String getDataKeys(string keysname)
    {
        string value = lvwBalUnits.DataKeys[lvwBalUnits.SelectedIndex][keysname].ToString();

        return value == "" ? "" : value;
    }
    private void ClearBalUnit()
    {
        lvwBalUnits.SelectedIndex = -1;
        selDiscount.SelectedValue = "";

    }

   
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        //调用增加的判断处理

        if (!BalUnitAddValidation()) return;


        //调用增加的存储过程
        context.SPOpen();
        context.AddField("p_balUnitNo").Value = getDataKeys("BALUNITNO").Trim();
        context.AddField("p_discount").Value = selDiscount.SelectedValue.Trim();
        context.AddField("p_max").Value = Convert.ToDouble(txtMax.Text.Trim()) * 100.0;
        context.AddField("p_begindate").Value = txtFromDate.Text.Trim();
        context.AddField("p_enddate").Value = txtToDate.Text.Trim();
        context.AddField("p_callingno").Value = getDataKeys("CALLINGNO").Trim();
        context.AddField("p_corpno").Value = getDataKeys("CORPNO").Trim();
        context.AddField("p_departno").Value = getDataKeys("DEPARTNO").Trim();
        context.AddField("p_isspecial").Value = (isSpecial.Checked == true) ? "1" : "0";
        context.AddField("p_balType").Value = GetCblString(cblType);
        context.AddField("p_balTypeName").Value = GetCblName(cblType);
        context.AddField("p_comScheme").Value = selComScheme.SelectedValue.Trim();
        bool ok = context.ExecuteSP("SP_PS_UnitDiscountAdd");
        if (ok)
        {
            AddMessage("新增申请提交成功");
            ClearData();
            btnQuery_Click(sender, e);
        }
    }

    protected void btnModify_Click(object sender, EventArgs e)
    {
        //调用修改的判断处理

        if (!BalUnitAddValidation()) return;
        if (!BalUnitModifyValidation()) return;
        //调用修改的存储过程
        context.SPOpen();
        context.AddField("p_balUnitNo").Value = getDataKeys("BALUNITNO").Trim();
        context.AddField("p_discount").Value = selDiscount.SelectedValue.Trim();
        context.AddField("p_max").Value = Convert.ToDouble(txtMax.Text.Trim()) * 100.0;
        context.AddField("p_begindate").Value = txtFromDate.Text.Trim();
        context.AddField("p_enddate").Value = txtToDate.Text.Trim();
        context.AddField("p_callingno").Value = getDataKeys("CALLINGNO").Trim();
        context.AddField("p_corpno").Value = getDataKeys("CORPNO").Trim();
        context.AddField("p_departno").Value = getDataKeys("DEPARTNO").Trim();
        context.AddField("p_isspecial").Value = (isSpecial.Checked == true) ? "1" : "0";
        context.AddField("p_balType").Value = GetCblString(cblType);
        context.AddField("p_balTypeName").Value = GetCblName(cblType);
        context.AddField("p_comScheme").Value = selComScheme.SelectedValue.Trim();
        bool ok = context.ExecuteSP("SP_PS_UnitDiscountModify");
       
        if (ok)
        {
            AddMessage("修改申请提交成功");
            //ClearBalUnit();
            btnQuery_Click(sender, e);
        }
    }

    private Boolean BalUnitAddValidation()
    {
        //判断是否选择了需要修改的结算单元
        if (lvwBalUnits.SelectedIndex == -1)
        {
            context.AddError("A008107052");
            return false;
        }


        //判断优惠编码是否为空
        string strDiscount = selDiscount.SelectedValue;
        if (strDiscount == "")
        {
            context.AddError("请选择优惠编码", selDiscount);
        }
        //判断优惠上线是否为空
        if (txtMax.Text.Trim() == "")
            context.AddError("优惠上线不能为空", txtMax);
        else if (!Validation.isPosRealNum(txtMax.Text.Trim()))
            context.AddError("优惠上线必须为数字", txtMax);

        //对开始日期和结束日期的判断
        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, true);

        string type = GetCblString(cblType);
        if (type=="")
        {
            context.AddError("请勾选商户等级", cblType);
        }
        //判断佣金方案是否为空
        string strComScheme = selComScheme.SelectedValue;
        if (strComScheme == "")
        {
            context.AddError("请选择佣金方案", selComScheme);
        }
        return !(context.hasError());
    }
    private Boolean BalUnitModifyValidation()
    {
       
        //判断优惠编码是否为空
        string strDiscount = selDiscount.SelectedValue;
        string strMax = txtMax.Text.Trim();
        string strBeginDate = txtFromDate.Text.Trim();
        string strToDate = txtToDate.Text.Trim();
        string special = (isSpecial.Checked == true) ? "1" : "0";
        string comschemeno = selComScheme.SelectedValue;
        string cbltype = GetCblName(cblType);
        bool ischanged;
        if (getDataKeys("ISSPECIAL")==string.Empty)
        {
            
            if (special=="1")
            {
                ischanged = true;
            }
            else
            {
                ischanged = false;
            }
        }
        else
        {
            if (getDataKeys("ISSPECIAL") == special)
            {
                ischanged = false;
            }
            else
            {
                ischanged = true;
            }
        }
        if (strDiscount == getDataKeys("PREFERENTIALCODE") && strMax == getDataKeys("PREFERENTIALUPPER") && strBeginDate == Convert.ToDateTime(getDataKeys("BEGINDATE")).ToString("yyyyMMdd") && strToDate == Convert.ToDateTime(getDataKeys("ENDDATE")).ToString("yyyyMMdd") && !ischanged && comschemeno == getDataKeys("comschemeno") && cbltype == getDataKeys("balunittypename"))
        {
            context.AddError("未修改结算单元优惠信息,不可提交修改操作");
        }
        return !(context.hasError());
    }

   
    protected void btnDelete_Click(object sender, EventArgs e)
    {
        if (lvwBalUnits.SelectedIndex == -1)
        {
            context.AddError("A008107052");
            return;
        }
            
        if (getDataKeys("DISCOUNT").Trim() == "")
        {
            context.AddError("此结算单元没有设置优惠方式,不需要删除");
        }
        if (context.hasError())
            return;
        context.SPOpen();
        context.AddField("p_balUnitNo").Value = getDataKeys("BALUNITNO").Trim();
        context.AddField("p_discount").Value = getDataKeys("PREFERENTIALCODE").Trim();
        context.AddField("p_max").Value = Convert.ToInt32(getDataKeys("PREFERENTIALUPPER").Trim())*100.0;
        context.AddField("p_begindate").Value = Convert.ToDateTime(getDataKeys("BEGINDATE")).ToString("yyyyMMdd");
        context.AddField("p_enddate").Value = Convert.ToDateTime(getDataKeys("ENDDATE")).ToString("yyyyMMdd"); 
        context.AddField("p_callingno").Value = getDataKeys("CALLINGNO").Trim();
        context.AddField("p_corpno").Value = getDataKeys("CORPNO").Trim();
        context.AddField("p_departno").Value = getDataKeys("DEPARTNO").Trim();
        context.AddField("p_isspecial").Value = (isSpecial.Checked == true) ? "1" : "0";
        context.AddField("p_balType").Value = GetCblString(cblType);
        context.AddField("p_balTypeName").Value = GetCblName(cblType);
        context.AddField("p_comScheme").Value = selComScheme.SelectedValue.Trim();
        bool ok = context.ExecuteSP("SP_PS_UnitDiscountDelete");

        if (ok)
        {
            AddMessage("删除申请提交成功");
            ClearData();
            btnQuery_Click(sender, e);
        }
    }
    private  void ClearData()
    {
        selDiscount.SelectedValue = "";
        selComScheme.SelectedValue = "";
        txtMax.Text = "";
        txtFromDate.Text = ""; 
        txtToDate.Text = "";
        isSpecial.Checked = false;
        ClearCheckBox();
    }
    private string GetCblString(CheckBoxList cblType)
    {
        string cblSting = "";
        foreach (ListItem li in cblType.Items)
        {
            if (li.Selected)
            {
                cblSting += "" + li.Value + ""+"," ;

            }
        }
        if (cblSting.Length > 0)
        {
            cblSting = cblSting.Substring(0, cblSting.Length - 1);
        }
        return cblSting;
    }
    private void BindCheckBox(CheckBoxList cblType)
    {
        context.DBOpen("Select");
        string sql = @"select t.BALUNITTYPE from TF_BALUNIT_TYPE t where t.BALUNITNO='" + getDataKeys("BALUNITNO") + "' and t.usetage='1'";
        DataTable table = context.ExecuteReader(sql);
        if(table.Rows.Count>0)
        {
            foreach (DataRow row in table.Rows)
            {
                string type = row.ItemArray[0].ToString();
                if(type!="")
                {
                    foreach (ListItem li in cblType.Items)
                    {
                        if (li.Value == type)
                        {
                            li.Selected = true;

                        }
                    }
                }
            }
        }
        else
        {
            ClearCheckBox();
        }
    }

    private void ClearCheckBox()
    {
        foreach (ListItem li in cblType.Items)
        {

            li.Selected = false;
        }
    }
    private string GetCblName(CheckBoxList cblType)
    {
        string cblSting = "";
        foreach (ListItem li in cblType.Items)
        {
            if (li.Selected)
            {
                cblSting += "" + li.Text + "" + ",";

            }
        }
        if (cblSting.Length > 0)
        {
            cblSting = cblSting.Substring(0, cblSting.Length - 1);
        }
        return cblSting;
    }





}