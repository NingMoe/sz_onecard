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
using TDO.BusinessCode;
using TDO.CardManager;
using PDO.PersonalBusiness;
using TDO.PersonalTrade;
using TDO.UserManager;
using Common;
using Master;

public partial class ASP_PersonalBusiness_PB_TransitBalance : Master.FrontMaster
{
    private static int par_ChangeSpan = 7;       //换卡转值时长限制
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            LabAsn.Attributes["readonly"] = "true";
            LabCardtype.Attributes["readonly"] = "true";
            sDate.Attributes["readonly"] = "true";
            eDate.Attributes["readonly"] = "true";
            cMoney.Attributes["readonly"] = "true";

            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";

            //设置GridView绑定的DataTable
            lvwTransitQuery.DataSource = new DataTable();
            lvwTransitQuery.DataBind();
            lvwTransitQuery.SelectedIndex = -1;

            //指定GridView DataKeyNames
            lvwTransitQuery.DataKeyNames = new string[] { "OLDCARDNO", "CARDNO", "OPERATETIME", "CARDACCMONEY","TFLAG","TRADEID" };

            //创建转值的临时表
            //createTempTable();

            initLoad(sender, e);
        }
    }
    //private void createTempTable()
    //{
    //    //创建临时表

    //    context.DBOpen("Select");
    //    context.ExecuteNonQuery("exec SP_PB_CreateTmp");
    //}
    protected void initLoad(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //从系统参数表中读取换卡转值时长限制
        TD_M_TAGTDO ddoTD_M_TAGTDOIn = new TD_M_TAGTDO();
        ddoTD_M_TAGTDOIn.TAGCODE = "PB_TBCHANGE_SPAN";//取得是换卡卡的时长限制
        TD_M_TAGTDO[] ddoTD_M_TAGTDOOutArr = (TD_M_TAGTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TAGTDOIn, "S001002125");
        if (ddoTD_M_TAGTDOOutArr[0].TAGVALUE != null)
        {
            par_ChangeSpan = Convert.ToInt16(ddoTD_M_TAGTDOOutArr[0].TAGVALUE);
        }
        //从前台业务交易费用表中读取数据
        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "04";

        TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001002125", "TD_M_TRADEFEE", null);

        for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        {
            if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "03")
                ProcedureFee.Text = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "99")
                OtherFee.Text = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        }
        Total.Text = (Convert.ToDecimal(ProcedureFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");
        TransitBalance.Text = "0.00";
        Transit.Enabled = false;
    }
    protected void ChangeInfo(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //从业务台帐主表中读取数据
        TF_B_TRADETDO ddoTF_B_TRADEIn = new TF_B_TRADETDO();
        ddoTF_B_TRADEIn.CARDNO = txtCardno.Text;
        TF_B_TRADETDO ddoTF_B_TRADEOut = (TF_B_TRADETDO)tmTMTableModule.selByPK(context, ddoTF_B_TRADEIn, typeof(TF_B_TRADETDO), null, "TF_B_TRADE_Transit", null);
        //string str = " SELECT OLDCARDNO,REASONCODE,OPERATSTAFFNO,OPERATSTIME FROM TF_B_TRADE " +
        //             " WHERE CARDNO = '" + txtCardno.Text + "' AND TRADETYPECODE IN ('03','73','74','75) " +
        //             " AND CANCELTAG = '0' ";
        //DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, str, 0);
        if (ddoTF_B_TRADEOut == null)
        {
            context.AddError("A001005109");
            return;
        }
        //从退还卡原因编码表中读取数据
        TD_M_REASONTYPETDO ddoTD_M_REASONTYPEIn = new TD_M_REASONTYPETDO();
        ddoTD_M_REASONTYPEIn.REASONCODE = ddoTF_B_TRADEOut.REASONCODE;

        TD_M_REASONTYPETDO ddoTD_M_REASONTYPEOut = (TD_M_REASONTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_REASONTYPEIn, typeof(TD_M_REASONTYPETDO), null, "TD_M_REASONTYPE_Destroy", null);

        //从内部员工编码表中读取数据
        TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        ddoTD_M_INSIDESTAFFIn.STAFFNO = ddoTF_B_TRADEOut.OPERATESTAFFNO;

        TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFOut = (TD_M_INSIDESTAFFTDO)tmTMTableModule.selByPK(context, ddoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_Destroy", null);

        //给页面显示项赋值
        txtOCardno.Text = ddoTF_B_TRADEOut.OLDCARDNO;
        Reasontype.Text = ddoTD_M_REASONTYPEOut.REASON;
        if (ddoTD_M_INSIDESTAFFOut != null)
        {
            ChangeStaff.Text = ddoTD_M_INSIDESTAFFOut.STAFFNAME;
        }
        else
        {
            ChangeStaff.Text = "市民卡换卡";
        }
        ChangeTime.Text = ddoTF_B_TRADEOut.OPERATETIME.ToString("yyyy-MM-dd");

        //if (ddoTF_B_TRADETDOOut.OPERATETIME.AddDays(7) < DateTime.Now)
        //{
        //    context.AddError("A001003102");
        //    return;
        //}
    }

    public void lvwTransitQuery_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwTransitQuery.PageIndex = e.NewPageIndex;
        lvwTransitQuery.DataSource = CreateChangeQueryDataSource();
        lvwTransitQuery.DataBind();
    }


    protected void lvwTransitQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow)
        {
            //隐藏记录流水和标志位
            e.Row.Cells[4].Visible = false;
            e.Row.Cells[5].Visible = false;
        }

    }


    public DataTable CreateChangeQueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
       
        Decimal TransitMoney = 0;
        //DataView dataView = null;
        newCardNo.Value = txtCardno.Text;

        //查询本次换卡记录
        TF_B_TRADETDO ddoTF_B_TRADEIn = new TF_B_TRADETDO();
        string strChange = "SELECT a.TRADEID, a.CARDNO,a.OLDCARDNO,a.OPERATETIME,b.CARDACCMONEY/100.0 CARDACCMONEY,'0' TFLAG ";
        strChange += " FROM TF_B_TRADE a,TF_F_CARDEWALLETACC b WHERE a.CARDNO = '" + newCardNo.Value + "' AND a.TRADETYPECODE "+
                    " IN ('03','73','74','75','7C','E3') AND b.CARDNO = a.OLDCARDNO AND a.CANCELTAG = '0'"+
                    " AND not exists (select 1 from tf_b_trade c where c.cardno = a.oldcardno and c.tradetypecode = '5C' and c.canceltag='0')";

        DataTable dataChange = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strChange, 0);

        //换卡记录不存在
        if (dataChange.Rows.Count == 0)
        {
            string strEwChange = "SELECT a.TRADEID, a.CARDNO,a.OLDCARDNO," +
                                " (case " +
                                "  when c.REASONCODE in('12','13') then TO_DATE(TO_CHAR(c.OPERATETIME,'YYYYMMDD'),'YYYYMMDD')-7" +
                                "  else c.OPERATETIME" +
                                "  end) OPERATETIME," +
                                " (case" +
                                "  when a.reasoncode in('14','15') then b.CARDACCMONEY/100.0 " +
                                "  else c.OLDCARDMONEY/100.0" +
                                "  end)CARDACCMONEY, '0' TFLAG " +
                                " FROM TF_B_TRADE a,TF_F_CARDEWALLETACC b,TF_B_TRADE c WHERE a.CARDNO = '" + newCardNo.Value + "'" +
                                " AND a.TRADETYPECODE IN ('03','73','74','75','7C','E3') " +
                                " AND b.CARDNO = a.OLDCARDNO " +
                                " AND a.CANCELTAG = '0'" +
                                " AND a.OLDCARDNO = c.CARDNO" +
                                " AND c.TRADETYPECODE = '5C' " +
                                " AND c.CANCELTAG = '0'";
            dataChange = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strEwChange, 0);
            if (dataChange.Rows.Count == 0)
            {
                context.AddError("A001005120");
                return dataChange;
            }
        }

        //换卡记录存在

        //查询转值记录
        string strTransit = "SELECT CARDNO FROM TF_B_TRADE WHERE CARDNO = '" + newCardNo.Value + "' AND TRADETYPECODE = '04' AND CANCELTAG = '0'";
        DataTable dataTransit = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strTransit, 0);

        //转值记录不存在
        if (dataTransit.Rows.Count == 0)
        {
            //换卡时间和当前时间差小于7天
            ChangeRecord.Value = "0";
            if (Convert.ToDateTime(dataChange.Rows[0][3].ToString()).AddDays(par_ChangeSpan) >= DateTime.Now)
            {
                context.AddError("A001005122");
                return dataChange;
            }
            ////换卡时间和当前时间差大于7天
            else
            {
                TransitMoney = Convert.ToDecimal(dataChange.Rows[0][4].ToString());
                //更新卡号
                newCardNo.Value = dataChange.Rows[0][2].ToString();
                //查询以往换卡转值
                Transithistory(dataChange, TransitMoney);
            }
        }

        //转值记录存在
        else if (dataTransit.Rows.Count != 0)
        {
            //更新卡号
            newCardNo.Value = dataChange.Rows[0][2].ToString();
            ChangeRecord.Value = "1";
            dataChange.Rows.Clear();
            //查询以往换卡转值
            Transithistory(dataChange, TransitMoney);
        }  
       
        
        //dataView = new DataView(dataChange);
        return dataChange;
    }

    public DataTable Transithistory(DataTable dataChange, Decimal TransitMoney)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        TF_B_TRADETDO ddoTF_B_TRADEIn = new TF_B_TRADETDO();
        DataRow relation;
        int i = 1;
        ArrayList al = new ArrayList();//存放某个旧卡之前的所有新卡
        al.Add(txtCardno.Text);
        while (i != 0)
        {
            
            al.Add(newCardNo.Value);
            //查询以往换卡记录
            string strChangeOld = "SELECT a.TRADEID, a.CARDNO,a.OLDCARDNO,a.OPERATETIME,b.CARDACCMONEY/100.0 CARDACCMONEY, '1' TFLAG ";
            strChangeOld += " FROM TF_B_TRADE a,TF_F_CARDEWALLETACC b WHERE a.CARDNO = '" + newCardNo.Value + "' AND "+
                            " a.TRADETYPECODE IN ('03','73','74','75','7C','E3') AND b.CARDNO = a.OLDCARDNO AND a.CANCELTAG = '0' "+
                            " AND not exists (select 1 from tf_b_trade c where c.cardno = a.oldcardno and c.tradetypecode = '5C' and c.canceltag='0')";
            DataTable dataChangeOld = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strChangeOld, 0);
            if (dataChangeOld.Rows.Count == 0)
            {
                string strEwChange = "SELECT a.TRADEID, a.CARDNO,a.OLDCARDNO," +
                    " (case " +
                    "  when c.REASONCODE in('12','13') then TO_DATE(TO_CHAR(c.OPERATETIME,'YYYYMMDD'),'YYYYMMDD')-7" +
                    "  else c.OPERATETIME" +
                    "  end) OPERATETIME," +
                    " (case" +
                    "  when a.reasoncode in('14','15') then b.CARDACCMONEY/100.0 " +
                    "  else c.OLDCARDMONEY/100.0" +
                    "  end)CARDACCMONEY, '1' TFLAG " +
                    " FROM TF_B_TRADE a,TF_F_CARDEWALLETACC b,TF_B_TRADE c WHERE a.CARDNO = '" + newCardNo.Value + "'" +
                    " AND a.TRADETYPECODE IN ('03','73','74','75','7C','E3') " +
                    " AND b.CARDNO = a.OLDCARDNO " +
                    " AND a.CANCELTAG = '0'" +
                    " AND a.OLDCARDNO = c.CARDNO" +
                    " AND c.TRADETYPECODE = '5C' " +
                    " AND c.CANCELTAG = '0'";
                dataChangeOld = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strEwChange, 0);

                if (dataChangeOld.Rows.Count == 0)
                {
                    break;
                }
            }
            //查询转值记录
            //查询换卡转值限制记录
            context.DBOpen("Select");
            string strTransitLimitSql = @"SELECT CARDNO FROM TF_B_TRANSITLIMIT WHERE CARDNO = '" + dataChangeOld.Rows[0][2].ToString() + "' AND STATE = '0'";
            DataTable dataTransitLimit = context.ExecuteReader(strTransitLimitSql);

            DataTable dataTransitOld = new DataTable();
            //如果旧卡没有转值限制，则正常查询是否有转值记录。否则查询再早的记录
            if (dataTransitLimit.Rows.Count == 0)
            {
                string strtemp = "";
                foreach (string cardnotemp in al)
                {
                    strtemp = strtemp + " CARDNO='" + cardnotemp + "' OR";//把所有旧卡之前的新卡全都累加起来
                }
                strtemp = " (" + strtemp.Substring(0, strtemp.Length - 2) + ") ";
                string strTransitOld = "SELECT CARDNO FROM TF_B_TRADE WHERE " + strtemp + " AND OLDCARDNO = '" + dataChangeOld.Rows[0][2].ToString() + "' AND TRADETYPECODE = '04' AND CANCELTAG = '0'";
                dataTransitOld = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strTransitOld, 0);
            }

            //没有转值记录
            if (dataTransitOld.Rows.Count == 0 && dataTransitLimit.Rows.Count == 0)
            {
                //换卡时间超过7天
                if (Convert.ToDateTime(dataChangeOld.Rows[0][3].ToString()).AddDays(par_ChangeSpan) <= DateTime.Now)
                {
                    //更新卡号
                    newCardNo.Value = dataChangeOld.Rows[0][2].ToString();
                    //累加金额
                    TransitMoney = TransitMoney + Convert.ToDecimal(dataChangeOld.Rows[0][4].ToString());
                    relation = dataChange.NewRow();
                    relation = dataChangeOld.Rows[0];
                    dataChange.ImportRow(relation);
                }
                //换卡时间不足7天
                else if (Convert.ToDateTime(dataChangeOld.Rows[0][3].ToString()).AddDays(par_ChangeSpan) > DateTime.Now)
                {
                    context.AddError("A001005122");
                    TransitMoney = 0;
                    dataChange.Rows.Clear();
                    break;
                }
            }
            else
            {
                //更新卡号
                newCardNo.Value = dataChangeOld.Rows[0][2].ToString();
            }
        }

        TransitBalance.Text = TransitMoney.ToString("0.00");
        return dataChange;
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        Transit.Enabled = false;
        TMTableModule tmTMTableModule = new TMTableModule();

        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据

            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
            ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;

            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

            //给页面显示项赋值

            LabAsn.Text = hiddenAsn.Value.Substring(4, 16);
            LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
           
            sDate.Text = hiddensDate.Value.Substring(0, 4) + "-" + hiddensDate.Value.Substring(4, 2) + "-" + hiddensDate.Value.Substring(6, 2);
            eDate.Text = hiddeneDate.Value.Substring(0, 4) + "-" + hiddeneDate.Value.Substring(4, 2) + "-" + hiddeneDate.Value.Substring(6, 2);
            cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / 100).ToString("0.00");

            //查询开通功能
            PBHelper.openFunc(context, openFunc, txtCardno.Text);

            //查询换卡信息
            ChangeInfo(sender, e);
            if (context.hasError()) return;
            //查询转值信息

            lvwTransitQuery.DataSource = CreateChangeQueryDataSource();
            lvwTransitQuery.DataBind();

            if (lvwTransitQuery.Rows.Count <= 0) return;

            if (context.hasError()) return;

            Transit.Enabled = true;
            btnPrintPZ.Enabled = false;
        }
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")
        {
            Transit.Enabled = false;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            AddMessage("前台写卡成功");
            clearCustInfo(txtCardno);
        }
        else if (hidWarning.Value == "writeFail")
        {
            context.AddError("前台写卡失败");
        }
        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }
        hidWarning.Value = "";
        hidCardnoForCheck.Value = "";//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致
    }

    private void RecordIntoTmp()
    {
        //记录入临时表
        context.DBOpen("Insert");
        int seq = 0;
        foreach (GridViewRow gvr in lvwTransitQuery.Rows)
        {
            if (gvr.Cells[4].Text == "1")
            {
                context.ExecuteNonQuery("insert into TMP_PB_TransitBalance values('" + Session.SessionID + "'," + (seq++) + ",'" + gvr.Cells[5].Text + "')");
            }
        }
        context.DBCommit();

    }

    private void clearTempTable()
    {
        //清空临时表
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_PB_TransitBalance where SESSIONID='" + Session.SessionID + "'");
        context.DBCommit();
    }

    protected void Transit_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //库内余额为负时,不能进行转值
        if (Convert.ToDecimal(TransitBalance.Text) < 0)
        {
            context.AddError("A001005123");
            return;
        }
        //清空临时表数据
        clearTempTable();

        //向临时表中插入数据
        RecordIntoTmp();

        //从IC卡电子钱包账户表中读取数据
        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtOCardno.Text;
        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null, "TF_F_CARDEWALLETACC", null);

        //存储过程赋值
        SP_PB_TransitBalancePDO pdo = new SP_PB_TransitBalancePDO();
        pdo.SESSIONID = Session.SessionID;
        pdo.NEWCARDNO = txtCardno.Text;
        pdo.OLDCARDNO = txtOCardno.Text;
        pdo.TRADETYPECODE = "04";
        pdo.NEWCARDACCMONEY = Convert.ToInt32(Convert.ToDecimal(cMoney.Text) * 100);
        pdo.CURRENTMONEY = Convert.ToInt32(Convert.ToDecimal(TransitBalance.Text) * 100);
        pdo.OLDCARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;
        pdo.PREMONEY = Convert.ToInt32(hiddencMoney.Value);
        pdo.ASN = LabAsn.Text;
        pdo.CARDTRADENO = hiddentradeno.Value;
        pdo.CARDTYPECODE = hiddenLabCardtype.Value;
        pdo.CHANGERECORD = ChangeRecord.Value;
        pdo.TERMNO = "112233445566";
        pdo.OPERCARDNO = context.s_CardID;

        //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据

        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
        ddoTF_F_CUSTOMERRECIn.CARDNO = txtOCardno.Text;

        //UPDATE BY JIANGBB 2012-04-19解密
        DDOBase ddoBase = (DDOBase)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

        ddoBase = CommonHelper.AESDeEncrypt(ddoBase);
        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)ddoBase;
        //TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

        if (ddoTF_F_CUSTOMERRECOut == null)
        {
            context.AddError("A001107112");
            return;
        }
        hidCustname.Value = ddoTF_F_CUSTOMERRECOut.CUSTNAME;
        hidPaperno.Value = ddoTF_F_CUSTOMERRECOut.PAPERNO;

        //从证件类型编码表(TD_M_PAPERTYPE)中读取数据

        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
        ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);

        //证件类型赋值

        if (ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE != "")
        {
            hidPapertype.Value = ddoTD_M_PAPERTYPEOut.PAPERTYPENAME;
        }
        else hidPapertype.Value = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;


        hidSupplyMoney.Value = "" + pdo.CURRENTMONEY;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M001005001");
            //写卡
            hidCardReaderToken.Value = cardReader.createToken(context);
            hidCardnoForCheck.Value = txtCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致

            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                "chargeCard();", true);
            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, hidCustname.Value, "转值", "0.00"
                , "", "", hidPaperno.Value, (Convert.ToDecimal(pdo.CURRENTMONEY+pdo.PREMONEY) / (Convert.ToDecimal(100))).ToString("0.00"),
                "", (Convert.ToDecimal(pdo.CURRENTMONEY) / (Convert.ToDecimal(100))).ToString("0.00"), context.s_UserID, context.s_DepartName,
                hidPapertype.Value, OtherFee.Text, "0.00");

            //foreach (Control con in this.Page.Controls)
            //{
            //    ClearControl(con);
            //}
            ChangeRecord.Value = "0";
            //重新初始化
            initLoad(sender, e);
        }
    }
}
