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
using Common;
using PDO.ChargeCard;

// 充值卡售卡返销处理
public partial class ASP_ChargeCard_CC_SaleRollback : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        clearGridViewData();
    }

    // 清楚gridview数据并去激活“提交”按钮
    private void clearGridViewData()
    {
        UserCardHelper.resetData(gvResult, null);
        btnSubmit.Enabled = false;
    }

    // gridview换页处理
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    // 查询输入校验处理
    private void validate()
    {
        Validation valid = new Validation(context);

        //对起始卡号进行非空、长度14、英数检验
        bool b = Validation.isEmpty(txtFromCardNo);
        if (!b) 
        {
            ChargeCardHelper.validateCardNo(context, txtFromCardNo, "A007P01003: 充值卡号格式不正确");
        }


        // 对售出时间范围进行检查       
        b = Validation.isEmpty(txtFromSaleDate);
        DateTime ?fromDate = null, toDate = null;
        if (!b)
        {
            fromDate = valid.beDate(txtFromSaleDate, "A007P05005: 售出时间范围起始值格式必须为yyyyMMdd");
        }
        b = Validation.isEmpty(txtToSaleDate);
        if (!b)
        {
            toDate = valid.beDate(txtToSaleDate, "A007P05006: 售出时间范围终止值格式必须为yyyyMMdd");
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "A007P05007: 售出时间范围起始值不能大于终止值");
        }

    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        clearGridViewData();

        validate();
        if (context.hasError()) return;

        // 查询当班充值卡销售台帐
        DataTable data = ChargeCardHelper.callQuery(context, "F00", context.s_UserID,
            txtFromCardNo.Text, txtFromSaleDate.Text, txtToSaleDate.Text);

        UserCardHelper.resetData(gvResult, data);

        btnSubmit.Enabled = (data.Rows.Count > 0);
        
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N007P00001: 查询结果为空");
        }      
    }

    // 提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        string radioBatchNo = Request.Form["radioBatchNo"];
        if (radioBatchNo == null)
        {
            context.AddError("A007P05008: 没有选择需要返销的售卡记录");
            return;
        }

        SP_CC_SaleRollbackPDO pdo = new SP_CC_SaleRollbackPDO();
        pdo.batchNo = radioBatchNo;                              // 批次号
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok) AddMessage("D007P05001: 返销成功");

        btnQuery_Click(sender, e);
    }
}
