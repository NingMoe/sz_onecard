using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using Common;
using Master;
using PDO.PersonalBusiness;
using TM;
using System.IO;
/// <summary>
/// 换乘抽奖->领奖历史查询
/// add by youyue 20140804
/// </summary>
public partial class ASP_TransferLottery_TL_AwardHistory : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
            
        }

    }
    /// <summary>
    /// 读卡校验
    /// </summary>
    /// <returns></returns>
    private Boolean ReadCardValidation(TextBox text)
    {
        //对卡号进行非空、长度、数字检验 
        if (text.Text.Trim() == "")
            context.AddError("未输入卡号", txtCardno);
        else
        {
            if (Validation.strLen(text.Text.Trim()) != 16)
                context.AddError("卡号不是16位", text);
            else if (!Validation.isNum(text.Text.Trim()))
                context.AddError("卡号不是数字", text);
        }

        return !(context.hasError());

    }
    //读卡
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        DataTable dt = null;
        //社保卡号转电子钱包卡号
        if (txtCardno.Text.StartsWith("A"))
        {
            dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_CARDNO", txtCardno.Text);
            if (dt.Rows.Count > 0)
            {
                txtCardno.Text = dt.Rows[0]["CARDNO"].ToString();
            }
        }
        //对输入卡号进行检验
        if (!ReadCardValidation(txtCardno))
            return;
        dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_AWARDSHISTORY", txtCardno.Text);
        if (dt.Rows.Count > 0)
        {
            List<String> list = new List<string>();
            list.Add("NAME");
            list.Add("PAPERNO");
            list.Add("TEL");
            CommonHelper.AESDeEncrypt(dt, list);
           
        }
        else
        {
            context.AddError("该卡没有领奖记录");
        }
        gvResult.DataSource = dt;
        gvResult.DataBind();
    }
}