using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;


public partial class ASP_ProvisionNote_PN_FinanceOut : Master.ExportMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            //初始化订单表格

            gvBank.DataSource = query();
            gvBank.DataBind();

            //初始化账单表格
            gvTrade.DataSource = query();
            gvTrade.DataBind();

            //初始化系统业务交易类型表
            PNHelper.initPaperTypeList(context, selTradeType, "QUERYPNTRADETYPE", "");

            //初始化银行备付金交易类型表
            PNHelper.initPaperTypeList(context, selBankTradeType, "QUERYBANKTRADETYPE", "1");

            //初始化银行列表
            PNHelper.initPaperTypeList(context, selBank, "QUERYPNBANK", "");

            //初始化最早日期
            DataTable dt = PNHelper.callQuery(context, "QUERYTOPOUTDATE", "");
            if (dt != null && dt.Rows.Count > 0)
            {
                txtFromDate.Text = dt.Rows[0][0].ToString();
            }

            //初始化部门数据
            FIHelper.selectDept(context, selDept, true);

            return;
        }
    }



    // gridview 换页事件
    public void gvTrade_Page(Object sender, GridViewPageEventArgs e)
    {
        //gvTrade.PageIndex = e.NewPageIndex;

    }

    // 查询输入校验处理
    private void validate()
    {
        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtFromDate);
        DateTime? fromDate = null;
        if (b1)
        {
            context.AddError("日期不能为空");
        }
        else
        {
            fromDate = valid.beDate(txtFromDate, "日期格式必须为yyyyMMdd");
        }

        if (fromDate != null)
        {
            //查询该日是否已经解款完成
            DataTable dt = PNHelper.callQuery(context, "QUERYOUTVALIDATE", txtFromDate.Text);
            {
                if (dt.Rows[0][0].ToString() != "0")
                {
                    context.AddError("该日出金匹配完成，无法匹配帐务信息");
                    return;
                }
            }

        }
    }



    /// <summary>
    /// 查询
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {

        validate();
        if (context.hasError()) return;

        DataTable data = PNHelper.callQuery(context, "QUERYBANKOCABOUT", selBank.SelectedValue, selBankTradeType.SelectedValue, txtOtherName.Text, txtBankFromMoney.Text, txtBankToMoney.Text);

        DataTable data1 = PNHelper.callQuery(context, "QUERYTRADECODEOUT", txtFromDate.Text.Trim(), selTradeType.SelectedValue, txtName.Text, txtTradeFromMoney.Text, txtTradeToMoney.Text, selDept.SelectedValue);

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("银行查询结果为空");
        }
        if (data1 == null || data1.Rows.Count == 0)
        {
            AddMessage("业务查询结果为空");
        }

        UserCardHelper.resetData(gvBank, data);
        UserCardHelper.resetData(gvTrade, data1);

        labBank.Text = "0";
        labTrade.Text = "0";

    }

    /// <summary>
    /// 提交处理
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnConfirm_Click(object sender, EventArgs e)
    {

        //出金确认提交
        context.SPOpen();
        context.AddField("p_tradeDate").Value = txtFromDate.Text;

        bool ok = context.ExecuteSP("SP_BFJ_CompletePay");
        if (ok)
        {
            context.AddMessage("匹配完成");
            hidTypeValue.Value = "";
        }
    }

    //不匹配
    protected void btnCancelSub_Click(object sender, EventArgs e)
    {
        //清空临时表信息

        clearTempTable();

        if (!RecordUnTmp()) return;

        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        bool ok = context.ExecuteSP("SP_PN_FinanceDel");

        if (ok)
        {
            context.AddMessage("不匹配业务确认成功");
            btnQuery_Click(sender, e);
        }
    }

    // 提交审核处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        //清空临时表信息

        clearTempTable();


        if (!RecordIntoTmp()) return;

        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        bool ok = context.ExecuteSP("SP_PN_FinanceOutAdd");

        if (ok)
        {
            context.AddMessage("出金帐务确认成功");
            hidTypeValue.Value = "";
            hidDate.Value = "";
            btnQuery_Click(sender, e);
        }

    }

    private void clearTempTable()//清空临时表
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON where F0 ='" + System.Web.HttpContext.Current.Session.SessionID + "'");
        context.DBCommit();
    }

    /// <summary>
    /// 不匹配功能录入
    /// </summary>
    /// <returns></returns>
    private bool RecordUnTmp()
    {
        //选中记录入临时表
        context.DBOpen("Insert");
        int bankCount = 0;
        int tradeCount = 0;
        int errBankCount = 0;
        int errTradeCount = 0;

        foreach (GridViewRow gvr in gvBank.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkBankList");
            if (cb != null && cb.Checked)
            {
                //校验银行帐务是否匹配过
                if (gvr.Cells[2].Text.Trim() != gvr.Cells[3].Text.Trim())
                {
                    errBankCount++;
                }
                bankCount++;
                //银行帐务录入临时表
                context.ExecuteNonQuery("insert into TMP_COMMON (F0,F1,F2) values('" +
                     Session.SessionID + "', '0','" + gvr.Cells[9].Text + "')");
            }
        }

        foreach (GridViewRow gvr in gvTrade.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkTradeList");
            if (cb != null && cb.Checked)
            {
                //校验银行帐务是否匹配过
                if (gvr.Cells[2].Text.Trim() != gvr.Cells[3].Text.Trim())
                {
                    errTradeCount++;
                }
                tradeCount++;
                //业务帐务记录入临时表
                context.ExecuteNonQuery("insert into TMP_COMMON (F0,F1,F2) values('" +
                     Session.SessionID + "', '1','" + gvr.Cells[8].Text + "')");
            }
        }

        if (bankCount == 0 && tradeCount == 0)
        {
            context.AddError("请选择不需要匹配的帐务明细信息！");
            return false;
        }

        if (errBankCount != 0 && errTradeCount != 0)
        {
            context.AddError("银行帐务有" + errBankCount + "条记录已匹配，不能取消");
            context.AddError("业务帐务有" + errTradeCount + "条记录已匹配，不能取消");
            return false;
        }

        if (context.hasError())
        {
            return false;
        }
        else
        {
            context.DBCommit();
            return true;
        }
    }

    private bool RecordIntoTmp()
    {
        //选中记录入临时表
        context.DBOpen("Insert");
        int bankCount = 0;
        int tradeCount = 0;
        int banksummoney = 0;
        int tradesummoney = 0;

        List<string> company = new List<string>();
        foreach (GridViewRow gvr in gvBank.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkBankList");
            if (cb != null && cb.Checked)
            {
                bankCount++;
                //银行帐务录入临时表
                context.ExecuteNonQuery("insert into TMP_COMMON (F0,F1,F2,F3) values('" +
                     Session.SessionID + "', '0','" + Convert.ToInt32(Convert.ToDecimal(gvr.Cells[2].Text) * 100) + "','" + gvr.Cells[9].Text + "')");

                banksummoney += Convert.ToInt32(Convert.ToDecimal(gvr.Cells[2].Text) * 100);
            }
        }
        //校验是否选择了银行帐务

        if (bankCount <= 0)
        {
            context.AddError("请选择银行帐务信息！");
            return false;
        }


        foreach (GridViewRow gvr in gvTrade.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkTradeList");
            if (cb != null && cb.Checked)
            {
                tradeCount++;
                //业务帐务记录入临时表
                context.ExecuteNonQuery("insert into TMP_COMMON (F0,F1,F2,F3,F4) values('" +
                     Session.SessionID + "', '1','" + Convert.ToInt32(Convert.ToDecimal(gvr.Cells[2].Text) * 100) + "','" + gvr.Cells[8].Text + "','" + gvr.Cells[1].Text + "')");

                tradesummoney += Convert.ToInt32(Convert.ToDecimal(gvr.Cells[2].Text) * 100);

                //取第一个勾选的日期 因业务查询有日期order by.取第一个最早日期开始提交
                if (hidDate.Value == "")
                {
                    hidDate.Value = gvr.Cells[1].Text;
                }
            }
        }

        //校验是否选择了业务帐务

        if (tradeCount <= 0)
        {
            context.AddError("请选择业务帐务信息！");
            return false;
        }

        if (context.hasError())
        {
            return false;
        }
        else
        {
            context.DBCommit();
            return true;
        }
    }

    /// <summary>
    /// 查询账单
    /// </summary>
    /// <returns></returns>
    private ICollection query()
    {

        return new DataView();
    }

    /// <summary>
    /// 银行列表全选
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void chkAllBank_CheckedChanged(object sender, EventArgs e)
    {
        double count = 0.0;
        CheckBox cbx = (CheckBox)sender;
        if (cbx.ID == "chkAllBank")
        {
            foreach (GridViewRow gvr in gvBank.Rows)
            {
                CheckBox ch = (CheckBox)gvr.FindControl("chkBankList");
                ch.Checked = cbx.Checked;
            }
        }

        foreach (GridViewRow gvr in gvBank.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("chkBankList");
            if (ch.Checked)
            {
                count += double.Parse(gvr.Cells[2].Text.ToString());
            }
        }

        labBank.Text = count.ToString();
    }

    /// <summary>
    /// 业务列表全选
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void chkAllTrade_CheckedChanged(object sender, EventArgs e)
    {
        double count = 0.0;
        CheckBox cbx = (CheckBox)sender;
        if (cbx.ID == "chkAllTrade")
        {
            foreach (GridViewRow gvr in gvTrade.Rows)
            {
                CheckBox ch = (CheckBox)gvr.FindControl("chkTradeList");
                ch.Checked = cbx.Checked;
            }
        }

        foreach (GridViewRow gvr in gvTrade.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("chkTradeList");
            if (ch.Checked)
            {
                count += double.Parse(gvr.Cells[2].Text.ToString());
            }
        }

        labTrade.Text = count.ToString();
    }

    /// <summary>
    /// 银行软删除 --更新库内是否需要匹配标识
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvBank_RowDelete(object sender, GridViewDeleteEventArgs e)
    {
        string tradeid = gvBank.Rows[e.RowIndex].Cells[9].Text.ToString();
        context.SPOpen();
        context.AddField("P_TRADEID").Value = tradeid;
        bool ok = context.ExecuteSP("SP_PN_FinanceBankDel");

        if (ok)
        {
            btnQuery_Click(sender, e);
        }
    }

    /// <summary>
    /// 业务软删除 --更新库内是否需要匹配标识
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvTrade_RowDelete(object sender, GridViewDeleteEventArgs e)
    {
        string tradeid = gvTrade.Rows[e.RowIndex].Cells[8].Text.ToString();
        context.SPOpen();
        context.AddField("P_TRADEID").Value = tradeid;
        bool ok = context.ExecuteSP("SP_PN_FinanceTradeDel");

        if (ok)
        {
            btnQuery_Click(sender, e);
        }
    }

    protected void gvBank_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[9].Visible = false;    //TRADEID隐藏
        }
    }

    protected void gvTrade_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[8].Visible = false;    //TRADEID隐藏
        }
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvBank.Rows.Count > 0)
        {
            ExportGridView(gvBank);
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }
}
