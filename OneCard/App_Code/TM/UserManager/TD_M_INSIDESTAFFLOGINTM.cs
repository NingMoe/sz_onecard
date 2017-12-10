/***************************************************************
 * TD_M_INSIDESTAFFLOGINTM
 * 类名:内部员工登录限制表TM
 * 变更日        姓名           摘要
 * ----------    -----------    --------------------------------
 * 2008/02/28    方剑           初次做成
 ***************************************************************
 */
using TDO;
using DAO;
using TDO.UserManager;
using Master;
using System;

namespace TM.UserManager
{
    public class TD_M_INSIDESTAFFLOGINTM
    {
        public TD_M_INSIDESTAFFLOGINTM()
        {

        }

        /************************************************************************
         * 在内部员工登录限制表中判断是否有限制
         * @param CmnContext context         上下文环境
         * @param TD_M_INSIDESTAFFLOGINTDO a_ddoTD_M_INSIDESTAFFLOGINIn              内部员工登录限制表DDO
         * @return 		                     TD_M_INSIDESTAFFLOGINTDO
         ************************************************************************/
        public bool isUsage(CmnContext context, TD_M_INSIDESTAFFLOGINTDO a_ddoTD_M_INSIDESTAFFLOGINIn)
        {

            TD_M_INSIDESTAFFLOGINTDO[] ddoTD_M_INSIDESTAFFLOGINOutArr;

            SelectDAO daoSelect = new SelectDAO();
            ddoTD_M_INSIDESTAFFLOGINOutArr = (TD_M_INSIDESTAFFLOGINTDO[])daoSelect.selDDOArr(context, a_ddoTD_M_INSIDESTAFFLOGINIn, "TD_M_INSIDESTAFFLOGIN", typeof(TD_M_INSIDESTAFFLOGINTDO));

            //当找不到相关记录时，表明不对该用户做限制
            if (ddoTD_M_INSIDESTAFFLOGINOutArr.Length == 0)
            {
                return true;
            }
            else
            {
                Boolean bIP = false;
                for (int index = 0; index < ddoTD_M_INSIDESTAFFLOGINOutArr.Length; index++)
                {
                    TD_M_INSIDESTAFFLOGINTDO ddoTD_M_INSIDESTAFFLOGINOut = ddoTD_M_INSIDESTAFFLOGINOutArr[index];

                    //判断限制是否有效
                    if (ddoTD_M_INSIDESTAFFLOGINOut.VALIDTAG == "0")
                        continue;

                    //判断是否在有效日期之内

                    String strToday = DateTime.Now.Date.ToString("yyyyMMdd");
                    if (strToday.CompareTo(ddoTD_M_INSIDESTAFFLOGINOut.STARTDATE) < 0
                        || strToday.CompareTo(ddoTD_M_INSIDESTAFFLOGINOut.ENDDATE) > 0)
                    {
                        continue;
                    }

                    //判断是否在有效时间之内

                    String strNow = DateTime.Now.ToString("HHmmss");
                    if (strNow.CompareTo(ddoTD_M_INSIDESTAFFLOGINOut.STARTTIME) < 0
                        || strNow.CompareTo(ddoTD_M_INSIDESTAFFLOGINOut.ENDTIME) > 0)
                    {
                        continue;
                    }

                    //判断IP地址是否符合
                    if (ddoTD_M_INSIDESTAFFLOGINOut.IPADDR.Trim() != a_ddoTD_M_INSIDESTAFFLOGINIn.IPADDR.Trim())
                    {
                        continue;
                    }

                    bIP = true;
                    break;
                }

                if (!bIP)
                {
                    context.AddError("A100001006");
                    return false;
                }
            }

            return true;
        }

        /************************************************************************
         *增加内部员工登录限制表中数据
         * @param CmnContext context         上下文环境
         * @param TD_M_INSIDESTAFFLOGINTDO a_ddoTD_M_INSIDESTAFFLOGINIn              
         * @return 		                    
         ************************************************************************/

        public int insAdd(CmnContext context, TD_M_INSIDESTAFFLOGINTDO a_ddoTD_M_INSIDESTAFFLOGINIn)
        {
            InsertScene insertScene = new InsertScene();
            return insertScene.Execute(context, a_ddoTD_M_INSIDESTAFFLOGINIn);
        }

        /************************************************************************
         *修改内部员工登录限制表中数据
         * @param CmnContext context         上下文环境
         * @param TD_M_INSIDESTAFFLOGINTDO a_ddoTD_M_INSIDESTAFFLOGINIn              
         * @return 		                    
         ************************************************************************/

        public int updRecord(CmnContext context, TD_M_INSIDESTAFFLOGINTDO a_ddoTD_M_INSIDESTAFFLOGINIn, TD_M_INSIDESTAFFLOGINTDO a_ddoTD_M_INSIDESTAFFLOGINOld)
        {
            UpdateScene updateScene = new UpdateScene();
            return updateScene.Execute(context, a_ddoTD_M_INSIDESTAFFLOGINIn, a_ddoTD_M_INSIDESTAFFLOGINOld,"");
        }

        /************************************************************************
         *删除内部员工登录限制表中数据
         * @param CmnContext context         上下文环境
         * @param TD_M_INSIDESTAFFLOGINTDO a_ddoTD_M_INSIDESTAFFLOGINIn              
         * @return 		                    
         ************************************************************************/
        public int delRecord(CmnContext context, TD_M_INSIDESTAFFLOGINTDO a_ddoTD_M_INSIDESTAFFLOGINIn)
        {
            DeleteScene delScene = new DeleteScene();
            return delScene.Execute(context, a_ddoTD_M_INSIDESTAFFLOGINIn, "DELETE_TD_M_INSIDESTAFFLOGIN");
        }

    }
}
