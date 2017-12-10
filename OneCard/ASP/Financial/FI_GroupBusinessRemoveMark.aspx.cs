using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TDO.Financial;
using Master;
using System.Data;
using TDO.UserManager;
using Common;
using PDO.PrivilegePR;
using TM;
using PDO.Financial;

/******************************
 * 团购业务取消录入
 * 2014-11-25
 * gl
 *****************************/
public partial class ASP_Financial_FI_GroupBusinessRemoveMark : Master.Master
{
    #region Initialization
    /// <summary>
    /// 初始化界面
    /// </summary>
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化商家
            InitDropDownList(context, selShop, "QUERYTRADETYPESHOP", "");

            InitializaDeptAndStaff();

           

            gvResult.DataSource = new DataTable();
            gvResult.DataBind();

            gvList.DataSource = new DataTable();
            gvList.DataBind();
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
    /// 权限验证
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
    /// 查询
    /// </summary>
    /// <returns>返回查询到的DataTable</returns>
    private DataTable QueryData()
    {
        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();

        pdo.funcCode = "QUERYGROUPBUYNOS";

        pdo.var1 = DateTime.Now.ToString("yyyyMMdd");
        pdo.var2 = DateTime.Now.ToString("yyyyMMdd");
        pdo.var3 = selStaff.SelectedValue;
        pdo.var4 = selDept.SelectedValue;

        pdo.var5 = selShop.SelectedValue;
        pdo.var6 = txtGroupBuyNo.Text;
        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        UserCardHelper.resetData(gvResult, data);
        gvList.DataSource = new DataTable();
        gvList.DataBind();
        return data;
    }
    #endregion

    #region Event Handler 
    /// <summary>
    /// 选择部门事件
    /// </summary>
    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selDept.SelectedValue);
    }
    /// <summary>
    /// 查询团购业务事件
    /// </summary>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (context.hasError()) return;

        DataTable data = QueryData();
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
    }
    /// <summary>
    /// 取消标记事件
    /// </summary>
    protected void btnRemove_Click(object sender, EventArgs e)
    {
        string msgCodes = "";//将勾选的团购劵号存入msgCodes字符串中
        string msgNames = "";//将勾选的团购商家存入msgNames字符串中
        int count = 0;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkGroupBuyCodeList");
            if (cb != null && cb.Checked)
            {
                count++;
                if (count == 1)
                {
                    msgCodes += gvr.Cells[1].Text;
                    msgNames += gvr.Cells[2].Text;
                }
                else
                {
                    msgCodes += "," + gvr.Cells[1].Text;
                    msgNames += "," + gvr.Cells[2].Text;
                }
            }
        }

        //请至少选中一条团购劵信息
        if (count == 0)
        {
            context.AddError("请至少选中一条团购劵信息！");
            return;
        }
        SP_FI_GroupBuyDelPDO pdo = new SP_FI_GroupBuyDelPDO();
        pdo.msgGroupCodes = msgCodes;
        pdo.msgGroupNames = msgNames;
        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (!ok)
        {
            AddMessage(pdoOut.retMsg);
        }
        else
        {
            QueryData();
            gvResult.SelectedIndex = -1;//取消选中
            AddMessage(string.Format("取消匹配{0}笔团购信息成功",count));
        }
    }

    /// <summary>
    /// 选择不同行
    /// </summary>
    protected void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (gvResult.SelectedIndex == -1)
            return;
        string groupBuyId = gvResult.SelectedRow.Cells[1].Text;
        string groupName = gvResult.SelectedRow.Cells[2].Text;
        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();

        pdo.funcCode = "QUERYGROUPBUYNOLINKTRADES";

        pdo.var1 = groupBuyId;
        pdo.var2 = groupName;
        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);
    

        UserCardHelper.resetData(gvList, data);
    }

    /// <summary>
    /// 注册行单击事件
    /// </summary>
    public void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    /// <summary>
    /// 分页
    /// </summary>
    protected void gvResult_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    #endregion
}