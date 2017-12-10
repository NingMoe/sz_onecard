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

public partial class ASP_PersonalBusiness_PB_B_Card_Query : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        initLoad(sender, e);

        //设置GridView绑定的DataTable
        UserCardHelper.resetData(lvwQuery, null);

        setReadOnly(cMoney, LabCardtype, sDate, eDate, RESSTATE);
    }

    //protected void lnkSim_Click(object sender, EventArgs e)
    //{
    //    UserCardHelper.validateSimNo(context, txtSimNo, false);
    //    if (context.hasError()) return;
		//
    //    DataTable dt = SPHelper.callPBQuery(context, "QueryCardNoBySim", txtSimNo.Text);
    //    if (dt != null && dt.Rows.Count > 0)
    //    {
    //        txtCardno.Text = "" + dt.Rows[0].ItemArray[0];
    //    }
    //   else
    //    {
    //        context.AddError("A001003X02: 没有查询到与SIM串号对应的IC卡卡号");
    //        txtCardno.Text = "";
    //    }
    //}

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
        //吴江B卡判断
        if (txtCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("不是吴江B卡,不能在本业务界面操作");
            return;
        }
        
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

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
            Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
            Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
        }
        
        // 查询SIM串号
        //DataTable dt = SPHelper.callPBQuery(context, "QuerySimByCardNo", txtCardno.Text);
        //if (dt != null && dt.Rows.Count > 0 )
        //{
        //    txtSimNo.Text = "" + dt.Rows[0].ItemArray[0];
        //}
        //else
        //{
        //    txtSimNo.Text = "";
        //}
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

        //吴江B卡判断
        if (txtCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("不是吴江B卡,不能在本业务界面操作");
            return;
        }
        
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
    }


    public void lvwQuery_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwQuery.PageIndex = e.NewPageIndex;
        btnQueryImpl();
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //吴江B卡判断
        if (txtCardno.Text.Substring(0, 6) != "215031")
        {
            context.AddError("不是吴江B卡,不能在本业务界面操作");
            return;
        }
        
        UserCardHelper.resetData(lvwQuery, null);
        btnQueryImpl();
    }

    protected void btnQueryImpl()
    {
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
        }
    }

    protected void lvwQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
    }
}
