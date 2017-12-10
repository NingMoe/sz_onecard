using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Collections;
using Master;

/// <summary>
/// 创建人: 殷华荣 2012年8月9日
/// 资源管理打印 打印需求单、订购单、领用单 
/// </summary>
public class RMPrintHelper
{
    public RMPrintHelper()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    /// <summary>
    /// 打印多条需求单
    /// </summary>
    /// <param name="context"></param>
    /// <param name="applyOrderNo">需求单号</param>
    /// <param name="type">类型 01：存货补货  02：新制卡</param>
    /// <returns></returns>
    static public string PrintApplyOrder(CmnContext context, ArrayList applyOrderNo, string type)
    {
        return PrintApplyOrder(context, "", "", "", "", "", "", "", "", "", "", applyOrderNo, type);
    }

    /// <summary>
    /// 打印一条需求单
    /// </summary>
    /// <param name="context"></param>
    /// <param name="orderid">需求单号</param>
    /// <param name="cardface">卡面名称</param>
    /// <param name="cardsamplecode">卡样编码</param>
    /// <param name="cardnum">卡片数量</param>
    /// <param name="returndate">要求到货日期</param>
    /// <param name="remark">备注</param>
    /// <param name="cardname">卡片名称</param>
    /// <param name="cardfaceaffirmway">卡面确认方式</param>
    /// <param name="name">下单部门 下单人</param>
    /// <param name="ordermand">订单要求</param>
    /// <param name="type">类型 01存货补货  02新制卡</param>
    /// <returns></returns>
    static public string PrintApplyOrder(CmnContext context, string orderid, string cardface, string cardsamplecode,
        string cardnum, string returndate, string remark, string cardname, string cardfaceaffirmway,
        string name, string ordermand, string type)
    {
        return PrintApplyOrder(context, orderid, cardface, cardsamplecode, cardnum,
            returndate, remark, cardname, cardfaceaffirmway, name, ordermand, null, type);
    }

    /// <summary>
    /// 打印用户卡存货补货或者新制卡需求单
    /// </summary>
    /// <param name="context"></param>
    /// <param name="orderid">需求单号</param>
    /// <param name="cardface">卡面名称</param>
    /// <param name="cardsamplecode">卡样编码</param>
    /// <param name="cardnum">卡片数量</param>
    /// <param name="returndate">要求到货日期</param>
    /// <param name="remark">备注</param>
    /// <param name="cardname">卡片名称</param>
    /// <param name="cardfaceaffirmway">卡面确认方式</param>
    /// <param name="name">下单部门 下单人</param>
    /// <param name="ordermand">订单要求</param>
    /// <param name="applyOrderNo">订单号集合,批量打印时存放所有的订单号</param>
    /// <param name="type">类型 01存货补货  02新制卡</param>
    /// <returns></returns>
    static private string PrintApplyOrder(CmnContext context, string orderid, string cardface, string cardsamplecode,
                                         string cardnum, string returndate, string remark, string cardname,
                                         string cardfaceaffirmway, string name, string ordermand, ArrayList applyOrderNo, string type)
    {
        string content = "";    //需求单明细内容
        if (applyOrderNo != null && applyOrderNo.Count > 0)
        {
            string strWhere = "";
            foreach (string orderno in applyOrderNo)
            {
                strWhere += "'" + orderno.ToString() + "',";
            }
            if (strWhere.EndsWith(","))
            {
                strWhere = strWhere.Remove(strWhere.Length - 1);
            }
            DataTable data = ResourceManageHelper.callQuery(context, "APPLYORDERSEARCH", strWhere);
            if (data != null && data.Rows.Count > 0)
            {
                content = GetSupplyStockHtml(data, type); //获取需求单清单内容
                name = GetAllApplyOrderName(data);        //获取下单人 下单部门
                ordermand = GetAllApplyOrderMand(data);   //获取所有订单的订单要求
            }
        }
        else
        {
            if (type == "01")  //存货补货
            {
                content = @"<tr height=25px>
                            <td align='center'>" + orderid + @"</td>
                            <td align='left'>" + cardface + @"</td>
                            <td align='center'>" + cardsamplecode + @"</td>
                            <td align='right'>" + cardnum + @"</td>
                            <td align='center'>" + returndate + @"</td>
                            <td align='center'>" + remark + @"</td>
                      </tr>";
            }
            else if (type == "02")  //新制卡
            {
                content = @"<tr height=25px>
                            <td align='center'>" + orderid + @"</td>
                            <td align='left'>" + cardname + @"</td>
                            <td align='center'>" + cardfaceaffirmway + @"</td>
                            <td align='right'>" + cardnum + @"</td>
                            <td align='center'>" + returndate + @"</td>
                            <td align='center'>" + remark + @"</td>
                      </tr>";
            }
        }
        string date = DateTime.Now.Year.ToString() + " 年 " + DateTime.Now.Month.ToString() + " 月 " + DateTime.Now.Day.ToString() + " 日";
        string html = string.Format(
            @"<div align='center' style='font-size:30px'>苏州市民卡有限公司</div>
                      <div align='center' style='font-size:30px'>卡片下单需求</div>
                      <div align='right'>日期：{1}</div>
                      <table border=1px cellpadding=0 cellspacing=0 width='100%' align='center' style='border-style:solid' class='data'>
                             <tr height=25px>
                                <td colspan = 6 align='center'>制卡需求</td>
                             </tr>
                             <tr height=25px>
                                <td align='center'>需求单号</td>
                                <td align='center'>IC卡面类型</td>
                                <td align='center'>卡样编号</td>
                                <td align='center'>数量</td>
                                <td align='center'>要求到货时间</td>
                                <td align='center'>备注</td>
                             </tr>
                             {0}
                             <tr height=50px>
                                <td align='center'>订卡部门/经办人</td>
                                <td colspan=5>{2}</td>
                             </tr>
                            <tr height=25px>
                                <td align='center'>订单要求</td>
                                <td colspan=5>{3}</td>
                            </tr>
                            <tr height=25px>
                                <td colspan=6 align='center'>部门审批意见</td>
                            </tr>
                            <tr height=100px>
                                <td colspan=3 valign='top' width=50%>
                                    部门意见
                                    <div style='margin-top:100px;text-align:right'>
                                        签字：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        </br>
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    </div>
                                </td>
                                <td colspan=3 valign='top'>
                                    主管（副）总经理意见
                                    <div style='margin-top:100px;text-align:right'>
                                        签字：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        </br>
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    </div>
                                </td>
                            </tr>
                            <tr height=25px>
                                <td colspan=6 align='center'>审批意见</td>
                            </tr>
                            <tr height=100px>
                                <td colspan=3 valign='top' width=50%>
                                    技术部意见 
                                    <div style='margin-top:100px;text-align:right'>
                                        签字：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        </br>
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    </div>
                                </td>
                                <td colspan=3 valign='top'>
                                    总经理意见
                                    <div style='margin-top:100px;text-align:right'>
                                        签字：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        </br>
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    </div>
                                </td>
                            </tr>
                            <tr height=25px>
                                <td colspan=3 align='center'>
                                    年&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                </td>
                                <td colspan=3 align='center'>
                                    年&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                </td>
                            </tr>
                      </table>", content, date, name, ordermand);
        return html;
    }

    /// <summary>
    /// 打印资源需求单
    /// </summary>
    /// <param name="context">上下文</param>
    /// <param name="orderid">需求单ID</param>
    /// <param name="resourcepeType">资源类型</param>
    /// <param name="resourceName">资源名称</param>
    /// <param name="resourceAtt">资源属性</param>
    /// <param name="num">数量</param>
    /// <param name="returndate">要求到货日期</param>
    /// <param name="remark">备注</param>
    /// <param name="resourceNeedName">订单需求人</param>
    /// <param name="mand">订单要求</param>
    /// <returns></returns>
    static public string PrintResourceApplyOrder(CmnContext context,string orderNo,string resourceType,string resourceName,
                                           string resourceAtt,string num,string requiredate,string remark,string mand, GridView gvResult)
    {
        int count = 0;
        string content = string.Empty;
        string orderMand = string.Empty;
        string resourceNeedName = context.s_DepartID + ":" + context.s_DepartName + "/" + context.s_UserID + ":" + context.s_UserName;

        //查询时勾选打印
        for (int i = 0; i < gvResult.Rows.Count; i++)
        {
            CheckBox cb = (CheckBox)gvResult.Rows[i].FindControl("ItemCheckBox");

            if (cb != null && cb.Checked)
            {
                count++;
                string orderNoGv = gvResult.Rows[i].Cells[1].Text.Trim();
                string resourceTypeGv = gvResult.Rows[i].Cells[3].Text.Trim();
                string resourceNameGv = gvResult.Rows[i].Cells[4].Text.Trim();
                string resourceAttGv = gvResult.Rows[i].Cells[6].Text.Trim();
                string numGv = gvResult.Rows[i].Cells[18].Text.Trim();
                string requiredateGv = gvResult.Rows[i].Cells[19].Text.Trim();
                string remarkGv = gvResult.Rows[i].Cells[26].Text.Trim() == "&nbsp;" ? "" : gvResult.Rows[i].Cells[26].Text.Trim();
                orderMand += orderNoGv + ":" + gvResult.Rows[i].Cells[20].Text.Trim()+"<br/>";

                content += @"<tr height=25px>
                            <td align='center'>" + orderNoGv + @"</td>
                            <td align='center'>" + resourceTypeGv + @"</td>
                            <td align='center'>" + resourceNameGv + @"</td>
                            <td align='center'>" + resourceAttGv + @"</td>
                            <td align='center'>" + numGv + @"</td>
                            <td align='center'>" + requiredateGv + @"</td>
                            <td align='center'>" + remarkGv + @"</td>
                      </tr>";

            }
        }

        //提交时打印
        if (count == 0)
        {
            content += @"<tr height=25px>
                            <td align='center'>" + orderNo + @"</td>
                            <td align='center'>" + resourceType + @"</td>
                            <td align='center'>" + resourceName + @"</td>
                            <td align='center'>" + resourceAtt + @"</td>
                            <td align='center'>" + num + @"</td>
                            <td align='center'>" + requiredate + @"</td>
                            <td align='center'>" + remark + @"</td>
                      </tr>";
            orderMand = mand;
        }

        string date = DateTime.Now.Year.ToString() + " 年 " + DateTime.Now.Month.ToString() + " 月 " + DateTime.Now.Day.ToString() + " 日";
        string html = string.Format(
            @"<div align='center' style='font-size:30px'>苏州市民卡有限公司</div>
                      <div align='center' style='font-size:30px'>资源下单需求</div>
                      <div align='right'>日期：{1}</div>
                      <table border=1px cellpadding=0 cellspacing=0 width='100%' align='center' style='border-style:solid' class='data'>
                             <tr height=25px>
                                <td colspan = 7 align='center'>资源需求</td>
                             </tr>
                             <tr height=25px>
                                <td align='center'>需求单号</td>
                                <td align='center'>资源类型</td>
                                <td align='center'>资源名称</td>
                                <td align='center'>资源属性</td>
                                <td align='center'>数量</td>
                                <td align='center'>要求到货时间</td>
                                <td align='center'>备注</td>
                             </tr>
                             {0}
                             <tr height=50px>
                                <td align='center'>订卡部门/经办人</td>
                                <td colspan=6>{2}</td>
                             </tr>
                            <tr height=25px>
                                <td align='center'>订单要求</td>
                                <td colspan=6>{3}</td>
                            </tr>
                            <tr height=25px>
                                <td colspan=7 align='center'>部门审批意见</td>
                            </tr>
                            <tr height=100px>
                                <td colspan=3 valign='top' width=50%>
                                    部门意见
                                    <div style='margin-top:100px;text-align:right'>
                                        签字：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        </br>
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    </div>
                                </td>
                                <td colspan=4 valign='top'>
                                    主管（副）总经理意见
                                    <div style='margin-top:100px;text-align:right'>
                                        签字：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        </br>
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    </div>
                                </td>
                            </tr>
                            <tr height=25px>
                                <td colspan=7 align='center'>审批意见</td>
                            </tr>
                            <tr height=100px>
                                <td colspan=3 valign='top' width=50%>
                                    技术部意见 
                                    <div style='margin-top:100px;text-align:right'>
                                        签字：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        </br>
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    </div>
                                </td>
                                <td colspan=4 valign='top'>
                                    总经理意见
                                    <div style='margin-top:100px;text-align:right'>
                                        签字：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        </br>
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    </div>
                                </td>
                            </tr>
                            <tr height=25px>
                                <td colspan=3 align='center'>
                                    年&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                </td>
                                <td colspan=4 align='center'>
                                    年&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                </td>
                            </tr>
                      </table>", content, date, resourceNeedName, orderMand);
        return html;
    }

    /// <summary>
    /// 批量打印充值卡需求单
    /// </summary>
    /// <param name="context"></param>
    /// <param name="applyOrderNo">需求单号集合,批量打印时存放所有的需求单号</param>
    /// <returns></returns>
    static public string PrintChargeCardOrder(CmnContext context, ArrayList applyOrderNo)
    {
        return PrintChargeCardOrder(context, "", "", "", "", "", "", "", applyOrderNo);
    }

    /// <summary>
    /// 打印单条充值卡需求单
    /// </summary>
    /// <param name="context"></param>
    /// <param name="orderid"></param>
    /// <param name="cardvalue">面额</param>
    /// <param name="cardnum">卡片数量</param>
    /// <param name="returndate">要求到货日期</param>
    /// <param name="remark">备注</param>
    /// <param name="name">下单部门 / 下单人</param>
    /// <param name="ordermand">订单要求</param>
    /// <returns></returns>
    static public string PrintChargeCardOrder(CmnContext context, string orderid, string cardvalue,
        string cardnum, string returndate, string remark, string name, string ordermand)
    {
        return PrintChargeCardOrder(context, orderid, cardvalue, cardnum, returndate, remark, name, ordermand, null);
    }

    /// <summary>
    /// 打印充值卡需求单
    /// </summary>
    /// <param name="context"></param>
    /// <param name="orderid">需求单号</param>
    /// <param name="cardvalue">充值卡面额</param>
    /// <param name="cardnum">卡片数量</param>
    /// <param name="returndate">要求到货日期</param>
    /// <param name="remark">备注</param>
    /// <param name="name">下单部门/下单人</param>
    /// <param name="ordermand">订单要求</param>
    /// <param name="applyOrderNo">需求单号集合 批量打印时存放所有的需求单号</param>
    /// <returns></returns>
    static private string PrintChargeCardOrder(CmnContext context, string orderid, string cardvalue,
        string cardnum, string returndate, string remark, string name, string ordermand, ArrayList applyOrderNo)
    {
        string content = "";
        if (applyOrderNo != null && applyOrderNo.Count > 0)
        {
            string strWhere = "";
            foreach (string orderno in applyOrderNo)
            {
                strWhere += "'" + orderno.ToString() + "',";
            }
            if (strWhere.EndsWith(","))
            {
                strWhere = strWhere.Remove(strWhere.Length - 1);
            }
            DataTable data = ResourceManageHelper.callQuery(context, "APPLYCHARGECARDSEARCH", strWhere);
            if (data != null && data.Rows.Count > 0)
            {
                content = GetChargeCardOrderHtml(data);   //获取需求单清单明细
                name = GetAllApplyOrderName(data);        //获取需求单下单人
                ordermand = GetAllApplyOrderMand(data);   //获取需求单订单要求
            }
        }
        else
        {
            content = @"<tr>
                            <td align=center>" + orderid + @"</td>
                            <td align=center>" + cardvalue + @"</td>
                            <td align=right>" + cardnum + @"</td>
                            <td align=center>" + returndate + @"</td>
                            <td align=center>" + remark + @"</td>
                      </tr>";
        }
        string date = DateTime.Now.Year.ToString() + " 年 " + DateTime.Now.Month.ToString() + " 月 " + DateTime.Now.Day.ToString() + " 日";
        string html = string.Format(
              @"<div align='center' style='font-size:30px'>苏州市民卡有限公司</div>
                <div align='center' style='font-size:30px'>卡片下单需求</div>
                <div align='right'>日期:&nbsp;{1}</div>
                        <table border=1px cellpadding=0 cellspacing=0 width='100%' align='center' style='border-style:solid' class='data'>
                             <tr height=25px>
                                <td colspan = 5 align=center>制卡需求</td>
                             </tr>
                             <tr height=25px>
                                <td align=center>需求单号</td>
                                <td align=center>面值</td>
                                <td align=center>数量</td>
                                <td align=center>要求到货时间</td>
                                <td align=center>备注</td>
                             </tr>
                             {0}
                             <tr height=25px>
                                <td align=center>订卡部门/经办人</td>
                                <td colspan=4>{2}</td>
                             </tr>
                            <tr height=25px>
                                <td align=center>订单要求</td>
                                <td colspan=4>{3}</td>
                            </tr>
                            <tr height=25px>
                                <td colspan=5 align=center>部门审批意见</td>
                            </tr>
                            <tr height=100px>
                                <td colspan=2 valign='top' width=50%>
                                    部门意见
                                    <div style='margin-top:100px;text-align:right'>
                                        签字：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        </br>
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    </div> 
                                </td>
                                <td colspan=3 valign='top'>
                                    主管（副）总经理意见
                                    <div style='margin-top:100px;text-align:right'>
                                        签字：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        </br>
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    </div> 
                                </td>
                            </tr>
                            <tr height=25px>
                                <td colspan=5 align=center>审批意见</td>
                            </tr>
                            <tr height=100px>
                                <td colspan=2 valign='top' width=50%>
                                    技术部意见 
                                    <div style='margin-top:100px;text-align:right'>
                                        签字：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        </br>
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    </div> 
                                </td>
                                <td colspan=3 valign='top'>
                                    总经理意见
                                    <div style='margin-top:100px;text-align:right'>
                                        签字：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        </br>
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    </div> 
                                </td>
                            </tr>
                            <tr height=25px>
                                <td colspan=2 align=center>
                                    年&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                </td>
                                <td colspan=3 align=center>
                                    年&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                </td>
                            </tr>
                        </table>", content, date, name, ordermand);
        return html;
    }

    /// <summary>
    /// 获取所有需求单下单部门、下单人
    /// </summary>
    /// <param name="data">打印的需求单查询结果集</param>
    /// <returns></returns>
    static private string GetAllApplyOrderName(DataTable data)
    {
        string name = "";
        for (int i = 0; i < data.Rows.Count; i++)
        {
            name += data.Rows[i]["APPLYORDERID"].ToString() + "：" + data.Rows[i]["DEPARTNAME"].ToString() + " / " + data.Rows[i]["ORDERSTAFF"].ToString() + "</br>";
        }
        return name;
    }

    /// <summary>
    /// 获取所有需求单的订单要求
    /// </summary>
    /// <param name="data">打印的需求单查询结果集</param>
    /// <returns></returns>
    static private string GetAllApplyOrderMand(DataTable data)
    {
        string ordermand = "";
        for (int i = 0; i < data.Rows.Count; i++)
        {
            if (data.Rows[i]["ORDERDEMAND"].ToString().Trim().Length > 0)
            {
                ordermand += data.Rows[i]["APPLYORDERID"].ToString() + "：" + data.Rows[i]["ORDERDEMAND"].ToString() + "</br>";
            }
        }
        return ordermand;
    }

    /// <summary>
    /// 生成存货补货和新制卡打印清单脚本内容
    /// </summary>
    /// <param name="data">需求单查询结果集</param>
    /// <param name="type">类型 01：存货补货， 02：新制卡</param>
    /// <returns></returns>
    static private string GetSupplyStockHtml(DataTable data, string type)
    {
        string orderno = "";        //订单编号
        string cardtype = "";       //卡片类型
        string cardsamplecode = ""; //卡样编号
        string num = "";            //数量
        string returndate = "";     //要求到货时间
        string remark = "";         //备注
        string html = "";           //html标签字符串
        for (int i = 0; i < data.Rows.Count; i++)
        {
            if (type == "01")
            {
                cardtype = data.Rows[i]["CARDTYPE"].ToString();
                cardsamplecode = data.Rows[i]["CARDSAMPLECODE"].ToString();
            }
            else if (type == "02")
            {
                cardtype = data.Rows[i]["CARDNAME"].ToString();
                cardsamplecode = data.Rows[i]["CARDFACEAFFIRMWAY"].ToString();
            }
            orderno = data.Rows[i]["APPLYORDERID"].ToString();
            num = data.Rows[i]["CARDNUM"].ToString();
            returndate = data.Rows[i]["REQUIREDATE"].ToString();
            remark = data.Rows[i]["REMARK"].ToString();
            html += @"<tr height=25px>
                            <td align='center'>" + orderno + @"</td>
                            <td align='left'>" + cardtype + @"</td>
                            <td align='center'>" + cardsamplecode + @"</td>
                            <td align='right'>" + num + @"</td>
                            <td align='center'>" + returndate + @"</td>
                            <td align='center'>" + remark + @"</td>
                      </tr>";
        }
        return html;
    }

    /// <summary>
    /// 获取充值卡需求单打印正文内容
    /// </summary>
    /// <param name="data">充值卡需求单查询结果集</param>
    /// <returns></returns>
    static private string GetChargeCardOrderHtml(DataTable data)
    {
        string value = "";       //卡片类型
        string num = "";         //数量
        string returndate = "";  //要求到货时间
        string remark = "";      //备注
        string html = "";        //html标签字符串
        string orderid = "";     //需求单号
        for (int i = 0; i < data.Rows.Count; i++)
        {
            orderid = data.Rows[i]["APPLYORDERID"].ToString();
            value = data.Rows[i]["VALUECODE"].ToString();
            num = data.Rows[i]["CARDNUM"].ToString();
            returndate = data.Rows[i]["REQUIREDATE"].ToString();
            remark = data.Rows[i]["REMARK"].ToString();
            html += @"<tr height=25px>
                            <td align='center'>" + orderid + @"</td>
                            <td align='center'>" + value + @"</td>
                            <td align='right'>" + num + @"</td>
                            <td align='center'>" + returndate + @"</td>
                            <td align='center'>" + remark + @"</td>
                      </tr>";
        }
        return html;
    }

    /// <summary>
    /// 生成用户卡订购单单条打印的脚本
    /// </summary>
    /// <param name="context"></param>
    /// <param name="orderNo">订购单号</param>
    /// <param name="cardtype">卡面名称</param>
    /// <param name="cardsamplecode">卡样名称</param>
    /// <param name="num">卡片数量</param>
    /// <param name="begincardno">起始卡号</param>
    /// <param name="endcardno">结束卡号</param>
    /// <param name="requiredate">要求到货日期</param>
    /// <param name="remark">备注</param>
    /// <returns>打印的Html脚本文本</returns>
    static public string GetCardOrderPrintText(CmnContext context, string orderNo, string cardtype,
                                                string cardsamplecode, string num, string begincardno,
                                                string endcardno, string requiredate, string remark)
    {
        return GetCardOrderPrintText
                (context, orderNo, cardtype, cardsamplecode, num,
                  begincardno, endcardno, requiredate, remark, null);
    }

    /// <summary>
    /// 生成用户卡订购单多条打印的脚本
    /// </summary>
    /// <param name="context"></param>
    /// <param name="orderNoList">订购单号集合,多条打印时存放所有的订购单</param>
    /// <returns>订购单打印HTML脚本</returns>
    static public string GetCardOrderPrintText(CmnContext context, ArrayList orderNoList)
    {
        return GetCardOrderPrintText
                       (context, "", "", "", "", "", "", "", "", orderNoList);
    }

    /// <summary>
    /// 准备用户卡订购单打印的脚本 卡片下单时单条打印 或者订购单查询时多条打印
    /// </summary>
    /// <param name="cardtype">卡面类型</param>
    /// <param name="cardsamplecode">卡样编码，如果没有卡样编码则传卡片名称</param>
    /// <param name="num">卡片数量</param>
    /// <param name="begincardno">起始卡号</param>
    /// <param name="endcardno">结束卡号</param>
    /// <param name="requiredate">要求到货日期</param>
    /// <param name="remark">备注</param>
    /// <returns></returns>
    static private string GetCardOrderPrintText
        (CmnContext context, string orderNo, string cardtype, string cardsamplecode, string num,
         string begincardno, string endcardno, string requiredate, string remark, ArrayList orderNoList)
    {
        string content = "";
        if (orderNoList == null || orderNoList.Count < 1) //卡片下单页面打印订购单
        {
            content = @"<tr height=25px>
                             <td align='center'>" + orderNo + @"</td>
                             <td align='left'>" + cardtype + @"</td>
                             <td align='center'>" + cardsamplecode + @"</td>
                             <td align='center'>" + begincardno + " - " + endcardno + @"</td>
                             <td align='right'>" + num + @"</td>
                             <td align='center'>" + requiredate + @"</td>
                        </tr>";
        }
        else //订单查询页面查询 可批量打印订购单
        {
            string strWhere = "";
            foreach (string orderno in orderNoList)
            {
                strWhere += "'" + orderno.ToString() + "',";
            }
            if (strWhere.EndsWith(","))
            {
                strWhere = strWhere.Remove(strWhere.Length - 1);
            }
            DataTable data = ResourceManageHelper.callQuery(context, "USERCARDORDERSEARCH", strWhere);
            if (data != null && data.Rows.Count > 0)
            {
                content = GetUseCardOrderText(data);
                remark = GetUserCardOrderRemarkPrint(data);
            }
        }
        string date = DateTime.Now.Year.ToString() + " 年 " + DateTime.Now.Month.ToString() + " 月 " + DateTime.Now.Day.ToString() + " 日";
        string html = string.Format(
                      @"<div align='center' style='font-size:30px'>卡片订购单</div>
                        <div align='right'>日期：{2}</div>
                        <table border=1px cellpadding=0 cellspacing=0 width='100%' align='center' style='border-style:solid' class='data'>
                             <tr height=25px>
                                <td colspan = 6 align='center'>制卡需求</td>
                             </tr>
                             <tr height=25px>
                                <td align='center'>订购单号</td>
                                <td align='center'>IC卡面类型</td>
                                <td align='center'>卡样编号</td>
                                <td align='center'>卡号段</td>
                                <td align='center'>数量</td>
                                <td align='center'>要求到货时间</td>
                             </tr>
                             {0}
                            <tr height=25px>
                                <td align='center'>备注</td>
                                <td colspan=5>{1}</td>
                            </tr>
                            <tr height=50px>
                                <td align='center'>其他说明项</td>
                                <td colspan=5></td>
                            </tr>
                            <tr height=75px>
                                <td align='center'>工程采购部意见</td>
                                <td colspan=5>
                                    <div style='margin-top:75px;text-align:left'>
                                        签字：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    </div>
                                </td>
                            </tr>
                            <tr height=25px>
                                <td colspan=6 align='center'>以下由卡商填写</td>
                            </tr>
                            <tr height=25px>
                                <td rowspan=7 align='center'>卡片参数</td>
                                <td align='center'>芯片类型</td>
                                <td colspan=4></td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>COS名称及版本</td>
                                <td colspan=4></td>
                            </tr>
                             <tr height=25px>
                                <td align='center'>天线参数及版本</td>
                                <td colspan=4></td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>封装厂商</td>
                                <td colspan=4></td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>谐振频率范围</td>
                                <td colspan=4></td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>卡基材料</td>
                                <td colspan=4></td>
                            </tr>
                            <tr height=50px>
                                <td align='center'>其他</td>
                                <td colspan=4></td>
                            </tr>
                            <tr height=75px>
                                <td colspan=2 align='center'>卡商确认</td>
                                <td colspan=4 valign='bottom'>
                                    <div style='margin-top:75px;text-align:left'>
                                        签字：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    </div>
                                </td>
                            </tr>
                        </table>", content, remark, date);
        return html;
    }

    /// <summary>
    /// 准备资源订购单查询
    /// </summary>
    /// <param name="context">上下文环境</param>
    /// <param name="orderNo">订购单号</param>
    /// <param name="resourceType">资源类型</param>
    /// <param name="resourceName">资源名称</param>
    /// <param name="resourceAtt">资源属性</param>
    /// <param name="num">订购数量</param>
    /// <param name="requiredate">要求到货日期</param>
    /// <param name="remark">备注</param>
    /// <param name="orderNoList"></param>
    /// <returns>html字符串</returns>
    public static string GetResourceOrderPrintText
        (CmnContext context, string orderNo, string resourceType, string resourceName, string resourceAtt,
         string num, string requiredate, string remark)
    {
        string content = "";
        content = @"<tr height=25px>
                             <td align='center'>" + orderNo + @"</td>
                             <td align='left'>" + resourceType + @"</td>
                             <td align='center'>" + resourceName + @"</td>
                             <td align='center'>" + resourceAtt + @"</td>
                             <td align='right'>" + num + @"</td>
                             <td align='center'>" + requiredate + @"</td>
                        </tr>";

        string date = DateTime.Now.Year.ToString() + " 年 " + DateTime.Now.Month.ToString() + " 月 " + DateTime.Now.Day.ToString() + " 日";
        string html = string.Format(
                      @"<div align='center' style='font-size:30px'>资源订购单</div>
                        <div align='right'>日期：{2}</div>
                        <table border=1px cellpadding=0 cellspacing=0 width='100%' align='center' style='border-style:solid' class='data'>
                             <tr height=25px>
                                <td colspan = 6 align='center'>资源需求</td>
                             </tr>
                             <tr height=25px>
                                <td align='center'>订购单号</td>
                                <td align='center'>资源类型</td>
                                <td align='center'>资源名称</td>
                                <td align='center'>资源属性</td>
                                <td align='center'>数量</td>
                                <td align='center'>要求到货时间</td>
                             </tr>
                             {0}
                            <tr height=25px>
                                <td align='center'>备注</td>
                                <td colspan=5>{1}</td>
                            </tr>
                            <tr height=50px>
                                <td align='center'>其他说明项</td>
                                <td colspan=5></td>
                            </tr>
                            <tr height=75px>
                                <td align='center'>采购部意见</td>
                                <td colspan=5>
                                    <div style='margin-top:75px;text-align:left'>
                                        签字：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    </div>
                                </td>
                            </tr>
                        </table>", content, remark, date);
        return html;
    }

    /// <summary>
    /// 单条打印充值卡订购单，卡片下单页面
    /// </summary>
    /// <param name="context"></param>
    /// <param name="value">充值卡面额</param>
    /// <param name="num">充值卡数量</param>
    /// <param name="begincardno">起始卡号</param>
    /// <param name="endcardno">结束卡号</param>
    /// <param name="requiredate">要求到货日期</param>
    /// <param name="remark">备注</param>
    /// <returns>生成的订购单打印脚本</returns>
    static public string GetChargeCardOrderPrintText(CmnContext context, string orderNo, string value, string num,
         string begincardno, string endcardno, string requiredate, string remark)
    {
        return GetChargeCardOrderPrintText
               (context, orderNo, value, num,
                 begincardno, endcardno, requiredate, remark, null);
    }

    /// <summary>
    /// 订购单查询页面，充值卡多条订购单打印
    /// </summary>
    /// <param name="context"></param>
    /// <param name="orderNoList"></param>
    /// <returns></returns>
    static public string GetChargeCardOrderPrintText(CmnContext context, ArrayList orderNoList)
    {
        return GetChargeCardOrderPrintText(context, "", "", "", "", "", "", "", orderNoList);
    }

    /// <summary>
    /// 打印充值卡订购单 卡片下单时单条打印 或者订购单查询时多条打印
    /// </summary>
    /// <param name="value">面额</param>
    /// <param name="num">数量</param>
    /// <param name="begincardno">起始卡号</param>
    /// <param name="endcardno">结束卡号</param>
    /// <param name="requiredate">要求到货日期</param>
    /// <param name="remark">备注</param>
    /// <returns>订购单打印脚本</returns>
    static private string GetChargeCardOrderPrintText
        (CmnContext context, string orderNo, string value, string num,
         string begincardno, string endcardno, string requiredate, string remark, ArrayList orderNoList)
    {
        string content = "";
        if (orderNoList == null || orderNoList.Count < 1) //卡片下单页面打印订购单
        {
            content = @"<tr height=25px>
                             <td align='center'>" + orderNo + @"</td>
                             <td align='center'>" + value + @"</td>
                             <td align='center'>" + begincardno + " - " + endcardno + @"</td>
                             <td align='right'>" + num + @"</td>
                             <td align='center'>" + requiredate + @"</td>
                        </tr>";
        }
        else //订单查询页面查询 可批量打印订购单
        {
            string strWhere = "";
            foreach (string orderno in orderNoList)
            {
                strWhere += "'" + orderno.ToString() + "',";
            }
            if (strWhere.EndsWith(","))
            {
                strWhere = strWhere.Remove(strWhere.Length - 1);
            }
            DataTable data = ResourceManageHelper.callQuery(context, "CHARGECARDORDERSEARCH", strWhere);
            if (data != null && data.Rows.Count > 0)
            {
                content = GetChargeCardOrderText(data);
                remark = GetChargeCardOrderRemarkPrint(data);
            }
        }
        string date = DateTime.Now.Year.ToString() + " 年 " + DateTime.Now.Month.ToString() + " 月 " + DateTime.Now.Day.ToString() + " 日";
        string html = string.Format(
                       @"<div align='center' style='font-size:30px'>卡片订购单</div>
                        <div align='right'>日期：{2}</div>
                        <table border=1px cellpadding=0 cellspacing=0 width='100%' align='center' style='border-style:solid' class='data'>
                             <tr height=25px>
                                <td colspan = 5 align='center'>制卡需求</td>
                             </tr>
                             <tr height=25px>
                                <td align='center'>订购单号</td>
                                <td align='center'>面额</td>
                                <td align='center'>卡号段</td>
                                <td align='center'>数量</td>
                                <td align='center'>要求到货时间</td>
                             </tr>
                             {0}
                            <tr height=25px>
                                <td align='center'>备注</td>
                                <td colspan=4 align='left'>{1}</td>
                            </tr>
                            <tr height=50px>
                                <td align='center'>其他说明项</td>
                                <td colspan=4></td>
                            </tr>
                            <tr height=75px>
                                <td align='center'>工程采购部意见</td>
                                <td colspan=4>
                                    <div style='margin-top:75px;text-align:left'>
                                        签字：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                    </div>
                                </td>
                            </tr>
                            <tr height=25px>
                                <td colspan=5 align='center'>以下由卡商填写</td>
                            </tr>
                            <tr height=25px>
                                <td rowspan=7 align='center'>卡片参数</td>
                                <td align='center'>芯片类型</td>
                                <td colspan=3></td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>COS名称及版本</td>
                                <td colspan=3></td>
                            </tr>
                             <tr height=25px>
                                <td align='center'>天线参数及版本</td>
                                <td colspan=3></td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>封装厂商</td>
                                <td colspan=3></td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>谐振频率范围</td>
                                <td colspan=3></td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>卡基材料</td>
                                <td colspan=3></td>
                            </tr>
                            <tr height=50px>
                                <td align='center'>其他</td>
                                <td colspan=3></td>
                            </tr>
                            <tr height=75px>
                                <td colspan=2 align='center'>卡商确认</td>
                                <td colspan=3>
                                    <div style='margin-top:75px;text-align:left'>
                                        签字：&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    </div>
                                </td>
                            </tr>
                        </table>", content, remark, date);
        return html;
    }

    /// <summary>
    /// 用户卡订购单内容 脚本
    /// </summary>
    /// <param name="data">订购单查询结果集</param>
    /// <returns></returns>
    static private string GetUseCardOrderText(DataTable data)
    {
        string orderno = "";
        string cardface = "";       //卡面类型
        string cardsamplecode = ""; //卡样编号
        string num = "";            //数量
        string returndate = "";     //要求到货时间
        string html = "";           //html标签字符串
        string begincardno = "";    //起始卡号
        string endcardno = "";      //结束卡号
        for (int i = 0; i < data.Rows.Count; i++)
        {
            orderno = data.Rows[i]["CARDORDERID"].ToString();
            cardface = data.Rows[i]["CARDFACE"].ToString();
            if (data.Rows[i]["CARDSAMPLECODE"].ToString().Trim().Length < 1)
            {
                cardsamplecode = data.Rows[i]["CARDNAME"].ToString();
            }
            else
            {
                cardsamplecode = data.Rows[i]["CARDSAMPLECODE"].ToString();
            }
            begincardno = data.Rows[i]["BEGINCARDNO"].ToString();
            endcardno = data.Rows[i]["ENDCARDNO"].ToString();
            num = data.Rows[i]["CARDNUM"].ToString();
            returndate = data.Rows[i]["REQUIREDATE"].ToString();
            html += @"<tr>
                            <td align='center'>" + orderno + @"</td>
                            <td align='left'>" + cardface + @"</td>
                            <td align='center'>" + cardsamplecode + @"</td>
                            <td align='center'>" + begincardno + " - " + endcardno + @"</td>
                            <td align='right'>" + num + @"</td>
                            <td align='center'>" + returndate + @"</td>
                      </tr>";
        }
        return html;
    }

    /// <summary>
    /// 获取用户卡卡片订购单备注
    /// </summary>
    /// <param name="data">订购单查询结果集</param>
    /// <returns></returns>
    static private string GetUserCardOrderRemarkPrint(DataTable data)
    {
        string orderno = "";        //订购单号
        string remark = "";         //备注
        string html = "";
        for (int i = 0; i < data.Rows.Count; i++)
        {
            orderno = data.Rows[i]["CARDORDERID"].ToString();
            remark = data.Rows[i]["REMARK"].ToString();
            if (remark.Trim().Length > 0)
            {
                html += orderno + " : " + remark + "</br>";
            }
        }
        return html;
    }

    /// <summary>
    /// 充值卡订购单明细 脚本
    /// </summary>
    /// <param name="data">订购单查询结果集</param>
    /// <returns></returns>
    static private string GetChargeCardOrderText(DataTable data)
    {
        string orderno = "";         //订购单号
        string cardvalue = "";       //面额
        string num = "";            //数量
        string returndate = "";     //要求到货时间
        string html = "";           //html标签字符串
        string begincardno = "";    //起始卡号
        string endcardno = "";      //结束卡号
        for (int i = 0; i < data.Rows.Count; i++)
        {
            orderno = data.Rows[i]["CARDORDERID"].ToString();
            cardvalue = data.Rows[i]["CARDVALUE"].ToString();
            begincardno = data.Rows[i]["BEGINCARDNO"].ToString();
            endcardno = data.Rows[i]["ENDCARDNO"].ToString();
            num = data.Rows[i]["CARDNUM"].ToString();
            returndate = data.Rows[i]["REQUIREDATE"].ToString();
            html += @"<tr height=25px>
                            <td align='center'>" + orderno + @"</td>
                            <td align='center'>" + cardvalue + @"</td>
                            <td align='center'>" + begincardno + "-" + endcardno + @"</td>
                            <td align='right'>" + num + @"</td>
                            <td align='center'>" + returndate + @"</td>
                      </tr>";
        }
        return html;
    }

    /// <summary>
    /// 充值卡备注打印内容
    /// </summary>
    /// <param name="data">充值卡查询结果集</param>
    /// <returns>打印脚本</returns>
    static private string GetChargeCardOrderRemarkPrint(DataTable data)
    {
        string orderno = "";        //订购单号
        string remark = "";         //备注
        string html = "";
        for (int i = 0; i < data.Rows.Count; i++)
        {
            orderno = data.Rows[i]["CARDORDERID"].ToString();
            remark = data.Rows[i]["REMARK"].ToString();
            if (remark.Trim().Length > 0)
            {
                html += orderno + " : " + remark + "</br>";
            }
        }
        return html;
    }

    /// <summary>
    /// 批量打印领用单
    /// </summary>
    /// <param name="gv"></param>
    /// <returns></returns>
    static public string GetUseCardApplyPrintText(CmnContext context, GridView gv)
    {
        return GetUseCardApplyPrintText(context, "", "", "", "", "", "", "", "", "", gv);
    }

    /// <summary>
    /// 单条打印领用单
    /// </summary>
    /// <param name="getcardorderid"></param>
    /// <param name="cardface"></param>
    /// <param name="applygetnum"></param>
    /// <param name="agreegetnum"></param>
    /// <param name="alreadygetnum"></param>
    /// <param name="departname"></param>
    /// <param name="staffname"></param>
    /// <param name="useway"></param>
    /// <param name="remark"></param>
    /// <returns></returns>
    static public string GetUseCardApplyPrintText(CmnContext context, string getcardorderid, string cardface,
                                                  string applygetnum, string agreegetnum, string alreadygetnum,
                                                  string departname, string staffname, string useway, string remark)
    {
        return GetUseCardApplyPrintText(context, getcardorderid, cardface, applygetnum, agreegetnum, alreadygetnum,
                                        departname, staffname, useway, remark, null);
    }

    /// <summary>
    /// 打印用户卡领用单
    /// </summary>
    /// <param name="getcardorderid">领用单号</param>
    /// <param name="cardface">卡面名称</param>
    /// <param name="cardnum">卡片数量</param>
    /// <param name="departname">部门名称</param>
    /// <param name="staffname">领用人</param>
    /// <param name="useway">用途</param>
    /// <param name="remark">备注</param>
    /// <returns>打印脚本</returns>
    static private string GetUseCardApplyPrintText(CmnContext context, string getcardorderid, string cardface,
                                                  string applygetnum, string agreegetnum, string alreadygetnum,
                                                  string departname, string staffname, string useway, string remark, GridView gv)
    {
        string date = DateTime.Now.Year.ToString() + " 年 " + DateTime.Now.Month.ToString() + " 月 " + DateTime.Now.Day.ToString() + " 日";
        string html = string.Format(
                      @"<div align='center' style='font-size:30px'>苏州市民卡有限公司</div>
                        <div align='center' style='font-size:30px'>卡片领用单</div>
                        <div align='right'>日期：{0}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div>
                        <table border=1px cellpadding=0 cellspacing=0 width='98%' align='left' style='border-style:solid' class='data'>", date);
        if (gv == null)
        {
            html += string.Format(@"<tr height=25px>
                                <td align='center'>领用单号</td>
                                <td>{0}</td>
                                <td align='center'>IC卡面类型</td>
                                <td>{1}</td>
                                <td align='center'>转出仓库</td>
                                <td>公司商品库</td>
                             </tr>
                             <tr height=25px>
                                <td align='center'>已领用数量</td>
                                <td>{2}</td>
                                <td align='center'>转入部门</td>
                                <td>{3}</td>
                                <td align='center'>申请人</td>
                                <td>{4}</td>
                             </tr>
                            <tr height=40px>
                                <td align='center'>用途</td>
                                <td colspan=2>{5}</td>
                                <td align='center'>备注</td>
                                <td colspan=2>{6}</td>
                            </tr>", getcardorderid, cardface, alreadygetnum, departname, staffname, useway, remark);
        }
        else
        {
            int count = 0;
            foreach (GridViewRow gvr in gv.Rows)
            {
                CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
                if (cb != null && cb.Checked)
                {
                    ++count;
                    html += string.Format(@"<tr height=25px>
                                <td align='center'>领用单号</td>
                                <td>{0}</td>
                                <td align='center'>IC卡面类型</td>
                                <td>{1}</td>
                                <td align='center'>转出仓库</td>
                                <td>公司商品库</td>
                             </tr>
                             <tr height=25px>
                                <td align='center'>已领用数量</td>
                                <td>{2}</td>
                                <td align='center'>转入部门</td>
                                <td>{3}</td>
                                <td align='center'>申请人</td>
                                <td>{4}</td>
                             </tr>
                            <tr height=40px>
                                <td align='center'>用途</td>
                                <td colspan=2>{5}</td>
                                <td align='center'>备注</td>
                                <td colspan=2>{6}</td>
                            </tr>", gvr.Cells[1].Text, gvr.Cells[3].Text, gvr.Cells[6].Text, gvr.Cells[10].Text,
                                    gvr.Cells[9].Text, gvr.Cells[7].Text, gvr.Cells[11].Text);
                }
            }
            if (count <= 0)
            {
                context.AddError("A004P03R01: 没有选中任何行");
            }
        }
        html += string.Format(@"<tr height=30px>
                                <td colspan=6 style='margin:0px;padding:0px;border:1px;display:block;vertical-align:top'>
                                    <table width='100%' cellspan=0 colspan=0 border=0 class='data' style='border-style:solid' border=1>
                                        <tr>
                                            <td valign='top'>
                                                领用人签字
                                                <div style='margin-top:10px;text-align:right'>
                                                    </br>
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                </div>
                                            </td>
                                            <td valign='top'>
                                                领用部门签字
                                                <div style='margin-top:10px;text-align:right'>
                                                    </br>
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                </div>
                                            </td>
                                            <td valign='top'>
                                                库管员签字
                                                <div style='margin-top:10px;text-align:right'>
                                                    </br>
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>");
        return html;
    }

    static public string GetChargeCardApplyPrintText(CmnContext context, GridView gv)
    {
        return GetChargeCardApplyPrintText(context, "", "", "", "", "", "", "", "", "", gv);
    }

    static public string GetChargeCardApplyPrintText(CmnContext context, string getcardorderid, string cardvalue,
                                                    string applygetnum, string agreegetnum, string alreadygetnum,
                                                    string departname, string staffname, string useway, string remark)
    {
        return GetChargeCardApplyPrintText(context, getcardorderid, cardvalue, applygetnum, agreegetnum, alreadygetnum,
                                           departname, staffname, useway, remark, null);
    }

    /// <summary>
    /// 打印充值卡领用单
    /// </summary>
    /// <param name="getcardorderid">领用单号</param>
    /// <param name="cardvalue">卡片面额</param>
    /// <param name="cardnum">卡片数量</param>
    /// <param name="departname">部门名称</param>
    /// <param name="staffname">领用人</param>
    /// <param name="useway">用途</param>
    /// <param name="remark">备注</param>
    /// <returns>打印脚本</returns>
    static private string GetChargeCardApplyPrintText(CmnContext context, string getcardorderid, string cardvalue,
                                                      string applygetnum, string agreegetnum, string alreadygetnum,
                                                      string departname, string staffname, string useway, string remark, GridView gv)
    {
        string date = DateTime.Now.Year.ToString() + " 年 " + DateTime.Now.Month.ToString() + " 月 " + DateTime.Now.Day.ToString() + " 日";
        string html = string.Format(
                      @"<div align='center' style='font-size:30px'>苏州市民卡有限公司</div>
                        <div align='center' style='font-size:30px'>卡片领用单</div>
                        <div align='right'>日期：{0}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div>
                        <table border=1px cellpadding=0 cellspacing=0 width='98%' align='left' style='border-style:solid' class='data'>", date);
        if (gv == null)
        {
            html += string.Format(@"<tr height=25px>
                                <td align='center'>领用单号</td>
                                <td>{0}</td>
                                <td align='center'>充值卡面额</td>
                                <td>{1}</td>
                                <td align='center'>转出仓库</td>
                                <td>公司商品库</td>
                             </tr>
                             <tr height=25px>
                                <td align='center'>已领用数量</td>
                                <td>{2}</td>
                                <td align='center'>转入部门</td>
                                <td>{3}</td>
                                <td align='center'>申请人</td>
                                <td>{4}</td>
                             </tr>
                            <tr height=40px>
                                <td align='center'>用途</td>
                                <td colspan=2>{5}</td>
                                <td align='center'>备注</td>
                                <td colspan=2>{6}</td>
                            </tr>", getcardorderid, cardvalue, alreadygetnum, departname, staffname, useway, remark);

        }
        else
        {
            int count = 0;
            foreach (GridViewRow gvr in gv.Rows)
            {
                CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
                if (cb != null && cb.Checked)
                {
                    ++count;
                    html += string.Format(@"<tr height=25px>
                                <td align='center'>领用单号</td>
                                <td>{0}</td>
                                <td align='center'>充值卡面额</td>
                                <td>{1}</td>
                                <td align='center'>转出仓库</td>
                                <td>公司商品库</td>
                             </tr>
                             <tr height=25px>
                                <td align='center'>已领用数量</td>
                                <td>{2}</td>
                                <td align='center'>转入部门</td>
                                <td>{3}</td>
                                <td align='center'>申请人</td>
                                <td>{4}</td>
                             </tr>
                            <tr height=40px>
                                <td align='center'>用途</td>
                                <td colspan=2>{5}</td>
                                <td align='center'>备注</td>
                                <td colspan=2>{6}</td>
                            </tr>", gvr.Cells[1].Text, gvr.Cells[2].Text, gvr.Cells[5].Text, gvr.Cells[9].Text, gvr.Cells[8].Text, gvr.Cells[6].Text, gvr.Cells[10].Text);
                }
            }
            if (count <= 0)
            {
                context.AddError("A004P03R01: 没有选中任何行");
            }
        }
        html += string.Format(@"<tr height=30px>
                                <td colspan=6 style='margin:0px;padding:0px;border:1px;display:block;vertical-align:top'>
                                    <table width='100%' cellspan=0 colspan=0 border=0 class='data' style='border-style:solid' border=1>
                                        <tr>
                                            <td valign='top'>
                                                领用人签字
                                                <div style='margin-top:10px;text-align:right'>
                                                    </br>
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                </div>
                                            </td>
                                            <td valign='top'>
                                                领用部门签字
                                                <div style='margin-top:10px;text-align:right'>
                                                    </br>
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                </div>
                                            </td>
                                            <td valign='top'>
                                                库管员签字
                                                <div style='margin-top:10px;text-align:right'>
                                                    </br>
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;年
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;月
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;日
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>");
        return html;
    }

    /// <summary>
    /// 打印用户卡退库单
    /// </summary>
    /// <returns></returns>
    static public string GetUserCardStockReturnPrintText(string seqNo, string begincardno, string endcardno, string cardfacename, string reason,
                                                       string department, string staffname)
    {
        string date = DateTime.Now.Year.ToString() + " 年 " + DateTime.Now.Month.ToString() + " 月 " + DateTime.Now.Day.ToString() + " 日";
        string html = string.Format(
                      @"<div align='center' style='font-size:30px'>卡片退库单</div>
                        <table border=1px cellpadding=0 cellspacing=0 width='100%' align='center' style='border-style:solid' class='data'>
                             <tr height=25px>
                                <td align='center'>退库单号</td>
                                <td>{0}</td>
                                <td align='center'>退库日期</td>
                                <td>{1}</td>
                             </tr>
                            <tr height=25px>
                                <td align='center'>卡号段</td>
                                <td>{2}</td>
                                <td align='center'>卡面类型</td>
                                <td>{6}</td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>退库原因</td>
                                <td colspan=3 align=left>{3}</td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>退库部门</td>
                                <td>{4}</td>
                                <td align='center'>退库员工</td>
                                <td>{5}</td>
                            </tr>
                        </table>", seqNo, date, begincardno + " - " + endcardno, reason, department, staffname, cardfacename);
        return html;
    }

    /// <summary>
    /// 打印充值卡退库单
    /// </summary>
    /// <returns></returns>
    static public string GetChargeCardStockReturnPrintText(string seqNo, string begincardno, string endcardno, string reason,
                                                       string department, string staffname)
    {
        string date = DateTime.Now.Year.ToString() + " 年 " + DateTime.Now.Month.ToString() + " 月 " + DateTime.Now.Day.ToString() + " 日";
        string html = string.Format(
                      @"<div align='center' style='font-size:30px'>卡片退库单</div>
                        <table border=1px cellpadding=0 cellspacing=0 width='100%' align='center' style='border-style:solid' class='data'>
                             <tr height=25px>
                                <td align='center'>退库单号</td>
                                <td>{0}</td>
                                <td align='center'>退库日期</td>
                                <td>{1}</td>
                             </tr>
                            <tr height=25px>
                                <td align='center'>卡号段</td>
                                <td colspan=3>{2}</td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>退库原因</td>
                                <td colspan=3 align=left>{3}</td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>退库部门</td>
                                <td>{4}</td>
                                <td align='center'>退库员工</td>
                                <td>{5}</td>
                            </tr>
                        </table>", seqNo, date, begincardno + " - " + endcardno, reason, department, staffname);
        return html;
    }

    /// <summary>
    /// 打印用户卡退货单
    /// </summary>
    /// <returns></returns>
    static public string GetUseCardReturnCardPrintText(string seqNo, string begincardno, string endcardno, string cardfacename, string cardmanu,
                                                       string reason, string department, string staffname)
    {
        string date = DateTime.Now.Year.ToString() + " 年 " + DateTime.Now.Month.ToString() + " 月 " + DateTime.Now.Day.ToString() + " 日";
        string html = string.Format(
                      @"<div align='center' style='font-size:30px'>卡片退货单</div>
                        <table border=1px cellpadding=0 cellspacing=0 width='100%' align='center' style='border-style:solid' class='data'>
                             <tr height=25px>
                                <td align='center'>退货单号</td>
                                <td>{0}</td>
                                <td align='center'>退货日期</td>
                                <td>{1}</td>
                             </tr>
                            <tr height=25px>
                                <td align='center'>卡号段</td>
                                <td>{2}</td>
                                <td align='center'>卡面类型</td>
                                <td>{7}</td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>厂商</td>
                                <td colspan=3>{3}</td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>退货原因</td>
                                <td colspan=3 align=left>{4}</td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>退货部门</td>
                                <td>{5}</td>
                                <td align='center'>退货员工</td>
                                <td>{6}</td>
                            </tr>
                        </table>", seqNo, date, begincardno + " - " + endcardno, cardmanu, reason, department, staffname, cardfacename);
        return html;
    }

    /// <summary>
    /// 打印充值卡退货单
    /// </summary>
    /// <returns></returns>
    static public string GetChargeCardReturnCardPrintText(string seqNo, string begincardno, string endcardno, string cardmanu,
                                                          string reason, string department, string staffname)
    {
        string date = DateTime.Now.Year.ToString() + " 年 " + DateTime.Now.Month.ToString() + " 月 " + DateTime.Now.Day.ToString() + " 日";
        string html = string.Format(
                      @"<div align='center' style='font-size:30px'>卡片退货单</div>
                        <table border=1px cellpadding=0 cellspacing=0 width='100%' align='center' style='border-style:solid' class='data'>
                             <tr height=25px>
                                <td align='center'>退货单号</td>
                                <td>{0}</td>
                                <td align='center'>退货日期</td>
                                <td>{1}</td>
                             </tr>
                            <tr height=25px>
                                <td align='center'>卡号段</td>
                                <td colspan=3>{2}</td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>厂商</td>
                                <td colspan=3>{3}</td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>退货原因</td>
                                <td colspan=3 align=left>{4}</td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>退货部门</td>
                                <td>{5}</td>
                                <td align='center'>退货员工</td>
                                <td>{6}</td>
                            </tr>
                        </table>", seqNo, date, begincardno + " - " + endcardno, cardmanu, reason, department, staffname);
        return html;
    }

    /// <summary>
    /// 打印用户卡签收入库单
    /// </summary>
    /// <returns></returns>
    static public string GetUseCardSignInStoragePrintText(string seqNo, string manuname, string cardsurfacename, string quantity,
                                                          string department, string staffname)
    {
        string date = DateTime.Now.Year.ToString() + " 年 " + DateTime.Now.Month.ToString() + " 月 " + DateTime.Now.Day.ToString() + " 日";
        string html = string.Format(
                      @"<div align='center' style='font-size:30px'>卡片签收入库单</div>
                        <table border=1px cellpadding=0 cellspacing=0 width='100%' align='center' style='border-style:solid' class='data'>
                             <tr height=25px>
                                <td align='center'>入库单号</td>
                                <td>{0}</td>
                                <td align='center'>入库日期</td>
                                <td>{1}</td>
                             </tr>
                            <tr height=25px>
                                <td align='center'>供货单位</td>
                                <td>{2}</td>
                                <td align='center'>卡面名称</td>
                                <td>{3}</td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>数量</td>
                                <td colspan=3 align=left>{4}</td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>入库部门</td>
                                <td>{5}</td>
                                <td align='center'>入库员工</td>
                                <td>{6}</td>
                            </tr>
                        </table>", seqNo, date, manuname, cardsurfacename, quantity, department, staffname);
        return html;
    }

    /// <summary>
    /// 打印充值卡签收入库单
    /// </summary>
    /// <returns></returns>
    static public string GetChargeCardSignInStoragePrintText(string seqNo, string cardvalue, string quantity, string department, string staffname)
    {
        string date = DateTime.Now.Year.ToString() + " 年 " + DateTime.Now.Month.ToString() + " 月 " + DateTime.Now.Day.ToString() + " 日";
        string html = string.Format(
                      @"<div align='center' style='font-size:30px'>卡片签收入库单</div>
                        <table border=1px cellpadding=0 cellspacing=0 width='100%' align='center' style='border-style:solid' class='data'>
                             <tr height=25px>
                                <td align='center'>入库单号</td>
                                <td>{0}</td>
                                <td align='center'>入库日期</td>
                                <td>{1}</td>
                             </tr>
                            <tr height=25px>
                                <td align='center'>面额</td>
                                <td>{2}</td>
                                <td align='center'>数量</td>
                                <td colspan=3 align=left>{3}</td>
                            </tr>
                            <tr height=25px>
                                <td align='center'>入库部门</td>
                                <td>{4}</td>
                                <td align='center'>入库员工</td>
                                <td>{5}</td>
                            </tr>
                        </table>", seqNo, date, cardvalue, quantity, department, staffname);
        return html;
    }
}
