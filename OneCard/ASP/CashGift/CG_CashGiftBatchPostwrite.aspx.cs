using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

/***************************************************************
 * 功能名: 礼金卡_批量写卡时写卡后调用本页面
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/08/28    liuhe			初次开发
 ****************************************************************/
public partial class ASP_CashGift_CG_CashGiftBatchPostwrite : Master.OcxAsynPageMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string reqBatchId = RequestString("batchId");
        string reqCardNo = RequestString("cardNo");
        string reqAsn = RequestString("asn");
        string reqWallet1 = RequestString("balance");//单位分
        string reqWallet2 = RequestString("walletBalance");//单位分
        string reqBegindate = RequestString("startDate");
        string reqEnddate = RequestString("endDate");
        string reqOnlineTradeno = RequestString("onlineTradeNo");
        string reqOfflineTradeno = RequestString("offlineTradeNo");
        string reqStatus = RequestString("status");
        string reqDesc = RequestString("desc");

        CommitInDB(reqBatchId, reqCardNo, reqAsn,
           reqWallet1, reqWallet2, reqBegindate,
           reqEnddate, reqOnlineTradeno, reqOfflineTradeno, reqStatus, reqDesc);
    }

    /// <summary>
    /// 写卡后调用,用于售卡返销和记录台账
    /// </summary>
    /// <param name="batchId">批次号</param>
    /// <param name="cardNo">卡号</param>
    /// <param name="asn20">ASN号</param>
    /// <param name="wallet1">电子存折余额</param>
    /// <param name="wallet2">电子钱包余额</param>
    /// <param name="begindate">启用日期</param>
    /// <param name="enddate">有效日期</param>
    /// <param name="onlineTradeno">联机交易序号</param>
    /// <param name="offlineTradeno">脱机交易序号</param>
    /// <param name="status">ocx返回状态</param>
    /// <param name="desc">错误描述</param>
    private void CommitInDB(string batchId, string cardNo, string asn20,
       string wallet1, string wallet2, string begindate,
       string enddate, string onlineTradeno, string offlineTradeno,
        string status, string desc)
    {

        try
        {
            string asn = "";
            if (asn20.Length == 20)
                asn = asn20.Substring(4, 16);

            string msg = "";
            string succtag = "1";//0成功,1失败
            if (status.Equals("0"))//ocx返回状态成功
            {
                succtag = "0";
            }
            string tradeid = "";//存储过程返回交易序号

            if (status.Equals("1"))//ocx返回状态写卡失败
            {
                context.SPOpen();
                context.AddField("P_ID").Value = DealString.GetRecordID(onlineTradeno, asn20);
                context.AddField("P_CARDNO").Value = cardNo;
                context.AddField("P_WALLET1", "Int32").Value = (int)Convert.ToDecimal(wallet1 == "" ? "0.00" : wallet1);
                context.AddField("P_CARDTRADENO").Value = onlineTradeno;
                context.AddField("P_CURRCARDNO").Value = context.s_CardID;
                context.AddField("P_TRADEID", "string", "output", "16");

                bool ok = context.ExecuteSP("SP_CG_BatchSaleCardRollback");
                msg = context.GetFieldValue("p_retCode").ToString() + context.GetFieldValue("p_retMsg").ToString();
                tradeid = context.GetFieldValue("P_TRADEID").ToString();

                context.DBCommit();

                Response.Write(context.GetFieldValue("P_RETCODE").ToString());
            }

            #region 记录批量售卡台账子表
            context.SPOpen();
            context.AddField("P_BATCHID").Value = batchId;
            context.AddField("P_CARDNO").Value = cardNo;
            context.AddField("P_ASN").Value = asn;
            context.AddField("P_WALLET1", "Int32").Value = (int)Convert.ToDecimal(wallet1 == "" ? "0.00" : wallet1);
            context.AddField("P_WALLET2", "Int32").Value = (int)Convert.ToDecimal(wallet2 == "" ? "0.00" : wallet2);
            context.AddField("P_STARTDATE").Value = begindate;
            context.AddField("P_ENDDATE").Value = enddate;
            context.AddField("P_ONLINETRADENO").Value = onlineTradeno;
            context.AddField("P_OFFLINETRADENO").Value = offlineTradeno;
            context.AddField("P_TRADETYPECODE").Value = "50";
            context.AddField("P_OPERATETYPECODE").Value = "02";
            context.AddField("P_SUCCTAG").Value = succtag;
            context.AddField("P_ERRMSG").Value = desc;
            context.AddField("P_REMARK").Value = msg;
            context.AddField("P_TRADEID").Value = tradeid;

            bool oklog = context.ExecuteSP("SP_BatchTradelistADD");
            #endregion

        }
        catch (Exception ex)
        {
            Common.Log.Error("CashGiftBatchPostwrite," + batchId + "," + cardNo, ex, "AppLog");
        }
    }


}
