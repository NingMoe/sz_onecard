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
using System.Globalization;
using Master;
using System.Text.RegularExpressions;
using System.Net;

namespace Common
{
    public class Validation
    {
        private CmnContext context;
        public Validation(CmnContext contxt)
        {
            context = contxt;
        }

        public bool notEmpty(WebControl tb, String errCode)
        {
            string value = null;

            if (tb is TextBox )
            {
                TextBox txtBox = (TextBox)tb;
                txtBox.Text = txtBox.Text.Trim();
                value = txtBox.Text;
            }
            else if (tb is DropDownList)
            {
                value = ((DropDownList)tb).SelectedValue;
            }
            if (value != null && value.Length == 0)
            {
                context.AddError(errCode, tb);
                return false;
            }
            return true;
        }

        public bool maxLength(TextBox tb, int maxlen, String errCode)
        {
            tb.Text = tb.Text.Trim();
            if (strLen(tb.Text) > maxlen)
            {
                context.AddError(errCode, tb);
                return false;
            }
            return true;
        }

        public bool fixedLength(TextBox tb, int len, String errCode)
        {
            tb.Text = tb.Text.Trim();
            if (strLen(tb.Text) != len)
            {
                context.AddError(errCode, tb);
                return false;
            }
            return true;
        }

        public bool beAlpha(TextBox tb, String errCode)
        {
            tb.Text = tb.Text.Trim();
            if(!isCharNum(tb.Text))
            {
                context.AddError(errCode, tb);
                return false;
            }
            return true;
        }

        public long beNumber(TextBox tb, String errCode)
        {
            tb.Text = tb.Text.Trim();
            if (!isNum(tb.Text))
            {
                context.AddError(errCode, tb);
                return 0;
            }

            long ret = 0;
            try
            {
                ret = Convert.ToInt64(tb.Text);
            }
            catch (Exception)
            {
            }

            return ret;
        }

        public static int getPrice(TextBox tb)
        {
            return (int)(Double.Parse(tb.Text) * 100);
        }

        public static bool isPrice(string tb)
        {
            return Regex.IsMatch(tb, @"^\d{1,7}(\.\d{0,2})?$");
        }

        public static bool isPriceEx(string tb)
        {
            return Regex.IsMatch(tb, @"^\-?\d{1,7}(\.\d{0,2})?$");
        }

        public long bePrice(TextBox tb, String errCode)
        {
            tb.Text = tb.Text.Trim();
            bool ret = isPrice(tb.Text);
            if (!ret)
            {
                if (errCode != null)
                {
                    context.AddError(errCode, tb);
                }
                return 0;
            }
            return (long)(Double.Parse(tb.Text) * 100);
        }

        public long bePrice(string str, String errCode)
        {

            bool ret = isPrice(str);
            if (!ret)
            {
                if (errCode != null)
                {
                    context.AddError(errCode);
                }
                return 0;
            }
            return (long)(Double.Parse(str) * 100);
        }

        public DateTime? beDate(TextBox tb, String errCode)
        {
            tb.Text = tb.Text.Trim();
            if (!isDate(tb.Text, "yyyyMMdd"))
            {
                context.AddError(errCode, tb);
                return null;
            }

            return DateTime.ParseExact(tb.Text, "yyyyMMdd", null); ;
        }

        public DateTime? beMonth(TextBox tb, String errCode)
        {
            tb.Text = tb.Text.Trim();
            if (!isDate(tb.Text, "yyyyMM"))
            {
                context.AddError(errCode, tb);
                return null;
            }

            return DateTime.ParseExact(tb.Text, "yyyyMM", null); ;
        }

        public bool check(bool b, String errCode)
        {
            if (!b)
            {
                context.AddError(errCode);
                return false;
            }
            return true;
        }
        public bool check(bool b, String errCode,WebControl wb)
        {
            if (!b)
            {
                context.AddError(errCode, wb);
                return false;
            }
            return true;
        }

        public static bool isEmpty(TextBox tb)
        {
            tb.Text = tb.Text.Trim();
            return tb.Text.Length == 0;
        }

        /************************************************************************
         * 检验是否是半角数字
         * @param
         * @return
         ************************************************************************/
        public static Boolean isNum(String strInput)
        {
            System.Text.RegularExpressions.Regex reg1
                        = new System.Text.RegularExpressions.Regex(@"^[0-9]+$");
            return reg1.IsMatch(strInput);  
        }

        /************************************************************************
         * 检验是否是半角正实数（可有1-2位小数）
         * @param
         * @return
         ************************************************************************/
        public static Boolean isPosRealNum(String strInput)
        {
            System.Text.RegularExpressions.Regex reg1
                        = new System.Text.RegularExpressions.Regex(@"^[0-9]+(.[0-9]{1,2})?$");
            return reg1.IsMatch(strInput);
        }

        /************************************************************************
         * 检验是否是半角字符
         * @param
         * @return
         ************************************************************************/
        public static Boolean isChar(String strInput)
        {
            System.Text.RegularExpressions.Regex reg1
                        = new System.Text.RegularExpressions.Regex(@"^[A-Za-z]+$");
            return reg1.IsMatch(strInput);
        }

        /************************************************************************
         * 检验是否是半角英数字
         * @param
         * @return
         ************************************************************************/
        public static Boolean isCharNum(String strInput)
        {
            System.Text.RegularExpressions.Regex reg1
                        = new System.Text.RegularExpressions.Regex(@"^[A-Za-z0-9]+$");
            return reg1.IsMatch(strInput);
        }

        /************************************************************************
         * 检验是否是EMail
         * @param
         * @return
         ************************************************************************/
        public static System.Text.RegularExpressions.Regex reg1
            = new System.Text.RegularExpressions.Regex(
                 @"^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}" +
                 @"\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\" + 
                 @".)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$");

        public string isEMail(string txtEmail)
        {
            string ret= "";
            if (txtEmail.Length <= 0) return ret;

            if (strLen(txtEmail) > 30)
            {
                ret += "电子邮件地址过长(不能超过30位)\n";
                return ret;
            }
            

            bool retbool = reg1.IsMatch(txtEmail);
            if (!retbool)
            {
                ret += "电子邮件地址格式非法\n";
            }

            return ret;
        }

        public bool isEMail(TextBox txtEmail)
        {
            string strInput = txtEmail.Text.Trim();
            txtEmail.Text = strInput;
            if (strInput.Length <= 0) return true;

            if (strLen(strInput) > 30)
            {
                this.context.AddError("A003100043: 电子邮件地址过长(不能超过30位)", txtEmail);

                return false;
            }

            bool ret = reg1.IsMatch(strInput);
            if (!ret)
            {
                this.context.AddError("A003100028: 电子邮件地址格式非法", txtEmail);
            }

            return ret;
        }

        /************************************************************************
         * 检验是否是Date
         * @param
         * @return
         ************************************************************************/
        public static bool isDate(String strInput)
        {
            return isDate(strInput, "yyyy-MM-dd");
        }
        public static bool isTime(String strInput)
        {
            return isDate(strInput, "HHmmss");
        }

        public static bool isIPAddress(String strInput)
        {
            IPAddress ip;
            return IPAddress.TryParse(strInput, out ip);
        }

        public static bool isDate(String strInput, String fmt)
        {
            if (strInput == "")
                return false;

            try{
                DateTime.ParseExact(strInput, fmt, null);
            }
            catch
            {
                return false;
            }

            return true;
        }

        /************************************************************************
         * 得到字符串的半角长度
         * @param
         * @return
         ************************************************************************/
        public static int strLen(String strInput)
        {
            return Encoding.Default.GetBytes(strInput).Length;
        }
        //检验是否是18位身份证号码 add by youyue
        public static bool isPaperNo(string paperno)
        {
           
            return Regex.IsMatch(paperno, @"^[1-9]\d{5}(18|19|([23]\d))\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\d{3}[0-9Xx]$");
 
        }
        public static bool CheckIDCard(string Id)
        {
            if (Id.Length == 18)
            {
                bool check = CheckIDCard18(Id);
                return check;
            }
            else if (Id.Length == 15)
            {
                bool check = CheckIDCard15(Id);
                return check;
            }
            else
            {
                return false;
            }
        }
        private static bool CheckIDCard18(string Id)
        {
            long n = 0;
            if (long.TryParse(Id.Remove(17), out n) == false || n < Math.Pow(10, 16) || long.TryParse(Id.Replace('x', '0').Replace('X', '0'), out n) == false)
            {
                return false;//数字验证
            }
            string address = "11x22x35x44x53x12x23x36x45x54x13x31x37x46x61x14x32x41x50x62x15x33x42x51x63x21x34x43x52x64x65x71x81x82x91";
            if (address.IndexOf(Id.Remove(2)) == -1)
            {
                return false;//省份验证
            }
            string birth = Id.Substring(6, 8).Insert(6, "-").Insert(4, "-");
            DateTime time = new DateTime();
            if (DateTime.TryParse(birth, out time) == false)
            {
                return false;//生日验证
            }
            string[] arrVarifyCode = ("1,0,x,9,8,7,6,5,4,3,2").Split(',');
            string[] Wi = ("7,9,10,5,8,4,2,1,6,3,7,9,10,5,8,4,2").Split(',');
            char[] Ai = Id.Remove(17).ToCharArray();
            int sum = 0;
            for (int i = 0; i < 17; i++)
            {
                sum += int.Parse(Wi[i]) * int.Parse(Ai[i].ToString());
            }
            int y = -1;
            Math.DivRem(sum, 11, out y);
            if (arrVarifyCode[y] != Id.Substring(17, 1).ToLower())
            {
                return false;//校验码验证

            }
            return true;//符合GB11643-1999标准
        }

        private static bool CheckIDCard15(string Id)
        {
            long n = 0;
            if (long.TryParse(Id, out n) == false || n < Math.Pow(10, 14))
            {
                return false;//数字验证
            }
            string address = "11x22x35x44x53x12x23x36x45x54x13x31x37x46x61x14x32x41x50x62x15x33x42x51x63x21x34x43x52x64x65x71x81x82x91";
            if (address.IndexOf(Id.Remove(2)) == -1)
            {
                return false;//省份验证
            }
            string birth = Id.Substring(6, 6).Insert(4, "-").Insert(2, "-");
            DateTime time = new DateTime();
            if (DateTime.TryParse(birth, out time) == false)
            {
                return false;//生日验证
            }
            return true;//符合15位身份证标准
        }

    }
}
