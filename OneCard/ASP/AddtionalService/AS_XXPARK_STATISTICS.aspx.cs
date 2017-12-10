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

public partial class AS_XXPARK_STATISTICS : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtStatMonth.Text = DateTime.Today.AddMonths(-1).ToString("yyyy");
        }
    }
    protected Boolean validation(string month)
    {
        if (Validation.isEmpty(txtStatMonth))
        {
            context.AddError("查询年份不能为空");
            return false;
        }
        else if (!Validation.isDate(txtStatMonth.Text.Trim(), "yyyy"))
        {
            context.AddError("查询年份格式必须为yyyy");
            return false;
        }
        else if (txtStatMonth.Text.CompareTo(month) > 0)
        {
            context.AddError("查询年份不能大于当前年份");
            return false;
        }
        return true;
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        string currentYear = DateTime.Today.ToString("yyyy");
        //校验输入有效性
        if (!validation(currentYear)) return;
        //查询汇总结果

        string queryYear = txtStatMonth.Text.Trim();
        DataTable data = ASHelper.callQuery(context, "XXParkStatistics", queryYear);

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
            return;
        }

        DataTable bindingTable = generateDataTable(data, queryYear);

        gvResult.DataSource = bindingTable;
        gvResult.DataBind();       
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

    private DataTable generateDataTable(DataTable data, string queryYear)
    {
        DataTable dt = new DataTable();
        dt.Columns.Add(new DataColumn("CARDTYPENAME", typeof (string)));//项目
        dt.Columns.Add(new DataColumn("MONTH_01", typeof(decimal)));//1月
        dt.Columns.Add(new DataColumn("MONTH_02", typeof(decimal)));//2月
        dt.Columns.Add(new DataColumn("MONTH_03", typeof(decimal)));//3月
        dt.Columns.Add(new DataColumn("MONTH_04", typeof(decimal)));//4月
        dt.Columns.Add(new DataColumn("MONTH_05", typeof(decimal)));//5月
        dt.Columns.Add(new DataColumn("MONTH_06", typeof(decimal)));//6月
        dt.Columns.Add(new DataColumn("MONTH_07", typeof(decimal)));//7月
        dt.Columns.Add(new DataColumn("MONTH_08", typeof(decimal)));//8月
        dt.Columns.Add(new DataColumn("MONTH_09", typeof(decimal)));//9月
        dt.Columns.Add(new DataColumn("MONTH_10", typeof(decimal)));//10月
        dt.Columns.Add(new DataColumn("MONTH_11", typeof(decimal)));//11月
        dt.Columns.Add(new DataColumn("MONTH_12", typeof(decimal)));//12月
        dt.Columns.Add(new DataColumn("YEAR_SUM", typeof(decimal)));//当年合计
        dt.Columns.Add(new DataColumn("ALL_SUM", typeof(decimal)));//开通总量
        //开始处理数据
        DataRow parkOnline = dt.NewRow();//园林-线上
        DataRow parkOffline = dt.NewRow();//园林-线下
        DataRow parkSum = dt.NewRow();//园林-合计
        DataRow xxOnline = dt.NewRow();//休闲-线上
        DataRow xxOffline = dt.NewRow();//休闲-线下
        DataRow wxOffline = dt.NewRow();//休闲年卡-线下（无锡）
        DataRow czOffline = dt.NewRow();//休闲年卡-线下（常州）
        DataRow csOffline = dt.NewRow();//休闲年卡-线下（常熟）
        DataRow xxSum = dt.NewRow();//休闲-合计
        parkOnline["CARDTYPENAME"] = "园林年卡-线上";
        parkOffline["CARDTYPENAME"] = "园林年卡-线下";
        parkSum["CARDTYPENAME"] = "合计";
        xxOnline["CARDTYPENAME"] = "休闲年卡-线上";
        xxOffline["CARDTYPENAME"] = "休闲年卡-线下";

        wxOffline["CARDTYPENAME"] = "休闲年卡-线下（无锡）";
        czOffline["CARDTYPENAME"] = "休闲年卡-线下（常州）";
        csOffline["CARDTYPENAME"] = "休闲年卡-线下（常熟）";

        xxSum["CARDTYPENAME"] = "合计";

        decimal parkYearSumOnline = 0;//园林线上-当年合计
        decimal parkYearSumOffline = 0;//园林线下-当年合计
        decimal xxYearSumOnline = 0;//休闲线上-当年合计
        decimal xxYearSumOffline = 0;//休闲线下-当年合计

        decimal wxxxYearSumOffline = 0;//休闲线下-当年合计（无锡）
        decimal czxxYearSumOffline = 0;//休闲线下-当年合计（常州）
        decimal csxxYearSumOffline = 0;//休闲线下-当年合计（常熟）

        //计算1月-12月的值
        for (int i = 1; i <= 12; i++)
        {
            string selectMonth = queryYear + "-" + i.ToString().PadLeft(2, '0');
            string columnName = "MONTH_" + i.ToString().PadLeft(2, '0');
            //园林-线上
            DataRow[] selectRows = data.Select("stag='1' and smonth='" + selectMonth + "' ");
            if (selectRows.Length > 0)
            {
                decimal sNum = ASHelper.ToDecimal(selectRows[0]["snum"]);
                parkOnline[columnName] = sNum;
                parkYearSumOnline += sNum;
                parkSum[columnName] = ASHelper.ToDecimal(parkSum[columnName]) + sNum;
            }
            //园林-线下
            selectRows = data.Select("stag='2' and smonth='" + selectMonth + "' ");
            if (selectRows.Length > 0)
            {
                decimal sNum = ASHelper.ToDecimal(selectRows[0]["snum"]);
                parkOffline[columnName] = sNum;
                parkYearSumOffline += sNum;
                parkSum[columnName] = ASHelper.ToDecimal(parkSum[columnName]) + sNum;
            }
            //休闲-线上
            selectRows = data.Select("stag='3' and smonth='" + selectMonth + "' ");
            if (selectRows.Length > 0)
            {
                decimal sNum = ASHelper.ToDecimal(selectRows[0]["snum"]);
                xxOnline[columnName] = sNum;
                xxYearSumOnline += sNum;
                xxSum[columnName] = ASHelper.ToDecimal(xxSum[columnName]) + sNum;
            }
            //休闲-线下
            selectRows = data.Select("stag='4' and smonth='" + selectMonth + "' ");
            if (selectRows.Length > 0)
            {
                decimal sNum = ASHelper.ToDecimal(selectRows[0]["snum"]);
                xxOffline[columnName] = sNum;
                xxYearSumOffline += sNum;
                xxSum[columnName] = ASHelper.ToDecimal(xxSum[columnName]) + sNum;
            }
            //休闲-线下（无锡）
            selectRows = data.Select("stag='5' and smonth='" + selectMonth + "' ");
            if (selectRows.Length > 0)
            {
                decimal sNum = ASHelper.ToDecimal(selectRows[0]["snum"]);
                wxOffline[columnName] = sNum;
                wxxxYearSumOffline += sNum;
                xxSum[columnName] = ASHelper.ToDecimal(xxSum[columnName]) + sNum;
            }
            //休闲-线下（常州）
            selectRows = data.Select("stag='6' and smonth='" + selectMonth + "' ");
            if (selectRows.Length > 0)
            {
                decimal sNum = ASHelper.ToDecimal(selectRows[0]["snum"]);
                czOffline[columnName] = sNum;
                czxxYearSumOffline += sNum;
                xxSum[columnName] = ASHelper.ToDecimal(xxSum[columnName]) + sNum;
            }
            //休闲-线下（常熟）
            selectRows = data.Select("stag='7' and smonth='" + selectMonth + "' ");
            if (selectRows.Length > 0)
            {
                decimal sNum = ASHelper.ToDecimal(selectRows[0]["snum"]);
                csOffline[columnName] = sNum;
                csxxYearSumOffline += sNum;
                xxSum[columnName] = ASHelper.ToDecimal(xxSum[columnName]) + sNum;
            }
        }

        parkOnline["YEAR_SUM"] = parkYearSumOnline;
        parkOffline["YEAR_SUM"] = parkYearSumOffline;
        parkSum["YEAR_SUM"] = parkYearSumOnline + parkYearSumOffline;
        xxOnline["YEAR_SUM"] = xxYearSumOnline;
        xxOffline["YEAR_SUM"] = xxYearSumOffline;
        wxOffline["YEAR_SUM"] = wxxxYearSumOffline;
        czOffline["YEAR_SUM"] = czxxYearSumOffline;
        csOffline["YEAR_SUM"] = csxxYearSumOffline;
        xxSum["YEAR_SUM"] = xxYearSumOnline + xxYearSumOffline + wxxxYearSumOffline + czxxYearSumOffline +
                            csxxYearSumOffline;
        //计算开通总量
        //园林-线上
        DataRow[] selectSumRows = data.Select("smonth='9999-12' and stag='1_ALL' ");
        if (selectSumRows.Length > 0)
        {
            decimal sNum = ASHelper.ToDecimal(selectSumRows[0]["snum"]);
            parkOnline["ALL_SUM"] = sNum;
            parkSum["ALL_SUM"] = ASHelper.ToDecimal(parkSum["ALL_SUM"]) + sNum;
        }
        //园林-线下
        selectSumRows = data.Select("smonth='9999-12' and stag='2_ALL' ");
        if (selectSumRows.Length > 0)
        {
            decimal sNum = ASHelper.ToDecimal(selectSumRows[0]["snum"]);
            parkOffline["ALL_SUM"] = sNum;
            parkSum["ALL_SUM"] = ASHelper.ToDecimal(parkSum["ALL_SUM"]) + sNum;
        }
        //休闲-线上
        selectSumRows = data.Select("smonth='9999-12' and stag='3_ALL' ");
        if (selectSumRows.Length > 0)
        {
            decimal sNum = ASHelper.ToDecimal(selectSumRows[0]["snum"]);
            xxOnline["ALL_SUM"] = sNum;
            xxSum["ALL_SUM"] = ASHelper.ToDecimal(xxSum["ALL_SUM"]) + sNum;
        }
        //休闲-线下
        selectSumRows = data.Select("smonth='9999-12' and stag='4_ALL' ");
        if (selectSumRows.Length > 0)
        {
            decimal sNum = ASHelper.ToDecimal(selectSumRows[0]["snum"]);
            xxOffline["ALL_SUM"] = sNum;
            xxSum["ALL_SUM"] = ASHelper.ToDecimal(xxSum["ALL_SUM"]) + sNum;
        }
        //休闲-线下（无锡）
        selectSumRows = data.Select("smonth='9999-12' and stag='5_ALL' ");
        if (selectSumRows.Length > 0)
        {
            decimal sNum = ASHelper.ToDecimal(selectSumRows[0]["snum"]);
            wxOffline["ALL_SUM"] = sNum;
            xxSum["ALL_SUM"] = ASHelper.ToDecimal(xxSum["ALL_SUM"]) + sNum;
        }
        //休闲-线下（常州）
        selectSumRows = data.Select("smonth='9999-12' and stag='6_ALL' ");
        if (selectSumRows.Length > 0)
        {
            decimal sNum = ASHelper.ToDecimal(selectSumRows[0]["snum"]);
            czOffline["ALL_SUM"] = sNum;
            xxSum["ALL_SUM"] = ASHelper.ToDecimal(xxSum["ALL_SUM"]) + sNum;
        }
        //休闲-线下（常熟）
        selectSumRows = data.Select("smonth='9999-12' and stag='7_ALL' ");
        if (selectSumRows.Length > 0)
        {
            decimal sNum = ASHelper.ToDecimal(selectSumRows[0]["snum"]);
            csOffline["ALL_SUM"] = sNum;
            xxSum["ALL_SUM"] = ASHelper.ToDecimal(xxSum["ALL_SUM"]) + sNum;
        }

        //添加行
        dt.Rows.Add(parkOnline);
        dt.Rows.Add(parkOffline);
        dt.Rows.Add(parkSum);
        dt.Rows.Add(xxOnline);
        dt.Rows.Add(xxOffline);
        dt.Rows.Add(wxOffline);
        dt.Rows.Add(czOffline);
        dt.Rows.Add(csOffline);
        dt.Rows.Add(xxSum);
        //将空白的都变成0
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            DataRow currentRow = dt.Rows[i];
            for (int j = 0; j < dt.Columns.Count; j++)
            {
                if (currentRow[j] == null || currentRow[j].ToString().Length == 0)
                {
                    currentRow[j] = 0;
                }
            }
        }
        return dt;
    }
}