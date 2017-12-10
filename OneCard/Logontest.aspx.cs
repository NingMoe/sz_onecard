using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using Common;
using SSO;
using System.Text.RegularExpressions;

public partial class Logontest : Master.MasterBase
{
    public override void ErrorMsgShow()
    {
        Msg.Text = "";
        ArrayList errorMessages = context.ErrorMessage;
        for (int index = 0; index < errorMessages.Count; index++)
        {
            if (index > 0)
                Msg.Text += "|";

            String error = errorMessages[index].ToString();
            int start = error.IndexOf(":");
            if (start > 0) 
            {
                error = error.Substring(start + 1, error.Length - start - 1);
            }

            Msg.Text += error;
        }
    }

    //进入登录页面
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack && Session["SSOInfo"] != null) return;

        //跳转子系统
        if (Request.QueryString["Login"] == "1" && !string.IsNullOrEmpty(Request.QueryString["SysName"]))
        {
            if (Session["SSOInfo"] != null && Session["STAFF"] != null)
            {
                DataTable dt = (DataTable)Session["SSOInfo"];
                foreach (DataRow dr in dt.Rows)
                {
                    if (dr["SysName"].ToString() == Request.QueryString["SysName"] && (Boolean)dr["IsAuth"])
                    {
                        //登录子系统
                        string token = Guid.NewGuid().ToString();
                        //更新令牌
                        bool ok = SSOHelper.UpdateToken(this.context, token, dr["StaffTable"].ToString(), Session["STAFF"].ToString());
                        if (ok)
                        {
                            Response.Redirect(string.Format("{0}?staff={1}&token={2}&type={3}", dr["LoginURL"].ToString()
                                , Session["STAFF"], token, "test"));
                        }
                        else
                        {
                            context.AddError("更新令牌失败，请联系管理员");
                            Session["LogonInfo"] = null;
                            return;
                        }
                        break;
                    }
                }
            }
            context.AddError("登录失败，请重新登录");
            Session["LogonInfo"] = null;
            return;
        }
        else
        {
            //登出各个系统
            if (Request.QueryString["Logout"] == "1" && Session["SSOInfo"] != null)
            {
                Logout();
            }
            //读配置文件，初始化SESSION
            SetupSession();
        }
    }

    //读配置文件，初始化SESSION
    private void SetupSession()
    {
        Session["SSOInfo"] = SSOHelper.SetupSession();
    }

    //登出各子系统
    private void Logout()
    {
        Response.Write("<link href='css/login1.css' rel='stylesheet' type='text/css' />");
        Response.Write(SSOHelper.Logout((DataTable)Session["SSOInfo"]));
    }

    /************************************************************************
     * 输入检查
     * @param
     * @return
     ************************************************************************/
    private Boolean InputCheck()
    {
        if (UserName.Text.Trim() == "")
        {
            context.AddError("A100001001", UserName);
        }

        if (UserPass.Text.Trim() == "")
            context.AddError("A100001002", UserPass);

        //卡有效性检查
        //context.AddError("A100001004");

        if (context.hasError())
            return false;
        else
            return true;
    }


    /************************************************************************
     * 对登录用户进行有效性判断，成功后向后续页面传递数据
     * @param
     * @return
     ************************************************************************/
    protected void LogonBtn_Click(object sender, EventArgs e)
    {
        if (!InputCheck())
            return;

        if (Session["SSOInfo"] == null)

        {
            context.AddError("登录超时，请重新登录");
            return;
        }

        //登录认证
        DataTable dt = (DataTable)Session["SSOInfo"];
        string loginURL = "", staffTable = "";
        string strIpAdr = "";
        if (Request.Headers["x-forwarded-for"] != null)
            strIpAdr = Request.Headers["x-forwarded-for"].ToString();
        else
            strIpAdr = Request.UserHostAddress;

        if (SSOHelper.CheckLogin(false, this.context, UserName.Text.Trim(), txtOperCardno.Text.Trim(), UserPass.Text.Trim(),
            strIpAdr, Response, Session, ref loginURL, ref staffTable, ref dt))
        {
            // 把校验结果写到SESSION中
            Session["SSOInfo"] = dt;
            Session["STAFF"] = UserName.Text.Trim();
            
            Session["url"] = loginURL;
            
            // 更新令牌
            string token = Guid.NewGuid().ToString();
           
            Session["token"] = token;
            bool ok = SSOHelper.UpdateToken(this.context, token, staffTable, UserName.Text.Trim());
            if (ok)
            {

                //if (dt.Select("IsAuth = 'True' ").Length == 1)
                //{
                  
                //    Response.Redirect(string.Format("{0}?staff={1}&token={2}&type={3}&power={4}", loginURL, Session["STAFF"], token, "test", "one"));
                    
                //}
                //else
                //{
                //    Response.Redirect(string.Format("{0}?staff={1}&token={2}&type={3}", loginURL, Session["STAFF"], token, "test"));
                   
                //}
                btnWarning_Click(sender, e);
                
            }
            else
            {
                context.AddError("更新令牌失败，请联系管理员");
                return;
            }
        }
        else
        {
            return;
        }


    }
    /// <summary>
    /// 验证新密码输入格式，密码设置至少包含字母、数据、符号三种中的两种 2013/8/26 add by youyue
    /// </summary>
    /// <param name="newPwd"></param>
    /// <returns></returns>
    public bool validNewPwd(string newPwd)
    {
        if (Regex.IsMatch(newPwd, @"^(?=.*?\d)(?=.*?[A-Za-z])|(?=.*?\d)(?=.*?[!@#$%^&])|(?=.*?[A-Za-z])(?=.*?[!@#$%^&])|[\dA-Za-z!@#$%^&]+$ "))
        {
            return true;
        }
        else
        {
            return false;
        }

    }
    
    //页面跳转方法
    protected void btnRedirect_Click(object sender, EventArgs e)
    {
        
        DataTable dt = Session["SSOInfo"] as DataTable;
        string url = Session["url"].ToString();
        string tok = Session["token"].ToString();
        if (dt.Select("IsAuth = 'True' ").Length == 1)
        {

            Response.Redirect(string.Format("{0}?staff={1}&token={2}&type={3}&power={4}", url, Session["STAFF"], tok, "test", "one"));

        }
        else
        {
            Response.Redirect(string.Format("{0}?staff={1}&token={2}&type={3}", url, Session["STAFF"], tok, "test"));

        }
        }
    
    protected void btnWarning_Click(object sender, EventArgs e)
    {
        if (!validNewPwd(UserPass.Text.Trim()))
        {
           ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "warning", "showWarning()", true);


        }
        else
        {
            btnRedirect_Click(sender, e);//跳转页面
        }
    }


   
  

}
