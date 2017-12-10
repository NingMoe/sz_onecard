using TDO;
using DAO;
using TDO.ResourceManager;
using TDO.CardManager;
using Master;
using System;

namespace TM.EquipmentManagement
{
    public class TD_M_CARDSURFACETM
    {
        public TD_M_CARDSURFACETM()
        {

        }

        /************************************************************************
         * 判断卡面类型编码是否已存在
         * @param CmnContext context         上下文环境
         * @param TD_M_CARDSURFACETDO a_ddoTD_M_CARDSURFACEIn              卡面类型编码表输入DDO
         * @return 		                     
         ************************************************************************/
        public bool chkCardSurface(CmnContext context, TD_M_CARDSURFACETDO a_ddoTD_M_CARDSURFACEIn)
        {
            SelectDAO daoSelect = new SelectDAO();
            TD_M_CARDSURFACETDO ddoTD_M_CARDSURFACEOut = (TD_M_CARDSURFACETDO)daoSelect.selDDO(context, a_ddoTD_M_CARDSURFACEIn, "TD_M_CARDSURFACE_CODE", typeof(TD_M_CARDSURFACETDO));

            //判断是否存在该卡面类型编码
            if (ddoTD_M_CARDSURFACEOut != null)
                return false;
            else
                return true;
        }

        /************************************************************************
         *增加卡面类型编码表中数据
         * @param CmnContext context         上下文环境
         * @param TD_M_CARDSURFACETDO a_ddoTD_M_CARDSURFACEIn              卡面类型编码表输入DDO
         * @return 		                    
         ************************************************************************/
        public int insAdd(CmnContext context, TD_M_CARDSURFACETDO a_ddoTD_M_CARDSURFACEIn)
        {
            InsertScene insertScene = new InsertScene();
            return insertScene.Execute(context, a_ddoTD_M_CARDSURFACEIn);
        }

        /************************************************************************
         * 修改卡面类型编码表中的数据
         * @param CmnContext context         上下文环境
         * @param TD_M_CARDSURFACETDO a_ddoTD_M_CARDSURFACEIn              卡面类型编码表输入DDO
         * @return 		                     修改的记录行数
         ************************************************************************/
        public int updRecord(CmnContext context, TD_M_CARDSURFACETDO a_ddoTD_M_CARDSURFACEIn)
        {
            UpdateScene updateScene = new UpdateScene();
            return updateScene.Execute(context, a_ddoTD_M_CARDSURFACEIn);
        }
    }
}
