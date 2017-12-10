using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Text;

/// <summary>
/// DecryptSting 的摘要说明
/// </summary>
/// 
namespace Common
{
    public class DecryptString
    {
        // Encode the specified byte array by using CryptoAPITranform.
        public static String EncodeString(String sourceStr)
        {
            return evs(evs(evs(evs(evs(sourceStr)))));
        }

        // Decode the specified byte array using CryptoAPITranform.
        public static String DecodeString(String sourceStr)
        {
            return dvs(dvs(dvs(dvs(dvs(sourceStr)))));
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

        public static string dvs(string instr)
        {
            int iLen = instr.Length;
            int off = iLen % 94;
            int iOff, iDiff;
            StringBuilder outstr = new StringBuilder();
            int a;
            for (int i = 0; i < iLen; ++i)
            {
                iOff = i % 94;
                iDiff = off + iOff - instr[i] + 33;
                if (iDiff > 0)
                {
                    a = instr[i] + (iDiff / 95 + 1) * 94 - off - iOff;
                }
                else
                {
                    a = instr[i] - off - iOff;
                }
                outstr.Append((char)a);
            }
            return outstr.ToString();
        }
	    
    }
}
