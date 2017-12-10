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
using Common;
using TM;
using PDO.GroupCard;
using System.Collections.Generic;
using System.Text;

// 企服卡开卡审批

public partial class ASP_CustomerAcc_CA_OpenApproval : Master.Master
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
        // 从企服卡开卡总台帐中查询批次号，生成批次号列表
        selBatchNo.Items.Clear();

        DataTable dt = GroupCardHelper.callQuery(context, "OpenBatchNo");

        btnQuery.Enabled = dt.Rows.Count > 0;

        if (dt.Rows.Count == 0)
        {
            UserCardHelper.resetData(gvResult, null);

            chkApprove.Enabled = false;
            chkReject.Enabled = false;
            labCorp.Text = "";
            labDeposit.Text = "" ;
            labCardFee.Text = "";
            labChargAmount.Text = "";
            labTotalAmount.Text = "";
        }
        else
        {
            UserCardHelper.resetData(gvResult, null);
            GroupCardHelper.fillWoCode(selBatchNo, dt, false);
        }

        chkApprove.Checked = false;
        chkReject.Checked = false;
        btnSubmit.Enabled = false;
    }

    // 根据批次号查询批量开卡明细信息
    private void createGridViewDataSource()
    {
        string batchNoOldFlag = selBatchNo.SelectedValue;
        int hyphenPos = batchNoOldFlag.IndexOf('-');
        String oldFlag = batchNoOldFlag.Substring(hyphenPos + 1);
        String batchNo = selBatchNo.SelectedItem.Text;

        DataTable data = GroupCardHelper.callQuery(context, "OpenCorpName", batchNo);
        labCorp.Text = (String)data.Rows[0].ItemArray[0];

        data = CAHelper.callQuery(context,
            oldFlag == "1" ? "OpenAprvOld" : "OpenAprvNew", batchNo);

        //add by jiangbb 解密
        //CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR" }));

        UserCardHelper.resetData(gvResult, data);

        Decimal depositTotal = 0, cardFeeTotal = 0, chargeTotal = 0;

        // 生成汇总信息
        if (oldFlag != "1")
        {
            Object[] itemArray;
            for (int i = 0; i < data.Rows.Count; ++i)
            {
                itemArray = data.Rows[i].ItemArray;
                if (itemArray[4] != DBNull.Value)
                {
                    depositTotal += (Decimal)(itemArray[4]);
                }
                if (itemArray[5] != DBNull.Value)
                {
                    cardFeeTotal += (Decimal)(itemArray[5]);
                }
                if (itemArray[6] != DBNull.Value)
                {
                    chargeTotal += (Decimal)(itemArray[6]);
                }
            }
        }

        labDeposit.Text = depositTotal.ToString("n");
        labCardFee.Text = cardFeeTotal.ToString("n");
        labChargAmount.Text =  chargeTotal.ToString("n");
        labTotalAmount.Text = (depositTotal + cardFeeTotal + chargeTotal).ToString("n");

    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[2].Text = DeEncrypt(e.Row.Cells[2].Text);
            e.Row.Cells[3].Text = DeEncrypt(e.Row.Cells[3].Text);
           
        }
    }

    //解密
    private string DeEncrypt(string value)
    {
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESDeEncrypt(value, ref strBuilder);
        return strBuilder.ToString();
    }

    // gridview 换页事件
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        createGridViewDataSource();
    }

    // 提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (chkApprove.Checked )
        {
            submitApproval("1", "D004P02001: 企服卡批量开卡审批通过，请等待财务审核");
        }
        else
        {
            submitApproval("3", "D004P02002: 审批作废");
        }
    }

    // 调用企服卡开卡审批存储过程
    private void submitApproval(string stateCode, string okMsgCode)
    {
        context.SPOpen();
        context.AddField("p_batchNo").Value = selBatchNo.SelectedItem.Text;
        context.AddField("p_stateCode").Value = stateCode;

        bool ok = context.ExecuteSP("SP_CA_OpenApproval");

        if (ok) AddMessage(okMsgCode);

        initBatchList();
    }

    // 通过/作废 复选框改变事件
    protected void chk_CheckedChanged(object sender, EventArgs e)
    {
        CheckBox ch = (CheckBox)sender;
        if (ch.Checked)
        {
            if (ch == chkApprove)  chkReject.Checked = false;
            else  chkApprove.Checked = false;
        }

        btnSubmit.Enabled = (chkApprove.Checked || chkReject.Checked);
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        createGridViewDataSource();
    }

    protected void selBatchNo_SelectedIndexChanged(object sender, EventArgs e)
    {
        createGridViewDataSource();
    }
}
