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
    ToolboxData("<{0}:OpenFunc runat=\"server\"> </{0}:OpenFunc>")
    ]
    public class OpenFunc : WebControl
    {
        public OpenFunc()
        {
        }

        [
        Bindable(true),
        Category("Appearance"),
        DefaultValue(""),
        Localizable(true)
        ]
        public virtual ArrayList List
        {
            get
            {
                return (ArrayList)ViewState["List"];
            }
            set
            {
                ViewState["List"] = value;
            }
        }

        protected override void RenderContents(HtmlTextWriter writer)
        {
            if (List != null && List.Count > 0)
            {
                writer.Write("<ul class=\"ktgn\">");

                for (int index = 0; index < List.Count; index++)
                {
                    writer.Write("<li class=\"select\">");
                    writer.Write(List[index].ToString());
                    writer.Write("</li>");
                }

                writer.Write("</ul>");
            }
        }
    }
}
