using System;
using System.Data;
using System.Configuration;
using System.Collections.Generic;
using System.Collections;
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
 * 功能名: 专有账户_开户
 * 更改日期      姓名           摘要 
 * ----------    -----------    --------------------------------
 * 2011/06/21    liuh			初次开发
 ****************************************************************/
public partial class ASP_CustomerAcc_CA_OpenAcc : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            if (!context.s_Debugging) setReadOnly(txtCardno);

            setReadOnly(LabAsn, LabCardtype, cMoney, sDate, eDate);

            ASHelper.initSexList(selCustsex);
            ASHelper.initPaperTypeList(context, selPapertype);

            CAHelper.FillAcctType(context, ddlAcctType);
        }
    }

    /// <summary>
    /// 读卡按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        #region add by shil 20130909,如果是旅游年卡，则不允许在该页面办理业务
        //验证卡片是否旅游年卡(51)，如果是旅游年卡，则不允许在该页面办理业务
        bool cardTypeOk = CommonHelper.allowCardtype(context, txtCardno.Text, "5101", "5103");
        if (cardTypeOk == false)
        {
            return;
        }
      
        #endregion

        TMTableModule tmTMTableModule = new TMTableModule();

        //卡账户有效性检验
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;

        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (ok == false)
        {
            return;
        }

        #region 卡片信息（从卡片里读出的数据）
        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPE_Out = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);
        LabCardtype.Text = ddoTD_M_CARDTYPE_Out.CARDTYPENAME;

        LabAsn.Text = hiddenAsn.Value.Substring(4, 16);
        sDate.Text = ASHelper.toDateWithHyphen(hiddensDate.Value);
        eDate.Text = ASHelper.toDateWithHyphen(hiddeneDate.Value);
        cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / (Convert.ToDecimal(100))).ToString("0.00");
        #endregion

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
            this.lblCardtype.Text = ((TD_M_CARDTYPETDO)ddoTD_M_CARDTYPEOut).CARDTYPENAME;//卡类型
            this.lblAsn.Text = ((TL_R_ICUSERTDO)ddoTL_R_ICUSEROut).ASN;//asn
            //this.lblCardccMoney.Text = ((Convert.ToDecimal(((TF_F_CARDEWALLETACCTDO)ddoTF_F_CARDEWALLETACCOut).CARDACCMONEY)) / (Convert.ToDecimal(100))).ToString("0.00");
            this.lblSellDate.Text = ((TF_F_CARDRECTDO)ddoTF_F_CARDRECOut).SELLTIME.ToString("yyyy-MM-dd");
            this.lblEndDate.Text = ASHelper.toDateWithHyphen(((TF_F_CARDRECTDO)ddoTF_F_CARDRECOut).VALIDENDDATE);
        }

        //查询卡片开通功能并显示
        PBHelper.openFunc(context, openFunc, txtCardno.Text);
        #endregion

        #region 用户信息
        //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据
        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
        ddoTF_F_CUSTOMERRECIn.CARDNO = txtCardno.Text;

        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

        if (ddoTF_F_CUSTOMERRECOut == null)
        {
            context.AddError("A001107112");
            return;
        }

        if (ddoTF_F_CUSTOMERRECOut.PAPERNO != "" && ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE != "")
        {//如果新客户资料表存在显示新客户资料信息
            TF_F_CUSTTDO ddoTF_F_CUSTIn = new TF_F_CUSTTDO();
            ddoTF_F_CUSTIn.PAPER_NO = ddoTF_F_CUSTOMERRECOut.PAPERNO;
            ddoTF_F_CUSTIn.PAPER_TYPE_CODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

            TF_F_CUSTTDO ddoTF_F_CUSTOut = (TF_F_CUSTTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTIn, typeof(TF_F_CUSTTDO), null, "TF_F_CUST", null);

            if (ddoTF_F_CUSTOut != null)
            {

               
                DeEncrypt(this.txtCusname, ddoTF_F_CUSTOut.CUST_NAME);

                if (ddoTF_F_CUSTOut.CUST_BIRTH != "")
                {
                    String Bdate = ddoTF_F_CUSTOut.CUST_BIRTH;
                    if (Bdate.Length == 8)
                    {
                        txtCustbirth.Text = Bdate.Substring(0, 4) + "-" + Bdate.Substring(4, 2) + "-" + Bdate.Substring(6, 2);
                    }
                    else txtCustbirth.Text = Bdate;
                }
               
                DeEncrypt(this.txtCustpaperno, ddoTF_F_CUSTOut.PAPER_NO);

                this.selPapertype.SelectedValue = ddoTF_F_CUSTOut.PAPER_TYPE_CODE;
                this.selCustsex.SelectedValue = ddoTF_F_CUSTOut.CUST_SEX;

                DeEncrypt(txtCustaddr, ddoTF_F_CUSTOut.CUST_ADDR);

                this.txtCustpost.Text = ddoTF_F_CUSTOut.CUST_POST;

                DeEncrypt(txtCustphone, ddoTF_F_CUSTOut.CUST_PHONE);

                DeEncrypt(txtCustTelphone, ddoTF_F_CUSTOut.CUST_TELPHONE);

                this.txtEmail.Text = ddoTF_F_CUSTOut.CUST_EMAIL;
            }
        }
        else
        {
            DeEncrypt(txtCusname, ddoTF_F_CUSTOMERRECOut.CUSTNAME);
            if (ddoTF_F_CUSTOMERRECOut.CUSTBIRTH != "")
            {
                String Bdate = ddoTF_F_CUSTOMERRECOut.CUSTBIRTH;
                if (Bdate.Length == 8)
                {
                    txtCustbirth.Text = Bdate.Substring(0, 4) + "-" + Bdate.Substring(4, 2) + "-" + Bdate.Substring(6, 2);
                }
                else txtCustbirth.Text = Bdate;
            }
            DeEncrypt(txtCustpaperno, ddoTF_F_CUSTOMERRECOut.PAPERNO);
            this.selPapertype.SelectedValue = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;
            this.selCustsex.SelectedValue = ddoTF_F_CUSTOMERRECOut.CUSTSEX;
            DeEncrypt(txtCustaddr, ddoTF_F_CUSTOMERRECOut.CUSTADDR);
            this.txtCustpost.Text = ddoTF_F_CUSTOMERRECOut.CUSTPOST;
            DeEncrypt(txtCustphone, ddoTF_F_CUSTOMERRECOut.CUSTPHONE);
            this.txtEmail.Text = ddoTF_F_CUSTOMERRECOut.CUSTEMAIL;
        }
        #endregion

        if (!CommonHelper.HasOperPower(context))
        {
            txtCustpaperno.Text = CommonHelper.GetPaperNo(txtCustpaperno.Text);
            txtCustphone.Text = CommonHelper.GetCustPhone(txtCustphone.Text);
            txtCustTelphone.Text = CommonHelper.GetCustPhone(txtCustTelphone.Text);
            txtCustaddr.Text = CommonHelper.GetCustAddress(txtCustaddr.Text);
        }

        InitAccInfo();
        
        this.btnOpenAcc.Enabled = true;
        
    }

    private void DeEncrypt(Control control, string text)
    {
        StringBuilder strBuilder = new StringBuilder();
        TextBox textbox = (TextBox)control;
        AESHelp.AESDeEncrypt(text, ref strBuilder);
        textbox.Text = strBuilder.ToString();
    }

    /// <summary>
    /// 开户按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnOpenAcc_Click(object sender, EventArgs e)
    {
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

        context.SPOpen();
        context.AddField("P_CARDNO").Value = this.txtCardno.Text;
        context.AddField("P_ACCTYPE").Value = ddlAcctType.SelectedValue;

        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCusname.Text, ref strBuilder);
        context.AddField("P_CUSTNAME").Value = strBuilder.ToString();

        context.AddField("P_CUSTBIRTH").Value = strBirth;
        context.AddField("P_PAPERTYPECODE").Value = this.selPapertype.Text;

        AESHelp.AESEncrypt(txtCustpaperno.Text, ref strBuilder);
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
        context.AddField("P_ISUPOLDCUS").Value = this.chkUpOldCus.Checked == true ? "1" : "0";

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

        string str1 = "111111"; //初始密码
        StringBuilder szOutput = new System.Text.StringBuilder(256);
        CAEncryption.CAEncrypt(str1, ref szOutput);
        context.AddField("P_PWD").Value = szOutput.ToString();

        bool ok = context.ExecuteSP("SP_CA_OpenAcc");

        if (ok)
        {
            context.DBCommit();

            btnPrintPZ.Enabled = true;

            //ASHelper.preparePingZheng,待补充

            if (chkPingzheng.Checked && btnPrintPZ.Enabled)
            {
                ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "printdiv('ptnPingZheng1');", true);
            }

            btnOpenAcc.Enabled = false;

            this.txtCardno.Text = "";

            InitAccInfo();

            AddMessage("M001090110:开户成功，请修改初始密码");
        }

    }

    /// <summary>
    /// 提交前验证输入项
    /// </summary>
    /// <returns></returns>
    private bool ValidateBeforeSubmit()
    {
        //验证输入金额

            if (this.txtUpperOnce.Text.Trim().Length >0 &&!Validation.isNum(this.txtUpperDay.Text.Trim()) )
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
        if (txtCustphone.Text.Trim() == "" && txtCustTelphone.Text.Trim() == "")
        {
            context.AddError("A006001129:手机号码和固定电话最少填一个", txtCustphone);
        }

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
    /// 初始化账户信息
    /// </summary>
    /// <returns>账户是否存在</returns>
    private bool InitAccInfo()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //客户账户
        DataTable data = CAHelper.callQuery(context, "QRYACCTOUNT", txtCardno.Text.Trim());
        UserCardHelper.resetData(gvAccount, data);
        return true;
    }

}
