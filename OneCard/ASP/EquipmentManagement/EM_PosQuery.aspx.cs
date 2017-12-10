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
using TDO.ResourceManager;
using TDO.BalanceChannel;
using Common;

public partial class ASP_EquipmentManagement_EM_PosQuery : Master.Master
{
 
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化行业
            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
            TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), null);

            ControlDeal.SelectBoxFill(selCalling1.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);

            // 初始化状态
            TD_M_RESOURCESTATETDO tdoTD_M_RESOURCESTATETDOIn = new TD_M_RESOURCESTATETDO();
            TD_M_RESOURCESTATETDO[] tdoTD_M_RESOURCESTATETDOOutArr = (TD_M_RESOURCESTATETDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_RESOURCESTATETDOIn, typeof(TD_M_RESOURCESTATETDO), null, "TD_M_RESOURCESTATETDO", null);
            ControlDeal.SelectBoxFill(selPosState.Items, tdoTD_M_RESOURCESTATETDOOutArr, "RESSTATE", "RESSTATECODE", true);

            //初始化POS来源
            EMHelper.setSource(selSource);

            //POS库存查询表头
            initPosList();
        }  
    }

    //表头
    private void initPosList()
    {
        DataTable posData = new DataTable();
        DataView posDataView = new DataView(posData);

        lvwPos.DataKeyNames = new string[] { "POSNO", "POSSOURCE", "POSMODE", "TOUCHTYPE", "LAYTYPE", "COMMTYPE", "EQUPRICE", "HARDWARENUM", "RESSTATE", "CALLING", "CORP", "DEPT", "INSTIME", "OUTTIME", "REINTIME", "DESTROYTIME", "ASSIGNEDSTAFF" };
        lvwPos.DataSource = posDataView;
        lvwPos.DataBind();
    }
    
    //选择行业时，初始化单位和部门
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

    //初始化单位
    protected void InitCorp(DropDownList father, DropDownList target, String sqlCondition)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
        tdoTD_M_CORPIn.CALLINGNO = father.SelectedValue;

        TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, sqlCondition, null);
        ControlDeal.SelectBoxFill(target.Items, tdoTD_M_CORPOutArr, "CORP", "CORPNO", true);
    }

    //初始化部门
    private void InitDepart(DropDownList corp, DropDownList dept, String sqlCondition)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //从部门编码表(TD_M_CDEPART)中读取数据，放入下拉列表中

        TD_M_DEPARTTDO tdoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
        tdoTD_M_DEPARTIn.CORPNO = corp.SelectedValue;

        TD_M_DEPARTTDO[] tdoTD_M_DEPARTOutArr = (TD_M_DEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null, sqlCondition, null);
        ControlDeal.SelectBoxFill(dept.Items, tdoTD_M_DEPARTOutArr, "DEPART", "DEPARTNO", true);

    }

    protected void lvwPos_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwPos','Select$" + e.Row.RowIndex + "')");
        }
    }

    public void lvwPos_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwPos.PageIndex = e.NewPageIndex;
        btnPosQuery_Click(sender, e);
    }

    protected void btnPosQuery_Click(object sender, EventArgs e)
    {
        //输入判断
        if (!ValidateForPosQuery())
            return;

        TMTableModule tmTMTableModule = new TMTableModule();
        TL_R_EQUATDO ddoTL_R_EQUATDOIn = new TL_R_EQUATDO();

        string strSql = "SELECT p.POSNO POSNO,p.EQUSOURCE POSSOURCE,m.POSMODE POSMODE,t.TOUCHTYPE TOUCHTYPE,l.LAYTYPE LAYTYPE,c.COMMTYPE COMMTYPE,p.EQUPRICE EQUPRICE,p.POSHARDWARENUM HARDWARENUM," +
            "s.RESSTATE RESSTATE,h.CALLING CALLING,a.CORP CORP,r.DEPART DEPT,p.INSTIME INSTIME,p.OUTTIME OUTTIME,p.REINTIME REINTIME,p.DESTROYTIME DESTROYTIME,e.STAFFNAME ASSIGNEDSTAFF " +
            "FROM TL_R_EQUA p left join TD_M_POSTOUCHTYPE t on p.TOUCHTYPECODE=t.TOUCHTYPECODE " +
            "left join TD_M_POSMODE m on p.POSMODECODE=m.POSMODECODE " +
            "left join TD_M_POSLAYTYPE l on p.LAYTYPECODE=l.LAYTYPECODE " +
            "left join TD_M_POSCOMMTYPE c on p.COMMTYPECODE=c.COMMTYPECODE " +
            "left join TD_M_RESOURCESTATE s on p.RESSTATECODE=s.RESSTATECODE " +
            "left join TD_M_CALLINGNO h on p.CALLINGNO=h.CALLINGNO " +
            "left join TD_M_CORP a on p.CORPNO=a.CORPNO " +
            "left join TD_M_DEPART r on p.DEPARTNO=r.DEPARTNO " +
            "left join TD_M_INSIDESTAFF e on p.ASSIGNEDSTAFFNO=e.STAFFNO ";

        ArrayList list = new ArrayList();
        if (txtPosNo.Text.Trim() != "")
            list.Add("p.POSNO like '"+ GetSearchString(txtPosNo.Text.Trim())+"'");

        if (selCalling1.SelectedValue != "")
            list.Add("p.CALLINGNO='" + selCalling1.SelectedValue + "'");

        if (selCorp1.SelectedValue != "")
            list.Add("p.CORPNO='" + selCorp1.SelectedValue + "'");

        if (selDept1.SelectedValue != "")
            list.Add("p.DEPARTNO='" + selDept1.SelectedValue + "'");

        if (selPosState.SelectedValue != "")
            list.Add("p.RESSTATECODE='" + selPosState.SelectedValue + "'");

        if (selSource.SelectedValue != "")
            list.Add("p.EQUSOURCE='" + selSource.SelectedValue + "'");

        list.Add("rownum<200");

        strSql += DealString.ListToWhereStr(list);

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTL_R_EQUATDOIn, null, strSql, 0);
        DataView dataView = new DataView(data);

        lvwPos.DataSource = dataView;
        lvwPos.DataBind();
    }


    //输入验证
    private bool ValidateForPosQuery()
    {
        //POS编号必须为数字、6位
        string strPosNo = txtPosNo.Text.Trim();
        if (strPosNo != "")
        {
            if (!Validation.isNum(strPosNo))
                context.AddError("A006400001", txtPosNo);

            if (Validation.strLen(strPosNo) > 6)
                context.AddError("A006400002", txtPosNo);
        }

        if (context.hasError())
            return false;
        else
            return true;
    }

    protected void lvwPos_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string s = e.Row.Cells[15].Text;
            if (Validation.isPrice(s))
                e.Row.Cells[15].Text = (Convert.ToDouble(s) / 100).ToString("0.00");
            else
                e.Row.Cells[15].Text = "";
            
        }
    }

    private string GetSearchString(string str)
    {
        return str.Trim() + "%";
    }

}
