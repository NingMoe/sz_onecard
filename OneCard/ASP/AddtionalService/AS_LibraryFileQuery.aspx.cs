using System;
using System.Data;
using System.Web.UI;
using Common;
using Master;
using System.Web.UI.WebControls;
using PDO.AdditionalService;

/**********************************
 * 图书馆业务明细查询
 * 2015-01-14
 * gl
 * 初次编写
 * ********************************/
public partial class ASP_AddtionalService_AS_LibraryFileQuery : Master.Master
{
    #region Initialization
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
            initLoad();
        }
    }


    private void initLoad()
    {
        //初始化日期
        txtFromDate.Text = DateTime.Now.AddDays(-30).ToString("yyyyMMdd");
        txtToDate.Text = DateTime.Now.ToString("yyyyMMdd");
        //初始化业务类型
        selTradeType.Items.Add(new ListItem("---请选择---", ""));
        selTradeType.Items.Add(new ListItem("01:发卡", "01"));
        selTradeType.Items.Add(new ListItem("02:挂失", "02"));
        selTradeType.Items.Add(new ListItem("03:解挂", "03"));
        selTradeType.Items.Add(new ListItem("04:补卡", "04"));
        selTradeType.Items.Add(new ListItem("10:开通", "10"));
        selTradeType.Items.Add(new ListItem("11:普通关闭", "11"));
        selTradeType.Items.Add(new ListItem("12:挂失关闭", "12"));
        //初始化处理结果
        selTradeStates.Items.Add(new ListItem("---请选择---", ""));
        selTradeStates.Items.Add(new ListItem("0:成功", "0"));
        selTradeStates.Items.Add(new ListItem("1:失败", "1"));
        selTradeStates.SelectedIndex = 2;
    }
    #endregion 

    #region Private
    /// <summary>
    /// 查询输入有效性验证
    /// </summary>
    private void validate()
    {
        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtFromDate);
        bool b2 = Validation.isEmpty(txtToDate);
        DateTime? fromDate = null, toDate = null;
        if (b1 || b2)//验证是否为空
            context.AddError("开始日期和结束日期必须填写");
        else //验证格式
        {
            if (!b1)
                fromDate = valid.beDate(txtFromDate, "开始日期范围起始值格式必须为yyyyMMdd");

            if (!b2)
                toDate = valid.beDate(txtToDate, "结束日期范围终止值格式必须为yyyyMMdd");
        }

        //验证时间范围是否合理
        if (fromDate != null && toDate != null)
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");

    }
    #endregion

    #region Event Handler
    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        SP_AS_QueryPDO pdo = new SP_AS_QueryPDO();
        pdo.funcCode = "QUERYLIBRARYFILEDETAIL";  //查询对账文件明细
        pdo.var1 = selTradeType.SelectedValue.Trim();
        pdo.var2 = selTradeStates.SelectedValue.Trim();
        pdo.var3 = txtFromDate.Text.Trim();
        pdo.var4 = txtToDate.Text.Trim();
        

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        UserCardHelper.resetData(gvResult, data);
    }

    //分页
    protected void gvResult_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    #endregion
}
