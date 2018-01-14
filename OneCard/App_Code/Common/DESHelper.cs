using System;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Web;
using System.Text;
using System.IO; 

/// <summary>
/// Summary description for DESHelper
/// </summary>
public class DESHelper
{
	public DESHelper()
	{
		//
		// TODO: Add constructor logic here
		//
	}
    //private static string key = "IIQCKGRa"; // 正式的用:IIQCKGRa测试：feNAMWpm
    //// <summary> 
    /// DES加密 
    /// </summary> 
    /// <param name="encryptString"></param> 
    /// <returns></returns> 
    public static string DesEncrypt(string encryptString,string key) 
    { 

        byte[] keyBytes = ASCIIEncoding.ASCII.GetBytes(key.Substring(0, 8));
        byte[] keyIV = keyBytes; 
        //byte[] inputByteArray = Encoding.UTF8.GetBytes(encryptString); 
        byte[] inputByteArray = Encoding.Default.GetBytes(encryptString); 
        DESCryptoServiceProvider provider = new DESCryptoServiceProvider();
        provider.Mode = CipherMode.ECB;
        provider.Padding = PaddingMode.PKCS7;
        MemoryStream mStream = new MemoryStream(); 
        CryptoStream cStream = new CryptoStream(mStream, provider.CreateEncryptor(keyBytes, keyIV), CryptoStreamMode.Write); 
        cStream.Write(inputByteArray, 0, inputByteArray.Length); 
        cStream.FlushFinalBlock(); 
        return Convert.ToBase64String(mStream.ToArray()); 
    } 
    /// <summary>
    /// DES解密 
    /// </summary>
    /// <param name="decryptString"></param>
    /// <returns></returns>
    public static string DesDecrypt(string decryptString,string key) 
    {
        byte[] keyBytes = ASCIIEncoding.ASCII.GetBytes(key.Substring(0, 8)); 
        byte[] keyIV = keyBytes; 
        byte[] inputByteArray = Convert.FromBase64String(decryptString); 
        DESCryptoServiceProvider provider = new DESCryptoServiceProvider();
        provider.Mode = CipherMode.ECB;
        provider.Padding = PaddingMode.PKCS7;
        MemoryStream mStream = new MemoryStream(); 
        CryptoStream cStream = new CryptoStream(mStream, provider.CreateDecryptor(keyBytes, keyIV), CryptoStreamMode.Write); 
        cStream.Write(inputByteArray, 0, inputByteArray.Length); 
        cStream.FlushFinalBlock(); 
        return Encoding.UTF8.GetString(mStream.ToArray()); 
    } 
}