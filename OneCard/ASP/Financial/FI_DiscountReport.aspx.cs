using System;
using System.Data;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using PDO.PartnerShip;
using TDO.BalanceChannel;
using TDO.UserManager;
using TM;
using TDO.BalanceParameter;
using System.IO;
using System.Web;
using System.Text;
using NPOI.HSSF.UserModel;

public partial class ASP_Financial_FI_DiscountReport :  Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
        UserCardHelper.resetData(gvResult, null);
        TMTableModule tmTMTableModule = new TMTableModule();
        //初始化查询输入的行业名称下拉列表框


        //从行业编码表(TD_M_CALLINGNO)中读取数据，放入查询输入行业名称下拉列表中
        TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
        TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), "S008100213", "TD_M_CALLINGNO_DISCOUNT", null);

        ControlDeal.SelectBoxFillWithCode(selCalling.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);

        txtBeginDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
        txtEndDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");

    }

    public void lvwBalUnits_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);

    }
    protected void selCalling_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择查询的行业名称后,初始化单位名称,初始化结算单元名称
        selCorp.Items.Clear();
        selDepart.Items.Clear();
        selBalUint.Items.Clear();

        InitCorp(selCalling, selCorp, "TD_M_CORPCALLUSAGE_DISCOUNT");//加载存在优惠方案的单位名称

        //初始化结算单元(属于选择行业)名称下拉列表值


        InitBalUnit("00", selCalling);

    }
    protected void selCorp_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择查询的单位名称后,初始化部门名称,初始化结算单元名称



        //选定单位后,设置部门下拉列表数据
        if (selCorp.SelectedValue == "")
        {
            selDepart.Items.Clear();
            InitBalUnit("00", selCalling);
            return;
        }
        //初始化单位下的部门信息
        InitDepart(selCorp, selDepart, "TD_M_DEPARTUSAGE_DISCOUNT");
        //初始化结算单元(属于选择单位)名称下拉列表值


        InitBalUnit("01", selCorp);


    }
    protected void selDepart_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择查询的部门名称后,初始化结算单元名称



        //选定单位后,设置部门下拉列表数据
        if (selDepart.SelectedValue == "")
        {
            InitBalUnit("01", selCorp);
            return;
        }

        //初始化结算单元(属于选择部门)名称下拉列表值


        InitBalUnit("02", selDepart);

    }
    protected void InitCorp(DropDownList origindwls, DropDownList extdwls, String sqlCondition)
    {
        // 从单位编码表(TD_M_CORP)中读取数据，放入增加,修改区域中单位信息下拉列表中

        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
        tdoTD_M_CORPIn.CALLINGNO = origindwls.SelectedValue;

        TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, sqlCondition, null);
        ControlDeal.SelectBoxFillWithCode(extdwls.Items, tdoTD_M_CORPOutArr, "CORP", "CORPNO", true);
    }
    private void InitDepart(DropDownList origindwls, DropDownList extdwls, String sqlCondition)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //从部门编码表(TD_M_CDEPART)中读取数据，放入下拉列表中



        TD_M_DEPARTTDO tdoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
        tdoTD_M_DEPARTIn.CORPNO = origindwls.SelectedValue;

        TD_M_DEPARTTDO[] tdoTD_M_DEPARTOutArr = (TD_M_DEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null, sqlCondition, null);
        ControlDeal.SelectBoxFillWithCode(extdwls.Items, tdoTD_M_DEPARTOutArr, "DEPART", "DEPARTNO", true);
    }
    private void InitBalUnit(string balType, DropDownList dwls)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_TRADE_BALUNITTDO tdoTF_TRADE_BALUNITIn = new TF_TRADE_BALUNITTDO();
        TF_TRADE_BALUNITTDO[] tdoTF_TRADE_BALUNITOutArr = null;

        //查询选定行业下的结算单元
        if (balType == "00")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_CALLING_DISCOUNT", null);
        }

        //查询选定单位下的结算单元
        else if (balType == "01")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = selCalling.SelectedValue;
            tdoTF_TRADE_BALUNITIn.CORPNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_CORP_DISCOUNT", null);
        }

        //查询选定部门下的结算单元
        else if (balType == "02")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = selCalling.SelectedValue;
            tdoTF_TRADE_BALUNITIn.CORPNO = selCorp.SelectedValue;
            tdoTF_TRADE_BALUNITIn.DEPARTNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_DEPART_DISCOUNT", null);
        }

        ControlDeal.SelectBoxFill(selBalUint.Items, tdoTF_TRADE_BALUNITOutArr, "BALUNIT", "BALUNITNO", true);
    }
    // 查询输入校验处理
    private void validate()
    {
        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtBeginDate);
        bool b2 = Validation.isEmpty(txtEndDate);
        DateTime? fromDate = null, toDate = null;

        if (!b1)
        {
            fromDate = valid.beDate(txtBeginDate, "开始日期范围起始值格式必须为yyyyMMdd");
        }
        if (!b2)
        {
            toDate = valid.beDate(txtEndDate, "结束日期范围终止值格式必须为yyyyMMdd");
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        }


    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {

        validate();
        if (context.hasError()) return;
        hidBeginDate.Value = txtBeginDate.Text.ToString().Trim();
        hidEndDate.Value = txtEndDate.Text.ToString().Trim();
        //优惠商户转账信息
        DataTable data = SPHelper.callPSQuery(context, "QueryDiscountReport", selCalling.SelectedValue,
            selCorp.SelectedValue, selDepart.SelectedValue, selBalUint.SelectedValue,
           txtBeginDate.Text, txtEndDate.Text,selType.SelectedValue);
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        UserCardHelper.resetData(gvResult, data);


    }

    private double totalSupplys = 0;    //充值

    private double totalConsums = 0;    //交易总金额
    private double totalDiscounts = 0;    //折扣
    private double totalRefunds = 0;    //退款总金额
    private double totalRefundDiscounts = 0; //退款折扣
    private double totalTradeMoney = 0;    //消费金额

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            totalConsums += Convert.ToDouble(GetTableCellValue(e.Row.Cells[11]));
            totalDiscounts += Convert.ToDouble(GetTableCellValue(e.Row.Cells[7]));
            totalRefunds += Convert.ToDouble(GetTableCellValue(e.Row.Cells[8]));
            totalRefundDiscounts += Convert.ToDouble(GetTableCellValue(e.Row.Cells[9]));
            totalTradeMoney += Convert.ToDouble(GetTableCellValue(e.Row.Cells[10]));
     

        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[11].Text = totalConsums.ToString("n");
            e.Row.Cells[7].Text = totalDiscounts.ToString("n");
            e.Row.Cells[8].Text = totalRefunds.ToString("n");
            e.Row.Cells[9].Text = totalRefundDiscounts.ToString("n");
            e.Row.Cells[10].Text = totalTradeMoney.ToString("n");
       
        }
    }
    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
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
    private void validate2()
    {
        //判断凭证日期是否为同一天

        if (txtBeginDate.Text != txtEndDate.Text)
        {
            context.AddError("查询日期不是同一天，凭证导出必须为日结");
        }

        ////对财务转账类型进行非空检验

        //if (selTrans.SelectedValue == "")
        //{
        //    context.AddError("请先选择财务转账类型", selTrans);
        //}
    }
    private bool checkEndDate()
    {
        TP_DEALTIMETDO tdoTP_DEALTIMEIn = new TP_DEALTIMETDO();
        TP_DEALTIMETDO[] tdoTP_DEALTIMEOutArr = (TP_DEALTIMETDO[])tm.selByPKArr(context, tdoTP_DEALTIMEIn, typeof(TP_DEALTIMETDO), null, "DEALTIME", null);
        if (tdoTP_DEALTIMEOutArr.Length == 0)
        {
            context.AddError("没有找到有效的结算处理时间");
            return false;
        }
        else
        {
            DateTime dealDate = tdoTP_DEALTIMEOutArr[0].DEALDATE.Date;
            DateTime endDate = DateTime.ParseExact(txtEndDate.Text.Trim(), "yyyyMMdd", null);
            if (endDate.CompareTo(dealDate) >= 0)
            {
                context.AddError("结束日期过大，未结算");
                return false;
            }
        }
        return true;
    }
    
    
}