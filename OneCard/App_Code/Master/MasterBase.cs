/************************************************************************
 * MasterBase
 * 类名:页面基类
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2008/01/09    方剑           初次开发
 ************************************************************************/
using System;
using System.Configuration;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Drawing;
using System.IO;
using Common;

namespace Master
{
    public class MasterBase : System.Web.UI.Page
    {
        //应用程序上下文，存放在页面和Bean之间传递的数据
        public CmnContext context;

        //执行成功标志
        protected Boolean boolComfirm = false;

        //页面输入数据
        private Hashtable inputValues;
        public Hashtable InputValues
        {
            get { return inputValues; }
            set { inputValues = value; }
        }

        //页面输出数据
        private Hashtable outputValues;
        public Hashtable OutputValues
        {
            get { return outputValues; }
            set { outputValues = value; }
        }

        //错误信息
        //protected ArrayList errorMessage;

        //完成信息
        //protected ArrayList confirmMessage;

        //存放上一次页面Validation不通过的控件ID
        protected ArrayList CustomerControls
        {
            get{ return (ArrayList)ViewState["CustomerControls"];}
            set{ViewState["CustomerControls"] = value; }
        }
        
        public MasterBase()
        {
        }

        /************************************************************************
         * 页面初始化 
         * @param object sender
         * @param EventArgs e	
         * @return 		                     
         ************************************************************************/
        protected void Page_Init(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.AddHeader("pragma", "no-cache");

            //初始化应用程序上下文
            context = new CmnContext();

            //给应用程序上下文赋值
            context.Response = Response;
            context.HttpServer = Server;
            context.PageName = Page.Request.Path;
            context.ResourcePath = ConfigurationManager.AppSettings.Get("Path") +"Resources" + Path.DirectorySeparatorChar;
            context.DataBaseType = ConfigurationManager.AppSettings.Get("DataBaseType");
            if (context.DataBaseType != null)
                context.DataBaseType = context.DataBaseType.ToLower();

            Application["PageName"] = Page.Request.Path;

            //从Session中获得输入的数据，如果没有获得，则初始化
            object o = Session["InputValues"];
            if (o == null)
                inputValues = new Hashtable();
            else
            {
                inputValues = (Hashtable)o;
                String ErrorMsg = (String)inputValues["InitErrorMessage"];

                if (ErrorMsg != null)
                {
                    context.AddError(ErrorMsg);
                    Session["InputValues"] = null;
                }
            }
            outputValues = new Hashtable();

            //进行用户认证
            User_Auth();

            //给errorMessage赋予初值
            //errorMessage = new ArrayList();

            //给confirmMessage赋予初值
            //confirmMessage = new ArrayList();

            //给应用程序上下文赋值
            context.OutputValues = outputValues;
            //context.ErrorMessage = errorMessage;
        }

        /************************************************************************
         * 页面调用完成
         * @param object sender
         * @param EventArgs e	
         * @return 		                     
         ************************************************************************/
        protected void Page_LoadComplete(object sender, EventArgs e)
        {
            //检查上一次Validation未通过的控件，本次是否通过
            //通过:将控件底色改为白色
            if (CustomerControls != null)
            {
                for (int i = 0; i < CustomerControls.Count; i++)
                {
                    object UniqueID = CustomerControls[i];

                    if (!context.ControlUniqueIDs.Contains(UniqueID))
                    {
                        WebControl control = (WebControl)Page.Form.FindControl(UniqueID.ToString());
                        if (control != null)
                        {
                            control.BackColor = Color.FromArgb(255, 255, 255);
                        }
                    }
                }
            }
            
            //当应用有错误的时候，记录Validation未通过的控件，并RollBack
            //没有错误时，Commit
            if (context.hasError())
            {
                CustomerControls = context.ControlUniqueIDs;
                context.RollBack();
            }
            else
            {
                context.DBCommit();
            }

            //if(confirmMessage.Count > 0)
            //    context.ErrorMessage = confirmMessage;

            //如果有错误信息，显示
            ErrorMsgShow();

            context.ErrorMessage.Clear();
            context.NormalMessages.Clear();
        }


        /************************************************************************
         * 页面迁移
         * @param String page
         * @return 		                     
         ************************************************************************/
        protected void Transfer(String page)
        {
            context.DBCommit();

            //将本页面的输出值，作为下一个页面的输入
            Session["InputValues"] = outputValues;

            if (page == null)
            {
                //Server.Transfer(context.PageName);
            }
            else
            {
                String Url = context.GetUrl(page);

                if (Url == null)
                    context.AppException("S100001002");

                Response.Redirect(Url);
            }
        }

        /************************************************************************
         * URL迁移
         * @param String page
         * @return 		                     
         ************************************************************************/
        protected void TransferURL(String strUrl)
        {
            context.DBCommit();

            //将本页面的输出值，作为下一个页面的输入
            Session["InputValues"] = outputValues;

            Server.Transfer(strUrl);
        }

        protected virtual void User_Auth()
        {
        }

        public virtual void ErrorMsgShow()
        {

        }

        protected void AddMessage(String strMsgID)
        {
            context.AddMessage(strMsgID);

            boolComfirm = true;
        }

        protected void Page_Error(object sender, EventArgs e)
        {
            Exception objErr = Server.GetLastError().GetBaseException();

            String errorMsg = (String)Application["PageName"];
            if (errorMsg != null)
            {
                errorMsg = "页面：" + errorMsg;
            }

            Log.Error(errorMsg, objErr, "ExpLog");

            //Server.ClearError();
            //Server.Transfer("/Onecard/error.html");
        } 
    }
}
