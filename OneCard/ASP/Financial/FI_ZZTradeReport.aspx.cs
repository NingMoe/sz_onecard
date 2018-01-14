using Common;
using Master;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NPOI.HSSF.UserModel;
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using TDO.BalanceParameter;
using TM;
public partial class ASP_Financial_FI_ZZTradeReport : Master.ExportMaster
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

            //从内部部门编码表(TD_M_INSIDEDEPART)中读取数据，放入下拉列表中

            UserCardHelper.selectDepts(context, selDept, true);
            UserCardHelper.selectAllStaffs(context, selStaff, selDept, true);
        }
    }


    #region Private
    protected void selDept_Changed(object sender, EventArgs e)
    {
        //查询选择部门名称后,设置员工姓名下拉列表值
        UserCardHelper.selectAllStaffs(context, selStaff, selDept, true);
    }

    #region validate
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
    #endregion

    #region queryData

    private Dictionary<string, string> DeclarePost()
    {
        Dictionary<string, string> postData = new Dictionary<string, string>();
        postData.Add("channelCode", "ONECARD");
        postData.Add("tradeType", selTradeType.SelectedValue);
        postData.Add("fromDate", txtFromDate.Text);
        postData.Add("toDate", txtToDate.Text);
        postData.Add("operateDepartId", selDept.SelectedValue);
        postData.Add("operateStaffNo", selStaff.SelectedValue);

        return postData;
    }

    private DataTable initEmptyDataTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("TRADETYPE", typeof(string));//业务类型
        dt.Columns.Add("CARDNO", typeof(string));//卡号
        dt.Columns.Add("OPERATETIME", typeof(string));//操作时间
        dt.Columns.Add("OPERATEDEPARTID", typeof(string));//操作部门号
        dt.Columns.Add("OPERATESTAFFNO", typeof(string));//操作员工号
        dt.Columns.Add("POSNO", typeof(string));//POS编号
        dt.Columns.Add("PSAMNO", typeof(string));//PSAM编号
        dt.Columns.Add("DETAILNO", typeof(string));//子订单号
        dt.Columns.Add("ORDERNO", typeof(string));//主订单号

        dt.Columns["TRADETYPE"].MaxLength = 100;
        dt.Columns["CARDNO"].MaxLength = 100;
        dt.Columns["OPERATETIME"].MaxLength = 100;
        dt.Columns["OPERATEDEPARTID"].MaxLength = 100;
        dt.Columns["OPERATESTAFFNO"].MaxLength = 100;
        dt.Columns["POSNO"].MaxLength = 100;
        dt.Columns["PSAMNO"].MaxLength = 100;
        dt.Columns["DETAILNO"].MaxLength = 100;
        dt.Columns["ORDERNO"].MaxLength = 100;

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

    #endregion


    #region protect Event
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //获取对应的业务类型
            ListItem listItem = selTradeType.Items.FindByValue(e.Row.Cells[0].Text);
            if (listItem != null)
            {
                e.Row.Cells[0].Text = listItem.Text.Substring(listItem.Text.IndexOf(':') + 1);
            }

            //获取对应的操作部门
            ListItem listDeptItem = selDept.Items.FindByValue(e.Row.Cells[3].Text);
            if (listDeptItem != null)
            {
                e.Row.Cells[3].Text = listDeptItem.Text.Substring(listDeptItem.Text.IndexOf(':') + 1);
            }

            //获取对应的操作员工
            ListItem listStaffItem = selStaff.Items.FindByValue(e.Row.Cells[4].Text);
            if (listStaffItem != null)
            {
                e.Row.Cells[4].Text = listStaffItem.Text.Substring(listStaffItem.Text.IndexOf(':') + 1);
            }

            DateTimeFormatInfo df = new System.Globalization.DateTimeFormatInfo();
            
            e.Row.Cells[2].Text = DateTime.ParseExact(e.Row.Cells[2].Text,"yyyyMMddHHmmss",System.Globalization.CultureInfo.InvariantCulture).ToString("yyyy-MM-dd HH:mm:ss", null);
        }
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        DataTable data = fillDataTable(HttpHelper.TradeType.ZZTradeQuery, DeclarePost());
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
    #endregion

}
