using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TDO.BusinessCode;
using TM;
using System.Web;
using System.IO;
using NPOI.HSSF.UserModel;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json;


public partial class ASP_GroupCard_GC_ZZOrderDistrabution : Master.FrontMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
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
        gvList.DataSource = new DataTable();
        gvList.DataBind();

        if (!ValidInput()) return;

        DataTable table = GetQueryTable();
        if (table == null || table.Rows.Count < 1)
        {
            gvOrder.DataSource = new DataTable();
            gvOrder.DataBind();
            context.AddError("未查出记录");
            return;
        }
        gvOrder.DataSource = table;
        gvOrder.DataBind();

        //订单状态为制卡则启用配送按钮
        if (selOrderStates.SelectedValue == "1")
        {
            btnDistrabution.Enabled = true;
        }
        if (selOrderStates.SelectedValue == "0")
        {
            btnPrint.Enabled = false;
        }
    }

    private DataTable initEmptyDataTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("ORDERNO", typeof(string));//主订单号
        dt.Columns.Add("ORDERSTATE", typeof(string));//订单状态
        dt.Columns.Add("RECEIVECUSTNAME", typeof(string));//收件人
        dt.Columns.Add("RECEIVEADDRESS", typeof(string));//收货地址
        dt.Columns.Add("RECEIVECUSTPHONE", typeof(string));//收件人电话
        dt.Columns.Add("CUSTPOST", typeof(string));//邮编
        dt.Columns.Add("CREATETIME", typeof(string));//订单录入时间
        dt.Columns.Add("TRACKINGCOPCODE", typeof(string));//快递公司
        dt.Columns.Add("TRACKINGNO", typeof(string));//快递编号

        dt.Columns["ORDERNO"].MaxLength = 10000;
        dt.Columns["ORDERSTATE"].MaxLength = 10000;
        dt.Columns["RECEIVECUSTNAME"].MaxLength = 10000;
        dt.Columns["RECEIVEADDRESS"].MaxLength = 10000;
        dt.Columns["RECEIVECUSTPHONE"].MaxLength = 10000;
        dt.Columns["CUSTPOST"].MaxLength = 10000;
        dt.Columns["CREATETIME"].MaxLength = 10000;
        dt.Columns["TRACKINGNO"].MaxLength = 10000;
        dt.Columns["TRACKINGCOPCODE"].MaxLength = 10000;

        return dt;
    }

    private DataTable initEmptyListDataTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("DETAILNO", typeof(string));//子订单号
        dt.Columns.Add("ORDERNO", typeof(string));//主订单号
        dt.Columns.Add("CARDNO", typeof(string));//卡号
        dt.Columns.Add("PACKAGENAME", typeof(string));//套餐类型
        dt.Columns.Add("SUPPLYMONEY", typeof(string));//充值金额，单位分
        dt.Columns.Add("CUSTNAME", typeof(string));//持卡人姓名
        dt.Columns.Add("PAPERNO", typeof(string));//持卡人证件号码
        dt.Columns.Add("CUSTPHONE", typeof(string));//持卡人电话
        dt.Columns.Add("CREATETIME", typeof(string));//订单录入时间

        dt.Columns["DETAILNO"].MaxLength = 10000;
        dt.Columns["ORDERNO"].MaxLength = 10000;
        dt.Columns["CARDNO"].MaxLength = 10000;
        dt.Columns["PACKAGENAME"].MaxLength = 10000;
        dt.Columns["SUPPLYMONEY"].MaxLength = 10000;
        dt.Columns["CUSTNAME"].MaxLength = 10000;
        dt.Columns["PAPERNO"].MaxLength = 10000;
        dt.Columns["CUSTPHONE"].MaxLength = 10000;
        dt.Columns["CREATETIME"].MaxLength = 10000;

        return dt;
    }

    private DataTable fillDataTable(string orderType, HttpHelper.TradeType tradetype, Dictionary<string, string> postData)
    {
        string jsonResponse = HttpHelper.ZZPostRequest(tradetype, postData);
        //解析json
        DataTable dt = new DataTable();
        if (orderType == "order")
        {
            dt = initEmptyDataTable();
        }
        else
        {
            dt = initEmptyListDataTable();
        }
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

    //Data绑定
    protected void gvOrder_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DropDownList selCopName = (DropDownList)e.Row.FindControl("selCopName");
            GroupCardHelper.fillInTrackingCop(context, selCopName, true);
            if (selOrderStates.SelectedValue == "2")    //已发货
            {
                TextBox txtCopNo = (TextBox)e.Row.FindControl("txtCopNo");
                txtCopNo.Text = e.Row.Cells[12].Text;   //物流单号
                try
                {
                    selCopName.SelectedValue = e.Row.Cells[11].Text;  //物流公司
                }
                catch
                {

                    selCopName.SelectedValue = "01";
                }
                selCopName.Enabled = false;
                txtCopNo.Enabled = false;
            }
            else
            {
                selCopName.SelectedValue = "01";
            }

            switch (e.Row.Cells[5].Text)
            {
                case "0":
                    e.Row.Cells[5].Text = "未处理";
                    break;
                case "1":
                    e.Row.Cells[5].Text = "已制卡";
                    break;
                case "2":
                    e.Row.Cells[5].Text = "已发货";
                    break;
                default:
                    e.Row.Cells[5].Text = "状态异常";
                    break;
            }

        }

        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[11].Visible = false;
            e.Row.Cells[12].Visible = false;
        }
    }

    // gridview 换页事件
    public void gvOrder_Page(Object sender, GridViewPageEventArgs e)
    {
        gvOrder.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    protected void gvOrder_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int index = Convert.ToInt32(e.CommandArgument.ToString());
        if (e.CommandName == "QueryList")
        {
            string orderNo = gvOrder.Rows[index].Cells[4].Text;
            DataTable table = GetListTable(orderNo);

            if (table == null || table.Rows.Count < 1)
            {
                gvList.DataSource = new DataTable();
                gvList.DataBind();
                context.AddError("未查出记录");
                return;
            }

            gvList.DataSource = table;
            gvList.DataBind();
        }
    }

    protected void gvList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {

        }
    }

    private void clearTempTable()//清空临时表
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_ORDER where f0 = '" + Session.SessionID + "'");
        context.DBCommit();
    }

    private DataTable GetQueryTable()
    {
        DataTable table = new DataTable();

        Dictionary<string, string> postData = new Dictionary<string, string>();
        postData.Add("channelCode", "ONECARD");
        postData.Add("orderNo", txtOrderNo.Text);
        postData.Add("fromDate", txtFromDate.Text);
        postData.Add("toDate", txtToDate.Text);
        postData.Add("orderState", selOrderStates.SelectedValue);
        postData.Add("payCanal", selPayCanal.SelectedValue);
        postData.Add("custPhone", "");
        table = fillDataTable("order", HttpHelper.TradeType.ZZOrderDistrabution, postData);
        return table;
    }

    /// <summary>
    /// 获取子订单集合
    /// </summary>
    /// <param name="orderNo"></param>
    /// <returns></returns>
    private DataTable GetListTable(string orderNo)
    {
        DataTable table = new DataTable();

        Dictionary<string, string> postData = new Dictionary<string, string>();
        postData.Add("channelCode", "ONECARD");
        postData.Add("orderNo", orderNo);
        table = fillDataTable("orderList", HttpHelper.TradeType.ZZOrderListDistrabution, postData);
        return table;
    }

    private string GetListInfo(DataTable dt)
    {
        string cardNoColl = "";
        foreach (DataRow item in dt.Rows)
        {
            if (string.IsNullOrEmpty(item["cardno"].ToString()))
            {
                cardNoColl = cardNoColl + item["packagename"].ToString() + "兑换券,";
            }
            else
            {
                cardNoColl = cardNoColl + item["cardno"].ToString() + ",";
            }
        }
        return cardNoColl;
    }


    //配送
    protected void btnDistrabution_Click(object sender, EventArgs e)
    {
        int ordercount = 0;
        string orderNo = string.Empty;
        string custName = string.Empty;
        string copName = string.Empty;
        string copNo = string.Empty;
        foreach (GridViewRow gvr in gvOrder.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkOrderList");
            if (cb != null && cb.Checked)
            {
                ordercount++;
                DropDownList ddl = (DropDownList)gvr.FindControl("selCopName");
                TextBox txtCopNo = (TextBox)gvr.FindControl("txtCopNo");
                if (ddl.SelectedValue == "")
                {
                    context.AddError("请选择物流公司!", ddl);
                }
                if (txtCopNo.Text == "")
                {
                    context.AddError("请录入物流单号!", txtCopNo);
                }
                if (gvr.Cells[5].Text.ToString() != "已制卡")
                {
                    context.AddError("订单状态需为已制卡!");
                }
                orderNo = gvr.Cells[4].Text.ToString();
                copName = ddl.SelectedValue;
                copNo = txtCopNo.Text;
            }
        }

        if (context.hasError())
        {
            return;
        }

        if (ordercount > 1 || ordercount == 0)
        {
            context.AddError("只能选择一个订单！");
            return;
        }


        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        bool ok = context.ExecuteSP("SP_GC_RelaxDistrabution");
        if (ok)
        {
            context.AddMessage("配送完成！");

            hidTradeNo.Value = GetSeq();
            hidOrderNo.Value = orderNo;
            //记录小额同步信息
            UpdateSyncType("01", "03", "", "");

            //同步接口
            string code = "";
            string message = "";
            synMsg(sender, e, "2", orderNo, copName, copNo, ref code, ref message);

            //更新同步信息
            UpdateSyncType("02", "03", code, message);

            btnQuery_Click(sender, e);
        }
    }

    private string GetSeq()
    {
        context.SPOpen();
        context.AddField("step").Value = 1;
        context.AddField("seq", "string", "Output", "16");
        context.ExecuteReader("SP_GetSeq");
        context.DBCommit();

        return "" + context.GetFieldValue("seq");
    }

    //记录同步信息
    private void UpdateSyncType(string operateType, string tradeType, string syncCode, string syncMsg)
    {
        //operateType 01新增 02修改
        //tradeType 01售卡 02充值 03配送
        context.SPOpen();
        context.AddField("P_TRADEID").Value = hidTradeNo.Value;
        context.AddField("P_ORDERNO").Value = hidOrderNo.Value;
        context.AddField("P_DETAILNO").Value = "";
        context.AddField("P_CARDNO").Value = "";
        context.AddField("P_SYNCTYPE").Value = syncCode == "0000" ? "02" : "03";
        context.AddField("P_SYNCMSG").Value = syncMsg;
        context.AddField("P_OPERATETYPE").Value = operateType;
        context.AddField("P_TRADETYPE").Value = tradeType;
        context.ExecuteSP("SP_GC_ZZUpdateSync");
    }

    private void synMsg(object sender, EventArgs e, string _orderState, string _orderId, string _logisticsCompany, string _trackingNo, ref string code, ref string message)
    {

        string orderid = _orderId;
        string detailId = "";
        string cardNo = "";
        string orderState = _orderState;
        string rejectType = "";
        string logisticsCompany = _logisticsCompany;
        string trackingNo = _trackingNo;
        string operateStaffNo = context.s_UserID;
        string operateDepartId = context.s_DepartID;
        string remark = "";

        Dictionary<string, string> postData = new Dictionary<string, string>();
        postData.Add("channelCode", "ONECARD");
        postData.Add("orderNo", orderid);
        postData.Add("detailNo", detailId);
        postData.Add("cardNo", cardNo);
        postData.Add("orderState", orderState);
        postData.Add("rejectType", rejectType);
        postData.Add("logisticsCompany", logisticsCompany);
        postData.Add("trackingNo", trackingNo);
        postData.Add("operateStaffNo", operateStaffNo);
        postData.Add("operateDepartId", operateDepartId);
        postData.Add("remark", remark);

        string jsonResponse = HttpHelper.ZZPostRequest(HttpHelper.TradeType.ZZOrderChange, postData);

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
        }

        if (code == "0000") //表示成功
        {
            context.AddMessage("处理成功");
        }
        else
        {
            context.AddMessage("处理失败,失败原因：" + message);
        }
    }

    /// <summary>
    /// 打印功能
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnPrint_Click(object sender, EventArgs e)
    {
        int ordercount = 0;
        string orderNo = string.Empty;
        string custName = string.Empty;
        string custPhone = string.Empty;
        string custAddr = string.Empty;
        //string custPost = string.Empty;
        string senderPhone = "0512-962026";
        string senderCompany = "苏州市民卡有限公司";
        string senderAddr = "苏州市姑苏区人民路3118号国发大厦18楼";
        string labTag = "（转转卡）";
        foreach (GridViewRow gvr in gvOrder.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkOrderList");
            if (cb != null && cb.Checked)
            {
                ordercount++;
                custName = gvr.Cells[6].Text.Trim();
                custAddr = gvr.Cells[7].Text.Trim();
                custPhone = gvr.Cells[8].Text.Trim();
                //custPost = gvr.Cells[9].Text.Trim();
                orderNo = gvr.Cells[4].Text.Trim();
            }
        }
        if (ordercount > 1 || ordercount == 0)
        {
            context.AddError("只能选择一个订单！");
            return;
        }

        DataTable dt = GetListTable(orderNo);
        if (dt == null || dt.Rows.Count < 1)
        {
            context.AddError("未找到订单明细");
            return;
        }

        string cardNoColl = GetListInfo(dt);
        cardNoColl = cardNoColl.Substring(0, cardNoColl.Length == 0 ? 0 : cardNoColl.Length - 1);
        //获取卡号集合
        string cardNoCollReserved = string.Empty;
        if (cardNoColl.Length > 33)
        {
            cardNoCollReserved = cardNoColl.Substring(34);
            cardNoColl = cardNoColl.Substring(0, 33);
        }

        //地址长度过长时换行 add by huangzl
        if (custAddr.Length > 23)
        {
            if (custAddr.Length > 46)
            {
                custAddr = custAddr.Substring(0, 23) + "<br/>" + custAddr.Substring(23, 23) + "<br/>" + custAddr.Substring(46);
            }
            else
            {
                custAddr = custAddr.Substring(0, 23) + "<br/>" + custAddr.Substring(23);
            }
        }
        GroupCardHelper.prepareExpress(ptnExpress, senderPhone, senderCompany, senderAddr, labTag, custName, custPhone, custAddr, cardNoColl, cardNoCollReserved);

        ScriptManager.RegisterStartupScript(this, this.GetType(), "printExpressScript", "printExPress();", true);
    }

    /// <summary>
    /// 更新配送状态
    /// </summary>
    /// <param name="distrabutionType">配送状态 0：未配送，1：已配送，2：配送失败</param>
    /// <param name="distrabutionMsg">配送消息</param>
    /// <returns>更新成功状态</returns>
    private void UpdateDistrabutionType(string distrabutionType, string distrabutionMsg)
    {
        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        context.AddField("P_DISTRABUTIONTYPE").Value = distrabutionType;
        context.AddField("P_DISTRABUTIONMSG").Value = distrabutionMsg;
        context.ExecuteSP("SP_GC_RelaxUpdateDistrabution");
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        DataTable dt = GetQueryTable();

        if (dt != null && dt.Rows.Count != 0)
        {
            //删除订单状态、订单录入时间
            dt.Columns.Remove("CREATETIME");
            dt.Columns.Remove("ORDERSTATE");
            dt.Columns.Add("cardno", typeof(string));
            foreach (DataRow item in dt.Rows)
            {
                DataTable listDt = GetListTable(item["orderNo"].ToString());
                string cardNoColl = GetListInfo(listDt);
                item["cardno"] = cardNoColl.Substring(0, cardNoColl.Length == 0 ? 0 : cardNoColl.Length - 1);
            }
            ExportToExcel(dt);
        }
    }

    protected void ExportToExcel(DataTable dt)
    {
        string path = HttpContext.Current.Server.MapPath("../../") + "Tools\\配送物流信息模板.xls";

        FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read);

        HSSFWorkbook workbook = new HSSFWorkbook(fs);

        HSSFSheet sheet = (HSSFSheet)workbook.GetSheetAt(0);

        for (int i = 0; i < dt.Rows.Count; i++)
        {
            if (sheet.GetRow(2 + i) == null)
            {
                sheet.CreateRow(2 + i);
            }
            for (int j = 0; j < dt.Columns.Count; j++)
            {
                if (sheet.GetRow(2 + i).GetCell(j) == null)
                {
                    sheet.GetRow(2 + i).CreateCell(j);
                }

                sheet.GetRow(2 + i).GetCell(j).SetCellValue(dt.Rows[i][j].ToString());
            }
        }

        MemoryStream ms = new MemoryStream();
        using (ms)
        {
            workbook.Write(ms);
            byte[] data = ms.ToArray();
            #region 客户端保存
            HttpResponse response = System.Web.HttpContext.Current.Response;
            response.Clear();
            //Encoding pageEncode = Encoding.GetEncoding(PageEncode);
            response.Charset = "UTF-8";
            response.ContentType = "application/vnd-excel";//"application/vnd.ms-excel";
            System.Web.HttpContext.Current.Response.AddHeader("Content-Disposition", string.Format("attachment; filename=Distrabution.xls"));
            System.Web.HttpContext.Current.Response.BinaryWrite(data);
            #endregion
        }

        //excel.WriteToFile();
    }
}
