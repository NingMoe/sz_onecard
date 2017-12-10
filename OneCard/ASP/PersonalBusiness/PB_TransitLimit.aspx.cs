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
using PDO.Financial;
using Master;
using Common;

public partial class ASP_PersonalBusiness_PB_TransitLimit : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //指定GridView DataKeyNames
            gvResult.DataKeyNames = new string[] { "TRADEID", "CARDNO", "STATE", "ADDTIME", "ADDSTAFFNO", 
                                                   "DELETETIME","DELETESTAFFNO", "REMARK"};
            //显示列表
            showNonDataGridView();

            hidTradeId.Value = "";

        }
    }
    private void showNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[0].Visible = false;
        }
    }
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        gvResult.DataSource = queryTransitLimit();
        gvResult.DataBind();
    }
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件


            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");

        }
    }
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        hidTradeId.Value = getDataKeys("TRADEID");
        txtOpCardno.Text = getDataKeys("CARDNO");
        txtRemark.Text = getDataKeys("REMARK");

        if (getDataKeys("STATE") == "添加")
            btnCancel.Enabled = true;
        else
            btnCancel.Enabled = false;
    }
    public String getDataKeys(String keysname)
    {
        return gvResult.DataKeys[gvResult.SelectedIndex][keysname].ToString();
    }
    private Boolean checkQueryValidation()
    {
        if (txtCardno.Text.Trim() != "")
        {
            if (Validation.strLen(txtCardno.Text.Trim()) != 16)
                context.AddError("A094570070:卡号必须为16位", txtCardno);
            else if (!Validation.isNum(txtCardno.Text.Trim()))
                context.AddError("A094570071:卡号必须为数字", txtCardno);
        }

        return !(context.hasError());
    }
    private Boolean checkSupplyValidation()
    {
        if (txtOpCardno.Text.Trim() == "")
            context.AddError("A094570072:卡号不能为空", txtOpCardno);
        else if (Validation.strLen(txtOpCardno.Text.Trim()) != 16)
            context.AddError("A094570073:卡号必须为16位", txtOpCardno);
        else if (!Validation.isNum(txtOpCardno.Text.Trim()))
            context.AddError("A094570074:卡号必须为数字", txtOpCardno);

        if (txtRemark.Text.Trim() != "")
        {
            if (Validation.strLen(txtRemark.Text.Trim()) >= 50)
                context.AddError("A094570075:备注长度不能大于50", txtCardno);
        }

        return !(context.hasError());
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //验证输入有效性

        if (!checkQueryValidation())
            return;

        //查询转值限制记录
        queryqueryTransitLimitReg();
    }
    protected void queryqueryTransitLimitReg()
    {
        //查询单位购卡记录
        ICollection dataView = queryTransitLimit();

        //没有查询出记录时,显示错误
        if (dataView.Count == 0)
        {
            showNonDataGridView();
            context.AddError("没有查询出任何记录");
            return;
        }

        //显示Gridview
        gvResult.DataSource = dataView;
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }
    private ICollection queryTransitLimit()
    {
        DataTable data = SPHelper.callPBQuery(context, "QueryTransitLimit", txtCardno.Text, selState.SelectedValue);
        return new DataView(data);
    }
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        //添加

        //输入校验
        if (!checkSupplyValidation())
            return;
        operateTransitLimit("ADD");
    }
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        //删除

        //校验是否选择要删除的记录
        if (hidTradeId.Value == "")
            context.AddError("A094570076:未选择任何记录");
        if (context.hasError())
            return;
        operateTransitLimit("DELETE");
    }
    protected void operateTransitLimit(string funccode)
    {
        //调用处理存储过程

        context.SPOpen();
        context.AddField("P_FUNCCODE").Value = funccode;
        context.AddField("P_TRADEID").Value = hidTradeId.Value;
        context.AddField("P_CARDNO").Value = txtOpCardno.Text.Trim();
        context.AddField("P_REMARK").Value = txtRemark.Text.Trim();


        bool ok = context.ExecuteSP("SP_PB_TRANSITLIMIT");

        if (ok)
        {
            AddMessage("操作成功");

            //清空
            hidTradeId.Value = "";
            txtOpCardno.Text = "";
            txtRemark.Text = "";

            btnCancel.Enabled = false;
            //刷新列表
            queryqueryTransitLimitReg();
        }

    }
}