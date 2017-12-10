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
using TDO.UserManager;
//udpated:2011-05-25.更新人：wdx,更新内容：增加录入人员查询条件，
public partial class ASP_TaxiService_TS_ConsumeAppendQry : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
        //初始化部门

        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
        TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
        ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
        selDept.SelectedValue = context.s_DepartID;
        InitStaffList(context.s_DepartID);
        selStaff.SelectedValue = context.s_UserID;
    }


    private void InitStaffList(string deptNo)
    {
        if (deptNo == "")
        {
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


    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        //分页显示事件
        gvResult.PageIndex = e.NewPageIndex;
        UserCardHelper.resetData(gvResult, QueryInfo());
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {

    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            gvResult.AllowPaging = false;
            DataTable dt = QueryInfo();
            UserCardHelper.resetData(gvResult, dt);
            ExportGridView(gvResult);
            gvResult.AllowPaging = true;
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }


    private DataTable QueryInfo()
    {
        //从出租消费正常清单查询表(TQ_TAXI_RIGHT)中读取数据

        return SPHelper.callTSQuery(context, "TaxiAppendQuery", txtStaffNoExt.Text,
            txtBeginDate.Text, txtEndDate.Text,selStaff.SelectedValue);
    }

    private void QueryValidationFalse()
    {
        //对司机工号非空,数字,长度的检测

        txtStaffNoExt.Text = txtStaffNoExt.Text.Trim();
        string strStaffNo = txtStaffNoExt.Text;
        if (Validation.strLen(strStaffNo) != 0)
        {
            if (!Validation.isNum(strStaffNo))
                context.AddError("A003100002", txtStaffNoExt);
            else if (Validation.strLen(strStaffNo) != 6)
                context.AddError("A003100003", txtStaffNoExt);
        }

        //对起始和终止日期的校验

        UserCardHelper.validateDateRange(context, txtBeginDate, txtEndDate, false);
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        QueryValidationFalse();

        if (context.hasError()) return;

        UserCardHelper.resetData(gvResult, QueryInfo());
    }

}
