using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Security.Cryptography;
using System.IO;

namespace ChargeCardDataProduce
{
	public class Validator
	{




        //Ĭ����Կ����
        private static byte[] Keys = { 0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF };
        /**/
        /**/
        /**/
        /// <summary>
        /// DES�����ַ���
        /// </summary>
        /// <param name="encryptString">�����ܵ��ַ���</param>
        /// <param name="encryptKey">������Կ,Ҫ��Ϊ8λ</param>
        /// <returns>���ܳɹ����ؼ��ܺ���ַ�����ʧ�ܷ���Դ��</returns>
        public static string EncryptDES(string encryptString, string encryptKey)
        {
            try
            {
                byte[] rgbKey = Encoding.UTF8.GetBytes(encryptKey.Substring(0, 8));
                byte[] rgbIV = Keys;
                byte[] inputByteArray = Encoding.UTF8.GetBytes(encryptString);
                DESCryptoServiceProvider dCSP = new DESCryptoServiceProvider();
                MemoryStream mStream = new MemoryStream();
                CryptoStream cStream = new CryptoStream(mStream, dCSP.CreateEncryptor(rgbKey, rgbIV), CryptoStreamMode.Write);
                cStream.Write(inputByteArray, 0, inputByteArray.Length);
                cStream.FlushFinalBlock();
                return Convert.ToBase64String(mStream.ToArray());
            }
            catch
            {
                return encryptString;
            }
        }

        /**/
        /**/
        /**/
        /// <summary>
        /// DES�����ַ���
        /// </summary>
        /// <param name="decryptString">�����ܵ��ַ���</param>
        /// <param name="decryptKey">������Կ,Ҫ��Ϊ8λ,�ͼ�����Կ��ͬ</param>
        /// <returns>���ܳɹ����ؽ��ܺ���ַ�����ʧ�ܷ�Դ��</returns>
        public static string DecryptDES(string decryptString, string decryptKey)
        {
            try
            {
                byte[] rgbKey = Encoding.UTF8.GetBytes(decryptKey);
                byte[] rgbIV = Keys;
                byte[] inputByteArray = Convert.FromBase64String(decryptString);
                DESCryptoServiceProvider DCSP = new DESCryptoServiceProvider();
                MemoryStream mStream = new MemoryStream();
                CryptoStream cStream = new CryptoStream(mStream, DCSP.CreateDecryptor(rgbKey, rgbIV), CryptoStreamMode.Write);
                cStream.Write(inputByteArray, 0, inputByteArray.Length);
                cStream.FlushFinalBlock();
                return Encoding.UTF8.GetString(mStream.ToArray());
            }
            catch
            {
                return decryptString;
            }
        }


        /************************************************************************
       * �����Ƿ��ǰ������
       * @param
       * @return
       ************************************************************************/
        public static Boolean isNum(String strInput)
        {
            System.Text.RegularExpressions.Regex reg1
                        = new System.Text.RegularExpressions.Regex(@"^[0-9]+$");
            return reg1.IsMatch(strInput);
        }

        // Encode the specified byte array by using CryptoAPITranform.
        public static String EncodeString(String sourceStr)
        {
            return evs(evs(evs(evs(evs(sourceStr)))));
        }

        public static string evs(string instr)
        {
            int iLen = instr.Length;

            int off = iLen % 94;
            StringBuilder outstr = new StringBuilder();
            int a;
            for (int i = 0; i < instr.Length; ++i)
            {
                a = (instr[i] - 33 + off + i % 94) % 94 + 33;
                outstr.Append((char)a);
            }

            return outstr.ToString();
        }
	}
}
