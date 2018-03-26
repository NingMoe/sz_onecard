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
using Common;
using TM;
using PDO.GroupCard;
using TDO.UserManager;
using TDO.BusinessCode;

public partial class ASP_GroupCard_GC_OrderSearch : Master.ExportMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        //初始化审核状态
        OrderHelper.selOrderState(context, selApprovalStatus, true);
        //初始化部门
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
        TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
        ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
        selDept.SelectedValue = context.s_DepartID;
        ControlDeal.SelectBoxFill(selManagerDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);//初始化客户经理部门
        selManagerDept.SelectedValue = context.s_DepartID;
        InitStaffList(selStaff,context.s_DepartID);//初始化录入员工
        selStaff.SelectedValue = context.s_UserID;
        InitStaffList(selManager, context.s_DepartID);//初始化客户经理
        selManager.SelectedValue = context.s_UserID;
        gvOrderList.DataKeyNames = new string[] { "ORDERNO", "GROUPNAME", "NAME", "PHONE", "IDCARDNO", "TOTALMONEY","cashgiftmoney",
            "TRANSACTOR", "INPUTTIME","REMARK","financeremark","financeapproverno","getdepartment","getdate","ORDERSTATE","CHARGECARDMONEY","SZTCARDMONEY","CUSTOMERACCMONEY","CUSTOMERACCHASMONEY","readermoney","ISRELATED" };
        InitStaffList(ddlApprover, "0001");//初始化审核员工
        //初始化日期
        DateTime date = new DateTime();
        date = DateTime.Today;
        txtFromDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");
        if (HasOperPower("201012")) //如果是部门主管，add by shil,20120604
        {
            //可以查看本部门员工
            selStaff.Enabled = true;
        }
        if (HasOperPower("201013")) //如果是公司主管，add by shil,20120604
        {
            //可以查看所有记录
            selStaff.Enabled = true;
            selDept.Enabled = true;
        }
        ShowNonDataGridView();
        divDetail.Visible = false;
        divInfo.Visible = false;
        divMakeCardWarn.Visible = false;
        divMakeCardWarn2.Visible = false;
        divAll.Visible = false;
        divGridView.Visible = false;
        ControlDeal.SelectBoxFill(selMakeDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);//初始化制卡部门
        InitStaffList(selMakeOperator,"");//初始化制卡员工
        divCheckInfo.Visible = false;//隐藏到账信息
        divCheckInfoWarm.Visible = false;
    }
    //权限
    private bool HasOperPower(string powerCode)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
        string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + 
            "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
        DataTable dataSupply = tmTMTableModule.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
        if (dataSupply.Rows.Count > 0)
            return true;
        else
            return false;
    }
    
    //初始化员工选项
    private void InitStaffList(DropDownList ddl,string deptNo)
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
                GroupCardHelper.fill(ddl, table, true);
                return;
            }
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";
            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);
            ControlDeal.SelectBoxFill(ddl.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
            //ddl.SelectedValue = context.s_UserID;
        }
        else
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";
            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
            ControlDeal.SelectBoxFill(ddl.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
    }
    /// <summary>
    /// 初始化列表
    /// </summary>
    private void ShowNonDataGridView()
    {
        gvOrderList.DataSource = new DataTable();
        gvOrderList.DataBind();
    }
    //录入部门
    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selStaff,selDept.SelectedValue);
    }
    //制卡部门
    protected void selMakeDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selMakeOperator, selMakeDept.SelectedValue);
    }
    //客户经理
    protected void managerDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selManager,selManagerDept.SelectedValue);
    }

    public String getDataKeys2(String keysname,int selectindex)
    {
        return gvOrderList.DataKeys[selectindex][keysname].ToString();
    }

    //查询
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        divDetail.Visible = false;
        divInfo.Visible = false;
        divMakeCardWarn.Visible = false;
        divMakeCardWarn2.Visible = false;
        divAll.Visible = false;
        divGridView.Visible = false;
        divCheckInfo.Visible = false;
        divCheckInfoWarm.Visible = false;
        if (!ValidInput()) return;
        string groupName = ""; //单位名称
        groupName = txtGroupName.Text.Trim();
        string name = txtName.Text.Trim();//联系人
        string staff = "";
        if (selStaff.SelectedIndex > 0)
        {
            staff = selStaff.SelectedValue;
        }
        string dept = "";
        if(selDept.SelectedIndex>0)
        {
            dept = selDept.SelectedValue;
        }
        string mstaff = "";//客户经理
        if (selManager.SelectedIndex > 0)
        {
            mstaff = selManager.SelectedValue;
        }
        string mdept = "";//客户经理所属部门
        if(selManagerDept.SelectedIndex>0)
        {
            mdept = selManagerDept.SelectedValue;
        }
        string paytype = "";//付款方式
        if(payType.SelectedValue!="")
        {
            paytype = payType.SelectedValue;
        }
        string money = "";
        if (txtTotalMoney.Text.Trim().Length > 0)
        {
            money = (Convert.ToDecimal(txtTotalMoney.Text.Trim()) * 100).ToString();
        }
        string fromDate = txtFromDate.Text.Trim();
        string endDate = txtToDate.Text.Trim();

        DataTable dt = GroupCardHelper.callOrderQuery(context, "AllOrderInfoSelect", groupName, name, staff, money, fromDate, endDate, selApprovalStatus.SelectedValue, ddlApprover.SelectedValue, dept, selType.SelectedValue, selMakeDept.SelectedValue, selMakeOperator.SelectedValue, mstaff, mdept, paytype);
        if (dt == null || dt.Rows.Count < 1)
        {
            gvOrderList.DataSource = new DataTable();
            gvOrderList.DataBind();
            context.AddError("未查出订单记录");
            return;
        }
        gvOrderList.DataSource = dt;
        gvOrderList.DataBind();
        if (Session["ok"] != null)
        {
            bool ok = Convert.ToBoolean(Session["ok"]);
            if (ok)
            {
                AddMessage("A094393Y01:修改成功");
                Session["ok"] = null;
            }
        }
        
    }
    /// <summary>
    /// Excel导出
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvOrderList.Rows.Count > 0)
        {
            gvOrderList.Columns[0].Visible = false;
            gvOrderList.AllowPaging = false;//不分页导出Excel
            btnQuery_Click(sender,e);
            ExportGridView(gvOrderList);
            gvOrderList.Columns[0].Visible = true;
            gvOrderList.AllowPaging = true;
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }
    /// <summary>
    /// 查询验证
    /// </summary>
    /// <returns></returns>
    private bool ValidInput()
    {
        //校验单位名称长度
        if (!string.IsNullOrEmpty(txtGroupName.Text.Trim()))
        {
            if (txtGroupName.Text.Trim().Length > 50)
            {
                context.AddError("单位名称长度不能超过50个字符长度");
            }
        }
        //校验联系人长度
        if (!string.IsNullOrEmpty(txtName.Text.Trim()))
        {
            if (txtName.Text.Trim().Length > 50)
            {
                context.AddError("联系人长度不能超过25个字符长度");
            }
        }

        if (txtTotalMoney.Text.Trim().Length > 0) //金额不为空时
        {
            if (!Validation.isPrice(txtTotalMoney.Text.Trim()))
            {
                context.AddError("金额输入不正确", txtTotalMoney);
            }
            else if (Convert.ToDecimal(txtTotalMoney.Text.Trim()) <= 0)
            {
                context.AddError("金额必须是正数", txtTotalMoney);
            }
        }
        //对开始日期和结束日期的判断
        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, false);
        return !(context.hasError());
    }
    /// <summary>
    /// 查询公司名
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    //protected void queryGroupName(object sender, EventArgs e)
    //{
    //    OrderHelper.queryCompany(context, txtGroupName, selCompany);
        
    //}

    /// <summary>
    /// 单位名称全称下拉选框选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    //protected void selCompany_Changed(object sender, EventArgs e)
    //{
    //    txtGroupName.Text = selCompany.SelectedItem.ToString();
    //}

    //注册行单击事件
    protected void gvOrderList_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvOrderList','Select$" + e.Row.RowIndex + "')");
        }
    }
    //GRIDVIEW行绑定事件
    protected void gvOrderList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            
            //选择员工GRIDVIEW中的一行记录
            string orderno = gvOrderList.DataKeys[e.Row.RowIndex]["ORDERNO"].ToString();
            ViewState["orderno"] = orderno;
            Button btnPrint = (Button)e.Row.FindControl("btnPrint");
            btnPrint.Attributes.Add("onclick",
                "CreateWindow('RoleWindow','GC_OrderPrint.aspx?orderno=" + orderno.Trim() + "    " + "',null,0);return false;");
            Button btnUpdate = (Button)e.Row.FindControl("btnUpdate");
            btnUpdate.Attributes.Add("onclick",
                "CreateWindow('RoleWindow','GC_OrderInfoModify.aspx?orderno=" + orderno.Trim() + "');return false;");
            string queryPaytype = @"select pa.paytypecode from tf_f_paytype pa where pa.orderno ='" + orderno + " ' ";
            string payType = "";
            context.DBOpen("Select");
            DataTable data = context.ExecuteReader(queryPaytype);
            if (data.Rows.Count>0)
            {
                for (int i = 0; i<data.Rows.Count;i++ )
                {
                    payType += Paytype(data.Rows[i][0].ToString()) + ",";
                }
                payType = payType.Remove(payType.LastIndexOf(","), 1);
            }
           
            e.Row.Cells[10].Text = payType;
            if( e.Row.Cells[14].Text ==":")
            {
                e.Row.Cells[14].Text = "";
            }

        }     
    }
    //支付方式
    private string Paytype(string paytypecode)
    {
        string paytype = "";
        switch (paytypecode)
        {
            case "0":
                paytype= "支/本票";
                break;
            case "1":
                paytype="转账";
                break;
            case "2":
                paytype= "现金";
                break;
            case "3":
                paytype="刷卡";
                break;
            case "4":
                paytype="呈批单";
                break;
            default:
                paytype="";
                break;
        }
        return paytype;
    }
    /// <summary>
    /// 查看订单详情
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDetail_Click(object sender, EventArgs e)
    {
        Button btnDetail = sender as Button;
        int index = 0;
        if (gvOrderList.PageIndex > 0)
        {
            index = int.Parse(btnDetail.CommandArgument) - 10 * gvOrderList.PageIndex;
        }
        else
        {
            index = int.Parse(btnDetail.CommandArgument);//获取行号
        } 
        divInfo.InnerHtml = GetOrderMakeOrComfirmHtml(getDataKeys2("ORDERNO", index), getDataKeys2("GROUPNAME", index), getDataKeys2("NAME", index),
           getDataKeys2("TOTALMONEY", index), getDataKeys2("ORDERSTATE", index), getDataKeys2("INPUTTIME", index), getDataKeys2("cashgiftmoney", index),
          getDataKeys2("SZTCARDMONEY", index), getDataKeys2("CHARGECARDMONEY", index), getDataKeys2("CUSTOMERACCMONEY", index), getDataKeys2("CUSTOMERACCHASMONEY", index), getDataKeys2("readermoney", index));
        divInfo.Visible = true;
        divDetail.Visible = true;
        divGridView.Visible = false;
        divMakeCardWarn.Visible = false;
        divMakeCardWarn2.Visible = false;
        divCheckInfoWarm.Visible = false;
        divCheckInfo.Visible = false;
        string isrelated = getDataKeys2("ISRELATED", index);
        string orderstate = getDataKeys2("ORDERSTATE", index).Substring(0,2);
        if (isrelated.Equals("1"))//制卡关联时
        {
            if (orderstate == "04" || orderstate == "05" || orderstate == "06" || orderstate == "07" || orderstate == "08" )
            {
                divAll.Visible = true;//当订单状态为制卡中、制卡完成、不关联确认完成、领用完成、确认完成时显示卡号段       
            }
            else
            {
                divAll.Visible = false;
                divMakeCardWarn.Visible = true;//显示订单未制卡提示信息
                divMakeCardWarn2.Visible = false;
            }
        }
        else  //领卡关联
        {
            if (orderstate == "10" || orderstate == "08")
            {
                divAll.Visible = true;//当订单状态为确认完成、领卡补关联完成时显示卡号段       
            }
            else
            { 
                divAll.Visible = false;
                divMakeCardWarn2.Visible = true;//显示订单未完成领卡关联提示信息
            }
        }
        
        if (int.Parse(getDataKeys2("cashgiftmoney", index)) > 0 ) //利金卡总金额大于0
        {
            divCash.Visible = true;
            hidCashOrderNo.Value = getDataKeys2("ORDERNO", index);//绑定orderno
        }
        else
        {
            divCash.Visible = false;
        }
        if (int.Parse(getDataKeys2("CHARGECARDMONEY", index)) > 0)//充值卡总金额大于0
        {
            divCharge.Visible = true;
            hidCashOrderNo.Value = getDataKeys2("ORDERNO", index);
        }
        else
        {
            divCharge.Visible = false;
        }
        if (int.Parse(getDataKeys2("SZTCARDMONEY", index)) > 0 && isrelated.Equals("1"))//苏州通卡总金额大于0并且是关联的
        {
            divSZT.Visible = true;
            hidCashOrderNo.Value = getDataKeys2("ORDERNO", index);
        }
        else
        {
            divSZT.Visible = false;
        }
        if (int.Parse(getDataKeys2("readermoney", index))>0)//读卡器总金额大于0
        {
            divReader.Visible = true;
            hidCashOrderNo.Value = getDataKeys2("ORDERNO", index);
        }
        else
        {
            divReader.Visible = false;
        }
    }
    /// <summary>
    /// 到账信息
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnCheckInfo_Click(object sender, EventArgs e)
    {
        divInfo.Visible = false;
        divDetail.Visible = false;
        divGridView.Visible = false;
        divMakeCardWarn.Visible = false;
        divMakeCardWarn2.Visible = false;
        divCheckInfoWarm.Visible = false;
        divCheckInfo.Visible = false;
        Button btnCheckInfo = sender as Button;
        int index = 0;
        if (gvOrderList.PageIndex > 0)
        {
            index = int.Parse(btnCheckInfo.CommandArgument) - 10 * gvOrderList.PageIndex;
        }
        else
        {
            index = int.Parse(btnCheckInfo.CommandArgument);//获取行号
        }
        string orderno = getDataKeys2("ORDERNO", index);
        DataTable dt = GroupCardHelper.callOrderQuery(context, "QueryCheckRelationInfo", orderno);
        if (dt.Rows.Count > 0)
        {
            divCheckInfo.Visible = true;
            divCheckInfoWarm.Visible = false;
            GridView2.DataSource = dt;
            GridView2.DataBind();
        }
        else
        {
            GridView2.DataSource = null;//清空GridView
            GridView2.DataBind();
            divCheckInfo.Visible = false;
            divCheckInfoWarm.Visible = true ;
        }

    }
    //详细信息
    protected void gvOrderList_SelectedIndexChanged(object sender, EventArgs e)
    {
       
    }
    public string GetOrderMakeOrComfirmHtml(string orderno, string groupName, string name,
       string totalMoney, string orderstate, string inputtime, string cashgiftmoney, string sztcardmoney,
       string chargecardmoney, string customeraccmoney, string customeracchasmoney,string readermoney)
    {
        
        string CustomerAccHtml = "";
        if (!string.IsNullOrEmpty(customeraccmoney))
        {
            CustomerAccHtml += "<tr><td colspan = '10'><hr></td></tr>";
            CustomerAccHtml += string.Format(@"<tr height=23px>
                                            <td style='text-align:right'>专有账户充值总金额:</td>
		                                    <td> {0} </td>
		                                    <td style='text-align:right'>已充值金额:</td>
		                                    <td> {1} </td>
		                                    <td style='text-align:right'>未充值金额:</td>
		                                    <td> {2} </td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
		                                    <td style='text-align:right'></td>
		                                    <td></td>
                                        </tr>", customeraccmoney, customeracchasmoney,
                                              (Convert.ToDecimal(customeraccmoney) - Convert.ToDecimal(customeracchasmoney)).ToString());
        }
        string html = string.Format(@"<table border=0px cellpadding=0 cellspacing=0 width='100%' align='center' style='border-style:solid' class='data'>
	                                     <tr height=23px>
		                                    <td style='text-align:right' width ='12%'>单位名称:</td>
		                                    <td width ='18%'> {0} </td>
		                                    <td style='text-align:right' width ='10%'>联系人:</td>
		                                    <td width ='6%'> {1} </td>
		                                    <td style='text-align:right' width ='10%'>订单总金额:</td>
		                                    <td width ='6%'> {2}元 </td>
		                                    <td style='text-align:right' width ='10%'>订单状态:</td>
		                                    <td width ='8%'> {3} </td>
		                                    <td style='text-align:right' width ='10%'>录入时间:</td>
		                                    <td width ='10%'> {4} </td>
	                                     </tr>
                                         <tr height=23px>
		                                    <td style='text-align:right'>利金卡总金额:</td>
		                                    <td> {5} </td>
		                                    <td style='text-align:right'>苏州通卡总金额:</td>
		                                    <td> {6} </td>
		                                    <td style='text-align:right'>充值卡总金额:</td>
		                                    <td> {7} </td>
		                                    <td style='text-align:right'>专有账户总金额:</td>
		                                    <td> {8} </td>
		                                    <td style='text-align:right'>读卡器总金额:</td>
		                                    <td> {9} </td>
	                                     </tr>
                                            
                                    </table>", groupName, name, totalMoney, orderstate, inputtime, cashgiftmoney, sztcardmoney, chargecardmoney, customeraccmoney,readermoney
                                             );
        return html;
    }

   
    
    //分页
    protected void gvOrderList_Page(object sender, GridViewPageEventArgs e)
    {
        gvOrderList.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    /// <summary>
    /// 显示利金卡卡号段
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnCash_Click(object sender, EventArgs e)
    {
        divGridView.Visible = true;
        string orderno = hidCashOrderNo.Value;
        DataTable dt = GroupCardHelper.callOrderQuery(context, "CashCardSectionNo", orderno);
        if (dt.Rows.Count > 0)
        {
            GridView1.DataSource = dt;
            GridView1.DataBind();
        }
        else
        {
            GridView1.DataSource = null;//清空GridView
            GridView1.DataBind();
        }

    }
    /// <summary>
    /// 显示市民卡B卡卡号段
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSZT_Click(object sender, EventArgs e)
    {
        divGridView.Visible = true;
        string orderno = hidCashOrderNo.Value;
        DataTable dt = GroupCardHelper.callOrderQuery(context, "SZTCardSectionNo", orderno);
        if (dt.Rows.Count > 0)
        {
            GridView1.DataSource = dt;
            GridView1.DataBind();
        }
        else
        {
            GridView1.DataSource = null;
            GridView1.DataBind();
        }
    }
    /// <summary>
    /// 显示充值卡卡号段
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnCharge_Click(object sender, EventArgs e)
    {
        divGridView.Visible = true;
        string orderno = hidCashOrderNo.Value;
        DataTable dt = GroupCardHelper.callOrderQuery(context, "ChargeCardSectionNo", orderno);
        if (dt.Rows.Count > 0)
        {
            GridView1.DataSource = dt;
            GridView1.DataBind();
        }
        else
        {
            GridView1.DataSource = null;
            GridView1.DataBind();
        }
    }
    /// <summary>
    /// 显示读卡器卡号段
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReader_Click(object sender, EventArgs e)
    {
        divGridView.Visible = true;
        string orderno = hidCashOrderNo.Value;
        DataTable dt = GroupCardHelper.callOrderQuery(context, "ReaderCardSectionNo", orderno);
        if (dt.Rows.Count > 0)
        {
            GridView1.DataSource = dt;
            GridView1.DataBind();
        }
        else
        {
            GridView1.DataSource = null;
            GridView1.DataBind();
        }
    }
}
