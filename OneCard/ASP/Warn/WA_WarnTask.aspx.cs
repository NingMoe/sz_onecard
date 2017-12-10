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
using PDO.Warn;

public partial class ASP_Warn_WA_WarnTask : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        UserCardHelper.resetData(gvResult, null);
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (selSubmitType.SelectedValue == "0")
        {
            SP_WA_MonitorPDO pdo = new SP_WA_MonitorPDO();
            TMStorePModule.Excute(context, pdo);
            context.ErrorMessage.Clear();
            AddMessage("运行完成");
        }
        else if (selSubmitType.SelectedValue == "1")
        {
            SP_WA_Monitor_Static_AccoutPDO pdo =
                new SP_WA_Monitor_Static_AccoutPDO();
            bool ok = TMStorePModule.Excute(context, pdo);
            if (ok)
            {
                AddMessage("生成" + pdo.amount + "条告警单");
            }
        }
    }

    protected void btnCreate_Click(object sender, EventArgs e)
    {
        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, true);
        if (context.hasError()) return;

        SP_WA_TaskCreatePDO pdo = new SP_WA_TaskCreatePDO();
        pdo.beginDate = txtFromDate.Text;
        pdo.endDate = txtToDate.Text;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok) AddMessage("D860P04001: 生成新任务成功");
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, false);
        if (context.hasError()) return;

        UserCardHelper.resetData(gvResult, SPHelper.callWAQuery(context, "QueryWarnTasks",
            txtFromDate.Text, txtToDate.Text));
    }
}
