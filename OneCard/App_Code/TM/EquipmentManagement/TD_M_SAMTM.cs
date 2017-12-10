using TDO;
using DAO;
using TDO.ResourceManager;
using Master;
using System;

public class TD_M_SAMTM
{
	public TD_M_SAMTM()
	{
	}

    /************************************************************************
         * 判断充值SAM卡是否已存在

         * @param CmnContext context         上下文环境
         * @param TD_M_SAMTDO a_ddoTD_M_SAMIn              充值SAM卡表输入DDO
         * @return 		                     
         ************************************************************************/
        public bool chkSam(CmnContext context, TD_M_SAMTDO a_ddoTD_M_SAMIn)
        {
            SelectDAO daoSelect = new SelectDAO();
            TD_M_SAMTDO ddoTD_M_SAMOut = (TD_M_SAMTDO)daoSelect.selDDO(context, a_ddoTD_M_SAMIn, "TD_M_SAM_CODE", typeof(TD_M_SAMTDO));

            //判断是否存在该充值SAM卡
            if (ddoTD_M_SAMOut != null)
                return false;
            else
                return true;
        }

        /************************************************************************
         *增加充值SAM卡表中数据
         * @param CmnContext context         上下文环境
         * @param TD_M_SAMTDO a_ddoTD_M_SAMIn              充值SAM卡表输入DDO
         * @return 		                    
         ************************************************************************/
        public int insAdd(CmnContext context, TD_M_SAMTDO a_ddoTD_M_SAMIn)
        {
            InsertScene insertScene = new InsertScene();
            return insertScene.Execute(context, a_ddoTD_M_SAMIn);
        }

        /************************************************************************
         * 修改充值SAM卡表中的数据

         * @param CmnContext context         上下文环境
         * @param TD_M_SAMTDO a_ddoTD_M_SAMIn              充值SAM卡表输入DDO
         * @return 		                     修改的记录行数
         ************************************************************************/
        public int updRecord(CmnContext context, TD_M_SAMTDO a_ddoTD_M_SAMIn)
        {
            UpdateScene updateScene = new UpdateScene();
            return updateScene.Execute(context, a_ddoTD_M_SAMIn);
        }
    }

