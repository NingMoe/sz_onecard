/***************************************************************
 * TD_M_MENUTM
 * 类名:菜单项编码表TM
 * 变更日        姓名           摘要
 * ----------    -----------    --------------------------------
 * 2008/02/28    方剑           初次做成
 ***************************************************************
 */
using TDO;
using DAO;
using TDO.UserManager;
using Master;

namespace TM.UserManager
{
    public class TD_M_MENUTM
    {
        public TD_M_MENUTM()
        {

        }

        /************************************************************************
         * 从菜单项编码表中提取数据
         * @param CmnContext context         上下文环境
         * @param TD_M_MENUTDO a_ddoTD_M_MENUIn              菜单项编码表输入DDO
         * @return 		                     TD_M_INSIDEDEPARTTDO
         ************************************************************************/
        public TD_M_MENUTDO[] selByPK(CmnContext context, DDOBase a_ddoDDOBaseIn)
        {

            TD_M_MENUTDO[] ddoTD_M_MENUOut;

            SelectDAO daoSelect = new SelectDAO();
            ddoTD_M_MENUOut = (TD_M_MENUTDO[])daoSelect.selDDOArr(context, a_ddoDDOBaseIn, "TD_M_MENU", typeof(TD_M_MENUTDO));

            return ddoTD_M_MENUOut;
        }

        /************************************************************************
         * 从菜单项编码表中提取数据
         * @param CmnContext context         上下文环境
         * @param TD_M_MENUTDO a_ddoTD_M_MENUIn              菜单项编码表输入DDO
         * @return 		                     TD_M_INSIDEDEPARTTDO
         ************************************************************************/
        public TD_M_MENUTDO[] selDefaultMenu(CmnContext context, DDOBase a_ddoDDOBaseIn)
        {

            TD_M_MENUTDO[] ddoTD_M_MENUOut;

            SelectDAO daoSelect = new SelectDAO();
            ddoTD_M_MENUOut = (TD_M_MENUTDO[])daoSelect.selDDOArr(context, a_ddoDDOBaseIn, "TD_M_MENUDEFAULT", typeof(TD_M_MENUTDO));

            return ddoTD_M_MENUOut;
        }

        /************************************************************************
         * 从菜单项编码表中提取快捷菜单的数据
         * @param CmnContext context         上下文环境
         * @param TD_M_MENUTDO a_ddoTD_M_MENUIn              菜单项编码表输入DDO
         * @return 		                     TD_M_INSIDEDEPARTTDO
         ************************************************************************/
        public TD_M_MENUTDO[] selPopupMenu(CmnContext context, DDOBase a_ddoDDOBaseIn)
        {

            TD_M_MENUTDO[] ddoTD_M_MENUOut;

            SelectDAO daoSelect = new SelectDAO();
            ddoTD_M_MENUOut = (TD_M_MENUTDO[])daoSelect.selDDOArr(context, a_ddoDDOBaseIn, "TD_M_MENUPOPUP", typeof(TD_M_MENUTDO));

            return ddoTD_M_MENUOut;
        }

        /************************************************************************
         * 判断该用户是否有打开快捷菜单的权限
         * @param CmnContext context         上下文环境
         * @param TD_M_MENUTDO a_ddoTD_M_MENUIn              菜单项编码表输入DDO
         * @return 		                     true :有   false:无
         ************************************************************************/
        public bool hasPopupMenu(CmnContext context, DDOBase a_ddoDDOBaseIn)
        {
            TD_M_MENUTDO[] ddoTD_M_MENUOut;

            SelectDAO daoSelect = new SelectDAO();
            ddoTD_M_MENUOut = (TD_M_MENUTDO[])daoSelect.selDDOArr(context, a_ddoDDOBaseIn, "TD_M_MENUPOPUPPOWER", typeof(TD_M_MENUTDO));
            if (ddoTD_M_MENUOut.Length == 0)
                return false;
            else
                return true;

        }
        
    }
}

