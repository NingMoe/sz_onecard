/***************************************************************
 * TD_M_INSIDESTAFFTM
 * 类名:内部员工编码表TM
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
    public class TD_M_INSIDESTAFFTM
    {
        public TD_M_INSIDESTAFFTM()
        {

        }

        /************************************************************************
         * 从内部员工编码表中提取数据，并判断用户名、卡号、密码和有效性
         * @param CmnContext context         上下文环境
         * @param TD_M_INSIDESTAFFTDO a_ddoTD_M_INSIDESTAFFIn              内部员工编码表输入DDO
         * @return 		                     TD_M_INSIDEDEPARTTDO
         ************************************************************************/
        public TD_M_INSIDESTAFFTDO selByPK(CmnContext context, TD_M_INSIDESTAFFTDO a_ddoTD_M_INSIDESTAFFIn)
        {
            return selByPK(context, a_ddoTD_M_INSIDESTAFFIn, 1);
        }

        /************************************************************************
         * 从内部员工编码表中提取数据，并判断用户名、卡号、密码和有效性
         * @param CmnContext context         上下文环境
         * @param TD_M_INSIDESTAFFTDO a_ddoTD_M_INSIDESTAFFIn              内部员工编码表输入DDO
         * @param int Flag              0:不比较CardNo   1:比较CardNo
         * @return 		                     TD_M_INSIDEDEPARTTDO
         ************************************************************************/
        public TD_M_INSIDESTAFFTDO selByPK(CmnContext context, TD_M_INSIDESTAFFTDO a_ddoTD_M_INSIDESTAFFIn,int Flag)
        {

            TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFOut;

            SelectDAO daoSelect = new SelectDAO();
            ddoTD_M_INSIDESTAFFOut = (TD_M_INSIDESTAFFTDO)daoSelect.selDDO(context, a_ddoTD_M_INSIDESTAFFIn, "TD_M_INSIDESTAFF", typeof(TD_M_INSIDESTAFFTDO));

            //判断是否存在该员工

            if (ddoTD_M_INSIDESTAFFOut == null)
            {
                context.AddError("A100001003");
                return null;
            }

            if (Flag == 1)
            {
                //判断卡号是否匹配
                if (ddoTD_M_INSIDESTAFFOut.OPERCARDNO != a_ddoTD_M_INSIDESTAFFIn.OPERCARDNO)
                {
                    context.AddError("A100001008");
                    return null;
                }
            }

            //判断该用户是否有效

            if (ddoTD_M_INSIDESTAFFOut.DIMISSIONTAG != "1")
            {
                context.AddError("A100001007");
                return null;
            }

            return ddoTD_M_INSIDESTAFFOut;
        }

        /************************************************************************
         *增加内部员工编码表中数据
         * @param CmnContext context         上下文环境
         * @param TD_M_INSIDESTAFFTDO a_ddoTD_M_INSIDESTAFFIn              内部员工编码表输入DDO
         * @return 		                    
         ************************************************************************/

        public int insAdd(CmnContext context, TD_M_INSIDESTAFFTDO a_ddoTD_M_INSIDESTAFFIn)
        {
            InsertScene insertScene = new InsertScene();
            return insertScene.Execute(context, a_ddoTD_M_INSIDESTAFFIn);
        }

        /************************************************************************
         * 修改内部员工编码表中的数据
         * @param CmnContext context         上下文环境
         * @param TD_M_INSIDESTAFFTDO a_ddoTD_M_INSIDESTAFFIn              内部员工编码表输入DDO
         * @return 		                     修改的记录行数
         ************************************************************************/
        public int updRecord(CmnContext context, TD_M_INSIDESTAFFTDO a_ddoTD_M_INSIDESTAFFIn)
        {
            UpdateScene updateScene = new UpdateScene();
            return updateScene.Execute(context, a_ddoTD_M_INSIDESTAFFIn);
        }

        /************************************************************************
         * 检查员工密码
         * @param CmnContext context         上下文环境
         * @param TD_M_INSIDESTAFFTDO a_ddoTD_M_INSIDESTAFFIn              内部员工编码表输入DDO
         * @return 		                     Boolean
         ************************************************************************/
        public Boolean chkPassWD(CmnContext context, TD_M_INSIDESTAFFTDO a_ddoTD_M_INSIDESTAFFIn)
        {

            TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFOut;

            SelectDAO daoSelect = new SelectDAO();
            ddoTD_M_INSIDESTAFFOut = (TD_M_INSIDESTAFFTDO)daoSelect.selDDO(context, a_ddoTD_M_INSIDESTAFFIn, "TD_M_INSIDESTAFF", typeof(TD_M_INSIDESTAFFTDO));

            //判断是否存在该员工
            if (ddoTD_M_INSIDESTAFFOut == null)
            {
                context.AddError("A010001002");
                return false;
            }

            return true;
        }

        /************************************************************************
         * 删除内部员工编码表中的数据
         * @param CmnContext context         上下文环境
         * @param TD_M_INSIDESTAFFTDO a_ddoTD_M_INSIDESTAFFIn              内部员工编码表输入DDO
         * @return 		                     
         ************************************************************************/

        public int delDelete(CmnContext context, TD_M_INSIDESTAFFTDO a_ddoTD_M_INSIDESTAFFIn)
        {
            DeleteScene deleteScene = new DeleteScene();
            return deleteScene.Execute(context, a_ddoTD_M_INSIDESTAFFIn, "DELETE_TD_M_INSIDESTAFF");
        }
    }
}
