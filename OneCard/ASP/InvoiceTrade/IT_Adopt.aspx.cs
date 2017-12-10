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
using Common;
using TM;
using TDO.BalanceChannel;
using TDO.UserManager;
using PDO.InvoiceTrade;
using System.Collections.Generic;

public partial class ASP_InvoiceTrade_IT_Adopt : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            QueryInvoice();
        }
    }
    //查询分配未领用的发票
    private void QueryInvoice()
    {
        List<string> vars = new List<string>();
        vars.Add("05");//05为分配状态

        vars.Add(this.context.s_UserID);

        DataTable data = SPHelper.callITQuery(context, "invoicenoSegmentSel", vars.ToArray());

        //string sql = "select VOLUMENO,min(INVOICENO) MININVOICENO,count(INVOICENO) INVOICENUM from TL_R_INVOICE t where t.ALLOTSTATECODE='05' and t.ALLOTSTAFFNO='999999' group by VOLUMENO";

        //TMTableModule tmTMTableModule = new TMTableModule();
        //TDO.InvoiceTrade.TL_R_INVOICETDO tdoTL_R_INVOICETDO = new TDO.InvoiceTrade.TL_R_INVOICETDO();
        //DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTL_R_INVOICETDO, null, sql, 0);
        gvResult.DataSource = data;
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }


  



    protected void InvoiceAdopt_Click(object sender, EventArgs e)
    {
        SP_IT_AdoptPDO pdo = new SP_IT_AdoptPDO();
       
        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            QueryInvoice();
            AddMessage("M200002092:发票领用成功");
        }

    }
}
