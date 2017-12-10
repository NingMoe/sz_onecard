using System;
using System.Data;
using System.Configuration;

using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using Master;
using PDO.GroupCard;
using TDO.BusinessCode;
using TM;
using System.Data.OleDb;
using System.IO;
/// <summary>
/// 订单帮助类

/// </summary>
public class OrderHelper
{
    public OrderHelper()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    public static void clearTempInfo(CmnContext context)
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_ORDER");
        context.DBCommit();
    }

    public static void WriteInfoIntoTempTable(CmnContext context, GridView gvCashGift,
        GridView gvChargeCard, GridView gvSZTCard, GridView gvLvYou, GridView gvInvoice,
        CheckBoxList chkPayTypeList, string sessionId)
    {
        clearTempInfo(context);
        context.DBOpen("Insert");
        //利金卡数据入临时表
        for (int i = 0; i < gvCashGift.Rows.Count; i++)
        {
            TextBox txtValue = (TextBox)gvCashGift.Rows[i].FindControl("txtCashGiftValue");
            TextBox txtNum = (TextBox)gvCashGift.Rows[i].FindControl("txtCashGiftNum");
            if (txtNum.Text.Trim().Length > 0 && txtValue.Text.Trim().Length > 0)
            {
                context.ExecuteNonQuery("insert into TMP_ORDER(F0, F1, F2, F3, F4) values('"
                        + sessionId + "', '0','" + Convert.ToDecimal(txtValue.Text.Trim()) * 100 + "','"
                        + txtNum.Text.Trim()
                        + "','" + Convert.ToDecimal(txtValue.Text.Trim()) * 100 * Convert.ToInt32(txtNum.Text.Trim())
                        + "')");
            }
        }
        //充值卡数据入临时表
        for (int i = 0; i < gvChargeCard.Rows.Count; i++)
        {
            DropDownList selChargeCardValue = (DropDownList)gvChargeCard.Rows[i].FindControl("selChargeCardValue");
            TextBox txtNum = (TextBox)gvChargeCard.Rows[i].FindControl("txtChargeCardNum");
            //TextBox txtFromCardNo = (TextBox)gvChargeCard.Rows[i].FindControl("txtFromCardNo");
            //TextBox txtToCardNo = (TextBox)gvChargeCard.Rows[i].FindControl("txtToCardNo");
            if (selChargeCardValue.SelectedValue != null && txtNum.Text.Trim().Length > 0)
            {
                string ChargeCardValue = selChargeCardValue.SelectedItem.ToString();
                context.ExecuteNonQuery("insert into TMP_ORDER(F0, F1, F2, F3, F4) values('"
                        + sessionId + "', '1','" + selChargeCardValue.SelectedValue
                        + "','" + txtNum.Text.Trim() + "','"
                        + Convert.ToDecimal(ChargeCardValue.Substring(2, ChargeCardValue.Length - 2)) * 100 * Convert.ToInt32(txtNum.Text.Trim()) + "')");
            }
        }
        //市民卡B卡数据入临时表
        for (int i = 0; i < gvSZTCard.Rows.Count; i++)
        {
            DropDownList selCardtype = (DropDownList)gvSZTCard.Rows[i].FindControl("selSZTCardtype");
            TextBox txtCardNum = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardNum");
            TextBox txtCardPrice = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardPrice");
            TextBox txtChargeMoney = (TextBox)gvSZTCard.Rows[i].FindControl("txtSZTCardChargeMoney");

            if (selCardtype.SelectedValue != null && txtCardNum.Text.Trim().Length > 0
                && txtCardPrice.Text.Trim().Length > 0 && txtChargeMoney.Text.Trim().Length > 0)
            {
                context.ExecuteNonQuery("insert into TMP_ORDER(F0, F1, F2, F3, F4, F5, F6) values('"
                        + sessionId + "', '2','" + selCardtype.SelectedValue + "','"
                        + txtCardNum.Text.Trim() + "','"
                        + Convert.ToDecimal(txtCardPrice.Text.Trim()) * 100 + "','"
                        + Convert.ToDecimal(txtChargeMoney.Text.Trim()) * 100 + "','"
                        + (Convert.ToDecimal(txtCardPrice.Text.Trim()) * 100 * Convert.ToInt32(txtCardNum.Text.Trim()) + Convert.ToDecimal(txtChargeMoney.Text.Trim()) * 100) + "')");
            }
        }

        //旅游卡数据入临时表
        for (int i = 0; i < gvLvYou.Rows.Count; i++)
        {
            TextBox txtCardNum = (TextBox)gvLvYou.Rows[i].FindControl("txtLvYouNum");
            TextBox txtCardPrice = (TextBox)gvLvYou.Rows[i].FindControl("txtLvYouPrice");
            TextBox txtChargeMoney = (TextBox)gvLvYou.Rows[i].FindControl("txtLvYouChargeMoney");

            if (txtCardNum.Text.Trim().Length > 0
                && txtCardPrice.Text.Trim().Length > 0 && txtChargeMoney.Text.Trim().Length > 0)
            {
                context.ExecuteNonQuery("insert into TMP_ORDER(F0, F1, F2, F3, F4, F5, F6) values('"
                        + sessionId + "', '5','5101','"
                        + txtCardNum.Text.Trim() + "','"
                        + Convert.ToDecimal(txtCardPrice.Text.Trim()) * 100 + "','"
                        + Convert.ToDecimal(txtChargeMoney.Text.Trim()) * 100 + "','"
                        + (Convert.ToDecimal(txtCardPrice.Text.Trim()) * 100 * Convert.ToInt32(txtCardNum.Text.Trim()) + Convert.ToDecimal(txtChargeMoney.Text.Trim()) * 100) + "')");
            }
        } 

        //发票数据入临时表
        for (int i = 0; i < gvInvoice.Rows.Count; i++)
        {
            DropDownList selInvoicetype = (DropDownList)gvInvoice.Rows[i].FindControl("selInvoicetype");
            //TextBox txtInvoiceNum = (TextBox)gvInvoice.Rows[i].FindControl("txtInvoiceNum");
            TextBox txtInvoiceMoney = (TextBox)gvInvoice.Rows[i].FindControl("txtInvoiceMoney");

            if (selInvoicetype.SelectedValue != null && txtInvoiceMoney.Text.Trim().Length > 0)
            {
                context.ExecuteNonQuery("insert into TMP_ORDER(F0, F1, F2, F3 ) values('"
                        + sessionId + "', '3','" + selInvoicetype.SelectedValue
                        + "','" + Convert.ToDecimal(txtInvoiceMoney.Text.Trim()) * 100 + "')");
            }
        }
        //for (int i = 0; i < chkInvoiceList.Items.Count; i++)
        //{
        //    if (chkInvoiceList.Items[i].Selected)
        //    {
        //        context.ExecuteNonQuery("insert into TMP_ORDER(F0, F1, F2, F3) values('"
        //                                              + sessionId + "', '3','" + chkInvoiceList.Items[i].Value
        //                                              + "','" + chkInvoiceList.Items[i].Text + "')");
        //    }
        //}

        for (int i = 0; i < chkPayTypeList.Items.Count; i++)
        {
            if (chkPayTypeList.Items[i].Selected)
            {
                context.ExecuteNonQuery("insert into TMP_ORDER(F0, F1, F2, F3) values('"
                                                      + sessionId + "', '4','" + chkPayTypeList.Items[i].Value
                                                      + "','" + chkPayTypeList.Items[i].Text + "')");
            }
        }

        if (!context.hasError())
        {
            context.DBCommit();
        }
        else
        {
            context.RollBack();
        }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="context">上下文</param>
    /// <param name="orderno">订单号</param>
    /// <param name="groupName">企业名称</param>
    /// <param name="name">联系人</param>
    /// <param name="phone">电话</param>
    /// <param name="idCardNo">身份证号</param>
    /// <param name="totalMoney">总金额</param>
    /// <param name="transactor">经办人</param>
    /// <param name="remark">备注</param>
    /// <param name="type">类型 1:显示财务审核文本框, 0:隐藏财务审核文本框</param>
    /// <param name="financeRemark">财务审核意见</param>
    /// <param name="totalCashGiftChargeMoney">礼金卡总充值金额</param>
    /// <param name="approver">财务审核人</param>
    /// <param name="customeraccmoney">专有账户总充值金额</param>
    /// <param name="getDept">领卡网点</param>
    /// <param name="getDate">领卡日期</param>
    /// <param name="tag1">是否需要显示已关联数量 </param>
    /// <param name="tag2">是否需要显示领卡网点 领卡日期 </param>
    /// <returns></returns>
    public static string GetOrderHtmlString(CmnContext context, string orderno, string groupName, string name, string phone,
        string idCardNo, string totalMoney, string transactor, string remark, string type, string financeRemark,
        string totalCashGiftChargeMoney, string approver, string customeraccmoney, string getDept, string getDate,
        bool tag1, bool tag2)
    {
        string[] htmls = GetCashGiftAndChargeCardAndSZTCardHtml(context, orderno, totalCashGiftChargeMoney, tag1);
        //string otherHtml = GetGCCardAndSztCardHtml(context, orderno, tag1);
        string invoicehtml = GetInvoiceHtml(context, orderno);
        string paytypehtml = GetPayType(context, orderno);
        string totalMoneyHtml = GetTotalMoneyHtml(totalMoney);
        string customerAccReaderGardenRelaxHtml = GetCustmerAccAndReaderAndGardenCardAndRelaxCardHtml(context, orderno, tag1);
        string financeRemarkHtml = "";
        if (type == "1")
        {
            financeRemarkHtml = "<textarea id='txt' height=50px style='width:96%' onblur='SetFinanceRemark();'></textarea>";
        }
        else
        {
            financeRemarkHtml = financeRemark;
        }
        string getDeptDateHeml = "";//领卡日期 领卡网点HTML脚本
        if (tag2)
        {
            getDeptDateHeml = string.Format(@"<tr height=23px>
                                                <td style='text-align:center'>领卡网点</td>
                                                <td> {0} </td>
                                                <td style='text-align:center'>领卡日期</td>
                                                <td colspan=3> {1} </td>
                                              </tr>", getDept, getDate);
        }
        //获取日期字符串
        string dateString = DateTime.Now.Year.ToString() + " 年 " + DateTime.Now.Month.ToString() + " 月 " + DateTime.Now.Day.ToString() + " 日";
        string html = string.Format(
                              @"<div style='font-weight:bold;text-align:center;'>
                                苏 州 市 民 卡 有 限 公 司 集 团 购 卡 申 领 单</div>
                                       <div align='left'>根据中国人民银行对第三方支付机构办理预付卡的要求，单位办理苏州通卡需提供以下信息：</div>
                                       <table border=1px cellpadding=0 cellspacing=0 width='100%' align='center' style='border-style:solid' class='data'>
                                             <tr height=23px>
                                                <td style='text-align:center;font-weight:bold'>单位名称</td>
                                                <td colspan='3'> {1} </td>
                                                <td style='text-align:center'>编号</td>
                                                <td>{0}</td>
                                             </tr>
                                             <tr height=23px>
                                                <td width='9%' style='text-align:center'>联系人</td>
                                                <td width='16%'> {2} </td>
                                                <td width='14%' style='text-align:center'>联系电话</td>
                                                <td width='16%'> {3} </td>
                                                <td width='10%' style='text-align:center'>身份证号</td>
                                                <td> {4} </td>
                                             </tr>
                                             <tr height=23px>
                                                 <td style='text-align:center'>业务类型</td>
                                                 <td colspan=5 style='margin:0px;padding:0px;border:0px;display:block;vertical-align:top'>
                                                     <table width='100%' cellspan=0 colspan=0 border=0 class='data' style='border-style:solid' border=1>
                                                            <tr>
                                                                <td width='20%' style='margin:0px;padding:0px;border:0px;display:block;vertical-align:top'> {5} </td>
                                                                <td width='20%' style='margin:0px;padding:0px;border:0px;display:block;vertical-align:top'> {6} </td>
                                                                <td style='margin:0px;padding:0px;border-top:0px;display:block;vertical-align:top' colspan=2> {7} </td>
                                                            </tr>                                                            
                                                            {16}
                                                     </table>
                                                 </td>
                                             </tr>
                                             <tr height=23px>
                                                <td style='text-align:center'>开票项目</td>
                                                <td colspan=4 style='margin:0px;padding:0px;border:0px;display:block;vertical-align:top'>
                                                    {8}
                                                </td>
                                                <td style='width:0px;border-top:0px;border-left:0px;border-bottom:0px'></td>
                                             </tr>
                                             <tr height=23px>
                                                <td style='text-align:center'>付款方式</td>
                                                <td colspan=5> {9} </td>
                                             </tr>
                                             <tr height=23px>
                                                <td style='text-align:center'>合计金额</td>
                                                <td colspan=5> {10} </td>
                                             </tr>
                                            {17}
                                             <tr height=23px>
                                                <td style='text-align:center'>备    注</td>
                                                <td colspan=5> {11} </td>
                                             </tr>
                                             <tr height=50px>
                                                <td style='text-align:center'>财务审批</td>
                                                <td colspan=4>{12}</td>
                                                <td style='text-align:center'>财务审批人:{15}</td>
                                             </tr>
                                       </table>
                                        <table cellspan=0 cellspace=0 border=0 width=100%>
                                            <tr><td align=left width='50%'></td><td align=center>经办人: {13}</td><td align=right>{14}</td></tr></table>",
                                       orderno, groupName, name, phone, idCardNo, htmls[0], htmls[1], htmls[2],
                                       invoicehtml, paytypehtml, totalMoneyHtml, remark, financeRemarkHtml, transactor,
                                       dateString, approver, customerAccReaderGardenRelaxHtml, getDeptDateHeml);
        return html;
    }

    //生成利金卡和充值卡的HTML脚本
    static private string[] GetCashGiftAndChargeCardAndSZTCardHtml(CmnContext context, string orderno, string totalCashGiftChargeMoney, bool tag1)
    {
        string[] htmls = new string[3];
        int cashgiftNum = 0;
        int chargecardNum = 0;
        int sztcardNum = 0;
        int count = 0;//利金卡、充值卡、市民卡B卡最大行数
        DataTable cashGiftData = GroupCardHelper.callOrderQuery(context, "CashOrderInfo", orderno);
        if (cashGiftData != null && cashGiftData.Rows.Count > 0)
        {
            cashgiftNum = cashGiftData.Rows.Count;
        }
        DataTable chargeCardData = GroupCardHelper.callOrderQuery(context, "ChargeCardOrderInfo", orderno);
        if (chargeCardData != null && chargeCardData.Rows.Count > 0)
        {
            chargecardNum = chargeCardData.Rows.Count;
        }

        DataTable sztData = GroupCardHelper.callOrderQuery(context, "ResidentCardInfo", orderno);
        if (sztData != null && sztData.Rows.Count > 0)
        {
            sztcardNum = sztData.Rows.Count;
        }

        count = cashgiftNum >= chargecardNum ? cashgiftNum : chargecardNum;
        count = sztcardNum >= count ? sztcardNum : count;

        //利金卡部分
        string cashgiftHtml = "<table width='100%' cellspan=0 colspan=0 border=0 class='data' style='border-style:solid;margin: 0px ;border:0px' border=1>";
        if (tag1)
        {
            cashgiftHtml += "<tr height=23px><td colspan=3 style='text-align:center;border-left:0px;border-top:0px'>利金卡</td></tr>";
            cashgiftHtml += "<tr height=23px><td style='text-align:center;border-left:0px'>面额</td><td style='text-align:center'>数量</td><td>已关联数</td></tr>";
        }
        else
        {
            cashgiftHtml += "<tr height=23px><td colspan=2 style='text-align:center;border-left:0px;border-top:0px'>利金卡</td></tr>";
            cashgiftHtml += "<tr height=23px><td style='text-align:center;border-left:0px'>面额</td><td style='text-align:center'>数量</td></tr>";
        }
        int cashgiftsum = 0;
        int bindNum = 0; //已关联数
        for (int i = 0; i < count; i++)
        {
            if (i > cashgiftNum - 1) //超出内容的行显示空格
            {
                if (tag1)
                {
                    cashgiftHtml += "<tr height=23px><td></td><td></td><td></td></tr>";
                }
                else
                {
                    cashgiftHtml += "<tr height=23px><td></td><td></td></tr>";
                }
            }
            else
            {
                if (tag1)
                {
                    bindNum = Convert.ToInt32(cashGiftData.Rows[i]["COUNT"].ToString()) - Convert.ToInt32(cashGiftData.Rows[i]["LEFTQTY"].ToString());
                    cashgiftHtml += "<tr height=23px><td style='text-align:center'>"
                                + (Convert.ToInt32(cashGiftData.Rows[i]["VALUE"].ToString()) / 100.0).ToString()
                                + "元</td><td style='text-align:center'>"
                                + cashGiftData.Rows[i]["COUNT"].ToString()
                                + "</td><td style='text-align:center'>"
                                + bindNum.ToString() + "</td></tr>";
                }
                else
                {
                    cashgiftHtml += "<tr height=23px><td style='text-align:center'>"
                                                    + (Convert.ToInt32(cashGiftData.Rows[i]["VALUE"].ToString()) / 100.0).ToString()
                                                    + "元</td><td style='text-align:center'>"
                                                    + cashGiftData.Rows[i]["COUNT"].ToString()
                                                    + "</td></tr>";
                }
                cashgiftsum += Convert.ToInt32(cashGiftData.Rows[i]["SUM"].ToString());
            }
        }
        if (cashgiftsum == 0)
        {
            cashgiftsum = totalCashGiftChargeMoney.Trim().Length > 0 ? (int)(Convert.ToDecimal(totalCashGiftChargeMoney.Trim()) * 100) : 0;
        }
        if (tag1)
        {
            cashgiftHtml += "<tr height=23px><td colspan=3 style='text-align:center;border-left:0px;border-bottom:0px'>小计&nbsp;￥" + (cashgiftsum / 100.0).ToString() + "元</td></tr>";
        }
        else
        {
            cashgiftHtml += "<tr height=23px><td colspan=2 style='text-align:center;border-left:0px;border-bottom:0px'>小计&nbsp;￥" + (cashgiftsum / 100.0).ToString() + "元</td></tr>";
        }
        cashgiftHtml += "</table>";
        htmls[0] = cashgiftHtml;

        //充值卡部分
        string chargecardHtml = "<table width='100%' cellspan=0 colspan=0 border=0 class='data' style='margin: 0px;border:0px'>";
        if (tag1)
        {
            chargecardHtml += "<tr height=23px><td colspan=3 style='text-align:center;border:0px;'>充值卡</td></tr>";
            chargecardHtml += "<tr height=23px><td style='text-align:center;border-left:0px'>面额</td><td style='text-align:center'>数量</td><td style='text-align:center;border-right:0px'>已关联数</td></tr>";
        }
        else
        {
            chargecardHtml += "<tr height=23px><td colspan=2 style='text-align:center;border:0px;'>充值卡</td></tr>";
            chargecardHtml += "<tr height=23px><td style='text-align:center;border-left:0px'>面额</td><td style='text-align:center;border-right:0px'>数量</td></tr>";
        }
        int chargecardsum = 0;

        for (int i = 0; i < count; i++)
        {
            if (i > chargecardNum - 1)
            {
                if (tag1)
                {
                    chargecardHtml += "<tr height=23px><td style='border-left:0px'></td><td></td><td style='border-right:0px'></td></tr>";
                }
                else
                {
                    chargecardHtml += "<tr height=23px><td style='border-left:0px'></td><td style='border-right:0px'></td></tr>";
                }
            }
            else
            {
                if (tag1)
                {
                    bindNum = Convert.ToInt32(chargeCardData.Rows[i]["COUNT"].ToString()) - Convert.ToInt32(chargeCardData.Rows[i]["LEFTQTY"].ToString());
                    chargecardHtml += "<tr height=23px><td style='text-align:center;border-left:0px'>"
                                + chargeCardData.Rows[i]["VALUENAME"].ToString()
                                + "</td><td style='text-align:center'>"
                                + chargeCardData.Rows[i]["COUNT"].ToString()
                                + "</td><td style='text-align:center;border-right:0px'>"
                                + bindNum.ToString() + "</td></tr>";
                }
                else
                {
                    chargecardHtml += "<tr height=23px><td style='text-align:center;border-left:0px'>"
                                                    + chargeCardData.Rows[i]["VALUENAME"].ToString()
                                                    + "</td><td style='text-align:center;border-right:0px'>"
                                                    + chargeCardData.Rows[i]["COUNT"].ToString()
                                                    + "</td></tr>";
                }
                chargecardsum += Convert.ToInt32(chargeCardData.Rows[i]["SUM"].ToString());
            }
        }
        if (tag1)
        {
            chargecardHtml += "<tr height=23px><td colspan=3 style='text-align:center;border-right:0px;border-left:0px;border-bottom:0px'>小计&nbsp;￥" + (chargecardsum / 100.0).ToString() + "元</td></tr>";
        }
        else
        {
            chargecardHtml += "<tr height=23px><td colspan=2 style='text-align:center;border-right:0px;border-left:0px;border-bottom:0px'>小计&nbsp;￥" + (chargecardsum / 100.0).ToString() + "元</td></tr>";
        }
        chargecardHtml += "</table>";
        htmls[1] = chargecardHtml;

        //市民卡B卡部分
        string cardtype = ""; //卡片类型
        string gcCount = "";   //数量
        string gcPrice = "";  //单价
        string gcTotalChargeMoney = "";//总充值金额
        string sztHtml = "";
        if (tag1)
        {
            sztHtml = @"<table width='100%' cellspan=0 colspan=0 border=0 class='data' style='margin: 0px;border:0px'>
                            <tr height=23px>
                                <td colspan=5 style='text-align:center;border:0px;'>市民卡B卡</td>
                            </tr>";
            sztHtml += "<tr height=23px><td style='text-align:center;border-left:0px'>卡类型</td><td style='text-align:center'>数量</td><td style='text-align:center'>卡单价</td><td style='text-align:center'>总充值金额</td><td style='text-align:center;border-right:0px'>已关联数</td></tr>";
        }
        else
        {
            sztHtml = @"<table width='100%' cellspan=0 colspan=0 border=0 class='data'>
                            <tr height=23px>
                                <td colspan=4 style='text-align:center;border:0px;'>市民卡B卡</td>
                            </tr>";
            sztHtml += "<tr height=23px><td style='text-align:center;border-left:0px'>卡类型</td><td style='text-align:center'>数量</td><td style='text-align:center'>卡单价</td><td style='text-align:center;border-right:0px'>总充值金额</td></tr>";
        }
        Decimal sum = 0;
        int hasMakeNum = 0;
        for (int i = 0; i < count; i++)
        {
            if (i > sztcardNum - 1)
            {
                if (tag1)
                {
                    sztHtml += "<tr height=23px><td style='border-left:0px'></td><td></td><td></td><td></td><td></td></tr>";
                }
                else
                {
                    sztHtml += "<tr height=23px><td style='border-left:0px'></td><td></td><td></td><td></td></tr>";
                }
            }
            else
            {
                cardtype = sztData.Rows[i]["CARDSURFACENAME"].ToString();
                gcCount = sztData.Rows[i]["COUNT"].ToString();
                gcPrice = sztData.Rows[i]["UNITPRICE"].ToString();
                gcTotalChargeMoney = sztData.Rows[i]["TOTALCHARGEMONEY"].ToString();
                sum += Convert.ToDecimal(sztData.Rows[i]["TOTALMONEY"].ToString());
                if (tag1)
                {
                    hasMakeNum = Convert.ToInt32(sztData.Rows[i]["COUNT"].ToString()) - Convert.ToInt32(sztData.Rows[i]["LEFTQTY"].ToString());
                    sztHtml += "<tr height=23px><td style='text-align:center;border-left:0px'>"
                        + cardtype + "</td><td style='text-align:center'>"
                        + gcCount + "</td><td style='text-align:center'>"
                        + gcPrice + "</td><td style='text-align:center'>"
                        + gcTotalChargeMoney + "</td><td style='text-align:center'>"
                        + hasMakeNum + "</td></tr>";
                }
                else
                {
                    sztHtml += "<tr height=23px><td style='text-align:center;border-left:0px'>"
                                           + cardtype + "</td><td style='text-align:center'>"
                                           + gcCount + "</td><td style='text-align:center'>"
                                           + gcPrice + "</td><td style='text-align:center'>"
                                           + gcTotalChargeMoney + "</td></tr>";
                }
            }
        }
        if (tag1)
        {
            sztHtml += "<tr height=23px><td colspan=5 style='text-align:center;border-left:0px;border-right:0px;border-bottom:0px'>小计&nbsp;￥" + sum + "元</td></tr>";
        }
        else
        {
            sztHtml += "<tr height=23px><td colspan=4 style='text-align:center;border-left:0px;border-right:0px;border-bottom:0px'>小计&nbsp;￥" + sum + "元</td></tr>";
        }
        sztHtml += "</table>";

        htmls[2] = sztHtml;

        return htmls;
    }


    // 生成市民卡B卡的HTML脚本
    //    static private string GetGCCardAndSztCardHtml(CmnContext context, string orderno, bool tag1)
    //    {
    //        //获取订单基本信息
    //        DataTable gcData = GroupCardHelper.callOrderQuery(context, "ResidentCardInfo", orderno);
    //        string cardtype = ""; //卡片类型
    //        string gcCount = "";   //数量
    //        string gcPrice = "";  //单价
    //        string gcTotalChargeMoney = "";//总充值金额
    //        string html = "";
    //        if (tag1)
    //        {
    //            html = @"<table width='100%' cellspan=0 colspan=0 border=0 class='data' style='margin: 0px;border:0px'>
    //                            <tr height=23px>
    //                                <td colspan=5 style='text-align:center;border:0px;'>市民卡B卡</td>
    //                            </tr>";
    //            html += "<tr height=23px><td style='text-align:center;border-left:0px'>卡类型</td><td style='text-align:center'>数量</td><td style='text-align:center'>卡单价</td><td style='text-align:center'>总充值金额</td><td style='text-align:center;border-right:0px'>已关联数</td></tr>";
    //        }
    //        else
    //        {
    //            html = @"<table width='100%' cellspan=0 colspan=0 border=0 class='data'>
    //                            <tr height=23px>
    //                                <td colspan=4 style='text-align:center;border:0px;'>市民卡B卡</td>
    //                            </tr>";
    //            html += "<tr height=23px><td style='text-align:center;border-left:0px'>卡类型</td><td style='text-align:center'>数量</td><td style='text-align:center'>卡单价</td><td style='text-align:center;border-right:0px'>总充值金额</td></tr>";
    //        }
    //        Int64 sum = 0;
    //        int bindNum = 0;
    //        if (gcData != null && gcData.Rows.Count > 0)
    //        {
    //            for (int i = 0; i < gcData.Rows.Count; i++)
    //            {
    //                cardtype = gcData.Rows[i]["CARDSURFACENAME"].ToString();
    //                gcCount = gcData.Rows[i]["COUNT"].ToString();
    //                gcPrice = gcData.Rows[i]["UNITPRICE"].ToString();
    //                gcTotalChargeMoney = gcData.Rows[i]["TOTALCHARGEMONEY"].ToString();
    //                sum += Convert.ToInt64(gcData.Rows[i]["TOTALMONEY"].ToString());
    //                if (tag1)
    //                {
    //                    bindNum = Convert.ToInt32(gcData.Rows[i]["COUNT"].ToString()) - Convert.ToInt32(gcData.Rows[i]["LEFTQTY"].ToString());
    //                    html += "<tr height=23px><td style='text-align:center'>"
    //                        + cardtype + "</td><td style='text-align:center'>"
    //                        + gcCount + "</td><td style='text-align:center'>"
    //                        + gcPrice + "</td><td style='text-align:center'>"
    //                        + gcTotalChargeMoney + "</td><td style='text-align:center'>"
    //                        + bindNum + "</td></tr>";
    //                }
    //                else
    //                {
    //                    html += "<tr height=23px><td style='text-align:center'>"
    //                                           + cardtype + "</td><td style='text-align:center'>"
    //                                           + gcCount + "</td><td style='text-align:center'>"
    //                                           + gcPrice + "</td><td style='text-align:center'>"
    //                                           + gcTotalChargeMoney + "</td></tr>";
    //                }
    //            }
    //        }
    //        if (tag1)
    //        {
    //            html += "<tr height=23px><td colspan=5 style='text-align:center;border-left:0px;border-right:0px'>小计&nbsp;￥" + sum + "元</td></tr>";
    //        }
    //        else
    //        {
    //            html += "<tr height=23px><td colspan=4 style='text-align:center;border-left:0px;border-right:0px'>小计&nbsp;￥" + sum + "元</td></tr>";
    //        }
    //        html += "</table>";
    //        return html;
    //    }

    static private string GetCustmerAccAndReaderAndGardenCardAndRelaxCardHtml(CmnContext context, string orderno, bool tag1)
    {
        string html = "";
        string customerAccTotalMoney = "0";
        string customerAccHasMoney = "";
        string rPrice = "";
        string rCount = "";
        string rHasqty = "";
        string rSum = "0";
        string gcCount = "";
        string gcPrice = "";
        string gcSum = "0";
        string rcCount = "";
        string rcPrice = "";
        string rcSum = "0";

        bool hasrow = false;//是否有订单信息

        //获取订单专有账户基本信息
        DataTable csaData = GroupCardHelper.callOrderQuery(context, "CustomerAccOrderInfo", orderno);
        if (csaData.Rows.Count > 0)
        {
            hasrow = true;
            customerAccTotalMoney = (Convert.ToInt32(csaData.Rows[0]["CUSTOMERACCMONEY"].ToString()) / 100.0).ToString();
            customerAccHasMoney = (Convert.ToInt32(csaData.Rows[0]["CUSTOMERACCHASMONEY"].ToString()) / 100.0).ToString();
        }

        //获取订单读卡器基本信息
        DataTable rData = GroupCardHelper.callOrderQuery(context, "ReaderOrderInfo", orderno);
        if (rData.Rows.Count > 0)
        {
            hasrow = true;
            rPrice = (Convert.ToInt32(rData.Rows[0]["VALUE"].ToString()) / 100.0).ToString();
            rCount = rData.Rows[0]["COUNT"].ToString();
            rHasqty = (Convert.ToInt32(rData.Rows[0]["COUNT"].ToString()) - Convert.ToInt32(rData.Rows[0]["LEFTQTY"].ToString())).ToString();
            rSum = (Convert.ToInt32(rData.Rows[0]["SUM"].ToString()) / 100.0).ToString();
        }

        //获取订单园林年卡基本信息
        DataTable gcData = GroupCardHelper.callOrderQuery(context, "GardenCardOrderInfo", orderno);
        if (gcData.Rows.Count > 0)
        {
            hasrow = true;
            gcCount = gcData.Rows[0]["COUNT"].ToString();
            gcPrice = (Convert.ToInt32(gcData.Rows[0]["VALUE"].ToString()) / 100.0).ToString();
            gcSum = (Convert.ToInt32(gcData.Rows[0]["SUM"].ToString()) / 100.0).ToString();
        }

        //获取订单休闲年卡基本信息
        DataTable rcData = GroupCardHelper.callOrderQuery(context, "RelaxCardOrderInfo", orderno);
        if (rcData.Rows.Count > 0)
        {
            hasrow = true;
            rcCount = rcData.Rows[0]["COUNT"].ToString();
            rcPrice = (Convert.ToInt32(rcData.Rows[0]["VALUE"].ToString()) / 100.0).ToString();
            rcSum = (Convert.ToInt32(rcData.Rows[0]["SUM"].ToString()) / 100.0).ToString();
        }

        string csahtml = "";
        string rhtml = "";
        string gchtml = "";
        string rchtml = "";
        if (!hasrow)
        {
            if (tag1)
            {
                csahtml = string.Format(@"<tr height=23px><td colspan=2 style='text-align:center;border-left:0px'>专有账户</td></tr>
					                  <tr height=23px><td style='text-align:center;border-left:0px'>总充值金额</td><td style='text-align:center'>已充值金额</td></tr>
					                  <tr height=23px><td colspan=2 style='text-align:center;border-left:0px'>小计&nbsp;0</td></tr>");
            }
            else
            {
                csahtml = string.Format(@"<tr height=23px><td style='text-align:center;border-left:0px'>专有账户</td></tr>
					                  <tr height=23px><td style='text-align:center;border-left:0px'>总充值金额</td></tr>
					                  <tr height=23px><td style='text-align:center;border-left:0px'>小计&nbsp;0</td></tr>");
            }

            if (tag1)
            {
                rhtml = string.Format(@"<tr height=23px><td colspan=3 style='text-align:center;border-left:0px'>读卡器</td></tr>
								    <tr height=23px><td style='text-align:center;border-left:0px'>数量</td><td style='text-align:center'>单价</td><td style='text-align:center'>已关联数</td></tr>
								    <tr height=23px><td colspan=3 style='text-align:center;border-left:0px'>小计&nbsp;0</td></tr>");
            }
            else
            {
                rhtml = string.Format(@"<tr height=23px><td colspan=2 style='text-align:center;border-left:0px'>读卡器</td></tr>
								    <tr height=23px><td style='text-align:center;border-left:0px'>数量</td><td style='text-align:center'>单价</td></tr>
								    <tr height=23px><td colspan=2 style='text-align:center;border-left:0px'>小计&nbsp;0</td></tr>");
            }

            gchtml = string.Format(@"<tr height=23px><td colspan=2 style='text-align:center;border-left:0px;border-top:0px'>园林年卡</td></tr>
							   	 <tr height=23px><td style='text-align:center;border-left:0px'>数量</td><td style='text-align:center'>单价</td></tr>
								 <tr height=23px><td colspan=2 style='text-align:center;border-left:0px'>小计&nbsp;0</td></tr>");


            rchtml = string.Format(@"<tr height=23px><td colspan=2 style='text-align:center;border-left:0px;border-top:0px'>休闲年卡</td></tr>
								 <tr height=23px><td style='text-align:center;border-left:0px'>数量</td><td style='text-align:center'>单价</td></tr>
								 <tr height=23px><td colspan=2 style='text-align:center;border-left:0px'>小计&nbsp;0</td></tr>");
        }
        else
        {
            if (tag1)
            {
                csahtml = string.Format(@"<tr height=23px><td colspan=2 style='text-align:center;border-left:0px'>专有账户</td></tr>
					                  <tr height=23px><td style='text-align:center;border-left:0px'>总充值金额</td><td style='text-align:center'>已充值金额</td></tr>
					                  <tr height=23px><td style='text-align:center;border-left:0px'>{0}</td><td style='text-align:center'>{1}</td></tr>
					                  <tr height=23px><td colspan=2 style='text-align:center;border-left:0px'>小计&nbsp;{0}</td></tr>", customerAccTotalMoney, customerAccHasMoney);
            }
            else
            {
                csahtml = string.Format(@"<tr height=23px><td style='text-align:center;border-left:0px'>专有账户</td></tr>
					                  <tr height=23px><td style='text-align:center;border-left:0px'>总充值金额</td></tr>
					                  <tr height=23px><td style='text-align:center;border-left:0px'>{0}</td></tr>
					                  <tr height=23px><td style='text-align:center;border-left:0px'>小计&nbsp;{0}</td></tr>", customerAccTotalMoney);
            }

            if (tag1)
            {
                rhtml = string.Format(@"<tr height=23px><td colspan=3 style='text-align:center;border-left:0px'>读卡器</td></tr>
								    <tr height=23px><td style='text-align:center;border-left:0px'>数量</td><td style='text-align:center'>单价</td><td style='text-align:center'>已关联数</td></tr>
								    <tr height=23px><td style='text-align:center;border-left:0px'>{0}</td><td style='text-align:center'>{1}</td><td style='text-align:center'>{2}</td></tr>
								    <tr height=23px><td colspan=3 style='text-align:center;border-left:0px'>小计&nbsp;{3}</td></tr>", rCount, rPrice, rHasqty, rSum);
            }
            else
            {
                rhtml = string.Format(@"<tr height=23px><td colspan=2 style='text-align:center;border-left:0px'>读卡器</td></tr>
								    <tr height=23px><td style='text-align:center;border-left:0px'>数量</td><td style='text-align:center'>单价</td></tr>
								    <tr height=23px><td style='text-align:center;border-left:0px'>{0}</td><td style='text-align:center'>{1}</td></tr>
								    <tr height=23px><td colspan=2 style='text-align:center;border-left:0px'>小计&nbsp;{2}</td></tr>", rCount, rPrice, rSum);
            }

            gchtml = string.Format(@"<tr height=23px><td colspan=2 style='text-align:center;border-left:0px;border-top:0px'>园林年卡</td></tr>
							   	 <tr height=23px><td style='text-align:center;border-left:0px'>数量</td><td style='text-align:center'>单价</td></tr>
								 <tr height=23px><td style='text-align:center;border-left:0px'>{0}</td><td style='text-align:center'>{1}</td></tr>
								 <tr height=23px><td colspan=2 style='text-align:center;border-left:0px'>小计&nbsp;{2}</td></tr>", gcCount, gcPrice, gcSum);


            rchtml = string.Format(@"<tr height=23px><td colspan=2 style='text-align:center;border-left:0px;border-top:0px'>休闲年卡</td></tr>
								 <tr height=23px><td style='text-align:center;border-left:0px'>数量</td><td style='text-align:center'>单价</td></tr>
								 <tr height=23px><td style='text-align:center;border-left:0px'>{0}</td><td style='text-align:center'>{1}</td></tr>
								 <tr height=23px><td colspan=2 style='text-align:center;border-left:0px'>小计&nbsp;{2}</td></tr>", rcCount, rcPrice, rcSum);
        }
        html = string.Format(@"<tr>
						        <td width='20%' style='margin:0px;padding:0px;border:0px;display:block;vertical-align:top'> 
							        <table width='100%' cellspan=0 colspan=0 border=0 class='data'>
								        {0}
							        </table>
						        </td>
						        <td width='20%' style='margin:0px;padding:0px;border:0px;display:block;vertical-align:top'> 
							        <table width='100%' cellspan=0 colspan=0 border=0 class='data'>
                                        {1}
							        </table>	
						        </td>
						        <td width='20%' style='margin:0px;padding:0px;border:0px;display:block;vertical-align:top'> 
							        <table width='100%' cellspan=0 colspan=0 border=0 class='data'>
                                        {2}
							        </table>
						        </td>
						        <td width='20%' style='margin:0px;padding:0px;border:0px;display:block;vertical-align:top'> 
							        <table width='100%' cellspan=0 colspan=0 border=0 class='data'>
								        {3}
							        </table>
						        </td>
					        </tr>", csahtml, rhtml, gchtml, rchtml);
        return html;
    }

    static private string GetInvoiceHtml(CmnContext context, string orderno)
    {
        string html = @"<table width='81.3%' cellspan=0 colspan=0 border=0 class='data'style='border:0px'>
                            <tr height=23px>
                                <td colspan=2 style='text-align:center;border-top:0px;border-left:0px'>开票项目</td>
                            </tr>";
        html += "<tr height=23px><td width='50%' style='text-align:center;border-left:0px'>开票类型</td><td width='50%' style='text-align:center'>开票金额</td></tr>";
        string invoicetype = "";
        //string invoicecount = "";
        string invoicemoney = "";
        //获取开票信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "InvoiceOrderInfo", orderno);
        if (data != null && data.Rows.Count > 0)
        {
            for (int i = 0; i < data.Rows.Count; i++)
            {
                invoicetype = data.Rows[i]["INVOICETYPENAME"].ToString();
                //invoicecount = data.Rows[i]["INVOICENUM"].ToString();
                invoicemoney = data.Rows[i]["INVOICEMONEY"].ToString();
                html += "<tr height=23px><td style='text-align:center;border-bottom:0px;border-left:0px'>" + invoicetype + "</td><td style='text-align:center;border-bottom:0px'>" + invoicemoney + "</td></tr>";
            }
        }
        html += "</table>";
        return html;
    }

    static private string GetPayType(CmnContext context, string orderno)
    {
        string chk1 = "", chk2 = "", chk3 = "", chk4 = "", chk5 = "";
        //获取支付方式信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "PayTypeOrderInfo", orderno);
        if (data != null && data.Rows.Count > 0)
        {
            for (int i = 0; i < data.Rows.Count; i++)
            {
                switch (Convert.ToInt32(data.Rows[i]["PAYTYPECODE"]))
                {
                    case 0:
                        chk1 = "checked = true";
                        break;
                    case 1:
                        chk2 = "checked = true";
                        break;
                    case 2:
                        chk3 = "checked = true";
                        break;
                    case 3:
                        chk4 = "checked = true";
                        break;
                    case 4:
                        chk5 = "checked = true";
                        break;
                    default:
                        break;

                }
            }
        }
        string html = @"支/本票<input type=checkbox  " + chk1 + @"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        转帐<input type=checkbox " + chk2 + @"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        现金<input type=checkbox " + chk3 + @"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        刷卡<input type=checkbox " + chk4 + @"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        呈批单<input type=checkbox " + chk5 + @"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
        return html;
    }

    /// <summary>
    /// 将金额按照 万  仟  佰  拾  元  角  分 的格式输出

    /// </summary>
    /// <param name="totalMoney"></param>
    /// <returns></returns>
    static private string GetTotalMoneyHtml(string totalMoney)
    {
        string html = "";
        if (!totalMoney.Contains("."))
        {
            totalMoney += ".00";
        }

        string[] money = totalMoney.Split('.');
        for (int index = money[0].Length - 1; index >= 0; index--)
        {
            if (index == money[0].Length - 1) //个位
            {
                html += GetCapMoney(money[0][money[0].Length - 1].ToString()) + "&nbsp;元&nbsp;";
            }
            else if (index == money[0].Length - 2) //十位
            {
                html = GetCapMoney(money[0][money[0].Length - 2].ToString()) + "&nbsp;拾&nbsp;" + html;
            }
            else if (index == money[0].Length - 3) //百位
            {
                html = GetCapMoney(money[0][money[0].Length - 3].ToString()) + "&nbsp;佰&nbsp;" + html;
            }
            else if (index == money[0].Length - 4) //千位
            {
                html = GetCapMoney(money[0][money[0].Length - 4].ToString()) + "&nbsp;仟&nbsp;" + html;
            }
            else if (index == money[0].Length - 5) //万位
            {
                html = GetCapMoney(money[0][money[0].Length - 5].ToString()) + "&nbsp;万&nbsp;" + html;
            }
            else if (index == money[0].Length - 6) //十万位
            {
                html = GetCapMoney(money[0][money[0].Length - 6].ToString()) + "&nbsp;拾&nbsp;" + html;
            }
            else if (index == money[0].Length - 7) //百万位
            {
                html = GetCapMoney(money[0][money[0].Length - 7].ToString()) + "&nbsp;佰&nbsp;" + html;
            }
            else if (index == money[0].Length - 8) //千万位
            {
                html = GetCapMoney(money[0][money[0].Length - 8].ToString()) + "&nbsp;仟&nbsp;" + html;
            }
        }
        html = html + GetCapMoney(money[1][0].ToString()) + "&nbsp;角&nbsp;" + GetCapMoney(money[1][1].ToString()) + "&nbsp;分&nbsp;";
        html = html + "&nbsp;&nbsp;&nbsp;&nbsp;￥" + totalMoney + "元";
        return html;
    }

    static private string GetCapMoney(string money)
    {
        string[] capMoney = new string[10] { "零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖" };
        int index = Convert.ToInt32(money.ToString());
        return capMoney[index];
    }
    /// <summary>
    /// 创建注释
    /// 创建标识：石磊 2013-03-22
    /// 方法描述：从通用编码表中初始化订单状态
    /// 使用的表：
    /// 使用的视图：
    /// 使用的存储过程：SP_RM_Query
    /// </summary>
    /// <param name="context">上下文环境</param>
    /// <param name="ddl">下拉选框</param>
    /// <param name="empty">是否附加空选项---请选择---，true附加，false不附加</param>
    /// <returns></returns>
    public static void selOrderState(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "InitOrderState");
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("初始化订单状态失败");
        }
    }
    /// <summary>
    /// 创建注释
    /// 创建标识：石磊 2012-07-20
    /// 方法描述：查询并为下拉选框赋值
    /// 使用的表：
    /// 使用的视图：
    /// 使用的存储过程：SP_RM_Query
    /// </summary>
    /// <param name="context">上下文环境</param>
    /// <param name="ddl">待赋值的下拉选框</param>
    /// <param name="funcCode">存储过程功能编码</param>
    /// <param name="vars">存储过程参数</param>
    /// <returns></returns>
    public static void select(CmnContext context, DropDownList ddl, string funcCode, params string[] vars)
    {
        SP_GC_OrderQueryPDO pdo = new SP_GC_OrderQueryPDO();
        pdo.funcCode = funcCode;
        int varNum = 0;
        foreach (string var in vars)
        {
            switch (++varNum)
            {
                case 1:
                    pdo.var1 = var;
                    break;
                case 2:
                    pdo.var2 = var;
                    break;
                case 3:
                    pdo.var3 = var;
                    break;
                case 4:
                    pdo.var4 = var;
                    break;
                case 5:
                    pdo.var5 = var;
                    break;
                case 6:
                    pdo.var6 = var;
                    break;
                case 7:
                    pdo.var7 = var;
                    break;
                case 8:
                    pdo.var8 = var;
                    break;
                case 9:
                    pdo.var9 = var;
                    break;
            }
        }

        StoreProScene storePro = new StoreProScene();

        DataTable dataTable = storePro.Execute(context, pdo);
        if (dataTable.Rows.Count == 0)
        {
            return;
        }

        Object[] itemArray;
        ListItem li;
        for (int i = 0; i < dataTable.Rows.Count; ++i)
        {
            itemArray = dataTable.Rows[i].ItemArray;
            li = new ListItem("" + itemArray[1] + ":" + itemArray[0], itemArray[1].ToString());
            ddl.Items.Add(li);
        }
    }
    /// <summary>
    /// 查询单位全称
    /// </summary>
    /// <param name="txtCompanyPar"></param>
    /// <param name="selCompanyPar"></param>
    public static void queryCompany(CmnContext context, TextBox txtCompanyPar, DropDownList selCompanyPar)
    {
        //模糊查询单位名称，并在列表中赋值

        string name = txtCompanyPar.Text.Trim();
        if (name == "")
        {
            selCompanyPar.Items.Clear();
            return;
        }
        TMTableModule tm = new TMTableModule();
        TD_M_BUYCARDCOMINFOTDO tdoTD_M_BUYCARDCOMINFOIn = new TD_M_BUYCARDCOMINFOTDO();
        TD_M_BUYCARDCOMINFOTDO[] tdoTD_M_BUYCARDCOMINFOOutArr = null;
        tdoTD_M_BUYCARDCOMINFOIn.COMPANYNAME = "%" + name + "%";
        tdoTD_M_BUYCARDCOMINFOOutArr = (TD_M_BUYCARDCOMINFOTDO[])tm.selByPKArr(context, tdoTD_M_BUYCARDCOMINFOIn, typeof(TD_M_BUYCARDCOMINFOTDO), null, "TD_M_BUYCARDCOMINFO_NAME", null);

        selCompanyPar.Items.Clear();
        if (tdoTD_M_BUYCARDCOMINFOOutArr.Length > 0)
        {
            selCompanyPar.Items.Add(new ListItem("---请选择---", ""));
        }
        foreach (TD_M_BUYCARDCOMINFOTDO ddoComInfo in tdoTD_M_BUYCARDCOMINFOOutArr)
        {
            selCompanyPar.Items.Add(new ListItem(ddoComInfo.COMPANYNAME, ddoComInfo.COMPANYNO));
        }
    }

    public static DataTable getExcel_info(string filePath)
    {
        DataTable dt = new DataTable();
        string connStr = "";
        string extension = Path.GetExtension(filePath);
        switch (extension)
        {
            case ".xls":
                connStr = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties='Excel 8.0;HDR=Yes;IMEX=1;'";
                break;
            case ".xlsx":
                connStr = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + filePath + ";Extended Properties='Excel 12.0;HDR=Yes;IMEX=1;'";
                break;
            default:
                connStr = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties='Excel 8.0;HDR=Yes;IMEX=1;'";
                break;
        }

        // string connStr = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties=\"Excel 8.0;HDR=YES\";";
        OleDbConnection oleconn = new OleDbConnection(connStr);
        try
        {
            oleconn.Open();
            DataTable dt1 = oleconn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, new object[] { null, null, null, "TABLE" });
            if (dt1.Rows.Count > 0)
            {
                string sheet_str = dt1.Rows[0]["TABLE_NAME"].ToString();
                string selStr = "SELECT * FROM [" + sheet_str + "]";
                try
                {
                    OleDbCommand olecommand = new OleDbCommand(selStr, oleconn);
                    OleDbDataAdapter adapterin = new OleDbDataAdapter(olecommand);
                    adapterin.Fill(dt);
                }
                catch (Exception ex)
                {
                    throw ex;
                }
            }
        }
        catch
        {

        }
        finally
        {
            oleconn.Close();
        }
        return dt;
    }

    public static void fillAccountList(CmnContext context, GridView gvResult, string sessId)
    {
        // 首先清空临时表

        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON " +
            " where F10 = '" + sessId + "'");

        // 根据页面数据生成临时表数据

        int count = 0;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                string f3 = gvr.Cells[3].Text == "&nbsp;" ? "" : gvr.Cells[3].Text;
                string f4 = gvr.Cells[4].Text == "&nbsp;" ? "" : gvr.Cells[4].Text;
                string f5 = gvr.Cells[5].Text == "&nbsp;" ? "" : gvr.Cells[5].Text;
                string f6 = gvr.Cells[6].Text == "&nbsp;" ? "" : gvr.Cells[6].Text;
                string f7 = gvr.Cells[7].Text == "&nbsp;" ? "" : gvr.Cells[7].Text;
                string f8 = gvr.Cells[8].Text == "&nbsp;" ? "" : gvr.Cells[8].Text;
                string f9 = gvr.Cells[9].Text == "&nbsp;" ? "" : gvr.Cells[9].Text;
                string f10 = gvr.Cells[10].Text == "&nbsp;" ? "" : gvr.Cells[10].Text;

                context.ExecuteNonQuery("insert into TMP_COMMON (F0,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10) values('"
                + gvr.Cells[1].Text.Trim() + "','"
                + gvr.Cells[2].Text.Trim() + "','"
                + f3 + "','"
                + f4 + "','"
                + f5 + "','"
                + f6 + "','"
                + f7 + "','"
                + f8 + "','"
                + f9 + "','"
                + f10 + "','" + sessId + "')");
            }
        }
        context.DBCommit();

        // 没有选中任何行，则返回错误

        if (count <= 0)
        {
            context.AddError("A004P03R01: 没有选中任何行");
        }
    }
    #region 旧打印格式
    public static string GetOrderHtmlString(CmnContext context, string orderno, string groupName, string name, string phone,
        string idCardNo, string totalMoney, string transactor, string remark, string type, string financeRemark,
        string invoiceCount, string invoiceTotalMoney, string totalCashGiftChargeMoney, string approver)
    {
        string[] htmls = GetCashGiftAndChargeCardHtml(context, orderno, totalCashGiftChargeMoney);
        string otherHtml = GetGCCardAndSztCardHtml(context, orderno);
        string invoicehtml = GetInvoiceHtml(context, orderno, invoiceCount, invoiceTotalMoney);
        string paytypehtml = GetPayType(context, orderno);
        string totalMoneyHtml = GetTotalMoneyHtml(totalMoney);

        string financeRemarkHtml = "";
        if (type == "1")
        {
            financeRemarkHtml = "<textarea id='txt' height=50px style='width:96%' onblur='SetFinanceRemark();'></textarea>";
        }//<textarea 
        else
        {
            financeRemarkHtml = financeRemark;//<div align=right>{14}</div>  <div style='text-align:right;'>编号: {0}</div>
        }
        //获取日期字符串

        string dateString = DateTime.Now.Year.ToString() + " 年 " + DateTime.Now.Month.ToString() + " 月 " + DateTime.Now.Day.ToString() + " 日";

        string html = string.Format(
                              @"<div style='font-weight:bold;text-align:center;'>
                                苏 州 市 民 卡 有 限 公 司 集 团 购 卡 申 领 单</div>
                                       <div align='left'>根据中国人民银行对第三方支付机构办理预付卡的要求，单位办理苏州通卡需提供以下信息：</div>
                                       <table border=1px cellpadding=0 cellspacing=0 width='100%' align='center' style='border-style:solid' class='data'>
                                             <tr height=23px>
                                                <td style='text-align:center;font-weight:bold'>单位名称</td>
                                                <td colspan='3'> {1} </td>
                                                <td style='text-align:center'>编号</td>
                                                <td>{0}</td>
                                             </tr>
                                             <tr height=23px>
                                                <td width='9%' style='text-align:center'>联系人</td>
                                                <td width='16%'> {2} </td>
                                                <td width='14%' style='text-align:center'>联系电话</td>
                                                <td width='16%'> {3} </td>
                                                <td width='10%' style='text-align:center'>身份证号</td>
                                                <td> {4} </td>
                                             </tr>
                                             <tr height=23px>
                                                 <td style='text-align:center'>业务类型</td>
                                                 <td style='margin:0px;padding:0px;border:1px;display:block;vertical-align:top'> {5} </td>
                                                 <td colspan=3 style='margin:0px;padding:0px;border:1px;display:block;vertical-align:top'> {6} </td>
                                                 <td style='margin:0px;padding:0px;display:block;vertical-align:top'> {7} </td>
                                             </tr>
                                             <tr height=23px>
                                                <td style='text-align:center'>开票项目</td>
                                                <td colspan=5>&nbsp; {8} </td>
                                             </tr>
                                             <tr height=23px>
                                                <td style='text-align:center'>付款方式</td>
                                                <td colspan=5> {9} </td>
                                             </tr>
                                             <tr height=23px>
                                                <td style='text-align:center'>合计金额</td>
                                                <td colspan=5> {10} </td>
                                             </tr>
                                             <tr height=23px>
                                                <td style='text-align:center'>备    注</td>
                                                <td colspan=5> {11} </td>
                                             </tr>
                                             <tr height=50px>
                                                <td style='text-align:center'>财务审批</td>
                                                <td colspan=4>{12}</td>
                                                <td style='text-align:center'>财务审批人:{15}</td>
                                             </tr>
                                       </table>
                                        <table cellspan=0 cellspace=0 border=0 width=100%>
                                            <tr><td align=left width='50%'></td><td align=center>经办人: {13}</td><td align=right>{14}</td></tr></table>",
                                       orderno, groupName, name, phone, idCardNo, htmls[0], htmls[1], otherHtml,
                                       invoicehtml, paytypehtml, totalMoneyHtml, remark, financeRemarkHtml, transactor, dateString, approver);
        return html;
    }

    //生成利金卡和充值卡的HTML脚本
    static private string[] GetCashGiftAndChargeCardHtml(CmnContext context, string orderno, string totalCashGiftChargeMoney)
    {
        string[] htmls = new string[2];
        int cashgiftNum = 0;
        int chargecardNum = 0;
        int count = 0;
        DataTable cashGiftData = GroupCardHelper.callOrderQuery(context, "CashOrderInfo", orderno);
        if (cashGiftData != null && cashGiftData.Rows.Count > 0)
        {
            cashgiftNum = cashGiftData.Rows.Count;
        }
        DataTable chargeCardData = GroupCardHelper.callOrderQuery(context, "ChargeCardOrderInfo", orderno);
        if (chargeCardData != null && chargeCardData.Rows.Count > 0)
        {
            chargecardNum = chargeCardData.Rows.Count;
        }
        count = (cashgiftNum >= chargecardNum ? cashgiftNum : chargecardNum);
        string cashgift = "<table width='100%' cellspan=0 colspan=0 border=0 class='data' style='border-style:solid' border=1>";
        cashgift += "<tr height=23px><td colspan=2 style='text-align:center'>利金卡</td></tr>";
        cashgift += "<tr height=23px><td style='text-align:center'>面额</td><td style='text-align:center'>数量</td></tr>";
        int cashgiftsum = 0;
        if (cashGiftData != null && cashGiftData.Rows.Count > 0)
        {
            for (int i = 0; i < count; i++)
            {
                if (i > cashGiftData.Rows.Count - 1) //超出内容的行显示空格
                {
                    cashgift += "<tr height=23px><td></td><td></td></tr>";
                }
                else
                {
                    cashgift += "<tr height=23px><td style='text-align:center'>"
                             + (Convert.ToInt32(cashGiftData.Rows[i]["VALUE"].ToString()) / 100.0).ToString()
                             + "元</td><td style='text-align:center'>"
                             + cashGiftData.Rows[i]["COUNT"].ToString() + "</td></tr>";
                    cashgiftsum += Convert.ToInt32(cashGiftData.Rows[i]["SUM"].ToString());
                }
            }
        }
        if (cashgiftsum == 0)
        {
            cashgiftsum = totalCashGiftChargeMoney.Trim().Length > 0 ? (int)(Convert.ToDecimal(totalCashGiftChargeMoney.Trim()) * 100) : 0;
        }
        //cashgift += "<tr height=23px><td colspan=2 style='text-align:center'>总金额&nbsp;￥" + totalCashGiftChargeMoney + "元</td></tr>";
        cashgift += "<tr height=23px><td colspan=2 style='text-align:center'>小计&nbsp;￥" + (cashgiftsum / 100.0).ToString() + "</td></tr>";
        cashgift += "</table>";
        htmls[0] = cashgift;
        string chargecard = "<table width='100%' cellspan=0 colspan=0 border=0 class='data'>";
        chargecard += "<tr height=23px><td colspan=3 style='text-align:center'>充值卡</td></tr>";
        chargecard += "<tr height=23px><td style='text-align:center'>面额</td><td style='text-align:center'>数量</td><td style='text-align:center'>充值卡卡号</td></tr>";
        int chargecardsum = 0;
        if (chargeCardData != null && chargeCardData.Rows.Count > 0)
        {
            for (int i = 0; i < count; i++)
            {
                if (i > chargeCardData.Rows.Count - 1)
                {
                    chargecard += "<tr height=23px><td></td><td></td><td></td></tr>";
                }
                else
                {
                    chargecard += "<tr height=23px><td style='text-align:center'>"
                             + (Convert.ToInt32(chargeCardData.Rows[i]["VALUE"].ToString()) / 100.0).ToString()
                             + "元</td><td style='text-align:center'>"
                             + chargeCardData.Rows[i]["COUNT"].ToString() + "</td><td style='text-align:center'>"
                             + chargeCardData.Rows[i]["FROMCARDNO"].ToString() + " - " + chargeCardData.Rows[i]["TOCARDNO"].ToString() + "</td></tr>";
                    chargecardsum += Convert.ToInt32(chargeCardData.Rows[i]["SUM"].ToString());
                }
            }
        }

        chargecard += "<tr height=23px><td colspan=3 style='text-align:center'>小计&nbsp;￥" + (chargecardsum / 100.0).ToString() + "</td></tr>";
        chargecard += "</table>";
        htmls[1] = chargecard;
        return htmls;
    }


    // 生成企服卡和普通苏州通卡的HTML脚本
    static private string GetGCCardAndSztCardHtml(CmnContext context, string orderno)
    {
        //获取订单基本信息
        DataTable gcData = GroupCardHelper.callOrderQuery(context, "OrderInfoOld", orderno);
        string gcCount = gcData.Rows[0]["GCCOUNT"].ToString(); //企服卡数量

        string gcPrice = (Convert.ToInt32(gcData.Rows[0]["GCUNITPRICE"].ToString()) / 100.0).ToString(); //企服卡单价

        string gcTotalChargeMoney = (Convert.ToInt32(gcData.Rows[0]["GCTOTALCHARGEMONEY"].ToString()) / 100.0).ToString();
        string html = @"<table width='100%' cellspan=0 colspan=0 border=0 class='data'>
                            <tr height=23px>
                                <td></td>
                                <td style='text-align:center'>企服卡</td>
                                <td style='text-align:center'>市民卡B卡</td>
                                <td style='text-align:center'>市民卡B卡</td>
                            </tr>";
        int sum = 0;
        //获取卡片类型
        html += "<tr height=23px><td style='text-align:center'>卡片类型</td>";

        html += "<td style='text-align:center'>企服卡</td>";

        DataTable sztData = GroupCardHelper.callOrderQuery(context, "SZTCardOrderInfo", orderno);
        if (sztData != null && sztData.Rows.Count > 0)
        {
            for (int i = 0; i < sztData.Rows.Count; i++)
            {
                if (i == 0)
                {
                    html += "<td style='text-align:center'>" + sztData.Rows[i]["CARDTYPE"].ToString() + "</td>";
                }
                if (i == 1)
                {
                    html += "<td style='text-align:center'>" + sztData.Rows[i]["CARDTYPE"].ToString() + "</td>";
                }
            }
        }
        if (sztData != null && sztData.Rows.Count == 1) //如果只有一行 补充一个单元格
        {
            html += "<td style='text-align:center'></td>";
        }
        if (sztData == null || sztData.Rows.Count < 1)  //如果没有数据，补充两个单元格
        {
            html += "<td style='text-align:center'></td>";
            html += "<td style='text-align:center'></td>";
        }
        html += "</tr>";
        //获取卡片数量
        html += "<tr height=23px><td style='text-align:center'>卡片数量</td>";

        html += "<td style='text-align:center'>" + gcCount + "</td>";

        int szt1Count = 0;
        int szt2Count = 0;
        if (sztData != null && sztData.Rows.Count > 0)
        {
            for (int i = 0; i < sztData.Rows.Count; i++)
            {
                if (i == 0)
                {
                    html += "<td style='text-align:center'>" + sztData.Rows[i]["COUNT"].ToString() + "</td>";
                    szt1Count = Convert.ToInt32(sztData.Rows[i]["COUNT"].ToString());
                }
                if (i == 1)
                {
                    html += "<td style='text-align:center'>" + sztData.Rows[i]["COUNT"].ToString() + "</td>";
                    szt2Count = Convert.ToInt32(sztData.Rows[i]["COUNT"].ToString());
                }
            }
        }
        if (sztData != null && sztData.Rows.Count == 1) //如果只有一行 补充一个单元格
        {
            html += "<td style='text-align:center'></td>";
        }
        if (sztData == null || sztData.Rows.Count < 1)  //如果没有数据，补充两个单元格
        {
            html += "<td style='text-align:center'></td>";
            html += "<td style='text-align:center'></td>";
        }
        html += "</tr>";
        //获取卡片工本费

        html += "<tr height=23px><td style='text-align:center'>卡片工本费</td>";

        html += "<td style='text-align:center'>" + gcPrice + "</td>";

        int szt1Price = 0;
        int szt2Price = 0;
        if (sztData != null && sztData.Rows.Count > 0)
        {
            for (int i = 0; i < sztData.Rows.Count; i++)
            {
                if (i == 0)
                {
                    html += "<td style='text-align:center'>" + (Convert.ToInt32(sztData.Rows[i]["UNITPRICE"].ToString()) / 100.0).ToString() + "</td>";
                    szt1Price = Convert.ToInt32(sztData.Rows[i]["UNITPRICE"].ToString());
                }
                if (i == 1)
                {
                    html += "<td style='text-align:center'>" + (Convert.ToInt32(sztData.Rows[i]["UNITPRICE"].ToString()) / 100.0).ToString() + "</td>";
                    szt2Price = Convert.ToInt32(sztData.Rows[i]["UNITPRICE"].ToString());
                }
            }
        }
        if (sztData != null && sztData.Rows.Count == 1)
        {
            html += "<td style='text-align:center'></td>";
        }
        if (sztData == null || sztData.Rows.Count < 1)
        {
            html += "<td style='text-align:center'></td>";
            html += "<td style='text-align:center'></td>";
        }
        html += "</tr>";
        //获取总充值金额

        html += "<tr height=23px><td style='text-align:center'>总充值金额</td>";

        html += "<td style='text-align:center'>" + gcTotalChargeMoney + "</td>";

        int szt1TotalChargeMoney = 0;
        int szt2TotalChargeMoney = 0;
        if (sztData != null && sztData.Rows.Count > 0)
        {
            for (int i = 0; i < sztData.Rows.Count; i++)
            {
                if (i == 0)
                {
                    html += "<td style='text-align:center'>" + (Convert.ToInt32(sztData.Rows[i]["TOTALCHARGEMONEY"].ToString()) / 100.0).ToString() + "</td>";
                    szt1TotalChargeMoney = Convert.ToInt32(sztData.Rows[i]["TOTALCHARGEMONEY"].ToString());

                }
                if (i == 1)
                {
                    html += "<td style='text-align:center'>" + (Convert.ToInt32(sztData.Rows[i]["TOTALCHARGEMONEY"].ToString()) / 100.0).ToString() + "</td>";
                    szt2TotalChargeMoney = Convert.ToInt32(sztData.Rows[i]["TOTALCHARGEMONEY"].ToString());
                }
            }
        }
        if (sztData != null && sztData.Rows.Count == 1)
        {
            html += "<td style='text-align:center'></td>";
        }
        if (sztData == null || sztData.Rows.Count < 1)
        {
            html += "<td style='text-align:center'></td>";
            html += "<td style='text-align:center'></td>";
        }
        html += "</tr>";
        sum = (Convert.ToInt32(gcCount) * (int)(Convert.ToDecimal(gcPrice) * 100) + (int)(Convert.ToDecimal(gcTotalChargeMoney) * 100))
            + (szt1Count * szt1Price + szt1TotalChargeMoney)
            + (szt2Count * szt2Price + szt2TotalChargeMoney);

        html += "<tr height=23px><td colspan=4 style='text-align:center'>小计&nbsp;￥" + sum / 100.0 + "</td></tr>";
        html += "</table>";
        return html;
    }

    static private string GetInvoiceHtml(CmnContext context, string orderno, string invoiceCount, string invoiceTotalMoney)
    {
        string chk1 = "", chk2 = "", chk3 = "", chk4 = "";
        //获取开票信息

        DataTable data = GroupCardHelper.callOrderQuery(context, "InvoiceOrderInfo", orderno);
        if (data != null && data.Rows.Count > 0)
        {
            for (int i = 0; i < data.Rows.Count; i++)
            {
                switch (Convert.ToInt32(data.Rows[i]["INVOICETYPECODE"]))
                {
                    case 0:
                        chk1 = "checked = true";
                        break;
                    case 1:
                        chk2 = "checked = true";
                        break;
                    case 2:
                        chk3 = "checked = true";
                        break;
                    case 3:
                        chk4 = "checked = true";
                        break;
                    default:
                        break;
                }
            }
        }
        string html = @"苏州通卡充值<input type=checkbox " + chk1 + @"  /> &nbsp;&nbsp;&nbsp;
                        交通费<input type=checkbox " + chk2 + @"/>&nbsp;&nbsp;&nbsp;
                        招待费&nbsp;<input type=checkbox " + chk3 + @"/>&nbsp;&nbsp;&nbsp;
                        福利费<input type=checkbox " + chk4 + @"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        发票数量&nbsp;" + invoiceCount + @"&nbsp;&nbsp;&nbsp;&nbsp;
                        发票总金额￥&nbsp;" + invoiceTotalMoney + @"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
        return html;
    }
    #endregion
}
