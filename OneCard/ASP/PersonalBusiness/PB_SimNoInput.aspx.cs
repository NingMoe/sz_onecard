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
using PDO.PersonalBusiness;
using TM;
using System.IO;
using Common;
using System.Text;

public partial class ASP_PersonalBusiness_PB_SimNoInput : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        UserCardHelper.resetData(gvResult, null);
    }

    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        createGridViewData();
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        SP_PB_SimNoInputPDO pdo = new SP_PB_SimNoInputPDO();
        pdo.SESSIONID = Session.SessionID;
        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("SIM串号录入成功");
        }

        clearGridViewData();
        clearTempTable();
    }

    private void createGridViewData()
    {
        DataTable data = SPHelper.callPBQuery(context, "QueryInvalidLines", Session.SessionID);
        if (data.Rows.Count > 0)
        {
            context.AddError("共有" + data.Rows.Count + "条记录检查未通过，详见下面列表。请检查上传文件后重试。");

            UserCardHelper.resetData(gvResult, data);
            return;
        }

        data = SPHelper.callPBQuery(context, "QuerySimCard", Session.SessionID);
        UserCardHelper.resetData(gvResult, data);

        btnSubmit.Visible = (data.Rows.Count != 0);
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        UserCardHelper.validateCardNo(context, txtCardNo, true);
        UserCardHelper.validateSimNo(context, txtSimNo, true);

        if (context.hasError()) return;

        UserCardHelper.resetData(gvResult,
            SPHelper.callPBQuery(context, "QuerySimCardNo", txtCardNo.Text, txtSimNo.Text));
    }

    protected void btnUpload_Click(object sender, EventArgs e)
    {
        clearGridViewData();
        GroupCardHelper.uploadFileValidate(context, FileUpload1);
        if (context.hasError()) return;

        // 首先清空临时表

        clearTempTable();

        context.DBOpen("Insert");
        Stream stream = FileUpload1.FileContent;
        StreamReader reader = new StreamReader(stream, Encoding.GetEncoding("gb2312"));
        string strLine = "";
        int lineCount = 0; int goodLines = 0;
        String[] fields = null;
        Hashtable ht = new Hashtable();

        while (true)
        {
            strLine = reader.ReadLine();
            if (strLine == null)
            {
                break;
            }
            ++lineCount;

            strLine = strLine.Trim();
            if (strLine.Length <= 0)
            {
                continue;
            }

            if (strLine.Length > 37)
            {
                context.AddError("第" + lineCount + "行长度为" + strLine.Length + ", 根据格式定义不能超过37");
                continue;
            }

            fields = strLine.Split(new char[2] { ',', '\t' });
            // 字段数目为2时合法

            if (fields.Length != 2)
            {
                context.AddError("第" + lineCount + "行字段数目为" + fields.Length + ", 根据格式定义必须为2");
                continue;
            }

            dealFileContent(ht, fields, lineCount);
            ++goodLines;
        }

        if (goodLines <= 0)
        {
            context.AddError("A004P01F01: 上传文件为空");
        }

        if (!context.hasError())
        {
            context.DBCommit();
            createGridViewData();
        }
        else
        {
            context.RollBack();
        }
    }

    private void dealFileContent(Hashtable ht, String[] fields, int lineCount)
    {
        String cardNo = fields[0].Trim();
        // 卡号
        if (cardNo.Length != 16)
        {
            context.AddError("第" + lineCount + "行卡号长度不是16位");
        }
        else if (!Validation.isNum(cardNo))
        {
            context.AddError("第" + lineCount + "行卡号不全是数字");
        }

        // SIM串号

        string simNo = fields[1].Trim();
        if (simNo.Length != 20)
        {
            context.AddError("第" + lineCount + "行SIM串号长度不是20位");
        }
        else if (!Validation.isCharNum(simNo))
        {
            context.AddError("第" + lineCount + "行SIM串号不全是英数字");
        }

        if (!context.hasError())
        {
            context.ExecuteNonQuery("insert into tmp_simcard_imp(cardNo, simNo,SessionID) values('"
                + cardNo + "', '" + simNo + "', '" + Session.SessionID + "')");
        }
    }

    private void clearGridViewData()
    {
        UserCardHelper.resetData(gvResult, null);

        btnSubmit.Visible = false;
    }

    private void clearTempTable()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from tmp_simcard_imp where SessionID='"
            + Session.SessionID + "'");
        context.DBCommit();
    }

}
