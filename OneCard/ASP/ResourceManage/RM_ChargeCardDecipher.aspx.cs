using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Master;
using Common;
using System.Text;
using System.Runtime.InteropServices;
using System.Data;
using TM;
using System.IO;

public partial class ASP_ResourceManage_RM_ChargeCardDecipher : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //密码项为空,卡号不为空 则计算充值卡密码
        if (string.IsNullOrEmpty(TextBox1.Text)&&!string.IsNullOrEmpty(txtCardNo.Text))
        {
            inputValidationCardNo();
            privateValidation();
            if (context.hasError())
            {
                return;
            }
            string encryptPwd = string.Empty;
            string deciperPwd = string.Empty;

            //string queryCompanyno = @"Select a.PASSWD From TD_XFC_INITCARD a Where a.XFCARDNO = '" + txtCardNo.Text + "'";
            //context.DBOpen("Select");
            //DataTable data = context.ExecuteReader(queryCompanyno);
            DataTable data = ResourceManageHelper.callQuery(context, "queryCompanyNo", txtCardNo.Text);
            if (data.Rows.Count > 0)
            {
                encryptPwd = data.Rows[0][0].ToString();
                StringBuilder strPlain = new StringBuilder(1024);
                //string PwdIndex = System.Configuration.ConfigurationManager.AppSettings["PwdIndex"];
                //RMEncryptionHelper.DecodeString(Convert.ToInt32(PwdIndex), encryptPwd, strPlain);
                StringBuilder plain2 = new StringBuilder(16 + 1);//解密后密文16位

                int ret = -1;
                int ret2 = -1;
                string token;
                int epochSeconds;
                // 打开服务
                ret = RMEncryptionHelper.Open();
                if (ret != 0)
                {
                    context.AddError("打开服务失败！");
                    return;
                }
                else
                {
                    context.AddError("打开服务成功");
                }

                //计算令牌
                //RMEncryptionHelper.GetTokenString(out operCardNo, out token, out epochSeconds);


                // 获得TOKEN值


                string sql = "SELECT SYSDATE FROM DUAL";

                TMTableModule tm = new TMTableModule();
                DataTable dt = tm.selByPKDataTable(context, sql, 1);
                DateTime now = (DateTime)dt.Rows[0].ItemArray[0];
                TimeSpan epochTime = (now.ToUniversalTime() - new DateTime(1970, 1, 1));
                token = Token.createToken(context.s_CardID, (uint)epochTime.TotalSeconds);
                epochSeconds = (int)epochTime.TotalSeconds;
                //解密
                ret2 = RMEncryptionHelper.DecodeString(context.s_CardID, token, epochSeconds, 0, encryptPwd.ToString(), plain2);
                if (ret2 != 0)
                {
                    context.AddError("解密失败");
                    return;
                }
                else
                {
                    deciperPwd = plain2.ToString();

                }
                RMEncryptionHelper.Close();

                if (deciperPwd != "") //密码解密成功
                {
                    context.SPOpen();
                    context.AddField("P_STARTCARDNO").Value = txtCardNo.Text.Trim().ToString();//充值卡号

                    bool ok = context.ExecuteSP("SP_RM_CHARGECARDPWD");
                    if (ok)
                    {
                        TextBox1.Text = deciperPwd;
                        context.AddMessage("解密成功");
                    }
                    else
                    {
                        context.AddError("解密失败");
                    }
                }
                else
                {
                    context.AddError("解密失败");
                }
            }
            else
            {
                context.AddError("不存在此充值卡卡号", txtCardNo);
            }
        }
        //密码项不为空,卡号为空 则计算充值卡号
        if (!string.IsNullOrEmpty(TextBox1.Text)&&string.IsNullOrEmpty(txtCardNo.Text))
        {
            inputValidationPwd();
            privateValidation();
            if (context.hasError())
            {
                return;
            }

            //充值卡密码加密
            int ret = -1;
            int ret2 = -1;
            string token;
            int epochSeconds;
            string plain = TextBox1.Text.Trim();//明文
            StringBuilder cliper = new StringBuilder(512 + 1);//密文可以确定为512位

            string strCliper = "";  //加密后的密文
            // 打开服务
            ret = RMEncryptionHelper.Open();
            if (ret != 0)
            {
                context.AddError("打开服务失败！");
                return;
            }
            else
            {
                context.AddError("打开服务成功");
            }

            // 获得TOKEN值


            string sql = "SELECT SYSDATE FROM DUAL";

            TMTableModule tm = new TMTableModule();
            DataTable data = tm.selByPKDataTable(context, sql, 1);
            DateTime now = (DateTime)data.Rows[0].ItemArray[0];
            TimeSpan epochTime = (now.ToUniversalTime() - new DateTime(1970, 1, 1));
            token = Token.createToken(context.s_CardID, (uint)epochTime.TotalSeconds);
            epochSeconds = (int)epochTime.TotalSeconds;

            // 加密
            ret2 = RMEncryptionHelper.EncodeString(context.s_CardID, token, epochSeconds, 0, plain, cliper);
            if (ret2 != 0)
            {
                context.AddError("加密失败!");
                RMEncryptionHelper.Close();
                return;
            }
            else
            {
                strCliper = cliper.ToString();
            }
            RMEncryptionHelper.Close();

            DataTable dt = ResourceManageHelper.callQuery(context, "queryCardNo", strCliper);
            if (dt.Rows.Count > 0)
            {
                txtCardNo.Text = dt.Rows[0][0].ToString();
            }
            else
            {
                context.AddError("不存在此充值卡卡号", TextBox1);
            }
        }
    }

    /// <summary>
    /// Validation For CardNo
    /// </summary>
    protected void inputValidationCardNo()
    {
        if (!Validation.isCharNum(txtCardNo.Text.Trim()))
            context.AddError("充值卡卡号必须是英数", txtCardNo);
        if (Validation.strLen(txtCardNo.Text.Trim()) != 14)
            context.AddError("充值卡卡号长度必须为14位", txtCardNo);
    }

    /// <summary>
    /// Validation For Password
    /// </summary>
    protected void inputValidationPwd()
    {
        if (Validation.strLen(TextBox1.Text.Trim()) != 16)
            context.AddError("充值卡密码长度必须为16位", TextBox1);
    }

    //私钥导入验证
    protected void privateValidation()
    {
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
            if (ret != 0)
            {
                context.AddError("私钥验证不通过");
            }
        }
        else
        {
            context.AddError("没有导入私钥文件");
        }

    }
}