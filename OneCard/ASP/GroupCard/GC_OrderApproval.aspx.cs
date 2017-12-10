using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
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

// 企服卡开卡审批


public partial class ASP_TianyiReport_SZ_OrderApproval : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack)
        {
            if (hidShowCheckQuery.Value == "1")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showCheckQuery", "showCheckQuery();", true);
            }
            return;
        }
        //初始化部门

        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
        TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
        ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
        //selDept.SelectedValue = context.s_DepartID;
        ControlDeal.SelectBoxFill(selManagerDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);//初始化客户经理所在部门

        //初始化经办人
        InitStaffList(selStaff,context.s_DepartID);
        InitStaffList(selManager,context.s_DepartID);//初始化客户经理

        //selStaff.SelectedValue = context.s_UserID;
        //初始化账单录入员工

        InitStaffList(selCheckInStaff,"0001");

        gvOrderList.DataKeyNames = new string[] { "ORDERNO", "GROUPNAME", "NAME", "PHONE", "IDCARDNO", "TOTALMONEY", "TRANSACTOR", "INPUTTIME", "REMARK", "cashgiftmoney", "customeraccmoney" };

        //初始化订单表格

        gvOrderList.DataSource = new DataTable();
        gvOrderList.DataBind();
        //初始化账单表格

        gvResult.DataSource = query();
        gvResult.DataBind();
    }
    private void InitStaffList(DropDownList selStaffno, string deptNo)
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
                GroupCardHelper.fill(selStaffno, table, true);

                return;
            }

            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);
            ControlDeal.SelectBoxFill(selStaffno.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
            selStaffno.SelectedValue = context.s_UserID;
        }
        else
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
            ControlDeal.SelectBoxFill(selStaffno.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
    }
    /// <summary>
    /// 单位名称选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void txtGroupName_Changed(object sender, EventArgs e)
    {
        OrderHelper.queryCompany(context, txtGroupName, selCompany);
    }
    /// <summary>
    /// 单位名称全称下拉选框选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void selCompany_Changed(object sender, EventArgs e)
    {
        txtGroupName.Text = selCompany.SelectedItem.ToString();
    }
    /// <summary>
    /// 户名选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    //protected void txtAccountName_Changed(object sender, EventArgs e)
    //{
    //    //模糊查询户名，并在列表中赋值

    //    string name = txtAccountName.Text.Trim();
    //    if (name == "")
    //    {
    //        selAccountName.Items.Clear();
    //        context.DBOpen("Select");
    //        string sql = @"SELECT  DISTINCT ACCOUNTNAME FROM TF_F_CHECK  WHERE USETAG ='1' AND ACCOUNTNAME IS NOT NULL";
    //        DataTable table = context.ExecuteReader(sql);
    //        if (table.Columns.Count > 0)
    //        {

    //            selAccountName.DataSource = table;
    //            selAccountName.DataTextField = table.Columns[0].ColumnName;
    //            selAccountName.DataValueField = table.Columns[0].ColumnName;
    //            selAccountName.DataBind();
    //            selAccountName.Items.Insert(0, new ListItem("---请选择---", ""));
    //            selAccountName.SelectedIndex = -1;
    //        }
    //        else
    //        {
    //            selAccountName.Items.Add(new ListItem("---请选择---", ""));
    //        }
    //        return;
    //    }
    //    else
    //    {
    //        string accountname = "%" + name + "%";
    //        selAccountName.Items.Clear();
    //        context.DBOpen("Select");
    //        string sql = @"SELECT DISTINCT ACCOUNTNAME FROM TF_F_CHECK  WHERE USETAG ='1' AND ACCOUNTNAME LIKE '" + accountname + "' ";
    //        DataTable table = context.ExecuteReader(sql);
    //        if (table.Columns.Count > 0)
    //        {
    //            selAccountName.DataSource = table;
    //            selAccountName.DataTextField = table.Columns[0].ColumnName;
    //            selAccountName.DataValueField = table.Columns[0].ColumnName;
    //            selAccountName.DataBind();
    //            selAccountName.Items.Insert(0, new ListItem("---请选择---", ""));
    //            selAccountName.SelectedIndex = -1;
    //        }
    //        else
    //        {
    //            selAccountName.Items.Add(new ListItem("---请选择---", ""));
    //        }
    //        return;
    //    }
    //}
    /// <summary>
    /// 户名全称下拉选框选择时间
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    //protected void selAccountName_Changed(object sender, EventArgs e)
    //{
    //    txtAccountName.Text = selAccountName.SelectedValue;
    //}
    /// <summary>
    /// 部门选择时间，查询部门所属员工

    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selStaff, selDept.SelectedValue);
    }

    protected void managerDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selManager, selManagerDept.SelectedValue);
    }

    // gridview 换页事件
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        //gvResult.PageIndex = e.NewPageIndex;

    }
    /// <summary>
    /// 提交处理
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        context.SPOpen();

        context.AddField("P_SESSIONID").Value = Session.SessionID;
        context.AddField("P_FINANCEREMARK").Value = hidFinanceRemark.Value;
        context.AddField("p_ISAPPROVE").Value = hidApprove.Value;
        bool ok = context.ExecuteSP("SP_GC_ORDERAPPROVAL");
        if (ok)
        {
            AddMessage("审批通过成功");

            //刷新列表
            btnQuery_Click(sender, e);
            btnQueryCheck_Click(sender, e);

            divInfo.InnerHtml = "";
        }

        ScriptManager.RegisterStartupScript(this, this.GetType(), "aa", "SetText();", true);
    }

    // 提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        //清空临时表信息

        clearTempTable();

        //选择审核的订单和账单入临时表
        if (!RecordIntoTmp()) return;

        if (!string.IsNullOrEmpty(hidRemind.Value) && hidApprove.Value != "1")
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "Script", "submitConfirm('" + hidRemind.Value + "');", true);
        }
        else
        {
            btnConfirm_Click(sender, e);
        }
        
    }
    private void clearTempTable()//清空临时表

    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_ORDER");
        context.DBCommit();
    }

    private bool RecordIntoTmp()
    {
        //选中记录入临时表
        context.DBOpen("Insert");
        int ordercount = 0;
        int checkcount = 0;
        int ordersummoney = 0;
        int checksummoney = 0;
        hidApprove.Value = "1";//订单付款方式为呈批单

        List<string> company = new List<string>();
        foreach (GridViewRow gvr in gvOrderList.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkOrderList");
            if (cb != null && cb.Checked)
            {
                ordercount++;
                //订单记录入临时表
                context.ExecuteNonQuery("insert into TMP_ORDER (F0,F1,F2) values('" +
                     Session.SessionID + "', '" + "0" + "','" + gvr.Cells[1].Text + "')");
                if (!company.Contains(gvr.Cells[2].Text))
                {
                    company.Add(gvr.Cells[2].Text);
                }
                ordersummoney += Convert.ToInt32(Convert.ToDecimal(gvr.Cells[4].Text) * 100);
                context.DBCommit();
                string sql = "select PAYTYPECODE from TF_F_PAYTYPE where orderno = '" + gvr.Cells[1].Text + "'";
                context.DBOpen("Select");
                DataTable data = context.ExecuteReader(sql);
                if (!(data.Rows.Count == 1 && data.Rows[0]["PAYTYPECODE"].ToString() == "4"))
                {
                    hidApprove.Value = "0";//不是付款方式只为呈批单的订单
                }
            }           
        }
        //校验是否选择了订单

        if (ordercount <= 0)
        {
            context.AddError("请选择订单！");
            return false;
        }

        if (hidApprove.Value == "0")//如果订单付款方式只为呈批单，则允许直接审核通过而不需要关联账单

        {
            foreach (GridViewRow gvr in gvResult.Rows)
            {
                CheckBox cb = (CheckBox)gvr.FindControl("chkCheck");
                if (cb != null && cb.Checked)
                {
                    checkcount++;
                    //账单记录入临时表
                    context.ExecuteNonQuery("insert into TMP_ORDER (F0,F1,F2) values('" +
                         Session.SessionID + "', '" + "1" + "', '" + gvr.Cells[7].Text + "')");

                    if (!company.Contains(gvr.Cells[3].Text))
                    {
                        company.Add(gvr.Cells[3].Text);
                    }

                    checksummoney += Convert.ToInt32(Convert.ToDecimal(gvr.Cells[1].Text) * 100);
                }
            }
            //校验是否选择了账单

            if (checkcount <= 0)
            {
                context.AddError("请选择账单！");
                return false;
            }
            //校验选择的订单总金额是否大于账单总金额

            if (ordersummoney > checksummoney)
            {
                context.AddError("选择的订单总金额超过账单总金额，请重新选择！");
                return false;
            }

            context.DBCommit();

            hidRemind.Value = "";

            //提示内容复制
            if (company.Count > 1)
            {
                foreach (string str in company)
                {
                    hidRemind.Value += "" + str + ";";
                }
            }
            else
            {
                hidRemind.Value = "";
            }
        }
        return true;
    }
    
    // 回退
    protected void btnRollBack_Click(object sender, EventArgs e)
    {
        if (gvOrderList.SelectedIndex < 0)
        {
            context.AddError("未选中任何行");
            return;
        }
        context.SPOpen();
        context.AddField("p_ORDERNO").Value = getDataKeys2("ORDERNO"); // 订单号

        context.AddField("p_HASAPPROVAL").Value = "0";//未审核

        bool ok = context.ExecuteSP("SP_GC_RETURNORDER");

        if (ok)
        {
            AddMessage("回退成功");

            btnQuery_Click(sender, e);
        }
    }

    protected void gvOrderList_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvOrderList','Select$" + e.Row.RowIndex + "')");
        }
    }

    protected void gvOrderList_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择员工GRIDVIEW中的一行记录

        string orderno = getDataKeys2("ORDERNO");
        ViewState["orderno"] = orderno;
        string groupName = getDataKeys2("GROUPNAME");
        string name = getDataKeys2("NAME");
        string phone = getDataKeys2("PHONE");
        string idCardNo = getDataKeys2("IDCARDNO");
        string totalMoney = getDataKeys2("TOTALMONEY");
        string transactor = getDataKeys2("TRANSACTOR");
        string remark = getDataKeys2("REMARK");
        string totalCashGiftChargeMoney = getDataKeys2("cashgiftmoney");
        string customeraccmoney = getDataKeys2("customeraccmoney");
        divInfo.InnerHtml = OrderHelper.GetOrderHtmlString(context, orderno, groupName,
            name, phone, idCardNo, totalMoney, transactor,
            remark, "1", "", totalCashGiftChargeMoney, "", customeraccmoney, "", "", false, false);
    }
    /// <summary>
    /// 获取关键字

    /// </summary>
    /// <param name="keysname"></param>
    /// <returns></returns>
    public String getDataKeys2(String keysname)
    {
        return gvOrderList.DataKeys[gvOrderList.SelectedIndex][keysname].ToString();
    }

    /// <summary>
    /// 查询订单按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!ValidInput()) return;

        string groupName = txtGroupName.Text.Trim();
        string name = txtName.Text.Trim();
        string staff = "";
        if (selStaff.SelectedIndex > 0)
        {
            staff = selStaff.SelectedValue;
        }
        string mstaff = "";//客户经理
        if (selManager.SelectedIndex > 0)
        {
            mstaff = selManager.SelectedValue;
        }
        string mdept = "";//客户经理所属部门

        if (selManagerDept.SelectedIndex > 0)
        {
            mdept = selManagerDept.SelectedValue;
        }
        string money = "";
        if (txtTotalMoney.Text.Trim().Length > 0)
        {
            money = (Convert.ToDecimal(txtTotalMoney.Text.Trim()) * 100).ToString();
        }
        string fromDate = txtFromDate.Text.Trim();
        string endDate = txtToDate.Text.Trim();

        DataTable dt = GroupCardHelper.callOrderQuery(context, "OrderInfoSelect", groupName, name, staff, money, fromDate, endDate, selDept.SelectedValue, mdept, mstaff);
        if (dt == null || dt.Rows.Count < 1)
        {
            gvOrderList.DataSource = new DataTable();
            gvOrderList.DataBind();
            context.AddError("未查出未审批的记录");
            return;
        }
        gvOrderList.DataSource = dt;
        gvOrderList.DataBind();

    }
    /// <summary>
    /// 查询账单按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQueryCheck_Click(object sender, EventArgs e)
    {
        if (!ValidCheckInput()) return;
        gvResult.DataSource = query();
        gvResult.DataBind();
    }
    /// <summary>
    /// 查询账单
    /// </summary>
    /// <returns></returns>
    private ICollection query()
    {
        string money = "";
        if (txtCheckMoney.Text.Trim().Length > 0)
        {
            money = (Convert.ToDecimal(txtCheckMoney.Text.Trim()) * 100).ToString();
        }
        DataTable data = GroupCardHelper.callOrderQuery(context, "AccountHasLeftQuery", txtAccountName.Text.Trim(),
            money, selCheckInStaff.SelectedValue, txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), txtAccount.Text.Trim());
        return new DataView(data);
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
    /// 账单查询校验
    /// </summary>
    /// <returns></returns>
    private bool ValidCheckInput()
    {
        if (txtCheckMoney.Text.Trim().Length > 0) //金额不为空时
        {
            if (!Validation.isPrice(txtCheckMoney.Text.Trim()))
            {
                context.AddError("金额输入不正确", txtCheckMoney);
            }
            else if (Convert.ToDecimal(txtCheckMoney.Text.Trim()) <= 0)
            {
                context.AddError("金额必须是正数", txtCheckMoney);
            }
        }
        //对开始日期和结束日期的判断

        UserCardHelper.validateDateRange(context, txtStartDate, txtEndDate, false);
        if (txtAccount.Text.Trim().Length > 0)  //对方帐号不为空时
        {
            if (Validation.strLen(txtAccount.Text.Trim()) > 20)
            {
                context.AddError("对方帐号长度不能超过20位", txtAccount);
            }
        }
        return !(context.hasError());
    }
}
