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

public partial class ASP_TaxiService_TS_ReadCardRecord : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (!context.s_Debugging)
                txtCardno.Attributes["readonly"] = "true";

            //btnSave.Enabled = false;


            //初始化数据类型
            selTradeTypes.Items.Add(new ListItem("老司机卡内交易记录", "0"));
            selTradeTypes.Items.Add(new ListItem("银联闪付交易记录", "1"));
            selTradeTypes.Items.Add(new ListItem("新司机卡内交易记录", "2"));
            selTradeTypes.Items.Add(new ListItem("省一卡通交易记录", "3"));
            selTradeTypes.SelectedIndex = -1;

            lvwQuery.Visible = true;
            lvwQueryYL.Visible = false;
            lvwQuerySMK.Visible = false;
            lvwQueryJT.Visible = false;
            btnReadCard.Visible = true;
            btnReadCardYL.Visible = false;
            btnReadCardSMK.Visible = false;
            btnReadCardJT.Visible = false;
            lvwQuery.DataSource = new DataTable();
            lvwQuery.DataBind();
        }
    }

    protected void selTradeTypes_Changed(object sender, EventArgs e)
    {
        if (selTradeTypes.SelectedValue == "0")
        {
            lvwQuery.Visible = true;
            lvwQueryYL.Visible = false;
            lvwQuerySMK.Visible = false;
            lvwQueryJT.Visible = false;
            btnReadCard.Visible = true;
            btnReadCardYL.Visible = false;
            btnReadCardSMK.Visible = false;
            btnReadCardJT.Visible = false;
            lvwQuery.DataSource = new DataTable();
            lvwQuery.DataBind();
        }
        else if (selTradeTypes.SelectedValue == "1")
        {
            lvwQuery.Visible = false;
            lvwQueryYL.Visible = true;
            lvwQuerySMK.Visible = false;
            lvwQueryJT.Visible = false;
            btnReadCard.Visible = false;
            btnReadCardYL.Visible = true;
            btnReadCardSMK.Visible = false;
            btnReadCardJT.Visible = false;
            lvwQueryYL.DataSource = new DataTable();
            lvwQueryYL.DataBind();
        }
        else if (selTradeTypes.SelectedValue == "2")
        {
            lvwQuery.Visible = false;
            lvwQueryYL.Visible = false;
            lvwQuerySMK.Visible = true;
            lvwQueryJT.Visible = false;
            btnReadCard.Visible = false;
            btnReadCardYL.Visible = false;
            btnReadCardSMK.Visible = true;
            btnReadCardJT.Visible = false;
            lvwQuerySMK.DataSource = new DataTable();
            lvwQuerySMK.DataBind();
        }
        else if (selTradeTypes.SelectedValue == "3")
        {
            lvwQuery.Visible = false;
            lvwQueryYL.Visible = false;
            lvwQuerySMK.Visible = false;
            lvwQueryJT.Visible = true;
            btnReadCard.Visible = false;
            btnReadCardYL.Visible = false;
            btnReadCardSMK.Visible = false;
            btnReadCardJT.Visible = true;
            lvwQueryJT.DataSource = new DataTable();
            lvwQueryJT.DataBind();
        }
    }

    #region 老司机卡交易记录
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        //显示记录
        String strDriverRecd = hidDriverRecord.Value.Trim();

        //strDriverRecd = "010021500000021181009800009700001000000000AE00DE000116750C785B5D20080814182900";
       
        //strDriverRecd += strDriverRecd;
        //strDriverRecd += strDriverRecd;
        //strDriverRecd += strDriverRecd;
        //strDriverRecd += strDriverRecd;
        //strDriverRecd += strDriverRecd;

        int len = strDriverRecd.Length ;
        int cols = 78;
        int count = (int)(len / cols);

        lvwQuery.DataSource = ShowCardRecords(len, cols, count, strDriverRecd);
        lvwQuery.DataBind();

        //btnSave.Enabled = true;

    }




    private ICollection ShowCardRecords(int len, int cols, int count, string strDriverRecd)
    {
        DataTable table = new DataTable();
        table.Columns.Add(new DataColumn("TRADEMONEY", typeof(String)));
        table.Columns.Add(new DataColumn("PSAMNO", typeof(String)));
        table.Columns.Add(new DataColumn("CARDTRADENO", typeof(String)));
        table.Columns.Add(new DataColumn("TRADEDATE", typeof(String)));
        table.Columns.Add(new DataColumn("TRADETIME", typeof(String)));
        table.Columns.Add(new DataColumn("TAC", typeof(String)));
        table.Columns.Add(new DataColumn("OUTLINECARDTRADENO", typeof(String)));
        table.Columns.Add(new DataColumn("ASN", typeof(String)));
        table.Columns.Add(new DataColumn("PREMONEY", typeof(String)));

        DataRow row;
        for (int i = 0; i < count; ++i)
        {
            row = table.NewRow();
            row["TRADEMONEY"] = Convert.ToInt32(strDriverRecd.Substring(cols * i + 0, 8),16);
            row["PSAMNO"] = strDriverRecd.Substring(cols * i + 8, 12);
            row["CARDTRADENO"] = strDriverRecd.Substring(cols * i + 20, 8);
            row["TRADEDATE"] = strDriverRecd.Substring(cols * i + 28, 8);
            row["TRADETIME"] = strDriverRecd.Substring(cols * i + 36, 6);
            row["TAC"] = strDriverRecd.Substring(cols * i + 42, 8);
            row["OUTLINECARDTRADENO"] = strDriverRecd.Substring(cols * i + 50, 4);
            row["ASN"] = strDriverRecd.Substring(cols * i + 54, 16);
            row["PREMONEY"] = Convert.ToInt32(strDriverRecd.Substring(cols * i + 70, 8), 16);
            table.Rows.Add(row);
        }

        DataView dataView = new DataView(table);
        return dataView;
    }

    #endregion 

    #region 银联交易记录

    protected void btnReadCardYL_Click(object sender, EventArgs e)
    {
        //显示记录
        String strDriverRecdYL = hidDriverRecordYL.Value.Trim();

        int len = strDriverRecdYL.Length;
        int cols = 226;
        int count = (int)(len / cols);

        lvwQueryYL.DataSource = ShowCardRecordsYL(len, cols, count, strDriverRecdYL);
        lvwQueryYL.DataBind();
    }
    private ICollection ShowCardRecordsYL(int len, int cols, int count, string strDriverRecdYL)
    {

        DataTable table = new DataTable();
        table.Columns.Add(new DataColumn("TRADETYPE", typeof(String)));
        table.Columns.Add(new DataColumn("TRADEID", typeof(String)));
        table.Columns.Add(new DataColumn("TRADEDATE", typeof(String)));
        table.Columns.Add(new DataColumn("TRADETIME", typeof(String)));
        table.Columns.Add(new DataColumn("MAINACCOUNT", typeof(String)));
        table.Columns.Add(new DataColumn("TRADEMONEY", typeof(String)));
        table.Columns.Add(new DataColumn("VAILDTIME", typeof(String)));
        table.Columns.Add(new DataColumn("ASN", typeof(String)));
        table.Columns.Add(new DataColumn("APPCIPHER", typeof(String)));
        table.Columns.Add(new DataColumn("APPLICATIONDATA", typeof(String)));
        table.Columns.Add(new DataColumn("UNPREDICTABLE", typeof(String)));
        table.Columns.Add(new DataColumn("APPCOUNT", typeof(String)));
        table.Columns.Add(new DataColumn("VERRESULTS", typeof(String)));
        table.Columns.Add(new DataColumn("FILENAME", typeof(String)));
        table.Columns.Add(new DataColumn("AUTHORIZATIONCODE", typeof(String)));

        DataRow row;
        for (int i = 0; i < count; ++i)
        {
            row = table.NewRow();
            row["TRADETYPE"] = strDriverRecdYL.Substring(cols * i + 0, 2);
            row["TRADEID"] = strDriverRecdYL.Substring(cols * i + 2, 8);
            row["TRADEDATE"] = strDriverRecdYL.Substring(cols * i + 10, 8);
            row["TRADETIME"] = strDriverRecdYL.Substring(cols * i + 18, 6);
            row["MAINACCOUNT"] = strDriverRecdYL.Substring(cols * i + 24, 22);
            row["TRADEMONEY"] = strDriverRecdYL.Substring(cols * i + 46, 12);
            row["VAILDTIME"] = strDriverRecdYL.Substring(cols * i + 58, 4);
            row["ASN"] = strDriverRecdYL.Substring(cols * i + 62, 4);
            row["APPCIPHER"] = strDriverRecdYL.Substring(cols * i + 66, 18);
            row["APPLICATIONDATA"] = strDriverRecdYL.Substring(cols * i + 84, 66);
            row["UNPREDICTABLE"] = strDriverRecdYL.Substring(cols * i + 150, 10);
            row["APPCOUNT"] = strDriverRecdYL.Substring(cols * i + 160, 6);
            row["VERRESULTS"] = strDriverRecdYL.Substring(cols * i + 166, 12);
            row["FILENAME"] = strDriverRecdYL.Substring(cols * i + 178, 34);
            row["AUTHORIZATIONCODE"] = strDriverRecdYL.Substring(cols * i + 212, 14);
            table.Rows.Add(row);
        }

        DataView dataView = new DataView(table);
        return dataView;
    }

    #endregion

    #region 新司机卡交易记录
    protected void btnReadCardSMK_Click(object sender, EventArgs e)
    {
        //显示记录
        String strDriverRecdSMK = hidDriverRecordSMK.Value.Trim();

        int len = strDriverRecdSMK.Length;
        int cols = 78;
        int count = (int)(len / cols);

        lvwQuerySMK.DataSource = ShowCardRecordsSMK(len, cols, count, strDriverRecdSMK);
        lvwQuerySMK.DataBind();
    }

    private ICollection ShowCardRecordsSMK(int len, int cols, int count, string strDriverRecdSMK)
    {

        DataTable table = new DataTable();
        table.Columns.Add(new DataColumn("TRADEMONEY", typeof(String)));
        table.Columns.Add(new DataColumn("PSAMNO", typeof(String)));
        table.Columns.Add(new DataColumn("CARDTRADENO", typeof(String)));
        table.Columns.Add(new DataColumn("TRADEDATE", typeof(String)));
        table.Columns.Add(new DataColumn("TRADETIME", typeof(String)));
        table.Columns.Add(new DataColumn("TAC", typeof(String)));
        table.Columns.Add(new DataColumn("OUTLINECARDTRADENO", typeof(String)));
        table.Columns.Add(new DataColumn("ASN", typeof(String)));
        table.Columns.Add(new DataColumn("PREMONEY", typeof(String)));

        DataRow row;
        for (int i = 0; i < count; ++i)
        {
            row = table.NewRow();
            row["TRADEMONEY"] = Convert.ToInt32(strDriverRecdSMK.Substring(cols * i + 0, 8),16);
            row["PSAMNO"] = strDriverRecdSMK.Substring(cols * i + 8, 12);
            row["CARDTRADENO"] = strDriverRecdSMK.Substring(cols * i + 20, 8);
            row["TRADEDATE"] = strDriverRecdSMK.Substring(cols * i + 28, 8);
            row["TRADETIME"] = strDriverRecdSMK.Substring(cols * i + 36, 6);
            row["TAC"] = strDriverRecdSMK.Substring(cols * i + 42, 8);
            row["OUTLINECARDTRADENO"] = strDriverRecdSMK.Substring(cols * i + 50, 4);
            row["ASN"] = strDriverRecdSMK.Substring(cols * i + 54, 16);
            row["PREMONEY"] = Convert.ToInt32(strDriverRecdSMK.Substring(cols * i + 70, 8),16);
            table.Rows.Add(row);
        }

        DataView dataView = new DataView(table);
        return dataView;
    }

    #endregion

    #region 省卡交易记录
    protected void btnReadCardJT_Click(object sender, EventArgs e)
    {
        //显示记录
        String strDriverRecdJT = hidDriverRecordJT.Value.Trim();

        int len = strDriverRecdJT.Length;
        int cols = 98;
        int count = (int)(len / cols);

        lvwQueryJT.DataSource = ShowCardRecordsJT(len, cols, count, strDriverRecdJT);
        lvwQueryJT.DataBind();
    }

    private ICollection ShowCardRecordsJT(int len, int cols, int count, string strDriverRecdJT)
    {

        DataTable table = new DataTable();
        table.Columns.Add(new DataColumn("TRADEMONEY", typeof(String)));
        table.Columns.Add(new DataColumn("PSAMNO", typeof(String)));
        table.Columns.Add(new DataColumn("CARDTRADENO", typeof(String)));
        table.Columns.Add(new DataColumn("TRADEDATE", typeof(String)));
        table.Columns.Add(new DataColumn("TRADETIME", typeof(String)));
        table.Columns.Add(new DataColumn("TAC", typeof(String)));
        table.Columns.Add(new DataColumn("OUTLINECARDTRADENO", typeof(String)));
        table.Columns.Add(new DataColumn("ASN", typeof(String)));
        table.Columns.Add(new DataColumn("PREMONEY", typeof(String)));
        table.Columns.Add(new DataColumn("ISSUERCODE", typeof(String)));
        table.Columns.Add(new DataColumn("KEYVERSION", typeof(String)));
        table.Columns.Add(new DataColumn("KEYINDEX", typeof(String)));
        table.Columns.Add(new DataColumn("PSAM", typeof(String)));
        table.Columns.Add(new DataColumn("RESERVE", typeof(String)));
        DataRow row;
        for (int i = 0; i < count; ++i)
        {
            row = table.NewRow();
            row["TRADEMONEY"] = Convert.ToInt32(strDriverRecdJT.Substring(cols * i + 0, 8),16);
            row["PSAMNO"] = strDriverRecdJT.Substring(cols * i + 8, 12);
            row["CARDTRADENO"] = strDriverRecdJT.Substring(cols * i + 20, 8);
            row["TRADEDATE"] = strDriverRecdJT.Substring(cols * i + 28, 8);
            row["TRADETIME"] = strDriverRecdJT.Substring(cols * i + 36, 6);
            row["TAC"] = strDriverRecdJT.Substring(cols * i + 42, 8);
            row["OUTLINECARDTRADENO"] = strDriverRecdJT.Substring(cols * i + 50, 4);
            row["ASN"] = strDriverRecdJT.Substring(cols * i + 54, 20);
            row["PREMONEY"] = Convert.ToInt32(strDriverRecdJT.Substring(cols * i + 74, 8),16);
            row["ISSUERCODE"] = strDriverRecdJT.Substring(cols * i + 82, 8);
            row["KEYVERSION"] = strDriverRecdJT.Substring(cols * i + 90, 2);
            row["KEYINDEX"] = strDriverRecdJT.Substring(cols * i + 92, 2);
            row["PSAM"] = strDriverRecdJT.Substring(cols * i + 94, 2);
            row["RESERVE"] = strDriverRecdJT.Substring(cols * i + 96, 2);
            table.Rows.Add(row);
        }

        DataView dataView = new DataView(table);
        return dataView;
    }

    #endregion

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (selTradeTypes.SelectedValue == "0")
        {
            //保存处理
            ExportGridView(lvwQuery);
        }
        else if (selTradeTypes.SelectedValue == "1")
        {
            ExportGridView(lvwQueryYL);
        }
        else if (selTradeTypes.SelectedValue == "2")
        {
            ExportGridView(lvwQuerySMK);
        }
        else if (selTradeTypes.SelectedValue == "3")
        {
            ExportGridView(lvwQueryJT);
        }
    }

}
