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
/***************************************************************
 * 功能名: 资源管理下单申请
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/07/18    shil			初次开发
 ****************************************************************/
public partial class ASP_ResourceManage_RM_ResourceUnderOrder : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView();
            //初始化页面
            init_Page();
        }
    }

    private void showNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }

    /// <summary>
    /// 页面初始化
    /// </summary>
    protected void init_Page()
    {
        //初始化日期
        DateTime date = new DateTime();
        date = DateTime.Today;
        txtStartDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtEndDate.Text = DateTime.Today.ToString("yyyyMMdd");

        txtApplyOrderID.Text = "XQ";


    }

    #region 查询
    /// <summary>
    /// 查询按钮点击事件
    /// </summary>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //查询校验
        if (!queryValidation())
            return;

        gvResult.DataSource = queryApplyStock();
        gvResult.DataBind();

    }
    /// <summary>
    /// 查询需求单
    /// </summary>
    /// <returns></returns>
    protected ICollection queryApplyStock()
    {
        //查询需求单，需求单号如果为XQ时，默认为未输入需求单号
        string applyOrderID = "";
        if (txtApplyOrderID.Text.Trim() != "XQ")
            applyOrderID = txtApplyOrderID.Text.Trim();
        DataTable data = OtherResourceManagerHelper.callOtherQuery(context, "Query_GridUnderOrder", applyOrderID, txtStartDate.Text.Trim(), txtEndDate.Text.Trim());
        if (data.Rows.Count == 0)
        {
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return new DataView(data);
    }

    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string attribute = "";//属性绑定
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                if (i == 5 || i == 7 || i == 9 || i == 11 || i == 13 || i == 15)
                {
                    if (!string.IsNullOrEmpty(e.Row.Cells[i].Text.Trim()) && e.Row.Cells[i].Text.Trim() != "&nbsp;")
                    {
                        attribute += e.Row.Cells[i - 1].Text.Trim() + ":" + e.Row.Cells[i].Text.Trim() + ";";
                    }
                }
            }
            e.Row.Cells[4].Text = attribute;
        }

        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header)
        {
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                if ((i > 4 && i < 16) || i == 3)
                {
                    e.Row.Cells[i].Visible = false;
                }
            }
        }
    }

    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(gvResult.SelectedRow.Cells[0].Text.Trim()))
        {
            return;
        }
        DataTable data = OtherResourceManagerHelper.callOtherQuery(context, "Query_ListUnderOrder", gvResult.SelectedRow.Cells[0].Text.Trim());

        try
        {
            lbResourceType.Text = data.Rows[0]["RESUOURCETYPE"].ToString();
            lbResourceName.Text = data.Rows[0]["RESOURCENAME"].ToString();
            lbRequireOrder.Text = data.Rows[0]["ORDERDEMAND"].ToString();
            lbRequireDate.Text = data.Rows[0]["REQUIREDATE"].ToString();
            lbRecentDate.Text = data.Rows[0]["LATELYDATE"].ToString();
            lbOrderDate.Text = Convert.ToDateTime(data.Rows[0]["ORDERTIME"].ToString()).ToString("yyyy-MM-dd HH:mm:ss");
            lbStaffName.Text = data.Rows[0]["STAFFNAME"].ToString();
            lbAttribute1.Text = data.Rows[0][12].ToString() == "" ? "" : data.Rows[0][11].ToString() + ":";
            lbValue1.Text = data.Rows[0][12].ToString() == "" ? "" : data.Rows[0][12].ToString();
            lbAttribute2.Text = data.Rows[0][14].ToString() == "" ? "" : data.Rows[0][13].ToString() + ":";
            lbValue2.Text = data.Rows[0][14].ToString() == "" ? "" : data.Rows[0][14].ToString();
            lbAttribute3.Text = data.Rows[0][16].ToString() == "" ? "" : data.Rows[0][15].ToString() + ":";
            lbValue3.Text = data.Rows[0][16].ToString() == "" ? "" : data.Rows[0][16].ToString();
            lbAttribute4.Text = data.Rows[0][18].ToString() == "" ? "" : data.Rows[0][17].ToString() + ":";
            lbValue4.Text = data.Rows[0][18].ToString() == "" ? "" : data.Rows[0][18].ToString();
            lbAttribute5.Text = data.Rows[0][20].ToString() == "" ? "" : data.Rows[0][19].ToString() + ":";
            lbValue5.Text = data.Rows[0][20].ToString() == "" ? "" : data.Rows[0][20].ToString();
            lbAttribute6.Text = data.Rows[0][22].ToString() == "" ? "" : data.Rows[0][21].ToString() + ":";
            lbValue6.Text = data.Rows[0][22].ToString() == "" ? "" : data.Rows[0][22].ToString();
        }
        catch
        {

        }

    }

    /// <summary>
    /// 查询输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean queryValidation()
    {
        //校验需求单号
        if (!string.IsNullOrEmpty(txtApplyOrderID.Text.Trim()) && txtApplyOrderID.Text.Trim() != "XQ")
        {
            if (Validation.strLen(txtApplyOrderID.Text.Trim()) != 18)
                context.AddError("A095470100：需求单号必须为18位", txtApplyOrderID);
            if (!Validation.isCharNum(txtApplyOrderID.Text.Trim()))
                context.AddError("A095470101：需求单必须为英数", txtApplyOrderID);
        }
        //校验日期
        ResourceManageHelper.checkDate(context, txtStartDate, txtEndDate, "A095470102", "A095470103", "A095470104");

        return !context.hasError();
    }
    #endregion
    /// <summary>
    /// 申请输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean supplyValidation()
    {

        //下单数量
        if (string.IsNullOrEmpty(txtNum.Text.Trim()) || txtNum.Text.Trim().Equals("0"))
            context.AddError("A001002306：下单数量不可为空", txtNum);
        else if (!Validation.isNum(txtNum.Text.Trim()))
            context.AddError("A001002307：下单数量必须为数字", txtNum);
        else if (Convert.ToDouble(txtNum.Text.Trim()) > Convert.ToDouble(gvResult.SelectedRow.Cells[16].Text.ToString()))
            context.AddError("A001002308：下单数量不可大于申请数量", txtNum);

        if (Validation.strLen(txtRemark.Text.Trim()) > 255)
        {
            context.AddError("A094780209：备注长度不能超过255位", txtRemark);
        }

        return !context.hasError();
    }
    /// <summary>
    /// 申请按钮点击事件
    /// </summary>
    protected void btnApply_Click(object sender, EventArgs e)
    {
        if (gvResult.SelectedRow == null)
        {
            context.AddError("没有选中任何行");
            return;
        }

        //提交校验
        if (!supplyValidation())
            return;

        string strTime = lbOrderDate.Text.Trim().Replace("-", "").Replace(":", "").Replace("/", "");

        DateTime time = DateTime.ParseExact(lbOrderDate.Text.Trim(), "yyyy-MM-dd HH:mm:ss", null);


        context.SPOpen();
        context.AddField("P_APPLYORDERID").Value = gvResult.SelectedRow.Cells[0].Text.Trim();
        context.AddField("P_RESOURCECODE").Value = gvResult.SelectedRow.Cells[3].Text.Trim();
        context.AddField("P_ATTRIBUTE1").Value = lbValue1.Text.Trim();
        context.AddField("P_ATTRIBUTE2").Value = lbValue2.Text.Trim();
        context.AddField("P_ATTRIBUTE3").Value = lbValue3.Text.Trim();
        context.AddField("P_ATTRIBUTE4").Value = lbValue4.Text.Trim();
        context.AddField("P_ATTRIBUTE5").Value = lbValue5.Text.Trim();
        context.AddField("P_ATTRIBUTE6").Value = lbValue6.Text.Trim();
        context.AddField("P_RESOURCENUM").Value = txtNum.Text.Trim();
        context.AddField("P_TODAY").Value = time.ToString("yyyyMMdd");
        context.AddField("P_ORDERDEMAND").Value = lbRequireOrder.Text.Trim();
        context.AddField("P_REQUIREDATE").Value = lbRequireDate.Text.Trim();
        context.AddField("P_REMARK").Value = txtRemark.Text.Trim();

        //调用资源下单存储过程
        bool ok = context.ExecuteSP("SP_RM_OTHER_UnderOrder");

        if (ok)
        {
            AddMessage("申请成功");
            //清空
            //clear();
        }
    }
    /// <summary>
    /// 清空输入项
    /// </summary>
    protected void clear()
    {
        lbAttribute1.Text = "";
        lbAttribute2.Text = "";
        lbAttribute3.Text = "";
        lbAttribute4.Text = "";
        lbAttribute5.Text = "";
        lbAttribute6.Text = "";
        lbResourceType.Text = "";
        lbResourceName.Text = "";
        lbRequireOrder.Text = "";
        lbRequireDate.Text = "";
        lbRecentDate.Text = "";
        lbOrderDate.Text = "";
        txtNum.Text = "";
    }

    /// <summary>
    /// 打印按钮点击事件
    /// </summary>
    protected void btnPrint_Click(object sender, EventArgs e)
    {
        int count = 0;
        ArrayList orderList = new ArrayList();
        string html = "";
        if (hidCardType.Value == "usecard")
        {
            if (hidApplyType.Value == "ApplyStock")
            {
                if (count < 1)
                {
                    context.AddError("请选择需要打印的需求单");
                    return;
                }
                html = RMPrintHelper.PrintApplyOrder(context, orderList, "01");
            }
            else
            {
                if (count < 1)
                {
                    context.AddError("请选择需要打印的需求单");
                    return;
                }
                html = RMPrintHelper.PrintApplyOrder(context, orderList, "02");
            }
        }
        else
        {

            if (count < 1)
            {
                context.AddError("请选择需要打印的需求单");
                return;
            }
            html = RMPrintHelper.PrintChargeCardOrder(context, orderList);
        }
        printarea.InnerHtml = html;
        //执行打印脚本
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
    }


    /// <summary>
    /// 翻页事件
    /// </summary>
    protected void gvResult_Page(object sender, GridViewPageEventArgs e)
    {
        GridView gv = new GridView();

        gv.PageIndex = e.NewPageIndex;
    }


}