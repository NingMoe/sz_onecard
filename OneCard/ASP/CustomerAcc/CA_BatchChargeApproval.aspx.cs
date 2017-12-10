using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using PDO.GroupCard;
using Common;

// 联机帐户批量充值后台充值审批

public partial class ASP_CustomerAcc_CA_BatchChargeApproval : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 初始化集团客户
        GroupCardHelper.initGroupCustomer(context, selCorp);

        // 初始化批次号列表
        initBatchList();

    }

    // 初始化批次号列表
    private void initBatchList()
    {
        ControlDeal cd = new ControlDeal(context);
        selBatchNo.Items.Clear();

        // 从联机帐户充值总量台帐中选取批次号

        DataTable dt = SPHelper.callQuery("SP_CA_Query", context, "ChargeBatchNo", new string[1]);
        GroupCardHelper.fillWoCode(selBatchNo, dt, false);

        if (selBatchNo.Items.Count > 0)
        {
            //初始化集团客户
            DataTable table = SPHelper.callQuery("SP_CA_Query", context, "QueryCorpCodeByBatchNo", selBatchNo.SelectedValue.Trim());
            if (table != null && table.Rows.Count > 0)
            {
                CAHelper.SelectDDLByNo(selCorp, table.Rows[0][0].ToString());
            }
            createGridViewDataSource();
            displaySummaryInfo();
        }

        btnQuery.Enabled = selBatchNo.Items.Count > 0;
        chkApprove.Enabled = btnQuery.Enabled;
        chkReject.Enabled = btnQuery.Enabled;
    }

    // 根据批次号从联机帐户后台充值明细表中取出明细
    private void createGridViewDataSource()
    {
        DataTable data = null;
        string[] pvars = new string[1];
        pvars[0] = selBatchNo.SelectedValue;
        data = SPHelper.callQuery("SP_CA_Query", context, "ChargeAprv", pvars);
        gvResult.DataSource = data;
        gvResult.DataBind();
    }

    // 显示充值卡充值汇总信息
    private void displaySummaryInfo()
    {
        // 查询集团名称，充值数量，充值总额
        string[] pvars = new string[1];
        pvars[0] = selBatchNo.SelectedValue;
        DataTable data = SPHelper.callQuery("SP_CA_Query", context, "ChargeAprvTotal", pvars);
        if (data != null && data.Rows.Count > 0)
        {
            Object[] row0 = data.Rows[0].ItemArray;
            labAmount.Text = "" + row0[0];
            labChargeTotal.Text = "" + ((Decimal)row0[1]).ToString("n");
        }
        if (selCorp.SelectedValue.Trim().Length > 0)
        {
            lblCorpName.Text = selCorp.SelectedItem.Text;
        }
        else
        {
            lblCorpName.Text = "";
        }
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
        if (selBatchNo == null || selBatchNo.Items.Count < 1)
        {
            context.AddError("A006013011:没有要审核的批次信息");
            return;
        }
        if (chkApprove.Checked)
        {
            submitApproval("1", "D006013011: 帐户批量充值审批通过，请等待财务审核");   // 审批通过
        }
        else
        {
            submitApproval("3", "D006013012: 审批作废");   // 审批作废
        }
        chkReject.Checked = false;
        chkApprove.Checked = false;
        btnSubmit.Enabled = false;

        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        labAmount.Text = "";
        labChargeTotal.Text = "";
    }

    // 调用充值审批存储过程
    private void submitApproval(string stateCode, string okMsgCode)
    {
        context.SPOpen();
        context.AddField("p_batchNo").Value = selBatchNo.SelectedItem.Text;
        context.AddField("p_stateCode").Value = stateCode;  // '1' Approved, '3' Rejected

        if (context.ExecuteSP("SP_CA_BATCHCHARGEAPPROVAL"))
        {
            AddMessage(okMsgCode);
        }

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
    protected void selBatchNo_SelectedIndexChanged(object sender, EventArgs e)
    {
        createGridViewDataSource();
        displaySummaryInfo();
        //初始化集团客户
        DataTable table = SPHelper.callQuery("SP_CA_Query", context, "QueryCorpCodeByBatchNo", selBatchNo.SelectedValue.Trim());
        if (table != null && table.Rows.Count > 0)
        {
            CAHelper.SelectDDLByNo(selCorp, table.Rows[0][0].ToString());
        }
    }

    protected void selCorp_SelectedIndexChanged(object sender, EventArgs e)
    {
        selBatchNo.Items.Clear();

        // 从联机帐户充值总量台帐中选取批次号

        DataTable dt = SPHelper.callQuery("SP_CA_Query", context, "QueryBatchNoByCorpCode", selCorp.SelectedValue.Trim());
        GroupCardHelper.fillWoCode(selBatchNo, dt, false);
        if (selBatchNo.Items.Count < 1)
        {
            //清空列表
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
            context.AddError("A006013012:集团客户下没有待审批的充值记录");
            ClearChargeTotal();
        }
        else
        {
            createGridViewDataSource();
            displaySummaryInfo();
        }
    }

    //清空汇总信息
    private void ClearChargeTotal()
    {
        lblCorpName.Text = "";
        labAmount.Text = "";
        labChargeTotal.Text = "";
    }
}
