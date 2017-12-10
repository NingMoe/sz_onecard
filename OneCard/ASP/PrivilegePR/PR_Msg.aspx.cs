using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using PDO.PrivilegePR;
using Master;
using System.Data;
using TM;
using System.IO;
using System.Text;

public partial class ASP_PrivilegePR_PR_Msg : Master.Master
{
    #region  Initialization
    protected void Page_Load(object sender, EventArgs e)
    {
        if (labSentResult.Text != "")
        {
            labSentResult.Text = "";
        }
        if (Page.IsPostBack) return;

        SP_PR_QueryPDO pdo = new SP_PR_QueryPDO();
        StoreProScene sp = new StoreProScene();
        pdo.funcCode = "QueryDept";

        DataTable dt = sp.Execute(context, pdo);
        UserCardHelper.resetData(gvDept, dt);

        pdo = new SP_PR_QueryPDO();
        pdo.funcCode = "QueryRole";
        dt = sp.Execute(context, pdo);
        UserCardHelper.resetData(gvRole, dt);

        pdo = new SP_PR_QueryPDO();
        pdo.funcCode = "QueryStaff";
        dt = sp.Execute(context, pdo);
        UserCardHelper.resetData(gvStaff, dt);
        queryRecvMsg();

    }
    #endregion

    #region  Messages Funtions
    /// <summary>
    /// 查找发件信息
    /// </summary>
    protected void querySentMsg()
    {
        SP_PR_QueryPDO pdo = new SP_PR_QueryPDO();
        StoreProScene sp = new StoreProScene();
        pdo.funcCode = "QuerySentMsg";
        pdo.var1 = context.s_DepartID;
        pdo.var2 = context.s_UserID;

        DataTable dt = sp.Execute(context, pdo);
        UserCardHelper.resetData(gvRecvList, dt);
    }
    /// <summary>
    /// 查找收件信息
    /// </summary>
    protected void queryRecvMsg()
    {
        SP_PR_QueryPDO pdo = new SP_PR_QueryPDO();
        StoreProScene sp = new StoreProScene();
        pdo.funcCode = "QueryRecvMsg";
        pdo.var1 = context.s_DepartID;
        pdo.var2 = context.s_UserID;

        DataTable dt = sp.Execute(context, pdo);
        UserCardHelper.resetData(gvRecvList, dt);
    }
    /// <summary>
    /// 转发
    /// </summary>
    protected void transferMsg()
    {
        SP_PR_QueryPDO pdo = new SP_PR_QueryPDO();
        StoreProScene sp = new StoreProScene();
        pdo.funcCode = "QuerySingleMsg";
        pdo.var1 = hidShowMsgId.Value;

        DataTable dt = sp.Execute(context, pdo);
        if (dt.Rows.Count > 0)
        {
            Object[] row = dt.Rows[0].ItemArray;

            txtTitle.Text = "FW: " + row[3];
            radLevel.SelectedValue = "" + row[4];
            txtBody.Text = "\r\n\r\n---原始消息----\r\n" + row[6];
        }
        msgWritePage.Attributes["style"] = "";
        msgWriteResultPage.Attributes["style"] = "display: none";
    }
    /// <summary>
    /// 回复
    /// </summary>
    protected void replyMsg()
    {
        SP_PR_QueryPDO pdo = new SP_PR_QueryPDO();
        StoreProScene sp = new StoreProScene();
        pdo.funcCode = "QuerySingleMsg";
        pdo.var1 = hidShowMsgId.Value;

        DataTable dt = sp.Execute(context, pdo);
        if (dt.Rows.Count > 0)
        {
            Object[] row = dt.Rows[0].ItemArray;

            txtRecv.Text = "员工: " + row[1];
            hidMsgToDepts.Value = "";
            hidMsgToRoles.Value = "";
            hidMsgToStaffs.Value = "" + row[2];

            txtTitle.Text = "Re: " + row[3];
            radLevel.SelectedValue = "" + row[4];
            txtBody.Text = "\r\n\r\n---原始消息----\r\n" + row[6];
        }
        msgWritePage.Attributes["style"] = "";
        msgWriteResultPage.Attributes["style"] = "display: none";
    }
    /// <summary>
    /// 显示信息明细
    /// </summary>
    protected void showMsg()
    {
        SP_PR_QueryPDO pdo = new SP_PR_QueryPDO();
        StoreProScene sp = new StoreProScene();
        pdo.funcCode = "QuerySingleMsg";
        pdo.var1 = hidShowMsgId.Value;
        pdo.var2 = context.s_DepartID;
        pdo.var3 = context.s_UserID;

        DataTable dt = sp.Execute(context, pdo);
        if (dt.Rows.Count > 0)
        {
            Object[] row = dt.Rows[0].ItemArray;

            txtShowMsgger.Text = "" + row[1] + " 发送于 " + ((DateTime)row[5]).ToString("yyyy-MM-dd HH:mm:ss");
            txtShowTitle.Text = "" + row[3];
            selShowLevel.SelectedValue = "" + row[4];
            txtShowBody.Text = "" + row[6];
            txtShowBody.Width = 850;
            if (row[7] != null && !string.IsNullOrEmpty(row[7].ToString()))
            {
                linkDownLoad.Visible = true;
            }
            else
            {
                linkDownLoad.Visible = false;
            }
        }
    }
    /// <summary>
    /// 删除收件信息
    /// </summary>
    protected void delMsg()
    {
        SP_PR_QueryPDO pdo = new SP_PR_QueryPDO();
        StoreProScene sp = new StoreProScene();
        pdo.funcCode = "DelMsgList";
        pdo.var1 = hidDelMsgIdList.Value;
        pdo.var2 = context.s_DepartID;
        pdo.var3 = context.s_UserID;

        sp.Execute(context, pdo);

        queryRecvMsg();
    }
    /// <summary>
    /// 删除已发送信息
    /// </summary>
    protected void delSentMsg()
    {
        SP_PR_QueryPDO pdo = new SP_PR_QueryPDO();
        StoreProScene sp = new StoreProScene();
        pdo.funcCode = "DelSentList";
        pdo.var1 = hidDelMsgIdList.Value;
        pdo.var2 = context.s_DepartID;
        pdo.var3 = context.s_UserID;

        sp.Execute(context, pdo);

        querySentMsg();
    }
    /// <summary>
    /// 发送信息
    /// </summary>
    protected void sendMsg(object sender, EventArgs e)
    {
        if (fileUpload.HasFile)
        {
            //检验文件大小
            int len = fileUpload.FileBytes.Length;
            if (len > 1 * 1024 * 1024) // 1M
            {
                labSentResult.Text = "附件大小不能超过1M";
                setup1.Attributes["class"] = "inline";
                setup2.Attributes["class"] = "disable";
                msgWritePage.Attributes["style"] = "display: none";
                msgWriteResultPage.Attributes["style"] = "";
                return;
            }
        }

        if (txtBody.Text.Length > 1024)
        {
            labSentResult.Text = "发送内容文本太长";
            setup1.Attributes["class"] = "inline";
            setup2.Attributes["class"] = "disable";
            msgWritePage.Attributes["style"] = "display: none";
            msgWriteResultPage.Attributes["style"] = "";
            return;
        }
        SP_PR_SendMsgPDO pdo = new SP_PR_SendMsgPDO();
        pdo.msgtitle = txtTitle.Text;
        pdo.msgbody = txtBody.Text;
        pdo.msglevel = Convert.ToInt32(radLevel.SelectedValue);

        pdo.depts = hidMsgToDepts.Value;
        pdo.roles = hidMsgToRoles.Value;
        pdo.staffs = hidMsgToStaffs.Value;

        pdo.msgpos = 1;
        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (!ok)
        {
            labSentResult.Text = pdoOut.retMsg;
        }
        else
        {
            if (fileUpload.HasFile)
            {
                //获取附件
                HttpPostedFile upFile = fileUpload.PostedFile;
                int FileLength = upFile.ContentLength;
                Byte[] FileByteArray = new Byte[FileLength];
                Stream StreamObject = upFile.InputStream;
                StreamObject.Read(FileByteArray, 0, FileLength);
                StreamObject.Close();

                UpdateFile(pdoOut.retMsg, fileUpload.FileName, FileByteArray);
            }
            labSentResult.Text = "消息发送成功!";
        }
        setup1.Attributes["class"] = "inline";
        setup2.Attributes["class"] = "disable";
        msgWritePage.Attributes["style"] = "display: none";
        msgWriteResultPage.Attributes["style"] = "";
    }
    /// <summary>
    /// 更新附件
    /// </summary>
    /// <param name="p_outcardsamplecode"></param>
    /// <param name="buff">二进制流文件</param>
    public void UpdateFile(string ID, string filename, byte[] buff)
    {
        if (filename.Length > 50)
        {
            filename = filename.Substring(0, 50);
        }
        context.DBOpen("BatchDML");
        context.AddField(":MSGID", "String").Value = ID;
        context.AddField(":MSGFILENAME", "String").Value = filename;
        context.AddField(":MSGFILE", "BLOB").Value = buff;
        string sql = "UPDATE TF_B_MSG SET MSGFILE = :MSGFILE,MSGFILENAME = :MSGFILENAME WHERE MSGID = :MSGID";
        context.ExecuteNonQuery(sql);
        context.DBCommit();
    }
    #endregion

    #region Event Handler
    /// <summary>
    /// 点击
    /// </summary>
    protected void btnConfirm_Click(object sender, EventArgs e)
    {

        if (hidWarning.Value == "showMsg")
        {
            showMsg();
        }
        else if (hidWarning.Value == "delMsg")
        {
            delMsg();
        }
        else if (hidWarning.Value == "queryRecvMsg")
        {
            queryRecvMsg();
        }
        else if (hidWarning.Value == "transferMsg")
        {
            transferMsg();
        }
        else if (hidWarning.Value == "replyMsg")
        {
            replyMsg();
        }
        else if (hidWarning.Value == "querySentMsg")
        {
            querySentMsg();
        }
        else if (hidWarning.Value == "delSentMsg")
        {
            delSentMsg();
        }

        hidWarning.Value = "";
    }
    /// <summary>
    /// 下载
    /// </summary>
    protected void linkDownLoad_Click(object sender, EventArgs e)
    {
        //生成文件
        SP_PR_QueryPDO pdo = new SP_PR_QueryPDO();
        StoreProScene sp = new StoreProScene();
        pdo.funcCode = "QuerySingleMsg";
        pdo.var1 = hidShowMsgId.Value;
        pdo.var2 = context.s_DepartID;
        pdo.var3 = context.s_UserID;

        DataTable dt = sp.Execute(context, pdo);
        if (dt.Rows.Count > 0)
        {
            Object[] row = dt.Rows[0].ItemArray;
            if (row[7] != null && row[8] != null)
            {
                byte[] file = (byte[])row[8];
                //下载文件
                HttpResponse contextResponse = HttpContext.Current.Response;
                contextResponse.Clear();
                contextResponse.Buffer = true;
                string strTemp = System.Web.HttpUtility.UrlEncode(row[7].ToString(), System.Text.Encoding.UTF8);//解决文件名乱码
                contextResponse.AppendHeader("Content-Disposition", String.Format("attachment;filename={0}", strTemp));
                contextResponse.AppendHeader("Content-Length", file.Length.ToString());
                contextResponse.BinaryWrite(file);
                contextResponse.Flush();
                contextResponse.End();
            }
        }
    }

    /// <summary>
    /// DataBound事件
    /// </summary>
    protected void gvRecvList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[2].Text == "0")
            {
                e.Row.CssClass = "tabsel";
            }

            e.Row.Cells[0].Text = e.Row.Cells[0].Text.Replace("xxxyyy", e.Row.Cells[1].Text);

            string msglevel = e.Row.Cells[5].Text;
            e.Row.Cells[5].Text = msglevel == "0" ? "普通"
                : msglevel == "1" ? "重要"
                : msglevel == "2" ? "紧急"
                : msglevel == "3" ? "特急"
                : "未知";

            e.Row.Attributes.Add("OnDblClick", "showSingleMsg('" + e.Row.Cells[1].Text + "')");
        }

        if (e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[1].Visible = false;
            e.Row.Cells[2].Visible = false;
        }

    }
   
    /// <summary>
    /// 对收件信息排序
    /// </summary>
    protected void gvRecvList_Sorting(object sender, GridViewSortEventArgs e)
    {
        if (hidIsInRecvBox.Value == "true")
        {
            this.queryRecvMsg();
        }
        else
        {
            this.querySentMsg();
        }

        GridViewSortExpression = e.SortExpression;
        gvRecvList.DataSource = SortDataTable(gvRecvList.DataSource as DataTable, false);
        gvRecvList.DataBind();
    }
    #endregion

    #region Properties
    /// <summary>
    /// 获取或设置排序方向
    /// </summary>
    private string GridViewSortDirection
    {
        get { return ViewState["SortDirection"] as string ?? "ASC"; }
        set { ViewState["SortDirection"] = value; }
    }
    /// <summary>
    /// 获取或设置排序内容
    /// </summary>
    private string GridViewSortExpression
    {
        get { return ViewState["SortExpression"] as string ?? string.Empty; }
        set { ViewState["SortExpression"] = value; }
    }
    #endregion

    #region 排序
    /// <summary>
    /// 转换排序方向
    /// </summary>
    private string GetSortDirection()
    {
        switch (GridViewSortDirection)
        {
            case "ASC":
                GridViewSortDirection = "DESC";
                break;
            case "DESC":
                GridViewSortDirection = "ASC";
                break;
        }
        return GridViewSortDirection;
    }
    /// <summary>
    /// 排序
    /// </summary>
    protected DataView SortDataTable(DataTable dataTable, bool isPageIndexChanging)
    {
        if (dataTable == null)
        {
            return new DataView();
        }

        DataView dataView = new DataView(dataTable);
        if (GridViewSortExpression != string.Empty)
        {
            dataView.Sort = string.Format("{0} {1}", GridViewSortExpression,
                isPageIndexChanging ? GridViewSortDirection : GetSortDirection());
        }
        return dataView;
    }
    #endregion
}
