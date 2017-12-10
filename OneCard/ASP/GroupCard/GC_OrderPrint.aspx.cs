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

public partial class ASP_GroupCard_SZ_OrderPrint : Master.PopUpMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        //验证父页面权限
        AuthParentPage("ASP/GroupCard/GC_OrderSearch.aspx");

        string orderno = Request["ORDERNO"].ToString();
        if (orderno.Length == 12)
        {
            orderno = orderno + "    ";
        }
        DataTable dt = GroupCardHelper.callOrderQuery(context, "AllOrderInfoSelectByOrderNo", orderno);
        if (dt != null && dt.Rows.Count > 0)
        {
            string groupName = dt.Rows[0]["GROUPNAME"].ToString();
            string name = dt.Rows[0]["NAME"].ToString();
            string phone = dt.Rows[0]["PHONE"].ToString();
            string idCardNo = dt.Rows[0]["IDCARDNO"].ToString();
            string totalMoney = dt.Rows[0]["TOTALMONEY"].ToString();
            string transactor = dt.Rows[0]["TRANSACTOR"].ToString();
            string customeraccmoney = dt.Rows[0]["CUSTOMERACCMONEY"].ToString();
            string getdepartment = dt.Rows[0]["getdepartment"].ToString();
            string getdate = dt.Rows[0]["getdate"].ToString();
            string remark = dt.Rows[0]["REMARK"].ToString();
            string financeremark = dt.Rows[0]["financeremark"].ToString();
            string financeapproverno = dt.Rows[0]["financeapproverno"].ToString();
            string totalCashGiftChargeMoney = dt.Rows[0]["cashgiftmoney"].ToString();
            //财务审批补充账单信息
            DataTable data = GroupCardHelper.callOrderQuery(context, "AccountSelectByOrderNo", orderno);
            if (data != null && data.Rows.Count > 0)
            {
                financeremark += "</br>";
                for (int i = 0; i < data.Rows.Count; i++)
                {
                    financeremark += "到账银行:" + data.Rows[i]["Toaccountbank"].ToString()
                            + ", 到账账号:" + data.Rows[i]["TOACCOUNTNUMBER"].ToString()
                            + ", 日期:" + data.Rows[i]["TRADEDATE"].ToString()
                            + ", 金额:" + data.Rows[i]["MONEY"].ToString() + "元</br>";
                }
            }
            printarea.InnerHtml = OrderHelper.GetOrderHtmlString(context, orderno, groupName,
                name, phone, idCardNo, totalMoney, transactor, remark, "0",
                financeremark, totalCashGiftChargeMoney, financeapproverno, customeraccmoney, getdepartment, getdate, false, true);
        }
    }
}
