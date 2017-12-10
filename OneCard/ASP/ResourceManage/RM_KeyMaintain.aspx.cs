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

public partial class ASP_ResourceManage_RM_KeyMaintain : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化页面
            init_Page();
            //gvResult.DataKeyNames = new string[] { "ID", "PUBLICKEY", "PRIVATEKEY", "OPERATETIME", "PRODUCER" };
            gvResult.DataKeyNames = new string[] { "ID", "OPERATETIME", "PRODUCER", "PRIVATEKEY" };
            //((ScriptManager)ToolkitScriptManager1.FindControl("ScriptManager1")).RegisterPostBackControl(gvResult.FindControl("btnPublicDownload") );//Label1
        }
        int count = this.gvResult.Rows.Count;
        for (int i = 0; i < count; i++)
        {
            Button item1 = (Button)gvResult.Rows[i].FindControl("btnPrivateDownload");
            ScriptManager.GetCurrent(this.Page).RegisterPostBackControl(item1);

            //Button item2 = (Button)gvResult.Rows[i].FindControl("btnPublicDownload");
            //ScriptManager.GetCurrent(this.Page).RegisterPostBackControl(item2);
        }
    }
    /// <summary>
    /// 页面初始化
    /// </summary>
    protected void init_Page()
    {
       
        //从充值卡卡片厂商编码表（TP_XFC_CORP）读取数据，放入下拉列表
        string query = @"Select CORPNAME,CORPCODE  FROM TP_XFC_CORP order by CORPCODE ";

        context.DBOpen("Select");
        DataTable dataTable = context.ExecuteReader(query);
        if (dataTable.Rows.Count == 0)
        {
            return;
        }
        ddlProducer.Items.Add(new ListItem("---请选择---", ""));
        selProducer.Items.Add(new ListItem("---请选择---", ""));
        Object[] itemArray;
        ListItem li;
        for (int i = 0; i < dataTable.Rows.Count; ++i)
        {
            itemArray = dataTable.Rows[i].ItemArray;
            li = new ListItem("" + itemArray[1] + ":" + itemArray[0], (String)itemArray[1]);
            ddlProducer.Items.Add(li);
            selProducer.Items.Add(li);
        }
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!privateValidation())
            return;
        gvResult.DataSource = queryKey();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
        Label1.Text = "";
        selProducer.SelectedValue = "";
    }

    protected void query()
    {
        gvResult.DataSource = queryKey();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
        Label1.Text = "";
        selProducer.SelectedValue = "";
    }

    protected ICollection queryKey()
    {
        DataTable data = ResourceManageHelper.callQuery(context, "queryKey", ddlProducer.SelectedValue );
        if (data.Rows.Count == 0)
        {
            ResourceManageHelper.resetData(gvResult, data);
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return new DataView(data);
    }
    
    protected Boolean privateValidation()
    {
        bool flag = false;
        if (FileUpload1.HasFile)
        {
            //获取私钥内容
            Stream stream = FileUpload1.FileContent;
            StreamReader reader = new StreamReader(stream, Encoding.GetEncoding("gb2312"));
            string privateKeyStr = reader.ReadToEnd();

            //获取公钥文件路径  
            string str = System.Configuration.ConfigurationManager.AppSettings["publicKeyFile"];
            string publicKeyFile = Server.MapPath(str);
            //string publicKeyFile = Server.MapPath("../../Resources/publicKeytest.pub");
            //获取公钥内容
            StreamReader pu = new StreamReader(publicKeyFile.ToString());
            string publicKeyStr = pu.ReadToEnd();

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

    /// <summary>
    /// 生成公私钥对事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnCreate_Click(object sender, EventArgs e)
    {
        if (!privateValidation())
            return;
        StringBuilder publicKeyString = new StringBuilder(4096);
        StringBuilder privateKeyString = new StringBuilder(4096);
        RMEncryptionHelper.GenerateRsaKey(0, publicKeyString, privateKeyString);//产生公钥和私钥（字符串形式）
        context.SPOpen();
        context.AddField("P_PUBLICKEY").Value = publicKeyString.ToString();
        context.AddField("P_PRIVATEKEY").Value = privateKeyString.ToString();
        bool ok = context.ExecuteSP("SP_RM_CREATEKEY");
        if (ok)
        {
            context.AddMessage("生成公私钥对成功");
            query();
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

    protected void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        Label1.Text = getDataKeys("ID");
        if (getDataKeys("PRODUCER")!="")
        {
            selProducer.SelectedValue = getDataKeys("PRODUCER").Substring(0,1);
        }    
    }

    /// <summary>
    /// 获取关键字的值
    /// </summary>
    /// <param name="keysname"></param>
    /// <returns></returns>
    public String getDataKeys(String keysname)
    {
        return gvResult.DataKeys[gvResult.SelectedIndex][keysname].ToString();
    }

    public String getDataKeys(String keysname, int selectindex)
    {
        return gvResult.DataKeys[selectindex][keysname].ToString();
    }

    /// <summary>
    /// 下载私钥
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnPrivateDownload_Click(object sender, EventArgs e)
    {
        if (!privateValidation())
            return;
        Button btnDownload = sender as Button;
        int index = int.Parse(btnDownload.CommandArgument);//获取行号
        context.SPOpen();
        context.AddField("P_ID").Value = getDataKeys("ID", index);
        context.AddField("P_FUNCCODE").Value = "PRIVATE";
        bool ok = context.ExecuteSP("SP_RM_DOWNLOADKEYLOG");//记录下载私钥日志
        if (ok)
        {
            string privateKey = getDataKeys("PRIVATEKEY", index);//获取私钥
            string producer = getDataKeys("PRODUCER", index).Substring(0, 1);//获取厂家
            string fileName = producer + "_" + DateTime.Today.ToString("yyyyMMdd") + "_" + "privatekey" + ".txt";
            Response.Clear();
            Response.Buffer = false;
            Response.ContentType = "application/octet-stream";
            Response.AppendHeader("content-disposition", "attachment;filename=" + fileName + ";");
            Response.Write(privateKey.ToString());
            Response.Flush();
            Response.End();
        }
        else
        {
            context.AddError("记录下载私钥日志失败");
        }
    }

    /// <summary>
    /// 修改事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnModify_Click(object sender, EventArgs e)
    {
        // 没有选中任何行，则返回错误
        if (gvResult.SelectedIndex == -1)
        {
            context.AddError("没有选中任何行");
            return;
        }
        if (selProducer.SelectedValue=="")
        {
            context.AddError("请选择卡片厂商");
            return;
        }
        if (!privateValidation())
            return;
        context.SPOpen();
        context.AddField("P_ID").Value = Label1.Text.Trim().ToString();
        context.AddField("P_CORPCODE").Value = selProducer.SelectedValue;
        bool ok = context.ExecuteSP("SP_RM_MODIFYKEY");
        if (ok)
        {
            context.AddMessage("修改操作成功");
            query();
        }  
    }
}