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
using Common;
using TM;
using PDO.GroupCard;
using TDO.UserManager;

// 企服卡开卡审批




public partial class ASP_GroupCard_SZ_OrderSearchOld : Master.ExportMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        InitStatus();

        //初始化部门

        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
        TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
        ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
        selDept.SelectedValue = context.s_DepartID;
        InitStaffList(context.s_DepartID);
        selStaff.SelectedValue = context.s_UserID;

        gvOrderList.DataKeyNames = new string[] { "ORDERNO", "GROUPNAME", "NAME", "PHONE", "IDCARDNO", "TOTALMONEY", "TRANSACTOR", "INPUTTIME", "REMARK", "FINANCEREMARK", "INVOICECOUNT", "INVOICETOTALMONEY", "TOTALCHARGECASHGIFT", "approver" };

        if (HasOperPower("201012")) //如果是部门主管，add by shil,20120604
        {
            //可以查看本部门员工

            selStaff.Enabled = true;
        }
        if (HasOperPower("201013")) //如果是公司主管，add by shil,20120604
        {
            //可以查看所有记录

            selStaff.Enabled = true;
            selDept.Enabled = true;
        }



    }

    private bool HasOperPower(string powerCode)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
        string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
        DataTable dataSupply = tmTMTableModule.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
        if (dataSupply.Rows.Count > 0)
            return true;
        else
            return false;
    }

    private void InitStatus()
    {
        selApprovalStatus.Items.Add(new ListItem("0:未审批", "0"));
        selApprovalStatus.Items.Add(new ListItem("1:审批通过", "1"));
        selApprovalStatus.Items.Add(new ListItem("2:审批作废", "2"));
        selApprovalStatus.SelectedValue = "1";
    }

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

    protected void gvOrderList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string orderno = ((GridView)sender).DataKeys[e.Row.RowIndex]["ORDERNO"].ToString();
            //string groupName = ((GridView)sender).DataKeys[e.Row.RowIndex]["GROUPNAME"].ToString();
            //string name = ((GridView)sender).DataKeys[e.Row.RowIndex]["NAME"].ToString();
            //string phone = ((GridView)sender).DataKeys[e.Row.RowIndex]["PHONE"].ToString();
            //string idCardNo = ((GridView)sender).DataKeys[e.Row.RowIndex]["IDCARDNO"].ToString();
            //string totalMoney = ((GridView)sender).DataKeys[e.Row.RowIndex]["TOTALMONEY"].ToString();
            //string transactor = ((GridView)sender).DataKeys[e.Row.RowIndex]["TRANSACTOR"].ToString();
            //string remark = ((GridView)sender).DataKeys[e.Row.RowIndex]["REMARK"].ToString();
            //string financeRemark = ((GridView)sender).DataKeys[e.Row.RowIndex]["FINANCEREMARK"].ToString();
            //string invoiceCount = ((GridView)sender).DataKeys[e.Row.RowIndex]["INVOICECOUNT"].ToString();
            //string invoiceTotalMoney = ((GridView)sender).DataKeys[e.Row.RowIndex]["INVOICETOTALMONEY"].ToString();
            //string totalCashGiftChargeMoney = ((GridView)sender).DataKeys[e.Row.RowIndex]["TOTALCHARGECASHGIFT"].ToString();
            //string approver = ((GridView)sender).DataKeys[e.Row.RowIndex]["approver"].ToString();
            Button btnPrint = (Button)e.Row.FindControl("btnPrint");

            //DataTable dt = GroupCardHelper.callOrderQuery(context, "AllOrderInfoSelectByOrderNoOld", orderno);

            btnPrint.Attributes.Add("onclick",
                "CreateWindow('RoleWindow','GC_OrderPrintOld.aspx?orderno=" + orderno.Trim() + "    " + "',null,0);return false;");
            Button btnUpdate = (Button)e.Row.FindControl("btnUpdate");
            btnUpdate.Attributes.Add("onclick",
                "CreateWindow('RoleWindow','GC_OrderInfoModifyOld.aspx?orderno=" + orderno.Trim() + "');return false;");
        }
    }

    public String getDataKeys2(String keysname)
    {
        return gvOrderList.DataKeys[gvOrderList.SelectedIndex][keysname].ToString();
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        string groupName = txtGroupName.Text.Trim();
        string name = txtName.Text.Trim();
        string staff = "";
        if (selStaff.SelectedIndex > 0)
        {
            staff = selStaff.SelectedValue;
        }
        string money = "";
        if (txtTotalMoney.Text.Trim().Length > 0)
        {
            money = (Convert.ToDecimal(txtTotalMoney.Text.Trim()) * 100).ToString();
        }
        string fromDate = txtFromDate.Text.Trim();
        string endDate = txtToDate.Text.Trim();

        DataTable dt = GroupCardHelper.callOrderQuery(context, "AllOrderInfoSelectOld", groupName, name, staff, money, fromDate, endDate, selApprovalStatus.SelectedValue, selDept.SelectedValue);
        if (dt == null || dt.Rows.Count < 1)
        {
            gvOrderList.DataSource = new DataTable();
            gvOrderList.DataBind();
            context.AddError("未查出订单记录");
            return;
        }
        gvOrderList.DataSource = dt;
        gvOrderList.DataBind();
        if (Session["ok"] != null)
        {
            bool ok = Convert.ToBoolean(Session["ok"]);
            if (ok)
            {
                AddMessage("修改成功");
                Session["ok"] = null;
            }
        }
    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvOrderList.Rows.Count > 0)
        {
            gvOrderList.Columns[0].Visible = false;
            ExportGridView(gvOrderList);
            gvOrderList.Columns[0].Visible = true;

        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }
}
