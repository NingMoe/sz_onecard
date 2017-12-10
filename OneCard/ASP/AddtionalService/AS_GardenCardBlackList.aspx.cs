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
using TM;
using PDO.AdditionalService;
using Common;
using System.Text;
using System.Collections.Generic;

/******************************
 * 园林黑名单维护
 * 2012-09-26
 * shil
 *****************************/

public partial class ASP_AddtionalService_AS_GardenCardBlackList : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        gvResult.DataKeyNames = new string[] { "CUSTNAME", "PAPERNO"};

        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }
    // gridview换页处理
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //校验查询条件是否有效
        if (!string.IsNullOrEmpty(txtPaperNo.Text.Trim()))
        {
            if (!Validation.isCharNum(txtPaperNo.Text.Trim()))
                context.AddError("A094570055：身份证号码必须为英数", txtPaperNo);
            else if (Validation.strLen(txtPaperNo.Text.Trim()) > 18)
                context.AddError("A094570056：身份证号码长度不能超过18位", txtPaperNo);
        }

        if (context.hasError())
        {
            return;
        }
        string sql = "";
        sql += "select distinct(b.CUSTNAME),a.PAPERNO from TF_F_CARDPARKBLACKLIST a inner join tf_f_customerrec b on  a.PAPERNO = b.PAPERNO(+) where  a.USETAG='1'";
        if(!string.IsNullOrEmpty(txtPaperNo.Text.Trim()))
        {
            StringBuilder strBuilder = new StringBuilder();
            AESHelp.AESEncrypt(txtPaperNo.Text.Trim(), ref strBuilder);
            sql += "and a.PAPERNO = '" + strBuilder.ToString()+ "'";
        }
        context.DBOpen("Select");
        DataTable data = context.ExecuteReader(sql);

        if (data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        //add by jiangbb 解密
        CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" }));

        gvResult.DataSource = data;
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }
    protected void btnAddBlack_Click(object sender, EventArgs e)
    {
        //添加黑名单身份证号有效性校验
        if (string.IsNullOrEmpty(txtAddPaperno.Text.Trim()))
            context.AddError("A094570235：身份证号码不能为空", txtAddPaperno);
        else if (!Validation.isCharNum(txtAddPaperno.Text.Trim()))
            context.AddError("A094570236：身份证号码必须为英数", txtAddPaperno);
        else if (Validation.strLen(txtAddPaperno.Text.Trim()) > 18)
            context.AddError("A094570237：身份证号码长度不能超过18位", txtAddPaperno);
        else if (!Validation.isPaperNo(txtAddPaperno.Text.Trim()))
            context.AddError("A094570238:身份证号码验证不通过", txtAddPaperno);
        if (context.hasError())
        {
            return;
        }

        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtAddPaperno.Text.Trim(), ref strBuilder);

        //判断添加的身份证号是否在黑名单中，并且标志位为有效
        string sql = "";
        sql = "select 1 from TF_F_CARDPARKBLACKLIST where PAPERNO = '" + strBuilder.ToString() + "' and usetag='1'";
        context.DBOpen("Select");
        DataTable dataIsBlack = context.ExecuteReader(sql);
        if (dataIsBlack.Rows.Count > 0)
        {
            context.AddError("添加的身份证号已经在黑名单中");
            return;
        }

        context.SPOpen();
        context.AddField("P_FUNCCODE").Value = "ADDBLACKLIST";
        context.AddField("P_PAPERNO").Value = strBuilder.ToString();
        bool ok = context.ExecuteSP("SP_AS_CARDPARKBLACKLIST");
        if (ok)
        {
            context.AddMessage("加入黑名单成功");
            //刷新列表
            btnQuery_Click(sender, e);
        }
    }
    protected void btnCancelBlack_Click(object sender, EventArgs e)
    {
        context.SPOpen();
        context.AddField("P_FUNCCODE").Value = "DELETEBLACKLIST";
        context.AddField("P_PAPERNO").Value = hidPaperNo.Value;
        bool ok = context.ExecuteSP("SP_AS_CARDPARKBLACKLIST");
        if (ok)
        {
            context.AddMessage("撤取消黑名单成功");
            //刷新列表
            btnQuery_Click(sender, e);
        }
    }
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(getDataKeys("PAPERNO"), ref strBuilder);
        hidPaperNo.Value = strBuilder.ToString();
        //取消黑名单有效
        btnCancelBlack.Enabled = true;
    }
    /// <summary>
    /// 获取关键字的值
    /// </summary>
    public String getDataKeys(string keysname)
    {
        return gvResult.DataKeys[gvResult.SelectedIndex][keysname].ToString();
    }
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        //注册行单击事件
        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }
}