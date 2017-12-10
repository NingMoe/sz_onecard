using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TDO.UserManager;
using System.Web.UI.HtmlControls;

//description 休闲订单审核
//creater     蒋兵兵
//date        2015-04-17


public partial class ASP_GroupCard_GC_RelaxOrderApproval : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtFromDate.Text = DateTime.Now.AddMonths(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Now.ToString("yyyyMMdd");

            gvOrderList.DataSource = new DataTable();
            gvOrderList.DataBind();

            previousLink.Visible = false;
            nextLink.Visible = false;
        }

    }

    protected void selRemark_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (selRemark.SelectedValue == "03")
            txtRemark.Visible = true;
        else
            txtRemark.Visible = false;
    }

    /// <summary>
    /// 读取照片
    /// </summary>
    /// <param name="orderdetailid">子订单ID</param>
    /// <param name="phototype">照片类型</param>
    /// <returns>字节流</returns>
    private byte[] ReadImage(string orderdetailid, string phototype)
    {
        string selectSql = "Select " + phototype + " From TF_F_XXOL_ORDERDETAIL Where ORDERDETAILID=:ORDERDETAILID";
        context.DBOpen("Select");
        context.AddField(":ORDERDETAILID").Value = orderdetailid;
        DataTable dt = context.ExecuteReader(selectSql);
        context.DBCommit();
        if (dt != null && dt.Rows.Count > 0 && dt.DefaultView[0][phototype].ToString() != "")
        {
            return (byte[])dt.Rows[0].ItemArray[0];
        }

        return null;
    }


    /// <summary>
    /// 查询订单按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!ValidInput()) return;

        gvOrderList.DataSource = new DataTable();
        gvOrderList.DataBind();

        string fromDate = txtFromDate.Text.Trim();
        string endDate = txtToDate.Text.Trim();

        previousLink.Visible = true;
        nextLink.Visible = true;
        ShowFileContent();

        btnRollBack.Enabled = false;
        btnRevoke.Enabled = false;

        //驳回状态正常的可以驳回
        if (selOrderStates.SelectedValue == "1")
        {
            btnRollBack.Enabled = true;
        }
        //驳回状态不是正常的可以撤销驳回驳回
        if (selOrderStates.SelectedValue == "0")
        {
            btnRevoke.Enabled = true;

            selRemark.SelectedValue = "";
            txtRemark.Text = "";
            txtRemark.Visible = false;
        }
    }

    protected void gvOrderList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            HtmlImage imgP = (HtmlImage)e.Row.FindControl("imgPerson");
            string photoType = "PHTOT";
            imgP.Src = "GC_RelaxCardOrderGetPic.aspx?orderDetailId=" + e.Row.Cells[21].Text + "&photoType=" + photoType;
            imgP.Attributes.Add("onclick", "CreateWindow('RoleWindow','GC_ShowPicture.aspx?orderDetailId=" + e.Row.Cells[21].Text + "&photoType=" + photoType + "');");

            HtmlImage imgI = (HtmlImage)e.Row.FindControl("imgIDCard");
            photoType = "PAPERPHTOT";
            imgI.Src = "GC_RelaxCardOrderGetPic.aspx?orderDetailId=" + e.Row.Cells[21].Text + "&photoType=" + photoType;
            imgI.Attributes.Add("onclick", "CreateWindow('RoleWindow','GC_ShowPicture.aspx?orderDetailId=" + e.Row.Cells[21].Text + "&photoType=" + photoType + "');");
        }
    }

    //分页
    protected void Link_Click(object sender, CommandEventArgs e)
    {
        ViewState["page"] = e.CommandArgument.ToString();
        ShowFileContent();
    }

    //显示文件内容
    public void ShowFileContent()
    {
        // 指定的页数
        int page = 1;
        if (ViewState["page"] != null && !string.IsNullOrEmpty(ViewState["page"].ToString()))
            page = Int32.Parse(ViewState["page"].ToString());

        //总数
        int iCount = 0;
        //每页数量
        int iPerPage = 10;
        int begin = (page - 1) * iPerPage + 1;
        int end = page * iPerPage + 1;
        string[] parm = new string[8];
        parm[0] = selOrderType.SelectedValue;
        parm[1] = txtOrderNo.Text;
        parm[2] = txtFromDate.Text;
        parm[3] = txtToDate.Text;
        parm[4] = selOrderStates.SelectedValue;
        parm[5] = selPayCanal.SelectedValue;
        parm[6] = begin.ToString();
        parm[7] = end.ToString();
        iCount = Int32.Parse(GroupCardHelper.callQuery(context, "QueryOrderCount", parm).Rows[0][0].ToString());
        DataTable table = GroupCardHelper.callQuery(context, "QueryRelaxOrder", parm);
        if (table.Rows.Count > 0)
        {
            gvOrderList.DataSource = table;
            gvOrderList.DataBind();
        }
        // 页数
        int iPagecount = 1;
        iPagecount = (int)Math.Ceiling((double)iCount / (double)iPerPage);
        // 显示页控件
        // 设置页
        if (iPagecount > 1)
        {
            int currentPage = page;
            // 前一页
            if (currentPage == 1)
            {
                previousLink.Enabled = false;
            }
            else
            {
                previousLink.Enabled = true;
                previousLink.CommandArgument = (currentPage - 1).ToString();
            }
            // 下一页
            if (currentPage == iPagecount)
            {
                nextLink.Enabled = false;
            }
            else
            {
                nextLink.Enabled = true;
                nextLink.CommandArgument = (currentPage + 1).ToString();
            }
        }
        else
        {
            previousLink.Visible = false;
            nextLink.Visible = false;
        }
    }

    // 回退
    protected void btnRollBack_Click(object sender, EventArgs e)
    {
        //清空临时表信息

        clearTempTable();

        //选择审核的订单和账单入临时表
        if (!RecordIntoTmp()) return;

        context.SPOpen();
        context.AddField("p_sessionID").Value = Session.SessionID;

        bool ok = context.ExecuteSP("SP_GC_RELAXORDERBACK");

        if (ok)
        {
            AddMessage("回退成功");

            InvokeApp();    //调用手机端APP
            btnQuery_Click(sender, e);
        }
    }

    // 撤销回退
    protected void btnRevoke_Click(object sender, EventArgs e)
    {
        //清空临时表信息

        clearTempTable();

        //选择审核的订单和账单入临时表
        if (!RecordIntoTmp()) return;

        context.SPOpen();
        context.AddField("p_sessionID").Value = Session.SessionID;

        bool ok = context.ExecuteSP("SP_GC_RELAXORDERREVOKE");

        if (ok)
        {
            AddMessage("撤销回退成功");

            InvokeApp();    //调用手机端APP
            btnQuery_Click(sender, e);
        }

    }

    /// <summary>
    /// 调用手机APP端
    /// </summary>
    private void InvokeApp()
    {
        string msg = RelaxWebServiceHelper.RelaxOrderTypeInfo(GetTMPRelax());
        //if (msg != "0000")
        //{
        //    context.AddError(msg);
        //}
        //else
        //{
        //    context.AddMessage("调用手机端成功");
        //}
    }
    private void clearTempTable()//清空临时表
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_ORDER where f0 = '" + Session.SessionID + "'");
        context.DBCommit();
    }

    //选中记录入临时表
    private bool RecordIntoTmp()
    {
        context.DBOpen("Insert");
        int ordercount = 0;

        List<string> company = new List<string>();
        foreach (GridViewRow gvr in gvOrderList.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkOrderList");
            if (cb != null && cb.Checked)
            {
                ordercount++;
                //订单记录入临时表
                context.ExecuteNonQuery("insert into TMP_ORDER (F0,F1,F2,F3) values('" +
                     Session.SessionID + "', '" + gvr.Cells[19].Text + "','" + gvr.Cells[21].Text + "', '" + selRemark.SelectedItem.Text + "')");
            }
        }
        //校验是否选择了订单

        if (ordercount <= 0)
        {
            context.AddError("请选择订单！");
            context.RollBack();
            return false;
        }
        if (context.hasError())
        {
            context.RollBack();
            return false;
        }
        context.DBCommit();
        return true;
    }

    /// <summary>
    /// 获取休闲数据用以发起休闲订单状态变更
    /// </summary>
    /// <returns></returns>
    private DataTable GetTMPRelax()
    {
        DataTable dt = GroupCardHelper.callQuery(context, "QueryTMPRelax", Session.SessionID);
        return dt;
    }

    /// <summary>
    /// 查询验证
    /// </summary>
    /// <returns></returns>
    private bool ValidInput()
    {
        //校验联系人长度
        if (!string.IsNullOrEmpty(txtOrderNo.Text) && !Validation.isCharNum(txtOrderNo.Text))
        {
            context.AddError("A094780090:订单号只能为英数");
        }

        //对开始日期和结束日期的判断

        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, false);
        return !(context.hasError());
    }
}
