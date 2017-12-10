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
using TDO.PersonalTrade;
using PDO.PersonalBusiness;

public partial class ASP_PersonalBusiness_PB_TradefeeRollback : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //设置GridView绑定的DataTable
            lvwQuery.DataSource = new DataTable();
            lvwQuery.DataBind();
            lvwQuery.SelectedIndex = -1;

            //指定GridView DataKeyNames
            lvwQuery.DataKeyNames = new string[] { "TRADEID", "CARDNO", "TRADEMONEY", "OPERATESTAFF", "OPERATETIME" };

            initLoad(sender, e);
        }
    }

    protected void initLoad(object sender, EventArgs e)
    {
        lvwQuery.DataSource = CreateQueryDataSource();
        lvwQuery.DataBind();
        //if (lvwQuery.Rows.Count > 0)
        //{
        //    lvwQuery.SelectedIndex = 0;
        //}
    }
    public ICollection CreateQueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        TF_B_FEEROLLBACKTDO ddoTF_B_FEEROLLBACKIn = new TF_B_FEEROLLBACKTDO();
        string strSql = " SELECT a.TRADEID, a.CARDNO, a.CURRENTMONEY/100.0 TRADEMONEY, b.STAFFNAME OPERATESTAFF, a.OPERATETIME " +
                        " FROM TF_B_TRADE a, TD_M_INSIDESTAFF b,TF_B_FEEROLLBACK c WHERE a.OPERATESTAFFNO = b.STAFFNO " +
                        " AND a.TRADEID = c.CANCELTRADEID AND a.OPERATESTAFFNO = '" + context.s_UserID + "' "+
                        " AND c.CANCELTAG = '0' ORDER BY a.OPERATETIME DESC ";

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTF_B_FEEROLLBACKIn, null, strSql, 1000);
        DataView dataView = new DataView(data);
        return dataView;

    }
    public String getDataKeys(string keysname)
    {
        return lvwQuery.DataKeys[lvwQuery.SelectedIndex][keysname].ToString();
    }

    protected void lvwQuery_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择列表框一行记录后,得到该行记录的交易序号

        hiddenTradeid.Value = getDataKeys("TRADEID");
        hidCardno.Value = getDataKeys("CARDNO");

    }

    public void lvwQuery_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwQuery.PageIndex = e.NewPageIndex;
        lvwQuery.DataSource = CreateQueryDataSource();
        lvwQuery.DataBind();
    }

    protected void lvwQuery_RowCreated(object sender, GridViewRowEventArgs e)
    {

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwQuery','Select$" + e.Row.RowIndex + "')");
        }
    }
    
    protected void btnRollback_Click(object sender, EventArgs e)
    {
        if (hiddenTradeid.Value == "" || hiddenTradeid.Value == null)
        {
            context.AddError("A001025101");
            return;
        }

        SP_PB_TradefeeRollbackPDO pdo = new SP_PB_TradefeeRollbackPDO();
        pdo.CANCELTRADEID = hiddenTradeid.Value;
        pdo.ID = DealString.GetRecordID(hidCardno.Value.Substring(12, 4), hidCardno.Value);
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M001025100");
            foreach (Control con in this.Page.Controls)
            {
                ClearControl(con);
            }
            initLoad(sender, e);
        }
    }
}
