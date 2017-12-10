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

/// <summary>
/// DecryptCard 的摘要说明
/// </summary>
namespace Common
{
    public class DecryptCard
    {
	    public DecryptCard()
	    {
        }

        public static String GroupDecrypt(String strSource)
        {
            return EncodeString(strSource, "group");
        }

        public static String ChargeDecrypt(String strSource)
        {
            return EncodeString(strSource, "szcic");
        }

        private static String EncodeString(String strSource, String strKey)
        {
            if (strKey.Trim().Equals(""))
                return strSource;

            int iKeyLen = strKey.Length;
            int iSourceLen = strSource.Length;
            int i, add = 0, add_tmp, source_tmp;
            byte bTmp = 0;
            String tmpStr = "";
            char[] arrTmp = null;
            String rtnStr = "";
            int isub = 0;
            char chTmp;

            for (int index = 0; index < iSourceLen; index++)
            {
                if (index < iKeyLen)
                {
                    i = index;
                }
                else
                {
                    i = (index + 1) / iKeyLen;
                    i = (index + 1) - i * iKeyLen;

                    if (i != 0)
                    {
                        i = index / iKeyLen;
                        i = index - i * iKeyLen;

                    }
                }

                tmpStr = strKey.Substring(i, 1);
                arrTmp = tmpStr.ToCharArray();
                bTmp = Convert.ToByte(arrTmp[0]);
                add = Convert.ToInt16(bTmp);
                add_tmp = add / 10;
                add = add - add_tmp * 10;

                tmpStr = strSource.Substring(index, 1);
                arrTmp = tmpStr.ToCharArray();
                bTmp = Convert.ToByte(arrTmp[0]);
                source_tmp = Convert.ToInt16(bTmp);

                isub = source_tmp - add;

                if ((isub) < 0)
                    rtnStr = rtnStr + source_tmp.ToString() + tmpStr;
                else
                {
                    bTmp = Convert.ToByte(isub);
                    chTmp = Convert.ToChar(bTmp);
                    rtnStr = rtnStr + "0" + chTmp;
                }

            }


            return rtnStr;
        }

    }
}

