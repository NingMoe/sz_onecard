using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Master;
using TM;
using Common;
using PDO.PersonalBusiness;
using TDO.CardManager;
using TDO.ResourceManager;
using TDO.BusinessCode;
using TDO.CustomerAcc;
using System.Text;

/***************************************************************
 * 功能名: 专有账户_查询
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2011/06/24    liuh			初次开发
 ****************************************************************/
public partial class ASP_CustomerAcc_CA_Query : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack == false)
        {
            setReadOnly(txtCardno, LabAsn, LabCardtype, cMoney, sDate, eDate);

            beginDate.Text = DateTime.Today.AddDays(-30).ToString("yyyyMMdd");
            endDate.Text = DateTime.Today.ToString("yyyyMMdd");

            // 初始化集团客户
            GroupCardHelper.initGroupCustomer(context, selCorp);
        }
    }

    /// <summary>
    /// 根据证件号码查询卡号
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQueryCard_Click(object sender, EventArgs e)
    {
        //对输入证件号码进行检验
        if (ValidatePaperNo() == false)
            return;

        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(this.txtPaperNo.Text.Trim(), ref strBuilder);

        StringBuilder strBuilder2 = new StringBuilder();
        AESHelp.AESEncrypt(this.txtName.Text.Trim(), ref strBuilder2);

        DataTable dt = SPHelper.callQuery("SP_CA_Query", context, "QRYCARDNO", strBuilder.ToString(), strBuilder2.ToString());

        if (dt != null && dt.Rows.Count > 0)
        {
            //GroupCardHelper.fill(selCardNo, dt, true);
        }
        else
        {
            context.AddError("A001003192：未查找到对应卡号");
        }
    }

    /// <summary>
    /// 选择卡号
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void selCardNo_SelectedIndexChanged(object sender, EventArgs e)
    {
        //txtCardno.Text = selCardNo.SelectedValue;
    }

    /// <summary>
    /// 读卡按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        ClearCardInfo();
        ClearAccountInfo();
        ClearUserInfo();
        ClearAccountTrade();

        #region 卡片信息（从卡片里读出的数据）
        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);
        LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;

        LabAsn.Text = hiddenAsn.Value.Substring(4, 16);
        sDate.Text = ASHelper.toDateWithHyphen(hiddensDate.Value);
        eDate.Text = ASHelper.toDateWithHyphen(hiddeneDate.Value);
        cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / (Convert.ToDecimal(100))).ToString("0.00");
        #endregion

        //加载卡户、用户、账户信息
        LoadDisplayInfo();
    }

    /// <summary>
    /// 读数据库按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDBread_Click(object sender, EventArgs e)
    {
        ClearGvResult();
        ClearReadCardInfo();
        ClearCardInfo();
        ClearAccountInfo();
        ClearUserInfo();
        ClearAccountTrade();

        //验证查询条件不能为空
        if (!CheckQueryControl())
        {
            return;
        }
        createGridViewDataSource(sender,e);
        
        //对卡号空值长度数字的判断
        //UserCardHelper.validateCardNo(context, txtCardno, false);
        //if (context.hasError())
        //{
        //    return;
        //}
      

        
    }

    private void createGridViewDataSource(object sender, EventArgs e)
    {
        List<string> vars = new List<string>();
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(this.txtPaperNo.Text.Trim(), ref strBuilder);
        vars.Add(strBuilder.ToString());
        vars.Add(this.txtInputCardNo.Text.Trim());
        StringBuilder strBuilder1 = new StringBuilder();
        AESHelp.AESEncrypt(this.txtName.Text.Trim(), ref strBuilder1);
        vars.Add(strBuilder1.ToString());
        vars.Add(selCorp.SelectedValue.Trim());
        DataTable data = SPHelper.callQuery("SP_CA_Query", context, "QRYACCTCUSTOMERINFO", vars.ToArray());
        if (data.Rows.Count == 0)
        {
            context.AddError("A001090203:没有查询出对应信息");
            return;
        }
        else
        {
            gvResult.DataSource = data;
            gvResult.DataBind();
            gvResult.SelectedIndex = 0;
            gv_SelectedIndexChanged(sender, e);
        }
         
       
    }

    /// <summary>
    ///OnPageIndexChanging
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void lvwQuery_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwQuery.PageIndex = e.NewPageIndex;
        BindGvData();
    }

    /// <summary>
    /// 查询按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        UserCardHelper.resetData(lvwQuery, null);
        BindGvData();
    }

    private void ClearGvResult()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }

    private void ClearlvwQuery()
    {
        lvwQuery.DataSource = new DataTable();
        lvwQuery.DataBind();
        lvwQuery.SelectedIndex = -1;
    }

    private void ClearReadCardInfo()
    {
        txtCardno.Text = "";
        LabAsn.Text = "";
        LabCardtype.Text = "";
        cMoney.Text = "";
        sDate.Text = "";
        eDate.Text = "";
    }


    //清空卡户信息
    private void ClearCardInfo()
    {
        lblResState.Text = "";
        lblAsn.Text = "";
        lblCardtype.Text = "";
        lblSellDate.Text = "";
        lblEndDate.Text = "";
        lblFConsumeTime.Text = "";
        lblLConsumeTime.Text = "";
        lblConsumeMoney.Text = "";
        lblFSupplyTime.Text = "";
        lblLSupplyTime.Text = "";
        lblSupplyMoney.Text = "";
        lblDeposit.Text = "";
        lblCardCost.Text = "";
        openFunc.List = null;
    }

    //清空用户信息
    private void ClearUserInfo()
    {
        lblCustName.Text = "";
        lblCustBirthday.Text = "";
        lblPapertype.Text = "";
        lblPaperno.Text = "";
        lblCustsex.Text = "";
        lblCustphone.Text = "";
        lblCustTelphone.Text = "";
        lblCustpost.Text = "";
        lblEmail.Text = "";
        lblCustaddr.Text = "";
        lblCorp.Text = "";
    }

    private void ClearAccountInfo()
    {
        gvAccount.DataSource = new DataTable();
        gvAccount.DataBind();
    }

    //清空账户业务查询结果
    private void ClearAccountTrade()
    {
        selType.SelectedIndex = 0;
        lvwQuery.DataSource = new DataTable();
        lvwQuery.DataBind();
    }

    /// <summary>
    /// GIRDVIEW绑定数据
    /// </summary>
    private void BindGvData()
    {
        if (selType.SelectedValue == "") return;

        //对起始日期和终止日期做检验
        beginDate.Text = beginDate.Text.Trim();
        endDate.Text = endDate.Text.Trim();
        UserCardHelper.validateDateRange(context, beginDate, endDate, true);
        if (context.hasError()) return;

        //Validation valid = new Validation(context);

        //if (valid.beDate(beginDate, "").Value.AddMonths(12) < DateTime.Now)
        //    context.AddError("A001003101");

        //if (context.hasError()) return;

        System.Collections.Generic.List<string> vars = new System.Collections.Generic.List<string>();
        vars.Add(this.txtCardno.Text.Trim());
        vars.Add(this.beginDate.Text.Trim());
        vars.Add(this.endDate.Text.Trim());

        DataTable data = SPHelper.callQuery("SP_CA_Query", context, selType.SelectedValue, vars.ToArray());
        UserCardHelper.resetData(lvwQuery, data);


    }

    /// <summary>
    /// OnRowDataBound
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void lvwQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        //控制金额、日期显示
        ControlDeal.RowDataBound(e);
    }

    /// <summary>
    /// 加载卡户、用户、账户信息
    /// </summary>
    private void LoadDisplayInfo()
    {
        #region 卡户信息
        Dictionary<String, DDOBase> listDDO = new Dictionary<String, DDOBase>();
        if (!CAHelper.GetCardInfo(context, txtCardno.Text, out listDDO))
        {
            return;
        }
        else
        {
            DDOBase ddoTL_R_ICUSEROut;
            listDDO.TryGetValue("TL_R_ICUSER", out ddoTL_R_ICUSEROut);
            DDOBase ddoTD_M_RESOURCESTATEOut;
            listDDO.TryGetValue("TD_M_RESOURCESTATE", out ddoTD_M_RESOURCESTATEOut);
            DDOBase ddoTD_M_CARDTYPEOut;
            listDDO.TryGetValue("TD_M_CARDTYPE", out ddoTD_M_CARDTYPEOut);
            DDOBase ddoTF_F_CARDEWALLETACCOut;
            listDDO.TryGetValue("TF_F_CARDEWALLETACC", out ddoTF_F_CARDEWALLETACCOut);
            DDOBase ddoTF_F_CARDRECOut;
            listDDO.TryGetValue("TF_F_CARDREC", out ddoTF_F_CARDRECOut);
            #region lblResState库存状态
            if (ddoTD_M_RESOURCESTATEOut == null)
                lblResState.Text = ((TL_R_ICUSERTDO)ddoTL_R_ICUSEROut).RESSTATECODE;
            else
                lblResState.Text = ((TD_M_RESOURCESTATETDO)ddoTD_M_RESOURCESTATEOut).RESSTATE;
            #endregion
            if ((TD_M_CARDTYPETDO)ddoTD_M_CARDTYPEOut != null)
            {
                this.lblCardtype.Text = ((TD_M_CARDTYPETDO)ddoTD_M_CARDTYPEOut).CARDTYPENAME;//卡类型
            }
            if ((TL_R_ICUSERTDO)ddoTL_R_ICUSEROut != null)
            {
                this.lblAsn.Text = ((TL_R_ICUSERTDO)ddoTL_R_ICUSEROut).ASN;//asn
            }
            //this.lblCardccMoney.Text = ((Convert.ToDecimal(((TF_F_CARDEWALLETACCTDO)ddoTF_F_CARDEWALLETACCOut).CARDACCMONEY)) / (Convert.ToDecimal(100))).ToString("0.00");
            if ((TF_F_CARDRECTDO)ddoTF_F_CARDRECOut != null)
            {
                this.lblSellDate.Text = ((TF_F_CARDRECTDO)ddoTF_F_CARDRECOut).SELLTIME.ToString("yyyy-MM-dd");

                this.lblEndDate.Text = ASHelper.toDateWithHyphen(((TF_F_CARDRECTDO)ddoTF_F_CARDRECOut).VALIDENDDATE);


                this.lblDeposit.Text = (Convert.ToDecimal(((TF_F_CARDRECTDO)ddoTF_F_CARDRECOut).DEPOSIT) / 100).ToString("0.00");
                this.lblCardCost.Text = (Convert.ToDecimal(((TF_F_CARDRECTDO)ddoTF_F_CARDRECOut).CARDCOST) / 100).ToString("0.00");
            }
            readAcc();

        }

        //查询卡片开通功能并显示
        PBHelper.openFunc(context, openFunc, txtCardno.Text);
        #endregion

        #region 账户信息

        DataTable data = CAHelper.callQuery(context, "QRYACCTOUNT", txtCardno.Text);
        UserCardHelper.resetData(gvAccount, data);

        string cust_id;
        string ACCT_ID;
        if (data != null && data.Rows.Count > 0)
        {
            cust_id = data.Rows[0]["CUST_ID"].ToString(); //取出客户标识
            ACCT_ID = data.Rows[0]["ACCT_ID"].ToString(); //取出账户标识
        }
        else
        {
            context.AddError("A001090102:未查出客户账户信息");
            return;
        }

       
        #endregion

        #region 用户信息
        listDDO = new Dictionary<String, DDOBase>();
        if (!CAHelper.GetCustInfo(context, txtCardno.Text, cust_id, out listDDO))
        {
            return;
        }
        else
        {
            DDOBase ddoTF_F_CUSTOut;
            listDDO.TryGetValue("TF_F_CUST", out ddoTF_F_CUSTOut);
            DDOBase ddoTD_M_PAPERTYPEOut;
            listDDO.TryGetValue("TD_M_PAPERTYPE", out ddoTD_M_PAPERTYPEOut);

            //证件类型显示
            if (((TF_F_CUSTTDO)ddoTF_F_CUSTOut).PAPER_TYPE_CODE != "")
            {
                lblPapertype.Text = ((TD_M_PAPERTYPETDO)ddoTD_M_PAPERTYPEOut).PAPERTYPENAME;
            }
            else
            {
                lblPapertype.Text = ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).PAPER_TYPE_CODE;
            }


            //性别显示
            if (((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_SEX == "0")
                lblCustsex.Text = "男";
            else if (((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_SEX == "1")
                lblCustsex.Text = "女";
            else lblCustsex.Text = "";

            //出生日期显示
            if (((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_BIRTH != "")
            {
                String Bdate = ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_BIRTH;
                if (Bdate.Length == 8)
                {
                    lblCustBirthday.Text = Bdate.Substring(0, 4) + "-" + Bdate.Substring(4, 2) + "-" + Bdate.Substring(6, 2);
                }
                else
                {
                    lblCustBirthday.Text = Bdate;
                }
            }
            DeEncrypt(lblCustName, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_NAME);
            DeEncrypt(lblPaperno, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).PAPER_NO);
            DeEncrypt(lblCustaddr, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_ADDR);
            lblCustpost.Text = ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_POST;
            DeEncrypt(lblCustphone, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_PHONE);
            DeEncrypt(lblCustTelphone, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_TELPHONE);
            lblEmail.Text = ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_EMAIL;

            if (!CommonHelper.HasOperPower(context))
            {
                lblPaperno.Text = CommonHelper.GetPaperNo(lblPaperno.Text);
                lblCustphone.Text = CommonHelper.GetCustPhone(lblCustphone.Text);
                lblCustTelphone.Text = CommonHelper.GetCustPhone(lblCustTelphone.Text);
                lblCustaddr.Text = CommonHelper.GetCustAddress(lblCustaddr.Text);
            }
        }
        #endregion

        #region 查询集团客户信息
        data = CAHelper.callQuery(context, "QRYCORPBYACCT", ACCT_ID);
        if (data != null && data.Rows.Count > 0)
        {
            lblCorp.Text = data.Rows[0]["CORPCODE"].ToString() + ":" + data.Rows[0]["CORPNAME"].ToString();
        }

        #endregion
    }

    protected void readAcc()
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

        lblSupplyMoney.Text = Convert.ToDouble(data.Rows[0][0].ToString()).ToString("0.00");
        lblConsumeMoney.Text = Convert.ToDouble(data.Rows[0][1].ToString()).ToString("0.00");
        if (data.Rows[0][2].ToString() == null || data.Rows[0][2].ToString() == "")
        {
            lblFSupplyTime.Text = "";
        }
        else lblFSupplyTime.Text = Convert.ToDateTime(data.Rows[0][2].ToString()).ToString("yyyy-MM-dd");

        if (data.Rows[0][3].ToString() == null || data.Rows[0][3].ToString() == "")
        {
            lblFConsumeTime.Text = "";
        }
        else lblFConsumeTime.Text = Convert.ToDateTime(data.Rows[0][3].ToString()).ToString("yyyy-MM-dd");
        if (data.Rows[0][4].ToString() == null || data.Rows[0][4].ToString() == "")
        {
            lblLConsumeTime.Text = "";
        }
        else lblLConsumeTime.Text = Convert.ToDateTime(data.Rows[0][4].ToString()).ToString("yyyy-MM-dd");
        if (data.Rows[0][5].ToString() == null || data.Rows[0][5].ToString() == "")
        {
            lblLSupplyTime.Text = "";
        }
        else lblLSupplyTime.Text = Convert.ToDateTime(data.Rows[0][5].ToString()).ToString("yyyy-MM-dd");

     
       
    }

    private void DeEncrypt(Control control, string text)
    {
        StringBuilder strBuilder = new StringBuilder();
        Label textbox = (Label)control;
        AESHelp.AESDeEncrypt(text, ref strBuilder);
        textbox.Text = strBuilder.ToString();
    }

    /// <summary>
    /// 验证证件号码
    /// </summary>
    /// <returns>通过验证返回true</returns>
    private Boolean ValidatePaperNo()
    {
        //对证件号码进行非空、长度、英数字检验
        if (txtPaperNo.Text.Trim() == "" && txtName.Text.Trim() == "")
        {
            context.AddError("A001001130");
        }
        else if (txtPaperNo.Text.Trim() != "" && !Validation.isCharNum(txtPaperNo.Text.Trim()))
        {
            context.AddError("A001001122", txtPaperNo);
        }
        else if (txtPaperNo.Text.Trim() != "" && Validation.strLen(txtPaperNo.Text.Trim()) > 20)
        {
            context.AddError("A001001123", txtPaperNo);
        }

        return !(context.hasError());
    }

    protected void gvAccount_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvAccount','Select$" + e.Row.RowIndex + "')");
        }
    }

    protected void gvAccount_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    protected void gv_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    /// <summary>
    /// 选择数据行事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gv_SelectedIndexChanged(object sender, EventArgs e)
    {
        ClearReadCardInfo();
        ClearCardInfo();
        ClearAccountInfo();
        ClearUserInfo();

        txtCardno.Text = gvResult.Rows[gvResult.SelectedIndex].Cells[0].Text.Trim();
        //btnDBread_Click(sender, e);

        //加载卡户、用户、账户信息
        LoadDisplayInfo();
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[1].Text.Trim() == "&nbsp;")
            {
                e.Row.Cells[1].Text = "";
            }
            if (e.Row.Cells[3].Text.Trim() == "&nbsp;")
            {
                e.Row.Cells[3].Text = "";
            }
            e.Row.Cells[1].Text = DeEncrypt(e.Row.Cells[1].Text);
            e.Row.Cells[3].Text = DeEncrypt(e.Row.Cells[3].Text);
            if (!CommonHelper.HasOperPower(context))
            {
                e.Row.Cells[3].Text = CommonHelper.GetPaperNo(e.Row.Cells[3].Text);
            }
        }
    }

    // gridview换页事件
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        createGridViewDataSource(sender,e);
    }

    //解密
    private string DeEncrypt(string value)
    {
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESDeEncrypt(value, ref strBuilder);
        return strBuilder.ToString();
    }

    /// <summary>
    /// 对查询条件的验证
    /// </summary>
    private bool CheckQueryControl()
    {
        bool isPapernoEmpty = Validation.isEmpty(this.txtPaperNo);
        bool isCardnoEmpty = Validation.isEmpty(this.txtInputCardNo);
        bool isNameEmpty = Validation.isEmpty(this.txtName);
        bool isCorpEmpty = (selCorp.SelectedValue.Trim() == "");
        if (isPapernoEmpty && isCardnoEmpty && isNameEmpty && isCorpEmpty)
        {
            context.AddError("A900010B91: 查询条件不可为空");
            return false;
        }

        if (isPapernoEmpty == false && Validation.isCharNum(txtPaperNo.Text.Trim()) == false)
        {
            context.AddError("A900010B92: 证件号必须是半角英文或数字", txtPaperNo);
            return false;
        }

        if (isPapernoEmpty == false && Validation.strLen(txtPaperNo.Text.Trim()) > 20)
        {
            context.AddError("A001001123", txtPaperNo);
            return false;
        }

        if (isCardnoEmpty == false)
        {
            if (Validation.isNum(txtInputCardNo.Text.Trim()) == false)
            {
                context.AddError("A900010B93: 卡号必须是数字", txtInputCardNo);
                return false;
            }
            else if (this.txtInputCardNo.Text.Trim().Length != 16)
            {
                context.AddError("A900010B94: 卡号位数必须为16位", txtInputCardNo);
                return false;
            }
        }

        return true;
    }
}
