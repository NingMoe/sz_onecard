using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using TDO.BalanceChannel;
using TM;
using TDO.UserManager;
using Common;
using TM.UserManager;
using Master;

public partial class ASP_PrivilegePR_PR_BasicParamsConfig : Master.Master
{
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //指定部门GridView DataKeyNames
            lvwDepart.DataKeyNames = new string[] { "DEPARTNO", "DEPARTNAME", "REGIONCODE" , "USETAG"};

            lvwDepart.DataSource = CreateDepartQueryDataSource();
            lvwDepart.DataBind();

            //设置地区信息
            InitSelREGIONCODE();

            //指定角色GridView DataKeyNames
            lvwRole.DataKeyNames = new string[] { "ROLENO", "ROLENAME" };

            lvwRole.DataSource = CreateRoleQueryDataSource();
            lvwRole.DataBind();
        }
    }

    public void lvwDepart_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwDepart.PageIndex = e.NewPageIndex;
        lvwDepart.DataSource = CreateDepartQueryDataSource();
        lvwDepart.DataBind();
    }

    public void lvwRole_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwRole.PageIndex = e.NewPageIndex;
        lvwRole.DataSource = CreateRoleQueryDataSource();
        lvwRole.DataBind();
    }

    private Boolean CheckContext()
    {
        //对context的error检测 
        if (context.hasError())
            return false;
        else
            return true;
    }
    
    //判断部门信息

    private Boolean DepartConfigValidation()
    {
        //对部门编码进行非空、长度、数字检验

        String strDepartNO = txtDepartNO.Text.Trim();

        if (strDepartNO == "")
            context.AddError("A010007061", txtDepartNO);
        else
        {
            int len = Validation.strLen(strDepartNO);

            if (Validation.strLen(strDepartNO) > 4 || Validation.strLen(strDepartNO) < 4)
                context.AddError("A010007062", txtDepartNO);
            else if (!Validation.isNum(strDepartNO))
                context.AddError("A010007063", txtDepartNO);

        }

        

        //对部门名称进行非空、长度检验

        String strDepartName = txtDepartName.Text.Trim();

        if (strDepartName == "")
            context.AddError("A010007064", txtDepartName);
        else
        {
            int len = Validation.strLen(strDepartName);

            if (Validation.strLen(strDepartName) > 40)
                context.AddError("A010007066", txtDepartName);

        }

        //对地区进行非空检验
        //if (selRegion.SelectedValue == "")
        //    context.AddError("A008113018", selRegion);

        if (context.hasError())
            return false;
        else
            return true;

    }

    private Boolean DepartAddValidation()
    {
       //查询是否存在该部门编码
        TMTableModule tmTMTableModule = new TMTableModule();

        //从部门编码表(TD_M_INSIDEDEPART)中读取数据
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
        tdoTD_M_INSIDEDEPARTIn.DEPARTNO = txtDepartNO.Text.Trim();

        TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, "TD_M_INSIDEDEPART", null);

        if (tdoTD_M_INSIDEDEPARTOutArr.Length != 0)
        {
            context.AddError("A010007097", txtDepartNO);
        }
        
        //对输入的部门信息检验
        DepartConfigValidation();
        return CheckContext();
    }

    private Boolean DepartModifyValidation()
    {

        //判断部门名称是否为空
        if (lvwDepart.SelectedIndex < 0)
        {
            context.AddError("A010007126", txtDepartNO);
            return false;
        }
        
        //判断该部门名称是否是选中的部门名称
        if (txtDepartNO.Text.Trim() != getDataKeys("DEPARTNO"))
        {
            context.AddError("A010007096", txtDepartNO);
            return false;
        }
       
       //对修改的部门信息检验
       DepartConfigValidation();
       return CheckContext();
    }

    private Boolean DepartDeleteValidation()
    {
        //判断部门名称是否为空
        if (lvwDepart.SelectedIndex < 0)
        {
            context.AddError("A010007126", txtDepartNO);
            return false;
        }

        //判断该部门名称是否是选中的部门名称
        if (txtDepartNO.Text.Trim() != getDataKeys("DEPARTNO"))
        {
            context.AddError("A010007098", txtDepartNO);
            return false;
        }
        
        //对删除的部门信息检验
        DepartConfigValidation();
        return CheckContext();
    }

    

    //部门编码表单击事件
    public ICollection CreateDepartQueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从部门信息资料表(TD_M_INSIDEDEPARTT)中读取数据
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
        string strsql = "SELECT A.DEPARTNO, A.DEPARTNAME, A.UPDATESTAFFNO, A.UPDATETIME, A.REMARK, A.REGIONCODE, B.REGIONNAME,A.USETAG";
        strsql += " FROM TD_M_INSIDEDEPART A, TD_M_REGIONCODE B";
        strsql += " WHERE A.REGIONCODE = B.REGIONCODE(+) Order By A.DEPARTNO";
        //DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTD_M_INSIDEDEPARTIn, null, "", null, 0);
        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTD_M_INSIDEDEPARTIn, null, strsql, 0);
        DataView dataView = new DataView(data);
        
        return dataView;
    }

    protected void lvwDepart_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwDepart','Select$" + e.Row.RowIndex + "')");
        }
    }


    protected void lvwDepart_SelectedIndexChanged(object sender, EventArgs e)
    {
        
        //选择部门GRIDVIEW中的一行记录
        txtDepartNO.Text = getDataKeys("DEPARTNO");
        txtDepartName.Text = getDataKeys("DEPARTNAME");
        selRegion.SelectedValue = getDataKeys("REGIONCODE");
        selUseTag.SelectedValue = getDataKeys("USETAG");
    }

    public String getDataKeys(String keysname)
    {
        return lvwDepart.DataKeys[lvwDepart.SelectedIndex][keysname].ToString();
    }


    //部门编码的按纽事件
    protected void btnDepartAdd_Click(object sender, EventArgs e)
    {
        //对输入部门信息检验
        if (!DepartAddValidation())
            return;

        //执行单位信息增加的过程
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();

        tdoTD_M_INSIDEDEPARTIn.DEPARTNO = txtDepartNO.Text.Trim();
        tdoTD_M_INSIDEDEPARTIn.DEPARTNAME = txtDepartName.Text.Trim();
        tdoTD_M_INSIDEDEPARTIn.REGIONCODE = selRegion.SelectedValue;
        tdoTD_M_INSIDEDEPARTIn.USETAG = selUseTag.SelectedValue;

        TD_M_INSIDEDEPARTTM tmTD_M_INSIDEDEPART = new TD_M_INSIDEDEPARTTM();
        int AddSum = tmTD_M_INSIDEDEPART.insAdd(context, tdoTD_M_INSIDEDEPARTIn);

        //插入数据不成功显示错误信息
        if (AddSum == 0)
        {
            context.AddError("S010007067");
        }

        //增加成功后提交
        context.DBCommit();

        lvwDepart.DataSource = CreateDepartQueryDataSource();
        lvwDepart.DataBind();

        AddMessage("M010007116");

        //清除信息
        ClearDepart();

    }
    
    protected void btnDepartModify_Click(object sender, EventArgs e)
    {
        //对修改部门信息检验
        if (!DepartModifyValidation())
            return;

        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();

        tdoTD_M_INSIDEDEPARTIn.DEPARTNO = txtDepartNO.Text.Trim();
        tdoTD_M_INSIDEDEPARTIn.DEPARTNAME = txtDepartName.Text.Trim();
        tdoTD_M_INSIDEDEPARTIn.REGIONCODE = selRegion.SelectedValue;
        tdoTD_M_INSIDEDEPARTIn.USETAG = selUseTag.SelectedValue;

        TD_M_INSIDEDEPARTTM tmTD_M_INSIDEDEPART = new TD_M_INSIDEDEPARTTM();
        int RecordSum = tmTD_M_INSIDEDEPART.updRecord(context, tdoTD_M_INSIDEDEPARTIn);

        //修改数据不成功显示错误信息
        if (RecordSum == 0)
        {
            context.AddError("S010007068");
        }

        //修改成功后提交
        context.DBCommit();

        lvwDepart.DataSource = CreateDepartQueryDataSource();
        lvwDepart.DataBind();

        AddMessage("M010007117");

        //清除信息
        ClearDepart();

    }

    protected void btnDepartDelete_Click(object sender, EventArgs e)
    {
        //对删除部门信息检验
        if (!DepartDeleteValidation())
            return;

        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();

        tdoTD_M_INSIDEDEPARTIn.DEPARTNO = txtDepartNO.Text.Trim();
        TD_M_INSIDEDEPARTTM tmTD_M_INSIDEDEPART = new TD_M_INSIDEDEPARTTM();
        int DeleteSum = tmTD_M_INSIDEDEPART.delDelete(context, tdoTD_M_INSIDEDEPARTIn);

        //删除数据不成功显示错误信息
        if (DeleteSum == 0)
        {
            context.AddError("S010007069");
        }

        //删除成功后提交
        context.DBCommit();

        lvwDepart.DataSource = CreateDepartQueryDataSource();
        lvwDepart.DataBind();

        AddMessage("M010007118");

        //清除信息
        ClearDepart();
    }

    private void ClearDepart()
    {
        //清空部门配置中输入的信息
        txtDepartNO.Text = "";
        txtDepartName.Text = "";
        selRegion.SelectedIndex = 0;
        lvwDepart.SelectedIndex = -1;
    }


    //判断角色信息
    private Boolean RoleConfigValidation()
    {
        
        //对角色编码进行非空、长度、数字检验

        String strRoleNO = txtRoleNO.Text.Trim();

        if (strRoleNO == "")
            context.AddError("A010008071", txtRoleNO);
        else
        {
            int len = Validation.strLen(strRoleNO);

            if (Validation.strLen(strRoleNO) > 4 || Validation.strLen(strRoleNO) < 4)
                context.AddError("A010008073", txtRoleNO);
            else if (!Validation.isCharNum(strRoleNO))
                context.AddError("A010008072", txtRoleNO);
        }

        
        //对角色名称进行非空、长度检验

        String strRoleName = txtRoleName.Text.Trim();

        if (strRoleName == "")
            context.AddError("A010008074", txtRoleName);
        else
        {
            int len = Validation.strLen(strRoleName);

            if (Validation.strLen(strRoleName) > 20)
                context.AddError("A010008076", txtRoleName);

        }

        if (context.hasError())
            return false;
        else
            return true;
    }
    
    private Boolean RoleAddValidation()
    {
        
        //判断表中是否已经存在该角色
        TMTableModule tmTMTableModule = new TMTableModule();
        //从角色编码表(TD_M_ROLE)中读取数据

        TD_M_ROLETDO tdoTD_M_ROLEIn = new TD_M_ROLETDO();
        tdoTD_M_ROLEIn.ROLENO = txtRoleNO.Text.Trim();

        TD_M_ROLETDO[] tdoTD_M_ROLEOutArr = (TD_M_ROLETDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_ROLEIn, typeof(TD_M_ROLETDO), null, "TD_M_ROLENO", null);

        if (tdoTD_M_ROLEOutArr.Length != 0)
        {
            context.AddError("A010008099", txtRoleNO);
        }
        
        //对输入的角色信息检验
        RoleConfigValidation();
        return CheckContext();
    }

    private Boolean RoleModifyValidation()
    {

        //判断角色名称是否为空白
        if (lvwRole.SelectedIndex < 0)
        {
            context.AddError("A010008127", txtRoleNO);
            return false;
        }
        
        //判断该角色名称是否是原来选中的角色名称
        if (txtRoleNO.Text.Trim() != getDataKeys1("ROLENO"))
        {
            context.AddError("A010008100", txtRoleNO);
        }
        
        //对修改的角色信息检验
        RoleConfigValidation();
        return CheckContext();
    }

    private Boolean RoleDeleteValidation()
    {
        //判断角色名称是否为空白
        if (lvwRole.SelectedIndex < 0)
        {
            context.AddError("A010008127", txtRoleNO);
            return false;
        }

        //判断该角色名称是否是原来选中的角色名称
        if (txtRoleNO.Text.Trim() != getDataKeys1("ROLENO"))
        {
            context.AddError("A010008101", txtRoleNO);
        }
        
        //对删除的角色信息检验
        RoleConfigValidation();
        return CheckContext();
    }


    //角色编码表单击事件
    public ICollection CreateRoleQueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从角色资料表(TD_M_Role)中读取数据
        TD_M_ROLETDO tdoTD_M_ROLEIn = new TD_M_ROLETDO();
        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTD_M_ROLEIn, null, "", null, 0);

        DataView dataView = new DataView(data);
        return dataView;
    }

    protected void lvwRole_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwRole','Select$" + e.Row.RowIndex + "')");
        }
    }


    protected void lvwRole_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择角色GRIDVIEW中的一行记录
        txtRoleNO.Text = getDataKeys1("ROLENO");
        txtRoleName.Text = getDataKeys1("ROLENAME");

    }

    public String getDataKeys1(String keysname)
    {
        return lvwRole.DataKeys[lvwRole.SelectedIndex][keysname].ToString();
    }


    //角色编码的按纽事件
    protected void btnRoleAdd_Click(object sender, EventArgs e)
    {
        //对输入角色信息检验
        if (!RoleAddValidation())
            return;

        //执行角色信息增加的过程
        TD_M_ROLETDO tdoTD_M_ROLEIn = new TD_M_ROLETDO();

        tdoTD_M_ROLEIn.ROLENO = txtRoleNO.Text.Trim();
        tdoTD_M_ROLEIn.ROLENAME = txtRoleName.Text.Trim();

        TD_M_ROLETM tmTD_M_ROLE = new TD_M_ROLETM();
        int AddSum = tmTD_M_ROLE.insAdd(context, tdoTD_M_ROLEIn);

        //插入数据不成功显示错误信息
        if (AddSum == 0)
        {
            context.AddError("S010008077");
        }

        //增加成功后提交
        context.DBCommit();

        lvwRole.DataSource = CreateRoleQueryDataSource();
        lvwRole.DataBind();

        AddMessage("M010008119");

        //清除输入的角色信息
        ClearRole();


    }

    protected void btnRoleModify_Click(object sender, EventArgs e)
    {
        //对修改角色信息检验
        if (!RoleModifyValidation())
            return;

        TD_M_ROLETDO tdoTD_M_ROLEIn = new TD_M_ROLETDO();

        tdoTD_M_ROLEIn.ROLENO = txtRoleNO.Text.Trim();
        tdoTD_M_ROLEIn.ROLENAME = txtRoleName.Text.Trim();

        TD_M_ROLETM tmTD_M_ROLE = new TD_M_ROLETM();
        int RecordSum = tmTD_M_ROLE.updRecord(context, tdoTD_M_ROLEIn);

        //修改数据不成功显示错误信息
        if (RecordSum == 0)
        {
            context.AddError("S010008078");
        }

        //修改成功后提交
        context.DBCommit();

        lvwRole.DataSource = CreateRoleQueryDataSource();
        lvwRole.DataBind();

        AddMessage("M010008120");

        //清除输入的角色信息
        ClearRole();

    }

    protected void btnRoleDelete_Click(object sender, EventArgs e)
    {
        //对删除角色信息检验
        if (!RoleDeleteValidation())
            return;

        TD_M_ROLETDO tdoTD_M_ROLEIn = new TD_M_ROLETDO();

        tdoTD_M_ROLEIn.ROLENO = txtRoleNO.Text.Trim();
        TD_M_ROLETM tmTD_M_ROLE = new TD_M_ROLETM();
        int DeleteSum = tmTD_M_ROLE.delDelete(context, tdoTD_M_ROLEIn);

        //删除数据不成功显示错误信息
        if (DeleteSum == 0)
        {
            context.AddError("S010008079");
        }

        //删除成功后提交
        context.DBCommit();

        lvwRole.DataSource = CreateRoleQueryDataSource();
        lvwRole.DataBind();

        AddMessage("M010008121");

        //清除输入的角色信息
        ClearRole();

    }

    
    private void ClearRole()
    {
        //清除输入的角色信息
        txtRoleNO.Text = "";
        txtRoleName.Text = "";
        lvwRole.SelectedIndex = -1;
    }

    //初始化地区编码下拉列表值
    private void InitSelREGIONCODE()
    {
        selRegion.Items.Clear();

        TMTableModule tmTMTableModule = new TMTableModule();

        TD_M_REGIONCODETDO ddoTD_M_REGIONCODEIn = new TD_M_REGIONCODETDO();
        TD_M_REGIONCODETDO[] ddoTD_M_REGIONCODEOutArr = (TD_M_REGIONCODETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_REGIONCODEIn, typeof(TD_M_REGIONCODETDO), "S008113013", "TD_M_REGIONUSETAG", null);

        ControlDeal.SelectBoxFill(selRegion.Items, ddoTD_M_REGIONCODEOutArr, "REGIONNAME", "REGIONCODE", true);
    }
}
