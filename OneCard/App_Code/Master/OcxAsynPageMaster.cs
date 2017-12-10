using System;
using System.Collections.Generic;
using System.Web;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using TM;


namespace Master
{
    /// <summary>
    /// 弹出页面继承的基类
    /// </summary>
    public class OcxAsynPageMaster : MasterBase
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
            string reqBatchId = RequestString("batchId");

            try
            {
                DataTable data = SPHelper.callQuery("SP_CG_Query", context, "FindBatchTradeOperateuser", reqBatchId);
                if (data.Rows.Count == 1)
                {
                    context.s_UserID = data.Rows[0]["operatestaffno"].ToString();
                    context.s_UserName = "";
                    context.s_DepartID = data.Rows[0]["operatedepartid"].ToString();
                    context.s_DepartName = "";
                    context.s_CardID = data.Rows[0]["opercardno"].ToString();
                }
                else
                {
                    this.Response.Write("error2");
                    Server.Transfer("~/AccessDeny.aspx");
                    return;
                }


                Session["context"] = context;
            }
            catch (Exception ex)
            {
                Common.Log.Error("OcxAsynPageMaster," + reqBatchId, ex, "AppLog");
                this.Response.Write("error3");
                return;
            }
        }

        /// <summary>
        /// 获取地址链接后的参数
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        protected string RequestString(object key)
        {
            if (Request.Form[key.ToString()] != null)
            {
                return Request.Form[key.ToString()].ToString();
            }
            if (Request.QueryString[key.ToString()] != null)
            {
                return Request.QueryString[key.ToString()].ToString();
            }
            return "";
        }


        /// <summary>
        /// 返回MD5加密串
        /// </summary>
        /// <param name="str">加密前字符串</param>
        /// <returns></returns>
        protected string Md5Encrypt(string str)
        {
            return System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(str, "MD5");
        }
    }
}
