using System;
using System.Data;
using System.Web.UI;
using Common;
using Master;
using PDO.ProvisionNote;
using System.Web.UI.WebControls;

/// <summary>
/// 银行接口查询
/// </summary>

public partial class ASP_ProvisionNote_PN_QueryBank : Master.ExportMaster
{
    #region Initialization
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();

            //初始化同步发起发
            PNHelper.initPaperTypeList(context, selBank, "QUERYPNBANK", "");
        }
    }
    #endregion 

    #region Private
    /// <summary>
    /// 查询输入有效性验证
    /// </summary>
    /// <returns></returns>
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

        SP_PN_QueryPDO pdo = new SP_PN_QueryPDO();
        pdo.funcCode = "QUERYBANK";  //功能号为银行接口查询
        pdo.var1 = txtFromDate.Text.Trim();
        pdo.var2 = txtToDate.Text.Trim();
        pdo.var3 = selBank.SelectedValue;
    
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
