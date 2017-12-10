using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using Master;
using PDO.Financial;
using TDO.BalanceParameter;

public partial class ASP_Financial_FI_WJTourReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期
            txtFromDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
            //默认报表类型为汇总
            selTradeType.SelectedValue = "0";
        }
    }

    private double opennum = 0;
    private double tradenum = 0;
    private string sparetimes = "";
    private int index;

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (selTradeType.SelectedValue.Equals("0"))
        {
            if (selNewCardType.SelectedValue.Equals("1"))
            {
                if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
                {
                    opennum += Convert.ToDouble(GetTableCellValue(e.Row.Cells[1]));
                    tradenum += Convert.ToDouble(GetTableCellValue(e.Row.Cells[2]));
                }
                else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
                {
                    e.Row.Cells[0].Text = "总计";
                    e.Row.Cells[1].Text = opennum.ToString();
                    e.Row.Cells[2].Text = tradenum.ToString();
                }
                return;
            }
            else
            {
                if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
                {
                    opennum += Convert.ToDouble(GetTableCellValue(e.Row.Cells[2]));
                 
                }
                else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
                {
                    e.Row.Cells[0].Text = "总计";
                    e.Row.Cells[2].Text = opennum.ToString();
                }
                return;
            }
        }
        if (selTradeType.SelectedValue.Equals("1"))
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                //显示售卡时间,格式为YYYY-MM-dd
                if (e.Row.Cells[3].Text.Length == 8)
                    e.Row.Cells[3].Text = e.Row.Cells[3].Text.Substring(0, 4) + "-" + e.Row.Cells[3].Text.Substring(4, 2) + "-" + e.Row.Cells[3].Text.Substring(6, 2);

                //显示结束日期,格式为YYYY-MM-dd
                if (e.Row.Cells[4].Text.Length == 8)
                    e.Row.Cells[4].Text = e.Row.Cells[4].Text.Substring(0, 4) + "-" + e.Row.Cells[4].Text.Substring(4, 2) + "-" + e.Row.Cells[4].Text.Substring(6, 2);
                
                ControlDeal.RowDataBound(e);
            }
            return;
        }
        if (selTradeType.SelectedValue.Equals("2"))
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                //显示交易时间,格式为YYYY-MM-dd
                if (e.Row.Cells[3].Text.Length == 14)
                    e.Row.Cells[3].Text = e.Row.Cells[3].Text.Substring(0, 4) + "-" + e.Row.Cells[3].Text.Substring(4, 2) + "-" + e.Row.Cells[3].Text.Substring(6, 2)+ " " +
                                          e.Row.Cells[3].Text.Substring(8, 2) + ":" + e.Row.Cells[3].Text.Substring(10, 2) + ":" + e.Row.Cells[3].Text.Substring(12, 2);                

                //显示结束日期,格式为YYYY-MM-dd
                if (e.Row.Cells[5].Text.Length == 8)
                    e.Row.Cells[5].Text = e.Row.Cells[5].Text.Substring(0, 4) + "-" + e.Row.Cells[5].Text.Substring(4, 2) + "-" + e.Row.Cells[5].Text.Substring(6, 2);
                
                ControlDeal.RowDataBound(e);

                if (e.Row.Cells[4].Text.Length != 0)
                {
                    sparetimes = e.Row.Cells[4].Text;
                    index = sparetimes.IndexOf(".");
                    e.Row.Cells[4].Text = sparetimes.Substring(0, index);
                }
            }
            return;
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
        if (selTradeType.SelectedValue.Equals("0"))
            pdo.funcCode = "WJTourReport";
        if (selTradeType.SelectedValue.Equals("1"))
            pdo.funcCode = "WJTourReportOpenDetail";
        if (selTradeType.SelectedValue.Equals("2"))
            pdo.funcCode = "WJTourReportConsumeDetail";
        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;
        pdo.var3 = selNewCardType.SelectedValue;

        StoreProScene storePro = new StoreProScene();

        DataTable data = storePro.Execute(context, pdo);

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
            btnPrint.Enabled = false;
        }

        opennum = 0;
        tradenum = 0;
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

    protected void selTradeType_change(object sender, EventArgs e)
    {
        if (selTradeType.SelectedValue.Equals("0"))
        {
            labTitle.Text = "吴江旅游年卡汇总";
            lbl1.Visible = true;
            selNewCardType.Visible = true;
            //清空列表
            showNonDataGridView();
            return;
        }
        if (selTradeType.SelectedValue.Equals("1"))
        {
            labTitle.Text = "吴江旅游年卡售卡明细";
            lbl1.Visible = true;
            selNewCardType.Visible = true;
            //清空列表
            showNonDataGridView();
            return;
        }
        if (selTradeType.SelectedValue.Equals("2"))
        {
            labTitle.Text = "吴江旅游年卡消费明细";
            lbl1.Visible = false;
            selNewCardType.Visible = false;
            //清空列表
            showNonDataGridView();
            return;
        }
    }

    private void showNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }
}