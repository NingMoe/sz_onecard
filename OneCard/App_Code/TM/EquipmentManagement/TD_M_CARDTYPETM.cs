using TDO;
using DAO;
using TDO.ResourceManager;
using TDO.CardManager;
using Master;
using System;

namespace TM.EquipmentManagement
{
    public class TD_M_CARDTYPETM
    {
        public TD_M_CARDTYPETM()
        {

        }

        /************************************************************************
         * 判断卡类型编码是否已存在
         * @param CmnContext context         上下文环境
         * @param TD_M_CARDTYPETDO a_ddoTD_M_CARDTYPEIn              卡类型编码表输入DDO
         * @return 		                     
         ************************************************************************/
        public bool chkCardType(CmnContext context, TD_M_CARDTYPETDO a_ddoTD_M_CARDTYPEIn)
        {
            SelectDAO daoSelect = new SelectDAO();
            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)daoSelect.selDDO(context, a_ddoTD_M_CARDTYPEIn, "TD_M_CARDTYPE_CODE", typeof(TD_M_CARDTYPETDO));

            //判断是否存在该卡类型编码
            if (ddoTD_M_CARDTYPEOut != null)
                return false;
            else
                return true;
        }

        /************************************************************************
         *增加卡类型编码表中数据
         * @param CmnContext context         上下文环境
         * @param TD_M_CARDTYPETDO a_ddoTD_M_CARDTYPEIn              卡类型编码表输入DDO
         * @return 		                    
         ************************************************************************/
        public int insAdd(CmnContext context, TD_M_CARDTYPETDO a_ddoTD_M_CARDTYPEIn)
        {
            InsertScene insertScene = new InsertScene();
            return insertScene.Execute(context, a_ddoTD_M_CARDTYPEIn);
        }

        /************************************************************************
         * 修改卡类型编码表中的数据
         * @param CmnContext context         上下文环境
         * @param TD_M_CARDTYPETDO a_ddoTD_M_CARDTYPEIn              卡类型编码表输入DDO
         * @return 		                     修改的记录行数
         ************************************************************************/
        public int updRecord(CmnContext context, TD_M_CARDTYPETDO a_ddoTD_M_CARDTYPEIn)
        {
            UpdateScene updateScene = new UpdateScene();
            return updateScene.Execute(context, a_ddoTD_M_CARDTYPEIn);
        }
    }
}
