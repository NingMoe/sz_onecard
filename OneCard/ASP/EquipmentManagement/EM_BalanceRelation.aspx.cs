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
using TDO.BalanceChannel;
using TDO.ResourceManager;
using TDO.UserManager;
using Common;

using PDO.EquipmentManagement;

public partial class ASP_EquipmentManagement_EM_BalanceRelation : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if(!Page.IsPostBack){

            //初始化POS来源
            EMHelper.setSource(selSource1);
            EMHelper.setSource(selSource2);

            txtPosNo2.Enabled = false;

            //初始化行业
            TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
            TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tm.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO),null);
            ControlDeal.SelectBoxFillWithCode(selCalling1.Items, tdoTD_M_CALLINGNOOutArr,
                "CALLING", "CALLINGNO", true);
            ControlDeal.SelectBoxFillWithCode(selCalling2.Items, tdoTD_M_CALLINGNOOutArr,
                "CALLING", "CALLINGNO", true);
            

            //初始化商户经理
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), "S008111111", "TD_M_INSIDESTAFF_SVR", null);
            ControlDeal.SelectBoxFillWithCode(selManager.Items, tdoTD_M_INSIDESTAFFOutArr,
               "STAFFNAME", "STAFFNO", true);

            //表头
            InitRelations();
        }
    }

    //选择POS来源，设置POS编号是否可编辑
    protected void selSource2_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (selSource2.SelectedValue == "")
        {
            txtPosNo2.Text = "";
            txtPosNo2.Enabled = false;
        }
        else
            txtPosNo2.Enabled = true;
    }

    //选择行业时，初始化单位、部门
    protected void selCalling1_SelectedIndexChanged(object sender, EventArgs e)
    {
        selDept1.Items.Clear();
        if (selCalling1.SelectedValue == "")
        {
            selCorp1.Items.Clear();
            return;
        }
        InitCorp(selCalling1, selCorp1, "TD_M_CORPCALLUSAGE");
    }

    //选择行业时，初始化单位、部门
    protected void selCalling2_SelectedIndexChanged(object sender, EventArgs e)
    {
        selDept2.Items.Clear();
        if (selCalling2.SelectedValue == "")
        {
            selCorp2.Items.Clear();
            selBalanceUnit.Items.Clear();
            return;
        }
        InitCorp(selCalling2, selCorp2, "TD_M_CORPCALLUSAGE");
        InitBalUnit("00",selCalling2);
        BalUnit("00", selCalling2);
    }

    //选择单位时，初始化部门
    protected void selCorp1_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (selCorp1.SelectedValue == "")
        {
            selDept1.Items.Clear();
            return;
        }
        InitDepart(selCorp1, selDept1, "TD_M_DEPARTUSAGE");
    }

    //选择单位时，初始化部门、结算单元
    protected void selCorp2_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (selCorp2.SelectedValue == "")
        {
            selDept2.Items.Clear();
            InitBalUnit("00", selCalling2);
            return;
        }
        InitDepart(selCorp2, selDept2, "TD_M_DEPARTUSAGE");
        InitBalUnit("01", selCorp2);
        BalUnit("01", selCorp2);
    }

    //选择部门时，初始化结算单元
    protected void selDept2_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (selDept2.SelectedValue == "")
        {
            InitBalUnit("01", selCorp2);
            return;
        }
        InitBalUnit("02", selDept2);
        //BalUnit("02", selDept2);
    }

    protected void selPsamJointUse_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (selPsamJointUse.SelectedValue == "0")
        {
            palSelUnit.Visible = false;
        }
        else
        {
            palSelUnit.Visible = true;
        }
    }
    //初始化单位
    protected void InitCorp(DropDownList father, DropDownList target, String sqlCondition)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
        tdoTD_M_CORPIn.CALLINGNO = father.SelectedValue;

        TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, sqlCondition, null);
        ControlDeal.SelectBoxFillWithCode(target.Items, tdoTD_M_CORPOutArr,
           "CORP", "CORPNO", true);
    }

    //初始化部门
    private void InitDepart(DropDownList corp, DropDownList dept, String sqlCondition)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //从部门编码表(TD_M_CDEPART)中读取数据，放入下拉列表中

        TD_M_DEPARTTDO tdoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
        tdoTD_M_DEPARTIn.CORPNO = corp.SelectedValue;

        TD_M_DEPARTTDO[] tdoTD_M_DEPARTOutArr = (TD_M_DEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null, sqlCondition, null);
        ControlDeal.SelectBoxFillWithCode(dept.Items, tdoTD_M_DEPARTOutArr,
           "DEPART", "DEPARTNO", true);
    }
    //初始化结算单元，并设置与结算单元关联的默认商户经理
    private void InitBalUnit(string balType, DropDownList dwls)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_TRADE_BALUNITTDO tdoTF_TRADE_BALUNITIn = new TF_TRADE_BALUNITTDO();
        TF_TRADE_BALUNITTDO[] tdoTF_TRADE_BALUNITOutArr = null;

        //查询行业下的结算单元
        if (balType == "00")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_CALLING", null);
        }

        //查询单位下的结算单元
        else if (balType == "01")
        {
            tdoTF_TRADE_BALUNITIn.CORPNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_CORP", null);
        }

        //查询部门下的结算单元
        else if (balType == "02")
        {
            tdoTF_TRADE_BALUNITIn.DEPARTNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_DEPART", null);
        }

        //当结算单元存在时,初始化结算单元，并设置商户经理默认值
        if (tdoTF_TRADE_BALUNITOutArr.Length == 1)
        {
            TF_TRADE_BALUNITTDO ddoTF_TRADE_BALUNITTDO = tdoTF_TRADE_BALUNITOutArr[0];

            //初始化结算单元
            selBalanceUnit.Items.Clear();
            selBalanceUnit.Items.Add(new ListItem(ddoTF_TRADE_BALUNITTDO.BALUNITNO + ":" + ddoTF_TRADE_BALUNITTDO.BALUNIT, ddoTF_TRADE_BALUNITTDO.BALUNITNO));
            selBalanceUnit.SelectedValue = ddoTF_TRADE_BALUNITTDO.BALUNITNO;

            //设置商户经理默认值        
            string sevManagerCode = ddoTF_TRADE_BALUNITTDO.SERMANAGERCODE;
            ListItem item = selManager.Items.FindByValue(sevManagerCode);
            if (item != null)
                selManager.SelectedValue = sevManagerCode;
        }
        else if (tdoTF_TRADE_BALUNITOutArr.Length > 1)
        {
            ControlDeal.SelectBoxFillWithCode(selBalanceUnit.Items, tdoTF_TRADE_BALUNITOutArr,
               "BALUNIT", "BALUNITNO", true);
        }
        else
        {
            //结算单元不存在时，清空结算单元下拉框，设置商户经理默认值为空
            selBalanceUnit.Items.Clear();
            selManager.SelectedValue = "";
        }
        
    }

    private void BalUnit(string balType, DropDownList dwls)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_TRADE_BALUNITTDO tdoTF_TRADE_BALUNITIn = new TF_TRADE_BALUNITTDO();
        TF_TRADE_BALUNITTDO[] tdoTF_TRADE_BALUNITOutArr = null;

        //查询选定行业下的结算单元
        if (balType == "00")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = selCalling2.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_BYCALLING", null);
        }

        //查询选定单位下的结算单元
        else if (balType == "01")
        {
            tdoTF_TRADE_BALUNITIn.CORPNO = selCorp2.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_SHIHUA", null);
        }

        //查询选定部门下的结算单元
        //else if (balType == "02")
        //{
        //    tdoTF_TRADE_BALUNITIn.DEPARTNO = dwls.SelectedValue;
        //    tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_DEPART", null);
        //}

        ControlDeal.SelectBoxFill(selUnit.Items, tdoTF_TRADE_BALUNITOutArr, "BALUNIT", "BALUNITNO", true);

    }
    //表头
    private void InitRelations(){
        lvwRelation.DataSource = new DataTable();
        lvwRelation.DataBind();
        lvwRelation.SelectedIndex = -1;
        lvwRelation.DataKeyNames = new string[] { "PSAMNO", "POSNO", "CALLINGNO", "CORPNO", "DEPARTNO", "SERMANAGERCODE", "BALUNITNO", "USETYPECODE", "BUILDTIME", "CALLING", "CORP", "DEPT", "MANAGER", "BALANCEUNIT","NOTE" };
    }

    //选择行
    public void lvwRelation_SelectedIndexChanged(object sender, EventArgs e)
    {
        ClearData();

        //selSource2.SelectedValue = getDataKeys("USETYPECODE");
        SetSelectionValue(selSource2, getDataKeys("USETYPECODE"));
        txtPosNo2.Text = getDataKeys("POSNO");
        txtPsamNo2.Text = getDataKeys("PSAMNO");
        //selCalling2.SelectedValue = getDataKeys("CALLINGNO");
        SetSelectionValue(selCalling2, getDataKeys("CALLINGNO"));
        //selManager.SelectedValue = getDataKeys("SERMANAGERCODE");
        SetSelectionValue(selManager, getDataKeys("SERMANAGERCODE"));
        txtNote.Text = getDataKeys("NOTE");

        string corpNo = getDataKeys("CORPNO");
        string corpName = getDataKeys("CORP");
        selCorp2.Items.Add(new ListItem(corpNo + ":" +corpName, corpNo));
        selCorp2.SelectedValue = corpNo;

        string deptNo = getDataKeys("DEPARTNO");
        string deptName = getDataKeys("DEPT");
        if (deptNo!="")  //增加部门是否存在判断  add by youyue
        {
           selDept2.Items.Add(new ListItem(deptNo + ":" + deptName, deptNo));
        }
        selDept2.SelectedValue = deptNo;

        string balUnitNo = getDataKeys("BALUNITNO");
        string balUnitName = getDataKeys("BALANCEUNIT");
        if (balUnitNo != "") //增加结算单元是否存在判断  add by youyue
        {
            selBalanceUnit.Items.Add(new ListItem(balUnitNo + ":" + balUnitName, balUnitNo));
        }
        selBalanceUnit.SelectedValue = balUnitNo;

        txtPosNo2.Enabled = true;
        if (getDataKeys("tlsamno").Equals("")) //是否支持联机消费
        {
            chkIsLimit.Checked = false;
        }
        else
        {
            chkIsLimit.Checked = true;
        }
    }

    private void SetSelectionValue(DropDownList list, string value)
    {
        ListItem item = list.Items.FindByValue(value.Trim());
        if (item != null)
            list.SelectedValue = value;
        else
            list.SelectedValue = "";
    }
    
    private string getDataKeys(string keysname)
    {
        string ret = lvwRelation.DataKeys[lvwRelation.SelectedIndex][keysname].ToString().Trim();
        return Server.HtmlDecode(ret).Trim();
    }
    protected void lvwRelation_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwRelation','Select$" + e.Row.RowIndex + "')");
        }
    }

    public void lvwRelation_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwRelation.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    //查询
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //输入判断
        if (!ValidateForQuery())
            return;

        TMTableModule tmTMTableModule = new TMTableModule();
        TF_R_PSAMPOSRECTDO tdoPsamPosRec = new TF_R_PSAMPOSRECTDO();

        string strSql = "SELECT	ps.SAMNO PSAMNO,ps.POSNO POSNO,ps.CALLINGNO CALLINGNO,ps.CORPNO CORPNO,ps.DEPARTNO DEPARTNO," +
            "ps.SERMANAGERCODE SERMANAGERCODE,ps.BALUNITNO BALUNITNO,ps.USETYPECODE USETYPECODE,ps.TAKETIME BUILDTIME, ps.REMARK NOTE," +
            "calling.CALLING CALLING,corp.CORP CORP,dept.DEPART DEPT,staf.STAFFNAME MANAGER,balu.BALUNIT BALANCEUNIT ,tl.SAMNO tlsamno " +
            "FROM TF_R_PSAMPOSREC ps left join TD_M_CALLINGNO calling on ps.CALLINGNO=calling.CALLINGNO " +
            "left join TD_M_CORP corp on ps.CORPNO=corp.CORPNO " +
            "left join TD_M_DEPART dept on ps.DEPARTNO=dept.DEPARTNO " +
            "left join TD_M_INSIDESTAFF staf on ps.SERMANAGERCODE=staf.STAFFNO " +
            "left join TF_TRADE_BALUNIT balu on ps.BALUNITNO=balu.BALUNITNO "+
            "left join TF_TRADE_LIMIT tl on ps.SAMNO = tl.SAMNO  and ps.POSNO = tl.POSNO";

        ArrayList list = new ArrayList();
        if (selSource1.Text.Trim() != "")
        {
            list.Add("ps.USETYPECODE='" + selSource1.Text.Trim()+"'");
        }
        if (txtPsamNo1.Text.Trim() != "")
        {
            list.Add("ps.SAMNO in ( '" + GetSearchString(txtPsamNo1.Text) + "')");
            //list.Add("ps.SAMNO in ( '" + txtPsamNo1.Text + "','"+ txtPsamNo1.Text + "0000')");
        }
        if (txtPosNo1.Text.Trim() != "")
        {
            list.Add("ps.POSNO like '" + GetSearchString(txtPosNo1.Text.Trim()) + "'");
        }
        if (selCalling1.SelectedValue != "")
        {
            list.Add("ps.CALLINGNO='" + selCalling1.SelectedValue + "'");
        }
        if (selCorp1.SelectedValue != "")
        {
            list.Add("ps.CORPNO='" + selCorp1.SelectedValue + "'");
        }
        if (selDept1.SelectedValue != "")
        {
            list.Add("ps.DEPARTNO='" + selDept1.SelectedValue + "'");
        }
        string strBeginDate = txtStartDate.Text.Trim();
        if(strBeginDate != ""){
            DateTime beginDate = DateTime.ParseExact(strBeginDate, "yyyy-MM-dd", null);
            list.Add("ps.TAKETIME >= to_date('" + beginDate+"','yyyy-mm-dd hh24:mi:ss')");
        }
        string strEndDate = txtEndDate.Text.Trim();
        if (strEndDate != "")
        {
            DateTime endDate = DateTime.ParseExact(strEndDate, "yyyy-MM-dd", null);
            endDate = endDate.AddDays(1);
            list.Add("ps.TAKETIME < to_date('" + endDate+"','yyyy-mm-dd hh24:mi:ss')");
        }

        list.Add("rownum<1001  ");

        string where = DealString.ListToWhereStr(list);
        strSql = strSql + where;

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoPsamPosRec, null, strSql, 0);
        DataView dataView = new DataView(data);

        lvwRelation.DataKeyNames = new string[] { "PSAMNO", "POSNO", "CALLINGNO", "CORPNO", "DEPARTNO", "SERMANAGERCODE", "BALUNITNO", "USETYPECODE", "BUILDTIME", "CALLING", "CORP", "DEPT", "MANAGER", "BALANCEUNIT", "NOTE", "tlsamno" };
        lvwRelation.DataSource = dataView;
        lvwRelation.DataBind();

        lvwRelation.SelectedIndex = -1;
        ClearData();
    }

    private void ClearData()
    {
        selSource2.SelectedValue = "";
        txtPosNo2.Text = "";
        txtPsamNo2.Text = "";
        selCalling2.SelectedValue = "";
        selCorp2.Items.Clear();
        selDept2.Items.Clear();
        selManager.SelectedValue = "";
        selBalanceUnit.Items.Clear();
        selUnit.Items.Clear();
        txtNote.Text = "";
        chkIsLimit.Checked = false;
    }

    //建立关联关系
    protected void btnBuild_Click(object sender, EventArgs e)
    {
        //输入判断
        if (!ValidateForBuild())
            return;

        //非油品结算单元判断
        if (selPsamJointUse.SelectedValue == "1")
        {
            if (selUnit.SelectedValue == "")
            {
                context.AddError("A006500012", selPsamJointUse);
                return;
            }
        }

        //调用建立关联关系存储过程
        SP_EM_BuildRelationPDO pdo = new SP_EM_BuildRelationPDO();
        pdo.posNo = txtPosNo2.Text.Trim();
        pdo.psamNo = txtPsamNo2.Text.Trim();
        pdo.callingNo = selCalling2.SelectedValue;
        pdo.corpNo = selCorp2.SelectedValue;
        pdo.deptNo = selDept2.SelectedValue;
        pdo.svcMgrNo = selManager.SelectedValue;
        pdo.posSource = selSource2.SelectedValue;
        pdo.balUnitNo = selBalanceUnit.SelectedValue;
        pdo.UnitNo = selUnit.SelectedValue;
        pdo.note = txtNote.Text.Trim();
        pdo.psamType = selPsamJointUse.SelectedValue;

        pdo.isTradeLimit = chkIsLimit.Checked == true ? "1" : "0"; //1是允许联机消费   add by youyue 20131024

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M006500200");

            lvwRelation.SelectedIndex = -1;
            ClearData();
        }
     
    }

    //更换关联关系
    protected void btnChange_Click(object sender, EventArgs e)
    {
        //输入判断
        if (!ValidateForChange())
            return;

        //非油品结算单元判断
        if (selPsamJointUse.SelectedValue == "1")
        {
            if (selUnit.SelectedValue == "")
            {
                context.AddError("A006500012", selPsamJointUse);
                return;
            }
        }

        //调用更换关联关系存储过程
        SP_EM_ChangeRelationPDO pdo = new SP_EM_ChangeRelationPDO();
        pdo.newPosNo = txtPosNo2.Text.Trim();
        pdo.newPsamNo = txtPsamNo2.Text.Trim();
        pdo.oldPosNo = getDataKeys("POSNO");
        pdo.oldPsamNo = getDataKeys("PSAMNO");
        pdo.callingNo = selCalling2.SelectedValue;
        pdo.corpNo = selCorp2.SelectedValue;
        pdo.deptNo = selDept2.SelectedValue;
        pdo.svcMgrNo = selManager.SelectedValue;
        pdo.posSource = selSource2.SelectedValue;
        pdo.balUnitNo = selBalanceUnit.SelectedValue;
        pdo.UnitNo = selUnit.SelectedValue;
        pdo.note = txtNote.Text.Trim();
        pdo.psamType = selPsamJointUse.SelectedValue;

        pdo.isTradeLimit = chkIsLimit.Checked == true ? "1" : "0"; //1是允许联机消费   add by youyue 20131024

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M006500201");

            lvwRelation.SelectedIndex = -1;
            ClearData();
            btnQuery_Click(sender, e);
        }

    }

    //终止关联关系
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        //输入判断
        if (!ValidateForCancel())
            return;

        //调用终止关联关系存储过程
        SP_EM_CancelRelationPDO pdo = new SP_EM_CancelRelationPDO();
        pdo.posNo = txtPosNo2.Text.Trim();
        pdo.psamNo = txtPsamNo2.Text.Trim();
        pdo.callingNo = selCalling2.SelectedValue;
        pdo.corpNo = selCorp2.SelectedValue;
        pdo.deptNo = selDept2.SelectedValue;
        pdo.svcMgrNo = selManager.SelectedValue;
        pdo.posSource = selSource2.SelectedValue;
        pdo.balUnitNo = selBalanceUnit.SelectedValue;
        pdo.note = txtNote.Text.Trim();

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M006500202");

            lvwRelation.SelectedIndex = -1;
            ClearData();
        }

    }

    //查询输入判断
    private bool ValidateForQuery()
    {
        Validation valid = new Validation(context);

        //PSAM
        string strPsamNo = txtPsamNo1.Text.Trim();
        if (strPsamNo != "")
        {
            //英文或数字
            if (!Validation.isCharNum(strPsamNo))
            {
                context.AddError("A006500001", txtPsamNo1);
            }
            //小于12位
            if (Validation.strLen(strPsamNo) > 12)
            {
                context.AddError("A006500002", txtPsamNo1);
            }

        }

        //当POS非空时，进行数字、长度判断
        string strPosNo = txtPosNo1.Text.Trim();
        if (strPosNo != "")
        {
            if (!Validation.isNum(strPosNo))
            {
                context.AddError("A006500003", txtPosNo1);
            }
            if (Validation.strLen(strPosNo) > 6)
            {
                context.AddError("A006500004", txtPosNo1);
            }
        }
        
        DateTime? dateEff = null, dateExp = null;

        string strBeginDate = txtStartDate.Text.Trim();
        string strEndDate = txtEndDate.Text.Trim();
        //起始日期非空时格式判断
        if(strBeginDate != "")
            dateEff = beDate(txtStartDate, "A006500023");

        //终止日期非空时格式判断
        if(strEndDate != "")
            dateExp = beDate(txtEndDate, "A006500024");

        //起始日期不能大于终止日期
        if (dateEff != null && dateExp != null && dateEff.Value.CompareTo(dateExp.Value) > 0)
            context.AddError("A006500021");

        if (context.hasError())
            return false;
        else
            return true;
    }

    public DateTime? beDate(TextBox tb, String errCode)
    {
        tb.Text = tb.Text.Trim();

        if (!Validation.isDate(tb.Text))
        {
            context.AddError(errCode, tb);
            return null;
        }

        return DateTime.ParseExact(tb.Text, "yyyy-MM-dd", null); ;
    }

    //建立关联关系输入判断
    private bool ValidateForBuild()
    {
        //
        string strSource = selSource2.SelectedValue;
        string strPosNo = txtPosNo2.Text.Trim();
        if (strSource == "")
        {
            //当POS来源为空时，POS编号必须也为空
            if (strPosNo != "")
                context.AddError("A006500005", txtPosNo2);
        }
        else
        {
            //当POS来源非空时，POS编号必须也非空
            if (strPosNo == "")
                context.AddError("A006500006", txtPosNo2);
            else
            {
                //POS编号数字、长度判断
                if (!Validation.isNum(strPosNo))
                    context.AddError("A006500025", txtPosNo2);

                if (Validation.strLen(strPosNo) != 6)
                    context.AddError("A006500007", txtPosNo2);

            }
        }

        //PSAM卡不能为空，且须是英数、长度不大于12位
        string strPsamNo = txtPsamNo2.Text.Trim();
        if (strPsamNo == "")
            context.AddError("A006500008", txtPsamNo2);
        else
        {
            if (!Validation.isCharNum(strPsamNo))
            {
                context.AddError("A006500009", txtPsamNo2);
            }
            if (Validation.strLen(strPsamNo) > 12)
            {
                context.AddError("A006500010", txtPsamNo2);
            }
        }

        //行业非空判断
        string strCalling = selCalling2.SelectedValue;
        if (strCalling == "")
            context.AddError("A006500011", selCalling2);

        //结算单元非空判断
        string strBalUnit = selBalanceUnit.SelectedValue;
        if (strBalUnit == "")
            context.AddError("A006500012", selBalanceUnit);

        //商户经理非空判断
        string strManager = selManager.SelectedValue;
        if (strManager == "")
            context.AddError("A006500013", selManager);

        //当备注非空时，长度判断
        string strNote = txtNote.Text.Trim();
        if (strNote != "" && Validation.strLen(strNote) > 100)
            context.AddError("A006500014", txtNote);

        if (context.hasError())
            return false;
        else
            return true;
    }

    //终止关联关系输入判断
    private bool ValidateForCancel()
    {
        //判断是否选择记录
        if (lvwRelation.SelectedIndex == -1)
        {
            context.AddError("A006500015");
            return false;
        }

        //POS领用方式、POS编号、PSAM卡号、行业、单位、部门、结算单元、商户经理 不能修改
        if( selSource2.SelectedValue != getDataKeys("USETYPECODE")
            || txtPosNo2.Text.Trim() != getDataKeys("POSNO")
            || txtPsamNo2.Text.Trim() != getDataKeys("PSAMNO")
            || selCalling2.SelectedValue != getDataKeys("CALLINGNO")
            || selCorp2.SelectedValue != getDataKeys("CORPNO")
            || selDept2.SelectedValue != getDataKeys("DEPARTNO")
            || selBalanceUnit.SelectedValue != getDataKeys("BALUNITNO")
            || selManager.SelectedValue != getDataKeys("SERMANAGERCODE")
        )
        {
            context.AddError("A006500020");
        }

        if (context.hasError())
            return false;
        else
            return true;
            
    }

    //更换关联关系输入判断
    private bool ValidateForChange()
    {
        //判断是否选择记录
        if (lvwRelation.SelectedIndex == -1)
        {
            context.AddError("A006500015");
            return false;
        }

        //PSAM卡号不能为空
        string strPsamNo = txtPsamNo2.Text.Trim();
        if (strPsamNo == "")
            context.AddError("A006500008", txtPsamNo2);
        else
        {
            if (!Validation.isCharNum(strPsamNo))
            {
                context.AddError("A006500009", txtPsamNo2);
            }
            if (Validation.strLen(strPsamNo) > 12)
            {
                context.AddError("A006500010", txtPsamNo2);
            }
        }

        //PSAM卡号、POS编号至少有一项被修改
        //if (txtPosNo2.Text.Trim() == getDataKeys("POSNO") && txtPsamNo2.Text.Trim() == getDataKeys("PSAMNO"))
        //    context.AddError("A006500022");

        if(txtPosNo2.Text.Trim() != getDataKeys("POSNO") && txtPsamNo2.Text.Trim() != getDataKeys("PSAMNO"))
            context.AddError("A006500026");

        //当备注非空时，长度判断
        string strNote = txtNote.Text.Trim();
        if (strNote != "" && Validation.strLen(strNote) > 100)
            context.AddError("A006500014", txtNote);

        //行业、单位、部门、结算单元、商户经理 不能被修改
        if ( selCalling2.SelectedValue != getDataKeys("CALLINGNO")
            || selCorp2.SelectedValue != getDataKeys("CORPNO")
            || selDept2.SelectedValue != getDataKeys("DEPARTNO")
            || selBalanceUnit.SelectedValue != getDataKeys("BALUNITNO")
            || selManager.SelectedValue != getDataKeys("SERMANAGERCODE")
        )
        {
            context.AddError("A006500017");
        }

        //POS来源、POS编号必须同时为空或同时不为空
        string strPosNo = txtPosNo2.Text.Trim();
        string strSource = selSource2.SelectedValue;
        if (strPosNo == "")
        {
            if (strSource != "")
                context.AddError("A006500006", selSource2);

        }
        else
        {
            if(strSource == "")
                context.AddError("A006500005", txtPosNo2);

            if (!Validation.isNum(strPosNo))
                context.AddError("A006500025", txtPosNo2);

            if(Validation.strLen(strPosNo)>6)
                context.AddError("A006500007", txtPosNo2);
        }
        if (strSource == "" && strPosNo != "") 
            context.AddError("A006500005", txtPosNo2);

        if (context.hasError())
            return false;
        else
            return true;

    }

    private string GetSearchString(string str)
    {
        return str.Trim() + "%";
    }

}
