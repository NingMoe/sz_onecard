using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Master;
using Common;
using PDO.UserCard;
/***************************************************************
 * 功能名: 资源管理退库
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/07/24    殷华荣			初次开发
 ****************************************************************/
public partial class ASP_ResourceManage_RM_StockReturn : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            hidCardType.Value = "usecard";
        }
        ResourceManageHelper.selectTab(this, this.GetType(), hidCardType);
    }

    private void ValidInput(string cardtype)
    {
        //对起始卡号和结束卡号进行校验
        if (cardtype == "usecard")
        {
            UserCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo);
        }
        else
        {
            // 检查起始卡号和终止卡号的格式（非空、14位、英数）
            long quantity = ChargeCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo);
        }
        //验证退库原因非空
        if (txtRemark.Text.Trim().Length < 1)
        {
            context.AddError("请输入退库原因", txtRemark);
        }
        else
        {
            if (txtRemark.Text.Trim().Length > 500)
            {
                context.AddError("退库原因不能超过1000个字符", txtRemark);
            }
        }
    }
    //提交
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        string printhtml = "";
        if (hidCardType.Value == "usecard")
        {
            ValidInput("usecard");
            if (context.hasError())
            {
                return;
            }
            //调用用户卡退库存储过程
            context.SPOpen();
            context.AddField("p_fromCardNo").Value = txtFromCardNo.Text.Trim();
            context.AddField("p_toCardNo").Value = txtToCardNo.Text.Trim();
            context.AddField("p_returnReason").Value = txtRemark.Text.Trim();
            context.AddField("p_seqNo", "String", "output", "16", null);
            bool ok = context.ExecuteSP("SP_RM_StockReturn_COMMIT");
            if (ok)
            {
                AddMessage("退库成功");
                String seqNo = "" + context.GetFieldValue("p_seqNo"); ViewState["seqNo"] = seqNo;
                string begincardno = txtFromCardNo.Text.Trim();
                string endcardno = txtToCardNo.Text.Trim();
                string reason = txtRemark.Text.Trim();
                //查询出卡面名称
                SP_UC_QueryPDO pdo = new SP_UC_QueryPDO();
                pdo.funcCode = "CardInfoQuery";
                pdo.var1 = txtFromCardNo.Text.Trim();
                pdo.var2 = txtFromCardNo.Text.Trim();
                StoreProScene storePro = new StoreProScene();
                DataTable data = storePro.Execute(context, pdo);
                string cardfacename = "";
                if (data != null && data.Rows.Count > 0)
                {
                    cardfacename = data.Rows[0]["CARDSURFACENAME"].ToString(); ViewState["cardsurfacename"] = cardfacename;
                }
                if (chkOrder.Checked)
                {
                    printhtml = RMPrintHelper.GetUserCardStockReturnPrintText(seqNo, begincardno, endcardno, cardfacename, reason,
                                                                              context.s_DepartName, context.s_UserName);
                }
            }
        }
        else
        {
            ValidInput("chargecard");
            //充值卡卡号验证
            bool b = ChargeCardHelper.hasSameFaceValue(context, txtFromCardNo, txtToCardNo);
            if (!b)
            {
                return;
            }
            //调用充值卡退库存储过程
            context.SPOpen();
            context.AddField("p_fromCardNo").Value = txtFromCardNo.Text.Trim();
            context.AddField("p_toCardNo").Value = txtToCardNo.Text.Trim();
            context.AddField("p_returnReason").Value = txtRemark.Text.Trim();
            context.AddField("p_seqNo", "String", "output", "16", null);
            bool ok = context.ExecuteSP("SP_RM_CC_StockReturn_Commit");
            if (ok)
            {
                AddMessage("退库成功");
                String seqNo = "" + context.GetFieldValue("p_seqNo"); ViewState["ccseqNo"] = seqNo;
                string begincardno = txtFromCardNo.Text.Trim();
                string endcardno = txtToCardNo.Text.Trim();
                string reason = txtRemark.Text.Trim();
                if (chkOrder.Checked)
                {
                    printhtml = RMPrintHelper.GetChargeCardStockReturnPrintText(seqNo, begincardno, endcardno, reason,
                                                                                context.s_DepartName, context.s_UserName);
                }
            }
        }
        if (printhtml.Trim().Length > 0)
        {
            printarea.InnerHtml = printhtml;
            //执行打印脚本
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
        }
    }

    protected void btnPrint_Click(object sender, EventArgs e)
    {
        string printhtml = "";
        //用户卡
        if (hidCardType.Value == "usecard")
        {
            if (ViewState["seqNo"] != null)
            {
                String seqNo = ViewState["seqNo"].ToString();
                string begincardno = txtFromCardNo.Text.Trim();
                string endcardno = txtToCardNo.Text.Trim();
                string reason = txtRemark.Text.Trim();
                string cardfacename = ViewState["cardsurfacename"].ToString();
                printhtml = RMPrintHelper.GetUserCardStockReturnPrintText(seqNo, begincardno, endcardno, cardfacename, reason,
                                                                          context.s_DepartName, context.s_UserName);
            }
            else
            {
                context.AddError("没有要打印的退库单"); return;
            }
        }
        else
        {
            if (ViewState["ccseqNo"] != null)
            {
                String seqNo = ViewState["ccseqNo"].ToString();
                string begincardno = txtFromCardNo.Text.Trim();
                string endcardno = txtToCardNo.Text.Trim();
                string reason = txtRemark.Text.Trim();
                printhtml = RMPrintHelper.GetChargeCardStockReturnPrintText(seqNo, begincardno, endcardno, reason,
                                                                            context.s_DepartName, context.s_UserName);
            }
            else
            {
                context.AddError("没有要打印的退库单"); return;
            }
        }
        printarea.InnerHtml = printhtml;
        //执行打印脚本
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
    }

}