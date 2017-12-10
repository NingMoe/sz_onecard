using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Common;
using TM;
using TDO.BalanceChannel;
using TDO.UserManager;
using PDO.InvoiceTrade;

/***************************************************************
 * 功能名: 发票_分配
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2011/01/13    liuh			初次开发
 ****************************************************************/
public partial class ASP_InvoiceTrade_IT_Distribution : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtCount.Attributes.Add("onkeyup", "javascript:return txtCountControlChange();");
            txtCount.Attributes.Add("onblur", "javascript:return txtCountControlChange();");
            txtBeginNo.Attributes.Add("onblur", "javascript:return Change();");

            //人员下拉框
            InitInvoice();
            txtBeginNo.ReadOnly = true;
            txtVolumnNo.ReadOnly = true;
            InitStaffControl();

            this.txtCount.Text = "100";
        }
    }

    //初始化发票代码和发票起始号码
    private void InitInvoice()
    {
        string sql = string.Format("select volumeno,invoiceno from (select volumeno,invoiceno from TL_R_INVOICE t where  t.ALLOTSTATECODE='01'and t.usestatecode='00' and t.allotdepartno='{0}' order by t.allottime asc,invoiceno) temp where rownum=1", context.s_DepartID);
        TMTableModule tmTMTableModule1 = new TMTableModule();
        DataTable data = tmTMTableModule1.selByPKDataTable(context, sql, 0);
        if (data != null && data.Rows.Count > 0)
        {
            txtVolumnNo.Text = data.Rows[0][0].ToString();
            txtBeginNo.Text = data.Rows[0][1].ToString();

        }
    }

    /// <summary>
    /// 初始化领用人
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    private void InitStaffControl()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        tdoTD_M_INSIDESTAFFIn.DEPARTNO = this.context.s_DepartID; ;
        TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
        ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
    }

    /// <summary>
    /// 分配按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void InvoiceDistrbution_Click(object sender, EventArgs e)
    {
        if (!InvoiceValidate())
            return;

        SP_IT_DistributionPDO pdo = new SP_IT_DistributionPDO();
        pdo.beginNo = txtBeginNo.Text.Trim();
        pdo.endNo = hidEndNo.Value.Trim();
        pdo.allotDept = this.context.s_DepartID;
        pdo.allotStaff = selStaff.SelectedValue;
        pdo.volumeno = this.txtVolumnNo.Text.Trim();

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M200002091:发票分配成功");

            btnQuery_Click(sender, e);
        }
        InitInvoice();
    }

    /// <summary>
    /// 出库前验证控件内容
    /// </summary>
    /// <returns></returns>
    public bool InvoiceValidate()
    {
        InvoiceValidator iv = new InvoiceValidator(context);
        bool b = iv.validateIdRange(txtBeginNo, hidEndNo.Value.Trim());

        if (Validation.strLen(txtVolumnNo.Text) != 12)
        {
            context.AddError("A200001991:发票代码长度必须是12位", txtVolumnNo);
            b = false;
        }

        if (Validation.isNum(this.txtCount.Text) == false)
        {
            context.AddError("A200001992:发票份数必须是数字", txtCount);
            b = false;
        }

        //领用人非空
        if (selStaff.SelectedValue == "")
        {
            context.AddError("A200002031", selStaff);
            b = false;
        }
        return b;
    }

    /// <summary>
    /// 查询按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!InputValidate())
            return;

        List<string> vars = new List<string>();
        vars.Add("01");//01为出库状态
        vars.Add(this.context.s_UserID);
        vars.Add(this.txtVolumnNo_Sel.Text.Trim());
        vars.Add(this.txtBeginNo_Sel.Text.Trim());
        vars.Add(this.txtEndNo_Sel.Text.Trim());

        DataTable data = SPHelper.callITQuery(context, "Distribution", vars.ToArray());

        gvResult.DataSource = data;
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }

    /// <summary>
    /// 分页事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gvResult_PageIndexChanging(Object sender, GridViewPageEventArgs e)
    {
        //分页事件
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    /// <summary>
    /// 查询前验证查询条件
    /// </summary>
    /// <returns></returns>
    private bool InputValidate()
    {
        if (this.txtVolumnNo_Sel.Text.Length > 0 && Validation.strLen(this.txtVolumnNo_Sel.Text) != 12)
        {
            context.AddError("A200001991:发票代码长度必须是12位", txtVolumnNo_Sel);
            return false;
        }

        InvoiceValidator iv = new InvoiceValidator(context);
        return iv.validateIdRangeAllowNull(this.txtBeginNo_Sel, this.txtEndNo_Sel);

    }
}
