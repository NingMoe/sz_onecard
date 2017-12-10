/***************************************************************
 * TD_M_ROLETM
 * 类名:角色编码表TM
 * 变更日        姓名           摘要
 * ----------    -----------    --------------------------------
 * 2008/04/02    陈栋           初次做成
 ***************************************************************
 */

using TDO;
using DAO;
using TDO.UserManager;
using Master;

namespace TM.UserManager
{
    public class TD_M_ROLETM
    {
        public TD_M_ROLETM()
        {
           
        }
        /************************************************************************
         * 从角色编码表中提取数据
         * @param CmnContext context         上下文环境
         * @param TD_M_ROLETDO a_ddoTD_M_ROLEIn              菜单项编码表输入DDO
         * @return 		                     TD_M_ROLETDO
         ************************************************************************/

        public TD_M_ROLETDO selByPK(CmnContext context, TD_M_ROLETDO a_ddoTD_M_ROLEIn)
        {

            TD_M_ROLETDO ddoTD_M_ROLEOut;

            SelectDAO daoSelect = new SelectDAO();
            ddoTD_M_ROLEOut = (TD_M_ROLETDO)daoSelect.selDDO(context, a_ddoTD_M_ROLEIn, "TD_M_ROLE", typeof(TD_M_ROLETDO));

            if (ddoTD_M_ROLEOut == null)
            {
                context.AppException("S100001002");
            }

            return ddoTD_M_ROLEOut;
        }

        /************************************************************************
         * 增加角色编码表中数据
         * @param CmnContext context         上下文环境
         * @param TD_M_ROLETDO a_ddoTD_M_ROLEIn              菜单项编码表输入DDO
         * @return 		                     
         ************************************************************************/

        public int insAdd(CmnContext context, TD_M_ROLETDO a_ddoTD_M_ROLEIn)
        {
            InsertScene insertScene = new InsertScene();
            return insertScene.Execute(context, a_ddoTD_M_ROLEIn);
        }

        /************************************************************************
         * 修改角色编码表中数据
         * @param CmnContext context         上下文环境
         * @param TD_M_ROLETDO a_ddoTD_M_ROLEIn              菜单项编码表输入DDO
         * @return 		                     
         ************************************************************************/

        public int updRecord(CmnContext context, TD_M_ROLETDO a_ddoTD_M_ROLEIn)
        {
            UpdateScene updateScene = new UpdateScene();
            return updateScene.Execute(context, a_ddoTD_M_ROLEIn);
        }

        /************************************************************************
        * 删除角色编码表中数据
        * @param CmnContext context         上下文环境
        * @param TD_M_ROLETDO a_ddoTD_M_ROLEIn              菜单项编码表输入DDO
        * @return 		                     
        ************************************************************************/

        public int delDelete(CmnContext context, TD_M_ROLETDO a_ddoTD_M_ROLEIn)
        {
            DeleteScene deleteScene = new DeleteScene();
            return deleteScene.Execute(context, a_ddoTD_M_ROLEIn, "DELETE_TD_M_ROLE");
        }
    }
}