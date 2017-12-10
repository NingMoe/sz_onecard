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
 * 功能名: 资源领用审批
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/12/11    尤悦			初次开发
 ****************************************************************/

public partial class ASP_ResourceManage_RM_GetResourceExam : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showDataGridView();           
        }

    }
    /// <summary>
    /// 查询出所有未审核的资源领用信息
    /// </summary>
    private void showDataGridView()
    {
        DataTable dataGetResourceApply = SPHelper.callQuery("SP_RM_OTHER_QUERY", context, "Query_GetResourceApplyNoApproved");
        gvResultResourceApply.DataSource = dataGetResourceApply;
        gvResultResourceApply.DataBind();
        gvResultResourceApply.SelectedIndex = -1;
    }
    // 选中gridview当前页所有数据
    protected void CheckAll(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResultResourceApply.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }
   
    protected void gvResultResourceApply_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string attribute = "";//属性绑定
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {

                if (i == 13 || i == 15 || i == 17 || i == 19 || i == 21 || i == 23)
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
                if (i >=12)
                {
                    e.Row.Cells[i].Visible = false;  //隐藏资源属性列
                }
            }
        }
    }

    /// <summary>
    /// 审核通过
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnPass_Click(object sender, EventArgs e)
    {
        string sessionID = Session.SessionID;  
        FillTempTable(sessionID,"1");
        ValidInput(); //验证输入
        if (context.hasError())
            return;
        context.SPOpen();
        context.AddField("p_sessionID").Value = sessionID;
        bool ok = context.ExecuteSP("SP_RM_OTHER_GETRESAPPLYAPPROVE");
        if (ok)
        {
            AddMessage("审批通过");
        }
        //清空临时表
       clearTempTable(sessionID);
       showDataGridView();    


    }
    /// <summary>
    /// 数据插入临时表
    /// </summary>
    /// <param name="sessionID"></param>
    private void FillTempTable(string sessionID,string orderstate)
    {
        // 根据页面数据生成临时表数据
        int count = 0;
        //记录入临时表
        context.DBOpen("Insert");
        for (int index = 0; index < gvResultResourceApply.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvResultResourceApply.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                string getcardorderid = gvResultResourceApply.Rows[index].Cells[1].Text.Trim();
                string agreegetnum = "";
                if (orderstate.Equals("1"))
                {
                    TextBox txt = (TextBox)gvResultResourceApply.Rows[index].FindControl("txtAgreeGetNum");
                    agreegetnum = txt.Text.Trim();
                }
               
                //，F0:领用单号，F1:同意领用数量，F2:SessionID
                context.ExecuteNonQuery(@"insert into TMP_COMMON (f0,f1,f2)
                                values('" + getcardorderid + "','" + agreegetnum + "','" + sessionID + "')");
            }
        }
        context.DBCommit();
        
        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("A004P03R01: 没有选中任何行");
        }
    }
    /// <summary>
    /// 审核作废
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        string sessionID = Session.SessionID;        
        FillTempTable(sessionID, "0");
        if (context.hasError())
            return;
        context.SPOpen();
        context.AddField("p_sessionID").Value = sessionID;
        bool ok = context.ExecuteSP("SP_RM_OTHER_GETRESAPPLYAPPROVE");
        if (ok)
        {
            AddMessage("审批作废");
        }
        //清空临时表
        clearTempTable(sessionID);
        showDataGridView();
    }
    /// <summary>
    /// 通过输入验证
    /// </summary>
    private void ValidInput()
    {
        for (int index = 0; index < gvResultResourceApply.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvResultResourceApply.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                TextBox txt = (TextBox)gvResultResourceApply.Rows[index].FindControl("txtAgreeGetNum");
                if (txt.Text.Trim().Length < 1)
                {
                    context.AddError("请填写同意领用数量", txt);
                    return;
                }
                if (txt.Text.Trim().Equals("0"))
                {
                    context.AddError("同意领用数量不能为零", txt);
                    return;
                }
                if (!Validation.isNum(txt.Text.Trim()))
                {
                    context.AddError("同意领用数量请输入数字", txt);
                    return;
                }
                string applyGetNum = gvResultResourceApply.Rows[index].Cells[5].Text; //申请领用数量
                if (Convert.ToInt32(txt.Text.Trim()) > Convert.ToInt32(applyGetNum))  //验证同意领用数量不能超过申请领用数量
                {
                    context.AddError("同意领用数量不能超过申请领用数量", txt);
                    return;
                }
            }
        }
    }

    /// <summary>
    /// 清空临时表
    /// </summary>
    private void clearTempTable(string sessionID)
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery(@"delete from TMP_COMMON where f2='"
            + sessionID + "'");
        context.DBCommit();
    }
}