using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using Master;
using PDO.ProvisionNote;
using TDO.UserManager;
/* ------------------------------------
<AUTHOR>JIANGBB</AUTHOR>
<CREATEDATE>2014-08-08</CREATEDATE>
<DESCRIPTION>网点代办业务录入功能</DESCRIPTION>
------------------------------------ */
public partial class ASP_ProvisionNote_PN_DeptTradeInput : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();

            txtDate.Text = DateTime.Now.ToString("yyyyMMdd");

            //初始化部门数据
            FIHelper.selectDept(context, selDept, true);

            //验证是否有全部网点主管的操作权限
            if (!HasOperPower("201008"))
            {
                selDept.SelectedValue = context.s_DepartID;
                selDept.Enabled = false;
            }
        }
    }

    /// <summary>
    /// 验证是否有操作权限
    /// </summary>
    /// <param name="powerCode">权限编码</param>
    /// <returns></returns>
    private bool HasOperPower(string powerCode)
    {
        //TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
        string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
        DataTable dataSupply = tm.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
        if (dataSupply.Rows.Count > 0)
            return true;
        else
            return false;
    }

    /// <summary>
    /// 查询校验
    /// </summary>
    private void queryValidate()
    {
        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtDate);
        DateTime? fromDate = null;
        if (!b1)
        {
            fromDate = valid.beDate(txtDate, "日期格式必须为yyyyMMdd");
        }
    }

    /// <summary>
    /// 新增校验
    /// </summary>
    private void newValidate()
    {
        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtSelDate);
        DateTime? fromDate = null;
        if (!b1)
        {
            fromDate = valid.beDate(txtSelDate, "日期格式必须为yyyyMMdd");
        }

        string strMoney = txtMoney.Text.Trim();
        if (strMoney == "")
            context.AddError("金额不能为空", txtMoney);
        else
        {
            if (!Validation.isPriceEx(strMoney))
                context.AddError("金额格式不正确", txtMoney);
        }
    }

    /// <summary>
    /// 删除校验
    /// </summary>
    private void deleteValidate()
    {
        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtSelDate);
        DateTime? fromDate = null;
        if (!b1)
        {
            fromDate = valid.beDate(txtSelDate, "日期格式必须为yyyyMMdd");
        }
    }

    /// <summary>
    /// 行点击取得业务流水号等信息
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        hidTradeId.Value = gvResult.SelectedRow.Cells[0].Text.Trim();
        txtDate.Text = gvResult.SelectedRow.Cells[7].Text;
        txtMoney.Text = gvResult.SelectedRow.Cells[2].Text;
        selTradeType.SelectedValue = gvResult.SelectedRow.Cells[8].Text;
    }

    public void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    /// <summary>
    /// DataBound时隐藏业务类型等信息
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[7].Visible = false;
            e.Row.Cells[8].Visible = false;
        }
    }

    // 提交处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        queryValidate();

        if (context.hasError())
            return;

        SP_PN_QueryPDO pdo = new SP_PN_QueryPDO();
        pdo.funcCode = "QUERYDEPTTADE";
        pdo.var1 = txtSelDate.Text.Trim();
        pdo.var2 = selTradeIn.SelectedValue.Trim();
        pdo.var3 = selDept.SelectedValue;

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        UserCardHelper.resetData(gvResult, data);
    }

    // 新增处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 输入校验
        newValidate();
        if (context.hasError()) return;

        context.SPOpen();
        context.AddField("P_TRADEID").Value = "";
        context.AddField("P_DATE").Value = txtDate.Text.Trim();
        context.AddField("P_MONEY").Value = Convert.ToDouble(txtMoney.Text.Trim()) * 100;
        context.AddField("P_TRADETYPE").Value = "01";
        context.AddField("P_WELTYPE").Value = selTradeType.SelectedValue;
        context.AddField("P_REMARK").Value = txtRemark.Text.Trim();
        bool ok = context.ExecuteSP("SP_PN_DeptTradeInput");
        if (ok)
        {
            context.AddMessage("新增业务成功");

            foreach (Control item in this.Page.Controls)
            {
                ClearControl(item);
            }
            this.txtDate.Text = DateTime.Now.ToString("yyyyMMdd");

            btnQuery_Click(sender, e);
        }
    }

    // 删除处理
    protected void btnDelete_Click(object sender, EventArgs e)
    {
        // 输入校验
        deleteValidate();
        if (context.hasError()) return;

        context.SPOpen();
        context.AddField("P_TRADEID").Value = hidTradeId.Value;
        context.AddField("P_DATE").Value = "";
        context.AddField("P_MONEY").Value = "";
        context.AddField("P_TRADETYPE").Value = "02";
        context.AddField("P_WELTYPE").Value = "";
        context.AddField("P_REMARK").Value = "";
        bool ok = context.ExecuteSP("SP_PN_DeptTradeInput");
        if (ok)
        {
            context.AddMessage("删除业务成功");
            hidTradeId.Value = "";
            btnQuery_Click(sender,e);
            foreach (Control item in this.Page.Controls)
            {
                ClearControl(item);
            }
            this.txtDate.Text = DateTime.Now.ToString("yyyyMMdd");
            return;
        }
    }



    protected void ClearControl(Control control)
    {
        foreach (Control c in control.Controls)
        {
            if (c is Label)
            {
                ((Label)c).Text = "";
            }
            else if (c is TextBox)
            {
                ((TextBox)c).Text = "";
            }
            else if (c is CheckBox)
            {
                ((CheckBox)c).Checked = false;
            }
            else if (c is RadioButton)
            {
                ((RadioButton)c).Checked = false;
            }
            else if (c is DropDownList)
            {
                ((DropDownList)c).SelectedValue = "";
            }

            if (c.Controls.Count > 0)
            {
                ClearControl(c);
            }
        }
    }
}
