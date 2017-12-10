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

public partial class ASP_Financial_FI_SellChange_Report : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期
            DateTime tf = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, 1);
            DateTime tt = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, DateTime.DaysInMonth(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month));

            txtFromDate.Text = tf.ToString("yyyyMMdd");
            txtToDate.Text = tt.ToString("yyyyMMdd");
        }
    }
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
       
    }

    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        SP_FI_CARDSTATPDO pdo = new SP_FI_CARDSTATPDO();
        pdo.funcCode = "SELLCHANGEREPORTCOL";
        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;

        StoreProScene storePro = new StoreProScene();

        DataTable data = storePro.Execute(context, pdo);

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
    }
    
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        switch (e.Row.RowType)
        {
            case DataControlRowType.Header:
                TableCellCollection tcHeader = e.Row.Cells;
                tcHeader.Clear();
               
                tcHeader.Add(new TableHeaderCell());
                tcHeader[0].Attributes.Add("rowspan", "2"); 
                tcHeader[0].Text = "客服";
                tcHeader.Add(new TableHeaderCell());
                tcHeader[1].Attributes.Add("colspan", "2"); 
                tcHeader[1].Text = "售卡";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[2].Attributes.Add("colspan", "2");
                tcHeader[2].Text = "换卡";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[3].Attributes.Add("colspan", "2");
                tcHeader[3].Text = "省一卡通";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[4].Attributes.Add("colspan", "2");
                tcHeader[4].Text = "读卡器";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[5].Attributes.Add("colspan", "2");
                tcHeader[5].Text = "合计";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[6].Attributes.Add("colspan", "1");
                tcHeader[6].Text = "利金卡";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[7].Attributes.Add("colspan", "1");
                tcHeader[7].Text = "利金卡再售卡";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[8].Attributes.Add("colspan", "1");
                tcHeader[8].Text = "CZK100";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[9].Attributes.Add("colspan", "1");
                tcHeader[9].Text = "CZK200";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[10].Attributes.Add("colspan", "1");
                tcHeader[10].Text = "CZK500";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[11].Attributes.Add("colspan", "1");
                tcHeader[11].Text = "CZK180";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[12].Attributes.Add("colspan", "1");
                tcHeader[12].Text = "CZK298";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[13].Attributes.Add("colspan", "1");
                tcHeader[13].Text = "回收漫游卡</th></tr><tr>";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[14].Attributes.Add("colspan", "1");
                tcHeader[14].Text = "数量";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[15].Attributes.Add("colspan", "1");
                tcHeader[15].Text = "金额";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[16].Attributes.Add("colspan", "1");
                tcHeader[16].Text = "数量";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[17].Attributes.Add("colspan", "1");
                tcHeader[17].Text = "金额";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[18].Attributes.Add("colspan", "1");
                tcHeader[18].Text = "数量";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[19].Attributes.Add("colspan", "1");
                tcHeader[19].Text = "金额";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[20].Attributes.Add("colspan", "1");
                tcHeader[20].Text = "数量";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[21].Attributes.Add("colspan", "1");
                tcHeader[21].Text = "金额";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[22].Attributes.Add("colspan", "1");
                tcHeader[22].Text = "数量";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[23].Attributes.Add("colspan", "1");
                tcHeader[23].Text = "金额";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[24].Attributes.Add("colspan", "1");
                tcHeader[24].Text = "数量";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[25].Attributes.Add("colspan", "1");
                tcHeader[25].Text = "数量";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[26].Attributes.Add("colspan", "1");
                tcHeader[26].Text = "数量";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[27].Attributes.Add("colspan", "1");
                tcHeader[27].Text = "数量";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[28].Attributes.Add("colspan", "1");
                tcHeader[28].Text = "数量";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[29].Attributes.Add("colspan", "1");
                tcHeader[29].Text = "数量";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[30].Attributes.Add("colspan", "1");
                tcHeader[30].Text = "数量";

                tcHeader.Add(new TableHeaderCell());
                tcHeader[31].Attributes.Add("colspan", "1");
                tcHeader[31].Text = "数量";

                break;
        }
    }
}