using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Master;
using Common;

/// <summary>
/// TradeQueryHelper 的摘要说明
/// 交易信息查询处理
/// </summary>
/// 
public class TradeQueryHelper
{
	public TradeQueryHelper()
	{
	
	}

    public static void ValidBeginAndEndDate(CmnContext context, TextBox txtBeginDate, TextBox txtEndDate)
    {
        DateTime? beginDate = null;
        DateTime? endDate = null;

        //对起始日期非空, 格式的校验
        string strBeginDate = txtBeginDate.Text.Trim();
        string strEndDate = txtEndDate.Text.Trim();
        if (strBeginDate == "")
        {
            context.AddError("A003104410", txtBeginDate);
        }

        else if (!Validation.isDate(strBeginDate, "yyyy-MM-dd"))
        {
            context.AddError("A003104411", txtBeginDate);
        }
        else
        {
            beginDate = DateTime.ParseExact(strBeginDate, "yyyy-MM-dd", null);
        }

        //对终止日期非空, 格式的校验
        if (strEndDate == "")
        {
            context.AddError("A003104412", txtEndDate);
        }

        else if (!Validation.isDate(strEndDate, "yyyy-MM-dd"))
        {
            context.AddError("A003104413", txtEndDate);
        }
        else
        {
            endDate = DateTime.ParseExact(strEndDate, "yyyy-MM-dd", null);
        }

        //对终止日期大于起始日期的校验
        if (beginDate != null && endDate != null)
        {
            if (beginDate.Value.CompareTo(endDate.Value) > 0)
            {
                context.AddError("A003104414 ", txtBeginDate);
            }
        }
    }
}
