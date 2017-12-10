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
using PDO.UserCard;
using Master;

public partial class ASP_UserCard_UC_CardStat : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            StateSubmit();
        }
    }

    private void StateSubmit()
    {
        SP_UC_QueryPDO pdo = new SP_UC_QueryPDO();
        pdo.funcCode = "CardStat";

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        gvResult.DataSource = data;
        gvResult.DataBind();

    }

    protected void gvResult_PreRender(object sender, EventArgs e)
    {
        GridViewMergeHelper.MergeGridViewRows(gvResult, 0, 2);
    }

    private int total = 0;

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            total += Convert.ToInt32(e.Row.Cells[4].Text);
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].ColumnSpan = 4;
            e.Row.Cells[1].Visible = false;
            e.Row.Cells[2].Visible = false;
            e.Row.Cells[3].Visible = false;
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[4].Text = "" + total;
        }
    }

    protected void gvResult_DataBound(object sender, EventArgs e)
    {
        GridViewMergeHelper.DataBoundWithEmptyRows(gvResult);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        ExportGridView(gvResult);
    }
}
