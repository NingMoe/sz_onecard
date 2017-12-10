using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using PDO.Financial;
using Master;
using System.Data;
using System.IO;
using NPOI.HSSF.UserModel;


public partial class ASP_Financial_FI_MonthReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            selType.Items.Add(new ListItem("苏州市民卡公司经营业务指标完成表", "CardSaleTotalStat"));
            selType.Items.Add(new ListItem("刷卡构成表", "SwingCardStat"));
            txtToday.Text = DateTime.Now.ToString("yyyy-MM-dd");
           
        }
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        UserCardHelper.resetData(gvResult, null);

        if (context.hasError()) return;

        SP_FI_StatPDO pdo = new SP_FI_StatPDO();
        pdo.funcCode = selType.SelectedValue;
        labTitle.Text = selType.SelectedItem.Text;

        if (selType.SelectedValue == "CardSaleTotalStat")
        {
            gvResult.Visible = true;
            GridView2.Visible = false;
            Label1.Visible = false;

        }
        else
        {
            gvResult.Visible = false;
            GridView2.Visible = true;
            Label1.Visible = true;
        }
        
        int i = Convert.ToInt32(Convert.ToDateTime(txtToday.Text.ToString()).DayOfWeek);
        pdo.var1 = Convert.ToDateTime(txtToday.Text.ToString()).AddDays(-i - 2).ToString("yyyyMMdd"); 
        //string[] date = txtToday.Text.Split('-');
        pdo.var2 = Convert.ToDateTime(txtToday.Text.ToString()).AddDays(-1).ToString("yyyyMMdd");
        pdo.var3 = Convert.ToDateTime(txtToday.Text).AddDays(-1).ToString("yyyyMM01");
        pdo.var4 = Convert.ToDateTime(txtToday.Text).AddDays(-1).ToString("yyyy0101");

        txtFromDate.Text = pdo.var1;
        txtToDate.Text = Convert.ToDateTime(txtToday.Text.ToString()).AddDays(-1).ToString("yyyyMMdd");

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        

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
        UserCardHelper.resetData(GridView2, data);
    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (selType.SelectedValue == "CardSaleTotalStat")
        {
            if (gvResult.Rows.Count > 0)
            {
                SP_FI_StatPDO pdo = new SP_FI_StatPDO();
                pdo.funcCode = selType.SelectedValue;

                int i = Convert.ToInt32(Convert.ToDateTime(txtToday.Text.ToString()).DayOfWeek);
                pdo.var1 = Convert.ToDateTime(txtToday.Text.ToString()).AddDays(-i - 2).ToString("yyyyMMdd");
                //string[] date = txtToday.Text.Split('-');
                pdo.var2 = Convert.ToDateTime(txtToday.Text.ToString()).AddDays(-1).ToString("yyyyMMdd");
                pdo.var3 = Convert.ToDateTime(txtToday.Text).AddDays(-1).ToString("yyyyMM01");
                pdo.var4 = Convert.ToDateTime(txtToday.Text).AddDays(-1).ToString("yyyy0101");
                StoreProScene storePro = new StoreProScene();
                DataTable data = storePro.Execute(context, pdo);
                ExportToExcel(data, "CardSaleTotalStat");
               
            }
            else
            {
                context.AddMessage("查询结果为空，不能导出");
            }
        }
        else
        {
            if (GridView2.Rows.Count > 0)
            {
                SP_FI_StatPDO pdo = new SP_FI_StatPDO();
                pdo.funcCode = selType.SelectedValue;
                int i = Convert.ToInt32(Convert.ToDateTime(txtToday.Text.ToString()).DayOfWeek);
                pdo.var1 = Convert.ToDateTime(txtToday.Text.ToString()).AddDays(-i - 2).ToString("yyyyMMdd");
                string[] date = txtToday.Text.Split('-');
                pdo.var2 = date[0] + date[1] + date[2];
                pdo.var3 = Convert.ToDateTime(txtToday.Text).AddDays(-1).ToString("yyyyMM01");
                pdo.var4 = Convert.ToDateTime(txtToday.Text).AddDays(-1).ToString("yyyy0101");
                StoreProScene storePro = new StoreProScene();
                DataTable data = storePro.Execute(context, pdo);

                ExportToExcel(data, "SwingCardStat");
                
            }
            else
            {
                context.AddMessage("查询结果为空，不能导出");
            }
        }

       
    }
    protected void lvwQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
    }
  
    protected void GridView2_RowCreated(object sender, GridViewRowEventArgs e)
    {
        //判断创建的行是否为表头行          
        if (e.Row.RowType == DataControlRowType.Header)
        {
            TableCellCollection tcHeader = e.Row.Cells;
            //清除自动生成的表头
            tcHeader.Clear();

            tcHeader.Add(new TableHeaderCell());
            tcHeader[0].RowSpan = 2;
            tcHeader[0].Text = "项目";


            tcHeader.Add(new TableHeaderCell());
            tcHeader[1].ColumnSpan = 2;
            tcHeader[1].Text = "本周实际";

            tcHeader.Add(new TableHeaderCell());
            tcHeader[2].ColumnSpan = 2;
            tcHeader[2].Text = "本月实际";

            tcHeader.Add(new TableHeaderCell());
            tcHeader[3].ColumnSpan = 2;
            tcHeader[3].Text = "本年实际</th></tr><tr>";


            tcHeader.Add(new TableHeaderCell());
            tcHeader[4].Text = "刷卡额";
            tcHeader[4].Attributes.Add("style", "font-weight: bold;text-align: center;");

            tcHeader.Add(new TableHeaderCell());
            tcHeader[5].Text = "佣金收入";
            tcHeader[5].Attributes.Add("style", "font-weight: bold;text-align: center;");

            tcHeader.Add(new TableHeaderCell());
            tcHeader[6].Text = "刷卡额";
            tcHeader[6].Attributes.Add("style", "font-weight: bold;text-align: center;");

            tcHeader.Add(new TableHeaderCell());
            tcHeader[7].Text = "佣金收入";
            tcHeader[7].Attributes.Add("style", "font-weight: bold;text-align: center;");

            tcHeader.Add(new TableHeaderCell());
            tcHeader[8].Text = "刷卡额";
            tcHeader[8].Attributes.Add("style", "font-weight: bold;text-align: center;");

            tcHeader.Add(new TableHeaderCell());
            tcHeader[9].Text = "佣金收入";
            tcHeader[9].Attributes.Add("style", "font-weight: bold;text-align: center;");

           
        }
      

    }

    protected void ExportToExcel(DataTable dt,string type)
    {
        string path = "";
        int count;
        if (type == "CardSaleTotalStat")
        {
            path = HttpContext.Current.Server.MapPath("../../") + "Tools\\苏州市民卡公司经营业务指标完成表模板.xls";
            count = 2;
        }
        else
        {
            path = HttpContext.Current.Server.MapPath("../../") + "Tools\\刷卡构成表模板.xls";
            count = 4;
        }
       

        FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read);

        HSSFWorkbook workbook = new HSSFWorkbook(fs);

        HSSFSheet sheet = (HSSFSheet)workbook.GetSheetAt(0);
              
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            if (sheet.GetRow(count + i) == null)
            {
                sheet.CreateRow(count + i);

            }
            for (int j = 0; j < dt.Columns.Count; j++)
            {
                if (sheet.GetRow(count + i).GetCell(j) == null)
                {
                    sheet.GetRow(count + i).CreateCell(j);
                   
                }

                sheet.GetRow(count + i).GetCell(j).SetCellValue(dt.Rows[i][j].ToString());
                
            }
        }       

        MemoryStream ms = new MemoryStream();
        using (ms)
        {
            workbook.Write(ms);
            byte[] data = ms.ToArray();
            #region 客户端保存
            HttpResponse response = System.Web.HttpContext.Current.Response;
            response.Clear();
            //Encoding pageEncode = Encoding.GetEncoding(PageEncode);
            response.Charset = "UTF-8";
            response.ContentType = "application/vnd-excel";//"application/vnd.ms-excel";
            System.Web.HttpContext.Current.Response.AddHeader("Content-Disposition", string.Format("attachment; filename=export.xls"));
            System.Web.HttpContext.Current.Response.BinaryWrite(data);
            #endregion
        }


    }

}