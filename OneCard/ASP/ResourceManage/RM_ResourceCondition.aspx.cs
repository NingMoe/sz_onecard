//---------------------------------------------------------------- 
//Copyright (C) 2012-2013 linkage Software 
// All rights reserved.
//<author>jiangbb</author>
//<createDate>2012-12-05</createDate>
//<description>资源定义</description>
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

public partial class ASP_ResourceManage_ResourceCondition : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView(); ;
            //初始化卡片类型

            //初始化资源类型
            OtherResourceManagerHelper.selectResourceType(context, selResourceType, true);

            //初始化资源类型
            OtherResourceManagerHelper.selectResourceType(context, InResourceType, true);

            txtResourceCode.Text = OtherResourceManagerHelper.selectMaxResourceCode(context, "Query_ResourceCode");

        }
    }
    private void showNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }


    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string attribute = "";//属性绑定
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                if (i == 3 || i == 4 || i == 5 || i == 6 || i == 7 || i == 8)
                {
                    if (!string.IsNullOrEmpty(e.Row.Cells[i].Text.ToString()) && e.Row.Cells[i].Text.ToString() != "&nbsp;")
                    {
                        attribute += e.Row.Cells[i].Text + ";";
                    }
                }
            }
            e.Row.Cells[3].Text = attribute;
        }
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[4].Visible = false;
            e.Row.Cells[5].Visible = false;
            e.Row.Cells[6].Visible = false;
            e.Row.Cells[7].Visible = false;
            e.Row.Cells[8].Visible = false;
        }
    }

    //查询
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        foreach (Control item in this.Page.Controls)
        {
            ClearThisControl(item); //清空卡片类型、起讫卡号
        }



        DataTable dt = OtherResourceManagerHelper.callOtherQuery(context, "Query_GridResourceType", selResourceType.SelectedValue);
        if (dt == null || dt.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        ResourceManageHelper.resetData(gvResult, dt);
    }

    public ICollection CreateDataTable()
    {
        DataTable dt = OtherResourceManagerHelper.callOtherQuery(context, "Query_GridResourceType", selResourceType.SelectedValue);
        return dt.DefaultView;

    }

    /// <summary>
    /// 添加资源

    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!SubmitValidate()) return;

        context.SPOpen();
        context.AddField("P_RESOURCECODE").Value = txtResourceCode.Text.Trim();
        context.AddField("P_RESOURCENAME").Value = txtResourceName.Text.Trim();
        context.AddField("P_RESOURCETYPE").Value = InResourceType.SelectedValue;
        context.AddField("P_DESCPIRTION").Value = txtRemark.Text.Trim();
        context.AddField("P_ATTRIBUTE1").Value = txtAttribute1.Text.Trim();
        context.AddField("P_ATTRIBUTETYPE1").Value = !cbType1.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTEISNULL1").Value = !cbIsNull1.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTE2").Value = txtAttribute2.Text.Trim();
        context.AddField("P_ATTRIBUTETYPE2").Value = !cbType2.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTEISNULL2").Value = !cbIsNull2.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTE3").Value = txtAttribute3.Text.Trim();
        context.AddField("P_ATTRIBUTETYPE3").Value = !cbType3.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTEISNULL3").Value = !cbIsNull3.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTE4").Value = txtAttribute4.Text.Trim();
        context.AddField("P_ATTRIBUTETYPE4").Value = !cbType4.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTEISNULL4").Value = !cbIsNull4.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTE5").Value = txtAttribute5.Text.Trim();
        context.AddField("P_ATTRIBUTETYPE5").Value = !cbType5.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTEISNULL5").Value = !cbIsNull5.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTE6").Value = txtAttribute6.Text.Trim();
        context.AddField("P_ATTRIBUTETYPE6").Value = !cbType6.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTEISNULL6").Value = !cbIsNull6.Checked ? "0" : "1";
        bool ok = context.ExecuteSP("SP_RM_OTHER_ConditionAdd");
        if (ok)
        {
            AddMessage("资源添加成功");
            gvResult.DataSource = CreateDataTable();
            gvResult.DataBind();
        }

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
        if (gvResult.SelectedRow.Cells[1].Text.Trim() != txtResourceCode.Text.Trim())
        {
            context.AddError("资源编码不可修改");
            return;
        }

        if (!SubmitValidate()) return;

        context.SPOpen();
        context.AddField("P_RESOURCECODE").Value = txtResourceCode.Text.Trim();
        context.AddField("P_RESOURCENAME").Value = txtResourceName.Text.Trim();
        context.AddField("P_RESOURCETYPE").Value = InResourceType.SelectedValue;
        context.AddField("P_DESCPIRTION").Value = txtRemark.Text.Trim();
        context.AddField("P_ATTRIBUTE1").Value = txtAttribute1.Text.Trim();
        context.AddField("P_ATTRIBUTETYPE1").Value = !cbType1.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTEISNULL1").Value = !cbIsNull1.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTE2").Value = txtAttribute2.Text.Trim();
        context.AddField("P_ATTRIBUTETYPE2").Value = !cbType2.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTEISNULL2").Value = !cbIsNull2.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTE3").Value = txtAttribute3.Text.Trim();
        context.AddField("P_ATTRIBUTETYPE3").Value = !cbType3.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTEISNULL3").Value = !cbIsNull3.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTE4").Value = txtAttribute4.Text.Trim();
        context.AddField("P_ATTRIBUTETYPE4").Value = !cbType4.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTEISNULL4").Value = !cbIsNull4.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTE5").Value = txtAttribute5.Text.Trim();
        context.AddField("P_ATTRIBUTETYPE5").Value = !cbType5.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTEISNULL5").Value = !cbIsNull5.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTE6").Value = txtAttribute6.Text.Trim();
        context.AddField("P_ATTRIBUTETYPE6").Value = !cbType6.Checked ? "0" : "1";
        context.AddField("P_ATTRIBUTEISNULL6").Value = !cbIsNull6.Checked ? "0" : "1";
        bool ok = context.ExecuteSP("SP_RM_OTHER_ConditionModify");
        if (ok)
        {
            AddMessage("资源修改成功");
            gvResult.DataSource = CreateDataTable();
            gvResult.DataBind();
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
        context.AddField("P_RESOURCECODE").Value = txtResourceCode.Text.Trim();
        bool ok = context.ExecuteSP("SP_RM_OTHER_ConditionDelete");
        if (ok)
        {
            AddMessage("资源删除成功");

            btnQuery_Click(sender, e);

        }
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
            DataTable dt = OtherResourceManagerHelper.callOtherQuery(context, "Query_ListResourceType", row.Cells[1].Text.Trim());
            try
            {
                InResourceType.SelectedValue = dt.Rows[0]["RESOURCETYPE"].ToString();   //资源类型
                txtResourceCode.Text = dt.Rows[0]["RESOURCECODE"].ToString();           //资源编码
                txtResourceName.Text = dt.Rows[0]["RESOURCENAME"].ToString();           //资源名称
                txtAttribute1.Text = dt.Rows[0]["ATTRIBUTE1"].ToString();               //属性1名称
                cbType1.Checked = dt.Rows[0]["ATTRIBUTETYPE1"].ToString() == "&nbsp;" || dt.Rows[0]["ATTRIBUTETYPE1"].ToString() == "1" ? true : false;         //领用属性
                cbIsNull1.Checked = dt.Rows[0]["ATTRIBUTEISNULL1"].ToString() == "&nbsp;" || dt.Rows[0]["ATTRIBUTEISNULL1"].ToString() == "1" ? true : false;   //是否必填
                txtAttribute2.Text = dt.Rows[0]["ATTRIBUTE2"].ToString();               //属性2名称
                cbType2.Checked = dt.Rows[0]["ATTRIBUTETYPE2"].ToString() == "&nbsp;" || dt.Rows[0]["ATTRIBUTETYPE2"].ToString() == "1" ? true : false;         //领用属性
                cbIsNull2.Checked = dt.Rows[0]["ATTRIBUTEISNULL2"].ToString() == "&nbsp;" || dt.Rows[0]["ATTRIBUTEISNULL2"].ToString() == "1" ? true : false;   //是否必填
                txtAttribute3.Text = dt.Rows[0]["ATTRIBUTE3"].ToString();               //属性3名称
                cbType3.Checked = dt.Rows[0]["ATTRIBUTETYPE3"].ToString() == "&nbsp;" || dt.Rows[0]["ATTRIBUTETYPE3"].ToString() == "1" ? true : false;         //领用属性
                cbIsNull3.Checked = dt.Rows[0]["ATTRIBUTEISNULL3"].ToString() == "&nbsp;" || dt.Rows[0]["ATTRIBUTEISNULL3"].ToString() == "1" ? true : false;   //是否必填
                txtAttribute4.Text = dt.Rows[0]["ATTRIBUTE4"].ToString();               //属性4名称
                cbType4.Checked = dt.Rows[0]["ATTRIBUTETYPE4"].ToString() == "&nbsp;" || dt.Rows[0]["ATTRIBUTETYPE4"].ToString() == "1" ? true : false;         //领用属性
                cbIsNull4.Checked = dt.Rows[0]["ATTRIBUTEISNULL4"].ToString() == "&nbsp;" || dt.Rows[0]["ATTRIBUTEISNULL4"].ToString() == "1" ? true : false;   //是否必填
                txtAttribute5.Text = dt.Rows[0]["ATTRIBUTE5"].ToString();               //属性5名称
                cbType5.Checked = dt.Rows[0]["ATTRIBUTETYPE5"].ToString() == "&nbsp;" || dt.Rows[0]["ATTRIBUTETYPE5"].ToString() == "1" ? true : false;         //领用属性
                cbIsNull5.Checked = dt.Rows[0]["ATTRIBUTEISNULL5"].ToString() == "&nbsp;" || dt.Rows[0]["ATTRIBUTEISNULL5"].ToString() == "1" ? true : false;   //是否必填
                txtAttribute6.Text = dt.Rows[0]["ATTRIBUTE6"].ToString();               //属性6名称
                cbType6.Checked = dt.Rows[0]["ATTRIBUTETYPE6"].ToString() == "&nbsp;" || dt.Rows[0]["ATTRIBUTETYPE6"].ToString() == "1" ? true : false;         //领用属性
                cbIsNull6.Checked = dt.Rows[0]["ATTRIBUTEISNULL6"].ToString() == "&nbsp;" || dt.Rows[0]["ATTRIBUTEISNULL6"].ToString() == "1" ? true : false;   //是否必填
            }
            catch
            {
            }
        }
    }

    /// <summary>
    /// 操作校验
    /// </summary>
    /// <returns></returns>
    private bool SubmitValidate()
    {
        Validation valid = new Validation(context);

        //对资源类型校验
        if (InResourceType.SelectedValue== "")
        {
            context.AddError("A001002103：请选择资源类型", InResourceType);
        }

        //资源编码校验
        if (string.IsNullOrEmpty(txtResourceCode.Text.Trim()))
        {
            context.AddError("A094780200：资源类型编码不能为空", txtResourceCode);
        }
        else if (Validation.strLen(txtResourceCode.Text.Trim()) > 6)
        {
            context.AddError("A094780201：资源类型编码长度不能超过6位", txtResourceCode);
        }
        else if (!Validation.isNum(txtResourceCode.Text.Trim()))
        {
            context.AddError("A094780202：资源类型编码必须为数字", txtResourceCode);
        }

        //资源名称校验
        if (string.IsNullOrEmpty(txtResourceName.Text.Trim()))
        {
            context.AddError("A094780203：资源名称不能为空", txtResourceName);
        }
        else if (Validation.strLen(txtResourceName.Text.Trim()) > 50)
        {
            context.AddError("A094780204：资源名称长度不能超过50位", txtResourceName);
        }

        //资源描述
        if (Validation.strLen(txtRemark.Text.Trim()) > 250)
        {
            context.AddError("A094780205：资源描述长度不能超过500位", txtRemark);
        }

        //判断属性
        if (cbType1.Checked || cbIsNull1.Checked)
        {
            if (string.IsNullOrEmpty(txtAttribute1.Text.Trim()))
            {
                context.AddError("A094780206:领用属性或是否必填勾选后属性不能为空", txtAttribute1);
            }
            else if (Validation.strLen(txtAttribute1.Text.Trim()) > 50)
            {
                context.AddError("A094780207:属性长度不能超过50位", txtAttribute1);
            }
        }

        if (cbType2.Checked || cbIsNull2.Checked)
        {
            if (string.IsNullOrEmpty(txtAttribute2.Text.Trim()))
            {
                context.AddError("A094780206:领用属性或是否必填勾选后属性不能为空", txtAttribute2);
            }
            else if (Validation.strLen(txtAttribute2.Text.Trim()) > 50)
            {
                context.AddError("A094780207:属性长度不能超过50位", txtAttribute2);
            }
        }

        if (cbType3.Checked || cbIsNull3.Checked)
        {
            if (string.IsNullOrEmpty(txtAttribute3.Text.Trim()))
            {
                context.AddError("A094780206:领用属性或是否必填勾选后属性不能为空", txtAttribute3);
            }
            else if (Validation.strLen(txtAttribute3.Text.Trim()) > 50)
            {
                context.AddError("A094780207:属性长度不能超过50位", txtAttribute3);
            }
        }

        if (cbType4.Checked || cbIsNull4.Checked)
        {
            if (string.IsNullOrEmpty(txtAttribute4.Text.Trim()))
            {
                context.AddError("A094780206:领用属性或是否必填勾选后属性不能为空", txtAttribute4);
            }
            else if (Validation.strLen(txtAttribute4.Text.Trim()) > 50)
            {
                context.AddError("A094780207:属性长度不能超过50位", txtAttribute4);
            }
        }

        if (cbType5.Checked || cbIsNull5.Checked)
        {
            if (string.IsNullOrEmpty(txtAttribute5.Text.Trim()))
            {
                context.AddError("A094780206:领用属性或是否必填勾选后属性不能为空", txtAttribute5);
            }
            else if (Validation.strLen(txtAttribute5.Text.Trim()) > 50)
            {
                context.AddError("A094780207:属性长度不能超过50位", txtAttribute5);
            }
        }

        if (cbType6.Checked || cbIsNull6.Checked)
        {
            if (string.IsNullOrEmpty(txtAttribute6.Text.Trim()))
            {
                context.AddError("A094780206:领用属性或是否必填勾选后属性不能为空", txtAttribute6);
            }
            else if (Validation.strLen(txtAttribute6.Text.Trim()) > 50)
            {
                context.AddError("A094780207:属性长度不能超过50位", txtAttribute6);
            }
        }


        return !context.hasError();
    }

    //清空控件值
    private void ClearThisControl(Control control)
    {
        foreach (Control item in control.Controls)
        {
            if (item is TextBox)
            {
                if (item.ID.Contains("Resource") || item.ID.Contains("Attribute"))
                {
                    ((TextBox)item).Text = "";
                }
            }
            else if (item is CheckBox)
            {
                if (item.ID.Contains("Type") || item.ID.Contains("Null"))
                {
                    ((CheckBox)item).Checked = false;
                }
            }
            else if (item is DropDownList)
            {
                if (item.ID == "InResourceType")
                {
                    ((DropDownList)item).SelectedIndex = -1;
                }
            }
            if (item.Controls.Count > 0)
            {
                ClearThisControl(item);
            }
        }
    }

}