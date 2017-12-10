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
using TM;
using TDO.BalanceChannel;
using Common;
using TDO.ConsumeBalance;
using PDO.SpecialDeal;
using TDO.PersonalTrade;

public partial class ASP_SpecialDeal_SD_SpeAdjustAccInput : Master.Master
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
            selAdjReason.Items.Add(new ListItem("1:隔日退货","1"));
            selAdjReason.Items.Add(new ListItem("2:交易成功,签购单未打印","2"));
            selAdjReason.Items.Add(new ListItem("3:交易不成功","3"));
            selAdjReason.Items.Add(new ListItem("4:扣款,多刷金额","4"));
            selAdjReason.Items.Add(new ListItem("5:其他", "5"));

            //显示交易信息列表
            showConGridView();

            //指定GridView DataKeyNames
            lvwConsumeInfo.DataKeyNames = new string[] {
                 "CARDNO","CALLINGNAME","CORPNAME","DEPARTNAME","TRADEDATE" ,"TRADETIME","PREMONEY","TRADEMONEY","CARDTRADENO","ID","NAME" };

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
            //单元格从索引0开始
            //显示交易日期,格式为YYYY-MM-dd
            if (e.Row.Cells[4].Text.Length == 8 )
              e.Row.Cells[4].Text = e.Row.Cells[4].Text.Substring(0, 4) + "-" + e.Row.Cells[4].Text.Substring(4, 2) + "-" + e.Row.Cells[4].Text.Substring(6, 2);

            //显示交易时间,格式为hh:mm:ss
            if (e.Row.Cells[5].Text.Length == 6 )
              e.Row.Cells[5].Text = e.Row.Cells[5].Text.Substring(0, 2) + ":" + e.Row.Cells[5].Text.Substring(2, 2) + ":" + e.Row.Cells[5].Text.Substring(4, 2);

            //显示交易前金额,交易金额,单位为元
            e.Row.Cells[6].Text = (Convert.ToDouble(e.Row.Cells[6].Text) / 100).ToString("0.00");
            e.Row.Cells[7].Text = (Convert.ToDouble(e.Row.Cells[7].Text) / 100).ToString("0.00");
        }

        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow)
        {
           //记录流水号(ID)字段隐藏
           e.Row.Cells[9].Visible = false;
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
        labCalling.Text = getDataKeys("CALLINGNAME");
        labCorp.Text = getDataKeys("CORPNAME");
        labDepart.Text = getDataKeys("DEPARTNAME");
        labComScheme.Text = getDataKeys("NAME");
        txtCardNoExt.Text = getDataKeys("CARDNO");
        labTradeDate.Text = getDataKeys("TRADEDATE").Insert(4,"-").Insert(7,"-");
        hidTradeMoneyExt.Value = getDataKeys("TRADEMONEY");
        labTradeMoney.Text = (Convert.ToDouble(getDataKeys("TRADEMONEY")) / 100).ToString("0.00"); 
        
        //获得最大可调账金额
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_B_SPEADJUSTACCTDO tdoTF_B_SPEADJUSTACCIn = new TF_B_SPEADJUSTACCTDO();
        string strSql = "select sum(nvl(tbs.REFUNDMENT,0)) from TF_B_SPEADJUSTACC tbs ";
        ArrayList list = new ArrayList();
        list.Add("tbs.ID='" + getDataKeys("ID")+"'");
        list.Add("tbs.STATECODE IN ('0','1','2')");
        strSql += DealString.ListToWhereStr(list);
        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTF_B_SPEADJUSTACCIn, null, strSql, 0);
        int hasAdjustMoney = 0;
        Int32.TryParse(data.Rows[0][0].ToString(), out hasAdjustMoney);
        string maxAdjustMoney = ((Convert.ToDouble(getDataKeys("TRADEMONEY")) - hasAdjustMoney)/100d).ToString("0.00");
        hidMaxAdjustMoney.Value = maxAdjustMoney;
        LabMaxAdjustMoney.Text = maxAdjustMoney;
    }

    public string getDataKeys(string keysname)
    {
        return lvwConsumeInfo.DataKeys[lvwConsumeInfo.SelectedIndex][keysname].ToString();
    }


    protected void selCalling_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择行业名称后处理
        if (selCalling.SelectedValue == "01")
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
                //卡号是否在IC卡电子钱包帐户表中
               if( !chkCardNoInCardAcc(strCardNoEx))
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

        //else if (Convert.ToInt32(Convert.ToDouble(txtRefundment.Text.Trim()) * 100) > 1000000)
        //    context.AddError("A009110103", txtRefundment);

        //对退款金额<=最大调账金额交验
        else if ( Convert.ToInt32(Convert.ToDouble(txtRefundment.Text.Trim()) * 100) > Convert.ToInt32(Convert.ToDouble(hidMaxAdjustMoney.Value)*100) )
            context.AddError("A009110107", txtRefundment);
            
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

        //对应退还商户佣金非空
        string strReBrokerage = txtReBrokerage.Text.Trim();
        if (strReBrokerage == "")
            context.AddError("A009110012", txtReBrokerage);
        else if (!Validation.isPrice(strReBrokerage))
            context.AddError("A009110013", txtReBrokerage);

        else if (Convert.ToInt32(Convert.ToDouble(txtReBrokerage.Text.Trim()) * 100) > 1000000)
            context.AddError("A009110014", txtReBrokerage);

        //对应退还商户佣金<=退款金额交验
        else if (Convert.ToInt32(Convert.ToDouble(txtReBrokerage.Text.Trim()) * 100) > Convert.ToInt32(Convert.ToDouble(txtRefundment.Text.Trim()) * 100))
            context.AddError("A009110015", txtReBrokerage);

        //对非空交易说明长度的校验
        string strRemark = txtRemark.Text.Trim();
        if (strRemark != "" && Validation.strLen(strRemark) > 100)
            context.AddError("A009110010", txtRemark);
    
        return context.hasError();

    }


    private bool chkCardNoInCardAcc(string cardNo)
    {
        //卡号是否在IC卡电子钱包中
        TMTableModule tm = new TMTableModule();
        DataTable data = null;

        string sql = "select CARDNO from TF_F_CARDEWALLETACC where CARDNO ='" + cardNo + "'";

        data = tm.selByPKDataTable(context, sql, 0);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            return false;
        }
        return true;
    }
    //判断该交易是否已做过特殊调账
    private string IsExistAdjust(string id)
    {
        //卡号是否在IC卡电子钱包中
        TMTableModule tm = new TMTableModule();
        DataTable data = null;
        string sql = string.Format(" select decode(statecode,'0','录入待确认','1','确认通过待调帐','2','已调帐充值','3','确认作废') from tf_b_speadjustacc t where t.id='{0}'", id);
        
        data = tm.selByPKDataTable(context, sql, 0);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            return "";
        }
        return data.Rows[0][0].ToString();
    }


    protected void btnConfirm_Click(object sender, EventArgs e)
    {
      
        //调用录入的存储过程

        SP_SD_SpeAdjustAccInputPDO pdo = new SP_SD_SpeAdjustAccInputPDO();

        pdo.cardNo = txtCardNoExt.Text.Trim();   //IC卡号

        pdo.cardUser = txtCardUser.Text.Trim();  //持卡人姓名

        pdo.userPhone = txtUserPhone.Text.Trim(); //持卡人电话

        pdo.adjAccReson = selAdjReason.SelectedValue; //调帐原因

        Double dRefundment = Convert.ToDouble(txtRefundment.Text.Trim()) * 100;
        int iRenewMoney = Convert.ToInt32(dRefundment);

        pdo.refundMoney = iRenewMoney;    //退款金额

        Double dRebrokerage = Convert.ToDouble(txtReBrokerage.Text.Trim()) * 100;
        int iRebrokerage = Convert.ToInt32(dRebrokerage);

        pdo.ReBrokerage = iRebrokerage; //应退还商户佣金

        pdo.remark = txtRemark.Text.Trim();//交易说明

        pdo.ID = getDataKeys("ID");        //记录流水号


        bool ok = TMStorePModule.Excute(context, pdo);
        //bool ok = true;
        if (ok)
        {
            AddMessage("M009110111");
        }

        ClearAdjustInfo();
    }

    protected void btnInput_Click(object sender, EventArgs e)
    {
        //调用录入信息的验证处理

        if (InputValidation()) return;

        //判断该交易是否已做过特殊调账
        string state=IsExistAdjust(getDataKeys("ID"));
        if (state!="")
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "AdjustScript", "submitConfirm('" + state + "');", true);
        }
        else
            btnConfirm_Click(sender, e);
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
        if(strTradeDate != "" && !Validation.isDate(strTradeDate,"yyyy-MM-dd"))
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
            context.AddError("A009110001");
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

        string strSql = "SELECT " +
                        "tq.CARDNO,tq.CALLINGNO,tno.CALLING CALLINGNAME,tq.CORPNO,tp.CORP CORPNAME,tq.DEPARTNO,tt.DEPART DEPARTNAME, " +
                        "tq.TRADEDATE,tq.TRADETIME,tq.PREMONEY,tq.TRADEMONEY,tq.CARDTRADENO,tq.ID,tcoms.NAME " +
                        "FROM TQ_TRADE_RIGHT tq, TD_M_CALLINGNO tno, TD_M_CORP tp, TD_M_DEPART tt,TD_TBALUNIT_COMSCHEME tbcoms,TF_TRADE_COMSCHEME tcoms ";

        ArrayList list = new ArrayList();

        //交易日期不为空的情况
        if (txtTradeDate.Text.Trim() != "")
            list.Add("tq.TRADEDATE = '" + txtTradeDate.Text.Trim().Replace("-", "") + "'");

        //卡号不为空的情况
        if (txtCardNo.Text.Trim() != "")
            list.Add("tq.CARDNO = '" + txtCardNo.Text.Trim() + "'");

        list.Add("tq.CALLINGNO = tno.CALLINGNO(+)");
        list.Add("tq.CORPNO = tp.CORPNO(+)");
        list.Add("tq.DEPARTNO = tt.DEPARTNO(+)");
        list.Add("tq.BALUNITNO = tbcoms.BALUNITNO(+)");
        list.Add("tbcoms.COMSCHEMENO = tcoms.COMSCHEMENO(+)");
        list.Add("tbcoms.USETAG='1'");

      

        //行业名称不为空的情况
        if (selCalling.SelectedValue != "")
            list.Add("tq.CALLINGNO = '" + selCalling.SelectedValue + "'");

        //单位名称不为空的情况
        if (selCorp.SelectedValue != "")
            list.Add("tq.CORPNO  = '" + selCorp.SelectedValue + "'");

        //部门名称不为空的情况
        if (selDepart.SelectedValue != "")
            list.Add("tq.DEPARTNO = '" + selDepart.SelectedValue + "'");

        strSql += DealString.ListToWhereStr(list);

        //strSql += " ORDER BY tq.CARDTRADENO ";

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTraRitIn, null, strSql, 1000);

        // getNameByCode(data);

        DataView dataView = new DataView(data);
        return dataView;

    }


    private void getNameByCode(DataTable data)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //查询行业,单位,部门信息
        TD_M_CALLINGNOTDO ddoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
        DataTable dataCalling = tmTMTableModule.selByPKDataTable(context, ddoTD_M_CALLINGNOIn, null, "", null, 0);

        TD_M_CORPTDO ddoTD_M_CORPIn = new TD_M_CORPTDO();
        DataTable dataCorp = tmTMTableModule.selByPKDataTable(context, ddoTD_M_CORPIn, null, "", null, 0);

        TD_M_DEPARTTDO ddoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
        DataTable dataDepart = tmTMTableModule.selByPKDataTable(context, ddoTD_M_DEPARTIn, null, "", null, 0);

        DataRow[] dataRows = null;

        data.Columns["CALLINGNAME"].MaxLength = 20;
        data.Columns["CORPNAME"].MaxLength = 20;
        data.Columns["DEPARTNAME"].MaxLength = 40;

        //循环读取交易记录信息
        for (int index = 0; index < data.Rows.Count; index++)
        {

            string CallingNO = data.Rows[index]["CALLINGNO"].ToString();
            string CorpNo = data.Rows[index]["CORPNO"].ToString();
            string DepartNo = data.Rows[index]["DEPARTNO"].ToString();

            //显示行业编码对应的行业名称
            if (CallingNO != null && CallingNO.Trim() != "")
            {
                dataRows = dataCalling.Select("CALLINGNO = '" + CallingNO + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["CALLINGNAME"] = dataRows[0]["CALLING"];
                }
            }

            //显示单位编码对应的单位名称
            if (CorpNo != null && CorpNo.Trim() != "")
            {
                dataRows = dataCorp.Select("CORPNO = '" + CorpNo + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["CORPNAME"] = dataRows[0]["CORP"];
                }
            }

            //显示部门编码对应的部门名称
            if (DepartNo != null && DepartNo.Trim() != "")
            {
                dataRows = dataDepart.Select("DEPARTNO = '" + DepartNo + "'");
                if (dataRows.Length == 1)
                {
                    data.Rows[index]["DEPARTNAME"] = dataRows[0]["DEPART"];
                }
            }
        }
    }



    private void ClearAdjustInfo()
    {
        labCalling.Text ="";
        labCorp.Text = "";
        labDepart.Text = "";
        labComScheme.Text = "";
        txtCardNoExt.Text = "";
        labTradeDate.Text = "";
        labTradeMoney.Text = "";

        selAdjReason.SelectedValue = "";

        txtCardUser.Text = "";
        txtUserPhone.Text = "";

        txtRefundment.Text = "";
        txtReBrokerage.Text = "";
        txtRemark.Text = "";

        lvwConsumeInfo.SelectedIndex = -1;
    }

}
