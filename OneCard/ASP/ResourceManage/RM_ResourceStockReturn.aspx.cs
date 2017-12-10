using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using Master;
using Common;
using TDO.UserManager;
using TM;
using System.Text.RegularExpressions;
/***************************************************************
 * 功能名: 其他资源管理  资源退库
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/12/14   董翔			初次开发
 ****************************************************************/
public partial class ASP_ResourceManage_RM_ResourceStockReturn : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            showNonDataGridView();
            init_Page();
            trAttribute.Visible = false;
            btnSubmit.Enabled = false;

            if (HasOperPower("201008"))//全部网点主管
            {
                InitStaffList(context.s_DepartID);
                selStaff.SelectedValue = context.s_UserID;
            }
            else if (HasOperPower("201007"))//网点主管
            {
                InitStaffList(context.s_DepartID);
                selStaff.SelectedValue = context.s_UserID;
            }
            
            else//网点营业员
            {
                selStaff.Items.Add(new ListItem(context.s_UserID + ":" + context.s_UserName, context.s_UserID));
                selStaff.SelectedValue = context.s_UserID;
                selStaff.Enabled = false;
            }
        }
        else
        {
            for (int i = 1; i <= 6; i++)
            {
                HtmlControl divAttribute = (HtmlControl)this.FindControl("divAttribute" + i.ToString());
                HiddenField hideAttributeType = (HiddenField)this.FindControl("hideAttribute" + i.ToString() + "Type");
                if (divAttribute.Visible && hideAttributeType.Value == "1")
                {
                    HiddenField hideInputType = (HiddenField)this.FindControl("hideInputType" + i.ToString());
                    if (hideInputType.Value == "0")
                    {
                        HtmlControl spanAttributeNo = (HtmlControl)this.FindControl("spanAttribute" + i.ToString() + "No");
                        spanAttributeNo.Attributes["style"] = "display:none";
                        HtmlControl spanAttributeStr = (HtmlControl)this.FindControl("spanAttribute" + i.ToString() + "Str");
                        spanAttributeStr.Attributes["style"] = "";
                    }
                    else if (hideInputType.Value == "1")
                    {
                        HtmlControl spanAttributeNo = (HtmlControl)this.FindControl("spanAttribute" + i.ToString() + "No");
                        spanAttributeNo.Attributes["style"] = "";
                        HtmlControl spanAttributeStr = (HtmlControl)this.FindControl("spanAttribute" + i.ToString() + "Str");
                        spanAttributeStr.Attributes["style"] = "display:none";
                    }
                }
            }
        }
    }

    //初始化员工列表
    private void InitStaffList(string deptNo)
    {
        if (deptNo == "")
        {
            string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
            if (dBalunitNo != "")//add by liuhe20120214添加对代理的权限处理
            {
                context.DBOpen("Select");

                string sql = @"SELECT STAFFNAME,STAFFNO FROM TD_M_INSIDESTAFF 
                             WHERE DIMISSIONTAG ='1' AND  DEPARTNO IN 
                            (SELECT DEPARTNO FROM TD_DEPTBAL_RELATION WHERE DBALUNITNO='" + dBalunitNo + "' AND USETAG='1')";
                DataTable table = context.ExecuteReader(sql);
                GroupCardHelper.fill(selStaff, table, true);

                return;
            }

            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);
            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
            selStaff.SelectedValue = context.s_UserID;
        }
        else
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
    }

    //判断是否有指定权限
    private bool HasOperPower(string powerCode)
    {
        //TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
        string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
        DataTable dataSupply = tm.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
        if (dataSupply.Rows.Count > 0)
            return true;
        else
            return false;
    }

    /// <summary>
    /// 页面初始化
    /// </summary>
    protected void init_Page()
    {
        //初始化资源类型
        OtherResourceManagerHelper.selectResourceType(context, ddlResourceType, true);

        //初始化资源名称
        OtherResourceManagerHelper.selectResource(context, ddlResource, true, ddlResourceType.SelectedValue);
    }

    /// <summary>
    /// 初始化列表
    /// </summary>
    private void showNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }

    //查询资源名称
    protected void ddlResourceType_SelectIndexChange(object sender, EventArgs e)
    {
        ddlResource.Items.Clear();
        OtherResourceManagerHelper.selectResource(context, ddlResource, true, ddlResourceType.SelectedValue);
    }

     
    /// <summary>
    /// 查询按钮点击事件
    /// </summary>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        gvResult.DataSource = queryResourceOrder();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }

    /// <summary>
    /// 查询资源领用单
    /// </summary>
    /// <returns></returns>
    protected ICollection queryResourceOrder()
    {
        //查询资源领用单
        string[] parm = new string[9];
        parm[0] = "";
        parm[1] = "";
        parm[2] = "";
        parm[3] = "";
        parm[4] = selStaff.SelectedValue;
        parm[5] = ddlResourceType.SelectedValue;
        parm[6] = ddlResource.SelectedValue;
        parm[7] = "0";
        parm[8] = "2";
        DataTable data = SPHelper.callQuery("SP_RM_OTHER_Query", context, "Query_GetResourceApply", parm);
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
        //领用单号
        GridViewRow dr = ((GridView)(sender)).SelectedRow;
        string orderid = dr.Cells[0].Text.ToString().Trim();
        QueryOrderInfo(orderid);
        //btnDownload.Enabled = true;
    }

    //查询领用单明细
    public void QueryOrderInfo(string orderid)
    {
        string[] parm = new string[1];
        parm[0] = orderid;
        DataTable data = SPHelper.callQuery("SP_RM_OTHER_Query", context, "Query_ResourceStockReturn", parm);
        if (data.Rows.Count == 0)
        {
            context.AddError("查询领用单明细失败");
            return;
        }
        else
        {
            btnSubmit.Enabled = true;
            DataRow dr = data.Rows[0];
            txtResourceGetOrderID.Text = dr["GETORDERID"].ToString();
            txtSTATE.Text = dr["STATE"].ToString();
            txtResourceType.Text = dr["RESUOURCETYPE"].ToString();
            txtResourceName.Text = dr["RESOURCENAME"].ToString();
            txtAPPLYGETNUM.Text = dr["APPLYGETNUM"].ToString();
            txtAGREEGETNUM.Text = dr["AGREEGETNUM"].ToString();
            txtALREADYGETNUM.Text = dr["ALREADYGETNUM"].ToString();
            txtReMark.Text = "";
            InitAttribute();
            trAttribute.Visible = true;
            for (int i = 1; i <= 6; i++)
            {
                ShowAttribute(i.ToString(), dr["ATTRIBUTE" + i.ToString()].ToString()
                    , dr["ATTRIBUTETYPE" + i.ToString()].ToString(), dr["ATTRIBUTEISNULL" + i.ToString()].ToString()
                    , dr["ATTRIBUTE" + i.ToString() + "VALUE"].ToString());
            }
        }
    }

    //显示资源属性
    protected void ShowAttribute(string attributeNum, string attribute, string attributeType, string attributeISNULL, string attributeValue)
    {
        //属性是否为空
        if (!string.IsNullOrEmpty(attribute))
        {
            Label lbName = (Label)this.FindControl("lblAttribute" + attributeNum + "Name");
            lbName.Text = attribute + ":";
            HiddenField hidAttributeType = (HiddenField)this.FindControl("hideAttribute" + attributeNum + "Type");
            hidAttributeType.Value = attributeType;
            HiddenField hidAttributeISNULL = (HiddenField)this.FindControl("hideAttribute" + attributeNum + "ISNULL");
            hidAttributeISNULL.Value = attributeISNULL;
            HtmlControl spanAttributeNull = (HtmlControl)this.FindControl("spanAttribute" + attributeNum + "Null");
            if (attributeISNULL == "1" && attributeType == "1")
            {
                spanAttributeNull.Attributes["style"] = "color: red; font-weight: bold;";
            }
            else
            {
                spanAttributeNull.Attributes["style"] = "display: none;color: red; font-weight: bold;";
            }
            //属性是否为领用属性
            if (attributeType != "1")
            {
                TextBox txtAttributeValueStr = (TextBox)this.FindControl("txtAttribute" + attributeNum + "ValueStr");
                txtAttributeValueStr.Attributes["class"] = "inputlabel";
                txtAttributeValueStr.ReadOnly = true;
                txtAttributeValueStr.Text = attributeValue;
                HtmlControl linkAttributeType = (HtmlControl)this.FindControl("linkAttribute" + attributeNum + "Type");
                linkAttributeType.Visible = false;
            }
            else
            {
                TextBox txtAttributeValueStr = (TextBox)this.FindControl("txtAttribute" + attributeNum + "ValueStr");
                txtAttributeValueStr.Attributes["class"] = "inputtext";
                txtAttributeValueStr.ReadOnly = false;
                HtmlControl linkAttributeType = (HtmlControl)this.FindControl("linkAttribute" + attributeNum + "Type");
                linkAttributeType.Visible = true;
            }
        }
        else
        {
            HtmlControl divAttribute = (HtmlControl)this.FindControl("divAttribute" + attributeNum);
            divAttribute.Visible = false;
        }
    }

    //初始化资源属性
    protected void InitAttribute()
    {
        for (int i = 1; i <= 6; i++)
        {
            HtmlControl divAttribute = (HtmlControl)this.FindControl("divAttribute" + i.ToString());
            divAttribute.Visible = true;
            TextBox txtAttributeValueStr = (TextBox)this.FindControl("txtAttribute" + i.ToString() + "ValueStr");
            txtAttributeValueStr.Attributes["class"] = "";
            txtAttributeValueStr.ReadOnly = false;
            txtAttributeValueStr.Text = "";
            HtmlControl spanAttributeNo = (HtmlControl)this.FindControl("spanAttribute" + i.ToString() + "No");
            spanAttributeNo.Attributes["display"] = "none";
            HtmlControl spanAttributeStr = (HtmlControl)this.FindControl("spanAttribute" + i.ToString() + "Str");
            spanAttributeStr.Attributes["display"] = "display";
            HtmlControl linkAttributeType = (HtmlControl)this.FindControl("linkAttribute" + i.ToString() + "Type");
            linkAttributeType.Visible = true;
            HiddenField hideAttributeType = (HiddenField)this.FindControl("hideAttribute" + i.ToString() + "Type");
            hideAttributeType.Value = "0";
            HiddenField hideAttributeISNULL = (HiddenField)this.FindControl("hideAttribute" + i.ToString() + "ISNULL");
            hideAttributeISNULL.Value = "0";
        }
    }

    /// <summary>
    /// 签收输入校验
    /// </summary>
    /// <returns>没有错误返回true,存在错误则返回false</returns>
    protected Boolean submitValidation()
    {
        //签收数量
        if (string.IsNullOrEmpty(txtReturnNum.Text.Trim()) || txtReturnNum.Text.Trim().Equals("0"))
            context.AddError("退库数量不能为空或零", txtReturnNum);
        else if (!Validation.isNum(txtReturnNum.Text.Trim()))
            context.AddError("退库数量必须为数字", txtReturnNum);
        else if (Int32.Parse(txtReturnNum.Text.Trim()) > Int32.Parse(txtALREADYGETNUM.Text.Trim()))
            context.AddError("退库数量不正确，超过了已领用数量", txtReturnNum);
        for (int i = 1; i <= 6; i++)
        {
            ValidationAttribute(i.ToString());
        }
        return !context.hasError();
    }

    private void ValidationAttribute(string attributeNum)
    {
        Validation valid = new Validation(context);
        //领用属性
        HiddenField hideAttributeType = (HiddenField)this.FindControl("hideAttribute" + attributeNum + "Type");
        Label lblAttributeName = (Label)this.FindControl("lblAttribute" + attributeNum + "Name");
        string attributeName = lblAttributeName.Text.Replace(":", ""); 
        if (hideAttributeType.Value == "1")
        {
            //字符串输入方式
            HiddenField hideInputType = (HiddenField)this.FindControl("hideInputType" + attributeNum);
            HiddenField hideAttributeISNULL = (HiddenField)this.FindControl("hideAttribute" + attributeNum + "ISNULL");
            if (hideInputType.Value == "0")
            {
                TextBox txtAttributeValueStr = (TextBox)this.FindControl("txtAttribute" + attributeNum + "ValueStr");
                if (hideAttributeISNULL.Value == "1" && string.IsNullOrEmpty(txtAttributeValueStr.Text.Trim()))
                    context.AddError("请输入" + attributeName, txtAttributeValueStr);
                if (!string.IsNullOrEmpty(txtAttributeValueStr.Text.Trim()))
                {
                    string attribute = txtAttributeValueStr.Text.Trim();
                    foreach (string s in attribute.Split(','))
                    {
                        if (s.Length > 50)
                        {
                            context.AddError("分割后长度不可超过50位", txtAttributeValueStr);
                            break;
                        }
                    }
                    if (attribute.Split(',').Length != Int32.Parse(txtReturnNum.Text.Trim()))
                        context.AddError("分割后数量与退库数量不一致", txtAttributeValueStr);
                }
            }
            else if (hideInputType.Value == "1")
            {
                TextBox txtAttributeValueNoFrom = (TextBox)this.FindControl("txtAttribute" + attributeNum + "ValueNoFrom");
                TextBox txtAttributeValueNoTo = (TextBox)this.FindControl("txtAttribute" + attributeNum + "ValueNoTo");
                if (hideAttributeISNULL.Value == "1" &&
                    (string.IsNullOrEmpty(txtAttributeValueNoFrom.Text.Trim()) || string.IsNullOrEmpty(txtAttributeValueNoTo.Text.Trim())))
                    context.AddError("请输入" + attributeName, txtAttributeValueNoFrom);
                if (!string.IsNullOrEmpty(txtAttributeValueNoFrom.Text.Trim()) && !string.IsNullOrEmpty(txtAttributeValueNoTo.Text.Trim()))
                {
                    if (txtAttributeValueNoFrom.Text.Trim().Length > 50 || txtAttributeValueNoTo.Text.Trim().Length > 50)
                        context.AddError("属性长度不可超过50位", txtAttributeValueNoFrom);
                    
                    if (RegexInput(txtAttributeValueNoFrom, "起始号段必须是纯数字或者字母+数字组成") && RegexInput(txtAttributeValueNoTo, "终止号段必须是纯数字或者字母+数字组成"))
                    {
                        JudgeStockOutNum(txtAttributeValueNoFrom, txtAttributeValueNoTo);
                    }
                }
            }
        }
    }
    /// <summary>
    /// 判断号段数量与出库数量是否一致
    /// </summary>
    /// <param name="tbFrom"></param>
    /// <param name="tbTo"></param>
    private void JudgeStockOutNum(TextBox tbFrom, TextBox tbTo)
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
            if (quantity != long.Parse(txtReturnNum.Text.Trim()))
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
                if (quantity != long.Parse(txtReturnNum.Text.Trim()))
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
            if (match2.Success&&!match1.Success) //输入字母加数字时
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

    //获取领用属性值（单个资源）
    private string GetAttribute(string attributeNum, int index)
    {
        //领用属性
        HiddenField hideAttributeType = (HiddenField)this.FindControl("hideAttribute" + attributeNum + "Type");
        if (hideAttributeType.Value == "1")
        {
            //字符串输入方式
            HiddenField hideInputType = (HiddenField)this.FindControl("hideInputType" + attributeNum);
            HiddenField hideAttributeISNULL = (HiddenField)this.FindControl("hideAttribute" + attributeNum + "ISNULL");
            if (hideInputType.Value == "0")
            {
                TextBox txtAttributeValueStr = (TextBox)this.FindControl("txtAttribute" + attributeNum + "ValueStr");
                if (string.IsNullOrEmpty(txtAttributeValueStr.Text.Trim()))
                    return "";
                else
                {
                    return txtAttributeValueStr.Text.Trim().Split(',')[index - 1];
                }
            }
            else if (hideInputType.Value == "1")
            {
                TextBox txtAttributeValueNoFrom = (TextBox)this.FindControl("txtAttribute" + attributeNum + "ValueNoFrom");
                TextBox txtAttributeValueNoTo = (TextBox)this.FindControl("txtAttribute" + attributeNum + "ValueNoTo");
                if ((string.IsNullOrEmpty(txtAttributeValueNoFrom.Text.Trim()) || string.IsNullOrEmpty(txtAttributeValueNoTo.Text.Trim())))
                    return "";
                else
                {
                    Match match1 = Regex.Match(txtAttributeValueNoFrom.Text, @"^[0-9]+$", RegexOptions.IgnoreCase);//数字
                    Match match2 = Regex.Match(txtAttributeValueNoTo.Text, @"^[0-9]+$", RegexOptions.IgnoreCase);
                    long fromCardNum = -1, toCardNum = -1;
                    if (match1.Success && match2.Success) //输入号段方式是数字
                    {
                        fromCardNum = long.Parse(txtAttributeValueNoFrom.Text.Trim());
                        toCardNum = long.Parse(txtAttributeValueNoTo.Text.Trim());
                        if (index < 1)
                        {
                            return (fromCardNum.ToString() + "-" + toCardNum.ToString());
                        }
                        else
                        {
                            return (toCardNum + (long)(index - 1)).ToString();
                        }
                    }
                    else  //输入号段方式是字母加数字
                    {
                        string str1 = RegexString(txtAttributeValueNoFrom.Text.Trim());//获取第一个输入框中号段的前缀字母
                        long str2 = long.Parse(RegexStringNum(txtAttributeValueNoFrom.Text.Trim()));
                        int length1 = RegexStringNum(txtAttributeValueNoFrom.Text.Trim()).Length;//获取第一个输入框中号段的后缀数字
                        int length2 = str2.ToString().Length;
                        string addZero = "";
                        if (length2 < length1)
                        {
                            for (int i = 0; i < length1 - length2; i++)
                            {
                                addZero += "0";
                            }

                        }
                        if (index < 1)
                        {
                            return (str1 + addZero + str2 + "-").Trim();
                        }
                        else
                        {
                            return (str1 + addZero + (str2 + (long)(index - 1))).ToString().Trim();
                        }
                    }
                }
            }
        }
        return "";
    }

    //获取领用属性值（批量）
    private string GetAttribute(string attributeNum)
    {
        //领用属性
        HiddenField hideAttributeType = (HiddenField)this.FindControl("hideAttribute" + attributeNum + "Type");
        if (hideAttributeType.Value == "1")
        {
            //字符串输入方式
            HiddenField hideInputType = (HiddenField)this.FindControl("hideInputType" + attributeNum);
            HiddenField hideAttributeISNULL = (HiddenField)this.FindControl("hideAttribute" + attributeNum + "ISNULL");
            if (hideInputType.Value == "0")
            {
                TextBox txtAttributeValueStr = (TextBox)this.FindControl("txtAttribute" + attributeNum + "ValueStr");
                if (string.IsNullOrEmpty(txtAttributeValueStr.Text.Trim()))
                    return "";
                else
                {
                    return txtAttributeValueStr.Text.Trim();
                }
            }
            else if (hideInputType.Value == "1")
            {
                TextBox txtAttributeValueNoFrom = (TextBox)this.FindControl("txtAttribute" + attributeNum + "ValueNoFrom");
                TextBox txtAttributeValueNoTo = (TextBox)this.FindControl("txtAttribute" + attributeNum + "ValueNoTo");
                if ((string.IsNullOrEmpty(txtAttributeValueNoFrom.Text.Trim()) || string.IsNullOrEmpty(txtAttributeValueNoTo.Text.Trim())))
                    return "";
                else
                {
                    return txtAttributeValueNoFrom.Text.Trim() + "-" + txtAttributeValueNoTo.Text.Trim();
                }
            }
        }
        return "";
    }

    /// <summary>
    /// 申请按钮点击事件
    /// </summary>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        //提交校验
        if (!submitValidation())
            return;

        //清空临时表
        clearTempTable();

        //记录入临时表
        context.DBOpen("Insert");
        //将每个资源属性记录到临时表
        for (int n = 1; n <= Int32.Parse(txtReturnNum.Text.Trim()); n++)
        {
            context.ExecuteNonQuery("insert into TMP_COMMON (f0,f1,f2,f3,f4,f5,f6,f7) values('" +
                n.ToString() + "', '" + GetAttribute("1", n) + "', '" + GetAttribute("2", n) + "', '" + GetAttribute("3", n) +
                "', '" + GetAttribute("4", n) + "', '" + GetAttribute("5", n) + "', '" + GetAttribute("6", n) + "','" + Session.SessionID + "')");
        }
        context.DBCommit();


        //属性插入临时表中
        context.SPOpen();
        context.AddField("P_GETORDERID").Value = txtResourceGetOrderID.Text.Trim();
        context.AddField("P_SESSION").Value = Session.SessionID;
        context.AddField("P_SUM").Value = Int32.Parse(txtReturnNum.Text);
        context.AddField("P_ATTRIBUTE1").Value = GetAttribute("1");
        context.AddField("P_ATTRIBUTE2").Value = GetAttribute("2");
        context.AddField("P_ATTRIBUTE3").Value = GetAttribute("3");
        context.AddField("P_ATTRIBUTE4").Value = GetAttribute("4");
        context.AddField("P_ATTRIBUTE5").Value = GetAttribute("5");
        context.AddField("P_ATTRIBUTE6").Value = GetAttribute("6");
        context.AddField("P_REASON").Value = txtReMark.Text;
        //调用下单申请存储过程
        bool ok = context.ExecuteSP("SP_RM_ResourceStockReutrn");
        if (ok)
        {
            AddMessage("退库成功");
            btnSubmit.Enabled = false;
        }
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