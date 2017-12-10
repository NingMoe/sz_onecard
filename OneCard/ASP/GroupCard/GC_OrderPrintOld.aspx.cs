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

public partial class ASP_GroupCard_SZ_OrderPrintOld : Master.PopUpMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        //验证父页面权限
        AuthParentPage("ASP/GroupCard/GC_OrderSearchOld.aspx");

        string orderno = Request["ORDERNO"].ToString();
        if (orderno.Length == 12)
        {
            orderno = orderno + "    ";
        }
        DataTable dt = GroupCardHelper.callOrderQuery(context, "AllOrderInfoSelectByOrderNoOld", orderno);
        if (dt != null && dt.Rows.Count > 0)
        {
            string groupName = dt.Rows[0]["GROUPNAME"].ToString();
            string name = dt.Rows[0]["NAME"].ToString();
            string phone = dt.Rows[0]["PHONE"].ToString();
            string idCardNo = dt.Rows[0]["IDCARDNO"].ToString();
            string totalMoney = dt.Rows[0]["TOTALMONEY"].ToString();
            string transactor = dt.Rows[0]["TRANSACTOR"].ToString();
            string remark = dt.Rows[0]["REMARK"].ToString();
            string financeRemark = dt.Rows[0]["FINANCEREMARK"].ToString();
            string invoiceCount = dt.Rows[0]["INVOICECOUNT"].ToString();
            string invoiceTotalMoney = dt.Rows[0]["INVOICETOTALMONEY"].ToString();
            string totalCashGiftChargeMoney = dt.Rows[0]["TOTALCHARGECASHGIFT"].ToString();
            string approver = dt.Rows[0]["approver"].ToString();
            printarea.InnerHtml = OrderHelper.GetOrderHtmlString(context, orderno,
                groupName, name, phone, idCardNo, totalMoney, transactor, remark,
                "2", financeRemark, invoiceCount, invoiceTotalMoney,
                totalCashGiftChargeMoney, approver);
        }
    }
}
