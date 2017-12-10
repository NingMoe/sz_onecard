using TDO;
using DAO;
using TDO.ResourceManager;
using TDO.CardManager;
using Master;
using System;

namespace TM.EquipmentManagement
{
    public class TD_M_POSMODETM
    {
        public TD_M_POSMODETM()
        {

        }

        /************************************************************************
         * 判断POS型号编码是否已存在
         * @param CmnContext context         上下文环境
         * @param TD_M_POSMODETDO a_ddoTD_M_POSMODEIn              POS型号编码表输入DDO
         * @return 		                     
         ************************************************************************/
        public bool chkPosMode(CmnContext context, TD_M_POSMODETDO a_ddoTD_M_POSMODEIn)
        {
            SelectDAO daoSelect = new SelectDAO();
            TD_M_POSMODETDO ddoTD_M_POSMODEOut = (TD_M_POSMODETDO)daoSelect.selDDO(context, a_ddoTD_M_POSMODEIn, "TD_M_POSMODE_CODE", typeof(TD_M_POSMODETDO));

            //判断是否存在该POS型号编码
            if (ddoTD_M_POSMODEOut != null)
                return false;
            else
                return true;
        }

        /************************************************************************
         *增加POS型号编码表中数据
         * @param CmnContext context         上下文环境
         * @param TD_M_POSMODETDO a_ddoTD_M_POSMODEIn              POS型号编码表输入DDO
         * @return 		                    
         ************************************************************************/
        public int insAdd(CmnContext context, TD_M_POSMODETDO a_ddoTD_M_POSMODEIn)
        {
            InsertScene insertScene = new InsertScene();
            return insertScene.Execute(context, a_ddoTD_M_POSMODEIn);
        }

        /************************************************************************
         * 修改POS型号编码表中的数据
         * @param CmnContext context         上下文环境
         * @param TD_M_POSMODETDO a_ddoTD_M_POSMODEIn              POS型号编码表输入DDO
         * @return 		                     修改的记录行数
         ************************************************************************/
        public int updRecord(CmnContext context, TD_M_POSMODETDO a_ddoTD_M_POSMODEIn)
        {
            UpdateScene updateScene = new UpdateScene();
            return updateScene.Execute(context, a_ddoTD_M_POSMODEIn);
        }
    }
}
