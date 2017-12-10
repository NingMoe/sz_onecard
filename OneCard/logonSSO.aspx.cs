using System;
using System.Collections;
using Common;
using PDO.PrivilegePR;
using TDO.UserManager;
using TM;
using TM.UserManager;

public partial class LogonSSO : Master.MasterBase
{
    protected void Page_Load(object sender, EventArgs e)
    {
        //判断登录模式，初始化登录页面
        string loginURL = System.Configuration.ConfigurationManager.AppSettings["LoginServer"] + "/Logon.aspx";
        if (Request.QueryString["type"] == "admin")
        {
            loginURL = System.Configuration.ConfigurationManager.AppSettings["LoginServer"] + "/LogonAdmin.aspx";
        }
        else if (Request.QueryString["type"] == "test")
        {
            loginURL = System.Configuration.ConfigurationManager.AppSettings["LoginServer"] + "/Logontest.aspx";
        }
        if (string.IsNullOrEmpty(Request.QueryString["staff"]) || string.IsNullOrEmpty(Request.QueryString["token"]))
        {
            //URL无效 返回登录页面
            Response.Redirect(loginURL);
        }
        else
        {
            string token=Guid.NewGuid().ToString();
            //校验令牌
            context.DBOpen("StorePro");
            context.AddField("P_STAFF").Value = Request.QueryString["staff"];
            context.AddField("P_TOKEN").Value = Request.QueryString["token"];
            context.AddField("P_NEWTOKEN").Value = token;   //生成新Token
            context.AddField("P_DEPT", "String", "output", "4", null);
            context.AddField("P_STAFFNAME", "String", "output", "20", null);
            context.AddField("P_OPERCARDNO", "String", "output", "16", null);
            bool ok = context.ExecuteSP("SP_SSO_CHECKTOKEN");
            if (ok)
            {
                Session["token"] = token;
                string deptNo, staffName, operCardNo;
                deptNo = context.GetFieldValue("P_DEPT").ToString().Trim();
                staffName = context.GetFieldValue("P_STAFFNAME").ToString().Trim();
                operCardNo = context.GetFieldValue("P_OPERCARDNO").ToString().Trim();
                //ip地址
                String strIpAdr = "";
                if (Request.Headers["x-forwarded-for"] != null)
                    strIpAdr = Request.Headers["x-forwarded-for"].ToString();
                else
                    strIpAdr = Request.UserHostAddress;

                //从内部部门表中读取数据

                TD_M_INSIDEDEPARTTM tmTD_M_INSIDEDEPART = new TD_M_INSIDEDEPARTTM();
                TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
                tdoTD_M_INSIDEDEPARTIn.DEPARTNO = deptNo;
                TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTOut = tmTD_M_INSIDEDEPART.selByPK(context, tdoTD_M_INSIDEDEPARTIn);

                context.s_UserID = Request.QueryString["staff"];
                context.s_DepartID = deptNo;
               

                //记录登录日志
                SP_PR_LogonLogPDO pdo = new SP_PR_LogonLogPDO();
                pdo.IPADDR = strIpAdr;
                pdo.LOGONPAGE = "LogonSSO.aspx";
                pdo.OPERCARDNO = operCardNo;
                ok = TMStorePModule.Excute(context, pdo);
                if (!ok)
                {
                    return;
                }

                //设定向后传递的数据
                Hashtable hash = new Hashtable();
                hash.Add("UserID", Request.QueryString["staff"]);
                hash.Add("UserName", staffName);
                hash.Add("DepartID", deptNo);
                hash.Add("DepartName", tdoTD_M_INSIDEDEPARTOut.DEPARTNAME);
                hash.Add("CardID", operCardNo);

                hash.Add("RegionCode", tdoTD_M_INSIDEDEPARTOut.REGIONCODE);//部门的归属区域
                context.s_RegionCode = tdoTD_M_INSIDEDEPARTOut.REGIONCODE;//部门的归属区域

                String dtNow = DateTime.Now.Ticks.ToString();
                String prePasswd = Request.QueryString["staff"] + dtNow;
                String postPasswd = DecryptString.EncodeString(prePasswd);
                hash.Add("DateTime", dtNow);
                hash.Add("DecryptString", postPasswd);
                if (Request.QueryString["type"] == "test")
                    hash.Add("Debugging", "True");
                else
                    hash.Add("Debugging", "False");
                if (Request.QueryString["type"] == "admin")
                    hash.Add("LogonLevel", "Admin");
                else
                    hash.Add("LogonLevel", "Normal");
                Session["LogonInfo"] = hash;
                if (!string.IsNullOrEmpty(Request.QueryString["link"]))
                {
                    Transfer(Request.QueryString["link"]);
                }
                else
                {
                    Transfer("Default.aspx");
                }
            }
            else
            {
                //返回登录页面
                Response.Redirect(loginURL);
            }
        }
    }
}