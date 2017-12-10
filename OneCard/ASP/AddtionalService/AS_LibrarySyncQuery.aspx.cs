using System;
using System.Data;
using System.Web.UI;
using Common;
using Master;
using System.Web.UI.WebControls;
using PDO.AdditionalService;
using System.Collections.Generic;

/**********************************
 * 图书馆同步信息查询
 * 2015-01-14
 * gl
 * 初次编写
 * ********************************/
public partial class ASP_AddtionalService_AS_LibrarySyncQuery : Master.Master
{
    #region Initialization
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
            initLoad();
        }
    }


    private void initLoad()
    {
        //初始化日期
        txtFromDate.Text = DateTime.Now.AddDays(-30).ToString("yyyyMMdd");
        txtToDate.Text = DateTime.Now.ToString("yyyyMMdd");
        //初始化同步类型
        selSyncType.Items.Add(new ListItem("---请选择---", ""));
        selSyncType.Items.Add(new ListItem("0001:A卡开通", "0001"));
        selSyncType.Items.Add(new ListItem("0002:A卡挂失", "0002"));
        selSyncType.Items.Add(new ListItem("0003:市民卡补换卡", "0003"));
        selSyncType.Items.Add(new ListItem("0004:卡注销校验", "0004"));
        selSyncType.Items.Add(new ListItem("0005:欠费查询", "0005"));
        selSyncType.Items.Add(new ListItem("1001:开通校验", "1001"));
        selSyncType.Items.Add(new ListItem("1002：开通关闭", "1002"));

        //初始化同步结果
        selSyncStates.Items.Add(new ListItem("---请选择---", ""));
        selSyncStates.Items.Add(new ListItem("0:未同步", "0"));
        selSyncStates.Items.Add(new ListItem("1:同步成功", "1"));
        selSyncStates.Items.Add(new ListItem("2:同步失败", "2"));
        selSyncStates.SelectedIndex = 3;

        //初始化业务处理结果
        selTradeStates.Items.Add(new ListItem("---请选择---", ""));
        selTradeStates.Items.Add(new ListItem("0:未处理", "0"));
        selTradeStates.Items.Add(new ListItem("1:处理成功", "1"));
        selTradeStates.Items.Add(new ListItem("2:处理失败", "2"));
        selTradeStates.SelectedIndex = 3;

        //初始化同步发起方
        selSyncHomes.Items.Add(new ListItem("---请选择---", ""));
        selSyncHomes.Items.Add(new ListItem("01:市民卡公司", "01"));
        selSyncHomes.Items.Add(new ListItem("L1:图书馆", "L1"));
    }
    #endregion 

    #region Private
    /// <summary>
    /// 查询输入有效性验证
    /// </summary>
    private void validate()
    {
        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtFromDate);
        bool b2 = Validation.isEmpty(txtToDate);
        DateTime? fromDate = null, toDate = null;
        if (b1 || b2)//验证是否为空
            context.AddError("开始日期和结束日期必须填写");
        else //验证格式
        {
            if (!b1)
                fromDate = valid.beDate(txtFromDate, "开始日期范围起始值格式必须为yyyyMMdd");

            if (!b2)
                toDate = valid.beDate(txtToDate, "结束日期范围终止值格式必须为yyyyMMdd");
        }

        //验证时间范围是否合理
        if (fromDate != null && toDate != null)
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");

    }
    #endregion

    #region Event Handler
    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        SP_AS_QueryPDO pdo = new SP_AS_QueryPDO();
        pdo.funcCode = "QUERYLIBRARYSYNC";   //查询同步信息
        pdo.var1 = txtCardno.Text.Trim();
        pdo.var2 = selSyncType.SelectedValue.Trim();
        pdo.var3 = selSyncStates.SelectedValue.Trim();
        pdo.var4 = selSyncHomes.SelectedValue.Trim();
        pdo.var5 = selTradeStates.SelectedValue.Trim();
        pdo.var6 = txtFromDate.Text.Trim();
        pdo.var7 = txtToDate.Text.Trim();


        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        //解密
        CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "NAME", "PAPERNO", "PHONE", "ADDR" }));
       
        UserCardHelper.resetData(gvResult, data);
    }

    //分页
    protected void gvResult_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    #endregion
}
