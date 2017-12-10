using System;
using System.Data;
using System.Web.UI;
using Common;
using Master;
using System.Web.UI.WebControls;
using PDO.AdditionalService;
using TDO.CardManager;
using TM;

/**********************************
 * 图书馆欠款欠书查询
 * 2015-01-14
 * gl
 * 初次编写
 * ********************************/
public partial class ASP_AddtionalService_AS_LibraryOweQuery : Master.FrontMaster
{
    #region Initialization
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            //if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";
            // 设置可读属性
            setReadOnly(txtCardBalance, txtStartDate, txtEndDate);

            //初始状态查询不可用
            btnQuery.Enabled = false;

            gvMoney.DataSource = new DataTable();
            gvMoney.DataBind();

            gvBook.DataSource = new DataTable();
            gvBook.DataBind();
        }
    }
    #endregion

    #region Private
    private Boolean DBreadValidation()
    {
        //对卡号进行非空、长度、数字检验
        txtCardno.Text = txtCardno.Text.Trim();
        if (txtCardno.Text == "")
        {
            context.AddError("A001004113", txtCardno);
            return false;
        }
        else
        {
            if (!Validation.isNum(txtCardno.Text.Trim()))
            {
                context.AddError("A001004115", txtCardno);
                return false;
            }
        }
        PBHelper.queryCardNo(context, txtCardno);
        return !(context.hasError());

    }
    #endregion

    #region Event Handler

    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从卡资料表(TF_F_CARDREC)中读取数据
        TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
        ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text.Trim();

        TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

        if (ddoTF_F_CARDRECOut == null)
        {
            context.AddError("A001008103");
            return;
        }
        //从IC卡电子钱包帐户表(TF_F_CARDEWALLETACC)中读取数据


        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text.Trim();

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);

        if (ddoTF_F_CARDEWALLETACCOut == null)
        {
            context.AddError("A001008103");
            return;
        }

        txtStartDate.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");

        String Vdate = ddoTF_F_CARDRECOut.VALIDENDDATE;
        txtEndDate.Text = ASHelper.toDateWithHyphen(Vdate);

        Double cardMoney = Convert.ToDouble(ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY);
        txtCardBalance.Text = (cardMoney / 100).ToString("0.00");

        // 读取卡片类型
        readCardType(txtCardno.Text, labCardType);

        // 读取卡片状态

        ASHelper.readCardState(context, txtCardno.Text, txtCardState);

        if (txtCardState.Text == "售出")
            btnQuery.Enabled = true;

    }
    // 读数据库处理
    protected void btnDBread_Click(object sender, EventArgs e)
    {
        //对输入卡号进行检验
        if (!DBreadValidation())
            return;
        TMTableModule tmTMTableModule = new TMTableModule();

        //从卡资料表(TF_F_CARDREC)中读取数据
        TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
        ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text.Trim();

        TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

        if (ddoTF_F_CARDRECOut == null)
        {
            context.AddError("A001008103");
            return;
        }
        //从IC卡电子钱包帐户表(TF_F_CARDEWALLETACC)中读取数据


        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text.Trim();

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);

        if (ddoTF_F_CARDEWALLETACCOut == null)
        {
            context.AddError("A001008103");
            return;
        }

        txtStartDate.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");

        String Vdate = ddoTF_F_CARDRECOut.VALIDENDDATE;
        txtEndDate.Text = ASHelper.toDateWithHyphen(Vdate);

        Double cardMoney = Convert.ToDouble(ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY);
        txtCardBalance.Text = (cardMoney / 100).ToString("0.00");


        // 读取卡片类型
        readCardType(txtCardno.Text, labCardType);
        // 读取卡片状态

        ASHelper.readCardState(context, txtCardno.Text, txtCardState);

        if (txtCardState.Text == "售出")
            btnQuery.Enabled = true;
    }
    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (context.hasError()) return;

        SP_AS_QueryPDO pdo = new SP_AS_QueryPDO();
        pdo.funcCode = "QUERYCARDOPENLIB"; //查询卡是否开通图书馆功能
        pdo.var1 = txtCardno.Text.Trim();
        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        if (data == null || data.Rows.Count == 0)
        {
            context.AddError("当前卡并未开通图书馆功能");
            return;
        }
        //设置报文解析的欠款DataTable
        DataTable oweMoneytable = new DataTable();

        //设置报文解析的欠书DataTable
        DataTable oweBooktable = new DataTable();

        //返回错误信息
        string errorInfo = "";

        //调用图书馆欠款欠书接口
        LibraryHelper.getOweTable(txtCardno.Text.Trim(), out oweBooktable, out oweMoneytable, out errorInfo);

        if (errorInfo != "")
        {
            context.AddError(errorInfo);
        }
        UserCardHelper.resetData(gvMoney, oweMoneytable);

        UserCardHelper.resetData(gvBook, oweBooktable);
    }

    //分页
    protected void gvMoney_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvMoney.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    protected void gvBook_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvBook.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    #endregion

}
