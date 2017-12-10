using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using System.Collections.Generic;

/******************************
 * 银行业务查询
 * 2014-10-20
 * guol
 *****************************/
public partial class ASP_ProvisionNote_PN_QueryBankAccounts : Master.Master
{
    #region  Initialization
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            controlsInit();
            return;
        }
    }
    #endregion

    #region Private

    private void controlsInit()
    {
        //初始化订单表格
        gvBank.DataSource = new DataTable();
        gvBank.DataBind();

        //已匹配完成
        gvList.DataSource = new DataTable();
        gvList.DataBind();


        //初始化银行备付金交易类型表
        PNHelper.initPaperTypeList(context, selBankTradeType, "QUERYAllBANKTRADETYPE");

        //初始化银行列表
        PNHelper.initPaperTypeList(context, selBank, "QUERYPNBANK", "");

        return;
    }

    // 查询输入校验处理
    private void validate()
    {
        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtFromDate);
        bool b2 = Validation.isEmpty(txtToDate);
        DateTime? fromDate = null, toDate = null;
        if (b1 || b2)//验证是否为空
            context.AddError("开始日期和结束日期必须填写");
        else //验证格式
        {
            if (!b1)
                fromDate = valid.beDate(txtFromDate, "开始日期范围起始值格式必须为yyyyMMdd");

            if (!b2)
                toDate = valid.beDate(txtToDate, "结束日期范围终止值格式必须为yyyyMMdd");
        }

        //验证时间范围是否合理
        if (fromDate != null && toDate != null)
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
    }
    #endregion

    #region Event Handler
    /// <summary>
    /// 查询
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;
        DataTable data = PNHelper.callQuery(context, "QUERYBANKACCOUNTS",
            txtFromDate.Text.Trim(),
            txtToDate.Text.Trim(),
            selBank.SelectedValue.Trim(),
            selBankTradeType.SelectedValue.Trim(),
            txtOtherName.Text.Trim(),
            txtBankFromMoney.Text.Trim(),
            txtBankToMoney.Text.Trim());

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("银行查询结果为空");
        }
        UserCardHelper.resetData(gvBank, data);

    }
    /// <summary>
    /// 选择不同行
    /// </summary>
    /// <returns></returns>
    protected void gvBank_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (gvBank.SelectedIndex == -1)
            return;
        string tradeId = gvBank.SelectedRow.Cells[8].Text;
        hidTrade.Value = tradeId;
        DataTable data = PNHelper.callQuery(context, "QUERYBANKACCOUNTSTOBUSINESS", tradeId);

        UserCardHelper.resetData(gvList, data);
    }

    /// <summary>
    /// 注册行单击事件
    /// </summary>
    /// <returns></returns>
    public void gvBank_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvBank','Select$" + e.Row.RowIndex + "')");
        }
    }
    /// <summary>
    /// RowDataBound事件
    /// </summary>
    /// <returns></returns>
    protected void gvBank_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[8].Visible = false;    //TRADEID隐藏
        }
    }

    //分页
    protected void gvBank_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvBank.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    /// <summary>
    /// 已匹配明细列表全选
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void chkList_CheckedChanged(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        if (cbx.ID == "chkAll")
        {
            foreach (GridViewRow gvr in gvList.Rows)
            {
                CheckBox ch = (CheckBox)gvr.FindControl("chkList");
                ch.Checked = cbx.Checked;
            }
        }
    }

    #endregion

    // 提交处理
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        //清空临时表信息

        clearTempTable();

        if (!RecordCancelTmp()) return;

        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        bool ok = context.ExecuteSP("SP_PN_BankCancel");

        if (ok)
        {
            context.AddMessage("帐务取消匹配成功");
            hidTypeValue.Value = "";
            btnQuery_Click(sender, e);
            gvBank.SelectedIndex = -1;
            gvList.DataSource = new DataTable();
            gvList.DataBind();
        }
    }

    private void clearTempTable()//清空临时表
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON where F0 ='" + System.Web.HttpContext.Current.Session.SessionID + "'");
        context.DBCommit();
    }

    /// <summary>
    /// 准备需要返销的明细数据
    /// </summary>
    /// <returns></returns>
    private bool RecordCancelTmp()
    {
        //选中记录入临时表
        context.DBOpen("Insert");
        int listCount = 0;

        List<string> orderno = new List<string>();
        foreach (GridViewRow gvr in gvList.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkList");
            if (cb != null && cb.Checked)
            {//判断批次号是否存在
                if (!orderno.Contains(gvr.Cells[10].Text))
                {
                    orderno.Add(gvr.Cells[10].Text);

                    listCount++;
                    //银行帐务录入临时表
                    context.ExecuteNonQuery("insert into TMP_COMMON (F0,F1,F2) values('" +
                         Session.SessionID + "', '3','" + gvr.Cells[10].Text + "')");
                }
            }
        }

        //校验是否选择了业务帐务

        if (listCount <= 0)
        {
            context.AddError("请选择需要返销的帐务明细信息！");
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
}
