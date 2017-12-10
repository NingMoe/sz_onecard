using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

/***************************************************************
 * 功能名: 礼金卡_批量写卡时读卡后调用本页面
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/08/28    liuhe			初次开发
 ****************************************************************/
public partial class ASP_CashGift_CG_CashGiftBatchPrewrite : Master.OcxAsynPageMaster
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

        //礼金卡售卡
        CommitInDB(reqBatchId, reqCardNo, reqAsn,
            reqWallet1, reqWallet2, reqBegindate,
            reqEnddate, reqOnlineTradeno, reqOfflineTradeno);
    }


    /// <summary>
    /// 礼金卡售卡
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
    private void CommitInDB(string batchId, string cardNo, string asn20,
        string wallet1, string wallet2, string begindate,
        string enddate, string onlineTradeno, string offlineTradeno)
    {
        try
        {
            string asn = "";
            if (asn20.Length == 20)
                asn = asn20.Substring(4, 16);

            string tradeid = "";//存储过程返回交易序号
            string msg = "";//构建台账子表错误消息字段

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
            context.AddField("P_CURRCARDNO").Value = context.s_CardID;
            context.AddField("P_ID").Value = DealString.GetRecordID(onlineTradeno, asn20);
            context.AddField("P_TRADEID", "string", "output", "16");
            bool ok = context.ExecuteSP("SP_CG_BatchSaleCard");
            tradeid = context.GetFieldValue("P_TRADEID").ToString();
            msg = context.GetFieldValue("p_retCode").ToString() + context.GetFieldValue("p_retMsg").ToString();
            context.DBCommit();

            #region 记录批量售卡台账子表
            string succtag = "1";
            if (msg.Trim().Equals("0000000000"))
                succtag = "0";

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
            context.AddField("P_OPERATETYPECODE").Value = "01";
            context.AddField("P_SUCCTAG").Value = succtag;
            context.AddField("P_ERRMSG").Value = msg;
            context.AddField("P_REMARK").Value = "";
            context.AddField("P_TRADEID").Value = tradeid;

            bool oklog = context.ExecuteSP("SP_BatchTradelistADD");
            #endregion

            if (ok && oklog)
            {
                this.Response.Write("ok" + Md5Encrypt(batchId + cardNo));
            }
            else
            {
                this.Response.Write("error0");
            }
        }
        catch (Exception ex)
        {
            Common.Log.Error("CashGiftBatchPrewrite," + batchId + "," + cardNo, ex, "AppLog");
            this.Response.Write("error1");
        }
        
    }
}
