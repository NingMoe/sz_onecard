using System;
using System.Data;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TM;
using TDO.PartnerShip;
using TDO.UserManager;

/***************************************************************
 * 功能名: 结算单元网点关系维护
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2011/12/28    liuh			初次开发

 ****************************************************************/
public partial class ASP_PartnerShip_PS_DeptBalRelation : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            //设置GridView绑定的DataTable
            lvwBalUnits.DataSource = new DataTable();
            lvwBalUnits.DataBind();
            lvwBalUnits.SelectedIndex = -1;

            //网点结算单元
            TMTableModule tmTMTableModule = new TMTableModule();
            TF_DEPT_BALUNITTDO[] tdoTF_DEPT_BALUNITTDOOutArr = null;
            TF_DEPT_BALUNITTDO tdoTF_TRADE_BALUNITIn = new TF_DEPT_BALUNITTDO();
            tdoTF_DEPT_BALUNITTDOOutArr = (TF_DEPT_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_DEPT_BALUNITTDO), null, null, null);

            context.DBOpen("Select");
            string sql = @"SELECT DBALUNIT, DBALUNITNO	FROM TF_DEPT_BALUNIT WHERE USETAG = '1' AND DEPTTYPE <> '2' ORDER BY DBALUNITNO";
            System.Data.DataTable table = context.ExecuteReader(sql);
            GroupCardHelper.fill(selBalUnit, table, true);
            GroupCardHelper.fill(ddlBalUnit, table, true);
          
            TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
            TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
            ControlDeal.SelectBoxFill(selInsideDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
            ControlDeal.SelectBoxFill(ddlInsideDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
        }
    }

    /// <summary>
    ///  查询按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        List<string> vars = new List<string>();
        vars.Add(this.ddlBalUnit.SelectedValue);
        vars.Add(this.ddlInsideDept.SelectedValue);

        //查询结算单元信息
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryDeptBalRelation", vars.ToArray());

        UserCardHelper.resetData(lvwBalUnits, data);

        lvwBalUnits.SelectedIndex = -1;
        selBalUnit.SelectedValue = "";
        selInsideDept.SelectedValue = "";
    }


    /// <summary>
    /// 增加按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        #region 增加前的验证
        if (lvwBalUnits.SelectedIndex != -1)
        {
            //当所有的信息都没有修改时不能增加该结算单元佣金规则
            if (
                selBalUnit.SelectedValue == lvwBalUnits.SelectedRow.Cells[1].Text &&
                selInsideDept.SelectedValue == lvwBalUnits.SelectedRow.Cells[3].Text
            )
            {
                context.AddError("A008104062:不能增加重复的信息");
                return;
            }
        }

        //结算单元是否为空
        if (selBalUnit.SelectedValue == "")
        {
            context.AddError("A008104006", selBalUnit);
        }

        //网点名称为空
        if (this.selInsideDept.SelectedValue == "")
        {
            context.AddError("A008104061：网点名称为空", selInsideDept);
        }
        if (context.hasError())
        {
            return;
        }

        #endregion

        context.SPOpen();
        context.AddField("P_BALUNITNO").Value = this.selBalUnit.SelectedValue;
        context.AddField("P_DEPARTNO").Value = this.selInsideDept.SelectedValue;
        context.AddField("P_OPTYPE").Value = "ADD";

        bool ok = context.ExecuteSP("SP_PS_DEPTBALRELATION");

        if (ok)
        {
            AddMessage("M008104170:结算单元-网点关系增加成功");
            btnQuery_Click(sender, e);
        }
    }

    /// <summary>
    /// 删除按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDel_Click(object sender, EventArgs e)
    {
        #region 删除前的验证
        if (lvwBalUnits.SelectedIndex == -1)
        {
            context.AddError("A008104004:没有选择要删除的记录");
            return;
        }
        else
        {
            //当所有的信息都没有修改时不能增加该结算单元佣金规则
            if (
                selBalUnit.SelectedValue != lvwBalUnits.SelectedRow.Cells[1].Text ||
                selInsideDept.SelectedValue != lvwBalUnits.SelectedRow.Cells[3].Text
            )
            {
                context.AddError("A008104063:选定记录更改后不能删除");
                return;
            }
        }
        #endregion

        context.SPOpen();
        context.AddField("P_BALUNITNO").Value = this.selBalUnit.SelectedValue;
        context.AddField("P_DEPARTNO").Value = this.selInsideDept.SelectedValue;
        context.AddField("P_OPTYPE").Value = "DEL";

        bool ok = context.ExecuteSP("SP_PS_DEPTBALRELATION");

        if (ok)
        {
            AddMessage("M008104171:结算单元-网点关系删除成功");
            btnQuery_Click(sender, e);
        }
    }

    /// <summary>
    /// 注册行单击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void lvwBalUnits_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwBalUnits','Select$" + e.Row.RowIndex + "')");
        }
    }

    /// <summary>
    /// 选择数据行
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void lvwBalUnits_SelectedIndexChanged(object sender, EventArgs e)
    {
        selBalUnit.SelectedValue = lvwBalUnits.SelectedRow.Cells[1].Text;
        selInsideDept.SelectedValue = lvwBalUnits.SelectedRow.Cells[3].Text;
    }


    public String getDataKeys(string keysname)
    {
        try
        {
            string value = lvwBalUnits.DataKeys[lvwBalUnits.SelectedIndex][keysname].ToString();
            return value.Trim();
        }
        catch
        {
            return "";
        }
    }
}
