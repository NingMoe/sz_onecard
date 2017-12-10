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
using PDO.GroupCard;
using TM;
using System.Text;

// 企服卡财务审核处理

public partial class ASP_CustomerAcc_CA_OpenFiApproval : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
        
        // 创建临时表
        GroupCardHelper.createTempTable(context);
           
        // 创建开卡财务审核数据列表
        createGridViewData();
    }

    // 创建开卡财务审核数据列表
    private void createGridViewData()
    {
        // 从开卡总台张查询需要财务审核的数据
        DataTable data = GroupCardHelper.callQuery(context, "OpenFiItems");
        UserCardHelper.resetData(gvResult, data);

        bool enabled = (data.Rows.Count > 0);

        chkApprove.Enabled = enabled;
        chkReject.Enabled = enabled;

        chkApprove.Checked = false;
        chkReject.Checked = false;
        btnSubmit.Enabled = false;
    }

    // 选中gridview当前页所有数据
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
            submitApproval("2", "D004P03001: 审核通过");   // 通过
        } 
        else
        {
            submitApproval("3", "D004P03002: 审核作废");   // 作废
        }
    }

    // 调用开卡财务审核存储过程

    private void submitApproval(string stateCode, string okMsgCode)
    {
        string sessionID = Session.SessionID;
        GroupCardHelper.fillBatchNoList(context, gvResult, sessionID);
        if (context.hasError()) return;

        // 调用开卡财务审核存储过程
        context.SPOpen();
        context.AddField("p_sessionId").Value = sessionID;
        context.AddField("p_stateCode").Value = stateCode;

        StringBuilder szOutput = new System.Text.StringBuilder(256);
        CAEncryption.CAEncrypt("111111", ref szOutput);
        context.AddField("P_PWD").Value = szOutput.ToString();

        bool ok = context.ExecuteSP("SP_CA_OpenFiApproval");

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
