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

public partial class ASP_PersonalBusiness_PB_Retrade : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";

            LabCardtype.Attributes["readonly"] = "true";
            sDate.Attributes["readonly"] = "true";
            cMoney.Attributes["readonly"] = "true";

            //设置GridView绑定的DataTable
            lvwQuery.DataSource = new DataTable();
            lvwQuery.DataBind();
            lvwQuery.SelectedIndex = -1;

            //指定GridView DataKeyNames
            lvwQuery.DataKeyNames = new string[] { "TRADEID", "TRADETYPE", "OPERATETIME", "strCardNo", 
                "lMoney", "lOldMoney","strTermno","strEndDateNum","strFlag","strStaffno","strTaxino","strState",
                "STAFFNAME","TRADETYPECODE","Cardtradeno","writeCardScript" };

        }
    }
    private static bool isSmk;
    public static bool IsSmk
    {
        set { isSmk = value; }
        get { return isSmk; }
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
            hiddenTRADETYPECODE.Value = gv.Cells[13].Text;
            hiddenOPERATETIME.Value = gv.Cells[2].Text;
            hiddenlOldMoney.Value = Convert.ToString((Convert.ToDecimal(gv.Cells[5].Text)) * 100);
            hiddencMoney.Value = "" + Convert.ToDecimal(gv.Cells[5].Text) * 100;
            hidSupplyMoney.Value = "" + Convert.ToDecimal(gv.Cells[4].Text) * 100;
            hidChargeMoney.Value = "" + Convert.ToDecimal(gv.Cells[5].Text) * 100;
            hidUnSupplyMoney.Value = "" + Convert.ToDecimal(gv.Cells[4].Text) * 100;
            hidCardtradeno.Value = gv.Cells[14].Text;
            hidMonthlyFlag.Value = gv.Cells[8].Text;
            hidZJGMonthlyFlag.Value = gv.Cells[7].Text.Trim();//wdx 20111130 张家港月票补写

            hidCarNo.Value = OperdStr("E" + gv.Cells[10].Text.Trim());
            hidStaffNo.Value = gv.Cells[9].Text;
            hidState.Value = gv.Cells[11].Text;
            hidOPERATENO.Value = gv.Cells[12].Text;
            hidwriteCardScript.Value = gv.Cells[15].Text;
        }

        Subcommit.Enabled = true;
    }
    public ICollection CreateQueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从业务写卡台帐表中读取数据

        TF_CARD_TRADETDO ddoTF_CARD_TRADEIn = new TF_CARD_TRADETDO();
        string str = " SELECT * from ( SELECT a.TRADEID,c.TRADETYPE TRADETYPE,a.OPERATETIME,b.STAFFNAME,a.strCardNo,a.lMoney/100.0 lMoney," +
                    " a.lOldMoney/100.0 lOldMoney,a.strTermno,a.strEndDateNum,a.strFlag,a.strStaffno,a.strTaxino," +
                    " a.strState,a.TRADETYPECODE, a.Cardtradeno, a.writeCardScript " +
                    " FROM TF_CARD_TRADE a,TD_M_INSIDESTAFF b,TD_M_TRADETYPE c, TF_B_TRADE d " +
                    " WHERE strCardNo = '" + txtCardno.Text + "' AND a.TRADETYPECODE = c.TRADETYPECODE AND a.TRADEID = d.TRADEID " +
                    " AND a.SUCTAG != '2' AND d.OPERATESTAFFNO = b.STAFFNO(+) " +
                    " order by a.OPERATETIME desc, a.TRADEID desc ) WHERE ROWNUM < 13 ";

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTF_CARD_TRADEIn, null, str, 0);

        if (data.Rows.Count == 0)
        {
            str = " SELECT * from ( SELECT a.TRADEID,c.TRADETYPE TRADETYPE,a.OPERATETIME,b.STAFFNAME,a.strCardNo,a.lMoney/100.0 lMoney," +
                    " a.lOldMoney/100.0 lOldMoney,a.strTermno,a.strEndDateNum,a.strFlag,a.strStaffno,a.strTaxino," +
                    " a.strState,d.TRADETYPECODE, a.Cardtradeno, a.writeCardScript " +
                    " FROM TF_CARD_TRADE@WWW.SMK.COM a,TD_M_INSIDESTAFF b,TD_M_TRADETYPE c, TF_B_TRADE d " +
                    " WHERE strCardNo = '" + txtCardno.Text + "' AND d.TRADETYPECODE = c.TRADETYPECODE AND a.TRADEID = d.TRADEID " +
                    " AND a.SUCTAG != '2' AND d.OPERATESTAFFNO = b.STAFFNO(+) " +
                    " order by a.OPERATETIME desc, a.TRADEID desc ) WHERE ROWNUM < 13 ";

             data = tmTMTableModule.selByPKDataTable(context, ddoTF_CARD_TRADEIn, null, str, 0);
             IsSmk = true;
        }
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
        string[] strValues = { "01","02","04","14","21","96","98","5B","8H","03","7H","7I","7K","05",
                               "31","32","23","70","71","72","8A","8B","9E","9B","8D","9D","73","74",
                               "75","76","77","78","D1","D2","H0","H1","H2","C3","H3","H4","H5","A1",
                               "A3","K1","A5","39","40","42","3A","3B","50","51","53","54","55","F0",
                               "F1","54","F4","E1","E2","E3","E4"};

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


                AddMessage("M001013001");

                //业务类型为售卡时
                if (hiddenTRADETYPECODE.Value == "01")
                {
                    if (Convert.ToDateTime(sDate.Text) < DateTime.Today)
                    {
                        context.AddError("A001021009");
                        return;
                    }
                    //从IC卡电子钱包账户表中读取数据

                    TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
                    ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text;

                    TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);
                    if (ddoTF_F_CARDEWALLETACCOut.TOTALCONSUMEMONEY != 0 || ddoTF_F_CARDEWALLETACCOut.TOTALSUPPLYMONEY != 0)
                    {
                        context.AddError("A001021008");
                        return;
                    }

                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "saleCard();", true);
                }
                //业务类型为充值,转值,企服卡充值,充值卡充值,特殊圈存,调账充值,专有账户圈存时

                else if (hiddenTRADETYPECODE.Value == "02" || hiddenTRADETYPECODE.Value == "04" || hiddenTRADETYPECODE.Value == "14" || hiddenTRADETYPECODE.Value == "21" || hiddenTRADETYPECODE.Value == "96" || hiddenTRADETYPECODE.Value == "98" || hiddenTRADETYPECODE.Value == "5B" || hiddenTRADETYPECODE.Value == "8H")
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
                    if (hiddenlOldMoney.Value != hiddencMoney.Value)
                    {
                        context.AddError("A001012100");
                        return;
                    }
                    hidCardReaderToken.Value = cardReader.createToken(context);

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "chargeCard();", true);
                }
                //业务类型为换卡时,add by liuhe20130912 7H,7I旅游卡售卡

                else if (hiddenTRADETYPECODE.Value == "03"
                    || hiddenTRADETYPECODE.Value == "7H"
                    || hiddenTRADETYPECODE.Value == "7I")
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
                    if (hiddenlOldMoney.Value != hiddencMoney.Value)
                    {
                        context.AddError("A001012100");
                        return;
                    }

                    int railTimes = 0;
                    //换卡时需要修改轨交次数
                    if (hiddenTRADETYPECODE.Value == "03")
                    {
                        TF_CARD_TRADETDO ddoTF_CARD_TRADEIn = new TF_CARD_TRADETDO();
                        //先获取换卡旧卡卡号
                        string strsql = " SELECT t.oldcardno FROM TF_B_TRADE t WHERE t.CARDNO='" + txtCardno.Text + "' AND t.TRADETYPECODE='03' AND t.TRADEID='" + hiddenID.Value + "' ";

                        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTF_CARD_TRADEIn, null, strsql, 0);
                        if (data != null && data.Rows.Count > 0)
                        {
                            //获取轨交换乘次数

                            try
                            {

                                //礼金卡不需要执行该操作,针对新卡为市民卡结构
                                if (hiddenLabCardtype.Value != "05")
                                {
                                    //请求集合
                                    NameValueCollection values = new NameValueCollection();
                                    values.Add("id", "00215000" + data.Rows[0]["oldcardno"].ToString().Substring(8, 8));

                                    //发起请求
                                    PostSubmitter postSubmit = new PostSubmitter("http://172.10.0.110:8080/WebServiceSX.asmx/GetYKTCount", values);
                                    postSubmit.Type = Common.PostSubmitter.PostTypeEnum.Post;

                                    //获取返回信息
                                    string response = postSubmit.Post();
                                    XmlDocument xmlDoc = new XmlDocument();
                                    xmlDoc.LoadXml(response);

                                    if (xmlDoc != null && !string.IsNullOrEmpty(xmlDoc.InnerText))
                                    {
                                        string str = xmlDoc.InnerText.Substring(xmlDoc.InnerText.Length - 2, 2);
                                        railTimes = Convert.ToInt32(str, 16);
                                        //给写卡JS控件赋值
                                        hiddenTradeNum.Value = xmlDoc.InnerText;
                                    }

                                }
                            }
                            catch (Exception ex)
                            {

                                context.AddError(ex.Message);
                            }
                        }
                    }
                    if (!string.IsNullOrEmpty(hiddenTradeNum.Value))
                    {
                        if (isSmk)
                        {
                            hidCardReaderToken.Value = cardReader.createToken(context);
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                                    "changeGj();", true);
                        }
                        else
                        {
                            hidCardReaderToken.Value = cardReader.createToken(context);
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                                    "changeCardGj();", true);
                        }
                        context.AddMessage(" 轨交次数" + railTimes + "次成功转移至新卡，有疑问可以向轨交咨询和修改次数");
                    }
                    else
                    {
                        hidCardReaderToken.Value = cardReader.createToken(context);
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                                "changeCard();", true);
                    }
                }
                else if (hiddenTRADETYPECODE.Value == "7K")//添加旅游卡回收补写卡
                {
                    if (hiddenlOldMoney.Value != hiddencMoney.Value)
                    {
                        context.AddError("A001012100");
                        return;
                    }
                    if (hidUnSupplyMoney.Value != hiddenlOldMoney.Value)
                    {
                        context.AddError("A001012191:圈提金额不等于回收前余额");
                        return;
                    }
                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "unchargeCard();", true);
                }
                //业务类型为退卡时
                else if (hiddenTRADETYPECODE.Value == "05")
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
                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "lockReturnCard();", true);
                }
                //业务类型为学生月票开卡,老人月票开卡,高龄月票开卡,学生月票补卡,老人月票补卡,高龄月票补卡时


                else if (hiddenTRADETYPECODE.Value == "31" || hiddenTRADETYPECODE.Value == "32"
                        || hiddenTRADETYPECODE.Value == "23" || hiddenTRADETYPECODE.Value == "70"
                        || hiddenTRADETYPECODE.Value == "71" || hiddenTRADETYPECODE.Value == "72")
                {
                    if (Convert.ToDateTime(sDate.Text) < DateTime.Today)
                    {
                        context.AddError("A001021009");
                        return;
                    }
                    //从IC卡电子钱包账户表中读取数据


                    TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
                    ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text;

                    TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);
                    if (ddoTF_F_CARDEWALLETACCOut.TOTALCONSUMEMONEY != 0 || ddoTF_F_CARDEWALLETACCOut.TOTALSUPPLYMONEY != 0)
                    {
                        context.AddError("A001021008");
                        return;
                    }
                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "startMonthlyInfo();", true);
                }
                //业务类型为张家港残爱卡开通、审核,张家港老免卡开通、审核 wdx20111130
                else if (hiddenTRADETYPECODE.Value == "8A" || hiddenTRADETYPECODE.Value == "8B"
                        || hiddenTRADETYPECODE.Value == "9E" || hiddenTRADETYPECODE.Value == "9B"
                    || hiddenTRADETYPECODE.Value == "8D" || hiddenTRADETYPECODE.Value == "9D")
                {
                    //if (Convert.ToDateTime(sDate.Text) < DateTime.Today)
                    //{
                    //    context.AddError("A001021009");
                    //    return;
                    //}
                    //从IC卡电子钱包账户表中读取数据




                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "startZJGMonthlyInfo();", true);
                }
                //业务类型为学生月票换卡,老人月票换卡,高龄卡换卡,老人月票升级高龄卡,月票卡更新,学生月票更新老人月票时


                else if (hiddenTRADETYPECODE.Value == "73" || hiddenTRADETYPECODE.Value == "74"
                    || hiddenTRADETYPECODE.Value == "75" || hiddenTRADETYPECODE.Value == "76"
                    || hiddenTRADETYPECODE.Value == "77" || hiddenTRADETYPECODE.Value == "78")
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
                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "startMonthlyInfo();", true);
                }
                //业务类型为月票卡售卡,补卡返销时


                else if (hiddenTRADETYPECODE.Value == "D1" || hiddenTRADETYPECODE.Value == "D2"
                    || hiddenTRADETYPECODE.Value == "H0" || hiddenTRADETYPECODE.Value == "H1"
                    || hiddenTRADETYPECODE.Value == "H2" || hiddenTRADETYPECODE.Value == "C3"
                    )
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
                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "endMonthlyInfo();", true);
                }
                //业务类型为月票卡换卡返销时


                else if (hiddenTRADETYPECODE.Value == "H3" || hiddenTRADETYPECODE.Value == "H4"
                    || hiddenTRADETYPECODE.Value == "H5")
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
                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "rollbackMonthlyInfo();", true);
                }
                //业务类型为售卡返销时



                else if (hiddenTRADETYPECODE.Value == "A1")
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
                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "saleRollback();", true);
                }
                //业务类型为换卡返销,add by liuhe20130912 7H,7I旅游卡售卡返销
                else if (hiddenTRADETYPECODE.Value == "A3" || hiddenTRADETYPECODE.Value == "K1")
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
                    if (hiddenlOldMoney.Value != hiddencMoney.Value)
                    {
                        context.AddError("A001012100");
                        return;
                    }
                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "changeCardRollback();", true);
                }
                //业务类型为退卡返销
                else if (hiddenTRADETYPECODE.Value == "A5")
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
                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "unlockReturnCard();", true);
                }
                //业务类型为出租车开卡



                else if (hiddenTRADETYPECODE.Value == "39")
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
                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "newDriverCard();", true);
                }
                //业务类型为出租车补换卡



                else if (hiddenTRADETYPECODE.Value == "40")
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
                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "newDriverCard();", true);
                }
                //业务类型为出租车信息修改
                else if (hiddenTRADETYPECODE.Value == "42")
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
                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "newDriverCard();", true);
                }
                //业务类型为园林年卡关闭


                else if (hiddenTRADETYPECODE.Value == "3A")
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
                    hidParkInfo.Value = "FFFFFFFFFFFF";
                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                "startPark();", true);
                }
                //业务类型为休闲年卡关闭


                else if (hiddenTRADETYPECODE.Value == "3B")
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
                    hidParkInfo.Value = "FFFFFFFFFFFF";
                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                "startXXPark();", true);
                }
                else if (hiddenTRADETYPECODE.Value == "50" || hiddenTRADETYPECODE.Value == "51" ||
                         hiddenTRADETYPECODE.Value == "53" || hiddenTRADETYPECODE.Value == "54" ||
                         hiddenTRADETYPECODE.Value == "55" || hiddenTRADETYPECODE.Value == "F0" ||
                         hiddenTRADETYPECODE.Value == "F1" || hiddenTRADETYPECODE.Value == "54" ||
                         hiddenTRADETYPECODE.Value == "F4")
                {
                    ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript", hidwriteCardScript.Value, true);
                }

                //世乒旅游售卡
                else if (hiddenTRADETYPECODE.Value == "E1")
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
                    string str = hidwriteCardScript.Value;
                    Regex reg = new Regex(@"\(([^)]*)\)");
                    Match m = reg.Match(str);

                    string[] val = m.Result("$1").Split(',');

                    if (val.Length == 2)
                        hiddenShiPingTag.Value = val[1].Trim();
                 
                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "writeShiPing();", true);
                }


                //世乒换卡
                else if (hiddenTRADETYPECODE.Value == "E3")
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
                    string str = hidwriteCardScript.Value;
                    Regex reg = new Regex(@"\(([^)]*)\)");
                    Match m = reg.Match(str);

                    string[] val = m.Result("$1").Split(',');

                    if (val.Length == 2)
                        hiddenShiPingTag.Value = val[1].Trim();

                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "changeShiPingCard();", true);
                }
                //世乒旅游售卡返销
                else if ( hiddenTRADETYPECODE.Value == "E2" )
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

                    hiddenShiPingTag.Value = "FFFFFFFFFFFFFFFFFFFF";
                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "saleShiPingRollback();", true);
                }
                //世乒旅游换卡返销
                else if ( hiddenTRADETYPECODE.Value == "E4")
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

                    hiddenShiPingTag.Value = "FFFFFFFFFFFFFFFFFFFF";
                    hidCardReaderToken.Value = cardReader.createToken(context);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                        "changeShiPingRollback();", true);
                }

                
                //foreach (Control con in this.Page.Controls)
                //{
                //    ClearControl(con);
                //}
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
