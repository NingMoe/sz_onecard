using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using Common;
using System.Web;
using System.IO;
/***************************************************************
 * 功能名: 其他资源管理  文档管理
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2013/7/2      董翔			初次开发
 ****************************************************************/
public partial class ASP_ResourceManage_RM_DocumentManager : Master.Master
{
    //初始化
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            linkDownLoad.Visible = false;
        }
    }

    //查询事件
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!queryValidation())
            return;

        gvResult.DataSource = QueryDocumentList();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }

    /// <summary>
    /// 查询输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean queryValidation()
    {
        //校验日期
        ResourceManageHelper.checkDate(context, txtStartDate, txtEndDate, "A095470102", "A095470103", "A095470104");

        return !context.hasError();
    }

    /// <summary>
    /// 提交输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean submitValidation()
    {
        //文档名称
        if (string.IsNullOrEmpty(txtContractName.Text.Trim()))
            context.AddError("文档名称不能为空", txtContractName);
        else if (Validation.strLen(txtContractName.Text.Trim()) > 50)
            context.AddError("文档名称长度不能超过50位", txtContractName);

        //文档编号
        if (string.IsNullOrEmpty(txtContractID.Text.Trim()))
            context.AddError("文档编号不能为空", txtContractID);
        else if (Validation.strLen(txtContractID.Text.Trim()) > 50)
            context.AddError("文档编号长度不能超过50位", txtContractID);

        //签订单位
        if (!string.IsNullOrEmpty(txtSigningCompany.Text.Trim()) && Validation.strLen(txtSigningCompany.Text.Trim()) > 50)
            context.AddError("签订单位度不能超过50位", txtSigningCompany);

        //签订日期
        if (!string.IsNullOrEmpty(txtSigningDate.Text.Trim()) && !Validation.isDate(txtSigningDate.Text.Trim(), "yyyyMMdd"))
            context.AddError("签订日期格式必须为yyyyMMdd", txtSigningDate);

        //备注
        if (!string.IsNullOrEmpty(txtReMark.Text.Trim()))
            if (Validation.strLen(txtReMark.Text.Trim()) > 255)
                context.AddError("文档内容概要长度不能超过255位", txtReMark);

        if (FileUpload1.HasFile)
        {
            //检验文件大小
            int len = FileUpload1.FileBytes.Length;
            if (len > 5 * 1024 * 1024) // 5M
            {
                context.AddError("文档扫描件大小不能大于5兆", FileUpload1);
            }
            if (FileUpload1.FileName.Length > 50)
            {
                context.AddError("文档扫描件文件名长度不能大于50位", FileUpload1);
            }
        }

        return !context.hasError();
    }

    /// <summary>
    /// 查询文档
    /// </summary>
    /// <returns></returns>
    protected ICollection QueryDocumentList()
    {
        string[] parm = new string[5];
        parm[0] = txtStartDate.Text;
        parm[1] = txtEndDate.Text; ;
        parm[2] = txtSelContractName.Text.Trim();
        parm[3] = txtSelComPany.Text.Trim();
        parm[4] = ddlSelDocumentType.SelectedValue;
        DataTable data = SPHelper.callQuery("SP_RM_OTHER_Query", context, "Query_DocumentList", parm);
        if (data.Rows.Count == 0)
        {
            ResourceManageHelper.resetData(gvResult, data);
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return new DataView(data);
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            ResourceManageHelper.ClearRowDataBound(e);
            if (e.Row.Cells[5].Text != "&nbsp;" && e.Row.Cells[5].Text != "")
            {
                e.Row.Cells[5].Text = (Convert.ToDateTime(e.Row.Cells[5].Text)).ToString("yyyy-MM-dd");
            }
        }
    }
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        //注册行单击事件
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    //选择行事件
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        //订购单号
        GridViewRow dr = ((GridView)(sender)).SelectedRow;
        string contractid = dr.Cells[0].Text.ToString().Trim();
        QueryDocumentInfo(contractid);
    }

    //查询文档明细
    public void QueryDocumentInfo(string contractid)
    {
        string[] parm = new string[1];
        parm[0] = contractid;
        DataTable data = SPHelper.callQuery("SP_RM_OTHER_Query", context, "Query_ContractInfo", parm);
        if (data.Rows.Count == 0)
        {
            context.AddError("查询文档明细失败");
            return;
        }
        else
        {
            //btnSubmit.Enabled = true;
            DataRow dr = data.Rows[0];
            txtContractName.Text = dr["CONTRACTNAME"].ToString();
            txtContractID.Text = dr["CONTRACTID"].ToString();
            txtSigningCompany.Text = dr["SIGNINGCOMPANY"].ToString();
            if (!string.IsNullOrEmpty(dr["SIGNINGDATE"].ToString()))
                txtSigningDate.Text = ((DateTime)dr["SIGNINGDATE"]).ToString("yyyyMMdd");
            txtReMark.Text = dr["CONTRACTDESC"].ToString();
            hideContractCode.Value = dr["CONTRACTCODE"].ToString();
            ddlDocumentType.SelectedIndex = ddlDocumentType.Items.IndexOf(ddlDocumentType.Items.FindByValue(dr["DOCUMENTTYPE"].ToString()));
            if (dr["CONTRACTFILENAME"] != null && !string.IsNullOrEmpty(dr["CONTRACTFILENAME"].ToString()))
            {
                linkDownLoad.Visible = true;
            }
            else
            {
                linkDownLoad.Visible = false;
            }
        }
    }




    //新增文档
    protected void btnDocumentAdd_Click(object sender, EventArgs e)
    {
        //提交校验
        if (!submitValidation())
            return;

        context.SPOpen();
        //新增文档
        context.AddField("P_CONTRACTNAME").Value = txtContractName.Text.Trim();
        context.AddField("P_CONTRACTID").Value = txtContractID.Text.Trim();
        context.AddField("P_SIGNINGCOMPANY").Value = txtSigningCompany.Text.Trim();
        context.AddField("P_SIGNINGDATE").Value = txtSigningDate.Text.Trim();
        context.AddField("P_CONTRACTDESC").Value = txtReMark.Text.Trim();
        context.AddField("P_DOCUMENTTYPE").Value = ddlDocumentType.SelectedValue;
        context.AddField("P_CONTRACTCODE", "String", "output", "16", null);
        //调用新增文档存储过程
        bool ok = context.ExecuteSP("SP_RM_ADDCONTRACT");

        if (ok)
        {
            String contractCode = "" + context.GetFieldValue("P_CONTRACTCODE");
            if (FileUpload1.HasFile)
            {
                //获取附件
                HttpPostedFile upFile = FileUpload1.PostedFile;
                int FileLength = upFile.ContentLength;
                Byte[] FileByteArray = new Byte[FileLength];
                Stream StreamObject = upFile.InputStream;
                StreamObject.Read(FileByteArray, 0, FileLength);
                StreamObject.Close();

                //保存附件
                UpdateFile(contractCode, FileUpload1.FileName, FileByteArray);
            }
            AddMessage("新增成功");
            Clear();
        }
    }

    //修改文档
    protected void btnDocumentModify_Click(object sender, EventArgs e)
    {
        //提交校验
        if (!submitValidation())
            return;

        context.SPOpen();
        //修改文档
        context.AddField("P_CONTRACTCODE").Value = hideContractCode.Value;
        context.AddField("P_CONTRACTNAME").Value = txtContractName.Text.Trim();
        context.AddField("P_CONTRACTID").Value = txtContractID.Text.Trim();
        context.AddField("P_SIGNINGCOMPANY").Value = txtSigningCompany.Text.Trim();
        context.AddField("P_SIGNINGDATE").Value = txtSigningDate.Text.Trim();
        context.AddField("P_CONTRACTDESC").Value = txtReMark.Text.Trim();
        context.AddField("P_DOCUMENTTYPE").Value = ddlDocumentType.SelectedValue;
        //调用修改文档同存储过程
        bool ok = context.ExecuteSP("SP_RM_EDITCONTRACT");

        if (ok)
        {
            if (FileUpload1.HasFile)
            {
                //获取附件
                HttpPostedFile upFile = FileUpload1.PostedFile;
                int FileLength = upFile.ContentLength;
                Byte[] FileByteArray = new Byte[FileLength];
                Stream StreamObject = upFile.InputStream;
                StreamObject.Read(FileByteArray, 0, FileLength);
                StreamObject.Close();

                //保存附件
                UpdateFile(hideContractCode.Value, FileUpload1.FileName, FileByteArray);
            }
            AddMessage("修改成功");
            Clear();
        }
    }

    /// <summary>
    /// 更新图片
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
        context.AddField(":P_ID", "String").Value = ID;
        context.AddField(":P_FILENAME", "String").Value = filename;
        context.AddField(":BLOB", "BLOB").Value = buff;
        string sql = "UPDATE TL_R_CONTRACT SET CONTRACTFILE = :BLOB,CONTRACTFILENAME = :P_FILENAME WHERE CONTRACTCODE = :P_ID";
        context.ExecuteNonQuery(sql);
        context.DBCommit();
    }

    //删除文档
    protected void btnDocumentDelete_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(hideContractCode.Value))
        {
            context.AddError("请选择一个文档");
            return;
        }
        context.SPOpen();
        //删除文档
        context.AddField("P_CONTRACTCODE").Value = hideContractCode.Value;
        //调用删除文档存储过程
        bool ok = context.ExecuteSP("SP_RM_DELETECONTRACT");
        if (ok)
        {
            AddMessage("删除成功");
            Clear();
        }
    }

    //下载扫描件
    protected void linkDownLoad_Click(object sender, EventArgs e)
    {
        //生成文件
        string[] parm = new string[1];
        parm[0] = hideContractCode.Value;
        DataTable dt = SPHelper.callQuery("SP_RM_OTHER_Query", context, "Query_ContractInfo", parm);
        if (dt.Rows.Count > 0)
        {
            Object[] row = dt.Rows[0].ItemArray;
            if (row[6] != null && row[7] != null)
            {
                byte[] file = (byte[])row[6];
                //下载文件
                HttpResponse contextResponse = HttpContext.Current.Response;
                contextResponse.Clear();
                contextResponse.Buffer = true;
                contextResponse.AppendHeader("Content-Disposition", String.Format("attachment;filename={0}", Server.UrlEncode(row[7].ToString())));
                contextResponse.AppendHeader("Content-Length", file.Length.ToString());
                contextResponse.BinaryWrite(file);
                contextResponse.Flush();
                contextResponse.End();
            }
        }
    }

    private void Clear()
    {
        //清除输入的员工信息
        linkDownLoad.Visible = false;
        hideContractCode.Value = "";
        txtContractName.Text = "";
        txtContractID.Text = "";
        txtSigningCompany.Text = "";
        txtSigningDate.Text = "";
        txtReMark.Text = "";
        gvResult.DataSource = QueryDocumentList();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }
}