/***************************************************************
 * DealString
 * 类名:字符串处理类
 * 变更日        姓名           摘要
 * ----------    -----------    --------------------------------
 * 2008/01/09    方剑           初次做成
 ***************************************************************
 */
using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.IO;
using System.Text;
using Common;

public class DealString
{
    public DealString()
    {
    }

    /************************************************************************
     * 加密字符串
     * @param String Str                 需要加密的字符串
     * @return 		                    加密后的字串
     ************************************************************************/
    public static string encrypPass(string pass)
    {
        return DecryptCard.GroupDecrypt(pass);
    }

    /************************************************************************
     * 将以“,”分割开的字符串，转换为list 
     * @param String Str                 “,”分割开的字符串
     * @return 		                     ArrayList
     ************************************************************************/
    static public ArrayList StrToList(String Str)
    {
        ArrayList list = new ArrayList();
        Str = Str.Trim();

        int start = 0;
        int end = 0;
        String subStr;
        int len;
        end = Str.IndexOf(",");

        while (end > 0)
        {
            subStr = Str.Substring(start, end - start);
            len = Str.Length;

            list.Add(subStr);

            Str = Str.Substring(end + 1);
            start = 0;
            end = Str.IndexOf(",");
        }

        if (Str != "")
            list.Add(Str);

        return list;
    }

    /************************************************************************
     * 将以“,”分割开的字符串，转换为list 
     * @param String Str                 “,”分割开的字符串
     * @return 		                     ArrayList
     ************************************************************************/
    static public String ListToWhereStr(ArrayList list)
    {
        String str = " ";
        for (int i = 0; i < list.Count; i++)
        {
            if (i == 0)
                str += " Where (" + list[i].ToString() + ")";
            else
            {
                str += " And (" + list[i].ToString() + ")";
            }

        }
        return str;
    }

    /************************************************************************
     * 从文件中读出【Key=Value】格式，存入HashTable中返回
     * @param StreamReader reader        文件
     * @return 		                     String
     ************************************************************************/
    static public String GetResourceValue(String ResourcePath, String FileName, String KeyName)
    {
        String strLine = null;
        int index = 0;
        String strKey;
        String strValue;
        StreamReader reader = new StreamReader(ResourcePath + FileName + ".txt", Encoding.GetEncoding("gb2312"));

        if (reader != null)
        {
            while ((strLine = reader.ReadLine()) != null)
            {
                strLine = strLine.Trim();
                if (strLine.Length <= 0)
                {
                    continue;
                }

                index = strLine.IndexOf("=");
                if (index > 0 && index < strLine.Length - 1)
                {
                    strKey = strLine.Substring(0, index);
                    strValue = strLine.Substring(index + 1, strLine.Length - index - 1);

                    if (KeyName == strKey)
                    {
                        reader.Close();
                        return strValue;
                    }
                }
                else
                    continue;
            }

            reader.Close();
        }

        return null;
    }

    /************************************************************************
    * 拼接输入字段生成记录流水号
    * @param       inTradeNo String 卡交易序列号
    * @param       inAsn     String  ASN
    * @return 	             String  记录流水号  
    ************************************************************************/
    static public String GetRecordID(String inTradeNo, String inAsn)
    {
        string nowTime = DateTime.Now.ToString("MMddHHmmss");
        return nowTime + inAsn.Substring(inAsn.Length - 8, 8);
    }

    /************************************************************************
    * 拼接输入字段生成记录流水号
    * @param   inPsam    String  PSAM编号
    * @param   inTac     String  TAC码
    * @param   tradeTime String  交易时间
    * @return 		                     String
    ************************************************************************/
    static public String GetRecordID(String tradeTime, String inPsam, String inTac)
    {
        tradeTime = tradeTime.Substring(2, 8) + "00";
        return tradeTime + inPsam + inTac;
    }
}
