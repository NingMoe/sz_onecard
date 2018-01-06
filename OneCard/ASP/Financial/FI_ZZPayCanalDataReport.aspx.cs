using Common;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
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
            txtToDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");

            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
        }
    }

    private int totalopentimes = 0;           //开通数量
    private double totalcardcost = 0;         //卡费
    private double totalfuncfee = 0;          //功能费
    private double totalptdiscount = 0;         //优惠金额
    private double totaldhdiscount = 0;         //优惠金额
    private double totalpostage = 0;          //邮费
    private double totalorderfee = 0;         //实际功能费
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            totalopentimes += Convert.ToInt32(GetTableCellValue(e.Row.Cells[2]));
            totalcardcost += Convert.ToDouble(GetTableCellValue(e.Row.Cells[3]));
            totalfuncfee += Convert.ToDouble(GetTableCellValue(e.Row.Cells[4]));
            totalptdiscount += Convert.ToDouble(GetTableCellValue(e.Row.Cells[5]));
            totaldhdiscount += Convert.ToDouble(GetTableCellValue(e.Row.Cells[6]));
            totalpostage += Convert.ToDouble(GetTableCellValue(e.Row.Cells[7]));
            totalorderfee += Convert.ToDouble(GetTableCellValue(e.Row.Cells[8]));
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[0].ColumnSpan = 2;
            e.Row.Cells[1].Visible = false;
            e.Row.Cells[2].Text = totalopentimes.ToString();
            e.Row.Cells[3].Text = totalcardcost.ToString();
            e.Row.Cells[4].Text = totalfuncfee.ToString();
            e.Row.Cells[5].Text = totalptdiscount.ToString();
            e.Row.Cells[6].Text = totaldhdiscount.ToString();
            e.Row.Cells[7].Text = totalpostage.ToString();
            e.Row.Cells[8].Text = totalorderfee.ToString();
        }
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
        
        DataTable data= fillDataTable(HttpHelper.TradeType.ZZOrderCardQuery, DeclarePost());
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
        postData.Add("tradeType", selTradeType.SelectedValue);
        postData.Add("fromDate", txtFromDate.Text);
        postData.Add("toDate", txtToDate.Text);

        return postData;
    }

    private DataTable initEmptyDataTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("TRADETYPE", typeof(string));//业务类型
        dt.Columns.Add("CARDNO", typeof(string));//卡号
        dt.Columns.Add("OPERATETIME", typeof(string));//操作时间
        dt.Columns.Add("OPERATEDEPARTID", typeof(string));//操作部门号
        dt.Columns.Add("STAFFNO", typeof(string));//操作员工号
        dt.Columns.Add("POSNO", typeof(string));//POS编号
        dt.Columns.Add("PSAMNO", typeof(string));//PSAM编号

        dt.Columns["TRADETYPE"].MaxLength = 10000;
        dt.Columns["CARDNO"].MaxLength = 10000;
        dt.Columns["OPERATETIME"].MaxLength = 10000;
        dt.Columns["OPERATEDEPARTID"].MaxLength = 10000;
        dt.Columns["STAFFNO"].MaxLength = 10000;
        dt.Columns["POSNO"].MaxLength = 10000;
        dt.Columns["PSAMNO"].MaxLength = 10000;

        return dt;
    }

    private DataTable fillDataTable(HttpHelper.TradeType tradetype, Dictionary<string, string> postData)
    {
        string jsonResponse = HttpHelper.ZZPostRequest(tradetype, postData);
        //解析json
        DataTable dt = initEmptyDataTable();
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
                if (propertyName == "tradeColl")
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
                        DataRow newRow = dt.NewRow();
                        foreach (JProperty subItemJProperty in subItem.Properties())
                        {
                            newRow[subItemJProperty.Name] = subItemJProperty.Value.ToString();
                        }
                        dt.Rows.Add(newRow);
                    }
                }
            }
        }
        else
        {
            context.AddError(message);
        }
        return dt;
    }

    #endregion
}
