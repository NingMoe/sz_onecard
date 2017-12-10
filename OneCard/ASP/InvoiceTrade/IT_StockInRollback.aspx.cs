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
 * 功能名: 发票退回
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2011/01/21    王定喜			根据常州需求增加发票退回操作（主要包括入库回退和冻结回退）
 ****************************************************************/
public partial class ASP_InvoiceTrade_IT_StockInRollback : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtCount.Attributes.Add("onkeyup", "javascript:return txtCountControlChange();");
            txtCount.Attributes.Add("onblur", "javascript:return txtCountControlChange();");
            txtBeginNo.Attributes.Add("onblur", "javascript:return Change();");

            TMTableModule tmTMTableModule = new TMTableModule();

        }
    }

  

    /// <summary>
    /// 发票退回按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void InvoiceStockOut_Click(object sender, EventArgs e)
    {
        if (!InvoiceValidate())
            return;

        //发票退回存储过程
        SP_IT_StockInRollBackPDO pdo = new SP_IT_StockInRollBackPDO();
        pdo.beginNo = txtBeginNo.Text.Trim();
        pdo.endNo = hidEndNo.Value.Trim();
        pdo.volumeno = this.txtVolumnNo.Text.Trim();

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M2EE002001:发票退回成功");

            btnQuery_Click(sender, e);
        }
    }

    /// <summary>
    /// 发票退回前验证控件内容
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
        vars.Add("00");//00为入库状态
        vars.Add(this.txtVolumnNo_Sel.Text.Trim());
        vars.Add(this.txtBeginNo_Sel.Text.Trim());
        vars.Add(this.txtEndNo_Sel.Text.Trim());

        DataTable data = SPHelper.callITQuery(context, "invoicenoSegmentSel", vars.ToArray());

        gvResult.DataSource = data;
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;

        List<string> vars1 = new List<string>();
        vars1.Add("04");//04为冻结状态

        vars1.Add(this.txtVolumnNo_Sel.Text.Trim());
        vars1.Add(this.txtBeginNo_Sel.Text.Trim());
        vars1.Add(this.txtEndNo_Sel.Text.Trim());

        DataTable data1 = SPHelper.callITQuery(context, "Freeze", vars1.ToArray());

        gvFreeze.DataSource = data1;
        gvFreeze.DataBind();
        gvFreeze.SelectedIndex = -1;

        if (this.txtVolumnNo_Sel.Text.Trim().Length > 0)
        {
            this.txtVolumnNo.Text = this.txtVolumnNo_Sel.Text;
        }
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
