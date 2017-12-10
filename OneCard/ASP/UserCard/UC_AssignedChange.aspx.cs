using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using Common;

public partial class ASP_UserCard_UC_AssignedChange : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        UserCardHelper.selectDepts(context, selDept, true);
        UserCardHelper.selectAllStaffs(context, selOper, selDept, true);
        // 首先清空临时表

        GroupCardHelper.clearTempCustInfoTable(context, Session.SessionID);

        clearGridViewData();

    }

    protected void selDept_SelectedIndexChanged(object sender, EventArgs e)
    {
        //查询选择部门名称后,设置员工姓名下拉列表值
        UserCardHelper.selectAllStaffs(context, selOper, selDept, true);
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

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (selDept.SelectedValue == "")
        {
            context.AddError("归属部门不能为空", selDept);
            return;
        }

        if (selOper.SelectedValue == "")
        {
            context.AddError("归属员工不能为空", selOper);
            return;
        }

        context.SPOpen();

        context.AddField("p_ASSIGNEDSTAFFNO").Value = selOper.SelectedValue;
        context.AddField("p_ASSIGNEDDEPARTID").Value = selDept.SelectedValue;
        context.AddField("p_CURRENTTIME", "DateTime", "InputOutput", "");
        context.AddField("p_TRADEID", "string", "Output", "16");

        bool ok = context.ExecuteSP("SP_UC_AssignedChange");

        if (ok)
        {
            AddMessage("更改卡归属成功");
        }
    }
}
