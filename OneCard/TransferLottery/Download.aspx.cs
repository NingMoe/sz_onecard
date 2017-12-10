using System;
using System.Data;
using System.Web;
//下载奖池数据
public partial class TransferLottery_Download : Master.TransferLotteryMaster
{
    //页面初始化
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack) 
        {
            DataTable dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_LOTTERYTASKALL", "");
            ddlLotteryPeriod.DataTextField = "LOTTERYPERIOD";
            ddlLotteryPeriod.DataValueField = "LOTTERYPERIOD";
            ddlLotteryPeriod.DataSource = dt;
            ddlLotteryPeriod.DataBind();
            ddlLotteryPeriod.SelectedIndex = 0; 
        } 
    }

    //下载奖池数据
    protected void btnDownlodad_Click(object sender, EventArgs e)
    {
        DataTable dt = SPHelper.callQuery("SP_TL_Query", context, "DOWNLOAD_LOTTERYDATA", ddlLotteryPeriod.SelectedValue);
        if (dt.Rows.Count > 0 )
        {
            Object[] row = dt.Rows[0].ItemArray;
            if (row[0] != null)
            {
                byte[] file = (byte[])row[0];
                //下载文件
                HttpResponse contextResponse = HttpContext.Current.Response;
                contextResponse.Clear();
                contextResponse.Buffer = true;
                string strTemp = System.Web.HttpUtility.UrlEncode(ddlLotteryPeriod.SelectedValue + ".zip", System.Text.Encoding.UTF8); 
                contextResponse.AppendHeader("Content-Disposition", String.Format("attachment;filename={0}", strTemp));
                contextResponse.AppendHeader("Content-Length", file.Length.ToString());
                contextResponse.BinaryWrite(file);
                contextResponse.Flush();
                contextResponse.End();
            }
        }
    }
}