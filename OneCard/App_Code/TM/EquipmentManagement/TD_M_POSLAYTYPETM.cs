using TDO;
using DAO;
using TDO.ResourceManager;
using TDO.CardManager;
using Master;
using System;

namespace TM.EquipmentManagement
{
    public class TD_M_POSLAYTYPETM
    {
        public TD_M_POSLAYTYPETM()
        {

        }

        /************************************************************************
         * 判断放置类型编码是否已存在
         * @param CmnContext context         上下文环境
         * @param TD_M_POSLAYTYPETDO a_ddoTD_M_POSLAYTYPEIn              放置类型编码表输入DDO
         * @return 		                     
         ************************************************************************/
        public bool chkLayType(CmnContext context, TD_M_POSLAYTYPETDO a_ddoTD_M_POSLAYTYPEIn)
        {
            SelectDAO daoSelect = new SelectDAO();
            TD_M_POSLAYTYPETDO ddoTD_M_POSLAYTYPEOut = (TD_M_POSLAYTYPETDO)daoSelect.selDDO(context, a_ddoTD_M_POSLAYTYPEIn, "TD_M_POSLAYTYPE_CODE", typeof(TD_M_POSLAYTYPETDO));

            //判断是否存在该放置类型编码
            if (ddoTD_M_POSLAYTYPEOut != null)
                return false;
            else
                return true;
        }

        /************************************************************************
         *增加放置类型编码表中数据
         * @param CmnContext context         上下文环境
         * @param TD_M_POSLAYTYPETDO a_ddoTD_M_POSLAYTYPEIn              放置类型编码表输入DDO
         * @return 		                    
         ************************************************************************/
        public int insAdd(CmnContext context, TD_M_POSLAYTYPETDO a_ddoTD_M_POSLAYTYPEIn)
        {
            InsertScene insertScene = new InsertScene();
            return insertScene.Execute(context, a_ddoTD_M_POSLAYTYPEIn);
        }

        /************************************************************************
         * 修改放置类型编码表中的数据
         * @param CmnContext context         上下文环境
         * @param TD_M_POSLAYTYPETDO a_ddoTD_M_POSLAYTYPEIn              放置类型编码表输入DDO
         * @return 		                     修改的记录行数
         ************************************************************************/
        public int updRecord(CmnContext context, TD_M_POSLAYTYPETDO a_ddoTD_M_POSLAYTYPEIn)
        {
            UpdateScene updateScene = new UpdateScene();
            return updateScene.Execute(context, a_ddoTD_M_POSLAYTYPEIn);
        }
    }
}
