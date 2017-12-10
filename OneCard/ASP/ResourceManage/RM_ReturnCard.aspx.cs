//---------------------------------------------------------------- 
//Copyright (C) 2012-2013 linkage Software 
// All rights reserved.
//<author>jiangbb</author>
//<createDate>2012-07-27</createDate>
//<description>退货</description>
//---------------------------------------------------------------- 
using System;
using System.Web.UI;
using Common;
using PDO.UserCard;
using Master;
using System.Data;


public partial class ASP_ResourceManage_RM_ReturnCard : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            hidCardType.Value = "usecard";
        }
        ResourceManageHelper.selectTab(this, this.GetType(), hidCardType);
        if (hidCardType.Value == "usecard")
        {
            txtFromCardNo.MaxLength = txtToCardNo.MaxLength = 16;
        }
        else
        {
            txtFromCardNo.MaxLength = txtToCardNo.MaxLength = 14;
        }
    }
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        //校验
        if (!supplyValidation())
            return;
        context.SPOpen();
        context.AddField("P_BEGINCARDNO").Value = txtFromCardNo.Text.Trim();
        context.AddField("P_ENDCARDNO").Value = txtToCardNo.Text.Trim();
        context.AddField("p_returnmsg").Value = txtRemark.Text.Trim();
        context.AddField("P_SIGNTYPE").Value = hidCardType.Value == "usecard" ? 0 : 1;
        context.AddField("p_seqNo", "String", "output", "16", null);
        bool ok = context.ExecuteSP("SP_RM_RETURNCARD");
        if (ok)
        {
            String seqNo = "" + context.GetFieldValue("p_seqNo"); ViewState["seqNo"] = seqNo;
            AddMessage("退货成功");
            string printhtml = "";
            //查询出卡片厂商
            SP_UC_QueryPDO pdo = new SP_UC_QueryPDO();
            pdo.funcCode = "CardInfoQuery";
            pdo.var1 = txtFromCardNo.Text.Trim();
            pdo.var2 = txtFromCardNo.Text.Trim();
            StoreProScene storePro = new StoreProScene();
            DataTable data = storePro.Execute(context, pdo);
            string cardmanu = "";
            string cardfacename = "";
            if (data != null && data.Rows.Count > 0)
            {
                cardmanu = data.Rows[0]["MANUNAME"].ToString(); ViewState["cardmanu"] = cardmanu;
                cardfacename = data.Rows[0]["CARDSURFACENAME"].ToString(); ViewState["cardsurfacename"] = cardfacename;
            }
            if (hidCardType.Value == "usecard")
            {
                
                string begincardno = txtFromCardNo.Text.Trim();
                string endcardno = txtToCardNo.Text.Trim();
                string reason = txtRemark.Text.Trim();
                if (chkOrder.Checked)
                {
                    printhtml = RMPrintHelper.GetUseCardReturnCardPrintText(seqNo, begincardno, endcardno, cardfacename, cardmanu, reason,
                                                                            context.s_DepartName, context.s_UserName);
                }
            }
            else
            {
                string begincardno = txtFromCardNo.Text.Trim();
                string endcardno = txtToCardNo.Text.Trim();
                string reason = txtRemark.Text.Trim();
                if (chkOrder.Checked)
                {
                    printhtml = RMPrintHelper.GetChargeCardReturnCardPrintText(seqNo, begincardno, endcardno, cardmanu, reason,
                                                                               context.s_DepartName, context.s_UserName);
                }
            }
            //ClearContorl();
            if (printhtml.Trim().Length > 0)
            {
                printarea.InnerHtml = printhtml;
                //执行打印脚本
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
            }
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
                string cardmanu = ViewState["cardmanu"].ToString();
                string cardfacename = ViewState["cardsurfacename"].ToString();
                printhtml = RMPrintHelper.GetUseCardReturnCardPrintText(seqNo, begincardno, endcardno, cardfacename, cardmanu, reason,
                                                                        context.s_DepartName, context.s_UserName);
            }
            else
            {
                context.AddError("没有要打印的退货单"); return;
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
                string cardmanu = ViewState["cardmanu"].ToString();
                printhtml = RMPrintHelper.GetChargeCardReturnCardPrintText(seqNo, begincardno, endcardno, cardmanu, reason,
                                                                           context.s_DepartName, context.s_UserName);
            }
            else
            {
                context.AddError("没有要打印的退货单"); return;
            }
        }
        printarea.InnerHtml = printhtml;
        //执行打印脚本
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
    }

    private void ClearContorl()
    {
        txtFromCardNo.Text = txtToCardNo.Text = txtRemark.Text = string.Empty;
    }

    protected Boolean supplyValidation()
    {
        if (hidCardType.Value == "usecard")
        {
            // 对起始卡号和结束卡号进行校验
            ResourceManageHelper.validateUseCardNoRange(context, txtFromCardNo, txtToCardNo, true, true);
        }
        else
        {
            // 检查起始卡号和终止卡号的格式（非空、14位、英数）
            ResourceManageHelper.validateChargeCardNoRange(context, txtFromCardNo, txtFromCardNo, true);
        }
        return !context.hasError();
    }
}