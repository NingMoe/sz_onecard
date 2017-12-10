using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.IO;
using Master;
using Common;

/// <summary>
///GetCardnoSectionHelper 的摘要说明
///获取卡号段
/// </summary>
public class GetCardnoSectionHelper : Master.Master
{
	public GetCardnoSectionHelper()
	{
		//
		//TODO: 在此处添加构造函数逻辑
		//
	}

    public static DataTable getCardnoSection(CmnContext context, string cardtypecode, Int32 count, ref int selectIndex)
    {
        string sql = "";
        sql += " select min(t.cardno) startcardno , " + //最小卡号
               "        max(t.cardno) endcardno , " + //最大卡号
               "       (max(t.cardno) - min(t.cardno) +1) cardnum " +
               " from  (select n.cardno  " +
               "        from tf_f_cardnoconfig n " +
               "        where n.cardtypecode = '" + cardtypecode + "' " +
               "        and   not exists (select 1 from TD_M_CARDNO_EXCLUDE b where substr(b.cardno,-8) = n.cardno ) " + //排除排重表中已有卡号
               "        and   not exists (select 1 from tl_r_icuser a where substr(a.cardno,-8) = n.cardno ) " + //排除卡库存表中已有卡号
               "        order by n.cardno) t " +
               " group by t.cardno - rownum ";

        string excutesql = "select re.startcardno , re.endcardno , re.cardnum from ( " + sql + " ) re where re.cardnum > 19 order by re.cardnum desc";

        context.DBOpen("Select");
        DataTable CardNoData = context.ExecuteReader(excutesql);

        //选择行数
        selectIndex = -1;
        //自动选中第一个号段中号数量大于要求卡片数量的行
        for (int i = 0; i < CardNoData.Rows.Count; ++i)
        {
            //itemArray = selectRowData.Rows[i].ItemArray;
            if (Convert.ToInt32(CardNoData.Rows[i][2]) < count)
            {
                selectIndex = i - 1;
                break;
            }
            //如果到最后一行也没有小于订购数量的号段数量，则选中最后一行
            if (i == CardNoData.Rows.Count - 1)
            {
                selectIndex = i;
                break;
            }
        }

        return CardNoData;
    }
    /// <summary>
    /// 获取市民卡A卡卡号段
    /// </summary>
    /// <param name="context">上下文</param>
    /// <param name="cardtypecode">卡类型</param>
    /// <param name="count">卡片数量</param>
    /// <param name="selectIndex">选择行数</param>
    /// <returns></returns>
    public static DataTable getSMKCardnoSection(CmnContext context, Int32 count, ref int selectIndex)
    {
        //string sql = "";
        //sql += " select min(t.cardno) startcardno , " + //最小卡号
        //       "        max(t.cardno) endcardno , " + //最大卡号
        //       "       (max(t.cardno) - min(t.cardno) +1) cardnum " +
        //       " from  (select n.cardno  " +
        //       "        from tf_f_smkcardnoconfig n " +
        //       "        where not exists (select 1 from TD_M_SMKCARDNO_EXCLUDE b where substr(b.cardno,-8) = n.cardno ) " + //排除排重表中已有卡号
        //       "        and   not exists (select 1 from tl_r_icuser a where substr(a.cardno,-8) = n.cardno ) " + //排除卡库存表中已有卡号
        //       "        order by n.cardno) t " +
        //       " group by t.cardno - rownum ";

        //string excutesql = "select re.startcardno , re.endcardno , re.cardnum from ( " + sql + " ) re where re.cardnum > 19 order by re.cardnum desc";
        string excutesql = "select startcardno , endcardno , cardnum from  TF_F_CARDORDER_EXCLUDE  where cardtypecode = '18' and cardnum > 19 order by cardnum desc";
        context.DBOpen("Select");
        DataTable CardNoData = context.ExecuteReader(excutesql);

        //选择行数
        selectIndex = -1;
        //自动选中第一个号段中号数量大于要求卡片数量的行
        for (int i = 0; i < CardNoData.Rows.Count; ++i)
        {
            //itemArray = selectRowData.Rows[i].ItemArray;
            if (Convert.ToInt32(CardNoData.Rows[i][2]) < count)
            {
                selectIndex = i - 1;
                break;
            }
            //如果到最后一行也没有小于订购数量的号段数量，则选中最后一行
            if (i == CardNoData.Rows.Count - 1)
            {
                selectIndex = i;
                break;
            }
        }

        return CardNoData;
    }
}