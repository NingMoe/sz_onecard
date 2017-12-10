using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using TDO.UserManager;
using Common;
using TDO.BusinessCode;
using System.Collections;
using TM;
using Master;

public partial class ASP_GroupCard_GC_OrderDistribution : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            ShowNonDataGridView();
            gvOrderList.DataKeyNames = new string[] { "ORDERNO", "GROUPNAME", "NAME", "PHONE", "IDCARDNO", "TOTALMONEY", "TRANSACTOR", "INPUTTIME", "REMARK", "cashgiftmoney", "customeraccmoney", "approver", "financeremark" };
            Init_Page();

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
        //初始化经办人
        InitStaffList(ddlTransactor, "");
        //初始化部门


        //TMTableModule tmTMTableModule = new TMTableModule();
        //TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
        //TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
        //ControlDeal.SelectBoxFill(ddlDepart.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
        //ddlDepart.SelectedValue = context.s_DepartID;

        FIHelper.selectDeptHasArea(context, ddlDepart, true);

    }
    /// <summary>
    /// 初始化下拉选框
    /// </summary>
    /// <param name="ddl">控件名称</param>
    /// <param name="deptNo">部门编码</param>
    private void InitStaffList(DropDownList ddl, string deptNo)
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
                GroupCardHelper.fill(ddlTransactor, table, true);

                return;
            }

            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);
            ControlDeal.SelectBoxFill(ddlTransactor.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
            //ddlTransactor.SelectedValue = context.s_UserID;

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

    //部门选择事件
    protected void ddlDept_Change(object sender, EventArgs e)
    {
        InitStaffList(ddlTransactor, ddlDepart.SelectedValue);
    }
    /// <summary>
    /// 查询
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!ValidInput()) return;
        gvOrderList.DataSource = query();
        gvOrderList.DataBind();
        gvOrderList.SelectedIndex = -1;
    }
    /// <summary>
    /// 查询
    /// </summary>
    /// <returns></returns>
    private ICollection query()
    {
        string companyName = txtGroupName.Text.Trim();
        string money = "";
        if (txtTotalMoney.Text.Trim().Length > 0)
        {
            money = (Convert.ToDecimal(txtTotalMoney.Text.Trim()) * 100).ToString();
        }
        DataTable data = GroupCardHelper.callOrderQuery(context, "QueryOrderApproved", companyName, txtName.Text.Trim(),
             ddlTransactor.SelectedValue, money, txtFromDate.Text.Trim(), txtToDate.Text.Trim(), ddlDepart.SelectedValue, context.s_DepartID);

        if (data == null || data.Rows.Count < 1)
        {
            gvOrderList.DataSource = new DataTable();
            gvOrderList.DataBind();
            context.AddError("未查出订单记录");
        }
        return new DataView(data);
    }
    /// <summary>
    /// 查询单位名称
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void queryGroupName(object sender, EventArgs e)
    {
        queryCompany(txtGroupName, selCompany);
    }
    private void queryCompany(TextBox txtCompanyPar, DropDownList selCompanyPar)
    {
        //模糊查询单位名称，并在列表中赋值


        string name = txtCompanyPar.Text.Trim();
        if (name == "")
        {
            selCompanyPar.Items.Clear();
            return;
        }

        TD_M_BUYCARDCOMINFOTDO tdoTD_M_BUYCARDCOMINFOIn = new TD_M_BUYCARDCOMINFOTDO();
        TD_M_BUYCARDCOMINFOTDO[] tdoTD_M_BUYCARDCOMINFOOutArr = null;
        tdoTD_M_BUYCARDCOMINFOIn.COMPANYNAME = "%" + name + "%";
        tdoTD_M_BUYCARDCOMINFOOutArr = (TD_M_BUYCARDCOMINFOTDO[])tm.selByPKArr(context, tdoTD_M_BUYCARDCOMINFOIn, typeof(TD_M_BUYCARDCOMINFOTDO), null, "TD_M_BUYCARDCOMINFO_NAME", null);
        selCompanyPar.Items.Clear();
        if (tdoTD_M_BUYCARDCOMINFOOutArr.Length > 0)
        {
            selCompanyPar.Items.Add(new ListItem("---请选择---", ""));
        }
        foreach (TD_M_BUYCARDCOMINFOTDO ddoComInfo in tdoTD_M_BUYCARDCOMINFOOutArr)
        {
            selCompanyPar.Items.Add(new ListItem(ddoComInfo.COMPANYNAME));
        }
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



    protected void gvOrderList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            HiddenField hidDept = e.Row.Cells[0].FindControl("hidGetDept") as HiddenField;
            HiddenField hidDate = e.Row.Cells[0].FindControl("hidGetDate") as HiddenField;
            //初始化领卡网点


            //TMTableModule tmTMTableModule = new TMTableModule();
            //TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
            //TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
            DropDownList getDept = e.Row.Cells[2].FindControl("ddlGetDepart") as DropDownList;
            FIHelper.selectDeptHasArea(context, getDept, true);
            //ControlDeal.SelectBoxFill(getDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
            if (hidDept.Value != "")
            {
                getDept.SelectedValue = hidDept.Value;
            }
            //初始化领卡日期


            TextBox getDate = e.Row.Cells[3].FindControl("txtGetDate") as TextBox;
            if (hidDate.Value != "")
            {
                getDate.Text = hidDate.Value;
            }
            else
            {
                getDate.Text = string.Empty;
            }
            //if (getDate.Text.Trim().Length<1)
            //{
            //     getDate.Text = DateTime.Today.ToString("yyyyMMdd");
            //}

        }
    }



    protected void btnDetail_Click(object sender, EventArgs e)
    {
        Button btnCreate = sender as Button;
        int index = int.Parse(btnCreate.CommandArgument);//获取行号
        //选择员工GRIDVIEW中的一行记录


        string orderno = getDataKeys2(index, "ORDERNO");
        ViewState["orderno"] = orderno;
        string groupName = getDataKeys2(index, "GROUPNAME");
        string name = getDataKeys2(index, "NAME");
        string phone = getDataKeys2(index, "PHONE");
        string idCardNo = getDataKeys2(index, "IDCARDNO");
        string totalMoney = getDataKeys2(index, "TOTALMONEY");
        string transactor = getDataKeys2(index, "TRANSACTOR");
        string remark = getDataKeys2(index, "REMARK");
        string totalCashGiftChargeMoney = getDataKeys2(index, "cashgiftmoney");
        string customeraccmoney = getDataKeys2(index, "customeraccmoney");
        string approver = getDataKeys2(index, "approver");
        string financeRemark = getDataKeys2(index, "financeremark");
        divInfo.InnerHtml = OrderHelper.GetOrderHtmlString(context, orderno, groupName,
            name, phone, idCardNo, totalMoney, transactor,
            remark, "0", financeRemark, totalCashGiftChargeMoney, approver, customeraccmoney, "", "", false, false);
    }

    public String getDataKeys2(int index, String keysname)
    {
        return gvOrderList.DataKeys[index][keysname].ToString();
    }

    /// <summary>
    /// 提交分配
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        string sessionID = Session.SessionID;
        ValidSubmit();
        if (context.hasError())
            return;
        FillTempTable(sessionID);
        context.SPOpen();
        context.AddField("p_sessionID").Value = sessionID;
        bool ok = context.ExecuteSP("SP_GC_OrderDistribution");
        if (ok)
        {
            AddMessage("确认分配成功");
        }
        //清空临时表


        clearTempTable(sessionID);
        btnQuery_Click(sender, e);
    }
    /// <summary>
    /// 验证提交
    /// </summary>
    private void ValidSubmit()
    {

        int count = 0;
        for (int index = 0; index < gvOrderList.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvOrderList.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                DropDownList getDept = (DropDownList)gvOrderList.Rows[index].Cells[2].FindControl("ddlGetDepart");//领卡网点
                TextBox getDate = (TextBox)gvOrderList.Rows[index].Cells[3].FindControl("txtGetDate");//领卡日期
                if (getDept.SelectedIndex < 1)
                {
                    context.AddError("请选择领用网点", getDept);
                }
                if (getDate.Text.Trim().Length < 1)
                {
                    context.AddError("领卡日期不可为空", getDate);
                }
                else if (!Validation.isDate(getDate.Text.Trim(), "yyyyMMdd"))
                {
                    context.AddError("领卡日期格式不是yyyyMMdd", getDate);
                }

            }

        }
        // 没有选中任何行，则返回错误


        if (count <= 0)
        {
            context.AddError("A004P03R01: 没有选中任何行");
        }
    }
    /// <summary>
    /// 数据插入临时表


    /// </summary>
    /// <param name="sessionID"></param>
    private void FillTempTable(string sessionID)
    {

        //记录入临时表
        context.DBOpen("Insert");
        for (int index = 0; index < gvOrderList.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvOrderList.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {

                string orderno = gvOrderList.Rows[index].Cells[5].Text.Trim();
                string isrelated = "1";
                RadioButton radio = (RadioButton)gvOrderList.Rows[index].Cells[4].FindControl("radioButton1");
                if (radio.Checked == false)  //关联卡选择否

                {
                    isrelated = "0";
                }
                DropDownList getDept = (DropDownList)gvOrderList.Rows[index].Cells[2].FindControl("ddlGetDepart");//领卡网点
                TextBox getDate = (TextBox)gvOrderList.Rows[index].Cells[3].FindControl("txtGetDate");//领卡日期

                //F0:订单编号，F1:是否关联卡，F2:领卡网点，F3：领卡日期，F4：SessionID
                context.ExecuteNonQuery(@"insert into TMP_ORDER (f0,f1,f2,f3,f4)
                                values('" + orderno + "','" + isrelated + "','" + getDept.SelectedValue + "','" + getDate.Text.Trim() + "','" + sessionID + "')");
            }
        }
        context.DBCommit();


    }

    /// <summary>
    /// 清空临时表


    /// </summary>
    private void clearTempTable(string sessionID)
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_ORDER");
        context.DBCommit();
    }   
}