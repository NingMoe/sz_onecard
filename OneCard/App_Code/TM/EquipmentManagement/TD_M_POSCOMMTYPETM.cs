using TDO;
using DAO;
using TDO.ResourceManager;
using TDO.CardManager;
using Master;
using System;

namespace TM.EquipmentManagement
{
    public class TD_M_POSCOMMTYPETM
    {
        public TD_M_POSCOMMTYPETM()
        {

        }

        /************************************************************************
         * 判断通信类型编码是否已存在
         * @param CmnContext context         上下文环境
         * @param TD_M_POSCOMMTYPETDO a_ddoTD_M_POSCOMMTYPEIn              通信类型编码表输入DDO
         * @return 		                     
         ************************************************************************/
        public bool chkCommType(CmnContext context, TD_M_POSCOMMTYPETDO a_ddoTD_M_POSCOMMTYPEIn)
        {
            SelectDAO daoSelect = new SelectDAO();
            TD_M_POSCOMMTYPETDO ddoTD_M_POSCOMMTYPEOut = (TD_M_POSCOMMTYPETDO)daoSelect.selDDO(context, a_ddoTD_M_POSCOMMTYPEIn, "TD_M_POSCOMMTYPE_CODE", typeof(TD_M_POSCOMMTYPETDO));

            //判断是否存在该通信类型编码
            if (ddoTD_M_POSCOMMTYPEOut != null)
                return false;
            else
                return true;
        }

        /************************************************************************
         *增加通信类型编码表中数据
         * @param CmnContext context         上下文环境
         * @param TD_M_POSCOMMTYPETDO a_ddoTD_M_POSCOMMTYPEIn              通信类型编码表输入DDO
         * @return 		                    
         ************************************************************************/
        public int insAdd(CmnContext context, TD_M_POSCOMMTYPETDO a_ddoTD_M_POSCOMMTYPEIn)
        {
            InsertScene insertScene = new InsertScene();
            return insertScene.Execute(context, a_ddoTD_M_POSCOMMTYPEIn);
        }

        /************************************************************************
         * 修改通信类型编码表中的数据
         * @param CmnContext context         上下文环境
         * @param TD_M_POSCOMMTYPETDO a_ddoTD_M_POSCOMMTYPEIn              通信类型编码表输入DDO
         * @return 		                     修改的记录行数
         ************************************************************************/
        public int updRecord(CmnContext context, TD_M_POSCOMMTYPETDO a_ddoTD_M_POSCOMMTYPEIn)
        {
            UpdateScene updateScene = new UpdateScene();
            return updateScene.Execute(context, a_ddoTD_M_POSCOMMTYPEIn);
        }
    }
}
