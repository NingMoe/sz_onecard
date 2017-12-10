using TDO;
using DAO;
using TDO.ResourceManager;
using TDO.CardManager;
using Master;
using System;

namespace TM.EquipmentManagement
{
    public class TD_M_MANUTM
    {
        public TD_M_MANUTM()
        {
             
        }

        /************************************************************************
         * 判断卡片厂商编码是否已存在
         * @param CmnContext context         上下文环境
         * @param TD_M_MANUTDO a_ddoTD_M_MANUIn              卡片厂商编码表输入DDO
         * @return 		                     
         ************************************************************************/
        public bool chkCardManu(CmnContext context, TD_M_MANUTDO a_ddoTD_M_MANUIn)
        {
            SelectDAO daoSelect = new SelectDAO();
            TD_M_MANUTDO ddoTD_M_MANUOut = (TD_M_MANUTDO)daoSelect.selDDO(context, a_ddoTD_M_MANUIn, "TD_M_MANU_CODE", typeof(TD_M_MANUTDO));

            //判断是否存在该卡片厂商编码
            if (ddoTD_M_MANUOut != null)
            {
                context.AddError("A006112020");
                return false;
            }
            else
                return true;
        }

        /************************************************************************
         *增加卡片厂商编码表中数据
         * @param CmnContext context         上下文环境
         * @param TD_M_MANUTDO a_ddoTD_M_MANUIn              卡片厂商编码表输入DDO
         * @return 		                    
         ************************************************************************/
        public int insAdd(CmnContext context, TD_M_MANUTDO a_ddoTD_M_MANUIn)
        {
            InsertScene insertScene = new InsertScene();
            return insertScene.Execute(context, a_ddoTD_M_MANUIn);
        }

        /************************************************************************
         * 修改卡片厂商编码表中的数据
         * @param CmnContext context         上下文环境
         * @param TD_M_MANUTDO a_ddoTD_M_MANUIn              卡片厂商编码表输入DDO
         * @return 		                     修改的记录行数
         ************************************************************************/
        public int updRecord(CmnContext context, TD_M_MANUTDO a_ddoTD_M_MANUIn)
        {
            UpdateScene updateScene = new UpdateScene();
            return updateScene.Execute(context, a_ddoTD_M_MANUIn);
        }
    }
}
