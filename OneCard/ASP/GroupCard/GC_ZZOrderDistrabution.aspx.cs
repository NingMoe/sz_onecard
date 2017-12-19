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

//description 休闲订单操作
//creater     蒋兵兵
//date        2015-04-17


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
    /// 读取照片
    /// </summary>
    /// <param name="orderdetailid">子订单ID</param>
    /// <param name="phototype">照片类型</param>
    /// <returns>字节流</returns>
    private byte[] ReadImage(string orderdetailid, string phototype)
    {
        string selectSql = "Select " + phototype + " From TF_F_XXOL_ORDERDETAIL Where ORDERDETAILID=:ORDERDETAILID";
        context.DBOpen("Select");
        context.AddField(":ORDERDETAILID").Value = orderdetailid;
        DataTable dt = context.ExecuteReader(selectSql);
        if (dt != null && dt.Rows.Count > 0 && dt.DefaultView[0][phototype].ToString() != "")
        {
            return (byte[])dt.Rows[0].ItemArray[0];
        }

        return null;
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

        string fromDate = txtFromDate.Text.Trim();
        string endDate = txtToDate.Text.Trim();

        DataTable dt = GroupCardHelper.callQuery(context, "QueryRelaxOrderDistrabutionAll", selOrderStates.SelectedValue, txtOrderNo.Text, fromDate, endDate, txtCustPhone.Text, selPayCanal.SelectedValue);
        if (dt == null || dt.Rows.Count < 1)
        {
            gvOrder.DataSource = new DataTable();
            gvOrder.DataBind();
            context.AddError("未查出记录");
            return;
        }
        gvOrder.DataSource = dt;
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

    protected void gvOrder_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            //e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvOrder','Select$" + e.Row.RowIndex + "')");
        }
    }

    protected void gvOrder_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "QueryList")
        {
            DataTable dt = GroupCardHelper.callQuery(context, "QueryRelaxOrderDistrabutionList", e.CommandArgument.ToString());
            if (dt == null || dt.Rows.Count < 1)
            {
                gvList.DataSource = new DataTable();
                gvList.DataBind();
                context.AddError("未查出记录");
                return;
            }

            gvList.DataSource = dt;
            gvList.DataBind();
        }
    }

    protected void gvList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Image imgP = (Image)e.Row.FindControl("imgPerson");
            Session["PicData"] = ReadImage(e.Row.Cells[17].Text, "PHTOT");
            string photoType = "PHTOT";
            imgP.ImageUrl = "GC_RelaxCardOrderGetPic.aspx?orderDetailId=" + e.Row.Cells[17].Text + "&photoType=" + photoType;

            Image imgI = (Image)e.Row.FindControl("imgIDCard");
            Session["PicData"] = ReadImage(e.Row.Cells[17].Text, "PAPERPHTOT");
            photoType = "PAPERPHTOT";
            imgI.ImageUrl = "GC_RelaxCardOrderGetPic.aspx?orderDetailId=" + e.Row.Cells[17].Text + "&photoType=" + photoType;
        }
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header)
        {
            //收货人姓名、地址、电话、邮编、证件类型、套餐类型编码、功能费
            e.Row.Cells[19].Visible = false;
            e.Row.Cells[20].Visible = false;
            e.Row.Cells[21].Visible = false;
            e.Row.Cells[22].Visible = false;
            e.Row.Cells[23].Visible = false;
            e.Row.Cells[24].Visible = false;
            e.Row.Cells[25].Visible = false;
        }
    }

    //清空内容
    private void clearControl()
    {
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
        foreach (GridViewRow gvr in gvOrder.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkOrderList");
            if (cb != null && cb.Checked)
            {
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
                ordercount++;
                //订单记录入临时表
                context.ExecuteNonQuery("insert into TMP_ORDER (F0,F1,F2,F3) values('" +
                     Session.SessionID + "', '" + gvr.Cells[4].Text.Trim() + "','" + ddl.SelectedValue + "','" + txtCopNo.Text + "')");
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

    //选中记录入临时表用以导出功能
    private bool RecordIntoTmpForExport()
    {
        context.DBOpen("Insert");

        int ordercount = GetOrderCount();

        List<string> company = new List<string>();

        //校验是否选择了订单

        if (ordercount <= 0)
        {
            context.AddError("请选择需要导出的订单！");
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
    /// 获取勾选的订单数量
    /// </summary>
    /// <returns></returns>
    private int GetOrderCount()
    {
        int ordercount = 0;

        foreach (GridViewRow gvr in gvOrder.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkOrderList");
            if (cb != null && cb.Checked)
            {
                ordercount++;
                //订单记录入临时表
                context.ExecuteNonQuery("insert into TMP_ORDER (F0,F1) values('" +
                     Session.SessionID + "', '" + gvr.Cells[4].Text.Trim() + "')");
            }
        }

        return ordercount;
    }


    /// <summary>
    /// 读卡信息判断
    /// </summary>
    private void CheckCard()
    {
        //卡内金额不为0
        if (Convert.ToDecimal(hiddencMoney.Value) != 0)
        {
            context.AddError("A001001144");
            return;
        }
    }

    //配送
    protected void btnDistrabution_Click(object sender, EventArgs e)
    {
        clearTempTable();

        if (!RecordIntoTmp()) return;

        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        bool ok = context.ExecuteSP("SP_GC_RelaxDistrabution");
        if (ok)
        {
            context.AddMessage("配送完成！");

            DataTable dt = GroupCardHelper.callQuery(context, "QueryDistrabution");
            if (dt == null || dt.Rows.Count < 1)
            {
                context.AddError("未找到待同步记录");
                return;
            }

            //调用休闲订单状态变更通知
            string msg = RelaxWebServiceHelper.RelaxOrderTypeInfo(dt);
            string disType = "1";   //默认成功
            string disMsg = msg;
            if (msg != "0000")
            {
                disType = "2";
                if (msg.Length > 200)
                {
                    disMsg = msg.Substring(0, 150);
                }
            }
            UpdateDistrabutionType(disType, disMsg);    //调用更新配送状态


            btnQuery_Click(sender, e);
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
        string labTag = "（休闲年卡）";
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

        DataTable dt = GroupCardHelper.callQuery(context, "QueryOrderDetailCardNo", orderNo);
        if (dt == null || dt.Rows.Count < 1)
        {
            context.AddError("未找到订单明细");
            return;
        }
        //获取卡号集合
        string cardNoColl = dt.Rows[0][1].ToString();
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
                custAddr = custAddr.Substring(0, 23) + "<br/>" + custAddr.Substring(24, 23) + "<br/>" + custAddr.Substring(47);
            }
            else
            {
                custAddr = custAddr.Substring(0, 23) + "<br/>" + custAddr.Substring(24);
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
        clearTempTable();

        if (!RecordIntoTmpForExport()) return;

        DataTable data = GroupCardHelper.callQuery(context, "QueryExportDistrabution", Session.SessionID);

        if (data != null && data.Rows.Count != 0)
        {
            ExportToExcel(data);
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
