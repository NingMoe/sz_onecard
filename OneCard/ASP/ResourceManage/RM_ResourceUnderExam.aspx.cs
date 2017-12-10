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
public partial class ASP_ResourceManage_RM_ResourceUnderExam : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView();


            txtOrderID.Text = "DG";
        }
    }

    /// <summary>
    /// 查询按钮点击事件
    /// </summary>
    protected void btnQuery_Click(object sender, EventArgs e)
    {

        DateTime dt = DateTime.Now;
        string dts = string.Format("{0:yyyy-MM-dd HH:mm:ss}", dt);
        DateTime sss = DateTime.ParseExact(dts, "yyyy-MM-dd HH:mm:ss", null);


        if (!queryValidation())
            return;

        bindResult();//查询用户卡

        btnPass.Enabled = true;
        btnCancel.Enabled = true;
    }
    /// <summary>
    /// 用户卡GridView绑定数据源
    /// </summary>
    protected void bindResult()
    {
        //用户卡
        gvResult.DataSource = queryResult();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }

    /// <summary>
    /// 查询用户卡订购单
    /// </summary>
    /// <returns></returns>
    protected ICollection queryResult()
    {
        //查询用户卡，订购单号如果为DG时，默认为未输入订购单号
        string cardOrderID = "";
        if (txtOrderID.Text.Trim() != "DG")
            cardOrderID = txtOrderID.Text.Trim();
        DataTable data = OtherResourceManagerHelper.callOtherQuery(context, "Query_ResourceUnderExam", cardOrderID, selExamState.SelectedValue);
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
        //插入临时表
        if (!RecordIntoTmp()) return;

        //调用审核通过存储过程
        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;

        bool ok = context.ExecuteSP("SP_RM_UNDEREXAM_PASS");

        if (ok)
        {
            AddMessage("审核通过成功");

            //更新列表
            bindResult();
        }
    }
    /// <summary>
    /// 作废按钮点击事件
    /// </summary>
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        if (!RecordIntoTmp()) return;

        //调用审核作废存储过程
        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;

        bool ok = context.ExecuteSP("SP_RM_UNDEREXAM_CANCEL");

        if (ok)
        {
            AddMessage("审核作废成功");

            //更新列表
            bindResult();
        }
    }

    /// <summary>
    /// 选中的记录入临时表
    /// </summary>
    /// <returns>入临时表成功返回true，否则返回false</returns>
    private bool RecordIntoTmp()
    {
        //清空临时表
        clearTempTable();

        //记录入临时表
        context.DBOpen("Insert");

        // 没有选中任何行，则返回错误
        if (gvResult.SelectedIndex == -1)
        {
            context.AddError("没有选中任何行");
            return false;
        }

        context.ExecuteNonQuery("insert into TMP_COMMON (f0,f1) values('" +
                gvResult.SelectedRow.Cells[0].Text + "', '" + Session.SessionID + "')");

        context.DBCommit();

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
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }
    //用户卡列表分页
    protected void gvResult_Page(object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        bindResult();
    }

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
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }
}