using System;
using System.Collections;
using System.Data;
using Common;
using PDO.PrivilegePR;

/// <summary>
/// 交通局版本抽奖页面基类
/// </summary>
namespace Master
{
    public class TransferLotteryMaster : Master
    {
        public TransferLotteryMaster()
        {
            
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
                TransferURL("logon.aspx");
            }


            Hashtable hash = (Hashtable)Session["LogonInfo"];

            if (hash["UserID"] == null || hash["UserName"] == null || hash["CardID"] == null ||
                hash["DepartID"] == null ||
                hash["DepartName"] == null || hash["DateTime"] == null ||
                hash["DecryptString"] == null)
            {
                Response.Redirect("logon.aspx");
            }

            context.s_UserID = hash["UserID"].ToString();
            context.s_UserName = hash["UserName"].ToString();
            context.s_DepartID = hash["DepartID"].ToString();
            context.s_DepartName = hash["DepartName"].ToString();
            context.s_CardID = hash["CardID"].ToString();
            context.s_RegionCode = hash["RegionCode"].ToString();//归属区域
            if ("True".Equals(hash["Debugging"].ToString()))
                context.s_Debugging = true;

            Session["context"] = context;

            String strDateTime = hash["DateTime"].ToString();
            String strDecrypt = hash["DecryptString"].ToString();
            String prePasswd = context.s_UserID + strDateTime;
            String postPasswd = DecryptString.EncodeString(prePasswd);

            if (!postPasswd.Equals(strDecrypt))
            {
                Response.Redirect("logon.aspx");
            }

            // 检查是否当前菜单被授权
            SP_PR_QueryPDO pdo = new SP_PR_QueryPDO();
            pdo.funcCode = "ValidateMenu";
            pdo.var1 = Request.RawUrl.Substring(1);
            pdo.var2 = context.s_UserID;
            String lowerUrl = pdo.var1.ToLower();

            if (lowerUrl.Contains("autocomplete"))
            {
                return;
            }
            if (lowerUrl.IndexOf("transferlottery/logon.aspx") == -1 
                && lowerUrl.IndexOf("transferlottery/changepwd.aspx") ==-1
                && lowerUrl.IndexOf("transferlottery/download.aspx") == -1 )
            {
                StoreProScene sp = new StoreProScene();
                DataTable dt = sp.Execute(context, pdo);
                if (dt == null || dt.Rows.Count == 0)
                {
                    Server.Transfer("~/AccessDeny.aspx");
                }
            }
        }
    }
}