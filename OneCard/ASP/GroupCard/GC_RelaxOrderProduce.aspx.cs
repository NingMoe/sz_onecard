using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TDO.BusinessCode;
using TM;
using TDO.ResourceManager;

//description 休闲订单制卡
//creater     蒋兵兵
//date        2015-04-17


public partial class ASP_GroupCard_GC_RelaxOrderProduce : Master.FrontMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            gvOrderList.DataSource = new DataTable();
            gvOrderList.DataBind();

            previousLink.Visible = false;
            nextLink.Visible = false;
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
        context.DBCommit();
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

        if (!ValidInput())
            return;

        gvOrderList.DataSource = new DataTable();
        gvOrderList.DataBind();

        string fromDate = txtFromDate.Text.Trim();
        string endDate = txtToDate.Text.Trim();

        previousLink.Visible = true;
        nextLink.Visible = true;
        ShowFileContent();
    }

    //Data绑定
    protected void gvOrderList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Button btn = (Button)e.Row.FindControl("btnProduce");
            btn.Attributes.Add("onclick", "ReadCardInfo()");

            Image imgP = (Image)e.Row.FindControl("imgPerson");
            string photoType = "PHTOT";
            imgP.ImageUrl = "GC_RelaxCardOrderGetPic.aspx?orderDetailId=" + e.Row.Cells[19].Text + "&photoType=" + photoType;

            Image imgI = (Image)e.Row.FindControl("imgIDCard");
            photoType = "PAPERPHTOT";
            imgI.ImageUrl = "GC_RelaxCardOrderGetPic.aspx?orderDetailId=" + e.Row.Cells[19].Text + "&photoType=" + photoType;
        }
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header)
        {
            //收货人姓名、地址、电话、邮编、证件类型、套餐类型编码、功能费
            e.Row.Cells[21].Visible = false;
            e.Row.Cells[22].Visible = false;
            e.Row.Cells[23].Visible = false;
            e.Row.Cells[24].Visible = false;
            e.Row.Cells[25].Visible = false;
            e.Row.Cells[26].Visible = false;
            e.Row.Cells[27].Visible = false;
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
        parm[0] = "0";
        parm[1] = txtOrderNo.Text;
        parm[2] = txtFromDate.Text;
        parm[3] = txtToDate.Text;
        parm[4] = selPayCanal.SelectedValue;
        parm[5] = begin.ToString();
        parm[6] = end.ToString();
        iCount = Int32.Parse(GroupCardHelper.callQuery(context, "QueryRelaxProduceCount", parm).Rows[0][0].ToString());
        DataTable table = GroupCardHelper.callQuery(context, "QueryRelaxOrderProduce", parm);
        if (table.Rows.Count > 0)
        {
            gvOrderList.DataSource = table;
            gvOrderList.DataBind();
            //btnSubmit.Attributes["Class"] = "btn";
            //btnSubmit.Enabled = true;
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

    //protected void gvOrderList_RowCreated(object sender, GridViewRowEventArgs e)
    //{
    //    if (e.Row.RowType == DataControlRowType.DataRow)
    //    {
    //        //注册行单击事件

    //        e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvOrderList','Select$" + e.Row.RowIndex + "')");
    //    }
    //}

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
                context.ExecuteNonQuery("insert into TMP_ORDER (F0,F1,F2) values('" +
                     Session.SessionID + "', '" + gvr.Cells[6].Text + "','" + gvr.Cells[8].Text + "')");
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
    /// 售卡费用相关信息
    /// </summary>
    private void GetTradeFee()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //从前台业务交易费用表中读取售卡费用数据

        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "01";

        TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001001137", "TD_M_TRADEFEE", null);

        for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        {
            //"00"为卡押金
            if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "00")
                hiddenDepositFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //"10"为卡费

            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "10")
                hiddenCardcostFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //"99"为其他费用

            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "99")
                hidOtherFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        }

        //从用户卡库存表(TL_R_ICUSER)中读取数据

        TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
        ddoTL_R_ICUSERIn.CARDNO = txtCardno.Text;

        TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

        if (ddoTL_R_ICUSEROut == null)
        {
            context.AddError("A001001101");
            return;
        }

        //获取卡售卡方式
        hidSaletype.Value = ddoTL_R_ICUSEROut.SALETYPE;

        if (hidSaletype.Value != "01" && hidSaletype.Value != "02")
        {
            context.AddError("未找到正确的售卡方式");
            return;
        }

        //计算费用
        //售卡方式为卡费方式
        if (hidSaletype.Value.Equals("01"))
        {
            hiddenCardcostFee.Value = (Convert.ToDecimal(hiddenCardcostFee.Value) + (Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE)) / 100).ToString("0.00");
            hiddenDepositFee.Value = Convert.ToDecimal(hiddenDepositFee.Value).ToString();
        }
        //售卡方式为押金方式
        if (hidSaletype.Value.Equals("02"))
        {
            hiddenCardcostFee.Value = Convert.ToDecimal(hiddenCardcostFee.Value).ToString();
            hiddenDepositFee.Value = (Convert.ToDecimal(hiddenDepositFee.Value) + (Convert.ToDecimal(ddoTL_R_ICUSEROut.CARDPRICE)) / 100).ToString("0.00");
        }
    }

    /// <summary>
    /// 绑定按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvOrderList_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Produce")
        {
            btnReadCard_Click(sender, e);

            //验证卡状态
            checkCardState(txtCardno.Text);

            //校验用户相关信息
            string funcFee = string.Empty;
            string packageTypeCode = string.Empty;
            SaleInfoValidation(e.CommandArgument.ToString(), ref funcFee, ref packageTypeCode);

            //获取卡相关资费
            GetTradeFee();
            if (context.hasError())
                return;

            //return;
            //售卡-休闲开通
            ProduceCard(e.CommandArgument.ToString(), funcFee, packageTypeCode);

            btnQuery_Click(sender, e);
        }
    }


    //读卡功能
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(),
                    "js", "ReadCardInfo()", true);
    }

    #region 售卡用户信息进行检验
    /// <summary>
    /// 售卡用户信息进行检验
    /// </summary>
    /// <param name="orderDetailId">子订单ID</param>
    /// <param name="funcFee">功能费</param>
    /// <param name="packageTypeCode">套餐类型</param>
    /// <returns></returns>
    private Boolean SaleInfoValidation(string orderDetailId, ref string funcFee, ref string packageTypeCode)
    {
        funcFee = string.Empty;
        packageTypeCode = string.Empty;
        DataTable data = GroupCardHelper.callQuery(context, "QueryOrderDetail", orderDetailId);

        if (data == null || data.Rows.Count == 0)
        {
            context.AddError("没有找到该订单的用户信息");
            return false;
        }

        hidcustName.Value = data.Rows[0]["CUSTNAME"].ToString();
        hidpaperType.Value = data.Rows[0]["PAPERTYPE"].ToString();
        hidpaperNo.Value = data.Rows[0]["PAPERNO"].ToString();
        hidcustPhone.Value = data.Rows[0]["CUSTPHONE"].ToString();
        hidaddress.Value = data.Rows[0]["ADDRESS"].ToString();
        hidcustPost.Value = data.Rows[0]["CUSTPOST"].ToString();
        hidcustSex.Value = data.Rows[0]["CUSTSEX"].ToString();
        hidcustBirth.Value = data.Rows[0]["CUSTBIRTH"].ToString();
        hidcustEmail.Value = data.Rows[0]["CUSTEMAIL"].ToString();
        funcFee = data.Rows[0]["FUNCFEE"].ToString();
        packageTypeCode = data.Rows[0]["PACKAGETYPE"].ToString();

        //对用户姓名进行非空、长度检验

        if (hidcustName.Value == "")
            context.AddError("A001001111");
        else if (Validation.strLen(hidcustName.Value) > 50)
            context.AddError("A001001113");

        //对用户性别进行非空检验

        if (hidcustSex.Value == "")
            context.AddError("A001001116");
        else if (hidcustSex.Value != "0" && hidcustSex.Value != "1")
            context.AddError("A010001116:性别填写有误");

        //对证件类型进行非空检验

        if (hidpaperType.Value == "")
            context.AddError("A001001117");

        //对出生日期进行非空、日期格式检验
        if (hidcustBirth.Value != "")

            try
            {
                DateTime.ParseExact(hidcustBirth.Value, "yyyyMMdd", null);
            }
            catch
            {
            }

        //对联系电话进行非空、长度、数字检验

        if (hidcustPhone.Value == "")
            context.AddError("A001001124");
        else if (Validation.strLen(hidcustPhone.Value) > 20)
            context.AddError("A001001126");
        else if (!Validation.isNum(hidcustPhone.Value))
            context.AddError("A001001125");

        //对证件号码进行非空、长度、英数字检验

        if (hidpaperNo.Value == "")
            context.AddError("A001001121");
        else if (!Validation.isCharNum(hidpaperNo.Value))
            context.AddError("A001001122");
        else if (Validation.strLen(hidpaperNo.Value) > 20)
            context.AddError("A001001123");

        //对邮政编码进行非空、长度、数字检验

        //if (hidcustPost.Value != "")
        //{
        //    if (Validation.strLen(hidcustPost.Value) != 6)
        //        context.AddError("A001001120");
        //    else if (!Validation.isNum(hidcustPost.Value))
        //        context.AddError("A001001119");
        //}

        //对联系地址进行非空、长度检验

        if (hidaddress.Value == "")
            context.AddError("A001001127");
        else if (Validation.strLen(hidaddress.Value) > 100)
            context.AddError("A001001809:联系地址长度大于100位");

        //对电子邮件进行格式检验
        if (hidcustEmail.Value != "")
            new Validation(context).isEMail(hidcustEmail.Value);

        return !(context.hasError());
    }
    #endregion

    /// <summary>
    /// 制卡功能
    /// </summary>
    protected void ProduceCard(string orderDetailId, string funcFee, string packageTypeCode)
    {
        StringBuilder strBuilder = new StringBuilder();
        context.SPOpen();
        context.AddField("P_ORDERDETAILID").Value = orderDetailId;      //子订单号
        context.AddField("P_ID").Value = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value.Substring(4, 16));
        context.AddField("P_CARDNO").Value = txtCardno.Text;
        context.AddField("P_DEPOSIT").Value = Convert.ToInt32(Convert.ToDecimal(hiddenDepositFee.Value) * 100);
        context.AddField("P_CARDCOST").Value = Convert.ToInt32(Convert.ToDecimal(hiddenCardcostFee.Value) * 100);
        context.AddField("P_OTHERFEE").Value = Convert.ToInt32((Convert.ToDecimal(hidOtherFee.Value)) * 100);
        context.AddField("P_CARDTRADENO").Value = hiddentradeno.Value;
        context.AddField("P_CARDTYPECODE").Value = hiddenLabCardtype.Value;
        context.AddField("P_CARDMONEY").Value = Convert.ToInt32(Convert.ToDecimal(hiddencMoney.Value) * 100);
        context.AddField("P_SELLCHANNELCODE").Value = "01";
        context.AddField("P_SERSTAKETAG").Value = "0";
        context.AddField("P_TRADETYPECODE").Value = "01";

        AESHelp.AESEncrypt(hidcustName.Value, ref strBuilder);
        context.AddField("P_CUSTNAME").Value = strBuilder.ToString();
        context.AddField("P_CUSTSEX").Value = hidcustSex.Value;
        context.AddField("P_CUSTBIRTH").Value = hidcustBirth.Value;
        context.AddField("P_PAPERTYPECODE").Value = hidpaperType.Value;

        AESHelp.AESEncrypt(hidpaperNo.Value, ref strBuilder);
        context.AddField("P_PAPERNO").Value = strBuilder.ToString();

        AESHelp.AESEncrypt(hidaddress.Value, ref strBuilder);
        context.AddField("P_CUSTADDR").Value = strBuilder.ToString();
        context.AddField("P_CUSTPOST").Value = hidcustPost.Value;

        AESHelp.AESEncrypt(hidcustPhone.Value, ref strBuilder);
        context.AddField("P_CUSTPHONE").Value = strBuilder.ToString();
        context.AddField("P_CUSTEMAIL").Value = hidcustEmail.Value;
        context.AddField("P_REMARK").Value = "";
        context.AddField("P_CUSTRECTYPECODE").Value = "1";
        context.AddField("P_TERMNO").Value = "112233445566";
        context.AddField("P_OPERCARDNO").Value = context.s_CardID;
        context.AddField("P_FUNCFEE").Value = funcFee;
        context.AddField("P_PACKAGETYPE").Value = packageTypeCode;
        context.AddField("P_PASSPAPERNO").Value = hidpaperNo.Value;
        context.AddField("P_PASSCUSTNAME").Value = hidcustName.Value;
        context.AddField("P_CURRENTTIME", "DateTime", "output", "", null);
        context.AddField("P_SALECARDTRADEID", "string", "output", "16", null);
        context.AddField("P_RELAXTRADEID", "string", "output", "16", null);
        //return;
        bool ok = context.ExecuteSP("SP_GC_RELAXSALECARD");
        if (ok)
        {
            context.AddMessage("制卡完成！");
        }
    }

    //配送
    protected void btnDistrabution_Click(object sender, EventArgs e)
    {
        string orderno = gvOrderList.Rows[gvOrderList.SelectedIndex].Cells[17].Text.ToString();
        string detailno = gvOrderList.Rows[gvOrderList.SelectedIndex].Cells[19].Text.ToString();
        context.SPOpen();
        context.AddField("P_ORDERNO").Value = detailno;      //子订单号
        //context.AddField("P_TRACKINGCOPCODE").Value = selTrackingCop.SelectedValue;
        //context.AddField("P_TRACKINGNO").Value = txtTrackingNo.Text;
        bool ok = context.ExecuteSP("SP_GC_RelaxDistrabution");
        if (ok)
        {
            context.AddMessage("配送完成！");

            DataTable dt = GroupCardHelper.callQuery(context, "QueryDistrabution", orderno);
            if (dt == null || dt.Rows.Count < 1)
            {
                context.AddError("未找到待同步记录");
                return;
            }

            //调用休闲订单状态变更通知
            string msg = RelaxWebServiceHelper.RelaxOrderTypeInfo(dt);
            if (msg != "0000")
            {
                context.AddError(msg);
            }
            else
            {
                context.AddMessage("调用手机端成功");
            }
        }
    }
}
