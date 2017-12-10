using TDO;
using DAO;
using TDO.ResourceManager;
using TDO.CardManager;
using Master;
using System;

namespace TM.EquipmentManagement
{
    public class TD_M_POSMANUTM
    {
        public TD_M_POSMANUTM()
        {

        }

        /************************************************************************
         * 判断POS厂商编码是否已存在
         * @param CmnContext context         上下文环境
         * @param TD_M_POSMANUTDO a_ddoTD_M_POSMANUIn              POS厂商编码表输入DDO
         * @return 		                     
         ************************************************************************/
        public bool chkPosManu(CmnContext context, TD_M_POSMANUTDO a_ddoTD_M_POSMANUIn)
        {
            SelectDAO daoSelect = new SelectDAO();
            TD_M_POSMANUTDO ddoTD_M_POSMANUOut = (TD_M_POSMANUTDO)daoSelect.selDDO(context, a_ddoTD_M_POSMANUIn, "TD_M_POSMANU_CODE", typeof(TD_M_POSMANUTDO));

            //判断是否存在该POS厂商编码
            if (ddoTD_M_POSMANUOut != null)
                return false;
            else
                return true;
        }

        /************************************************************************
         *增加POS厂商编码表中数据
         * @param CmnContext context         上下文环境
         * @param TD_M_POSMANUTDO a_ddoTD_M_POSMANUIn              POS厂商编码表输入DDO
         * @return 		                    
         ************************************************************************/
        public int insAdd(CmnContext context, TD_M_POSMANUTDO a_ddoTD_M_POSMANUIn)
        {
            InsertScene insertScene = new InsertScene();
            return insertScene.Execute(context, a_ddoTD_M_POSMANUIn);
        }

        /************************************************************************
         * 修改POS厂商编码表中的数据
         * @param CmnContext context         上下文环境
         * @param TD_M_POSMANUTDO a_ddoTD_M_POSMANUIn              POS厂商编码表输入DDO
         * @return 		                     修改的记录行数
         ************************************************************************/
        public int updRecord(CmnContext context, TD_M_POSMANUTDO a_ddoTD_M_POSMANUIn)
        {
            UpdateScene updateScene = new UpdateScene();
            return updateScene.Execute(context, a_ddoTD_M_POSMANUIn);
        }
    }
}
