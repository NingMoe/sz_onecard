using System;
using System.Collections.Generic;
using System.Web;
using Controls.Customer.Asp;
using System.Data;
using System.Collections;
using Master;
using System.Web.UI.WebControls;

/// <summary>
///PBHelper 的摘要说明
/// </summary>
public class PBHelper
{
    public static void openFunc(CmnContext context, OpenFunc openFunc, String cardNo)
    {
        DataTable dt = SPHelper.callPBQuery(context, "QueryOpenFuncs", cardNo);
        ArrayList list = new ArrayList();
        
        if (dt != null && dt.Rows.Count > 0)
        {
            for (int i = 0; i < dt.Rows.Count; ++i )
            {
                list.Add("" + dt.Rows[i].ItemArray[0]);
            }
        }

        openFunc.List = list;
    }

    public static void queryCardNo(CmnContext context, TextBox txtCardno)
    {
        if (txtCardno.Text.Length != 16)
        {
            DataTable dt = SPHelper.callPBQuery(context, "QueryCardNo", txtCardno.Text);
            if (dt.Rows.Count != 1)
            {
                string errMsg = "根据后缀" + txtCardno.Text + "找不到唯一的补全卡号, 符合后缀的卡号有"
                    + dt.Rows.Count + "个, 分别为: " + dt.Rows[0].ItemArray[0];

                for (int i = 1; i < dt.Rows.Count && i < 3; ++i)
                {
                    errMsg += ", " + dt.Rows[i].ItemArray[0];
                }

                if (dt.Rows.Count > 3)
                {
                    errMsg += ", ...";
                }

                context.AddError(errMsg);
            }
            else
            {
                txtCardno.Text = "" + dt.Rows[0].ItemArray[0];
            }
        }
    }
}
