/***************************************************************
 * TD_M_INSIDESTAFFTM
 * 类名:内部员工编码表TM
 * 变更日        姓名           摘要
 * ----------    -----------    --------------------------------
 * 2008/04/09    陈栋           初次做成
 ***************************************************************
 */
using TDO;
using DAO;
using TDO.UserManager;
using Master;
using System;

namespace TM.UserManager
{
    public class TD_M_INSIDESTAFFPARAMETERTM
    {
        public TD_M_INSIDESTAFFPARAMETERTM()
        {

        }

        /************************************************************************
             * 从内部员工参数表中提取数据
             * @param CmnContext context         上下文环境
             * @param TD_M_INSIDESTAFFPARAMETERTDO a_ddoTD_M_INSIDESTAFFPARAMETERIn              内部员工参数表输入DDO
             * @return 		                     TD_M_INSIDESTAFFPARAMETERTDO
         ************************************************************************/
        public TD_M_INSIDESTAFFPARAMETERTDO selByPK(CmnContext context, TD_M_INSIDESTAFFPARAMETERTDO a_ddoTD_M_INSIDESTAFFPARAMETERIn)
        {

            TD_M_INSIDESTAFFPARAMETERTDO ddoTD_M_INSIDESTAFFPARAMETEROut;

            SelectDAO daoSelect = new SelectDAO();
            ddoTD_M_INSIDESTAFFPARAMETEROut = (TD_M_INSIDESTAFFPARAMETERTDO)daoSelect.selDDO(context, a_ddoTD_M_INSIDESTAFFPARAMETERIn, "TD_M_INSIDESTAFFPARAMETER", typeof(TD_M_INSIDESTAFFPARAMETERTDO));

            return ddoTD_M_INSIDESTAFFPARAMETEROut;
        }

        /************************************************************************
             * 增加内部员工参数表中数据
             * @param CmnContext context         上下文环境
             * @param TD_M_INSIDESTAFFPARAMETERTDO a_ddoTD_M_INSIDESTAFFPARAMETERIn              内部员工参数表输入DDO
             * @return 		                     TD_M_INSIDESTAFFPARAMETERTDO
         ************************************************************************/

        public int insAdd(CmnContext context, TD_M_INSIDESTAFFPARAMETERTDO a_ddoTD_M_INSIDESTAFFPARAMETERIn)
        {
            InsertScene insertScene = new InsertScene();
            return insertScene.Execute(context, a_ddoTD_M_INSIDESTAFFPARAMETERIn);
        }

        /************************************************************************
             * 修改内部员工参数表中数据
             * @param CmnContext context         上下文环境
             * @param TD_M_INSIDESTAFFPARAMETERTDO a_ddoTD_M_INSIDESTAFFPARAMETERIn              内部员工参数表输入DDO
             * @return 		                     TD_M_INSIDESTAFFPARAMETERTDO
         ************************************************************************/
        public int updRecord(CmnContext context, TD_M_INSIDESTAFFPARAMETERTDO a_ddoTD_M_INSIDESTAFFPARAMETERIn)
        {
            UpdateScene updateScene = new UpdateScene();
            return updateScene.Execute(context, a_ddoTD_M_INSIDESTAFFPARAMETERIn);
        }

        /************************************************************************
             * 删除内部员工参数表中数据
             * @param CmnContext context         上下文环境
             * @param TD_M_INSIDESTAFFPARAMETERTDO a_ddoTD_M_INSIDESTAFFPARAMETERIn              内部员工参数表输入DDO
             * @return 		                     TD_M_INSIDESTAFFPARAMETERTDO
         ************************************************************************/

        public int delDelete(CmnContext context, TD_M_INSIDESTAFFPARAMETERTDO a_ddoTD_M_INSIDESTAFFPARAMETERIn)
        {
            DeleteScene deleteScene = new DeleteScene();
            return deleteScene.Execute(context, a_ddoTD_M_INSIDESTAFFPARAMETERIn, "DELETE_TD_M_INSIDESTAFFPARAMETER");
        }

    }
}
