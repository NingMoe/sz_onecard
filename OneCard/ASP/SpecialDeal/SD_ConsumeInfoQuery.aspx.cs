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
using TDO.BalanceChannel;
using TDO.ConsumeBalance;
using Common;
using PDO.SpecialDeal;

public partial class ASP_SpecialDeal_SD_ConsumeInfoQuery : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        //消费清单信息列表表头
        showConGridView();

        //初始化行业名称
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
        TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), "S008100211", "TD_M_CALLINGNO", null);

        ControlDeal.SelectBoxFill(selCalling.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);
    }

    public void lvwConsumeInfo_Page(Object sender, GridViewPageEventArgs e)
    {
        //分页事件
        lvwConsumeInfo.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    protected void selCalling_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择行业后,初始化单位信息        if (selCalling.SelectedValue == "")
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
        //选择单位后,初始化部门信息        if (selCorp.SelectedValue == "")
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

    private bool QueryValidation()
    {
        //对起始和终止日期的校验
        UserCardHelper.validateDateRange(context, txtStartDate, txtEndDate, true);

        //对非空POS编号长度数字类型的校验
        txtPosNo.Text = txtPosNo.Text.Trim();
        string strPosNo = txtPosNo.Text;
        if (strPosNo != "")
        {
            if (Validation.strLen(strPosNo) > 6)
                context.AddError("A009100003", txtPosNo);
            else if (!Validation.isNum(strPosNo))
                context.AddError("A009100004", txtPosNo);
        }

        //对非空PSAM编号长度英数字的判断
        txtPasmNo.Text = txtPasmNo.Text.Trim();
        string strPsamNo = txtPasmNo.Text.Trim();
        if (strPsamNo != "")
        {
            if (Validation.strLen(strPsamNo) != 12)
                context.AddError("A009100001", txtPasmNo);
            else if (!Validation.isCharNum(strPsamNo))
                context.AddError("A009100002", txtPasmNo);
        }

        //对非空卡号长度数字的判断
        txtCardNo.Text = txtCardNo.Text.Trim();
        string strCardNo = txtCardNo.Text;
        if (strCardNo != "")
        {
            if (Validation.strLen(strCardNo) != 16)
                context.AddError("A009100109", txtCardNo);
            else if (!Validation.isNum(strCardNo))
                context.AddError("A009100110", txtCardNo);
        }

		// 校验结算日期
		UserCardHelper.validateDate(context, txtDealDate, false, "", 
			"A009100210: 结算日期格式必须是yyyyMMdd形式");
		
        return context.hasError();
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //调用查询条件的判断处理        if (QueryValidation())
        {
            showConGridView();
            return;
        }

        //取得查询结果
        ICollection dataView = QueryResultColl();

        //没有查询出交易记录时,显示错误
        if (dataView.Count == 0)
        {
            showConGridView();
            AddMessage("N007P00001: 查询结果为空");
            return;
        }

        //显示查询结果信息
        lvwConsumeInfo.DataSource = dataView;
        lvwConsumeInfo.DataBind();

    }

    private void showConGridView()
    {
        //置空交易记录信息列表
        UserCardHelper.resetData(lvwConsumeInfo, null);

        labCount.Text = "";
        labSum.Text = "";
    }

    public ICollection QueryResultColl()
    {
        //从消费正常清单查询表(TQ_TRADE_RIGHT)中读取数据
        SP_12QueryPDO pdo = new SP_12QueryPDO("SP_SD_Query");

        DataTable data = SPHelper.call12Query(pdo, context, "ConsumeInfoQuery",
            txtStartDate.Text, txtEndDate.Text, txtCardNo.Text,
            selCalling.SelectedValue, selCorp.SelectedValue,
            selDepart.SelectedValue, txtPosNo.Text, txtPasmNo.Text, txtDealDate.Text);

        labCount.Text = pdo.var11;
        labSum.Text = pdo.var12;

        return new DataView(data);
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        //保存当前查询出的交易信息
        ExportGridView(lvwConsumeInfo);
    }
}
