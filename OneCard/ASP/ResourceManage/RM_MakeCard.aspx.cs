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
using Master;
using Common;
using System.Text;
using System.Runtime.InteropServices;
using System.IO;
using System.Net;


/***************************************************************
 * 功能名: 生成制卡
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2013/07/18    youyue			初次开发
 ****************************************************************/

public partial class ASP_ResourceManage_RM_MakeCard : Master.Master
{

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期
            DateTime date = new DateTime();
            date = DateTime.Today;
            txtStartDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
            txtEndDate.Text = DateTime.Today.ToString("yyyyMMdd");
            txtApplyOrderID.Text = "DG";
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();

            gvResult.DataKeyNames = new string[] { "CARDORDERID", "VALUECODE", "CARDNUM", "STATE", "ORDERTIME", "TASKID","MANUTYPECODE",
            "APPVERNO","SECTION","TASKSTATE","TASKSTARTTIME","TASKENDTIME","ORDERSTAFF","DATETIME","FILEPATH","REMARK" };
        }
        int count = this.gvResult.Rows.Count;
        for (int i = 0; i < count; i++)
        {
            Button item1 = (Button)gvResult.Rows[i].FindControl("btnDownload");//获取GridView中的下载Button
            ScriptManager.GetCurrent(this.Page).RegisterPostBackControl(item1);

            Button item2 = (Button)gvResult.Rows[i].FindControl("btnDelete");//获取GridView中的删除Button
            ScriptManager.GetCurrent(this.Page).RegisterPostBackControl(item2);
        }
    }

    /// <summary>
    /// 查询
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //查询校验
        if (!queryValidation())
            return;
        if (!privateValidation())
            return;
        gvResult.DataSource = queryTask();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }

    //操作结束后实时更新查询结果
    protected void query()
    {
        gvResult.DataSource = queryTask();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }

    /// <summary>
    /// 查询制卡任务
    /// </summary>
    /// <returns></returns>
    protected ICollection queryTask()
    {
        //查询制卡任务，订购单号如果为DG时，默认为未输入订购单号
        string applyOrderID = "";
        if (txtApplyOrderID.Text.Trim() != "DG")
            applyOrderID = txtApplyOrderID.Text.Trim();
        DataTable data = ResourceManageHelper.callQuery(context, "queryTask", applyOrderID,
                                                        txtStartDate.Text.Trim(), txtEndDate.Text.Trim());
        if (data.Rows.Count == 0)
        {
            ResourceManageHelper.resetData(gvResult, data);
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return new DataView(data);
    }

    /// <summary>
    /// 查询输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean queryValidation()
    {
        //校验需求单号
        if (!string.IsNullOrEmpty(txtApplyOrderID.Text.Trim()) && txtApplyOrderID.Text.Trim() != "DG")
        {
            if (Validation.strLen(txtApplyOrderID.Text.Trim()) != 18)
                context.AddError("A095470100：订购单号必须为18位", txtApplyOrderID);
            if (!Validation.isCharNum(txtApplyOrderID.Text.Trim()))
                context.AddError("A095470101：订购单必须为英数", txtApplyOrderID);
        }
        //校验日期
        ResourceManageHelper.checkDate(context, txtStartDate, txtEndDate, "A095470102", "A095470103", "A095470104");

        return !context.hasError();
    }

    /// <summary>
    /// 提交任务
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 没有选中任何行，则返回错误
        if (gvResult.SelectedIndex == -1)
        {
            context.AddError("没有选中任何行");
        }
        else
        {
            if (gvResult.SelectedRow.Cells[3].Text.Trim() != "1:审核通过")  //不为审核提供
            {
                context.AddError("此订单不是审核通过状态，不能提交任务");
            }
            else if (gvResult.SelectedRow.Cells[9].Text.Trim() != "&nbsp;")  //不为待处理状态
            {
                context.AddError("此订单已有任务状态，不能再提交任务");
            }
            else
            {
                StringBuilder sign = new StringBuilder(1024);
                if (FileUpload1.HasFile)
                {
                    //获取私钥文件内容
                    Stream stream = FileUpload1.FileContent;
                    StreamReader reader = new StreamReader(stream, Encoding.GetEncoding("gb2312"));
                    string privateKeyStr = reader.ReadToEnd();
                    reader.Close();
                    stream.Close();
                    string strSignPlain = gvResult.SelectedRow.Cells[2].Text + gvResult.SelectedRow.Cells[8].Text.Substring(0, 6) + gvResult.SelectedRow.Cells[8].Text.Substring(0, 14) + gvResult.SelectedRow.Cells[8].Text.Substring(15, 14);//数量+年份+批次号+金额+厂家+起始卡号+结束卡号
                    StringBuilder strSignature = new StringBuilder(1024);
                    RMEncryptionHelper.Sign(0, privateKeyStr.ToString(), strSignPlain, strSignature);//私钥签名
                    sign = strSignature;
                }
                else
                {
                    context.AddError("请导入私钥");
                    return;
                }
                context.SPOpen();
                context.AddField("P_CARDORDERID").Value = gvResult.SelectedRow.Cells[0].Text.ToString();
                context.AddField("P_Sign").Value = sign.ToString();//签名
                bool ok = context.ExecuteSP("SP_RM_TASKSUBMIT");
                if (ok)
                {
                    context.AddMessage("任务提交成功");
                    query();
                }
            }
        }
    }

    //作废任务
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        // 没有选中任何行，则返回错误
        if (gvResult.SelectedIndex == -1)
        {
            context.AddError("没有选中任何行");
        }
        else
        {
            if (gvResult.SelectedRow.Cells[9].Text.Trim() != "0:待处理") //不为待处理状态
            {
                context.AddError("此订单不为待处理状态，不可作废任务");
            }
            else
            {
                if (!privateValidation())
                    return;
                context.SPOpen();
                context.AddField("P_TASKID").Value = gvResult.SelectedRow.Cells[5].Text.ToString();
                context.AddField("P_CARDORDERID").Value = gvResult.SelectedRow.Cells[0].Text.ToString();
                bool ok = context.ExecuteSP("SP_RM_TASKCANCEL");
                if (ok)
                {
                    context.AddMessage("作废任务成功");
                    query();
                }
            }
        }
    }

    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    //私钥导入验证
    protected Boolean privateValidation()
    {
        bool flag = false;
        if (FileUpload1.HasFile)
        {
            //获取私钥内容
            Stream stream = FileUpload1.FileContent;
            StreamReader reader = new StreamReader(stream, Encoding.GetEncoding("gb2312"));
            string privateKeyStr = reader.ReadToEnd();
            reader.Close();
            stream.Close();

            //获取公钥文件路径  
            string str = System.Configuration.ConfigurationManager.AppSettings["publicKeyFile"];
            string publicKeyFile = Server.MapPath(str);
            //string publicKeyFile = Server.MapPath("../../Resources/publicKeytest.pub");
            //获取公钥内容
            StreamReader pu = new StreamReader(publicKeyFile.ToString());
            string publicKeyStr = pu.ReadToEnd();
            pu.Close();

            //产生随机数
            StringBuilder randomNumber = new StringBuilder(17);//注意分配空间为17位，因为随机数本身占16位，再加字符串结束符共17位
            RMEncryptionHelper.GenerateRandom(randomNumber);
            string strSignPlain = randomNumber.ToString();

            //数字签名与认证
            int ret = 0;
            StringBuilder strSignature = new StringBuilder(1024);
            RMEncryptionHelper.Sign(0, privateKeyStr.ToString(), strSignPlain, strSignature);//私钥签名
            ret = RMEncryptionHelper.Verify(0, publicKeyStr.ToString(), strSignPlain, strSignature.ToString());//公钥验证
            if (ret == 0)
            {
                flag = true;
            }
            else
            {
                context.AddError("私钥验证不通过");
            }
        }
        else
        {
            context.AddError("没有导入私钥文件");
        }
        return flag;
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            HiddenField hidPath = e.Row.Cells[14].FindControl("hidFilePath") as HiddenField;
            HiddenField hidState = e.Row.Cells[15].FindControl("hidTaskState") as HiddenField;
            string strStateVale = string.Empty;
            if (hidState.Value!="")
            {
                strStateVale = hidState.Value.Substring(0,1);
            }
            Button buttonDownloadFile = e.Row.Cells[14].FindControl("btnDownload") as Button;
            Button buttonDeleteFile = e.Row.Cells[15].FindControl("btnDelete") as Button;
            if (hidPath.Value == "" || strStateVale == "6" || strStateVale == "7") //制卡文件是否存在或者状态是否为已下载（已删除）
            {
                buttonDownloadFile.Visible = false;
                buttonDeleteFile.Visible = false;
            }
            else
            {
                buttonDownloadFile.Visible = true;
                buttonDeleteFile.Visible = true;
            }
        }
    }

    //下载制卡文件事件
    protected void btnDownload_Click(object sender, EventArgs e)
    {
        if (!privateValidation())
            return;
        Button btnDownload = sender as Button;
        int index = int.Parse(btnDownload.CommandArgument);//获取行号
        //记录下载制卡文件操作台帐
        context.SPOpen();
        context.AddField("P_TASKID").Value = getDataKeys("TASKID", index);
        bool ok = context.ExecuteSP("SP_RM_DOWNLOADFILELOG");//记录下载制卡文件操作台帐
        if (ok)
        {
            string downloadPath = getDataKeys("FILEPATH", index);//获取文件下载地址Server.MapPath("")
            string fileName = getDataKeys("SECTION", index) + ".txt";//制卡文件名称
            //面值XXX元起始卡号-终止卡号.txt
            string cardvalue = getDataKeys("VALUECODE", index).Split(':')[1];
            //File.Delete(downloadPath);//删除文件
            DownloadFile("面值"+cardvalue+fileName, downloadPath);
        }
        else
        {
            context.AddError("记录下载制卡文件操作台帐失败");
        }
    }

    //删除制卡文件事件
    protected void btnDelete_Click(object sender, EventArgs e)
    {
        if (!privateValidation())
            return;
        Button btnDelete = sender as Button;
        int index = int.Parse(btnDelete.CommandArgument);//获取行号

        context.SPOpen();
        context.AddField("P_TASKID").Value = getDataKeys("TASKID", index);
        bool success = context.ExecuteSP("SP_RM_MAKECARDSTATECHANGE");//修改任务状态为6：已下载

        if (success)
        {
            context.AddError("修改任务状态为已下载成功");
            query();
        }
        else
        {
            context.AddError("修改任务状态为已下载失败");
        }
    }

    public String getDataKeys(String keysname, int selectindex)
    {
        return gvResult.DataKeys[selectindex][keysname].ToString();
    }

    /// <summary>
    /// 从服务器下载文件至本地
    /// </summary>
    /// <param name="fileName">客户端保存文件名</param>
    /// <param name="filePath">服务器文件地址</param>
    /// <returns></returns>
    public void DownloadFile(string fileName, string filePath)
    {
        try
        {
            string url = "http:" + filePath.Replace("\\", "/");

            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            WebResponse response = request.GetResponse();
            Stream stream = response.GetResponseStream();

            StreamReader reader = new StreamReader(stream, Encoding.GetEncoding("UTF-8"));
            string ttt = reader.ReadToEnd();
            byte[] bytes = Encoding.UTF8.GetBytes(ttt);
            stream.Read(bytes, 0, bytes.Length);
            stream.Close();
            Response.ContentType = "application/octet-stream";
            //通知浏览器下载文件而不是打开  
            Response.AddHeader("Content-Disposition", "attachment;filename=" + HttpUtility.UrlEncode(fileName, System.Text.Encoding.UTF8));
            Response.BinaryWrite(bytes);
            Response.Flush();
            Response.End();

            //if (File.Exists(filePath))
            //{
            //    //以字符流的形式下载文件  
            //    FileStream fs = new FileStream(filePath, FileMode.Open);
            //    byte[] bytes = new byte[(int)fs.Length];
            //    fs.Read(bytes, 0, bytes.Length);
            //    fs.Close();
            //    Response.ContentType = "application/octet-stream";
            //    //通知浏览器下载文件而不是打开  
            //    Response.AddHeader("Content-Disposition", "attachment;filename=" + HttpUtility.UrlEncode(fileName, System.Text.Encoding.UTF8));
            //    Response.BinaryWrite(bytes);
            //    Response.Flush();
            //    Response.End();
            //}
            //else
            //{
            //    context.AddError("文件不存在");
            //}
        }
        catch (Exception ex)
        {
            context.AddError("下载文件失败" + ex);
        }
    }

    //重启失败任务
    protected void btnRestart_Click(object sender, EventArgs e)
    {
        // 没有选中任何行，则返回错误
        if (gvResult.SelectedIndex == -1)
        {
            context.AddError("没有选中任何行");
        }
        else
        {
            if (gvResult.SelectedRow.Cells[9].Text.Trim()!= "3:处理失败") //不为处理成功状态
            {
                context.AddError("此订单不为处理失败状态，不可重新启动任务");
            }
            else
            {
                if (!privateValidation())
                    return;

                context.SPOpen();
                context.AddField("P_TASKID").Value = gvResult.SelectedRow.Cells[5].Text.ToString();
                bool ok = context.ExecuteSP("SP_RM_TASKUPDATE");
                if (ok)
                {
                    context.AddMessage("重启任务成功");
                    query();
                }
                else
                {
                    context.AddMessage("重启任务失败");
                }
            }
        }
    }
}