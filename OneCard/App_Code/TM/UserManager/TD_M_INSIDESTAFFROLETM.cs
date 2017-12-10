/***************************************************************
 * TD_M_INSIDEDEPART_TM
 * 类名:内部部门编码表TM
 * 变更日        姓名           摘要
 * ----------    -----------    --------------------------------
 * 2008/04/07    陈栋           初次做成
 ***************************************************************
 */
using System;
using System.Data;
using TDO;
using DAO;
using TDO.UserManager;
using Master;

public class TD_M_INSIDESTAFFROLETM
{
	public TD_M_INSIDESTAFFROLETM()
	{
		
	}

    /************************************************************************
        * 从内部员工与角色对应表中提取数据
        * @param CmnContext context         上下文环境
        * @param TD_M_INSIDESTAFFROLETDO a_ddoTD_M_INSIDESTAFFROLEIn              内部部门编码表输入DDO
        * @return 		                     TD_M_INSIDESTAFFROLETDO
        ************************************************************************/
    public TD_M_INSIDESTAFFROLETDO selByPK(CmnContext context, TD_M_INSIDESTAFFROLETDO a_ddoTD_M_INSIDESTAFFROLEIn)
    {

        TD_M_INSIDESTAFFROLETDO ddoTD_M_INSIDESTAFFROLEOut;

        SelectDAO daoSelect = new SelectDAO();
        ddoTD_M_INSIDESTAFFROLEOut = (TD_M_INSIDESTAFFROLETDO)daoSelect.selDDO(context, a_ddoTD_M_INSIDESTAFFROLEIn, "TD_M_INSIDESTAFFROLE", typeof(TD_M_INSIDESTAFFROLETDO));

        if (ddoTD_M_INSIDESTAFFROLEOut == null)
        {
            context.AppException("S100001010");
        }

        return ddoTD_M_INSIDESTAFFROLEOut;
    }

    /************************************************************************
        *增加内部员工与角色对应表中数据
        * @param CmnContext context         上下文环境
        * @param TD_M_INSIDESTAFFROLETDO a_ddoTD_M_INSIDESTAFFROLEIn              内部部门编码表输入DDO
        * @return 		                    
        ************************************************************************/

    public int insAdd(CmnContext context, TD_M_INSIDESTAFFROLETDO a_ddoTD_M_INSIDESTAFFROLEIn)
    {
        InsertScene insertScene = new InsertScene();
        return insertScene.Execute(context, a_ddoTD_M_INSIDESTAFFROLEIn);
    }

    /************************************************************************
         * 修改内部员工与角色对应表中的数据
         * @param CmnContext context         上下文环境
         * @param TD_M_INSIDESTAFFROLETDO a_ddoTD_M_INSIDESTAFFROLEIn              内部员工编码表输入DDO
         * @return 		                     
         ************************************************************************/

    public int updRecord(CmnContext context, TD_M_INSIDESTAFFROLETDO a_ddoTD_M_INSIDESTAFFROLEIn)
    {
        UpdateScene updateScene = new UpdateScene();
        return updateScene.Execute(context, a_ddoTD_M_INSIDESTAFFROLEIn);
    }

    /************************************************************************
        * 删除内部员工与角色对应表中的数据
        * @param CmnContext context         上下文环境
        * @param TD_M_INSIDESTAFFROLETDO a_ddoTD_M_INSIDESTAFFROLEIn              内部部门编码表输入DDO
        * @return 		                     
        ************************************************************************/

    public int delDelete(CmnContext context, TD_M_INSIDESTAFFROLETDO a_ddoTD_M_INSIDESTAFFROLEIn)
    {
        DeleteScene deleteScene = new DeleteScene();
        return deleteScene.Execute(context, a_ddoTD_M_INSIDESTAFFROLEIn, "DELETE_TD_M_INSIDESTAFFROLE");
    }
}
