using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.UI.WebControls;
using Controls.Customer.Asp;
using Master;

/// <summary>
/// HYDROPHelper 的摘要说明
/// </summary>
public class HYDROPHelper
{
    public static void InitItemCodes(DropDownList selItemCode, bool isAddEmpty)
    {
        if (isAddEmpty)
        {
            selItemCode.Items.Add(new ListItem("", ""));
        }
        selItemCode.Items.Add(new ListItem("001:苏州市区水费", "001"));
        selItemCode.Items.Add(new ListItem("002:苏州吴中水费", "002"));
        selItemCode.Items.Add(new ListItem("003:苏州新区水费", "003"));
        selItemCode.Items.Add(new ListItem("004:相城区水费", "004"));
        selItemCode.Items.Add(new ListItem("005:工业园区水费代缴", "005"));
        selItemCode.Items.Add(new ListItem("011:苏州燃气", "011"));
        //selItemCode.Items.Add(new ListItem("021:苏州市区有线电视", "021"));
        selItemCode.Items.Add(new ListItem("031:苏州电力", "031"));
        selItemCode.Items.Add(new ListItem("101:电信充值", "101"));
        //selItemCode.Items.Add(new ListItem("141:苏州电信预付费", "141"));
        selItemCode.Items.Add(new ListItem("121:移动充值", "121"));
        //selItemCode.Items.Add(new ListItem("151:移动预付费", "151"));
        selItemCode.Items.Add(new ListItem("131:联通充值", "131"));
        //selItemCode.Items.Add(new ListItem("161:联通预付费", "161"));
        selItemCode.Items.Add(new ListItem("201:苏州市有线电视费", "201"));
    }

    public static string GetBALUNITNO(string itemCode)
    {
        switch (itemCode)
        {
            case "001":
                return "14001450";//苏州市区水费
            case "002":
                return "14001452";//苏州吴中水费
            case "003":
                return "14001454";//苏州新区水费
            case "004":
                return "14001451";//相城区水费
            case "005":
                return "14001453";//工业园区水费代缴
            case "011":
                return "14001460";//苏州燃气
            case "031":
                return "14001459";//苏州电力
            case "101":
                return "14001464";//电信充值
            case "121":
                return "14001466";//移动充值
            case "131":
                return "14001465";//联通充值
            case "201":
                return "14001458";//苏州市有线电视费
            default:
                return "12345678";
        }
    }

    public static void InitChargeTypes(DropDownList selChargeType, bool isAddEmpty)
    {
        if (isAddEmpty)
        {
            selChargeType.Items.Add(new ListItem("", ""));
        }
        selChargeType.Items.Add(new ListItem("0:电子钱包", "0"));
        selChargeType.Items.Add(new ListItem("1:专有账户", "1"));
    }

    public static void InitChargeStatus(DropDownList selChargeStatus, bool isAddEmpty)
    {
        if (isAddEmpty)
        {
            selChargeStatus.Items.Add(new ListItem("", ""));
        }
        selChargeStatus.Items.Add(new ListItem("0:缴费失败", "0"));
        selChargeStatus.Items.Add(new ListItem("1:缴费成功", "1"));
        selChargeStatus.Items.Add(new ListItem("2:缴费异常", "2"));
    }

    public static void PreparePingZheng(string seqNo, PrintPingZheng ptnPZ,CmnContext context)
    {
        DataTable data = SPHelper.callQuery("SP_CS_HYDROPPOWER_QUERY", context, "Query_HYDROPPOWER_RecordBySeqNo",
            seqNo);
        if (data.Rows.Count > 0)
        {
            DataRow dataRow = data.Rows[0];
            ASHelper.preparePingZheng(ptnPZ, dataRow["CARDNO"].ToString(), dataRow["CUSTOMER_NAME"].ToString(),
                dataRow["CHARGE_ITEM_TYPE_DISPLAY"].ToString(), dataRow["REAL_AMOUNT"].ToString(), "", "", "", "", "", dataRow["REAL_AMOUNT"].ToString(), dataRow["OPERATESTAFFNO"].ToString(), dataRow["CHARGE_TYPE_DISPLAY"].ToString(), "", "", "");
        }
    }
}