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
    ToolboxData("<{0}:PrintRMPingZheng runat=\"server\"> </{0}:PrintRMPingZheng>")
    ]
    /// <summary>
    /// Summary description for PrintRMPingZheng
    /// </summary>
    public class PrintRMPingZheng : WebControl
    {
        public PrintRMPingZheng()
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
            writer.Write("IC卡号:"+CardNo);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:102px; top:145px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("姓名:"+UserName);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:102px; top:185px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("交易类型:"+JiaoYiLeiXing);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:102px; top:225px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("机具号:"+JiJuHao);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:102px; top:265px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("交易金额:" + JiaoYiJinE);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:102px; top:305px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("IC卡余额:" + ICKaYuE);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:102px; top:345px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("手续费:" + ShouXuFei);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:102px; top:385px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("卡费:" + KaYaJin);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:102px; top:425px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("使用折旧费:" + ZheJiuFei);
            writer.Write("</div>");
            writer.Write("<div class=\"juedui\" style=\"left:102px; top:465px;white-space: nowrap;font-size:26px;\" >");
            writer.Write("总交易金额:" + ZongJinE);
            writer.Write("</div>");
            writer.Write("</div>");

        }
    }
}