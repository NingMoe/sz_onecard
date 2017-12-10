using System;
using System.Data;
using System.Web.UI.WebControls;
using Master;
using Common;
using TDO.UserManager;
using TM;
/***************************************************************
 * 功能名: 项目管理  项目计划
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/12/18    董翔			初次开发
 ****************************************************************/

public partial class ASP_ProjectManage_PM_ProjectJobManage : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (IsPostBack) return;
        showNonDataGridView();
        //初始化资源类型
        ProjectManageHelper.selectProject(context, ddlPROJECTNAME, true);
        if (HasOperPower("201008"))//全部网点主管
        {
            //初始化部门
            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
            TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
            ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
            selDept.SelectedValue = context.s_DepartID;
            InitStaffList(context.s_DepartID);
            selStaff.SelectedValue = context.s_UserID;
        }
        else if (HasOperPower("201007"))//网点主管
        {
            selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
            selDept.SelectedValue = context.s_DepartID;
            selDept.Enabled = false;

            InitStaffList(context.s_DepartID);
            selStaff.SelectedValue = context.s_UserID;
        }

        else//网点营业员
        {
            selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
            selDept.SelectedValue = context.s_DepartID;
            selDept.Enabled = false;

            selStaff.Items.Add(new ListItem(context.s_UserID + ":" + context.s_UserName, context.s_UserID));
            selStaff.SelectedValue = context.s_UserID;
            selStaff.Enabled = false;
        }
    }

    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selDept.SelectedValue);

    }

    //初始化员工列表
    private void InitStaffList(string deptNo)
    {
        if (deptNo == "")
        {
            string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
            if (dBalunitNo != "")//add by liuhe20120214添加对代理的权限处理
            {
                context.DBOpen("Select");

                string sql = @"SELECT STAFFNAME,STAFFNO FROM TD_M_INSIDESTAFF 
                             WHERE DIMISSIONTAG ='1' AND  DEPARTNO IN 
                            (SELECT DEPARTNO FROM TD_DEPTBAL_RELATION WHERE DBALUNITNO='" + dBalunitNo + "' AND USETAG='1')";
                DataTable table = context.ExecuteReader(sql);
                GroupCardHelper.fill(selStaff, table, true);

                return;
            }

            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);
            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
            selStaff.SelectedValue = context.s_UserID;
        }
        else
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
    }

    //判断是否有指定权限
    private bool HasOperPower(string powerCode)
    {
        //TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
        string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
        DataTable dataSupply = tm.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
        if (dataSupply.Rows.Count > 0)
            return true;
        else
            return false;
    }

    private void showNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        gvResultJob.DataSource = new DataTable();
        gvResultJob.DataBind();
    }

    /// <summary>
    /// 查询输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean queryValidation()
    {
        //校验日期
        ResourceManageHelper.checkDate(context, selStartDate, selEndDate, "A095470102", "A095470103", "A095470104");
        return !context.hasError();
    }

    //查询
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!queryValidation())
            return;

        showNonDataGridView();
        ClearPage();

        DataTable data = QuerySource();
        ResourceManageHelper.resetData(gvResult, data);
    }

    private DataTable QuerySource()
    {
        string[] parm = new string[3];
        parm[0] = selStartDate.Text;
        parm[1] = selEndDate.Text;
        parm[2] = ddlPROJECTNAME.SelectedValue;
        DataTable data = SPHelper.callQuery("SP_PM_Query", context, "Query_Project", parm);
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        return data;
    }

    private void ClearPage()
    {
        txtPROJECTNAME.Text = "";
        txtEXPECTEDDATE.Text = "";
        txtJOBDESC.Text = "";
        selStaff.SelectedIndex = 0;
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            if (e.Row.Cells[2].Text != "&nbsp;" && e.Row.Cells[2].Text != "")
            {
                e.Row.Cells[2].Text = Convert.ToDateTime(e.Row.Cells[2].Text).ToString("yyyy-MM-dd");
            }
        }
    }

    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    /// <summary>
    /// 选择行
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        GridViewRow row = gvResult.SelectedRow;
        if (row != null)
        {
           ClearPage();
           gvResultJob.DataSource = GetProjectJob(row.Cells[0].Text.ToString().Trim());
           gvResultJob.DataBind();
           gvResultJob.SelectedIndex = -1;
           hidePROJECTCODE.Value = row.Cells[0].Text.ToString().Trim();
           txtPROJECTNAME.Text = row.Cells[1].Text.ToString().Trim();
        }
    }

    private DataTable GetProjectJob(string projectcode)
    {
        string[] parm = new string[1];
        parm[0] = projectcode;
        DataTable data = SPHelper.callQuery("SP_PM_Query", context, "Query_ProjectJob", parm);
        return data;
    }


    protected void gvResultJob_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            if (e.Row.Cells[2].Text != "&nbsp;" && e.Row.Cells[2].Text != "")
            {
                e.Row.Cells[2].Text = Convert.ToDateTime(e.Row.Cells[2].Text).ToString("yyyy-MM-dd");
            }
            if (e.Row.Cells[5].Text != "&nbsp;" && e.Row.Cells[5].Text != "")
            {
                e.Row.Cells[5].Text = Convert.ToDateTime(e.Row.Cells[5].Text).ToString("yyyy-MM-dd");
            }
        }
    }

    protected void gvResultJob_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResultJob','Select$" + e.Row.RowIndex + "')");
        }
    }

    /// <summary>
    /// 选择行
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gvResultJob_SelectedIndexChanged(object sender, EventArgs e)
    {
        GridViewRow row = gvResultJob.SelectedRow;
        if (row != null)
        {
            txtEXPECTEDDATE.Text = row.Cells[2].Text.ToString().Trim().Replace("-", "");
            txtJOBDESC.Text = row.Cells[1].Text.ToString().Trim();
            selStaff.SelectedIndex = selStaff.Items.IndexOf(selStaff.Items.FindByValue(row.Cells[3].Text.ToString().Split(':')[0]));
            hideJOBCODE.Value = row.Cells[0].Text.ToString().Trim();
        }
    }


    /// <summary>
    /// 添加计划
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (gvResult.SelectedRow == null)
        {
            context.AddError("没有选中任何行");
            return;
        }
        if (!SubmitValidate()) return;
        context.SPOpen();
        context.AddField("P_PROJECTCODE").Value = hidePROJECTCODE.Value.Trim();
        context.AddField("P_JOBDESC").Value = txtJOBDESC.Text.Trim();
        context.AddField("P_EXPECTEDDATE").Value = txtEXPECTEDDATE.Text.Trim();
        context.AddField("P_JOBSTAFF").Value = selStaff.SelectedValue;
        bool ok = context.ExecuteSP("SP_PM_ADDPROJECTJOB");
        if (ok)
        {
            AddMessage("项目计划添加成功");
            gvResultJob.DataSource = GetProjectJob(hidePROJECTCODE.Value.Trim());
            gvResultJob.DataBind();
        }
         

    }

    /// <summary>
    /// 修改
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnModify_Click(object sender, EventArgs e)
    {
        if (  gvResultJob.SelectedRow == null)
        {
            context.AddError("没有选中任何行");
            return;
        }
        if (!SubmitValidate()) return;
        context.SPOpen();
        context.AddField("P_PROJECTCODE").Value = hidePROJECTCODE.Value.Trim();
        context.AddField("P_JOBCODE").Value = hideJOBCODE.Value.Trim();
        context.AddField("P_JOBDESC").Value = txtJOBDESC.Text.Trim();
        context.AddField("P_EXPECTEDDATE").Value = txtEXPECTEDDATE.Text.Trim();
        context.AddField("P_JOBSTAFF").Value = selStaff.SelectedValue;
        bool ok = context.ExecuteSP("SP_PM_EDITPROJECTJOB");
        if (ok)
        {
            AddMessage("项目计划修改成功");
            gvResultJob.DataSource = GetProjectJob(hidePROJECTCODE.Value.Trim());
            gvResultJob.DataBind();
        }
         

    }

    /// <summary>
    /// 删除
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        if (  gvResultJob.SelectedRow == null)
        {
            context.AddError("没有选中任何行");
            return;
        }
        context.SPOpen();
        context.AddField("P_PROJECTCODE").Value = hidePROJECTCODE.Value.Trim();
        context.AddField("P_JOBCODE").Value = hideJOBCODE.Value.Trim();
        bool ok = context.ExecuteSP("SP_PM_DELETEPROJECTJOB");
        if (ok)
        {
            AddMessage("项目计划删除成功");
            gvResultJob.DataSource = GetProjectJob(hidePROJECTCODE.Value.Trim());
            gvResultJob.DataBind();
        }
    }

    /// <summary>
    /// 操作校验
    /// </summary>
    /// <returns></returns>
    private bool SubmitValidate()
    {
        Validation valid = new Validation(context);
        //计划说明
        if (Validation.strLen(txtJOBDESC.Text.Trim()) > 500)
        {
            context.AddError("A094780199：计划说明长度不能超过255位", txtJOBDESC);
        }

        //计划执行人
        if (selStaff.SelectedValue == "")
        {
            context.AddError("A094780198：请选择计划执行人", selStaff);
        }

        //预期完成日期
        if (string.IsNullOrEmpty(txtEXPECTEDDATE.Text.Trim()))
        {
            context.AddError("A094780197：预期完成日期不能为空", txtEXPECTEDDATE);
        }
        else if (!Validation.isDate(txtEXPECTEDDATE.Text.Trim(), "yyyyMMdd"))
        {
            context.AddError("A094780196：预计完成时间格式不正确", txtEXPECTEDDATE);
        }
        return !context.hasError();
    }
    
}