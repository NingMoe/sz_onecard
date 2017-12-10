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
 * 功能名: 其他资源管理  资源领用申请
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/12/5   尤悦			初次开发
 * 2013/1/18   尤悦         修改
 ****************************************************************/

public partial class ASP_ResourceManage_RM_GetResourceApply : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            ShowNonDataGridView();
            Init_Page();
     
        }
        selDept.Enabled = false;//申请部门下拉框不可操作
        InitAttribute();      
    }

    /// <summary>
    /// 初始化列表
    /// </summary>
    private void ShowNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }
    /// <summary>
    /// 页面初始化
    /// </summary>
    protected void Init_Page()
    {
        //初始化日期
        DateTime date = new DateTime();
        date = DateTime.Today;
        txtFromDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");
        //初始化资源类型
        OtherResourceManagerHelper.selectResourceType(context, ddlResourceType, true);
        //初始化资源名称
        OtherResourceManagerHelper.selectResource(context, ddlResource, true, ddlResourceType.SelectedValue);
        //初始化申请部门
        OtherResourceManagerHelper.selectDepartment(context, selDept, true);
        selDept.SelectedValue = context.s_DepartID;  //申请部门绑定本部门
        //初始化申请员工
        OtherResourceManagerHelper.selectStaff(context, selStaff, true, selDept.SelectedValue);
        
    }

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
    /// <summary>
    /// 查询按钮点击事件
    /// </summary>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        ddlResourceType.SelectedIndex = 0;
        ddlResource.SelectedIndex = 0;
        txtApplyNum.Text = "";
        txtRemark.Text = "";
        txtUseWay.Text = "";
        InitAttribute();
        //验证日期
        ResourceManageHelper.checkDate(context, txtFromDate, txtToDate, "A001002701:开始日期范围起始值格式必须为yyyyMMdd",
            "A001002702:结束日期范围终止值格式必须为yyyyMMdd", "A001002703:开始日期不能大于结束日期");
        if (context.hasError())
        {
            return;
        }
        gvResult.DataSource = QueryGetResourceApply();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }

    /// <summary>
    /// 查询资源领用申请单（本部门的）
    /// </summary>
    /// <returns></returns>
    protected ICollection QueryGetResourceApply()
    {
        string[] parm = new string[5];
        parm[0] = txtFromDate.Text.Trim();
        parm[1] = txtToDate.Text.Trim();
        parm[2] = selExamState.SelectedValue;
        parm[3] = selDept.SelectedValue;
        parm[4] = selStaff.SelectedValue;
        DataTable data = SPHelper.callQuery("SP_RM_OTHER_QUERY", context, "Query_GetResourceApply", parm);
        if (data.Rows.Count == 0)
        {
            ResourceManageHelper.resetData(gvResult, data);
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return new DataView(data);
    }

    //选择申请部门
    protected void selDept_Changed(object sender, EventArgs e)
    {
        selStaff.Items.Clear(); 
        //初始化申请员工
        OtherResourceManagerHelper.selectStaff(context, selStaff, true, selDept.SelectedValue);
    }

    //申请
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        ReadSelectIndex();
        ValidInput();
        if (context.hasError())
        {
            return;
        }
        context.SPOpen();
        context.AddField("P_USEWAY").Value = txtUseWay.Text.Trim();
        context.AddField("P_RESOURCECODE").Value = ddlResource.SelectedValue;
        context.AddField("P_APPLYGETNUM").Value = Int32.Parse(txtApplyNum.Text.Trim());
        context.AddField("P_REMARK").Value = txtRemark.Text.Trim();        
        if (array != null)   //存在非领用属性
        {
            for(int g=1;g<=array.Count;g++)
            {
                string acturalnumber = array[g - 1].ToString(); //实际指定的属性number
                Panel divAttribute = UpdatePanel1.FindControl("divAttribute" + g.ToString()) as Panel;
                DropDownList ddlAttribute = divAttribute.FindControl("ddlAttribute" + g.ToString()) as DropDownList;
                string attribute = "";
                if (ddlAttribute.SelectedIndex>0)
                {
                    attribute = ddlAttribute.SelectedValue;
                }
                context.AddField("P_ATTRIBUTE" + acturalnumber).Value = attribute;
              }
            if (array.Count<6)//非领用属性个数小于6，则需要增加输入属性参数个数
            {
                ArrayList arrayNew = new ArrayList();
                for (int i = 1; i <= 6;i++ )
                {
                    arrayNew.Add(i);
                }
                for (int g = 1; g <= array.Count; g++)
                {
                     arrayNew.Remove(array[g-1]);
                }
                for (int i = 1; i <= arrayNew.Count;i++ )
                {
                    context.AddField("P_ATTRIBUTE" +arrayNew[i-1].ToString()).Value ="";
                }
            }
        } 
        else  //不存在非领用属性
        {
            context.AddField("P_ATTRIBUTE1").Value = "";
            context.AddField("P_ATTRIBUTE2").Value = "";
            context.AddField("P_ATTRIBUTE3").Value = "";
            context.AddField("P_ATTRIBUTE4").Value = "";
            context.AddField("P_ATTRIBUTE5").Value = "";
            context.AddField("P_ATTRIBUTE6").Value = "";
        }
        bool ok = context.ExecuteSP("SP_RM_GETRESOURCEAPPLYSUBMIT");
        if (ok)
        {
            AddMessage("提交成功");
            btnQuery_Click(sender,e);//刷新列表
        }

    }
    /// <summary>
    /// 记录页面选择的非领用属性
    /// </summary>
    private void ReadSelectIndex()
    {
        for (int i = 1; i <= 6; i++)
        {
            Panel divAttribute = UpdatePanel1.FindControl("divAttribute" + i.ToString()) as Panel;
            HiddenField hideSelectIndex = divAttribute.FindControl("hideSelectIndex" + i.ToString()) as HiddenField;
            Label lblName = divAttribute.FindControl("lblAttribute" + i.ToString() + "Name") as Label;
            DropDownList ddlAttribute = divAttribute.FindControl("ddlAttribute" + i.ToString()) as DropDownList;
            hideSelectIndex.Value = "0";//默认为未选择属性
            hideSelectIndex.Value = ddlAttribute.SelectedIndex.ToString();
        }
    }
    //校验
    private void ValidInput()
    {
        if (ddlResourceType.SelectedIndex < 1) //资源类型必选
        {
            context.AddError("A001002704:请选择资源类型", ddlResourceType);
        }
        if (ddlResource.SelectedIndex < 1) //资源名称必选
        {
            context.AddError("A001002705:请选择资源名称", ddlResource);
        }
        if (txtApplyNum.Text.Trim().Length < 1) //领用数量必选
        {
            context.AddError("A001002706:请填写领用数量", txtApplyNum);
        }
        else
        {
            if (txtApplyNum.Text.Trim().Equals("0"))
            {
                context.AddError("A001002708:领用数量不能为零", txtApplyNum);
            }
            else if (!Validation.isNum(txtApplyNum.Text.Trim()))
            {
                context.AddError("A001002707:领用数量必须是数字", txtApplyNum);
            }
        }
        if (txtUseWay.Text.Trim().Length < 1)  //用途必填
        {
            context.AddError("A001002709:请填写用途", txtUseWay);
        }
        else
        {
            if (txtUseWay.Text.Trim().Length > 50) //用途不超过50个汉字
            {
                context.AddError("A001002710:用途长度不能超过50位", txtUseWay);
            }
        }
        if (txtRemark.Text.Trim().Length > 50) //备注不超过50个汉字
        {
            context.AddError("A001002711:备注长度不能超过50位", txtRemark);
        }
        ClearAttribute();
        QueryAttributeInfo(ddlResource.SelectedValue);
        for (int i = 1; i <= 6; i++)
        {
            Panel divAttribute = UpdatePanel1.FindControl("divAttribute" + i.ToString()) as Panel;
            HiddenField hideISNULL = divAttribute.FindControl("hideISNULL" + i.ToString()) as HiddenField;
            Label lblName = divAttribute.FindControl("lblAttribute" + i.ToString() + "Name") as Label;
            DropDownList ddlAttribute = divAttribute.FindControl("ddlAttribute" + i.ToString()) as DropDownList;
            HiddenField hideSelectIndex = divAttribute.FindControl("hideSelectIndex" + i.ToString()) as HiddenField;
            if (divAttribute.Visible == true)
            {
                string lblNameText = lblName.Text.Substring(0, lblName.Text.Length - 1);
                ddlAttribute.SelectedIndex = int.Parse(hideSelectIndex.Value);
                if (hideISNULL.Value == "1" && ddlAttribute.SelectedIndex < 1)
                {
                    context.AddError("A001002712:" + lblNameText + "不可为空", ddlAttribute);   //属性必填
                }
            }
        }  
     }
   
    
    //选择资源类型
    public void ddlChangeResourceType_change(object sender,EventArgs e)
    {
        ddlResource.Items.Clear();
        //初始化资源名称
        OtherResourceManagerHelper.selectResource(context, ddlResource, true, ddlResourceType.SelectedValue);
        if (ddlResourceType.SelectedValue.Equals(""))
        {
            ddlResource.Enabled = false;        
        }
        else
        {
            ddlResource.Enabled = true;
        }
    }
    //选择资源
    public void ddlChangeResource_change(object sender,EventArgs e)
    {
        ClearAttribute();
        QueryAttributeInfo(ddlResource.SelectedValue);
        txtApplyNum.Text = string.Empty;
        txtRemark.Text = string.Empty;
        txtUseWay.Text = string.Empty;
    }
    ArrayList array = new ArrayList();
    /// <summary>
    /// 获取所选资源的非领用属性
    /// </summary>
    /// <param name="resourcecode"></param>
    private void QueryAttributeInfo(string resourcecode)
    {
        string[] parm = new string[1];
        parm[0] = resourcecode;
        DataTable dataAttribute = SPHelper.callQuery("SP_RM_OTHER_QUERY", context, "Query_GetAttribute", parm);
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
                if (dr["ATTRIBUTE" + i.ToString()].ToString().Length!=0  && dr["ATTRIBUTETYPE" + i.ToString()].ToString() == "0")
                {
                    array.Add(i);
                }               
            }
            if (array!=null) //存在非领用属性
            { 
                   for (int g = 1; g <= array.Count; g++)
                   {
                       Panel divAttribute = UpdatePanel1.FindControl("divAttribute" + g.ToString()) as Panel;
                       divAttribute.Visible = true;  //显示Panel
                       Label lbName = divAttribute.FindControl("lblAttribute" + g.ToString() + "Name") as Label;
                       string acturalnumber = array[g - 1].ToString();//实际指定的属性number
                       lbName.Text = dr["ATTRIBUTE" + acturalnumber].ToString()+":"; //显示实际的非领用属性
                       if (dr["ATTRIBUTEISNULL" + acturalnumber].ToString()=="1")
                       {
                           HiddenField hideISNULL = divAttribute.FindControl("hideISNULL"+g.ToString()) as HiddenField;
                           hideISNULL.Value = "1";
                           HtmlControl span = divAttribute.FindControl("spanAttribute" + g.ToString()) as HtmlControl;
                           span.Visible = true;
                       }
                       DropDownList ddlAttribute = divAttribute.FindControl("ddlAttribute" + g.ToString()) as DropDownList;
                       OtherResourceManagerHelper.queryAttribute(context, ddlAttribute, "Query_Attribute" + acturalnumber, true, parm);
                   }
            }
        }
     }
    /// <summary>
    /// 清空非领用属性框
    /// </summary>
    private void ClearAttribute()
    {
        ddlAttribute1.Items.Clear();
        ddlAttribute2.Items.Clear();
        ddlAttribute3.Items.Clear();
        ddlAttribute4.Items.Clear();
        ddlAttribute5.Items.Clear();
        ddlAttribute6.Items.Clear();
    }
    //用于显示资源属性
    protected void gvResultResourceApply_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string attribute = "";//属性绑定
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {

                if (i == 13 || i == 15 || i == 17 || i == 19 || i == 21 || i == 23)
                {
                    if (!string.IsNullOrEmpty(e.Row.Cells[i].Text.Trim()) && e.Row.Cells[i].Text.Trim() != "&nbsp;")
                    {
                        attribute += e.Row.Cells[i - 1].Text.Trim() + ":" + e.Row.Cells[i].Text.Trim() + ";";
                    }
                }
            }
            e.Row.Cells[4].Text = attribute;
        }

        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header)
        {
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                if (i >= 12)
                {
                    e.Row.Cells[i].Visible = false;  //隐藏资源属性列
                }
            }
        }
    }

   
}

   
        

    
    
