using System;
using System.Web.UI;
using Common;
using TDO.CardManager;
using TDO.CustomerAcc;
using TDO.ResourceManager;
using TM;
using Master;
using System.Collections.Generic;
using System.Data;
using System.Web.UI.WebControls;
using System.Text;


/***************************************************************
 * 功能名: 专有账户_修改资料
 * 更改日期      姓名           摘要 
 * ----------    -----------    --------------------------------
 * 2011/07/21    董翔			初次开发
 ****************************************************************/
public partial class ASP_CustomerAcc_CA_ChangeCustInfo :  Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            if (!context.s_Debugging)
            {
               // setReadOnly(txtCardno);
               
            }
            ASHelper.initSexList(selCustsex);
            ASHelper.initPaperTypeList(context, selPapertype);
            gvAccount.DataKeyNames = new string[] { "ACCT_ID", "CUST_ID", "ACCT_TYPE_NO","ICCARD_NO", "ACCT_TYPE_NAME","ACCT_ITEM_TYPE", 
                                                    "LIMIT_DAYAMOUNT", "LIMIT_EACHTIME", "EFF_DATE", "STATE", "STATENAME", 
                                                     "Create_Date", "REL_BALANCE", "Total_Consume_Money", "Total_Consume_Times",
                                                     "LAST_CONSUME_TIME",  "Total_Supply_Money", "Total_Supply_Times", "LAST_SUPPLY_TIME"};

        }
    }

    /// <summary>
    /// 读卡按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        ClearAcctInfo();
        ClearUserInfo();
        txtUpperDay.Text = "";
        txtUpperOnce.Text = "";
        //加载卡户、用户、账户信息
        LoadDisplayInfo();
    }


    private void ClearAcctInfo()
    {
        gvAccount.DataSource = new DataTable();
        gvAccount.DataBind();
        gvAccount.SelectedIndex = -1;
    }

    private void ClearUserInfo()
    {
        txtCusname.Text = "";
        txtCustbirth.Text = "";
        selPapertype.SelectedIndex = 0;
        txtCustpaperno.Text = "";
        selCustsex.SelectedIndex = 0;
        txtCustphone.Text = "";
        txtCustTelphone.Text = "";
        txtCustpost.Text = "";
        txtCustaddr.Text = "";
        txtEmail.Text = "";
    }

    protected void btnDBReadCard_Click(object sender, EventArgs e)
    {
        ClearAcctInfo();
        ClearUserInfo();

        //对卡号空值长度数字的判断
        UserCardHelper.validateCardNo(context, txtCardno, false);
        if (context.hasError())
        {
            return;
        }
        txtUpperDay.Text = "";
        txtUpperOnce.Text = "";
        //加载卡户、用户、账户信息
        LoadDisplayInfo();
    }

    /// <summary>
    /// 提交按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (gvAccount.SelectedIndex < 0)
        {
            context.AddError("A001090201:请选择一条账户信息");
            return;
        }
        //if (this.PassWD.Text.Trim() == "")
        //{
        //    context.AddError("A001090202:请输入账户密码");
        //    return;
        //}
        
        #region 验证密码
        //if (!CAHelper.CheckPWD(context, this.txtCardno.Text, PassWD.Text.Trim(), true))
        //    return;
        #endregion


        if (ValidateBeforeSubmit() == false)
        {
            return;
        }

        //出生日期转换成yyyyMMdd
        string strBirth = "";
        if (txtCustbirth.Text.Trim() != "" && txtCustbirth.Text.Trim().Length == 10)
        {
            string[] arr = (txtCustbirth.Text.Trim()).Split('-');

            strBirth = arr[0] + arr[1] + arr[2];
        }
        if (!context.hasError())
        {
            string acctid = getDataKeys2("ACCT_ID");
            context.SPOpen();
            context.AddField("P_ACCTID").Value = acctid;
            context.AddField("P_CARDNO").Value = this.txtCardno.Text.Trim();

            StringBuilder strBuilder = new StringBuilder();
            AESHelp.AESEncrypt(txtCusname.Text.Trim(), ref strBuilder);
            context.AddField("P_CUSTNAME").Value = strBuilder.ToString();

            context.AddField("P_CUSTBIRTH").Value = strBirth;
            context.AddField("P_PAPERTYPECODE").Value = this.selPapertype.Text;

            AESHelp.AESEncrypt(txtCustpaperno.Text.Trim(), ref strBuilder);
            context.AddField("P_PAPERNO").Value = strBuilder.ToString();

            context.AddField("P_CUSTSEX").Value = this.selCustsex.Text;

            AESHelp.AESEncrypt(txtCustphone.Text, ref strBuilder);
            context.AddField("P_CUSTPHONE").Value = strBuilder.ToString();

            AESHelp.AESEncrypt(txtCustTelphone.Text, ref strBuilder);
            context.AddField("P_CUSTTELPHONE").Value = strBuilder.ToString();

            context.AddField("P_CUSTPOST").Value = this.txtCustpost.Text;

            AESHelp.AESEncrypt(txtCustaddr.Text, ref strBuilder);
            context.AddField("P_CUSTADDR").Value = strBuilder.ToString();

            context.AddField("P_CUSTEMAIL").Value = this.txtEmail.Text;
            context.AddField("P_CHANGE_LIMIT").Value = "1";
            if (this.txtUpperOnce.Text != "")
            {
                context.AddField("P_LIMIT_EACHTIME").Value = Convert.ToInt32((Convert.ToDecimal(this.txtUpperOnce.Text)) * 100).ToString();
            }
            else
            {
                context.AddField("P_LIMIT_EACHTIME").Value = "0";
            }
            if (this.txtUpperDay.Text != "")
            {
                context.AddField("P_LIMIT_DAYAMOUNT").Value = Convert.ToInt32((Convert.ToDecimal(this.txtUpperDay.Text)) * 100).ToString();
            }
            else
            {
                context.AddField("P_LIMIT_DAYAMOUNT").Value = "0";
            }

            bool ok = context.ExecuteSP("SP_CA_CHANGECUSTINFO");

            if (ok)
            {
                btnPrintPZ.Enabled = true;

                //ASHelper.preparePingZheng,待补充

                if (chkPingzheng.Checked && btnPrintPZ.Enabled)
                {
                    ScriptManager.RegisterStartupScript(
                        this, this.GetType(), "writeCardScript",
                        "printdiv('ptnPingZheng1');", true);
                }

                btnSubmit.Enabled = false;

                this.txtCardno.Text = "";
                AddMessage("M001090110:修改资料成功");
            }
        }

    }

    /// <summary>
    /// 提交前验证输入项
    /// </summary>
    /// <returns></returns>
    private bool ValidateBeforeSubmit()
    {
        //验证输入金额

        if (this.txtUpperOnce.Text.Trim().Length > 0 && !Validation.isNum(this.txtUpperDay.Text.Trim()))
        {
            context.AddError("A001090101:当日消费限额不是数字", txtUpperDay);
        }

        if (this.txtUpperOnce.Text.Trim().Length > 0 && !Validation.isNum(this.txtUpperOnce.Text.Trim()))
        {
            context.AddError("A001090101:每笔消费限额不是数字", txtUpperOnce);
        }

        #region 对用户信息进行验证
        //对用户姓名进行非空、长度检验
        if (txtCusname.Text.Trim() == "")
            context.AddError("A001001111", txtCusname);
        else if (Validation.strLen(txtCusname.Text.Trim()) > 50)
            context.AddError("A001001113", txtCusname);


        //对证件类型进行非空检验
        if (selPapertype.SelectedValue == "")
            context.AddError("A001001117", selPapertype);

        //对出生日期进行日期格式检验
        String cDate = txtCustbirth.Text.Trim();
        if (cDate != "")
        {
            if (!Validation.isDate(txtCustbirth.Text.Trim()))
                context.AddError("A001001115", txtCustbirth);
        }

        //对联系电话进行非空、长度、数字检验
       
        if (txtCustphone.Text.Trim() != "")
        {
            if (Validation.strLen(txtCustphone.Text.Trim()) > 20)
                context.AddError("A001001126:手机号码长度大于20位", txtCustphone);
            else if (!Validation.isNum(txtCustphone.Text.Trim()))
                context.AddError("A001001125:手机号码不是数字", txtCustphone);
        }
        if (txtCustTelphone.Text.Trim() != "")
        {
            if (Validation.strLen(txtCustTelphone.Text.Trim()) > 20)
                context.AddError("A001001127:固定电话长度大于20位", txtCustTelphone);
        }

        //对证件号码进行非空、长度、英数字检验
        if (txtCustpaperno.Text.Trim() == "")
            context.AddError("A001001121", txtCustpaperno);
        else if (!Validation.isCharNum(txtCustpaperno.Text.Trim()))
            context.AddError("A001001122", txtCustpaperno);
        else if (Validation.strLen(txtCustpaperno.Text.Trim()) > 20)
            context.AddError("A001001123", txtCustpaperno);
        else if (selPapertype.SelectedValue == "00" && !Validation.isPaperNo(txtCustpaperno.Text.Trim()))
            context.AddError("A001001131:证件号码验证不通过", txtCustpaperno);
        //对邮政编码进行非空、长度、数字检验
        if (txtCustpost.Text.Trim() != "")
        {
            if (Validation.strLen(txtCustpost.Text.Trim()) != 6)
                context.AddError("A001001120", txtCustpost);
            else if (!Validation.isNum(txtCustpost.Text.Trim()))
                context.AddError("A001001119", txtCustpost);
        }

        //对联系地址进行非空、长度检验
        if (txtCustaddr.Text.Trim() != "")
        {
            if (Validation.strLen(txtCustaddr.Text.Trim()) > 50)
                context.AddError("A001001128", txtCustaddr);
        }


        //对电子邮件进行格式检验
        if (txtEmail.Text.Trim() != "")
            new Validation(context).isEMail(txtEmail);
        #endregion

        return !(context.hasError());
    }

    /// <summary>
    /// 加载卡户、用户、账户信息
    /// </summary>
    private void LoadDisplayInfo()
    {
        #region 卡户信息
        TMTableModule tmTMTableModule = new TMTableModule();

        #region lblResState库存状态
        //从用户卡库存表(TL_R_ICUSER)中读取数据
        TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
        ddoTL_R_ICUSERIn.CARDNO = txtCardno.Text;

        TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

        if (ddoTL_R_ICUSEROut == null)
        {
            context.AddError("A001001101");
            return;
        }
        #endregion

        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = ddoTL_R_ICUSEROut.CARDTYPECODE;
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);
        if (ddoTD_M_CARDTYPEOut != null)
        {
            this.LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;//卡类型
        }

        this.LabAsn.Text = ddoTL_R_ICUSEROut.ASN;//asn

        //从IC卡电子钱包账户表中读取数据
        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text;
        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);
        if (ddoTF_F_CARDEWALLETACCOut != null)
        {
            this.cMoney.Text = ((Convert.ToDecimal(ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY)) / (Convert.ToDecimal(100))).ToString("0.00");
        }

        //从IC卡资料表中读取数据

        TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
        ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text;

        TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);
        if (ddoTF_F_CARDRECOut != null)
        {
            this.sDate.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");
            this.eDate.Text = ASHelper.toDateWithHyphen(ddoTF_F_CARDRECOut.VALIDENDDATE);
        }

        #endregion

        #region 账户信息

        DataTable data = CAHelper.callQuery(context, "QRYACCTOUNT", txtCardno.Text);
        UserCardHelper.resetData(gvAccount, data);

        Dictionary<String, DDOBase> listDDO = new Dictionary<String, DDOBase>();
        string cust_id;
        if (data != null && data.Rows.Count > 0)
        {
            cust_id = data.Rows[0]["CUST_ID"].ToString(); //取出客户标识
        }
        else
        {
            context.AddError("A001090102:未查出客户账户信息");
            return;
        }

        //listDDO = new Dictionary<String, DDOBase>();
        //if (!CAHelper.GetCustAcctInfo(context, txtCardno.Text, false, out listDDO))
        //{
        //    return;
        //}
        //else
        //{
        //    DDOBase ddoTF_F_CUST_ACCTOut;
        //    listDDO.TryGetValue("TF_F_CUST_ACCT", out ddoTF_F_CUST_ACCTOut);
        //    DDOBase ddoTF_F_ACCT_BALANCEOut;
        //    listDDO.TryGetValue("TF_F_ACCT_BALANCE", out ddoTF_F_ACCT_BALANCEOut);
        //    this.txtUpperOnce.Text = ((Convert.ToDecimal(((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).LIMIT_EACHTIME)) / (Convert.ToDecimal(100))).ToString();
        //    this.txtUpperDay.Text = ((Convert.ToDecimal(((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).LIMIT_DAYAMOUNT)) / (Convert.ToDecimal(100))).ToString();
            //this.lblEffDate.Text = ((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).EFF_DATE.ToString("yyyy-MM-dd");
            //this.lblAccState.Text = CAHelper.GetAccStateByCode(((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).STATE);
            //this.lblCreateDate.Text = ((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).CREATE_DATE.ToString("yyyy-MM-dd");
            //this.lblRelBalance.Text = ((Convert.ToDecimal(((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).REL_BALANCE)) / (Convert.ToDecimal(100))).ToString("0.00"); ;

            //this.lblTotalConsume.Text = ((Convert.ToDecimal(((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).TOTAL_CONSUME_MONEY)) / (Convert.ToDecimal(100))).ToString("0.00");
            //this.lblTotalConsumeTimes.Text = ((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).TOTAL_CONSUME_TIMES.ToString();
            //this.lblLastConsumeTime.Text = (((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).TOTAL_CONSUME_TIMES == 0) ? "" : ((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).LAST_CONSUME_TIME.ToString("yyyy-MM-dd");

            //this.lblTotalSupply.Text = ((Convert.ToDecimal(((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).TOTAL_SUPPLY_MONEY)) / (Convert.ToDecimal(100))).ToString("0.00");
            //this.lblTotalSupplyTimes.Text = ((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).TOTAL_SUPPLY_TIMES.ToString();
            //this.lblLastSupplyTime.Text = (((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).TOTAL_SUPPLY_TIMES == 0) ? "" : ((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).LAST_SUPPLY_TIME.ToString("yyyy-MM-dd");
        //    cust_id = ((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).CUST_ID;

        //    if (((TF_F_CUST_ACCTTDO)ddoTF_F_CUST_ACCTOut).STATE.Equals("A") == false
        //        || ((TF_F_ACCT_BALANCETDO)ddoTF_F_ACCT_BALANCEOut).STATE.Equals("A") == false)
        //    {
        //        context.AddMessage("A001090121:账户或余额账本状态无效，请确定是否继续充值");
        //    }
        //}
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

            //出生日期显示
            if (((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_BIRTH != "")
            {
                String Bdate = ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_BIRTH;
                if (Bdate.Length == 8)
                {
                    txtCustbirth.Text = Bdate.Substring(0, 4) + "-" + Bdate.Substring(4, 2) + "-" + Bdate.Substring(6, 2);
                }
                else
                {
                    txtCustbirth.Text = Bdate;
                }
            }

            selPapertype.SelectedIndex = selPapertype.Items.IndexOf(selPapertype.Items.FindByValue(((TF_F_CUSTTDO)ddoTF_F_CUSTOut).PAPER_TYPE_CODE));
            selCustsex.SelectedIndex = selCustsex.Items.IndexOf(selCustsex.Items.FindByValue(((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_SEX));
            DeEncrypt(txtCusname, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_NAME);
            DeEncrypt(txtCustpaperno, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).PAPER_NO);
            DeEncrypt(txtCustaddr, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_ADDR);
            txtCustpost.Text = ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_POST;
            DeEncrypt(txtCustphone, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_PHONE);
            DeEncrypt(txtCustTelphone, ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_TELPHONE);
            txtEmail.Text = ((TF_F_CUSTTDO)ddoTF_F_CUSTOut).CUST_EMAIL;
        }
        #endregion

        this.btnSubmit.Enabled = true;
    }

    private void DeEncrypt(Control control, string text)
    {
        StringBuilder strBuilder = new StringBuilder();
        TextBox textbox = (TextBox)control;
        AESHelp.AESDeEncrypt(text, ref strBuilder);
        textbox.Text = strBuilder.ToString();
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
        txtUpperDay.Text = Convert.ToInt32(getDataKeys2("LIMIT_DAYAMOUNT")).ToString();
        txtUpperOnce.Text = Convert.ToInt32(getDataKeys2("LIMIT_EACHTIME")).ToString();
        btnSubmit.Enabled = true;
    }

    public String getDataKeys2(String keysname)
    {
        return gvAccount.DataKeys[gvAccount.SelectedIndex][keysname].ToString();
    }

}