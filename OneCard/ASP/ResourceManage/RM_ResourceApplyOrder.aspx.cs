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
 * 功能名: 资源管理下单申请
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/07/18    shil			初次开发
 ****************************************************************/
public partial class ASP_ResourceManage_RM_ResourceApplyOrder : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView();
            //初始化页面
            init_Page();
        }

        InitAttribute();
    }

    private void showNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }

    /// <summary>
    /// 页面初始化
    /// </summary>
    protected void init_Page()
    {
        //初始化日期
        DateTime date = new DateTime();
        date = DateTime.Today;
        txtStartDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtEndDate.Text = DateTime.Today.ToString("yyyyMMdd");

        txtApplyOrderID.Text = "XQ";

        //初始化资源类型
        OtherResourceManagerHelper.selectResourceType(context, selResourceType, true);

        //初始化资源类型
        OtherResourceManagerHelper.selectResourceType(context, InResourceType, true);

        //初始化资源名称
        OtherResourceManagerHelper.selectResource(context, selResourceName, true, selResourceType.SelectedValue);

        //初始化资源名称
        OtherResourceManagerHelper.selectResource(context, InResourceName, true, InResourceType.SelectedValue);

    }
    #region 全选列表
    /// <summary>
    /// 选择或取消所有复选框
    /// </summary>
    protected void CheckAll(object sender, EventArgs e)
    {
        //全选信息记录

        CheckBox cbx = (CheckBox)sender;


        foreach (GridViewRow gvr in gvResult.Rows)
        {
            if (!gvr.Cells[1].Enabled) continue;
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }
    #endregion
    #region 查询
    /// <summary>
    /// 查询按钮点击事件
    /// </summary>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //查询校验
        if (!queryValidation())
            return;

        gvResult.DataSource = queryApplyStock();
        gvResult.DataBind();

    }
    /// <summary>
    /// 查询存货补货需求单
    /// </summary>
    /// <returns></returns>
    protected DataTable queryApplyStock()
    {
        //查询存货补货，需求单号如果为XQ时，默认为未输入需求单号
        string applyOrderID = "";
        if (txtApplyOrderID.Text.Trim() != "XQ")
            applyOrderID = txtApplyOrderID.Text.Trim();
        DataTable data = OtherResourceManagerHelper.callOtherQuery(context, "Query_GetApplyOrder", selResourceType.SelectedValue,
            selResourceName.SelectedValue, applyOrderID, txtStartDate.Text.Trim(), txtEndDate.Text.Trim());
        if (data.Rows.Count == 0)
        {
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return data;
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string attribute = "";//属性绑定
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                if (i == 7 || i == 9 || i == 11 || i == 13 || i == 15 || i == 17)
                {
                    if (!string.IsNullOrEmpty(e.Row.Cells[i].Text.Trim()) && e.Row.Cells[i].Text.Trim() != "&nbsp;")
                    {
                        attribute += e.Row.Cells[i - 1].Text.Trim() + ":" + e.Row.Cells[i].Text.Trim() + ";";
                    }
                }
            }
            e.Row.Cells[6].Text = attribute;
        }

        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header)
        {
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                if (i > 6 && i < 18)
                {
                    e.Row.Cells[i].Visible = false;
                }
            }
        }
    }

    /// <summary>
    /// 查询输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean queryValidation()
    {
        //校验需求单号
        if (!string.IsNullOrEmpty(txtApplyOrderID.Text.Trim()) && txtApplyOrderID.Text.Trim() != "XQ")
        {
            if (Validation.strLen(txtApplyOrderID.Text.Trim()) != 18)
                context.AddError("A095470100：需求单号必须为18位", txtApplyOrderID);
            if (!Validation.isCharNum(txtApplyOrderID.Text.Trim()))
                context.AddError("A095470101：需求单必须为英数", txtApplyOrderID);
        }
        //校验日期
        ResourceManageHelper.checkDate(context, txtStartDate, txtEndDate, "A095470102", "A095470103", "A095470104");

        return !context.hasError();
    }
    #endregion
    /// <summary>
    /// 申请输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean supplyValidation()
    {
        //资源类型
        if (InResourceType.SelectedIndex == -1)
        {
            context.AddError("A001002103：请选择资源类型", InResourceType);
        }

        //资源名称
        if (InResourceName.SelectedIndex == -1)
        {
            context.AddError("A001002104：请选择资源名称", InResourceName);
        }

        //下单数量
        if (string.IsNullOrEmpty(txtNum.Text.Trim()) || txtNum.Text.Trim().Equals("0"))
            context.AddError("A095470110:卡片数量不能为空或零", txtNum);
        else if (!Validation.isNum(txtNum.Text.Trim()))
            context.AddError("A095470111：卡片数量必须为数字", txtNum);

        //要求到货日期
        if (string.IsNullOrEmpty(txtDate.Text.Trim()))
            context.AddError("A095470112：要求到货日期不能为空", txtDate);
        else if (!Validation.isDate(txtDate.Text.Trim(), "yyyyMMdd"))
            context.AddError("A095470113：要求到货日期格式必须为yyyyMMdd", txtDate);

        //订单要求
        if (!string.IsNullOrEmpty(txtOrderMand.Text.Trim()))
            if (Validation.strLen(txtOrderMand.Text.Trim()) > 100)
                context.AddError("A094780208:订单要求长度不能超过100位", txtOrderMand);

        //备注
        if (!string.IsNullOrEmpty(txtReMark.Text.Trim()))
            if (Validation.strLen(txtReMark.Text.Trim()) > 255)
                context.AddError("A094780209:备注长度不能超过255位", txtReMark);

        QueryAttributeInfo();
        for (int i = 1; i <= 6; i++)
        {
            Panel divAttribute = UpdatePanel1.FindControl("divAttribute" + i.ToString()) as Panel;
            HiddenField hideISNULL = divAttribute.FindControl("hideISNULL" + i.ToString()) as HiddenField;
            Label lblName = divAttribute.FindControl("lblAttribute" + i.ToString() + "Name") as Label;
            TextBox txtBox = divAttribute.FindControl("txtAttribute" + i.ToString()) as TextBox;
            if (divAttribute.Visible == true)
            {
                if (hideISNULL.Value == "1" && txtBox.Text.Length < 1)
                {
                    string lblNameText = lblName.Text.Substring(0, lblName.Text.Length - 1);
                    context.AddError("请填写" + lblNameText, txtBox);   //属性必填
                }
                if (txtBox.Text.Length > 50)
                {
                    context.AddError(txtBox.Text + "长度不能超过50", txtBox);
                }
            }
        }

        return !context.hasError();
    }
    /// <summary>
    /// 申请按钮点击事件
    /// </summary>
    protected void btnApply_Click(object sender, EventArgs e)
    {
        //提交校验
        if (!supplyValidation())
            return;

        context.SPOpen();
        context.AddField("P_RESOURCECODE").Value = InResourceName.SelectedValue;
        context.AddField("P_ATTRIBUTE1").Value = txtAttribute1.Text.Trim();
        context.AddField("P_ATTRIBUTE2").Value = txtAttribute2.Text.Trim();
        context.AddField("P_ATTRIBUTE3").Value = txtAttribute3.Text.Trim();
        context.AddField("P_ATTRIBUTE4").Value = txtAttribute4.Text.Trim();
        context.AddField("P_ATTRIBUTE5").Value = txtAttribute5.Text.Trim();
        context.AddField("P_ATTRIBUTE6").Value = txtAttribute6.Text.Trim();
        context.AddField("P_RESOURCENUM").Value = txtNum.Text.Trim();
        context.AddField("P_ORDERDEMAND").Value = txtOrderMand.Text.Trim();
        context.AddField("P_REQUIREDATE").Value = txtDate.Text.Trim();
        context.AddField("P_REMARK").Value = txtReMark.Text.Trim();

        context.AddField("P_APPLYORDERID", "String", "output", "18", null);     //需求单号

        //调用资源下单存储过程
        bool ok = context.ExecuteSP("SP_RM_OTHER_ApplyOrder");

        if (ok)
        {
            AddMessage("申请成功");
            //清空
            //clear();
            string html = string.Empty;
            string orderid = "" + context.GetFieldValue("P_APPLYORDERID");  //需求单号
            string resourceAtt = string.Empty;        //属性
            if (!string.IsNullOrEmpty(txtAttribute1.Text.Trim()))
            {
                resourceAtt += lblAttribute1Name.Text.Trim() + ":" + txtAttribute1.Text.Trim() + ";";
            }
            if (!string.IsNullOrEmpty(txtAttribute2.Text.Trim()))
            {
                resourceAtt += lblAttribute2Name.Text.Trim() + txtAttribute2.Text.Trim() + ";";
            }
            if (!string.IsNullOrEmpty(txtAttribute3.Text.Trim()))
            {
                resourceAtt += lblAttribute3Name.Text.Trim() + txtAttribute3.Text.Trim() + ";";
            }
            if (!string.IsNullOrEmpty(txtAttribute4.Text.Trim()))
            {
                resourceAtt += lblAttribute4Name.Text.Trim() + txtAttribute4.Text.Trim() + ";";
            }
            if (!string.IsNullOrEmpty(txtAttribute5.Text.Trim()))
            {
                resourceAtt += lblAttribute5Name.Text.Trim() + txtAttribute5.Text.Trim() + ";";
            }
            if (!string.IsNullOrEmpty(txtAttribute6.Text.Trim()))
            {
                resourceAtt += lblAttribute6Name.Text.Trim() + txtAttribute6.Text.Trim() + ";";
            }

            if (chkOrder.Checked)
            {
                html = RMPrintHelper.PrintResourceApplyOrder(context, orderid, InResourceType.SelectedItem.Text.Split(':')[1].ToString(), InResourceName.SelectedItem.Text.Split(':')[1].ToString()
                        , resourceAtt, txtNum.Text.Trim(), txtDate.Text.Trim(), txtReMark.Text.Trim(), txtOrderMand.Text.Trim(), new GridView());

                printarea.InnerHtml = html;
                //执行打印脚本
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
            }
        }

    }
    /// <summary>
    /// 清空输入项
    /// </summary>
    protected void clear()
    {
        txtAttribute1.Text = "";
        txtAttribute2.Text = "";
        txtAttribute3.Text = "";
        txtAttribute4.Text = "";
        txtAttribute5.Text = "";
        txtAttribute6.Text = "";
        txtNum.Text = "";
        txtDate.Text = "";
        txtOrderMand.Text = "";
        txtReMark.Text = "";

    }

    /// <summary>
    /// 打印按钮点击事件
    /// </summary>
    protected void btnPrint_Click(object sender, EventArgs e)
    {
        int count = 0;
        string html = "";
        for (int index = 0; index < gvResult.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvResult.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
            }
        }
        if (count == 0)
        {
            context.AddError("请选择需要打印的需求单");
            return;
        }

        html = RMPrintHelper.PrintResourceApplyOrder(context, "", "", "", "", "", "", "", "", gvResult);
        printarea.InnerHtml = html;
        //执行打印脚本
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
    }

    // 查询条件处资源类型改变时
    protected void selResourceType_change(object sender, EventArgs e)
    {
        selResourceName.Items.Clear();
        OtherResourceManagerHelper.selectResource(context, selResourceName, true, selResourceType.SelectedValue);
    }

    //填写需求单处资源类型改变时
    protected void InResourceType_change(object sender, EventArgs e)
    {
        InResourceName.Items.Clear();
        OtherResourceManagerHelper.selectResource(context, InResourceName, true, InResourceType.SelectedValue);
        if (InResourceType.SelectedValue == "")
        {
            InResourceName.Enabled = false;
        }
        else
        {
            InResourceName.Enabled = true;
        }
    }

    ArrayList array = new ArrayList();

    /// <summary>
    /// 初始化资源属性(隐藏属性)
    /// </summary>
    private void InitAttribute()
    {
        divAttribute1.Visible = false;
        divAttribute2.Visible = false;
        divAttribute3.Visible = false;
        divAttribute4.Visible = false;
        divAttribute5.Visible = false;
        divAttribute6.Visible = false;
    }

    //
    private void QueryAttributeInfo()
    {
        DataTable dataAttribute = OtherResourceManagerHelper.callOtherQuery(context, "Query_GetAttribute", InResourceName.SelectedValue);
        if (dataAttribute.Rows.Count == 0)
        {
            InitAttribute();
            return;
        }
        else //给隐藏的控件赋值
        {
            DataRow dr = dataAttribute.Rows[0];
            for (int i = 1; i <= 6; i++) //遍历data
            {
                if (dr["ATTRIBUTE" + i.ToString()].ToString().Length != 0)
                {
                    array.Add(i);
                }
            }
            if (array != null) //存在非领用属性
            {
                for (int g = 1; g <= array.Count; g++)
                {
                    Panel divAttribute = UpdatePanel1.FindControl("divAttribute" + g.ToString()) as Panel;
                    string acturalnumber = array[g - 1].ToString();//实际指定的属性number
                    if (dr["ATTRIBUTETYPE" + acturalnumber].ToString() == "0")      //非领用
                    {
                        divAttribute.Visible = true;  //显示Panel
                        Label lbName = divAttribute.FindControl("lblAttribute" + g.ToString() + "Name") as Label;
                        Label lbRed = divAttribute.FindControl("lbRed" + g.ToString()) as Label;
                        TextBox txtBox = divAttribute.FindControl("txtAttribut" + g.ToString()) as TextBox;
                        lbName.Text = dr["ATTRIBUTE" + acturalnumber].ToString(); //显示实际的非领用属性
                        if (dr["ATTRIBUTEISNULL" + acturalnumber].ToString() == "1")
                        {
                            lbRed.Visible = true;
                            HiddenField hideISNULL = divAttribute.FindControl("hideISNULL" + g.ToString()) as HiddenField;
                            hideISNULL.Value = "1";
                        }
                        lbName.Text += ":";
                    }
                }
            }
        }
    }


    //填写需求单处资源名称改变时
    protected void InResourceName_change(object sender, EventArgs e)
    {
        clear();

        QueryAttributeInfo();

        //try
        //{
        //    if (data.Rows[0][2].ToString() == "0")
        //    {
        //        lbAttribute1.Text = data.Rows[0][0].ToString() + "(必填):";
        //    }
        //    if (data.Rows[0][5].ToString() == "0")
        //    {
        //        lbAttribute2.Text = data.Rows[0][3].ToString() + "(必填):";
        //    }
        //    if (data.Rows[0][8].ToString() == "0")
        //    {
        //        lbAttribute3.Text = data.Rows[0][6].ToString() + "(必填):";
        //    }
        //    if (data.Rows[0][11].ToString() == "0")
        //    {
        //        lbAttribute4.Text = data.Rows[0][9].ToString() + "(必填):";
        //    }
        //    if (data.Rows[0][14].ToString() == "0")
        //    {
        //        lbAttribute5.Text = data.Rows[0][12].ToString() + "(必填):";
        //    }
        //    if (data.Rows[0][17].ToString() == "0")
        //    {
        //        lbAttribute6.Text = data.Rows[0][15].ToString() + "(必填):";
        //    }
        //}
        //catch
        //{

        //}
    }

    /// <summary>
    /// 翻页事件
    /// </summary>
    protected void gvResult_Page(object sender, GridViewPageEventArgs e)
    {
        GridView gv = new GridView();

        gv.PageIndex = e.NewPageIndex;
    }


}