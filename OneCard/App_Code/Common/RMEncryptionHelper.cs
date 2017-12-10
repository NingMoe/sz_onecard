using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Runtime.InteropServices;
using System.Text;
using System.IO;
/// <summary>
/// Summary description for RMEncryptionHelper
/// </summary>
public class RMEncryptionHelper
{
    public RMEncryptionHelper()
    {
        //
        // TODO: Add constructor logic here
        //

    }
    /// <summary>
    /// 产生公钥和私钥文件
    /// </summary>
    /// <param name="keyType">密钥类型(0字符串，1文件路径)</param>
    /// <param name="publicKey">公钥</param>
    /// <param name="privateKey">私钥</param>
    [DllImport("libEncryption.dll", EntryPoint = "GenerateRsaKey")]
    public static extern void GenerateRsaKey(int keyType, StringBuilder publicKey, StringBuilder privateKey);

    /// <summary>
    /// 加密字符串
    /// </summary>
    /// <param name="keyType">密钥类型(0字符串，1文件路径)</param>
    /// <param name="publicKey">公钥</param>
    /// <param name="plain">明文字符串</param>
    /// <param name="cliper">密文字符串</param>
    [DllImport("libEncryption.dll", EntryPoint = "Encrypt")]
    public static extern void Encrypt(int keyType, string publicKey, string plain, StringBuilder cliper);

    /// <summary>
    /// 解密字符串
    /// </summary>
    /// <param name="keyType">密钥类型(0字符串，1文件路径)</param>
    /// <param name="privateKey">私钥</param>
    /// <param name="cliper">密文字符串</param>
    /// <param name="plain">明文字符串</param>
    [DllImport("libEncryption.dll", EntryPoint = "Decrypt")]
    public static extern void Decrypt(int keyType, string privateKeyString, string cliper, StringBuilder plain);

    /// <summary>
    /// 加密文件
    /// </summary>
    /// <param name="keyType">密钥类型(0字符串，1文件路径)</param>
    /// <param name="publicKey">公钥</param>
    /// <param name="plainPath">明文文件路径</param>
    /// <param name="cliperPath">密文文件路径</param>
    [DllImport("libEncryption.dll", EntryPoint = "EncodeFile")]
    public static extern void EncodeFile(int keyType, string publicKey, string plainPath, string cliperPath);

    /// <summary>
    /// 解密文件
    /// </summary>
    /// <param name="keyType">密钥类型(0字符串，1文件路径)</param>
    /// <param name="privateKey">私钥</param>
    /// <param name="cliperPath">密文文件路径</param>
    /// <param name="plainPath">明文文件路径</param>
    [DllImport("libEncryption.dll", EntryPoint = "DecodeFile")]
    public static extern void DecodeFile(int keyType, string privateKey, string cliperPath, string plainPath);

    /// <summary>
    /// 加密字符串函数
    /// </summary>
    /// <param name="type">密钥索引</param>
    /// <param name="plain">明文</param>
    /// <param name="cliper">密文</param>
    [DllImport("libEncryption.dll", EntryPoint = "EncodeString")]
    public static extern void EncodeString(int type, string plain, StringBuilder cliper);

    /// <summary>
    /// 解密字符串函数
    /// </summary>
    /// <param name="type">密钥索引</param>
    /// <param name="cliper">密文</param>
    /// <param name="plain">明文</param>
    [DllImport("libEncryption.dll", EntryPoint = "DecodeString")]
    public static extern void DecodeString(int type, string cliper, StringBuilder plain);

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


    /// <summary>
    /// 打开
    /// </summary>
    /// <returns>0：成功 其他：失败</returns>
    [DllImport("libSecAccess.dll", EntryPoint = "Open")]
    public extern static int Open();

    /// <summary>
    /// 关闭
    /// </summary>
    /// <returns>0：成功 其他：失败</returns>
    [DllImport("libSecAccess.dll", EntryPoint = "Close")]
    public extern static int Close();

    /// <summary>
    /// 加密
    /// </summary>
    /// <param name="operCardNo">操作员号</param>
    /// <param name="token">令牌</param>
    /// <param name="epochTime">从1970至现在间隔的秒数</param>
    /// <param name="type">密钥类型</param>
    /// <param name="plain">明文</param>
    /// <param name="cliper">密文</param>
    /// <returns>0：成功 其他：失败</returns>
    [DllImport("libSecAccess.dll", EntryPoint = "EncodeString")]
    public extern static int EncodeString(string operCardNo, string token, int epochTime,
    int type, string plain, StringBuilder cliper);

    /// <summary>
    /// 解密
    /// </summary>
    /// <param name="operCardNo">操作员号</param>
    /// <param name="token">令牌</param>
    /// <param name="epochTime">从1970至现在间隔的秒数</param>
    /// <param name="type">密钥类型</param>
    /// <param name="cliper">密文</param>
    /// <param name="plain">明文</param>
    /// <returns>0：成功 其他：失败</returns>
    [DllImport("libSecAccess.dll", EntryPoint = "DecodeString")]
    public extern static int DecodeString(string operCardNo, string token, int epochTime,
    int type, string cliper, StringBuilder plain);
    /// <summary>
    /// 计算令牌
    /// </summary>
    /// <returns></returns>
    public static void GetTokenString(out string operCardNo, out string token, out int epochSeconds)
    {
        operCardNo = "2150010112345678";
        DateTime now = DateTime.Now;
        TimeSpan epochTime = (now.ToUniversalTime() - new DateTime(1970, 1, 1));
        epochSeconds = (int)epochTime.TotalSeconds;
        token = Common.Token.createToken(operCardNo, (uint)epochSeconds);
    }

}