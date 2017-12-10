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
using PDO.PersonalBusiness;
using TDO.PersonalTrade;

public partial class ASP_PersonalBusiness_PB_Speloadinput : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //设置GridView绑定的DataTable
            lvwSpeloadQuery.DataSource = new DataTable();
            lvwSpeloadQuery.DataBind();
            lvwSpeloadQuery.SelectedIndex = -1;

            //指定GridView DataKeyNames
            lvwSpeloadQuery.DataKeyNames = new string[] { "TRADEID", "CARDNO", "TRADEMONEY", "TRADETIMES",
                "TRADEDATE", "INPUTTIME", "REMARK","STATECODE" };

            initLoad(sender, e);
        }
    }

    public ICollection CreateSpeloadQueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从特殊圈存台帐表中读取数据
        TF_B_SPELOADTDO ddoTF_B_SPELOADIn = new TF_B_SPELOADTDO();
        string strSql = "SELECT TRADEID,CARDNO,TRADEMONEY/100.0 TRADEMONEY,TRADETIMES,TRADEDATE,INPUTTIME,REMARK,STATECODE ";
        strSql += " FROM TF_B_SPELOAD WHERE INPUTSTAFFNO = '" + context.s_UserID + "' ORDER BY INPUTTIME DESC";

        ArrayList list = new ArrayList();

        strSql += DealString.ListToWhereStr(list);

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTF_B_SPELOADIn, null, strSql, 0);
        DataView dataView = new DataView(data);
        return dataView;
    }

    public String getDataKeys(string keysname)
    {
        return lvwSpeloadQuery.DataKeys[lvwSpeloadQuery.SelectedIndex][keysname].ToString();
    }

    protected void lvwSpeloadQuery_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择列表框一行记录后,得到该行记录的交易序号、状态
        hiddenTradeid.Value = getDataKeys("TRADEID");
        hidStateCode.Value = getDataKeys("STATECODE");
    }

    public void lvwSpeloadQuery_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwSpeloadQuery.PageIndex = e.NewPageIndex;
        lvwSpeloadQuery.DataSource = CreateSpeloadQueryDataSource();
        lvwSpeloadQuery.DataBind();
    }

    protected void lvwSpeloadQuery_RowCreated(object sender, GridViewRowEventArgs e)
    {

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwSpeloadQuery','Select$" + e.Row.RowIndex + "')");
        }
    }
    protected void lvwSpeloadQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[7].Text == "0")
            {
                e.Row.Cells[7].Text = "未圈存";
            }
            else if (e.Row.Cells[7].Text == "1")
            {
                e.Row.Cells[7].Text = "已圈存";
            }
            else if (e.Row.Cells[7].Text == "2")
            {
                e.Row.Cells[7].Text = "已作废";
            }
        }

    }
    public ICollection SpeloadQueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从特殊圈存台帐表中读取数据

        TF_B_SPELOADTDO ddoTF_B_SPELOADIn = new TF_B_SPELOADTDO();
        string strSql = "SELECT a.TRADEID,a.CARDNO,a.TRADEMONEY/100.0 TRADEMONEY,a.TRADETIMES,a.TRADEDATE,a.INPUTTIME,b.STAFFNAME INPUTSTAFF,a.REMARK,STATECODE";
        strSql += " FROM TF_B_SPELOAD a,TD_M_INSIDESTAFF b WHERE CARDNO = '" + txtCardno.Text + "'  AND b.STAFFNO = a.INPUTSTAFFNO AND TRADETYPECODE = '95' ORDER BY INPUTTIME DESC";

        ArrayList list = new ArrayList();

        strSql += DealString.ListToWhereStr(list);

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTF_B_SPELOADIn, null, strSql, 0);
        DataView dataView = new DataView(data);
        return dataView;
    }
    //轻轨交易补录数据显示
    public ICollection QueryLRTTradeManualInfo()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从特殊圈存台帐表中读取数据

        string strSql = " select a.cardno 卡号,a.cardtradeno 交易序号,a.tradedate 交易日期,a.tradetime 交易时间," +
                        " a.trademoney/100.0 交易金额,a.RENEWTIME 录入时间,b.STAFFNAME 录入员工,a.ERRORREASON 原因" +
                        " from TF_B_LRTTRADE_MANUAL a,TD_M_INSIDESTAFF b where a.cardno='" + txtCardno.Text + "' " +
                        " and a.RENEWSTAFFNO = b.STAFFNO and a.checkstatecode='1' and a.cardtradeno is not null  order by to_char(a.CHECKTIME,'yyyymmdd')";

        DataTable data = tmTMTableModule.selByPKDataTable(context, strSql, 0);
        DataView dataView = new DataView(data);
        return dataView;
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (txtCardno.Text.Trim() == ""|| Validation.strLen(txtCardno.Text.Trim())!=16)
        {
            context.AddError("卡号必须为16位");

            initLoad(sender, e);
        }
        else
        {
            PBHelper.queryCardNo(context, txtCardno);

            //查询轻轨交易补录信息
            gvResult.DataSource = QueryLRTTradeManualInfo();
            gvResult.DataBind();

            lvwSpeloadQuery.DataSource = SpeloadQueryDataSource();
            lvwSpeloadQuery.DataBind();
        }
    }
    protected void initLoad(object sender, EventArgs e)
    {
        lvwSpeloadQuery.DataSource = CreateSpeloadQueryDataSource();
        lvwSpeloadQuery.DataBind();
    }

    private bool AddValidate()
    {
        //对卡号数字检验
        txtCardno.Text = txtCardno.Text.Trim();
        if (!Validation.isNum(txtCardno.Text))
            context.AddError("A001004115", txtCardno);

        //对金额做非空,格式检验
        Money.Text = Money.Text.Trim();
        if (Money.Text == "")
            context.AddError("A001018102", Money);
        else if (!Validation.isPosRealNum(Money.Text))
            context.AddError("A001018103", Money);

        //对交易日期做非空,格式检验
        tradeDate.Text = tradeDate.Text.Trim();
        if (tradeDate.Text == "")
            context.AddError("A001018104", tradeDate);
        else if (!Validation.isDate(tradeDate.Text))
            context.AddError("A001018105", tradeDate);

        //对交易笔数做非空,数字检验
        tradeNum.Text = tradeNum.Text.Trim();
        if (tradeNum.Text == "")
            context.AddError("A001018106", tradeNum);
        else if (!Validation.isNum(tradeNum.Text))
            context.AddError("A001018107", tradeNum);

        //对备注进行非空,长度检验
        txtRemark.Text = txtRemark.Text.Trim();
        if (Validation.strLen(txtRemark.Text) > 50)
            context.AddError("A001018109", txtRemark);

        PBHelper.queryCardNo(context, txtCardno);

        return !context.hasError();
    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        //对增加信息进行检验
        if (!AddValidate())
        return;

        TMTableModule tmTMTableModule = new TMTableModule();

        //存储过程赋值
        SP_PB_SpeloadinputPDO pdo = new SP_PB_SpeloadinputPDO();
        pdo.TRADETYPECODE = "95";
        pdo.CARDNO = txtCardno.Text;
        pdo.TRADEMONEY = Convert.ToInt32(Convert.ToDecimal(Money.Text) * 100);
        pdo.TRADEDATE = Convert.ToDateTime(tradeDate.Text);
        pdo.TRADETIMES = Convert.ToInt32(tradeNum.Text);
        pdo.REMARK = txtRemark.Text;

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M001018100");
            foreach (Control con in this.Page.Controls)
            {
                ClearControl(con);
            }
            initLoad(sender, e);
        }
    }
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //检验是否已选择记录
        if (hiddenTradeid.Value == "")
        {
            context.AddError("A001018110");
            return;
        }
        else if (hidStateCode.Value != "0")     //add by jiangbb from 缺陷报告单_20140509-001.doc
        {
            context.AddError("A00228110:该记录不是未圈存状态");
            return;
        }

        //存储过程赋值
        SP_PB_SpeloadcancelPDO pdo = new SP_PB_SpeloadcancelPDO();
        pdo.TRADEID = hiddenTradeid.Value;

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M001018101");

            initLoad(sender, e);
        }
    }
}
