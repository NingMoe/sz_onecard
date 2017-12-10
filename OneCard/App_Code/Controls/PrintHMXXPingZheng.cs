using System;
using System.ComponentModel;
using System.Security.Permissions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;

/// <summary>
///PrintHMXXPingZheng 的摘要说明
/// </summary>
namespace Controls.Customer.Asp
{
    [
    AspNetHostingPermission(SecurityAction.Demand,
        Level = AspNetHostingPermissionLevel.Minimal),
    AspNetHostingPermission(SecurityAction.InheritanceDemand,
        Level = AspNetHostingPermissionLevel.Minimal),
    DefaultProperty("List"),
    ToolboxData("<{0}:PrintHMXXPingZheng runat=\"server\"> </{0}:PrintHMXXPingZheng>")
    ]
    public class PrintHMXXPingZheng : WebControl
    {
	    public PrintHMXXPingZheng()
	    {
		    //
		    //TODO: 在此处添加构造函数逻辑
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

        public virtual String FaShengJinE
        {
            get { return (String)ViewState["FaShengJinE"]; }
            set { ViewState["FaShengJinE"] = value; }
        }

        public virtual String ShouFei
        {
            get { return (String)ViewState["ShouFei"]; }
            set { ViewState["ShouFei"] = value; }
        }

        public virtual String YouXiaoQi
        {
            get { return (String)ViewState["YouXiaoQi"]; }
            set { ViewState["YouXiaoQi"] = value; }
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
            writer.Write("<div class=\"juedui\" style=\"left:215px; top:45px;\" >");
            writer.Write("网点:" + WangDian);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:340px; top:45px;\" >");
            writer.Write("操作员:" + StaffName);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:450px;top:45px;\" >");
            writer.Write("流水号:" + LiuShuiHao);
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:100px;top:60px;\" >");
            writer.Write("----------------------------------------------------------");
            writer.Write("----------------------------------------------------------");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:100px; top:75px;\" >");
            writer.Write("业务类型");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:250px; top:75px;\" >");
            writer.Write("卡号");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:380px; top:75px;\" >");
            writer.Write("发生金额");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:490px; top:75px;\" >");
            writer.Write("收费");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:550px; top:75px;\" >");
            writer.Write("有效期");
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:100px; top:95px;\" >");
            writer.Write(YeWuLeiXing);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:250px; top:95px;\" >");
            writer.Write(CardNo);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:380px; top:95px;\" >");
            writer.Write(FaShengJinE);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:490px; top:95px;\" >");
            writer.Write(ShouFei);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:550px; top:95px;\" >");
            writer.Write(YouXiaoQi);
            writer.Write("</div>");

            //writer.Write("<div class=\"juedui\" style=\"left:510px; top:140px;\" >");
            //writer.Write("客户签名: " + "<span style='width:70px;border-bottom:1px solid black'></span>");
            //writer.Write("</div>");

            writer.Write("</div>");

        }
    }
}