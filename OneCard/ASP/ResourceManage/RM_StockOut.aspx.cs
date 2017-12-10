using System;
using System.Data;
using System.Collections;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TM;
using TDO.CardManager;
using TDO.UserManager;
using System.IO;
/***************************************************************
 * 功能名: 资源管理出库
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/07/24    殷华荣			初次开发
 * 
 * 2015/09/10    youyue         增加导入卡号文件的方式提交出库
 ****************************************************************/
public partial class ASP_ResourceManage_RM_StockOut : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            gvResultUseCard.DataKeyNames = new string[] {  "getcardorderid" ,"cardtypecode","cardtypename" , "cardsurfacecode",
                                                           "cardsurfacename" ,"applygetnum" ,"agreegetnum" ,"alreadygetnum" ,
                                                             "useway" ,"ordertime" ,"orderstaffno" ,"staffname","departname" ,
                                                            "remark"};

            gvResultChargeCard.DataKeyNames = new string[] { "getcardorderid", "valuecode", "value", "applygetnum","agreegetnum","alreadygetnum", 
                                                                 "useway", "ordertime", "orderstaffno", "staffname", "departname", "remark" };

            txtFromCardNo.Attributes["OnBlur"] = "javascript:return Change();";
            txtToCardNo.Attributes["OnBlur"] = "javascript:return Change();";
            setReadOnly(txtCardSum);

            // 选取拥有领用权限的员工，生成列表
            UserCardHelper.selectAssignableStaffs(context, ddlAssignedStaff, true);
            UserCardHelper.selectAssignableStaffs(context, selAssignedStaff, false);

            //初始化开始日期
            txtStartDate.Text = DateTime.Now.AddMonths(-1).ToString("yyyyMMdd");
            txtEndDate.Text = DateTime.Now.ToString("yyyyMMdd");

            // 服务周期
            selServiceCycle.Items.Add(new ListItem("00:年度", "00"));
            selServiceCycle.Items.Add(new ListItem("01:季度", "01"));
            selServiceCycle.Items.Add(new ListItem("02:月份", "02"));
            selServiceCycle.Items.Add(new ListItem("03:天数", "03"));
            selServiceCycle.Items[2].Selected = true;

            // 退值（模式）
            selRetValMode.Items.Add(new ListItem("0:不退值", "0"));
            //selRetValMode.Items.Add(new ListItem("有条件退值", "1"));
            selRetValMode.Items.Add(new ListItem("2:无条件退值", "2"));
            selRetValMode.Items[1].Selected = true;

            //售卡方式
            selSaleType.Items.Add(new ListItem("01:卡费", "01"));
            selSaleType.Items.Add(new ListItem("02:押金", "02"));
            selSaleType.Items[0].Selected = true;

            //初始化领用状态
            ddlAssignedState.Items.Add(new ListItem("0:全部", "0"));
            ddlAssignedState.Items.Add(new ListItem("1:未领完", "1"));
            ddlAssignedState.Items.Add(new ListItem("2:已领完", "2"));
            ddlAssignedState.Items[0].Selected = true;

            ddlPrintState.Items.Add(new ListItem("0:全部", "0"));
            ddlPrintState.Items.Add(new ListItem("1:已打印", "1"));
            ddlPrintState.Items.Add(new ListItem("2:未打印", "2"));
            ddlPrintState.Items[0].Selected = true;

            showOrderNonDataGridView();

            hidCardType.Value = "usecard";

            //初始化充值卡领用部门、领用员工
            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
            TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
            ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
            selDept.SelectedValue = context.s_DepartID;
            InitStaffList(context.s_DepartID);
            selStaff.SelectedValue = context.s_UserID;


        }
        ResourceManageHelper.selectTab(this, this.GetType(), hidCardType);
    }

    // 选中gridview当前页所有数据
    protected void CheckAll(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResultUseCard.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }

    protected void selDept_Changed(object sender, EventArgs e)
    {
        //初始化员工
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

    //显示空表格
    private void showOrderNonDataGridView()
    {
        gvResultUseCard.DataSource = new DataTable();
        gvResultUseCard.DataBind();
        gvResultChargeCard.DataSource = new DataTable();
        gvResultChargeCard.DataBind();
    }

    protected void selSellType_change(object sender, EventArgs e)
    {
        if (selSaleType.SelectedValue.Equals("01"))
        {
            selServiceCycle.Enabled = false;
            txtServiceFee.Enabled = false;
            txtServiceFee.Text = "0";
        }
        else
        {
            selServiceCycle.Enabled = true;
            txtServiceFee.Enabled = true;
            txtServiceFee.Text = "1";
        }
    }
    /// <summary>
    /// 查询输入校验
    /// </summary>
    protected void queryValidation()
    {
        if (!string.IsNullOrEmpty(txtGetApplyNo.Text.Trim()) && txtGetApplyNo.Text.Trim() != "LY")
        {
            if (Validation.strLen(txtGetApplyNo.Text.Trim()) != 18)
                context.AddError("A094390100：领用单号必须为18位", txtGetApplyNo);
            if (!Validation.isCharNum(txtGetApplyNo.Text.Trim()))
                context.AddError("A094390101：领用单必须为英数", txtGetApplyNo);
        }
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //验证日期
        ResourceManageHelper.checkDate(context, txtStartDate, txtEndDate, "开始日期范围起始值格式必须为yyyyMMdd",
            "结束日期范围终止值格式必须为yyyyMMdd", "开始日期不能大于结束日期");

        queryValidation();

        if (context.hasError())
        {
            return;
        }
        DataTable data;
        string staff = "";
        if (ddlAssignedStaff.SelectedIndex > 0)
        {
            staff = ddlAssignedStaff.SelectedValue;
        }
        string getApplyNo = txtGetApplyNo.Text.Trim();
        if (txtGetApplyNo.Text.Trim() == "LY")
        {
            getApplyNo = "";
        }
        if (hidCardType.Value == "usecard")
        {
            if (ddlPrintState.SelectedIndex == 0) //显示全部包括 已打印和未打印的
            {
                data = ResourceManageHelper.callQuery(context, "USECARD_APPROVED", getApplyNo, staff,
                    txtStartDate.Text, txtEndDate.Text, ddlAssignedState.SelectedValue, "0");
            }
            else if (ddlPrintState.SelectedIndex == 1) //只显示已打印的
            {
                data = ResourceManageHelper.callQuery(context, "USECARD_APPROVED", getApplyNo, staff,
                                   txtStartDate.Text, txtEndDate.Text, ddlAssignedState.SelectedValue, "1");
            }
            else //只显示未打印的
            {
                data = ResourceManageHelper.callQuery(context, "USECARD_APPROVED", getApplyNo, staff,
                                                  txtStartDate.Text, txtEndDate.Text, ddlAssignedState.SelectedValue, "0", "0");
            }
            UserCardHelper.resetData(gvResultUseCard, data);
        }
        else
        {
            if (ddlPrintState.SelectedIndex == 0) //显示全部包括 已打印和未打印的
            {
                data = ResourceManageHelper.callQuery(context, "CHARGECARD_APPROVED", getApplyNo, staff,
                        txtStartDate.Text, txtEndDate.Text, ddlAssignedState.SelectedValue, "0");
            }
            else if (ddlPrintState.SelectedIndex == 1) //只显示已打印的
            {
                data = ResourceManageHelper.callQuery(context, "CHARGECARD_APPROVED", getApplyNo, staff,
                        txtStartDate.Text, txtEndDate.Text, ddlAssignedState.SelectedValue, "1");
            }
            else
            {
                data = ResourceManageHelper.callQuery(context, "CHARGECARD_APPROVED", getApplyNo, staff,
                                       txtStartDate.Text, txtEndDate.Text, ddlAssignedState.SelectedValue, "0", "0");
            }
            UserCardHelper.resetData(gvResultChargeCard, data);
        }
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
    }

    // 输入校验处理
    private void SubmitValidate()
    {
        //对起始卡号和结束卡号进行校验
        UserCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo);
        if (context.hasError())
        { return; }
        //对卡服务费进行非空、数字检验
        UserCardHelper.validatePrice(context, txtServiceFee, "A002P02009: 卡服务费不能为空", "A002P02010: 卡服务费必须是10.2的格式");
        if (context.hasError())
        { return; }
        //对卡片单价进行非空、数字检验
        UserCardHelper.validatePrice(context, txtCardPrice, "A002P02011: 卡片单价不能为空", "A002P02010: 卡片单价必须是10.2的格式");
        if (context.hasError())
        { return; }
        //验证出库数量是否大于同意领用数量
        if (Convert.ToInt32(txtCardSum.Text.Trim()) > Convert.ToInt32(getUseCardDataKeys2("agreegetnum")))
        {
            context.AddError("出库数量不能大于同意领用数量", txtCardSum);
        }
    }
    //提交申请
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        
        if (hidCardType.Value == "usecard")
        {
            if (gvResultUseCard.SelectedIndex < 0)
            {
                context.AddError("请选择一条领用单");
                return;
            }
            //验证领用员工和申请人是否是同一个人
            string orderstaffno = getUseCardDataKeys2("orderstaffno");
            if (orderstaffno != selAssignedStaff.SelectedValue)
            {
                context.AddError("申请员工和领用员工必须是同一个人");
                return;
            }

            SubmitValidate();

            if (context.hasError())
            {
                return;
            }

            //验证卡号段卡面类型是否和选择的领用单一致
            if (txtFromCardNo.Text.Trim().Substring(4, 4) != getUseCardDataKeys2("cardsurfacecode")
                || txtToCardNo.Text.Trim().Substring(4, 4) != getUseCardDataKeys2("cardsurfacecode"))
            {
                context.AddError("卡号段中卡面类型和选中的领用单不一致");
            }

            if (context.hasError())
            {
                return;
            }
            //调用用户卡出库存储过程
            context.SPOpen();
            context.AddField("p_fromCardNo").Value = txtFromCardNo.Text.Trim();
            context.AddField("p_toCardNo").Value = txtToCardNo.Text.Trim();
            context.AddField("p_assignedStaff").Value = selAssignedStaff.SelectedValue;
            context.AddField("p_serviceCycle").Value = selServiceCycle.SelectedValue;
            context.AddField("p_serviceFee", "Int32").Value = Convert.ToDecimal(txtServiceFee.Text.Trim()) * 100;
            context.AddField("p_retValMode").Value = selRetValMode.SelectedValue;
            context.AddField("p_saleType").Value = selSaleType.SelectedValue;
            context.AddField("p_cardPrice", "Int32").Value = Convert.ToDecimal(txtCardPrice.Text.Trim()) * 100;
            context.AddField("p_getcardorderid").Value = getUseCardDataKeys2("getcardorderid");
            context.AddField("p_alreadygetnum", "Int32").Value = Convert.ToInt32(txtCardSum.Text);
            bool ok = context.ExecuteSP("SP_RM_StockOut_COMMIT");

            if (ok)
            {
                AddMessage("D002P02000: 出库成功");
                //if (chkOrder.Checked)
                //{
                //    string getcardorderid = context.GetFieldValue("p_getCardOrderID").ToString();
                //    string cardface = gvResultUseCard.Rows[gvResultUseCard.SelectedIndex].Cells[2].Text;
                //    string applygetnum = gvResultUseCard.Rows[gvResultUseCard.SelectedIndex].Cells[3].Text;     //申请领用数量
                //    string agreegetnum = gvResultUseCard.Rows[gvResultUseCard.SelectedIndex].Cells[4].Text;     //同意领用数量
                //    string alreadygetnum = (Convert.ToInt32(txtCardSum.Text.Trim()) + Convert.ToInt32(gvResultUseCard.Rows[gvResultUseCard.SelectedIndex].Cells[6].Text)).ToString(); //已领用数量
                //    string useway = gvResultUseCard.Rows[gvResultUseCard.SelectedIndex].Cells[6].Text;         //用途
                //    string remark = gvResultUseCard.Rows[gvResultUseCard.SelectedIndex].Cells[10].Text;         //备注
                //    printhtml = RMPrintHelper.GetUseCardApplyPrintText(context, getcardorderid, cardface,
                //                                                       applygetnum, agreegetnum, alreadygetnum,
                //                                                       context.s_DepartName, context.s_UserName, useway, remark);
                //    printarea.InnerHtml = printhtml;
                //    //执行打印脚本
                //    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
                //}
                gvResultUseCard.SelectedIndex = -1;
            }
        }
        else
        {
            if (gvResultChargeCard.SelectedIndex < 0)
            {
                context.AddError("请选择一条领用单");
                return;
            }
            string valuecode = getChargeCardDataKeys2("valuecode");

            //验证充值卡卡号
            bool b = ChargeCardHelper.hasSameFaceValue(context, txtStartCardNo, txtEndCardNo, valuecode);
            if (!b)
            {
                return;
            }

            //验证领用员工申请领用单员工是否是同一个人
            string orderstaffno = getChargeCardDataKeys2("orderstaffno");
            if (orderstaffno != selStaff.SelectedValue)
            {
                context.AddError("申请员工和领用员工必须是同一个人");
                return;
            }

            //调用充值卡出库存储过程
            context.SPOpen();
            context.AddField("p_fromCardNo").Value = txtStartCardNo.Text.Trim();
            context.AddField("p_toCardNo").Value = txtEndCardNo.Text.Trim();
            context.AddField("p_assignDepartNo").Value = selDept.SelectedValue;
            context.AddField("p_getcardorderid").Value = getChargeCardDataKeys2("getcardorderid");
            context.AddField("p_alreadygetnum", "Int32").Value = Convert.ToInt32(labQuantity.Text);
            context.AddField("p_getStaffNo").Value = selStaff.SelectedValue;
            bool ok = context.ExecuteSP("SP_RM_CC_StockOut_Commit");
            if (ok)
            {
                AddMessage("D002P02000: 出库成功");
                //if (chkOrder.Checked)
                //{
                //    string getcardorderid = context.GetFieldValue("P_getCardOrderID").ToString();
                //    string cardvalue = gvResultChargeCard.Rows[gvResultChargeCard.SelectedIndex].Cells[1].Text; //卡面名称
                //    string applygetnum = gvResultChargeCard.Rows[gvResultChargeCard.SelectedIndex].Cells[2].Text; //卡片数量
                //    string agreegetnum = gvResultUseCard.Rows[gvResultUseCard.SelectedIndex].Cells[3].Text;       //同意领用数量
                //    string alreadygetnum = (Convert.ToInt32(labQuantity.Text.Trim()) + Convert.ToInt32(gvResultUseCard.Rows[gvResultUseCard.SelectedIndex].Cells[4].Text)).ToString(); //已领用数量
                //    string useway = gvResultChargeCard.Rows[gvResultChargeCard.SelectedIndex].Cells[5].Text;         //用途
                //    string remark = gvResultChargeCard.Rows[gvResultChargeCard.SelectedIndex].Cells[9].Text;         //备注
                //    printhtml = RMPrintHelper.GetChargeCardApplyPrintText(context, getcardorderid, cardvalue,
                //                                                        applygetnum, agreegetnum, alreadygetnum,
                //                                                       context.s_DepartName, context.s_UserName, useway, remark);
                //    printarea.InnerHtml = printhtml;
                //    //执行打印脚本
                //    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
                //}
                gvResultChargeCard.SelectedIndex = -1;
            }
        }
        btnQuery_Click(sender, e);
    }
    /// <summary>
    /// 打印领用单
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnPrint_Click(object sender, EventArgs e)
    {
        string printhtml = "";
        string sessionID = Session.SessionID;
        //用户卡
        if (hidCardType.Value == "usecard")
        {
            printhtml = RMPrintHelper.GetUseCardApplyPrintText(context, gvResultUseCard);
        }
        else
        {
            printhtml = RMPrintHelper.GetChargeCardApplyPrintText(context, gvResultChargeCard);
        }
        if (context.hasError())
        {
            return;
        }
        if (hidCardType.Value == "usecard")
        {
            ResourceManageHelper.fillGetCardNoList(context, gvResultUseCard, sessionID);
            context.SPOpen();
            context.AddField("p_sessionID").Value = sessionID;
            bool ok = context.ExecuteSP("SP_RM_PrintCount");
            if (!ok)
            {
                return;
            }
        }
        else
        {
            ResourceManageHelper.fillGetCardNoList(context, gvResultChargeCard, sessionID);
            context.SPOpen();
            context.AddField("p_sessionID").Value = sessionID;
            bool ok = context.ExecuteSP("SP_RM_PrintCount");
            if (!ok)
            {
                return;
            }
        }
        //清空临时表
        ResourceManageHelper.ClearTempData(context, sessionID);
        printarea.InnerHtml = printhtml;
        //执行打印脚本
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printOrderdiv('printarea');", true);
    }

    protected void gvResultUseCard_SelectedIndexChanged(object sender, EventArgs e)
    {
        string orderstaffno = getUseCardDataKeys2("orderstaffno");
        selAssignedStaff.SelectedValue = orderstaffno;
        queryDepositAcc();
    }


    protected void gvResultUseCard_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResultUseCard','Select$" + e.Row.RowIndex + "')");
        }
    }

    protected void gvResultChargeCard_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResultChargeCard','Select$" + e.Row.RowIndex + "')");
        }
    }

    public String getUseCardDataKeys2(String keysname)
    {
        return gvResultUseCard.DataKeys[gvResultUseCard.SelectedIndex][keysname].ToString();
    }

    public String getChargeCardDataKeys2(String keysname)
    {
        return gvResultChargeCard.DataKeys[gvResultChargeCard.SelectedIndex][keysname].ToString();
    }



    protected void selAssignedStaff_Change(object sender, EventArgs e)
    {
        //查询保证金账户
        queryDepositAcc();
    }
    protected void queryDepositAcc()
    {
        string cardsurfacecode = string.Empty;
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryStaffIsDeptBal", selAssignedStaff.SelectedValue);
        //如果查询结果存在并且员工所属网点结算单元为代理营业厅
        if (data.Rows.Count != 0 && data.Rows[0]["DEPTTYPE"].ToString().Equals("1"))
        {
            //查询保证金账户
            DataTable dataDeposit = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryDeptBalUnitDeposit", data.Rows[0]["DBALUNITNO"].ToString());
            if (dataDeposit.Rows.Count == 0)
            {
                //查询结果为空
                context.AddError("代理营业厅网点结算单元没有保证金账户！");
                return;
            }
            else
            {
                if (gvResultUseCard.DataKeys.Count>0)
                {
                    cardsurfacecode = getUseCardDataKeys2("cardsurfacecode");
                }
                
                labDeposit.Text = dataDeposit.Rows[0]["DEPOSIT"].ToString();

                //现在对代理网点的卡片出库保证金是10元/张，但对手表的代理价为358，所以保证金应为358,手表卡目前卡类型为2002连爱手表
                if (cardsurfacecode != "2002" )
                {
                    //获取可领卡价值额度，网点剩余卡价值
                    DeptBalunitHelper.SetDeposit(context, data.Rows[0]["DBALUNITNO"].ToString(), labDeposit, labUsablevalue, labStockvalue);
                    //获取卡价值
                    double cardValue = Convert.ToDouble(dataDeposit.Rows[0]["TAGVALUE"]);
                    labMaxAvailaCard.Text = ((int)(Convert.ToDouble(labUsablevalue.Text) / cardValue)).ToString();
                }
                else
                {
                    //获取手环卡代理营业厅对应网点结算单元编码的可领卡价值额度和网点剩余卡价值
                    SetSHDeposit(context, data.Rows[0]["DBALUNITNO"].ToString(), labDeposit, labUsablevalue, labStockvalue, labMaxAvailaCard);
                                      
                }              
            }
        }
        else
        {
            //清空
            labDeposit.Text = "";
            labUsablevalue.Text = "";
            labStockvalue.Text = "";
            labMaxAvailaCard.Text = "";
        }


    }
    //手环卡代理营业厅对应网点结算单元编码的可领卡价值额度和网点剩余卡价值
    private void SetSHDeposit(Master.CmnContext context, string dBalunitNo, Label labDeposit, Label labUusablevalue, Label labStockvalue, Label labMaxAvailaCard)
    {
        //查询结算单元卡总数量
        context.DBOpen("Select");
        string sql1 = @"select count(*) NUM
                        from TL_R_ICUSER a
                        where exists (select * from  TD_DEPTBAL_RELATION b 
                                      where a.assigneddepartid=b.departno 
                                      and b.dbalunitno='" + dBalunitNo + "')";
        sql1 += " and a.RESSTATECODE IN('01','05') ";
        DataTable table1 = context.ExecuteReader(sql1);

        context.DBOpen("Select");
        string sql2 = @"select count(*) NUM
                        from TL_R_ICUSER a
                        where exists (select * from  TD_DEPTBAL_RELATION b 
                                      where a.assigneddepartid=b.departno 
                                      and b.dbalunitno='" + dBalunitNo + "')";
        sql1 += " and a.RESSTATECODE IN('01','05') and a.cardsurfacecode='2002' ";
        DataTable table2 = context.ExecuteReader(sql1);
        
        //查询网点的读卡器价值额度 add by youyue 20130926
        context.DBOpen("Select");
        string sql3 = @"select count(*) NUM
                        from TL_R_READER a
                        where exists (select * from  TD_DEPTBAL_RELATION b 
                                      where a.assigneddepartid=b.departno 
                                      and b.dbalunitno='" + dBalunitNo + "')";
        sql3 += " and a.READERSTATE IN('1') ";//出库状态

        DataTable table3 = context.ExecuteReader(sql3);
        //查询读卡器价值

        context.DBOpen("Select");
        string sql4 = @"SELECT TAGVALUE FROM td_m_tag WHERE TAGCODE = 'READER_PRICE '";
        DataTable table4 = context.ExecuteReader(sql4);
        if (table1 != null && table1.Rows.Count > 0)
        {
            double deposit = Convert.ToDouble(labDeposit.Text.Trim());
            int cardnum = Convert.ToInt32(table1.Rows[0]["NUM"].ToString());//库里卡总数量(手环加普通卡)
            int cardnum2 = Convert.ToInt32(table2.Rows[0]["NUM"].ToString());//库里手环卡数量
            int cardnum1 = cardnum - cardnum2;//普通卡数量
            double cardmoney = 358;//单张手环卡价值

            int readernum = Convert.ToInt32(table3.Rows[0]["NUM"].ToString());
            double readermoney = Convert.ToDouble(table4.Rows[0]["TAGVALUE"].ToString()) / 100.0;

            //计算可领卡价值额度，网点剩余卡价值
            double stockvalue = cardnum2 * cardmoney + cardnum1*10 + readernum * readermoney;//网点手环卡价值加上普通卡价值加上读卡器的价值额度

            double usablevalue = deposit - stockvalue;
            labUusablevalue.Text = usablevalue.ToString("n");
            labStockvalue.Text = stockvalue.ToString("n");
            labMaxAvailaCard.Text = ((int)(Convert.ToDouble(labUsablevalue.Text) / cardmoney)).ToString();
        }

    }
    protected void txtToCardNo_Changed(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //验证用户卡卡号
        UserCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo);
        if (context.hasError()) return;

        TD_M_CARDSURFACETDO ddoTD_M_CARDSURFACEIn = new TD_M_CARDSURFACETDO();
        ddoTD_M_CARDSURFACEIn.CARDSURFACECODE = txtToCardNo.Text.Substring(4, 4);
        TD_M_CARDSURFACETDO ddoTD_M_CARDSURFACEOut = (TD_M_CARDSURFACETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDSURFACEIn, typeof(TD_M_CARDSURFACETDO), null, "TD_M_CARDSURFACE_CODE", null);
        if (ddoTD_M_CARDSURFACEOut == null)
        {
            context.AddError("S002P01I04");
            return;
        }
        txtFaceType.Text = ddoTD_M_CARDSURFACEOut.CARDSURFACENAME;

    }

    protected void txtEndCardNo_Changed(object sender, EventArgs e)
    {
        // 检查起始卡号和终止卡号的格式（非空、14位、英数）
        long quantity = ChargeCardHelper.validateCardNoRange(context, txtStartCardNo, txtEndCardNo);
        if (context.hasError())
        {
            return;
        }
        labQuantity.Text = "" + quantity;

        // 查询总面值
        labTotalValue.Text = ChargeCardHelper.queryTotalValue(context, txtStartCardNo, txtEndCardNo).ToString("n");

        // 检查充值卡是否都有相同的面值

        bool b = ChargeCardHelper.hasSameFaceValue(context, txtStartCardNo, txtEndCardNo);
        if (!b)
        {
            return;
        }

        // 检查卡是否是可售状态（出库或激活状态并且售出员工、售出时间为空）
        int count = ChargeCardHelper.queryCountOfStockOut(context, txtStartCardNo, txtEndCardNo);
        if (count != quantity)
        {
            context.AddError("A007P04C01: 充值卡不是入库状态");
            return;
        }

        // 检查卡是否是属于当前员工的部门
        //count = ChargeCardHelper.queryCountOfAssignDepart(context, txtFromCardNo, txtToCardNo);
        //if (count != quantity)
        //{
        //    context.AddError("A007P04001: 充值卡不属于当前员工的部门");
        //    return;
        //}
        setReadOnly(txtStartCardNo, txtEndCardNo);
    }

    protected void gvResultUseCard_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResultUseCard.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    protected void gvResultChargeCard_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResultChargeCard.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    /// <summary>
    /// 文件导入事件  add by youyue 20150910
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnUpload_Click(object sender, EventArgs e)
    {
        GroupCardHelper.uploadFileValidate(context, FileUpload1);
        
        
        if (hidCardType.Value == "usecard")
        {
            if (gvResultUseCard.SelectedIndex < 0)
            {
                context.AddError("请选择一条领用单");
                return;
            }
            //验证领用员工和申请人是否是同一个人
            string orderstaffno = getUseCardDataKeys2("orderstaffno");
            if (orderstaffno != selAssignedStaff.SelectedValue)
            {
                context.AddError("申请员工和领用员工必须是同一个人");
                return;
            }
            //对卡服务费进行非空、数字检验
            UserCardHelper.validatePrice(context, txtServiceFee, "A002P02009: 卡服务费不能为空", "A002P02010: 卡服务费必须是10.2的格式");
            //对卡片单价进行非空、数字检验
            UserCardHelper.validatePrice(context, txtCardPrice, "A002P02011: 卡片单价不能为空", "A002P02010: 卡片单价必须是10.2的格式");

        }
        else
        {
            if (gvResultChargeCard.SelectedIndex < 0)
            {
                context.AddError("请选择一条领用单");
                return;
            }
            //验证领用员工申请领用单员工是否是同一个人
            string orderstaffno = getChargeCardDataKeys2("orderstaffno");
            if (orderstaffno != selStaff.SelectedValue)
            {
                context.AddError("申请员工和领用员工必须是同一个人");
                return;
            }
        }
       
        if (context.hasError()) return;
        // 首先清空临时表
        clearTempTable();
        if (Path.GetExtension(FileUpload1.FileName) == ".xls" || Path.GetExtension(FileUpload1.FileName) == ".xlsx")
        {
            LoadExcelFile();

        }
        else
        {
            context.AddError("导入文件格式必须为.xls或.xlsx");
        }
        if (!context.hasError())
        {
            if (hidCardType.Value == "usecard")
            {
                //调用用户卡出库存储过程
                context.SPOpen();
                context.AddField("P_SESSIONID").Value = Session.SessionID;
                context.AddField("P_ASSIGNEDSTAFF").Value = selAssignedStaff.SelectedValue;
                context.AddField("P_SERVICECYCLE").Value = selServiceCycle.SelectedValue;
                context.AddField("P_SERVICEFEE", "Int32").Value = Convert.ToDecimal(txtServiceFee.Text.Trim()) * 100;
                context.AddField("P_RETVALMODE").Value = selRetValMode.SelectedValue;
                context.AddField("P_SALETYPE").Value = selSaleType.SelectedValue;
                context.AddField("P_CARDPRICE", "Int32").Value = Convert.ToDecimal(txtCardPrice.Text.Trim()) * 100;
                context.AddField("p_GETCARDORDERID").Value = getUseCardDataKeys2("getcardorderid");
                bool ok = context.ExecuteSP("SP_RM_STOCKOUTBATCH");

                if (ok)
                {
                    AddMessage("D002P02001: 文件出库成功");
                    gvResultUseCard.SelectedIndex = -1;
                }
            }
            else
            {
                //调用充值卡出库存储过程
                context.SPOpen();
                context.AddField("P_SESSIONID").Value = Session.SessionID;
                context.AddField("P_GETSTAFFNO").Value = selStaff.SelectedValue;
                context.AddField("P_ASSIGNDEPARTNO").Value = selDept.SelectedValue;
                context.AddField("P_GETCARDORDERID").Value = getChargeCardDataKeys2("getcardorderid");
                context.AddField("P_VALUECODE").Value = getChargeCardDataKeys2("valuecode");
                bool ok = context.ExecuteSP("SP_RM_CC_STOCKOUTBATCH");
                if (ok)
                {
                    AddMessage("D002P02002: 文件出库成功");
                    gvResultChargeCard.SelectedIndex = -1;
                }
            }
            btnQuery_Click(sender, e);
        }
        clearTempTable();
    }

    /// <summary>
    /// 导入Excel格式的制卡文件
    /// </summary>
    public void LoadExcelFile()
    {
        string type = hidCardType.Value;//用户卡还是充值卡
        if (File.Exists("D:\\excelfile\\" + FileUpload1.FileName))
        {
            File.Delete("D:\\excelfile\\" + FileUpload1.FileName);
        }
        byte[] bytes = FileUpload1.FileBytes;
        using (FileStream f = new FileStream("D:\\excelfile\\" + FileUpload1.FileName, FileMode.OpenOrCreate, FileAccess.ReadWrite))
        {
            f.Write(bytes, 0, bytes.Length);
        }
        DataTable data = OrderHelper.getExcel_info("D:\\excelfile\\" + FileUpload1.FileName);
        if (data != null && data.Rows.Count > 0)
        {
            if (data.Columns.Count != 1)
            {
                context.AddError("字段数目根据制卡格式定义必须为1");
                return;
            }
            //验证出库数量是否大于同意领用数量
            if (hidCardType.Value == "usecard")
            {
               if (data.Rows.Count > (Convert.ToInt32(getUseCardDataKeys2("agreegetnum")) - Convert.ToInt32(getUseCardDataKeys2("alreadygetnum"))))
               {
                context.AddError("A004P01F00:文件导入出库数量不能大于领用单剩余可以领用的数量");
                return;
               } 
            }
            else
            {
                if (data.Rows.Count > (Convert.ToInt32(getChargeCardDataKeys2("agreegetnum")) - Convert.ToInt32(getChargeCardDataKeys2("alreadygetnum"))))
                {
                    context.AddError("A004P01F00:文件导入出库数量不能大于领用单剩余可以领用的数量");
                    return;
                } 
            }
            
            Hashtable ht = new Hashtable();
            for (int i = 0; i < data.Rows.Count; i++)
            {
                if (data.Rows[i][0].ToString().Trim().Length > 0)
                {
                    String[] fields = new String[1];
                    fields[0] = data.Rows[i][0].ToString();
                    dealFileContent(ht, fields, i + 1, type);
                }
            }
           
            
        }
        else
        {
            context.AddError("A004P01F01: 上传文件为空");
        }

        if (!context.hasError())
        {

            context.DBCommit();
        }
        else
        {
            context.RollBack();
        }
        try
        {
            if (FileUpload1.HasFile && File.Exists("D:\\excelfile\\" + FileUpload1.FileName))
            {
                File.Delete("D:\\excelfile\\" + FileUpload1.FileName);
            }
        }
        catch
        { }

    }
    //读取上传文件,并插入数据库临时表中
    private void dealFileContent(Hashtable ht, String[] fields, int lineCount, string type)
    {
        String cardNo = fields[0].Trim();
        if (type == "usecard")
        {
            //校验卡号
            if (string.IsNullOrEmpty(cardNo))
                context.AddError("A095470154：导入文件的第" + lineCount + "行用户卡卡号不能为空");
            else if (Validation.strLen(cardNo) != 16)
                context.AddError("A095470155：导入文件的第" + lineCount + "行用户卡卡号必须为16位");
            else if (!Validation.isNum(cardNo))
                context.AddError("A095470156：导入文件的第" + lineCount + "行用户卡卡号必须为数字");
            else if (cardNo.Trim().Substring(4, 4) != getUseCardDataKeys2("cardsurfacecode"))
            {
                context.AddError("文件中卡号"+cardNo+"卡面类型和选中的领用单不一致");
            }
        }
        else
        {
            if (string.IsNullOrEmpty(cardNo))
                context.AddError("A095470157：导入文件的第" + lineCount + "行充值卡卡号不能为空");
            else if (Validation.strLen(cardNo) != 14)
                context.AddError("A095470158：导入文件的第" + lineCount + "行充值卡卡号必须为14位");
            else if ((!ChargeCardHelper.validateCardNo(cardNo)))
                context.AddError("A095470149:导入文件的第" + lineCount + "行卡号不符合充值卡卡号格式");

        }
        if (!context.hasError())
        {
            context.DBOpen("Insert");
            context.ExecuteNonQuery(@"insert into TMP_COMMON(f0,f1) 
            values('" + cardNo + "','" + Session.SessionID + "')");
            context.DBCommit();
        }

    }

    /// <summary>
    /// 清空临时表
    /// </summary>
    private void clearTempTable()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON where f1='" + Session.SessionID + "'");
        context.DBCommit();
    }

}