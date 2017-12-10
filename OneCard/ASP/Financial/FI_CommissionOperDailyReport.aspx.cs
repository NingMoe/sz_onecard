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
using TDO.UserManager;
using TDO.BalanceParameter;

public partial class ASP_Financial_FI_CommissionOperDailyReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期

            txtFromDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
            selectArea(context, selArea);
        }
    }

    private double amount = 0;
    private double amount2 = 0;
    private double commission = 0;
    private double commission_s = 0;
    private double rebrokerage = 0;
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            amount += Convert.ToDouble(GetTableCellValue(e.Row.Cells[4]));
            amount2 += Convert.ToDouble(GetTableCellValue(e.Row.Cells[5]));
            commission += Convert.ToDouble(GetTableCellValue(e.Row.Cells[6]));
            commission_s += Convert.ToDouble(GetTableCellValue(e.Row.Cells[7]));
            rebrokerage += Convert.ToDouble(GetTableCellValue(e.Row.Cells[8]));
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[4].Text = amount.ToString("n");
            e.Row.Cells[5].Text = amount2.ToString("n");
            e.Row.Cells[6].Text = commission.ToString("n");
            e.Row.Cells[7].Text = commission_s.ToString("n");
            e.Row.Cells[8].Text = rebrokerage.ToString("n");
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

    private bool checkEndDate()
    {
        TP_DEALTIMETDO tdoTP_DEALTIMEIn = new TP_DEALTIMETDO();
        TP_DEALTIMETDO[] tdoTP_DEALTIMEOutArr = (TP_DEALTIMETDO[])tm.selByPKArr(context, tdoTP_DEALTIMEIn, typeof(TP_DEALTIMETDO), null, "DEALTIME", null);
        if (tdoTP_DEALTIMEOutArr.Length == 0)
        {
            context.AddError("没有找到有效的结算处理时间");
            return false;
        }
        else
        {
            DateTime dealDate = tdoTP_DEALTIMEOutArr[0].DEALDATE.Date;
            DateTime endDate = DateTime.ParseExact(txtToDate.Text.Trim(), "yyyyMMdd", null);
            if (endDate.CompareTo(dealDate) >= 0)
            {
                context.AddError("结束日期过大，未结算");
                return false;
            }
        }
        return true;
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        // 查询输入校验处理
        validate();
        if (context.hasError()) return;

        //结算处理时间校验
        if (!checkEndDate()) return;

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "TRADECF_SERIALNO_DAILY_REPORT";
        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;
        pdo.var3 = context.s_UserID;
        pdo.var4 = selArea.SelectedValue;
        pdo.var5 = ddlMode.SelectedValue;//新增脱机联机 add by youyue20160712

        StoreProScene storePro = new StoreProScene();

        DataTable data = storePro.Execute(context, pdo);
        hidNo.Value = pdo.var9;

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
            btnPrint.Enabled = false;
        }

        amount = 0;
        amount2 = 0;
        commission = 0;
        commission_s = 0;
        rebrokerage = 0;
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

    public void selectArea(CmnContext context, DropDownList ddl)
    {
        ddl.Items.Add(new ListItem("---请选择---", ""));

        FIHelper.selectArea(context, ddl, "AREAQUERY", context.s_DepartID);

        if (ddl.Items.Count == 2)
        {
            ddl.SelectedIndex = 1;
            ddl.Enabled = false;
        }
        if (ddl.Items.Count == 1)
        {
            context.AddError("S095470020: 区域查询失败");
        }
    }    
}