using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using TM;
using Common;
using Master;
using TDO.UserManager;
using TDO.InvoiceTrade;
using PDO.InvoiceTrade;

public partial class ASP_InvoiceTrade_IT_PrintDept : Master.Master
{
    #region Event
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            //初始化日期
            txtBeginDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            txtEndDate.Text = DateTime.Now.ToString("yyyy-MM-dd");

            TMTableModule tmTMTableModule = new TMTableModule();

            //初始化部门
            TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO(); 
            TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
            ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
            selDept.SelectedValue = context.s_DepartID;
            InitStaffList(context.s_DepartID);
            selStaff.SelectedValue = context.s_UserID;


            //初始化收款方、纳税人识别号、开票人、开票时间
            txtPayer.Text = "个人";
            txtPayee.Text = "苏州市民卡有限公司";
            txtTaxPayerId.Text = "9132050874558352XW";
            txtStaff.Text = context.s_UserName;
            txtDate.Text = DateTime.Now.ToString("yyyy-MM-dd");

            //初始化苏信开户行
            string sqlSZBank = "select * from TD_M_SZBANK where USETAG='1'";
            DataTable dt = tm.selByPKDataTable(context, sqlSZBank, 0);
            FillDropDownListBANK(selSZBank, dt);

            //指定收款方名称
            selSZBank_SelectedIndexChanged(sender, e);

            //初始化发票项目


            tmTMTableModule = new TMTableModule();
            string sqlPROJ = "select * from TD_M_INVOICEPROJ where ISFREE=0";
            TD_M_INVOICEPROJTDO ddoTD_M_INVOICEPROJTDOIn = new TD_M_INVOICEPROJTDO();
            TD_M_INVOICEPROJTDO[] ddoTD_M_INVOICEPROJTDOOutArr = (TD_M_INVOICEPROJTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_INVOICEPROJTDOIn, typeof(TD_M_INVOICEPROJTDO), null, sqlPROJ);
            FillDropDownList(selProj, ddoTD_M_INVOICEPROJTDOOutArr, "INVOICEPROJNAME", "INVOICEPROJNAME");
            FillDropDownList(selProj2, ddoTD_M_INVOICEPROJTDOOutArr, "INVOICEPROJNAME", "INVOICEPROJNAME");
            FillDropDownList(selProj3, ddoTD_M_INVOICEPROJTDOOutArr, "INVOICEPROJNAME", "INVOICEPROJNAME");
            FillDropDownList(selProj4, ddoTD_M_INVOICEPROJTDOOutArr, "INVOICEPROJNAME", "INVOICEPROJNAME");
            FillDropDownList(selProj5, ddoTD_M_INVOICEPROJTDOOutArr, "INVOICEPROJNAME", "INVOICEPROJNAME");

            CommonHelper.SetInvoiceValues(context, txtCode, null);

            lblValidateCode.Text = InvoiceHelper.AutoGetValidateCode();

            //初始化表头
            initTable();

            lvwInvoice.DataKeyNames = new string[] { "TRADEID", "TRADETYPECODE" };
        }
    }

    //查询
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        btnClear_Click(sender, e);

        QueryCardOperRecord();
    }

    protected void Print_Click(object sender, EventArgs e)
    {
        bool ok = true;//存储过程调用成功

        txtAmount.Text = Request.Form["txtAmount"];
        txtTotal.Text = Request.Form["txtTotal"];
        txtTotal2.Text = Request.Form["txtTotal2"];

        //数据校验
        if (!InvoiceValidate())
            return;

        //附注行数不能超过4行

        string[] notes = txtNote.Text.Split(new char[] { '\n' });
        if (notes.Length > 4)
        {
            context.AddError("附注行数不能超过4行");
            return;
        }
        //首次打印时，调用开票存储过程

        if (hidPrinted.Value == "false")
        {
            string sessionid = Session.SessionID;

            WriteInfoIntoTempTable(sessionid);

            if (context.hasError())
                return;

            SP_IT_DeptBillingPDO pdo = new SP_IT_DeptBillingPDO();
            pdo.isFree = "0";//免税
            pdo.volno = txtCode.Text.Trim();
            pdo.payer = txtPayer.Text.Trim();
            pdo.billNo = txtInvoiceId.Text.Trim();
            pdo.payeeName = txtPayee.Text.Trim();
            pdo.taxNo = txtTaxPayerId.Text.Trim();
            pdo.drawer = txtStaff.Text.Trim();
            pdo.date = DateTime.ParseExact(txtDate.Text.Trim(), "yyyy-MM-dd", null);
            pdo.amount = getAmount();
            pdo.note = txtNote.Text.Trim();//.Replace(" ", "&nbsp;").Replace("\n", "<br>");

            pdo.proj1 = selProj.SelectedValue;
            if (txtAmount.Text.Trim() != "")
                pdo.fee1 = getFee(txtAmount);

            pdo.proj2 = selProj2.SelectedValue;
            if (txtAmount2.Text.Trim() != "")
                pdo.fee2 = getFee(txtAmount2);

            pdo.proj3 = selProj3.SelectedValue;
            if (txtAmount3.Text.Trim() != "")
                pdo.fee3 = getFee(txtAmount3);

            pdo.proj4 = selProj4.SelectedValue;
            if (txtAmount4.Text.Trim() != "")
                pdo.fee4 = getFee(txtAmount4);

            pdo.proj5 = selProj5.SelectedValue;
            if (txtAmount5.Text.Trim() != "")
                pdo.fee5 = getFee(txtAmount5);

            //验证码

            pdo.validatecode = lblValidateCode.Text;
            pdo.callingCode = selCalling.SelectedValue;
            pdo.callingName = selCalling.Items[selCalling.SelectedIndex].Text;

            pdo.bankName = GetSZBank("BANKNAME");
            pdo.bankAccount = GetSZBank("BANKCODE");

            pdo.SESSIONID = sessionid;

            ok = TMStorePModule.Excute(context, pdo);
            if (ok)
            {
                AddMessage("M200005001");

                //开票成功时，可以补打印，不能修改
                hidPrinted.Value = "true";
                btnPrintFaPiao.Text = "补打印";
                DisableInput();
                lvwInvoice.Enabled = false;
            }
        }

        if (ok)
        {
            //lvwInvoice.DataSource = new DataTable();
            //lvwInvoice.DataBind();

            //设置发票数据，调用打印JS
            InitInvoicePrintControl();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "printPaPiaoScript", "printFaPiao();", true);
        }
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        hidPrinted.Value = "false";

        btnPrintFaPiao.Text = "打印发票";

        lvwInvoice.Enabled = true;
        lvwInvoice.DataSource = new DataTable();
        lvwInvoice.DataBind();

        txtPayer.Enabled = true;
        txtInvoiceId.Enabled = true;
        selProj.Enabled = true;
        selProj2.Enabled = true;
        selProj3.Enabled = true;
        selProj4.Enabled = true;
        selProj5.Enabled = true;
        txtAmount.Enabled = true;
        txtAmount2.Enabled = true;
        txtAmount3.Enabled = true;
        txtAmount4.Enabled = true;
        txtAmount5.Enabled = true;
        txtNote.Enabled = true;
        txtPayCode.Enabled = true;
        txtPayCode.Text = "";
        txtPayer.Text = "个人";
        txtInvoiceId.Text = "";
        selProj.SelectedValue = "";
        selProj2.SelectedValue = "";
        selProj3.SelectedValue = "";
        selProj4.SelectedValue = "";
        selProj5.SelectedValue = "";
        txtAmount.Text = "0.00";
        txtAmount2.Text = "";
        txtAmount3.Text = "";
        txtAmount4.Text = "";
        txtAmount5.Text = "";
        txtNote.Text = "";

        txtTotal.Text = "";
        txtTotal2.Text = "";
        txtCode.Enabled = true;
        txtCode.Text = "";
        txtInvoiceId.Text = "";
        CommonHelper.SetInvoiceValues(context, txtCode, null);

        selSZBank.Enabled = true;
        lblValidateCode.Text = InvoiceHelper.AutoGetValidateCode();
    }

    protected void selTradeType_Changed(object sender, EventArgs e)
    {
        btnClear_Click(sender, e);
    }

    public void lvwInvoice_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwInvoice.PageIndex = e.NewPageIndex;
        QueryCardOperRecord();

        lvwInvoice.SelectedIndex = -1;
    }

    protected void lvwInvoice_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string v = e.Row.Cells[4].Text.Trim();
            if (v == "&nbsp;" || v == "")
                e.Row.Cells[4].Text = "";
            else
                e.Row.Cells[4].Text = (Convert.ToDouble(v) / 100).ToString("0.00");
        }
    }

    protected void selSZBank_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (selSZBank.SelectedValue != "")
        {
            string sqlSZBank = "select payeename from TD_M_SZBANK where bankname='" + selSZBank.SelectedValue + "'";
            DataTable dt = tm.selByPKDataTable(context, sqlSZBank, 0);
            if (dt.Rows.Count > 0)
            {
                txtPayee.Text = dt.Rows[0]["payeename"].ToString();
            }
        }
        else
        {
            txtPayee.Text = "";
        }


    }

    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selDept.SelectedValue);
        btnClear_Click(sender, e);
    }
    #endregion

    #region Private Method

    private void WriteInfoIntoTempTable(string sessionid)
    {
        clearTempInfo();

        context.DBOpen("Insert");

        
        int rowindex = 0;

        foreach (GridViewRow gvr in lvwInvoice.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                string f1 = gvr.Cells[1].Text == "&nbsp;" ? "" : gvr.Cells[1].Text;  //流水号
                string f2 = lvwInvoice.DataKeys[rowindex]["TRADETYPECODE"].ToString();  //业务类型编码
                int f3 = gvr.Cells[4].Text == "&nbsp;" ? 0 : (int)(Convert.ToDecimal(gvr.Cells[4].Text) * 100);  //交易金额
                string f4 = txtCode.Text.Trim();  //发票代码
                string f5 = txtInvoiceId.Text.Trim();  //发票号码

                context.ExecuteNonQuery("insert into TMP_TF_B_DEPTINVOICE(TRADEID, SESSIONID, TRADETYPECODE," +
                               "CURRENTMONEY, VOLUMENO,INVOICENO) values ('"
                                    + f1 + "','"
                                    + sessionid + "','"
                                    + f2 + "',"
                                    + f3 + ",'"
                                    + f4 + "','"
                                    + f5 + "')");
            }

            rowindex++;
        }

        if (!context.hasError())
        {
            context.DBCommit();
        }
        else
        {
            context.RollBack();
        }
    }

    public void clearTempInfo()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_TF_B_DEPTINVOICE");
        context.DBCommit();
    }

    //苏信开户行
    private void FillDropDownListBANK(DropDownList control, DataTable data)
    {
        control.Items.Add(new ListItem("---请选择---", ""));
        int i = 1;
        int weizhi = 0;
        foreach (DataRow dr in data.Rows)
        {
            control.Items.Add(new ListItem(dr["BANKCODE"].ToString() + ":" + dr["BANKNAME"].ToString(), dr["BANKNAME"].ToString()));
            if (dr["ISDEFAULT"].ToString() == "1")
            {
                weizhi = i;
            }
            i++;
        }
        control.SelectedIndex = weizhi;

    }

    private void FillDropDownList(DropDownList control, DDOBase[] data, string label, string value)
    {
        control.Items.Add(new ListItem("---请选择---", ""));
        foreach (DDOBase ddoDDOBase in data)
        {
            control.Items.Add(new ListItem(ddoDDOBase.GetString(label), ddoDDOBase.GetString(value)));
        }
    }

    //数据校验
    public bool InvoiceValidate()
    {
        bool b = true;
        //付款方非空

        if (txtPayer.Text.Trim() == "")
        {
            context.AddError("A200004021", txtPayer);
            b = false;
        }

        //发票号校验


        InvoiceValidator iv = new InvoiceValidator(context);
        if (!iv.validateId(txtInvoiceId))
            b = false;

        //发票项目校验
        WebControl[] projs = new WebControl[5] { selProj, selProj2, selProj3, selProj4, selProj5 };
        WebControl[] fees = new WebControl[5] { txtAmount, txtAmount2, txtAmount3, txtAmount4, txtAmount5 };
        if (!iv.validateItems(projs, fees))
            b = false;

        //开票人非空
        if (txtStaff.Text.Trim() == "")
        {
            context.AddError("A200004024", txtStaff);
            b = false;
        }

        //开票日期非空


        string strDate = txtDate.Text.Trim();
        if (strDate == "")
        {
            context.AddError("A200004025", txtDate);
            b = false;
        }
        else if (!Validation.isDate(strDate))
        {
            context.AddError("A200004026", txtDate);
            b = false;
        }
        return b;
    }
    //SQL条件语句
    private ArrayList getCondition()
    {
        ArrayList list = new ArrayList();

        getConditionFromTime(list);
        getConditionFromId(list);
        getConditionFromDepartOrStaff(list);

        return list;
    }

    private ArrayList getConditionFromId(ArrayList list)
    {
        string strBeginNo = txtBeginCardNo.Text.Trim();
        string strEndNo = txtEndCardNo.Text.Trim();

        if (selTradeType.SelectedValue == "1" || selTradeType.SelectedValue == "3" || selTradeType.SelectedValue == "4" || selTradeType.SelectedValue == "5" || selTradeType.SelectedValue == "6" || selTradeType.SelectedValue == "7")     //普通充值  增加充值类型6：手Q充值 7：充值补登
        {
            if (strBeginNo != "" && strEndNo != "")
            {
                list.Add("A.CARDNO between '" + strBeginNo + "' and '" + strEndNo + "'");
            }
            else if (strBeginNo != "")
            {
                list.Add("A.CARDNO= '" + strBeginNo + "'");
            }
            else if (strEndNo != "")
            {
                list.Add("A.CARDNO= '" + strEndNo + "'");
            }
        }
        else if (selTradeType.SelectedValue == "2")  //充值卡售出
        {
            if (strBeginNo != "" && strEndNo != "")
            {
                list.Add("A.STARTCARDNO >= '" + strBeginNo + "' And A.ENDCARDNO <= '" + strEndNo + "'");
            }
            else if (strBeginNo != "")
            {
                list.Add("A.STARTCARDNO >= '" + strBeginNo + "'");
            }
            else if (strEndNo != "")
            {
                list.Add("A.ENDCARDNO <= '" + strEndNo + "'");
            }
        }

        return list;
    }

    private ArrayList getConditionFromTime(ArrayList list)
    {
        string strBeginDate = txtBeginDate.Text.Trim();
        string strEndDate = txtEndDate.Text.Trim();

        if (selTradeType.SelectedValue == "4" || selTradeType.SelectedValue == "6" || selTradeType.SelectedValue == "7")//增加充值类型6：手Q充值 7：充值补登
        {
            if (strBeginDate != "" && strEndDate != "")
            {
                DateTime endDate = DateTime.ParseExact(strEndDate, "yyyy-MM-dd", null);
                endDate = endDate.AddDays(1);
                list.Add("to_date(A.TRADEDATE,'yyyy-mm-dd') >= to_date('" + strBeginDate + "','yyyy-mm-dd') and to_date(A.TRADEDATE,'yyyy-mm-dd') < to_date('" + endDate + "','yyyy-mm-dd hh24:mi:ss')");
            }
            else if (strBeginDate != "")
            {
                list.Add("to_date(A.TRADEDATE,'yyyy-mm-dd')>= to_date('" + strBeginDate + "','yyyy-mm-dd')");
            }
            else if (strEndDate != "")
            {
                DateTime endDate = DateTime.ParseExact(strEndDate, "yyyy-MM-dd", null);
                endDate = endDate.AddDays(1);
                list.Add("to_date(A.TRADEDATE,'yyyy-mm-dd')<to_date('" + endDate + "','yyyy-mm-dd hh24:mi:ss')");
            }
        }
        else
        {
            if (strBeginDate != "" && strEndDate != "")
            {
                DateTime endDate = DateTime.ParseExact(strEndDate, "yyyy-MM-dd", null);
                endDate = endDate.AddDays(1);
                list.Add("A.OPERATETIME >= to_date('" + strBeginDate + "','yyyy-mm-dd') and A.OPERATETIME < to_date('" + endDate + "','yyyy-mm-dd hh24:mi:ss')");
            }
            else if (strBeginDate != "")
            {
                list.Add("A.OPERATETIME>= to_date('" + strBeginDate + "','yyyy-mm-dd')");
            }
            else if (strEndDate != "")
            {
                DateTime endDate = DateTime.ParseExact(strEndDate, "yyyy-MM-dd", null);
                endDate = endDate.AddDays(1);
                list.Add("A.OPERATETIME<to_date('" + endDate + "','yyyy-mm-dd hh24:mi:ss')");
            }
        }

        return list;
    }

    private ArrayList getConditionFromDepartOrStaff(ArrayList list)
    {
        string departno = selDept.SelectedValue;
        string staffno = selStaff.SelectedValue;

        if (selTradeType.SelectedValue == "1" || selTradeType.SelectedValue == "3" || selTradeType.SelectedValue == "5")
        {
            if (departno != "")
            {
                list.Add("A.OPERATEDEPARTID = '" + departno + "'");
            }

            if (staffno != "")
            {
                list.Add("A.OPERATESTAFFNO = '" + staffno + "'");
            }

        }
        else if (selTradeType.SelectedValue == "2")
        {
            if (departno != "")
            {
                list.Add("D.DEPARTNO = '" + departno + "'");
            }

            if (staffno != "")
            {
                list.Add("A.STAFFNO = '" + staffno + "'");
            }
        }

        return list;
    }

    private void QueryCardOperRecord()
    {
        if (!InputValidate())
            return;

        string strSql = "";

        TMTableModule tmTMTableModule = new TMTableModule();

        if (selTradeType.SelectedValue == "1")     //普通充值
        {
            strSql += "SELECT A.TRADEID, A.CARDNO, A.TRADETYPECODE, C.TRADETYPE, A.CURRENTMONEY,";
            strSql += " A.OPERATESTAFFNO, A.OPERATETIME, B.VOLUMENO, B.INVOICENO";
            strSql += " From TF_B_TRADE A LEFT JOIN TF_B_DEPTINVOICE B ON A.TRADEID = B.TRADEID";
            strSql += " LEFT JOIN TD_M_TRADETYPE C ON A.TRADETYPECODE = C.TRADETYPECODE ";
            strSql += " WHERE A.TRADETYPECODE='02' AND A.CANCELTAG = '0'";
        }
        else if (selTradeType.SelectedValue == "2")  //充值卡售出
        {
            strSql += "SELECT A.TRADEID, DECODE(A.STARTCARDNO, A.ENDCARDNO, A.STARTCARDNO, A.STARTCARDNO || '-' || A.ENDCARDNO) CARDNO, A.TRADETYPECODE, C.TRADETYPE,";
            strSql += " A.MONEY CURRENTMONEY, A.STAFFNO OPERATESTAFFNO, A.OPERATETIME OPERATETIME,";
            strSql += " B.VOLUMENO, B.INVOICENO";
            strSql += " From TF_XFC_SELL A LEFT JOIN TF_B_DEPTINVOICE B ON A.TRADEID = B.TRADEID";
            strSql += " LEFT JOIN TD_M_TRADETYPE C ON A.TRADETYPECODE = C.TRADETYPECODE ";
            strSql += " LEFT JOIN TD_M_INSIDESTAFF D ON A.STAFFNO = D.STAFFNO ";
            strSql += " WHERE A.TRADETYPECODE='80' AND A.CANCELTAG = '0'";
        }
        else if (selTradeType.SelectedValue == "3") //礼金卡售出
        {
            strSql += "SELECT A.TRADEID, A.CARDNO, A.TRADETYPECODE, C.TRADETYPE, D.SUPPLYMONEY + 1000 CURRENTMONEY,";
            strSql += " A.OPERATESTAFFNO, A.OPERATETIME, B.VOLUMENO, B.INVOICENO";
            strSql += " From TF_B_TRADE A LEFT JOIN TF_B_TRADEFEE D ON A.TRADEID = D.TRADEID ";
            strSql += " LEFT JOIN TF_B_DEPTINVOICE B ON A.TRADEID = B.TRADEID ";
            strSql += " LEFT JOIN TD_M_TRADETYPE C ON A.TRADETYPECODE = C.TRADETYPECODE ";
            strSql += " WHERE A.TRADETYPECODE IN ('50','51') AND A.CANCELTAG = '0'";
        }
        else if (selTradeType.SelectedValue == "4")  //代理充值
        {
            strSql += "select A.ID TRADEID,A.CARDNO,A.TRADETYPECODE,C.TRADETYPE, A.TRADEMONEY CURRENTMONEY, A.STAFFNO OPERATESTAFFNO ,";
            strSql += " A.TRADEDATE OPERATETIME,B.VOLUMENO, B.INVOICENO";
            strSql += " From TQ_SUPPLY_RIGHT A LEFT JOIN TF_B_DEPTINVOICE B ON A.ID = B.TRADEID";
            strSql += " LEFT JOIN TD_M_TRADETYPE C ON A.TRADETYPECODE = C.TRADETYPECODE ";
            strSql += " WHERE A.TRADETYPECODE IN ('02','1S') AND (A.RSRVCHAR in ('01','02') or A.RSRVCHAR is null) AND A.BALUNITNO IS NOT NULL";
        }
        else if (selTradeType.SelectedValue == "5")  //省卡充值
        {
            strSql += "SELECT A.TRADEID, A.CARDNO, A.TRADETYPECODE, C.TRADETYPE, A.CURRENTMONEY,";
            strSql += " A.OPERATESTAFFNO, A.OPERATETIME, B.VOLUMENO, B.INVOICENO";
            strSql += " From TF_B_TRADE_SK A LEFT JOIN TF_B_DEPTINVOICE B ON A.TRADEID = B.TRADEID";
            strSql += " LEFT JOIN TD_M_TRADETYPE C ON A.TRADETYPECODE = C.TRADETYPECODE ";
            strSql += " WHERE A.TRADETYPECODE='02' AND A.CANCELTAG = '0'";
        }
        else if (selTradeType.SelectedValue == "6")  //手Q充值
        {
            strSql += "select A.ID TRADEID,A.CARDNO,A.TRADETYPECODE,C.TRADETYPE, A.TRADEMONEY CURRENTMONEY, A.STAFFNO OPERATESTAFFNO ,";
            strSql += " A.TRADEDATE OPERATETIME,B.VOLUMENO, B.INVOICENO";
            strSql += " From TQ_SUPPLY_RIGHT A LEFT JOIN TF_B_DEPTINVOICE B ON A.ID = B.TRADEID";
            strSql += " LEFT JOIN TD_M_TRADETYPE C ON A.TRADETYPECODE = C.TRADETYPECODE ";
            strSql += " WHERE A.balunitno='36000001' AND  A.rsrvchar = '01'";
        }
        else if (selTradeType.SelectedValue == "7")  //充值补登
        {
            strSql += "select A.ID TRADEID,A.CARDNO,A.TRADETYPECODE,C.TRADETYPE, A.TRADEMONEY CURRENTMONEY, A.STAFFNO OPERATESTAFFNO ,";
            strSql += " A.TRADEDATE OPERATETIME,B.VOLUMENO, B.INVOICENO";
            strSql += " From TQ_SUPPLY_RIGHT A LEFT JOIN TF_B_DEPTINVOICE B ON A.ID = B.TRADEID";
            strSql += " LEFT JOIN TD_M_TRADETYPE C ON A.TRADETYPECODE = C.TRADETYPECODE ";
            strSql += " WHERE A.TRADETYPECODE='2A'";
        }

        ArrayList list = getCondition();

        string where = ListToAndStr(list);
        strSql = strSql + where + " Order By OPERATETIME";

        DataTable data = tmTMTableModule.selByPKDataTable(context, strSql, 0);

        DataView dataView = new DataView(data);

        lvwInvoice.DataSource = dataView;
        lvwInvoice.DataBind();

        lvwInvoice.SelectedIndex = -1;
    }

    public void initTable()
    {
        lvwInvoice.DataSource = new DataTable();
        lvwInvoice.DataBind();
        lvwInvoice.SelectedIndex = -1;
        lvwInvoice.DataKeyNames = new string[] { "INVOICENO", "PROJ1", "FEE1", "PROJ2", "FEE2", "PROJ3", "FEE3", "PROJ4", "FEE4", "PROJ5", "FEE5", "AMOUNT", "PAYER", "DRAWER", "DRAWDATE", "TAXNO", "NOTE", "STATE", "ALLOTSTAFF", "ALLOTDEPT", "ALLOTDATE", "VOIDSTAFF", "VOIDDATE", "RSRV3" };
    }

    private bool InputValidate()
    {
        validateIdRangeAllowNull(txtBeginCardNo, txtEndCardNo);

        DateTime? dateEff = null, dateExp = null;

        string strBeginDate = txtBeginDate.Text.Trim();
        string strEndDate = txtEndDate.Text.Trim();
        //对起始日期非空, 格式的校验
        if (strBeginDate == "")
        {
            context.AddError("A002P01013", txtBeginDate);
        }
        else if (!Validation.isDate(strBeginDate, "yyyy-MM-dd"))
        {
            context.AddError("A200007030", txtBeginDate);
        }
        else
        {
            dateEff = DateTime.ParseExact(strBeginDate, "yyyy-MM-dd", null);
        }


        //对终止日期非空, 格式的校验
        if (strEndDate == "")
        {
            context.AddError("A002P01015", txtEndDate);
        }

        else if (!Validation.isDate(strEndDate, "yyyy-MM-dd"))
        {
            context.AddError("A200007031", txtEndDate);
        }
        else
        {
            dateExp = DateTime.ParseExact(strEndDate, "yyyy-MM-dd", null);
        }

        //起始日期不能大于终止日期
        if (dateEff != null && dateExp != null && dateEff.Value.CompareTo(dateExp.Value) > 0)
            context.AddError("A200007032");

        if (context.hasError())
            return false;
        else
            return true;

    }


    public bool validateIdRangeAllowNull(TextBox tbBeginCard, TextBox tbEndCard)
    {
        bool b = true;

        string strBeginNo = tbBeginCard.Text.Trim();
        string strEndNo = tbEndCard.Text.Trim();

        //起始卡号
        if (strBeginNo != "")
        {
            if (!Validation.isChar(strBeginNo) && !Validation.isCharNum(strBeginNo))
            {
                context.AddError("A001004116", tbBeginCard);//起始卡号不是字母或数字

                b = false;
            }
            //else if (Validation.strLen(strBeginNo) != 16)
            //{
            //    context.AddError("A001004114", tbBeginCard);//起始卡号长度不等于16位

            //    b = false;
            //}
        }

        //终止卡号


        if (strEndNo != "")
        {
            if (!Validation.isChar(strEndNo) && !Validation.isCharNum(strEndNo))
            {
                context.AddError("A001004116", tbEndCard);//终止卡号不是字母或数字

                b = false;
            }
            //else if (Validation.strLen(strEndNo) != 16)
            //{
            //    context.AddError("A001004114", tbEndCard);//终止卡号长度不等于16位

            //    b = false;
            //}
        }

        //终止卡号不小于起始卡号


        if (b && strBeginNo != "" && strEndNo != "")
        {
            //long lBeginNo = long.Parse(strBeginNo);
            //long lEndNo = long.Parse(strEndNo);
            if (strBeginNo.CompareTo(strEndNo) > 0)
            {
                context.AddError("A094780011");
                b = false;
            }
        }

        return b;
    }

    private String ListToAndStr(ArrayList list)
    {
        String str = " ";
        for (int i = 0; i < list.Count; i++)
        {
            str += " And (" + list[i].ToString() + ")";
        }
        return str;
    }

    //发票总金额，单位分
    private Decimal getAmount()
    {
        Decimal r = Convert.ToDecimal(getFee(txtAmount));
        return r;
    }

    //单个项目金额，单位分
    private int getFee(TextBox tb)
    {
        string s = tb.Text.Trim();
        if (s == "")
            return 0;

        Decimal d = Convert.ToDecimal(s) * 100;
        return (int)d;
    }


    //转为货币格式
    private string getInvoiceFee(string str)
    {
        if (str == "")
            return "";

        double d = Convert.ToDouble(str);
        return d.ToString("0.00");
    }

    //设置发票内容不可编辑
    private void DisableInput()
    {
        txtPayer.Enabled = false;
        txtCode.Enabled = false;
        txtInvoiceId.Enabled = false;
        selProj.Enabled = false;
        selProj2.Enabled = false;
        selProj3.Enabled = false;
        selProj4.Enabled = false;
        selProj5.Enabled = false;
        txtAmount.Enabled = false;
        txtAmount2.Enabled = false;
        txtAmount3.Enabled = false;
        txtAmount4.Enabled = false;
        txtAmount5.Enabled = false;
        txtNote.Enabled = false;
        selSZBank.Enabled = false;
        txtPayCode.Enabled = false;
    }

    //设置发票数据
    private void InitInvoicePrintControl()
    {
        DateTime now = DateTime.Now;
        ptnFaPiao.Year = now.ToString("yyyy");
        ptnFaPiao.Month = now.ToString("MM");
        ptnFaPiao.Day = now.ToString("dd");
        ptnFaPiao.FuKuanFang = txtPayer.Text.Trim();
        ptnFaPiao.ShouKuanFang = txtPayee.Text.Trim();
        ptnFaPiao.NaShuiRen = txtTaxPayerId.Text.Trim();
        ptnFaPiao.PiaoHao = txtInvoiceId.Text.Trim();
        ptnFaPiao.FuKuanFangCode = txtPayCode.Text.Trim();
        ptnFaPiao.JuanHao = txtCode.Text.Trim();
        Decimal i = getAmount();
        ptnFaPiao.JinE = (i / 100).ToString("0.00");

        ptnFaPiao.JinEChina = ConvertNumChn.ConvertSum(ptnFaPiao.JinE);

        ptnFaPiao.KaiPiaoRen = context.s_UserName;

        ArrayList projs = new ArrayList();
        //string[] proj1 = new string[2] { selProj.SelectedValue, getInvoiceFee(txtAmount.Text.Trim()) };
        //string[] proj2 = new string[2] { selProj2.SelectedValue, getInvoiceFee(txtAmount2.Text.Trim()) };
        //string[] proj3 = new string[2] { selProj3.SelectedValue, getInvoiceFee(txtAmount3.Text.Trim()) };
        //string[] proj4 = new string[2] { selProj4.SelectedValue, getInvoiceFee(txtAmount4.Text.Trim()) };
        //string[] proj5 = new string[2] { selProj5.SelectedValue, getInvoiceFee(txtAmount5.Text.Trim()) };

        string[] proj1 = new string[4] { selProj.SelectedValue, getInvoiceFee(txtAmount.Text.Trim()), "1", getInvoiceFee(txtAmount.Text.Trim()) };
        string[] proj2 = new string[4] { selProj2.SelectedValue, getInvoiceFee(txtAmount2.Text.Trim()), "1", getInvoiceFee(txtAmount2.Text.Trim()) };
        string[] proj3 = new string[4] { selProj3.SelectedValue, getInvoiceFee(txtAmount3.Text.Trim()), "1", getInvoiceFee(txtAmount3.Text.Trim()) };
        string[] proj4 = new string[4] { selProj4.SelectedValue, getInvoiceFee(txtAmount4.Text.Trim()), "1", getInvoiceFee(txtAmount4.Text.Trim()) };
        string[] proj5 = new string[4] { selProj5.SelectedValue, getInvoiceFee(txtAmount5.Text.Trim()), "1", getInvoiceFee(txtAmount5.Text.Trim()) };
        projs.Add(proj1);
        projs.Add(proj2);
        projs.Add(proj3);
        projs.Add(proj4);
        projs.Add(proj5);
        ptnFaPiao.ProjectList = projs;
        ptnFaPiao.ValidateCode = lblValidateCode.Text;
        ptnFaPiao.CallingName = selCalling.Items[selCalling.SelectedIndex].Text;
        ArrayList note = new ArrayList();
        string strNote = txtNote.Text.Trim();
        string[] notes = strNote.Split(new char[] { '\n' });

        for (int k = 0; k < notes.Length; k++)
        {
            note.Add(notes[k]);
        }
        ptnFaPiao.RemarkList = note;
        ptnFaPiao.BankName = GetSZBank("BANKNAME");
        ptnFaPiao.BankAccount = GetSZBank("BANKCODE");
    }

    //获取苏信开户行信息
    private string GetSZBank(string str)
    {
        string[] szbanks = selSZBank.Items[selSZBank.SelectedIndex].Text.Split(new char[] { ':' }); ;
        //string[] szbanks = selSZBank.Text.Split(new char[] { ':' });
        string bankname = "";
        string bankcode = "";
        if (szbanks.Length > 1)
        {
            bankname = szbanks[1];
            bankcode = szbanks[0];
        }
        if (str == "BANKNAME")
        {
            return bankname;
        }
        else if (str == "BANKCODE")
        {
            return bankcode;
        }
        else
        {
            return "";
        }
    }

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
    #endregion

    #region Private Data
    #endregion
}