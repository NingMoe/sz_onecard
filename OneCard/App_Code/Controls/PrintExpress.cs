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
    ToolboxData("<{0}:PrintExpress runat=\"server\"> </{0}:PrintExpress>")
    ]
    public class PrintExpress : WebControl
    {
        public PrintExpress()
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

        public virtual String SenderPhone
        {
            get { return (String)ViewState["SenderPhone"]; }
            set { ViewState["SenderPhone"] = value; }
        }

        public virtual String SenderCompany
        {
            get { return (String)ViewState["SenderCompany"]; }
            set { ViewState["SenderCompany"] = value; }
        }

        public virtual String SenderAddr
        {
            get { return (String)ViewState["SenderAddr"]; }
            set { ViewState["SenderAddr"] = value; }
        }

        public virtual String LabTag
        {
            get { return (String)ViewState["LabTag"]; }
            set { ViewState["LabTag"] = value; }
        }

        public virtual String CustName
        {
            get { return (String)ViewState["CustName"]; }
            set { ViewState["CustName"] = value; }
        }

        public virtual String CustPhone
        {
            get { return (String)ViewState["CustPhone"]; }
            set { ViewState["CustPhone"] = value; }
        }

        public virtual String CustAddr
        {
            get { return (String)ViewState["CustAddr"]; }
            set { ViewState["CustAddr"] = value; }
        }

        public virtual String CustTag
        {
            get { return (String)ViewState["CustTag"]; }
            set { ViewState["CustTag"] = value; }
        }
        public virtual String CustTagReserved
        {
            get { return (String)ViewState["CustTagReserved"]; }
            set { ViewState["CustTagReserved"] = value; }
        }

        protected override void RenderContents(HtmlTextWriter writer)
        {
            writer.Write("<div id=\"" + PrintArea + "\" style=\"display:none\">");

            //寄件人区
            writer.Write("<div class=\"juedui\" style=\"left:315px; top:100px;\" >");
            writer.Write(SenderPhone);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:165px; top:125px;\" >");
            writer.Write(SenderCompany);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:165px; top:150px;\" >");
            writer.Write(SenderAddr);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:165px; top:170px;\" >");
            writer.Write(LabTag);
            writer.Write("</div>");

            //收件人区
            writer.Write("<div class=\"juedui\" style=\"left:165px; top:210px;\" >");
            writer.Write(CustName);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:315px; top:210px;\" >");
            writer.Write(CustPhone);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:165px; top:260px;\" >");
            writer.Write(CustAddr);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:165px; top:305px;\" >");
            writer.Write(CustTag);
            writer.Write("</div>");

            writer.Write("</div>");
        }
    }
}
