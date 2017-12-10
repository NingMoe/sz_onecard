using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;

public partial class ASP_ResourceManage_RM_ServiceSet : Master.Master
{
    /// <summary>
    /// 产生随机数
    /// </summary>
    /// <param name="number">返回的随机数</param>
    [DllImport("libEncryption.dll", EntryPoint = "GenerateRandom")]
    public static extern void GenerateRandom(StringBuilder number);

    /// <summary>
    /// 数字签名
    /// </summary>
    /// <param name="keyType">密钥类型(0字符串，1文件路径)</param>
    /// <param name="privateKey">私钥</param>
    /// <param name="plain">待数字签名的数据</param>
    /// <param name="signature">数字签名</param>
    [DllImport("libEncryption.dll", EntryPoint = "Sign")]
    public static extern void Sign(int keyType, string privateKey, string plain, StringBuilder signature);
    
    /// <summary>
    /// 签名认证
    /// </summary>
    /// <param name="keyType">密钥类型(0字符串，1文件路径)</param>
    /// <param name="publicKey">公钥</param>
    /// <param name="plain">待数字签名的数据</param>
    /// <param name="signature">数字签名</param>
    /// <returns>认证是否通过0：通过 -1:不过</returns>
    [DllImport("libEncryption.dll", EntryPoint = "Verify")]
    public static extern int Verify(int keyType, string publicKey, string plain, string signature);

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            init_Page();
        }
    }

    protected void init_Page()
    {
       
        DataTable dt = SPHelper.callQuery("SP_CC_Query", context, "ServiceSet");

        string taskDesc = dt.Rows[0]["TASKDESC"].ToString();
        if (taskDesc != "")
        {
            lblServiceStatus.Text = taskDesc.Trim();
        }
        else
        {
            lblServiceStatus.Text = "当前没有正在执行的任务";
        }

        txtRecycleTime.Text = dt.Rows[0]["RECYCELTIME"].ToString();
        if (dt.Rows[0]["ISSTART"].ToString ()== "1")
        {
            cbStart.Checked = true;
        }
    }

    protected void btnServiceRefresh_Click(object sender, EventArgs e)
    {
        DataTable dt = SPHelper.callQuery("SP_CC_Query", context, "ServiceSet");
        string taskDesc = dt.Rows[0]["TASKDESC"].ToString();
        if (taskDesc != "")
        {
            lblServiceStatus.Text = taskDesc.Trim();
        }
        else
        {
            lblServiceStatus.Text = "当前没有正在执行的任务";
        }
    }

    //修改
    protected void btnServiceModify_Click(object sender, EventArgs e)
    {
        if (!submitValidation())
            return;
        if (!privateValidation())
            return;

        context.SPOpen();
        context.AddField("P_RECYCELTIME").Value = Convert.ToInt32(txtRecycleTime.Text.Trim());
        if (cbStart.Checked == true)
        {
            context.AddField("P_ISSTART").Value = "1";
        }
        else
        {
            context.AddField("P_ISSTART").Value = "0";
        }
        bool ok = context.ExecuteSP("SP_CC_SETSERVICE");
        if (ok)
        {
            AddMessage("修改成功");
            init_Page();
        }
        else
        {
            AddMessage("修改失败");
        }
    }

    protected Boolean submitValidation()
    {
        //轮询时间
        if (string.IsNullOrEmpty(txtRecycleTime.Text.Trim()))
            context.AddError("轮询时间不能为空", txtRecycleTime);
        else if (!Validation.isNum(txtRecycleTime.Text.Trim()))
            context.AddError("轮询时间必须是数字", txtRecycleTime);

        return !context.hasError();
    }

    //私钥导入验证
    protected Boolean privateValidation()
    {
        bool flag=false;
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
            GenerateRandom(randomNumber);
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
}