using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TDO.BusinessCode;
using TDO.UserManager;
using Common;
using TM;
using System.Data;

public partial class ASP_GroupCard_GC_OrderSubmission : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
        //初始化部门

        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
        TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
        ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
        //selDept.SelectedValue = context.s_DepartID;
        InitStaffList(context.s_DepartID);
        //selStaff.SelectedValue = context.s_UserID;
        gvOrderList.DataKeyNames = new string[] { "ORDERNO", "GROUPNAME", "NAME", "PHONE", "IDCARDNO", "TOTALMONEY", 
            "TRANSACTOR", "INPUTTIME", "FINANCEAPPROVERNO",  "financeremark",
            "ORDERSTATE","REMARK","cashgiftmoney","CHARGECARDMONEY","CUSTOMERACCMONEY","isrelated"};
    }

    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selDept.SelectedValue);
    }

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

    //查询单位名称
    protected void queryCompany(object sender, EventArgs e)
    {
      OrderHelper.queryCompany(context, txtCompany, selCompany);
    }

    protected void SelectedIndexChanged(object sender, EventArgs e)
    {
        if (selCompany.SelectedIndex > 0)
        {
            txtCompany.Text = selCompany.SelectedItem.Text;
        }
        else
        {
            txtCompany.Text = string.Empty;
        }
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
            selCompanyPar.Items.Add(new ListItem(ddoComInfo.COMPANYNAME, ddoComInfo.COMPANYNO));
        }
    }


    /// <summary>
    /// 查询验证
    /// </summary>
    /// <returns></returns>
    private bool ValidInput()
    {
        //校验单位名称长度
        if (!string.IsNullOrEmpty(txtCompany.Text.Trim()))
        {
            if (txtCompany.Text.Trim().Length > 50)
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
                context.AddError("A094391334:金额输入不正确", txtTotalMoney);
            }
            else if (Convert.ToDecimal(txtTotalMoney.Text.Trim()) <= 0)
            {
                context.AddError("A094391335:金额必须是正数", txtTotalMoney);
            }
        }
        if (txtName.Text.Trim().Length > 10)
        {
            context.AddError("A094391336:联系人长度不超过8位", txtName);
        }
        //对开始日期和结束日期的判断

        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, false);
        return !(context.hasError());
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!ValidInput())
        {
            return;
        }
        string groupName = txtCompany.Text.Trim();
        string name = txtName.Text.Trim();
        string staff = "";
        if (selStaff.SelectedIndex > 0)
        {
            staff = selStaff.SelectedValue;
        }
        string money = "";
        if (txtTotalMoney.Text.Trim().Length > 0)
        {
            money = (Convert.ToDecimal(txtTotalMoney.Text.Trim()) * 100).ToString();
        }
        string fromDate = txtFromDate.Text.Trim();
        string endDate = txtToDate.Text.Trim();

        DataTable dt = GroupCardHelper.callOrderQuery(context, "GotCardOrderQuery", groupName, name, staff, money, fromDate, endDate, selDept.SelectedValue,context.s_DepartID);
        if (dt == null || dt.Rows.Count < 1)
        {
            gvOrderList.DataSource = new DataTable();
            gvOrderList.DataBind();
            context.AddError("A094391337:未查出领用完成的记录");
            return;
        }
        gvOrderList.DataSource = dt;
        gvOrderList.DataBind();
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
        string customeraccmoney = getDataKeys2("CUSTOMERACCMONEY");
        string financeRemark = getDataKeys2("financeremark");
        string approver = getDataKeys2("FINANCEAPPROVERNO");
        string chargecardmoney = getDataKeys2("CHARGECARDMONEY");
        //if (Convert.ToInt32(chargecardmoney) > 0)
        //{
        //    hidHasChargeCard.Value = "1";
        //    divSale.Visible = true;
        //}
        //else
        //{
        //    hidHasChargeCard.Value = "0";
        //    divSale.Visible = false;
        //}
        divInfo.InnerHtml = OrderHelper.GetOrderHtmlString(context, orderno, groupName,
            name, phone, idCardNo, totalMoney, transactor,
            remark, "0", financeRemark, totalCashGiftChargeMoney, approver, customeraccmoney, "", "", false, false);
    }

    public String getDataKeys2(String keysname)
    {
        return gvOrderList.DataKeys[gvOrderList.SelectedIndex][keysname].ToString();
    }

    // "支付方式"与"到账标记"下拉列表选择更改事件处理
    //protected void selPayMode_SelectedIndexChanged(object sender, EventArgs e)
    //{
    //    if (selPayMode.SelectedValue == "1") // 现金
    //    {
    //        selRecvTag.Enabled = false;
    //        txtAccRecvDate.Enabled = false;
    //    }
    //    else if (selPayMode.SelectedValue == "0" || selPayMode.SelectedValue == "2") // 转账或报销
    //    {
    //        selRecvTag.Enabled = true;
    //        if (selRecvTag.SelectedValue == "0") // 未到账

    //        {
    //            txtAccRecvDate.Enabled = false;
    //            txtAccRecvDate.Text = "";
    //        }
    //        else if (selRecvTag.SelectedValue == "1") // 已到账

    //        {
    //            txtAccRecvDate.Enabled = true;
    //        }
    //    }
    //    else if (selPayMode.SelectedIndex == 0)
    //    {
    //        selRecvTag.Enabled = false;
    //        selRecvTag.SelectedIndex = 0;
    //        txtAccRecvDate.Text = "";
    //    }
    //}

    // 提交前校验处理

    //private void submitValidate()
    //{
    //    if (hidHasChargeCard.Value == "1")//如果订单中有充值卡
    //    {
    //        Validation valid = new Validation(context);
    //        valid.notEmpty(selPayMode, "A007P02014: 付款方式必须设置");
    //        // 转账情况下的到账标记、到账日期校验（已到帐时检查到帐日期）
    //        if (selPayMode.SelectedValue == "0" || selPayMode.SelectedValue == "2")  // 转账
    //        {
    //            valid.notEmpty(selRecvTag, "A007P02015: 到帐标记必须设置");

    //            if (selRecvTag.SelectedValue == "1")
    //            {
    //                bool b = valid.notEmpty(txtAccRecvDate, "A007P02016: 到帐日期不能为空");
    //                DateTime? dt = null;
    //                if (b) dt = valid.beDate(txtAccRecvDate, "A007P02017: 到帐日期必须格式为yyyyMMdd");
    //                if (dt != null)
    //                {
    //                    valid.check(dt.Value.CompareTo(DateTime.Today) <= 0, "A007P02018: 到帐日期不能超过当前日期");
    //                }
    //            }
    //        }
    //        valid.check(Validation.strLen(txtRemark.Text) <= 200, "A007P02019: 备注长度不能超过200");
    //    }
    //}

    protected void btnGetCard_Click(object sender, EventArgs e)
    {
        if (gvOrderList.SelectedIndex < 0)
        {
            context.AddError("A007P02020: 请选择一个订单");
            return;
        }
        string isrelated = getDataKeys2("isrelated");//判断是否关联
        string orderstate = getDataKeys2("ORDERSTATE").Substring(0,2);
        if (isrelated == "0" && orderstate == "07")//如果是领卡完成状态且isrelated == "0"时

        {
            context.AddError("A007P02021: 此订单需要先完成领卡补关联");
            return;
        }
        //submitValidate();
        if (context.hasError())
        {
            return;
        }
        string orderno = getDataKeys2("ORDERNO");
        string transactor = getDataKeys2("TRANSACTOR");
        string groupName = getDataKeys2("GROUPNAME");
        transactor = transactor.Split(':')[0];
        
        //查询订单付款方式
        string sql = "select PAYTYPECODE from TF_F_PAYTYPE where ORDERNO = '" + getDataKeys2("ORDERNO") + "'";
        context.DBOpen("Select");
        DataTable data = context.ExecuteReader(sql);
        string payMode = "1";  // 默认现金
        for (int i = 0; i < data.Rows.Count; i++)
        {
            //如果订单中付款方式有选择呈批单，则为报销
            if (data.Rows[i]["PAYTYPECODE"].ToString() == "4")
            {
                payMode = "2";//报销
            }
        }
        for (int i = 0; i < data.Rows.Count; i++)
        {
            //如果订单中付款方式有选择转账，则为转账

            if (data.Rows[i]["PAYTYPECODE"].ToString() == "1")
            {
                payMode = "0";//转账
            }
        }

        //查询到账单

        string sqldate = "select b.TRADEDATE  from TF_F_ORDERCHECKRELATION a,TF_F_CHECK b where a.ORDERNO = '" + getDataKeys2("ORDERNO") + "' and a.CHECKID = b.CHECKID";
        context.DBOpen("Select");
        data = context.ExecuteReader(sqldate);

        string accRecv = data.Rows.Count > 0 ? "1" : "0"; // 到账标记

        string recvDate = data.Rows.Count > 0 ? data.Rows[0]["TRADEDATE"].ToString() : DateTime.Today.ToString("yyyyMMdd"); // 到账日期

        string companyApproval = "0";//是否是新单位标识，0为否
        string personApproval = "0";
        //判断是否是新客户（单位/个人）

        if (groupName != "")//单位订单，查询单位购卡记录表
        {
            string sqlCompany = "select * from tf_f_combuycardreg a where a.companyno = (select k.companyno from td_m_buycardcominfo k,tf_f_combuycardreg t where k.companyno = t.companyno and  t.remark ='" + orderno + "') ";
            context.DBOpen("Select");
            DataTable dataCompany = context.ExecuteReader(sqlCompany);
            if (dataCompany.Rows.Count==1)
            {
                companyApproval = "1";//是新增单位购卡标识

            }
            else
            {
                companyApproval = "0";
            }

        }
        else //个人
        {
            string sqlPerson = "select * from tf_f_perbuycardreg a ,(select t.papertype,t.paperno from tf_f_perbuycardreg t,TD_M_BUYCARDPERINFO k  where t.papertype = k.papertype and t.paperno = k.paperno and t.remark ='" + orderno + "')b where a.papertype = b.papertype  and a.paperno  = b.paperno";
            context.DBOpen("Select");
            DataTable dataCompany = context.ExecuteReader(sqlPerson);
            if (dataCompany.Rows.Count == 1)
            {
                personApproval = "1";//是新增个人购卡标识

            }
            else
            {
                personApproval = "0";
            }
        }

        context.DBCommit();

        context.SPOpen();
        context.AddField("p_orderNo").Value = orderno;
        context.AddField("p_transactor").Value = transactor;
        context.AddField("p_custName").Value = groupName;
        context.AddField("p_payMode").Value = payMode;
        context.AddField("p_accRecv").Value = accRecv;
        context.AddField("p_recvDate").Value = recvDate;
        context.AddField("p_remark").Value = "";
        bool ok = context.ExecuteSP("SP_GC_GetCardConfirm");
        if (ok)
        {
            context.AddMessage("A007P02021:订单完成确认成功");

            if (companyApproval.Equals("1"))//如果是新增单位购卡,提交至安全值审核界面

            {
                context.SPOpen();
                context.AddField("P_ORDERNO").Value = orderno;
                context.AddField("P_ORDERTYPE").Value = "1";//单位

                bool ok2 = context.ExecuteSP("SP_GC_BUYCARDAPPROVAL");// 提交至安全值审核

                if (ok2)
                {
                    context.AddMessage("购卡单位安全值提交至审核界面成功");
                }
                else
                {
                    context.AddMessage("首次购卡单位安全值未提交至审核界面，若要设置安全值请在购卡客户维护界面设置");
                }
            }
            if (personApproval.Equals("1"))//如果是新增个人购卡,提交至安全值审核界面

            {
                context.SPOpen();
                context.AddField("P_ORDERNO").Value = orderno;
                context.AddField("P_ORDERTYPE").Value = "2";//个人
                bool ok3 = context.ExecuteSP("SP_GC_BUYCARDAPPROVAL");// 提交至安全值审核

                if (ok3)
                {
                    context.AddMessage("购卡个人安全值提交至审核界面成功");
                }
                else
                {
                    context.AddMessage("首次购卡个人安全值未提交至审核界面，若要设置安全值请在购卡客户维护界面设置");
                }
            }
            btnQuery_Click(sender, e);
        }
    }

}