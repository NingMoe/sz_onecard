using TDO;
using DAO;
using TDO.ResourceManager;
using TDO.CardManager;
using Master;
using System;

namespace TM.EquipmentManagement
{
    public class TD_M_CARDCHIPTYPETM
    {
        public TD_M_CARDCHIPTYPETM()
        {

        }

        /************************************************************************
         * 判断卡芯片类型编码是否已存在
         * @param CmnContext context         上下文环境
         * @param TD_M_CARDCHIPTYPETDO a_ddoTD_M_CARDCHIPTYPEIn              卡芯片类型编码表输入DDO
         * @return  编码已存在时返回false                  
         ************************************************************************/
        public bool chkCardChipType(CmnContext context, TD_M_CARDCHIPTYPETDO a_ddoTD_M_CARDCHIPTYPEIn)
        {
            SelectDAO daoSelect = new SelectDAO();
            TD_M_CARDCHIPTYPETDO ddoTD_M_CARDCHIPTYPEOut = (TD_M_CARDCHIPTYPETDO)daoSelect.selDDO(context, a_ddoTD_M_CARDCHIPTYPEIn, "TD_M_CARDCHIPTYPE_CODE", typeof(TD_M_CARDCHIPTYPETDO));

            //判断是否存在该卡芯片类型编码
            if (ddoTD_M_CARDCHIPTYPEOut != null)
                return false;
            else
                return true;
        }

        /************************************************************************
         *增加卡芯片类型编码表中数据
         * @param CmnContext context         上下文环境
         * @param TD_M_CARDCHIPTYPETDO a_ddoTD_M_CARDCHIPTYPEIn              卡芯片类型编码表输入DDO
         * @return 		                    
         ************************************************************************/
        public int insAdd(CmnContext context, TD_M_CARDCHIPTYPETDO a_ddoTD_M_CARDCHIPTYPEIn)
        {
            InsertScene insertScene = new InsertScene();
            return insertScene.Execute(context, a_ddoTD_M_CARDCHIPTYPEIn);
        }

        /************************************************************************
         * 修改卡芯片类型编码表中的数据
         * @param CmnContext context         上下文环境
         * @param TD_M_CARDCHIPTYPETDO a_ddoTD_M_CARDCHIPTYPEIn              卡芯片类型编码表输入DDO
         * @return 		                     修改的记录行数
         ************************************************************************/
        public int updRecord(CmnContext context, TD_M_CARDCHIPTYPETDO a_ddoTD_M_CARDCHIPTYPEIn)
        {
            UpdateScene updateScene = new UpdateScene();
            return updateScene.Execute(context, a_ddoTD_M_CARDCHIPTYPEIn);
        }
    }
}
