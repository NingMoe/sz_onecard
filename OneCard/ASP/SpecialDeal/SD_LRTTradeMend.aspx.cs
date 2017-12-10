using System;
using System.Data;
using System.Collections;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;

public partial class ASP_SpecialDeal_SD_SubwayTradeMend : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //指定GridView DataKeyNames
            gvResult.DataKeyNames =
                new string[]{"TRADEID","CARDNO","CHECKSTATECODE","TRADEDATE","TRADETIME","TRADEMONEY",  
               "CARDTRADENO","ERRORREASON","DEALRESULT","DEALSTAFFNO","DEALDATE", "RENEWSTAFF", "RENEWTIME",
               "CHECKSTAFF","CHECKTIME", "REMARK"};

            showConGridView();
            //初始化审核状态

            selChkState.Items.Add(new ListItem("---请选择---", ""));
            selChkState.Items.Add(new ListItem("0:录入待审核", "0"));
            selChkState.Items.Add(new ListItem("1:审核通过", "1"));
            selChkState.Items.Add(new ListItem("2:审核作废", "2"));

            selChkState.SelectedValue = "0";
        }
    }
    private void showConGridView()
    {
        //显示交易信息列表
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }
    #region 查询事件
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //验证有效性
        if (!queryValidation()) return;

        queryLRTTradeMendInfo();
    }
    protected void queryLRTTradeMendInfo()
    {
        gvResult.DataSource = CreateLRTTradeMendDataSource();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }
    public ICollection CreateLRTTradeMendDataSource()
    {
        //查询待审批的业务
        DataTable data = SPHelper.callSDQuery(context, "QueryLRTTradeMendInfo", txtCardNum.Text.Trim(), selChkState.SelectedValue, txtTradeStartDate.Text.Trim(), txtTradeEndDate.Text.Trim(), txtDealStartDate.Text.Trim(), txtDealEndDate.Text.Trim());
        return new DataView(data);
    }
    #endregion

    #region 查询校验
    protected Boolean queryValidation()
    {
        //校验卡号
        if (txtCardNum.Text.Trim() != "")
        {
            if (Validation.strLen(txtCardNum.Text.Trim()) != 16)
                context.AddError("A094570021：卡号必须为16位", txtCardNum);
            else if (!Validation.isNum(txtCardNum.Text.Trim()))
                context.AddError("A094570022：卡号必须为数字", txtCardNum);
        }

        Validation valid = new Validation(context);

        //校验交易开始日期，交易结束日期
        bool b1 = Validation.isEmpty(txtTradeStartDate);
        bool b2 = Validation.isEmpty(txtTradeEndDate);
        DateTime? fromDate = null, toDate = null;
        
        if (!b1)
        {
            fromDate = valid.beDate(txtTradeStartDate, "A094570023:交易开始日期范围起始值格式必须为yyyyMMdd");
        }
        if (!b2)
        {
            toDate = valid.beDate(txtTradeEndDate, "A094570024:交易结束日期范围终止值格式必须为yyyyMMdd");
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "A094570025：交易开始日期不能大于交易结束日期");
        }

        //校验处理开始日期，处理结束日期
        b1 = Validation.isEmpty(txtDealStartDate);
        b2 = Validation.isEmpty(txtDealEndDate);
        fromDate = null;
        toDate = null;

        if (!b1)
        {
            fromDate = valid.beDate(txtDealStartDate, "A094570026：处理开始日期范围起始值格式必须为yyyyMMdd");
        }
        if (!b2)
        {
            toDate = valid.beDate(txtDealEndDate, "A094570027：处理结束日期范围终止值格式必须为yyyyMMdd");
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "A094570028：处理开始日期不能大于处理结束日期");
        }
            
        return !(context.hasError());
    }
    #endregion

    #region 增加、修改、删除事件
    protected void btnBlackAdd_Click(object sender, EventArgs e)
    {
        //有效性校验
        if (!supplyValidation()) return;

        context.SPOpen();
        context.AddField("P_CARDNO").Value = txtCardno.Text.Trim();
        context.AddField("P_TRADEDATE").Value = TradeDate.Text.Trim();
        context.AddField("P_TRADETIME").Value = TradeTime.Text.Trim();
        context.AddField("P_TRADEMONEY").Value = Convert.ToInt32(Convert.ToDouble(txtMoney.Text.Trim()) * 100);
        context.AddField("P_DEALRESULT").Value = txtDealResult.Text.Trim();
        context.AddField("P_DEALSTAFF").Value = txtDealStaff.Text.Trim();
        context.AddField("P_DEALDATE").Value = DealDate.Text.Trim();
        context.AddField("P_REASON").Value = txtReason.Text.Trim();
        context.AddField("P_REMARK").Value = txtRemark.Text.Trim();

        bool ok = context.ExecuteSP("SP_SD_LRTTradeMend_Add");

        if (ok)
        {
            AddMessage("添加成功");
            //清空
            ClearInfo();
            //更新列表
            queryLRTTradeMendInfo();
        }
        
    }
    protected void btnBlackModify_Click(object sender, System.EventArgs e)
    {
        //有效性校验
        if (!supplyValidation()) return;

        if (hidCheckState.Value != "录入待审核")
            context.AddError("审核状态不是录入待审核时不允许修改");
        
        if (context.hasError()) return;

        //调用修改存储过程
        context.SPOpen();
        context.AddField("P_TRADEID").Value = hidTradeId.Value;
        context.AddField("P_CARDNO").Value = txtCardno.Text.Trim();
        context.AddField("P_TRADEDATE").Value = TradeDate.Text.Trim();
        context.AddField("P_TRADETIME").Value = TradeTime.Text.Trim();
        context.AddField("P_TRADEMONEY").Value = Convert.ToInt32(Convert.ToDouble(txtMoney.Text.Trim()) * 100);
        context.AddField("P_DEALRESULT").Value = txtDealResult.Text.Trim();
        context.AddField("P_DEALSTAFF").Value = txtDealStaff.Text.Trim();
        context.AddField("P_DEALDATE").Value = DealDate.Text.Trim();
        context.AddField("P_REASON").Value = txtReason.Text.Trim();
        context.AddField("P_REMARK").Value = txtRemark.Text.Trim();

        bool ok = context.ExecuteSP("SP_SD_LRTTradeMend_Mod");

        if (ok)
        {
            AddMessage("修改成功");
            //清空
            ClearInfo();
            //更新列表
            queryLRTTradeMendInfo();
        }
    }
    protected void btnBlackDelete_Click(object sender, EventArgs e)
    {
        if (hidTradeId.Value.Equals(""))
            context.AddError("未选择要删除的轻轨交易补录信息");
        if (hidCheckState.Value != "录入待审核")
            context.AddError("审核状态不是录入待审核时不允许删除");

        if (context.hasError()) return;

        //调用删除存储过程
        context.SPOpen();
        context.AddField("P_TRADEID").Value = hidTradeId.Value;

        bool ok = context.ExecuteSP("SP_SD_LRTTradeMend_Del");

        if (ok)
        {
            AddMessage("删除成功");
            //清空
            ClearInfo();
            //更新列表
            queryLRTTradeMendInfo();
        }
    }
    #endregion

    #region 提交校验
    protected Boolean supplyValidation()
    {
        //校验卡号
        if (txtCardno.Text.Trim() == "")
            context.AddError("A094570029：卡号不能为空", txtCardno);
        else if (Validation.strLen(txtCardno.Text.Trim()) != 16)
            context.AddError("A094570009：卡号必须为16位", txtCardno);
        else if (!Validation.isNum(txtCardno.Text.Trim()))
            context.AddError("A094570010：卡号必须为数字", txtCardno);

        //校验交易日期
        if (TradeDate.Text.Trim() == "")
            context.AddError("A094570020：交易日期不能为空",TradeDate);
        else if (!(Validation.isDate(TradeDate.Text.Trim(),"yyyyMMdd")))
            context.AddError("A094570032：交易日期格式必须为yyyyMMdd",TradeDate);

        //校验交易时间
        if (TradeTime.Text.Trim() != "")
            if (!(Validation.isTime(TradeTime.Text.Trim())))
                context.AddError("A094570033：交易时间时间格式必须为HH24MISS",TradeTime);

        //校验交易金额
        if (txtMoney.Text.Trim() == "")
            context.AddError("A094570034：交易金额不能为空",txtMoney);
        else if(!Validation.isPosRealNum(txtMoney.Text.Trim()))
            context.AddError("A094570035:交易金额必须为正数,且只允许两位小数");

        //校验处理结果
        if (txtDealResult.Text.Trim() != "")
            if (Validation.strLen(txtDealResult.Text.Trim()) > 25)
                context.AddError("A094570036:处理结果长度不能超过25位", txtDealResult);

        //校验处理员工姓名
        if (txtDealStaff.Text.Trim() != "")
            if (Validation.strLen(txtDealStaff.Text.Trim()) > 10)
                context.AddError("A094570037:处理员工姓名长度不能超过10位", txtDealStaff);

        //校验处理日期
        if (DealDate.Text.Trim() != "")
            if (!(Validation.isDate(DealDate.Text.Trim(), "yyyyMMdd")))
                context.AddError("A094570038：处理日期格式必须为yyyyMMdd", DealDate);

        //校验原因
        if (txtReason.Text.Trim() != "")
            if (Validation.strLen(txtReason.Text.Trim()) > 25)
                context.AddError("A094570039:原因长度不能超过25位", txtReason);

        //校验备注
        if (txtRemark.Text.Trim() != "")
            if (Validation.strLen(txtRemark.Text.Trim()) > 50)
                context.AddError("A094570040:备注长度不能超过50位", txtRemark);

        return !(context.hasError());
    }
    #endregion
    protected void ClearInfo()
    {
        hidTradeId.Value = "";
        txtCardno.Text = "";
        TradeDate.Text = "";
        TradeTime.Text = "";
        txtMoney.Text = "";
        txtDealResult.Text = "";
        txtDealStaff.Text = "";
        DealDate.Text = "";
        labCreateStaffNo.Text = "";
        txtReason.Text = "";
        txtRemark.Text = "";

        btnBlackModify.Enabled = false;
        btnBlackDelete.Enabled = false;
    }

    #region 页面控制事件
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");

        }
    }
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header
            || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[0].Visible = false;
        }
    }
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        //获取参数
        hidTradeId.Value = getDataKeys("TRADEID");
        hidCheckState.Value = getDataKeys("CHECKSTATECODE");
        txtCardno.Text = getDataKeys("CARDNO");
        TradeDate.Text = getDataKeys("TRADEDATE");
        TradeTime.Text = getDataKeys("TRADETIME");
        txtMoney.Text = getDataKeys("TRADEMONEY");
        txtDealResult.Text = getDataKeys("DEALRESULT");
        txtDealStaff.Text = getDataKeys("DEALSTAFFNO");
        DealDate.Text = getDataKeys("DEALDATE");
        labCreateStaffNo.Text = getDataKeys("RENEWSTAFF");
        txtReason.Text = getDataKeys("ERRORREASON");
        txtRemark.Text = getDataKeys("REMARK");

        btnBlackModify.Enabled = true;
        btnBlackDelete.Enabled = true;
    }
    public String getDataKeys(String keysname)
    {
        return gvResult.DataKeys[gvResult.SelectedIndex][keysname].ToString();
    }
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        //分页
        gvResult.PageIndex = e.NewPageIndex;
        queryLRTTradeMendInfo();
        ClearInfo();
    }
    #endregion
}