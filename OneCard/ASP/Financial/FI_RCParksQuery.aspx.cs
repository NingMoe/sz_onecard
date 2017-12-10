using System;
using System.Data;
using System.Web.UI;
using Common;
using PDO.Financial;
using Master;
using System.Web.UI.WebControls;

public partial class ASP_Financial_FI_RCParksQuery : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化期数列表
            InitDateList();
            InitTypeList();

            //初始化列表
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
        }
 
    }
    //初始化期数列表
    private void InitDateList()
    {
        string sysdate = DateTime.Today.ToString("yyyyMM");
        string year = sysdate.Substring(0,4);
        string month = sysdate.Substring(4,2);
        if (Int32.Parse(month) > 6)//如果系统时间201607-201612下拉期数为201606，201512，201506，201412
        {
            selDate.Items.Add(new ListItem(year + "06", year + "06"));
            selDate.Items.Add(new ListItem((Int32.Parse(year) - 1).ToString() + "12", (Int32.Parse(year) - 1).ToString() + "12"));
            selDate.Items.Add(new ListItem((Int32.Parse(year) - 1).ToString() + "06", (Int32.Parse(year) - 1).ToString() + "06"));
            selDate.Items.Add(new ListItem((Int32.Parse(year) - 2).ToString() + "12", (Int32.Parse(year) - 2).ToString() + "12"));
        }
        else//如果系统时间201601-201606,下拉期数为201512，201506，201412，201406
        {
            selDate.Items.Add(new ListItem((Int32.Parse(year) - 1).ToString() + "12", (Int32.Parse(year) - 1).ToString() + "12"));
            selDate.Items.Add(new ListItem((Int32.Parse(year) - 1).ToString() + "06", (Int32.Parse(year) - 1).ToString() + "06"));
            selDate.Items.Add(new ListItem((Int32.Parse(year) - 2).ToString() + "12", (Int32.Parse(year) - 2).ToString() + "12"));
            selDate.Items.Add(new ListItem((Int32.Parse(year) - 2).ToString() + "06", (Int32.Parse(year) - 2).ToString() + "06"));
        }
    }
    //初始化套餐
    private void InitTypeList()
    {
        DataTable dt = GroupCardHelper.callOrderQuery(context, "PACKAGETYPE_QUERY");
        GroupCardHelper.fill(selType, dt, true);
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if(selType.SelectedValue=="")
        {
            context.AddError("查询套餐不可为空");
        }
        if (context.hasError()) return;
        string year = selDate.SelectedValue.ToString().Substring(0,4);
        string month = selDate.SelectedValue.ToString().Substring(4,2);
        string enddate = (Int32.Parse(year) + 1).ToString() + month;
        DataTable dt = GroupCardHelper.callOrderQuery(context, "RELAX_PARKS_QUERY", enddate, selType.SelectedValue);

        if (dt == null || dt.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");

        }
        UserCardHelper.resetData(gvResult, dt);
    }

   
    /// <summary>
    /// 导出
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            ExportGridView(gvResult);
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }
}