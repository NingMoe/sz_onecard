//---------------------------------------------------------------- 
//Copyright (C) 2012-2013 linkage Software 
// All rights reserved.
//<author>jiangbb</author>
//<createDate>2012-07-27</createDate>
//<description>库存查询</description>
//---------------------------------------------------------------- 
using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ASP_ResourceManage_RM_QueryStock : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化卡片类型
            UserCardHelper.selectCardType(context, selCardType, true);

            //初始化卡面类型
            ResourceManageHelper.selectCardFace(context, selCardFaceType, true, selCardType.SelectedValue);

            //初始化面值
            ResourceManageHelper.selCardMoneySelect(context, selCardMoney, true);

            showNonDataGridView();

            hidCardType.Value = "usecard";
        }
        ResourceManageHelper.selectTab(this, this.GetType(), hidCardType);

        ondisplay();    //网点结果数量显示
    }

    /// <summary>
    /// 查询
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        ondisplay();
        ResourceManageHelper.resetData(gvUser, new DataTable());
        ResourceManageHelper.resetData(gvCharge, new DataTable());
        if (hidCardType.Value == "usecard")  //用户卡
        {

            DataTable dt = ResourceManageHelper.callQuery(context, "STOCK_USECARD", selCardType.SelectedValue,
                selCardFaceType.SelectedValue, selSellType.SelectedValue);
            if (dt == null || dt.Rows.Count == 0)
            {
                AddMessage("N005030001: 查询结果为空");
            }
            if (selSellType.SelectedValue == "01" || selSellType.SelectedValue == "04") //出入库或回收
            {
                ResourceManageHelper.resetData(gvResultUseCard1, dt);
                gvResultUseCard1.Visible = true;
                gvResultUseCard2.Visible = false;
                gvResultUseCard1.SelectedIndex = -1;

                //出入库
                hidSellType.Value = "01";
            }
            else
            {
                ResourceManageHelper.resetData(gvResultUseCard2, dt);
                gvResultUseCard1.Visible = false;
                gvResultUseCard2.Visible = true;

                //下单
                hidSellType.Value = "02";
            }

        }
        else if (hidCardType.Value == "chargecard") //充值卡
        {

            DataTable dt = ResourceManageHelper.callQuery(context, "STOCK_CHARGECARD", selCardMoney.SelectedValue,
                selSellType.SelectedValue);
            if (dt == null || dt.Rows.Count == 0)
            {
                AddMessage("N005030001: 查询结果为空");
            }

            if (selSellType.SelectedValue == "01")  //出入库
            {
                ResourceManageHelper.resetData(gvResultChargeCard1, dt);
                gvResultChargeCard1.Visible = true;
                gvResultChargeCard2.Visible = false;
                gvResultChargeCard1.SelectedIndex = -1;

                //出入库
                hidSellType.Value = "01";
            }
            else
            {
                ResourceManageHelper.resetData(gvResultChargeCard2, dt);
                gvResultChargeCard1.Visible = false;
                gvResultChargeCard2.Visible = true;

                //下单
                hidSellType.Value = "02";
            }
        }
    }

    //初始化Grid值
    private void showNonDataGridView()
    {
        gvResultUseCard1.DataSource = new DataTable();
        gvResultUseCard1.DataBind();
        gvResultUseCard2.DataSource = new DataTable();
        gvResultUseCard2.DataBind();
        gvResultChargeCard1.DataSource = new DataTable();
        gvResultChargeCard1.DataBind();
        gvResultChargeCard2.DataSource = new DataTable();
        gvResultChargeCard2.DataBind();
        gvUser.DataSource = new DataTable();
        gvUser.DataBind();
        gvCharge.DataSource = new DataTable();
        gvCharge.DataBind();
    }
    //用户卡单击事件
    protected void gvResultUseCard1_RowCreated(object sender, GridViewRowEventArgs e)
    {
        //注册行单击事件
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResultUseCard1','Select$" + e.Row.RowIndex + "')");
        }
    }

    //充值卡单击事件
    protected void gvResultChargeCard1_RowCreated(object sender, GridViewRowEventArgs e)
    {
        //注册行单击事件
        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResultChargeCard1','Select$" + e.Row.RowIndex + "')");
        }
    }

    protected void gv_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
        }
        if (hidCardType.Value == "usecard")
        {
            if (selSellType.SelectedValue == "01" || selSellType.SelectedValue == "04")  //出入库或回收时需要隐藏卡样编码
            {
                e.Row.Cells[6].Visible = false;     //卡样编码
            }
            else
            {
                e.Row.Cells[4].Visible = false;
            }
        }
        e.Row.Cells[0].Visible = false;     //卡片查询状态
    }
    //protected void gvUser_RowDataBound(object sender, GridViewRowEventArgs e)
    //{
    //    if (e.Row.RowType == DataControlRowType.DataRow)
    //    {
    //    }
    //    if (hidCardType.Value == "usecard")
    //    {
    //        if (e.Row.Cells[1].Text.Substring(0,2).Equals("05"))
    //        {
    //            e.Row.Cells[6].Visible = false;     //卡样编码
    //        }
    //        else
    //        {
    //            e.Row.Cells[4].Visible = false;
    //        }
    //    }
    //    e.Row.Cells[0].Visible = false;     //卡片查询状态
    //}

    //用户卡Grid选择
    public void gvResultUseCard1_SelectedIndexChanged(object sender, EventArgs e)
    {
        GridViewRow selectRow = gvResultUseCard1.SelectedRow;
        DataTable dt = new DataTable();
        if (selectRow.Cells[0].Text != "01")    //出库
        {
            return;
        }
        if (!selectRow.Cells[1].Text.Substring(0,2).Equals("05"))
        {
            dt = ResourceManageHelper.callQuery(context, "USECARD_DEPART", selectRow.Cells[1].Text.ToString().Split(':')[0].ToString(),
                selectRow.Cells[2].Text.ToString().Split(':')[0].ToString());
            if (dt == null || dt.Rows.Count == 0)
            {
               AddMessage("N005030001: 查询结果为空");
            }
        }
        else
        {
            dt = ResourceManageHelper.callQuery(context, "GIFTUSECARD_DEPART", selectRow.Cells[1].Text.ToString().Split(':')[0].ToString(),
                selectRow.Cells[2].Text.ToString().Split(':')[0].ToString());
            if (dt == null || dt.Rows.Count == 0)
            {
                AddMessage("N005030001: 查询结果为空");
            }
        }
        
        ResourceManageHelper.resetData(gvUser, dt);
    }

    //充值卡Grid选择
    public void gvResultChargeCard1_SelectedIndexChanged(object sender, EventArgs e)
    {

        GridViewRow selectRow = gvResultChargeCard1.SelectedRow;
        if (selectRow.Cells[0].Text != "01")     //出库
        {
            return;
        }
        DataTable dt = ResourceManageHelper.callQuery(context, "CHARGE_DEPART", selectRow.Cells[1].Text.ToString().Split(':')[0].ToString());
        if (dt == null || dt.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        ResourceManageHelper.resetData(gvCharge, dt);
    }

    /// <summary>
    /// 加载是否显示右边网点剩余数量
    /// </summary>
    private void ondisplay()
    {
        if (selSellType.SelectedValue == "01" )  //选择出库的时候加载事件
        {
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "javascript", "gvOnSelected();", true);
        }
        else
        {
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "javascript", "gvUnSelected();", true);
        }
    }

    //选定卡片类型卡面类型重新绑定
    public void selCardType_SelectedIndexChanged(object sender, EventArgs e)
    {
        selCardFaceType.Items.Clear();
        ResourceManageHelper.selectCardFace(context, selCardFaceType, true, selCardType.SelectedValue);
    }

    //绑定用户卡下单按钮的链接
    protected void gvResultUseCard1_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "applyOrder")
        {
            string cardSurFaceCode = e.CommandArgument.ToString().Split(';')[0].ToString().Split(':')[0].ToString();
            string cardSampleCode = e.CommandArgument.ToString().Split(';')[1].ToString();
            Response.Redirect("RM_ApplyOrder.aspx?surFaceCode=" + cardSurFaceCode + "&sampleCode=" + cardSampleCode);
        }
        else if (e.CommandName == "surFaceCode")
        {
            string cardSurFaceCode = e.CommandArgument.ToString().Split(':')[0].ToString();
            DataTable dt = ResourceManageHelper.callQuery(context, "GETCARDSAMPLECODE", cardSurFaceCode);
            if (dt == null || dt.Rows.Count == 0)
            {
                context.AddError("A094780003:该卡面没有卡样");
                return;
            }
            if (string.IsNullOrEmpty(dt.Rows[0][0].ToString()))
            {
                context.AddError("A094780003:该卡面没有卡样");
                return;
            }


            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "cw", "CreateWindow('RoleWindow','RM_ShowPicture.aspx?surFaceCode=" + dt.Rows[0][0].ToString() + "');", true);

        }
    }

    //绑定充值卡下单跳转
    protected void gvResultChargeCard1_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "applyOrder")
        {
            string valueCode = e.CommandArgument.ToString().Split(':')[0].ToString();
            Response.Redirect("RM_ApplyOrder.aspx?valueCode=" + valueCode);
        }
    }
    protected void btnExportResult_Click(object sender, EventArgs e)
    {
        if (hidCardType.Value == "usecard")  //用户卡
        {
            if (hidSellType.Value == "01")//出入库
            {
                if (gvResultUseCard1.Rows.Count > 0)
                {
                    ExportGridView(gvResultUseCard1);
                }
                else
                {
                    context.AddMessage("查询结果为空，不能导出");
                }
                return;
            }
            if (hidSellType.Value == "02")//下单
            {
                if (gvResultUseCard2.Rows.Count > 0)
                {
                    ExportGridView(gvResultUseCard2);
                }
                else
                {
                    context.AddMessage("查询结果为空，不能导出");
                }
                return;
            }
            return;
        }

        if (hidCardType.Value == "chargecard") //充值卡
        {
            if (hidSellType.Value == "01")//出入库
            {
                if (gvResultChargeCard1.Rows.Count > 0)
                {
                    ExportGridView(gvResultChargeCard1);
                }
                else
                {
                    context.AddMessage("查询结果为空，不能导出");
                }
                return;
            }

            if (hidSellType.Value == "02")//下单
            {
                if (gvResultChargeCard2.Rows.Count > 0)
                {
                    ExportGridView(gvResultChargeCard2);
                }
                else
                {
                    context.AddMessage("查询结果为空，不能导出");
                }
                return;
            }
            return;
        }
    }
    protected void btnExportLeft_Click(object sender, EventArgs e)
    {
        if (hidCardType.Value == "usecard")  //用户卡
        {
            if (gvUser.Rows.Count > 0)
            {
                ExportGridView(gvUser);
            }
            else
            {
                context.AddMessage("查询结果为空，不能导出");
            }
        }
        else if (hidCardType.Value == "chargecard") //充值卡
        {
            if (gvCharge.Rows.Count > 0)
            {
                ExportGridView(gvCharge);
            }
            else
            {
                context.AddMessage("查询结果为空，不能导出");
            }
        }
    }
}