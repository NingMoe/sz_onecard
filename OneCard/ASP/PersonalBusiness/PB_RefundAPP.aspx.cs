using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using Common;

public partial class ASP_PersonalBusiness_PB_RefundAPP : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            ShowNonDataGridView();
            Init_Page();
        }

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
        gvResult.DataSource = Query();
        gvResult.DataBind();
    }
    //查询退款记录
    protected DataTable Query()
    {
        DataTable data = SPHelper.callPBQuery(context, "Query_RefundAPP", txtCardno.Text.Trim(), txtFromDate.Text.Trim(), txtToDate.Text.Trim());
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
        if (txtCardno.Text != "")
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

    protected void gvResult_Page(object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
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
            context.AddError("A004P03R01: 没有选中订单记录");
        }

    }


    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 输入校验
        string sessionID = Session.SessionID;
        ValidSubmit();
        if (context.hasError())
            return;
        FillTempTable(sessionID);
        string state = string.Empty;
        context.SPOpen();

        context.AddField("p_SESSIONID").Value = sessionID;
        bool ok = context.ExecuteSP("SP_PB_REFUNDAPP");
        if (ok)
        {
            AddMessage("允许退款成功");
        }
        //清空临时表
        ClearTempTable(sessionID);
        btnQuery_Click(sender, e);
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
                context.ExecuteNonQuery(@"insert into TMP_ORDER (f0,f1)
                                values('" + tradeid + "','" + sessionID + "')");
            }
        }
        context.DBCommit();

    }
    private void ClearTempTable(string sessionID)
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_ORDER  where f1='" + Session.SessionID + "'");
        context.DBCommit();
    }  
}