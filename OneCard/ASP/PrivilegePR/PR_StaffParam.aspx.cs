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
using TM;
using Common;
using TM.UserManager;

public partial class ASP_PrivilegePR_PR_StaffParam : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            // 初始化员工的操作权限

            TMTableModule tmTMTableModule = new TMTableModule();

            TD_M_ROLEPOWERTDO tdoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
            TD_M_ROLEPOWERTDO[] tdoTD_M_ROLEPOWEROutArr = (TD_M_ROLEPOWERTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_ROLEPOWERIn, typeof(TD_M_ROLEPOWERTDO), null, "TD_M_ROLEPOWER_PAWER");

            if (tdoTD_M_ROLEPOWEROutArr.Length == 0)
            {
                txtCardCost.Enabled = false;
            }

            else 
            {
                //selCardCostStat.Enabled = false;
                selCardCostStat.Items.Add(new ListItem("2:卡押金", "2"));
                selCardCostStat.Items.Add(new ListItem("1:卡费", "1"));
                
            }
            
            TD_M_INSIDESTAFFPARAMETERTDO tdoTD_M_INSIDESTAFFPARAMETERIn = new TD_M_INSIDESTAFFPARAMETERTDO();
            tdoTD_M_INSIDESTAFFPARAMETERIn.STAFFNO = context.s_UserID;

            //指定内部员工参数GridView DataKeyNames
            lvwStaffParam.DataKeyNames = new string[] { "DEPARTNAME", "DEPARTNO", "STAFFNO", "CARDCOSTSTAT", "CARDCOST", "SUPPLEMONEY" };

            //内部员工参数GridView 
            lvwStaffParam.DataSource = new DataTable();
            lvwStaffParam.DataBind();


            //从内部部门编码表(TD_M_INSIDEDEPART)中读取数据，放入下拉列表中
            UserCardHelper.selectDepts(context, selDepartName1, true);
            UserCardHelper.selectDepts(context, selDepartName2, true);

            UserCardHelper.selectStaffs(context, selStaffName1, selDepartName1, true);


            TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
            string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '201004' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
            DataTable dataSupply = tmTMTableModule.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);

            if (dataSupply.Rows.Count == 0)
            {
                selDepartName1.SelectedValue = context.s_DepartID;
                selDepartName2.SelectedValue = context.s_DepartID;

                selDepartName1_SelectedIndexChanged(sender, e);
                selDepartName2_SelectedIndexChanged(sender, e);

                selStaffName1.SelectedValue = context.s_UserID;
                selStaffName2.SelectedValue = context.s_UserID;

                selDepartName1.Enabled = false;
                selStaffName1.Enabled = false;

                selDepartName2.Enabled = false;
                selStaffName2.Enabled = false;
                selCardCostStat.Enabled = false;
                txtCardCost.Enabled = false;
            }

           
        }
        

    }

    protected void lvwStaffParam_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[2].Text == "2")
            {
                e.Row.Cells[2].Text = "卡押金";
            }
            else if (e.Row.Cells[2].Text == "1")
            {
                e.Row.Cells[2].Text = "卡费";
            }

            if (e.Row.Cells[3].Text == "-0.01")
            {
                e.Row.Cells[3].Text = "";
            }
            
            if (e.Row.Cells[4].Text == "-0.01")
            {
                e.Row.Cells[4].Text = "";
            }

        }
    }


    private Boolean lvwStaffParamValidation()
    {
         
        //对员工姓名进行非空检验
        
        string strStaffName1 = selStaffName2.SelectedValue;
        if (strStaffName1 == "")
            context.AddError("A010002012", selStaffName2);


        //对卡费默认值进行金额的有效性检验

        string strtxtCardCost = txtCardCost.Text.Trim();

        if (strtxtCardCost != "")
        { 
            if (!Validation.isPrice(strtxtCardCost) )
                context.AddError("A010002013", txtCardCost);
        }

        //对充值默认值进行金额的有效性检验
       
        string strtxtSuppleMoney = txtSuppleMoney.Text.Trim();

        if (strtxtSuppleMoney != "")
        {
            if (!Validation.isPrice(strtxtSuppleMoney))
                context.AddError("A010002014", txtSuppleMoney);
        }

        return !context.hasError();

    }

    private Boolean CheckContext()
    {
        //对context的error检测 
        if (context.hasError())
            return false;
        else
            return true;
    }

    protected void selDepartName1_SelectedIndexChanged(object sender, EventArgs e)
    {
        //查询选择部门名称后,设置员工姓名下拉列表值
        UserCardHelper.selectStaffs(context, selStaffName1, selDepartName1, true);
    }

    protected void selDepartName2_SelectedIndexChanged(object sender, EventArgs e)
    {

        //查询选择部门名称后,设置员工姓名下拉列表值


        if (selDepartName2.SelectedValue == "")
        {
            selStaffName2.Items.Clear();
        }
        else
        {
            UserCardHelper.selectStaffs(context, selStaffName2, selDepartName2, true);
        }
    }   

    private Boolean StaffParaAddValidation()
    {
        //对输入的部门信息检验
        lvwStaffParamValidation();

        //判断表中是否已经存在该员工编码
        TMTableModule tmTMTableModule = new TMTableModule();

        //从员工编码表(TD_M_INSIDESTAFF)中读取数据


        TD_M_INSIDESTAFFPARAMETERTDO tdoTD_M_INSIDESTAFFPARAMETERIn = new TD_M_INSIDESTAFFPARAMETERTDO();
        tdoTD_M_INSIDESTAFFPARAMETERIn.STAFFNO = selStaffName2.SelectedValue.ToString();

        TD_M_INSIDESTAFFPARAMETERTDO[] tdoTD_M_INSIDESTAFFPARAMETEROutArr = (TD_M_INSIDESTAFFPARAMETERTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDESTAFFPARAMETERIn, typeof(TD_M_INSIDESTAFFPARAMETERTDO), null, "TD_M_INSIDESTAFFPARAMETER", null);

        if (tdoTD_M_INSIDESTAFFPARAMETEROutArr.Length != 0)
        {
            context.AddError("A010009102", selStaffName2);
        }

        return CheckContext();
    }

    private Boolean StaffParaModifyValidation()
    {

        if (lvwStaffParam.SelectedIndex < 0)
        {
            context.AddError("A010009103", selStaffName2);
            return false;
        }

        //判断该员工是否为选中的员工
        if (selStaffName2.SelectedValue != getDataKeys("STAFFNO"))
        {
            context.AddError("A010002105", selStaffName2);
            return false;
        }
        
        //对修改的部门信息检验
        lvwStaffParamValidation();
        return CheckContext();
    
    }

    private Boolean StaffParaDeleteValidation()
    {
        if (lvwStaffParam.SelectedIndex < 0)
        {
            context.AddError("A010009104", selStaffName2);
            return false;
        }

        //判断该员工是否为选中的员工
        if (selStaffName2.SelectedValue != getDataKeys("STAFFNO"))
        {
            context.AddError("A010002106", selStaffName2);
            return false;
        }

        //对修改的部门信息检验
        lvwStaffParamValidation();
        return CheckContext();

    }
    
    public ICollection CreateStaffQueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从内部员工参数表(TD_M_INSIDESTAFFPARAMETER)中读取数据

        TD_M_INSIDESTAFFPARAMETERTDO tdoTD_M_INSIDESTAFFPARAMETERIn = new TD_M_INSIDESTAFFPARAMETERTDO();

        String strSql = "SELECT ISPM.STAFFNO,ISPM.CARDCOSTSTAT,ISPM.CARDCOST/100.0 CARDCOST,depart.DEPARTNO,depart.DEPARTNAME,ISPM.SUPPLEMONEY/100.0 SUPPLEMONEY,staff.STAFFNAME";
        strSql += " FROM TD_M_INSIDESTAFFPARAMETER ISPM,TD_M_INSIDESTAFF staff,TD_M_INSIDEDEPART depart";

        ArrayList list = new ArrayList();
        list.Add("ISPM.STAFFNO  = staff.STAFFNO");
        list.Add("depart.DEPARTNO  = staff.DEPARTNO");

        if (selStaffName1.SelectedValue != "")
            list.Add("ISPM.STAFFNO = '" + selStaffName1.SelectedValue + "'");

        strSql += DealString.ListToWhereStr(list);

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTD_M_INSIDESTAFFPARAMETERIn, null, strSql, 0);
        DataView dataView = new DataView(data);
        return dataView;

    }

    //查询内部员工参数信息
    protected void btnQuery_Click(object sender, EventArgs e)
    {

        DataView dataView = (DataView)CreateStaffQueryDataSource();
        lvwStaffParam.DataSource = dataView;
        lvwStaffParam.DataBind();

        if(dataView.Count == 0)
            AddMessage("N007P00001");
        
    }

    public void lvwStaffParam_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwStaffParam.PageIndex = e.NewPageIndex;
        lvwStaffParam.DataSource = CreateStaffQueryDataSource();
        lvwStaffParam.DataBind();
    }


    //内部员工参数配置单击事件
    protected void lvwStaffParam_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwStaffParam','Select$" + e.Row.RowIndex + "')");
        }
    }


    protected void lvwStaffParam_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选中GRIDVIEW中的一行记录
        selDepartName2.SelectedValue = getDataKeys("DEPARTNO");
        
        TMTableModule tmTMTableModule = new TMTableModule();
        //从内部员工编码表(TD_M_INSIDESTAFF)中读取数据，放入下拉列表中

        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();

        tdoTD_M_INSIDESTAFFIn.DEPARTNO = selDepartName2.SelectedValue;

        TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF1", null);
        ControlDeal.SelectBoxFill(selStaffName2.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);

        selStaffName2.SelectedValue = getDataKeys("STAFFNO");

        selCardCostStat.SelectedValue = getDataKeys("CARDCOSTSTAT");
        
        //判断卡押金默认值是否为-1，如果是-1就显示为空，否则显示数值
        if (getDataKeys("CARDCOST") == "-0.01")
        {
            txtCardCost.Text = "";
        }
        else
            txtCardCost.Text = getDataKeys("CARDCOST");
        
        //判断充值默认值是否为-1，如果是-1就显示为空，否则显示数值
        if (getDataKeys("SUPPLEMONEY") == "-0.01")
        {
            txtSuppleMoney.Text = "";
        }
        else
            txtSuppleMoney.Text = getDataKeys("SUPPLEMONEY");

    }

    public String getDataKeys(String keysname)
    {
        return lvwStaffParam.DataKeys[lvwStaffParam.SelectedIndex][keysname].ToString();
    }

    
    //按纽单击事件
    protected void btnStaffParaAdd_Click(object sender, EventArgs e)
    {
        //对输入员工参数信息检验
        if (!StaffParaAddValidation()) return;

        //执行员工信息增加的过程
        TD_M_INSIDESTAFFPARAMETERTDO tdoTD_M_INSIDESTAFFPARAMETERIn = new TD_M_INSIDESTAFFPARAMETERTDO();
        TD_M_INSIDESTAFFPARAMETERTM tmTD_M_INSIDESTAFFPARAMETER = new TD_M_INSIDESTAFFPARAMETERTM();
        
        tdoTD_M_INSIDESTAFFPARAMETERIn.STAFFNO = selStaffName2.SelectedValue;
        tdoTD_M_INSIDESTAFFPARAMETERIn.CARDCOSTSTAT = selCardCostStat.SelectedValue;

        
        //判断卡押金默认值是否为空，如果是就向表里插入-1，否则插入数值
        string strtxtCardCost = txtCardCost.Text.Trim();
        if (strtxtCardCost == "")
        {
            tdoTD_M_INSIDESTAFFPARAMETERIn.CARDCOST = -1;
        }
        else
            tdoTD_M_INSIDESTAFFPARAMETERIn.CARDCOST = Validation.getPrice(txtCardCost);

        
        //判断充值默认值是否为空，如果是就向表里插入-1，否则插入数值
        string strtxtSuppleMoney = txtSuppleMoney.Text.Trim();
        if (strtxtSuppleMoney == "")
        {
            tdoTD_M_INSIDESTAFFPARAMETERIn.SUPPLEMONEY = -1;
        }
        else 
            tdoTD_M_INSIDESTAFFPARAMETERIn.SUPPLEMONEY = Validation.getPrice(txtSuppleMoney);
        
        int AddSum = tmTD_M_INSIDESTAFFPARAMETER.insAdd(context, tdoTD_M_INSIDESTAFFPARAMETERIn);

        //插入数据不成功显示错误信息
        if (AddSum == 0)
        {
            context.AddError("S010002015");
            return;
        }

        //增加成功后提交
        context.DBCommit();

        lvwStaffParam.DataSource = CreateStaffQueryDataSource();
        lvwStaffParam.DataBind();

        AddMessage("M010002107");
    }
    
    protected void btnStaffParaModify_Click(object sender, EventArgs e)
    {
        
        //对修改员工参数信息检验
        if (!StaffParaModifyValidation()) return;

        //执行员工参数信息修改的过程
        TD_M_INSIDESTAFFPARAMETERTDO tdoTD_M_INSIDESTAFFPARAMETERIn = new TD_M_INSIDESTAFFPARAMETERTDO();

        tdoTD_M_INSIDESTAFFPARAMETERIn.STAFFNO = selStaffName2.SelectedValue;
        tdoTD_M_INSIDESTAFFPARAMETERIn.CARDCOSTSTAT = selCardCostStat.SelectedValue;

        //判断卡押金默认值是否为空，如果是就向表里插入-1，否则插入数值
        string strtxtCardCost = txtCardCost.Text.Trim();
        if (strtxtCardCost == "")
        {
            tdoTD_M_INSIDESTAFFPARAMETERIn.CARDCOST = -1;
        }
        else
            tdoTD_M_INSIDESTAFFPARAMETERIn.CARDCOST = Validation.getPrice(txtCardCost);

        //判断充值默认值是否为空，如果是就向表里插入-1，否则插入数值
        string strtxtSuppleMoney = txtSuppleMoney.Text.Trim();
        if (strtxtSuppleMoney == "")
        {
            tdoTD_M_INSIDESTAFFPARAMETERIn.SUPPLEMONEY = -1;
        }
        else
            tdoTD_M_INSIDESTAFFPARAMETERIn.SUPPLEMONEY = Validation.getPrice(txtSuppleMoney);
        

        TD_M_INSIDESTAFFPARAMETERTM tmTD_M_INSIDESTAFFPARAMETER = new TD_M_INSIDESTAFFPARAMETERTM();
        int RecordSum = tmTD_M_INSIDESTAFFPARAMETER.updRecord(context, tdoTD_M_INSIDESTAFFPARAMETERIn);
        
        //修改数据不成功显示错误信息
        if (RecordSum == 0)
        {
            context.AddError("S010002016");
            return;
        }
            
        //修改成功后提交
        context.DBCommit();

        lvwStaffParam.DataSource = CreateStaffQueryDataSource();
        lvwStaffParam.DataBind();

        AddMessage("M010002108");

    }
    protected void btnStaffParaDelete_Click(object sender, EventArgs e)
    {
        
        //对删除员工参数信息检验
        if (!StaffParaDeleteValidation()) return;

        //执行员工参数信息删除的过程
        TD_M_INSIDESTAFFPARAMETERTDO tdoTD_M_INSIDESTAFFPARAMETERIn = new TD_M_INSIDESTAFFPARAMETERTDO();

        tdoTD_M_INSIDESTAFFPARAMETERIn.STAFFNO = selStaffName2.SelectedValue;

        TD_M_INSIDESTAFFPARAMETERTM tmTD_M_INSIDESTAFFPARAMETER = new TD_M_INSIDESTAFFPARAMETERTM();
        int DeleteSum = tmTD_M_INSIDESTAFFPARAMETER.delDelete(context, tdoTD_M_INSIDESTAFFPARAMETERIn);

        //删除数据不成功显示错误信息
        if (DeleteSum == 0)
        {
            context.AddError("S010002017");
        }

        //删除成功后提交
        context.DBCommit();

        lvwStaffParam.DataSource = CreateStaffQueryDataSource();
        lvwStaffParam.DataBind();

        AddMessage("M010002109");

    }


}
