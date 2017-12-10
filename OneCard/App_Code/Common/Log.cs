/***************************************************************
 * Log
 * 类名:日志处理类
 * 变更日        姓名           摘要
 * ----------    -----------    --------------------------------
 * 2008/01/09    方剑           初次做成
 ***************************************************************
 */
using System;
using System.Text;
using log4net;

namespace Common
{
    public class Log
    {
        private Log() { }
        private static ILog m_log;

        /************************************************************************
         * 初始化日志系统， 在系统运行开始初始化（Global.asax Application_Start内）
         * @return 		                     
         ************************************************************************/
        public static void Init()
        {
            log4net.Config.XmlConfigurator.Configure();
        }

        /************************************************************************
         * 记录信息日志
         * @param String message             信息
         * @param Type type                  操作类的类型	
         * @return 		                     
         ************************************************************************/
        public static void Info(String message, String LoggerName)
        {
            m_log = LogManager.GetLogger(LoggerName);
            m_log.Info(message);
        }

        /************************************************************************
         * 记录DEBUG日志
         * @param String message             DEBUG信息
         * @param Type type                  操作类的类型	
         * @return 		                     
         ************************************************************************/
        public static void Debug(String message, String LoggerName)
        {
            m_log = LogManager.GetLogger(LoggerName);
            m_log.Debug(message);
        }

        /************************************************************************
         * 记录错误日志
         * @param String message             错误信息
         * @param Type type                  操作类的类型	
         * @return 		                     
         ************************************************************************/
        public static void Error(String message, Exception ex, String LoggerName)
        {
            m_log = LogManager.GetLogger(LoggerName);
            m_log.Error(message, ex);
        }

        /************************************************************************
         * 记录告警日志
         * @param String message             告警信息
         * @param Type type                  操作类的类型	
         * @return 		                     
         ************************************************************************/
        public static void Warn(String message, Exception ex, String LoggerName)
        {
            m_log = LogManager.GetLogger(LoggerName);
            m_log.Warn(message, ex);
        }
    }
}