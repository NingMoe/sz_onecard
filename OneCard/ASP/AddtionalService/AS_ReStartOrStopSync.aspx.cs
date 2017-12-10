using System;
using System.Data;
using System.Web.UI;
using Common;
using Master;
using System.Web.UI.WebControls;
using PDO.AdditionalService;
using System.Collections.Generic;

/**********************************
 * 图书馆数据重新同步或不同步
 * 2015-06-26
 * gl
 * 初次编写
 * ********************************/
public partial class ASP_AddtionalService_AS_ReStartOrStopSync : Master.Master
{
    #region Initialization
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            gvLibrary.Visible = false;
            gvGarden.Visible = false;
            gvRelax.Visible = false;
            initLoad();
        }
    }


    private void initLoad()
    {
        //初始化同步结果
        selSyncTypes.Items.Add(new ListItem("---请选择---", ""));
        selSyncTypes.Items.Add(new ListItem("0:图书馆", "0"));
        selSyncTypes.Items.Add(new ListItem("1:休闲", "1"));
        selSyncTypes.Items.Add(new ListItem("2:园林", "2"));

        selSyncTypes.SelectedIndex = 0;
    }
    #endregion 

    #region Private
   
    #endregion

    #region Event Handler
    //切换查询类型
    protected void selSyncTypes_Changed(object sender, EventArgs e)
    {
        if (selSyncTypes.SelectedValue == "0")
        {

            gvLibrary.Visible = true;
            gvLibrary.DataSource = new DataTable();
            gvLibrary.DataBind();
            gvGarden.Visible = false;
            gvRelax.Visible = false;
        }
        else if (selSyncTypes.SelectedValue == "1")
        {
            gvLibrary.Visible = false;
            gvGarden.Visible = false;
            gvRelax.Visible = true;
            gvRelax.DataSource = new DataTable();
            gvRelax.DataBind();
        }
        else if (selSyncTypes.SelectedValue == "2")
        {
            gvLibrary.Visible = false;
            gvGarden.Visible = true;
            gvGarden.DataSource = new DataTable();
            gvGarden.DataBind();
            gvRelax.Visible = false;
        }
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (context.hasError()) return;

        if (selSyncTypes.SelectedValue == "0")
        {
            SP_AS_QueryPDO pdo = new SP_AS_QueryPDO();
            pdo.funcCode = "QUERYLIBRARYSYNCFAIL";   //查询同步信息
            StoreProScene storePro = new StoreProScene();
            DataTable data = storePro.Execute(context, pdo);

            if (data == null || data.Rows.Count == 0)
            {
                AddMessage("N005030001: 查询结果为空");
            }
            //解密
            CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "NAME", "PAPERNO", "PHONE", "ADDR" }));

            UserCardHelper.resetData(gvLibrary, data);
        }
        else if (selSyncTypes.SelectedValue == "1")
        {
            SP_AS_QueryPDO pdo = new SP_AS_QueryPDO();
            pdo.funcCode = "QUERYGARDENXXSYNCFAIL";   //查询同步信息
            StoreProScene storePro = new StoreProScene();
            DataTable data = storePro.Execute(context, pdo);

            if (data == null || data.Rows.Count == 0)
            {
                AddMessage("N005030001: 查询结果为空");
            }
            //解密
            CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "PAPERNO" }));
            UserCardHelper.resetData(gvRelax, data);
        }
        else
        {
            SP_AS_QueryPDO pdo = new SP_AS_QueryPDO();
            pdo.funcCode = "QUERYGARDENSYNCFAIL";   //查询同步信息
            StoreProScene storePro = new StoreProScene();
            DataTable data = storePro.Execute(context, pdo);

            if (data == null || data.Rows.Count == 0)
            {
                AddMessage("N005030001: 查询结果为空");
            }
            //解密
            CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "PAPERNO" }));
            UserCardHelper.resetData(gvGarden, data);
        }
    }

    //分页
    protected void gvLibrary_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvLibrary.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    protected void gvRelax_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvRelax.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    protected void gvGarden_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvGarden.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    protected void btnReStart_Click(object sender, EventArgs e)
    {
        StartOrStopSync("0");
    }

    protected void btnStop_Click(object sender, EventArgs e)
    {
        StartOrStopSync("1");
    }
    /// <summary>
    /// RowDataBound事件
    /// </summary>
    /// <returns></returns>
    protected void gvLibrary_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[2].Visible = false;    //TRADEID隐藏
        }
    }

    /// <summary>
    /// RowDataBound事件
    /// </summary>
    /// <returns></returns>
    protected void gvGarden_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[2].Visible = false;    //TRADEID隐藏
        }
    }

    /// <summary>
    /// RowDataBound事件
    /// </summary>
    /// <returns></returns>
    protected void gvRelax_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[2].Visible = false;    //TRADEID隐藏
        }
    }
    private void StartOrStopSync(string Type)
    {
        GridView gv = null;
        if (selSyncTypes.SelectedValue == "0")
        {
            gv = gvLibrary;
        }
        else if (selSyncTypes.SelectedValue == "1")
        {
            gv = gvRelax;
        }
        else
        {
            gv = gvGarden;
        }
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_AS_SYNCFAIL where SESSIONID='" + Session.SessionID + "'");

        Validation val = new Validation(context);
        // 根据页面数据生成临时表数据

        int count = 0;
        int seq = 0;

        foreach (GridViewRow gvr in gv.Rows)
        {

            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");

            if (cb != null && cb.Checked)
            {
                ++count;
                context.ExecuteNonQuery("insert into TMP_AS_SYNCFAIL(SESSIONID,ID,CARDNO,TRADEID)" +
                "values('" + Session.SessionID + "'," + (seq++) + ",'" + gvr.Cells[1].Text + "','" + gvr.Cells[2].Text + "')");
            }
        }
        if (context.hasError()) return;
        context.DBCommit();
        // 没有选中任何行，则返回错误

        if (count <= 0)
        {
            context.AddError("A004P03R01:没有选中任何行");
        }
        if (context.hasError()) return;

        context.SPOpen();
        context.AddField("p_SESSIONID").Value = Session.SessionID;
        context.AddField("p_TYPE").Value = selSyncTypes.SelectedValue;
        context.AddField("p_STATE").Value = Type;
        bool ok = context.ExecuteSP("SP_AS_SYNCFAILSTARTORSTOP");
        if (ok)
        {
            context.AddMessage("操作成功");
        }
        btnQuery_Click(null, null);
    }
    #endregion
}
