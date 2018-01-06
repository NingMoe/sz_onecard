using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TDO.UserManager;
using System.Web.UI.HtmlControls;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;


public partial class ASP_GroupCard_GC_ZZOrderApproval : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtFromDate.Text = DateTime.Now.AddMonths(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Now.ToString("yyyyMMdd");

            gvOrderList.DataSource = new DataTable();
            gvOrderList.DataBind();

            previousLink.Visible = false;
            nextLink.Visible = false;
        }

    }

    protected void selRemark_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (selRemark.SelectedValue == "03")
            txtRemark.Visible = true;
        else
            txtRemark.Visible = false;
    }
    protected void gvOrderList_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    protected void gvOrderList_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvOrderList','Select$" + e.Row.RowIndex + "')");
        }
    }

    /// <summary>
    /// 查询验证
    /// </summary>
    /// <returns></returns>
    private bool ValidInput()
    {
        //校验联系人长度
        if (!string.IsNullOrEmpty(txtOrderNo.Text) && !Validation.isCharNum(txtOrderNo.Text))
        {
            context.AddError("A094780090:订单号只能为英数");
        }

        //对开始日期和结束日期的判断

        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, false);
        return !(context.hasError());
    }

    /// <summary>
    /// 查询订单按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!ValidInput()) return;

        gvOrderList.DataSource = new DataTable();
        gvOrderList.DataBind();

        string fromDate = txtFromDate.Text.Trim();
        string endDate = txtToDate.Text.Trim();

        previousLink.Visible = true;
        nextLink.Visible = true;
        ShowFileContent();

        btnRollBack.Enabled = false;
        btnRevoke.Enabled = false;

        gvOrderList.SelectedIndex = -1;
        //驳回状态正常的可以驳回
        if (selOrderStates.SelectedValue == "0")
        {
            btnRollBack.Enabled = true;
        }
        //驳回状态不是正常的可以撤销驳回驳回
        if (selOrderStates.SelectedValue == "1")
        {
            btnRevoke.Enabled = true;

            selRemark.SelectedValue = "";
            txtRemark.Text = "";
            txtRemark.Visible = false;
        }
    }
    

    protected void gvOrderList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            HtmlImage imgP = (HtmlImage)e.Row.FindControl("imgPerson");
            imgP.Src = "GC_ZZShowGetPicture.aspx?orderDetailId=" + e.Row.Cells[11].Text;
            //imgP.Attributes.Add("onclick", "CreateWindow('RoleWindow','GC_ZZShowPicture.aspx?orderDetailId=" + e.Row.Cells[11].Text + "');");

            switch (e.Row.Cells[1].Text)
            {
                case "0":
                    e.Row.Cells[1].Text = "未处理";
                    break;
                case "1":
                    e.Row.Cells[1].Text = "已制卡";
                    break;
                case "2":
                    e.Row.Cells[1].Text = "已发货";
                    break;
                default:
                    e.Row.Cells[1].Text = "状态异常";
                    break;
            }

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

            switch (e.Row.Cells[12].Text)
            {
                case "0":
                    e.Row.Cells[12].Text = "0";
                    break;
                default:
                    e.Row.Cells[12].Text = (Convert.ToDecimal(e.Row.Cells[12].Text) / 100).ToString();
                    break;
            }
        }
    }

    //分页
    protected void Link_Click(object sender, CommandEventArgs e)
    {
        ViewState["page"] = e.CommandArgument.ToString();
        ShowFileContent();
    }
    private Dictionary<string, string> DeclarePost(int begin, int end)
    {
        Dictionary<string, string> postData = new Dictionary<string, string>();
        postData.Add("channelCode", "ONECARD");
        postData.Add("orderNo", txtOrderNo.Text);
        postData.Add("fromDate", txtFromDate.Text);
        postData.Add("toDate", txtToDate.Text);
        postData.Add("rejectType", selOrderStates.SelectedValue);
        postData.Add("payCanal", selPayCanal.SelectedValue);
        postData.Add("beginIndex", begin.ToString());
        postData.Add("endIndex", end.ToString());
        postData.Add("orderState", "");
        postData.Add("fetchType", "");

        return postData;
    }

    //显示文件内容
    public void ShowFileContent()
    {
        // 指定的页数
        int page = 1;
        if (ViewState["page"] != null && !string.IsNullOrEmpty(ViewState["page"].ToString()))
            page = Int32.Parse(ViewState["page"].ToString());

        //总数
        int iCount = 0;
        //每页数量
        int iPerPage = 5;
        int begin = (page - 1) * iPerPage + 1;
        int end = page * iPerPage + 1;


        iCount = GetListCount(HttpHelper.TradeType.ZZOrderCardCount, DeclarePost(begin, end));
        DataTable table = fillDataTable(HttpHelper.TradeType.ZZOrderCardQuery, DeclarePost(begin, end));
        if (table.Rows.Count > 0)
        {
            gvOrderList.DataSource = table;
            gvOrderList.DataBind();
        }
        // 页数
        int iPagecount = 1;
        iPagecount = (int)Math.Ceiling((double)iCount / (double)iPerPage);
        // 显示页控件
        // 设置页
        if (iPagecount > 1)
        {
            int currentPage = page;
            // 前一页
            if (currentPage == 1)
            {
                previousLink.Enabled = false;
            }
            else
            {
                previousLink.Enabled = true;
                previousLink.CommandArgument = (currentPage - 1).ToString();
            }
            // 下一页
            if (currentPage == iPagecount)
            {
                nextLink.Enabled = false;
            }
            else
            {
                nextLink.Enabled = true;
                nextLink.CommandArgument = (currentPage + 1).ToString();
            }
        }
        else
        {
            previousLink.Visible = false;
            nextLink.Visible = false;
        }
    }

    private int GetListCount(HttpHelper.TradeType tradetype, Dictionary<string, string> postData)
    {
        string jsonResponse = HttpHelper.ZZPostRequest(tradetype, postData);

        string code = "";
        string message = "";
        string listCount = "";
        JObject deserObject = (JObject)JsonConvert.DeserializeObject(jsonResponse);
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
            else if (propertyName == "listCount")
            {
                listCount = itemProperty.Value.ToString();
            }
        }
        int count = 0;
        if (code == "0000") //表示成功
        {
            count = Int32.Parse(listCount);
        }
        return count;
    }

    private DataTable initEmptyDataTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("DETAILNO", typeof(string));//子订单号
        dt.Columns.Add("ORDERNO", typeof(string));//订单号
        dt.Columns.Add("ORDERSTATE", typeof(string));//订单类型
        dt.Columns.Add("REJECTTYPE", typeof(string));//驳回状态
        dt.Columns.Add("CARDNO", typeof(string));//卡号
        dt.Columns.Add("PACKAGENAME", typeof(string));//套餐类型
        dt.Columns.Add("RECEIVECUSTNAME", typeof(string));//收件人
        dt.Columns.Add("RECEIVEADDRESS", typeof(string));//收货地址
        dt.Columns.Add("RECEIVECUSTPHONE", typeof(string));//收件人电话
        dt.Columns.Add("CUSTNAME", typeof(string));//持卡人姓名
        dt.Columns.Add("PAPERNO", typeof(string));//持卡人证件号码
        dt.Columns.Add("CUSTPHONE", typeof(string));//持卡人电话
        dt.Columns.Add("SUPPLYMONEY", typeof(string));//充值金额

        dt.Columns["DETAILNO"].MaxLength = 10000;
        dt.Columns["ORDERNO"].MaxLength = 10000;
        dt.Columns["ORDERSTATE"].MaxLength = 10000;
        dt.Columns["REJECTTYPE"].MaxLength = 10000;
        dt.Columns["CARDNO"].MaxLength = 10000;
        dt.Columns["PACKAGENAME"].MaxLength = 10000;
        dt.Columns["RECEIVECUSTNAME"].MaxLength = 10000;
        dt.Columns["RECEIVEADDRESS"].MaxLength = 10000;
        dt.Columns["RECEIVECUSTPHONE"].MaxLength = 10000;
        dt.Columns["CUSTNAME"].MaxLength = 10000;
        dt.Columns["PAPERNO"].MaxLength = 10000;
        dt.Columns["CUSTPHONE"].MaxLength = 10000;
        dt.Columns["SUPPLYMONEY"].MaxLength = 10000;

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
            else if (propertyName == "orderCardList")
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
                if (propertyName == "orderCardList")
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
                        //newRow["AccountId"] = hidAccountId.Value;
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

    // 回退
    protected void btnRollBack_Click(object sender, EventArgs e)
    {

        if (gvOrderList.SelectedIndex == -1)
        {
            context.AddError("当前未选择订单消息");
            return;
        }
        synMsg(sender, e, "1");
    }


    // 撤销回退
    protected void btnRevoke_Click(object sender, EventArgs e)
    {
        if (gvOrderList.SelectedIndex == -1)
        {
            context.AddError("当前未选择订单消息");
            return;
        }
        synMsg(sender, e, "0");
    }

    /// <summary>
    /// 提交同步信息
    /// </summary>
    /// <param name="orderType"></param>
    private void synMsg(object sender, EventArgs e, string orderType)
    {

        string orderid = gvOrderList.SelectedRow.Cells[0].Text.ToString();
        string detailId = gvOrderList.SelectedRow.Cells[11].Text.ToString();
        string cardNo = gvOrderList.SelectedRow.Cells[2].Text.ToString();
        string rejectType = orderType;
        string logisticsCompany = "";
        string trackingNo = "";
        string operateStaffNo = context.s_UserID;
        string operateDepartId = context.s_DepartID;
        string remark = "";

        Dictionary<string, string> postData = new Dictionary<string, string>();
        postData.Add("channelCode", "ONECARD");
        postData.Add("orderNo", orderid);
        postData.Add("detailNo", detailId);
        postData.Add("cardNo", cardNo);
        postData.Add("orderState", "");
        postData.Add("rejectType", rejectType);
        postData.Add("logisticsCompany", logisticsCompany);
        postData.Add("trackingNo", trackingNo);
        postData.Add("operateStaffNo", operateStaffNo);
        postData.Add("operateDepartId", operateDepartId);
        postData.Add("remark", remark);

        string jsonResponse = HttpHelper.ZZPostRequest(HttpHelper.TradeType.ZZOrderChange, postData);

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
        }

        if (code == "0000") //表示成功
        {
            context.AddMessage("处理成功");
            btnQuery_Click(sender, e);
        }
        else
        {
            context.AddMessage("处理失败,失败原因：" + message);
        }
    }
}
