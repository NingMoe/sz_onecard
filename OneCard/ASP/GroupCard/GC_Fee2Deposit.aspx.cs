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

/*
 * 增加将售卡的卡费转成卡押金的界面；卡号根据卡号段输入；
 * 当日操作，应该没有问题；往日操作，手工输入需扣减押金金额，
 * 由系统进行扣减，提供售卡业务查询。
 * 
 * 界面上提示：如果卡片开通园林或休闲功能请注意扣取的押金额，如：12元。 
 */
public partial class ASP_GroupCard_GC_Fee2Deposit : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
        UserCardHelper.resetData(gvResult, null);
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        // 对起始卡号和结束卡号进行校验
        UserCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo, true, true);
        if (context.hasError()) return;

        DataTable data = GroupCardHelper.callQuery(context, "Fee2DepositQuery", txtFromCardNo.Text, txtToCardNo.Text);
        UserCardHelper.resetData(gvResult, data);

        data = GroupCardHelper.callQuery(context, "Fee2DepositCheckSaleDay", txtFromCardNo.Text, txtToCardNo.Text);
        bool saleToday = false;
        if (data != null)
        {
            if (data.Rows.Count > 1)
            {
                context.AddError("起讫卡号范围内的卡片售卡日期不相同");
            }
            else if (data.Rows.Count == 1)
            {
                if ("" + data.Rows[0].ItemArray[0] == DateTime.Now.ToString("yyyyMMdd"))
                { // 当日售卡
                    saleToday = true;
                }
            }
        }

        data = GroupCardHelper.callQuery(context, "Fee2DepositCheckCardCost", txtFromCardNo.Text, txtToCardNo.Text);
        if (data != null && data.Rows.Count > 0)
        {
            context.AddError("起讫卡号范围内有卡片卡费已经是零");
        }

        btnSubmit.Enabled = !context.hasError();
        palDeduction.Visible = !saleToday && btnSubmit.Enabled;
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        UserCardHelper.validatePrice(context, txtDeductionMoney, "扣减押金额不能为空", "扣减金额必须是10.2的格式");
        if (context.hasError()) return;

        context.SPOpen();
        context.AddField("p_fromCardNo").Value = txtFromCardNo.Text;
        context.AddField("p_toCardNo").Value = txtToCardNo.Text;
        context.AddField("p_deductionMoney").Value = Convert.ToInt32(Convert.ToDecimal(txtDeductionMoney.Text) * 100);

        bool ok = context.ExecuteSP("SP_GC_Fee2Deposit");
        if (ok)
        {
            context.AddMessage("卡费转卡押金成功");
        }

        btnSubmit.Enabled = false;
        palDeduction.Visible = false;
        txtDeductionMoney.Text = "0";
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
    }
}
