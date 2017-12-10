/************************************************************************
 * Master
 * 类名:应用页面基类
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2008/01/09    方剑           初次开发
 ************************************************************************/
using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Collections;
using Common;
using TM;
using PDO.PrivilegePR;

namespace Master
{
    /// <summary>
    /// 弹出页面继承的基类
    /// </summary>
    public class PopUpMaster : MasterBase
    {
        protected TMTableModule tm = new TMTableModule();

        protected void setReadOnly(params WebControl[] wcs)
        {
            foreach (WebControl wc in wcs)
            {
                wc.Attributes["readonly"] = "true";
                wc.CssClass = "labeltext";
            }
        }

        protected void clearReadOnly(params WebControl[] wcs)
        {
            foreach (WebControl wc in wcs)
            {
                wc.Attributes.Remove("readonly");
                wc.CssClass = "inputmid";
            }
        }

        protected void ClearControl(Control control)
        {
            foreach (Control c in control.Controls)
            {
                if (c is Label)
                {
                    ((Label)c).Text = "";
                }
                else if (c is TextBox)
                {
                    ((TextBox)c).Text = "";
                }
                else if (c is CheckBox)
                {
                    ((CheckBox)c).Checked = false;
                }
                else if (c is RadioButton)
                {
                    ((RadioButton)c).Checked = false;
                }

                if (c.Controls.Count > 0)
                {
                    ClearControl(c);
                }
            }
        }

        protected void ClearLabelControl(Control control)
        {
            foreach (Control c in control.Controls)
            {
                if (c is Label)
                {
                    ((Label)c).Text = "";
                }

                if (c.Controls.Count > 0)
                {
                    ClearLabelControl(c);
                }
            }
        }

        protected void ErrorMsgHelper(ListControl lst)
        {
            if (context.ErrorMessage.Count > 0
                || context.NormalMessages.Count > 0)
            {
                bool hasError = context.ErrorMessage.Count > 0;

                lst.Items.Clear();
                lst.Visible = true;

                foreach (Object o in context.ErrorMessage)
                {
                    lst.Items.Add(o.ToString());
                }
                foreach (Object o in context.NormalMessages)
                {
                    lst.Items.Add(o.ToString());
                }

                if (lst is DropDownList)
                {
                    lst.BackColor = !hasError
                        ? System.Drawing.Color.FromArgb(255, 255, 255)
                        : System.Drawing.Color.FromArgb(255, 192, 192);
                }
                else
                {
                    lst.CssClass = !hasError ? "message" : "errormessage";
                }
            }
            else
            {
                lst.Visible = false;
            }
        }

        /************************************************************************
         * 用户认证
         * @return 		                     
         ************************************************************************/
        protected override void User_Auth()
        {
            if (Session["LogonInfo"] == null)
            {
                String strUrl = Request.Url.ToString();

                OutputValues.Add("InitErrorMessage", "已超时，请重新登录");

                if (strUrl.IndexOf("/admin", StringComparison.OrdinalIgnoreCase) >= 0)
                    TransferURL("~/TransferLogon.aspx?type=admin");
                else
                    TransferURL("~/TransferLogon.aspx");

            }

            string loginURL = ConfigurationManager.AppSettings["LoginServer"] + "/Logon.aspx";
            Hashtable hash = (Hashtable)Session["LogonInfo"];

            if (hash["UserID"] == null || hash["UserName"] == null || hash["CardID"] == null ||
                hash["DepartID"] == null ||
                hash["DepartName"] == null || hash["DateTime"] == null ||
                hash["DecryptString"] == null)
            {
                Response.Redirect(loginURL);

            }

            context.s_UserID = hash["UserID"].ToString();
            context.s_UserName = hash["UserName"].ToString();
            context.s_DepartID = hash["DepartID"].ToString();
            context.s_DepartName = hash["DepartName"].ToString();
            context.s_CardID = hash["CardID"].ToString();
            if ("True".Equals(hash["Debugging"].ToString()))
                context.s_Debugging = true;

            Session["context"] = context;

            String strDateTime = hash["DateTime"].ToString();
            String strDecrypt = hash["DecryptString"].ToString();
            String prePasswd = context.s_UserID + strDateTime;
            String postPasswd = DecryptString.EncodeString(prePasswd);

            if (!postPasswd.Equals(strDecrypt))
            {
                Response.Redirect(loginURL);
            }

        }

        /// <summary>
        /// 验证父页面是否有访问权限
        /// </summary>
        /// <param name="parentUrl"></param>
        protected void AuthParentPage(string parentUrl)
        {
            // 检查是否当前菜单被授权
            SP_PR_QueryPDO pdo = new SP_PR_QueryPDO();
            pdo.funcCode = "ValidateMenu";

            pdo.var1 = parentUrl;
            pdo.var2 = context.s_UserID;

            String lowerUrl = pdo.var1.ToLower();
            StoreProScene sp = new StoreProScene();
            DataTable dt = sp.Execute(context, pdo);

            if (dt == null || dt.Rows.Count == 0)
            {
                Server.Transfer("~/AccessDeny.aspx");
            }
        }
    }
}
