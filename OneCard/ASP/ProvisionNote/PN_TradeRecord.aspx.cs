using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Common;
using TM;
using PDO.GroupCard;
using TDO.UserManager;


public partial class ASP_ProvisionNote_PN_TradeRecord : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            

            if (hidShowCheckQuery.Value == "1")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showCheckQuery", "showCheckQuery();", true);
            }


            return;

        }
    }
    
    

    // gridview 换页事件
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        //gvResult.PageIndex = e.NewPageIndex;

    }

    /// <summary>
    /// 查询
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    { 
    
    }

    /// <summary>
    /// 提交处理
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        context.SPOpen();

        context.AddField("P_SESSIONID").Value = Session.SessionID;
        context.AddField("p_ISAPPROVE").Value = hidApprove.Value;
        bool ok = context.ExecuteSP("SP_GC_ORDERAPPROVAL");
        if (ok)
        {
            AddMessage("审批通过成功");


        }

        ScriptManager.RegisterStartupScript(this, this.GetType(), "aa", "SetText();", true);
    }

    // 提交处理
    protected void btnCancel_Click(object sender, EventArgs e)
    {
 
    }

    private void clearTempTable()//清空临时表
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_ORDER");
        context.DBCommit();
    }

    /// <summary>
    /// 查询账单
    /// </summary>
    /// <returns></returns>
    private ICollection query()
    {

        return new DataView();
    }
}
