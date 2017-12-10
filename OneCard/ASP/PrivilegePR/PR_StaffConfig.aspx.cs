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

public partial class ASP_PrivilegePR_PR_StaffConfig : Master.Master
{

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //指定员工GridView DataKeyNames
            lvwStaff.DataKeyNames = new string[] { "STAFFNO", "STAFFNAME", "OPERCARDNO", "DEPARTNO", "DIMISSIONTAG" };

            //设置离职下拉列表值
            TSHelper.initDismissionTag(selDimTag);

            //读取部门编码表信息

            //从内部部门编码表(TD_M_INSIDEDEPART)中读取数据，放入下拉列表中

            UserCardHelper.selectDepts(context, selDepartName, true);
            UserCardHelper.selectDepts(context, selDepartName1, true);

            UserCardHelper.selectAllStaffs(context, selStaffName, selDepartName1, true);
        }
    }

    private Boolean CheckContext()
    {
        //对context的error检测 
        if (context.hasError())
            return false;
        else
            return true;
    }


    //判断员工信息
    private Boolean StaffConfigValidation()
    {
        //对员工编码进行非空、长度、数字检验


        String strStaffNO = txtStaffNO.Text.Trim();

        if (strStaffNO == "")
            context.AddError("A010009082", txtStaffNO);
        else
        {
            int len = Validation.strLen(strStaffNO);

            if (Validation.strLen(strStaffNO) != 6)
                context.AddError("A010009084", txtStaffNO);
            else if (!Validation.isCharNum(strStaffNO))
                context.AddError("A010009083", txtStaffNO);
        }



        //对员工姓名进行非空、长度检验


        String strStaffName = txtStaffName.Text.Trim();

        if (strStaffName == "")
            context.AddError("A010009085", txtStaffName);
        else
        {
            int len = Validation.strLen(strStaffName);

            if (Validation.strLen(strStaffName) > 20)
                context.AddError("A010009087", txtStaffName);

        }

        //对员工卡号进行非空、长度、数字检验


        String strOpercardNO = txtOpercardNO.Text.Trim();

        if (strOpercardNO != "")
        {
            int len = Validation.strLen(strOpercardNO);

            if (Validation.strLen(strOpercardNO) != 16)
                context.AddError("A010009090", txtOpercardNO);
            else if (!Validation.isNum(strOpercardNO))
                context.AddError("A010009089", txtOpercardNO);
        }

        //对部门进行非空检验


        String strDepartName = selDepartName.SelectedValue;

        if (strDepartName == "")
            context.AddError("A010009091", selDepartName);

        //对是否离职进行非空检验


        String strDimTag = selDimTag.SelectedValue;

        if (strDimTag == "")
            context.AddError("A010009126", selDimTag);

        if (context.hasError())
            return false;
        else
            return true;
    }


    private Boolean StaffAddValidation()
    {

        //对输入的员工信息检验

        StaffConfigValidation();

        //判断表中是否已经存在该员工编码

        TMTableModule tmTMTableModule = new TMTableModule();

        //从员工编码表(TD_M_INSIDESTAFF)中读取数据


        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        tdoTD_M_INSIDESTAFFIn.STAFFNO = txtStaffNO.Text.Trim();

        TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF2", null);

        if (tdoTD_M_INSIDESTAFFOutArr.Length != 0)
        {
            context.AddError("A010009102", txtStaffNO);
        }

        return CheckContext();

    }

    private Boolean StaffModifyValidation()
    {

        //判断员工编码是否为空白

        if (lvwStaff.SelectedIndex < 0)
        {
            context.AddError("A010009103", txtStaffNO);
            return false;
        }

        //判断该员工编码是否是选中的员工编码

        if (txtStaffNO.Text.Trim() != getDataKeys2("STAFFNO"))
        {
            context.AddError("A010009103", txtStaffNO);
        }

        //对修改的员工信息检验

        StaffConfigValidation();
        return CheckContext();

    }

    private Boolean StaffDeleteValidation()
    {

        //判断员工编码是否为空白

        if (lvwStaff.SelectedIndex < 0)
        {
            context.AddError("A010009104", txtStaffNO);
            return false;
        }

        //判断该员工编码是否是选中的员工编码

        if (txtStaffNO.Text.Trim() != getDataKeys2("STAFFNO"))
        {
            context.AddError("A010009104", txtStaffNO);
        }

        //对删除的员工信息检验

        StaffConfigValidation();
        return CheckContext();
    }


    public ICollection CreateStaffQueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从员工编码表(TD_M_INSIDESTAFF)中读取数据


        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();

        String strSql = "SELECT	staff.STAFFNO,staff.STAFFNAME,staff.OPERCARDNO,depart.DEPARTNAME,staff.DIMISSIONTAG,staff.DEPARTNO";
        strSql += " FROM TD_M_INSIDESTAFF staff,TD_M_INSIDEDEPART depart";

        ArrayList list = new ArrayList();
        list.Add("staff.DEPARTNO  = depart.DEPARTNO");

        if (selDepartName1.SelectedValue != "")
            list.Add("depart.DEPARTNO = '" + selDepartName1.SelectedValue + "'");

        if (selStaffName.SelectedValue != "")
            list.Add("staff.STAFFNO = '" + selStaffName.SelectedValue + "'");

        strSql += DealString.ListToWhereStr(list);
        strSql += " ORDER BY staff.DEPARTNO,staff.STAFFNO ";
        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTD_M_INSIDESTAFFIn, null, strSql, 1000);
        DataView dataView = new DataView(data);
        return dataView;

    }

    public void lvwStaff_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwStaff.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }


    protected void lvwStaff_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwStaff','Select$" + e.Row.RowIndex + "')");
        }
    }


    protected void lvwStaff_SelectedIndexChanged(object sender, EventArgs e)
    {

        //选择员工GRIDVIEW中的一行记录

        txtStaffNO.Text = getDataKeys2("STAFFNO");
        txtStaffName.Text = getDataKeys2("STAFFNAME");
        txtOpercardNO.Text = getDataKeys2("OPERCARDNO");
        selDepartName.SelectedValue = getDataKeys2("DEPARTNO");
        selDimTag.SelectedValue = getDataKeys2("DIMISSIONTAG");

    }

    public String getDataKeys2(String keysname)
    {
        return lvwStaff.DataKeys[lvwStaff.SelectedIndex][keysname].ToString();
    }


    //员工编码的按纽事件

    protected void btnStaffAdd_Click(object sender, EventArgs e)
    {
        //对输入员工信息检验

        if (!StaffAddValidation()) return;

        //执行员工信息增加的过程
        //获取系统参数配置的初始密码
        string initPwd = "szcic12!!";
        DataTable dtCheckTable = SPHelper.callQuery("SP_SSO_CHECKUSER", context, "getInitPwdPara");
        if (dtCheckTable.Rows.Count > 0)
        {
            initPwd = dtCheckTable.Rows[0]["PWD"].ToString();
        }

        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();

        tdoTD_M_INSIDESTAFFIn.STAFFNO = txtStaffNO.Text.Trim();
        tdoTD_M_INSIDESTAFFIn.STAFFNAME = txtStaffName.Text.Trim();
        tdoTD_M_INSIDESTAFFIn.OPERCARDNO = txtOpercardNO.Text.Trim();
        tdoTD_M_INSIDESTAFFIn.DEPARTNO = selDepartName.SelectedValue;
        tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = selDimTag.SelectedValue;
        tdoTD_M_INSIDESTAFFIn.OPERCARDPWD = DecryptString.EncodeString(initPwd);

        TD_M_INSIDESTAFFTM tmTD_M_INSIDESTAFF = new TD_M_INSIDESTAFFTM();
        int AddSum = tmTD_M_INSIDESTAFF.insAdd(context, tdoTD_M_INSIDESTAFFIn);

        //插入数据不成功显示错误信息

        if (AddSum == 0)
        {
            context.AddError("S010009092");
        }

        //增加成功后提交

        context.DBCommit();

        string[] parm = new string[1];
        parm[0] = this.txtStaffNO.Text.Trim();
        if (SPHelper.callQuery("SP_PR_Query", context, "QureyStaffInOneCard", parm).Rows.Count > 0)
        {
            AddMessage("卡管理系统存在相同员工号的员工");
        }

        lvwStaff.DataSource = CreateStaffQueryDataSource();
        lvwStaff.DataBind();

        AddMessage("M010009123");


        //清除输入的员工信息

        ClearStaff();
    }

    protected void btnStaffModify_Click(object sender, EventArgs e)
    {
        //对修改员工信息检验

        if (!StaffModifyValidation())
            return;

        //执行员工信息修改的过程

        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();

        tdoTD_M_INSIDESTAFFIn.STAFFNO = txtStaffNO.Text.Trim();
        tdoTD_M_INSIDESTAFFIn.STAFFNAME = txtStaffName.Text.Trim();
        tdoTD_M_INSIDESTAFFIn.OPERCARDNO = txtOpercardNO.Text.Trim();
        tdoTD_M_INSIDESTAFFIn.DEPARTNO = selDepartName.SelectedValue;
        tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = selDimTag.SelectedValue;

        TD_M_INSIDESTAFFTM tmTD_M_INSIDESTAFF = new TD_M_INSIDESTAFFTM();
        int RecordSum = tmTD_M_INSIDESTAFF.updRecord(context, tdoTD_M_INSIDESTAFFIn);

        //修改数据不成功显示错误信息

        if (RecordSum == 0)
        {
            context.AddError("S010009093");
        }

        //修改成功后提交

        context.DBCommit();

        lvwStaff.DataSource = CreateStaffQueryDataSource();
        lvwStaff.DataBind();

        AddMessage("M010009124");

        //清除输入的员工信息

        ClearStaff();
    }

    protected void btnStaffDelete_Click(object sender, EventArgs e)
    {
        //对删除员工信息检验

        if (!StaffDeleteValidation())
            return;

        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();

        tdoTD_M_INSIDESTAFFIn.STAFFNO = txtStaffNO.Text.Trim();
        tdoTD_M_INSIDESTAFFIn.STAFFNAME = txtStaffName.Text.Trim();
        tdoTD_M_INSIDESTAFFIn.OPERCARDNO = txtOpercardNO.Text.Trim();
        tdoTD_M_INSIDESTAFFIn.DEPARTNO = selDepartName.SelectedValue;
        tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = selDimTag.SelectedValue;

        TD_M_INSIDESTAFFTM tmTD_M_INSIDESTAFF = new TD_M_INSIDESTAFFTM();
        int DeleteSum = tmTD_M_INSIDESTAFF.delDelete(context, tdoTD_M_INSIDESTAFFIn);

        //删除数据不成功显示错误信息

        if (DeleteSum == 0)
        {
            context.AddError("S010009094");
        }

        //删除成功后提交

        context.DBCommit();

        lvwStaff.DataSource = CreateStaffQueryDataSource();
        lvwStaff.DataBind();

        AddMessage("M010009125");

        //清除输入的员工信息

        ClearStaff();
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {

        //查询员工信息
        lvwStaff.DataSource = CreateStaffQueryDataSource();
        lvwStaff.DataBind();


    }

    protected void selDepartName1_SelectedIndexChanged(object sender, EventArgs e)
    {
        //查询选择部门名称后,设置员工姓名下拉列表值
        UserCardHelper.selectAllStaffs(context, selStaffName, selDepartName1, true);
    }   

    private void ClearStaff()
    {
        //清除输入的员工信息

        txtStaffNO.Text = "";
        txtStaffName.Text = "";
        txtOpercardNO.Text = "";
        selDepartName.SelectedValue = "";
    }
}
