using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using PDO.GroupCard;
using TM;

// 企服卡后台充值财务审核

public partial class ASP_CustomerAcc_CA_BatchChargeFiApproval : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 创建临时表
        GroupCardHelper.createTempTable(context);

        createGridViewData();
    }

    // 创建gridview数据
    private void createGridViewData()
    {
        // 从充值总量台帐表中查询信息
        DataTable data = SPHelper.callQuery("SP_CA_Query", context, "ChargeFiItems", new string[1]);
        UserCardHelper.resetData(gvResult, data);

        bool enabled = (data.Rows.Count > 0);

        chkApprove.Enabled = enabled;
        chkReject.Enabled = enabled;

        chkApprove.Checked = false;
        chkReject.Checked = false;
        btnSubmit.Enabled = false;
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

    // gridview换页事件
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        createGridViewData();
    }

    // 提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (chkApprove.Checked)
        {
            submitApproval("2", "D006014021: 审核通过");
        }
        else
        {
            submitApproval("3", "D006014022: 审核作废");
        }
    }

    // 调用充值财务审核存储过程
    private void submitApproval(string stateCode, string okMsgCode)
    {
        GroupCardHelper.fillBatchNoList(context, gvResult, Session.SessionID);
        if (context.hasError()) return;

        // 调用财务审核存储过程
        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        context.AddField("P_STATECODE").Value = stateCode;// '2' Approved, '3' Rejected
        bool ok = context.ExecuteSP("SP_CA_BATCHCHARGEFIAPPROVAL");

        if (ok) AddMessage(okMsgCode);

        createGridViewData();
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
}
