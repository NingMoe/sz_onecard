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
using TM;
using TDO.ConsumeBalance;
using TDO.BalanceChannel;
using TDO.UserManager;
using Common;
using PDO.SpecialDeal;

public partial class ASP_SpecialDeal_SD_TaxiConsumeInfoRecycle : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        //首次访问页面初始化
        if (!Page.IsPostBack)
        {   
            //初始查询待回收的出租补录信息
            InitQueryTaxiAppInfo();

            //清空临时表信息
            clearTempTable();

        }
    }


    private void clearTempTable()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_TAXICONSUME_REC_IMP where SessionId='"
            + Session.SessionID + "'");
        context.ExecuteNonQuery("delete from TMP_TAXICONSUME_RECYCYLE where SessionId='"
                    + Session.SessionID + "'");
        context.DBCommit();
    }


    public void InitQueryTaxiAppInfo()
    {
        //查补录后,待回收的出租消费信息
        gvResult.DataSource = QueryResultColl();
        gvResult.DataBind();

    }

    public ICollection QueryResultColl()
    {
        //查询待回收的出租补录消费信息
        // TF_B_TRADE_ACPMANUAL
        DataTable data = SPHelper.callSDQuery(context, "TaxiAppendQuery", "0");

        return  new DataView(data);
    }

    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        //分页显示事件
        gvResult.PageIndex = e.NewPageIndex;
        InitQueryTaxiAppInfo();
    }


    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        //出租补录数据行显示处理
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            ControlDeal.RowDataBound(e);
        }

        if (e.Row.RowType == DataControlRowType.Header 
            || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[0].Visible = false;
        }

    }

    protected void CheckAll(object sender, EventArgs e)
    {
        //全选异常信息记录
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            if (!gvr.Cells[1].Enabled) continue;
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }


    private bool RecordIntoTmp()
    {
        //回收记录入临时表
        context.DBOpen("Insert");

        int count = 0;
        int seq = 0;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                context.ExecuteNonQuery("insert into TMP_TAXICONSUME_REC_IMP values("
                    + (seq++) + ",'" + gvr.Cells[0].Text + "', '" + Session.SessionID + "')");
            }
        }

        context.DBCommit();

        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("A009104001");
            return false;
        }


        //从人工回收受理台帐中取得数据, 插入出租车消费信息回收临时表中
        context.DBOpen("Insert");

        string insertSql = "INSERT INTO TMP_TAXICONSUME_RECYCYLE " +
                           "(SEQ,TRADEID, ID ,CARDNO, RECTYPE ,ICTRADETYPECODE ,ASN," +
                           "CARDTRADENO,SAMNO, POSNO , POSTRADENO, TRADEDATE ,TRADETIME, " +
                           "PREMONEY,TRADEMONEY, SMONEY, BALUNITNO ,CALLINGNO, CORPNO," +
                           "DEPARTNO,CALLINGSTAFFNO,CITYNO, TAC,SOURCEID,DEALTIME, " +
                           "ERRORREASONCODE,DEALSTATECODE,STAFFNO,SessionId ) " +
                           "SELECT tmp.SEQ,tf.TRADEID,tf.ID,tf.CARDNO,tf.RECTYPE,tf.ICTRADETYPECODE,tf.ASN, " +
                           "tf.CARDTRADENO,tf.SAMNO,tf.POSNO,tf.POSTRADENO, tf.TRADEDATE ,tf.TRADETIME, " +
                           "tf.PREMONEY,tf.TRADEMONEY,tf.SMONEY, tf.BALUNITNO , tf.CALLINGNO, tf.CORPNO, " +
                           "tf.DEPARTNO,tf.CALLINGSTAFFNO, tf.CITYNO, tf.TAC, tf.SOURCEID, tf.DEALTIME, " +
                           "tf.ERRORREASONCODE,tf.DEALSTATECODE,tf.STAFFNO,tmp.SessionId " +
                           "FROM TF_B_TRADE_ACPMANUAL tf, TMP_TAXICONSUME_REC_IMP tmp	" +
                           "WHERE tf.TRADEID = tmp.TRADEID AND tmp.SessionId = '" + Session.SessionID + "'";

        context.ExecuteNonQuery(insertSql);

        context.DBCommit();
        return true;

    }

    private bool ValidationInput()
    { 
         //对非空回收说明的长度校验
        if (txtRenewRemark.Text.Trim() != "" && Validation.strLen(txtRenewRemark.Text.Trim()) > 150)
        {
            context.AddError("A009103023", txtRenewRemark);
            return false;
        }
        return true;

    }

    protected void btnRecycle_Click(object sender, EventArgs e)
    {
        //清空临时表信息
        clearTempTable();

        //选择回收的记录入临时表
        if (!RecordIntoTmp()) return;

        //回收说明长度的校验
        if (!ValidationInput()) return;

        //调用回收处理的存储过程
        SP_SD_TaxiConsumeRecPDO pdo = new SP_SD_TaxiConsumeRecPDO();
        pdo.renewRemark = txtRenewRemark.Text.Trim();
        pdo.sessionID = Session.SessionID;

        bool ok = TMStorePModule.Excute(context, pdo);
        //bool ok = true;
        if (ok)
        {
            AddMessage("M009104004");
        }

        //清空临时表数据
        clearTempTable();

        txtRenewRemark.Text = "";
        
        //查询出租补录信息
        InitQueryTaxiAppInfo();

    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        //清空临时表信息
        clearTempTable();

        //选择回收的记录入临时表
        if (!RecordIntoTmp()) return;

        //回收说明长度的校验
        if (!ValidationInput()) return;

        //调用作废处理的存储过程
        SP_SD_TaxiConsumeCancelPDO pdo = new SP_SD_TaxiConsumeCancelPDO();
        pdo.renewRemark = txtRenewRemark.Text.Trim();
        pdo.sessionID = Session.SessionID;

        bool ok = TMStorePModule.Excute(context, pdo);
        //bool ok = true;
        if (ok)
        {
            AddMessage("M009104005");
        }

        //清空临时表数据
        clearTempTable();

        txtRenewRemark.Text = "";

        //查询出租补录信息
        InitQueryTaxiAppInfo();
    }



}
