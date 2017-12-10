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
using Master;
using Common;

public partial class ASP_ResourceManage_RM_GetCardReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView();
            txtStartDate.Text = DateTime.Now.AddMonths(-1).ToString("yyyyMMdd");
            txtEndDate.Text = DateTime.Now.ToString("yyyyMMdd");
            //初始化卡片类型
            UserCardHelper.selectCardType(context, selCardType, true);

            //初始化卡面类型
            UserCardHelper.selectCardFace(context, selCardFaceType, true);

            //初始化部门
            UserCardHelper.selectDepts(context, selDepart, true);

            //初始化所属面值
            ResourceManageHelper.selCardMoney(context, selCardMoney, true);
            hidCardType.Value = "usecard";
        }
        ResourceManageHelper.selectTab(this, this.GetType(), hidCardType);
    }
    /// <summary>
    /// 查询条件卡片类型变更事件，更新卡片类型对应的卡面类型
    /// </summary>
    protected void selCardType_change(object sender, EventArgs e)
    {
        //卡面类型
        selCardFaceType.Items.Clear();
        ResourceManageHelper.selFaceType(context, selCardFaceType, true, selCardType.SelectedValue);
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //有效性校验
        ValidateForQuery();
        if (context.hasError()) return;

        if (hidCardType.Value == "usecard") //用户卡
        {
            DataTable data = ResourceManageHelper.callQuery(context, "GETUSECARDREPORT", selCardType.SelectedValue, selCardFaceType.SelectedValue,
                txtStartDate.Text, txtEndDate.Text, selDepart.SelectedValue);

            if (data == null || data.Rows.Count == 0)
            {
                AddMessage("N005030001: 查询结果为空");
                btnPrint.Enabled = false;
            }

            gvResultUseCard.DataSource = data;
            gvResultUseCard.DataBind();
        }
        else if (hidCardType.Value == "chargecard") //充值卡
        {
            DataTable data = ResourceManageHelper.callQuery(context, "GETCHARGECARDREPORT", selCardMoney.SelectedValue,
                txtStartDate.Text, txtEndDate.Text, selDepart.SelectedValue);
            if (data == null || data.Rows.Count == 0)
            {
                AddMessage("N005030001: 查询结果为空");
                btnPrint.Enabled = false;
            }

            gvResultChargeCard.DataSource = data;
            gvResultChargeCard.DataBind();
        }
    }
    /// <summary>
    /// 导出结果
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnExport_Click(object sender, EventArgs e)
    {
        GridView gvResult = new GridView();
        if (hidCardType.Value == "usecard") //用户卡
            gvResult = gvResultUseCard;
        else //充值卡
            gvResult = gvResultChargeCard;
        //导出结果
        if (gvResult.Rows.Count > 0)
        {
            ExportGridView(gvResult);
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }
    /// <summary>
    /// 初始化列表
    /// </summary>
    public void showNonDataGridView()
    {
        gvResultUseCard.DataSource = new DataTable();
        gvResultUseCard.DataBind();
        gvResultChargeCard.DataSource = new DataTable();
        gvResultChargeCard.DataBind();
    }
    /// <summary>
    /// 用户卡翻页事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gvResultUseCard_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResultUseCard.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    /// <summary>
    /// 充值卡翻页事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gvResultChargeCard_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResultChargeCard.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    /// <summary>
    /// 有效性校验
    /// </summary>
    private void ValidateForQuery()
    {
        //对起始和终止日期的校验
        UserCardHelper.validateDateRange(context, txtStartDate, txtEndDate, true);
    }

    private int operCount = 0;
    /// <summary>
    /// RowDataBound事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //去掉多余的引号
            ResourceManageHelper.ClearRowDataBound(e);
        }
        if (hidCardType.Value == "usecard") //用户卡
        {
            if (gvResultUseCard.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
            {
                operCount += Convert.ToInt32(GetTableCellValue(e.Row.Cells[3]));
            }
            else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
            {
                e.Row.Cells[0].Text = "总计";
                e.Row.Cells[3].Text = operCount.ToString();
            }
        }
        else //充值卡
        {
            if (gvResultChargeCard.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
            {
                operCount += Convert.ToInt32(GetTableCellValue(e.Row.Cells[2]));
            }
            else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
            {
                e.Row.Cells[0].Text = "总计";
                e.Row.Cells[2].Text = operCount.ToString();
            }
        }
    }
    /// <summary>
    /// 获取列表值
    /// </summary>
    /// <param name="cell"></param>
    /// <returns></returns>
    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }
}