using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TM;
using TDO.BusinessCode;
using TDO.CardManager;
using PDO.PersonalBusiness;
using System.Data;
using TDO.PersonalTrade;
using TDO.UserManager;
using PDO.CashGift;
using TDO.ResourceManager;
using Master;

public partial class ASP_CashGift_CG_CashGiftTransit :  Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            LabAsn.Attributes["readonly"] = "true";
            LabCardtype.Attributes["readonly"] = "true";
            //sDate.Attributes["readonly"] = "true";
            eDate.Attributes["readonly"] = "true";
            cMoney.Attributes["readonly"] = "true";
            txtWallet2.Attributes["readonly"] = "true";

            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";

            //设置GridView绑定的DataTable
            lvwTransitQuery.DataSource = new DataTable();
            lvwTransitQuery.DataBind();
            lvwTransitQuery.SelectedIndex = -1;

            //指定GridView DataKeyNames
            lvwTransitQuery.DataKeyNames = new string[] { "OLDCARDNO", "CARDNO", "OPERATETIME", "CARDACCMONEY", "TFLAG", "TRADEID" };

            initLoad(sender, e);
        }
    }

    protected void initLoad(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从前台业务交易费用表中读取数据
        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "55";

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

        TF_B_TRADETDO ddoTF_B_TRADEOut = (TF_B_TRADETDO)tmTMTableModule.selByPK(context, ddoTF_B_TRADEIn, typeof(TF_B_TRADETDO), null, "CashGift_Transitt", null);

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
        ChangeStaff.Text = ddoTD_M_INSIDESTAFFOut.STAFFNAME;
        ChangeTime.Text = ddoTF_B_TRADEOut.OPERATETIME.ToString("yyyy-MM-dd");
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
        strChange += " FROM TF_B_TRADE a,TF_F_CARDEWALLETACC b WHERE a.CARDNO = '" + newCardNo.Value + "' AND a.TRADETYPECODE " +
                    " IN ('54') AND b.CARDNO = a.OLDCARDNO AND a.CANCELTAG = '0'";

        DataTable dataChange = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strChange, 0);

        //换卡记录不存在
        if (dataChange.Rows.Count == 0)
        {
            context.AddError("A001005120");
        }

        //换卡记录存在
        else if (dataChange.Rows.Count != 0)
        {
            //查询转值记录
            string strTransit = "SELECT CARDNO FROM TF_B_TRADE WHERE CARDNO = '" + newCardNo.Value + "' AND TRADETYPECODE = '55' AND CANCELTAG = '0'";
            DataTable dataTransit = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strTransit, 0);

            //转值记录不存在
            if (dataTransit.Rows.Count == 0)
            {
                //换卡时间和当前时间差小于7天
                ChangeRecord.Value = "0";
                if (Convert.ToDateTime(dataChange.Rows[0][3].ToString()).AddDays(7) >= DateTime.Now)
                {
                    context.AddError("A001005122");
                    return dataChange;
                }
                //换卡时间和当前时间差大于7天
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

        while (i != 0)
        {
            //查询以往换卡记录
            string strChangeOld = "SELECT a.TRADEID, a.CARDNO,a.OLDCARDNO,a.OPERATETIME,b.CARDACCMONEY/100.0 CARDACCMONEY, '1' TFLAG ";
            strChangeOld += " FROM TF_B_TRADE a,TF_F_CARDEWALLETACC b WHERE a.CARDNO = '" + newCardNo.Value + "' AND " +
                            " a.TRADETYPECODE IN ('54') AND b.CARDNO = a.OLDCARDNO AND a.CANCELTAG = '0' ";
            DataTable dataChangeOld = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strChangeOld, 0);

            if (dataChangeOld.Rows.Count == 0)
                break;

            //查询转值记录

            string strTransitOld = "SELECT CARDNO FROM TF_B_TRADE WHERE OLDCARDNO = '" + dataChangeOld.Rows[0][2].ToString() + "' AND TRADETYPECODE = '55' AND CANCELTAG = '0'";
            DataTable dataTransitOld = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strTransitOld, 0);

            //没有转值记录
            if (dataTransitOld.Rows.Count == 0)
            {
                //换卡时间超过7天
                if (Convert.ToDateTime(dataChangeOld.Rows[0][3].ToString()).AddDays(7) <= DateTime.Now)
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

                else if (Convert.ToDateTime(dataChangeOld.Rows[0][3].ToString()).AddDays(7) > DateTime.Now)
                {
                    context.AddError("A001005122");
                    TransitMoney = 0;
                    dataChange.Rows.Clear();
                    break;
                }
            }
            else if (dataTransitOld.Rows.Count != 0)
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
        TMTableModule tmTMTableModule = new TMTableModule();

        //卡账户有效性检验
        checkCashGiftAccountInfo(txtCardno.Text);

        if (!context.hasError())
        {
          
            //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据

            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
            ddoTD_M_CARDTYPEIn.CARDTYPECODE = txtCardno.Text.Substring(4, 2);

            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

            //从用户卡库存表(TL_R_ICUSER)中读取数据
            TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
            ddoTL_R_ICUSERIn.CARDNO = txtCardno.Text;

            TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

            if (ddoTL_R_ICUSEROut == null)
            {
                context.AddError("A001004128");
                return;
            }

            if (Convert.ToDecimal(hiddenWallet2.Value) * 100 != ddoTL_R_ICUSEROut.CARDPRICE)
            {
                context.AddError("电子钱包2不为10元,不能转值");
                return;
            }

            
            //给页面显示项赋值
            LabAsn.Text = hiddenASn.Value.Substring(4, 16);
            LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
            //sDate.Text = hiddensDate.Value;
            eDate.Text = hiddeneDate.Value;
            cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / 100).ToString("0.00");
            txtWallet2.Text = hiddenWallet2.Value;

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
        SP_CG_TransitBalancePDO pdo = new SP_CG_TransitBalancePDO();
        pdo.SESSIONID = Session.SessionID;
        pdo.NEWCARDNO = txtCardno.Text;
        pdo.OLDCARDNO = txtOCardno.Text;
        pdo.TRADETYPECODE = "55";
        pdo.NEWCARDACCMONEY = Convert.ToInt32(Convert.ToDecimal(cMoney.Text) * 100);
        pdo.CURRENTMONEY = Convert.ToInt32((Convert.ToDecimal(TransitBalance.Text) * 100) - (Convert.ToDecimal(hiddenWallet2.Value) * 100));
        pdo.OLDCARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;
        pdo.PREMONEY = Convert.ToInt32(hiddencMoney.Value);
        pdo.ASN = LabAsn.Text;
        pdo.CARDTRADENO = hiddentradeno.Value;
        pdo.CARDTYPECODE = txtCardno.Text.Substring(4, 2);
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


        hidSupplyMoney.Value = "" + (pdo.CURRENTMONEY);

        string writeCardScript = "chargeCard();";
        pdo.writeCardScript = writeCardScript;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M001005001");
            //写卡
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                writeCardScript, true);
            btnPrintPZ.Enabled = true;

            hidCardnoForCheck.Value = txtCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致

            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, hidCustname.Value, "转值", "0.00"
                , "", "", hidPaperno.Value, (Convert.ToDecimal(pdo.CURRENTMONEY + pdo.PREMONEY) / (Convert.ToDecimal(100))).ToString("0.00"),
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