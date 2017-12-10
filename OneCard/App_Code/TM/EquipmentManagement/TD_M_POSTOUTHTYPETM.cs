using TDO;
using DAO;
using TDO.ResourceManager;
using TDO.CardManager;
using Master;
using System;

namespace TM.EquipmentManagement
{
    public class TD_M_POSTOUCHTYPETM
    {
        public TD_M_POSTOUCHTYPETM()
        {

        }

        /************************************************************************
         * 判断接触类型编码是否已存在
         * @param CmnContext context         上下文环境
         * @param TD_M_POSTOUCHTYPETDO a_ddoTD_M_POSTOUCHTYPEIn              接触类型编码表输入DDO
         * @return 		                     
         ************************************************************************/
        public bool chkTouchType(CmnContext context, TD_M_POSTOUCHTYPETDO a_ddoTD_M_POSTOUCHTYPEIn)
        {
            SelectDAO daoSelect = new SelectDAO();
            TD_M_POSTOUCHTYPETDO ddoTD_M_POSTOUCHTYPEOut = (TD_M_POSTOUCHTYPETDO)daoSelect.selDDO(context, a_ddoTD_M_POSTOUCHTYPEIn, "TD_M_POSTOUCHTYPE_CODE", typeof(TD_M_POSTOUCHTYPETDO));

            //判断是否存在该接触类型编码
            if (ddoTD_M_POSTOUCHTYPEOut != null)
                return false;
            else
                return true;
        }

        /************************************************************************
         *增加接触类型编码表中数据
         * @param CmnContext context         上下文环境
         * @param TD_M_POSTOUCHTYPETDO a_ddoTD_M_POSTOUCHTYPEIn              接触类型编码表输入DDO
         * @return 		                    
         ************************************************************************/
        public int insAdd(CmnContext context, TD_M_POSTOUCHTYPETDO a_ddoTD_M_POSTOUCHTYPEIn)
        {
            InsertScene insertScene = new InsertScene();
            return insertScene.Execute(context, a_ddoTD_M_POSTOUCHTYPEIn);
        }

        /************************************************************************
         * 修改接触类型编码表中的数据
         * @param CmnContext context         上下文环境
         * @param TD_M_POSTOUCHTYPETDO a_ddoTD_M_POSTOUCHTYPEIn              接触类型编码表输入DDO
         * @return 		                     修改的记录行数
         ************************************************************************/
        public int updRecord(CmnContext context, TD_M_POSTOUCHTYPETDO a_ddoTD_M_POSTOUCHTYPEIn)
        {
            UpdateScene updateScene = new UpdateScene();
            return updateScene.Execute(context, a_ddoTD_M_POSTOUCHTYPEIn);
        }
    }
}
