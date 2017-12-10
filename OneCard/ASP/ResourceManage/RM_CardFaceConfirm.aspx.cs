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
using System.IO;
using Master;
using Common;
/***************************************************************
 * 功能名: 资源管理卡面确认
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/07/25    shil			初次开发
 ****************************************************************/
public partial class ASP_ResourceManage_RM_CardFaceConfirm : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            gvOrder.DataKeyNames =
                new string[] { "APPLYORDERID", "CARDNAME", "WAY", "CARDNUM", "REQUIREDATE", 
                    "ORDERDEMAND", "ORDERTIME", "ORDERSTAFF", "REMARK" };

            showOrderDataGridView();

            //添加客户端事件
            preview.Attributes.Add("onload", "onPreviewLoad(this);");
        }
    }
    /// <summary>
    /// 初始化列表
    /// </summary>
    private void showOrderDataGridView()
    {
        gvOrder.DataSource = queryApplyOrder();
        gvOrder.DataBind();
        gvOrder.SelectedIndex = -1;
    }
    /// <summary>
    /// 查询待确认卡面的需求单
    /// </summary>
    /// <returns></returns>
    protected ICollection queryApplyOrder()
    {
        //查询需求单
        DataTable data = ResourceManageHelper.callQuery(context, "queryCardFaceAffirmAppleyOrder");
        return new DataView(data);
    }
    /// <summary>
    /// 上传卡样
    /// </summary>
    protected void btnUpload_Click(object sender, EventArgs e)
    {
        string[] strPics = { ".jpg", ".bmp", ".gif", ".jpeg", ".png" };
        int index = Array.IndexOf(strPics, Path.GetExtension(FileUpload1.FileName).ToLower());
        if (index == -1)
        {
            context.AddError("A094780002:上传文件格式必须为jpg|bmp|jpeg|png|gif");
            return;
        }
        int len = FileUpload1.FileBytes.Length;
        if (len > 1024 * 1024 * 5)
        {
            context.AddError("A094780014：上传文件大于5M");
            return ;
        }
        System.IO.Stream fileDataStream = FileUpload1.PostedFile.InputStream;

        int fileLength = FileUpload1.PostedFile.ContentLength;

        byte[] fileData = new byte[fileLength];

        fileDataStream.Read(fileData, 0, fileLength);
        fileDataStream.Close();

        context.SPOpen();
        context.AddField("P_FUNCCODE").Value = "CARDSAMPLEUPLOAD";
        context.AddField("P_APPLYORDERID").Value = labApplyOrderID.Text.Trim() ;
        context.AddField("P_CARDSAMPLECODE").Value = "";
        context.AddField("P_OUTSAMPLECODE", "String", "output", "6", null);
        bool ok = context.ExecuteSP("SP_RM_CARDFACECONFIRM");

        if (ok)
        {
            labCardSampleNo.Text = context.GetFieldValue("P_OUTSAMPLECODE").ToString();

            ResourceManageHelper.UpdateCardSample(context, labCardSampleNo.Text, fileData); //更新卡样编码表卡样

            AddMessage("添加卡样成功");

            if (!string.IsNullOrEmpty(labApplyOrderID.Text.Trim()) && !string.IsNullOrEmpty(labCardSampleNo.Text.Trim()))
                btnSubmit.Enabled = true;
            else
                btnSubmit.Enabled = false;

            DateTime d = new DateTime();
            preview.Src = "RM_GetPicture.aspx?CardSampleCode=" + labCardSampleNo.Text + "&d=" + d.ToString();

        }
    }
    /// <summary>
    /// 提交确认
    /// </summary>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(labApplyOrderID.Text.Trim()))
        {
            context.AddError("请选择需求单！");
            return;
        }
        if (string.IsNullOrEmpty(labCardSampleNo.Text.Trim()))
        {
            context.AddError("请上传卡样！");
            return;
        }
        context.SPOpen();
        context.AddField("P_FUNCCODE").Value = "CARDFACECONFIRM";
        context.AddField("P_APPLYORDERID").Value = labApplyOrderID.Text.Trim();
        context.AddField("P_CARDSAMPLECODE").Value = labCardSampleNo.Text.Trim();
        context.AddField("P_OUTSAMPLECODE", "String", "output", "6", null);
        bool ok = context.ExecuteSP("SP_RM_CARDFACECONFIRM");

        if (ok)
        {
            AddMessage("卡面确认成功");

            //清空
            labApplyOrderID.Text = "";
            labCardSampleNo.Text = "";
            txtApplyCardOrderID.Text = "";
            //刷新列表
            showOrderDataGridView();
        }
    }
    /// <summary>
    /// 分页事件
    /// </summary>
    protected void gvOrder_Page(object sender, GridViewPageEventArgs e)
    {
        gvOrder.PageIndex = e.NewPageIndex;
        showOrderDataGridView();
    }
    /// <summary>
    /// 选择需求单事件
    /// </summary>
    public void gvOrder_SelectedIndexChanged(object sender, EventArgs e)
    {
        //获取需求单号
        txtApplyCardOrderID.Text = getDataKeys("APPLYORDERID");

        labApplyOrderID.Text = txtApplyCardOrderID.Text;

        if (!string.IsNullOrEmpty(labApplyOrderID.Text.Trim()) && !string.IsNullOrEmpty(labCardSampleNo.Text.Trim()))
            btnSubmit.Enabled = true;
        else
            btnSubmit.Enabled = false;
    }
    /// <summary>
    /// 获取关键字的值
    /// </summary>
    public String getDataKeys(string keysname)
    {
        return gvOrder.DataKeys[gvOrder.SelectedIndex][keysname].ToString();
    }
    protected void gvOrder_RowCreated(object sender, GridViewRowEventArgs e)
    {
        //注册行单击事件
        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvOrder','Select$" + e.Row.RowIndex + "')");
        }
    }
}