using System;
using System.Data;
using System.Text;

namespace Common
{
    public class Token
    {
        public Token()
        {
            //
            // TODO: 在此处添加构造函数逻辑
            //
        }

        private static string encryptString(string instr, int iLen)
        {
            int off = iLen % 94;
            StringBuilder outstr = new StringBuilder();
            int a;
            for (int i = 0; i < instr.Length; ++i)
            {
                if (instr[i] > 126 || instr[i] < 33)
                    a = instr[i];
                else
                    a = (instr[i] - 33 + off + i % 94) % 94 + 33;

                outstr.Append((char)a);
            }

            return outstr.ToString();
        }

        private static uint hashString(string str)
        {
            uint h = 0;
            for (int i = 0; i < str.Length; i++)
            {
                h = h * 0xf4243 ^ str[i];
            }

            return h;
        }

        private static uint hashString(uint n)
        {
            return n * 2654435761U;
        }

        private static string strToHex(string Data)
        {
            //first take each charcter using substring.
            //then convert character into ascii.
            //then convert ascii value into Hex Format
            string sValue;
            string sHex = "";
            while (Data.Length > 0)
            {
                char tmp = Data[0];
                byte btmp = Convert.ToByte(tmp);
                sValue = Convert.ToString(btmp, 16).ToUpper();
                Data = Data.Substring(1, Data.Length - 1);
                sHex = sHex + sValue;
            }
            return sHex;
        }

        private static string strToFixedLength(string token, int fixedLength, char padding)
        {
            if (token.Length < fixedLength)
            {
                StringBuilder tmp2 = new StringBuilder();
                tmp2.Append(padding, (int)fixedLength - token.Length);

                return token + tmp2;
            }
            else
            {
                return token.Substring(0, fixedLength);
            }
        }

        public static string createToken(string operateCardNo, uint timestamp)
        {
            string token;
            string tmpbuf = timestamp.ToString();

            string in1 = operateCardNo + tmpbuf;
            uint times = (hashString(in1) ^ hashString(timestamp)) % 13 + 3;


            uint len = (uint)in1.Length + times;
            char tmp1 = (char)(times % 94 + 33);
            StringBuilder tmp2 = new StringBuilder();
            tmp2.Append(tmp1, (int)times);


            token = encryptString(in1 + tmp2, (int)len);
            while ((--times) > 0)
            {
                in1 = token;
                token = encryptString(in1, (int)len);
            }

            token = strToHex(token);

            return strToFixedLength(token, 40, 'X');

        }

    }
}
