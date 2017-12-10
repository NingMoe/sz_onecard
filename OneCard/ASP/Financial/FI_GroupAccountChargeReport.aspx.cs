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
using PDO.Financial;
using Master;
using Common;
using TM;
using TDO.UserManager;

public partial class ASP_Financial_FI_GroupAccountChargeReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期

            txtFromDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
            //初始化部门

            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
            TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
            ControlDeal.SelectBoxFill(supplyDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
            supplyDept.SelectedValue = context.s_DepartID;
        }
    }

    private double totalCharges = 0;

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            totalCharges += Convert.ToDouble(GetTableCellValue(e.Row.Cells[3]));
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[3].Text = totalCharges.ToString("n");
        }
    }
    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }
    // 查询输入校验处理
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

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        UserCardHelper.resetData(gvResult, null);

        validate();
        if (context.hasError()) return;

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "GROUP_INCOME_REPORT";
        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;
        string dept = "";
        if(supplyDept.SelectedIndex>0)
        {
            dept = supplyDept.SelectedValue;
        }
        pdo.var3 = dept;

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);
        hidNo.Value = pdo.var9;

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
            btnPrint.Enabled = false;
        }
        else
        {
            btnPrint.Enabled = true;
        }

        totalCharges = 0;
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
}
