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
 * 功能名: 资源管理订购单查询
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/07/25    shil			初次开发
 ****************************************************************/
public partial class ASP_ResourceManage_RM_ResourceQueryOrder : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView();

            gvResult.DataKeyNames =
                new string[] { "订购单号","需求单号","订购单状态", "资源类型", "资源名称", "属性", "数量", 
                    "要求到货日期", "最近到货日期", "已到货数量", "下单时间", "下单员工","审核时间","审核员工","备注" };

            init_Page();
        }
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
        txtOrderID.Text = "DG";

        //初始化资源类型
        OtherResourceManagerHelper.selectResourceType(context, selResourceType, true);

    }
    #region 全选列表
    /// <summary>
    /// 选择或取消所有复选框
    /// </summary>
    protected void CheckAll(object sender, EventArgs e)
    {
        //全选信息记录

        CheckBox cbx = (CheckBox)sender;

        GridView gv = new GridView();
            gv = gvResult;

        foreach (GridViewRow gvr in gv.Rows)
        {
            if (!gvr.Cells[1].Enabled) continue;
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }

    }
    #endregion
    /// <summary>
    /// 查询按钮点击事件
    /// </summary>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!queryValidation())
            return;
            bindUseCard();//查询用户卡
    }
    /// <summary>
    /// 用户卡GridView绑定数据源
    /// </summary>
    protected void bindUseCard()
    {
        //用户卡
        gvResult.DataSource = queryUseCard();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }
    /// <summary>
    /// 查询用户卡订购单
    /// </summary>
    /// <returns></returns>
    protected ICollection queryUseCard()
    {
        //查询用户卡
        //订购单号如果为DG时，默认为未输入订购单号
        //需求单号如果为XQ时，默认为未输入需求单号
        string cardOrderID = "";
        string applyOrderID = "";
        if (txtOrderID.Text.Trim() != "DG")
            cardOrderID = txtOrderID.Text.Trim();
        if (txtApplyOrderID.Text.Trim() != "XQ")
            applyOrderID = txtApplyOrderID.Text.Trim();
        DataTable data = OtherResourceManagerHelper.callOtherQuery(context, "QueryForResourceOrder", cardOrderID, applyOrderID, selExamState.SelectedValue, 
                    selResourceType.SelectedValue,txtStartDate.Text.Trim(), txtEndDate.Text.Trim());
        if (data.Rows.Count == 0)
        {
            ResourceManageHelper.resetData(gvResult, data);
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return new DataView(data);
    }

    /// <summary>
    /// 查询输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean queryValidation()
    {
        //校验日期
        ResourceManageHelper.checkDate(context, txtStartDate, txtEndDate, "A095470102", "A095470103", "A095470104");

        //校验需求单号
        if (!string.IsNullOrEmpty(txtApplyOrderID.Text.Trim()) && txtApplyOrderID.Text.Trim() != "XQ")
        {
            if (Validation.strLen(txtApplyOrderID.Text.Trim()) != 18)
                context.AddError("A095470139：需求单号必须为18位", txtApplyOrderID);
            if (!Validation.isCharNum(txtApplyOrderID.Text.Trim()))
                context.AddError("A095470140：需求单必须为英数", txtApplyOrderID);
        }
        
        //校验订购单号
        if (!string.IsNullOrEmpty(txtOrderID.Text.Trim()) && txtOrderID.Text.Trim() != "DG")
        {
            if (Validation.strLen(txtOrderID.Text.Trim()) != 18)
                context.AddError("A095470137：订购单号必须为18位", txtOrderID);
            if (!Validation.isCharNum(txtOrderID.Text.Trim()))
                context.AddError("A095470138：订购单必须为英数", txtOrderID);
        }

        return !context.hasError();
    }

    /// <summary>
    /// 打印按钮点击事件
    /// </summary>
    protected void btnPrint_Click(object sender, EventArgs e)
    {
        int count = 0;
        ArrayList orderList = new ArrayList();
        string html = "";
        
            //for (int index = 0; index < gvResult.Rows.Count; index++)
            //{
            //    CheckBox cb = (CheckBox)gvResult.Rows[index].FindControl("ItemCheckBox");
            //    if (cb != null && cb.Checked)
            //    {
            //        ++count;
            //        if (gvResult.Rows[index].Cells[4].Text.Trim().Equals("2:审核作废"))
            //        {
            //            context.AddError("选中的第" + count + "行订购单已经审核作废，不允许打印！");
            //            return;
            //        }
            //        orderList.Add(gvResult.Rows[index].Cells[1].Text.Trim());
            //    }
            //}
            //if (count < 1)
            //{
            //    context.AddError("请选择需要打印的需求单");
            //    return;
            //}

        if (gvResult.SelectedIndex == -1)
        {
            context.AddError("请选择一行记录");
            return;
        }

        if (gvResult.Rows[gvResult.SelectedIndex].Cells[4].Text.Trim().Equals("2:审核作废"))
        {
            context.AddError("选中行订购单已经审核作废，不允许打印！");
            return;
        }

        string orderNo=gvResult.Rows[gvResult.SelectedIndex].Cells[0].Text.Trim();
        string resourceType=gvResult.Rows[gvResult.SelectedIndex].Cells[3].Text.Trim();
        string resourceName=gvResult.Rows[gvResult.SelectedIndex].Cells[4].Text.Trim();
        string resourceAtt=gvResult.Rows[gvResult.SelectedIndex].Cells[5].Text.Trim();
        string num=gvResult.Rows[gvResult.SelectedIndex].Cells[17].Text.Trim();
        string requiredate=gvResult.Rows[gvResult.SelectedIndex].Cells[18].Text.Trim();
        string remark=gvResult.Rows[gvResult.SelectedIndex].Cells[24].Text.Trim();
        html = RMPrintHelper.GetResourceOrderPrintText(context, orderNo, resourceType, resourceName, resourceAtt, num, requiredate, remark);
        
        printarea.InnerHtml = html;
        //执行打印脚本
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
    }

    /// <summary>
    /// 初始化列表
    /// </summary>
    private void showNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }
    #region GridView事件
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string attribute = "";//属性绑定
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                if (i == 6 || i == 8 || i == 10 || i == 12 || i == 14 || i == 16)
                {
                    if (!string.IsNullOrEmpty(e.Row.Cells[i].Text.Trim()) && e.Row.Cells[i].Text.Trim() != "&nbsp;")
                    {
                        attribute += e.Row.Cells[i - 1].Text.Trim() + ":" + e.Row.Cells[i].Text.Trim() + ";";
                    }
                }
            }
            e.Row.Cells[5].Text = attribute;
        }

        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header)
        {
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                if (i > 5 && i < 17)
                {
                    e.Row.Cells[i].Visible = false;
                }
            }
        }
    }
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        //注册行单击事件
        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }
    //选择行事件
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {

        txtCardOrderID.Text = getDataKeys("订购单号");
        txtApplyCardOrderID.Text = getDataKeys("需求单号");
        txtExamState.Text = getDataKeys("订购单状态").Substring(getDataKeys("订购单状态").IndexOf(":") + 1);
        txtResourceType.Text = getDataKeys("资源类型");

        txtResourceName.Text = getDataKeys("资源名称");
        txtCardSum.Text = getDataKeys("数量");
        txtRequireDate.Text = getDataKeys("要求到货日期");
        txtLatelyDate.Text = getDataKeys("最近到货日期");

        txtAlreadyArriveNum.Text = getDataKeys("已到货数量");
        txtOrderStaff.Text = getDataKeys("下单员工");
        txtOrderTime.Text = getDataKeys("下单时间");

        txtExamStaff.Text = getDataKeys("审核员工");
        txtExamTime.Text = getDataKeys("审核时间");
        txtReMark.Text = getDataKeys("备注");
        

    }
    //获取关键字的值
    public String getDataKeys(string keysname)
    {
        GridView gv = new GridView();

            //用户卡
            gv = gvResult;

        return gv.DataKeys[gv.SelectedIndex][keysname].ToString();
    }
    //翻页事件
    protected void gvResult_Page(object sender, GridViewPageEventArgs e)
    {
        GridView gv = new GridView();

            gv = gvResult;

        gv.PageIndex = e.NewPageIndex;

            bindUseCard();
    }
    #endregion
}