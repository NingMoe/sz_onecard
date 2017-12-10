using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TDO.BalanceChannel;
using TDO.ConsumeBalance;
using TM;

public partial class ASP_CustomerAcc_CA_SpeAdjustAccCheck : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //查询待审核的特殊调账信息
            QueryAdjustAcc();
            //清空临时表数据
            clearTempTable();
        }
    }

    private void clearTempTable()
    {   //清空临时表数据

        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_ADJUSTACC_IMP where SessionId='"
            + Session.SessionID + "'");
        context.DBCommit();
    }

    private void QueryAdjustAcc()
    {
        //取得查询结果
        ICollection dataView = QueryResultColl();

        //显示查询结果信息
        gvResult.DataSource = dataView;
        gvResult.DataBind();
    }

    private void showResult()
    {
        //显示调帐信息列表信息
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }


    protected void CheckAll(object sender, EventArgs e)
    {
        //全选审核信息记录

        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            if (!gvr.Cells[0].Enabled) continue;
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }


    public ICollection QueryResultColl()
    {
        DataTable data = SPHelper.callQuery("SP_CA_Query", context, "SpeAdjustAccCheck", new string[1]);
        DataView dataView = new DataView(data);
        return dataView;
    }


    

    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        //分页处理 
        gvResult.PageIndex = e.NewPageIndex;
        QueryAdjustAcc();

    }



    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //单元格从索引0开始

            //显示 交易金额,,退款金额单位为元
            e.Row.Cells[3].Text = (Convert.ToDouble(e.Row.Cells[3].Text) / 100).ToString("0.00");
            e.Row.Cells[4].Text = (Convert.ToDouble(e.Row.Cells[4].Text) / 100).ToString("0.00");
            e.Row.Cells[12].Text = (Convert.ToDouble(e.Row.Cells[12].Text) / 100).ToString("0.00");
        }

        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow)
        {
            //隐藏业务流水号

            e.Row.Cells[13].Visible = false;
        }
    }


    private bool RecordIntoTmp()
    {
        //回收记录入临时表
        context.DBOpen("Insert");

        int count = 0;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;

                //退款金额转换为分为单位的整数

                Double dbl = Convert.ToDouble(gvr.Cells[3].Text) * 100;
                int iRefundMoney = Convert.ToInt32(dbl);
                context.ExecuteNonQuery("insert into TMP_ADJUSTACC_IMP values('"
                    + gvr.Cells[13].Text + "','" + gvr.Cells[1].Text + "'," + iRefundMoney + ",'" + Session.SessionID + "')");
            }
        }

        context.DBCommit();

        // 没有选中任何行，则返回错误

        if (count <= 0)
        {
            context.AddError("A009111001");
            return false;
        }

        return true;
    }


    protected void btnPass_Click(object sender, EventArgs e)
    {
        //清空临时表数据
        clearTempTable();

        //信息插入临时表
        if (!RecordIntoTmp()) return;

        //调用通过的存储过程
        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        context.AddField("P_STATECODE").Value = "1";
        bool ok = context.ExecuteSP("SP_CA_SPEADJUSTACCCHECK");
        if (ok)
        {
            AddMessage("M009111112");
        }
        //清空临时表数据
        clearTempTable();

        //查询待审核的调账信息
        QueryAdjustAcc();

    }




    protected void btnCancel_Click(object sender, EventArgs e)
    {
        //清空临时表数据
        clearTempTable();

        //信息插入临时表
        if (!RecordIntoTmp()) return;

        //调用作废的存储过程
        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        context.AddField("P_STATECODE").Value = "3";
        bool ok = context.ExecuteSP("SP_CA_SPEADJUSTACCCHECK");
        if (ok)
        {
            AddMessage("M009111113");
        }

        //清空临时表数据
        clearTempTable();
        //查询待审核的调账信息
        QueryAdjustAcc();
    }
}