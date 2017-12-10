using System;
using System.Data;
using System.Collections;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;

public partial class ASP_SpecialDeal_SD_SubwayTradeMendAudit : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //指定GridView DataKeyNames
            gvResult.DataKeyNames =
                new string[]{"TRADEID","CARDNO","TRADEDATE","TRADETIME","TRADEMONEY", "CARDTRADENO","ERRORREASON",
                    "DEALRESULT","DEALSTAFFNO","DEALDATE", "STAFFNAME", "RENEWTIME", "REMARK"};

            initLRTTradeMendInfo();
        }
    }
    #region 初始化查询
    protected void initLRTTradeMendInfo()
    {
        gvResult.DataSource = CreateLRTTradeMendAuditDataSource();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }
    public ICollection CreateLRTTradeMendAuditDataSource()
    {
        //查询待审批的业务
        DataTable data = SPHelper.callSDQuery(context, "QueryLRTTradeMendAudit");
        return new DataView(data);
    }
    #endregion

    #region 审核通过、作废事件
    protected void btnPass_Click(object sender, EventArgs e)
    {
        //校验交易序号
        if (txtTradeNo.Text.Trim() != "")
        {
            if (Validation.strLen(txtTradeNo.Text.Trim()) != 4)
                context.AddError("A094570041:交易序号必须为4位", txtTradeNo);
            else if (!Validation.isNum(txtTradeNo.Text.Trim()))
                context.AddError("A094570042:交易序号必须为数字", txtTradeNo);
        }
        if (context.hasError()) return;

        context.SPOpen();
        context.AddField("P_FUNCODE").Value = "PASS";
        context.AddField("P_TRADEID").Value = hidTradeId.Value;
        context.AddField("P_CARDTRADENO").Value = txtTradeNo.Text.Trim();

        bool ok = context.ExecuteSP("SP_SD_LRTTradeAudit");

        if (ok)
        {
            AddMessage("审核通过成功");
            //清空
            ClearInfo();
            //刷新列表
            initLRTTradeMendInfo();
        }
    }
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        context.SPOpen();
        context.AddField("P_FUNCODE").Value = "CANCEL";
        context.AddField("P_TRADEID").Value = hidTradeId.Value;
        context.AddField("P_CARDTRADENO").Value = txtTradeNo.Text.Trim();

        bool ok = context.ExecuteSP("SP_SD_LRTTradeAudit");

        if (ok)
        {
            AddMessage("审核作废成功");
            //清空
            ClearInfo();
            //刷新列表
            initLRTTradeMendInfo();
        }
    }
    #endregion

    protected void ClearInfo()
    {
        hidTradeId.Value = "";
        labCardno.Text = "";
        labTradeDate.Text = "";
        labTradeTime.Text = "";
        labMoney.Text = "";
        labDealResult.Text = "";
        labDealStaff.Text = "";
        labDealDate.Text = "";
        labCreateStaff.Text = "";
        labReason.Text = "";
        labRemark.Text = "";
        txtTradeNo.Text = "";

        btnPass.Enabled = false;
        btnCancel.Enabled = false;
    }
    #region 页面控制事件
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header
            || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[0].Visible = false;
        }
    }
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        //获取参数
        hidTradeId.Value = getDataKeys("TRADEID");
        labCardno.Text = getDataKeys("CARDNO");
        labTradeDate.Text = getDataKeys("TRADEDATE");
        labTradeTime.Text = getDataKeys("TRADETIME");
        labMoney.Text = getDataKeys("TRADEMONEY");
        labDealResult.Text = getDataKeys("DEALRESULT");
        labDealStaff.Text = getDataKeys("DEALSTAFFNO");
        labDealDate.Text = getDataKeys("DEALDATE");
        labCreateStaff.Text = getDataKeys("STAFFNAME");
        labReason.Text = getDataKeys("ERRORREASON");
        labRemark.Text = getDataKeys("REMARK");

        btnPass.Enabled = true;
        btnCancel.Enabled = true;
    }
    public String getDataKeys(String keysname)
    {
        return gvResult.DataKeys[gvResult.SelectedIndex][keysname].ToString();
    }
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        //分页
        gvResult.PageIndex = e.NewPageIndex;
        initLRTTradeMendInfo();
        ClearInfo();
    }
    #endregion
}