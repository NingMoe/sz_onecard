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
using System.Text.RegularExpressions;
/***************************************************************
 * 功能名: 其他资源管理  资源领用
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/12/12   尤悦			初次开发
 ****************************************************************/


public partial class ASP_ResourceManage_RM_GetResource : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            ShowNonDataGridView();
            Init_Page();

        }
        btnSubmit.Enabled = false;
        InitAttribute(); 
    }
    /// <summary>
    /// 页面初始化
    /// </summary>
    protected void Init_Page()
    {
        txtGetResourceOrderId.Text = "LY";
        //初始化日期
        DateTime date = new DateTime();
        date = DateTime.Today;
        txtFromDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");
        //初始化领用员工
        OtherResourceManagerHelper.selectStaff(context, selStaff, true);
        //初始化领用员工
        OtherResourceManagerHelper.selectStaff(context, ddlStaff, true);
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
        divChangedAttribute1.Visible = false; //隐藏另一种输入方式的属性
        divChangedAttribute2.Visible = false;
        divChangedAttribute3.Visible = false;
        divChangedAttribute4.Visible = false;
        divChangedAttribute5.Visible = false;
        divChangedAttribute6.Visible = false;
    }
     /// <summary>
    /// 查询输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    private Boolean queryValidation()
    {
        //校验需求单号
        if (!string.IsNullOrEmpty(txtGetResourceOrderId.Text.Trim()) && txtGetResourceOrderId.Text.Trim() != "LY")
        {
            if (Validation.strLen(txtGetResourceOrderId.Text.Trim()) != 18)
                context.AddError("A095470139：领用单号必须为18位", txtGetResourceOrderId);
            if (!Validation.isCharNum(txtGetResourceOrderId.Text.Trim()))
                context.AddError("A095470140：领用单号必须为英数", txtGetResourceOrderId);
        }
        //验证日期
        ResourceManageHelper.checkDate(context, txtFromDate, txtToDate, "开始日期范围起始值格式必须为yyyyMMdd",
            "结束日期范围终止值格式必须为yyyyMMdd", "开始日期不能大于结束日期");
        return !context.hasError();
    }

    /// <summary>
    /// 查询按钮点击事件
    /// </summary>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!queryValidation())
            return;
        gvResult.DataSource = QueryGetResourceOrder();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }
    /// <summary>
    /// 查询资源领用单
    /// </summary>
    /// <returns></returns>
    protected ICollection QueryGetResourceOrder()
    {
        //需求单号如果为LY时，默认为未输入领用单号
        string getResourceOrderID = "";
        if (txtGetResourceOrderId.Text.Trim() != "LY")
            getResourceOrderID = txtGetResourceOrderId.Text.Trim();
        string[] parm = new string[5];
        parm[0] = getResourceOrderID;
        parm[1] = txtFromDate.Text.Trim();
        parm[2] = txtToDate.Text.Trim();
        parm[3] = selStaff.SelectedValue;
        parm[4] = selExamState.SelectedValue;
        DataTable data = new DataTable();
        if(selExamState.SelectedIndex==0)
        {
            data = SPHelper.callQuery("SP_RM_OTHER_QUERY", context, "Query_GetResource", parm);
        }
        else
        {
            data = SPHelper.callQuery("SP_RM_OTHER_QUERY", context, "Query_GetResourceChose", parm);
        }
        if (data.Rows.Count == 0)
        {
            ResourceManageHelper.resetData(gvResult, data);
            context.AddMessage("没有查询出任何记录");
            return null;
        }
        return new DataView(data);
    }
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string attribute = "";//属性绑定
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                if (i == 15 || i == 17 || i == 19 || i == 21 || i == 23 || i == 25)
                {
                    if (!string.IsNullOrEmpty(e.Row.Cells[i].Text.Trim()) && e.Row.Cells[i].Text.Trim() != "&nbsp;")
                    {
                        attribute += e.Row.Cells[i - 1].Text.Trim() + ":" + e.Row.Cells[i].Text.Trim() + ";";
                    }
                }
            }
            e.Row.Cells[5].Text = attribute;
        }

        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header)
        {
            for (int i = 0; i < e.Row.Cells.Count; i++)
            {
                if (i >= 14)
                {
                    e.Row.Cells[i].Visible = false;  //隐藏资源属性列
                }
            }
        }
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            ResourceManageHelper.ClearRowDataBound(e);
        }
    }
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {

        //注册行单击事件
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }
    //选择行事件
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        ClearOriginalAttribute();
        ClearChangedAttribute();
        txtStockOutNum.Text = string.Empty;
        ddlStaff.SelectedIndex = 0;
        //显示领用单详细信息
        GridViewRow dr = ((GridView)(sender)).SelectedRow;
        txtResourceType.Text = dr.Cells[2].Text.Trim();
        txtResourceName.Text = dr.Cells[3].Text.Trim();
        txtState.Text = dr.Cells[1].Text.Trim().Substring(2);
        txtApplyNum.Text =dr.Cells[6].Text.Trim();
        txtAgreeNum.Text = dr.Cells[7].Text.Trim();
        txtAlreadyGetNum.Text = dr.Cells[8].Text.Trim();
        hideResourceCode.Value = dr.Cells[4].Text;       //资源编码
        hideGetOrderId.Value = dr.Cells[0].Text;         //领用单号
        if (txtState.Text.Equals("审核通过") || txtState.Text.Equals("部分领用")) //当领用状态为“审核通过”或“部分领用”时，可进行申请操作
        {
            btnSubmit.Enabled=true;
        }
        ddlStaff.SelectedValue = dr.Cells[10].Text.Trim().Substring(0,6);//绑定领用员工是申请员工
        QueryAttributeInfo(hideResourceCode.Value);
    }

    /// <summary>
    /// 获取所选资源的领用属性
    /// </summary>
    /// <param name="resourcecode">资源编码</param>
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
            ArrayList array = new ArrayList();
            DataRow dr = dataAttribute.Rows[0];
            for (int i = 1; i <= 6; i++) //遍历查找领用属性
            {
                if (dr["ATTRIBUTE" + i.ToString()].ToString().Length != 0 && dr["ATTRIBUTETYPE" + i.ToString()].ToString() == "1")
                {
                    array.Add(i);
                }
            }
            if (array != null) //存在领用属性
            {
                for (int g = 1; g <= array.Count; g++)
                {
                    HiddenField hideStyle = Page.FindControl("hideStyle" + g) as HiddenField;
                    if (hideStyle.Value.Equals("1") || hideStyle.Value.Equals("")) //第一种属性输入方式
                    {
                        Panel divAttribute = UpdatePanel1.FindControl("divAttribute" + g.ToString()) as Panel;
                        divAttribute.Visible = true;  //显示第一种输入方式的Panel
                        Label lbName = divAttribute.FindControl("lblAttribute" + g.ToString() + "Name") as Label;
                        string acturalnumber = array[g - 1].ToString();//实际指定的属性number
                        lbName.Text = dr["ATTRIBUTE" + acturalnumber].ToString() + ":"; //显示实际的领用属性
                        if (dr["ATTRIBUTEISNULL" + acturalnumber].ToString() == "1") //如果是必填属性
                        {
                            HiddenField hideISNULL = divAttribute.FindControl("hideISNULL" + g.ToString()) as HiddenField;
                            hideISNULL.Value = "1";
                            HtmlControl span = divAttribute.FindControl("spanAttribute" + g.ToString()) as HtmlControl;
                            span.Visible = true;                            
                        }
                    }
                    else  //第二种属性输入方式
                    {
                        Panel divAttribute = UpdatePanel1.FindControl("divChangedAttribute" + g.ToString()) as Panel;
                        divAttribute.Visible = true;  //显示第二种输入方式的Panel
                        Label lbName = divAttribute.FindControl("lblChangedAttribute" + g.ToString() + "Name") as Label;
                        string acturalnumber = array[g - 1].ToString();//实际指定的属性number
                        lbName.Text = dr["ATTRIBUTE" + acturalnumber].ToString() + ":"; //显示实际的领用属性
                        if (dr["ATTRIBUTEISNULL" + acturalnumber].ToString() == "1") //如果是必填属性
                        {
                            HiddenField hideISNULL = divAttribute.FindControl("hideChangedISNULL" + g.ToString()) as HiddenField;
                            hideISNULL.Value = "1";
                            HtmlControl span = divAttribute.FindControl("spanChangedAttribute" + g.ToString()) as HtmlControl;
                            span.Visible = true;
                        }
                    }
                } 
            }
        }
    }
    private ArrayList AttributeArray()
    {
        ArrayList array = new ArrayList();
        string[] parm = new string[1];
        parm[0] = hideResourceCode.Value;
        DataTable dataAttribute = SPHelper.callQuery("SP_RM_OTHER_QUERY", context, "Query_GetAttribute", parm);
        DataRow dr = dataAttribute.Rows[0];
        for (int i = 1; i <= 6; i++) //遍历查找领用属性
        {
            if (dr["ATTRIBUTE" + i.ToString()].ToString().Length != 0 && dr["ATTRIBUTETYPE" + i.ToString()].ToString() == "1")
            {
                array.Add(i);
            }
        }
        return array;

    }
    //获取领用属性值
    private string GetAttribute(string hideFieldNum, int index)
    {
        HiddenField hideField = Page.FindControl("HiddenField" + hideFieldNum) as HiddenField;
        if (hideField.Value!="")
        {
            HiddenField hideStyle = Page.FindControl("hideStyle" + hideField.Value) as HiddenField;
            if (hideStyle.Value.Equals("1")||hideStyle.Value.Equals("")) //字符输入方式
            {
                Panel divAttribute = UpdatePanel1.FindControl("divAttribute" + hideField.Value) as Panel;
                TextBox txtBox = divAttribute.FindControl("txtAttribute" + hideField.Value) as TextBox;
                HiddenField hideISNULL = divAttribute.FindControl("hideISNULL" + hideField.Value) as HiddenField;//是否必填
                if (string.IsNullOrEmpty(txtBox.Text.Trim()))
                {
                    return "";
                }
                else
                {
                    if(index<1)
                    {
                        return txtBox.Text.Trim();
                    }
                    else
                    {
                       return txtBox.Text.Trim().Split(',')[index - 1];
                    }
                }
            }   
            else  //号段输入方式
            {
                Panel divAttribute = UpdatePanel1.FindControl("divChangedAttribute" + hideField.Value) as Panel;
                HiddenField hideISNULL = divAttribute.FindControl("hideChangedISNULL" + hideField.Value) as HiddenField;//是否必填
                TextBox txtBoxFrom = divAttribute.FindControl("txtChangedAttribute" + hideField.Value + "From") as TextBox;
                TextBox txtBoxTo = divAttribute.FindControl("txtChangedAttribute" + hideField.Value + "To") as TextBox;
                if ((string.IsNullOrEmpty(txtBoxFrom.Text.Trim()) || string.IsNullOrEmpty(txtBoxTo.Text.Trim())))
                    return "";
                else
                {

                    Match match1 = Regex.Match(txtBoxFrom.Text, @"^[0-9]+$", RegexOptions.IgnoreCase);//数字
                    Match match2 = Regex.Match(txtBoxTo.Text, @"^[0-9]+$", RegexOptions.IgnoreCase);
                    long fromCardNum = -1, toCardNum = -1;
                    if (match1.Success && match2.Success) //输入号段方式是数字
                    {
                        fromCardNum = long.Parse(txtBoxFrom.Text.Trim());
                        toCardNum = long.Parse(txtBoxTo.Text.Trim());
                        if(index<1)
                        {
                            return (fromCardNum.ToString() + "-" + toCardNum.ToString());
                        }
                        else
                        {
                            return (toCardNum + (long)(index - 1)).ToString();
                        }  
                    }
                    else
                    {
                        string str1 = RegexString(txtBoxFrom.Text.Trim());
                        long str2 = long.Parse(RegexStringNum(txtBoxFrom.Text.Trim()));
                        int length1 = RegexStringNum(txtBoxFrom.Text.Trim()).Length;
                        int length2 = str2.ToString().Length;
                        string addZero = "";
                        if(length2<length1)
                        {
                            for(int i=0;i<length1-length2;i++)
                            {
                                addZero += "0";
                            }
                            
                        }
                        if (index < 1)
                        {
                            return (str1+addZero+str2 + "-" ).Trim();
                        }
                        else
                        {
                            return (str1 + addZero+(str2 + (long)(index - 1))).ToString().Trim();
                        }  
                    }
                }
            }
       }
        else
        {
            return "";
        }
    }
   
    /// <summary>
    /// 申请按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        ValidInput();
        if(context.hasError())
        {
            return;
        }  
        //清空临时表
        clearTempTable();
        HiddenField1.Value = "";
        HiddenField2.Value = "";
        HiddenField3.Value = "";
        HiddenField4.Value = "";
        HiddenField5.Value = "";
        HiddenField6.Value = "";
        string[] parm = new string[1];
        parm[0] = hideResourceCode.Value;
        DataTable dataAttribute = SPHelper.callQuery("SP_RM_OTHER_QUERY", context, "Query_GetAttribute", parm);
        DataRow dr = dataAttribute.Rows[0];
        ArrayList array = AttributeArray();
        if (array != null)   //存在领用属性
        {
            for (int i = 1; i <= array.Count; i++)
            {
                string acturalAttributeNum = array[i - 1].ToString();//实际存在的领用属性number
                HiddenField hideValue = Page.FindControl("HiddenField" + acturalAttributeNum) as HiddenField;
                hideValue.Value = i.ToString(); //HiddenField记录显示实际属性number的Panel编号
            }
            //记录入临时表
            context.DBOpen("Insert");
            //将每个资源属性记录到临时表
            for (int n = 1; n <= Int32.Parse(txtStockOutNum.Text.Trim()); n++)
            {
                context.ExecuteNonQuery("insert into TMP_COMMON (f0,f1,f2,f3,f4,f5,f6,f7) values('" +
                    n.ToString() + "', '" + GetAttribute("1", n) + "', '" + GetAttribute("2", n) + "', '" + GetAttribute("3", n) +
                    "', '" + GetAttribute("4", n) + "', '" + GetAttribute("5", n) + "', '" + GetAttribute("6", n) + "','" + Session.SessionID + "')");
            }
            context.DBCommit();     
        } 
        context.SPOpen();
        for (int n = 1; n<=6; n++)  
        {
            context.AddField("P_ARRRIBUTESUM" + n.ToString()).Value = GetAttribute(n.ToString(), 0); //资源单据管理台账表中记录资源属性
        }
        context.AddField("P_GETORDERID").Value = hideGetOrderId.Value; //领用单号
        context.AddField("P_SESSIONID").Value = Session.SessionID; //SESSIONID
        context.AddField("P_STOCKOUTNUM").Value = Int32.Parse(txtStockOutNum.Text.Trim()); //出库数量
        context.AddField("P_RESOURCECODE").Value = hideResourceCode.Value;  //资源编码
        context.AddField("P_AGREEGETNUM").Value = Int32.Parse(txtAgreeNum.Text.Trim());  //同意领用数量
        context.AddField("P_APPLYGETNUM").Value = Int32.Parse(txtApplyNum.Text.Trim()); //申请领用数量
        context.AddField("P_ALREADYGETNUM").Value = Int32.Parse(txtAlreadyGetNum.Text.Trim()); //已领用数量
        context.AddField("P_GETSTAFFNO").Value = ddlStaff.SelectedValue; //领用员工

        //调用资源领用存储过程
        bool ok = context.ExecuteSP("SP_RM_OTHER_GETRESOURCE");
        if (ok)
        {
            AddMessage("申请成功");
            gvResult.DataSource = QueryGetResourceOrder();
            gvResult.DataBind();
            gvResult.SelectedIndex = -1;
        }
    }
   
    /// <summary>
    /// 第二种输入方式的点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnChangeStyle_Click(object sender, EventArgs e)
    {
        string index = ((LinkButton)sender).CommandArgument;
        ClearOriginalIndexAttribute(index);
        if (txtState.Text.Equals("审核通过") || txtState.Text.Equals("部分领用")) //当领用状态为“审核通过”或“部分领用”时，可进行申请操作
        {
            btnSubmit.Enabled = true;
        }
        HiddenField hideStyle = Page.FindControl("hideStyle" + index) as HiddenField;
        hideStyle.Value = "2";
        QueryAttributeInfo(hideResourceCode.Value);
    }
    /// <summary>
    /// 还原第一种输入方式的点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnOriginalStyle_Click(object sender, EventArgs e)
    {
        string index = ((LinkButton)sender).CommandArgument;
        ClearChangedIndexAttribute(index);
        if (txtState.Text.Equals("审核通过") || txtState.Text.Equals("部分领用")) //当领用状态为“审核通过”或“部分领用”时，可进行申请操作
        {
            btnSubmit.Enabled = true;
        }
        HiddenField hideStyle = Page.FindControl("hideStyle" + index) as HiddenField;
        hideStyle.Value = "1";
        QueryAttributeInfo(hideResourceCode.Value);
    }


    //申请校验
    private void ValidInput()
    {
        if (txtStockOutNum.Text.Trim().Length < 1) //出库数量必填
        {
            context.AddError("请填写出库数量", txtStockOutNum);
        }
        else
        {
            if (txtStockOutNum.Text.Trim().Equals("0"))
            {
                context.AddError("出库数量领用数量不能为零", txtStockOutNum);
            }
            else if (!Validation.isNum(txtStockOutNum.Text.Trim()))
            {
                context.AddError("出库数量必须是数字", txtStockOutNum);
            }
            else if (Convert.ToInt32(txtStockOutNum.Text.Trim()) + Convert.ToInt32(txtAlreadyGetNum.Text.Trim()) > Convert.ToInt32(txtAgreeNum.Text.Trim()))//如果出库数量+已领用数量>同意领用数量
            {
                context.AddError("出库数量错误", txtStockOutNum);
            }
        }
        if(ddlStaff.SelectedIndex<1) //领用员工必填
        {
            context.AddError("请选择领用员工", ddlStaff);
        }
        ArrayList array = AttributeArray();
        if(array!=null) //如果存在领用属性
        {
            for (int g = 1; g <= array.Count; g++)
            {
                HiddenField hideStyle = Page.FindControl("hideStyle" + g) as HiddenField;
                if (hideStyle.Value.Equals("1") || hideStyle.Value.Equals("")) //第一种属性输入方式
                {
                    Panel divAttribute = UpdatePanel1.FindControl("divAttribute" + g.ToString()) as Panel;
                    divAttribute.Visible = true;  //显示第一种输入方式的Panel
                    
                }
                else  //第二种属性输入方式
                {
                    Panel divAttribute = UpdatePanel1.FindControl("divChangedAttribute" + g.ToString()) as Panel;
                    divAttribute.Visible = true;  //显示第二种输入方式的Panel
                }
            }
            for (int i = 1; i <= array.Count; i++)
            {
                ValidationAttribute(i.ToString());//验证输入属性格式是否正确
            }
        }
        if (txtState.Text.Equals("审核通过") || txtState.Text.Equals("部分领用")) //当领用状态为“审核通过”或“部分领用”时，可进行申请操作
        {
            btnSubmit.Enabled = true;
        }
    }
    /// <summary>
    /// 验证输入属性格式是否正确
    /// </summary>
    /// <param name="attributeNum">页面显示的属性number</param>
    private void ValidationAttribute(string attributeNum)
    {
        Validation valid = new Validation(context);
        HiddenField hideStyle = Page.FindControl("hideStyle" + attributeNum) as HiddenField;
        if (hideStyle.Value.Equals("1")|| hideStyle.Value.Equals("")) //如果是字段方式输入属性
        {
            //字符串输入方式
            Panel divAttribute = UpdatePanel1.FindControl("divAttribute" + attributeNum) as Panel;
            TextBox txtBox = divAttribute.FindControl("txtAttribute" + attributeNum) as TextBox;
            HiddenField hideISNULL = divAttribute.FindControl("hideISNULL" + attributeNum) as HiddenField;//是否必填
            if (hideISNULL.Value.Equals("") && txtBox.Text.Trim().Length < 1) //如果领用属性为不必填且输入领用属性为空时
            {
                return;
            }
            if (hideISNULL.Value.Equals("1") && txtBox.Text.Trim().Length < 1) //如果领用属性为必填且输入领用属性为空时
            {
                Label lblAttribute = divAttribute.FindControl("lblAttribute" + attributeNum + "Name") as Label;
                context.AddError("请输入" + lblAttribute.Text.Substring(0, lblAttribute.Text.Length-1), txtBox);
            }
            else
            {
                string attribute = txtBox.Text.Trim();
                foreach (string s in attribute.Split(','))
                {
                    if (s.Length > 50)
                    {
                        context.AddError("分割后长度不可超过50位", txtBox);
                        break;
                    }
                }
                if (attribute.Split(',').Length != Int32.Parse(txtStockOutNum.Text.Trim()))
                    context.AddError("分割后数量与签收数量不一致", txtBox);
            } 
        }
        else //如果是号段方式输入属性
        {
            Panel divAttribute = UpdatePanel1.FindControl("divChangedAttribute" + attributeNum) as Panel;
            HiddenField hideISNULL = divAttribute.FindControl("hideChangedISNULL" + attributeNum) as HiddenField;//是否必填
            TextBox txtBoxFrom = divAttribute.FindControl("txtChangedAttribute" + attributeNum + "From") as TextBox;
            TextBox txtBoxTo = divAttribute.FindControl("txtChangedAttribute" + attributeNum + "To") as TextBox;
            if (hideISNULL.Value.Equals("") && txtBoxFrom.Text.Trim().Length < 1 && txtBoxTo.Text.Trim().Length<1) //如果领用属性为不必填且输入领用属性为空时
            {
                return;
            }
            if (hideISNULL.Value.Equals("1") && (string.IsNullOrEmpty(txtBoxFrom.Text.Trim()) || string.IsNullOrEmpty(txtBoxTo.Text.Trim()))) //如果领用属性为必填且输入为空时
            {
                Label lblAttribute = divAttribute.FindControl("lblChangedAttribute" + attributeNum + "Name") as Label;
                context.AddError("请输入" + lblAttribute.Text.Substring(0, lblAttribute.Text.Length - 1), txtBoxFrom);
            }
            if (!string.IsNullOrEmpty(txtBoxFrom.Text.Trim()) && !string.IsNullOrEmpty(txtBoxTo.Text.Trim()))
            {
                if (txtBoxFrom.Text.Trim().Length > 50 || txtBoxTo.Text.Trim().Length > 50)
                    context.AddError("属性长度不可超过50位", txtBoxFrom);
                if (RegexInput(txtBoxFrom, "起始号段必须是纯数字或者字母+数字组成") && RegexInput(txtBoxTo, "终止号段必须是纯数字或者字母+数字组成"))
                {
                    JudgeStockOutNum(txtBoxFrom, txtBoxTo);
                }
            }
        }        
    }
    /// <summary>
    /// 判断号段数量与出库数量是否一致
    /// </summary>
    /// <param name="tbFrom"></param>
    /// <param name="tbTo"></param>
    private void JudgeStockOutNum(TextBox tbFrom,TextBox tbTo)
    {
        Match match1 = Regex.Match(tbFrom.Text, @"^[0-9]+$", RegexOptions.IgnoreCase);//数字
        Match match2 = Regex.Match(tbTo.Text, @"^[0-9]+$", RegexOptions.IgnoreCase);
        string fromCardString = "", toCardString = "";
        long fromCardNum = -1, toCardNum = -1;
        long quantity = 0;
        if (match1.Success && match2.Success)  //输入号段方式是数字
        {
            fromCardNum = long.Parse(tbFrom.Text.Trim());
            toCardNum = long.Parse(tbTo.Text.Trim());
            quantity = toCardNum - fromCardNum + 1;
            if (quantity != long.Parse(txtStockOutNum.Text.Trim()))
                context.AddError("号段数量与出库数量不一致", tbFrom);
            
        }
        else  //输入号段方式是字母加数字
        {
            fromCardString = RegexString(tbFrom.Text.Trim());
            toCardString = RegexString(tbTo.Text.Trim());
            string fromNum = RegexStringNum(tbFrom.Text.Trim());
            string toNum = RegexStringNum(tbTo.Text.Trim());
            if (fromCardString.EndsWith(toCardString))//输入号段前缀字母相同
            {
                fromCardNum = long.Parse(RegexStringNum(tbFrom.Text.Trim()));//获取号段中数字
                toCardNum = long.Parse(RegexStringNum(tbTo.Text.Trim()));
                quantity = toCardNum - fromCardNum + 1;
                if (quantity != long.Parse(txtStockOutNum.Text.Trim()))
                    context.AddError("号段数量与出库数量不一致", tbFrom);
            }
            else
            {
                context.AddError("如果输入号段方式是字母加数字，则号段输入前缀字母必须相同", tbTo);
            }
            if (!fromNum.Length.Equals(toNum.Length))
            {
                context.AddError("如果输入号段方式是字母加数字，则号段输入后缀数字位数必须相同", tbTo);
            }
        }
    }
    /// <summary>
    /// 领用属性号段方式输入时，可以输入纯数字或者字母+数字
    /// </summary>
    /// <param name="tb"></param>
    /// <param name="errCode"></param>
    /// <returns></returns>
    private bool RegexInput(TextBox tb, String errCode)
    {
        tb.Text = tb.Text.Trim();
        Match match1 = Regex.Match(tb.Text, @"^[0-9]+$", RegexOptions.IgnoreCase);//数字
        Match match2 = Regex.Match(tb.Text, @"^[A-Za-z0-9]+", RegexOptions.IgnoreCase);//字母加数字
        Match match3 = Regex.Match(tb.Text, @"^[A-Za-z]+$", RegexOptions.IgnoreCase);//字母
        if (match1.Success || match2.Success && match3.Success == false) //输入纯数字或字母加数字时
        {
            if (match2.Success && !match1.Success) //输入字母加数字时
            {
                string regex = @"^(\D*)(\d+)$";
                Match match = Regex.Match(tb.Text, regex, RegexOptions.IgnoreCase);
                string str1 = match.Groups[1].Value;//获取前缀字母
                Match match4 = Regex.Match(str1, @"^[A-Za-z]+$", RegexOptions.IgnoreCase);//字母
                if (!match4.Success)
                {
                    context.AddError("如果号段输入方式为字母+数字，则输入前缀必须为字母", tb);
                    return false;
                }
                else
                {
                    return true;
                }
            }
            else
            {
                return true;
            }
        }
        else
        {
            context.AddError(errCode, tb);
            return false;
        }
    }
    /// <summary>
    /// 比如输入NB001 – NB005，通过正则表达式获取到数字
    /// </summary>
    /// <param name="inputString"></param>
    /// <returns></returns>
    private string RegexStringNum(string inputString)
    {
        string regex = @"^(\D*)(\d+)$";
        string str1 = inputString;
        Match match = Regex.Match(str1, regex, RegexOptions.IgnoreCase);
        if (match.Success)
        {
            str1 = match.Groups[2].Value;//获取数字(eg:001)
        }
        return str1;
    }
    /// <summary>
    /// 比如输入NB001 – NB005，通过正则表达式获取到字母
    /// </summary>
    /// <param name="inputString"></param>
    /// <returns></returns>
    private string RegexString(string inputString)
    {
        string regex = @"^(\D*)(\d+)$";
        string str1 = inputString;
        Match match = Regex.Match(str1, regex, RegexOptions.IgnoreCase);
        if (match.Success)
        {
            str1 = match.Groups[1].Value;//获取字母(eg:NB)
        }
        return str1;
    }

    /// <summary>
    /// 清空字符输入方式的某个属性
    /// </summary>
    /// <param name="index">第几个</param>
    private void ClearOriginalIndexAttribute(string index)
    {
        switch(index)
        {
            case "1":
                txtAttribute1.Text = string.Empty;
                break;
            case "2":
                txtAttribute2.Text = string.Empty;
                break;
            case "3":
                txtAttribute3.Text = string.Empty;
                break;
            case "4":
                txtAttribute4.Text = string.Empty;
                break;
            case "5":
                txtAttribute5.Text = string.Empty;
                break;
            case "6":
                txtAttribute6.Text = string.Empty;
                break;
        }        
    }
    /// <summary>
    /// 清空号段输入方式的某个属性
    /// </summary>
    /// <param name="index">第几个</param>
    private void ClearChangedIndexAttribute(string index)
    {
        switch (index)
        {
            case "1":
                 txtChangedAttribute1From.Text = string.Empty;
                 txtChangedAttribute1To.Text = string.Empty;
                break;
            case "2":
                 txtChangedAttribute2From.Text = string.Empty;
                 txtChangedAttribute2To.Text = string.Empty;
                break;
            case "3":
                txtChangedAttribute3From.Text = string.Empty;
                txtChangedAttribute3To.Text = string.Empty;
                break;
            case "4":
                txtChangedAttribute4From.Text = string.Empty;
                txtChangedAttribute4To.Text = string.Empty;
                break;
            case "5":
                txtChangedAttribute5From.Text = string.Empty;
                txtChangedAttribute5To.Text = string.Empty;
                break;
            case "6":
                txtChangedAttribute6From.Text = string.Empty;
                txtChangedAttribute6To.Text = string.Empty;
                break;
        }
    }

    /// <summary>
    /// 清空号段输入方式的所有属性
    /// </summary>
    private void ClearChangedAttribute()
    {
        txtChangedAttribute1From.Text = string.Empty;
        txtChangedAttribute1To.Text = string.Empty;
        txtChangedAttribute2From.Text = string.Empty;
        txtChangedAttribute2To.Text = string.Empty;
        txtChangedAttribute3From.Text = string.Empty;
        txtChangedAttribute3To.Text = string.Empty;
        txtChangedAttribute4From.Text = string.Empty;
        txtChangedAttribute4To.Text = string.Empty;
        txtChangedAttribute5From.Text = string.Empty;
        txtChangedAttribute5To.Text = string.Empty;
        txtChangedAttribute6From.Text = string.Empty;
        txtChangedAttribute6To.Text = string.Empty;
    }
    /// <summary>
    /// 清空字符输入方式的所有属性
    /// </summary>
    private void ClearOriginalAttribute()
    {
        txtAttribute1.Text = string.Empty;
        txtAttribute2.Text = string.Empty;
        txtAttribute3.Text = string.Empty;
        txtAttribute4.Text = string.Empty;
        txtAttribute5.Text = string.Empty;
        txtAttribute6.Text = string.Empty;
    }
    /// <summary>
    /// 清空临时表
    /// </summary>
    private void clearTempTable()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON where f7='"
            + Session.SessionID + "'");
        context.DBCommit();
    }
    

}