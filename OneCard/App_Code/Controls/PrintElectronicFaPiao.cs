using System;
using System.ComponentModel;
using System.Security.Permissions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Drawing;

namespace Controls.Customer.Asp
{
    [
    AspNetHostingPermission(SecurityAction.Demand,
        Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand,
        Level = AspNetHostingPermissionLevel.Minimal),
    DefaultProperty("List"),
    ToolboxData("<{0}:PrintElectronicFaPiao runat=\"server\"> </{0}:PrintElectronicFaPiao>")
    ]
    public class PrintElectronicFaPiao : WebControl
    {
        public PrintElectronicFaPiao()
        {
            //
            // TODO: Add constructor logic here
            //
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
        public virtual String DateTime
        {
            get { return (String)ViewState["DateTime"]; }
            set { ViewState["DateTime"] = value; }
        }

        public virtual String DeptNo
        {
            get { return (String)ViewState["DeptNo"]; }
            set { ViewState["DeptNo"] = value; }
        }

        public virtual String StaffNo
        {
            get { return (String)ViewState["StaffNo"]; }
            set { ViewState["StaffNo"] = value; }
        }


        public virtual String CardNo
        {
            get { return (String)ViewState["CardNo"]; }
            set { ViewState["CardNo"] = value; }
        }

        public virtual String JinE
        {
            get { return (String)ViewState["JinE"]; }
            set { ViewState["JinE"] = value; }
        }

        public virtual String XiaoJi
        {
            get { return (String)ViewState["XiaoJi"]; }
            set { ViewState["XiaoJi"] = value; }
        }

        public virtual String ImageUrl
        {
            get { return (String)ViewState["ImageUrl"]; }
            set { ViewState["ImageUrl"] = value; }
        }

        public virtual String TradeType
        {
            get { return (String)ViewState["TradeType"]; }
            set { ViewState["TradeType"] = value; }
        }

        protected override void RenderContents(HtmlTextWriter writer)
        {



            writer.Write("<div id=\"" + PrintArea + "\" style=\"display:none\">");

            writer.Write("<div class=\"juedui\" style=\"left:70px;top:10px;font-size:17px\">");
            writer.Write("苏州市民卡有限公司");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:95px;top:30px;\">");
            writer.Write("电子发票提取码");
            writer.Write("</div>");




            writer.Write("<div class=\"juedui\" style=\"left:20px;top:60px;\">");
            writer.Write("日期时间:");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:100px;top:60px;\">");
            writer.Write(DateTime);
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:400px;top:50px;\">");
            writer.Write("-----------------------------------------");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:20px;top:80px;\">");
            writer.Write("网点编码:");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:100px;top:80px;\">");
            writer.Write(DeptNo);
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:440px;top:70px;\" align=\"center\" >");
            writer.Write("<img id=\"imgPrint\" runat=\"server\" width=\"130\" height=\"130\" src=\"" + ImageUrl + "\"/>");
            writer.Write("</div>");


            writer.Write("<div class=\"juedui\" style=\"left:20px;top:95px;\">");
            writer.Write("经办人编码:");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:100px;top:95px;\">");
            writer.Write(StaffNo);
            writer.Write("</div>");


            writer.Write("<div class=\"juedui\" style=\"left:20px;top:110px;\">");
            writer.Write(TradeType);
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:100px;top:110px;\">");
            writer.Write(CardNo);
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:20px;top:125px;\">");
            writer.Write("金额:");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:100px;top:125px;\">");
            writer.Write(JinE);
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:20px;top:140px;\">");
            writer.Write("合计:");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:100px;top:140px;\">");
            writer.Write(XiaoJi);
            writer.Write("</div>");



            writer.Write("<div class=\"juedui\" style=\"left:20px;top:170px;\">");
            writer.Write("电子发票提取码");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:20px;top:185px;\">");
            writer.Write("您可以使用微信或支付宝扫描右边二维码");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:20px;top:200px;\">");
            writer.Write("开具电子发票，二维码有效期30天;");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:400px;top:200px;\">");
            writer.Write("-----------------------------------------");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:20px;top:215px;\">");
            writer.Write("如您需要当日的电子发票请务必在当日扫描后开具。");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:430px;top:215px;\">");
            writer.Write("客户服务专线：962026");
            writer.Write("</div>");


            //writer.Write("<div class=\"juedui\" style=\"left:20px;top:245px;\">");
            //writer.Write("-----------------------------------------------------");
            //writer.Write("</div>");

            //writer.Write("<div class=\"juedui\" style=\"left:80px;top:260px;\" align=\"center\" >");
            //writer.Write("<img id=\"imgPrint\" runat=\"server\" width=\"150\" height=\"150\" src=\"" + ImageUrl + "\"/>");
            //writer.Write("</div>");

            //writer.Write("<div class=\"juedui\" style=\"left:20px;top:415px;\">");
            //writer.Write("-----------------------------------------------------");
            //writer.Write("</div>");

            //writer.Write("<div class=\"juedui2\" style=\"left:20px;top:430px;\">");
            //writer.Write("客户服务专线：962026");
            //writer.Write("</div>");


            writer.Write("</div>");
        }

    }
}