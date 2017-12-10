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
///创建人: 石磊 2013年1月23日
///卡卡转账圈存打印
/// </summary>
public class PrintHelper
{
	public PrintHelper()
	{
		//
		//TODO: 在此处添加构造函数逻辑
		//
	}

    /// <summary>
    /// 卡卡转账圈存打印
    /// </summary>
    /// <param name="context"></param>
    /// <param name="tradeid">流水号</param>
    /// <param name="dept">网点</param>
    /// <param name="staff">营业员</param>
    /// <param name="outcard">转出卡卡号</param>
    /// <param name="incard">转入卡卡号</param>
    /// <param name="money">转出金额</param>
    /// <param name="outcardmoney">转出后卡内余额</param>
    /// <param name="incardmoney">转入卡内余额</param>
    /// <returns></returns>
    static public string PrintCardToCardIn(CmnContext context, string tradeid, string dept, string staff, string outcard, string incard,
                                           string money, string outcardmoney, string incardmoney)
    {
        string date = DateTime.Now.Year.ToString() + "-" + DateTime.Now.Month.ToString() + "-" + DateTime.Now.Day.ToString();
        #region 旧格式
        //        string html = string.Format(
        //                      @"<div align='center' style='font-size:30px'>苏州市民卡业务回单</div>
        //                        <div style='height:40px'></div>
        //                        <div align='right'>流水号：{0}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div>
        //                        <table border=0 cellpadding=0 cellspacing=0 width='98%' align='left' style='border:none' class='data'>
        //                          <tr>
        //                            <td width='33%'></td>
        //                            <td width='33%'></td>
        //                            <td width='34%'></td>
        //                          </tr>                          
        //                          <tr height=25px>
        //                            <td align='left' colspan='3'>业务类型：卡卡转账</td>
        //                          </tr>
        //                          <tr height=25px>
        //                            <td align='left'>日期：{1}</td>
        //                            <td align='left'>网点：{2}</td>
        //                            <td align='left'>营业员：{3}</td>
        //                          </tr>
        //                          <tr height=25px>
        //                            <td align='left' colspan='3'>转出卡卡号：{4}</td>
        //                          </tr>
        //                          <tr height=25px>
        //                            <td align='left' colspan='3'>转入卡卡号：{5}</td>
        //                          </tr>
        //                          <tr height=25px>
        //                            <td align='left' colspan='3'>转出金额：{6}，转出后卡内余额：{7}，转入卡内余额：{8}</td>
        //                          </tr>
        //                            <tr height=50px>
        //                            <td align='right' colspan='3'>客户签字：________________</td>
        //                          </tr>
        //                        </table>
        //                        ", tradeid, date, dept, staff,outcard,incard,money,outcardmoney,incardmoney);
        #endregion
        string html = string.Format(
                      @"<div align='center' style='font-size:20px;height:35px'>苏州市民卡业务回单</div>
                        <table border=0 cellpadding=0 cellspacing=0 width=649px align='center' style='border:none;font-size:14px' class='data'>
                         <tr>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td width=76px></td>
                          </tr>
                          <tr height=25px>
                            <td colspan='6'>
                              <table width='100%' style='font-size:14px'>
                                 <tr>
                                   <td align='left'>日期:{1}</td>
                                   <td align='center'>网点:{2}</td>
                                   <td align='center'>操作员:{3}</td>
                                   <td align='right'>流水号:{0}</td>
                                 </tr>
                              </table>
                            </td>
                            <td></td>
                          </tr>
                          <tr>
                            <td colspan = '7'>---------------------------------------------------------------------------------------------------------------------------------------</td>
                          </tr>                          
                          <tr height=25px>
                            <td align='left'>业务类型</td>
                            <td align='left'>交易卡号</td>
                            <td align='left'>账户类型</td>
                            <td align='right'>原余额</td>
                            <td align='right'>发生金额</td>
                            <td align='right'>收费</td>
                            <td align='center'>其他</td>
                          </tr>
                          <tr height=25px>
                            <td align='left'>卡卡转账</td>
                            <td align='left'>{4}</td>
                            <td align='left'>钱包</td>
                            <td align='right'>{7}</td>
                            <td align='right'>-{6}</td>
                            <td align='right'>0</td>
                            <td align='center'></td>
                          </tr>
                          <tr height=25px>
                            <td align='left'></td>
                            <td align='left'>{5}</td>
                            <td align='left'>钱包</td>
                            <td align='right'>{8}</td>
                            <td align='right'>{6}</td>
                            <td align='right'>0</td>
                            <td align='center'></td>
                          </tr>
                          <tr height=85px>
                            <td colspan='7'></td> 
                          </tr>
                          <tr height=40px>
                            <td align='right' colspan='4'>客户签名：</td>
                            <td colspan='3'></td>
                          </tr>
                        </table>
                        ", tradeid, date, dept, staff, outcard, incard, money, outcardmoney, incardmoney);
        return html;
    }

    /// <summary>
    /// 读卡器打印
    /// </summary>
    static public string PrintReader(CmnContext context, string tradeid, string dept, string staff, bool showGuarantee,bool isbatch, string tradetype, string readerno, string readerno2,
                                           string occurmoney, string charge, string othermoney, string occurmoney2, string charge2, string othermoney2,string totalmoney)
    {
        string date = DateTime.Now.Year.ToString() + "-" + DateTime.Now.Month.ToString() + "-" + DateTime.Now.Day.ToString();
        string html = string.Format(
                      @"<div align='center' style='font-size:20px;height:35px'>苏州市民卡业务回单</div>
                        <table border=0 cellpadding=0 cellspacing=0 width=649px align='center' style='border:none;font-size:14px' class='data'>
                         <tr>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td width=76px></td>
                          </tr>
                          <tr height=25px>
                            <td colspan='6'>
                              <table width='100%' style='font-size:14px'>
                                 <tr>
                                   <td align='left'>日期:{1}</td>
                                   <td align='center'>网点:{2}</td>
                                   <td align='center'>操作员:{3}</td>
                                   <td align='right'>流水号:{0}</td>
                                 </tr>
                              </table>
                            </td>
                            <td></td>
                          </tr>
                          <tr>
                            <td colspan = '7'>---------------------------------------------------------------------------------------------------------------------------------------</td>
                          </tr>                          
                          <tr height=25px>
                            <td colspan='6'>
                              <table width='100%' style='font-size:14px'>
                                 <tr>						  
									<td width=135px align='left'>业务类型</td>
									<td width=120px align='left'>读卡器编号</td>
									<td width=100px align='right'>发生金额</td>
									<td width=111px align='right'>收费</td>
									<td width=107px align='center'>其他</td>
                                 </tr>
                              </table>
                            </td>	
                            <td></td>							
                          </tr>
                          <tr height=25px>
                            <td colspan='6'>
                              <table width='100%' style='font-size:14px'>
                                 <tr>							  
									<td width=135px align='left'>{4}</td>
									<td width=120px align='left'>{5}</td>
									<td width=100px align='right'>{6}</td>
									<td width=111px align='right'>{7}</td>
									<td width=107px align='center'>{11}</td>
                                 </tr>
                              </table>
                            </td>	
                            <td></td>	
                          </tr>
                          <tr height=25px>
                            <td colspan='6'>
                              <table width='100%' style='font-size:14px'>
                                 <tr>		
									<td width=135px align='left'></td>
									<td width=120px align='left'>{8}</td>
									<td width=100px align='right'>{9}</td>
									<td width=111px align='right'>{10}</td>
									<td width=107px align='center'>{12}</td>
                                 </tr>
                              </table>
                            </td>	
                            <td></td>	
                          </tr>
                          <tr height=25px></tr>
                        ", tradeid, date, dept, staff, tradetype, readerno, occurmoney, charge, readerno2, occurmoney2, charge2, othermoney, othermoney2);

        //显示保修须知
        if (showGuarantee)
        {
            html += @"  <tr>
                        <td colspan='7'>
					    <table width='100%' style='font-size:14px'>
                                <tr height=25px>
                                <td align='center' style='font-size:16px'>市民卡读卡器保修须知</td>
                                </tr>
							    <tr height=20px><td >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;本产品自出售日起7日内，若出现非人为故障，消费者可凭本单据选择退货或换货服务。</td></tr>
							    <tr height=20px><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;本产品自出售日起壹年内，若出现非人为损坏的故障，消费者可凭本单据在市民卡服务中心免费保修；</td></tr>
							    <tr height=20px><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;对于超出保修期或不符合免费保修服务的，我公司将提供维修服务，当维修需要更换零件或整机更换时，需收取相应费用；</td></tr>
                                <tr height=20px><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;在保修期内，如发生以下情况之一的将不在保修范围之内:</td></tr>
							    <tr height=20px><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;①一切人为因素或未按照使用说明进行操作使用造成故障或损坏的；②因产品跌落、浸水或其他溶液及本人使用不当造成产品故障及损坏的；③客户自行拆装、修理及改装造成损坏或故障的。</td></tr>
							    <tr height=20px><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;产品保修程序：客户使用中出现故障时，应携带本单据及产品至市民卡服务中心办理保修手续，详情请咨询客服热线：962026。</td></tr>
                            </table>
					    </td> 
                        </tr>
            ";
        }
        //计算总价
        if (isbatch)
        {

            html += string.Format(@"  <tr>
                        <td colspan='7'>
					    <table width='100%' style='font-size:14px'>
                                <tr height=25px>
                                <td align='left'>总金额：{0}</td>
                                </tr>
							</table>
					    </td> 
                        </tr>
                     ",totalmoney);
        }

        html += @" <tr height=40px>
                     <td align='right' colspan='7'>客户签名：___________________</td>
                   </tr>
                 </table>";

        return html;
    }
}