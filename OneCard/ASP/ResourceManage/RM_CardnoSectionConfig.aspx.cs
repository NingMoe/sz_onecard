//---------------------------------------------------------------- 
//Copyright (C) 2012-2013 linkage Software 
// All rights reserved.
//<author>jiangbb</author>
//<createDate>2012-07-27</createDate>
//<description>下单号段配置</description>
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

public partial class ASP_ResourceManage_RM_CardnoSectionConfig : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView();
            //初始化卡片类型
            UserCardHelper.selectCardType(context, selCardType, true);
            //初始化卡片类型
            UserCardHelper.selectCardType(context, InCardType, true);

        }
    }
    private void showNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }


    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        //配置表ID
        e.Row.Cells[0].Visible = false;
    }

    //查询
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        ClearControl(); //清空卡片类型、起讫卡号

        DataTable dt = ResourceManageHelper.callQuery(context, "CARDSECTION", selCardType.SelectedValue);
        if (dt == null || dt.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        ResourceManageHelper.resetData(gvResult, dt);
    }

    public ICollection CreateDataTable()
    {
        DataTable dt = ResourceManageHelper.callQuery(context, "CARDSECTION", selCardType.SelectedValue);
        return dt.DefaultView;
        
    }

    /// <summary>
    /// 添加卡号段
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!SubmitValidate()) return;

        context.SPOpen();
        context.AddField("p_cardtypecode").Value = InCardType.SelectedValue;
        context.AddField("p_begincardno").Value = txtFromCardNo.Text.Trim();
        context.AddField("p_endcardno").Value = txtToCardNo.Text.Trim();
        bool ok = context.ExecuteSP("SP_RM_SECTIONADD");
        if (ok)
        {
            AddMessage("下单号段配置新增成功");
            btnQuery_Click(sender, e);
            gvResult_SelectedIndexChanged(sender, e);
            ClearControl();
        }
        
    }

    protected void btnAuto_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(InCardType.SelectedValue))
        {
            context.AddError("A094780004", InCardType);
            return;
        }

        context.SPOpen();
        context.AddField("p_cardtypecode").Value = InCardType.SelectedValue;

        bool ok = context.ExecuteSP("SP_RM_SECTIONAUTO");
        if (ok)
        {
            AddMessage("卡片下单号段分配成功");
        }

    }
    /// <summary> 
    /// 初始化Grid 卡片类型 起讫卡号值
    /// </summary>
    private void ClearControl()
    {
        gvResult.SelectedIndex = -1;
        InCardType.SelectedIndex = 0;
        txtFromCardNo.Text = txtToCardNo.Text = string.Empty;

        btnDetail.Enabled = false;

        //清空可用和已用卡号段列表
        ResourceManageHelper.resetData(gvCardnoUsed, null);
        ResourceManageHelper.resetData(gvCardnoAvailable, null);
        divCardnoUsed.Visible = false;
        divCardnoAvailable.Visible = false;
    }

    /// <summary>
    /// 修改
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnModify_Click(object sender, EventArgs e)
    {
        if (gvResult.SelectedRow == null)
        {
            context.AddError("没有选中任何行");
            return;
        }

        if (!SubmitValidate()) return;

        context.SPOpen();
        context.AddField("p_cardnoconfigid").Value = gvResult.SelectedRow.Cells[0].Text.ToString();
        context.AddField("p_cardtypecode").Value = InCardType.SelectedValue;
        context.AddField("p_begincardno").Value = txtFromCardNo.Text.Trim();
        context.AddField("p_endcardno").Value = txtToCardNo.Text.Trim();
        bool ok = context.ExecuteSP("SP_RM_SECTIONMODIFY");
        if (ok)
        {
            AddMessage("下单号段配置修改成功");
            btnQuery_Click(sender, e);
            ClearControl();
        }
        
    }

    /// <summary>
    /// 删除
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        if (gvResult.SelectedRow == null)
        {
            context.AddError("没有选中任何行");
            return;
        }

        context.SPOpen();
        context.AddField("p_cardnoconfigid").Value = gvResult.SelectedRow.Cells[0].Text.ToString();
        bool ok = context.ExecuteSP("SP_RM_SECTIODELETE");
        if (ok)
        {
            AddMessage("下单号段配置删除成功");

            gvResult.DataSource = CreateDataTable();
            gvResult.DataBind();
        }
        ClearControl();
    }

    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    /// <summary>
    /// 选择行
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        GridViewRow row = gvResult.SelectedRow;
        if (row != null)
        {
            InCardType.SelectedValue = row.Cells[1].Text.Split(':')[0].ToString();
            txtFromCardNo.Text = row.Cells[2].Text;
            txtToCardNo.Text = row.Cells[3].Text;

            btnDetail.Enabled = true;
        }
        else
        {
            btnDetail.Enabled = false;
        }

        ResourceManageHelper.resetData(gvCardnoUsed, null);
        ResourceManageHelper.resetData(gvCardnoAvailable, null);
        divCardnoUsed.Visible = false;
        divCardnoAvailable.Visible = false;
    }

    /// <summary>
    /// 操作校验
    /// </summary>
    /// <returns></returns>
    private bool SubmitValidate()
    {
        Validation valid = new Validation(context);
        long fromCard = 0, toCard = 0;

        //对起始卡号进行非空、长度、数字检验

        if (string.IsNullOrEmpty(InCardType.SelectedValue))
        {
            context.AddError("A094780004", InCardType);
        }

        bool b = valid.notEmpty(txtFromCardNo, "A094780005");
        if (b) b = valid.fixedLength(txtFromCardNo, 8, "A094780006");
        if (b) fromCard = valid.beNumber(txtFromCardNo, "A094780007");

        //对终止卡号进行长度、数字检验

        if (txtToCardNo.Text != "")
        {
            b = valid.fixedLength(txtToCardNo, 8, "A094780009");
            toCard = valid.beNumber(txtToCardNo, "A094780010");

            // 0 <= 终止卡号-起始卡号 <= 10000
            if (fromCard > 0 && toCard > 0)
            {
                long quantity = toCard - fromCard;
                b = valid.check(quantity >= 0, "A004112106",txtToCardNo);
            }
        }
        else
        {
            context.AddError("A094780008",txtToCardNo);
        }

        //预留号段不可配置
        int fromCardNo = Convert.ToInt32(txtFromCardNo.Text.Trim());
        int toCardNo = Convert.ToInt32(txtToCardNo.Text.Trim());

        //if ((30000801 <= fromCardNo && fromCardNo <= 39999999) || ((30000801 <= toCardNo && toCardNo <= 39999999)) || (fromCardNo <= 30000801 && 39999999 <= toCardNo))
        //    context.AddError("30000801到39999999为苏州市民卡预留号段，不允许配置");

        if ((60000001 <= fromCardNo && fromCardNo <= 79999999) || ((60000001 <= toCardNo && toCardNo <= 79999999)) || (fromCardNo <= 60000001 && 79999999 <= toCardNo))
            context.AddError("60000001到79999999为张家港市民卡预留号段，不允许配置");

        return !context.hasError();
    }


    #region 查询可用号段和已用号段
    protected void btnDetail_Click(object sender, EventArgs e)
    {
        GridViewRow row = gvResult.SelectedRow;
        if (row != null)
        {
            string cardtypecode = row.Cells[1].Text.Split(':')[0].ToString();
            //查询已用卡号段
            setCardnoUsedSection(cardtypecode);
            //查询可用卡号段
            setCardnoValidationSection(cardtypecode);

            divCardnoUsed.Visible = true;
            divCardnoAvailable.Visible = true;
        }
    }
    /// <summary>
    /// 查询卡类型所属卡已用号段
    /// </summary>
    /// <param name="cardtypecode">卡类型编码</param>
    /// <returns></returns>
    protected void setCardnoUsedSection(string cardtypecode)
    {
        //清空卡号段列表
        ResourceManageHelper.resetData(gvCardnoUsed, null);

        string sql = "";
        sql += " select min(t.cardno) startcardno , " + //最小卡号
               "        max(t.cardno) endcardno , " + //最大卡号
               "       (max(t.cardno) - min(t.cardno) +1) cardnum " +
               " from  (select n.cardno  " +
               "        from tl_r_icuser n " +
               "        where n.cardtypecode = '" + cardtypecode + "' " +
               "        union " +
               "        select m.cardno  " +
               "        from TD_M_CARDNO_EXCLUDE m " +
               "        where m.cardtypecode = '" + cardtypecode + "' " +
               "        order by cardno) t " +
               " group by t.cardno - rownum ";

        string excutesql = "select re.startcardno , re.endcardno , re.cardnum from ( " + sql + " ) re order by re.startcardno";

        context.DBOpen("Select");
        DataTable CardNoData = context.ExecuteReader(excutesql);

        if (CardNoData.Rows.Count == 0)
        {
            context.AddError("该卡类型没有已用卡号段");
            return;
        }

        DataTable selectRowData = new DataTable();

        gvCardnoUsed.DataSource = CardNoData;
        gvCardnoUsed.DataBind();

    }
    /// <summary>
    /// 查询卡类型所属卡可用号段
    /// </summary>
    /// <param name="cardtypecode">卡类型编码</param>
    /// <returns></returns>
    protected void setCardnoValidationSection(string cardtypecode)
    {
        //清空卡号段列表
        ResourceManageHelper.resetData(gvCardnoAvailable, null);

        string sql = "";
        sql += " select min(t.cardno) startcardno , " + //最小卡号
               "        max(t.cardno) endcardno , " + //最大卡号
               "       (max(t.cardno) - min(t.cardno) +1) cardnum " +
               " from  (select n.cardno  " +
               "        from tf_f_cardnoconfig n " +
               "        where n.cardtypecode = '" + cardtypecode + "' " +
               "        and   not exists (select 1 from TD_M_CARDNO_EXCLUDE b where substr(b.cardno,-8) = n.cardno ) " + //排除排重表中已有卡号
               "        and   not exists (select 1 from tl_r_icuser a where substr(a.cardno,-8) = n.cardno ) " + //排除卡库存表中已有卡号
               "        order by n.cardno) t " +
               " group by t.cardno - rownum ";

        string excutesql = "select re.startcardno , re.endcardno , re.cardnum from ( " + sql + " ) re order by re.startcardno";

        context.DBOpen("Select");
        DataTable CardNoData = context.ExecuteReader(excutesql);

        if (CardNoData.Rows.Count == 0)
        {
            context.AddError("该卡类型没有可用的卡号段");
            return;
        }

        DataTable selectRowData = new DataTable();

        gvCardnoAvailable.DataSource = CardNoData;
        gvCardnoAvailable.DataBind();

    }
    #endregion

}