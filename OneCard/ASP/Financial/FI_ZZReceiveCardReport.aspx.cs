using Common;
using Master;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NPOI.HSSF.UserModel;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using TDO.BalanceParameter;
using TDO.UserManager;
using TM;
public partial class ASP_Financial_FI_ZZReceiveCardReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期

            txtFromDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");


            gvResult.DataSource = new DataTable();
            gvResult.DataBind();

            //从内部部门编码表(TD_M_INSIDEDEPART)中读取数据，放入下拉列表中

            UserCardHelper.selectDepts(context, selDept, true);
            UserCardHelper.selectAllStaffs(context, selStaff, selDept, true);
        }
    }


    #region private

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
        postData.Add("operateDepartId", selDept.SelectedValue);
        postData.Add("operateStaffNo", selStaff.SelectedValue);
        postData.Add("fromDate", txtFromDate.Text);
        postData.Add("toDate", txtToDate.Text);

        return postData;
    }

    private DataTable initEmptyDataTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("DETAILNO", typeof(string));//子订单号
        dt.Columns.Add("ORDERNO", typeof(string));//主订单号
        dt.Columns.Add("CARDNO", typeof(string));//卡号
        dt.Columns.Add("OPERATETIME", typeof(string));//领卡时间
        dt.Columns.Add("PACKAGENAME", typeof(string));//套餐类型
        dt.Columns.Add("OPERATEDEPARTID", typeof(string));//操作部门号
        dt.Columns.Add("OPERATESTAFFNO", typeof(string));//操作员工号

        dt.Columns["DETAILNO"].MaxLength = 100;
        dt.Columns["ORDERNO"].MaxLength = 100;
        dt.Columns["CARDNO"].MaxLength = 100;
        dt.Columns["OPERATETIME"].MaxLength = 100;
        dt.Columns["PACKAGENAME"].MaxLength = 100;
        dt.Columns["OPERATEDEPARTID"].MaxLength = 100;
        dt.Columns["OPERATESTAFFNO"].MaxLength = 100;

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
            else if (propertyName == "receiveCardList")
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
                if (propertyName == "receiveCardList")
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

    protected void selDept_Changed(object sender, EventArgs e)
    {
        //查询选择部门名称后,设置员工姓名下拉列表值
        UserCardHelper.selectAllStaffs(context, selStaff, selDept, true);
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            switch (e.Row.Cells[4].Text)
            {
                case "Z1":
                    e.Row.Cells[4].Text = "200元24小时套餐";
                    break;
                case "Z2":
                    e.Row.Cells[4].Text = "288元48小时套餐";
                    break;
                default:
                    e.Row.Cells[4].Text = "套餐类型异常";
                    break;
            }

            //获取部门编号对应的部门名称
            ListItem listItem = selDept.Items.FindByValue(e.Row.Cells[5].Text);
            if (listItem != null)
            {
                e.Row.Cells[5].Text = listItem.Text.Substring(listItem.Text.IndexOf(':') + 1);
            }

            //获取员工编号对应的员工名称
            listItem = selStaff.Items.FindByValue(e.Row.Cells[6].Text);
            if (listItem != null)
            {
                e.Row.Cells[6].Text = listItem.Text.Substring(listItem.Text.IndexOf(':') + 1);
            }

            e.Row.Cells[3].Text = DateTime.ParseExact(e.Row.Cells[3].Text, "yyyyMMddHHmmss", System.Globalization.CultureInfo.InvariantCulture).ToString("yyyy-MM-dd HH:mm:ss", null);
        }
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        DataTable data = fillDataTable(HttpHelper.TradeType.ZZReceiveCardQuery, DeclarePost());
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
