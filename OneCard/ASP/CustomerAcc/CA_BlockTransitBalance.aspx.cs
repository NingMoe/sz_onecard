using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using TM;
using Common;
using TDO.CardManager;
using TDO.CustomerAcc;
using System.Data;
using System.Text;
using System.Collections;
using TDO.BusinessCode;
using System.Collections.Generic;
using PDO.PersonalBusiness;
using Master;
/***************************************************************
 * 功能名: 专有账户_挂失转账户
 * 更改日期      姓名           摘要 
 * ----------    -----------    --------------------------------
 * 2011/08/16   董翔			初次开发
 ****************************************************************/
public partial class ASP_CustomerAcc_CA_BlockTransitBalance : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            setReadOnly(OtxtCardno);
            //if (!context.s_Debugging)
            //{
            //    setReadOnly(OtxtCardno);
            //    setReadOnly(ItxtCardno);
            //}
            gvOutAccount.DataKeyNames = new string[] { "ACCT_ID", "CUST_ID", "ACCT_TYPE_NO","ICCARD_NO", "ACCT_TYPE_NAME","ACCT_ITEM_TYPE", 
                                                    "LIMIT_DAYAMOUNT", "LIMIT_EACHTIME", "EFF_DATE", "STATE", "STATENAME", 
                                                     "Create_Date", "REL_BALANCE", "Total_Consume_Money", "Total_Consume_Times",
                                                     "LAST_CONSUME_TIME",  "Total_Supply_Money", "Total_Supply_Times", "LAST_SUPPLY_TIME"};
            // 初始化集团客户
            GroupCardHelper.initGroupCustomer(context, selCorp);
        }
        if (CAHelper.HasNoPasswordPower(context))
        {
            div_password.Visible = false;
        }
    }

    //清空查询信息
    private void ClearQueryInfo()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }
    //清空挂失卡用户信息
    private void ClearOUserInfo()
    {
        OtxtCardno.Text = "";
        OlblCusname.Text = "";
        OlblCustphone.Text = "";
        OlblPapertype.Text = "";
        OlblCustpaperno.Text = "";
    }
    //清空挂失卡账户信息
    private void ClearOAccountInfo()
    {
        gvOutAccount.DataSource = new DataTable();
        gvOutAccount.DataBind();
    }

    //清空转入卡信息
    private void ClearIUserInfo()
    {
        ItxtCardno.Text = "";
        IlblCusname.Text = "";
        IlblCustphone.Text = "";
        IlblPapertype.Text = "";
        IlblCustpaperno.Text = "";
    }
    //清空转入卡账户信息
    private void ClearIAccountInfo()
    {
        gvInAccount.DataSource = new DataTable();
        gvInAccount.DataBind();
    }

    /// <summary>
    /// 查询按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        ClearQueryInfo();
        ClearOUserInfo();
        ClearOAccountInfo();
        ClearIUserInfo();
        ClearIAccountInfo();

        //验证查询条件
        if (this.CheckQueryControl() == false)
        {
            return;
        }
        createGridViewDataSource();
        
        foreach (Control con in this.Page.Controls)
        {
            ClearLabelControl(con);
        }

    }

    private void createGridViewDataSource()
    {
        List<string> vars = new List<string>();

        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(this.txtPaperno.Text.Trim(), ref strBuilder);
        vars.Add(strBuilder.ToString());
        vars.Add(this.txtInputCardNo.Text.Trim());
        StringBuilder strBuilder1 = new StringBuilder();
        AESHelp.AESEncrypt(this.txtName.Text.Trim(), ref strBuilder1);
        vars.Add(strBuilder1.ToString());
        vars.Add(selCorp.SelectedValue.Trim());
        DataTable data = SPHelper.callQuery("SP_CA_Query", context, "QRYACCTCUSTOMERBLOCKTRANINFO", vars.ToArray());

        if (data.Rows.Count == 0)
        {
            context.AddError("A001090203:没有查询出对应信息");
            btnConfirm.Enabled = false;
            return;
        }
        gvResult.DataSource = data;
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }

    /// <summary>
    /// 对查询条件的验证
    /// </summary>
    private bool CheckQueryControl()
    {
        bool isNameEmpty = Validation.isEmpty(this.txtName);
        bool isPapernoEmpty = Validation.isEmpty(this.txtPaperno);
        bool isCardNoEmpty = Validation.isEmpty(this.txtInputCardNo);
        bool isCorpEmpty = (selCorp.SelectedValue.Trim().Length == 0);

        if (isPapernoEmpty && isNameEmpty && isCardNoEmpty && isCorpEmpty)
        {
            context.AddError("A900010B91: 查询条件不可为空");
            return false;
        }

        if (isPapernoEmpty == false && Validation.isCharNum(txtPaperno.Text.Trim()) == false)
        {
            context.AddError("A900010B92: 证件号必须是半角英文或数字", txtPaperno);
            return false;
        }

        if (isPapernoEmpty == false && Validation.strLen(txtPaperno.Text.Trim()) > 20)
        {
            context.AddError("A001001123", txtPaperno);
            return false;
        }

        return true;
    }

    // gridview换页事件
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        createGridViewDataSource();
    }

    /// <summary>
    /// 选择数据行事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gv_SelectedIndexChanged(object sender, EventArgs e)
    {
        OtxtCardno.Text = gvResult.Rows[gvResult.SelectedIndex].Cells[0].Text.Trim();
        btnDBread_Click(sender, e);
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[2].Text = DeEncrypt(e.Row.Cells[2].Text);
            e.Row.Cells[4].Text = DeEncrypt(e.Row.Cells[4].Text);
            if (!CommonHelper.HasOperPower(context))
            {
                e.Row.Cells[4].Text = CommonHelper.GetPaperNo(e.Row.Cells[4].Text);
            }
        }
    }

    protected void gv_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    //解密
    private string DeEncrypt(string value)
    {
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESDeEncrypt(value, ref strBuilder);
        return strBuilder.ToString();
    }

    /// <summary>
    /// 读转入卡按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        if (OtxtCardno.Text.Trim() != ItxtCardno.Text.Trim())
        {
            //加载卡户、用户、账户信息
            LoadDisplayInfo(true, ItxtCardno, null, IlblCusname, IlblCustphone, IlblPapertype, IlblCustpaperno, null, null
                    , null, null, null, null, IhidAccID, gvInAccount, true);
            if (!context.hasError())
            {
                this.btnTransAcc.Enabled = true;
            }
        }
        else
        {
            context.AddError("A006001313:同一张卡不能做挂失补账户操作");
        }
    }

    //清空挂失卡用户信息
    private void ClearBlockUserInfo()
    {
        OlblCusname.Text = "";
        OlblCustphone.Text = "";
        OlblPapertype.Text = "";
        OlblCustpaperno.Text = "";
    }

    //清空挂失卡账户信息
    private void ClearAccountInfo()
    {
        gvOutAccount.DataSource = new DataTable();
        gvOutAccount.DataBind();
    }

    /// <summary>
    /// 读数据库按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDBread_Click(object sender, EventArgs e)
    {
        ClearBlockUserInfo();
        ClearAccountInfo();

        //对卡号空值长度数字的判断
        UserCardHelper.validateCardNo(context, OtxtCardno, false);
        if (context.hasError())
        {
            return;
        }

        //加载用户、账户信息
        LoadDisplayInfo(false, OtxtCardno, null, OlblCusname, OlblCustphone, OlblPapertype, OlblCustpaperno, null, null
        , null, null, null, null, OhidAccID, gvOutAccount, false);
        if (!context.hasError())
        {
            this.btnTransAcc.Enabled = true;
        }
        //LoadDisplayInfo(false, OtxtCardno, OlblRelBalance, OlblCusname, OlblCustphone, OlblPapertype, OlblCustpaperno, OlblAccState, OlblCreateDate
        //, OlblTotalConsume, OlblTotalSupply, OlblUpperDay, OlblUpperOnce, OhidAccID, gvOutAccount);

    }
    //清空新卡用户信息
    private void ClearNewCardUserInfo()
    {
        IlblCusname.Text = "";
        IlblCustphone.Text = "";
        IlblPapertype.Text = "";
        IlblCustpaperno.Text = "";
    }

    //清空新卡账户信息
    private void ClearNewCardAccountInfo()
    {
        gvInAccount.DataSource = new DataTable();
        gvInAccount.DataBind();
    }

    /// <summary>
    /// 新卡读数据库按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnNDBread_Click(object sender, EventArgs e)
    {
        ClearNewCardUserInfo();
        ClearNewCardAccountInfo();

        //对卡号空值长度数字的判断
        UserCardHelper.validateCardNo(context, ItxtCardno, false);
        //UserCardHelper.validateCardNo(context, OtxtCardno, false);
        TMTableModule tmTMTableModule = new TMTableModule();

        //卡账户有效性检验
        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = ItxtCardno.Text;

        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (ok == false)
        {
            return;
        }
        if (context.hasError())
        {
            return;
        }
        if (OtxtCardno.Text.Trim() != ItxtCardno.Text.Trim())
        {
            //加载卡户、用户、账户信息
            LoadDisplayInfo(true, ItxtCardno, null, IlblCusname, IlblCustphone, IlblPapertype, IlblCustpaperno, null, null
                    , null, null, null, null, IhidAccID, gvInAccount, true);
            if (!context.hasError())
            {
                this.btnTransAcc.Enabled = true;
            }
        }
        else
        {
            context.AddError("A006001313:同一张卡不能做挂失补账户操作");
        }
    }

    /// <summary>
    /// 转账按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        //验证卡号
        UserCardHelper.validateCardNo(context, OtxtCardno, false);
        UserCardHelper.validateCardNo(context, ItxtCardno, false);

        if (OtxtCardno.Text.Trim() == ItxtCardno.Text.Trim())
        {
            context.AddError("A006001313:同一张卡不能做挂失补账户操作");
            return;
        }

        string cardNo = OtxtCardno.Text;
        if (!CAHelper.HasNoPasswordPower(context))
        {
            if (this.PassWD.Text.Trim() == "")
            {
                context.AddError("A001090202:请输入账户密码");
                return;
            }
            #region 验证密码
            if (ViewState["ACCT_ID"] != null)
            {
                ArrayList list = (ArrayList)ViewState["ACCT_ID"];
                for (int i = 0; i < list.Count; i++)
                {
                    //验证密码
                    if (!CAHelper.CheckMultipleAccPWD(context, list[i].ToString(), PassWD.Text.Trim(), false))
                    {
                        this.btnTransAcc.Enabled = false;
                        return;
                    }
                }
            }
            #endregion
        }

        if (!context.hasError())
        {
            //存储过程中自动开户 兼 转账
            context.SPOpen();
            context.AddField("P_OCARDNO").Value = OtxtCardno.Text; //挂失卡卡号
            context.AddField("P_ICARDNO").Value = ItxtCardno.Text; //转入卡卡号
            context.AddField("P_ID").Value = DealString.GetRecordID(OtxtCardno.Text.Substring(12, 4), OtxtCardno.Text);

            StringBuilder szOutput = new System.Text.StringBuilder(256);
            CAEncryption.CAEncrypt("111111", ref szOutput);
            context.AddField("P_PWD").Value = szOutput.ToString();

            bool ok = context.ExecuteSP("SP_CA_BLOCKTRANSITBALANCE");

            if (ok)
            {
                if (!context.hasError()) context.AddMessage("M001090114:挂失补账户成功");

                btnPrintPZ.Enabled = true;

                //打印凭证
                ASHelper.preparePingZheng(ptnPingZheng, this.OtxtCardno.Text, this.OlblCusname.Text, "挂失补账户",
                    "0.00", "", "", this.OlblCustpaperno.Text, "", "0.00",
                    "0.00", context.s_UserName, "", this.OlblPapertype.Text, "0.00",
                    "");

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

        if (!isInCard) //挂失卡的客户信息从账户资料表里读
        {
            //如果新客户资料表存在显示新客户资料信息
            TF_F_CUSTTDO ddoTF_F_CUSTIn = new TF_F_CUSTTDO();
            ddoTF_F_CUSTIn.ICCARD_NO = ((TextBox)cardno).Text;

            TF_F_CUSTTDO ddoTF_F_CUSTOut = (TF_F_CUSTTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTIn, typeof(TF_F_CUSTTDO), null, "TF_F_CUST_CARDNO", null);

            if (ddoTF_F_CUSTOut != null)
            {
                DeEncrypt(cusname, ddoTF_F_CUSTOut.CUST_NAME);

                //从证件类型编码表(TD_M_PAPERTYPE)中读取数据
                TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
                ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOut.PAPER_TYPE_CODE;
                TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);
                if (ddoTD_M_PAPERTYPEOut != null)
                {
                    ((Label)papertype).Text = ddoTD_M_PAPERTYPEOut.PAPERTYPENAME;
                }
                DeEncrypt(custpaperno, ddoTF_F_CUSTOut.PAPER_NO);
                DeEncrypt(custphone, ddoTF_F_CUSTOut.CUST_PHONE);
            }
            else
            {
                context.AddError("A001107113:未找到账户资料信息");
                this.btnTransAcc.Enabled = false;
                return;
            }
        }
        else //转入卡的用户信息从持卡人资料表里读
        {
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
            DeEncrypt(cusname, ddoTF_F_CUSTOMERRECOut.CUSTNAME);
            //从证件类型编码表(TD_M_PAPERTYPE)中读取数据
            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
            ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;
            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);
            if (ddoTD_M_PAPERTYPEOut != null)
            {
                ((Label)papertype).Text = ddoTD_M_PAPERTYPEOut.PAPERTYPENAME;
            }
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
                    if (!data.Rows[i]["STATE"].ToString().Equals("F"))
                    {
                        context.AddError("A006023001:客户账户不是挂失状态");
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