using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
/// <summary>
/// 系统管理-员工打印配置页面
/// youyue 20140728
/// </summary>
public partial class ASP_PrivilegePR_PR_StaffPrintConfig : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            InitLoad();
            gvList.DataSource = new DataTable();
            gvList.DataBind();
            gvList.SelectedIndex = -1;
            //指定GridView DataKeyNames
            gvList.DataKeyNames = new string[] { "DEPART", "STAFF", "PRINTMODE" };

        }
    }
    //初始化
    private void InitLoad()
    {
        string sql = "select * from td_m_insidestaffrole where staffno = '" + context.s_UserID + "'and roleno='0001'";
        context.DBOpen("Select");
        DataTable dt = context.ExecuteReader(sql);
        if (dt.Rows.Count > 0)  //当前操作员有管理员权限
        {
            UserCardHelper.selectDepts(context, selDepart, true);
            UserCardHelper.selectDepts(context, ddlDepart, true);
            UserCardHelper.selectStaffs(context, selStaff, selDepart, true);
            UserCardHelper.selectStaffs(context, ddlStaff, ddlDepart, true);
            hidIsManager.Value = "1";//1:管理员权限
        }
        else
        {
            selDepart.Items.Add(new ListItem("---请选择---", ""));
            selDepart.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
            ddlDepart.Items.Add(new ListItem("---请选择---", ""));
            ddlDepart.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
            selStaff.Items.Add(new ListItem("---请选择---", ""));
            selStaff.Items.Add(new ListItem(context.s_UserID + ":" + context.s_UserName, context.s_UserID));
            ddlStaff.Items.Add(new ListItem("---请选择---", ""));
            ddlStaff.Items.Add(new ListItem(context.s_UserID + ":" + context.s_UserName, context.s_UserID));
            hidIsManager.Value = "0";//0:非管理员权限
        }
        
    }
    /// <summary>
    /// 查询事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        gvList.DataSource = QueryDataSource();
        gvList.DataBind();

    }
    public ICollection QueryDataSource()
    {
        string[] parm = new string[2];
        if (hidIsManager.Value == "1" ) //是管理员权限可以查询所有人
        {
            parm[0] = selDepart.SelectedValue.Trim();
            parm[1] = selStaff.SelectedValue.Trim();
        }
        else
        {  
            parm[0] = context.s_DepartID;//非管理员权限只能查到自己
            parm[1] = context.s_UserID;
            
        }
        DataTable dt = SPHelper.callQuery("SP_PR_Query", context, "QueryStaffPrintMode", parm);
        DataView dataView = new DataView(dt);
        if (dt == null || dt.Rows.Count < 1)
        {
            gvList.DataSource = new DataTable();
            gvList.DataBind();
            AddMessage("查无数据");
        }
        return dataView;
    }
    //分页
    protected void gvList_Page(object sender, GridViewPageEventArgs e)
    {
        gvList.PageIndex = e.NewPageIndex;
        gvList.DataSource = QueryDataSource();
        gvList.DataBind();

        gvList.SelectedIndex = -1;
    }
    public string getDataKeys(string keysname)
    {
        return gvList.DataKeys[gvList.SelectedIndex][keysname].ToString();
    }
    protected void gvList_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvList','Select$" + e.Row.RowIndex + "')");
        }
    }
    protected void gvList_SelectedIndexChanged(object sender, EventArgs e)
    {
        ddlDepart.SelectedValue = getDataKeys("DEPART").Substring(0,4);
        ddlStaff.SelectedValue = getDataKeys("STAFF").Substring(0,6); 
        string printMode = getDataKeys("PRINTMODE").Substring(0,1);
        if (printMode.Equals("1")) //打印方式是针式打印
        {
            zhenshiPrint.Checked = true;
        }
        else
        {
            reminPrint.Checked = true;
        }

    }
    private bool ValidInput()
    {
        //校验部门
        if (ddlDepart.SelectedValue.Equals(""))
        {
            context.AddError("请选择部门", ddlDepart);
        }
        //校验员工
        if (ddlStaff.SelectedValue.Equals(""))
        {
            context.AddError("请选择员工", ddlStaff);
        }
        return !(context.hasError());
    }
    /// <summary>
    /// 新增事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!ValidInput()) return;
        string printMode = zhenshiPrint.Checked == true ? "1" : "2";
        context.SPOpen();
        context.AddField("P_STAFFNO").Value = ddlStaff.SelectedValue;
        context.AddField("P_PRINTMODE").Value = printMode;
        bool ok = context.ExecuteSP("SP_PR_STAFFPRINTADD");
        if (ok)
        {
            context.AddMessage("新增员工打印设置成功");
            btnQuery_Click(sender, e);
        }
    }
    //修改事件
    protected void btnModify_Click(object sender, EventArgs e)
    {
        if (gvList.SelectedIndex == -1)
        {
            context.AddError("未选中数据行");
            return;
        }
        if (!ValidInput()) return;
        string printMode = zhenshiPrint.Checked == true ? "1" : "2";
        context.SPOpen();
        context.AddField("P_STAFFNO").Value = ddlStaff.SelectedValue;
        context.AddField("P_PRINTMODE").Value = printMode;
        bool ok = context.ExecuteSP("SP_PR_STAFFPRINTEDIT");
        if (ok)
        {
            context.AddMessage("修改员工打印设置成功");
            btnQuery_Click(sender, e);
        }
    }
    
    protected void selDepart_SelectedIndexChanged(object sender, EventArgs e)
    {
        if(hidIsManager.Value.Equals("1"))//是管理员权限
        {
            UserCardHelper.selectStaffs(context, selStaff, selDepart, true);
        }
        else
        {
            if (selDepart.SelectedValue.Equals(string.Empty))
            {
                selStaff.SelectedValue = "";
            }
            else
            {
                selStaff.SelectedValue = context.s_UserID;
            }
        }
        
    }
    
    protected void ddlDepart_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (hidIsManager.Value.Equals("1"))//是管理员权限
        {
            UserCardHelper.selectStaffs(context, ddlStaff, ddlDepart, true);
        }
        else
        {
            if (ddlDepart.SelectedValue.Equals(string.Empty))
            {
                ddlStaff.SelectedValue = "";
            }
            else
            {
                ddlStaff.SelectedValue = context.s_UserID;
            }
        }
       
    }
}