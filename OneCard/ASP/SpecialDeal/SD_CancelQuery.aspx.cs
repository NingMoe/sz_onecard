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
using PDO.Warn;
using TM;
using Common;

public partial class ASP_SpecialDeal_SD_CancelQuery : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        UserCardHelper.resetData(gvTotalResult, null);
        UserCardHelper.resetData(gvDetailResult, null);
        txtCancelFromCardNo.Text = DateTime.Now.ToString("yyyyMMdd");
        txtCancelToCardNo.Text = DateTime.Now.ToString("yyyyMMdd");
        setReadOnly();
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {

        validate();
        if (context.hasError())
        {
            UserCardHelper.resetData(gvTotalResult, null);
            return;
        }
        //取得查询结果
        DataTable dataTable = SPHelper.callSDQuery(context, "QueryCancel",
                selDeptName.SelectedValue,
                txtCancelFromCardNo.Text,
                txtCancelToCardNo.Text,
                txtCardNo.Text,
                txtTradeFromCardNo.Text,
                txtTradeToCardNo.Text,
                selQuery.SelectedValue);

        if (selQuery.SelectedValue == "0")
        {
            UserCardHelper.resetData(gvTotalResult, dataTable);
            gvTotalResult.Visible = true;
            gvDetailResult.Visible = false;
        }
        else
        {
            UserCardHelper.resetData(gvDetailResult, dataTable);
            gvTotalResult.Visible = false;
            gvDetailResult.Visible = true;
        }
    }

    private void validate()
    {
        Validation valid = new Validation(context);
        //结算单元名称校验

        DateTime? dateEff = null, dateExp = null;
        //对作废起始日期进行非空和日期格式检验
        if (!string.IsNullOrEmpty(txtCancelFromCardNo.Text))
            dateEff = valid.beDate(txtCancelFromCardNo, "A002P01014: 起始日期格式不是yyyyMMdd");

        //对作废终止日期进行非空和日期格式检验
        if (!string.IsNullOrEmpty(txtCancelToCardNo.Text))
            dateExp = valid.beDate(txtCancelToCardNo, "A002P01016: 结束日期格式不是yyyyMMdd");

        //作废起始日期不能大于作废终止日期
        if (dateEff != null && dateExp != null)
        {
            valid.check(dateEff.Value.CompareTo(dateExp.Value) <= 0, "A002P01017: 起始日期不能大于结束日期");
        }

        if (selQuery.SelectedValue != "0")
        {
            //对非空卡号长度数字的判断
            string strCardNo = txtCardNo.Text.Trim();
            if (strCardNo != "")
            {
                if (Validation.strLen(strCardNo) != 16)
                    context.AddError("A009100109", txtCardNo);
                else if (!Validation.isNum(strCardNo))
                    context.AddError("A009100110", txtCardNo);
            }

            DateTime? dateTradeEff = null, dateTradeExp = null;
            //对交易起始日期进行非空和日期格式检验

            if (!string.IsNullOrEmpty(txtTradeFromCardNo.Text.Trim()))
                dateTradeEff = valid.beDate(txtTradeFromCardNo, "A00501B016: 作废起始日期格式无效");

            //对交易终止日期进行非空和日期格式检验
            if (!string.IsNullOrEmpty(txtTradeToCardNo.Text.Trim()))
                dateTradeExp = valid.beDate(txtTradeToCardNo, "A00501B018: 作废终止日期格式无效");

            //交易起始日期不能大于交易终止日期
            if (dateTradeEff != null && dateTradeExp != null)
            {
                valid.check(dateTradeEff.Value.CompareTo(dateTradeExp.Value) <= 0, "A00501B019: 作废起始日期大于终止日期");
            }
        }
    }

    //汇总时不可输入卡号和交易起始终止日期
    private void setReadOnly()
    {
        if (selQuery.SelectedValue == "0")//汇总
        {
            txtCardNo.Text = txtTradeFromCardNo.Text = txtTradeToCardNo.Text = string.Empty;
            txtCardNo.Enabled = txtTradeFromCardNo.Enabled = txtTradeToCardNo.Enabled = false;
        }
        else
        {
            txtCardNo.Enabled = txtTradeFromCardNo.Enabled = txtTradeToCardNo.Enabled = true;
        }
    }

    protected void selQuery_SelectedIndexChanged(object sender, EventArgs e)
    {
        setReadOnly();
    }

    private int operCount = 0;
    private double totalCharges = 0;
    protected void gvTotalResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[0].Text = Convert.ToDateTime(e.Row.Cells[0].Text).ToString("yyyy/MM/dd");
            operCount += Convert.ToInt32(GetTableCellValue(e.Row.Cells[2]));
            totalCharges += Convert.ToDouble(GetTableCellValue(e.Row.Cells[3]));
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[0].ColumnSpan = 2;
            e.Row.Cells[1].Visible = false;
            e.Row.Cells[2].Text = operCount.ToString();
            e.Row.Cells[3].Text = totalCharges.ToString("n");
        }

    }

    protected void gvDetailResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[0].Text = DateTime.ParseExact(e.Row.Cells[0].Text, "yyyyMMdd", null).ToString("yyyy/MM/dd");
            e.Row.Cells[16].Text = Convert.ToDateTime(e.Row.Cells[16].Text).ToString("yyyy/MM/dd");
        }
    }

    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }
    public void gvDetailResult_Page(object sender, GridViewPageEventArgs e)
    {
        gvDetailResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    protected void txtBalunitNo_TextChanged(object sender, EventArgs e)
    {
        string name = txtBalunitNo.Text.Trim();
        if (string.IsNullOrEmpty(name))
        {
            selDeptName.Items.Clear();
            return;
        }
        DataTable dataTable = SPHelper.callSDQuery(context, "QueryDept", name);
        selDeptName.Items.Clear();
        if (dataTable.Rows.Count > 0)
        {
            selDeptName.Items.Add(new ListItem("---请选择---", ""));
        }
        foreach (DataRow dr in dataTable.Rows)
        {
            selDeptName.Items.Add(new ListItem(dr["BALUNITNO"].ToString() + ":" + dr["BALUNIT"].ToString(), dr["BALUNITNO"].ToString()));
        }
    }
    protected void selDeptName_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (selDeptName.SelectedItem.Value != "")
        {
            txtBalunitNo.Text = selDeptName.SelectedItem.Text.Split(':')[1];
        }
    }
}
