using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using TM;
using Common;
using TDO.CardManager;
using TDO.CustomerAcc;
using System.Data;
using TDO.PersonalTrade;
using TDO.BusinessCode;
using TDO.UserManager;
using System.Text;
using System.Collections;
/***************************************************************
 * 功能名: 专有账户_换卡转账户
 * 更改日期      姓名           摘要 
 * ----------    -----------    --------------------------------
 * 2012/08/31   殷华荣			初次开发
 ****************************************************************/
public partial class ASP_CustomerAcc_CA_ChangeCardTransitBalance : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            if (!context.s_Debugging)
            {
                setReadOnly(OtxtCardno);
                setReadOnly(ItxtCardno);
            }
            gvOutAccount.DataKeyNames = new string[] { "ACCT_ID", "CUST_ID", "ACCT_TYPE_NO","ICCARD_NO", "ACCT_TYPE_NAME","ACCT_ITEM_TYPE", 
                                                    "LIMIT_DAYAMOUNT", "LIMIT_EACHTIME", "EFF_DATE", "STATE", "STATENAME", 
                                                     "Create_Date", "REL_BALANCE", "Total_Consume_Money", "Total_Consume_Times",
                                                     "LAST_CONSUME_TIME",  "Total_Supply_Money", "Total_Supply_Times", "LAST_SUPPLY_TIME"};
        }
    }


    /// <summary>
    /// 读新卡按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        if (OtxtCardno.Text.Trim() != ItxtCardno.Text.Trim())
        {
            //加载卡户、用户、账户信息
            LoadDisplayInfo(true, ItxtCardno, null, IlblCusname, IlblCustphone, IlblPapertype, IlblCustpaperno, null, null
                    , null, null, null, null, null, gvInAccount, true);
            ChangeInfo();
        }
        else
        {
            context.AddError("A006001313:同一张卡不能做挂失补账户操作");
        }
    }

    /// <summary>
    /// 读数据库按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDBread_Click(object sender, EventArgs e)
    {
        //对卡号空值长度数字的判断
        UserCardHelper.validateCardNo(context, OtxtCardno, false);
        if (context.hasError())
        {
            return;
        }

        //加载用户、账户信息
        LoadDisplayInfo(false, OtxtCardno, null, OlblCusname, OlblCustphone, OlblPapertype, OlblCustpaperno, null, null
        , null, null, null, null, null, gvOutAccount, false);

    }
    /// <summary>
    /// 加载旧卡信息
    /// </summary>
    protected void ChangeInfo()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //从业务台帐主表中读取数据
        TF_B_TRADETDO ddoTF_B_TRADEIn = new TF_B_TRADETDO();
        ddoTF_B_TRADEIn.CARDNO = ItxtCardno.Text;
        TF_B_TRADETDO ddoTF_B_TRADEOut = (TF_B_TRADETDO)tmTMTableModule.selByPK(context, ddoTF_B_TRADEIn, typeof(TF_B_TRADETDO), null, "TF_B_TRADE_Transit", null);
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

        if (ddoTD_M_INSIDESTAFFOut == null)
        {
            ddoTD_M_INSIDESTAFFOut.STAFFNAME = "市民卡换卡";
        }
        //给页面显示项赋值


        OtxtCardno.Text = ddoTF_B_TRADEOut.OLDCARDNO;

        //加载用户、账户信息
        LoadDisplayInfo(false, OtxtCardno, null, OlblCusname, OlblCustphone, OlblPapertype, OlblCustpaperno, null, null
        , null, null, null, null, null, gvOutAccount, false);

        this.btnTransAcc.Enabled = true;

    }

    /// <summary>
    /// 转账按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (this.PassWD.Text.Trim() == "")
        {
            context.AddError("A001090202:请输入账户密码");
            return;
        }

        string cardNo = OtxtCardno.Text;

        #region 验证密码
        if (ViewState["ACCT_ID"] != null)
        {
            ArrayList list = (ArrayList)ViewState["ACCT_ID"];
            for (int i = 0; i < list.Count; i++)
            {
                //验证密码
                if (!CAHelper.CheckMultipleAccPWD(context, list[i].ToString(), PassWD.Text.Trim(), true))
                {
                    this.btnTransAcc.Enabled = false;
                    return;
                }
            }
        }

        #endregion

        if (!context.hasError())
        {
            //存储过程中自动开户 兼 转账
            context.SPOpen();
            context.AddField("P_OCARDNO").Value = OtxtCardno.Text;
            context.AddField("P_ICARDNO").Value = ItxtCardno.Text;
            context.AddField("p_TRADEORIGIN").Value = "";

            StringBuilder szOutput = new System.Text.StringBuilder(256);
            CAEncryption.CAEncrypt("111111", ref szOutput);
            context.AddField("P_PWD").Value = szOutput.ToString();

            context.AddField("p_TRADEID", "String", "output", "16", null);

            bool ok = context.ExecuteSP("SP_CA_CHANGECARDTRANSITBALANCE");

            if (ok)
            {
                if (!context.hasError())
                {
                    context.AddMessage("M001090113:换卡补账户成功");
                    context.DBCommit();
                }

                btnPrintPZ.Enabled = true;

                ////打印凭证
                //ASHelper.preparePingZheng(ptnPingZheng, this.lblCardno.Text, this.lblCustName.Text, strTradetypeName,
                //    "0.00", "", "", this.lblPaperno.Text, "", "0.00",
                //    "0.00", context.s_UserName, "", this.lblPapertype.Text, "0.00",
                //    "");

                if (chkPingzheng.Checked && btnPrintPZ.Enabled)
                {
                    ScriptManager.RegisterStartupScript(
                        this, this.GetType(), "writeCardScript",
                        "printdiv('ptnPingZheng1');", true);
                }
                this.btnTransAcc.Enabled = false;
            }
        }
    }

    /// <summary>
    /// 加载用户、账户信息
    /// </summary>
    private void LoadDisplayInfo(bool CheckAccState, Control cardno, Control relBalance, Control cusname, Control custphone, Control papertype,
       Control custpaperno, Control accState, Control createDate, Control totalConsume, Control totalSupply, Control UpperType,
        Control upper, Control accid, GridView gv, bool isInCard)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        #region 用户信息
        //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据  改方法可提取封装
        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
        ddoTF_F_CUSTOMERRECIn.CARDNO = ((TextBox)cardno).Text;
        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);
        if (ddoTF_F_CUSTOMERRECOut == null)
        {
            context.AddError("A001107112");
            this.btnTransAcc.Enabled = false;
            return;
        }

        if (ddoTF_F_CUSTOMERRECOut.PAPERNO != "" && ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE != "")
        {//如果新客户资料表存在显示新客户资料信息
            TF_F_CUSTTDO ddoTF_F_CUSTIn = new TF_F_CUSTTDO();
            ddoTF_F_CUSTIn.ICCARD_NO = ddoTF_F_CUSTOMERRECOut.CARDNO;
            
            TF_F_CUSTTDO ddoTF_F_CUSTOut = (TF_F_CUSTTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTIn, typeof(TF_F_CUSTTDO), null, "TF_F_CUST_CARDNO", null);

            if (ddoTF_F_CUSTOut != null)
            {
                DeEncrypt(cusname, ddoTF_F_CUSTOut.CUST_NAME);

                //从证件类型编码表(TD_M_PAPERTYPE)中读取数据
                TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
                ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOut.PAPER_TYPE_CODE;
                TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);
                ((Label)papertype).Text = ddoTD_M_PAPERTYPEOut.PAPERTYPENAME;

                DeEncrypt(custpaperno, ddoTF_F_CUSTOut.PAPER_NO);
                DeEncrypt(custphone, ddoTF_F_CUSTOut.CUST_PHONE);
            }
        }
        else
        {
            DeEncrypt(cusname, ddoTF_F_CUSTOMERRECOut.CUSTNAME);

            //从证件类型编码表(TD_M_PAPERTYPE)中读取数据
            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
            ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;
            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);
            ((Label)papertype).Text = ddoTD_M_PAPERTYPEOut.PAPERTYPENAME;

            DeEncrypt(custpaperno, ddoTF_F_CUSTOMERRECOut.PAPERNO);
            DeEncrypt(custphone, ddoTF_F_CUSTOMERRECOut.CUSTPHONE);
        }

        if (!CommonHelper.HasOperPower(context))
        {
            ((Label)custpaperno).Text = CommonHelper.GetPaperNo(((Label)custpaperno).Text);
            ((Label)custphone).Text = CommonHelper.GetCustPhone(((Label)custphone).Text);
        }

        #endregion

        #region 账户信息

        DataTable data = CAHelper.callQuery(context, "QRYACCTOUNT", ((TextBox)cardno).Text);
        UserCardHelper.resetData(gv, data);

        if (!isInCard) //如果读转出卡 不需要验证是否已开户
        {
            if (data == null || data.Rows.Count == 0)
            {
                context.AddError("A006023009:未查出客户账户信息");
                this.btnTransAcc.Enabled = false;
                return;
            }
            //取出所有账户标识
            ArrayList list = new ArrayList();
            for (int i = 0; i < data.Rows.Count; i++)
            {
                list.Add(data.Rows[i]["ACCT_ID"]);
            }
            ViewState["ACCT_ID"] = list;
        }
        if (data != null || data.Rows.Count > 0)
        {
            if (CheckAccState) //转入卡 验证客户账户状态是否有效
            {
                for (int i = 0; i < data.Rows.Count; i++)
                {
                    if (!data.Rows[i]["STATE"].ToString().Equals("A"))
                    {
                        context.AddError("A001090103:客户账户状态无效");
                        this.btnTransAcc.Enabled = false;
                        return;
                    }
                }
            }
            else //转出卡验证客户账户是否是挂失状态
            {
                for (int i = 0; i < data.Rows.Count; i++)
                {
                    if (!data.Rows[i]["STATE"].ToString().Equals("A"))
                    {
                        context.AddError("A001090103:客户账户状态无效");
                        this.btnTransAcc.Enabled = false;
                        return;
                    }
                }
            }
        }
        #endregion
    }

    private void DeEncrypt(Control control, string text)
    {
        StringBuilder strBuilder = new StringBuilder();
        Label textbox = (Label)control;
        AESHelp.AESDeEncrypt(text, ref strBuilder);
        textbox.Text = strBuilder.ToString();
    }

}