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
 * 功能名: 资源管理订购单查询
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/07/25    shil			初次开发
 ****************************************************************/
public partial class ASP_ResourceManage_RM_QueryOrder : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView();

            hidCardType.Value = "usecard";

            gvResultUseCard.DataKeyNames =
                new string[] { "CARDORDERID","ORDERTYPE","APPLYORDERID", "STATE", "CARDTYPE", "CARDFACE", "CARDSAMPLECODE", 
                    "CARDNAME", "WAY", "CARDNUM", "REQUIREDATE", "LATELYDATE","ALREADYARRIVENUM","RETURNCARDNUM","BEGINCARDNO",
                    "ENDCARDNO","CARDCHIP","COSTYPE","MANUNAME","APPVERNO","VALIDBEGINDATE","VALIDENDDATE",
                    "ORDERTIME", "ORDERSTAFF","EXAMTIME", "EXAMSTAFF", "REMARK" };

            gvResultChargeCard.DataKeyNames =
                new string[] { "CARDORDERID","APPLYORDERID", "STATE", "CARDVALUE", "CARDNUM", "REQUIREDATE", "LATELYDATE",
                    "ALREADYARRIVENUM","RETURNCARDNUM","BEGINCARDNO","ENDCARDNO","ORDERTIME", "ORDERSTAFF","EXAMTIME",
                    "EXAMSTAFF", "REMARK" };

            init_Page();
        }

        //固化标签
        ResourceManageHelper.selectTab(this, this.GetType(), hidCardType);
    }
    /// <summary>
    /// 页面初始化
    /// </summary>
    protected void init_Page()
    {
        //初始化日期
        DateTime date = new DateTime();
        date = DateTime.Today;
        txtStartDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtEndDate.Text = DateTime.Today.ToString("yyyyMMdd");

        txtApplyOrderID.Text = "XQ";
        txtOrderID.Text = "DG";

        //从IC卡卡面编码表(TD_M_CARDSURFACE)中读取数据，放入下拉列表中
        ResourceManageHelper.selectCardFace(context, selFaceType, true, "");
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
            //用户卡
            gv = gvResultUseCard;
        else
            //充值卡
            gv = gvResultChargeCard;

        foreach (GridViewRow gvr in gv.Rows)
        {
            if (!gvr.Cells[1].Enabled) continue;
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }

    }
    #endregion
    /// <summary>
    /// 查询按钮点击事件
    /// </summary>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!queryValidation())
            return;

        if (hidCardType.Value == "usecard")
            bindUseCard();//查询用户卡
        else
            bindChargeCard();//查询充值卡
    }
    /// <summary>
    /// 用户卡GridView绑定数据源
    /// </summary>
    protected void bindUseCard()
    {
        //用户卡
        gvResultUseCard.DataSource = queryUseCard();
        gvResultUseCard.DataBind();
        gvResultUseCard.SelectedIndex = -1;
    }
    /// <summary>
    /// 充值卡GridView绑定数据源
    /// </summary>
    protected void bindChargeCard()
    {
        //充值卡
        gvResultChargeCard.DataSource = queryChargeCard();
        gvResultChargeCard.DataBind();
        gvResultChargeCard.SelectedIndex = -1;
    }
    /// <summary>
    /// 查询用户卡订购单
    /// </summary>
    /// <returns></returns>
    protected ICollection queryUseCard()
    {
        //查询用户卡
        //订购单号如果为DG时，默认为未输入订购单号
        //需求单号如果为XQ时，默认为未输入需求单号
        string cardOrderID = "";
        string applyOrderID = "";
        if (txtOrderID.Text.Trim() != "DG")
            cardOrderID = txtOrderID.Text.Trim();
        if (txtApplyOrderID.Text.Trim() != "XQ")
            applyOrderID = txtApplyOrderID.Text.Trim();
        DataTable data = ResourceManageHelper.callQuery(context, "UseCardOrderQuery",txtStartDate.Text.Trim(), txtEndDate.Text.Trim(),
                                               selExamState.SelectedValue, cardOrderID, applyOrderID, selFaceType.SelectedValue);
        if (data.Rows.Count == 0)
        {
            ResourceManageHelper.resetData(gvResultUseCard, data);
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return new DataView(data);
    }
    /// <summary>
    /// 查询充值卡订购单
    /// </summary>
    /// <returns></returns>
    protected ICollection queryChargeCard()
    {
        //查询充值卡
        //订购单号如果为DG时，默认为未输入订购单号
        //需求单号如果为XQ时，默认为未输入需求单号
        string cardOrderID = "";
        string applyOrderID = "";
        if (txtOrderID.Text.Trim() != "DG")
            cardOrderID = txtOrderID.Text.Trim();
        if (txtApplyOrderID.Text.Trim() != "XQ")
            applyOrderID = txtApplyOrderID.Text.Trim();
        DataTable data = ResourceManageHelper.callQuery(context, "ChargeCardOrderQuery", txtStartDate.Text.Trim(), txtEndDate.Text.Trim(),
                                               selExamState.SelectedValue, cardOrderID, applyOrderID);
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
        //校验日期
        ResourceManageHelper.checkDate(context, txtStartDate, txtEndDate, "A095470102", "A095470103", "A095470104");

        //校验需求单号
        if (!string.IsNullOrEmpty(txtApplyOrderID.Text.Trim()) && txtApplyOrderID.Text.Trim() != "XQ")
        {
            if (Validation.strLen(txtApplyOrderID.Text.Trim()) != 18)
                context.AddError("A095470139：需求单号必须为18位", txtApplyOrderID);
            if (!Validation.isCharNum(txtApplyOrderID.Text.Trim()))
                context.AddError("A095470140：需求单必须为英数", txtApplyOrderID);
        }
        
        //校验订购单号
        if (!string.IsNullOrEmpty(txtOrderID.Text.Trim()) && txtOrderID.Text.Trim() != "DG")
        {
            if (Validation.strLen(txtOrderID.Text.Trim()) != 18)
                context.AddError("A095470137：订购单号必须为18位", txtOrderID);
            if (!Validation.isCharNum(txtOrderID.Text.Trim()))
                context.AddError("A095470138：订购单必须为英数", txtOrderID);
        }

        return !context.hasError();
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
            for (int index = 0; index < gvResultUseCard.Rows.Count; index++)
            {
                CheckBox cb = (CheckBox)gvResultUseCard.Rows[index].FindControl("ItemCheckBox");
                if (cb != null && cb.Checked)
                {
                    ++count;
                    if (gvResultUseCard.Rows[index].Cells[4].Text.Trim().Equals("2:审核作废"))
                    {
                        context.AddError("选中的第" + count + "行订购单已经审核作废，不允许打印！");
                        return;
                    }
                    orderList.Add(gvResultUseCard.Rows[index].Cells[1].Text.Trim());
                }
            }
            if (count < 1)
            {
                context.AddError("请选择需要打印的需求单");
                return;
            }
            html = RMPrintHelper.GetCardOrderPrintText(context, orderList);
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
                    if (gvResultChargeCard.Rows[index].Cells[3].Text.Trim().Equals("2:审核作废"))
                    {
                        context.AddError("选中的第" + count + "行订购单已经审核作废，不允许打印！");
                        return;
                    }
                    orderList.Add(gvResultChargeCard.Rows[index].Cells[1].Text.Trim());
                }
            }
            if (count < 1)
            {
                context.AddError("请选择需要打印的需求单");
                return;
            }
            html = RMPrintHelper.GetChargeCardOrderPrintText(context, orderList);
        }
        printarea.InnerHtml = html;
        //执行打印脚本
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
    }

    /// <summary>
    /// 初始化列表
    /// </summary>
    private void showNonDataGridView()
    {
        gvResultUseCard.DataSource = new DataTable();
        gvResultUseCard.DataBind();
        gvResultChargeCard.DataSource = new DataTable();
        gvResultChargeCard.DataBind();
    }
    #region GridView事件
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            ResourceManageHelper.ClearRowDataBound(e);
        }
    }
    protected void gvResultUseCard_RowCreated(object sender, GridViewRowEventArgs e)
    {
        //注册行单击事件
        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResultUseCard','Select$" + e.Row.RowIndex + "')");
        }
    }
    protected void gvResultChargeCard_RowCreated(object sender, GridViewRowEventArgs e)
    {
        //注册行单击事件
        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResultChargeCard','Select$" + e.Row.RowIndex + "')");
        }
    }
    //选择行事件
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (hidCardType.Value == "usecard")
        {
            txtCardOrderID.Text = getDataKeys("CARDORDERID");
            txtApplyCardOrderID.Text = getDataKeys("APPLYORDERID");
            txtOrderType.Text = getDataKeys("ORDERTYPE").Substring(getDataKeys("ORDERTYPE").IndexOf(":")+1);
            txtExamState.Text = getDataKeys("STATE").Substring(getDataKeys("STATE").IndexOf(":") + 1);

            txtCardType.Text = getDataKeys("CARDTYPE").Substring(getDataKeys("CARDTYPE").IndexOf(":") + 1);
            txtFaceType.Text = getDataKeys("CARDFACE").Substring(getDataKeys("CARDFACE").IndexOf(":") + 1);
            txtCardSampleCode.Text = getDataKeys("CARDSAMPLECODE");
            txtCardName.Text = getDataKeys("CARDNAME");

            txtFromCardNo.Text = getDataKeys("BEGINCARDNO");
            txtToCardNo.Text = getDataKeys("ENDCARDNO");
            txtCardSum.Text = getDataKeys("CARDNUM");
            txtDate.Text = getDataKeys("REQUIREDATE");

            txtLatelyDate.Text = getDataKeys("LATELYDATE");
            txtAlreadyArriveNum.Text = getDataKeys("ALREADYARRIVENUM");
            txtReturnCardNum.Text = getDataKeys("RETURNCARDNUM");
            txtProducer.Text = getDataKeys("MANUNAME").Substring(getDataKeys("MANUNAME").IndexOf(":") + 1);

            txtOrderStaff.Text = getDataKeys("ORDERSTAFF").Substring(getDataKeys("ORDERSTAFF").IndexOf(":") + 1);
            txtOrderTime.Text = getDataKeys("ORDERTIME");
            txtReMark.Text = getDataKeys("REMARK");
        }
        else
        {
            txtChargeOrderID.Text = getDataKeys("CARDORDERID");
            txtApplyChargeOrderID.Text = getDataKeys("APPLYORDERID");
            txtChargeExamState.Text = getDataKeys("STATE").Substring(getDataKeys("STATE").IndexOf(":") + 1);
            txtCardValue.Text = getDataKeys("CARDVALUE").Substring(getDataKeys("CARDVALUE").IndexOf(":") + 1);

            txtChargeCardDate.Text = getDataKeys("REQUIREDATE");
            txtFromChargeCardno.Text = getDataKeys("BEGINCARDNO");
            txtToChargeCardno.Text = getDataKeys("ENDCARDNO");
            txtChargeCardNum.Text = getDataKeys("CARDNUM");

            txtChargeLatelyDate.Text = getDataKeys("LATELYDATE");
            txtChargeAlreadyArriveNum.Text = getDataKeys("ALREADYARRIVENUM");
            txtChargeReturnCardNum.Text = getDataKeys("RETURNCARDNUM");

            txtChargeOrderStaff.Text = getDataKeys("ORDERSTAFF").Substring(getDataKeys("ORDERSTAFF").IndexOf(":") + 1);
            txtChargeOrderTime.Text = getDataKeys("ORDERTIME");
            txtChargeReMark.Text = getDataKeys("REMARK");
        }

    }
    //获取关键字的值
    public String getDataKeys(string keysname)
    {
        GridView gv = new GridView();
        if (hidCardType.Value == "usecard")
            //用户卡
            gv = gvResultUseCard;
        else
            //充值卡
            gv = gvResultChargeCard;

        return gv.DataKeys[gv.SelectedIndex][keysname].ToString();
    }
    //翻页事件
    protected void gvResult_Page(object sender, GridViewPageEventArgs e)
    {
        GridView gv = new GridView();
        if (hidCardType.Value == "usecard")
            //用户卡gridview
            gv = gvResultUseCard;
        else
            //充值卡gridview
            gv = gvResultChargeCard;

        gv.PageIndex = e.NewPageIndex;

        if (hidCardType.Value == "usecard")
            //用户卡列表
            bindUseCard();
        else
            //充值卡列表
            bindChargeCard();
    }
    #endregion
}