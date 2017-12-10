using System;
using System.Collections.Generic;
using System.Web;
using System.Data;
using Master;
using System.Text;
using System.Web.UI.WebControls;

/// <summary>
/// TLHelper 的摘要说明

/// </summary>
namespace Common
{
    public class TLHelper
    {
        /// <summary>
        /// 验证抽奖状态

        /// </summary>
        /// <param name="context">上下文</param>
        /// <param name="hidAward">奖项</param>
        /// <param name="hidLottery">状态</param>
        public static void ValidationLottery(CmnContext context, string lotteryPeriod, HiddenField hidAward, HiddenField hidLottery)
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

            dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_LOTTERYTASK", lotteryPeriod);
            if (dt.Rows.Count == 0)
            {
                context.AddError("当期抽奖数据还没有生成");
                return;
            }
            string lotteryState = dt.Rows[0]["LOTTERYSTATE"].ToString();
            if (lotteryState == "1")
            {
                //context.AddError("当期所有奖项已经全部抽奖完成");
                hidLottery.Value = "1";
            }
            else if (Convert.ToInt16(lotteryState) >= 3 && hidAward.Value == "0")
            {
                hidLottery.Value = "1";
            }
            else if (Convert.ToInt16(lotteryState) >= 4 && hidAward.Value == "1")
            {
                hidLottery.Value = "1";
            }
            else if (lotteryState != "3" && hidAward.Value == "1")
            {
                context.AddError("特等奖抽奖完成后才能抽一等奖");
            }
            else if (Convert.ToInt16(lotteryState) >= 5 && hidAward.Value == "2")
            {
                hidLottery.Value = "1";
            }
            else if (lotteryState != "4" && hidAward.Value == "2")
            {
                context.AddError("一等奖抽奖完成后才能抽二等奖");
            }
            else if (lotteryState == "6" && hidAward.Value == "3")
            {
                hidLottery.Value = "1";
            }
            else if (lotteryState != "5" && hidAward.Value == "3")
            {
                context.AddError("二等奖抽奖完成后才能抽三等奖");
            }
        }

        /// <summary>
        /// 查询中奖名单
        /// </summary>
        /// <param name="context">上下文</param>
        /// <param name="lotteryPeriod">抽奖期数</param>
        /// <param name="award">奖项</param>
        /// <returns></returns>
        public static string QueryWinnerList(CmnContext context, string lotteryPeriod, string award)
        {
            //查询中奖名单
            string result = string.Empty;
            //DONE:中奖名单都是在抽奖后生成的，且永远不会改变。此处可以采用缓存保存中奖名单，增加页面加载速度。

            string cacheKey = "QUERY_WINNERLIST_" + lotteryPeriod + "_" + award;
            if (HttpContext.Current.Cache.Get(cacheKey) == null)
            {
                DataTable dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_WINNERLIST", lotteryPeriod, award);
                StringBuilder sb = new StringBuilder();
                if (dt.Rows.Count > 0)
                {
                    sb.AppendLine("<tr>");
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        if (i != 0 && i % 7 == 0)
                        {
                            sb.AppendLine("</tr><tr>");
                        }
                        sb.AppendFormat("<td>{0}</td>", dt.Rows[i]["CARDNO"].ToString());
                    }
                    int n = dt.Rows.Count % 7;
                    for (int i = 0; i < (7 - n); i++)
                    {
                        sb.AppendLine("<td></td>");
                    }
                    sb.AppendLine("</tr>");
                    result = sb.ToString();
                    HttpContext.Current.Cache.Insert(cacheKey, result, null, DateTime.Now.AddHours(12), TimeSpan.Zero);
                }
            }
            else
            {
                result = HttpContext.Current.Cache.Get(cacheKey).ToString();
            }

            return result;
        }

        /// <summary>
        /// 查询中奖名单 -- 交通局版

        /// </summary>
        /// <param name="context">上下文</param>
        /// <param name="lotteryPeriod">抽奖期数</param>
        /// <param name="award">奖项</param>
        /// <returns></returns>
        public static string ShowWinnerList(CmnContext context, string lotteryPeriod, string award)
        {
            //查询中奖名单
            string result = string.Empty;
            //DONE:中奖名单都是在抽奖后生成的，且永远不会改变。此处可以采用缓存保存中奖名单，增加页面加载速度。

            string cacheKey = "SHOW_WINNERLIST_" + lotteryPeriod + "_" + award;
            if (HttpContext.Current.Cache.Get(cacheKey) == null)
            {
                DataTable dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_WINNERLIST", lotteryPeriod, award);
                StringBuilder sb = new StringBuilder();
                if (dt.Rows.Count > 0)
                {
                    if (award == "0")
                    {
                        sb.Append("<div id=\"divWinnerList0\"><h2>特等奖中奖卡号:</h2>");
                        foreach (DataRow dr in dt.Rows)
                        {
                            if (dr["STATES"].ToString() == "0")
                            {
                                sb.AppendFormat("<h2>{0} <a data-cardno=\"{0}\" id=\"linkAward\" href=\"javascript:void(0);\">领奖</a></h2>", dr["CARDNO"].ToString(), lotteryPeriod);
                            }
                            else
                            {
                                sb.AppendFormat("<h2>{0}</h2>", dr["CARDNO"].ToString());
                            }
                        }
                        sb.Append("</div>");
                        result = sb.ToString();
                    }
                    else
                    {
                        sb.AppendLine("<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><thead><tr><td>中奖卡号</td><td>中奖卡号</td><td>中奖卡号</td></tr></thead>");
                        sb.AppendLine("<tbody>");
                        sb.AppendLine("<tr>");
                        for (int i = 0; i < dt.Rows.Count; i++)
                        {
                            if (i != 0 && i % 3 == 0)
                            {
                                sb.AppendLine("</tr><tr>");
                                if (i % 2 == 0)
                                {
                                    sb.AppendLine("<tr class=\"double-tr\">");
                                }
                                else
                                {
                                    sb.AppendLine("<tr>");
                                }
                            }
                            sb.AppendFormat("<td>{0}</td>", dt.Rows[i]["CARDNO"].ToString());
                        }
                        int n = dt.Rows.Count % 3;
                        for (int i = 0; i < (3 - n); i++)
                        {
                            sb.AppendLine("<td></td>");
                        }
                        sb.AppendLine("</tr>");
                        sb.AppendLine("</tbody></table>");
                        result = sb.ToString();
                        HttpContext.Current.Cache.Insert(cacheKey, result, null, DateTime.Now.AddHours(12), TimeSpan.Zero);
                    }
                }
            }
            else
            {
                result = HttpContext.Current.Cache.Get(cacheKey).ToString();
            }

            return result;
        }

        /// <summary>
        /// 查询卡号是否有效换乘中奖信息 add by youyue 20141010
        /// </summary>
        /// <param name="cardNo"></param>
        /// <returns></returns>
        public static string queryWinnerInfo(CmnContext context, String cardNo)
        {
            string winnerInfo = string.Empty;
            DataTable dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_CARDWINNERINFO", cardNo);
            if (dt.Rows.Count > 0)
            {
                winnerInfo = "卡号" + cardNo + "中换乘奖励";
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    winnerInfo += dt.Rows[i].ItemArray[0] + ",";
                }
                winnerInfo = winnerInfo.Remove(winnerInfo.LastIndexOf(","), 1);
                winnerInfo = winnerInfo + " ！";
            }
            return winnerInfo;
        }
    }
        
}