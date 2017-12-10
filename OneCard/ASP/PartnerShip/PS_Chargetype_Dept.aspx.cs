using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TM;
using TDO.UserManager;
/**********************************
 * 部门与充值营销模式关系维护
 * 2012-12-12
 * shil
 * 初次编写
 * ********************************/

public partial class ASP_PartnerShip_PS_Chargetype_Dept : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            //指定GridView DataKeyNames
            gvResult.DataKeyNames =
                new string[] { "CHARGETYPECODE", "CHARGETYPENAME", "DEPTNO", "DEPARTNAME", "STAFFNAME", "UPDATETIME" };

            //设置GridView绑定的DataTable
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
            gvResult.SelectedIndex = -1;

            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
            TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
            ControlDeal.SelectBoxFill(ddlDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
            ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);

            SPHelper.selectChargeType(context, ddlChargeType, true);
            SPHelper.selectChargeType(context, selChargeType, true);
        }
    }
    private void queryChargeTypeDept()
    {
        gvResult.DataSource = query();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }
    /// <summary>
    /// 查询
    /// </summary>
    /// <returns></returns>
    private ICollection query()
    {
        DataTable data = SPHelper.callQuery("SP_PS_Query", context, "CHARGETYPE_DEPT", ddlChargeType.SelectedValue, ddlDept.SelectedValue);
        return new DataView(data);
    }
    /// <summary>
    /// 查询按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        queryChargeTypeDept();
    }
    /// <summary>
    /// 增加按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (selChargeType.SelectedValue == "")
        {
            context.AddError("A094570250:充值营销模式不能为空！");
        }
        if(selDept.SelectedValue == "")
        {
            context.AddError("A094570251:部门不能为空！");
        }
        if (context.hasError())
        {
            return;
        }

        context.SPOpen();
        context.AddField("P_FUNCCODE").Value = "ADD";
        context.AddField("P_CHARGETYPECODE").Value = selChargeType.SelectedValue;
        context.AddField("P_DEPTNO").Value = selDept.SelectedValue;
        bool ok = context.ExecuteSP("SP_PS_CHARGETYPE_DEPT");
        if (ok)
        {
            context.AddMessage("增加部门与充值营销模式关系成功！");

            queryChargeTypeDept();

            selDept.SelectedValue = "";
            selChargeType.SelectedValue = ""; 

            btnDel.Enabled = false;
        }
    }

    /// <summary>
    /// 删除按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDel_Click(object sender, EventArgs e)
    {
        //删除校验
        if (gvResult.SelectedIndex < 0)
        {
            context.AddError(":A094570256:未选中任何行");
        }

        if (context.hasError())
        {
            return;
        }

        context.SPOpen();
        context.AddField("P_FUNCCODE").Value = "DELETE";
        context.AddField("P_CHARGETYPECODE").Value = getDataKeys("CHARGETYPECODE");
        context.AddField("P_DEPTNO").Value = getDataKeys("DEPTNO");
        bool ok = context.ExecuteSP("SP_PS_CHARGETYPE_DEPT");
        if (ok)
        {
            context.AddMessage("增加部门与充值营销模式关系成功！");

            queryChargeTypeDept();

            selDept.SelectedValue = "";
            selChargeType.SelectedValue = ""; 

            btnDel.Enabled = false;
        }
    }

    /// <summary>
    /// 注册行单击事件

    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    /// <summary>
    /// 选择数据行

    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        btnDel.Enabled = true;
        selDept.SelectedValue = getDataKeys("DEPTNO");
        selChargeType.SelectedValue = getDataKeys("CHARGETYPECODE"); 
    }
    public String getDataKeys(string keysname)
    {
        return gvResult.DataKeys[gvResult.SelectedIndex][keysname].ToString();
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header
            || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[2].Visible = false;
        }
    }
}