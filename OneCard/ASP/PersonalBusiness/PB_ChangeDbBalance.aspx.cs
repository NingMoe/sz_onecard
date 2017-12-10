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

public partial class ASP_PersonalBusiness_PB_ChangeDbBalance : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
        UserCardHelper.resetData(gvResult, null);
        UserCardHelper.resetData(gvCharge, null);
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        // 对卡号进行校验

        UserCardHelper.validateCardNo(context, txtCardNo, false);
        if (context.hasError()) return;

        // 只有不可读换卡和不可读退卡完成7日后，方可进行卡余额修改
        DataTable data = new DataTable();
        if (txtCardNo.Text.Substring(4, 2) == "18")
        {
            data = SPHelper.callPBQuery(context, "ChkSMKCardBalanceChange", txtCardNo.Text);
        }
        else
        {
            data = SPHelper.callPBQuery(context, "ChkCardBalanceChange", txtCardNo.Text);
        }
        if (data == null || data.Rows.Count == 0)
        {
            context.AddError("只有不可读换卡和不可读退卡完成7日后，方可进行卡余额修改");
        }

        if (context.hasError()) return;

        data = SPHelper.callPBQuery(context, "QryLastConsumeTrades", txtCardNo.Text);
        UserCardHelper.resetData(gvResult, data);

        if (data == null || data.Rows.Count == 0)
        {
            context.AddMessage("没有查询到最近消费记录");
        }

        data = SPHelper.callPBQuery(context, "QryLastSupplyTrades", txtCardNo.Text);
        UserCardHelper.resetData(gvCharge, data);

        if (data == null || data.Rows.Count == 0)
        {
            context.AddMessage("没有查询到最近充值记录");
        }

        data = SPHelper.callPBQuery(context, "QryAccInfo", txtCardNo.Text);
        if (data == null || data.Rows.Count == 0)
        {
            context.AddError("未查询出卡片库内账户余额，请检查卡号是否输入正确");
        }
        else
        {
            object[] row = data.Rows[0].ItemArray;
            labCardAcc.Text = "" + row[0];
        }

        btnSubmit.Enabled = !context.hasError();
        palDeduction.Visible = btnSubmit.Enabled;
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        UserCardHelper.validatePrice(context, txtNewBalance, "新金额不能为空", "新金额必须是10.2的格式");
        if (context.hasError()) return;

        int newBalance = Convert.ToInt32(Convert.ToDecimal(txtNewBalance.Text) * 100);

        decimal absDiff = Math.Abs(Convert.ToDecimal(labCardAcc.Text) - Convert.ToDecimal(txtNewBalance.Text));
        if (absDiff > 200)
        {
            context.AddError("修改差额(新金额-老金额)不允许超过200元", txtNewBalance);
            return;
        }

        context.SPOpen();
        context.AddField("p_cardNo").Value = txtCardNo.Text;
        context.AddField("p_newBalance").Value = newBalance;

        bool ok = context.ExecuteSP("SP_PB_ChangeDbBalance");
        if (ok)
        {
            context.AddMessage("已经提交修改库内卡余额，请等待财务审核后生效");
        }

        btnSubmit.Enabled = false;
        palDeduction.Visible = false;
        txtNewBalance.Text = "0";
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
    }
}