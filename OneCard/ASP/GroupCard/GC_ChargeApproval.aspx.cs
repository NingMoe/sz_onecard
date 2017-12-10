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
using PDO.GroupCard;
using Common;

// 企服卡后台充值审批
public partial class ASP_GroupCard_GC_ChargeApproval : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 初始化批次号列表
        initBatchList();
    }

    // 初始化批次号列表
    private void initBatchList()
    {
        ControlDeal cd = new ControlDeal(context);
        selBatchNo.Items.Clear();

        // 从企服卡充值总量台帐中选取批次号
        DataTable dt = GroupCardHelper.callQuery(context, "ChargeBatchNo");
        GroupCardHelper.fillWoCode(selBatchNo, dt, false);

        btnQuery.Enabled = selBatchNo.Items.Count > 0;
        chkApprove.Enabled = btnQuery.Enabled;
        chkReject.Enabled = btnQuery.Enabled;
    }

    // 根据批次号从企服卡后台充值明细表中取出明细
    private void createGridViewDataSource()
    {
        DataTable data = null;
        data = GroupCardHelper.callQuery(context, "ChargeAprv", selBatchNo.SelectedValue);
        gvResult.DataSource = data;
        gvResult.DataBind();
    }

    // 显示充值卡充值汇总信息
    private void displaySummaryInfo()
    {
        // 查询集团名称，充值数量，充值总额
        DataTable data = GroupCardHelper.callQuery(context, "ChargeAprvTotal", selBatchNo.SelectedValue);
        Object[] row0 = data.Rows[0].ItemArray;
        labCorp.Text = (string)row0[0];
        labAmount.Text = "" + row0[1];
        labChargeTotal.Text = "" + ((Decimal)row0[2]).ToString("n");
    }

    // gridview换页事件
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        createGridViewDataSource();
    }


    // 提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (chkApprove.Checked)
        {
            submitApproval("1", "D004P05001: 企服卡批量充值审批通过，请等待财务审核");   // 审批通过
        }
        else
        {
            submitApproval("3", "D004P05002: 审批作废");   // 审批作废
        }
        chkReject.Checked = false;
        chkApprove.Checked = false;
        btnSubmit.Enabled = false;

        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        labCorp.Text = "";
        labAmount.Text = "";
        labChargeTotal.Text = "";
    }

    // 调用充值审批存储过程
    private void submitApproval(string stateCode, string okMsgCode)
    {
        SP_GC_ChargeApprovalPDO pdo = new SP_GC_ChargeApprovalPDO();
        pdo.batchNo = selBatchNo.SelectedItem.Text;
        pdo.stateCode = stateCode; // '1' Approved, '3' Rejected
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok) AddMessage(okMsgCode);

        initBatchList();

        chkReject.Checked = false;
        chkApprove.Checked = false;
    }

    // "通过"，"作废"复选框改变事件
    protected void chk_CheckedChanged(object sender, EventArgs e)
    {
        CheckBox ch = (CheckBox)sender;
        if (ch.Checked)
        {
            if (ch == chkApprove) chkReject.Checked = false;
            else chkApprove.Checked = false;
        }

        btnSubmit.Enabled = (chkApprove.Checked || chkReject.Checked);
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        createGridViewDataSource();
        displaySummaryInfo();
    }
}
