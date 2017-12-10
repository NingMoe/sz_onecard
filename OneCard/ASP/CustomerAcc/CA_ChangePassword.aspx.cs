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
using TDO.CardManager;
using TM;
using Common;
using TDO.BusinessCode;
using PDO.PersonalBusiness;
using TDO.CustomerAcc;
using TDO.UserManager;
using System.Text;

/***************************************************************
 * 功能名: 专有账户_修改密码
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2011/06/21    liuh			初次开发
 ****************************************************************/
public partial class ASP_CustomerAcc_CA_ChangePassword : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";
            gvAccount.DataKeyNames = new string[] { "ACCT_ID", "CUST_ID", "ACCT_TYPE_NO","ICCARD_NO", "ACCT_TYPE_NAME","ACCT_ITEM_TYPE", 
                                                    "LIMIT_DAYAMOUNT", "LIMIT_EACHTIME", "EFF_DATE", "STATE", "STATENAME", 
                                                     "Create_Date", "REL_BALANCE", "Total_Consume_Money", "Total_Consume_Times",
                                                     "LAST_CONSUME_TIME",  "Total_Supply_Money", "Total_Supply_Times", "LAST_SUPPLY_TIME"};
        }
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
    }

    /// <summary>
    /// 读卡按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        ClearUserInfo();

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

        this.btnChangeUserPass.Enabled = true;
    }

    private void DeEncrypt(Control control, string text)
    {
        StringBuilder strBuilder = new StringBuilder();
        Label textbox = (Label)control;
        AESHelp.AESDeEncrypt(text, ref strBuilder);
        textbox.Text = strBuilder.ToString();
    }

    /// <summary>
    /// 修改密码按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnChangeUserPass_Click(object sender, EventArgs e)
    {
        if (!ChangePasswordValidation())
            return;

        if (txtCardno.Text == "")
        {
            context.AddError("A005001100");
            return;
        }

        StringBuilder szOutput = new System.Text.StringBuilder(256);
        CAEncryption.CAEncrypt(txtOPwd.Text.Trim(), ref szOutput);

        string oldPwd = szOutput.ToString(); //CAHelper.Md5Encrypt(txtOPwd.Text.Trim());
        if (this.cbxIsFirst.Checked)
        {//如果是首次修改，对比配置表中的初始密码和账户表密码

            TMTableModule tmTMTableModule = new TMTableModule();
      
            //客户账户
            TF_F_CUST_ACCTTDO ddoTF_F_CUST_ACCTIn = new TF_F_CUST_ACCTTDO();
            ddoTF_F_CUST_ACCTIn.ICCARD_NO = txtCardno.Text;

            TF_F_CUST_ACCTTDO ddoTF_F_CUST_ACCTOut = (TF_F_CUST_ACCTTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUST_ACCTIn, typeof(TF_F_CUST_ACCTTDO), null, "TF_F_CUST_ACCT", null);

            //获取初始密码
            StringBuilder pwd = new System.Text.StringBuilder(256);
            CAEncryption.CAEncrypt("111111", ref pwd);


            if (pwd.ToString().Equals(ddoTF_F_CUST_ACCTOut.CUST_PASSWARD) == false)
            {
                context.AddError("A004111010:账户密码与初始密码不同，不是首次修改");
                return;
            }
            else
            {
                oldPwd = pwd.ToString();
            }
        }

        string sessionid = Session.SessionID;
        CAHelper.FillAccIDList(context, gvAccount, sessionid);

        context.SPOpen();
        context.AddField("P_SESSIONID").Value = sessionid;
        context.AddField("P_CARDNO").Value = txtCardno.Text;
        context.AddField("P_OLDPASSWD").Value = oldPwd;

        szOutput = new System.Text.StringBuilder(256);
        CAEncryption.CAEncrypt(txtNPwd.Text.Trim(), ref szOutput);

        context.AddField("P_NEWPASSWD").Value = szOutput.ToString(); 

        bool ok = context.ExecuteSP("SP_CA_CHANGEACCPASS");

        if (ok)
        {
            AddMessage("M001111001");
            foreach (Control con in this.Page.Controls)
            {
                ClearControl(con);
            }
            btnChangeUserPass.Enabled = false;
            this.cbxIsFirst.Checked = false;
        }
        //清空临时表
        CAHelper.clearTempCustInfoTable(context);
    }

    /// <summary>
    /// 修改密码前的验证
    /// </summary>
    /// <returns></returns>
    private Boolean ChangePasswordValidation()
    {
        //对原密码进行非空、长度、数字检验
        String strOPwd = txtOPwd.Text.Trim();

        if (strOPwd == "")
            context.AddError("A004111001", txtOPwd);
        else
        {
            int len = Validation.strLen(strOPwd);

            if (Validation.strLen(strOPwd) != 6)
                context.AddError("A004111002", txtOPwd);
            else if (!Validation.isNum(strOPwd))
                context.AddError("A004111003", txtOPwd);

        }

        //对新密码进行非空、长度、英数检验
        String strNPwd = txtNPwd.Text.Trim();
        if (strNPwd == "")
            context.AddError("A004111004", txtNPwd);
        else
        {
            int len = Validation.strLen(strNPwd);

            if (Validation.strLen(strNPwd) != 6)
                context.AddError("A004111005", txtNPwd);
            else if (!Validation.isNum(strNPwd))
                context.AddError("A004111006", txtNPwd);
        }

        //对新密码确认进行非空检验
        String strANPwd = txtANPwd.Text.Trim();

        if (strANPwd == "")
            context.AddError("A004111007", txtANPwd);

        //对原密码与新密码是否一样进行检验
        if (!context.hasError())
        {
            if (strOPwd == strNPwd)
                context.AddError("A004111008", txtANPwd);
        }

        //对新密码与新密码确认是否一样进行检验
        if (!context.hasError())
        {
            if (strNPwd != strANPwd)
                context.AddError("A004111009", txtANPwd);
        }

        if (context.hasError())
            return false;
        else
            return true;
    }

}
