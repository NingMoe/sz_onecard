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
using Common;
using TDO.ChargeCard;
using Master;
using PDO.ChargeCard;

public partial class ASP_ChargeCard_CC_ExtendEndTime : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        UserCardHelper.resetData(gvResult, null);
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        ViewState["CardList"] = null;

        ChargeCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo, true);

        if (context.hasError())
        {
            UserCardHelper.resetData(gvResult, null);

            return;
        }

        DataTable data = ChargeCardHelper.callQuery(context, "F7", txtFromCardNo.Text, txtToCardNo.Text);

        UserCardHelper.resetData(gvResult, data);

        ViewState["CardList"] = data;

        if (data == null || data.Rows.Count == 0 )
        {
            AddMessage("N007P00001: 查询结果为空");
        }
        btnSubmit.Enabled = true;
    }

    protected void gvResult_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    protected void lvwQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
    }

    protected void btnSubmit_OnClick(object sender, EventArgs e)
    {
        if (ViewState["CardList"] != null)
        {
            DataTable data = (DataTable)ViewState["CardList"];
            if (data.Rows.Count > 0)
            {
                //清空临时表
                clearTemp();
                context.DBOpen("Insert");
                //卡号入临时表
                for (int i = 0; i < data.Rows.Count; i++)
                {
                    string cardno = data.Rows[i][0].ToString();
                    context.ExecuteNonQuery("insert into TMP_COMMON (F0,F1) values('" + Session.SessionID + "','" + cardno + "')");
                }
                context.DBCommit();
                //执行存储过程
                context.SPOpen();
                context.AddField("p_SessionID").Value = Session.SessionID;
                context.AddField("p_fromCardNo").Value = txtFromCardNo.Text;
                context.AddField("p_toCardNo").Value = txtToCardNo.Text;
                bool ok = context.ExecuteSP("SP_CC_EXTENDENDTIME");
                if (ok)
                {
                    context.AddMessage("A007P03010:充值卡有效期延长成功");
                    btnQuery_Click(sender, e);
                    btnSubmit.Enabled = false;
                }
                //清空临时表
                clearTemp();
            }
        }

    }

    private void clearTemp()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON where F0 = '" + Session.SessionID + "'");
        context.DBCommit();
    }
}
