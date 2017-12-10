using Common;
using System; 
/// <summary>
/// 换乘抽奖--抽奖事件 
/// 董翔 20140526
/// </summary>
public partial class TransferLottery_DoLottery : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["award"] != null)
        {
            hidAward.Value = Request["award"].ToString();
            //校验抽奖信息
            TLHelper.ValidationLottery(context, DateTime.Now.AddMonths(-1).ToString("yyyyMM"),hidAward, hidLottery);
            if (!context.hasError() && hidLottery.Value != "1")
            {
                //调用抽奖存储过程
                context.SPOpen();
                context.AddField("P_AWARDSCODE").Value = hidAward.Value;
                context.AddField("P_LOTTERYPERIOD").Value = DateTime.Now.AddMonths(-1).ToString("yyyyMM");
                bool ok = context.ExecuteSP("SP_TL_Lottery");
                if (ok)
                {
                    Response.Write("1");
                    Response.End(); 
                }
                else
                {
                    Response.Write(context.ErrorMessage[0].ToString());
                    Response.End();
                }
            }
        }
        Response.Write(context.ErrorMessage[0].ToString());
        Response.End();
    }
}