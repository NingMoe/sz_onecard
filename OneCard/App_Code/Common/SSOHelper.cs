using System.Collections;
using System.Web;
using System.Web.SessionState;

namespace SSO
{

    using System;
    using System.Data;
    using System.Text;
    using Common;
    using Master;

    /// <summary>
    ///SSOHelper 的摘要说明
    /// </summary>
    public class SSOHelper
    {
        //初始化SESSION
        public static DataTable SetupSession()
        {
            //读取配置文件中子系统信息
            SysInfosSection config = (SysInfosSection)System.Configuration.ConfigurationManager.GetSection(
        "SysInfosSection");
            //初始化表结构
            DataTable dt = new DataTable();
            dt.Columns.Add("SysName", System.Type.GetType("System.String"));
            dt.Columns.Add("StaffTable", System.Type.GetType("System.String"));
            dt.Columns.Add("LoginURL", System.Type.GetType("System.String"));
            dt.Columns.Add("LogoutURL", System.Type.GetType("System.String"));
            dt.Columns.Add("IsAuth", System.Type.GetType("System.Boolean"));
            //根据配置文件初始化表
            foreach (SysinfoElement sysinfo in config.Sysinfos)
            {
                DataRow dr = dt.NewRow();
                dr["SysName"] = sysinfo.SysName;
                dr["StaffTable"] = sysinfo.StaffTable;
                dr["LoginURL"] = sysinfo.LoginURL;
                dr["LogoutURL"] = sysinfo.LogoutURL;
                dr["IsAuth"] = false;
                dt.Rows.Add(dr);
            }
            return dt;
        }

        //更新令牌
        public static bool UpdateToken(CmnContext context, string token, string staffTable, string staff)
        {
            context.DBOpen("StorePro");
            context.AddField("P_STAFF").Value = staff;
            context.AddField("P_TOKEN").Value = token;
            context.AddField("P_TABLE").Value = staffTable;
            bool ok = context.ExecuteSP("SP_SSO_UPDATETOKEN");
            return ok;
        }

        //登出
        public static string Logout(DataTable dt)
        {
            StringBuilder result = new StringBuilder();
            foreach (DataRow dr in dt.Rows)
            {
                result.AppendLine("<iframe width=\"0\" height=\"0\" id=\"frameSSO\" src=\"" + dr["LogoutURL"].ToString() + "\" style=\"border-width: 0px;\"></iframe>");
            }
            return result.ToString();
        }

        //登录校验
        public static bool CheckLogin(bool isAdmin,CmnContext context, string username,
            string opercardno, string pwd, string ip,HttpResponse response,HttpSessionState session, ref string loginURL, ref string staffTable, ref DataTable sysinfos)
        {
            DateTime lastActiveTiem = DateTime.MinValue;
            string lastActiceSys;
            string[] parm = new string[4];
            parm[0] = username;
            parm[1] = opercardno;
            parm[2] = DecryptString.EncodeString(pwd);
            parm[3] = ip;
            DataTable data = null;
            //先检查用户名是否存在--add by zhangww
            data = SPHelper.callQuery("SP_SSO_CHECKUSER", context, "CheckStaffExist", parm);
            if (data.Rows.Count == 0)
            {
                context.AddError("用户名不存在，请确认！");
                return false;
            }
            else
            {
                ////用户名存在，先加一笔资料再说
                //context.DBOpen("StorePro");
                //context.AddField("p_functionCode").Value = "insertInitRecord";
                //context.AddField("p_staffno").Value = username;
                //if (!context.ExecuteSP("SP_PB_AddLogonFailRecord"))
                //{
                //    context.AddError("添加初始登陆记录失败，请联系管理员！");
                //    return false;
                //}
            }

            ////如果用户名存在，判断该账号是否被锁定
            //data = SPHelper.callQuery("SP_SSO_CHECKUSER", context, "CheckStaffIsLock", parm);
            //if (data.Rows.Count > 0)
            //{
            //    context.AddError("登陆失败超过规定次数，账户被锁定，请明日再试！");
            //    return false;
            //}

            if (!isAdmin)
            {
                data = SPHelper.callQuery("SP_SSO_CHECKUSER", context, "CheckStaff", parm);
                if (data.Rows.Count == 0)
                {
                    context.AddError("A100001003"); //用户名密码错误
                    AddLogonFailRecord(context, username);//记录登陆失败记录
                    return false;
                }
            }
            else
            {
                data = SPHelper.callQuery("SP_SSO_CHECKUSER", context, "CheckStaffInAdmin", parm);//add by liuhe20120928 电子钱包系统添加admin页面登录限制
                if (data.Rows.Count == 0)
                {
                    context.AddError("用户名密码错误或存在登录限制");
                    AddLogonFailRecord(context, username);//记录登陆失败记录
                    return false;
                }
            }

            if (!isAdmin && data.Select("OPERCARDNO = '" + opercardno + "'").Length == 0)
            {
                context.AddError("A100001008"); //操作员卡不匹配
                return false;
            }
            if (data.Select("DIMISSIONTAG = '1'").Length == 0)
            {
                context.AddError("A100001007"); //用户无效
                return false;
            }
            if (!isAdmin)
            {
                data = SPHelper.callQuery("SP_SSO_CHECKUSER", context, "CheckStaffLogin", parm);
                if (data.Rows.Count == 0)
                {
                    context.AddError("A100001006"); //登录限制
                    return false;
                }
            }
            foreach (DataRow dr in sysinfos.Rows)
            {
                //检查校验结果
                string sysName = dr["SysName"].ToString();
                DataRow[] checkData = data.Select("SYSNAME='" + sysName + "'");
                dr.BeginEdit();
                if (checkData.Length == 1)
                {
                    dr["IsAuth"] = true;
                    DateTime lastActiveTime = DateTime.MinValue;
                    if (checkData[0]["LAST_ACTIVE_TIME"] != null && checkData[0]["LAST_ACTIVE_TIME"].ToString() !="" )
                    {
                        lastActiveTime = (DateTime)checkData[0]["LAST_ACTIVE_TIME"];
                    }
                    // 根据校验结果，找出当前用户最后活动的子系统
                    if ((checkData[0]["LAST_ACTIVE_TIME"].ToString() == "" && lastActiveTiem == DateTime.MinValue)
                        || lastActiveTiem < lastActiveTime)
                    {
                        lastActiveTiem = checkData[0]["LAST_ACTIVE_TIME"].ToString() == "" ?
                            DateTime.MinValue : lastActiveTime;
                        lastActiceSys = dr["SysName"].ToString();
                        loginURL = dr["LoginURL"].ToString();
                        staffTable = dr["StaffTable"].ToString();
                    }
                    //检查市民卡DBLINK
                    if (checkData[0]["SMKCHECK"].ToString() == "ERROR")
                    {
                        System.Web.HttpContext.Current.Session["SMKCHECK"] = false;
                    }
                }
                else
                {
                    dr["IsAuth"] = false;
                }
                dr.EndEdit();
            }
            
            bool isNeedModifyPwd = false;
            string modifyType = "";
            DataTable dtCheckTable = null;
            //判断用户密码输入是否是初始密码
            dtCheckTable = SPHelper.callQuery("SP_SSO_CHECKUSER", context, "checkIsInitPwd", new string[] {pwd});
            if (dtCheckTable.Rows.Count > 0) //表示为初始密码
            {
                isNeedModifyPwd = true;
                modifyType = "1";//初始密码
            }
            else//判断用户是否很久没有没有修改密码了
            {
                dtCheckTable = SPHelper.callQuery("SP_SSO_CHECKUSER", context, "checkIsNotModifyPwdLongAgo", new string[] { username });
                if (dtCheckTable.Rows.Count > 0) //表示用户很久没有没有修改密码了
                {
                    isNeedModifyPwd = true;
                    modifyType = "2";//超过期限
                }
            }
            
            if (isNeedModifyPwd)
            {
                //强制跳转到修改密码页面
                Hashtable hash = new Hashtable();
                hash.Add("UserID", username);
                hash.Add("UserName", "");
                hash.Add("CardID", "");
                hash.Add("DepartID", "");
                hash.Add("DepartName", "");
                hash.Add("DateTime", "");
                hash.Add("DecryptString", DecryptString.EncodeString(username));
                hash.Add("RegionCode", "");
                hash.Add("Debugging","");
                hash["LogonLevel"] = isAdmin ? "Admin" : "Normal";
                session["LogonInfo"] = hash;
                string modifyPwdUrl =
                    string.Format("~/ASP/PrivilegePR/PR_ChangePassword.aspx?modifyType={0}", modifyType);
                response.Redirect(modifyPwdUrl);
                return false;
            }
            return true;
        }

        /// <summary>
        /// 登陆失败，增加失败记录
        /// </summary>
        /// <param name="context"></param>
        /// <param name="staffno"></param>
        private static void AddLogonFailRecord(CmnContext context, string staffno)
        {
            context.DBOpen("StorePro");
            context.AddField("p_functionCode").Value = "insertOrUpdateFailRecord";
            context.AddField("p_staffno").Value = staffno;
            bool ok = context.ExecuteSP("SP_PB_AddLogonFailRecord");
        }

    }
}