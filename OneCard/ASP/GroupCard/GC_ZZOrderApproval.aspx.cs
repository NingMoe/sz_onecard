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

        //驳回状态正常的可以驳回
        if (selOrderStates.SelectedValue == "1")
        {
            btnRollBack.Enabled = true;
        }
        //驳回状态不是正常的可以撤销驳回驳回
        if (selOrderStates.SelectedValue == "0")
        {
            btnRevoke.Enabled = true;

            selRemark.SelectedValue = "";
            txtRemark.Text = "";
            txtRemark.Visible = false;
        }
    }

    private Dictionary<string, string> PostQuery()
    {
        Dictionary<string, string> postData = new Dictionary<string, string>();
        postData.Add("", "");
        return postData;
    }

    protected void gvOrderList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            HtmlImage imgP = (HtmlImage)e.Row.FindControl("imgPerson");
            string photoType = "PHTOT";
            imgP.Src = "GC_ZZShowGetPicture.aspx?orderDetailId=" + e.Row.Cells[21].Text + "&photoType=" + photoType;
            imgP.Attributes.Add("onclick", "CreateWindow('RoleWindow','GC_ZZShowPicture.aspx?orderDetailId=" + e.Row.Cells[21].Text + "&photoType=" + photoType + "');");
            
        }
    }

    //分页
    protected void Link_Click(object sender, CommandEventArgs e)
    {
        ViewState["page"] = e.CommandArgument.ToString();
        ShowFileContent();
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
        int iPerPage = 10;
        int begin = (page - 1) * iPerPage + 1;
        int end = page * iPerPage + 1;
        string[] parm = new string[8];
        parm[0] = selOrderType.SelectedValue;
        parm[1] = txtOrderNo.Text;
        parm[2] = txtFromDate.Text;
        parm[3] = txtToDate.Text;
        parm[4] = selOrderStates.SelectedValue;
        parm[5] = selPayCanal.SelectedValue;
        parm[6] = begin.ToString();
        parm[7] = end.ToString();

        Dictionary<string, string> postData = new Dictionary<string, string>();
        postData.Add("orderid", txtOrderNo.Text);
        postData.Add("fromdate", txtFromDate.Text);
        postData.Add("todate", txtToDate.Text);
        postData.Add("rejecttype", selOrderStates.SelectedValue);
        postData.Add("paycanal", selPayCanal.SelectedValue);
        postData.Add("beginindex", begin.ToString());
        postData.Add("endindex", end.ToString());
        iCount = GetListCount(HttpHelper.TradeType.ZZOrderQuery,postData);
        DataTable table = fillDataTable(HttpHelper.TradeType.ZZOrderQuery, postData);
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

    private int GetListCount(HttpHelper.TradeType tradetype,Dictionary<string, string> postData)
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
            else if(propertyName == "listCount")
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
        dt.Columns.Add("DETAILID", typeof(string));//子订单号
        dt.Columns.Add("ORDERID", typeof(string));//订单号
        dt.Columns.Add("ORDERSTATE", typeof(string));//订单类型
        dt.Columns.Add("REJECTTYPE", typeof(string));//驳回状态
        dt.Columns.Add("CARDNO", typeof(string));//卡号
        dt.Columns.Add("PACKAGEENDTIME", typeof(string));//套餐有效期
        dt.Columns.Add("ACTIVEENDTIME", typeof(string));//激活有效期
        dt.Columns.Add("RECEIVECUSTNAME", typeof(string));//收件人
        dt.Columns.Add("RECEIVEADRESS", typeof(string));//收货地址
        dt.Columns.Add("RECEIVECUSTPHONE", typeof(string));//收件人电话
        dt.Columns.Add("CUSTNAME ", typeof(string));//持卡人姓名
        dt.Columns.Add("PAPERNO", typeof(string));//持卡人证件号码
        dt.Columns.Add("CUSTPHONE", typeof(string));//持卡人电话
        dt.Columns.Add("FETCHTYPE", typeof(string));//取货方式
        dt.Columns.Add("POSTAGE", typeof(string));//邮费
        dt.Columns.Add("FETCHCODE", typeof(string));//取件码
        dt.Columns.Add("TRACKINGNO", typeof(string));//物流号
        dt.Columns.Add("LOGISTICSCOMPANY", typeof(string));//物流公司
        dt.Columns.Add("PACKAGEMONEY", typeof(string));//套餐金额
        dt.Columns.Add("SUPPLYMONEY", typeof(string));//充值金额

        dt.Columns["DETAILID"].MaxLength = 10000;
        dt.Columns["ORDERID"].MaxLength = 10000;
        dt.Columns["ORDERSTATE"].MaxLength = 10000;
        dt.Columns["REJECTTYPE"].MaxLength = 10000;
        dt.Columns["CARDNO"].MaxLength = 10000;
        dt.Columns["PACKAGEENDTIME"].MaxLength = 10000;
        dt.Columns["ACTIVEENDTIME"].MaxLength = 10000;
        dt.Columns["RECEIVECUSTNAME"].MaxLength = 10000;
        dt.Columns["RECEIVEADRESS"].MaxLength = 10000;
        dt.Columns["RECEIVECUSTPHONE"].MaxLength = 10000;
        dt.Columns["CUSTNAME"].MaxLength = 10000;
        dt.Columns["PAPERNO"].MaxLength = 10000;
        dt.Columns["CUSTPHONE"].MaxLength = 10000;
        dt.Columns["FETCHTYPE"].MaxLength = 10000;
        dt.Columns["POSTAGE"].MaxLength = 10000;
        dt.Columns["FETCHCODE"].MaxLength = 10000;
        dt.Columns["TRACKINGNO"].MaxLength = 10000;
        dt.Columns["LOGISTICSCOMPANY"].MaxLength = 10000;
        dt.Columns["PACKAGEMONEY"].MaxLength = 10000;
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
        }

        if (code == "0000") //表示成功
        {
            foreach (JProperty itemProperty in deserObject.Properties())
            {
                string propertyName = itemProperty.Name;
                if (propertyName == "data")
                {
                    //DataTable赋值
                    JArray detailArray = (JArray)itemProperty.Value;
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
        //清空临时表信息

        clearTempTable();

        //选择审核的订单和账单入临时表
        if (!RecordIntoTmp()) return;

        context.SPOpen();
        context.AddField("p_sessionID").Value = Session.SessionID;

        bool ok = context.ExecuteSP("SP_GC_RELAXORDERBACK");

        if (ok)
        {
            AddMessage("回退成功");

            InvokeApp();    //调用手机端APP
            btnQuery_Click(sender, e);
        }
    }

    // 撤销回退
    protected void btnRevoke_Click(object sender, EventArgs e)
    {
        //清空临时表信息

        clearTempTable();

        //选择审核的订单和账单入临时表
        if (!RecordIntoTmp()) return;

        context.SPOpen();
        context.AddField("p_sessionID").Value = Session.SessionID;

        bool ok = context.ExecuteSP("SP_GC_RELAXORDERREVOKE");

        if (ok)
        {
            AddMessage("撤销回退成功");

            InvokeApp();    //调用手机端APP
            btnQuery_Click(sender, e);
        }

    }

    /// <summary>
    /// 调用手机APP端
    /// </summary>
    private void InvokeApp()
    {
        string msg = RelaxWebServiceHelper.RelaxOrderTypeInfo(GetTMPRelax());
        //if (msg != "0000")
        //{
        //    context.AddError(msg);
        //}
        //else
        //{
        //    context.AddMessage("调用手机端成功");
        //}
    }

    private void clearTempTable()//清空临时表
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_ORDER where f0 = '" + Session.SessionID + "'");
        context.DBCommit();
    }

    //选中记录入临时表
    private bool RecordIntoTmp()
    {
        context.DBOpen("Insert");
        int ordercount = 0;

        List<string> company = new List<string>();
        foreach (GridViewRow gvr in gvOrderList.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkOrderList");
            if (cb != null && cb.Checked)
            {
                ordercount++;
                //订单记录入临时表
                context.ExecuteNonQuery("insert into TMP_ORDER (F0,F1,F2,F3) values('" +
                     Session.SessionID + "', '" + gvr.Cells[19].Text + "','" + gvr.Cells[21].Text + "', '" + selRemark.SelectedItem.Text + "')");
            }
        }
        //校验是否选择了订单

        if (ordercount <= 0)
        {
            context.AddError("请选择订单！");
            context.RollBack();
            return false;
        }
        if (context.hasError())
        {
            context.RollBack();
            return false;
        }
        context.DBCommit();
        return true;
    }

    /// <summary>
    /// 获取休闲数据用以发起休闲订单状态变更
    /// </summary>
    /// <returns></returns>
    private DataTable GetTMPRelax()
    {
        DataTable dt = GroupCardHelper.callQuery(context, "QueryTMPRelax", Session.SessionID);
        return dt;
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
}
