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
using TM;
using TDO.ConsumeBalance;
using TDO.BalanceChannel;
using TDO.UserManager;
using Common;
using PDO.SpecialDeal;

public partial class ASP_SpecialDeal_SD_AutoTransferRecycle : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        //首次访问页面初始化

        if (!Page.IsPostBack)
        {
            //初始化行业名称

            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
            TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), "S008100211", "TD_M_CALLINGNO", null);

            ControlDeal.SelectBoxFill(selCalling.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);

            //初始查询待回收的转账账单信息信息
            //InitQueryTaxiAppInfo();
            gvResult.DataSource =new DataTable();
            gvResult.DataBind();

        }
    }


    private void clearTempTable()//清空临时表
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON where f1='"
            + Session.SessionID + "'");
        context.ExecuteNonQuery("delete from TMP_COMMON where f1='"
                    + Session.SessionID + "'");
        context.DBCommit();
    }


    public void InitQueryTaxiAppInfo()
    {
        //查补录后,待回收的转账账单信息
        gvResult.DataSource = QueryResultColl();
        gvResult.DataBind();

    }

    public ICollection QueryResultColl()
    {
        //查询待回收的转账账单信息
        // TF_B_TRADE_ACPMANUAL
        DataTable data = SPHelper.callSDQuery(context, "AutoTraAppendQuery", txtCardNo.Text, txtBalUnitNo.Text, txtStartDate.Text, txtEndDate.Text, selCalling.SelectedValue, selCorp.SelectedValue, selDepart.SelectedValue);

        return new DataView(data);
    }

    private bool QueryValidation()
    {
        //对开始日期和结束日期的判断
        UserCardHelper.validateDateRange(context, txtStartDate, txtEndDate, false);
        //对非空卡号长度数字的判断
        UserCardHelper.validateCardNo(context, txtCardNo, true);

        // 校验结算单元编码格式(8位英数)
        UserCardHelper.validateBalUnitNo(context, txtBalUnitNo, true);

        return context.hasError();
    }

    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        //分页显示事件
        gvResult.PageIndex = e.NewPageIndex;
        InitQueryTaxiAppInfo();
    }


    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        //补录数据行显示处理

        //if (e.Row.RowType == DataControlRowType.DataRow)
        //{
        //    //ControlDeal.RowDataBound(e);
        //    string staterr = e.Row.Cells[17].Text;
        //    e.Row.Cells[17].Text = getStaterr(staterr);
        //    string state = e.Row.Cells[19].Text;
        //    e.Row.Cells[19].Text = getState(state);
        //}

        if (e.Row.RowType == DataControlRowType.Header
            || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[0].Visible = false;
        }

    }

    //private string getStaterr(string code)
    //{
    //    if (code == "1")
    //        return "1：灰记录";
    //    if (code == "2")
    //        return "2：TAC校验错误非灰记录";
    //    if (code == "6")
    //        return "6：过期数据";
    //    if (code == "7")
    //        return "7：其他数据";
    //    if (code == "8")
    //        return "8：PSAM卡非法";
    //    if (code == "9")
    //        return "9：终端号非法";
    //    if (code == "A")
    //        return "A：POS和SAM不匹配";
    //    if (code == "B")
    //        return "B：缺少结算单元编码";
    //    if (code == "C")
    //        return "C：缺少卡号";
    //    if (code == "Z")
    //        return "Z：已经人工补全结算单元";
    //    return "";
    //}

    //private string getState(string code)
    //{
    //    if (code == "0")
    //        return "0：异常记录直接回收";
    //    if (code == "1")
    //        return "1：异常记录修改后回收";
    //    if (code == "2")
    //        return "2：人工输入交易记录";
    //    return "";
    //}

    protected void CheckAll(object sender, EventArgs e)
    {
        //全选信息记录

        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            if (!gvr.Cells[1].Enabled) continue;
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }

    protected void selCalling_SelectedIndexChanged(object sender, EventArgs e)
    {

        //选择行业名称后处理

        if (selCalling.SelectedValue == "")
        {
            selCorp.Items.Clear();
            selDepart.Items.Clear();
            return;
        }
        else
        {
            //初始化该行业下的单位名称
            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
            tdoTD_M_CORPIn.CALLINGNO = selCalling.SelectedValue;

            TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, "TD_M_CORPCALLUSAGE", null);
            ControlDeal.SelectBoxFill(selCorp.Items, tdoTD_M_CORPOutArr, "CORP", "CORPNO", true);
        }
    }

    protected void selCorp_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择单位名称后处理

        if (selCorp.SelectedValue == "")
        {
            selDepart.Items.Clear();
            return;
        }
        else
        {
            //初始化该单位下的部门名称
            TMTableModule tmTMTableModule = new TMTableModule();

            TD_M_DEPARTTDO tdoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
            tdoTD_M_DEPARTIn.CORPNO = selCorp.SelectedValue;

            TD_M_DEPARTTDO[] tdoTD_M_DEPARTOutArr = (TD_M_DEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null, "TD_M_DEPARTUSAGE", null);
            ControlDeal.SelectBoxFill(selDepart.Items, tdoTD_M_DEPARTOutArr, "DEPART", "DEPARTNO", true);
        }
    }


    private bool RecordIntoTmp()
    {
        //回收记录入临时表
        context.DBOpen("Insert");

        //int count = 0;
        //int seq = 0;
        //int tradeid = 0;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                //++count;
                context.ExecuteNonQuery("insert into TMP_COMMON (f0,f1) values('"+
                     gvr.Cells[0].Text + "', '" + Session.SessionID + "')");
            }
        }

        context.DBCommit();

        // 没有选中任何行，则返回错误


        return true;
    }

    //private bool ValidationInput()
    //{
    //    //对非空回收说明的长度校验
    //    if (txtRenewRemark.Text.Trim() != "" && Validation.strLen(txtRenewRemark.Text.Trim()) > 150)
    //    {
    //        context.AddError("A009103023", txtRenewRemark);
    //        return false;
    //    }
    //    return true;

    //}

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //调用查询输入的判处理
        if (QueryValidation())
        {
            return;
        }

        InitQueryTaxiAppInfo();
    }

    protected void submitConfirm_Click(object sender, EventArgs e)
    {
        int checkednum = 0;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++checkednum;
            }
        }
        if (checkednum <= 0)
        {
            context.AddError("A009104002");
        }
        else
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "AdjustScript", "submitConfirm('" + checkednum + "');", true);
        }
    }



    protected void btnRecycle_Click(object sender, EventArgs e)
    {
        //清空临时表信息

        clearTempTable();

        //选择回收的记录入临时表

        if (!RecordIntoTmp()) return;

        //回收说明长度的校验

        //if (!ValidationInput()) return;

        //调用回收处理的存储过程

        SP_SD_AutoTransferRecyclePDO pdo = new SP_SD_AutoTransferRecyclePDO();
        pdo.sessionID = Session.SessionID;

        bool ok = TMStorePModule.Excute(context, pdo);
        //bool ok = true;
        if (ok)
        {
            //转账账单信息回收成功
            AddMessage("M009104006"); 
        }

        //查询补录信息
        InitQueryTaxiAppInfo();

    }

}
