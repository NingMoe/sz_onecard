using System;
using System.Collections;
using System.Data;
using System.Drawing;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using Master;
using TDO.InvoiceTrade;
using TDO.UserManager;
using ThoughtWorks.QRCode.Codec;
using TM;

public partial class ASP_InvoiceTrade_IT_PrintElectronic : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            //初始化日期

            txtBeginDate.Text = DateTime.Now.ToString("yyyyMMdd");
            txtEndDate.Text = DateTime.Now.ToString("yyyyMMdd");
            //初始化表头

            initTable();
            //初始化部门
            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
            TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
            ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
            selDept.SelectedValue = context.s_DepartID;
            InitStaffList(context.s_DepartID);
            selStaff.SelectedValue = context.s_UserID;

            //初始化开票项目名称
            string sqlPROJ = "select * from TD_M_INVOICEPROJECT where USETAG='1'";
            TD_M_INVOICEPROJECTTDO ddoTD_M_INVOICEPROJECTTDOIn = new TD_M_INVOICEPROJECTTDO();
            TD_M_INVOICEPROJECTTDO[] ddoTD_M_INVOICEPROJECTTDOOutArr = (TD_M_INVOICEPROJECTTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_INVOICEPROJECTTDOIn, typeof(TD_M_INVOICEPROJECTTDO), null, sqlPROJ);
            FillDropDownList(ddlProjName, ddoTD_M_INVOICEPROJECTTDOOutArr, "PROJECTNAME", "PROJECTNAME");
           // hidMessage.Value = "";
        }
    }
    public void initTable()
    {
        lvwInvoice.DataSource = new DataTable();
        lvwInvoice.DataBind();
        lvwInvoice.SelectedIndex = -1;
        lvwInvoice.DataKeyNames = new string[] { "TRADEID", "CARDNO", "CURRENTMONEY", "OPERATETIME", "DEPARTNO", "OPERATESTAFFNO", "TRADETYPE", "VOLUMENO", "INVOICENO", "ISSK" };
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //if (!InputValidate())
        //    return;

        //DataTable dt = SPHelper.callQuery("SP_IT_Query", context, "QueryElectronicItems", txtBeginDate.Text.Trim(), txtEndDate.Text.Trim(), txtBeginCardNo.Text.Trim(), txtEndCardNo.Text.Trim(), selDept.SelectedValue, selStaff.SelectedValue, selTradeType.SelectedValue);
        //if (dt == null || dt.Rows.Count < 1)
        //{
        //    lvwInvoice.DataSource = new DataTable();
        //    lvwInvoice.DataBind();
        //    context.AddError("未查出记录");
        //    return;
        //}
        //lvwInvoice.DataSource = dt;
        //lvwInvoice.DataBind();
        //lvwInvoice.SelectedIndex = -1;
        QueryCardOperRecord();
        ddlProjName.SelectedIndex = 0;
        selProj1.SelectedIndex = 0;
        selProj1.Enabled = true;

    }

    private void QueryCardOperRecord()
    {
        if (!InputValidate())
            return;

        string strSql = "";

        TMTableModule tmTMTableModule = new TMTableModule();

        if (selTradeType.SelectedValue == "1")     //普通充值
        {
            strSql += "SELECT TRADEID,CARDNO,TRADETYPECODE,TRADETYPE,CURRENTMONEY,OPERATESTAFFNO,OPERATETIME,DEPARTNO,VOLUMENO,INVOICENO,ISSK FROM(";
            strSql += "SELECT A.TRADEID, A.CARDNO, A.TRADETYPECODE, C.TRADETYPE, A.CURRENTMONEY/100.0 CURRENTMONEY ,";
            strSql += " A.OPERATESTAFFNO, A.OPERATETIME, A.Operatedepartid DEPARTNO,'' VOLUMENO,'' INVOICENO,'' ISSK";
            strSql += " From TF_B_TRADE A, TD_M_TRADETYPE C";
            strSql += " WHERE A.TRADETYPECODE='02' AND A.CANCELTAG = '0'";
            strSql += "AND A.TRADEID NOT IN(SELECT K.TRADEID FROM TF_F_INVOICEORDERDETAIL K WHERE K.TRADEID=A.TRADEID and  k.usetag='1')";
            strSql += " AND  A.TRADETYPECODE = C.TRADETYPECODE(+) ";
            strSql += " union all";
            strSql += " SELECT A.TRADEID, A.CARDNO, A.TRADETYPECODE, C.TRADETYPE, A.CURRENTMONEY/100.0 CURRENTMONEY,";
            strSql += " A.OPERATESTAFFNO, A.OPERATETIME,A.Operatedepartid DEPARTNO,k.VOLUMENO,k.INVOICENO,'1' ISSK";
            strSql += " From TF_B_TRADE A, TD_M_TRADETYPE C,TF_F_INVOICEORDERDETAIL K ";
            strSql += " WHERE A.TRADETYPECODE='02' AND A.CANCELTAG = '0'";
            strSql += " AND A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += " AND A.TRADEID=K.TRADEID";
            strSql += " AND K.USETAG='1')P";
        }
        else if (selTradeType.SelectedValue == "2")  //充值卡售出
        {
            strSql += "SELECT TRADEID,CARDNO,TRADETYPECODE,TRADETYPE,CURRENTMONEY,OPERATESTAFFNO,OPERATETIME,DEPARTNO,VOLUMENO,INVOICENO,ISSK ,STARTCARDNO,ENDCARDNO FROM(";
            strSql += "SELECT A.TRADEID, DECODE(A.STARTCARDNO, A.ENDCARDNO, A.STARTCARDNO, A.STARTCARDNO || '-' || A.ENDCARDNO) CARDNO, A.TRADETYPECODE, C.TRADETYPE,";
            strSql += " A.MONEY/100.0 CURRENTMONEY, A.STAFFNO OPERATESTAFFNO, A.OPERATETIME OPERATETIME,D.DEPARTNO,'' VOLUMENO,'' INVOICENO,'' ISSK,A.STARTCARDNO,A.ENDCARDNO";
            strSql += "  From TF_XFC_SELL A , TD_M_TRADETYPE C ,TD_M_INSIDESTAFF D";
            strSql += " WHERE A.TRADETYPECODE='80' AND A.CANCELTAG = '0'  ";
            strSql += " AND A.TRADEID NOT IN(SELECT K.TRADEID FROM TF_F_INVOICEORDERDETAIL K WHERE K.TRADEID=A.TRADEID and  k.usetag='1') ";
            strSql += " AND  A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += " AND A.STAFFNO = D.STAFFNO(+)";
            strSql += " union all";
            strSql += " SELECT A.TRADEID, DECODE(A.STARTCARDNO, A.ENDCARDNO, A.STARTCARDNO, A.STARTCARDNO || '-' || A.ENDCARDNO) CARDNO, A.TRADETYPECODE, C.TRADETYPE,";
            strSql += " A.MONEY/100.0 CURRENTMONEY, A.STAFFNO OPERATESTAFFNO, A.OPERATETIME OPERATETIME,D.DEPARTNO,k.VOLUMENO,k.INVOICENO,'' ISSK,A.STARTCARDNO,A.ENDCARDNO";
            strSql += " From TF_XFC_SELL A , TD_M_TRADETYPE C ,TD_M_INSIDESTAFF D,TF_F_INVOICEORDERDETAIL K ";
            strSql += " WHERE A.TRADETYPECODE='80' AND A.CANCELTAG = '0' ";
            strSql += " AND  A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += " AND A.STAFFNO = D.STAFFNO(+)";
            strSql += " AND A.TRADEID=K.TRADEID";
            strSql += " AND K.USETAG='1')P";
        }
        else if (selTradeType.SelectedValue == "3") //礼金卡售出
        {
            strSql += "SELECT TRADEID,CARDNO,TRADETYPECODE,TRADETYPE,CURRENTMONEY,OPERATESTAFFNO,OPERATETIME,DEPARTNO,VOLUMENO,INVOICENO,ISSK FROM(";
            strSql += "SELECT A.TRADEID, A.CARDNO, A.TRADETYPECODE, C.TRADETYPE, (D.SUPPLYMONEY + 1000)/100.0 CURRENTMONEY,";
            strSql += "  A.OPERATESTAFFNO, A.OPERATETIME,A.Operatedepartid DEPARTNO,'' VOLUMENO,'' INVOICENO,'' ISSK";
            strSql += " From TF_B_TRADE A ,TF_B_TRADEFEE D ,TD_M_TRADETYPE C ";
            strSql += "WHERE A.TRADETYPECODE IN ('50','51') AND A.CANCELTAG = '0'  ";
            strSql += " AND A.TRADEID = D.TRADEID(+) ";
            strSql += " AND  A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += "AND A.TRADEID NOT IN(SELECT K.TRADEID FROM TF_F_INVOICEORDERDETAIL K WHERE K.TRADEID=A.TRADEID and  k.usetag='1')";
            strSql += " union all";
            strSql += " SELECT A.TRADEID, A.CARDNO, A.TRADETYPECODE, C.TRADETYPE, (D.SUPPLYMONEY + 1000)/100.0 CURRENTMONEY,";
            strSql += " A.OPERATESTAFFNO, A.OPERATETIME,A.Operatedepartid DEPARTNO,k.VOLUMENO,k.INVOICENO,'' ISSK";
            strSql += " From TF_B_TRADE A ,TF_B_TRADEFEE D ,TD_M_TRADETYPE C,TF_F_INVOICEORDERDETAIL K";
            strSql += " WHERE A.TRADETYPECODE IN ('50','51') AND A.CANCELTAG = '0' ";
            strSql += " AND A.TRADEID = D.TRADEID(+)";
            strSql += " AND  A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += " AND A.TRADEID=K.TRADEID";
            strSql += " AND K.USETAG='1')P";
        }
        else if (selTradeType.SelectedValue == "4")  //  代理充值
        {
            strSql += "SELECT TRADEID,CARDNO,TRADETYPECODE,TRADETYPE,CURRENTMONEY,OPERATESTAFFNO,OPERATETIME,DEPARTNO,VOLUMENO,INVOICENO,ISSK FROM(";
            strSql += "select A.ID TRADEID,A.CARDNO,A.TRADETYPECODE,C.TRADETYPE, A.TRADEMONEY/100.0 CURRENTMONEY, A.STAFFNO OPERATESTAFFNO ,";
            strSql += "A.TRADEDATE OPERATETIME,A.DEPARTNO,'' VOLUMENO,'' INVOICENO,'' ISSK";
            strSql += " From TQ_SUPPLY_RIGHT A, TD_M_TRADETYPE C";
            strSql += " WHERE A.TRADETYPECODE IN ('02','1S') AND (A.RSRVCHAR in ('01','02') or A.RSRVCHAR is null)";
            strSql += " AND A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += " AND A.ID NOT IN(SELECT K.TRADEID FROM TF_F_INVOICEORDERDETAIL K WHERE K.TRADEID=A.ID and  k.usetag='1')";
            strSql += " union all";
            strSql += " select A.ID TRADEID,A.CARDNO,A.TRADETYPECODE,C.TRADETYPE, A.TRADEMONEY/100.0 CURRENTMONEY, A.STAFFNO OPERATESTAFFNO ,";
            strSql += " A.TRADEDATE OPERATETIME,A.DEPARTNO,k.VOLUMENO,k.INVOICENO,'' ISSK";
            strSql += " From TQ_SUPPLY_RIGHT A, TD_M_TRADETYPE C,TF_F_INVOICEORDERDETAIL K ";
            strSql += " WHERE A.TRADETYPECODE IN ('02','1S') AND (A.RSRVCHAR in ('01','02') or A.RSRVCHAR is null) AND A.BALUNITNO IS NOT NULL ";
            strSql += " AND A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += " AND A.ID=K.TRADEID";
            strSql += " AND K.USETAG='1')P";
        }      
        else if (selTradeType.SelectedValue == "5")  //手Q充值
        {
            strSql += "SELECT TRADEID,CARDNO,TRADETYPECODE,TRADETYPE,CURRENTMONEY,OPERATESTAFFNO,OPERATETIME,DEPARTNO,VOLUMENO,INVOICENO,ISSK FROM(";
            strSql += "select A.ID TRADEID,A.CARDNO,A.TRADETYPECODE,C.TRADETYPE, A.TRADEMONEY/100.0 CURRENTMONEY, A.STAFFNO OPERATESTAFFNO ,";
            strSql += " A.TRADEDATE OPERATETIME,A.DEPARTNO,'' VOLUMENO,'' INVOICENO,'' ISSK";
            strSql += " From TQ_SUPPLY_RIGHT A,TD_M_TRADETYPE C ";
            strSql += " WHERE A.balunitno='36000001' AND  A.rsrvchar = '01' ";
            strSql += " AND A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += " AND A.ID NOT IN(SELECT K.TRADEID FROM TF_F_INVOICEORDERDETAIL K WHERE K.TRADEID=A.ID and  k.usetag='1')";
            strSql += " union all";
            strSql += " select A.ID TRADEID,A.CARDNO,A.TRADETYPECODE,C.TRADETYPE, A.TRADEMONEY/100.0 CURRENTMONEY, A.STAFFNO OPERATESTAFFNO ,";
            strSql += " A.TRADEDATE OPERATETIME,A.DEPARTNO,k.VOLUMENO,k.INVOICENO,'' ISSK";
            strSql += " From TQ_SUPPLY_RIGHT A,TD_M_TRADETYPE C  ,TF_F_INVOICEORDERDETAIL K ";
            strSql += " WHERE A.balunitno='36000001' AND  A.rsrvchar = '01' ";
            strSql += " AND A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += " AND A.ID=K.TRADEID";
            strSql += " AND K.USETAG='1')P";
        }
        else if (selTradeType.SelectedValue == "6")  //充值补登
        {
            strSql += "SELECT TRADEID,CARDNO,TRADETYPECODE,TRADETYPE,CURRENTMONEY,OPERATESTAFFNO,OPERATETIME,DEPARTNO,VOLUMENO,INVOICENO,ISSK FROM(";
            strSql += "select A.ID TRADEID,A.CARDNO,A.TRADETYPECODE,C.TRADETYPE, A.TRADEMONEY/100.0 CURRENTMONEY, A.STAFFNO OPERATESTAFFNO ,";
            strSql += "A.TRADEDATE OPERATETIME,A.DEPARTNO,'' VOLUMENO,'' INVOICENO,'' ISSK";
            strSql += " From TQ_SUPPLY_RIGHT A ,TD_M_TRADETYPE C ";
            strSql += " WHERE A.TRADETYPECODE='2A' ";
            strSql += " AND  A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += "AND A.ID NOT IN(SELECT K.TRADEID FROM TF_F_INVOICEORDERDETAIL K WHERE K.TRADEID=A.ID and  k.usetag='1')";
            strSql += " union all";
            strSql += " select A.ID TRADEID,A.CARDNO,A.TRADETYPECODE,C.TRADETYPE, A.TRADEMONEY/100.0 CURRENTMONEY, A.STAFFNO OPERATESTAFFNO ,";
            strSql += "A.TRADEDATE OPERATETIME,A.DEPARTNO,k.VOLUMENO,k.INVOICENO,'' ISSK";
            strSql += " From TQ_SUPPLY_RIGHT A ,TD_M_TRADETYPE C ,TF_F_INVOICEORDERDETAIL K ";
            strSql += " WHERE A.TRADETYPECODE='2A' ";
            strSql += " AND  A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += " AND A.ID=K.TRADEID";
            strSql += " AND K.USETAG='1')P";
        }
        else if (selTradeType.SelectedValue == "7")  //读卡器售出
        {
            strSql += "SELECT TRADEID,CARDNO,TRADETYPECODE,TRADETYPE,CURRENTMONEY,OPERATESTAFFNO,OPERATETIME,DEPARTNO,VOLUMENO,INVOICENO,ISSK,BEGINSERIALNUMBER,ENDSERIALNUMBER  FROM(";
            strSql += " select A.TRADEID,DECODE(A.BEGINSERIALNUMBER, A.ENDSERIALNUMBER, A.BEGINSERIALNUMBER, A.BEGINSERIALNUMBER || '-' || A.ENDSERIALNUMBER) CARDNO,A.OPERATETYPECODE TRADETYPECODE,C.TRADETYPE, A.MONEY/100.0 CURRENTMONEY, A.OPERATESTAFFNO ,";
            strSql += "A.OPERATETIME,D.DEPARTNO,'' VOLUMENO,'' INVOICENO,'' ISSK,A.BEGINSERIALNUMBER,A.ENDSERIALNUMBER";
            strSql += " From TF_B_READER A ,TD_M_TRADETYPE C,TD_M_INSIDESTAFF D ";
            strSql += " WHERE A.OPERATETYPECODE = C.TRADETYPECODE(+)  ";
            strSql += " AND A.OPERATESTAFFNO=D.STAFFNO(+)";
            strSql += " AND A.OPERATETYPECODE='1A' AND A.CANCELTAG = '0'  ";
            strSql += " AND A.TRADEID NOT IN(SELECT K.TRADEID FROM TF_F_INVOICEORDERDETAIL K WHERE K.TRADEID=A.TRADEID and  k.usetag='1')";
            strSql += " union all";
            strSql += " select A.TRADEID,DECODE(A.BEGINSERIALNUMBER, A.ENDSERIALNUMBER, A.BEGINSERIALNUMBER, A.BEGINSERIALNUMBER || '-' || A.ENDSERIALNUMBER) CARDNO,A.OPERATETYPECODE TRADETYPECODE,C.TRADETYPE, A.MONEY/100.0 CURRENTMONEY, A.OPERATESTAFFNO ,";
            strSql += "A.OPERATETIME,D.DEPARTNO,k.VOLUMENO,k.INVOICENO,'' ISSK,A.BEGINSERIALNUMBER,A.ENDSERIALNUMBER";
            strSql += " From TF_B_READER A ,TD_M_TRADETYPE C,TD_M_INSIDESTAFF D,TF_F_INVOICEORDERDETAIL K  ";
            strSql += " WHERE A.OPERATETYPECODE = C.TRADETYPECODE(+) ";
            strSql += " AND A.OPERATESTAFFNO=D.STAFFNO(+)";
            strSql += " AND A.OPERATETYPECODE='1A' AND A.CANCELTAG = '0' ";
            strSql += " AND A.TRADEID=K.TRADEID";
            strSql += " AND K.USETAG='1')P";
        }
        else if (selTradeType.SelectedValue == "8")  //售卡
        {
            strSql += "SELECT TRADEID,CARDNO,TRADETYPECODE,TRADETYPE,CURRENTMONEY,OPERATESTAFFNO,OPERATETIME,DEPARTNO,VOLUMENO,INVOICENO,ISSK FROM(";
            strSql += "SELECT A.TRADEID, A.CARDNO, A.TRADETYPECODE, C.TRADETYPE, A.CURRENTMONEY/100.0 CURRENTMONEY,";
            strSql += "A.OPERATESTAFFNO, A.OPERATETIME,A.Operatedepartid DEPARTNO,'' VOLUMENO,'' INVOICENO,'' ISSK";
            strSql += " From TF_B_TRADE A , TD_M_TRADETYPE C";
            strSql += " WHERE A.TRADETYPECODE='01' AND A.CANCELTAG = '0' ";
            strSql += " AND A.TRADETYPECODE = C.TRADETYPECODE(+) ";
            strSql += "AND A.TRADEID NOT IN(SELECT K.TRADEID FROM TF_F_INVOICEORDERDETAIL K WHERE K.TRADEID=A.TRADEID and  k.usetag='1')";
            strSql += " union all";
            strSql += " SELECT A.TRADEID, A.CARDNO, A.TRADETYPECODE, C.TRADETYPE, A.CURRENTMONEY/100.0 CURRENTMONEY,";
            strSql += "A.OPERATESTAFFNO, A.OPERATETIME,A.Operatedepartid DEPARTNO,k.VOLUMENO,k.INVOICENO,'' ISSK";
            strSql += " From TF_B_TRADE A , TD_M_TRADETYPE C ,TF_F_INVOICEORDERDETAIL K  ";
            strSql += " WHERE A.TRADETYPECODE='01' AND A.CANCELTAG = '0'";
            strSql += " AND A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += " AND A.TRADEID=K.TRADEID";
            strSql += " AND K.USETAG='1')P";
        }
        else if (selTradeType.SelectedValue == "9")  //休闲开卡
        {
            strSql += "SELECT TRADEID,CARDNO,TRADETYPECODE,TRADETYPE,CURRENTMONEY,OPERATESTAFFNO,OPERATETIME,DEPARTNO,VOLUMENO,INVOICENO,ISSK FROM(";
            strSql += "SELECT A.TRADEID, A.CARDNO, A.TRADETYPECODE, C.TRADETYPE, D.FUNCFEE/100.0 CURRENTMONEY,";
            strSql += "A.OPERATESTAFFNO, A.OPERATETIME,A.Operatedepartid DEPARTNO,'' VOLUMENO,'' INVOICENO,'' ISSK";
            strSql += " From TF_B_TRADE A, TF_B_TRADEFEE D ,TD_M_TRADETYPE C ";
            strSql += " WHERE A.TRADETYPECODE='25' AND A.CANCELTAG = '0'";
            strSql += " AND A.TRADEID = D.TRADEID(+)";
            strSql += " AND A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += " AND A.TRADEID NOT IN(SELECT K.TRADEID FROM TF_F_INVOICEORDERDETAIL K WHERE K.TRADEID=A.TRADEID and  k.usetag='1')";
            strSql += " union all";
            strSql += " SELECT A.TRADEID, A.CARDNO, A.TRADETYPECODE, C.TRADETYPE, D.FUNCFEE/100.0 CURRENTMONEY,";
            strSql += " A.OPERATESTAFFNO, A.OPERATETIME,A.Operatedepartid DEPARTNO,k.VOLUMENO,k.INVOICENO,'' ISSK";
            strSql += " From TF_B_TRADE A, TF_B_TRADEFEE D ,TD_M_TRADETYPE C,TF_F_INVOICEORDERDETAIL K  ";
            strSql += " WHERE A.TRADETYPECODE='25' AND A.CANCELTAG = '0'";
            strSql += " AND A.TRADEID = D.TRADEID(+)";
            strSql += " AND A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += " AND A.TRADEID=K.TRADEID";
            strSql += " AND K.USETAG='1')P";
        }
        else if (selTradeType.SelectedValue == "10")  //省卡充值
        {
            strSql += "SELECT TRADEID,CARDNO,TRADETYPECODE,TRADETYPE,CURRENTMONEY,OPERATESTAFFNO,OPERATETIME,DEPARTNO,VOLUMENO,INVOICENO,ISSK FROM(";
            strSql += "SELECT A.TRADEID, A.CARDNO, A.TRADETYPECODE, C.TRADETYPE, A.CURRENTMONEY/100.0 CURRENTMONEY,";
            strSql += "A.OPERATESTAFFNO, A.OPERATETIME,A.Operatedepartid DEPARTNO,'' VOLUMENO,'' INVOICENO,'1' ISSK";
            strSql += " From TF_B_TRADE_SK A ,TD_M_TRADETYPE C";
            strSql += " WHERE A.TRADETYPECODE='02' AND A.CANCELTAG = '0' ";
            strSql += " AND A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += " AND A.TRADEID NOT IN(SELECT K.TRADEID FROM TF_F_INVOICEORDERDETAIL K WHERE K.TRADEID=A.TRADEID and  k.usetag='1')";
            strSql += " union all";
            strSql += " SELECT A.TRADEID, A.CARDNO, A.TRADETYPECODE, C.TRADETYPE, A.CURRENTMONEY/100.0 CURRENTMONEY,";
            strSql += "A.OPERATESTAFFNO, A.OPERATETIME,A.Operatedepartid DEPARTNO,k.VOLUMENO,k.INVOICENO,'1' ISSK";
            strSql += " From TF_B_TRADE_SK A,TD_M_TRADETYPE C,TF_F_INVOICEORDERDETAIL K ";
            strSql += " WHERE A.TRADETYPECODE='02' AND A.CANCELTAG = '0' ";
            strSql += " AND A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += " AND A.TRADEID=K.TRADEID";
            strSql += " AND K.USETAG='1')P";
        }
        else if (selTradeType.SelectedValue == "11")  //省卡售卡
        {
            strSql += "SELECT TRADEID,CARDNO,TRADETYPECODE,TRADETYPE,CURRENTMONEY,OPERATESTAFFNO,OPERATETIME,DEPARTNO,VOLUMENO,INVOICENO,ISSK FROM(";
            strSql += "SELECT A.TRADEID, A.CARDNO, A.TRADETYPECODE, C.TRADETYPE, A.CURRENTMONEY/100.0 CURRENTMONEY,";
            strSql += "A.OPERATESTAFFNO, A.OPERATETIME,A.Operatedepartid DEPARTNO,'' VOLUMENO,'' INVOICENO,'1' ISSK";
            strSql += " From TF_B_TRADE_SK A ,TD_M_TRADETYPE C";
            strSql += " WHERE A.TRADETYPECODE='01' AND A.CANCELTAG = '0' ";
            strSql += " AND A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += " AND A.TRADEID NOT IN(SELECT K.TRADEID FROM TF_F_INVOICEORDERDETAIL K WHERE K.TRADEID=A.TRADEID and  k.usetag='1')";
            strSql += " union all ";
            strSql += " SELECT A.TRADEID, A.CARDNO, A.TRADETYPECODE, C.TRADETYPE, A.CURRENTMONEY/100.0 CURRENTMONEY,";
            strSql += " A.OPERATESTAFFNO, A.OPERATETIME,A.Operatedepartid DEPARTNO,k.VOLUMENO,k.INVOICENO,'1' ISSK ";
            strSql += " From TF_B_TRADE_SK A,TD_M_TRADETYPE C,TF_F_INVOICEORDERDETAIL K ";
            strSql += " WHERE A.TRADETYPECODE='01' AND A.CANCELTAG = '0' ";
            strSql += " AND A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += " AND A.TRADEID=K.TRADEID";
            strSql += " AND K.USETAG='1')P";
        }
        else if (selTradeType.SelectedValue == "12")  //  省卡代理充值
        {
            strSql += "SELECT TRADEID,CARDNO,TRADETYPECODE,TRADETYPE,CURRENTMONEY,OPERATESTAFFNO,OPERATETIME,DEPARTNO,VOLUMENO,INVOICENO,ISSK FROM(";
            strSql += "select A.ID TRADEID,A.CARDNO,A.TRADETYPECODE,C.TRADETYPE, A.TRADEMONEY/100.0 CURRENTMONEY, A.STAFFNO OPERATESTAFFNO ,";
            strSql += "A.TRADEDATE OPERATETIME,A.DEPARTNO,'' VOLUMENO,'' INVOICENO,'1' ISSK";
            strSql += " From TQ_SUPPLY_RIGHT_SK A, TD_M_TRADETYPE C, TF_SELSUP_BALUNIT b";
            strSql += " WHERE A.TRADETYPECODE ='02'  ";
            strSql += " AND A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += " AND b.ISPRVNCARD= '1'";
            strSql += " AND a.BALUNITNO=b.BALUNITNO";
            strSql += " AND A.ID NOT IN(SELECT K.TRADEID FROM TF_F_INVOICEORDERDETAIL K WHERE K.TRADEID=A.ID and  k.usetag='1')";
            strSql += " union all";
            strSql += " select A.ID TRADEID,A.CARDNO,A.TRADETYPECODE,C.TRADETYPE, A.TRADEMONEY/100.0 CURRENTMONEY, A.STAFFNO OPERATESTAFFNO ,";
            strSql += " A.TRADEDATE OPERATETIME,A.DEPARTNO,k.VOLUMENO,k.INVOICENO,'1' ISSK";
            strSql += " From TQ_SUPPLY_RIGHT_SK A, TD_M_TRADETYPE C, TF_SELSUP_BALUNIT b,TF_F_INVOICEORDERDETAIL K ";
            strSql += " WHERE A.TRADETYPECODE ='02' ";
            strSql += " AND A.TRADETYPECODE = C.TRADETYPECODE(+)";
            strSql += " AND b.ISPRVNCARD= '1'";
            strSql += " AND a.BALUNITNO=b.BALUNITNO";
            strSql += " AND A.ID=K.TRADEID";
            strSql += " AND K.USETAG='1')P";
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
    private String ListToAndStr(ArrayList list)
    {
        String str = " ";
        for (int i = 0; i < list.Count; i++)
        {
            if(i==0)
            {
                str += " Where (" + list[i].ToString() + ")";
            }
            else
            {
                str += " And (" + list[i].ToString() + ")";
            }
            
        }
        return str;
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

        if (selTradeType.SelectedValue == "1" || selTradeType.SelectedValue == "3" || selTradeType.SelectedValue == "4" || selTradeType.SelectedValue == "5" || selTradeType.SelectedValue == "6" || selTradeType.SelectedValue == "8" || selTradeType.SelectedValue == "9" || selTradeType.SelectedValue == "10" || selTradeType.SelectedValue == "11" || selTradeType.SelectedValue == "12")     //普通充值 
        {
            if (strBeginNo != "" && strEndNo != "")
            {
                list.Add("P.CARDNO between '" + strBeginNo + "' and '" + strEndNo + "'");
            }
            else if (strBeginNo != "")
            {
                list.Add("P.CARDNO= '" + strBeginNo + "'");
            }
            else if (strEndNo != "")
            {
                list.Add("P.CARDNO= '" + strEndNo + "'");
            }
        }
        else if (selTradeType.SelectedValue == "2")  //充值卡售出
        {
            if (strBeginNo != "" && strEndNo != "")
            {
                list.Add("P.STARTCARDNO >= '" + strBeginNo + "' And P.ENDCARDNO <= '" + strEndNo + "'");
            }
            else if (strBeginNo != "")
            {
                list.Add("P.STARTCARDNO >= '" + strBeginNo + "'");
            }
            else if (strEndNo != "")
            {
                list.Add("P.ENDCARDNO <= '" + strEndNo + "'");
            }
        }
        else if (selTradeType.SelectedValue == "7")  //读卡器售出
        {
            if (strBeginNo != "" && strEndNo != "")
            {
                list.Add("P.BEGINSERIALNUMBER >= '" + strBeginNo + "' And P.ENDSERIALNUMBER <= '" + strEndNo + "'");
            }
            else if (strBeginNo != "")
            {
                list.Add("P.BEGINSERIALNUMBER >= '" + strBeginNo + "'");
            }
            else if (strEndNo != "")
            {
                list.Add("P.ENDSERIALNUMBER <= '" + strEndNo + "'");
            }
        }

        return list;
    }

    private ArrayList getConditionFromTime(ArrayList list)
    {
        string strBeginDate = txtBeginDate.Text.Trim();
        string strEndDate = txtEndDate.Text.Trim();

        if (selTradeType.SelectedValue == "4" || selTradeType.SelectedValue == "5" || selTradeType.SelectedValue == "6" || selTradeType.SelectedValue == "12")// 4:代理充值5：手Q充值 6：充值补登 12:省卡代理充值
        {
            if (strBeginDate != "" && strEndDate != "")
            {
                //DateTime endDate = DateTime.ParseExact(strEndDate, "yyyy-MM-dd", null);
                //endDate = endDate.AddDays(1);
                list.Add("P.OPERATETIME>= " + strBeginDate + " and P.OPERATETIME<= " + strEndDate + "");
            }
           
        }
        else
        {
            if (strBeginDate != "" && strEndDate != "")
            {
                //DateTime endDate = DateTime.ParseExact(strEndDate, "yyyyMMdd", null);
                //endDate = endDate.AddDays(1);
                list.Add("P.OPERATETIME >= to_date('" + strBeginDate + "','yyyyMMdd') and P.OPERATETIME <= to_date('" + strEndDate + "','yyyyMMdd')+1");
            }
            
        }

        return list;
    }

    private ArrayList getConditionFromDepartOrStaff(ArrayList list)
    {
        string departno = selDept.SelectedValue;
        string staffno = selStaff.SelectedValue;

        //if (selTradeType.SelectedValue == "1" || selTradeType.SelectedValue == "3" || selTradeType.SelectedValue == "4")
        //{
            if (departno != "")
            {
                list.Add("P.DEPARTNO = '" + departno + "'");
            }

            if (staffno != "")
            {
                list.Add("P.OPERATESTAFFNO = '" + staffno + "'");
            }

       // }
        //else if (selTradeType.SelectedValue == "2")
        //{
        //    if (departno != "")
        //    {
        //        list.Add("P.DEPARTNO = '" + departno + "'");
        //    }

        //    if (staffno != "")
        //    {
        //        list.Add("P.OPERATESTAFFNO = '" + staffno + "'");
        //    }
        //}

        return list;
    }
   
    private bool InputValidate()
    {
        UserCardHelper.validateDateRange(context, txtBeginDate, txtEndDate, true);
        return !(context.hasError());

    }
 

    
    public void lvwInvoice_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwInvoice.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selDept.SelectedValue);

    }
    protected void lvwInvoice_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwInvoice','Select$" + e.Row.RowIndex + "')");
        }
    }
    public void lvwInvoice_SelectedIndexChanged(object sender, EventArgs e)
    {

        string[] p = SumTax();
        string sl = p[0].ToString();//税率
        if (sl == "0")//免税
        {
            ddlProjName.SelectedValue = "*预付卡销售*";
            selProj1.Enabled = true;
        }
        else
        {
            ddlProjName.SelectedValue = "*软件*苏州市民卡卡片业务系统软件V1.0";//征税的选这个
            selProj1.SelectedIndex = 0;
            selProj1.Enabled = false;
        }


    }
    public String getDataKeys(string keysname)
    {
        string value = lvwInvoice.DataKeys[lvwInvoice.SelectedIndex][keysname].ToString();

        return value == "" ? "" : value;
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
    
    /// <summary>
    /// 根据链接获取二维码
    /// </summary>
    /// <param name="link">链接</param>
    /// <returns>返回二维码图片</returns>
    public static Bitmap GetQRCodeBmp(string link)
    {
        QRCodeEncoder qrCodeEncoder = new QRCodeEncoder();
        qrCodeEncoder.QRCodeEncodeMode = QRCodeEncoder.ENCODE_MODE.BYTE;
        qrCodeEncoder.QRCodeScale = 4;
        qrCodeEncoder.QRCodeVersion = 0;
        qrCodeEncoder.QRCodeErrorCorrect = QRCodeEncoder.ERROR_CORRECTION.M;
        Bitmap bmp = qrCodeEncoder.Encode(link, Encoding.UTF8);
        return bmp;
    }

    protected void btnQR_Click(object sender, EventArgs e)
    {
        
        if (lvwInvoice.SelectedIndex == -1)
        {
            context.AddError("未选择数据");
            return;
        }
        if (ddlProjName.SelectedValue=="")
        {
            context.AddError("请选择开票项目名称");
            return;
        }
        //if (txtRemark.Text.Trim()=="")
        //{
        //    context.AddError("请填写附注",txtRemark);
        //    return;
        //}
        //判断是否开过电子票
        //string sql = "select 1 from TF_F_ELECTRONICINVOICE where tradeid = '" + getDataKeys("TRADEID") + "' and USETAG='1'";
        //context.DBOpen("Select");
        //DataTable data = context.ExecuteReader(sql);
        //if (data.Rows.Count > 0)//已经开过电子发票
        //{
        //    context.AddError("已经开过电子发票");
        //    return;
        //}
        string[] p = SumTax();
        string sl = p[0].ToString();//税率
        string se = p[1].ToString();//税额*100
        string spbm = p[2].ToString();//商品编码

        string isFree = "";
        if (sl=="0")
        {
            isFree = "0";//免税
        }
        else
        {
            isFree = "1";
        }
        ValidSubmit();
        if (context.hasError())
            return;
        //if(hidMessage.Value!="")
        //{
        //    DialogResult result = MessageBox.Show("A004P03R04: 存在以下已经打印过的流水号:" + hidMessage.Value, "提示", MessageBoxButtons.OKCancel, MessageBoxIcon.Asterisk);
        //    if (result == DialogResult.OK)
        //    {
                
        //    }
        //    else
        //    {
        //        return;//执行Cancel的代码
        //    }
        //}
        string projectName = "";
        if (selProj1.SelectedValue=="")
        {
            projectName = ddlProjName.SelectedValue;
        }
        else
        {
            projectName = ddlProjName.SelectedValue  + selProj1.SelectedValue;//项目名称 
        }
        string sessionID = Session.SessionID;
        //记录入临时表
        FillTempTable(sessionID);
        string isSK = getDataKeys("ISSK");
        context.SPOpen();
        context.AddField("p_SESSIONID").Value = sessionID;
        context.AddField("P_KPR").Value = context.s_UserName;//开票人
        context.AddField("P_PROJECTNAME").Value = projectName;//项目名称
        context.AddField("P_ISFREE").Value = isFree;//是否免税
        context.AddField("P_ISSK").Value = getDataKeys("ISSK");//是否是省卡充值或售卡
        context.AddField("P_REMARK").Value = txtRemark.Text.Trim();//备注
        context.AddField("P_OUTORDERNO", "String", "output", "16", null);
        context.AddField("P_OUTMONEY", "Int32", "output", "", null);
        context.AddField("P_OUTCARDNO", "String", "output", "500", null);
        bool ok = context.ExecuteSP("SP_IT_InsertPrintData");

        if (ok)
        {

            string orderNo = "" + context.GetFieldValue("P_OUTORDERNO"); //自定义订单号
            string cardNo = context.GetFieldValue("P_OUTCARDNO").ToString().Substring(0, context.GetFieldValue("P_OUTCARDNO").ToString().Length-1);//打印卡号
            double totalMoney =Convert.ToDouble(context.GetFieldValue("P_OUTMONEY").ToString())/100.0;//订单总金额
            //清空临时表
            ClearTempTable(sessionID);
            hidStaffno.Value = Session["staff"].ToString();
            //string totalMoney = Convert.ToDecimal(getDataKeys("CURRENTMONEY")).ToString("0.00");
            string depart = "";
            if (getDataKeys("DEPARTNO") == "" || getDataKeys("DEPARTNO") == null)
            {
                depart = "001";
            }
            else
            {
                depart = getDataKeys("DEPARTNO");
            }
            string t = "";
            string date = DateTime.Now.ToString("yyyyMMdd");//当前时间
            if (getDataKeys("ISSK").ToString() == "1")
            {
                t = depart + "," + orderNo + "," + totalMoney + "," + date + ",91320508MA1MT3CH0H";//门店号，订单号(传TRADEID)，金额，小票日期,纳税人识别号（001代表为空）测试110109500321655
            }
            else
            {
                t = depart + "," + orderNo + "," + totalMoney + "," + date + ",9132050874558352XW";//门店号，订单号(传TRADEID)，金额，小票日期,纳税人识别号（001代表为空）测试110109500321655
            }
            //发票参数 测试用的纳税人识别号:110109500321655
           

            //市民卡key_id :0Qn9 key：IIQCKGRa  省卡key：key_id :1mvn key :RjvKMZPj
            string desString = "";
            string idString = "";
            if (getDataKeys("ISSK").ToString()=="1")
            {
                desString = DESHelper.DesEncrypt(t, "RjvKMZPj");
                idString = "&id=1mvn1&r=";
            }
            else
            {
                desString = DESHelper.DesEncrypt(t, "IIQCKGRa");//DES 加密模式：ECB 填充模式：PKCS5Padding 字符集：UTF8 加密KEY:12345678
               idString = "&id=0Qn91&r=";//测试的用:1gFd1  正式的用:0Qn9
            }
            
            string encodeString = System.Web.HttpUtility.UrlEncode(desString, System.Text.Encoding.GetEncoding("GB2312"));//进行urlencode 之后的数据
            string address = "http://www.fapiao.com/fpt-wechat/wxscan/wxkp.do?t=v3";
            
            string link = address + idString + encodeString;//三段拼接则是二维码
            Bitmap bmp = GetQRCodeBmp(link);//生成二维码

            string tradeid = getDataKeys("TRADEID");
            bmp.Save(Server.MapPath("~/tmp/") + Session["staff"].ToString() + "_" + orderNo + ".jpg");// 把文件流保存成图片文件到本地

            imgPrint.Src = "~/tmp/" + Session["staff"].ToString() + "_" + orderNo + ".jpg";//需要打印的二维码
            InitInvoicePrintControl(orderNo, cardNo, totalMoney.ToString("0.00"));

           

            ScriptManager.RegisterStartupScript(this, this.GetType(), "printPaPiaoScript", "printFaPiao();", true);
            ClearData();
        }
       
    }

    //设置发票数据
    private void InitInvoicePrintControl(string orderid,string cardno,string totalMoney)
    {
        string tradetype = "";
        if (getDataKeys("TRADETYPE").ToString().Contains("读卡器"))
        {
            tradetype = "读卡器:";
        }
        else
        {
            tradetype = "卡号:";
        }
        string printCardNo = "";
        //如果是多个卡号则显示一个卡号,.....
        if (cardno.Contains(","))
        {
            string[] t = cardno.Split(',');
            printCardNo = t[0]+",......";
        }
        else
        {
            printCardNo = cardno;
        }
        DateTime now = DateTime.Now;
        ptnFaPiao.DateTime = now.ToString("yyyy-MM-dd HH:mm");
        ptnFaPiao.DeptNo = context.s_DepartID;
        ptnFaPiao.StaffNo = context.s_UserID;
        ptnFaPiao.TradeType = tradetype;
        ptnFaPiao.CardNo = printCardNo;
        ptnFaPiao.JinE = Convert.ToDecimal(totalMoney).ToString("0.00");
        ptnFaPiao.XiaoJi = Convert.ToDecimal(totalMoney).ToString("0.00");
        ptnFaPiao.ImageUrl = "../../tmp/" + context.s_UserID + "_" + orderid + ".jpg";

    }

    //计算总税额
    private string[] SumTax()
    {
        string[] s=new string[3];
        if (getDataKeys("TRADETYPE").ToString().Contains("充值") || getDataKeys("TRADETYPE").ToString().Contains("利金卡") || getDataKeys("TRADETYPE").ToString().Contains("休闲"))//充值利金卡休闲不征税
        {
            s[0] = "0";//税率
            s[1] = "0"; //税额
            s[2] = "6010000000000000000"; //商品编码
            return s;
        }
        else if (getDataKeys("TRADETYPE").ToString().Contains("读卡器"))//读卡器税率17%
        {
            s[0] = "0.17";//税率
           // string  xmje = ((Convert.ToDouble(getDataKeys("CURRENTMONEY"))/(1 + 0.17))*100).ToString();
            s[1] = ((Convert.ToDouble(getDataKeys("CURRENTMONEY"))-Convert.ToDouble(getDataKeys("CURRENTMONEY")) /(1+0.17))*100).ToString(); //税额
            s[2] = "1090503030000000000"; //商品编码
            return s;
        }
        else if (getDataKeys("TRADETYPE").ToString().Contains("售卡"))
        {
            //卡面类型及税率
            string sql = "select t.cardno,k.cardsurfacecode,t.tradetypecode ,d.datacode,c.goodsno  from tf_b_trade t,tl_r_icuser k,TD_M_CARDSURFACE c,td_m_tax d where t.cardno=k.cardno and k.cardsurfacecode=c.cardsurfacecode(+) and c.taxno=d.taxno(+) and t.tradeid= '" + getDataKeys("TRADEID") + "' ";
            context.DBOpen("Select");
            DataTable data = context.ExecuteReader(sql);
            if (data.Rows.Count > 0)
            {
                string tax = data.Rows[0]["datacode"].ToString().Trim();
                string cardsurface = data.Rows[0]["cardsurfacecode"].ToString().Trim();
                string spbm = data.Rows[0]["goodsno"].ToString().Trim();//商品编码
                if (cardsurface.Substring(0,2)=="05")//05:利金卡 税率为0
                {
                    s[0] = "0";//税率
                    s[1] = "0"; //税额
                    s[2] = "6010000000000000000"; //商品编码
                    return s;
                }
                else 
                {
                    if (spbm == "" || tax == "")//如果库里面没配置则默认用0801市民卡B卡标准卡面用的税率及编码
                    {
                        s[0] = "0.17";//税率
                        s[1] = ((Convert.ToDouble(getDataKeys("CURRENTMONEY")) - Convert.ToDouble(getDataKeys("CURRENTMONEY"))/(1+0.17)) * 100).ToString(); //税额
                        s[2] = "3040201030000000000"; //商品编码
                        return s;
                    }
                    else
                    {
                        s[0] = tax;//税率
                        s[1] = ((Convert.ToDouble(getDataKeys("CURRENTMONEY")) - Convert.ToDouble(getDataKeys("CURRENTMONEY")) / (1 + Convert.ToDouble(tax))) * 100).ToString(); //税额
                        s[2] = spbm; //商品编码
                        return s;
                    }
                   
                }
            }
            else
            {
                s[0] = "0.17";//税率
                s[1] = ((Convert.ToDouble(getDataKeys("CURRENTMONEY")) - Convert.ToDouble(getDataKeys("CURRENTMONEY")) / (1 + 0.17)) * 100).ToString(); //税额
                s[2] = "3040201030000000000"; //商品编码
                return s;
            }

        }
        s[0] = "0.17";//税率
        s[1] = ((Convert.ToDouble(getDataKeys("CURRENTMONEY")) - Convert.ToDouble(getDataKeys("CURRENTMONEY")) / (1 + 0.17)) * 100).ToString(); //税额
        s[2] = "3040201030000000000"; //商品编码
        return  s;
    }
    private void FillDropDownList(DropDownList control, DDOBase[] data, string label, string value)
    {
        control.Items.Add(new ListItem("---请选择---", ""));
        foreach (DDOBase ddoDDOBase in data)
        {
            control.Items.Add(new ListItem(ddoDDOBase.GetString(label), ddoDDOBase.GetString(value)));
        }
    }
    private void ValidSubmit()
    {
        int count = 0;
        int isPint = 0;
        int isDept = 0;
        string error = "";
        string dept = getDataKeys("DEPARTNO"); //当前选中的部门
        for (int index = 0; index < lvwInvoice.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox) lvwInvoice.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                string volumeno = lvwInvoice.Rows[index].Cells[8].Text.Trim(); //发票代码
                string selDept = lvwInvoice.Rows[index].Cells[6].Text.Trim(); //部门
                string tradeid = lvwInvoice.Rows[index].Cells[1].Text.Trim(); //流水号
                if (volumeno != "" && volumeno != "&nbsp;")
                {
                    isPint++;
                }
                if (selDept != "&nbsp;" && selDept != dept)
                {
                    isDept++;
                }
                //string sql = "select 1 from tf_f_invoicetmp  t where t.tradeid= '" + tradeid + "' ";
                //context.DBOpen("Select");
                //DataTable data = context.ExecuteReader(sql);
                //if (data.Rows.Count > 0)
                //{
                //    error += tradeid + ",";
                //}

            }
           
        }
        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("A004P03R01: 没有选中订单记录");
        }
        if (isPint > 0)
        {
            context.AddError("A004P03R02: 不可选中已开过票的记录");
        }
        if (isDept > 0)
        {
            context.AddError("A004P03R03: 不可选中不同部门的记录");
        }
        //if (error != "")
        //{
        //    hidMessage.Value = error.Substring(0, error.Length - 1);
           
        //}

    }

    private void FillTempTable(string sessionID)
    {

        //记录入临时表
        context.DBOpen("Insert");
        for (int index = 0; index < lvwInvoice.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)lvwInvoice.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                string tradeid = lvwInvoice.Rows[index].Cells[1].Text.Trim();//流水号
                string  money = (Convert.ToDecimal(lvwInvoice.Rows[index].Cells[4].Text.Trim())*100).ToString();
                string cardno = lvwInvoice.Rows[index].Cells[2].Text.Trim();
                string tradetype = lvwInvoice.Rows[index].Cells[3].Text.Trim();
                //F0:流水号，F1：SessionID,F2 金额,F3卡号,F4业务类型
                context.ExecuteNonQuery(@"insert into TMP_SECURITYVALUEAPPROVAL (f0,f1,f2,f3,f4)
                                values('" + tradeid + "','" + sessionID + "','" + money + "','" + cardno + "','" + tradetype + "')");
            }
        }
        context.DBCommit();

    }
    private void ClearTempTable(string sessionID)
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_SECURITYVALUEAPPROVAL  where f1='" + Session.SessionID + "'");
        context.DBCommit();
    }

    private void ClearData()
    {
        txtRemark.Text = "";
        foreach (GridViewRow gvr in lvwInvoice.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = false;
        }
        //hidMessage.Value = "";
    }
   
   

}