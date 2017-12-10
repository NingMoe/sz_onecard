using System;
using System.ComponentModel;
using System.Security.Permissions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;

namespace Controls.Customer.Asp
{
    [
    AspNetHostingPermission(SecurityAction.Demand,
        Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand,
        Level = AspNetHostingPermissionLevel.Minimal),
    DefaultProperty("List"),
    ToolboxData("<{0}:PrintShouJu runat=\"server\"> </{0}:PrintShouJu>")
    ]
    public class PrintShouJu : WebControl
    {
        public PrintShouJu()
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

        public virtual String CardNo
        {
            get { return (String)ViewState["CardNo"]; }
            set { ViewState["CardNo"] = value; }
        }

        public virtual String Price
        {
            get { return (String)ViewState["Price"]; }
            set { ViewState["Price"] = value; }
        }

        public virtual String StaffName
        {
            get { return (String)ViewState["StaffName"]; }
            set { ViewState["StaffName"] = value; }
        }

        protected override void RenderContents(HtmlTextWriter writer)
        {
                //左边的年月日
            writer.Write("<div id=\"" + PrintArea + "\" style=\"display:none\">");
                writer.Write("<div class=\"juedui\" style=\"left:120px;top:90px;\">");
                    writer.Write(Year);
                writer.Write("</div>");
                writer.Write("<div class=\"juedui\" style=\"left:170px; top:90px;\" >");
                    writer.Write(Month);
                writer.Write("</div>");
                writer.Write("<div class=\"juedui\" style=\"left:210px; top:90px;\" >");
                    writer.Write(Day);
                writer.Write("</div>");

                //右边的年月日
                writer.Write("<div class=\"juedui\" style=\"left:450px;top:75px;\" >");
                    writer.Write(Year);
                writer.Write("</div>");
                writer.Write("<div class=\"juedui\" style=\"left:530px; top:75px;\" >");
                    writer.Write(Month);
                writer.Write("</div>");
                writer.Write("<div class=\"juedui\" style=\"left:600px; top:75px;\" >");
                    writer.Write(Day);
                writer.Write("</div>");

                //左边的金额
                writer.Write("<div class=\"juedui\" style=\"left:170px;top:150px;\" >");
                    writer.Write(Price);
                writer.Write("</div>");
                //右边的金额
                writer.Write("<div class=\"juedui\" style=\"left:570px; top:140px;\" >");
                    writer.Write(Price);
                writer.Write("</div>");

                //左边经办人
                writer.Write("<div class=\"juedui\" style=\"left:165px;top:200px;\" >");
                    writer.Write(StaffName);
                writer.Write("</div>");
                //右边经办人
                writer.Write("<div class=\"juedui\" style=\"left:660px; top:185px;\" >");
                    writer.Write(StaffName);
                writer.Write("</div>");

                //左边卡号
                writer.Write("<div class=\"juedui\" style=\"left:150px;top:170px;\" >");
                    writer.Write(CardNo);
                writer.Write("</div>");
                //右边卡号
                writer.Write("<div class=\"juedui\" style=\"left:450px; top:155px;\" >");
                writer.Write(CardNo);
                writer.Write("</div>");
            writer.Write("</div>");

        }
    }
}
