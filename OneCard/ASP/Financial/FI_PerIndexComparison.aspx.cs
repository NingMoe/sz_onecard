using System;
using System.Data;
using System.Web.UI.WebControls;
using Common;

public partial class ASP_Financial_FI_PerIndexComparison : Master.ExportMaster
{

    protected void Page_Load(object sender, EventArgs e)
    {
       
        if (!IsPostBack)
        {
            txtStatMonth.Text = DateTime.Today.AddMonths(-1).ToString("yyyyMM");
            //txtStatMonth.Text = DateTime.Today.AddMonths(-1).ToString("yyyyMM");
            //gvResult.DataSource = GetPerIndexComparisonTable();
            //gvResult.DataBind();
            //gvMerchant.DataSource = GetTopTenMerchantTable();
            //gvMerchant.DataBind();
        }
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        string todaymonth = txtStatMonth.Text.Trim();
        //校验输入有效性

        if (!validation(todaymonth)) return;
        //查询汇总结果

        string lastYear = (Convert.ToInt32(txtStatMonth.Text.Trim().Substring(0, 4))-1).ToString();
        string thisYear = txtStatMonth.Text.Trim().Substring(0,4);
        string month = txtStatMonth.Text.Trim().Substring(4,2);

        gvResult.DataSource = GetPerIndexComparisonTable(lastYear, thisYear, month);
        gvResult.DataBind();
        gvMerchant.DataSource = GetTopTenMerchantTable(lastYear, thisYear, month);
        gvMerchant.DataBind();

    }

    protected Boolean validation(string month)
    {
        string todaymonth = DateTime.Today.ToString("yyyyMM");
        if (Validation.isEmpty(txtStatMonth))
        {
            context.AddError("汇总年月不能为空");
            return false;
        }
        else if (!Validation.isDate(txtStatMonth.Text.Trim(), "yyyyMM"))
        {
            context.AddError("查询时间格式必须为yyyyMM");
            return false;
        }
        else if (txtStatMonth.Text.CompareTo(todaymonth) >= 0)
        {
            context.AddError("汇总年月不能大于等于当前月");
            return false;
        }
        return true;
    }

    protected void gvResult_OnRowCreated(object sender, GridViewRowEventArgs e)
    {
        //DateTime dateTime = DateTime.Now;
        //string lastYear = dateTime.AddYears(-1).ToString("yyyy");
        //string thisYear = dateTime.ToString("yyyy");
        //string month = dateTime.AddMonths(-1).ToString("MM");
        if (txtStatMonth.Text.Trim() != "")
        {
            string lastYear = (Convert.ToInt32(txtStatMonth.Text.Trim().Substring(0, 4)) - 1).ToString();
            string thisYear = txtStatMonth.Text.Trim().Substring(0, 4);
            string month = txtStatMonth.Text.Trim().Substring(4, 2);

            string[] fieldNames =
            {
                "指标", lastYear + "年", lastYear + "年" + "1-" + month + "月",
                thisYear + "年" + "1-" + month + "月"
            };
            if (e.Row.RowType == DataControlRowType.Header)
            {
                GridViewRow gvr = new GridViewRow(0, 0, DataControlRowType.Header, DataControlRowState.Normal);
                for (int i = 0; i < fieldNames.Length; i++)
                {
                    TableCell tc = new TableCell();
                    tc.Text = fieldNames[i].ToString();
                    tc.Width = 200;
                    gvr.Cells.Add(tc);
                }
                gvResult.Controls[0].Controls.AddAt(0, gvr);
            }
        }
    }

    //构造指标对比表
    private DataTable GetPerIndexComparisonTable(string lastYear, string thisYear, string month)
    {
        DataTable dt = new DataTable();
        DateTime dateTime = DateTime.Now;
        //string lastYear = dateTime.AddYears(-1).ToString("yyyy");
        //string thisYear = dateTime.ToString("yyyy");
        //string month = dateTime.AddMonths(-1).ToString("MM");

        dt.Columns.Add("Index");
        dt.Columns.Add("LastYear");
        dt.Columns.Add("LastYearMonth");
        dt.Columns.Add("ThisYear");
        //汇总去年信息
        DataTable dtLastYearSummary = GetDataTableSummary(lastYear, true, null, null);
        //查询日活跃度
        DataTable dtLastYearActive = GetDataTableActive(lastYear, true, null, null);
        //查询去年活跃度
        DataTable dtLastYearActiveRange = GetRanageActiveDataTable(lastYear+"12");

        //汇总今年信息
        string sqlstr1 = " AND substr(TRADEMONTH,5,2)<=:MONTH";
        string sqlstr2 = " AND substr(TRADEDATE,5,2)<=:MONTH";
        DataTable dtThisYearSummary = GetDataTableSummary(thisYear, false, month, sqlstr1);
        //查询活跃度
        DataTable dtThisYearActive = GetDataTableActive(thisYear, false, month, sqlstr2);
        //查询今年活跃度
        DataTable dtThisYearActiveRange = GetRanageActiveDataTable(thisYear + month);

        //汇总去年同期信息
        DataTable dtYearSummary = GetDataTableSummary(lastYear, false, month, sqlstr1);
        //查询活跃度
        DataTable dtYearActive = GetDataTableActive(lastYear, false, month, sqlstr2);
        //查询去年同期活跃度
        DataTable dtYearActiveActiveRange = GetRanageActiveDataTable(lastYear + month);
        context.DBCommit();

        DataRow dr = dt.NewRow();
        dr[0] = "一、持卡总量（万张）";
        dr[1] = dtLastYearSummary.Rows[0]["TOTALAMOUNT"];
        dr[2] = dtYearSummary.Rows[0]["TOTALAMOUNT"];
        dr[3] = dtThisYearSummary.Rows[0]["TOTALAMOUNT"];
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        dr[0] = "二、新增发卡量（万张）";
        dr[1] = dtLastYearSummary.Rows[0]["ADDEDAMOUNT"];
        dr[2] = dtYearSummary.Rows[0]["ADDEDAMOUNT"];
        dr[3] = dtThisYearSummary.Rows[0]["ADDEDAMOUNT"];
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        dr[0] = "a:市民卡A卡";
        dr[1] = dtLastYearSummary.Rows[0]["ADDEDAMOUNT1"];
        dr[2] = dtYearSummary.Rows[0]["ADDEDAMOUNT1"];
        dr[3] = dtThisYearSummary.Rows[0]["ADDEDAMOUNT1"];
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        dr[0] = "b:市民卡B卡";
        dr[1] = dtLastYearSummary.Rows[0]["ADDEDAMOUNT2"];
        dr[2] = dtYearSummary.Rows[0]["ADDEDAMOUNT2"];
        dr[3] = dtThisYearSummary.Rows[0]["ADDEDAMOUNT2"];
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        dr[0] = "c:吴江市民卡";
        dr[1] = dtLastYearSummary.Rows[0]["ADDEDAMOUNT3"];
        dr[2] = dtYearSummary.Rows[0]["ADDEDAMOUNT3"];
        dr[3] = dtThisYearSummary.Rows[0]["ADDEDAMOUNT3"];
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        dr[0] = "d:张家港市民卡";
        dr[1] = dtLastYearSummary.Rows[0]["ADDEDAMOUNT4"];
        dr[2] = dtYearSummary.Rows[0]["ADDEDAMOUNT4"];
        dr[3] = dtThisYearSummary.Rows[0]["ADDEDAMOUNT4"];
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        dr[0] = "e:智能手表";
        dr[1] = dtLastYearSummary.Rows[0]["ADDEDAMOUNT5"];
        dr[2] = dtYearSummary.Rows[0]["ADDEDAMOUNT5"];
        dr[3] = dtThisYearSummary.Rows[0]["ADDEDAMOUNT5"];
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        dr[0] = "f:智能手环";
        dr[1] = dtLastYearSummary.Rows[0]["ADDEDAMOUNT6"];
        dr[2] = dtYearSummary.Rows[0]["ADDEDAMOUNT6"];
        dr[3] = dtThisYearSummary.Rows[0]["ADDEDAMOUNT6"];
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        dr[0] = "h:三网通卡";
        dr[1] = dtLastYearSummary.Rows[0]["ADDEDAMOUNT7"];
        dr[2] = dtYearSummary.Rows[0]["ADDEDAMOUNT7"];
        dr[3] = dtThisYearSummary.Rows[0]["ADDEDAMOUNT7"];
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        dr[0] = "i:银行联名卡";
        dr[1] = dtLastYearSummary.Rows[0]["ADDEDAMOUNT8"];
        dr[2] = dtYearSummary.Rows[0]["ADDEDAMOUNT8"];
        dr[3] = dtThisYearSummary.Rows[0]["ADDEDAMOUNT8"];
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        dr[0] = "三、用卡活跃度(万人)";
        dr[1] = dtLastYearActiveRange.Rows[0]["RANGEACTIVEAMOUNT"];
        dr[2] = dtYearActiveActiveRange.Rows[0]["RANGEACTIVEAMOUNT"];
        dr[3] = dtThisYearActiveRange.Rows[0]["RANGEACTIVEAMOUNT"];
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        dr[0] = "1:日均活跃度";
        dr[1] = Convert.ToInt32(dtLastYearActive.Rows[0]["ACTIVEAMOUNT"])/365;
        dr[2] = Convert.ToInt32(dtYearActive.Rows[0]["ACTIVEAMOUNT"])/(Convert.ToInt32(month)*30);
        dr[3] = Convert.ToInt32(dtThisYearActive.Rows[0]["ACTIVEAMOUNT"])/ (Convert.ToInt32(month) * 30);
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        dr[0] = "2:月均活跃度";
        dr[1] = Convert.ToInt32(dtLastYearSummary.Rows[0]["ACTIVEAMOUNT"])/12;
        dr[2] = Convert.ToInt32(dtYearSummary.Rows[0]["ACTIVEAMOUNT"]) / Convert.ToInt32(month);
        dr[3] = Convert.ToInt32(dtThisYearSummary.Rows[0]["ACTIVEAMOUNT"]) / Convert.ToInt32(month);
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        dr[0] = "四、交易量（万笔）";
        dr[1] = dtLastYearSummary.Rows[0]["TRADEAMOUNT"];
        dr[2] = dtYearSummary.Rows[0]["TRADEAMOUNT"];
        dr[3] = dtThisYearSummary.Rows[0]["TRADEAMOUNT"];
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        dr[0] = "1:日均交易量";
        dr[1] = Convert.ToInt32(dtLastYearSummary.Rows[0]["TRADEAMOUNT"])/365;
        dr[2] = Convert.ToInt32(dtYearSummary.Rows[0]["TRADEAMOUNT"])/ (Convert.ToInt32(month) * 30); 
        dr[3] = Convert.ToInt32(dtThisYearSummary.Rows[0]["TRADEAMOUNT"])/ (Convert.ToInt32(month) * 30);
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        dr[0] = "2:月均交易量";
        dr[1] = Convert.ToInt32(dtLastYearSummary.Rows[0]["TRADEAMOUNT"])/12;
        dr[2] = Convert.ToInt32(dtYearSummary.Rows[0]["TRADEAMOUNT"])/ Convert.ToInt32(month);
        dr[3] = Convert.ToInt32(dtThisYearSummary.Rows[0]["TRADEAMOUNT"])/ Convert.ToInt32(month);
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        DataTable dttradeMoney = ThisYearTradeMoney(thisYear+month);
        dr[0] = "五、交易金额（万元）";
        dr[1] = dtLastYearSummary.Rows[0]["TRADEMONEY"];
        dr[2] = dtYearSummary.Rows[0]["TRADEMONEY"];
        dr[3] = dttradeMoney.Rows[0]["yearpayMoney"];
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        dr[0] = "1:日均交易金额";
        dr[1] = Convert.ToInt32(dtLastYearSummary.Rows[0]["TRADEMONEY"])/365;
        dr[2] = Convert.ToInt32(dtYearSummary.Rows[0]["TRADEMONEY"])/ (Convert.ToInt32(month) * 30);
        dr[3] = Convert.ToInt32(dttradeMoney.Rows[0]["yearpayMoney"]) / (Convert.ToInt32(month) * 30);
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        dr[0] = "2:月均交易金额";
        dr[1] = Convert.ToInt32(dtLastYearSummary.Rows[0]["TRADEMONEY"])/12;
        dr[2] = Convert.ToInt32(dtYearSummary.Rows[0]["TRADEMONEY"])/ Convert.ToInt32(month);
        dr[3] = Convert.ToInt32(dttradeMoney.Rows[0]["yearpayMoney"]) / Convert.ToInt32(month);
        dt.Rows.Add(dr);

        dr = dt.NewRow();
        dr[0] = "六、佣金总额（万元）";
        dr[1] = dtLastYearSummary.Rows[0]["COMMISSIONMONEY"];
        dr[2] = dtYearSummary.Rows[0]["COMMISSIONMONEY"];
        dr[3] = dtThisYearSummary.Rows[0]["COMMISSIONMONEY"];
        dt.Rows.Add(dr);
        return dt;
    }

    private DataTable GetDataTableSummary(string year, bool isAllYear, string month, string sqlstr)
    {
        string sql =
            "SELECT NVL(MAX(TOTALAMOUNT)/10000,0) TOTALAMOUNT,NVL(SUM(ADDEDAMOUNT)/10000,0) ADDEDAMOUNT,NVL(SUM(TRADEAMOUNT)/10000,0) TRADEAMOUNT,NVL(SUM(TRADEMONEY)/1000000,0) TRADEMONEY," +
            "NVL(SUM(COMMISSIONMONEY)/1000000,0) COMMISSIONMONEY,NVL(SUM(ADDEDAMOUNT1)/10000,0) ADDEDAMOUNT1,NVL(SUM(ADDEDAMOUNT2)/10000,0) ADDEDAMOUNT2,NVL(SUM(ADDEDAMOUNT3)/10000,0) ADDEDAMOUNT3" +
            ",NVL(SUM(ADDEDAMOUNT4)/10000,0) ADDEDAMOUNT4,NVL(SUM(ADDEDAMOUNT5)/10000,0) ADDEDAMOUNT5,NVL(SUM(ADDEDAMOUNT6)/10000,0) ADDEDAMOUNT6,NVL(SUM(ADDEDAMOUNT7)/10000,0) ADDEDAMOUNT7" +
            ",NVL(SUM(ADDEDAMOUNT8)/10000,0) ADDEDAMOUNT8,NVL(SUM(ACTIVEAMOUNT)/10000,0) ACTIVEAMOUNT From TF_B_INDEXCOMPARISION Where substr(TRADEMONTH,0,4)=:YEAR";
        context.DBOpen("Select");
        context.AddField(":YEAR").Value = year;
        if (!isAllYear)
        {
            sql = sql + sqlstr;
            context.AddField(":Month").Value = month;
        }
        DataTable dt = context.ExecuteReader(sql);
        context.DBCommit();
        return dt;
    }

    private DataTable GetRanageActiveDataTable(string tradeMonth)
    {
        string sql =
            "SELECT RANGEACTIVEAMOUNT/10000 RANGEACTIVEAMOUNT From TF_B_INDEXCOMPARISION Where TRADEMONTH=:TRADEMONTH";
        context.DBOpen("Select");
        context.AddField(":TRADEMONTH").Value = tradeMonth;
        DataTable dt = context.ExecuteReader(sql);
        context.DBCommit();
        return dt;
    }

    private DataTable GetDataTableActive(string year, bool isAllYear, string month, string sqlstr)
    {
        string sql =
            "SELECT NVL(SUM(ACTIVEAMOUNT)/10000,0) ACTIVEAMOUNT From TF_B_DAILYACTIVENUM Where substr(TRADEDATE,0,4)=:YEAR";
        context.DBOpen("Select");
        context.AddField(":YEAR").Value = year;
        if (!isAllYear)
        {
            sql = sql + sqlstr;
            context.AddField(":Month").Value = month;
        }
        DataTable dt = context.ExecuteReader(sql);
        context.DBCommit();
        return dt;
    }

    private DataTable GetTopTenMerchantTable(string lastYear, string thisYear, string month)
    {
        DateTime dateTime = DateTime.Now;
        //string lastYear = dateTime.AddYears(-1).ToString("yyyy");
        //string thisYear = dateTime.ToString("yyyy");
        //string month = dateTime.AddMonths(-1).ToString("MM");
        DataTable dt = new DataTable();
        dt.Columns.Add("group_no");
        dt.Columns.Add("Merchant1");
        dt.Columns.Add("Slope1");
        dt.Columns.Add("Merchant2");
        dt.Columns.Add("Slope2");
        dt.Columns.Add("Merchant3");
        dt.Columns.Add("Slope3");
        //获取去年信息
        DataTable dtLastYear = GetTopTenMerchantTable(lastYear + "01", lastYear + "12");
        //获取去年同期数据
        DataTable dtLastYearMonth = GetTopTenMerchantTable(lastYear + "01", lastYear + month);
        //获取今年数据
        DataTable dtthisYear = GetTopTenMerchantTable(thisYear + "01", thisYear + month);
        if (dtLastYear.Rows.Count >= 10)
        {
            for (int i = 0; i < 10; i++)
            {
                DataRow dr = dt.NewRow();
                dr["group_no"] = i + 1;
                dr["Merchant1"] = dtLastYear.Rows[i]["balunit"];
                dr["Slope1"] = (Convert.ToDecimal(dtLastYear.Rows[i]["slope"])*100).ToString("0.00")+"%";
                dr["Merchant2"] = dtLastYearMonth.Rows[i]["balunit"];
                dr["Slope2"] = (Convert.ToDecimal(dtLastYearMonth.Rows[i]["slope"]) * 100).ToString("0.00") + "%";
                dr["Merchant3"] = dtthisYear.Rows[i]["balunit"];
                dr["Slope3"] = (Convert.ToDecimal(dtthisYear.Rows[i]["slope"]) * 100).ToString("0.00") + "%";
                dt.Rows.Add(dr);
            }
        }
        return dt;
    }

    private DataTable GetTopTenMerchantTable(string startMonth, string endMonth)
    {
        string sql =
            @"select MERCHANT balunit,PROPORTION slope, sum(COMMISION) from TF_B_MERCHANTCOMMISION WHERE TRADEMONTH>=:STARTMONTH and TRADEMONTH<= :ENDMONTH     group by MERCHANT,PROPORTION order by sum(COMMISION) desc ";
        context.DBOpen("Select");
        context.AddField(":STARTMONTH").Value = startMonth;
        context.AddField(":ENDMONTH").Value = endMonth;
        DataTable dt = context.ExecuteReader(sql);
        context.DBCommit();
        return dt;
    }

    private DataTable ThisYearTradeMoney(string month)
    {  //今年刷卡量从售卡数据表获取
        string sql = " SELECT yearpayMoney/1000000 yearpayMoney FROM TF_MONTHCARD_PUNCHSALE t WHERE t.stattime=:MONTH AND t.cardid='215092'";
        context.DBOpen("Select");
        context.AddField(":MONTH").Value = month;
        DataTable dt = context.ExecuteReader(sql);
        context.DBCommit();
        return dt;
    }
}