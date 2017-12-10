using System;
using System.Collections;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TDO.BalanceChannel;
using TDO.ConsumeBalance;
using TM;

public partial class ASP_CustomerAcc_CA_SpeAdjustAccInput : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化行业名称

            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
            TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), "S008100211", "TD_M_CALLINGNO", null);

            ControlDeal.SelectBoxFill(selCalling.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);

            //初始化调帐原因


            selAdjReason.Items.Add(new ListItem("---请选择---", ""));
            selAdjReason.Items.Add(new ListItem("1:隔日退货", "1"));
            selAdjReason.Items.Add(new ListItem("2:交易成功,签购单未打印", "2"));
            selAdjReason.Items.Add(new ListItem("3:交易不成功", "3"));
            selAdjReason.Items.Add(new ListItem("4:扣款,多刷金额", "4"));
            selAdjReason.Items.Add(new ListItem("5:其他", "5"));

            //显示交易信息列表
            //showConGridView();

            //指定GridView DataKeyNames
            lvwConsumeInfo.DataKeyNames = new string[] {
                 "ICCARD_NO","ACCT_TYPE_NO","ACCT_TYPE_NAME","CALLING","CORP","DEPART","TRADE_DATE" ,"TRADE_CHARGE","ORDER_NO","ID" };

        }
    }

    private void showConGridView()
    {
        //显示交易信息列表
        lvwConsumeInfo.DataSource = new DataTable();
        lvwConsumeInfo.DataBind();
        lvwConsumeInfo.SelectedIndex = -1;

    }

    public void lvwConsumeInfo_Page(Object sender, GridViewPageEventArgs e)
    {
        ClearAdjustInfo();
        lvwConsumeInfo.PageIndex = e.NewPageIndex;
        lvwConsumeInfo.DataSource = QueryResultColl();
        lvwConsumeInfo.DataBind();
    }


    protected void lvwConsumeInfo_RowDataBound(object sender, GridViewRowEventArgs e)
    {   
        //交易信息列表中显示格式设定

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //显示交易前金额,交易金额,单位为元
            e.Row.Cells[6].Text = (Convert.ToDouble(e.Row.Cells[6].Text) / 100).ToString("0.00");
        }
        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow)
        {
            //记录流水号(ID)字段隐藏
            e.Row.Cells[8].Visible = false;
        }
    }


    protected void lvwConsumeInfo_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwConsumeInfo','Select$" + e.Row.RowIndex + "')");
        }
    }

    public void lvwConsumeInfo_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择列表框一行记录后,显示
        labCalling.Text = getDataKeys("CALLING") ;
        labCorp.Text = getDataKeys("CORP");
        labDepart.Text = getDataKeys("DEPART");
        txtCardNoExt.Text = getDataKeys("ICCARD_NO");
        lblAcctType.Text = getDataKeys("ACCT_TYPE_NAME");
        labTradeDate.Text = getDataKeys("TRADE_DATE");
        hidTradeMoneyExt.Value = (Convert.ToDouble(getDataKeys("TRADE_CHARGE")) / 100).ToString();
        labTradeMoney.Text = (Convert.ToDouble(getDataKeys("TRADE_CHARGE")) / 100).ToString("0.00");
    }

    public string getDataKeys(string keysname)
    {
        return lvwConsumeInfo.DataKeys[lvwConsumeInfo.SelectedIndex][keysname].ToString();
    }


    protected void selCalling_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择行业名称后处理

        if (selCalling.SelectedValue == "")
        {
            selCorp.Items.Clear();
            selDepart.Items.Clear();
            return;
        }
        else
        {
            //初始化该行业下的单位名称
            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
            tdoTD_M_CORPIn.CALLINGNO = selCalling.SelectedValue;

            TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, "TD_M_CORPCALLUSAGE", null);
            ControlDeal.SelectBoxFill(selCorp.Items, tdoTD_M_CORPOutArr, "CORP", "CORPNO", true);

        }
    }

    protected void selCorp_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择单位名称后处理

        if (selCorp.SelectedValue == "")
        {
            selDepart.Items.Clear();
            return;
        }
        else
        {
            //初始化该单位下的部门名称
            TMTableModule tmTMTableModule = new TMTableModule();

            TD_M_DEPARTTDO tdoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
            tdoTD_M_DEPARTIn.CORPNO = selCorp.SelectedValue;

            TD_M_DEPARTTDO[] tdoTD_M_DEPARTOutArr = (TD_M_DEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null, "TD_M_DEPARTUSAGE", null);
            ControlDeal.SelectBoxFill(selDepart.Items, tdoTD_M_DEPARTOutArr, "DEPART", "DEPARTNO", true);
        }
    }

    private bool InputValidation()
    {
        //是否选择交易信息的校验

        if (labCalling.Text.Trim() == "")
        {
            context.AddError("A009110011");
            return true;
        }

        string strCardNoEx = txtCardNoExt.Text.Trim();
        if (strCardNoEx == "")
        {
            context.AddError("A009110108", txtCardNoExt);
        }
        else
        {
            if (Validation.strLen(strCardNoEx) != 16)
                context.AddError("A009100109", txtCardNoExt);
            else if (!Validation.isNum(strCardNoEx))
                context.AddError("A009100110", txtCardNoExt);
            else
            {
                //校验联机账户状态
                if (!CheckAccState(strCardNoEx))
                    context.AddError("A009110109", txtCardNoExt);
            }
        }

        //对持卡人用户非空,长度的校验

        string strCardUser = txtCardUser.Text.Trim();
        if (strCardUser == "")
            context.AddError("A009110005", txtCardUser);
        else if (Validation.strLen(strCardUser) > 50)
            context.AddError("A009110006", txtCardUser);

        //对退款金额非空,金额类型校验
        string strRefundment = txtRefundment.Text.Trim();
        if (strRefundment == "")
            context.AddError("A009110002", txtRefundment);
        else if (!Validation.isPrice(strRefundment))
            context.AddError("A009110003", txtRefundment);

        else if (Convert.ToInt32(Convert.ToDouble(txtRefundment.Text.Trim()) * 100) > 1000000)
            context.AddError("A009110103", txtRefundment);
        //对退款金额<=交易金额交验
        else if (Convert.ToInt32(Convert.ToDouble(txtRefundment.Text.Trim()) * 100) > Convert.ToInt32(Convert.ToDouble(hidTradeMoneyExt.Value) * 100))
            context.AddError("A009110107", txtRefundment);
        //调账总额不能超过交易金额
        else
        {
            int sumSpeAdjust = 0;
            string[] parm = new string[1];
            parm[0] = getDataKeys("ID");
            DataTable dt = SPHelper.callQuery("SP_CA_Query", context, "SpeAdjustAccCheckMoney", parm);
            Int32.TryParse(dt.Rows[0][0].ToString(), out sumSpeAdjust);
            if (Convert.ToInt32(Convert.ToDouble(txtRefundment.Text.Trim()) * 100) + sumSpeAdjust > Convert.ToInt32(Convert.ToDouble(hidTradeMoneyExt.Value) * 100))
            {
                context.AddError("A006019020 : 退款金额累计大于交易金额", txtRefundment);
            }
        }

        //对佣金金额非空,金额类型校验
        string strBrokerage = txtBrokerage.Text.Trim();
        if (strBrokerage == "")
            context.AddError("A006019012: 佣金金额为空", txtBrokerage);
        else if (!Validation.isPrice(strBrokerage))
            context.AddError("A006019013: 佣金金额无效", txtBrokerage);
        else if (Convert.ToInt32(Convert.ToDouble(txtBrokerage.Text.Trim()) * 100) > 1000000)
            context.AddError("A006019014: 佣金金额无效", txtBrokerage);
        //对佣金金额<=交易金额交验
        else if (Convert.ToInt32(Convert.ToDouble(txtBrokerage.Text.Trim()) * 100) > Convert.ToInt32(Convert.ToDouble(hidTradeMoneyExt.Value) * 100))
            context.AddError("A006019015: 佣金金额不能大于调帐金额", txtBrokerage);


        //对调帐原因非空的校验
        string strAdjReson = selAdjReason.SelectedValue;
        if (strAdjReson == "")
            context.AddError("A009110009", selAdjReason);

        //对持卡人电话非空,长度的校验

        string strUserPhone = txtUserPhone.Text.Trim();
        if (strUserPhone == "")
            context.AddError("A009110007", txtUserPhone);
        else if (Validation.strLen(strUserPhone) > 40)
            context.AddError("A009110008", txtUserPhone);

        //对非空交易说明长度的校验
        string strRemark = txtRemark.Text.Trim();
        if (strRemark != "" && Validation.strLen(strRemark) > 100)
            context.AddError("A009110010", txtRemark);

        return context.hasError();

    }


    private bool CheckAccState(string cardNo)
    {
        //检查联机帐户状态
        TMTableModule tm = new TMTableModule();
        DataTable data = null;

        string sql = @"SELECT ACCT_ID									
                        FROM TF_F_CUST_ACCT									
                        WHERE ICCARD_NO = '" + cardNo + @"'						
                        AND STATE = 'A'";
        data = tm.selByPKDataTable(context, sql, 0);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            return false;
        }
        return true;
    }



    protected void btnInput_Click(object sender, EventArgs e)
    {
        //调用录入信息的验证处理

        if (InputValidation()) return;

        //调用录入的存储过程
        Double dRefundment = Convert.ToDouble(txtRefundment.Text.Trim()) * 100;
        int iRenewMoney = Convert.ToInt32(dRefundment);
        int iBenewMoney = 0;
        if (txtBrokerage.Text.Trim() == "")
        {
            iBenewMoney = 0;
        }
        else
        {
            Double dBrokerage = Convert.ToDouble(txtBrokerage.Text.Trim()) * 100;
            iBenewMoney = Convert.ToInt32(dBrokerage);
        }
        context.SPOpen();
        context.AddField("P_ID").Value = getDataKeys("ID"); //记录流水号
        context.AddField("P_CARDNO").Value = txtCardNoExt.Text.Trim(); //IC卡号
        context.AddField("P_CARDUSER").Value = txtCardUser.Text.Trim(); //姓名
        context.AddField("P_USERPHONE").Value = txtUserPhone.Text.Trim(); //电话
        context.AddField("P_REFUNDMONEY").Value = iRenewMoney; //退款金额
        context.AddField("P_BROKERAGE").Value = iBenewMoney; //佣金
        context.AddField("P_ADJACCRESON").Value = selAdjReason.SelectedValue; //调帐原因
        context.AddField("P_REMARK").Value = txtRemark.Text.Trim(); //交易说明
        bool ok = context.ExecuteSP("SP_CA_SPEADJUSTACCINPUT");
        //bool ok = true;
        if (ok)
        {
            AddMessage("M006019020: 特殊调帐录入成功");
        }
        ClearAdjustInfo();
    }


    private bool QueryInputValidation()
    {
        //对非空卡号长度数字的判断
        string strCardNo = txtCardNo.Text.Trim();
        if (strCardNo != "")
        {
            if (Validation.strLen(strCardNo) != 16)
                context.AddError("A009100109", txtCardNo);
            else if (!Validation.isNum(strCardNo))
                context.AddError("A009100110", txtCardNo);
        }

        //对交易日期有效性的检测

        string strTradeDate = txtTradeDate.Text.Trim();
        if (strTradeDate != "" && !Validation.isDate(strTradeDate, "yyyy-MM-dd"))
        {
            context.AddError("A009100104", txtTradeDate);
        }

        return context.hasError();
    }


    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //输入查询条件的校验

        if (QueryInputValidation())
        {
            showConGridView();
            return;
        }

        //取得查询结果
        ICollection dataView = QueryResultColl();

        //没有查询出交易记录时,显示错误
        if (dataView.Count == 0)
        {
            showConGridView();
            context.AddError("A006019010:没有查询出当前输入条件对应的交易记录");
            return;
        }

        //显示查询结果信息
        lvwConsumeInfo.DataSource = dataView;
        lvwConsumeInfo.DataBind();

    }

    public ICollection QueryResultColl()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从消费正常清单查询表(TQ_TRADE_RIGHT)中读取数据

        TQ_TRADE_RIGHTTDO tdoTraRitIn = new TQ_TRADE_RIGHTTDO();

        string strSql = @"SELECT O.ICCARD_NO,
                           TYPE.ACCT_TYPE_NO,
                           TYPE.ACCT_TYPE_NAME,
                           CA.CALLING,
                           CORP.CORP,
                           DEPT.DEPART,
                           O.TRADE_DATE ,
                           O.TRADE_CHARGE   TRADE_CHARGE,
                           TO_CHAR(O.ORDER_NO)   ORDER_NO,
                           ID ID     
                          FROM TF_F_ACCT_ITEM_OWE O,
                               TF_TRADE_BALUNIT   B,
                               TD_M_CALLINGNO     CA,
                               TD_M_CORP          CORP,
                               TD_M_DEPART        DEPT,
                               TF_F_ACCT_TYPE_INFO TYPE
                         ";

        ArrayList list = new ArrayList();

        list.Add("O.BALUNITNO = B.BALUNITNO");
        list.Add("O.ACCT_TYPE_NO = TYPE.ACCT_TYPE_NO");
        //交易日期不为空的情况
        if (txtTradeDate.Text.Trim() != "")
            list.Add("to_char(O.TRADE_DATE,'YYYYMMDD') = '" + txtTradeDate.Text.Trim().Replace("-", "") + "'");

        //卡号不为空的情况
        if (txtCardNo.Text.Trim() != "")
            list.Add("O.ICCARD_NO = '" + txtCardNo.Text.Trim() + "'");

        list.Add("B.CALLINGNO = CA.CALLINGNO(+)");
        list.Add("B.CORPNO = CORP.CORPNO(+)");
        list.Add("B.DEPARTNO = DEPT.DEPARTNO(+)");
        
        list.Add("O.STATE != 'A'");



        //行业名称不为空的情况
        if (selCalling.SelectedValue != "")
            list.Add("CA.CALLINGNO = '" + selCalling.SelectedValue + "'");

        //单位名称不为空的情况
        if (selCorp.SelectedValue != "")
            list.Add("CORP.CORPNO  = '" + selCorp.SelectedValue + "'");

        //部门名称不为空的情况
        if (selDepart.SelectedValue != "")
            list.Add("DEPT.DEPARTNO = '" + selDepart.SelectedValue + "'");

        strSql += DealString.ListToWhereStr(list);

        //strSql += " ORDER BY tq.CARDTRADENO ";

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTraRitIn, null, strSql, 1000);
        // getNameByCode(data);
        DataView dataView = new DataView(data);
        return dataView;

    }


    private void ClearAdjustInfo()
    {
        labCalling.Text = "";
        labCorp.Text = "";
        labDepart.Text = "";
        lblAcctType.Text = "";
        txtCardNoExt.Text = "";
        labTradeDate.Text = "";
        labTradeMoney.Text = "";
        selAdjReason.SelectedValue = "";
        txtCardUser.Text = "";
        txtUserPhone.Text = "";
        txtRefundment.Text = "";
        txtRemark.Text = "";
        txtBrokerage.Text = "";
        lvwConsumeInfo.SelectedIndex = -1;
    }
}