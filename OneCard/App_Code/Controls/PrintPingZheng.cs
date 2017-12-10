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
    ToolboxData("<{0}:PrintPingZheng runat=\"server\"> </{0}:PrintPingZheng>")
    ]
    public class PrintPingZheng : WebControl
    {
        public PrintPingZheng()
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

        public virtual String StaffName
        {
            get { return (String)ViewState["StaffName"]; }
            set { ViewState["StaffName"] = value; }
        }

        public virtual String ZongJinEChina
        {
            get { return (String)ViewState["ZongJinEChina"]; }
            set { ViewState["ZongJinEChina"] = value; }
        }

        public virtual String ZongJinE
        {
            get { return (String)ViewState["ZongJinE"]; }
            set { ViewState["ZongJinE"] = value; }
        }

        public virtual String ZhangHao
        {
            get { return (String)ViewState["ZhangHao"]; }
            set { ViewState["ZhangHao"] = value; }
        }

        public virtual String JiaoYiFangShi
        {
            get { return (String)ViewState["JiaoYiFangShi"]; }
            set { ViewState["JiaoYiFangShi"] = value; }
        }

        public virtual String UserName
        {
            get { return (String)ViewState["UserName"]; }
            set { ViewState["UserName"] = value; }
        }

        public virtual String ZhengJianHaoMa
        {
            get { return (String)ViewState["ZhengJianHaoMa"]; }
            set { ViewState["ZhengJianHaoMa"] = value; }
        }

        public virtual String ZhengJianMingChen
        {
            get { return (String)ViewState["ZhengJianMingChen"]; }
            set { ViewState["ZhengJianMingChen"] = value; }
        }

        public virtual String JiaoYiLeiXing
        {
            get { return (String)ViewState["JiaoYiLeiXing"]; }
            set { ViewState["JiaoYiLeiXing"] = value; }
        }

        public virtual String JiJuHao
        {
            get { return (String)ViewState["JiJuHao"]; }
            set { ViewState["JiJuHao"] = value; }
        }

        public virtual String LiuShuiHao
        {
            get { return (String)ViewState["LiuShuiHao"]; }
            set { ViewState["LiuShuiHao"] = value; }
        }

        public virtual String JiaoYiJinE
        {
            get { return (String)ViewState["JiaoYiJinE"]; }
            set { ViewState["JiaoYiJinE"] = value; }
        }

        public virtual String ICKaYuE
        {
            get { return (String)ViewState["ICKaYuE"]; }
            set { ViewState["ICKaYuE"] = value; }
        }

        public virtual String ShouXuFei
        {
            get { return (String)ViewState["ShouXuFei"]; }
            set { ViewState["ShouXuFei"] = value; }
        }

        public virtual String KaYaJin
        {
            get { return (String)ViewState["KaYaJin"]; }
            set { ViewState["KaYaJin"] = value; }
        }

        public virtual String ZheJiuFei
        {
            get { return (String)ViewState["ZheJiuFei"]; }
            set { ViewState["ZheJiuFei"] = value; }
        }

        public virtual String Other
        {
            get { return (String)ViewState["Other"]; }
            set { ViewState["Other"] = value; }
        }

        public virtual String RailTimes
        {
            get { return (String)ViewState["RailTimes"]; }
            set { ViewState["RailTimes"] = value; }
        }

        protected override void RenderContents(HtmlTextWriter writer)
        {

            writer.Write("<div id=\"" + PrintArea + "\" style=\"display:none\">");
            writer.Write("<div class=\"juedui\" style=\"left:240px;top:25px;\" >");
            writer.Write(Year);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:285px; top:25px;\" >");
            writer.Write(Month);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:315px; top:25px;\" >");
            writer.Write(Day);
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:605px;top:20px;\" >");
            writer.Write(Year);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:655px;top:20px;\" >");
            writer.Write(Month);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:680px;top:20px;\" >");
            writer.Write(Day);
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:140px; top:55px;\" >");
            writer.Write(CardNo);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:140px; top:76px;\" >");
            writer.Write(UserName);
            //writer.Write(string.Empty);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:165px; top:97px;\" >");
            writer.Write(JiaoYiLeiXing);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:165px; top:119px;\" >");
            writer.Write(JiaoYiJinE);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:165px; top:140px;\" >");
            writer.Write(KaYaJin);
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:280px; top:55px;\" >");
            writer.Write(ZhangHao);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:280px; top:76px;\" >");
            //writer.Write(ZhengJianHaoMa);
            writer.Write(string.Empty);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:280px; top:97px;\" >");
            writer.Write(JiJuHao);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:280px; top:119px;\" >");
            writer.Write(ICKaYuE);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:324px; top:140px;\" >");
            writer.Write(ZheJiuFei);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:324px; top:190px;\" >");
            writer.Write(ZongJinEChina);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:200px; top:255px;\" >");
            writer.Write(StaffName);
            writer.Write("</div>");


            writer.Write("<div class=\"juedui\" style=\"left:440px; top:55px;\" >");
            writer.Write(JiaoYiFangShi);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:440px; top:76px;\" >");
            //writer.Write(ZhengJianMingChen);
            writer.Write(string.Empty);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:420px; top:97px;\" >");
            writer.Write(LiuShuiHao);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:440px; top:119px;\" >");
            writer.Write(ShouXuFei);
            writer.Write("</div>");
   
            writer.Write("<div class=\"juedui\" style=\"left:370px; top:140px;\" >");
            writer.Write("其他：");
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:440px; top:140px;\" >");
            writer.Write(Other);
            writer.Write("</div>");

            writer.Write("<div class=\"juedui\" style=\"left:635px; top:45px;\" >");
            writer.Write(CardNo);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:652px; top:67px;\" >");
            //writer.Write(UserName);
            writer.Write(string.Empty);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:652px; top:88px;\" >");
            writer.Write(JiaoYiLeiXing);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:652px; top:110px;\" >");
            writer.Write(JiJuHao);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:652px; top:131px;\" >");
            writer.Write(JiaoYiJinE);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:652px; top:153px;\" >");
            writer.Write(ICKaYuE);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:652px; top:175px;\" >");
            writer.Write(ShouXuFei);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:652px; top:196px;\" >");
            writer.Write(KaYaJin);
            writer.Write("</div>");
            if (!string.IsNullOrEmpty(RailTimes))
            {
                writer.Write("<div class=\"juedui\" style=\"left:592px; top:217px;\" >");
                writer.Write("轨交次数:" + RailTimes);
                writer.Write("</div>");
            }
            writer.Write("<div class=\"juedui\" style=\"left:690px; top:218px;\" >");
            writer.Write(ZheJiuFei);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:690px; top:239px;\" >");
            writer.Write(ZongJinE);
            writer.Write("</div>");

            
            writer.Write("</div>");

        }
    }
}
