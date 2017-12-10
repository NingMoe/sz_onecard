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
using PDO.PersonalBusiness;

public partial class ASP_PersonalBusiness_PB_CardToCardQuery : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期
            DateTime date = new DateTime();
            date = DateTime.Today;
            txtStartDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
            txtEndDate.Text = DateTime.Today.ToString("yyyyMMdd");

            //设置GridView绑定的DataTable
            lvwloadOutQuery.DataSource = new DataTable();
            lvwloadOutQuery.DataBind();
            lvwloadOutQuery.SelectedIndex = -1;
        }
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //有效性校验
        if (!queryValidation()) return;

        if (selTradeType.SelectedValue.Equals("0"))
        {
            //查询圈提记录
            queryCardToCardOutReg();
        }
        if (selTradeType.SelectedValue.Equals("1"))
        {
            //查询圈存记录
            queryCardToCardInReg();
        }
    }

    protected Boolean queryValidation()
    {
        //校验卡号
        if (txtCardNo.Text.Trim() != "")
        {
            if (Validation.strLen(txtCardNo.Text.Trim()) != 16)
                context.AddError("A094570009：卡号必须为16位", txtCardNo);
            else if (!Validation.isNum(txtCardNo.Text.Trim()))
                context.AddError("A094570010：卡号必须为数字", txtCardNo);
        }

        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtStartDate);
        bool b2 = Validation.isEmpty(txtEndDate);
        DateTime? fromDate = null, toDate = null;
        if (b1 || b2)
        {
            context.AddError("开始日期和结束日期必须填写");
        }
        else
        {
            if (!b1)
            {
                fromDate = valid.beDate(txtStartDate, "开始日期范围起始值格式必须为yyyyMMdd");
            }
            if (!b2)
            {
                toDate = valid.beDate(txtEndDate, "结束日期范围终止值格式必须为yyyyMMdd");
            }
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        }

        //校验起止日期
        return !(context.hasError());
    }

    protected void queryCardToCardOutReg()
    {
        lvwloadOutQuery.DataSource = CreateCardToCardOutDataSource();
        lvwloadOutQuery.DataBind();
        lvwloadOutQuery.SelectedIndex = -1;
    }
    public ICollection CreateCardToCardOutDataSource()
    {
        //查询圈提记录
        DataTable data = SPHelper.callQuery("SP_PB_Query", context, "QueryCardToCardOut", txtCardNo.Text.Trim(), selTranstate.SelectedValue, txtStartDate.Text.Trim(), txtEndDate.Text.Trim());
        return new DataView(data);

    }
    protected void queryCardToCardInReg()
    {
        lvwloadInQuery.DataSource = CreateCardToCardInDataSource();
        lvwloadInQuery.DataBind();
        lvwloadInQuery.SelectedIndex = -1;
    }
    public ICollection CreateCardToCardInDataSource()
    {
        //查询圈存记录
        DataTable data = SPHelper.callQuery("SP_PB_Query", context, "QueryCardToCardIn", txtCardNo.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim());
        return new DataView(data);

    }
    protected void selTradeType_change(object sender, EventArgs e)
    {
        if (selTradeType.SelectedValue.Equals("0"))
        {
            lvwloadOutQuery.Visible = true;
            lvwloadInQuery.Visible = false;

            selTranstate.SelectedValue = "";
            selTranstate.Enabled = true;

            //设置GridView绑定的DataTable
            lvwloadOutQuery.DataSource = new DataTable();
            lvwloadOutQuery.DataBind();
            lvwloadOutQuery.SelectedIndex = -1;

            return;
        }
        if (selTradeType.SelectedValue.Equals("1"))
        {
            lvwloadOutQuery.Visible = false;
            lvwloadInQuery.Visible = true;

            selTranstate.SelectedValue = "1";
            selTranstate.Enabled = false;

            //设置GridView绑定的DataTable
            lvwloadInQuery.DataSource = new DataTable();
            lvwloadInQuery.DataBind();
            lvwloadInQuery.SelectedIndex = -1;

            return;
        }
    }
    protected void lvwloadOutQuery_Page(object sender, GridViewPageEventArgs e)
    {
        lvwloadOutQuery.PageIndex = e.NewPageIndex;
        queryCardToCardOutReg();
    }
    protected void lvwloadInQuery_Page(object sender, GridViewPageEventArgs e)
    {
        lvwloadInQuery.PageIndex = e.NewPageIndex;
        queryCardToCardInReg();
    }

    private double Outmoney = 0;
    protected void lvwloadOutQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (lvwloadOutQuery.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            Outmoney += Convert.ToDouble(GetTableCellValue(e.Row.Cells[2]));
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[2].Text = Outmoney.ToString("n");
        }
    }
    private double Inmoney = 0;
    protected void lvwloadInQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (lvwloadInQuery.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            Inmoney += Convert.ToDouble(GetTableCellValue(e.Row.Cells[2]));
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[2].Text = Inmoney.ToString("n");
        }
    }
    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }
}