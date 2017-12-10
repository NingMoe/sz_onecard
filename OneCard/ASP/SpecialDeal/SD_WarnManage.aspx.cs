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
using TDO.BalanceParameter;
using TDO.BalanceChannel;
using TM;

public partial class ASP_SpecialDeal_SD_WarnManage : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期
            TMTableModule tmTMTableModule = new TMTableModule();
            txtFromDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");

            TF_SELSUP_BALUNITTDO tdoTF_SELSUP_BALUNITIn = new TF_SELSUP_BALUNITTDO();
            TF_SELSUP_BALUNITTDO[] tdoTF_SELSUP_BALUNITOutArr = (TF_SELSUP_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_SELSUP_BALUNITIn, typeof(TF_SELSUP_BALUNITTDO), null);

            ControlDeal.SelectBoxFill(selBalunit.Items, tdoTF_SELSUP_BALUNITOutArr, "BALUNIT", "BALUNITNO", true);
            selBalunit.Items[0].Value = "00000000";

        }
    }

    private DataTable ShowData(){
        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        if (ddlBalType.SelectedValue.Equals("0"))
        {
            pdo.funcCode = "SUPPLY_Warn_REPORT";
        }
        else
        {
            pdo.funcCode = "SUPPLY_Warn_REPORTDEPTBAL";
        }
        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;
        pdo.var7 = selBalunit.SelectedValue;

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        return data;
    }

    protected void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        gvResult.DataSource = ShowData();
        gvResult.DataBind();
    }
    // 查询输入校验处理
    private void validate()
    {
        Validation valid = new Validation(context);

        bool b = Validation.isEmpty(txtFromDate);
        DateTime? fromDate = null, toDate = null;
        if (!b)
        {
            fromDate = valid.beDate(txtFromDate, "开始日期范围起始值格式必须为yyyyMMdd");
        }
        b = Validation.isEmpty(txtToDate);
        if (!b)
        {
            toDate = valid.beDate(txtToDate, "结束日期范围终止值格式必须为yyyyMMdd");
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        }

    }

    
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if(context.hasError()) return;
        DataTable data=ShowData();
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
            
        }
        UserCardHelper.resetData(gvResult, data);
    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            ExportGridView(gvResult);
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }

    /// <summary>
    /// 单元类型选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ddlBalType_SelectedIndexChanged(object sender, EventArgs e)
    {
        selBalunit.Items.Clear();

        if (this.ddlBalType.SelectedValue.Equals("0"))
        {
            context.DBOpen("Select");
            System.Text.StringBuilder sql = new System.Text.StringBuilder();
            sql.Append("SELECT DBALUNIT, DBALUNITNO	FROM TF_DEPT_BALUNIT WHERE USETAG = '1' AND DEPTTYPE = '2'");
            sql.Append("ORDER BY DBALUNITNO");

            System.Data.DataTable table = context.ExecuteReader(sql.ToString());
            GroupCardHelper.fill(selBalunit, table, true);
        }
        else
        {
            TMTableModule tmTMTableModule = new TMTableModule();
            TF_SELSUP_BALUNITTDO tdoTF_SELSUP_BALUNITIn = new TF_SELSUP_BALUNITTDO();
            TF_SELSUP_BALUNITTDO[] tdoTF_SELSUP_BALUNITOutArr = (TF_SELSUP_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_SELSUP_BALUNITIn, typeof(TF_SELSUP_BALUNITTDO), "S094570030", "TF_SELSUP_BALUNIT", null);
            ControlDeal.SelectBoxFill(selBalunit.Items, tdoTF_SELSUP_BALUNITOutArr, "BALUNIT", "BALUNITNO", true);
        }
    }
}
