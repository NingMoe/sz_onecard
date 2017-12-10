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
using TDO.SupplyBalance;
using PDO.SpecialDeal;

public partial class ASP_SpecialDeal_SD_SupplyErrorInfoRecycle : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {

        if(!Page.IsPostBack)
        {

            //创建充值异常回收的临时表
           // createTempTable();

            //显示充值异常信息空列表表头
            showNonDataGridView(); 


            //初始化行业名称
            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
            TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), "S008100211", "TD_M_CALLINGNO", null);

            ControlDeal.SelectBoxFill(selCalling.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);

            //初始化错误原因

            selErrorReasonCode.Items.Add(new ListItem("---请选择---", ""));
            selErrorReasonCode.Items.Add(new ListItem("6:过期数据", "6"));
            selErrorReasonCode.Items.Add(new ListItem("7:其他数据", "7"));
            selErrorReasonCode.Items.Add(new ListItem("8:PSAM卡非法", "8"));
      
            selErrorReasonCode.Items.Add(new ListItem("B:缺少结算单元编码", "B"));
            selErrorReasonCode.Items.Add(new ListItem("C:缺少卡号", "C"));
       
            //清空临时表数据
            clearTempTable();


        }
    }


    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        //分页事件
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }


    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //单元格从索引0开始

            //显示交易日期,格式为YYYY-MM-dd
            if (e.Row.Cells[5].Text.Length == 8)
              e.Row.Cells[5].Text = e.Row.Cells[5].Text.Substring(0, 4) + "-" + e.Row.Cells[5].Text.Substring(4, 2) + "-" + e.Row.Cells[5].Text.Substring(6, 2);

            //显示交易时间,格式为hh:mm:ss
            if (e.Row.Cells[6].Text.Length == 6)
              e.Row.Cells[6].Text = e.Row.Cells[6].Text.Substring(0, 2) + ":" + e.Row.Cells[6].Text.Substring(2, 2) + ":" + e.Row.Cells[6].Text.Substring(4, 2);

            //显示交易前金额,交易金额,单位为元
            e.Row.Cells[7].Text = (Convert.ToDouble(e.Row.Cells[7].Text) / 100).ToString("0.00");
            e.Row.Cells[8].Text = (Convert.ToDouble(e.Row.Cells[8].Text) / 100).ToString("0.00");

        }

        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[15].Visible = false;
        }

    }




    private void showNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }

    protected void CheckAll(object sender, EventArgs e)
    {
        //全选充值异常信息记录
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            if (!gvr.Cells[0].Enabled) continue;
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
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


    private bool QueryValidation()
    {
        //对处理日期非空,格式的判断
        string strDealDate = txtDealDate.Text.Trim();
        if (strDealDate == "")
            context.AddError("A009103107", txtDealDate);
        else if (!Validation.isDate(strDealDate, "yyyy-MM"))
            context.AddError("A009103108", txtDealDate);

        //对非空交易起始和终止日期有效性的检测
        string strBeginDate = txtStartDate.Text.Trim();
        string strEndDate = txtEndDate.Text.Trim();

        DateTime? beginTime = null;
        DateTime? endTime = null;

        //当起始日期不为空的情况
        if (strBeginDate != "")
        {
            if (!Validation.isDate(strBeginDate, "yyyy-MM-dd"))
                context.AddError("A009103024", txtStartDate);
            else
                beginTime = DateTime.ParseExact(strBeginDate, "yyyy-MM-dd", null);

        }

        //当终止期不为空的情况
        if (strEndDate != "")
        {
            if (!Validation.isDate(strEndDate, "yyyy-MM-dd"))
                context.AddError("A009103025", txtEndDate);
            else
                endTime = DateTime.ParseExact(strEndDate, "yyyy-MM-dd", null);

        }

        //起始日期和终止日期都是合法日期格式时
        if (beginTime != null && endTime != null)
        {
            if (beginTime.Value.CompareTo(endTime.Value) > 0)
            {
                context.AddError("A009100106", txtStartDate);
            }

        }   

        //对非空PSAM编号长度英数字的判断
        string strPsamNo = txtPasmNo.Text.Trim();
        if (strPsamNo != "")
        {
            if (Validation.strLen(strPsamNo) != 12)
                context.AddError("A009100001", txtPasmNo);
            else if (!Validation.isCharNum(strPsamNo))
                context.AddError("A009100002", txtPasmNo);
        }

        //对非空POS编号长度数字类型的校验
        string strPosNo = txtPosNo.Text.Trim();
        if (strPosNo != "")
        {
            if (Validation.strLen(strPosNo) > 6)
                context.AddError("A009100003", txtPosNo);
            else if (!Validation.isNum(strPosNo))
                context.AddError("A009100004", txtPosNo);
        }

        //对非空卡号长度数字的判断
        string strCardNo = txtCardNo.Text.Trim();
        if (strCardNo != "")
        {
            if (Validation.strLen(strCardNo) != 16)
                context.AddError("A009100109", txtCardNo);
            else if (!Validation.isNum(strCardNo))
                context.AddError("A009100110", txtCardNo);
        }

       
        return context.hasError();
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //调用查询输入的判处理
        if (QueryValidation())
        {
            //置空异常记录信息列表
            showNonDataGridView();
            return;
        }

        hidDealDate.Value = txtDealDate.Text.Trim();

        //取得查询结果
        ICollection dataView = QueryResultColl();

        //没有查询出交易记录时,显示错误
        if (dataView.Count == 0)
        {
            context.AddError("A009105101");
            //置空异常记录信息列表
            showNonDataGridView();
            return;
        }

        //显示查询结果信息
        gvResult.DataSource = dataView;
        gvResult.DataBind();

    }


    public ICollection QueryResultColl()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从非实时充值异常清单表TF_SUPPLY_ERROR_01(…12)中读取数据
        TF_SUPPLY_ERROR_01TDO tdoSupplyIn = new TF_SUPPLY_ERROR_01TDO();


        //查询处理日期对应月份表异常记录

        string strSql = "SELECT " +
                        "tf.CARDNO,tf.CALLINGNO,tno.CALLING CALLINGNAME,tf.CORPNO,tp.CORP CORPNAME,tf.DEPARTNO,tt.DEPART DEPARTNAME, " +
                        "tf.TRADEDATE,tf.TRADETIME,tf.PREMONEY,tf.TRADEMONEY,tf.ASN,tf.CARDTRADENO,tf.POSNO,tf.SAMNO,tf.TAC,   " +
                        "(case when ( tf.ERRORREASONCODE = 'B' ) then '缺少结算单元编码' " +
                        "when ( tf.ERRORREASONCODE = 'C' ) then '缺少卡号' " +
                        "when ( tf.ERRORREASONCODE = '6' ) then '过期数据' " +
                        "when ( tf.ERRORREASONCODE = '7' ) then '其他数据' " +
                        "when ( tf.ERRORREASONCODE = '8' ) then 'PSAM卡非法' end ) ERRORREASON, ID " +
                        "FROM TF_SUPPLY_ERROR_" + hidDealDate.Value.Substring(5, 2) + " tf," +
                        " TD_M_CALLINGNO tno, TD_M_CORP tp, TD_M_DEPART tt  ";


        ArrayList list = new ArrayList();

        //当交易起始日期不为空的情况

        if (txtStartDate.Text.Trim() != "")
            list.Add("tf.TRADEDATE >='" + txtStartDate.Text.Trim().Replace("-", "") + "'");

        //当交易终止日期不为空的情况

        if (txtEndDate.Text.Trim() != "")
            list.Add("tf.TRADEDATE <='" + txtEndDate.Text.Trim().Replace("-", "") + "'");

        //卡号不为空的情况
        if (txtCardNo.Text.Trim() != "")
            list.Add("tf.CARDNO = '" + txtCardNo.Text.Trim() + "'");



        list.Add("tf.CALLINGNO = tno.CALLINGNO(+)");
        list.Add("tf.CORPNO = tp.CORPNO(+)");
        list.Add("tf.DEPARTNO = tt.DEPARTNO(+)");

       

        //行业名称不为空的情况
        if (selCalling.SelectedValue != "")
            list.Add("tf.CALLINGNO = '" + selCalling.SelectedValue + "'");

        //单位名称不为空的情况
        if (selCorp.SelectedValue != "")
            list.Add("tf.CORPNO  = '" + selCorp.SelectedValue + "'");

        //部门名称不为空的情况
        if (selDepart.SelectedValue != "")
            list.Add("tf.DEPARTNO = '" + selDepart.SelectedValue + "'");

        //PSAM编号不为空的情况
        if (txtPasmNo.Text.Trim() != "")
            list.Add("tf.SAMNO = '" + txtPasmNo.Text.Trim() + "'");


        //错误原因编码不为空的情况
        if (selErrorReasonCode.SelectedValue != "")
            list.Add("tf.ERRORREASONCODE = '" + selErrorReasonCode.SelectedValue + "'");

        //POS编号不为空的情况
        if (txtPosNo.Text.Trim() != "")
            list.Add("tf.POSNO like '" + txtPosNo.Text.Trim() + "%'");

        //查询为处理交易记录

        list.Add("tf.DEALSTATECODE = '0'");

        strSql += DealString.ListToWhereStr(list);

        // strSql += " ORDER BY tf.TRADEDATE ";

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoSupplyIn, null, strSql, 1000);

        //getNameByCode(data);

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

    private bool RecordIntoTmp()
    {
        //回收记录入临时表
        context.DBOpen("Insert");

        int count = 0;
        int seq = 0;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                context.ExecuteNonQuery("insert into TMP_SUPPLY_ERROR_IMP values("
                    + (seq++) + ",'" + gvr.Cells[15].Text + "', '" + Session.SessionID + "')");
            }
        }

        context.DBCommit();

        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("A009105001");
            return false;
        }

        //查询出异常清单月份表,插入回收充值异常记录临时表中
        context.DBOpen("Insert");

        string insertSql = "INSERT INTO TMP_SUPPLY_ERROR_RECYCLE	" +
                           "(SEQ,	ID,	CARDNO,	ASN,	CARDTRADENO	,TRADETYPECODE,	CARDTYPECODE,"+
	                       "TRADEDATE,	TRADETIME,	TRADEMONEY,	PREMONEY,	SUPPLYLOCNO,	SAMNO,"+
                           "POSNO	,STAFFNO,	TAC,	TRADEID,	TACSTATE,	BATCHNO	,"+
	                       "BALUNITNO,	CALLINGNO,	CORPNO,	DEPARTNO,	DEALTIME,"+	
	                       "ERRORREASONCODE,	SessionId )	"+															
                           "SELECT "+ 																										
	                       "tmp.SEQ,tf.ID,tf.CARDNO,tf.ASN,tf.CARDTRADENO,tf.TRADETYPECODE,	tf.CARDTYPECODE,"+	
                           "tf.TRADEDATE,tf.TRADETIME,tf.TRADEMONEY,tf.PREMONEY	,tf.SUPPLYLOCNO,tf.SAMNO,"+		
	                       "tf.POSNO,tf.STAFFNO,tf.TAC,tf.TRADEID,tf.TACSTATE,tf.BATCHNO,"+	
	                       "tf.BALUNITNO,tf.CALLINGNO,tf.CORPNO,tf.DEPARTNO,tf.DEALTIME,"+
	                       "tf.ERRORREASONCODE,	tmp.SessionId "+
                           "FROM TF_SUPPLY_ERROR_" + hidDealDate.Value.Substring(5, 2) + " tf, TMP_SUPPLY_ERROR_IMP tmp " +    
                           "WHERE tf.ID = tmp.ID AND SessionId = '" + Session.SessionID + "'";

        context.ExecuteNonQuery(insertSql);
        context.DBCommit();
        return true;

    }

    protected void btnRecycle_Click(object sender, EventArgs e)
    {
        //回收校验 
        if (RecycleValidationFalse()) return;

        //调用回收处理的存储过程
        SP_SD_SupplyErrRecPDO pdo = new SP_SD_SupplyErrRecPDO();
       
        pdo.renewRemark = txtRenewRemark.Text.Trim();
        pdo.billMonth = hidDealDate.Value.Substring(5, 2);
        pdo.sessionID = Session.SessionID;

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M009105001");

            showNonDataGridView();
        }

        //清空临时表数据
        clearTempTable();
        txtRenewRemark.Text = "";
        //btnQuery_Click(sender, e);


    }

    private bool RecycleValidationFalse()
    {
        //清空临时表数据
        clearTempTable();

        //选择的异常消费记录入临时表
        if (!RecordIntoTmp()) return true;

        //不能在回收处理时修改处理时间
        if (hidDealDate.Value != "" && hidDealDate.Value != txtDealDate.Text.Trim())
        {
            context.AddError("A009103026");
            return true;
        }

        //对非空回收说明的长度校验
        if (txtRenewRemark.Text.Trim() != "" && Validation.strLen(txtRenewRemark.Text.Trim()) > 150)
        {
            context.AddError("A009103023", txtRenewRemark);
            return true;
        }

        return false;
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        //作废校验 
        if (RecycleValidationFalse()) return;

        //调用作废处理的存储过程
        SP_SD_SupplyErrCancelPDO pdo = new SP_SD_SupplyErrCancelPDO();

        pdo.renewRemark = txtRenewRemark.Text.Trim();
        pdo.billMonth = hidDealDate.Value.Substring(5, 2);
        pdo.sessionID = Session.SessionID;

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M009105002");
            showNonDataGridView();
        }

        //清空临时表数据
        clearTempTable();
        txtRenewRemark.Text = "";
        //btnQuery_Click(sender, e);


    }


    private void clearTempTable()
    {
        //清空临时表数据
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_SUPPLY_ERROR_IMP where SessionId='"
            + Session.SessionID + "'");
        context.ExecuteNonQuery("delete from TMP_SUPPLY_ERROR_RECYCLE where SessionId='"
                    + Session.SessionID + "'");
        context.DBCommit();
    }



}
