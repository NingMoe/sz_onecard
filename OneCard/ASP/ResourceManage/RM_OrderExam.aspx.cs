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
 * 功能名: 资源管理下单审核
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/07/24    shil			初次开发
 ****************************************************************/
public partial class ASP_ResourceManage_RM_OrderExam : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView();

            hidCardType.Value = "usecard";

            txtOrderID.Text = "DG";
        }

        //固化标签
        ResourceManageHelper.selectTab(this, this.GetType(), hidCardType);
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
        if (hidCardType.Value == "usecard")
            //用户卡
            gv = gvResultUseCard;
        else
            //充值卡
            gv = gvResultChargeCard;

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

        if (hidCardType.Value == "usecard")
            bindUseCard();//查询用户卡
        else
            bindChargeCard();//查询充值卡

        btnPass.Enabled = true;
        btnCancel.Enabled = true;
    }
    /// <summary>
    /// 用户卡GridView绑定数据源
    /// </summary>
    protected void bindUseCard()
    {
        //用户卡
        gvResultUseCard.DataSource = queryUseCard();
        gvResultUseCard.DataBind();
        gvResultUseCard.SelectedIndex = -1;
    }
    /// <summary>
    /// 充值卡GridView绑定数据源
    /// </summary>
    protected void bindChargeCard()
    {
        //充值卡
        gvResultChargeCard.DataSource = queryChargeCard();
        gvResultChargeCard.DataBind();
        gvResultChargeCard.SelectedIndex = -1;
    }
    /// <summary>
    /// 查询用户卡订购单
    /// </summary>
    /// <returns></returns>
    protected ICollection queryUseCard()
    {
        //查询用户卡，订购单号如果为DG时，默认为未输入订购单号
        string cardOrderID = "";
        if (txtOrderID.Text.Trim() != "DG")
            cardOrderID = txtOrderID.Text.Trim();
        DataTable data = ResourceManageHelper.callQuery(context, "queryUseCardOrder", cardOrderID, selExamState.SelectedValue);
        if (data.Rows.Count == 0)
        {
            ResourceManageHelper.resetData(gvResultUseCard, data);
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return new DataView(data);
    }
    /// <summary>
    /// 查询充值卡订购单
    /// </summary>
    /// <returns></returns>
    protected ICollection queryChargeCard()
    {
        //查询用户卡，订购单号如果为DG时，默认为未输入订购单号
        string cardOrderID = "";
        if (txtOrderID.Text.Trim() != "DG")
            cardOrderID = txtOrderID.Text.Trim();
        DataTable data = ResourceManageHelper.callQuery(context, "queryChargeCardOrder", cardOrderID, selExamState.SelectedValue);
        if (data.Rows.Count == 0)
        {
            ResourceManageHelper.resetData(gvResultChargeCard, data);
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
    /// 通过按钮点击事件
    /// </summary>
    protected void btnPass_Click(object sender, EventArgs e)
    {
        //选择回收的记录入临时表
        if (!RecordIntoTmp(true)) return;

        //调用审核通过存储过程
        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;

        bool ok = context.ExecuteSP("SP_RM_ORDEREXAM_PASS");

        if (ok)
        {
            AddMessage("审核通过成功");

            //更新列表
            if (hidCardType.Value == "usecard")
                bindUseCard();
            else
                bindChargeCard();
        }
    }
    /// <summary>
    /// 作废按钮点击事件
    /// </summary>
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        //选择回收的记录入临时表
        if (!RecordIntoTmp(false)) return;

        //调用审核作废存储过程
        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;

        bool ok = context.ExecuteSP("SP_RM_ORDEREXAM_CANCEL");

        if (ok)
        {
            AddMessage("审核作废成功");

            //更新列表
            if (hidCardType.Value == "usecard")
                bindUseCard();
            else
                bindChargeCard();
        }
    }
    /// <summary>
    /// 选中的记录入临时表
    /// </summary>
    /// <returns>入临时表成功返回true，否则返回false</returns>
    private bool RecordIntoTmp(bool isPass)
    {
        //清空临时表
        clearTempTable();

        //记录入临时表
        context.DBOpen("Insert");

        GridView gv = new GridView();
        //如果选中用户卡标签则用户卡列表中订购单号入临时表，否则充值卡列表中订购单号入临时表
        if (hidCardType.Value == "usecard")
            //用户卡
            gv = gvResultUseCard;
        else
            //充值卡
            gv = gvResultChargeCard;

        int count = 0;
        //循环将选中行入临时表
        foreach (GridViewRow gvr in gv.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                //如果是用户卡审核通过，未确认卡面的新制卡片不允许审核通过
                if (hidCardType.Value == "usecard" && isPass)
                    if (string.IsNullOrEmpty(gvr.Cells[7].Text))
                    {
                        context.AddError("第" + count + "条记录是未确认卡面的新制卡片订购单，不允许审核通过！");
                        return false;
                    }
                context.ExecuteNonQuery("insert into TMP_COMMON (f0,f1) values('" +
                        gvr.Cells[1].Text + "', '" + Session.SessionID + "')");
            }
        }

        context.DBCommit();

        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("没有选中任何行");
            return false;
        }

        return true;
    }
    /// <summary>
    /// 清空临时表
    /// </summary>
    private void clearTempTable()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON where f1='"
            + Session.SessionID + "'");
        context.DBCommit();
    }
    /// <summary>
    /// 初始化列表
    /// </summary>
    private void showNonDataGridView()
    {
        gvResultUseCard.DataSource = new DataTable();
        gvResultUseCard.DataBind();
        gvResultChargeCard.DataSource = new DataTable();
        gvResultChargeCard.DataBind();
    }
    //用户卡列表分页
    protected void gvUseCardOrder_Page(object sender, GridViewPageEventArgs e)
    {
        gvResultUseCard.PageIndex = e.NewPageIndex;
        bindUseCard();
    }
    //充值卡列表分页
    protected void gvChargeCardOrder_Page(object sender, GridViewPageEventArgs e)
    {
        gvResultChargeCard.PageIndex = e.NewPageIndex;
        bindChargeCard();
    }
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            ResourceManageHelper.ClearRowDataBound(e);
        }
    }
}