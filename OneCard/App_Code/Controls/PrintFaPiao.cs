using System;
using System.ComponentModel;
using System.Security.Permissions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Drawing;    //需要调用的命名空间
namespace Controls.Customer.Asp
{
    [
    AspNetHostingPermission(SecurityAction.Demand,
        Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand,
        Level = AspNetHostingPermissionLevel.Minimal),
    DefaultProperty("List"),
    ToolboxData("<{0}:PrintFaPiao runat=\"server\"> </{0}:PrintFaPiao>")
    ]
    public class PrintFaPiao : WebControl
    {
        public PrintFaPiao()
        {
        }

        [
        Bindable(true),
        Category("Appearance"),
        DefaultValue(""),
        Localizable(true)
        ]

        public virtual String PrintArea
        {
            get { return (String)ViewState["PrintArea"]; }
            set { ViewState["PrintArea"] = value; }
        }

        public virtual String Year
        {
            get { return (String)ViewState["Year"]; }
            set { ViewState["Year"] = value; }
        }

        public virtual String Month
        {
            get { return (String)ViewState["Month"]; }
            set { ViewState["Month"] = value; }
        }

        public virtual String Day
        {
            get { return (String)ViewState["Day"]; }
            set { ViewState["Day"] = value; }
        }

        public virtual String FuKuanFang
        {
            get { return (String)ViewState["FuKuanFang"]; }
            set { ViewState["FuKuanFang"] = value; }
        }

        public virtual String ShouKuanFang
        {
            get { return (String)ViewState["ShouKuanFang"]; }
            set { ViewState["ShouKuanFang"] = value; }
        }

        public virtual String NaShuiRen
        {
            get { return (String)ViewState["NaShuiRen"]; }
            set { ViewState["NaShuiRen"] = value; }
        }

        public virtual String PiaoHao
        {
            get { return (String)ViewState["PiaoHao"]; }
            set { ViewState["PiaoHao"] = value; }
        }

        public virtual String JinEChina
        {
            get { return (String)ViewState["JinEChina"]; }
            set { ViewState["JinEChina"] = value; }
        }

        public virtual String JinE
        {
            get { return (String)ViewState["JinE"]; }
            set { ViewState["JinE"] = value; }
        }

        public virtual String KaiPiaoRen
        {
            get { return (String)ViewState["KaiPiaoRen"]; }
            set { ViewState["KaiPiaoRen"] = value; }
        }

        public virtual ArrayList ProjectList
        {
            get { return (ArrayList)ViewState["ProjectList"]; }
            set { ViewState["ProjectList"] = value; }
        }

        public virtual ArrayList RemarkList
        {
            get { return (ArrayList)ViewState["RemarkList"]; }
            set { ViewState["RemarkList"] = value; }
        }

        public virtual String FuKuanFangCode
        {
            get { return (String)ViewState["FuKuanFangCode"]; }
            set { ViewState["FuKuanFangCode"] = value; }
        }

        public virtual String JuanHao
        {
            get { return (String)ViewState["JuanHao"]; }
            set { ViewState["JuanHao"] = value; }
        }

        public virtual String ValidateCode
        {
            get { return (String)ViewState["ValidateCode"]; }
            set { ViewState["ValidateCode"] = value; }
        }

        public virtual String Remark//存放被红冲的发票
        {
            get { return (String)ViewState["Remark"]; }
            set { ViewState["Remark"] = value; }
        }

        public virtual String BankName//开户银行
        {
            get { return (String)ViewState["BankName"]; }
            set { ViewState["BankName"] = value; }
        }

        public virtual String BankAccount//开户帐号
        {
            get { return (String)ViewState["BankAccount"]; }
            set { ViewState["BankAccount"] = value; }
        }
        public virtual String CallingName//行业名称
        {
            get { return (String)ViewState["CallingName"]; }
            set { ViewState["CallingName"] = value; }
        }

        protected override void RenderContents(HtmlTextWriter writer)
        {

           

            writer.Write("<div id=\"" + PrintArea + "\" style=\"display:none\">");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:80px;top:22px;\">");
            writer.Write("验证码：");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui_fapiao\" style=\"left:125px;top:15px;\" >");
            writer.Write("<img  src=\"../../barcode.aspx?validatecode="+ValidateCode+"\" />");
            writer.Write("</div>");


            writer.Write("<div class=\"juedui_fapiao\" style=\"left:170px;top:75px;\">");
            if (Year != null && Month != null && Day != null)
                writer.Write(Year + "-" + Month + "-" + Day);
            writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:390px;top:75px;\">");
            writer.Write(CallingName);
            writer.Write("</div>");

            //writer.Write("<div class=\"juedui_fapiao\" style=\"left:60px;top:90px;\">");
            //writer.Write("付款方：");
            //writer.Write("</div>");

            //writer.Write("<div class=\"juedui_fapiao\" style=\"left:128px;top:90px;\">");
            //writer.Write(FuKuanFang);
            //writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:120px;top:107px;\">");
            writer.Write("付款方名称：");
            writer.Write("</div>");


            writer.Write("<div class=\"juedui_fapiao\" style=\"left:185px;top:107px;\">");
            writer.Write(FuKuanFang);
            writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:120px;top:125px;\">");
            writer.Write("付款方纳税人识别号：");
            writer.Write("</div>");


            writer.Write("<div class=\"juedui_fapiao\" style=\"left:230px;top:125px;\">");
            writer.Write(FuKuanFangCode);
            writer.Write("</div>");


            //writer.Write("<div class=\"juedui_fapiao\" style=\"left:60px;top:125px;\">");
            //writer.Write("收款方代码：");
            //writer.Write("</div>");

            //writer.Write("<div class=\"juedui_fapiao\" style=\"left:165px;top:125px;\">");
            //writer.Write(NaShuiRen);
            //writer.Write("</div>");


            //writer.Write("<div class=\"juedui_fapiao\" style=\"left:60px;top:145px;\">");
            //writer.Write("纳税人识别码：");
            //writer.Write("</div>");

            //writer.Write("<div class=\"juedui_fapiao\" style=\"left:160px;top:145px;\">");
            //writer.Write(NaShuiRen);
            //writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:470px;top:110px;\">");
            writer.Write("机打发票代码：");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:570px;top:110px;\">");
            writer.Write(JuanHao);
            writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:470px;top:125px;\">");
            writer.Write("机打发票号码：");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:570px;top:125px;\">");
            writer.Write(PiaoHao);
            writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:510px;top:145px;\">");
            writer.Write("附注：");
            writer.Write("</div>");

            if (RemarkList != null)
            {
                for (int index = 0; index < RemarkList.Count && index < 5; index++)
                {
                    int top = 160 + 15 * index;
                    writer.Write("<div class=\"juedui_fapiao\" style=\"left:510px;top:" + top.ToString() + "px;\">");
                    writer.Write((String)RemarkList[index]);
                    writer.Write("</div>");
                }
            }

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:120px;top:145px;\">");
            writer.Write("开票项目");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:210px;top:145px;\">");
            writer.Write("单价");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:280px;top:145px;\">");
            writer.Write("数量");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:350px;top:145px;\">");
            writer.Write("折扣额");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:420px;top:145px;\">");
            writer.Write("金额(人民币)");
            writer.Write("</div>");
            if (ProjectList != null)
            {
                for (int index = 0; index < ProjectList.Count && index < 5; index++)
                {
                    int top = 160 + 15 * index;
                    String[] arrProject = (String[])ProjectList[index];
                    if (string.IsNullOrEmpty(arrProject[0])) continue;
                    writer.Write("<div class=\"juedui_fapiao\" style=\"left:120px;top:" + top.ToString() + "px;\">");//开票项目
                    writer.Write(arrProject[0]);
                    writer.Write("</div>");

                    writer.Write("<div class=\"juedui_fapiao\" style=\"left:210px;top:" + top.ToString() + "px;\">");//单价
                    writer.Write(arrProject[1].Replace("-",""));
                    writer.Write("</div>");

                    writer.Write("<div class=\"juedui_fapiao\" style=\"left:280px;top:" + top.ToString() + "px;\">");//数量
                    writer.Write(arrProject[2]);
                    writer.Write("</div>");

                    writer.Write("<div class=\"juedui_fapiao\" style=\"left:350px;top:" + top.ToString() + "px;\">");//折扣额
                    writer.Write("0");
                    writer.Write("</div>");

                    writer.Write("<div class=\"juedui_fapiao\" style=\"left:420px;top:" + top.ToString() + "px;\">");//金额(人民币)
                    writer.Write(arrProject[3]);
                    writer.Write("</div>");

                }
            }

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:120px;top:216px;\">");
            writer.Write("金额合计（大写）:人民币&nbsp;&nbsp;");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:270px;top:216px;\">");
            writer.Write(JinEChina);
            writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:470px;top:216px;\">");
            writer.Write("（小写）￥");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:545px;top:216px;\">");
            writer.Write(JinE);
            writer.Write("</div>");


            writer.Write("<div class=\"juedui_fapiao\" style=\"left:120px;top:230px;\">");
            writer.Write("币种:");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui_fapiao\" style=\"left:270px;top:230px;\">");
            writer.Write("汇率:");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui_fapiao\" style=\"left:370px;top:230px;\">");
            writer.Write("牌价日:");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui_fapiao\" style=\"left:445px;top:230px;\">");
            writer.Write("金额:");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui_fapiao\" style=\"left:120px;top:250px;\">");
            writer.Write("备注:");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui_fapiao\" style=\"left:145px;top:250px;\">");
            writer.Write(Remark);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui_fapiao\" style=\"left:430px;top:250px;\">");
            writer.Write("开户银行："+BankName);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui_fapiao\" style=\"left:430px;top:262px;\">");
            writer.Write("开户帐号："+BankAccount);
            writer.Write("</div>");


            writer.Write("<div class=\"juedui_fapiao\" style=\"left:120px;top:274px;\">");
            writer.Write("开票人：");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:155px;top:274px;\">");
            writer.Write(KaiPiaoRen);
            writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:430px;top:274px;\">");
            writer.Write("收款方名称：");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:490px;top:274px;\">");
            writer.Write(getLengthb(ShouKuanFang) > 28 ? getStrLenB(ShouKuanFang, 0, 28) : ShouKuanFang);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui_fapiao\" style=\"left:490px;top:289px;\">");
            writer.Write(getLengthb(ShouKuanFang) > 28 ? getStrLenB(ShouKuanFang, 28, getLengthb(ShouKuanFang) - 28) : "");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:430px;top:300px;\">");
            writer.Write("收款方纳税识别号：");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui_fapiao\" style=\"left:530px;top:300px;\">");
            writer.Write(NaShuiRen);
            writer.Write("</div>");


            writer.Write("</div>");
        }


        public bool IsChinese(char c)
        {
            return (int)c >= 0x4E00 && (int)c <= 0x9FA5;
        }
        //获得字节长度
        private int getLengthb(string str)
        {
            if (str==null||str == "")
            {
                return 0;
            }
            return System.Text.Encoding.Default.GetByteCount(str);
        }

        //c#的中英文混合字符串截取指定长度,startidx从0开始 by gisoracle@126.com
        public string getStrLenB(string str, int startidx, int len)
        {
            int Lengthb = getLengthb(str);
            if (startidx + 1 > Lengthb)
            {
                return "";
            }
            int j = 0;
            int l = 0;
            int strw = 0;//字符的宽度
            bool b = false;
            string rstr = "";
            for (int i = 0; i < str.Length; i++)
            {
                char c = str[i];
                if (j >= startidx)
                {
                    rstr = rstr + c;
                    b = true;
                }
                if (IsChinese(c))
                {
                    strw = 2;
                }
                else
                {
                    strw = 1;
                }
                j = j + strw;
                if (b)
                {
                    l = l + strw;
                    if ((l + 1) >= len) break;

                }


            }
            return rstr;



        }


    }
}
