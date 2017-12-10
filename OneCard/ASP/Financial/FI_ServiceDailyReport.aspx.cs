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
using PDO.Financial;
using Master;
using Common;
using TM;
using TDO.UserManager;
using TDO.Financial;
using TDO.BusinessCode;

public partial class ASP_Financial_FI_ServiceDailyReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化业务  

            selDeptBalType.Items.Add(new ListItem("---请选择---", ""));
            selDeptBalType.Items.Add(new ListItem("代理网点", "1"));
            selDeptBalType.Items.Add(new ListItem("直营网点", "0"));
            selDeptBalType.SelectedValue = "";
            txtFromDate.Text = DateTime.Today.ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");

            InitDeptList();
            selDept.Items.Add(new ListItem("---请选择---", ""));
            selDept.SelectedValue = "";
            #region 注释
            //            if (HasOperPower("201008"))//全部网点主管
            //            {
            //                //初始化部门


            //                TMTableModule tmTMTableModule = new TMTableModule();
            //                TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
            //                TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
            //                ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
            //                selDept.SelectedValue = context.s_DepartID;
            //                InitStaffList(context.s_DepartID);
            //                //selStaff.SelectedValue = context.s_UserID;
            //            }
            //            else if (HasOperPower("201007"))//网点主管
            //            {
            //                selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
            //                selDept.SelectedValue = context.s_DepartID;
            //                selDept.Enabled = false;

            //                InitStaffList(context.s_DepartID);
            //                //selStaff.SelectedValue = context.s_UserID;
            //            }
            //            else if (HasOperPower("201009"))//代理全网点主管 add by liuhe20120214添加对代理的权限处理
            //            {
            //                context.DBOpen("Select");
            //                string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
            //                string sql = @"SELECT  D.DEPARTNAME,D.DEPARTNO FROM TD_DEPTBAL_RELATION R,TD_M_INSIDEDEPART D 
            //                            WHERE R.DEPARTNO=D.DEPARTNO AND R.DBALUNITNO='" + dBalunitNo + "' AND R.USETAG='1'";
            //                DataTable table = context.ExecuteReader(sql);
            //                GroupCardHelper.fill(selDept, table, true);

            //                selDept.SelectedValue = context.s_DepartID;
            //                InitStaffList(context.s_DepartID);
            //                //selStaff.SelectedValue = context.s_UserID;
            //            }
            //            else if (HasOperPower("201010"))//代理网点主管
            //            {
            //                selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
            //                selDept.SelectedValue = context.s_DepartID;
            //                selDept.Enabled = false;

            //                InitStaffList(context.s_DepartID);
            //                //selStaff.SelectedValue = context.s_UserID;
            //            }
            //            else//网点营业员


            //            {
            //                selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
            //                selDept.SelectedValue = context.s_DepartID;
            //                selDept.Enabled = false;

            //                //selStaff.Items.Add(new ListItem(context.s_UserID + ":" + context.s_UserName, context.s_UserID));
            //                //selStaff.SelectedValue = context.s_UserID;
            //                //selStaff.Enabled = false;
            //            }
            #endregion
        }
    }

    #region 注释
    //private bool HasOperPower(string powerCode)
    //{
    //    //TMTableModule tmTMTableModule = new TMTableModule();
    //    TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
    //    string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
    //    DataTable dataSupply = tm.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
    //    if (dataSupply.Rows.Count > 0)
    //        return true;
    //    else
    //        return false;
    //}


    //    private void InitStaffList(string deptNo)
    //    {
    //        if (deptNo == "")
    //        {
    //            string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
    //            if (dBalunitNo != "")//add by liuhe20120214添加对代理的权限处理
    //            {
    //                context.DBOpen("Select");

    //                string sql = @"SELECT STAFFNAME,STAFFNO FROM TD_M_INSIDESTAFF 
    //                             WHERE DIMISSIONTAG ='1' AND  DEPARTNO IN 
    //                            (SELECT DEPARTNO FROM TD_DEPTBAL_RELATION WHERE DBALUNITNO='" + dBalunitNo + "' AND USETAG='1')";
    //                DataTable table = context.ExecuteReader(sql);
    //                GroupCardHelper.fill(selStaff, table, true);

    //                return;
    //            }

    //            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
    //            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

    //            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "");
    //            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
    //            selStaff.SelectedValue = context.s_UserID;
    //        }
    //        else
    //        {
    //            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
    //            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
    //            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

    //            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
    //            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
    //        }
    //    }
    #endregion

    //protected void selDept_Changed(object sender, EventArgs e)
    //{
    //    InitStaffList(selDept.SelectedValue);
    //}

    private void InitDeptList()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
        TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
        ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
        selDept.SelectedValue = context.s_DepartID;
    }

    //选择网点类型后更换部门列表

    protected void selDeptBalType_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(selDeptBalType.SelectedValue))
        {
            InitDeptList();
            selDept.SelectedValue = "";
        }

        else if (selDeptBalType.SelectedValue.Equals("1"))
        {
            context.DBOpen("Select");
            string sql = @"SELECT  D.DEPARTNAME,D.DEPARTNO FROM TD_DEPTBAL_RELATION R,TD_M_INSIDEDEPART D 
                            WHERE R.DEPARTNO=D.DEPARTNO AND R.USETAG='" + selDeptBalType.SelectedValue + "' ORDER BY D.DEPARTNO";
            DataTable table = context.ExecuteReader(sql);
            GroupCardHelper.fill(selDept, table, true);
            selDept.SelectedValue = "";
        }
        else
        {
            context.DBOpen("Select");
            string sql = @"SELECT M.DEPARTNAME,M.DEPARTNO FROM TD_M_INSIDEDEPART M 
                            WHERE M.DEPARTNO NOT IN (SELECT R.DEPARTNO FROM TD_DEPTBAL_RELATION R WHERE R.USETAG='1') ORDER BY M.DEPARTNO";
            DataTable table = context.ExecuteReader(sql);
            GroupCardHelper.fill(selDept, table, true);
            selDept.SelectedValue = "";
        }
    }

    private Int32[] totalChargs = new Int32[9];
    private double[] totalMoney = new double[2];

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        e.Row.Cells[0].Visible = false;
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            totalChargs[1] +=Convert.ToInt32(GetTableCellValue(e.Row.Cells[2]));
            totalChargs[2] += Convert.ToInt32(GetTableCellValue(e.Row.Cells[3]));
            totalChargs[3] += Convert.ToInt32(GetTableCellValue(e.Row.Cells[4]));
            totalChargs[4] += Convert.ToInt32(GetTableCellValue(e.Row.Cells[5]));
            totalChargs[5] += Convert.ToInt32(GetTableCellValue(e.Row.Cells[6]));
            totalChargs[6] += Convert.ToInt32(GetTableCellValue(e.Row.Cells[7]));
            totalChargs[7] += Convert.ToInt32(GetTableCellValue(e.Row.Cells[8]));
            totalChargs[8] += Convert.ToInt32(GetTableCellValue(e.Row.Cells[9]));

            totalMoney[0] += Convert.ToDouble(GetTableCellValue(e.Row.Cells[10]));
            totalMoney[1] += Convert.ToDouble(GetTableCellValue(e.Row.Cells[11]));
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[1].Text = "总计";
            e.Row.Cells[2].Text = totalChargs[1].ToString();
            e.Row.Cells[3].Text = totalChargs[2].ToString();
            e.Row.Cells[4].Text = totalChargs[3].ToString(); 
            e.Row.Cells[5].Text = totalChargs[4].ToString();
            e.Row.Cells[6].Text = totalChargs[5].ToString();
            e.Row.Cells[7].Text = totalChargs[6].ToString();
            e.Row.Cells[8].Text = totalChargs[7].ToString();
            e.Row.Cells[9].Text = totalChargs[8].ToString();

            e.Row.Cells[10].Text = totalMoney[0].ToString("n");
            e.Row.Cells[11].Text = totalMoney[1].ToString("n");
        }
    }

    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }

    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header)
        {
            GridViewRow rowHeader = new GridViewRow(0, 0, DataControlRowType.Header, DataControlRowState.Normal);
            TableCellCollection cells = e.Row.Cells;
            TableCell headerCell = new TableCell();
            headerCell.Text = "";
            //headerCell.RowSpan = 1;
            //headerCell.ColumnSpan = 1;
            rowHeader.Cells.Add(headerCell);

            headerCell = new TableCell();
            headerCell.Text = "售卡数量";
            //headerCell.ColumnSpan = 3;
            rowHeader.Cells.Add(headerCell);

            headerCell = new TableCell();
            headerCell.Text = "";
            //headerCell.ColumnSpan = 5;
            rowHeader.Cells.Add(headerCell);
            rowHeader.CssClass = "tabbt";
            rowHeader.Cells[0].ColumnSpan = 4;
            //rowHeader.Cells[0].RowSpan = 2;
            rowHeader.Cells[1].ColumnSpan = 4;
            rowHeader.Cells[2].ColumnSpan = 3;
            rowHeader.Cells[0].VerticalAlign = VerticalAlign.Middle;
            rowHeader.Cells[0].HorizontalAlign = HorizontalAlign.Center;
            rowHeader.Cells[1].VerticalAlign = VerticalAlign.Middle;
            rowHeader.Cells[1].HorizontalAlign = HorizontalAlign.Center;
            rowHeader.Cells[2].VerticalAlign = VerticalAlign.Middle;
            rowHeader.Cells[2].HorizontalAlign = HorizontalAlign.Center;
            rowHeader.Visible = true;
            gvResult.Controls[0].Controls.AddAt(0, rowHeader);
        }
    }

    // 查询输入校验处理
    private void validate()
    {
        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtFromDate);
        bool b2 = Validation.isEmpty(txtToDate);
        DateTime? fromDate = null, toDate = null;
        if (b1 || b2)
        {
            context.AddError("开始日期和结束日期必须填写");
        }
        else
        {
            if (!b1)
            {
                fromDate = valid.beDate(txtFromDate, "开始日期范围起始值格式必须为yyyyMMdd");
            }
            if (!b2)
            {
                toDate = valid.beDate(txtToDate, "结束日期范围终止值格式必须为yyyyMMdd");
            }
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        }

        //if (selStaff.SelectedValue == "")
        //    context.AddError("请选择员工");

    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "ServiceDailyReport";
        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;
        pdo.var3 = selDeptBalType.SelectedValue;
        pdo.var4 = selDept.SelectedValue;


        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        UserCardHelper.resetData(gvResult, data);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            ExportGridView(gvResult);
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }

}
