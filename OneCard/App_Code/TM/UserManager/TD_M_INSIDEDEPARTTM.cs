/***************************************************************
 * TD_M_INSIDEDEPART_TM
 * 类名:内部部门编码表TM
 * 变更日        姓名           摘要
 * ----------    -----------    --------------------------------
 * 2008/02/28    方剑           初次做成
 ***************************************************************
 */
using System;
using System.Data;
using TDO;
using DAO;
using TDO.UserManager;
using Master;

namespace TM.UserManager
{
    public class TD_M_INSIDEDEPARTTM
    {
        public TD_M_INSIDEDEPARTTM()
        {

        }

        /************************************************************************
         * 从内部部门编码表中提取数据
         * @param CmnContext context         上下文环境
         * @param TD_M_INSIDEDEPARTTDO a_ddoTD_M_INSIDEDEPARTIn              内部部门编码表输入DDO
         * @return 		                     TD_M_INSIDEDEPARTTDO
         ************************************************************************/
        public TD_M_INSIDEDEPARTTDO selByPK(CmnContext context, TD_M_INSIDEDEPARTTDO a_ddoTD_M_INSIDEDEPARTIn)
        {

            TD_M_INSIDEDEPARTTDO ddoTD_M_INSIDEDEPARTOut;

            SelectDAO daoSelect = new SelectDAO();
            ddoTD_M_INSIDEDEPARTOut = (TD_M_INSIDEDEPARTTDO)daoSelect.selDDO(context, a_ddoTD_M_INSIDEDEPARTIn, "TD_M_INSIDEDEPART", typeof(TD_M_INSIDEDEPARTTDO));

            if (ddoTD_M_INSIDEDEPARTOut == null)
            {
                context.AppException("S100001001");
            }

            return ddoTD_M_INSIDEDEPARTOut;
        }

        /************************************************************************
         *增加内部部门编码表中数据
         * @param CmnContext context         上下文环境
         * @param TD_M_INSIDEDEPARTTDO a_ddoTD_M_INSIDEDEPARTIn              内部部门编码表输入DDO
         * @return 		                    
         ************************************************************************/

        public int insAdd(CmnContext context, TD_M_INSIDEDEPARTTDO a_ddoTD_M_INSIDEDEPARTIn)
        {
            InsertScene insertScene = new InsertScene();
            return insertScene.Execute(context, a_ddoTD_M_INSIDEDEPARTIn);
        }

        /************************************************************************
         * 修改内部部门编码表中的数据
         * @param CmnContext context         上下文环境
         * @param TD_M_INSIDESTAFFTDO a_ddoTD_M_INSIDESTAFFIn              内部员工编码表输入DDO
         * @return 		                     
         ************************************************************************/

        public int updRecord(CmnContext context, TD_M_INSIDEDEPARTTDO a_ddoTD_M_INSIDEDEPARTIn)
        {
            UpdateScene updateScene = new UpdateScene();
            return updateScene.Execute(context, a_ddoTD_M_INSIDEDEPARTIn);
        }

        /************************************************************************
         * 删除内部部门编码表中的数据
         * @param CmnContext context         上下文环境
         * @param TD_M_INSIDEDEPARTTDO a_ddoTD_M_INSIDEDEPARTIn              内部部门编码表输入DDO
         * @return 		                     
         ************************************************************************/

        public int delDelete(CmnContext context, TD_M_INSIDEDEPARTTDO a_ddoTD_M_INSIDEDEPARTIn)
        {
            DeleteScene deleteScene = new DeleteScene();
            return deleteScene.Execute(context, a_ddoTD_M_INSIDEDEPARTIn, "DELETE_TD_M_INSIDEDEPART");
        }
    }
}

