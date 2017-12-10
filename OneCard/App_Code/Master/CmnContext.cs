/***************************************************************
 * CmnContext
 * 类名:上下文类，用于在Application生存周期传递数据
 * 变更日        姓名           摘要
 * ----------    -----------    --------------------------------
 * 2008/01/09    方剑           初次做成
 ***************************************************************
 */
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
using System.Data.OleDb;
using System.Resources;
using System.Globalization;
using System.Drawing;
using Common;
using System.Data.OracleClient;

namespace Master
{
    public class CmnContext
    {
        public String s_UserID;
        public String s_UserName;
        public String s_DepartID;
        public String s_DepartName;
        public String s_CardID;
        public String s_RegionCode;//归属区域

        public Boolean s_Debugging = false;

        private DBConnection dBConnection = new DBConnection();

        private String dataBaseType;
        public String DataBaseType
        {
            get { return dataBaseType; }
            set { dataBaseType = value; }
        }

        private String resourcePath;
        public String ResourcePath
        {
            get { return resourcePath; }
            set { resourcePath = value; }
        }

        private HttpServerUtility  httpServer;
        public HttpServerUtility  HttpServer
        {
            get { return httpServer; }
            set { httpServer = value; }
        }
	

        private HttpResponse httpResponse;
        public HttpResponse Response
        {
            get { return httpResponse; }
            set { httpResponse = value; }
        }

        private String pageName;
        public String PageName
        {
            get { return pageName; }
            set { pageName = value; }
        }

        private ArrayList errorMessages = new ArrayList();
        public ArrayList ErrorMessage
        {
            get { return errorMessages; }
            set { errorMessages = value; }
        }
        private ArrayList normalMessages = new ArrayList();
        public ArrayList NormalMessages
        {
            get { return normalMessages; }
            set { normalMessages = value; }
        }

        private ArrayList controlUniqueIDs = new ArrayList();
        public ArrayList ControlUniqueIDs
        {
            get { return controlUniqueIDs; }
            set { controlUniqueIDs = value; }
        }

        private Hashtable outputValues;
        public Hashtable OutputValues
        {
            get { return outputValues; }
            set { outputValues = value; }
        }

        /************************************************************************
         * 检查是否有错误
         * @return 		                     有错误：true  无错误：false
         ************************************************************************/
        public Boolean hasError()
        {
            if (errorMessages.Count > 0)
                return true;
            else
                return false;
        }

        /************************************************************************
         * 根据UrlKey在UrlConfig资源文件中找到相应的URL
         * @param String urlKey              Url的Key值
         * @return 		                     Url
         ************************************************************************/
        public String GetUrl(String urlKey)
        {
            try
            {
                String Url = DealString.GetResourceValue(resourcePath, "UrlConfig", urlKey);
                if (Url != null) return Url;
            }
            catch (System.IO.FileNotFoundException)
            {
            }
            return urlKey;
       }


        /************************************************************************
         * 抛出异常 
         * @param String errorCode           错误编码
         * @return 		                     
         ************************************************************************/
        public void AppException(String errorCode)
        {
            //根据错误编码从错误信息资源文件中找到错误信息
            //String strMsg = DealString.GetResourceValue(resourcePath, "ErrorMessage", errorCode);

            //if (strMsg == null)
            //    throw new Exception(errorCode);
            //else
            //    throw new Exception(errorCode + "=" + strMsg);

            AddError(errorCode, null);
        }

        /************************************************************************
         * 记录消息 
         * @param String msgCode           消息编码
         * @return 		                     
         ************************************************************************/
        public void AddMessage(String msgCode)
        {
            string shortCode;
            // 取msgCode的前10位
            if (msgCode.Length > 10)
            {
                shortCode = msgCode.Substring(0, 10);
            }
            else
            {
                shortCode = msgCode;
            }

            //根据错误编码从错误信息资源文件中找到错误信息
            String strMsg = DealString.GetResourceValue(resourcePath,
                "ErrorMessage", shortCode);

            if (strMsg == null || strMsg.Trim().Length == 0)
                normalMessages.Add(msgCode);
            else
                normalMessages.Add(shortCode + ": " + strMsg);
        }


        /************************************************************************
         * 记录错误 
         * @param String errorCode           错误编码
         * @return 		                     
         ************************************************************************/
        public void AddError(String errorCode)
        {
            AddError(errorCode, null);
        }

        /************************************************************************
         * 记录错误 
         * @param String errorCode           错误编码
         * @param WebControl control         错误的控件	
         * @return 		                     
         ************************************************************************/
        public void AddError(String errorCode, WebControl control)
        {
            string shortCode = errorCode;
            String strMsg = "";

            if (errorCode.Length == 10) //如果错误编码为10位
            {
                //根据错误编码从错误信息资源文件中找到错误信息
                strMsg = DealString.GetResourceValue(resourcePath,
                    "ErrorMessage", shortCode);

                strMsg = shortCode + ": " + strMsg;
            }
            else
            {
                strMsg = errorCode;
            }

            errorMessages.Add(strMsg);

            if (shortCode.Length > 0 && shortCode.Substring(0, 1).Equals("S"))
            {

                String errorMsg = pageName;
                if (errorMsg != null)
                {
                    errorMsg = "页面：" + errorMsg + " || " + strMsg;
                }

                Log.Error(errorMsg, null, "AppLog");
            }
            //如果是控件Validation时错误，将控件的背景色改成粉红色
            if (control != null)
            {
                control.BackColor = Color.FromArgb(255, 192, 192);
                controlUniqueIDs.Add(control.UniqueID);
            }
        }
        /************************************************************************
        * 更改错误控件的颜色 
        * 创建标识：石磊 2012-08-06
        * @param WebControl control         错误的控件	
        * @return 		                     
        ************************************************************************/
        public void AddErrorControl(WebControl control)
        {
            //如果是控件Validation时错误，将控件的背景色改成粉红色
            if (control != null)
            {
                control.BackColor = Color.FromArgb(255, 192, 192);
                controlUniqueIDs.Add(control.UniqueID);
            }
        }
        /************************************************************************
         * 回滚事务、关闭数据库、重定向自身页面
         * @return 		                     void
         ************************************************************************/
        public void RollBack()
        {
            dBConnection.RollBack();
            dBConnection.Close();            
        }

        /************************************************************************
         * 数据库打开
         * @param String cmdType             语句类型
         * @return 		                     void
         ************************************************************************/
        public void DBOpen(String cmdType)
        {
            dBConnection.Open(cmdType);
        }
        public void SPOpen()
        {
            dBConnection.Open("StorePro");
        }
        /************************************************************************
         * 提交事务，关闭数据库连接
         * @return 		                     void
         ************************************************************************/
        public void DBCommit()
        {
            dBConnection.Commit();
            dBConnection.Close();
        }

        /************************************************************************
         * 从数据库中读出数据、返回数据
         * @param String sql                 执行语句
         * @return 		                     DataTable
         ************************************************************************/
        public bool ExecuteSP(String spName)
        {
            AddField("p_currOper", "String", "input", "4", s_UserID);
            AddField("p_currDept", "String", "input", "6", s_DepartID);
            AddField("p_retCode", "String", "output", "10", null);
            AddField("p_retMsg", "String", "output", "127", null);

            ExecuteReader(spName);

            String retCode = "" + GetFieldValue("p_retCode");
            if (retCode != "0000000000")
            {
                AddError(retCode + ":" + GetFieldValue("p_retMsg"));
                Log.Error(retCode + ":" + GetFieldValue("p_retMsg"), null, "AppLog");
                return false;
            }

            return true;
        }

        public bool ExecuteSP(String spName,out string retCode)
        {
            AddField("p_currOper", "String", "input", "4", s_UserID);
            AddField("p_currDept", "String", "input", "6", s_DepartID);
            AddField("p_retCode", "String", "output", "10", null);
            AddField("p_retMsg", "String", "output", "127", null);

            ExecuteReader(spName);

            retCode = "" + GetFieldValue("p_retCode");
            if (retCode != "0000000000")
            {
                AddError(retCode + ":" + GetFieldValue("p_retMsg"));
                Log.Error(retCode + ":" + GetFieldValue("p_retMsg"), null, "AppLog");
                return false;
            }

            return true;
        }

        public DataTable ExecuteReader(String Sql)
        {
            return dBConnection.ExecuteReader(Sql);
        }

        /************************************************************************
         * 执行语句、返回影响的行数
         * @param String sql                 执行语句
         * @return 		                     int
         ************************************************************************/
        public int ExecuteNonQuery(String Sql)
        {
            return dBConnection.ExecuteNonQuery(Sql);
        }

        /************************************************************************
         * 从Command的Parameters对象中获取参数的值
         * @return 		                     ArrayList
         ************************************************************************/
        public OracleParameter GetField(String paramName)
        {
            return dBConnection.GetParameter(paramName);
        }

        public object GetFieldValue(String paramName)
        {
            return dBConnection.GetParameterValue(paramName);
        }

        public void SetFieldValue(String paramName, object value)
        {
            dBConnection.SetParameterValue(paramName, value);
        }
        public ArrayList GetDBParameter()
        {
            return dBConnection.GetDBParameter();
        }

        /************************************************************************
         * 为Command的对象添加DB参数
         * @param String typeName            参数类型
         * @param String columnName          参数名
         * @param String columnValue         参数值
         * @return 		                     void
         ************************************************************************/
        public void AddDBParameter(String typeName, String columnName, String columnValue)
        {
            AddDBParameter(typeName, columnName, columnValue,"", "Input");
        }

        /************************************************************************
         * 为Command的对象添加DB参数
         * @param String typeName            参数类型
         * @param String columnName          参数名
         * @param String columnValue         参数值
         * @return 		                     void
         ************************************************************************/
        public OracleParameter AddField(String columnName)
        {
            return AddDBParameter("String", columnName, null, "", "input");
        }
        public OracleParameter AddField(String columnName, String typeName)
        {
            return AddDBParameter(typeName, columnName, null, "", "input");
        }
        public OracleParameter AddField(String columnName, String typeName, String paraType)
        {
            return AddDBParameter(typeName, columnName, null, "", paraType);
        }

        public OracleParameter AddField(String columnName, String typeName, String paraType, String columnLen)
        {
            return AddDBParameter(typeName, columnName, null, columnLen, paraType);
        }

        public OracleParameter AddField(String columnName, String typeName, String paraType, String columnLen, String columnValue)
        {
            return AddDBParameter(typeName, columnName, columnValue, columnLen, paraType);
        }

        public OracleParameter AddDBParameter(String typeName, String columnName, String columnValue, String columnLen, String paraType)
        {
            return dBConnection.AddDBParameter(typeName, columnName, columnValue,columnLen,paraType);
        }

        public CmnContext()
        {

        }
    }
}
