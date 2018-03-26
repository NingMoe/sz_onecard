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
using TDO.PersonalTrade;
using TDO.CardManager;
using TDO.BusinessCode;
using PDO.PersonalBusiness;
using TDO.ResourceManager;
using Master;

public partial class ASP_PersonalBusiness_PB_Speload : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            LabAsn.Attributes["readonly"] = "true";
            LabCardtype.Attributes["readonly"] = "true";
            sDate.Attributes["readonly"] = "true";
            RESSTATE.Attributes["readonly"] = "true";
            cMoney.Attributes["readonly"] = "true";
            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";

            //设置GridView绑定的DataTable
            lvwSpeloadQuery.DataSource = new DataTable();
            lvwSpeloadQuery.DataBind();
            lvwSpeloadQuery.SelectedIndex = -1;

            //指定GridView DataKeyNames
            lvwSpeloadQuery.DataKeyNames = new string[] { "TRADEID", "CARDNO", "TRADEMONEY", "TRADETIMES", "TRADEDATE", "INPUTTIME", "INPUTSTAFF","REMARK" };

        }
    }

    public ICollection CreateSpeloadQueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从特殊圈存台帐表中读取数据

        TF_B_SPELOADTDO ddoTF_B_SPELOADIn = new TF_B_SPELOADTDO();
        string strSql = "SELECT a.TRADEID,a.CARDNO,a.TRADEMONEY/100.0 TRADEMONEY,a.TRADETIMES,a.TRADEDATE,a.INPUTTIME,b.STAFFNAME INPUTSTAFF,a.REMARK";
        strSql += " FROM TF_B_SPELOAD a,TD_M_INSIDESTAFF b WHERE CARDNO = '" + txtCardno.Text + "' AND STATECODE = '0' AND b.STAFFNO = a.INPUTSTAFFNO AND TRADETYPECODE = '95' ORDER BY INPUTTIME DESC";

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
        //选择列表框一行记录后,给页面赋值

        hiddenTradeid.Value = getDataKeys("TRADEID");
        CardNo.Text = getDataKeys("CARDNO");
        labSpeload.Text = Convert.ToDecimal(getDataKeys("TRADEMONEY")).ToString("0.00");
        labStaff.Text = getDataKeys("INPUTSTAFF");
        labInputtime.Text = getDataKeys("INPUTTIME");
        labRemark.Text = getDataKeys("REMARK");

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

    protected void readInfo(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

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
            context.AddError("A001107112");
            return;
        }

        //从证件类型编码表(TD_M_PAPERTYPE)中读取数据

        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
        ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);

        //给页面显示项赋值

        CustName.Text = ddoTF_F_CUSTOMERRECOut.CUSTNAME;

        if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "0")
            Custsex.Text = "男";
        else if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "1")
            Custsex.Text = "女";
        else Custsex.Text = "";
        //出生日期赋值

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
        //证件类型赋值

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

    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //卡账户有效性检验

        context.SPOpen();

        context.AddField("p_CARDNO").Value = txtCardno.Text;

        bool ok = context.ExecuteSP("SP_Credit_Check");

        if (ok)
        {
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

            //给页面显示项赋值

            LabAsn.Text = hiddenAsn.Value.Substring(4, 16);
            LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
            sDate.Text = hiddensDate.Value.Substring(0, 4) + "-" + hiddensDate.Value.Substring(4, 2) + "-" + hiddensDate.Value.Substring(6, 2);
            cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / 100).ToString("0.00");
            //读取客户资料
            readInfo(sender, e);

            //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
            if (!CommonHelper.HasOperPower(context))
            {
                Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
                Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
                Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
            }
            
            CommonHelper.readCardJiMingState(context, txtCardno.Text, hidIsJiMing);

            //查询特殊圈存信息
            lvwSpeloadQuery.DataSource = CreateSpeloadQueryDataSource();
            lvwSpeloadQuery.DataBind();

            if (lvwSpeloadQuery.Rows.Count == 0)
            {
                context.AddError("A001019102");
                return;
            }
            btnSpsload.Enabled = true;
            btnPrintPZ.Enabled = false;
        }
     
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")
        {
            btnSpsload.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            AddMessage("前台写卡成功");
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

    protected void btnSpsload_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //未选择记录时,处理中止
        if (hiddenTradeid.Value == "")
        {
            context.AddError("A001019103");
            return;
        }

        CommonHelper.CheckMaxBalance(context, Convert.ToInt32(hiddencMoney.Value), Convert.ToInt32((Convert.ToDecimal(labSpeload.Text)) * 100), hidIsJiMing);

        if (context.hasError()) return;

        //存储过程赋值

        SP_PB_SpeloadPDO pdo = new SP_PB_SpeloadPDO();
        pdo.TRADEID = hiddenTradeid.Value;
        pdo.CARDNO = txtCardno.Text;
        pdo.CURRENTMONEY = Convert.ToInt32((Convert.ToDecimal(labSpeload.Text)) * 100);
        hidSupplyMoney.Value = "" + pdo.CURRENTMONEY;
        pdo.CARDMONEY = Convert.ToInt32(hiddencMoney.Value);
        pdo.CARDTRADENO = hiddentradeno.Value;
        pdo.TRADETYPECODE = "96";
        pdo.TERMNO = "112233445566";
        pdo.OPERCARDNO = context.s_CardID;

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M001019100");
            hidCardReaderToken.Value = cardReader.createToken(context);
            hidCardnoForCheck.Value = txtCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致


            ScriptManager.RegisterStartupScript(this, this.GetType(), 
                "writeCardScript", "chargeCard();", true);
            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, CustName.Text, "特殊圈存", labSpeload.Text
                , "", "", Paperno.Text, (Convert.ToDecimal(pdo.CARDMONEY + pdo.CURRENTMONEY) / 100).ToString("0.00"),
                "", labSpeload.Text, context.s_UserID, context.s_DepartName, Papertype.Text, "", "0.00");

            //foreach (Control con in this.Page.Controls)
            //{
            //    ClearControl(con);
            //}
            lvwSpeloadQuery.DataSource = new DataTable();
            lvwSpeloadQuery.DataBind();
        }
    }
}
