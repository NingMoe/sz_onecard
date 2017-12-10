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
using PDO.PersonalBusiness;
using TDO.ResourceManager;
using TDO.BusinessCode;
using TDO.CardManager;
using Common;
using TDO.PersonalTrade;
using System.Collections.Generic;

public partial class ASP_PersonalBusiness_PB_SpeloadQuery : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;


        //设置GridView绑定的DataTable
        lvwSpeloadQuery.DataSource = new DataTable();
        lvwSpeloadQuery.DataBind();
        lvwSpeloadQuery.SelectedIndex = -1;

        //指定GridView DataKeyNames
        lvwSpeloadQuery.DataKeyNames = new string[] { "TRADEID", "CARDNO", "TRADEMONEY", "TRADETIMES",
                "TRADEDATE", "INPUTTIME", "REMARK","STATECODE" };


        initLoad(sender, e);

        //设置GridView绑定的DataTable
        UserCardHelper.resetData(lvwQuery, null);

        UserCardHelper.resetData(lvwLostCardQuery, null);

        setReadOnly(cMoney, LabCardtype, sDate, eDate, RESSTATE);
        divLost.Visible = false;
    }

    protected void lnkSim_Click(object sender, EventArgs e)
    {
        UserCardHelper.validateSimNo(context, txtSimNo, false);
        if (context.hasError()) return;

        DataTable dt = SPHelper.callPBQuery(context, "QueryCardNoBySim", txtSimNo.Text);
        if (dt != null && dt.Rows.Count > 0)
        {
            txtCardno.Text = "" + dt.Rows[0].ItemArray[0];
        }
        else
        {
            context.AddError("A001003X02: 没有查询到与SIM串号对应的IC卡卡号");
            txtCardno.Text = "";
        }
    }

    protected void initLoad(object sender, EventArgs e)
    {
        beginDate.Text = DateTime.Today.AddDays(-37).ToString("yyyyMMdd");
        endDate.Text = DateTime.Today.AddDays(-7).ToString("yyyyMMdd");
    }
    private Boolean dateValidation()
    {
        beginDate.Text = beginDate.Text.Trim();
        endDate.Text = endDate.Text.Trim();
        UserCardHelper.validateDateRange(context, beginDate, endDate, true);

        Validation valid = new Validation(context);

        //if (valid.beDate(endDate, "").Value > DateTime.Now)
        //    context.AddError("A001003102");

        if (valid.beDate(beginDate, "").Value.AddMonths(12) < DateTime.Now)
            context.AddError("A001003101");

        return !(context.hasError());
    }
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从用户卡库存表(TL_R_ICUSER)中读取数据


        TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
        ddoTL_R_ICUSERIn.CARDNO = txtCardno.Text;

        TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

        if (ddoTL_R_ICUSEROut == null)
        {
            context.AddError("A001001101");
            return;
        }

        //从资源状态编码表中读取数据


        TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEIn = new TD_M_RESOURCESTATETDO();
        ddoTD_M_RESOURCESTATEIn.RESSTATECODE = ddoTL_R_ICUSEROut.RESSTATECODE;

        TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEOut = (TD_M_RESOURCESTATETDO)tmTMTableModule.selByPK(context, ddoTD_M_RESOURCESTATEIn, typeof(TD_M_RESOURCESTATETDO), null, "TD_M_RESOURCESTATE", null);

        if (ddoTD_M_RESOURCESTATEOut == null)
            RESSTATE.Text = ddoTL_R_ICUSEROut.RESSTATECODE;
        else
            RESSTATE.Text = ddoTD_M_RESOURCESTATEOut.RESSTATE;

        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据


        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

        LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;

        //页面显示项赋值


        //txtCardno.Text = hiddentxtCardno.Value;
        //LabAsn.Text = hiddenASn.Value.Substring(4, 16);
        sDate.Text = ASHelper.toDateWithHyphen(hiddensDate.Value);
        eDate.Text = ASHelper.toDateWithHyphen(hiddeneDate.Value); 
        cMoney.Text = ((Convert.ToDouble(hiddencMoney.Value)) / 100).ToString("0.00");

        PBHelper.openFunc(context, openFunc, txtCardno.Text);

        readInfo(sender, e);

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
            Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
            Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
        }

        if (context.hasError()) return;

        readAcc(sender, e);
        if (context.hasError()) return;

        UserCardHelper.resetData(lvwQuery, null);

        ScriptManager.RegisterStartupScript(this, this.GetType(),
            "writeCardScript", "readCardRecord();", true);

        hidread.Value = "1";

    } 

    protected void readInfo(object sender, EventArgs e)
    {
        readCustInfo(txtCardno.Text, CustName, CustBirthday, Papertype, Paperno,
            Custsex, Custphone, Custpost, Custaddr, txtEmail, Remark);
        
        // 查询SIM串号
        DataTable dt = SPHelper.callPBQuery(context, "QuerySimByCardNo", txtCardno.Text);
        if (dt != null && dt.Rows.Count > 0 )
        {
            txtSimNo.Text = "" + dt.Rows[0].ItemArray[0];
        }
        else
        {
            txtSimNo.Text = "";
        }
    }

    protected void readAcc(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从IC卡电子钱包帐户表(TF_F_CARDEWALLETACC)中读取数据

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();

        string strSql = "SELECT TOTALSUPPLYMONEY/100.0 a,TOTALCONSUMEMONEY/100.0 b,FIRSTSUPPLYTIME,FIRSTCONSUMETIME,LASTCONSUMETIME,LASTSUPPLYTIME";
        strSql += " FROM TF_F_CARDEWALLETACC WHERE CARDNO = '" + txtCardno.Text + "' ";
        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTF_F_CARDEWALLETACCIn, null, strSql, 0);

        if (data.Rows.Count == 0)
        {
            return;
        }

        tSupplyMoney.Text = Convert.ToDouble(data.Rows[0][0].ToString()).ToString("0.00");
        tConsumeMoney.Text = Convert.ToDouble(data.Rows[0][1].ToString()).ToString("0.00");
        if (data.Rows[0][2].ToString() == null || data.Rows[0][2].ToString() == "")
        {
            fSupplyTime.Text = "";
        }
        else fSupplyTime.Text = Convert.ToDateTime(data.Rows[0][2].ToString()).ToString("yyyy-MM-dd");

        if (data.Rows[0][3].ToString() == null || data.Rows[0][3].ToString() == "")
        {
            fConsumeTime.Text = "";
        }
        else fConsumeTime.Text = Convert.ToDateTime(data.Rows[0][3].ToString()).ToString("yyyy-MM-dd");
        if (data.Rows[0][4].ToString() == null || data.Rows[0][4].ToString() == "")
        {
            lConsumeTime.Text = "";
        }
        else lConsumeTime.Text = Convert.ToDateTime(data.Rows[0][4].ToString()).ToString("yyyy-MM-dd");
        if (data.Rows[0][5].ToString() == null || data.Rows[0][5].ToString() == "")
        {
            lSupplyTime.Text = "";
        }
        else lSupplyTime.Text = Convert.ToDateTime(data.Rows[0][5].ToString()).ToString("yyyy-MM-dd");

        TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
        ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text;
        TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);
        txtSellTime.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");
        txtDeposit.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.DEPOSIT) / 100).ToString("0.00");
        txtCardCost.Text = (Convert.ToDecimal(ddoTF_F_CARDRECOut.CARDCOST) / 100).ToString("0.00");
    }


    private Boolean DBreadValidation()
    {
        //对卡号进行非空、长度、数字检验

        txtCardno.Text = txtCardno.Text.Trim();
        if (txtCardno.Text == "")
            context.AddError("A001004113", txtCardno);
        else
        {
            if (!Validation.isNum(txtCardno.Text))
                context.AddError("A001004115", txtCardno);
        }

        PBHelper.queryCardNo(context, txtCardno);

        return !(context.hasError());

    }
    protected void btnDBread_Click(object sender, EventArgs e)
    {
        //对输入卡号进行检验

        if (!DBreadValidation())
            return;

        TMTableModule tmTMTableModule = new TMTableModule();

        
        //从用户卡库存表(TL_R_ICUSER)中读取数据

        TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
        ddoTL_R_ICUSERIn.CARDNO = txtCardno.Text;

        TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

        if (ddoTL_R_ICUSEROut == null)
        {
            context.AddError("A001001101");
            return;
        }

        //从资源状态编码表中读取数据

        TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEIn = new TD_M_RESOURCESTATETDO();
        ddoTD_M_RESOURCESTATEIn.RESSTATECODE = ddoTL_R_ICUSEROut.RESSTATECODE;

        TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEOut = (TD_M_RESOURCESTATETDO)tmTMTableModule.selByPK(context, ddoTD_M_RESOURCESTATEIn, typeof(TD_M_RESOURCESTATETDO), null, "TD_M_RESOURCESTATE", null);

        if (ddoTD_M_RESOURCESTATEOut == null)
            RESSTATE.Text = ddoTL_R_ICUSEROut.RESSTATECODE;
        else
            RESSTATE.Text = ddoTD_M_RESOURCESTATEOut.RESSTATE;

        //从卡资料表(TF_F_CARDREC)中读取数据

        TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
        ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text.Trim();

        TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

        if (ddoTF_F_CARDRECOut == null)
        {
            context.AddError("A001008103");
            return;
        }

        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据

        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = ddoTF_F_CARDRECOut.CARDTYPECODE;
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

        LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;

        //从IC卡电子钱包帐户表(TF_F_CARDEWALLETACC)中读取数据

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text.Trim();

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);

        if (ddoTF_F_CARDEWALLETACCOut == null)
        {
            context.AddError("A001008103");
            return;
        }

        //给页面显示项赋值

        hiddenLabCardtype.Value = ddoTF_F_CARDRECOut.CARDTYPECODE;
        //LabAsn.Text = ddoTF_F_CARDRECOut.ASN;
        sDate.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");

        String Vdate = ddoTF_F_CARDRECOut.VALIDENDDATE;
        eDate.Text = ASHelper.toDateWithHyphen(Vdate);

        Double cardMoney = Convert.ToDouble(ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY);
        cMoney.Text = (cardMoney / 100).ToString("0.00");

        PBHelper.openFunc(context, openFunc, txtCardno.Text);

        readInfo(sender, e);
        readAcc(sender, e);

        lvwQuery.DataSource = new DataTable();
        lvwQuery.DataBind();

        hidread.Value = "0";

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
            Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
            Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
        }
    }


    public void lvwQuery_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwQuery.PageIndex = e.NewPageIndex;
        btnQueryImpl();
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        UserCardHelper.resetData(lvwQuery, null);
        btnQueryImpl();
         
        lvwSpeloadQuery.DataSource = CreateSpeloadQueryDataSource();
        lvwSpeloadQuery.DataBind();
    }


    public void lvwSpeloadQuery_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwSpeloadQuery.PageIndex = e.NewPageIndex;
        lvwSpeloadQuery.DataSource = CreateSpeloadQueryDataSource();
        lvwSpeloadQuery.DataBind();
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

    public ICollection CreateSpeloadQueryDataSource()
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


    //特殊圈存历史，轻轨交易补录数据显示
    public ICollection CreateSpeloadHistoryQueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从特殊圈存台帐表中读取数据

        TF_B_SPELOADTDO ddoTF_B_SPELOADIn = new TF_B_SPELOADTDO();
        string strSql = " select a.cardno 卡号,a.cardtradeno 交易序号,a.tradedate 交易日期,a.tradetime 交易时间," +
                        " a.trademoney/100.0 交易金额,a.RENEWTIME 录入时间,b.STAFFNAME 录入员工,a.ERRORREASON 原因" +
                        " from TF_B_LRTTRADE_MANUAL a,TD_M_INSIDESTAFF b where a.cardno='" + txtCardno.Text + "' " +
                        " and a.RENEWSTAFFNO = b.STAFFNO and a.checkstatecode='1' and a.cardtradeno is not null  order by to_char(a.CHECKTIME,'yyyymmdd')";
        ArrayList list = new ArrayList();

        strSql += DealString.ListToWhereStr(list);

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTF_B_SPELOADIn, null, strSql, 0);
        DataView dataView = new DataView(data);
        return dataView;
    }


    protected void btnQueryImpl()
    {

        if (selType.SelectedValue == "QuerySpeloadConsumeInfo")
        {
            divLost.Visible = true;
        }
        else
        {
            divLost.Visible = false;
        }

        if (selType.SelectedValue == "") return;

        TMTableModule tmTMTableModule = new TMTableModule();

        //对起始日期和终止日期做检验

        if (!dateValidation())
            return;

       

        if (selType.SelectedValue == "SaveTempRecords")
        {
            if (hidread.Value == "1")
            {
                //查询临时表TMP_PB_ReadRecord中数据

                DataTable data = SPHelper.callPBQuery(context, "SaveTempRecords",
                    Session.SessionID, txtCardno.Text, hidTradeno.Value, 
                    hidTradeMoney.Value, hidTradeType.Value,
                    hidTradeTerm.Value, hidTradeDate.Value, 
                    hidTradeTime.Value, hiddencMoney.Value);

                UserCardHelper.resetData(lvwQuery, data);
            }
            else if (hidread.Value == "0")
            {
                context.AddError("A001003118");
                return;
            }
        }
        else
        {
            
            DataTable data = SPHelper.callPBQuery(context, selType.SelectedValue, 
                txtCardno.Text, beginDate.Text, endDate.Text);
            UserCardHelper.resetData(lvwQuery, data);
            //缺失的卡的记录


            if (selType.SelectedValue == "QuerySpeloadConsumeInfo")
            {

                //查询特殊圈存历史信息
                gvResult.DataSource = CreateSpeloadHistoryQueryDataSource();
                gvResult.DataBind();

                DataTable lostDT = LostCardTradNoQuery(data);
                if (lostDT != null && lostDT.Rows.Count > 0)
                {
                    txtCardno1.Text = txtCardno.Text;
                    tradeDate.Text = endDate.Text.Trim().Substring(0, 4) + "-" + endDate.Text.Trim().Substring(4, 2) + "-" + endDate.Text.Trim().Substring(6, 2);
                    txtRemark.Text = beginDate.Text.Trim() + "-" + endDate.Text.Trim() + " " + hiddenLostCard.Value.TrimEnd(',');
                    tradeNum.Text = lostDT.Rows.Count.ToString();
                }
                else
                {
                    txtCardno1.Text = "";
                    tradeDate.Text = "";
                    txtRemark.Text = "";
                    tradeNum.Text = "";
                }

                lvwLostCardQuery.DataSource = lostDT;
                lvwLostCardQuery.DataBind();
            }
            
        }
    }

    protected void lvwQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
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
        if (Validation.strLen(txtRemark.Text) > 100)
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
            lvwSpeloadQuery.DataSource = CreateSpeloadQueryDataSource();
            lvwSpeloadQuery.DataBind();
        }
    }



    public String getDataKeys(string keysname)
    {
        return lvwSpeloadQuery.DataKeys[lvwSpeloadQuery.SelectedIndex][keysname].ToString();
    }

    protected void lvwSpeloadQuery_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择列表框一行记录后,得到该行记录的交易序号


        hiddenTradeid.Value = getDataKeys("TRADEID");

    }

    protected void lvwSpeloadQuery_RowCreated(object sender, GridViewRowEventArgs e)
    {

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件


            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwSpeloadQuery','Select$" + e.Row.RowIndex + "')");
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

        //存储过程赋值


        SP_PB_SpeloadcancelPDO pdo = new SP_PB_SpeloadcancelPDO();
        pdo.TRADEID = hiddenTradeid.Value;

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M001018101");

            lvwSpeloadQuery.DataSource = CreateSpeloadQueryDataSource();
            lvwSpeloadQuery.DataBind();
        }
    }



    //缺失的卡交易序号的查询

    protected DataTable  LostCardTradNoQuery(DataTable preDT)
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("卡交易号");
        dt.Columns.Add("前一笔交易时间");
        dt.Columns.Add("后一笔交易时间");
        dt.Columns.Add("交易前￥");
        dt.Columns.Add("交易后￥");
        hiddenLostCard.Value = "";
        if (preDT != null && preDT.Rows.Count > 1)
        {
           for(int i=0;i<preDT.Rows.Count-1;i++)
           {
               setDataTable(ref dt, preDT.Rows[i+1], preDT.Rows[i]);
           }
        }
        return dt;
    }

    //往缺失交易序号表里填前一个交易序号和后一个交易序号之间缺失的交易序号信息
    protected void setDataTable(ref DataTable dt, DataRow predr, DataRow afterdr)
    {
        
        int preint=Convert.ToInt32(predr[0].ToString(), 16);
        int afterint=Convert.ToInt32(afterdr[0].ToString(), 16);
        int i = Convert.ToInt32(afterdr[0].ToString(), 16) - Convert.ToInt32(predr[0].ToString(), 16);
        if (i == 1)
            return;
        int temp = Convert.ToInt32(afterdr[0].ToString(), 16) - 1;
        for (int j = 2; j <= i; j++)
        {
            if (temp == preint)
            {
                break;
            }
            if (temp - 1 == preint && temp +1 == afterint)//当前缺失的交易序号前一个交易序号和后一个交易序号都是存在的
            {
                hiddenLostCard.Value = hiddenLostCard.Value + temp.ToString("X4")+",";
                dt.Rows.Add(temp.ToString("X4"), predr[1].ToString(),afterdr[1].ToString() , predr[4].ToString(), afterdr[2].ToString());
            }
            else if (temp - 1 == preint)//当前缺失的交易序号前一个交易序号是存在的，后一个交易序号不存在
            {
                hiddenLostCard.Value = hiddenLostCard.Value + temp.ToString("X4") + ",";
                dt.Rows.Add(temp.ToString("X4"), predr[1].ToString(), "", predr[4].ToString(), "");
            }
            else if (temp + 1 == afterint)//当前缺失的交易序号后一个交易序号是存在的，前一个交易序号不存在
            {
                hiddenLostCard.Value = hiddenLostCard.Value + temp.ToString("X4") + ",";
                dt.Rows.Add(temp.ToString("X4"), "", afterdr[1].ToString(), "", afterdr[2].ToString());
            }
            else//当前缺失的交易序号前一个交易序号和后一个交易序号都是不存在的

            {
                 hiddenLostCard.Value = hiddenLostCard.Value + temp.ToString("X4") + ",";
                 dt.Rows.Add(temp.ToString("X4"), "", "", "", "");
            }
            temp = Convert.ToInt32(afterdr[0].ToString(), 16) - j;
        }
    }
}
