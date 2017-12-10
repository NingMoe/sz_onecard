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
using TDO.BalanceChannel;
using Common;
using TDO.SupplyBalance;
using PDO.SpecialDeal;

public partial class ASP_SpecialDeal_SD_SupplyAutoReverseRecycle : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView();
             
            //初始化充值渠道
            ddlBalType_SelectedIndexChanged(sender, e);
        }
    }
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        //分页事件
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            //显示交易日期,格式为YYYY-MM-dd
            if (e.Row.Cells[3].Text.Length == 8)
                e.Row.Cells[3].Text = e.Row.Cells[3].Text.Substring(0, 4) + "-" + e.Row.Cells[3].Text.Substring(4, 2) + "-" + e.Row.Cells[3].Text.Substring(6, 2);

            //显示交易时间,格式为hh:mm:ss
            if (e.Row.Cells[4].Text.Length == 6)
                e.Row.Cells[4].Text = e.Row.Cells[4].Text.Substring(0, 2) + ":" + e.Row.Cells[4].Text.Substring(2, 2) + ":" + e.Row.Cells[4].Text.Substring(4, 2);

            //显示交易前金额,交易金额,单位为元
            e.Row.Cells[5].Text = (Convert.ToDouble(e.Row.Cells[5].Text)).ToString("n");
            e.Row.Cells[6].Text = (Convert.ToDouble(e.Row.Cells[6].Text)).ToString("n");
        }

        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[1].Visible = false;
        }
    }
    private void showNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }
    protected void CheckAll(object sender, EventArgs e)
    {
        //全选充值异常信息记录

        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            if (!gvr.Cells[0].Enabled) continue;
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }
    private bool QueryValidation()
    {
        //对非空交易起始和终止日期有效性的检测

        string strBeginDate = txtStartDate.Text.Trim();
        string strEndDate = txtEndDate.Text.Trim();

        DateTime? beginTime = null;
        DateTime? endTime = null;

        //当起始日期不为空的情况

        if (strBeginDate != "")
        {
            if (!Validation.isDate(strBeginDate, "yyyyMMdd"))
                context.AddError("A094570060:交易起始日期范围起始值格式必须为yyyyMMdd", txtStartDate);
            else
                beginTime = DateTime.ParseExact(strBeginDate, "yyyyMMdd", null);

        }

        //当终止期不为空的情况
        if (strEndDate != "")
        {
            if (!Validation.isDate(strEndDate, "yyyyMMdd"))
                context.AddError("A094570061:交易结束日期范围终止值格式必须为yyyyMMdd", txtEndDate);
            else
                endTime = DateTime.ParseExact(strEndDate, "yyyyMMdd", null);

        }

        //起始日期和终止日期都是合法日期格式时
        if (beginTime != null && endTime != null)
        {
            if (beginTime.Value.CompareTo(endTime.Value) > 0)
            {
                context.AddError("A094570062:交易起始日期不能大于交易结束日期", txtStartDate);
            }

        }

        //对非空卡号长度数字的判断
        string strCardNo = txtCardNo.Text.Trim();
        if (strCardNo != "")
        {
            if (Validation.strLen(strCardNo) != 16)
                context.AddError("A094570063:卡号必须为16位", txtCardNo);
            else if (!Validation.isNum(strCardNo))
                context.AddError("A094570064:卡号必须为数字", txtCardNo);
        }

        return context.hasError();
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //调用查询输入的判处理
        if (QueryValidation())
        {
            //置空异常记录信息列表
            showNonDataGridView();
            return;
        }

        //取得查询结果
        ICollection dataView = QueryResultColl();

        //没有查询出交易记录时,显示错误
        if (dataView.Count == 0)
        {
            context.AddError("A094570065:未查询出对应的充值自动冲正记录");
            //置空异常记录信息列表
            showNonDataGridView();
            return;
        }

        //显示查询结果信息
        gvResult.DataSource = dataView;
        gvResult.DataBind();
    }
    public ICollection QueryResultColl()
    {
        string funcCode = "QuerySupplyAutpReverse";
        if (this.ddlBalType.SelectedValue.Equals("0"))
        {
            funcCode = "QuerySupplyAutpReverseDeptBal";
        }
        DataTable data = SPHelper.callSDQuery(context, funcCode, txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), txtCardNo.Text.Trim(), selSupplyWay.SelectedValue);

        return new DataView(data);
    }
    private bool RecordIntoTmp()
    {
        //回收记录入临时表
        context.DBOpen("Insert");

        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                //++count;
                context.ExecuteNonQuery("insert into TMP_COMMON (f0,f1,f2,f3) values('" +
                     gvr.Cells[1].Text + "', '" + gvr.Cells[2].Text + "', '" + (Convert.ToDecimal(gvr.Cells[6].Text)*100).ToString() + "', '" + Session.SessionID + "')");
            }
        }

        context.DBCommit();

        return true;
    }
    protected void btnRecycle_Click(object sender, EventArgs e)
    {
        //回收校验 
        if (RecycleValidationFalse()) return;

        context.SPOpen();
        context.AddField("p_sessionID").Value = Session.SessionID; ;
        context.AddField("p_REMARK").Value = txtRenewRemark.Text.Trim();
        context.AddField("p_balType").Value = ddlBalType.SelectedValue;

        bool ok = context.ExecuteSP("SP_SD_AutoReverseRecycle");

        if (ok)
        {
            AddMessage("回收成功");
            //刷新列表
            btnQuery_Click(sender,e);
        }
    }
    private bool RecycleValidationFalse()
    {
        //对非空回收说明的长度校验
        if (txtRenewRemark.Text.Trim() != "" && Validation.strLen(txtRenewRemark.Text.Trim()) > 150)
        {
            context.AddError("A094570059", txtRenewRemark);
            return true;
        }

        //清空临时表数据
        clearTempTable();

        //选择的异常消费记录入临时表

        if (!RecordIntoTmp()) return true;        

        return false;
    }
    private void clearTempTable()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON where f3='"
            + Session.SessionID + "'");
        context.DBCommit();
    }

    /// <summary>
    /// 单元类型选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ddlBalType_SelectedIndexChanged(object sender, EventArgs e)
    {
        selSupplyWay.Items.Clear();

        if (this.ddlBalType.SelectedValue.Equals("0"))
        {
            context.DBOpen("Select");
            System.Text.StringBuilder sql = new System.Text.StringBuilder();
            sql.Append("SELECT DBALUNIT, DBALUNITNO	FROM TF_DEPT_BALUNIT WHERE USETAG = '1' AND DEPTTYPE = '2'");
            sql.Append("ORDER BY DBALUNITNO");

            System.Data.DataTable table = context.ExecuteReader(sql.ToString());
            GroupCardHelper.fill(selSupplyWay, table, true);
        }
        else
        {
            TMTableModule tmTMTableModule = new TMTableModule();
            TF_SELSUP_BALUNITTDO tdoTF_SELSUP_BALUNITIn = new TF_SELSUP_BALUNITTDO();
            TF_SELSUP_BALUNITTDO[] tdoTF_SELSUP_BALUNITOutArr = (TF_SELSUP_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_SELSUP_BALUNITIn, typeof(TF_SELSUP_BALUNITTDO), "S094570030", "TF_SELSUP_BALUNIT", null);
            ControlDeal.SelectBoxFill(selSupplyWay.Items, tdoTF_SELSUP_BALUNITOutArr, "BALUNIT", "BALUNITNO", true);
        }
    }
}