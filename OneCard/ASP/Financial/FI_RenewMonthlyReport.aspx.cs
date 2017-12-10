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
using TDO.BalanceChannel;
using PDO.Financial;
using Master;
using Common;

public partial class ASP_Financial_FI_RenewMonthlyReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期

            DateTime tf = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, 2);
            DateTime tt = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);

            txtFromDate.Text = tf.ToString("yyyyMMdd");
            txtToDate.Text = tt.ToString("yyyyMMdd");
        }
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        //if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        //{
        //    totalCharges += Convert.ToDouble(GetTableCellValue(e.Row.Cells[2]));
        //}
        //else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        //{
        //    e.Row.Cells[0].Text = "总计";
        //    e.Row.Cells[2].Text = totalCharges.ToString("n");
        //}
    }

    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }

    //protected void queryBalUnit(object sender, EventArgs e)
    //{
    //    string name = txtBalUnitName.Text.Trim();
    //    if (name == "")
    //    {
    //        selBalUnit.Items.Clear();
    //        txtBalUnit.Text = "";
    //        return;
    //    }

    //    TF_TRADE_BALUNITTDO tdoTF_TRADE_BALUNITIn = new TF_TRADE_BALUNITTDO();
    //    TF_TRADE_BALUNITTDO[] tdoTF_TRADE_BALUNITOutArr = null;
    //    tdoTF_TRADE_BALUNITIn.BALUNIT = "%" + name + "%";
    //    tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tm.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_NAME", null);

    //    selBalUnit.Items.Clear();
    //    foreach (TF_TRADE_BALUNITTDO ddoBalUnit in tdoTF_TRADE_BALUNITOutArr)
    //    {
    //        selBalUnit.Items.Add(new ListItem(ddoBalUnit.BALUNITNO + ":" + ddoBalUnit.BALUNIT, ddoBalUnit.BALUNITNO));
    //    }

    //    if (tdoTF_TRADE_BALUNITOutArr.Length > 0)
    //    {
    //        selBalUnit.SelectedValue = tdoTF_TRADE_BALUNITOutArr[0].BALUNITNO;
    //        txtBalUnit.Text = tdoTF_TRADE_BALUNITOutArr[0].BALUNITNO;
    //    }
    //    else
    //    {
    //        txtBalUnit.Text = "";
    //    }
    //}

    //protected void selBalUnit_Change(object sender, EventArgs e)
    //{
    //    txtBalUnit.Text = selBalUnit.SelectedValue;
    //}

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "TF_BUSRENEW_MONTHLY";
        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;
        //pdo.var7 = txtBalUnit.Text;

        StoreProScene storePro = new StoreProScene();

        DataTable data = storePro.Execute(context, pdo);
        hidNo.Value = pdo.var9;

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
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

        //if (txtBalUnit.Text.Trim() == "")
        //{
        //    context.AddError("A006500012", txtBalUnit);
        //}

    }
}
