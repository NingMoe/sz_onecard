using System;
using System.Data;
using System.Web.UI;
using Common;
using Master;
using PDO.ProvisionNote;
using System.Web.UI.WebControls;
using PDO.Financial;
using TDO.UserManager;


/******************************
 * 团购业务报表
 * 2014-11-25
 * gl
 *****************************/
public partial class ASP_Financial_FI_GroupBusinessQuery : Master.ExportMaster
{
    #region Initialization
    /// <summary>
    /// 初始化界面
    /// </summary>
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtFromDate.Text = DateTime.Now.AddDays(-30).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Now.AddDays(-1).ToString("yyyyMMdd");

            InitializaDeptAndStaff();
            //初始化商家
            InitDropDownList(context, selShop, "QUERYTRADETYPESHOP", "");

            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
        }
    }
    #endregion 

    #region Private
    /// <summary>
    /// 初始化部门
    /// </summary>
    /// <returns></returns>
    private void InitializaDeptAndStaff()
    {
        if (HasOperPower("201008"))//全部网点主管
        {
            //初始化部门
            FIHelper.selectDept(context, selDept, true);
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
        else if (HasOperPower("201009"))//代理全网点主管 add by liuhe20120214添加对代理的权限处理
        {
            context.DBOpen("Select");
            string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
            string sql = @"SELECT  D.DEPARTNAME,D.DEPARTNO FROM TD_DEPTBAL_RELATION R,TD_M_INSIDEDEPART D 
                            WHERE R.DEPARTNO=D.DEPARTNO AND R.DBALUNITNO='" + dBalunitNo + "' AND R.USETAG='1'";
            DataTable table = context.ExecuteReader(sql);
            GroupCardHelper.fill(selDept, table, true);

            selDept.SelectedValue = context.s_DepartID;
            InitStaffList(context.s_DepartID);
            selStaff.SelectedValue = context.s_UserID;
        }
        else if (HasOperPower("201010"))//代理网点主管
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
    /// <summary>
    /// 验证权限
    /// </summary>
    /// <returns></returns>
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
    /// <summary>
    /// 刷新员工
    /// </summary>
    /// <returns></returns>
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
    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selDept.SelectedValue);
    }
    /// <summary>
    /// 初始化DropDownList
    /// </summary>
    /// <param name="context">全局帮助类</param>
    /// <param name="lst">需要绑定的下拉框</param>
    /// <param name="funcCode">存储过程对应方法</param>
    /// <param name="vars">参数</param>
    /// <returns></returns>
    public static void InitDropDownList(CmnContext context, DropDownList lst, string funcCode, params string[] vars)
    {
        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = funcCode;

        StoreProScene storePro = new StoreProScene();
        DataTable dt = storePro.Execute(context, pdo);

        FillDropDownList(lst, dt, true);
    }
    /// <summary>
    /// 填充DropDownList
    /// </summary>
    /// <param name="ddl">填充的下拉框</param>
    /// <param name="dt">填充表</param>
    /// <param name="empty">是否有全选项</param>
    public static void FillDropDownList(DropDownList ddl, DataTable dt, bool empty)
    {
        ddl.Items.Clear();

        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        Object[] itemArray;
        ListItem li;
        for (int i = 0; i < dt.Rows.Count; ++i)
        {
            itemArray = dt.Rows[i].ItemArray;
            li = new ListItem("" + (String)itemArray[1] + ":" + itemArray[0], (String)itemArray[1]);
            ddl.Items.Add(li);
        }
    }
    /// <summary>
    /// 查询时输入性验证
    /// </summary>
    /// <returns></returns>
    private void QueryValidate()
    {
        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtFromDate);
        bool b2 = Validation.isEmpty(txtToDate);
        DateTime? fromDate = null, toDate = null;
        if (b1 || b2)
            context.AddError("开始日期和结束日期必须填写");

        else
        {
            if (!b1)
                fromDate = valid.beDate(txtFromDate, "开始日期范围起始值格式必须为yyyyMMdd");
            if (!b2)

                toDate = valid.beDate(txtToDate, "结束日期范围终止值格式必须为yyyyMMdd");
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        }
    }
      /// <summary>
    /// 提示是否业务回退
    /// </summary>
    /// <returns></returns>
    private void ShowTradeRollBackMessage(DataTable data)
    {
        for (int i = 0; i < data.Rows.Count; i++)
        {
            if (selWay.SelectedValue == "0")//汇总
            {
                if (!string.IsNullOrEmpty(data.Rows[i][4].ToString()))
                {
                    AddMessage("有业务回退!");
                    break;
                }

            }
            else
            {
                if (!string.IsNullOrEmpty(data.Rows[i][11].ToString()))
                {
                    AddMessage("有业务回退!");
                    break;
                }
            }
        }
    }
    /// <summary>
    /// 返回cell
    /// </summary>
    /// <param name="cell">变量Cell</param>
    /// <returns>返回指定Cell的text值</returns>
    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }
    #endregion

    #region Event Handler
    /// <summary>
    /// 查询
    /// </summary>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        QueryValidate();
        if (context.hasError()) return;

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;
        pdo.var3 = selStaff.SelectedValue;
        pdo.var4 = selDept.SelectedValue;
        pdo.var5 = selShop.SelectedValue;
        if (selWay.SelectedValue == "0")//汇总
        {
            pdo.funcCode = "QUERYGROUPBUYREPORTS";
        }
        else//明细
        {
            pdo.funcCode = "QUERYGROUPBUYDETAILREPORTS";
        }
        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        UserCardHelper.resetData(gvResult, data);
        ShowTradeRollBackMessage(data);
        
    }
    /// <summary>
    /// 导出事件
    /// </summary>
    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            ExportGridView(gvResult);
            return;
        }
        context.AddMessage("查询结果为空，不能导出");

    }
    /// <summary>
    /// 分页事件
    /// </summary>
    /// <returns></returns>
    protected void gvResult_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }


    private double totalCharges = 0; //计算总共金额
    private int totalCount = 0;//计算关联笔数
    private double  seviceCharges = 0;//服务费和押金
    private double reCharges = 0;//充值
    private double counterFee = 0;//手续费
    private double functionFee = 0;//功能费
     /// <summary>
    /// RowDataBound
    /// </summary>
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        //提示栏不显示，回退时标注红色
        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Footer)
        {
            if (selWay.SelectedValue == "0")//汇总
            {
                e.Row.Cells[4].Visible = false;
                if (e.Row.Cells[4].Text == "该业务已回退")
                    e.Row.ForeColor = System.Drawing.Color.Red;
            }
            else
            {
                e.Row.Cells[11].Visible = false;
                if (e.Row.Cells[11].Text == "该业务已回退")
                    e.Row.ForeColor = System.Drawing.Color.Red;
            }
        }
        //汇总过程
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (selWay.SelectedValue == "0")//汇总
            {
                totalCharges += Convert.ToDouble(GetTableCellValue(e.Row.Cells[2]));
                totalCount += Convert.ToInt32(GetTableCellValue(e.Row.Cells[3]));
            }
            else
            {
                seviceCharges += Convert.ToDouble(GetTableCellValue(e.Row.Cells[7]));
                reCharges += Convert.ToDouble(GetTableCellValue(e.Row.Cells[8]));
                counterFee += Convert.ToDouble(GetTableCellValue(e.Row.Cells[9]));
                functionFee += Convert.ToDouble(GetTableCellValue(e.Row.Cells[10]));
            }
        }
        //汇总结果
        if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            if (selWay.SelectedValue == "0")//汇总
            {
                e.Row.Cells[0].Text = "总计";
                e.Row.Cells[2].Text = totalCharges.ToString("n");
                e.Row.Cells[3].Text = totalCount.ToString();
            }
            if (selWay.SelectedValue == "1")//明细
            {
                e.Row.Cells[0].Text = "总计";
                e.Row.Cells[7].Text = seviceCharges.ToString("n");
                e.Row.Cells[8].Text = reCharges.ToString("n");
                e.Row.Cells[9].Text = counterFee.ToString("n");
                e.Row.Cells[10].Text = functionFee.ToString("n");
            }
        }
    }

    
    #endregion

}
