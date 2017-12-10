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
using TM;
using PDO.ChargeCard;
using Common;

// 直销到账处理
public partial class ASP_ChargeCard_CC_DSAccRecv : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        ChargeCardHelper.createTempTable(context);
        clearTempTable();

        DataTable dt = new DataTable();
        gvResult.DataSource = dt;
        gvResult.DataBind();
    }

    // 清空直销到账所用的临时表
    private void clearTempTable()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_CC_AccRecvList where SessionId='"
            + Session.SessionID + "'");
        context.DBCommit();
    }

    // 换页处理
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    // 查询按钮点击事件处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        // 根据是否到账以及客户姓名查询直销台帐（客户姓名为模糊查询）
        DataTable data = ChargeCardHelper.callQuery(context, "F01",
            radRecvd.Checked ? "1" : "0", txtCustName.Text.Trim());

        gvResult.DataSource = data;
        gvResult.DataBind();
        btnSubmit.Enabled = radNotRecvd.Checked && data.Rows.Count > 0;

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N007P00001: 查询结果为空");
        }

        // 初始化gridview中的是否到账复选框和到帐时间输入框
        for (int i = 0; i < gvResult.Rows.Count; ++i)
        {
            GridViewRow gvr = gvResult.Rows[i];
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            cb.Checked = radRecvd.Checked;
            cb.Enabled = !cb.Checked;

            TextBox tb = (TextBox)gvr.FindControl("txtRecvDate");
            if (radRecvd.Checked)
            {
                if (!Convert.IsDBNull(data.Rows[i].ItemArray[1]))
                {
                    tb.Text = ((DateTime)data.Rows[i].ItemArray[1]).ToString("yyyyMMdd");
                }
                tb.Enabled = false;
            } // if (radRecvd.Checked)
        }  // for (int i = 0; i <
    } // btnQuery_Click

    // “提交”按钮点击事情处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 首先清空临时表        clearTempTable();

        context.DBOpen("Insert");

        int count = 0;

        // 检查”是否到账“的设置以及”到账日期“的输入，并且放入临时表中
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            TextBox tb = (TextBox)gvr.FindControl("txtRecvDate");

            if (cb != null && cb.Checked )
            {
                if (tb.Text.Length <= 0)
                {
                    context.AddError("A007P03001: 设置到帐标记时，必须同时设置到帐日期");
                    return;
                }
                else
                {
                    Validation valid = new Validation(context);
                    DateTime? dt = null;
                    bool b = valid.fixedLength(tb, 8, "A007P03002: 到账日期必须为8位");

                    if (b)
                    {
                        dt = valid.beDate(tb, "A007P03003: 到帐日期必须格式为yyyyMMdd");
                        if (dt != null && dt.Value.CompareTo(DateTime.Today) > 0)
                        {
                            context.AddError("A007P03004: 到帐日期不能超过当前日期");
                        }
                    }
                }

                if (!context.hasError())
                {
                    ++count;
                    context.ExecuteNonQuery("insert into TMP_CC_AccRecvList values('"
                        + Session.SessionID + "','" + gvr.Cells[3].Text + "', '" + tb.Text + "')");
                }
            }
        }

        if (context.hasError())
        {
            context.RollBack();
            return;
        }
        context.DBCommit();

        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("A007P03005: 没有设置任何行的到帐标记为到帐");
            return;
        }

        // 调用”直销到账”存储过程
        SP_CC_DSAccRecvPDO pdo = new SP_CC_DSAccRecvPDO();
        pdo.sessionId = Session.SessionID;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok) AddMessage("D007P03001: 设置到帐成功");

        btnQuery_Click(sender, e);
        clearTempTable();
    }
}
