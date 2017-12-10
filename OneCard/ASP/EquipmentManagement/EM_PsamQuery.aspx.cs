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

public partial class ASP_EquipmentManagement_EM_PsamQuery : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化行业
            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
            TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), null);

            ControlDeal.SelectBoxFill(selCalling2.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);

            // 初始化状态
            TD_M_RESOURCESTATETDO tdoTD_M_RESOURCESTATETDOIn = new TD_M_RESOURCESTATETDO();
            TD_M_RESOURCESTATETDO[] tdoTD_M_RESOURCESTATETDOOutArr = (TD_M_RESOURCESTATETDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_RESOURCESTATETDOIn, typeof(TD_M_RESOURCESTATETDO), null, "TD_M_RESOURCESTATETDO", null);
            ControlDeal.SelectBoxFill(selPsamState.Items, tdoTD_M_RESOURCESTATETDOOutArr, "RESSTATE", "RESSTATECODE", true);

            //PSAM库存查询表头
            DataTable psamData = new DataTable();
            DataView psamDataView = new DataView(psamData);

            lvwPsam.DataKeyNames = new string[] { "PSAMNO", "COSTYPE", "CARDTYPE", "CARDPRICE", "CARDMANU", "RESSTATE", "CALLING", "CORP", "DEPT", "INSTIME", "OUTTIME", "REINTIME", "DESTROYTIME", "ASSIGNEDSTAFF" };
            lvwPsam.DataSource = psamDataView;
            lvwPsam.DataBind();
        }
    }

    //选择行业时，初始化单位、部门
    protected void selCalling2_SelectedIndexChanged(object sender, EventArgs e)
    {
        selDept2.Items.Clear();
        if (selCalling2.SelectedValue == "")
        {
            selCorp2.Items.Clear();
            return;
        }
        InitCorp(selCalling2, selCorp2, "TD_M_CORPCALLUSAGE");
    }

    //选择单位时，初始化部门
    protected void selCorp2_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (selCorp2.SelectedValue == "")
        {
            selDept2.Items.Clear();
            return;
        }
        InitDepart(selCorp2, selDept2, "TD_M_DEPARTUSAGE");
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

    //查询
    protected void btnPsamQuery_Click(object sender, EventArgs e)
    {
        //输入验证
        if (!ValidateForPsamQuery())
            return;

        //查询
        TMTableModule tmTMTableModule = new TMTableModule();
        TL_R_ICOTHERTDO ddoTL_R_ICOTHERTDOIn = new TL_R_ICOTHERTDO();

        string strSql = "SELECT p.CARDNO PSAMNO,c.COSTYPE COSTYPE,p.CARDTYPECODE CARDTYPE,p.CARDPRICE CARDPRICE,f.MANUNAME CARDMANU,s.RESSTATE RESSTATE," +
            "h.CALLING CALLING,a.CORP CORP,r.DEPART DEPT,p.INSTIME INSTIME,p.OUTTIME OUTTIME,p.REINTIME REINTIME,p.DESTROYTIME DESTROYTIME,e.STAFFNAME ASSIGNEDSTAFF " +
            "FROM TL_R_ICOTHER p left join TD_M_COSTYPE c on p.COSTYPECODE=c.COSTYPECODE " +
            "left join TD_M_MANU f on p.MANUTYPECODE=f.MANUCODE " +
            "left join TD_M_RESOURCESTATE s on p.RESSTATECODE=s.RESSTATECODE " +
            "left join TD_M_CALLINGNO h on p.CALLINGNO=h.CALLINGNO " +
            "left join TD_M_CORP a on p.CORPNO=a.CORPNO " +
            "left join TD_M_DEPART r on p.DEPARTNO=r.DEPARTNO " +
            "left join TD_M_INSIDESTAFF e on p.ASSIGNEDSTAFFNO=e.STAFFNO ";

        ArrayList list = new ArrayList();
        if (txtPsamNo.Text.Trim() != "")
            list.Add("p.CARDNO like '" + GetSearchString(txtPsamNo.Text) + "'");
            //list.Add("p.CARDNO like '%" + txtPsamNo.Text.Trim() + "%'");

        if (selCalling2.SelectedValue != "")
            list.Add("p.CALLINGNO='" + selCalling2.SelectedValue + "'");

        if (selCorp2.SelectedValue != "")
            list.Add("p.CORPNO='" + selCorp2.SelectedValue + "'");

        if (selDept2.SelectedValue != "")
            list.Add("p.DEPARTNO='" + selDept2.SelectedValue + "'");

        if (selPsamState.SelectedValue != "")
            list.Add("p.RESSTATECODE='" + selPsamState.SelectedValue + "'");

        list.Add("rownum<200");

        strSql += DealString.ListToWhereStr(list);

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTL_R_ICOTHERTDOIn, null, strSql, 0);
        DataView dataView = new DataView(data);

        lvwPsam.DataSource = dataView;
        lvwPsam.DataBind();
    }

    public void lvwPsam_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwPsam.PageIndex = e.NewPageIndex;
        btnPsamQuery_Click(sender, e);
    }

    //输入验证
    private bool ValidateForPsamQuery()
    {
        string strPsamNo = txtPsamNo.Text.Trim();
        if (strPsamNo != "")
        {
            //当PSAM卡号非空时，判断是否为英数，长度小于12
            if (!Validation.isCharNum(strPsamNo))
                context.AddError("A006400003", txtPsamNo);
            //if(!IsSearchString(strPsamNo))
                //context.AddError("A006400003", txtPsamNo);

            if (Validation.strLen(strPsamNo) > 12)
                context.AddError("A006400004", txtPsamNo);
        }

        if (context.hasError())
            return false;
        else
            return true;
    }

    private string GetSearchString(string str)
    {
        return str.Trim() + "%";
    }

    protected void lvwPsam_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string s = e.Row.Cells[12].Text;
            if (Validation.isPrice(s))
                e.Row.Cells[12].Text = (Convert.ToDouble(s) / 100).ToString("0.00");
            else
                e.Row.Cells[12].Text = "";
        }
    }
}
