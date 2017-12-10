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
using TDO.PersonalTrade;
using TM;
using TDO.CardManager;
using TDO.BusinessCode;
using PDO.PersonalBusiness;
using TDO.ResourceManager;
using Master;

public partial class ASP_PersonalBusiness_PB_Recover : Master.FrontMaster
{
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
            lvwSupplyQuery.DataSource = new DataTable();
            lvwSupplyQuery.DataBind();
            lvwSupplyQuery.SelectedIndex = -1;

            //指定GridView DataKeyNames
            lvwSupplyQuery.DataKeyNames = new string[] { "ID", "TRADETYPE", "SUPPLYMONEY", "PREMONEY", 
                "OPERATETIME", "STAFFNAME", "Cardtradeno", "NextCardtradeno","CANCELTAG" };

            initLoad(sender, e);
        }
    }

    //初始化时间


    protected void initLoad(object sender, EventArgs e)
    {
        beginDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
        endDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        lvwSupplyQuery.DataSource = new DataTable();
        lvwSupplyQuery.DataBind();

        SupplyMoney.Text = "";
        StaffName.Text = "";
        SupplyDate.Text = "";
        reCoverMoney.Text = "";

        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据


        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;

        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

        //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据


        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
        ddoTF_F_CUSTOMERRECIn.CARDNO = txtCardno.Text;

        //UPDATE BY JIANGBB 2012-04-19解密
        DDOBase ddoBase = (DDOBase)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

        ddoBase = CommonHelper.AESDeEncrypt(ddoBase);
        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)ddoBase;
        //TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

        if (ddoTF_F_CUSTOMERRECOut == null)
        {
            context.AddError("A001002111");
            return;
        }

        //从证件类型编码表(TD_M_PAPERTYPE)中读取数据


        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
        ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);

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

        //给页面显示项赋值


        LabAsn.Text = hiddenAsn.Value.Substring(4, 16);
        LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
        sDate.Text = hiddensDate.Value.Substring(0, 4) + "-" + hiddensDate.Value.Substring(4, 2) + "-" + hiddensDate.Value.Substring(6, 2);
        eDate.Text = hiddeneDate.Value.Substring(0, 4) + "-" + hiddeneDate.Value.Substring(4, 2) + "-" + hiddeneDate.Value.Substring(6, 2);
        cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / (Convert.ToDecimal(100))).ToString("0.00");

        CustName.Text = ddoTF_F_CUSTOMERRECOut.CUSTNAME;

        if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "0")
            Custsex.Text = "男";
        else if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "1")
            Custsex.Text = "女";
        else Custsex.Text = "";

        if (ddoTF_F_CUSTOMERRECOut.CUSTBIRTH != "")
        {
            String Bdate = ddoTF_F_CUSTOMERRECOut.CUSTBIRTH;
            if (Bdate.Length == 8)
            {
                CustBirthday.Text = Bdate.Substring(0, 4) + "-" + Bdate.Substring(4, 2) + "-" + Bdate.Substring(6, 2);
            }
            else CustBirthday.Text = Bdate;
        }
        else CustBirthday.Text = ddoTF_F_CUSTOMERRECOut.CUSTBIRTH;

        if (ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE != "")
        {
            Papertype.Text = ddoTD_M_PAPERTYPEOut.PAPERTYPENAME;
        }
        else Papertype.Text = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

        Paperno.Text = ddoTF_F_CUSTOMERRECOut.PAPERNO;
        Custaddr.Text = ddoTF_F_CUSTOMERRECOut.CUSTADDR;
        Custpost.Text = ddoTF_F_CUSTOMERRECOut.CUSTPOST;
        Custphone.Text = ddoTF_F_CUSTOMERRECOut.CUSTPHONE;
        txtEmail.Text = ddoTF_F_CUSTOMERRECOut.CUSTEMAIL;
        Remark.Text = ddoTF_F_CUSTOMERRECOut.REMARK;

        //查询卡片开通功能并显示
        PBHelper.openFunc(context, openFunc, txtCardno.Text);

        btnQuery.Enabled = true;

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
            Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
            Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
        }
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        lvwSupplyQuery.DataSource = CreateSupplyQueryDataSource();
        lvwSupplyQuery.DataBind();

        if (lvwSupplyQuery.Rows.Count == 0)
        {
            context.AddError("A001009101");
            return;
        }

        if (lvwSupplyQuery.Rows.Count > 0)
        {
            lvwSupplyQuery.SelectedIndex = 0;
            GridViewRow gv = lvwSupplyQuery.Rows[0];
            hiddenSupplyid.Value = gv.Cells[0].Text;
            SupplyMoney.Text = gv.Cells[2].Text;
            StaffName.Text = gv.Cells[5].Text;
            SupplyDate.Text = gv.Cells[4].Text;
            reCoverMoney.Text = gv.Cells[2].Text;
            hidPREMONEY.Value = Convert.ToDecimal(gv.Cells[3].Text).ToString();
            hidCardtradeno.Value = gv.Cells[6].Text.Trim();
            hidNextCardtradeno.Value = gv.Cells[7].Text.Trim();
            int supplyMoney = Convert.ToInt32(Convert.ToDecimal(reCoverMoney.Text) * 100);
            int preMoney = Convert.ToInt32(Convert.ToDecimal(gv.Cells[3].Text) * 100);
            hiddencMoney.Value = "" + (supplyMoney + preMoney);
            hidUnSupplyMoney.Value = "" + Convert.ToInt32(Convert.ToDecimal(reCoverMoney.Text) * 100);
            hidCANCELTAG.Value = gv.Cells[8].Text;
        }

        btnRecover.Enabled = true;
    }

    public DataTable CreateSupplyQueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从现金台帐主表中读取数据
        TF_B_TRADEFEETDO ddoTF_B_TRADEFEEIn = new TF_B_TRADEFEETDO();
        string strSql = " SELECT a.ID, c.TRADETYPE, a.SUPPLYMONEY/100.0 SUPPLYMONEY, a.PREMONEY/100.0 PREMONEY, a.OPERATETIME, "+
                        " b.STAFFNAME, d.Cardtradeno, d.NextCardtradeno,e.CANCELTAG " +
                        " FROM TF_B_TRADEFEE a,TD_M_INSIDESTAFF b,TD_M_TRADETYPE c, TF_CARD_TRADE d, TF_B_TRADE e " +
                        " WHERE a.CARDNO = '" + txtCardno.Text + "' " +
                        " AND a.OPERATETIME BETWEEN Trunc(sysdate,'dd') AND sysdate AND a.TRADEID = d.TRADEID" +
                        " AND a.TRADETYPECODE = '02' AND b.STAFFNO = a.OPERATESTAFFNO AND c.TRADETYPECODE = a.TRADETYPECODE "+
                        " AND e.TRADEID = a.TRADEID "+
                        " ORDER BY a.OPERATETIME DESC";

        ArrayList list = new ArrayList();

        strSql += DealString.ListToWhereStr(list);

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEFEEIn, null, strSql, 0);
        return data;
    }

    public void lvwSupplyQuery_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwSupplyQuery.PageIndex = e.NewPageIndex;
        lvwSupplyQuery.DataSource = CreateSupplyQueryDataSource();
        lvwSupplyQuery.DataBind();
    }
    protected void lvwSupplyQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[6].Visible = false;
            e.Row.Cells[7].Visible = false;
            e.Row.Cells[8].Visible = false;
        }
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "rewriteCard") // 重新写卡，生产新的令牌

        {
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "writeCard();", true);
        }
        else if (hidWarning.Value == "yes")
        {
            btnRecover.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            Recover(sender, e);
            // AddMessage("前台写卡成功，抹帐成功");
        }
        else if (hidWarning.Value == "writeFail")
        {
            context.AddError("前台写卡失败");
        }
        else if (hidWarning.Value == "RevocerConfirm")
        {
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                    "unchargeCard();", true);
        }

    }
    protected void btnRecover_Click(object sender, EventArgs e)
    {
        //充值员工和当前员工检验

        if (StaffName.Text != context.s_UserName)
        {
            context.AddError("A001009110");
            return;
        }
        //卡内余额和充值后金额检验

        if (Convert.ToDecimal(hiddencMoney.Value) == Convert.ToDecimal(cMoney.Text) * 100)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                    "RecoverCheck();", true);
            //卡内余额等于充值后金额时,抹卡
            
        }
        //卡内余额不等于充值后金额
        else if (Convert.ToDecimal(hiddencMoney.Value) != Convert.ToDecimal(cMoney.Text)*100)
        {
            //卡内余额不等于充值前金额
            if (Convert.ToDecimal(cMoney.Text) != Convert.ToDecimal(hidPREMONEY.Value))
            {
                context.AddError("A001009111");
                return;
            }
            //卡内余额等于充值前金额
            else if (Convert.ToDecimal(cMoney.Text) == Convert.ToDecimal(hidPREMONEY.Value))
            {
                //充值后卡交易序号不为空
                if (hidNextCardtradeno.Value != "&nbsp;")
                {
                    context.AddError("A001009111");
                    return;
                }
                //充值后卡交易序号为空

                else if (hidNextCardtradeno.Value == "&nbsp;")
                {
                    //卡交易序号不等于充值前卡交易序号

                    if (hiddentradeno.Value != hidCardtradeno.Value)
                    {
                        context.AddError("A001009112");
                        return;
                    }
                    //卡交易序号等于充值前卡交易序号

                    else if (hiddentradeno.Value == hidCardtradeno.Value)
                    {
                        if ( hidCANCELTAG.Value != "0" )
                        {
                            context.AddError("A001009113");
                            return;
                        }
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                                "DBRecoverCheck();", true);
                        //Recover(sender, e);
                    }
                }
            }
        }
        
    }
    protected void Recover(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从IC卡电子钱包账户表中读取数据


        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text;

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null, "TF_F_CARDEWALLETACC", null);
        //PDO赋值


        SP_PB_RecoverPDO pdo = new SP_PB_RecoverPDO();
        pdo.ID = DealString.GetRecordID(hiddentradeno.Value, LabAsn.Text);
        //pdo.ID = hiddentradeno.Value + DateTime.Now.ToString("yyyyMMddhhmmss").Substring(4, 10) + LabAsn.Text.Substring(12, 4);
        pdo.CARDNO = txtCardno.Text;
        pdo.TRADETYPECODE = "B1";
        pdo.ASN = LabAsn.Text;
        pdo.CARDTYPECODE = hiddenLabCardtype.Value;
        pdo.SUPPLYID = hiddenSupplyid.Value;
        pdo.CANCELMONEY = Convert.ToInt32(Convert.ToDecimal(reCoverMoney.Text) * 100);
        pdo.CARDMONEY = Convert.ToInt32(hiddencMoney.Value);
        pdo.CARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;
        pdo.CARDTRADENO = hiddentradeno.Value;
        pdo.OPERCARDNO = context.s_CardID;
        pdo.TERMNO = "112233445566";

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M001009001");

            foreach (Control con in this.Page.Controls)
            {
                ClearControl(con);
            }
            lvwSupplyQuery.DataSource = new DataTable();
            lvwSupplyQuery.DataBind();
            initLoad(sender, e);
            btnRecover.Enabled = false;
            btnQuery.Enabled = false;
        }

    }
}
