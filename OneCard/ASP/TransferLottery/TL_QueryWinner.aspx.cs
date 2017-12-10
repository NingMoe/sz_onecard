using System;
using System.Data;
using System.Text;
using Common;
/// <summary>
/// 中奖名单 
/// 董翔 20140421
/// </summary>
public partial class ASP_TransferLottery_TL_QueryWinner : Master.Master
{
    //页面初始化
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            DataTable dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_LOTTERYTASKALL");
            ddlLotteryPeriod.DataTextField = "LOTTERYPERIOD";
            ddlLotteryPeriod.DataValueField = "LOTTERYPERIOD";
            ddlLotteryPeriod.DataSource = dt;
            ddlLotteryPeriod.DataBind();
            LoadData(ddlLotteryPeriod.SelectedValue);
        }
    }

    //奖期变更
    protected void ddlLotteryPeriod_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadData(ddlLotteryPeriod.SelectedValue);
    }

    /// <summary>
    /// 查询并显示结果
    /// </summary>
    /// <param name="lotteryPeriod">期数</param>
    private void LoadData(string lotteryPeriod)
    {
        //查询中奖名单
        string winnerList = TLHelper.QueryWinnerList(context, lotteryPeriod, "0");
        if (!string.IsNullOrEmpty(winnerList))
        {
            litWinnerList0.Text = winnerList; 
        }
        winnerList = string.Empty;
        winnerList = TLHelper.QueryWinnerList(context, lotteryPeriod, "1");
        if (!string.IsNullOrEmpty(winnerList))
        {
            litWinnerList1.Text = winnerList;
        }
        winnerList = string.Empty;
        winnerList = TLHelper.QueryWinnerList(context, lotteryPeriod, "2");
        if (!string.IsNullOrEmpty(winnerList))
        {
            litWinnerList2.Text = winnerList;
        }
        winnerList = string.Empty;
        winnerList = TLHelper.QueryWinnerList(context, lotteryPeriod, "3");
        if (!string.IsNullOrEmpty(winnerList))
        {
            litWinnerList3.Text = winnerList;
        }  
    }
}