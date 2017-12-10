//---------------------------------------------------------------- 
//Copyright (C) 2012-2013 linkage Software 
// All rights reserved.
//<author>jiangbb</author>
//<createDate></createDate>
//<description>公交测试卡维护</description>
//---------------------------------------------------------------- 
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

public partial class ASP_SpecialDeal_SD_TestToBusCard : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showConGridView();
            //初始化审核状态

        }
    }
    private void showConGridView()
    {
        //显示交易信息列表
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }

    //查询
    protected void btnQuery_Click(object sender, EventArgs e)
    {

        if (!validate(txtCardNo))
        {
            return;
        }

        quertTestBusCard();

        txtFromCardNo.Text = "";
        txtToCardNo.Text = "";

    }

    protected void quertTestBusCard()
    {
        gvResult.DataSource = createGvResultSource();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }

    protected ICollection createGvResultSource()
    {
        //查询测试卡信息
        DataTable dt = SPHelper.callSDQuery(context, "QueryTestBusCard", txtCardNo.Text.Trim());

        return dt.DefaultView;
    }

    /// <summary>
    /// 校验卡号ASN号
    /// </summary>
    /// <param name="txtCardNo">卡号</param>
    /// <param name="txtAsn">ASN号</param>
    /// <returns></returns>
    private bool validate(TextBox txtCardNo)
    {
        if (!string.IsNullOrEmpty(txtCardNo.Text.Trim()))
        {
            if (!Validation.isNum(txtCardNo.Text.Trim()))
            {
                context.AddError("A001004115", txtCardNo);
            }
        }
        return !(context.hasError());
    }

    private bool SubmitValidate()
    {
        Validation valid = new Validation(context);
        long fromCard = 0, toCard = 0;

        //对起始卡号进行非空、长度、数字检验



        bool b = valid.notEmpty(txtFromCardNo, "A004112100");
        if (b) b = valid.fixedLength(txtFromCardNo, 16, "A004112101");
        if (b) fromCard = valid.beNumber(txtFromCardNo, "A004112102");

        //对终止卡号进行长度、数字检验

        if (txtToCardNo.Text != "")
        {
            b = valid.fixedLength(txtToCardNo, 16, "A004112104");
            toCard = valid.beNumber(txtToCardNo, "A004112105");

            // 0 <= 终止卡号-起始卡号 <= 10000
            if (fromCard > 0 && toCard > 0)
            {
                long quantity = toCard - fromCard;
                b = valid.check(quantity >= 0, "A004112106");
                if (b) valid.check(quantity <= 10000, "A004112107");
            }
        }
        else
        {
            context.AddError("A004112103",txtToCardNo);
        }

        return !context.hasError();
    }

    #region 增加、删除事件

    protected void btnBusAdd_Click(object sender, EventArgs e)
    {
        //有效性校验
        if (!SubmitValidate())
            return;
        context.SPOpen();
        context.AddField("p_beginCardNo").Value = txtFromCardNo.Text.Trim();
        context.AddField("p_endCardNo").Value = txtToCardNo.Text.Trim();
        context.AddField("p_dealType").Value = "0";
        bool ok = context.ExecuteSP("SP_SD_TESTTOBUSCARD");
        if (ok)
        {
            AddMessage("添加成功");

            quertTestBusCard();

        }

    }

    protected void btnBusDelete_Click(object sender, EventArgs e)
    {
        //有效性校验
        if (!SubmitValidate())
            return;

        context.SPOpen();
        context.AddField("p_beginCardNo").Value = txtFromCardNo.Text.Trim();
        context.AddField("p_endCardNo").Value = txtToCardNo.Text.Trim();
        context.AddField("p_dealType").Value = "1";
        bool ok = context.ExecuteSP("SP_SD_TESTTOBUSCARD");
        if (ok)
        {
            AddMessage("删除成功");

            quertTestBusCard();

        }
    }
    #endregion




    #region 页面控制事件
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        //分页
        gvResult.PageIndex = e.NewPageIndex;
        quertTestBusCard();
        ClearInfo();
    }

    private void ClearInfo()
    {
        txtCardNo.Text = "";
        txtFromCardNo.Text = "";
        txtToCardNo.Text = "";
    }
    #endregion
}