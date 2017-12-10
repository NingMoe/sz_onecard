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
   ToolboxData("<{0}:PrintTLPingZheng runat=\"server\"> </{0}:PrintTLPingZheng>")
   ]
    /// <summary>
    /// Summary description for PrintRMPingZheng
    /// </summary>
    public class PrintTLPingZheng : WebControl
    {
        public PrintTLPingZheng()
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

            writer.Write("<div id=\"" + PrintArea + "\" style=\"display:none\">");
            writer.Write("<div class=\"juedui\" style=\"left:260px;top:10px;\" >");
            writer.Write("<span style='font-size:20px'>苏州市民卡业务回单</span>");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:100px;top:45px;\" >");
            writer.Write("日期:" + Date);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:290px; top:45px;\" >");
            writer.Write("网点:" + WangDian);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:460px; top:45px;\" >");
            writer.Write("操作员:" + StaffName);
            writer.Write("</div>");
            

            writer.Write("<div class=\"juedui\" style=\"left:100px;top:60px;\" >");
            writer.Write("---------------------------------------------------------");
            writer.Write("---------------------------------------------------------");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:100px; top:75px;\" >");
            writer.Write("业务类型");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:210px; top:75px;\" >");
            writer.Write("中奖卡号");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:330px; top:75px;\" >");
            writer.Write("领奖卡号");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:450px; top:75px;\" >");
            writer.Write("中奖奖项");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:560px; top:75px;\" >");
            writer.Write("中奖金额");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:100px; top:95px;\" >");
            writer.Write(YeWuLeiXing);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:210px; top:95px;\" >");
            writer.Write(CardNo);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:330px; top:95px;\" >");
            writer.Write(AwardCardNo);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:450px; top:95px;\" >");
            writer.Write(JiangXiang);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:560px; top:95px;\" >");
            writer.Write(Money);
            writer.Write("</div>");


            writer.Write("<div class=\"juedui\" style=\"left:100px; top:120px;\" >");
            writer.Write("扣税");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:210px; top:120px;\" >");
            writer.Write("姓名");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:330px; top:120px;\" >");
            writer.Write("证件类型");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:450px; top:120px;\" >");
            writer.Write("证件号码");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:560px; top:120px;\" >");
            writer.Write("手机号码");
            writer.Write("</div>");


            writer.Write("<div class=\"juedui\" style=\"left:100px; top:140px;\" >");
            writer.Write(Tax);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:210px; top:140px;\" >");
            writer.Write(CustName);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:330px; top:140px;\" >");
            writer.Write(CustPaperType);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:450px; top:140px;\" >");
            writer.Write(CustPaperNo);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:560px; top:140px;\" >");
            writer.Write(CustPhone);
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:500px; top:220px;\" >");
            writer.Write("客户签名: " + "<span style='width:70px;border-bottom:1px solid black'></span>");
            writer.Write("</div>");

            writer.Write("</div>");

        }
    }
}