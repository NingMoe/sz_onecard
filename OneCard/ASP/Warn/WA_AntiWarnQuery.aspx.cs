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
using PDO.SpecialDeal;
using Common;
using TM;
using PDO.Warn;
using System.Collections.Generic;
using System.Xml;

public partial class ASP_Warn_WA_AntiWarnQuery : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 显示空列表表头

        UserCardHelper.resetData(gvResult, null);
        UserCardHelper.resetData(gridDetail, null);

        // 初始化下拉选项
        SPHelper.fillDDL(context, selCond, true, "SP_WA_Query", "WarnCondANTIDDL");

        selRiskGrade.Items.Add(new ListItem("---请选择---", ""));
        selRiskGrade.Items.Add(new ListItem("01:低风险", "01"));
        selRiskGrade.Items.Add(new ListItem("02:中风险", "02"));
        selRiskGrade.Items.Add(new ListItem("03:高风险", "03"));

        SPHelper.fillDDL(context, selSubjectType, true,
            "SP_WA_Query", "ANTIWarnTypeDDL", "SUBJECT_TYPE");

        selLimitType.Items.Add(new ListItem("---请选择---", ""));
        selLimitType.Items.Add(new ListItem("01:大额", "01"));
        selLimitType.Items.Add(new ListItem("02:可疑", "02"));

        txtBeginTime.Text = DateTime.Now.AddDays(-30).ToString("yyyyMMdd");
        txtEndTime.Text = DateTime.Now.ToString("yyyyMMdd");
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        selCond.SelectedIndex = 0;
        selRiskGrade.SelectedIndex = 0;
        selSubjectType.SelectedIndex = 0;
        selLimitType.SelectedIndex = 0;
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        hidSubjectType.Value = "";
        labCnt.Text = "0";
        labDetailCnt.Text = "0";
        UserCardHelper.resetData(gvResult, null);
        UserCardHelper.resetData(gridDetail, null);

        ValidateInfo();
        if (context.hasError())
        {
            return;
        }
        //取得查询结果 主体
        DataTable dataView = QueryWarns();

        if (dataView.Rows.Count == 0)
        {
            AddMessage("N007P00001: 查询结果为空");
            UserCardHelper.resetData(gvResult, null);
            UserCardHelper.resetData(gridDetail, null);
            return;
        }
        gvResult.DataSource = dataView;
        gvResult.DataBind();

        //取得查询结果，主体交易

        //DataTable dataViewdetail = QueryWarnsdetail();
        //gridDetail.DataSource = dataViewdetail;
        //gridDetail.DataBind();
    }

    private DataTable QueryWarns()
    {
        DataTable data = SPHelper.callWAQuery(context, "BHAntiSubjectQuery",
            selCond.SelectedValue,
            selRiskGrade.SelectedValue, selSubjectType.SelectedValue,
            selLimitType.SelectedValue, txtBeginTime.Text.Trim(), txtEndTime.Text.Trim());
        labCnt.Text = "" + data.Rows.Count;

        try
        {
            hidSubjectType.Value = data.Rows[0]["SUBJECTTYPE"].ToString();
        }
        catch
        {

        }
        if (hidSubjectType.Value == "02")
        {
            CommonHelper.AESSpeDeEncrypt(data, new List<string>(new string[] { "NAME", "PHONE", "ADDR", "PAPERNAME" }));
        }

        return data;
    }

    private DataTable QueryWarnsdetail()
    {
        DataTable data = SPHelper.callWAQuery(context, "AntiSubjectTradeQuery",
            selCond.SelectedValue,
            selRiskGrade.SelectedValue, selSubjectType.SelectedValue,
            selLimitType.SelectedValue, txtBeginTime.Text.Trim(), txtEndTime.Text.Trim());
        labDetailCnt.Text = "" + data.Rows.Count;

        return data;
    }
    private DataTable QueryWarnsdetailTMP()
    {
        DataTable data = SPHelper.callWAQuery(context, "BHAntiSubjectTradeQueryTMP");
        labDetailCnt.Text = "" + data.Rows.Count;

        if (hidSubjectType.Value == "02")
        {
            CommonHelper.AESSpeDeEncrypt(data, new List<string>(new string[] { "NAME", "PAPERNAME" }));
        }
        return data;
    }

    //带临时表
    private DataTable QueryWarnsXML()
    {
        DataTable data = SPHelper.callWAQuery(context, "BHAntiSubjectQueryXML",
            selCond.SelectedValue,
            selRiskGrade.SelectedValue, selSubjectType.SelectedValue,
            selLimitType.SelectedValue, txtBeginTime.Text.Trim(), txtEndTime.Text.Trim());
        labCnt.Text = "" + data.Rows.Count;

        return data;
    }
    //带临时表
    private DataTable QueryWarnsdetailXML()
    {
        DataTable data = SPHelper.callWAQuery(context, "BHAntiSubjectTradeQueryXML",
            selCond.SelectedValue,
            selRiskGrade.SelectedValue, selSubjectType.SelectedValue,
            selLimitType.SelectedValue, txtBeginTime.Text.Trim(), txtEndTime.Text.Trim());
        labDetailCnt.Text = "" + data.Rows.Count;

        return data;
    }
    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }
    protected void ValidateInfo()
    {
        //监控条件不能为空
        if (selCond.SelectedValue == "")
        {
            context.AddError("监控条件不能为空", selCond);
            return;
        }

        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkSubject");
            if (cb != null && cb.Checked)
            {
                String papertype = GetTableCellValue(gvr.Cells[5]);
                String papername = GetTableCellValue(gvr.Cells[6]);
                if (papertype == "11")
                {
                    if (!CommonHelper.CheckIDCard(papername))
                    {
                        context.AddError("证件号码不符合要求，请查验");
                        return;
                    }
                }

            }
        }
    }

    // 业务转发
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "Close")
        {
            btnClose_Click(sender, e);
        }

        hidWarning.Value = "";
    }

    private int insertSubjectIDToTmpTable()
    {
        int count = 0;

        context.DBOpen("Insert");

        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkSubject");
            if (cb != null && cb.Checked)
            {
                ++count;
                String id = gvr.Cells[2].Text;
                context.ExecuteNonQuery("insert into TMP_COMMON_ANTI1 (F0) "
               + " values('" + id + "')");
            }
        }

        if (context.hasError())
        {
            context.RollBack();
            return 0;
        }

        context.DBCommit();
        return count;
    }


    protected void btnClose_Click(object sender, EventArgs e)
    {
        clearNewTempTable();

        if (insertSubjectIDToTmpTable() <= 0)
        {
            context.AddError("A860400101: 未选中任何主体");
            return;
        }

        SP_WA_WarnManagePDO pdo = new SP_WA_WarnManagePDO();
        pdo.funcCode = "ANTICLOSERETURN";
        pdo.backWhy = "0"; // 关闭
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok) AddMessage("D860400001: 主体关闭成功");

        btnQuery_Click(sender, e);

        clearNewTempTable();
    }

    public void clearNewTempTable()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON_ANTI1");
        context.ExecuteNonQuery("delete from TMP_COMMON_ANTI2");
        context.DBCommit();
    }
    protected void btnExportXML_Click(object sender, EventArgs e)
    {
        ValidateInfo();
        if (context.hasError())
        {
            return;
        }
        clearNewTempTable();

        int countSubject = 0;
        context.DBOpen("Insert");

        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkSubject");
            if (cb != null && cb.Checked)
            {
                ++countSubject;
                String id = gvr.Cells[2].Text;
                context.ExecuteNonQuery("insert into TMP_COMMON_ANTI1 (F0) "
               + " values('" + id + "')");
            }
        }
        int countDetail = 0;
        foreach (GridViewRow gvr in gridDetail.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkDetail");
            if (cb != null && cb.Checked)
            {
                ++countDetail;
                String id = gvr.Cells[2].Text;
                context.ExecuteNonQuery("insert into TMP_COMMON_ANTI2 (F0) "
               + " values('" + id + "')");
            }
        }
        context.DBCommit();
        //必须选中至少一个主体才能导出

        if (countSubject < 1)
        {
            context.AddError("A860400101: 未选中任何主体");
            return;
        }
        //必须选中至少一个主体才能导出

        if (countDetail < 1)
        {
            context.AddError("A860400101: 未选中任何主体交易数据");
            return;
        }
        DataTable dt = QueryWarnsXML();
        DataTable dt1 = QueryWarnsdetailXML();
        //文件格式：报文类型和交易报告类型标识+报告机构编码+报送日期+当日报送批次+文件在该批次中的编号
        //普通报文以N开头，重发报文以R开头，纠错报文以C开头

        CommonHelper.AESSpeDeEncrypt(dt, new List<string>(new string[] { "NAME", "PHONE", "ADDR", "PAPERNAME" }));

        CommonHelper.AESSpeDeEncrypt(dt1, new List<string>(new string[] { "NAME", "PAPERNAME" }));

        ExportToXML("NPSZ2006532000019-" + DateTime.Now.ToString("yyyyMMdd") + "-0001-0001", dt, dt1);
    }


    protected void chkAllSubject_CheckedChanged(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        if (cbx.ID == "chkAllSubject")
        {
            foreach (GridViewRow gvr in gvResult.Rows)
            {

                CheckBox ch = (CheckBox)gvr.FindControl("chkSubject");
                ch.Checked = cbx.Checked;
            }
        }



        labDetailCnt.Text = "0";
        UserCardHelper.resetData(gridDetail, null);

        clearNewTempTable();
        int count = insertSubjectIDToTmpTable();
        //取得查询结果，主体交易

        DataTable dataViewdetail = QueryWarnsdetailTMP();
        gridDetail.DataSource = dataViewdetail;
        gridDetail.DataBind();

    }

    protected void ExportToXML(string filename, DataTable subjectDT, DataTable detailDT)
    {
        Response.Clear();
        //Response.Buffer = true;
        Response.Charset = "GB18030";
        Response.ContentType = "text/xml";
        Response.AddHeader("Content-disposition", "attachment; filename=" + System.Web.HttpUtility.UrlEncode(filename, System.Text.Encoding.UTF8) + ".XML");
        Response.ContentEncoding = System.Text.Encoding.GetEncoding("GB18030");
        this.EnableViewState = false;
        Response.Write("<?xml version=\"1.0\" encoding=\"GB18030\"?>");
        Response.Write("\r\n");
        Response.Write("<PSTR>");

        Response.Write("<RBIF>");
        Response.Write("<RINM>苏州市民卡有限公司</RINM>");
        Response.Write("<FIRC>320503</FIRC>");
        Response.Write("<FICD>@I</FICD>");
        Response.Write("<RFSG>1</RFSG>");
        Response.Write("<ORXN>@N</ORXN>");
        Response.Write("<SSTM>01</SSTM>");
        Response.Write("<STCR>01</STCR>");
        Response.Write("<SSDS>" + selCond.Items[selCond.SelectedIndex].Text + "</SSDS>");
        Response.Write("<UDSI>" + selCond.SelectedValue + "</UDSI>");
        Response.Write("<SCTN>" + subjectDT.Rows.Count.ToString() + "</SCTN>");
        Response.Write("<TTNM>" + detailDT.Rows.Count.ToString() + "</TTNM>");
        Response.Write("</RBIF>");

        //可疑主体
        int i = 0;
        Response.Write("<CTIFs>");
        foreach (DataRow dr in subjectDT.Rows)
        {
            Response.Write("<CTIF seqno=\"" + (++i).ToString() + "\">");
            Response.Write("<CTNM>" + ReplaceStr(dr["NAME"].ToString(), "不记名主体") + "</CTNM>");
            Response.Write("<SMID>" + ReplaceStr(dr["SUBJECTCODE"].ToString(), "@N") + "</SMID>");
            Response.Write("<CITP>" + ReplaceStr(dr["PAPERTYPE"].ToString(), "11") + "</CITP>");
            Response.Write("<CTID>" + ReplaceStr(dr["PAPERNAME"].ToString(), "321281198601012899") + "</CTID>");
            Response.Write("<CCIF>");
            Response.Write("<CTAR>" + ReplaceStr(dr["ADDR"].ToString()) + "</CTAR>");
            Response.Write("<CCTL>" + ReplaceStr(dr["PHONE"].ToString()) + "</CCTL>");
            Response.Write("<CEML>" + ReplaceStr(dr["EMAIL"].ToString()) + "</CEML>");
            Response.Write("</CCIF>");
            Response.Write("<CTVC>1H</CTVC>");
            Response.Write("<CRNM>@N</CRNM>");
            Response.Write("<CRIT>@N</CRIT>");
            Response.Write("<CRID>@N</CRID>");
            Response.Write("</CTIF>");
        }

        Response.Write("</CTIFs>");

        //可疑交易
        int j = 0;
        Response.Write("<STIFs>");
        foreach (DataRow dr in detailDT.Rows)
        {
            Response.Write("<STIF seqno=\"" + (++j).ToString() + "\">");
            Response.Write("<CTNM>" + ReplaceStr(dr["NAME"].ToString(), "不记名主体") + "</CTNM>");
            Response.Write("<CITP>" + ReplaceStr(dr["PAPERTYPE"].ToString(), "11") + "</CITP>");
            Response.Write("<CTID>" + ReplaceStr(dr["PAPERNAME"].ToString(), "321281198601012899") + "</CTID>");
            Response.Write("<CBAT>@I</CBAT>");
            Response.Write("<CBAC>@I</CBAC>");
            Response.Write("<CABM>@I</CABM>");
            Response.Write("<CTAT>02</CTAT>");
            Response.Write("<CTAC>" + ReplaceStr(dr["CARDNO"].ToString(), "2150000000000000") + "</CTAC>");
            Response.Write("<CPIN>苏州市民卡有限公司</CPIN>");
            Response.Write("<CPBA>7066602001120105002221</CPBA>");
            Response.Write("<CPBN>苏州银行分行营业部</CPBN>");
            Response.Write("<CTIP>@I</CTIP>");
            Response.Write("<TSTM>" + Convert.ToDateTime(dr["TRADETIME"].ToString()).ToString("yyyyMMddHHmmss") + "</TSTM>");
            Response.Write("<CTTP>" + ReplaceStr(dr["PAYMODE"].ToString(), "0400") + "</CTTP>");
            Response.Write("<TSDR>" + ReplaceStr(dr["PAYMENTTAG"].ToString(), "02") + "</TSDR>");
            Response.Write("<CRPP>@I</CRPP>");
            Response.Write("<CRTP>CNY</CRTP>");
            Response.Write("<CRAT>" + ReplaceStr(dr["TRADEMONEY"].ToString()) + "</CRAT>");
            Response.Write("<TCNM>" + ReplaceStr(dr["PARTNERNAME"].ToString(), "无相关信息") + "</TCNM>");
            Response.Write("<TSMI>" + ReplaceStr(dr["PARTNERNO"].ToString()) + "</TSMI>");
            Response.Write("<TCIT>21</TCIT>");
            Response.Write("<TCID>000000000</TCID>");
            Response.Write("<TCAT>@I</TCAT>");
            Response.Write("<TCBA>@I</TCBA>");
            Response.Write("<TCBN>@I</TCBN>");
            Response.Write("<TCTT>@N</TCTT>");
            Response.Write("<TCTA>" + ReplaceStr(dr["CARDNO"].ToString(), "2150000000000000") + "</TCTA>");
            Response.Write("<TCPN>苏州市民卡有限公司</TCPN>");
            Response.Write("<TCPA>7066602001120105002221</TCPA>");
            Response.Write("<TPBN>苏州银行分行营业部</TPBN>");
            Response.Write("<TCIP>@I</TCIP>");
            Response.Write("<TMNM>@I</TMNM>");
            Response.Write("<BPTC>00000000</BPTC>");
            Response.Write("<PMTC>" + ReplaceStr(dr["TRADEID"].ToString(), "0000000000") + "</PMTC>");
            Response.Write("<TICD>" + ReplaceStr(dr["TRADEID"].ToString(), "0000000000") + "</TICD>");
            Response.Write("</STIF>");
        }
        Response.Write("</STIFs>");

        Response.Write("</PSTR>");
        Response.Write("\r\n");
        Response.Flush();
        Response.End();
    }

    protected string ReplaceStr(string str1, string str2)
    {
        if (string.IsNullOrEmpty(str1.Trim()))
        {
            return str2.Trim();
        }
        return str1.Trim();
    }
    protected string ReplaceStr(string str1)
    {
        return ReplaceStr(str1, "@I");//因报告机构自身业务系统原因暂时无法得到的数据项

    }
    protected void selCond_SelectedIndexChanged(object sender, EventArgs e)
    {
        labCnt.Text = "0";
        labDetailCnt.Text = "0";
        UserCardHelper.resetData(gvResult, null);
        UserCardHelper.resetData(gridDetail, null);
    }
}
