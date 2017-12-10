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
using Common;

public partial class ASP_CashGift_CG_CashGiftBatchSale : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        UserCardHelper.resetData(gvResult, null);
 
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON");
        context.DBCommit();
    }

    private void updateGridView()
    {
        context.DBOpen("Select");
        string sql = "select * from (select rownum seq, f1 cardno, f2 salemoney, f4 readcardinfo," +
            " f5 writedbinfo, f6 writecardinfo from TMP_COMMON) order by seq desc";
        DataTable dt = context.ExecuteReader(sql);
        context.DBCommit();

        UserCardHelper.resetData(gvResult, dt);
    }

    private void insertBatchRecord()
    {
        hidSaleSeq.Value = "" + (Convert.ToInt32(hidSaleSeq.Value) + 1);

        context.DBOpen("Insert");
        string sql = "insert into TMP_COMMON(f0, f1, f2, f4) values('" +
            hidSaleSeq.Value + "', '" +
            txtCardNo.Value + "', '" + txtSaleMoney.Text + "','" + 
            txtStartDate.Value + "," + txtEndDate.Value +
            "," + Convert.ToDecimal(txtCardBalance.Value) / 100 +
            "," + Convert.ToDecimal(txtWallet2.Value) / 100 +
            "," + hidTradeNo.Value + "')";
        context.ExecuteNonQuery(sql);
        context.DBCommit();

    }

    private void updateBatchRecordWriteDb(bool ok, string retMsg)
    {
        context.DBOpen("Update");
        string sql = "update TMP_COMMON set f5 = '" +
            (ok ? "OK" : retMsg.Trim()) + "' where f0 = '" + hidSaleSeq.Value + "'";
        context.ExecuteNonQuery(sql);
        context.DBCommit();
    }

    private void updateBatchRecordWriteCardOK()
    {
        context.DBOpen("Update");
        context.ExecuteNonQuery("update TMP_COMMON set f6 = '" + 
            txtStartDate.Value + "," + txtEndDate.Value +
            "," + Convert.ToDecimal(txtCardBalance.Value)/100 +
            "," + Convert.ToDecimal(txtWallet2.Value)/100 +
            "," + hidTradeNo.Value +
            "' where f0 = '" + hidSaleSeq.Value + "'");
        context.DBCommit();
    }

    private void updateBatchRecordWriteCardFail(string retMsg)
    {
        context.DBOpen("Update");
        context.ExecuteNonQuery("update TMP_COMMON set f6 = lpad('FAIL:" + retMsg + 
              "', 255) where f0 = '" + txtCardNo.Value + "'");
        context.DBCommit();
    }
    
    private bool callSaleCardSP()
    {
        context.SPOpen();

        context.AddField("P_SUBMIT").Value = "1";
        context.AddField("P_CARDNO").Value = txtCardNo.Value;
        context.AddField("P_WALLET1").Value = Convert.ToInt32(txtCardBalance.Value);
        context.AddField("P_WALLET2").Value = Convert.ToInt32(txtWallet2.Value == "NaN" ? "0.00" : txtWallet2.Value);
        context.AddField("P_STARTDATE").Value = txtStartDate.Value;
        context.AddField("P_ENDDATE").Value = txtEndDate.Value;

        context.AddField("P_EXPIREDDATE").Value = "20501231";

        context.AddField("P_SALEMONEY").Value = Convert.ToInt32(txtSaleMoney.Text) * 100;
        context.AddField("P_ID").Value = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        context.AddField("P_CARDTRADENO").Value = hidTradeNo.Value;
        context.AddField("P_ASN").Value = hidAsn.Value.Substring(4, 16);
        context.AddField("P_SELLCHANNELCODE").Value = "01";
        context.AddField("P_TERMINALNO").Value = "112233445566"; 
 
        context.AddField("P_CARDPRICE", "Int32", "output", "");
        context.AddField("P_CUSTNAME");
        context.AddField("P_CUSTSEX");
        context.AddField("P_CUSTBIRTH");
        context.AddField("P_PAPERTYPE");
        context.AddField("P_PAPERNO");
        context.AddField("P_CUSTADDR");
        context.AddField("P_CUSTPOST");
        context.AddField("P_CUSTPHONE");
        context.AddField("P_CUSTEMAIL");
        context.AddField("P_REMARK");
        context.AddField("P_SEQNO", "string", "output", "16");
        context.AddField("P_CURRCARDNO").Value = context.s_CardID;
        context.AddField("P_WRITECARDSCRIPT", "string", "output", "1024");

        bool ok = context.ExecuteSP("SP_CG_SaleCard");

        // 存储过程执行成功，显示成功消息
        if (ok)
        {
            hidSeqNo.Value = "" + context.GetField("P_SEQNO").Value;

            // 准备收据打印数据
            ASHelper.prepareShouJu(ptnShouJu, txtCardNo.Value, context.s_UserName, txtSaleMoney.Text);

            string writeCardScripts = "" + context.GetField("P_WRITECARDSCRIPT").Value;

            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript", writeCardScripts, true);
        }

        return ok;
    }




    // 确认对话框确认处理
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "ReadSuccess") // 读卡成功
        {
            insertBatchRecord();
            bool ok = callSaleCardSP();
            updateBatchRecordWriteDb(ok, "" +　context.GetFieldValue("p_retMsg"));
            updateGridView();
        }
        else if (hidWarning.Value == "writeSuccess") // 写卡成功
        {
            context.DBOpen("StorePro");
            context.AddField("p_TRADEID").Value = hidSeqNo.Value;
            context.AddField("p_CARDTRADENO").Value = hidTradeNo.Value;
            context.ExecuteSP("SP_PB_updateCardTrade");

            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript", "readGiftFunc();", true);

            updateBatchRecordWriteCardOK();
            updateGridView();
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("前台写卡失败");
            updateBatchRecordWriteCardFail(hidWriteCardFailInfo.Value);
            updateGridView();
        }

        hidWarning.Value = ""; // 清除警告信息
    }

    // 提交判断
    private void submitValidate()
    {
        Validation val = new Validation(context);
        val.beNumber(txtSaleMoney, "售卡金额必须是有效整数金额");

    }

    // 售卡提交
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        submitValidate();
        if (context.hasError()) return;

        ScriptManager.RegisterStartupScript(
            this, this.GetType(), "writeCardScript", "readGiftFunc();", true);
    }
}
