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
using TDO.CardManager;
using PDO.PersonalBusiness;
using TDO.PersonalTrade;
using System.Text.RegularExpressions;
using System.Xml;
using System.Collections.Specialized;
using Common;

public partial class ASP_AddtionalService_AS_MonthCardRetrade : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";

            LabCardtype.Attributes["readonly"] = "true";
            sDate.Attributes["readonly"] = "true";
            cMoney.Attributes["readonly"] = "true";

            //初始化token
            string token;
            string sql = "SELECT SYSDATE FROM DUAL";

            TMTableModule tm = new TMTableModule();
            DataTable dt = tm.selByPKDataTable(context, sql, 1);
            DateTime now = (DateTime)dt.Rows[0].ItemArray[0];
            TimeSpan epochTime = (now.ToUniversalTime() - new DateTime(1970, 1, 1));
            token = Token.createToken(context.s_CardID, (uint)epochTime.TotalSeconds);

            hidCardReaderToken1.Value = token;

            //设置GridView绑定的DataTable
            lvwQuery.DataSource = new DataTable();
            lvwQuery.DataBind();
            lvwQuery.SelectedIndex = -1;

            //指定GridView DataKeyNames
            lvwQuery.DataKeyNames = new string[] { "TRADEID", "TRADETYPE", "OPERATETIME", "strCardNo", 
                "lMoney", "lOldMoney","strTermno","strEndDateNum","strFlag",
                "STAFFNAME","TRADETYPECODE","Cardtradeno","writeCardScript","rsrv1","rsrv2" };

        }
    }
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据

        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

        LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
        sDate.Text = hiddensDate.Value.Substring(0, 4) + "-" + hiddensDate.Value.Substring(4, 2) + "-" + hiddensDate.Value.Substring(6, 2);
        cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / (Convert.ToDecimal(100))).ToString("0.00");

        lvwQuery.DataSource = CreateQueryDataSource();
        lvwQuery.DataBind();

        if (lvwQuery.Rows.Count > 0)
        {
            lvwQuery.SelectedIndex = 0;

            GridViewRow gv = lvwQuery.Rows[0];

            hiddenID.Value = gv.Cells[0].Text;
            hiddenTRADETYPECODE.Value = gv.Cells[10].Text;
            hiddenOPERATETIME.Value = gv.Cells[2].Text;
            hidOPERATENO.Value = gv.Cells[9].Text;


            hiddenlOldMoney.Value = Convert.ToString((Convert.ToDecimal(gv.Cells[5].Text)) * 100);
            hiddencMoney.Value = "" + Convert.ToDecimal(gv.Cells[5].Text) * 100;
            hidSupplyMoney.Value = "" + Convert.ToDecimal(gv.Cells[4].Text) * 100;
            hidChargeMoney.Value = "" + Convert.ToDecimal(gv.Cells[5].Text) * 100;
            hidUnSupplyMoney.Value = "" + Convert.ToDecimal(gv.Cells[4].Text) * 100;

            //获取月票卡写卡函数
            if (hiddenTRADETYPECODE.Value == "73" || hiddenTRADETYPECODE.Value == "74"|| hiddenTRADETYPECODE.Value == "75")
            {
                hidMonthlyFlag.Value = gv.Cells[14].Text;
                hidMonthlyFlagYearCheck.Value = gv.Cells[13].Text;
                hidMonthlyFlagChange.Value = gv.Cells[12].Text;
            }
            else
            {
                hidMonthlyFlag.Value = gv.Cells[12].Text;
                hidMonthlyFlagYearCheck.Value= gv.Cells[13].Text;
                hidMonthlyFlagChange.Value = gv.Cells[14].Text;

                hidMonthlyYearCheck.Value = gv.Cells[13].Text;
                hidMonthlyUpgrade.Value = gv.Cells[14].Text;
            }
            

        }

        Subcommit.Enabled = true;
    }
    public ICollection CreateQueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从业务写卡台帐表中读取数据

        TF_CARD_TRADETDO ddoTF_CARD_TRADEIn = new TF_CARD_TRADETDO();
        string str = " SELECT * from ( SELECT a.TRADEID,c.TRADETYPE TRADETYPE,a.OPERATETIME,b.STAFFNAME,a.strCardNo,a.lMoney/100.0 lMoney, "+
                     "a.lOldMoney / 100.0 lOldMoney,a.strTermno,a.strEndDateNum,a.strFlag, "+
                     "a.TRADETYPECODE, a.Cardtradeno, a.writeCardScript ,a.rsrv1, a.rsrv2 "+
                     "FROM TF_CARD_TRADE a, TD_M_INSIDESTAFF b,TD_M_TRADETYPE c " +
                     "WHERE a.strCardNo = "+txtCardno.Text+" "+
                     "AND a.TRADETYPECODE = c.TRADETYPECODE " +
                     "AND a.stropercardno = b.staffno " +
                     "order by a.OPERATETIME desc, a.TRADEID desc ) " +
                     "WHERE ROWNUM < 13 ";

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTF_CARD_TRADEIn, null, str, 0);


        DataView dataView = new DataView(data);
        return dataView;
    }

    public void lvwQuery_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwQuery.PageIndex = e.NewPageIndex;
        lvwQuery.DataSource = CreateQueryDataSource();
        lvwQuery.DataBind();
    }

    protected void lvwQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[13].Visible = false;
        }
    }
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "rewriteCard") // 重新写卡，生产新的令牌
        {
            if (hiddenTRADETYPECODE.Value == "02")
            {
                hidCardReaderToken.Value = cardReader.createToken(context);
                ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "writeCardWithCheck();", true);
            }
            else
            {
                hidCardReaderToken.Value = cardReader.createToken(context);
                ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "writeCard();", true);
            }
        }
        else if (hidWarning.Value == "yes")
        {
            Subcommit.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            if (hiddenTRADETYPECODE.Value == "02")
            {
                SP_PB_updateCardTradePDO pdo = new SP_PB_updateCardTradePDO();
                pdo.CARDTRADENO = hiddentradeno.Value;
                pdo.TRADEID = hiddenID.Value;

                bool ok = TMStorePModule.Excute(context, pdo);

                if (ok)
                {
                    AddMessage("前台写卡成功");
                }
            }
            else
            {
                AddMessage("前台写卡成功");
            }
            if (!string.IsNullOrEmpty(hidWriteCardFailInfo.Value) && hiddenTRADETYPECODE.Value == "03")
            {
                context.AddError("获取轨交次数失败,请更新控件后补写卡");
            }       
        }
        else if (hidWarning.Value == "writeFail")
        {
            context.AddError("前台写卡失败");
        }

        hidWarning.Value = "";
        hidCardnoForCheck.Value = "";//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致

    }
    private string OperdStr(string strOper)
    {
        //先把司机卡号转换为ASCII,再把ASCII转换为16进制,才能写卡
        string tmpCardNo = "";
        foreach (char c in strOper)
        {
            int tmp = c;
            //69 52 53 54 55 56
            tmpCardNo += String.Format("{0:x}", tmp);
        }
        return tmpCardNo;
    }

    //判断业务类型是否在集合中 
    private bool validIn(string para)
    {
        string[] strValues = { "3E", "3G", "3L", "3M", "3P", "3Q" ,
                               "71", "72", "73", "74", "75", "76" };

        for (int i = 0; i < strValues.Length; i++)
        {
            if (strValues[i].Contains(para))
            {
                return true;
            }
        }

        return false;
    }

    protected void Subcommit_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //判断是否返销业务或退卡业务

        if (!(hiddenTRADETYPECODE.Value == "A1" || hiddenTRADETYPECODE.Value == "A3" || hiddenTRADETYPECODE.Value == "A5"
            || hiddenTRADETYPECODE.Value == "C3" || hiddenTRADETYPECODE.Value == "D1" || hiddenTRADETYPECODE.Value == "D2"
            || hiddenTRADETYPECODE.Value == "H0" || hiddenTRADETYPECODE.Value == "H1" || hiddenTRADETYPECODE.Value == "H2"
            || hiddenTRADETYPECODE.Value == "H3" || hiddenTRADETYPECODE.Value == "H4" || hiddenTRADETYPECODE.Value == "H5"
            || hiddenTRADETYPECODE.Value == "05" || hiddenTRADETYPECODE.Value == "F0" || hiddenTRADETYPECODE.Value == "F1"
            || hiddenTRADETYPECODE.Value == "F4" || hiddenTRADETYPECODE.Value == "K1" || hiddenTRADETYPECODE.Value == "E2"
            || hiddenTRADETYPECODE.Value == "E4"))
        {


            context.SPOpen();

            context.AddField("p_CARDNO").Value = txtCardno.Text;

            bool ok1 = context.ExecuteSP("SP_Credit_Check");

            if (ok1)
            {
                //所选记录为充值类业务时,查询是否有新的充值类业务
                if (hiddenTRADETYPECODE.Value == "02" || hiddenTRADETYPECODE.Value == "04" ||
                    hiddenTRADETYPECODE.Value == "21" || hiddenTRADETYPECODE.Value == "96" ||
                    hiddenTRADETYPECODE.Value == "98" || hiddenTRADETYPECODE.Value == "50" ||
                    hiddenTRADETYPECODE.Value == "51" || hiddenTRADETYPECODE.Value == "54" ||
                    hiddenTRADETYPECODE.Value == "55" || hiddenTRADETYPECODE.Value == "5B" || hiddenTRADETYPECODE.Value == "8H")
                {
                    if (hidOPERATENO.Value != context.s_UserName)
                    {
                        context.AddError("A001015105");
                        return;
                    }
                    if (Convert.ToDateTime(hiddenOPERATETIME.Value) < DateTime.Today)
                    {
                        context.AddError("A001021100");
                        return;
                    }
                    if (hidCardtradeno.Value != hiddentradeno.Value)
                    {
                        context.AddError("A001015104");
                        return;
                    }

                    TF_CARD_TRADETDO ddoTF_CARD_TRADEIn = new TF_CARD_TRADETDO();
                    ddoTF_CARD_TRADEIn.strCardNo = txtCardno.Text;
                    ddoTF_CARD_TRADEIn.OPERATETIME = Convert.ToDateTime(hiddenOPERATETIME.Value);
                    TF_CARD_TRADETDO ddoTF_CARD_TRADEOut = (TF_CARD_TRADETDO)tmTMTableModule.selByPK(context,
                            ddoTF_CARD_TRADEIn, typeof(TF_CARD_TRADETDO), null, "TF_CARD_TRADE_RETRADE", null);

                    if (ddoTF_CARD_TRADEOut != null && (
                        ddoTF_CARD_TRADEOut.TRADETYPECODE == "02" || ddoTF_CARD_TRADEOut.TRADETYPECODE == "04"
                        || ddoTF_CARD_TRADEOut.TRADETYPECODE == "21" || ddoTF_CARD_TRADEOut.TRADETYPECODE == "96"
                        || ddoTF_CARD_TRADEOut.TRADETYPECODE == "98" || ddoTF_CARD_TRADEOut.TRADETYPECODE == "5B" || ddoTF_CARD_TRADEOut.TRADETYPECODE == "8H"))
                    {
                        context.AddError("A001015102");
                        return;
                    }
                }
            }
            else return;
        }
        //判断业务类型
        if (validIn(hiddenTRADETYPECODE.Value))
        {
            SP_PB_RetradePDO pdo = new SP_PB_RetradePDO();
            pdo.CARDNO = txtCardno.Text;
            pdo.ID = hiddenID.Value;

            bool ok = TMStorePModule.Excute(context, pdo);

            if (ok)
            {
                #region 业务过程
                hidCardnoForCheck.Value = txtCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致

                //业务类型为月票卡开通时
                if (hiddenTRADETYPECODE.Value == "3E")
                {
                    if (hidOPERATENO.Value != context.s_UserName)
                    {
                        context.AddError("A001015105");
                        return;
                    }
                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                    "startMonthlyInfoNew();", true);
                }

                //业务类型为月票卡年审时
                else if ( hiddenTRADETYPECODE.Value == "3G")
                {
                    if (hidOPERATENO.Value != context.s_UserName)
                    {
                        context.AddError("A001015105");
                        return;
                    }
                    

                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                    "startMonthlyYearCheck();", true);
                }

                //业务类型为月票卡充值时
                else if (hiddenTRADETYPECODE.Value == "3L"|| hiddenTRADETYPECODE.Value == "3M")
                {
                    if (hidOPERATENO.Value != context.s_UserName)
                    {
                        context.AddError("A001015105");
                        return;
                    }

                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(
               this, this.GetType(), "writeCardScript", "startMonthlyCharge();", true);
                }

                //业务类型为月票卡充值返销时
                else if (hiddenTRADETYPECODE.Value == "3Q" || hiddenTRADETYPECODE.Value == "3P")
                {
                    if (hidOPERATENO.Value != context.s_UserName)
                    {
                        context.AddError("A001015105");
                        return;
                    }

                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(
               this, this.GetType(), "writeCardScript", "startMonthlyCharge();", true);
                }

                //业务类型为月票卡补卡时
                else if (hiddenTRADETYPECODE.Value == "71" || hiddenTRADETYPECODE.Value == "72")
                {
                    if (hidOPERATENO.Value != context.s_UserName)
                    {
                        context.AddError("A001015105");
                        return;
                    }

                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(
               this, this.GetType(), "writeCardScript", "startMonthlyMakeUp();", true);
                }

                //业务类型为月票卡换卡时（学生或老人）
                else if (hiddenTRADETYPECODE.Value == "73" || hiddenTRADETYPECODE.Value == "74")
                {
                    if (hidOPERATENO.Value != context.s_UserName)
                    {
                        context.AddError("A001015105");
                        return;
                    }

                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(
               this, this.GetType(), "writeCardScript", "startMonthlyChange();", true);
                }

                //业务类型为月票卡换卡时（高龄）
                else if (hiddenTRADETYPECODE.Value == "75")
                {
                    if (hidOPERATENO.Value != context.s_UserName)
                    {
                        context.AddError("A001015105");
                        return;
                    }

                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(
               this, this.GetType(), "writeCardScript", "startMonthlyMakeUp();", true);
                }

                //业务类型为月票卡转高龄时
                else if (hiddenTRADETYPECODE.Value == "76" )
                {
                    if (hidOPERATENO.Value != context.s_UserName)
                    {
                        context.AddError("A001015105");
                        return;
                    }

                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(
               this, this.GetType(), "writeCardScript", "modifyMonthlyInfo();", true);
                }
                lvwQuery.DataSource = new DataTable();
                lvwQuery.DataBind(); 
                #endregion
            }
        }
        //其他业务类型
        else
        {
            context.AddError("A001015103");
            return;
        }

    }
}
