using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Master;
using Common;
/***************************************************************
 * 功能名: 资源管理下单申请
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/07/18    shil			初次开发
 ****************************************************************/
public partial class ASP_ResourceManage_RM_ApplyOrder : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        bool isRedirect = false;
        if (!Page.IsPostBack)
        {
            //初始化列表
            showNonDataGridView();

            hidCardType.Value = "usecard";
            hidApplyType.Value = "ApplyStock";
            //初始化页面
            init_Page();

            if (Request.QueryString["surFaceCode"] != null)
            {
                selSupplyFaceType.SelectedValue = Request.QueryString["surFaceCode"].ToString();
                if (!string.IsNullOrEmpty(Request.QueryString["sampleCode"]))
                {
                    selSupplyFaceType_change(sender, e);
                }
            }
            if (Request.QueryString["valueCode"] != null)
            {
                isRedirect = true;
                selSupplyCardValue.SelectedValue = Request.QueryString["valueCode"].ToString();

            }
        }
        //固化标签
        ResourceManageHelper.selectTab(this, this.GetType(), hidCardType);

        if (isRedirect == false)
        {
            //固化单选框
            ScriptManager.RegisterStartupScript(this, this.GetType(), "radioTagScript", "SelectRadioTag();", true);
        }
        else
        {
            //选择充值卡
            ScriptManager.RegisterStartupScript(this, this.GetType(), "radioTagScript", "SelectChargeCard();", true);
        }

    }
    /// <summary>
    /// 页面初始化
    /// </summary>
    protected void init_Page()
    {
        //设置只读控件
        setReadOnly(txtCardSampleCode);

        //初始化日期
        DateTime date = new DateTime();
        date = DateTime.Today;
        txtStartDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtEndDate.Text = DateTime.Today.ToString("yyyyMMdd");

        txtApplyOrderID.Text = "XQ";

        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据，放入下拉列表中
        UserCardHelper.selectCardType(context, selCardType, true);

        //从IC卡卡面编码表(TD_M_CARDSURFACE)中读取数据，放入下拉列表中
        ResourceManageHelper.selectCardFace(context, selFaceType, true, selCardType.SelectedValue);

        //初始化面值
        ResourceManageHelper.selCardMoneySelect(context, selCardValue, true);

        //初始化提交卡面类型
        ResourceManageHelper.selectCardFace(context, selSupplyFaceType, true, "");

        //初始化卡面确认方式
        ResourceManageHelper.selCardFaceAffirmWay(context, selCardFaceAffirmWay, false);

        //初始化提交面值
        ResourceManageHelper.selCardMoney(context, selSupplyCardValue, true);
    }
    #region 全选列表
    /// <summary>
    /// 选择或取消所有复选框
    /// </summary>
    protected void CheckAll(object sender, EventArgs e)
    {
        //全选信息记录

        CheckBox cbx = (CheckBox)sender;

        GridView gv = new GridView();
        if (hidCardType.Value == "usecard")
            if (hidApplyType.Value == "ApplyStock")
                //用户卡存货补货列表
                gv = gvResultSupplyCard;
            else
                //用户卡新制卡片列表
                gv = gvResultNewCard;
        else
            //充值卡列表
            gv = gvResultChargeCard;

        foreach (GridViewRow gvr in gv.Rows)
        {
            if (!gvr.Cells[1].Enabled) continue;
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }
    #endregion
    #region 查询
    /// <summary>
    /// 查询按钮点击事件
    /// </summary>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //查询校验
        if (!queryValidation())
            return;

        if (hidCardType.Value == "usecard")
            if (hidApplyType.Value == "ApplyStock")
                bindApplyStock();//查询存货补货
            else
                bindApplyNew();//查询新制卡片
        else
            bindChargeCard();//查询充值卡
    }
    /// <summary>
    /// 存货补货GridView绑定数据源
    /// </summary>
    protected void bindApplyStock()
    {
        //存货补货
        gvResultSupplyCard.DataSource = queryApplyStock();
        gvResultSupplyCard.DataBind();
    }
    /// <summary>
    /// 新制卡片GridView绑定数据源
    /// </summary>
    protected void bindApplyNew()
    {
        //新制卡片
        gvResultNewCard.DataSource = queryApplyNew();
        gvResultNewCard.DataBind();
    }
    /// <summary>
    /// 充值卡GridView绑定数据源
    /// </summary>
    protected void bindChargeCard()
    {
        //充值卡
        gvResultChargeCard.DataSource = queryChargeCard();
        gvResultChargeCard.DataBind();
    }
    /// <summary>
    /// 查询存货补货需求单
    /// </summary>
    /// <returns></returns>
    protected ICollection queryApplyStock()
    {
        //查询存货补货，需求单号如果为XQ时，默认为未输入需求单号
        string applyOrderID = "";
        if (txtApplyOrderID.Text.Trim() != "XQ")
            applyOrderID = txtApplyOrderID.Text.Trim();
        DataTable data = ResourceManageHelper.callQuery(context, "queryApplyStock", selFaceType.SelectedValue,
            applyOrderID, txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), selOrderState.SelectedValue, selUseTag.SelectedValue);
        if (data.Rows.Count == 0)
        {
            ResourceManageHelper.resetData(gvResultSupplyCard, data);
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return new DataView(data);
    }
    /// <summary>
    /// 查询新制卡片需求单
    /// </summary>
    /// <returns></returns>
    protected ICollection queryApplyNew()
    {
        //查询新制卡片，需求单号如果为XQ时，默认为未输入需求单号
        string applyOrderID = "";
        if (txtApplyOrderID.Text.Trim() != "XQ")
            applyOrderID = txtApplyOrderID.Text.Trim();
        DataTable data = ResourceManageHelper.callQuery(context, "queryApplyNew", txtCardName.Text.Trim(),
            applyOrderID, txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), selOrderState.SelectedValue, selUseTag.SelectedValue);
        if (data.Rows.Count == 0)
        {
            ResourceManageHelper.resetData(gvResultNewCard, data);
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return new DataView(data);
    }
    /// <summary>
    /// 查询充值卡需求单
    /// </summary>
    /// <returns></returns>
    protected ICollection queryChargeCard()
    {
        //查询充值卡，需求单号如果为XQ时，默认为未输入需求单号
        string applyOrderID = "";
        if (txtApplyOrderID.Text.Trim() != "XQ")
            applyOrderID = txtApplyOrderID.Text.Trim();
        DataTable data = ResourceManageHelper.callQuery(context, "queryApplyChargeCard", selCardValue.SelectedValue,
            applyOrderID, txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), selOrderState.SelectedValue, selUseTag.SelectedValue);
        if (data.Rows.Count == 0)
        {
            ResourceManageHelper.resetData(gvResultChargeCard, data);
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return new DataView(data);
    }
    /// <summary>
    /// 查询输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean queryValidation()
    {
        //如果是用户卡新制卡片，则检验卡片名称
        if (hidCardType.Value == "usecard" && hidApplyType.Value == "ApplyNew")
        {
            if (!string.IsNullOrEmpty(txtCardName.Text.Trim()))
                if (Validation.strLen(txtCardName.Text.Trim()) > 25)
                    context.AddError("A095470105:：卡片名称长度不能超过25个字符长度", txtCardName);
        }
        //校验需求单号
        if (!string.IsNullOrEmpty(txtApplyOrderID.Text.Trim()) && txtApplyOrderID.Text.Trim() != "XQ")
        {
            if (Validation.strLen(txtApplyOrderID.Text.Trim()) != 18)
                context.AddError("A095470100：需求单号必须为18位", txtApplyOrderID);
            if (!Validation.isCharNum(txtApplyOrderID.Text.Trim()))
                context.AddError("A095470101：需求单必须为英数", txtApplyOrderID);
        }
        //校验日期
        ResourceManageHelper.checkDate(context, txtStartDate, txtEndDate, "A095470102", "A095470103", "A095470104");

        return !context.hasError();
    }
    #endregion
    /// <summary>
    /// 申请输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean supplyValidation()
    {
        //如果是用户卡存货补货
        if (hidCardType.Value == "usecard" && hidApplyType.Value == "ApplyStock")
        {
            //卡面类型
            if (selSupplyFaceType.SelectedValue.Equals(""))
                context.AddError("A095470106：请选择用户卡卡面类型", selSupplyFaceType);
            //卡样编码
            if (txtCardSampleCode.Text.Trim() == "")
                context.AddError("A095470107：该卡面没有卡样", txtCardSampleCode);
        }
        //如果是用户卡新制卡片
        if (hidCardType.Value == "usecard" && hidApplyType.Value == "ApplyNew")
        {
            //卡片名称
            if (string.IsNullOrEmpty(txtSupplyardName.Text.Trim()))
                context.AddError("卡片名称不能为空", txtSupplyardName);
            else if (Validation.strLen(txtSupplyardName.Text.Trim()) > 25)
                context.AddError("A095470108:卡片名称长度不能超过25个字符长度", txtSupplyardName);
        }
        //如果是充值卡
        if (hidCardType.Value == "chargecard")
        {
            //面值
            if (selSupplyCardValue.SelectedValue.Equals(""))
                context.AddError("A095470109：请选择充值卡面值", selSupplyCardValue);
        }

        //卡片数量
        if (string.IsNullOrEmpty(txtCardNum.Text.Trim()) || txtCardNum.Text.Trim().Equals("0"))
            context.AddError("A095470110:卡片数量不能为空或零", txtCardNum);
        else if (!Validation.isNum(txtCardNum.Text.Trim()))
            context.AddError("A095470111：卡片数量必须为数字", txtCardNum);

        //要求到货日期
        if (string.IsNullOrEmpty(txtDate.Text.Trim()))
            context.AddError("A095470112：要求到货日期不能为空", txtDate);
        else if (!Validation.isDate(txtDate.Text.Trim(), "yyyyMMdd"))
            context.AddError("A095470113：要求到货日期格式必须为yyyyMMdd", txtDate);

        //订单要求
        if (!string.IsNullOrEmpty(txtOrderMand.Text.Trim()))
            if (Validation.strLen(txtOrderMand.Text.Trim()) > 50)
                context.AddError("A095470114:订单要求长度不能超过50位", txtOrderMand);

        //备注
        if (!string.IsNullOrEmpty(txtReMark.Text.Trim()))
            if (Validation.strLen(txtReMark.Text.Trim()) > 50)
                context.AddError("A095470115:备注长度不能超过50位", txtReMark);

        return !context.hasError();
    }
    /// <summary>
    /// 申请按钮点击事件
    /// </summary>
    protected void btnApply_Click(object sender, EventArgs e)
    {
        //提交校验
        if (!supplyValidation())
            return;

        context.SPOpen();
        //需求单类型
        string applyordertype = "";    //需求单类型
        string cardtypecode = "";      //卡片类型编码
        string cardfacetypecode = "";  //卡面类型编码
        string cardsamplecode = "";    //卡样编码
        string cardfaceaffirmway = ""; //卡面确认方式
        string cardname = "";          //卡片名称
        string cardvalue = "";         //面值
        string name = context.s_DepartID + ":" + context.s_DepartName + " / " + context.s_UserID + ":" + context.s_UserName;
        if (hidCardType.Value == "usecard")
            if (hidApplyType.Value == "ApplyStock") //如果是存货补货，给卡片类型编码、卡面类型编码、卡样编码赋值
            {
                applyordertype = "01"; //存货补货
                cardfacetypecode = selSupplyFaceType.SelectedValue;
                cardtypecode = selSupplyFaceType.SelectedValue.Substring(0, 2);
                cardsamplecode = txtCardSampleCode.Text.Trim();
            }
            else //如果是新制卡片，给卡片名称、卡面确认方式赋值
            {
                applyordertype = "02"; //新制卡片
                cardname = txtSupplyardName.Text.Trim();
                cardfaceaffirmway = selCardFaceAffirmWay.SelectedValue;
            }
        else //如果是充值卡，给面值赋值
        {
            applyordertype = "03"; //充值卡
            cardvalue = selSupplyCardValue.SelectedValue;
        }

        context.AddField("P_APPLYORDERTYPE").Value = applyordertype;
        context.AddField("P_ORDERDEMAND").Value = txtOrderMand.Text.Trim();
        context.AddField("P_CARDTYPECODE").Value = cardtypecode;
        context.AddField("P_CARDSURFACECODE").Value = cardfacetypecode;
        context.AddField("P_CARDSAMPLECODE").Value = cardsamplecode;
        context.AddField("P_CARDNAME").Value = cardname;
        context.AddField("P_CARDFACEAFFIRMWAY").Value = cardfaceaffirmway;
        context.AddField("P_VALUECODE").Value = cardvalue;
        context.AddField("P_CARDNUM").Value = txtCardNum.Text.Trim();
        context.AddField("P_REQUIREDATE").Value = txtDate.Text.Trim();
        context.AddField("P_REMARK").Value = txtReMark.Text.Trim();

        context.AddField("P_ORDERID", "String", "output", "18", null);

        //调用下单申请存储过程
        bool ok = context.ExecuteSP("SP_RM_APPLYORDER");

        if (ok)
        {
            AddMessage("申请成功");
            String orderid = "" + context.GetFieldValue("P_ORDERID");
            string html = "";
            //更新列表
            if (hidCardType.Value == "usecard")
            {
                if (hidApplyType.Value == "ApplyStock")//存货补货
                {
                    bindApplyStock();
                    //自动打印需求单
                    if (chkOrder.Checked)
                    {
                        html = RMPrintHelper.PrintApplyOrder(context, orderid, selSupplyFaceType.SelectedItem.Text,
                             cardsamplecode, txtCardNum.Text.Trim(), txtDate.Text.Trim(), txtReMark.Text.Trim(),
                             cardname, cardfaceaffirmway, name, txtOrderMand.Text.Trim(), "01");
                    }
                }
                else//新制卡片
                {
                    bindApplyNew();
                    //自动打印需求单
                    if (chkOrder.Checked)
                    {
                        html = RMPrintHelper.PrintApplyOrder(context, orderid, selSupplyFaceType.SelectedItem.Text,
                            cardsamplecode, txtCardNum.Text.Trim(), txtDate.Text.Trim(), txtReMark.Text.Trim(),
                            cardname, cardfaceaffirmway, name, txtOrderMand.Text.Trim(), "02");
                    }
                }
            }
            else//充值卡
            {
                bindChargeCard();
                //自动打印需求单
                if (chkOrder.Checked)
                {
                    html = RMPrintHelper.PrintChargeCardOrder(context, orderid, selSupplyCardValue.SelectedItem.Text, txtCardNum.Text.Trim(),
                        txtDate.Text.Trim(), txtReMark.Text.Trim(), name, txtOrderMand.Text.Trim());
                }
            }

            if (html.Length > 0)
            {
                printarea.InnerHtml = html;
                //执行打印脚本
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
            }

            //清空
            //clear();
        }

    }
    /// <summary>
    /// 清空输入项
    /// </summary>
    protected void clear()
    {
        selSupplyFaceType.SelectedValue = "";
        txtCardSampleCode.Text = "";
        txtSupplyardName.Text = "";
        selCardFaceAffirmWay.SelectedValue = "1";
        selSupplyCardValue.SelectedValue = "";
        txtCardNum.Text = "";
        txtDate.Text = "";
        txtOrderMand.Text = "";
        txtReMark.Text = "";

        linkViewCardFace.Visible = false;
    }
    /// <summary>
    /// 关闭需求单
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnClose_Click(object sender, EventArgs e)
    {
        //清空临时表
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON where f1='"
            + Session.SessionID + "'");
        context.DBCommit();

        int count = 0;        
        GridView gv = new GridView();
        if (hidCardType.Value == "usecard")
        {
            if (hidApplyType.Value == "ApplyStock")
            {
                //存货补货
                gv = gvResultSupplyCard;                
            }
            else
            {
                //新制卡片
                gv = gvResultNewCard;
            }
        }
        else
        {
            //充值卡
            gv = gvResultChargeCard;
        }
        int hasOrderNum = 0;
        string orderstaff = "";
        foreach (GridViewRow gvr in gv.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                if (hidCardType.Value == "usecard")
                {
                    if (hidApplyType.Value == "ApplyStock")
                    {
                        //存货补货
                        hasOrderNum = Convert.ToInt32(gvr.Cells[11].Text);
                        orderstaff = gvr.Cells[10].Text;
                    }
                    else
                    {
                        //新制卡片
                        hasOrderNum = Convert.ToInt32(gvr.Cells[10].Text);
                        orderstaff = gvr.Cells[9].Text;
                    }
                }
                else
                {
                    //充值卡
                    hasOrderNum = Convert.ToInt32(gvr.Cells[9].Text);
                    orderstaff = gvr.Cells[8].Text;
                }
                if (orderstaff.Substring(0, 6) != context.s_UserID)
                {
                    context.AddError("只能关闭当前操作员工提交的需求单");
                    return;
                }
                if (hasOrderNum > 0)
                {
                    context.AddError("选中的第" + count + "行需求单" + gvr.Cells[1].Text + "已订购数量大于0，不允许关闭！");
                    return;
                }

                //如果是用户卡审核通过，未确认卡面的新制卡片不允许审核通过
                context.DBOpen("Insert");
                context.ExecuteNonQuery("insert into TMP_COMMON (f0,f1) values('" +
                        gvr.Cells[1].Text + "', '" + Session.SessionID + "')");
                context.DBCommit();
            }
        }

        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("没有选中任何行");
            return ;
        }

        //调用关闭需求单存储过程
        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;

        bool ok = context.ExecuteSP("SP_RM_APPLYORDER_CLOSE");

        if (ok)
        {
            AddMessage("关闭需求单成功");

            if (hidCardType.Value == "usecard")
            {
                if (hidApplyType.Value == "ApplyStock")//存货补货
                    bindApplyStock();
                else//新制卡片
                    bindApplyNew();
            }
            else//充值卡
                bindChargeCard();
        }
    }
    /// <summary>
    /// 打印按钮点击事件
    /// </summary>
    protected void btnPrint_Click(object sender, EventArgs e)
    {
        int count = 0;
        ArrayList orderList = new ArrayList();
        string html = "";
        if (hidCardType.Value == "usecard")
        {
            if (hidApplyType.Value == "ApplyStock")
            {
                //存货补货
                for (int index = 0; index < gvResultSupplyCard.Rows.Count; index++)
                {
                    CheckBox cb = (CheckBox)gvResultSupplyCard.Rows[index].FindControl("ItemCheckBox");
                    if (cb != null && cb.Checked)
                    {
                        ++count;
                        orderList.Add(gvResultSupplyCard.Rows[index].Cells[1].Text.Trim());
                    }
                }
                if (count < 1)
                {
                    context.AddError("请选择需要打印的需求单");
                    return;
                }
                html = RMPrintHelper.PrintApplyOrder(context, orderList, "01");
            }
            else
            {
                //新制卡片
                for (int index = 0; index < gvResultNewCard.Rows.Count; index++)
                {
                    CheckBox cb = (CheckBox)gvResultNewCard.Rows[index].FindControl("ItemCheckBox");
                    if (cb != null && cb.Checked)
                    {
                        ++count;
                        orderList.Add(gvResultNewCard.Rows[index].Cells[1].Text.Trim());
                    }
                }
                if (count < 1)
                {
                    context.AddError("请选择需要打印的需求单");
                    return;
                }
                html = RMPrintHelper.PrintApplyOrder(context, orderList, "02");
            }
        }
        else
        {
            //充值卡
            for (int index = 0; index < gvResultChargeCard.Rows.Count; index++)
            {
                CheckBox cb = (CheckBox)gvResultChargeCard.Rows[index].FindControl("ItemCheckBox");
                if (cb != null && cb.Checked)
                {
                    ++count;
                    orderList.Add(gvResultChargeCard.Rows[index].Cells[1].Text.Trim());
                }
            }
            if (count < 1)
            {
                context.AddError("请选择需要打印的需求单");
                return;
            }
            html = RMPrintHelper.PrintChargeCardOrder(context, orderList);
        }
        printarea.InnerHtml = html;
        //执行打印脚本
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
    }

    /// <summary>
    /// 查询条件卡片类型变更事件，更新卡片类型对应的卡面类型
    /// </summary>
    protected void selCardType_change(object sender, EventArgs e)
    {
        //卡面类型
        selFaceType.Items.Clear();
        ResourceManageHelper.selectCardFace(context, selFaceType, true, selCardType.SelectedValue);
    }
    /// <summary>
    /// 申请内容卡面类型变更事件，查询出卡面类型对应的卡样编码
    /// </summary>
    protected void selSupplyFaceType_change(object sender, EventArgs e)
    {
        //查询卡样编码
        DataTable data = ResourceManageHelper.callQuery(context, "queryCardSample", selSupplyFaceType.SelectedValue);

        if (data.Rows.Count != 1)
        {
            linkViewCardFace.Visible = false;
            context.AddError("未找到对应的卡样编码");
            txtCardSampleCode.Text = "";
            return;
        }

        //卡面编码
        txtCardSampleCode.Text = data.Rows[0][0].ToString();

        //显示查看按钮
        linkViewCardFace.Visible = true;
    }
    /// <summary>
    /// 初始化列表
    /// </summary>
    private void showNonDataGridView()
    {
        gvResultSupplyCard.DataSource = new DataTable();
        gvResultSupplyCard.DataBind();
        gvResultNewCard.DataSource = new DataTable();
        gvResultNewCard.DataBind();
        gvResultChargeCard.DataSource = new DataTable();
        gvResultChargeCard.DataBind();
    }
    /// <summary>
    /// 翻页事件
    /// </summary>
    protected void gvResult_Page(object sender, GridViewPageEventArgs e)
    {
        GridView gv = new GridView();
        if (hidCardType.Value == "usecard")
            if (hidApplyType.Value == "ApplyStock")
                //存货补货gridview
                gv = gvResultSupplyCard;
            else
                //新制卡片gridview
                gv = gvResultNewCard;
        else
            //充值卡gridview
            gv = gvResultChargeCard;

        gv.PageIndex = e.NewPageIndex;

        if (hidCardType.Value == "usecard")
            if (hidApplyType.Value == "ApplyStock")
                bindApplyStock();//存货补货
            else
                bindApplyNew();//新制卡片
        else
            bindChargeCard();//充值卡
    }


}