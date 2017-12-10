/***************************************************************
 * TD_M_COSTYPETM
 * 类名:COS类型编码表TM
 * 变更日        姓名           摘要
 * ----------    -----------    --------------------------------
 * 2008/05/27    方剑           初次做成
 ***************************************************************
 */
using TDO;
using DAO;
using TDO.ResourceManager;
using Master;
using System;

namespace TM.EquipmentManagement
{
    public class TD_M_COSTYPETM
    {
        public TD_M_COSTYPETM()
        {

        }

        /************************************************************************
         * 判断COS类型编码是否已存在
         * @param CmnContext context         上下文环境
         * @param TD_M_COSTYPETDO a_ddoTD_M_COSTYPEIn              COS类型编码表输入DDO
         * @return 		                     
         ************************************************************************/
        public bool chkCosType(CmnContext context, TD_M_COSTYPETDO a_ddoTD_M_COSTYPEIn)
        {
            SelectDAO daoSelect = new SelectDAO();
            TD_M_COSTYPETDO ddoTD_M_COSTYPEOut = (TD_M_COSTYPETDO)daoSelect.selDDO(context, a_ddoTD_M_COSTYPEIn, "TD_M_COSTYPE_CODE", typeof(TD_M_COSTYPETDO));

            //判断是否存在该COS类型编码
            if (ddoTD_M_COSTYPEOut != null)
            {
                context.AddError("A006111050");
                return false;
            }else
                return true;
        }

        /************************************************************************
         *增加COS类型编码表中数据
         * @param CmnContext context         上下文环境
         * @param TD_M_COSTYPETDO a_ddoTD_M_COSTYPEIn              COS类型编码表输入DDO
         * @return 		                    
         ************************************************************************/
        public int insAdd(CmnContext context, TD_M_COSTYPETDO a_ddoTD_M_COSTYPEIn)
        {
            InsertScene insertScene = new InsertScene();
            return insertScene.Execute(context, a_ddoTD_M_COSTYPEIn);
        }

        /************************************************************************
         * 修改COS类型编码表中的数据
         * @param CmnContext context         上下文环境
         * @param TD_M_COSTYPETDO a_ddoTD_M_COSTYPEIn              COS类型编码表输入DDO
         * @return 		                     修改的记录行数
         ************************************************************************/
        public int updRecord(CmnContext context, TD_M_COSTYPETDO a_ddoTD_M_COSTYPEIn)
        {
            UpdateScene updateScene = new UpdateScene();
            return updateScene.Execute(context, a_ddoTD_M_COSTYPEIn);
        }
    }
}
