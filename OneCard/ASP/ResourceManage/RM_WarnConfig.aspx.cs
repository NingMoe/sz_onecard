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

public partial class ASP_ResourceManage_RM_WarnConfig : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView();
            //初始化卡片类型
            UserCardHelper.selectCardType(context, selCardType, true);

            //初始化卡面类型
            UserCardHelper.selectCardFace(context, selCardFaceType, true);

            //初始化所属面值
            ResourceManageHelper.selCardMoney(context, selCardMoney, true);
            hidCardType.Value = "usecard";
        }
        ResourceManageHelper.selectTab(this, this.GetType(), hidCardType);
    }
    protected void selselCardType_change(object sender, EventArgs e)
    {
    }
    private void showNonDataGridView()
    {
        gvResultUseCard.DataSource = new DataTable();
        gvResultUseCard.DataBind();
        gvResultChargeCard.DataSource = new DataTable();
        gvResultChargeCard.DataBind();
    }
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
    }
    
    // 选中gridview当前页所有数据
    protected void CheckAll(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResultUseCard.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }

    // 选中gridview当前页所有数据
    protected void CheckChargeCardAll(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResultChargeCard.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }

    /// <summary>
    /// 查询条件卡片类型变更事件，更新卡片类型对应的卡面类型
    /// </summary>
    protected void selCardType_change(object sender, EventArgs e)
    {
        //卡面类型
        selCardFaceType.Items.Clear();
        ResourceManageHelper.selFaceType(context, selCardFaceType, true, selCardType.SelectedValue);
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (hidCardType.Value == "usecard")     //用户卡
        {
            DataTable dt = ResourceManageHelper.callQuery(context, "WARN_USECARD", selCardType.SelectedValue,
                selCardFaceType.SelectedValue, selWarnType.SelectedValue);
            if (dt == null || dt.Rows.Count == 0)
            {
                AddMessage("N005030001: 查询结果为空");
            }
            ResourceManageHelper.resetData(gvResultUseCard, dt);
            gvResultUseCard.SelectedIndex = -1;
        }
        else if (hidCardType.Value == "chargecard") //充值卡
        {
            DataTable dt = ResourceManageHelper.callQuery(context, "WARN_CHARGECARD", selCardMoney.SelectedValue,
                selWarnType.SelectedValue);
            if (dt == null || dt.Rows.Count == 0)
            {
                AddMessage("N005030001: 查询结果为空");
            }
            ResourceManageHelper.resetData(gvResultChargeCard, dt);
            gvResultChargeCard.SelectedIndex = -1;
        }
        if (selWarnType.SelectedValue == "0")       //是否过滤 0：不过滤 1过滤
        {
            btnAddWarn.Enabled = true;
            btnCancelWarn.Enabled = false;
        }
        else if (selWarnType.SelectedValue == "1")  //是否过滤 0：不过滤 1过滤
        {
            btnAddWarn.Enabled = false;
            btnCancelWarn.Enabled = true;
        }
    }


    /// <summary>
    /// GridView重新绑定
    /// </summary>
    /// <param name="strType">查询选项卡 usecard chargecard</param>
    /// <returns>查询集合</returns>
    private ICollection createGridView(string strType)
    {
        if (strType == "usecard")
        {
            DataTable dt = ResourceManageHelper.callQuery(context, "WARN_USECARD", selCardType.SelectedValue,
                 selCardFaceType.SelectedValue, selWarnType.SelectedValue);
            return dt.DefaultView;
        }
        else
        {
            DataTable dt = ResourceManageHelper.callQuery(context, "WARN_CHARGECARD", selCardMoney.SelectedValue,
                selWarnType.SelectedValue);
            return dt.DefaultView;
        }
    }

    /// <summary>
    /// 向告警临时表中新增需配置信息
    /// </summary>
    /// <param name="context">上下文环境</param>
    /// <param name="gridView">需操作的Grid</param>
    /// <param name="session">当前会话</param>
    /// <param name="warnType">是否需要过滤 0：不过滤 1：过滤</param>
    public void fillWarnConfigList(CmnContext context, GridView gridView, string session,string warnType)
    {
        // 首先清空临时表
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON " + " where F0 = '" + session + "'");

        // 根据页面数据生成临时表数据
        int count = 0;
        for (int index = 0; index < gridView.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gridView.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                if (hidCardType.Value == "usecard")
                {
                    string cardSurfaceCard = gridView.Rows[index].Cells[2].Text.Split(':')[0].ToString();
                    context.ExecuteNonQuery(@"insert into tmp_common(F0,F1,F2) values('" + session + "','" + warnType + "','" + cardSurfaceCard + "')");
                }
                else
                {
                    string valuecode = gridView.Rows[index].Cells[1].Text.Split(':')[0].ToString();
                    context.ExecuteNonQuery(@"insert into tmp_common(F0,F1,F2) values('" + session + "','" + warnType + "','" + valuecode + "')");
                }
            }
        }
        context.DBCommit();
        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("A004P03R01: 没有选中任何行");
        }
    }

    //添加过滤
    protected void btnAddWarn_Click(object sender, EventArgs e)
    {
        string session = Session.SessionID;
        if (hidCardType.Value == "usecard") //用户卡
        {
            fillWarnConfigList(context, gvResultUseCard, session, "0");
            if (context.hasError()) return;

            context.SPOpen();
            context.AddField("p_sessionID").Value = session;
            bool ok = context.ExecuteSP("SP_RM_WARNUSECARD");
            if (ok)
            {
                AddMessage("提交成功");
                gvResultUseCard.DataSource = createGridView("usecard");
                gvResultUseCard.DataBind();
                gvResultUseCard.SelectedIndex = -1;
            }
        }
        else if (hidCardType.Value == "chargecard") //充值卡
        {
            fillWarnConfigList(context, gvResultChargeCard, session, "0");
            if (context.hasError()) return;

            context.SPOpen();
            context.AddField("p_sessionID").Value = session;
            bool ok = context.ExecuteSP("SP_RM_WARNCHARGECARD");
            if (ok)
            {
                AddMessage("提交成功");
                gvResultChargeCard.DataSource = createGridView("chargecard");
                gvResultChargeCard.DataBind();
                gvResultChargeCard.SelectedIndex = -1;
            }
        }
    }

    //取消过滤
    protected void btnCancelWarn_Click(object sender, EventArgs e)
    {
        string session = Session.SessionID;
        if (hidCardType.Value == "usecard") //用户卡
        {
            fillWarnConfigList(context, gvResultUseCard, session, "1");
            if (context.hasError()) return;

            context.SPOpen();
            context.AddField("p_sessionID").Value = session;
            bool ok = context.ExecuteSP("SP_RM_WARNUSECARD");
            if (ok)
            {
                AddMessage("提交成功");
                gvResultUseCard.DataSource = createGridView("usecard");
                gvResultUseCard.DataBind();
                gvResultUseCard.SelectedIndex = -1;
            }
        }
        else if (hidCardType.Value == "chargecard")  //充值卡
        {
            fillWarnConfigList(context, gvResultChargeCard, session, "1");
            if (context.hasError()) return;

            context.SPOpen();
            context.AddField("p_sessionID").Value = session;
            bool ok = context.ExecuteSP("SP_RM_WARNCHARGECARD");
            if (ok)
            {
                AddMessage("提交成功");
                gvResultChargeCard.DataSource = createGridView("chargecard");
                gvResultChargeCard.DataBind();
                gvResultChargeCard.SelectedIndex = -1;
            }
        }
    }


    #region 分页暂时保留
    ////用户卡分页 100
    //public void gvResultUseCard_Page(Object sender, GridViewPageEventArgs e)
    //{
    //    gvResultUseCard.PageIndex = e.NewPageIndex;
    //    btnQuery_Click(sender, e);
    //}
    ////充值卡分页 100
    //public void gvResultChargeCard_Page(Object sender, GridViewPageEventArgs e)
    //{
    //    gvResultChargeCard.PageIndex = e.NewPageIndex;
    //    btnQuery_Click(sender, e);
    //}
    #endregion

}