using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using Master;
using PDO.ProvisionNote;


public partial class ASP_ProvisionNote_PN_UnBankApproval : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            //初始化订单表格

            gvBank.DataSource = query();
            gvBank.DataBind();

            return;
        }
    }

    // gridview 换页事件
    public void gvBank_Page(Object sender, GridViewPageEventArgs e)
    {
        gvBank.PageIndex = e.NewPageIndex;

    }

    // 查询输入校验处理
    private void validate()
    {
        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtFromDate);
        bool b2 = Validation.isEmpty(txtToDate);
        DateTime? fromDate = null, toDate = null;

        if (b1 || b2)
        {
            context.AddError("开始日期和结束日期必须填写");
        }
        else
        {
            if (!b1)
            {
                fromDate = valid.beDate(txtFromDate, "开始日期范围起始值格式必须为yyyyMMdd");
            }
            if (!b2)
            {
                toDate = valid.beDate(txtToDate, "结束日期范围终止值格式必须为yyyyMMdd");
            }
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        }
    }

    /// <summary>
    /// 查询
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {

        validate();
        if (context.hasError()) return;

        DataTable data = PNHelper.callQuery(context, "QUERYUNBANKLESS", txtFromDate.Text, txtToDate.Text);

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("查询结果为空");
        }

        UserCardHelper.resetData(gvBank, data);

        labBank.Text = "0";
    }

    // 提交审核处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        //清空临时表信息

        clearTempTable();


        if (!RecordIntoTmp("match")) return;

        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        bool ok = context.ExecuteSP("SP_PN_UNBANKLESS");

        if (ok)
        {
            context.AddMessage("不匹配帐务确认成功");
            btnQuery_Click(sender, e);
        }

    }

    private void clearTempTable()//清空临时表
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON where F0 ='" + System.Web.HttpContext.Current.Session.SessionID + "'");
        context.DBCommit();
    }

    private bool RecordIntoTmp(string type)
    {
        //选中记录入临时表
        context.DBOpen("Insert");
        int bankCount = 0;
        decimal posbanksummoney = 0;
        decimal netatradesummoney = 0;

        List<string> company = new List<string>();
        foreach (GridViewRow gvr in gvBank.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkBankList");
            if (cb != null && cb.Checked)
            {
                bankCount++;
                if (Convert.ToDecimal(gvr.Cells[2].Text) * 100 > 0)
                {
                    //正数银行帐务录入临时表
                    context.ExecuteNonQuery("insert into TMP_COMMON (F0,F1,F2,F3) values('" +
                         Session.SessionID + "', '0','" +Convert.ToDecimal(gvr.Cells[2].Text) * 100 + "','" + gvr.Cells[9].Text + "')");

                    posbanksummoney += Convert.ToDecimal(gvr.Cells[2].Text) * 100;
                }
                else
                {
                    //负数银行帐务录入临时表
                    context.ExecuteNonQuery("insert into TMP_COMMON (F0,F1,F2,F3) values('" +
                         Session.SessionID + "', '1','" + Convert.ToDecimal(gvr.Cells[2].Text) * 100 + "','" + gvr.Cells[9].Text + "')");

                    netatradesummoney += Convert.ToDecimal(gvr.Cells[2].Text) * 100;
                }
            }
        }
        //校验是否选择了银行帐务

        if (bankCount <= 0)
        {
            context.AddError("请选择银行信息！");
            return false;
        }
        if (type == "match")
        {
            if (posbanksummoney + netatradesummoney != 0)
            {
                context.AddError("勾选金额总数不为0,不可匹配");
            }

        }
        
        if (context.hasError())
        {
            return false;
        }
        else
        {
            context.DBCommit();
            return true;
        }
    }

    /// <summary>
    /// 查询账单
    /// </summary>
    /// <returns></returns>
    private ICollection query()
    {

        return new DataView();
    }

    protected void gvBank_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[9].Visible = false;    //TRADEID隐藏
        }
    }
    //撤销不匹配确认操作
    protected void btnRollBack_Click(object sender, EventArgs e)
    {
        //清空临时表信息

        clearTempTable();


        if (!RecordIntoTmp("rollback")) return;

        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        context.AddField("P_TYPE").Value = "ROLLBACK";
        bool ok = context.ExecuteSP("SP_PN_UNBANKROLLBACK");

        if (ok)
        {
            context.AddMessage("撤销成功");
            btnQuery_Click(sender, e);
        }
    }
    //隐藏不匹配的信息
    protected void btnHide_Click(object sender, EventArgs e)
    {
        //清空临时表信息

        clearTempTable();


        if (!RecordIntoTmp("hide")) return;

        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        context.AddField("P_TYPE").Value = "HIDE";
        bool ok = context.ExecuteSP("SP_PN_UNBANKROLLBACK");

        if (ok)
        {
            context.AddMessage("隐藏成功");
            btnQuery_Click(sender, e);
        }
    }
}
