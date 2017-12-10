using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;
using System.IO;
using System.Security.Cryptography;

namespace ChargeCardDataProduce
{
    public class RSAHelper
    {
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
        /// 生成公钥和私钥
        /// </summary>
        /// <param name="publicKeyFile"></param>
        /// <param name="privateKeyFile"></param>
        /// <param name="publicKey"></param>
        /// <param name="privateKey"></param>
        public static void GeneratePublicAndPrivateKey(string publicKeyFile, string privateKeyFile, out string publicKey, out string privateKey)
        {
            StringBuilder sb1 = new StringBuilder(publicKeyFile);
            StringBuilder sb2 = new StringBuilder(privateKeyFile);
            GenerateRsaKey(1, sb1, sb2);
            using (StreamReader sr = new StreamReader(sb1.ToString()))
            {
                publicKey = sr.ReadToEnd();
            }
            using (StreamReader sr = new StreamReader(sb2.ToString()))
            {
                privateKey = sr.ReadToEnd();
            }
        }
        /// <summary>
        /// 产生随机数
        /// </summary>
        /// <returns></returns>
        public static string RandomPwd()
        {
            StringBuilder number = new StringBuilder(17);//注意分配空间为17位，因为随机数本身占16位，再加字符串结束符共17位
            GenerateRandom(number);
            return number.ToString();
        }

        /// <summary>
        /// 签名认证
        /// </summary>
        /// <param name="content">需要验证的内容</param>
        /// <param name="signedString">签名</param>
        /// <param name="publicKey">公钥</param>
        /// <returns></returns>
        public static bool SignVerify(string content, string signedString, string publicKeyFile)
        {
            try
            {
                return Verify(1, publicKeyFile, content, signedString) == 0;
            }
            catch(Exception ex)
            {
                Log.Info(ex.Message, "AppLog");
                return false;
            }
        }

        /// <summary>
        /// 加密字符串
        /// </summary>
        /// <param name="str"></param>
        /// <param name="PublicPath"></param>
        /// <returns></returns>
        public static string RSAEncrypt(string str, string publicKeyFile)
        {
            StringBuilder strCliper = new StringBuilder(1024);//目前看到16位字符串加密后密文达到512位，没有做大规模测试，所以保险起见暂分配1024位
            Encrypt(1, publicKeyFile, str, strCliper);

            return strCliper.ToString();
        }

        /// <summary>
        /// 加密字符串(索引)
        /// </summary>
        /// <param name="type"></param>
        /// <param name="str"></param>
        /// <returns></returns>
        public static string RSAEncodeString(string type, string str)
        {
            StringBuilder strNewCliper = new StringBuilder(1024);//目前看到16位字符串加密后密文达到512位，没有做大规模测试，所以保险起见暂分配1024位
            EncodeString(Convert.ToInt32(type), str, strNewCliper);

            return strNewCliper.ToString();
        }


        /// <summary>
        /// 加密文件 --字符串
        /// </summary>
        /// <param name="publicKey">公钥</param>
        /// <param name="plainPath">明文文件路径</param>
        /// <param name="cliperPath">密文文件路径</param>
        public static void RSAEncryptFile(string publicKey, string plainPath, string cliperPath)
        {
            string[] paths = cliperPath.Split(';');

            foreach (string path in paths)
            {
                EncodeFile(0, publicKey, plainPath, path);
            }
        }

    }
}
