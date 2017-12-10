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
using Master;
using Common;

public partial class ASP_ResourceManage_RM_QueryGetCardHistory : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView();
            txtStartDate.Text = DateTime.Now.AddMonths(-1).ToString("yyyyMMdd");
            txtEndDate.Text = DateTime.Now.ToString("yyyyMMdd");
            //初始化卡片类型
            UserCardHelper.selectCardType(context, selCardType, true);

            //初始化卡面类型
            UserCardHelper.selectCardFace(context, selCardFaceType, true);

            //初始化部门
            UserCardHelper.selectDepts(context, selDepart, true);

            //初始化所属员工
            UserCardHelper.selectAllStaffs(context, selStaff, selDepart, true);

            //初始化所属面值
            ResourceManageHelper.selCardMoney(context, selCardMoney, true);
            hidCardType.Value = "usecard";
        }
        ResourceManageHelper.selectTab(this, this.GetType(), hidCardType);
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        ValidateForQuery();

        if (context.hasError()) return;
        if (hidCardType.Value == "usecard") //用户卡
        {
            DataTable dt = ResourceManageHelper.callQuery(context, "HISTORY_USECARD", selCardType.SelectedValue,
                selCardFaceType.SelectedValue, selStaff.SelectedValue, txtStartDate.Text, txtEndDate.Text, selDepart.SelectedValue, txtCardno.Text);
            if (dt == null || dt.Rows.Count == 0)
            {
                AddMessage("N005030001: 查询结果为空");
            }
            ResourceManageHelper.resetData(gvResultUseCard, dt);
        }
        else if (hidCardType.Value == "chargecard") //充值卡
        {

            DataTable dt = ResourceManageHelper.callQuery(context, "HISTORY_CHARGECARD", selCardMoney.SelectedValue,
                txtStartDate.Text, txtEndDate.Text, selStaff.SelectedValue, selDepart.SelectedValue, txtChargeCardno.Text);
            if (dt == null || dt.Rows.Count == 0)
            {
                AddMessage("N005030001: 查询结果为空");
            }
            ResourceManageHelper.resetData(gvResultChargeCard, dt);
        }
    }

    public void showNonDataGridView()
    {
        gvResultUseCard.DataSource = new DataTable();
        gvResultUseCard.DataBind();
        gvResultChargeCard.DataSource = new DataTable();
        gvResultChargeCard.DataBind();
    }

    public void gvResultUseCard_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResultUseCard.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    public void gvResultChargeCard_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResultChargeCard.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    private void ValidateForQuery()
    {
        //对起始和终止日期的校验
        UserCardHelper.validateDateRange(context, txtStartDate, txtEndDate, true);

        if (hidCardType.Value == "usecard")//用户卡
        {
            //校验卡号
            if (!string.IsNullOrEmpty(txtCardno.Text.Trim()))
            {
                if (Validation.strLen(txtCardno.Text.Trim()) != 16)
                    context.AddError("A095470145：卡号必须为16位", txtCardno);
                else if (!Validation.isNum(txtCardno.Text.Trim()))
                    context.AddError("A095470146：卡号必须为数字", txtCardno);
            }
        }
        else//充值卡
        {
            //校验卡号
            if (!string.IsNullOrEmpty(txtChargeCardno.Text.Trim()))
            {
                if (Validation.strLen(txtChargeCardno.Text.Trim()) != 14)
                    context.AddError("A095470148：充值卡卡号必须为14位", txtChargeCardno);
                else
                    ChargeCardHelper.validateCardNo(context, txtChargeCardno, "A095470149:卡号不符合充值卡卡号格式");
            }
        }
    }

    protected void selDepart_SelectedIndexChanged(object sender, EventArgs e)
    {
        // 员工
        UserCardHelper.selectStaffs(context, selStaff, selDepart, true);
    }
    //去掉多余的引号
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            ResourceManageHelper.ClearRowDataBound(e);
        }
    }

    /// <summary>
    /// 查询条件卡片类型变更事件，更新卡片类型对应的卡面类型
    /// </summary>
    protected void selCardType_change(object sender, EventArgs e)
    {
        //卡面类型
        selCardFaceType.Items.Clear();
        ResourceManageHelper.selFaceType(context, selCardFaceType, true, selCardType.SelectedValue);
    }
}