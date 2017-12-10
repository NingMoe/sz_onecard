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
using Common;
using TM;
using PDO.GroupCard;
using TDO.UserManager;

// 

public partial class ASP_GroupCard_SZ_OrderInfoModify : Master.PopUpMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        //验证父页面权限
        AuthParentPage("ASP/GroupCard/GC_OrderSearch.aspx");

        ViewState["orderno"] = Request["ORDERNO"].ToString();
        if (ViewState["orderno"].ToString().Length == 12)
        {
            ViewState["orderno"] = ViewState["orderno"].ToString().PadRight(16, ' ');
        }
        DataTable dt = GroupCardHelper.callOrderQuery(context, "AllOrderInfoSelectByOrderNo", ViewState["orderno"].ToString());
        if (dt != null && dt.Rows.Count > 0)
        {
            txtContactName.Text = dt.Rows[0]["NAME"].ToString();
            txtPhone.Text = dt.Rows[0]["PHONE"].ToString();
            txtIdNo.Text = dt.Rows[0]["IDCARDNO"].ToString();
        }
        

    }

    protected void btnUpdate_Click(object sender, EventArgs e)
    {
        string orderid = ViewState["orderno"].ToString();
        string name = txtContactName.Text.Trim();
        string phone = txtPhone.Text.Trim();
        string idCardNo = txtIdNo.Text.Trim();
        context.SPOpen();
        context.AddField("p_ORDERNO").Value = orderid;
        context.AddField("P_NAME").Value = name;
        context.AddField("P_PHONE").Value = phone;
        context.AddField("P_IDCARDNO").Value = idCardNo;
        bool ok = context.ExecuteSP("SP_GC_ORDERINFOUPDATE");
        if (ok)
        {
            Session["ok"] = true;
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "close", "closeDiv();", true);
        }
    }
}
