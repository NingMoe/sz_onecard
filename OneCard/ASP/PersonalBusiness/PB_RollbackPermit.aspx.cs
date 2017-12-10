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
using TDO.UserManager;
using Common;
using TDO.PersonalTrade;
using PDO.PersonalBusiness;

public partial class ASP_PersonalBusiness_PB_RollbackPermit : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            TMTableModule tmTMTableModule = new TMTableModule();

            //领用部门
            TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTTDOIn = new TD_M_INSIDEDEPARTTDO();
            TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTTDOOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTTDOIn, typeof(TD_M_INSIDEDEPARTTDO), null, null,  " WHERE USETAG = '1' ORDER BY DEPARTNO");
            ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTTDOOutArr, "DEPARTNAME", "DEPARTNO", true);

            selTRADETYPE.Items.Add(new ListItem("02:现金充值", "02"));
            selTRADETYPE.Items.Add(new ListItem("14:充值卡充值", "14"));

            selCancelTag.Items.Add(new ListItem("---请选择---",""));
            selCancelTag.Items.Add(new ListItem("已授权","0"));
            selCancelTag.Items.Add(new ListItem("已返销","1"));

            //设置lvwSupply绑定的DataTable
            lvwSupply.DataSource = new DataTable();
            lvwSupply.DataBind();
            lvwSupply.SelectedIndex = -1;

            //指定lvwSupply DataKeyNames
            lvwSupply.DataKeyNames = new string[] { "ID", "CARDNO", "SUPPLYMONEY", "XFCARDNO", 
                "STAFFNO", "OPERATETIME","CANCELTAG","CANCELSTAFF" };

            //设置lvwRetrade绑定的DataTable
            lvwRetrade.DataSource = new DataTable();
            lvwRetrade.DataBind();
            lvwRetrade.SelectedIndex = -1;

            //指定lvwRetrade DataKeyNames
            lvwRetrade.DataKeyNames = new string[] { "TRADEID", "CARDNO", "STAFFNO", "OPERATETIME" };
        }
    }
    protected void selDept_Changed(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        tdoTD_M_INSIDESTAFFIn.DEPARTNO = selDept.SelectedValue;
        TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
        ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //查询充值台帐
        lvwSupply.DataSource = CreateSupplyDataSource();
        lvwSupply.DataBind();

        //查询补写卡台帐
        lvwRetrade.DataSource = CreateRetradeDataSource();
        lvwRetrade.DataBind();
    }

    //充值台帐查询
    public void lvwSupply_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwSupply.PageIndex = e.NewPageIndex;
        lvwSupply.DataSource = CreateSupplyDataSource();
        lvwSupply.DataBind();
    }
    public ICollection CreateSupplyDataSource()
    {
        DataTable dataSupply = SPHelper.callPBQuery(context, "RollbackPermit",
                    selTRADETYPE.SelectedValue,txtCardno.Text,
                    selStaff.SelectedValue, OperateTime.Text, selCancelTag.SelectedValue);
        DataView dataView = new DataView(dataSupply);
        return dataView;

    }
    protected void lvwSupply_RowCreated(object sender, GridViewRowEventArgs e)
    {

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwSupply','Select$" + e.Row.RowIndex + "')");
        }
    }
    
    public String getDataKeys(string keysname)
    {
        return lvwSupply.DataKeys[lvwSupply.SelectedIndex][keysname].ToString();
    }
    protected void lvwSupply_SelectedIndexChanged(object sender, EventArgs e)
    {
        hiddenTRADEID.Value = getDataKeys("ID");
        string canceltag = getDataKeys("CANCELTAG");
        if (canceltag == "已授权")
        {
            btnPermit.Text = "取消授权";
            btnPermit.Enabled = true;
        }
        else if (canceltag == "已返销")
        {
            btnPermit.Text = "允许返销";
            btnPermit.Enabled = false;
        }
        else
        {
            btnPermit.Text = "允许返销";
            btnPermit.Enabled = true;
        }

    }
    

    //补写卡业务台帐查询
    public void lvwRetrade_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwRetrade.PageIndex = e.NewPageIndex;
        lvwRetrade.DataSource = CreateRetradeDataSource();
        lvwRetrade.DataBind();
    }
    public ICollection CreateRetradeDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        TF_CARD_RETRADETDO ddoTF_CARD_RETRADEIn = new TF_CARD_RETRADETDO();
        string strRetrade = " Select a.ID TRADEID, a.CARDNO, b.STAFFNAME STAFFNO, a.OPERATETIME "+
                            " FROM TF_CARD_RETRADE a, TD_M_INSIDESTAFF b ";

        ArrayList list = new ArrayList();

        list.Add("a.OPERATESTAFFNO = b.STAFFNO");

        if (txtCardno.Text != "")
            list.Add("a.CARDNO = '" + txtCardno.Text + "'");

        if (selStaff.Text != "")
        {
            list.Add(" a.OPERATESTAFFNO = '" + selStaff.SelectedValue + "'");
        }

        if (OperateTime.Text != "")
        {
            list.Add(" a.OPERATETIME BETWEEN TO_DATE('" + Convert.ToDateTime(OperateTime.Text) + "','YYYY-MM-DD HH24:MI:SS') " +
                    " AND TO_DATE('" + Convert.ToString(Convert.ToDateTime(OperateTime.Text).AddDays(1)) + "','YYYY-MM-DD HH24:MI:SS') ");
        }

        strRetrade += DealString.ListToWhereStr(list);

        strRetrade += " ORDER BY a.OPERATETIME DESC";

        DataTable dataRetrade = tmTMTableModule.selByPKDataTable(context, ddoTF_CARD_RETRADEIn, null, strRetrade, 1000);
        DataView dataView = new DataView(dataRetrade);
        return dataView;
    }

    protected void btnPermit_Click(object sender, EventArgs e)
    {
        if (hiddenTRADEID.Value == "" || hiddenTRADEID.Value == null)
        {
            context.AddError("A001024102");
            return;
        }
        
        SP_PB_RollbackPermitPDO pdo = new SP_PB_RollbackPermitPDO();

        pdo.CANCELTRADEID = hiddenTRADEID.Value;


        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            if (btnPermit.Text == "允许返销")
                AddMessage("M001024100");
            else if (btnPermit.Text == "取消授权")
                AddMessage("M001024101");

            btnPermit.Enabled = false;

            lvwSupply.DataSource = new DataTable();
            lvwSupply.DataBind();
            lvwSupply.SelectedIndex = -1;

            lvwRetrade.DataSource = new DataTable();
            lvwRetrade.DataBind();
            lvwRetrade.SelectedIndex = -1;

        }
    }
}
