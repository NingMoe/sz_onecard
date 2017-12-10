using System;
using System.ComponentModel;
using System.Security.Permissions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Controls.Customer.Asp
{

     [
    AspNetHostingPermission(SecurityAction.Demand,
        Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand,
        Level = AspNetHostingPermissionLevel.Minimal),
    DefaultProperty("List"),
    ToolboxData("<{0}:PrintTLRMPingZheng runat=\"server\"> </{0}:PrintTLRMPingZheng>")
    ]
    /// <summary>
    /// Summary description for PrintTLRMPingZheng
    /// </summary>
    public class PrintTLRMPingZheng : WebControl
    {
        public PrintTLRMPingZheng()
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
         public virtual String Date
         {
             get { return (String)ViewState["Date"]; }
             set { ViewState["Date"] = value; }
         }


         public virtual String CardNo
         {
             get { return (String)ViewState["CardNo"]; }
             set { ViewState["CardNo"] = value; }
         }

         public virtual String AwardCardNo
         {
             get { return (String)ViewState["AwardCardNo"]; }
             set { ViewState["AwardCardNo"] = value; }
         }

         public virtual String StaffName
         {
             get { return (String)ViewState["StaffName"]; }
             set { ViewState["StaffName"] = value; }
         }

         public virtual String YeWuLeiXing
         {
             get { return (String)ViewState["YeWuLeiXing"]; }
             set { ViewState["YeWuLeiXing"] = value; }
         }

         public virtual String WangDian
         {
             get { return (String)ViewState["WangDian"]; }
             set { ViewState["WangDian"] = value; }
         }

         public virtual String LiuShuiHao
         {
             get { return (String)ViewState["LiuShuiHao"]; }
             set { ViewState["LiuShuiHao"] = value; }
         }

         public virtual String Money
         {
             get { return (String)ViewState["Money"]; }
             set { ViewState["Money"] = value; }
         }
         public virtual String Tax
         {
             get { return (String)ViewState["Tax"]; }
             set { ViewState["Tax"] = value; }
         }

         public virtual String JiangXiang
         {
             get { return (String)ViewState["JiangXiang"]; }
             set { ViewState["JiangXiang"] = value; }
         }

         public virtual String CustName
         {
             get { return (String)ViewState["CustName"]; }
             set { ViewState["CustName"] = value; }
         }

         public virtual String CustPaperType
         {
             get { return (String)ViewState["CustPaperType"]; }
             set { ViewState["CustPaperType"] = value; }
         }

         public virtual String CustPaperNo
         {
             get { return (String)ViewState["CustPaperNo"]; }
             set { ViewState["CustPaperNo"] = value; }
         }

         public virtual String CustPhone
         {
             get { return (String)ViewState["CustPhone"]; }
             set { ViewState["CustPhone"] = value; }
         }

      
        protected override void RenderContents(HtmlTextWriter writer)
        {

            writer.Write("<div id=\"" + PrintArea + "\" style=\"display:none;\">");
            writer.Write("<div class=\"juedui\" style=\"left:105px;top:10px;white-space: nowrap;\" >");
            writer.Write("<span style='font-size:30px'>苏州市民卡业务回单</span>");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:133px;top:50px;font-size:25px;\" >");
            writer.Write(Year+"年");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:218px;top:50px;font-size:25px;\" >");
            writer.Write(Month+"月");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:275px;top:50px;font-size:25px;\" >");
            writer.Write(Day+"日");
            writer.Write("</div>");


            writer.Write("<div class=\"juedui\" style=\"left:102px; top:105px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("业务类型:" + YeWuLeiXing);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:102px; top:145px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("中奖卡号:" + CardNo);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:102px; top:185px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("领奖卡号:" + AwardCardNo);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:102px; top:225px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("中奖奖项:" + JiangXiang);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:102px; top:265px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("中奖金额:" + Money);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:102px; top:305px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("扣税:" + Tax);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:102px; top:345px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("姓名:" + CustName);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:102px; top:385px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("证件类型:" + CustPaperType);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:102px; top:425px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("证件号码:" + CustPaperNo);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:102px; top:465px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("手机号码:" + CustPhone);
            writer.Write("</div>");
            writer.Write("</div>");

        }
    
    }
}