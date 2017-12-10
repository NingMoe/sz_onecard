using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using System.Data;

public partial class ASP_PersonalBusiness_PB_RefundNFC : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            ShowNonDataGridView();
            Init_Page();
        }
        gvResult.DataKeyNames = new string[] { "TRADEID", "BALUNIT", "CARDNO", "ASN", "CARDTRADENO", "CARDOLDBAL", "TRADEMONEY", "TRADEDATE", "CUSTNAME", "CUSTPHONE", "REMARK", "REFUNDSTATUS" };

    }
    /// <summary>
    /// 初始化列表
    /// </summary>
    private void ShowNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }
    protected void Init_Page()
    {
        //初始化日期
        DateTime date = new DateTime();
        date = DateTime.Today;
        txtFromDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");

    }
    /// <summary>
    /// 查询
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!DateValidation())
            return;
        gvResult.DataSource = QueryRefundNFC();
        gvResult.DataBind();
    }
    //查询退款记录
    protected DataTable QueryRefundNFC()
    {
        DataTable data = SPHelper.callPBQuery(context, "Query_RefundNFC", txtCardno.Text.Trim(), selExamState.SelectedValue, txtFromDate.Text.Trim(), txtToDate.Text.Trim());
        if (data.Rows.Count == 0)
        {
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return data;
    }
    private Boolean DateValidation()
    {
        //对开始日期结束日期进行校验
        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, true);
        txtCardno.Text = txtCardno.Text.Trim();
        //对卡号进行长度、数字检验
        if (txtCardno.Text !="")
        {
            if (!Validation.isNum(txtCardno.Text.Trim()))
            {
                context.AddError("A001004115", txtCardno);
                return false;
            }
            else if (txtCardno.Text.Length != 16)
            {
                context.AddError("A001004115:卡号长度必须是16位", txtCardno);
                return false;
            }
        }
       
        return !(context.hasError());
    }
    /// <summary>
    /// 审核按钮事件（通过/作废）
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 输入校验
        string sessionID = Session.SessionID;
        ValidSubmit();
        if (context.hasError())
            return;
        FillTempTable(sessionID);
        string state=string.Empty;
        if (chkApprove.Checked)
        {
            state = "1";//允许退款
        }
        else
        {
            state = "2";//不允许退款
        }
        context.SPOpen();
        
        context.AddField("p_SESSIONID").Value = sessionID;
        context.AddField("p_STATE").Value = state;
        bool ok = context.ExecuteSP("SP_PB_REFUNDNFC");
        if (ok)
        {
            AddMessage("审核成功");
        }
        //清空临时表
        ClearTempTable(sessionID);
        btnQuery_Click(sender, e);
    }
 
    protected void lvwQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
    }
    public void lvwQuery_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwQuery.PageIndex = e.NewPageIndex;
        //btnQueryImpl();
    }
    // 通过 复选框 改变事件
    protected void chkApprove_CheckedChanged(object sender, EventArgs e)
    {
        if (chkApprove.Checked)
        {
            chkReject.Checked = false;
        }

        btnSubmit.Enabled = (chkApprove.Checked || chkReject.Checked);
    }

    // 作废 复选框 改变事件
    protected void chkReject_CheckedChanged(object sender, EventArgs e)
    {
        if (chkReject.Checked)
        {
            chkApprove.Checked = false;
        }
        btnSubmit.Enabled = (chkApprove.Checked || chkReject.Checked);
    }
    protected void gvResult_Page(object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }
    public String getDataKeys(String keysname, int selectindex)
    {
        return gvResult.DataKeys[selectindex][keysname].ToString();
    }
    // 选中gridview中当前页所有数据项
    protected void CheckAll(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }
    
    //显示卡内交易记录
    protected void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        int index = gvResult.SelectedIndex;
        string cardNo = getDataKeys("CARDNO", index);//卡号
        DataTable data = SPHelper.callPBQuery(context, "QueryCardRecords", cardNo);
        UserCardHelper.resetData(lvwQuery, data);

        if (data.Rows.Count == 0)
        {
            context.AddError("A001023103");
            return;
        }
    }
    /// <summary>
    /// 验证提交
    /// </summary>
    private void ValidSubmit()
    {
        int count = 0;
        for (int index = 0; index < gvResult.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvResult.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
            }

        }
        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("A004P03R01: 没有选中退款申请记录");
        }
       
    }
    private void FillTempTable(string sessionID)
    {

        //记录入临时表
        context.DBOpen("Insert");
        for (int index = 0; index < gvResult.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvResult.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                string tradeid = gvResult.Rows[index].Cells[1].Text.Trim();//流水号

                //F0:流水号，F1：SessionID
                context.ExecuteNonQuery(@"insert into TMP_COMMON (f0,f1)
                                values('" + tradeid + "','" + sessionID + "')");
            }
        }
        context.DBCommit();

    }
    private void ClearTempTable(string sessionID)
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON  where f1='" + Session.SessionID + "'");
        context.DBCommit();
    }  
}