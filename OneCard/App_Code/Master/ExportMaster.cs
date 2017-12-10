using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

/// <summary>
/// ExportMaster 的摘要说明
/// </summary>
/// 

namespace Master
{
    public class ExportMaster : FrontMaster
    {
        protected void ExportGridView(GridView gv)
        {
            foreach (GridViewRow gvr in gv.Rows)
            {
                foreach (TableCell tc in gvr.Cells)
                {
                    tc.Attributes.Add("style", "vnd.ms-excel.numberformat:@;");
                }
            }

            PrepareGridViewForExport(gv);

            Response.Clear();
            Response.Buffer = true;
            Response.Charset = "GB2312";
            Response.AppendHeader("Content-Disposition", "attachment;filename=export.xls");

            Response.ContentEncoding = System.Text.Encoding.GetEncoding("GB2312");
            Response.ContentType = "application/ms-excel";//设置输出文件类型为excel文件。 
            Response.Write("<meta http-equiv=Content-Type content=\"text/html; charset=GB2312\">");
            System.IO.StringWriter oStringWriter = new System.IO.StringWriter();
            System.Web.UI.HtmlTextWriter oHtmlTextWriter = new System.Web.UI.HtmlTextWriter(oStringWriter);
            gv.RenderControl(oHtmlTextWriter);
            Response.Output.Write(oStringWriter.ToString());
            Response.Flush();
            Response.End();
        }

        public override void VerifyRenderingInServerForm(Control control)
        {
        }

        protected void PrepareGridViewForExport(Control gv)
        {
            for (int i = 0; i < gv.Controls.Count; ++i )
            {
                Control ct = gv.Controls[i];
                if (ct is LinkButton)
                {
                    Literal l = new Literal();
                    l.Text = (ct as LinkButton).Text;
                    gv.Controls.Remove(ct);
                    gv.Controls.AddAt(i, l);
                }
                else if (ct is DropDownList)
                {
                    Literal l = new Literal();
                    l.Text = (ct as DropDownList).SelectedItem.Text;
                    gv.Controls.Remove(ct);
                    gv.Controls.AddAt(i, l);
                }
                else if (ct is CheckBox)
                {
                    Literal l = new Literal();
                    l.Text = (ct as CheckBox).Checked ? "True" : "False";
                    gv.Controls.Remove(ct);
                    gv.Controls.AddAt(i, l);
                }
                if (ct.HasControls())
                {
                    PrepareGridViewForExport(ct);
                }
            }
        }
    }
}
