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
using Common;
using PDO.Financial;
using Master;

public partial class ASP_Financial_FI_CardManagerReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            selType.Items.Add(new ListItem("售卡统计", "CardSaleStat"));
            selType.Items.Add(new ListItem("充值统计", "ChargeCardStat"));
            selType.Items.Add(new ListItem("换卡统计", "ChangeCardStat"));
            selType.Items.Add(new ListItem("退卡统计", "ReturnCardStat"));
            selType.Items.Add(new ListItem("卡使用统计", "Cardusestate"));
            selType.Items.Add(new ListItem("集团客户统计", "groupcuststate"));

            DateTime tf = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, 1);
            DateTime tt = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, DateTime.DaysInMonth(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month));

            txtFromDate.Text = tf.ToString("yyyyMMdd");
            txtToDate.Text = tt.ToString("yyyyMMdd");
        }
    }
    private void validate()
    {
        Validation valid = new Validation(context);

        bool b = Validation.isEmpty(txtFromDate);
        DateTime? fromDate = null, toDate = null;
        if (!b)
        {
            fromDate = valid.beDate(txtFromDate, "开始日期范围起始值格式必须为yyyyMMdd");
        }
        b = Validation.isEmpty(txtToDate);
        if (!b)
        {
            toDate = valid.beDate(txtToDate, "结束日期范围终止值格式必须为yyyyMMdd");
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        }

    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        UserCardHelper.resetData(gvResult, null);

        validate();
        if (context.hasError()) return;

        SP_FI_StatPDO pdo = new SP_FI_StatPDO();
        pdo.funcCode = selType.SelectedValue;
        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        labTitle.Text = selType.SelectedItem.Text;
        //hidNo.Value = pdo.var9;

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
            btnPrint.Enabled = false;
        }
        else
        {
            btnPrint.Enabled = true;
        }

        UserCardHelper.resetData(gvResult, data);
    }
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
    protected void lvwQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
    }
}
