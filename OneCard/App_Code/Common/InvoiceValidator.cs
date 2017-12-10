using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Master;

namespace Common
{
    //发票号验证
    public class InvoiceValidator
    {
        private CmnContext context;

        public InvoiceValidator(CmnContext contxt)
        {
            context = contxt;
        }

        // 发票号校验
        // 非空、数字、长度
        public bool validateId(TextBox tb)
        {
            string invoiceNo = tb.Text.Trim();
            if (invoiceNo == "")
            {
                context.AddError("A200001020", tb);//发票号为空
                return false;
            }
            return validateIdAllowNull(context, tb);
        }

        // 发票号数字和长度校验
        // 可为空
        public bool validateIdAllowNull(CmnContext contxt, TextBox tb)
        {
            string invoiceNo = tb.Text.Trim();
            if (invoiceNo == "")
            {
                return true;
            }
            if (!Validation.isNum(invoiceNo))
            {
                context.AddError("A200001021", tb);//发票号非数字
                return false;
            }
            if (Validation.strLen(invoiceNo) != 8)
            {
                context.AddError("A200001022", tb);//发票号长度不等于8
                return false;
            }
            return true;
        }

        public bool validateIdRangeAllowNull(TextBox tbBeginInvoice, TextBox tbEndInvoice){
            bool b = true;

            string strBeginNo = tbBeginInvoice.Text.Trim();
            string strEndNo = tbEndInvoice.Text.Trim();

            //起始发票号

            if (strBeginNo != "")
            {
                if (!Validation.isNum(strBeginNo))
                {
                    context.AddError("A200001024", tbBeginInvoice);//起始发票号不是数字
                    b = false;
                }
                else if (Validation.strLen(strBeginNo) != 8)
                {
                    context.AddError("A200001025", tbBeginInvoice);//起始发票号长度不等于8位
                    b = false;
                }
            }

            //终止发票号

            if (strEndNo != "")
            {
                if (!Validation.isNum(strEndNo))
                {
                    context.AddError("A200001027", tbEndInvoice);//终止发票号不是数字
                    b = false;
                }
                else if (Validation.strLen(strEndNo) != 8)
                {
                    context.AddError("A200001028", tbEndInvoice);//终止发票号长度不等于8位
                    b = false;
                }
            }

            //终止发票号不小于起始发票号

            if (b && strBeginNo != "" && strEndNo != "")
            {
                long lBeginNo = long.Parse(strBeginNo);
                long lEndNo = long.Parse(strEndNo);
                if (lBeginNo > lEndNo)
                {
                    context.AddError("A200001029");
                    b = false;
                }
                else
                {
                    if (lEndNo - lBeginNo > 10000)
                    {
                        context.AddError("A200001030");
                        b = false;
                    }
                }
            }

            return b;
        }

        // 起始发票号和终止发票号验证
        // 非空
        public bool validateIdRange(TextBox tbBeginInvoice, TextBox tbEndInvoice)
        {
            bool b = true;

            string strBeginNo = tbBeginInvoice.Text.Trim();
            string strEndNo = tbEndInvoice.Text.Trim();

            //起始发票号

            if (strBeginNo == "")
            {
                context.AddError("A200001023", tbBeginInvoice);//起始发票号为空
                b = false;
            }
            else if (!Validation.isNum(strBeginNo))
            {
                context.AddError("A200001024", tbBeginInvoice);//起始发票号不是数字
                b = false;
            }
            else if (Validation.strLen(strBeginNo) != 8)
            {
                context.AddError("A200001025", tbBeginInvoice);//起始发票号长度不等于8位
                b = false;
            }

            //终止发票号

            if (strEndNo == "")
            {
                context.AddError("A200001026", tbEndInvoice);//终止发票号为空
                b = false;
            }
            else if (!Validation.isNum(strEndNo))
            {
                context.AddError("A200001027", tbEndInvoice);//终止发票号不是数字
                b = false;
            }
            else if (Validation.strLen(strEndNo) != 8)
            {
                context.AddError("A200001028", tbEndInvoice);//终止发票号长度不等于8位
                b = false;
            }

            //终止发票号不小于起始发票号

            if (b)
            {
                long lBeginNo = long.Parse(strBeginNo);
                long lEndNo = long.Parse(strEndNo);
                if (lBeginNo > lEndNo)
                {
                    context.AddError("A200001029");
                    b = false;
                }
                else
                {
                    if (lEndNo - lBeginNo + 1 > 10000)
                    {
                        context.AddError("A200001030");
                        b = false;
                    }
                }
            }

            return b;
        }

        /// <summary>
        /// 起始发票号和终止发票号验证 @add by liuhe 20110111
        /// </summary>
        /// <param name="tbBeginInvoice"></param>
        /// <param name="tbEndInvoice">终止发票号不在页面显示情况</param>
        /// <returns></returns>
        public bool validateIdRange(TextBox tbBeginInvoice, string strEndNo)
        {
            bool b = true;

            string strBeginNo = tbBeginInvoice.Text.Trim();

            //起始发票号


            if (strBeginNo == "")
            {
                context.AddError("A200001023", tbBeginInvoice);//起始发票号为空

                b = false;
            }
            else if (!Validation.isNum(strBeginNo))
            {
                context.AddError("A200001024", tbBeginInvoice);//起始发票号不是数字

                b = false;
            }
            else if (Validation.strLen(strBeginNo) != 8)
            {
                context.AddError("A200001025", tbBeginInvoice);//起始发票号长度不等于8位

                b = false;
            }


            //终止发票号不小于起始发票号


            if (b)
            {
                long lBeginNo = long.Parse(strBeginNo);
                long lEndNo = long.Parse(strEndNo);
                if (lBeginNo > lEndNo)
                {
                    context.AddError("A200001029");
                    b = false;
                }
                else
                {
                    if (lEndNo - lBeginNo + 1 > 100000)//一次入库数量不超过十万
                    {
                        context.AddError("A200001030");
                        b = false;
                    }
                }
            }

            return b;
        }

        public bool validateItems(WebControl[] wcProjs, WebControl[] wcFees)
        {
            int n = 0;//有效条数
            bool b = true;

            for (int i = 0; i < wcProjs.Length; i++)
            {
                string proj = getControlValue(wcProjs[i]);
                string fee = getControlValue(wcFees[i]);

                int cnt = getFilledCnt(proj, fee);

                if (cnt == 2)
                {
                    if (!Validation.isPrice(fee))
                    {
                        context.AddError("A200005050", wcFees[i]);//金额非数字
                        b = false;
                    }
                    else
                    {
                        double dFee = Double.Parse(fee);
                        if (dFee.CompareTo(0) == 0)
                        {
                            context.AddError("A200005051", wcFees[i]);//金额为0
                            b = false;
                        }
                        else
                        {
                            n++;
                        }
                    }
                }
                else if (cnt == 1)
                {
                    context.AddError("A200005052", wcFees[i]);//项目与金额须同时存在
                    b = false;
                }
            }

            if (!b)
                return false;

            if (n == 0)
            {
                context.AddError("A200005053");//没有有效的条目
                return false;
            }

            return true;
        }

        private int getFilledCnt(string proj, string fee)
        {
            int i = 0;
            if (proj != "")
                i++;
            if (fee != "")
                i++;
            return i;
        }

        private string getControlValue(WebControl wc)
        {
            if (wc is TextBox)
                return ((TextBox)wc).Text.Trim();
            else if (wc is DropDownList)
                return ((DropDownList)wc).SelectedValue;
            else
                throw new Exception("unsupported control");
        }

        public bool validateItems2(WebControl[] wcPrice, WebControl[] wcNum)
        {
            int n = 0;//有效条数
            bool b = true;

            for (int i = 0; i < wcPrice.Length; i++)
            {
                string price = getControlValue(wcPrice[i]);
                string num = getControlValue(wcNum[i]);

                int cnt = getFilledCnt(price, num);

                if (cnt == 2)
                {
                    if (!Validation.isNum(num))
                    {
                        context.AddError("A200006049:数量非正整数", wcNum[i]);//数量非正整数

                        b = false;
                    }
                    if (!Validation.isPrice(price))
                    {
                        context.AddError("A200005050", wcPrice[i]);//金额非数字

                        b = false;
                    }
                    else
                    {
                        double dFee = Double.Parse(price);
                        if (dFee.CompareTo(0) == 0)
                        {
                            context.AddError("A200006051:金额不可为0", wcPrice[i]);//金额为0
                            b = false;
                        }
                        else
                        {
                            n++;
                        }
                    }
                }
                else if (cnt == 1)
                {
                    context.AddError("A200006052:单价和数量必须同时存在", wcNum[i]);
                    b = false;
                }
            }

            if (!b)
                return false;

            return true;
        }

    }
}
