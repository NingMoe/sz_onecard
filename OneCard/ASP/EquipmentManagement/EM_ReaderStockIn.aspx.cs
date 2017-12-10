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
/***************************************************************
 * 功能名: 读卡器出入库
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/08/20    shil			初次开发
 ****************************************************************/
public partial class ASP_EquipmentManagement_EM_ReaderStockIn : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //绑定JS，起始序列号，结束序列号失去焦点事件
            txtFromReaderNo.Attributes["OnBlur"] = "javascript:return Change();";
            txtToReaderNo.Attributes["OnBlur"] = "javascript:return Change();";
            //从厂商编码表(TD_M_MANU)中读取数据，放入下拉列表中

            //设置只读控件
            setReadOnly(txtReaderNum);

            UserCardHelper.selectManu(context, selManufacturer, false);
        }
    }
    /// <summary>
    /// 提交存处理
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        context.SPOpen();
        context.AddField("P_FROMREADERNO").Value = txtFromReaderNo.Text.Trim();
        context.AddField("P_TOREADERNO").Value = txtToReaderNo.Text.Trim();
        context.AddField("P_READERNUMBER").Value = txtReaderNum.Text.Trim();
        context.AddField("P_MANUCODE").Value = selManufacturer.SelectedValue;
        context.AddField("P_REMARK").Value = txtRemark.Text.Trim();

        bool ok = context.ExecuteSP("SP_EM_READERSTOCKIN");
        if (ok)
        {
            AddMessage("入库成功");
            txtFromReaderNo.Text = "";
            txtToReaderNo.Text = "";
            txtReaderNum.Text = "";
            txtRemark.Text = "";
            selManufacturer.SelectedValue = "01";
        }
    }
    /// <summary>
    /// 入库按钮点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnStockIn_Click(object sender, EventArgs e)
    {
        //输入校验
        if (!stockInValidation()) return;

        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Check", "submitConfirm();", true);
    }
    /// <summary>
    /// 输入校验
    /// </summary>
    /// <returns>没有错误时返回true，有错误时返回false</returns>
    protected Boolean stockInValidation()
    {
        //起始序列号
        if (string.IsNullOrEmpty(txtFromReaderNo.Text.Trim()))
            context.AddError("A094570200:读卡器起始序列号不能为空", txtFromReaderNo);
        else if (Validation.strLen(txtFromReaderNo.Text.Trim()) != 16)
            context.AddError("A094570201:读卡器起始序列号长度必须为16位", txtFromReaderNo);
        else if (!Validation.isNum(txtFromReaderNo.Text.Trim()))
            context.AddError("A094570202:读卡器起始序列号必须为数字", txtFromReaderNo);
        //结束序列号
        if (string.IsNullOrEmpty(txtToReaderNo.Text.Trim()))
            context.AddError("A094570203:读卡器结束序列号不能为空", txtToReaderNo);
        else if (Validation.strLen(txtToReaderNo.Text.Trim()) != 16)
            context.AddError("A094570204:读卡器结束序列号长度必须为16位", txtToReaderNo);
        else if (!Validation.isNum(txtToReaderNo.Text.Trim()))
            context.AddError("A094570205:读卡器结束序列号必须为数字", txtToReaderNo);

        if (txtFromReaderNo.Text.Trim().CompareTo(txtToReaderNo.Text.Trim()) > 0)
            context.AddError("A094570206:读卡器起始序列号不能大于结束序列号", txtFromReaderNo);

        //备注
        if (!string.IsNullOrEmpty(txtRemark.Text.Trim()))
            if (Validation.strLen(txtRemark.Text.Trim()) > 50)
                context.AddError("A094570207:备注长度不能超过50位", txtRemark);

        return !context.hasError();
    }
}