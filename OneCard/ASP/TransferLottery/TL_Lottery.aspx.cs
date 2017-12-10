using System;
using System.Data;
using System.Text;
using Common;
/// <summary>
/// 换乘抽奖 
/// 董翔 20140415
/// </summary>
public partial class ASP_TransferLottery_TL_Lottery : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if(!IsPostBack)
        {
             hidAward.Value = "0";
             tagAward0.Attributes["class"] = "on";
             ShowWinnerList();
             InitPage();
        }
    }

    //页面初始化
    private void InitPage()
    { 
        lblPeriod.Text = DateTime.Now.AddMonths(-1).ToString("yyyyMM");
        lblLotteryTime.Text = DateTime.Now.ToString();
        if (hidAward.Value == "0")
        {
            lblAward.Text = "特等奖";
        }
        else if (hidAward.Value == "1")
        {
            lblAward.Text = "一等奖";
        }
        else if (hidAward.Value == "2")
        {
            lblAward.Text = "二等奖";
        }
        else if (hidAward.Value == "3")
        {
            lblAward.Text = "三等奖";
        }
        InitValidation();
        if (!context.hasError())
        {
            btnLottery.Enabled = true;
        }
        else
        {
            btnLottery.Enabled = false;
        }
    }

    //初始化验证
    private void InitValidation()
    {
        //获取系统日期,判断其是否允许抽奖。
        int days = DateTime.Now.Day;
        DataTable dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_LOTTERYDAY");
        if (dt.Rows.Count == 0)
        {
            context.AddError("抽奖日期没有配置");
            return;
        }
        else
        {
            if (days < Convert.ToInt16(dt.Rows[0]["TAGVALUE"].ToString().Split('-')[0]) || days > Convert.ToInt16(dt.Rows[0]["TAGVALUE"].ToString().Split('-')[1]))
            {
                context.AddError("当前日期不允许抽奖");
                return;
            }
        }
        //根据系统日期，查询【抽奖任务表】
        dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_LOTTERYTASK", DateTime.Now.AddMonths(-1).ToString("yyyyMM"));
        if (dt.Rows.Count == 0)
        {
            context.AddError("当期抽奖数据还没有生成");
            return;
        }
        string lotteryState = dt.Rows[0]["LOTTERYSTATE"].ToString();
        if (lotteryState == "1")
        {
            context.AddError("当期所有奖项已经全部抽奖完成");
        }
        else if (Convert.ToInt16(lotteryState) >= 3 && hidAward.Value == "0")
        {
            context.AddError("当期特等奖已经抽奖完成");
        }
        else if (Convert.ToInt16(lotteryState) >= 4 && hidAward.Value == "1")
        {
            context.AddError("当期一等奖已经抽奖完成");
        }
        else if (lotteryState != "3" && hidAward.Value == "1")
        {
            context.AddError("特等奖抽奖完成后才能抽一等奖");
        }
        else if (Convert.ToInt16(lotteryState) >= 5 && hidAward.Value == "2")
        {
            context.AddError("当期二等奖已经抽奖完成");
        }
        else if (lotteryState != "4" && hidAward.Value == "2")
        {
            context.AddError("一等奖抽奖完成后才能抽二等奖");
        }
        else if (lotteryState == "6" && hidAward.Value == "3")
        {
            context.AddError("当期三等奖已经抽奖完成");
        }
        else if (lotteryState != "5" && hidAward.Value == "3")
        {
            context.AddError("二等奖抽奖完成后才能抽三等奖");
        }
    }

    //选中特等奖
    protected void tagAward0_Click(object sender, EventArgs e)
    {
        tagAward0.Attributes["class"] = "on";
        tagAward1.Attributes["class"] = "";
        tagAward2.Attributes["class"] = "";
        tagAward3.Attributes["class"] = "";
        hidAward.Value = "0";
        InitPage();
        ShowWinnerList();
        

    }

    //选中一等奖
    protected void tagAward1_Click(object sender, EventArgs e)
    {
        tagAward0.Attributes["class"] = "";
        tagAward1.Attributes["class"] = "on";
        tagAward2.Attributes["class"] = "";
        tagAward3.Attributes["class"] = "";
        hidAward.Value = "1";
        InitPage();
        ShowWinnerList();
        
        
    }

    //选中二等奖
    protected void tagAward2_Click(object sender, EventArgs e)
    {
        tagAward0.Attributes["class"] = "";
        tagAward1.Attributes["class"] = "";
        tagAward2.Attributes["class"] = "on";
        tagAward3.Attributes["class"] = "";
        hidAward.Value = "2";
        InitPage();
        ShowWinnerList();
        
        
    }

    //选中三等奖
    protected void tagAward3_Click(object sender, EventArgs e)
    {
        tagAward0.Attributes["class"] = "";
        tagAward1.Attributes["class"] = "";
        tagAward2.Attributes["class"] = "";
        tagAward3.Attributes["class"] = "on";
        hidAward.Value = "3";
        InitPage();
        ShowWinnerList();
        
       
    }

    //抽奖
    protected void btnLottery_Click(object sender, EventArgs e)
    {
        if (!context.hasError())
        {
            context.SPOpen();
            context.AddField("P_AWARDSCODE").Value = hidAward.Value;
            context.AddField("P_LOTTERYPERIOD").Value = DateTime.Now.AddMonths(-1).ToString("yyyyMM");
            bool ok = context.ExecuteSP("SP_TL_Lottery"); 
            if (ok)
            {
                AddMessage("抽奖成功");
                ShowWinnerList();
                btnLottery.Enabled = false;
            }
        }
    }

    //显示中奖名单
    private void ShowWinnerList()
    {
        //查询中奖名单
        string winnerList = TLHelper.QueryWinnerList(context, DateTime.Now.AddMonths(-1).ToString("yyyyMM"), hidAward.Value);
        if (!string.IsNullOrEmpty(winnerList))
        {
            litWinnerList.Text = winnerList;
            btnPrint.Enabled = true;
            lalTitle.Text = DateTime.Now.AddMonths(-1).ToString("yyyyMM") + " " + lblAward.Text + "中奖名单";
        }
        else
        {
            litWinnerList.Text = "";
            btnPrint.Enabled = false;
            lalTitle.Text = "";
        }
    }
}