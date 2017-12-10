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

public partial class ASP_PersonalBusiness_PB_AdvSaleCardRollback : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        GroupCardHelper.clearTempCustInfoTable(context, Session.SessionID);
        UserCardHelper.resetData(gvResult, null);
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        // 对起始卡号和结束卡号进行校验
        UserCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo, true, true);
        if (context.hasError()) return;

        context.DBOpen("Insert");
        context.ExecuteNonQuery("insert into TMP_COMMON(f0, f1) values('"
            + txtFromCardNo.Text + "', '" 
            + (txtToCardNo.Text == txtFromCardNo.Text ? "" : txtToCardNo.Text) + "')");
        context.DBCommit();

        updateGridView();
        
    }
    protected void btnUpload_Click(object sender, EventArgs e)
    {
        GroupCardHelper.uploadFileValidate(context, FileUpload1);
        if (context.hasError()) return;

        UserCardHelper.UploadFile(context, FileUpload1, Session.SessionID);
        if (context.hasError()) return;

        updateGridView();

    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        GroupCardHelper.clearTempCustInfoTable(context, Session.SessionID);

        UserCardHelper.resetData(gvResult, null);
    }

    private void updateGridView()
    {
        context.DBOpen("Select");
        string sql = "select rownum \"#\", f0 开始卡号, f1 结束卡号 from TMP_COMMON";
        DataTable dt = context.ExecuteReader(sql);
        context.DBCommit();

        UserCardHelper.resetData(gvResult, dt);

        btnSubmit.Enabled = dt != null && dt.Rows.Count > 0;
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        DataTable dt = SPHelper.callPBQuery(context, "ChkAdvSaleCardRollback");
        if (dt != null && dt.Rows.Count > 0)
        {
            context.AddError(dt.Rows[0].ItemArray[0] + "不是在当前自然月售出，不允许返销");
            return;
        }

        context.SPOpen();
        context.AddField("p_operCardNo").Value = context.s_CardID;
        bool ok = context.ExecuteSP("SP_PB_AdvSaleCardRollback");

        if (ok)
        {
            AddMessage("高级售卡返销成功");
        }
        
        GroupCardHelper.clearTempCustInfoTable(context, Session.SessionID);
        UserCardHelper.resetData(gvResult, null);
        btnSubmit.Enabled = false;
    }

}
