using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TM;
/**********************************
 * 充值营销模式维护
 * 2012-12-12
 * shil
 * 初次编写
 * ********************************/

public partial class ASP_PartnerShip_PS_Chargetype : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            //指定GridView DataKeyNames
            gvResult.DataKeyNames =
                new string[]{"CHARGETYPECODE","CHARGETYPENAME","CHARGETYPESTATE","STAFFNAME","UPDATETIME"};

            //设置GridView绑定的DataTable
            gvResult.DataSource = query();
            gvResult.DataBind();
            gvResult.SelectedIndex = -1;
        }
    }
    /// <summary>
    /// 查询
    /// </summary>
    /// <returns></returns>
    private ICollection query()
    {
        DataTable data = SPHelper.callQuery("SP_PS_Query", context, "CHARGETYPE");
        return new DataView(data);
    }
    /// <summary>
    /// 增加按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        //增加校验
        if (string.IsNullOrEmpty(txtChargeTypeName.Text.Trim()))
        {
            context.AddError("A094570253:充值营销模式名称不能为空");
        }
        else if (Validation.strLen(txtChargeTypeName.Text.Trim()) > 40)
        {
            context.AddError("A094570254:充值营销模式名称长度不能超过20个汉字");
        }

        if (Validation.strLen(txtChargeTypeState.Text.Trim()) > 400)
        {
            context.AddError("A094570255:充值营销模式说明长度不能超过200个汉字");
        }

        if (context.hasError())
        {
            return;
        }

        //调用增加存储过程
        context.SPOpen();
        context.AddField("P_FUNCCODE").Value = "ADD";
        context.AddField("P_CHARGETYPECODE").Value = "";
        context.AddField("P_CHARGETYPENAME").Value = txtChargeTypeName.Text.Trim();
        context.AddField("P_CHARGETYPESTATE").Value = txtChargeTypeState.Text.Trim();
        bool ok = context.ExecuteSP("SP_PS_CHARGETYPE");
        if (ok)
        {
            context.AddMessage("增加充值营销模式成功！");

            gvResult.DataSource = query();
            gvResult.DataBind();
            gvResult.SelectedIndex = -1;

            txtChargeTypeName.Text = "";
            txtChargeTypeState.Text = "";

            btnDel.Enabled = false;
        }
    }

    /// <summary>
    /// 删除按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDel_Click(object sender, EventArgs e)
    {
        //删除校验
        if (gvResult.SelectedIndex < 0)
        {
            context.AddError(":A094570256:未选中任何行");
        }

        if (context.hasError())
        {
            return;
        }

        //调用删除存储过程
        context.SPOpen();
        context.AddField("P_FUNCCODE").Value = "DELETE";
        context.AddField("P_CHARGETYPECODE").Value = getDataKeys("CHARGETYPECODE");
        context.AddField("P_CHARGETYPENAME").Value = "";
        context.AddField("P_CHARGETYPESTATE").Value = "";
        bool ok = context.ExecuteSP("SP_PS_CHARGETYPE");
        if (ok)
        {
            context.AddMessage("删除充值营销模式成功！");

            gvResult.DataSource = query();
            gvResult.DataBind();
            gvResult.SelectedIndex = -1;

            txtChargeTypeName.Text = "";
            txtChargeTypeState.Text = "";

            btnDel.Enabled = false;
        }
    }

    /// <summary>
    /// 注册行单击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    /// <summary>
    /// 选择数据行
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        btnDel.Enabled = true;
        txtChargeTypeName.Text = getDataKeys("CHARGETYPENAME");
        txtChargeTypeState.Text = getDataKeys("CHARGETYPESTATE");
    }

    public String getDataKeys(string keysname)
    {
        return gvResult.DataKeys[gvResult.SelectedIndex][keysname].ToString();
    }
}