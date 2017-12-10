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
 * 功能名: 卡片管理市民卡下单
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012-12-17    蒋兵兵			初次开发
 ****************************************************************/
public partial class ASP_ResourceManage_RM_SMK_CardOrder : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //绑定卡号段GridView关键字名称
            gvResult.DataKeyNames =
                new string[] { "startcardno", "endcardno", "cardnum" };

            hidCardType.Value = "usecard";
            //卡厂商
            ResourceManageHelper.selectManuWithCoding(context, selManu, true);

            //制卡文件名
            ResourceManageHelper.selFileNameSelect(context, selFileName, true);
            //初始化页面
            init_Page();
            //初始化列表
            showNonDataGridView();
        }

        //固化标签
        ResourceManageHelper.selectTab(this, this.GetType(), hidCardType);
    }
    /// <summary>
    /// 页面初始化
    /// </summary>
    protected void init_Page()
    {
        //初始化日期
        DateTime date = new DateTime();
        date = DateTime.Today;
    }
    #region 查询
    /// <summary>
    /// 查询按钮点击事件
    /// </summary>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //查询校验
        if (!queryValidation())
            return;
    }


    #endregion
    #region 校验
    /// <summary>
    /// 查询输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean queryValidation()
    {


        return !context.hasError();
    }
    /// <summary>
    /// 申请输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean supplyValidation()
    {
        Validation valid = new Validation(context);
        long fromCard = 0, toCard = 0;

        //if (hidCardType.Value == "usecard")//成品卡
        //{
        //    //制卡文件名
        //    if (selFileName.SelectedValue == "99")
        //    {
        //        context.AddError("A094780021", selFileName);
        //    }
        //}

        //卡厂商
        if (selManu.SelectedValue == "99")
        {
            context.AddError("A094780022：请选择卡厂商", selManu);
        }

        //批次号
        if (string.IsNullOrEmpty(txtBatchNo.Text.Trim()))
        {
            context.AddError("A094780023：批次号不能为空", txtBatchNo);
        }
        else if (Validation.strLen(txtBatchNo.Text.Trim()) > 12)
        {
            context.AddError("A094780024：批次号不允许超过12位", txtBatchNo);
        }

        //订购数量
        if (string.IsNullOrEmpty(txtCardSum.Text.Trim()))
        {
            context.AddError("A094780025：订购数量不允许为空", txtCardSum);
        }
        else if (!Validation.isNum(txtCardSum.Text.Trim()))
        {
            context.AddError("A094780026：订购数量只能为数字", txtCardSum);
        }

        //批次日期
        if (string.IsNullOrEmpty(txtDate.Text.Trim()))
        {
            context.AddError("A094780027：批次日期不能为空", txtDate);
        }
        else if (!Validation.isDate(txtDate.Text.Trim(),"yyyyMMdd"))
        {
            context.AddError("A094780028：批次日期格式不正确", txtDate);
        }

        //备注
        if (!string.IsNullOrEmpty(txtReMark.Text.Trim()))
            if (Validation.strLen(txtReMark.Text.Trim()) > 50)
                context.AddError("A095470128:备注长度不能超过50位", txtReMark);

        //校验卡号段与订购数量是否一致
        //对起始卡号进行非空、长度、数字检验


        bool b = valid.notEmpty(txtFromCardNo, "A004112100");
        if (b) b = valid.fixedLength(txtFromCardNo, 16, "A004112101");
        if (b) fromCard = valid.beNumber(txtFromCardNo, "A004112102");

        //对终止卡号进行非空、长度、数字检验


        b = valid.notEmpty(txtToCardNo, "A004112103");
        if (b) b = valid.fixedLength(txtToCardNo, 16, "A004112104");
        if (b) toCard = valid.beNumber(txtToCardNo, "A004112105");

        if (fromCard > 0 && toCard > 0)
        {
            long quantity = toCard - fromCard + 1;
            b = valid.check(quantity >= 0, "A004112106");
            if (b) valid.check(quantity == Convert.ToInt64(txtCardSum.Text.Trim()), "A094780030");
        }

        return !context.hasError();
    }
    #endregion
    #region 提交
    /// <summary>
    /// 提交按钮点击事件
    /// </summary>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        //提交校验
        if (!supplyValidation())
            return;

        //参数赋值
        context.SPOpen();
        context.AddField("P_APPLYORDERTYPE").Value = hidCardType.Value == "usecard" ? "01" : "02";
        context.AddField("P_FILENAME").Value = hidCardType.Value == "usecard" ? selFileName.SelectedItem.Text : "";
        context.AddField("P_MANUTYPECODE").Value = selManu.SelectedValue;
        context.AddField("P_BATCHNO").Value = txtBatchNo.Text;
        context.AddField("P_CARDSUM").Value = txtCardSum.Text;
        context.AddField("P_BATCHDATE").Value = txtDate.Text;
        context.AddField("P_BEGINCARDNO").Value = txtFromCardNo.Text;
        context.AddField("P_ENDCARDNO").Value = txtToCardNo.Text;
        context.AddField("P_ID").Value = hidCardType.Value == "usecard" ? selFileName.SelectedValue : "";
        context.AddField("P_REMARK").Value = txtReMark.Text;

        context.AddField("P_SMKMANUTYPECODE").Value = selManu.SelectedItem.Text.Trim().Split(':')[0].ToString();    //市民卡对应卡厂商编码
        context.AddField("P_INSERTTYPE").Value = selFileName.SelectedValue == "99" ? "1" : "0";                     //是否选择制卡文件名 0：是 1：否 （未填写制卡文件名则在零星制卡文件名称表中新增一行记录）

        bool ok = context.ExecuteSP("SP_SMK_CARDORDER");

        if (ok)
        {
            AddMessage("下单成功");

            //清空
            clear();

            //btnSubmit.Enabled = false;
        }
    }



    /// <summary>
    /// 清空输入项
    /// </summary>
    protected void clear()
    {
        txtBatchNo.Text = "";             //批次号
        txtDate.Text = "";                //批次日期
        txtCardSum.Text = "";             //订购数量
        txtFromCardNo.Text = "";          //起始卡号
        txtToCardNo.Text = "";            //结束卡号
        txtReMark.Text = "";              //备注

        selManu.SelectedIndex = -1;

        //清空卡号段列表
        ResourceManageHelper.resetData(gvResult, null);
    }
    #endregion

    /// <summary>
    /// 初始化列表
    /// </summary>
    private void showNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }

    //制卡文件名选择
    public void selFileName_Change(object sender, EventArgs e)
    {

        //清空输入项
        clear();

        //制卡文件名解析
        string[] strFiles = selFileName.SelectedItem.Text.Split('_');

        try
        {
            //卡厂商选择
            for (int i = 0; i < selManu.Items.Count; i++)
            {
                if (selManu.Items[i].Text.Contains(strFiles[0].ToString()))
                {
                    selManu.SelectedIndex = i;
                    break;
                }
            }

            txtBatchNo.Text = strFiles[1].ToString();
            txtDate.Text = strFiles[2].ToString();
            txtCardSum.Text = strFiles[3].Split('.')[0].ToString();
        }
        catch
        {
        }
    }

    protected void linkGetCard_OnClick(object sender, EventArgs e)
    {
        //校验订购数量是否为空
        if (string.IsNullOrEmpty(txtCardSum.Text))
        {
            context.AddError("A094780025", txtCardSum);
        }
        else if (!Validation.isNum(txtCardSum.Text.Trim()))
        {
            context.AddError("A094780026", txtCardSum);
        }
        if (context.hasError())
            return;

        int selectIndex = -1;
        DataTable dt = GetCardnoSectionHelper.getSMKCardnoSection(context, int.Parse(txtCardSum.Text), ref selectIndex);

        gvResult.DataSource = dt;
        gvResult.DataBind();
        gvResult.SelectedIndex = selectIndex;

        if (selectIndex != -1)
        {
            //调用gvResult列表选中事件
            gvResult_SelectedIndexChanged(sender, e);
        }

    }

    protected void linkCreateCard_OnClick(object sender, EventArgs e)
    {
        context.SPOpen();
        context.AddField("p_cardtypecode").Value = "18";

        bool ok = context.ExecuteSP("SP_RM_SECTIONAUTO");
        if (ok)
        {
            AddMessage("卡片下单号段生成成功");
        }
    }

    #region 卡号段gridview事件
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }
    //卡号段Gridview选择事件
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        string beginCardno = ""; //定义起始卡号
        string endCardno = ""; //定义结束卡号

        //起始卡号
        beginCardno = "2150" + "1801" + getDataKeys("startcardno");
        //未下订购单数量等于订购数量-已订购数量
        Int64 cardnum = Convert.ToInt64(txtCardSum.Text.Trim());
        //结束卡号根据起始卡号和卡片数量计算得出

        //当选择的号段数量大于订单要求数量时，按照订单要求计算结束卡号
        endCardno = (Convert.ToInt64(beginCardno) + cardnum - 1).ToString();

        //起始卡号和结束卡号赋值
        txtFromCardNo.Text = beginCardno;
        txtToCardNo.Text = endCardno;
    }
    //获取关键字的值
    public String getDataKeys(string keysname)
    {
        return gvResult.DataKeys[gvResult.SelectedIndex][keysname].ToString();
    }
    #endregion
    //onRowDataBound公共事件
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            ResourceManageHelper.ClearRowDataBound(e);
        }
    }

}