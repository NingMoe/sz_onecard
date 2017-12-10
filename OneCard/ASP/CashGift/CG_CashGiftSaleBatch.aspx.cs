using System;
using System.Collections.Generic;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;


/***************************************************************
 * 功能名: 礼金卡_批量售卡
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/08/28    liuhe			初次开发
 ****************************************************************/
public partial class ASP_CashGift_CG_CashGiftSaleBatch : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        UserCardHelper.resetData(gvResult, null); 

        #region 初始化ocx调用的参数
        string absurl = Request.Url.AbsoluteUri;
        string[] absUrls = absurl.Split('/');
        string url = absurl.Replace(absUrls[absUrls.Length - 1], "");
        this.hidPrewriteUrl.Value = url + "CG_CashGiftBatchPrewrite.aspx";
        this.hidPostwriteUrl.Value = url + "CG_CashGiftBatchPostwrite.aspx";
        this.hidSysDate.Value = DateTime.Now.ToString("yyyyMMdd");
        #endregion
    }

    /// <summary>
    /// 开始售卡按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSaleCard_Click(object sender, EventArgs e)
    {
        submitValidate();
        if (context.hasError()) return;

        SetBatchId();
        UserCardHelper.resetData(gvResult, null);
        this.divErrorList.Visible = false;

        string batchId = this.hidBatchId.Value;
        string needCount = this.txtSalCount.Text;
        string currentMoney = (Convert.ToDecimal(txtSaleMoney.Text) * 100).ToString();

        context.SPOpen();
        context.AddField("P_BATCHID").Value = batchId;
        context.AddField("P_NEEDCOUNT").Value = needCount;
        context.AddField("P_CURRNETMONEY").Value = currentMoney;
        context.AddField("P_SUCCOUNT").Value = "0";
        context.AddField("P_ERRCOUNT").Value = "0";
        context.AddField("P_SUCCARDNO").Value = "";
        context.AddField("P_ERRCARDNO").Value = "";
        context.AddField("P_TRADETYPECODE").Value = "50";
        context.AddField("P_OPERATETYPECODE").Value = "01";
        context.AddField("p_OPERCARDNO").Value = context.s_CardID.Trim();
        context.AddField("P_ERRMSG").Value = "";
        context.AddField("P_REMARK").Value = "";

        bool ok = context.ExecuteSP("SP_BatchTradeADD");

        if (ok)
        {
            this.btnSaleCard.Enabled = false;

            ScriptManager.RegisterStartupScript(
            this, this.GetType(), "writeStartOperationScript", "StartOperation();", true);
        }
    }


    /// <summary>
    /// 售卡写卡结束调用
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        string batchId = this.hidBatchId.Value;
        string needCount = this.txtSalCount.Text;
        string currentMoney = (Convert.ToDecimal(txtSaleMoney.Text) * 100).ToString();
        string successCount = this.hidSuccessCount.Value;
        string failCount = this.hidFailCount.Value;
        string successCardnos = this.hidSuccessCardnos.Value;
        string failCardnos = this.hidFailCardnos.Value;
        string finishmessage = this.hidFinishmessage.Value;

        context.SPOpen();
        context.AddField("P_BATCHID").Value = batchId;
        context.AddField("P_NEEDCOUNT").Value = needCount;
        context.AddField("P_CURRNETMONEY").Value = currentMoney;
        context.AddField("P_SUCCOUNT").Value = successCount;
        context.AddField("P_ERRCOUNT").Value = failCount;
        context.AddField("P_SUCCARDNO").Value = successCardnos;
        context.AddField("P_ERRCARDNO").Value = failCardnos;
        context.AddField("P_TRADETYPECODE").Value = "50";
        context.AddField("P_OPERATETYPECODE").Value = "02";
        context.AddField("p_OPERCARDNO").Value = context.s_CardID.Trim();
        context.AddField("P_ERRMSG").Value = finishmessage;
        context.AddField("P_REMARK").Value = "";

        bool ok = context.ExecuteSP("SP_BatchTradeADD");

        context.AddMessage(this.hidMsg.Value);

        BindErrorCardList();

        #region 清除控件值
        this.btnSaleCard.Enabled = true;

        this.hidMsg.Value = ""; // 清除警告信息
        this.hidBatchId.Value = "";
        this.hidSuccessCount.Value = "";
        this.hidFailCount.Value = "";
        this.hidSuccessCardnos.Value = "";
        this.hidFailCardnos.Value = "";
        this.hidFinishmessage.Value = "";
        this.txtSalCount.Text = "";
        this.txtSaleMoney.Text = "";
        #endregion
    }

    /// <summary>
    /// 提交前的验证
    /// </summary>
    private void submitValidate()
    {

        if (string.IsNullOrEmpty(context.s_CardID.Trim()))
        {
            context.AddError("无操作员卡号");
        }
        else if (!hiddenCheck.Value.Trim().Equals(context.s_CardID.Trim()))
        {
            context.AddError("插入操作员卡与登录员工不符");
        }

        Validation val = new Validation(context);

        long cnt = val.beNumber(txtSalCount, "售卡数量必须是有效整数");
        if (!context.hasError())
        {
            if (cnt > 100 || cnt <= 0)
            {
                context.AddError("售卡数量必须在1到100之间", txtSalCount);
            }
        }

        long salMoney = val.beNumber(txtSaleMoney, "售卡金额必须是有效整数金额");

        if (!context.hasError())
        {
            if (salMoney > 1000 || salMoney < 10)
            {
                context.AddError("售卡金额必须在10元到1000元之间", txtSaleMoney);
            }
        }
    }


    /// <summary>
    /// 创建批次号
    /// </summary>
    private void SetBatchId()
    {
        string batchId = "";

        batchId = DateTime.Now.ToString("yyyyMMddHHmmss") + context.s_UserID;

        this.hidBatchId.Value = batchId;

    }

    /// <summary>
    /// 绑定错误卡片列表
    /// </summary>
    private void BindErrorCardList()
    {
        DataTable data = SPHelper.callQuery("SP_CG_Query", context, "BatchSaleCardErrTrade",
           this.hidBatchId.Value);
        UserCardHelper.resetData(gvResult, data);

        if (data == null || data.Rows.Count == 0)
        {
            divErrorList.Visible = false;
        }
        else
        {
            divErrorList.Visible = true;
        }
    }
}
