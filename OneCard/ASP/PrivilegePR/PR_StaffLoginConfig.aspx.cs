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
using TDO.UserManager;
using Master;
using TM;
using Common;
using System.Text;
using TM.UserManager;
using System.Net;
using DAO;

public partial class ASP_PrivilegePR_PR_StaffLoginConfig : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            UserCardHelper.selectDepts(context, selDepartName, true);
            UserCardHelper.selectDepts(context, selDepartName1, true);

            UserCardHelper.selectStaffs(context, selStaffName, selDepartName, true);

            //指定内部员工登录限制GridView DataKeyNames
            lvwStaffLoginConfig.DataKeyNames = new string[] { "DEPARTNO", "STAFFNO", "IPADDR", "STARTDATE", "ENDDATE", "STARTTIME", "ENDTIME", "VALIDTAG", "STAFFNAME" };

            //设置有效的下拉列表值
            TSHelper.initUseTag(selValidTag);
        }
    }

   
    protected void selDepartName_SelectedIndexChanged1(object sender, EventArgs e)
    {
        UserCardHelper.selectStaffs(context, selStaffName, selDepartName, true);
    }

    public void lvwStaffLoginConfig_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwStaffLoginConfig.PageIndex = e.NewPageIndex;
        lvwStaffLoginConfig.DataSource = CreateStaffLoginConfigDataSource();
        lvwStaffLoginConfig.DataBind();
    }

    protected void selDepartName1_SelectedIndexChanged1(object sender, EventArgs e)
    {
        //查询选择部门名称后,设置员工姓名下拉列表值
        if (selDepartName1.SelectedValue == "")
        {
            selStaffName1.Items.Clear();
        }
        else
        {
            TMTableModule tmTMTableModule = new TMTableModule();
            //根据部门编码显示出该部门的所有员工，放入下拉列表中

            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();

            tdoTD_M_INSIDESTAFFIn.DEPARTNO = selDepartName1.SelectedValue;
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "0";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF1", null);
            ControlDeal.SelectBoxFill(selStaffName1.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
    }


    public ICollection CreateStaffLoginConfigDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从内部员工登录限制表(TD_M_INSIDESTAFFLOGIN)中读取数据

        TD_M_INSIDESTAFFLOGINTDO tdoTD_M_INSIDESTAFFLOGINIn = new TD_M_INSIDESTAFFLOGINTDO();

        String strSql = "SELECT ISLG.STAFFNO,ISLG.IPADDR,ISLG.STARTDATE,ISLG.ENDDATE," +
                        "ISLG.STARTTIME,ISLG.ENDTIME,ISLG.VALIDTAG,depart.DEPARTNAME," +
                        "staff.STAFFNAME,staff.STAFFNO,depart.DEPARTNO ";
        strSql += " FROM TD_M_INSIDESTAFFLOGIN ISLG,TD_M_INSIDESTAFF staff,TD_M_INSIDEDEPART depart";

        ArrayList list = new ArrayList();
        list.Add("staff.STAFFNO  = ISLG.STAFFNO");
        list.Add("staff.DEPARTNO  = depart.DEPARTNO");
        list.Add("staff.DIMISSIONTAG = '1'");

        if (selDepartName.SelectedValue != "")
            list.Add("depart.DEPARTNO = '" + selDepartName.SelectedValue + "'");

        if (selStaffName.SelectedValue != "")
            list.Add("staff.STAFFNO = '" + selStaffName.SelectedValue + "'");

        strSql += DealString.ListToWhereStr(list);

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTD_M_INSIDESTAFFLOGINIn, null, strSql, 0);
        DataView dataView = new DataView(data);
        return dataView;

    }

    private Boolean lvwStaffLoginConfigValidation()
    {
        Validation valid = new Validation(context);
        
        //对部门名称进行非空检验
        string strDepartName1 = selDepartName1.SelectedValue;
        if(strDepartName1 == "")
            context.AddError("A010004026", selDepartName1);

        //对员工姓名进行非空检验

        string strStaffName1 = selStaffName1.SelectedValue;
        if (strStaffName1 == "")
            context.AddError("A010004027", selStaffName1);

        DateTime?  dateEff = null, dateExp = null;
        
        //对IP地址进行非空和格式检验
        String strIPAdress = txtIPAdress.Text.Trim();

        if (strIPAdress == "")
            context.AddError("A010004028", txtIPAdress);
        else
        {
            if (!Validation.isIPAddress(strIPAdress))
                context.AddError("A010004030", txtIPAdress);
        }

        //对起始日期进行非空和日期格式检验

        bool b = valid.notEmpty(txtEffDate, "A010004031");
        if (b) dateEff = valid.beDate(txtEffDate, "A010004033");

        //对终止日期进行非空和日期格式检验

        b = valid.notEmpty(txtExpDate, "A010004034");
        if (b) dateExp = valid.beDate(txtExpDate, "A010004036");

        //起始日期不能大于终止日期
        if (dateEff != null && dateExp != null)
        {
            valid.check(dateEff.Value.CompareTo(dateExp.Value) <= 0, "A010004037");  

        }
        

        //对起始时间进行非空和时间格式检验
        String strEffTime = txtEffTime.Text.Trim();

        if (strEffTime == "")
            context.AddError("A010004038", txtEffTime);
        else
        {
            if (!Validation.isTime(strEffTime))
                context.AddError("A010004040", txtEffTime);
        }
        
        
        //对终止时间进行非空和时间格式检验
        String strExpTime = txtExpTime.Text.Trim();

        if (strExpTime == "")
            context.AddError("A010004041", txtExpTime);
        else
        {
            if (!Validation.isTime(strExpTime))
                context.AddError("A010004043", txtExpTime);
        }

        //起始时间不能大于终止时间
        if (strEffTime != null && strExpTime != null)
        { 
            valid.check(strEffTime.CompareTo(strExpTime) <= 0, "A010004044");
        }

        //对有效性进行非空检验
        String strValidTag = selValidTag.SelectedValue;

        if (strValidTag == "")
            context.AddError("A010004128", selValidTag);

        return !context.hasError();

    }

    private Boolean btnStaffLoginConfigAddValidation()
    {
        //对增加内部员工登录限制信息进行检验
        lvwStaffLoginConfigValidation();

        SelectDAO daoSelect = new SelectDAO();

        //从内部员工登录限制表(TD_M_INSIDESTAFFLOGIN)中读取数据，判断是否已经存在该员工编码

        TD_M_INSIDESTAFFLOGINTDO tdoTD_M_INSIDESTAFFLOGINIn = new TD_M_INSIDESTAFFLOGINTDO();
        tdoTD_M_INSIDESTAFFLOGINIn.STAFFNO = selStaffName1.SelectedValue;
        tdoTD_M_INSIDESTAFFLOGINIn.IPADDR = txtIPAdress.Text.Trim();

        TD_M_INSIDESTAFFLOGINTDO[] ddoTD_M_INSIDESTAFFLOGINOutArr = (TD_M_INSIDESTAFFLOGINTDO[])daoSelect.selDDOArr(context, tdoTD_M_INSIDESTAFFLOGINIn, "TD_M_INSIDESTAFFLOGIN_IP", typeof(TD_M_INSIDESTAFFLOGINTDO));

        if (ddoTD_M_INSIDESTAFFLOGINOutArr.Length != 0)
        {
            context.AddError("A010004129", txtIPAdress);
        }

        return !context.hasError(); 
    }

    private Boolean btnStaffLoginConfigModifyValidation()
    {

        if (lvwStaffLoginConfig.SelectedIndex < 0)
        {
            context.AddError("A010009103", selStaffName1);
            return false;
        }

        //判断在修改的时候部门编码是否是原来选中的部门编码
        if (selDepartName1.SelectedValue != getDataKeys("DEPARTNO"))
        {
            context.AddError("A010004095", selDepartName1);
        }

        //判断在修改的时候员工编码是否是原来选中的员工编码
        else if (selStaffName1.SelectedValue != getDataKeys("STAFFNO"))
        {
            context.AddError("A010004095", selStaffName1);
        }

        //对修改内部员工登录限制信息进行检验
        lvwStaffLoginConfigValidation();
        return !context.hasError();

    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //查询内部员工登录限制信息
        lvwStaffLoginConfig.DataSource = CreateStaffLoginConfigDataSource();
        lvwStaffLoginConfig.DataBind();
        if (lvwStaffLoginConfig.Rows.Count == 0)
        {
            AddMessage("N007P00001: 查询结果为空");
        }
    }

    
    protected void lvwStaffLoginConfig_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwStaffLoginConfig','Select$" + e.Row.RowIndex + "')");
        }
    }

    protected void lvwStaffLoginConfig_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择列表框一行记录
        selValidTag.SelectedValue = getDataKeys("VALIDTAG");
        selDepartName1.SelectedValue = getDataKeys("DEPARTNO");

        TMTableModule tmTMTableModule = new TMTableModule();
        //从内部员工编码表(TD_M_INSIDESTAFF)中读取数据，放入下拉列表中

        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        
        tdoTD_M_INSIDESTAFFIn.DEPARTNO = getDataKeys("DEPARTNO"); 
        tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "0";
        TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF1", null);
        ControlDeal.SelectBoxFill(selStaffName1.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);

        selStaffName1.SelectedValue = getDataKeys("STAFFNO");
        txtIPAdress.Text = getDataKeys("IPADDR");
        txtEffDate.Text = getDataKeys("STARTDATE");
        txtExpDate.Text = getDataKeys("ENDDATE");
        txtEffTime.Text = getDataKeys("STARTTIME");
        txtExpTime.Text = getDataKeys("ENDTIME");
     
    }

    public String getDataKeys(String keysname)
    {
        return lvwStaffLoginConfig.DataKeys[lvwStaffLoginConfig.SelectedIndex][keysname].ToString();
    }


    protected void btnStaffLoginConfigAdd_Click(object sender, EventArgs e)
    {
        //对输入员工参数信息检验
        if (!btnStaffLoginConfigAddValidation()) return;

        //执行员工信息增加的过程
        TD_M_INSIDESTAFFLOGINTDO tdoTD_M_INSIDESTAFFLOGINIn = new TD_M_INSIDESTAFFLOGINTDO();
        TD_M_INSIDESTAFFLOGINTM tmTD_M_INSIDESTAFFLOGIN = new TD_M_INSIDESTAFFLOGINTM();

        tdoTD_M_INSIDESTAFFLOGINIn.STAFFNO = selStaffName1.SelectedValue;
        tdoTD_M_INSIDESTAFFLOGINIn.IPADDR = txtIPAdress.Text.Trim();
        tdoTD_M_INSIDESTAFFLOGINIn.STARTDATE = txtEffDate.Text.Trim();
        tdoTD_M_INSIDESTAFFLOGINIn.ENDDATE = txtExpDate.Text.Trim();
        tdoTD_M_INSIDESTAFFLOGINIn.STARTTIME = txtEffTime.Text.Trim();
        tdoTD_M_INSIDESTAFFLOGINIn.ENDTIME = txtExpTime.Text.Trim();
        tdoTD_M_INSIDESTAFFLOGINIn.VALIDTAG = selValidTag.SelectedValue;

        int AddSum = tmTD_M_INSIDESTAFFLOGIN.insAdd(context, tdoTD_M_INSIDESTAFFLOGINIn);
        
        //插入数据不成功显示错误信息
        if (AddSum == 0)
        {
            context.AddError("S010004045");
        }

        //增加成功后提交
        context.DBCommit();

        lvwStaffLoginConfig.DataSource = CreateStaffLoginConfigDataSource();
        lvwStaffLoginConfig.DataBind();

        AddMessage("M010004112");


        //清除输入的员工参数信息
        ClearStaffLoginConfig();
    }

    protected void btnStaffLoginConfigModify_Click(object sender, EventArgs e)
    {
        //对修改员工参数信息检验
        if (!btnStaffLoginConfigModifyValidation()) return;

        TD_M_INSIDESTAFFLOGINTDO tdoTD_M_INSIDESTAFFLOGINIn = new TD_M_INSIDESTAFFLOGINTDO();
        TD_M_INSIDESTAFFLOGINTM tmTD_M_INSIDESTAFFLOGIN = new TD_M_INSIDESTAFFLOGINTM();

        tdoTD_M_INSIDESTAFFLOGINIn.STAFFNO = selStaffName1.SelectedValue;
        tdoTD_M_INSIDESTAFFLOGINIn.IPADDR = txtIPAdress.Text.Trim();  
        tdoTD_M_INSIDESTAFFLOGINIn.STARTDATE = txtEffDate.Text.Trim();
        tdoTD_M_INSIDESTAFFLOGINIn.ENDDATE = txtExpDate.Text.Trim();
        tdoTD_M_INSIDESTAFFLOGINIn.STARTTIME = txtEffTime.Text.Trim();
        tdoTD_M_INSIDESTAFFLOGINIn.ENDTIME = txtExpTime.Text.Trim();
        tdoTD_M_INSIDESTAFFLOGINIn.VALIDTAG = selValidTag.SelectedValue;


        TD_M_INSIDESTAFFLOGINTDO tdoTD_M_INSIDESTAFFLOGINOld = new TD_M_INSIDESTAFFLOGINTDO();
        tdoTD_M_INSIDESTAFFLOGINOld.STAFFNO = getDataKeys("STAFFNO");
        tdoTD_M_INSIDESTAFFLOGINOld.IPADDR = getDataKeys("IPADDR");

        int RecordSum = tmTD_M_INSIDESTAFFLOGIN.updRecord(context, tdoTD_M_INSIDESTAFFLOGINIn,tdoTD_M_INSIDESTAFFLOGINOld);
        
        //修改数据不成功显示错误信息
        if (RecordSum == 0)
        {
            context.AddError("S010004046");
        }   

        //修改成功后提交
        context.DBCommit();

        lvwStaffLoginConfig.DataSource = CreateStaffLoginConfigDataSource();
        lvwStaffLoginConfig.DataBind();

        AddMessage("M010004113");

        //清除输入的员工信息
        ClearStaffLoginConfig();
    }

    private Boolean btnStaffLoginConfigDeleteValidation()
    {

        if (lvwStaffLoginConfig.SelectedIndex < 0)
        {
            context.AddError("A010009104", selStaffName1);
            return true;
        }


        //判断在修改的时候部门编码是否是原来选中的部门编码
        if (selDepartName1.SelectedValue != getDataKeys("DEPARTNO"))
        {
            context.AddError("A010004096", selDepartName1);
        }

        //判断在修改的时候员工编码是否是原来选中的员工编码

        else if (selStaffName1.SelectedValue != getDataKeys("STAFFNO"))
        {
            context.AddError("A010004096", selStaffName1);
        }
        else if (txtIPAdress.Text != getDataKeys("IPADDR"))
        {
            context.AddError("A010004096", txtIPAdress);
        }

        return context.hasError();

    }


    protected void btnStaffLoginConfigDelete_Click(object sender, EventArgs e)
    {
        //对修改员工参数信息检验

        if (btnStaffLoginConfigDeleteValidation()) return;

        TD_M_INSIDESTAFFLOGINTDO tdoTD_M_INSIDESTAFFLOGINIn = new TD_M_INSIDESTAFFLOGINTDO();
        TD_M_INSIDESTAFFLOGINTM tmTD_M_INSIDESTAFFLOGIN = new TD_M_INSIDESTAFFLOGINTM();

        tdoTD_M_INSIDESTAFFLOGINIn.STAFFNO = selStaffName1.SelectedValue;
        tdoTD_M_INSIDESTAFFLOGINIn.IPADDR = txtIPAdress.Text.Trim();

        int RecordSum = tmTD_M_INSIDESTAFFLOGIN.delRecord(context, tdoTD_M_INSIDESTAFFLOGINIn);

        //修改数据不成功显示错误信息

        if (RecordSum == 0)
        {
            context.AddError("S010004047");
        }

        //修改成功后提交

        context.DBCommit();

        lvwStaffLoginConfig.DataSource = CreateStaffLoginConfigDataSource();
        lvwStaffLoginConfig.DataBind();

        AddMessage("M010004114");

        //清除输入的员工信息

        ClearStaffLoginConfig();
    }

    private void ClearStaffLoginConfig()
    {
        //清除输入的信息
        selDepartName1.SelectedValue = "";
        selStaffName1.SelectedValue = "";
        txtIPAdress.Text = "";
        txtEffDate.Text = "";
        txtExpDate.Text = "";
        txtEffTime.Text = "";
        txtExpTime.Text = "";
        selValidTag.SelectedValue = "";
    }
    
}
