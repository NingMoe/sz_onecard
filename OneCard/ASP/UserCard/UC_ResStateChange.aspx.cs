using System;
using System.Web.UI;
using System.Data;
using Common;

public partial class ASP_UserCard_UC_ResStateChange : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 首先清空临时表

        GroupCardHelper.clearTempCustInfoTable(context, Session.SessionID);

        clearGridViewData();

    }

    // 清除gridview数据
    private void clearGridViewData()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        btnSubmit.Enabled = false;
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        GroupCardHelper.clearTempCustInfoTable(context, Session.SessionID);

        clearGridViewData();
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!SubmitValidate())
            return;

        context.DBOpen("Insert");

        if (txtToCardNo.Text != "")
        {
            context.ExecuteNonQuery("insert into TMP_COMMON(f0, f1) values('"
                        + txtFromCardNo.Text + "', '" + txtToCardNo.Text + "')");
        }
        else
        {
            context.ExecuteNonQuery("insert into TMP_COMMON(f0) values('"
                    + txtFromCardNo.Text + "')");
        }
        context.DBCommit();

        updateGridView();

        btnClear.Enabled = true;
        btnSubmit.Enabled = true;
    }

    private bool SubmitValidate()
    {
        Validation valid = new Validation(context);
        long fromCard = 0, toCard = 0;

        //对起始卡号进行非空、长度、数字检验


        bool b = valid.notEmpty(txtFromCardNo, "A004112100");
        if (b) b = valid.fixedLength(txtFromCardNo, 16, "A004112101");
        if (b) fromCard = valid.beNumber(txtFromCardNo, "A004112102");

        //对终止卡号进行长度、数字检验
        if (txtToCardNo.Text != "")
        {
            b = valid.fixedLength(txtToCardNo, 16, "A004112104");
            toCard = valid.beNumber(txtToCardNo, "A004112105");

            // 0 <= 终止卡号-起始卡号 <= 10000
            if (fromCard > 0 && toCard > 0)
            {
                long quantity = toCard - fromCard;
                b = valid.check(quantity >= 0, "A004112106");
                if (b) valid.check(quantity <= 10000, "A004112107");
            }
        }

        return !context.hasError();
    }

    protected void btnUpload_Click(object sender, EventArgs e)
    {
        GroupCardHelper.uploadFileValidate(context, FileUpload1);
        if (context.hasError()) return;

        UserCardHelper.UploadFile(context, FileUpload1, Session.SessionID);
        if (context.hasError()) return;

        updateGridView();

        btnClear.Enabled = true;
        btnSubmit.Enabled = true;
    }

    private void updateGridView()
    {
        context.DBOpen("Select");
        string sql = "select * from (select rownum seq, f0 Begincardno, f1 Endcardno from TMP_COMMON) order by seq desc";
        DataTable dt = context.ExecuteReader(sql);
        context.DBCommit();

        UserCardHelper.resetData(gvResult, dt);
    }

    //private void createCustInfoGrid()
    //{
    //    DataTable data = SPHelper.callPBQuery(context, "ResstateChecks");
    //    UserCardHelper.resetData(gvResult, data);

    //    data = GroupCardHelper.callQuery(context, "BadItems");

    //    if (data != null && data.Rows.Count > 0 && ((decimal)data.Rows[0].ItemArray[0]) > 0)
    //    {
    //        context.AddError("共有" + data.Rows[0].ItemArray[0] + "张卡片没有通过检验，详见下面列表");
    //        btnSubmit.Enabled = false;
    //        return;
    //    }

    //    btnSubmit.Enabled = true;
    //}

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        context.SPOpen();

        context.AddField("p_CURRENTTIME", "DateTime", "InputOutput", "");
        context.AddField("p_TRADEID", "string", "Output", "16");

        bool ok = context.ExecuteSP("SP_UC_ResStateChange");

        if (ok)
        {
            AddMessage("更改卡入库状态成功");
        }
    }
}
