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
using Common;
using TM;
using TDO.PersonalTrade;
using TDO.CardManager;
using TDO.BusinessCode;
using DataExchange;
using System.Collections.Generic;

/// <summary>
/// 挂失解挂页面 
/// </summary>
public partial class ASP_PersonalBusiness_PB_ReportLoss : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            return;
        }
    }

    #region btnQuery_Click 查询按钮事件
    /// <summary>
    /// 查询按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //验证查询条件
        if (this.CheckQueryControl() == false)
        {
            return;
        }

        #region 构建查询sql
        System.Text.StringBuilder sql = new System.Text.StringBuilder();
        sql.Append("select  decode(c.cardstate, '10', '10:售出', '11', '11:换卡售出', '03', '03:书面挂失',  '04', '04:口头挂失')  as 状态,");
        sql.Append("c.cardno as 卡号,t.paperno as 证件号,t.custname as 姓名,decode(t.custsex, '0', '男', '女') as 性别, ");
        sql.Append("to_char(c.serstarttime,'yyyy-MM-dd') as 启用日期,w.cardaccmoney/100 as 卡内余额");
        sql.Append(" from  tf_f_cardrec c ,tf_f_customerrec t,tf_f_cardewalletacc w  ");
        sql.Append(" where c.cardno=t.cardno and c.cardno=w.cardno");
        sql.Append(" and  c.cardstate in ('10' , '11','03','04')");//'10:售出', '11:换卡售出', '03:书面挂失','04:口头挂失'
        //sql.Append(" and  c.custrectypecode='1' ");//限定是记名卡
		sql.Append(" and  (t.custname is not null or t.paperno is not null) ");//限定是记名卡


        if (this.txtCardNo.Text.Trim().Length > 0)
        {
            sql.Append(" and  c.cardno='" + this.txtCardNo.Text.Trim() + "'");
        }
        if (this.txtPaperno.Text.Trim().Length > 0)
        {
            sql.Append("and substr(c.cardno,1,6)!='215018'");//把市民卡全部剔除掉
            sql.Append(" and  t.paperno='" + CommonHelper.Encrypt(this.txtPaperno.Text.Trim()) + "'");
        }
        #endregion
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_B_TRADETDO tdoTF_B_TRADETDO = new TF_B_TRADETDO();
        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTF_B_TRADETDO, null, sql.ToString(), 0);

        CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "姓名", "证件号" }));

        UserCardHelper.resetData(gvResult, data);
        gvResult.SelectedIndex = -1;

        this.btnSubmit.Enabled = false;
        this.rdoCancelLoss.Checked = false;
        this.rdoRealReportLoss.Checked = false;
        this.rdoReportLoss.Checked = false;
        this.rdoCancelLoss.Enabled = false;
        this.rdoRealReportLoss.Enabled = false;
        this.rdoReportLoss.Enabled = false;


        foreach (Control con in this.Page.Controls)
        {
            ClearLabelControl(con);
        }
    }
    #endregion

    #region CheckQueryControl 对查询条件的验证
    /// <summary>
    /// 对查询条件的验证
    /// </summary>
    private bool CheckQueryControl()
    {
        bool isPapernoEmpty = Validation.isEmpty(this.txtPaperno);
        bool isCardnoEmpty = Validation.isEmpty(this.txtCardNo);

        if (isPapernoEmpty && isCardnoEmpty)
        {
            context.AddError("A900010B91: 查询条件不可为空");
            return false;
        }

        if (isPapernoEmpty == false && Validation.isCharNum(txtPaperno.Text.Trim()) == false)
        {
            context.AddError("A900010B92: 证件号必须是半角英文或数字", txtPaperno);
            return false;
        }

        if (isCardnoEmpty == false)
        {
            if (Validation.isNum(txtCardNo.Text.Trim()) == false)
            {
                context.AddError("A900010B93: 卡号必须是数字", txtCardNo);
                return false;
            }
            else if (this.txtCardNo.Text.Trim().Length != 16)
            {
                context.AddError("A900010B94: 卡号位数必须为16位", txtCardNo);
                return false;
            }
        }

        return true;
    }
    #endregion

    #region gv_SelectedIndexChanged选择按钮事件
    /// <summary>
    /// 选择按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gv_SelectedIndexChanged(object sender, EventArgs e)
    {
        // 得到选择行



        GridViewRow selectRow = gvResult.SelectedRow;

        #region 初始化几个用于页面展现的TDO对象
        string cardno = selectRow.Cells[2].Text;
        TMTableModule tmTMTableModule = new TMTableModule();

        //从IC卡资料表中读取数据




        TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
        ddoTF_F_CARDRECIn.CARDNO = cardno;
        TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

        //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据




        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
        ddoTF_F_CUSTOMERRECIn.CARDNO = cardno;
        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

        //从电子钱包账户表读取数据 
        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = cardno;
        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);

        //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据




        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPEIn.CARDTYPECODE = ddoTF_F_CARDRECOut.CARDTYPECODE;
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

        //从证件类型编码表(TD_M_PAPERTYPE)中读取数据




        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
        ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;
        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);
        #endregion

        this.lblCardno.Text = cardno;
        this.lblAsn.Text = ddoTF_F_CARDRECOut.ASN;
        this.lblCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
        this.lblCardstate.Text = GetCardstateNameByCode(ddoTF_F_CARDRECOut.CARDSTATE);

        this.lblSDate.Text = ddoTF_F_CARDRECOut.SERSTARTTIME.ToString("yyyyMMdd");
        this.lblEDate.Text = ddoTF_F_CARDRECOut.VALIDENDDATE;
        this.lblCardaccmoney.Text = ((Convert.ToDecimal(ddoTF_F_CARDEWALLETACOut.CARDACCMONEY)) / 100).ToString("0.00");

        this.lblCustName.Text = CommonHelper.DeEncrypt(ddoTF_F_CUSTOMERRECOut.CUSTNAME);
        this.lblCustBirthday.Text = ddoTF_F_CUSTOMERRECOut.CUSTBIRTH;
        this.lblPapertype.Text = ddoTD_M_PAPERTYPEOut.PAPERTYPENAME;
        this.lblCustsex.Text = ddoTF_F_CUSTOMERRECOut.CUSTSEX == "0" ? "男" : "女";
        this.lblCustphone.Text = CommonHelper.DeEncrypt(ddoTF_F_CUSTOMERRECOut.CUSTPHONE);
        this.lblPaperno.Text = CommonHelper.DeEncrypt(ddoTF_F_CUSTOMERRECOut.PAPERNO);
        this.lblCustpost.Text = ddoTF_F_CUSTOMERRECOut.CUSTPOST;
        this.lblCustaddr.Text = CommonHelper.DeEncrypt(ddoTF_F_CUSTOMERRECOut.CUSTADDR);

        this.hidCardstate.Value = ddoTF_F_CARDRECOut.CARDSTATE;

        #region 控制RadioButton的显示



        string stateCode = ddoTF_F_CARDRECOut.CARDSTATE;
        if (stateCode.Equals("10") || stateCode.Equals("11")) //  10：在售，11：换卡在售
        {
            this.rdoReportLoss.Enabled = true;
            this.rdoRealReportLoss.Enabled = true;
            this.rdoCancelLoss.Enabled = false;
        }
        else if (stateCode == "04") // 口头挂失
        {
            this.rdoReportLoss.Enabled = false;
            this.rdoRealReportLoss.Enabled = true;
            this.rdoCancelLoss.Enabled = true;
        }
        else if (stateCode == "03") // 书面挂失
        {
            this.rdoReportLoss.Enabled = false;
            this.rdoRealReportLoss.Enabled = false;
            this.rdoCancelLoss.Enabled = true;
        }
        this.btnPrintPZ.Enabled = false;
        #endregion


    }
    #endregion

    #region btnSubmit_Click 提交按钮事件
    /// <summary>
    /// 提交按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {

        #region 初始化参数值



        string strCardnewstate = "";//03挂失，10售出，11换卡售出，04 口头挂失
        string strTradetypecode = "";//08书面挂失，0E口挂，09解挂
        string strMsg = "";//页面返回的消息文本


        string cardno = this.lblCardno.Text;    //卡号

        string strTradetypeName = "";//打印凭证中的业务类型

        if (this.rdoReportLoss.Checked)//口挂
        {
            strCardnewstate = "04";
            strTradetypecode = "0E";
            strMsg = "口挂成功";
            strTradetypeName = "口头挂失";
        }
        else if (this.rdoRealReportLoss.Checked)//书挂
        {
            strCardnewstate = "03";
            strTradetypecode = "08";
            strMsg = "书挂成功";

            strTradetypeName = "书面挂失";
        }
        else if (this.rdoCancelLoss.Checked)//解挂
        {
            //取得挂失前卡资料表中的卡状态



            TMTableModule tmTMTableModule = new TMTableModule();
            TF_B_TRADETDO ddoTF_B_TRADETDOIn = new TF_B_TRADETDO();
            ddoTF_B_TRADETDOIn.CARDNO = this.lblCardno.Text;
            TF_B_TRADETDO[] ddoTF_B_TRADETDOOutArr = (TF_B_TRADETDO[])tmTMTableModule.selByPKArr(context, ddoTF_B_TRADETDOIn, typeof(TF_B_TRADETDO), null, "TF_B_TRADETDO_REPORTLOSS", null);

            if (ddoTF_B_TRADETDOOutArr.Length > 0)
            {
                strCardnewstate = ddoTF_B_TRADETDOOutArr[0].CARDSTATE;
            }
            else
            {
                strCardnewstate = "10";
            }

            strTradetypecode = "09";
            strMsg = "解挂成功";
            strTradetypeName = "解挂";
        }
        #endregion

        context.SPOpen();
        context.AddField("p_cardNo").Value = this.lblCardno.Text;
        context.AddField("p_cardnewstate").Value = strCardnewstate;
        context.AddField("p_tradetypecode").Value = strTradetypecode;
        context.AddField("p_createtime").Value = "";//后台同步时需要的参数，前台调用时传空字符
        context.AddField("p_TRADEID", "String", "output", "16");

        bool ok = context.ExecuteSP("SP_PB_ReportLoss_BAT");

        if (ok)
        {
            if (!context.hasError()) context.AddMessage(strMsg);

            btnPrintPZ.Enabled = true;

            //打印凭证
            ASHelper.preparePingZheng(ptnPingZheng, this.lblCardno.Text, this.lblCustName.Text, strTradetypeName,
                "0.00", "", "", this.lblPaperno.Text, "", "0.00",
                "0.00", context.s_UserName, "", this.lblPapertype.Text, "0.00",
                "");
            if (chkPingzheng.Checked && btnPrintPZ.Enabled)
            {
                ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "printdiv('ptnPingZheng1');", true);
            }

            btnQuery_Click(sender, e);
        }
    }

    private string GetErrorMsg()
    {
        string msg = "";
        ArrayList errorMessages = context.ErrorMessage;
        for (int index = 0; index < errorMessages.Count; index++)
        {
            if (index > 0)
                msg += "|";

            String error = errorMessages[index].ToString();
            int start = error.IndexOf(":");
            if (start > 0)
            {
                error = error.Substring(start + 1, error.Length - start - 1);
            }

            msg += error;
        }

        return msg;
    }
    #endregion

    #region rdo_CheckedChanged RadioButton选择事件
    /// <summary>
    /// RadioButton选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void rdo_CheckedChanged(object sender, EventArgs e)
    {
        RadioButton rdo = (RadioButton)sender;
        btnSubmit.Enabled = rdo.Checked;
    }
    #endregion
}
