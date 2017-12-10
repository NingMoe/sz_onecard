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
 * 功能名: 发票_出库
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2011/01/11    liuh			根据常州需求重新修改出库

 ****************************************************************/
public partial class ASP_InvoiceTrade_IT_StockOut : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtCount.Attributes.Add("onkeyup", "javascript:return txtCountControlChange();");
            txtCount.Attributes.Add("onblur", "javascript:return txtCountControlChange();");
            txtBeginNo.Attributes.Add("onblur", "javascript:return Change();");

            InitInvoice();
           
            txtBeginNo.ReadOnly = true;
            txtVolumnNo.ReadOnly = true;
            TMTableModule tmTMTableModule = new TMTableModule();

            //领用部门
            TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTTDOIn = new TD_M_INSIDEDEPARTTDO();
            TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTTDOOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTTDOIn, typeof(TD_M_INSIDEDEPARTTDO), null, null,  " WHERE USETAG = '1' ORDER BY DEPARTNO");
            ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTTDOOutArr, "DEPARTNAME", "DEPARTNO", true);
        }
    }


    private void InitInvoice()
    {
        string sql = string.Format("select volumeno,invoiceno from (select volumeno,invoiceno from TL_R_INVOICE t where t.allotstatecode='00' order by t.allottime asc,invoiceno) temp where rownum=1", context.s_UserID);
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
    protected void selDept_Changed(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        tdoTD_M_INSIDESTAFFIn.DEPARTNO = selDept.SelectedValue;
        TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFFROLE1010", null);
        ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        if (selStaff.Items.Count > 1)
        {
            selStaff.Items[1].Selected = true;
        }
    }

    /// <summary>
    /// 出库按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void InvoiceStockOut_Click(object sender, EventArgs e)
    {
        if (!InvoiceValidate())
            return;

        //发票出库存储过程
        SP_IT_StockOutPDO pdo = new SP_IT_StockOutPDO();
        pdo.beginNo = txtBeginNo.Text.Trim();
        pdo.endNo = hidEndNo.Value.Trim();
        pdo.allotDept = selDept.SelectedValue;
        pdo.allotStaff = selStaff.SelectedValue;
        pdo.volumeno = this.txtVolumnNo.Text.Trim();

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M200002001");

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
        //领用部门非空
        if (selDept.SelectedValue == "")
        {
            context.AddError("A200002030", selDept);
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
        vars.Add("00");//00为入库状态

        vars.Add(this.txtVolumnNo_Sel.Text.Trim());
        vars.Add(this.txtBeginNo_Sel.Text.Trim());
        vars.Add(this.txtEndNo_Sel.Text.Trim());

        DataTable data = SPHelper.callITQuery(context, "StockOut", vars.ToArray());

        gvResult.DataSource = data;
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;

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
