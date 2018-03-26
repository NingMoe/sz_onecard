using Common;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using TDO.BalanceParameter;
using TM;
public partial class ASP_Financial_FI_ZZPayCanalDataReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期

            TMTableModule tmTMTableModule = new TMTableModule();
            txtFromDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");

            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
        }
    }

    private double totalpostage = 0;            //邮费
    private double totalPayCanalMoney = 0;      //渠道总金额
    private double totalOpenTimes = 0;         //开通数量
    private double totalSupplyMoney = 0;        //充值金额
    private double totalfuncfee = 0;          //功能费
    private double totalCardPrice = 0;         //卡费合计
    private double totalOrderTotal = 0;         //订单总额
    private double totalActivatyDiscount = 0;   //直减优惠金额
    private double totaldiscount = 0;         //兑换券
    private double totalTransfee = 0;         //实际功能费
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {

            string orderType = "";

            switch (e.Row.Cells[3].Text)
            {
                case "1":
                    orderType = "(无卡办理)";
                    break;
                case "2":
                    orderType = "(兑换券)";
                    break;
                default:
                    orderType = "(类型异常)";
                    break;
            }


            switch (e.Row.Cells[4].Text)
            {
                case "Z1":
                    e.Row.Cells[4].Text = "200元24小时套餐" + orderType;
                    break;
                case "Z2":
                    e.Row.Cells[4].Text = "288元48小时套餐" + orderType;
                    break;
                default:
                    e.Row.Cells[4].Text = "套餐类型异常" + orderType;
                    break;
            }

            e.Row.Cells[1].Text = (Convert.ToDouble(GetTableCellValue(e.Row.Cells[1])) / 100.0).ToString();
            e.Row.Cells[2].Text = (Convert.ToDouble(GetTableCellValue(e.Row.Cells[2])) / 100.0).ToString();
            e.Row.Cells[5].Text = (Convert.ToDouble(GetTableCellValue(e.Row.Cells[5]))).ToString();
            e.Row.Cells[6].Text = (Convert.ToDouble(GetTableCellValue(e.Row.Cells[6])) / 100.0).ToString();
            e.Row.Cells[7].Text = (Convert.ToDouble(GetTableCellValue(e.Row.Cells[7])) / 100.0).ToString();
            e.Row.Cells[8].Text = (Convert.ToDouble(GetTableCellValue(e.Row.Cells[8])) / 100.0).ToString();
            e.Row.Cells[9].Text = (Convert.ToDouble(GetTableCellValue(e.Row.Cells[9])) / 100.0).ToString();
            e.Row.Cells[10].Text = (Convert.ToDouble(GetTableCellValue(e.Row.Cells[10])) / 100.0).ToString();
            e.Row.Cells[11].Text = (Convert.ToDouble(GetTableCellValue(e.Row.Cells[11])) / 100.0).ToString();
            e.Row.Cells[12].Text = (Convert.ToDouble(GetTableCellValue(e.Row.Cells[12])) / 100.0).ToString();

            //邮费和渠道总金额根据渠道次数汇总
            //已计算过该渠道则不再计算
            Hashtable hash = (Hashtable)Session["payCanalTimes"];
            if (hash.ContainsKey(e.Row.Cells[0].Text))
            {
                hash.Remove(e.Row.Cells[0].Text.ToString());
                totalpostage += Convert.ToDouble(GetTableCellValue(e.Row.Cells[1]));
                totalPayCanalMoney += Convert.ToDouble(GetTableCellValue(e.Row.Cells[2]));
            }

            totalOpenTimes += Convert.ToDouble(GetTableCellValue(e.Row.Cells[5]));
            totalSupplyMoney += Convert.ToDouble(GetTableCellValue(e.Row.Cells[6]));
            totalfuncfee += Convert.ToDouble(GetTableCellValue(e.Row.Cells[7]));
            totalCardPrice += Convert.ToDouble(GetTableCellValue(e.Row.Cells[8]));
            totalOrderTotal += Convert.ToDouble(GetTableCellValue(e.Row.Cells[9]));
            totalActivatyDiscount += Convert.ToDouble(GetTableCellValue(e.Row.Cells[10]));
            totaldiscount += Convert.ToDouble(GetTableCellValue(e.Row.Cells[11]));
            totalTransfee += Convert.ToDouble(GetTableCellValue(e.Row.Cells[12]));



            //获取部门编号对应的部门名称
            ListItem listItem = selTradeType.Items.FindByValue(e.Row.Cells[0].Text);
            if (listItem != null)
            {
                e.Row.Cells[0].Text = listItem.Text.Substring(listItem.Text.IndexOf(':') + 1);
            }

        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[1].Text = totalpostage.ToString();
            e.Row.Cells[2].Text = totalPayCanalMoney.ToString();
            e.Row.Cells[5].Text = totalOpenTimes.ToString();
            e.Row.Cells[6].Text = totalSupplyMoney.ToString();
            e.Row.Cells[7].Text = totalfuncfee.ToString();
            e.Row.Cells[8].Text = totalCardPrice.ToString();
            e.Row.Cells[9].Text = totalOrderTotal.ToString();
            e.Row.Cells[10].Text = totalActivatyDiscount.ToString();
            e.Row.Cells[11].Text = totaldiscount.ToString();
            e.Row.Cells[12].Text = totalTransfee.ToString();
        }

        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[3].Visible = false;
        }
    }

    protected void gvResult_PreRender(object sender, EventArgs e)
    {
        GridViewMergeHelper.MergeGridViewRows(gvResult, 0, 2);
    }

    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }
    // 查询输入校验处理
    private void validate()
    {
        Validation valid = new Validation(context);

        bool b = Validation.isEmpty(txtFromDate);
        DateTime? fromDate = null, toDate = null;
        if (!b)
        {
            fromDate = valid.beDate(txtFromDate, "开始日期范围起始值格式必须为yyyyMMdd");
        }
        b = Validation.isEmpty(txtToDate);
        if (!b)
        {
            toDate = valid.beDate(txtToDate, "结束日期范围终止值格式必须为yyyyMMdd");
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        }

    }

    private bool checkEndDate()
    {
        TP_DEALTIMETDO tdoTP_DEALTIMEIn = new TP_DEALTIMETDO();
        TP_DEALTIMETDO[] tdoTP_DEALTIMEOutArr = (TP_DEALTIMETDO[])tm.selByPKArr(context, tdoTP_DEALTIMEIn, typeof(TP_DEALTIMETDO), null, "DEALTIME", null);
        if (tdoTP_DEALTIMEOutArr.Length == 0)
        {
            context.AddError("没有找到有效的结算处理时间");
            return false;
        }
        else
        {
            DateTime dealDate = tdoTP_DEALTIMEOutArr[0].DEALDATE.Date;
            DateTime endDate = DateTime.ParseExact(txtToDate.Text.Trim(), "yyyyMMdd", null);
            if (endDate.CompareTo(dealDate) >= 0)
            {
                context.AddError("结束日期过大，未结算");
                return false;
            }
        }
        return true;
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        DataTable data = fillDataTable(HttpHelper.TradeType.ZZPayCanalDataQuery, DeclarePost());
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        UserCardHelper.resetData(gvResult, data);
    }


    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            ExportGridView(gvResult);
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }

    #region Private


    private Dictionary<string, string> DeclarePost()
    {
        Dictionary<string, string> postData = new Dictionary<string, string>();
        postData.Add("channelCode", "ONECARD");
        postData.Add("payCanal", selTradeType.SelectedValue);
        postData.Add("fromDate", txtFromDate.Text);
        postData.Add("toDate", txtToDate.Text);

        return postData;
    }

    private DataTable initEmptyPayCanalDataTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("PAYCANAL", typeof(string));//支付渠道
        dt.Columns.Add("POSTAGE", typeof(string));//邮费
        dt.Columns.Add("PAYCANALTOTALMONEY", typeof(string));//渠道总金额
        dt.Columns.Add("ORDERTYPE", typeof(string));//子订单类型
        dt.Columns.Add("PACKAGETYPE", typeof(string));//套餐类型
        dt.Columns.Add("OPENTIMES", typeof(string));//开通数量
        dt.Columns.Add("SUPPLYMONEY", typeof(string));//充值金额
        dt.Columns.Add("FUNCFEE", typeof(string));//功能费
        dt.Columns.Add("DISCOUNT", typeof(string));//兑换券优惠金额
        dt.Columns.Add("TRANSFEE", typeof(string));//实际功能费
        dt.Columns.Add("CARDPRICE", typeof(string));//卡费合计
        dt.Columns.Add("ORDERTOTAL", typeof(string));//订单总额
        dt.Columns.Add("ACTIVITYDISCOUNT", typeof(string));//直减优惠金额

        dt.Columns["PAYCANAL"].MaxLength = 10000;
        dt.Columns["POSTAGE"].MaxLength = 10000;
        dt.Columns["PAYCANALTOTALMONEY"].MaxLength = 10000;
        dt.Columns["ORDERTYPE"].MaxLength = 10000;
        dt.Columns["PACKAGETYPE"].MaxLength = 10000;
        dt.Columns["OPENTIMES"].MaxLength = 10000;
        dt.Columns["SUPPLYMONEY"].MaxLength = 10000;
        dt.Columns["FUNCFEE"].MaxLength = 10000;
        dt.Columns["DISCOUNT"].MaxLength = 10000;
        dt.Columns["TRANSFEE"].MaxLength = 10000;
        dt.Columns["CARDPRICE"].MaxLength = 10000;
        dt.Columns["ORDERTOTAL"].MaxLength = 10000;
        dt.Columns["ACTIVITYDISCOUNT"].MaxLength = 10000;

        return dt;
    }


    private DataTable fillDataTable(HttpHelper.TradeType tradetype, Dictionary<string, string> postData)
    {
        Session["payCanalTimes"] = null;
        string jsonResponse = HttpHelper.ZZPostRequest(tradetype, postData);

        //解析json
        Hashtable hash = new Hashtable();
        DataTable dtPayCanal = initEmptyPayCanalDataTable();
        JObject deserObject = (JObject)JsonConvert.DeserializeObject(jsonResponse);
        string code = "";
        string message = "";
        foreach (JProperty itemProperty in deserObject.Properties())
        {
            string propertyName = itemProperty.Name;
            if (propertyName == "respCode")
            {
                code = itemProperty.Value.ToString();
            }
            else if (propertyName == "respDesc")
            {
                message = itemProperty.Value.ToString();
            }
            else if (propertyName == "tradeColl")
            {
                if (itemProperty.Value == null)
                {
                    context.AddMessage("查询结果为空");
                    return null;
                }
            }
        }

        if (code == "0000") //表示成功
        {
            foreach (JProperty itemProperty in deserObject.Properties())
            {
                string propertyName = itemProperty.Name;
                if (propertyName == "payCanalColl")
                {
                    //DataTable赋值
                    JArray detailArray = new JArray();
                    try
                    {
                        detailArray = (JArray)itemProperty.Value;
                    }
                    catch (Exception)
                    {
                        context.AddMessage("查询结果为空");
                        return new DataTable();
                    }
                    foreach (JObject subItem in detailArray)
                    {
                        DataRow newRow = dtPayCanal.NewRow();

                        string payCanal = "";
                        string postage = "";
                        string payCanalTotalMoney = "";
                        foreach (JProperty subItemJProperty in subItem.Properties())
                        {
                            if (subItemJProperty.Name == "payCanal")
                            {
                                payCanal = subItemJProperty.Value.ToString();
                            }
                            else if (subItemJProperty.Name == "postAge")
                            {
                                postage = subItemJProperty.Value.ToString();
                            }
                            else if (subItemJProperty.Name == "payCanalTotalMoney")
                            {
                                payCanalTotalMoney = subItemJProperty.Value.ToString();
                            }
                            if (subItemJProperty.Name != "payCanalDataList")
                            {
                                newRow[subItemJProperty.Name] = subItemJProperty.Value.ToString();
                            }
                            if (subItemJProperty.Name == "payCanalDataList")
                            {
                                JArray payCanalDataList = new JArray();
                                try
                                {
                                    payCanalDataList = (JArray)subItemJProperty.Value;
                                }
                                catch (Exception)
                                {
                                    break;
                                    //context.AddMessage("查询结果为空");
                                    //return new DataTable();
                                }
                                //处理第二级集合
                                int index = 0;
                                foreach (JObject item in payCanalDataList)
                                {
                                    index++;
                                    //hash记录渠道对应套餐类型个数
                                    if (hash.ContainsKey(payCanal))
                                    {
                                        hash[payCanal] = index;
                                    }
                                    else
                                    {
                                        hash.Add(payCanal, index);
                                    }
                                    if (index > 1)
                                    {
                                        newRow = dtPayCanal.NewRow();
                                        newRow["PAYCANAL"] = payCanal;
                                        newRow["POSTAGE"] = postage;
                                        newRow["PAYCANALTOTALMONEY"] = payCanalTotalMoney;
                                    }
                                    foreach (JProperty payCanalPro in item.Properties())
                                    {
                                        string name = payCanalPro.Name;
                                        string value = payCanalPro.Value.ToString();
                                        newRow[payCanalPro.Name] = payCanalPro.Value.ToString();
                                    }
                                    dtPayCanal.Rows.Add(newRow);
                                }
                            }
                        }
                        //dtPayCanal.Rows.Add(newRow);
                    }
                }
            }
        }
        else
        {
            context.AddError(message);
        }
        Session["payCanalTimes"] = hash;

        return dtPayCanal;
    }

    #endregion
}
