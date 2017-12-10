/***************************************************************
 * TMTableModule
 * 类名:TM表模板类（适用于简单型的TM，只是提取数据）
 * 变更日        姓名           摘要
 * ----------    -----------    --------------------------------
 * 2008/02/29    方剑           初次做成
 ***************************************************************
 */
using System;
using System.Data;
using DAO;
using Master;

namespace TM
{
    public class TMTableModule
    {
        public TMTableModule()
        {

        }

        /************************************************************************
         * 从表中提取数据
         * @param CmnContext context         上下文环境
         * @param DDOBase a_ddoDDOBaseIn     表输入DDO
         * @param Type type                  DDO的类型
         * @param TString errCode            错误编码 errCode为null时，不做表记录为空的判断
         * @return 		                     DataTable
         ************************************************************************/
        public DataTable selByPKDataTable(CmnContext context, DDOBase a_ddoDDOBaseIn, String errCode)
        {
            return selByPKDataTable(context, a_ddoDDOBaseIn, errCode, null,0);
        }

        public DataTable selByPKDataTable(CmnContext context, DDOBase a_ddoDDOBaseIn, String errCode, String strSql,int countsize)
        {
            return selByPKDataTable(context, a_ddoDDOBaseIn, errCode, a_ddoDDOBaseIn.TableName, strSql, countsize);
        }

        public DataTable selByPKDataTable(CmnContext context, String strSql, int countsize)
        {
            return selByPKDataTable(context, null, null, null, strSql, countsize);
        }

        public DataTable selByPKDataTable(CmnContext context, DDOBase a_ddoDDOBaseIn, String errCode,String strSqlKey, String strSql, int countsize)
        {

            SelectDAO daoSelect = new SelectDAO();
            DataTable data = daoSelect.selDataTable(context, a_ddoDDOBaseIn, strSqlKey, strSql, countsize);

            if (data == null || data.Rows.Count == 0)
            {
                if (errCode != null)
                    context.AppException(errCode);
            }

            return data;
        }

        /************************************************************************
         * 从表中提取数据
         * @param CmnContext context         上下文环境
         * @param DDOBase a_ddoDDOBaseIn     表输入DDO
         * @param Type type                  DDO的类型
         * @param TString errCode            错误编码 errCode为null时，不做表记录为空的判断
         * @return 		                     表数组
         ************************************************************************/
        public Object selByPKArr(CmnContext context, DDOBase a_ddoDDOBaseIn, String errCode)
        {
            return selByPKArr(context, a_ddoDDOBaseIn, a_ddoDDOBaseIn.GetType(), errCode, null);
        }

        public Object selByPKArr(CmnContext context, DDOBase a_ddoDDOBaseIn,Type type,String errCode)
        {
            return selByPKArr(context, a_ddoDDOBaseIn, type, errCode, null);
        }

        public Object selByPKArr(CmnContext context, DDOBase a_ddoDDOBaseIn, Type type, String errCode, String strSql)
        {
            return selByPKArr(context, a_ddoDDOBaseIn, type, errCode, a_ddoDDOBaseIn.TableName, strSql);
        }

        public Object selByPKArr(CmnContext context, DDOBase a_ddoDDOBaseIn, Type type, String errCode,String strSqlKey, String strSql)
        {

            SelectDAO daoSelect = new SelectDAO();
            Object objArr = daoSelect.selDDOArr(context, a_ddoDDOBaseIn, strSqlKey, type, strSql);
            DDOBase[] ddoDDOBaseOutArr = (DDOBase[])objArr;

            if (objArr == null || ddoDDOBaseOutArr.Length == 0)
            {
                if (errCode != null)
                    context.AppException(errCode);
            }

            return objArr;
        }

        /************************************************************************
         * 从表中提取数据
         * @param CmnContext context         上下文环境
         * @param DDOBase a_ddoDDOBaseIn     表输入DDO
         * @param Type type                  DDO的类型
         * @param TString errCode            错误编码 errCode为null时，不做表记录为空的判断
         * @return 		                     表数据
         ************************************************************************/
        public Object selByPK(CmnContext context, DDOBase a_ddoDDOBaseIn, Type type, String errCode)
        {
            return selByPK(context, a_ddoDDOBaseIn, type, errCode, null);
        }

        public Object selByPK(CmnContext context, DDOBase a_ddoDDOBaseIn, Type type, String errCode, String strSql)
        {
            return selByPK(context, a_ddoDDOBaseIn, type, errCode, a_ddoDDOBaseIn.TableName, strSql);
        }

        public Object selByPK(CmnContext context, DDOBase a_ddoDDOBaseIn, Type type, String errCode,String strSqlKey, String strSql)
        {

            SelectDAO daoSelect = new SelectDAO();
            DDOBase ddoDDOBaseOut = daoSelect.selDDO(context, a_ddoDDOBaseIn, strSqlKey, type, strSql);

            if (ddoDDOBaseOut == null)
            {
                if (errCode != null)
                    context.AppException(errCode);
            }

            return ddoDDOBaseOut;
        }


    }
}



