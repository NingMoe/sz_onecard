/***************************************************************
 * TMStorePModule
 * 类名:TM存储过程模板类
 * 变更日        姓名           摘要
 * ----------    -----------    --------------------------------
 * 2008/02/29    方剑           初次做成
 ***************************************************************
 */
using System;
using System.Data;
using DAO;
using Master;
using Common;

namespace TM
{
    public class TMStorePModule
    {
        public TMStorePModule()
        {

        }

        /************************************************************************
         * 执行存储过程
         * @param CmnContext context         上下文环境
         * @param DDOBase a_ddoDDOBaseIn     存储过程输入DDO
         * @param Type type                  DDO的类型
         * @return 		                     表数组
         ************************************************************************/
        public static bool Excute(CmnContext context, PDOBase pdo)
        {
            PDOBase pdoOut;
            return Excute(context, pdo, out pdoOut);
        }
        public static bool Excute(CmnContext context, PDOBase pdo, out PDOBase pdoOut)
        {
            pdo.currOper = context.s_UserID;
            pdo.currDept = context.s_DepartID;

            StoreProduceDAO daoStoreProduce = new StoreProduceDAO();
            pdoOut = (PDOBase)daoStoreProduce.Excute(context, pdo, pdo.GetType());
            if (pdoOut == null)
            {
//                context.AddError("S002P01006");
                //context.RollBack();
                return false;
            }

            if (pdoOut.retCode != "0000000000")
            {
                context.AddError(pdoOut.retCode + ":" + pdoOut.retMsg);
                Log.Error(pdoOut.retCode + ":" + pdoOut.retMsg, null, "AppLog");
                //context.RollBack();
                return false;
            }

            //context.DBCommit();
            return true;
        }

    }
}



