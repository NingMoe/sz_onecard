/***************************************************************
 * PB_TransitBalance_Loss.aspx.cs
 * 系统名  : 城市一卡通系统

 * 子系统名: 个人业务 - 挂失卡转值 页面
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2010/11/18    粱锦           初次开发

 * 2010/12/02    粱锦           修改挂失卡转值 业务编码L4改为4L
 * 2011/02/12    粱锦           修改挂失卡是否已转值
 * update 2015-01-07 chenwentao
 * desc 读新卡时候验证是否是补卡售出，如果是补卡售出显示出旧卡转值信息
 ***************************************************************
 */
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
using TDO.BusinessCode;
using TDO.CardManager;
using PDO.PersonalBusiness;
using TDO.PersonalTrade;
using TDO.UserManager;
using TDO.ResourceManager;
using Master;
using System.Collections.Generic;
using DataExchange;

public partial class ASP_PersonalBusiness_PB_TransitBalance_Loss : Master.FrontMaster
{
    private static int par_LossSpan = 7;       //挂失卡转值时长限制

    private static decimal par_BaseFee = 0;   //交易手续费

    private static decimal par_OtherFee = 0;  //其他费用



    //页面Load事件
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            LabAsn.Attributes["readonly"] = "true";
            LabCardtype.Attributes["readonly"] = "true";
            sDate.Attributes["readonly"] = "true";
            //eDate.Attributes["readonly"] = "true";
            cMoney.Attributes["readonly"] = "true";

            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";


            //设置GridView gvLossOldCardInfo绑定的DataTable
            gvLossOldCardInfo.DataSource = new DataTable();
            gvLossOldCardInfo.DataBind();
            gvLossOldCardInfo.SelectedIndex = -1;
            gvLossOldCardInfo.DataKeyNames = new string[] { "LOSSDATE", "CARDACCMONEY", "CARDTYPENAME", "CUSTNAME", "PAPERNO" };


            //设置GridViewlvwTransitQuery绑定的DataTable
            lvwTransitQuery.DataSource = new DataTable();
            lvwTransitQuery.DataBind();
            lvwTransitQuery.SelectedIndex = -1;

            //指定GridView DataKeyNames
            lvwTransitQuery.DataKeyNames = new string[] { "OLDCARDNO", "CARDNO", "OPERATETIME", "CARDACCMONEY", "TFLAG", "TRADEID" };


            //初始化参数

            initPar();

            //初始化页面参数

            initLoad(sender, e);

        }
    }


    //读参数初始化页面控件值

    protected void initLoad(object sender, EventArgs e)
    {

        ProcedureFee.Text = (par_BaseFee).ToString("0.00");
        OtherFee.Text = (par_OtherFee).ToString("0.00");
        Total.Text = (par_BaseFee + par_OtherFee).ToString("0.00");

        TransitBalance.Text = "0.00";
        Transit.Enabled = false;

        ChangeRecord.Value = "0";
        HiddenLossCardMoney.Value = "0";
        HiddenTransitMoney.Value = "0";
    }



    //初始化页面参数

    private void initPar()
    {

        TMTableModule tmTMTableModule = new TMTableModule();


        //从系统参数表中读取挂失卡转值时长限制

        TD_M_TAGTDO ddoTD_M_TAGTDOIn = new TD_M_TAGTDO();
        ddoTD_M_TAGTDOIn.TAGCODE = "PB_TBLOSS_SPAN";

        TD_M_TAGTDO[] ddoTD_M_TAGTDOOutArr = (TD_M_TAGTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TAGTDOIn, "S001002125");

        if (ddoTD_M_TAGTDOOutArr[0].TAGVALUE != null)
        {
            par_LossSpan = Convert.ToInt16(ddoTD_M_TAGTDOOutArr[0].TAGVALUE);
        }




        //从前台业务交易费用表中读取数据


        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "4L";

        TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001002125", "TD_M_TRADEFEE", null);

        for (int j = 0; j < ddoTD_M_TRADEFEEOutArr.Length; j++)
        {
            if (ddoTD_M_TRADEFEEOutArr[j].FEETYPECODE == "03")
                par_BaseFee = (Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[j].BASEFEE)) / 100;
            else if (ddoTD_M_TRADEFEEOutArr[j].FEETYPECODE == "99")
                par_OtherFee = (Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[j].BASEFEE)) / 100;
        }
    }


    //lvwTransitQuery控件的 OnPageIndexChanging事件
    public void lvwTransitQuery_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwTransitQuery.PageIndex = e.NewPageIndex;
        lvwTransitQuery.DataSource = CreateChangeQueryDataSource();
        lvwTransitQuery.DataBind();
    }


    //lvwTransitQuery控件的 OnRowDataBound事件
    protected void lvwTransitQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow)
        {
            //隐藏记录流水和标志位
            e.Row.Cells[4].Visible = false;
            e.Row.Cells[5].Visible = false;
        }

    }




    //读卡
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        TransitBalance.Text = "0.00";
        Transit.Enabled = false;
        TMTableModule tmTMTableModule = new TMTableModule();

        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据


            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
            ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;

            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

            //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据

            TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
            ddoTF_F_CUSTOMERRECIn.CARDNO = txtCardno.Text;

            TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

            if (ddoTF_F_CUSTOMERRECOut == null)
            {
                context.AddError("A001107112");
                return;
            }

            //从用户卡库存表(TL_R_ICUSER)中读取数据

            TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
            ddoTL_R_ICUSERIn.CARDNO = txtCardno.Text;

            TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

            if (ddoTL_R_ICUSEROut == null)
            {
                context.AddError("A001001101");
                return;
            }


            



            //从证件类型编码表(TD_M_PAPERTYPE)中读取数据

            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
            ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);

            //给页面显示项赋值

            LabAsn.Text = hiddenAsn.Value.Substring(4, 16);
            LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
            sDate.Text = ASHelper.toDateWithHyphen(hiddensDate.Value);
            //eDate.Text = ASHelper.toDateWithHyphen(hiddeneDate.Value);
            cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / (Convert.ToDecimal(100))).ToString("0.00");
            CustName.Text = CommonHelper.DeEncrypt(ddoTF_F_CUSTOMERRECOut.CUSTNAME);


            //检验卡片是否已经启用

            if (String.Compare(hiddensDate.Value, DateTime.Today.ToString("yyyyMMdd")) > 0)
            {
                context.AddError("卡片尚未启用");
                return;
            }

            //性别显示
            if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "0")
                Custsex.Text = "男";
            else if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "1")
                Custsex.Text = "女";
            else Custsex.Text = "";

            //出生日期显示
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

            //证件类型显示
            if (ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE != "")
            {
                Papertype.Text = ddoTD_M_PAPERTYPEOut.PAPERTYPENAME;
            }
            else Papertype.Text = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

            Paperno.Text = CommonHelper.DeEncrypt(ddoTF_F_CUSTOMERRECOut.PAPERNO);
            Custaddr.Text = CommonHelper.DeEncrypt(ddoTF_F_CUSTOMERRECOut.CUSTADDR);
            Custpost.Text = ddoTF_F_CUSTOMERRECOut.CUSTPOST;
            Custphone.Text = CommonHelper.DeEncrypt(ddoTF_F_CUSTOMERRECOut.CUSTPHONE);
            txtEmail.Text = ddoTF_F_CUSTOMERRECOut.CUSTEMAIL;
            Remark.Text = ddoTF_F_CUSTOMERRECOut.REMARK;

        }
        //DataTable dt = SPHelper.callPBQuery(context, "HasTransitBalance", txtCardno.Text.Trim());
        //if (dt != null && dt.Rows.Count > 0)
        //{
        //    if (dt.Rows[0][0].ToString()=="03")
        //    {
        //        txtCondition.Text = dt.Rows[0][1].ToString();
        //        btnQuery_Click( sender,  e);
        //    }
        //}
        string OldcardNo = string.Empty;
        if (ISSupplSale(ref OldcardNo))
        {
            if (!string.IsNullOrEmpty(OldcardNo))
            {
                selQueryType.SelectedValue = "01";
                txtCondition.Text = OldcardNo;
                btnQuery_Click(sender, e);
            }
        }
    }



    // 查询挂失卡信息

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        TransitBalance.Text = "0.00";
        Transit.Enabled = false;
        // 输入项判断处理（证件号码、旧卡号码）
        // ASHelper.changeCardQueryValidate(context, txtId, txtOldCardNo, txtName);
        // if (context.hasError()) return;

        //判断是否要先转账户
        //if (selQueryType.SelectedValue == "01")
        //{
        //    PBHelper.hasAccountByCardNo(context, txtCondition.Text.Trim());            
        //}
        //else {
        //    PBHelper.hasAccountByPaperNo(context, txtCondition.Text.Trim());    
        //}
        //if (context.hasError()) return;

        // 从IC卡资料表中查询

        DataTable lossdata = SPHelper.callPBQuery(context, "QueryLossCard", selQueryType.SelectedValue, txtCondition.Text.Trim());

        CommonHelper.AESDeEncrypt(lossdata, new List<string>(new string[] { "custname", "paperno", "custphone" }));

        if (lossdata == null || lossdata.Rows.Count == 0)
        {
            UserCardHelper.resetData(gvLossOldCardInfo, null);
            AddMessage("N005030001: 查询结果为空");

            //清空转值列表

            UserCardHelper.resetData(lvwTransitQuery, null);

            HiddenLossCardMoney.Value = "0";
            Transit.Enabled = false;
        }
        else
        {
            UserCardHelper.resetData(gvLossOldCardInfo, lossdata);

            gvLossOldCardInfo.SelectedIndex = 0;
            gvLossOldCardInfo_SelectedIndexChanged(sender, e);



        }

        calTransitMoney();
    }

    //protected void gvLossOldCardInfo_RowDataBound(object sender, GridViewRowEventArgs e)
    //{
    //    if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow)
    //    {
    //        //隐藏记录流水和标志位
    //        //e.Row.Cells[4].Visible = false;
    //        //e.Row.Cells[5].Visible = false;
    //    }

    //}

    // 挂失卡信息查询结果 行选择事件
    public void gvLossOldCardInfo_SelectedIndexChanged(object sender, EventArgs e)
    {
        HiddenLossCardMoney.Value = "0";//当前挂失卡金额

        HiddenTransitMoney.Value = "0";//之前的所有换卡金额



        // 得到选择行

        GridViewRow selectRow = gvLossOldCardInfo.SelectedRow;

        // 根据选择行卡号读取用户信息

        newCardNo.Value = selectRow.Cells[1].Text;

        //挂失时间未超过7天

        if (Convert.ToDateTime(selectRow.Cells[2].Text).AddDays(par_LossSpan) >= DateTime.Now)
        {
            context.AddError("挂失时间不足");
            HiddenLossCardMoney.Value = "0";
            Transit.Enabled = false;
            return;
        }



        //从卡资料表(TF_F_CARDREC)中读取数据

        TMTableModule tmTMTableModule = new TMTableModule();

        TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
        ddoTF_F_CARDRECIn.CARDNO = newCardNo.Value;

        TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);
        if (ddoTF_F_CARDRECOut == null)
        {
            context.AddError("A001008103");
            Transit.Enabled = false;
            return;
        }
        else if (ddoTF_F_CARDRECOut.RSRV2 != null&&ddoTF_F_CARDRECOut.RSRV2!="")
        {
            context.AddError("卡号【" + newCardNo.Value + "】已办理过补卡业务，请重新选择一张卡");
            Transit.Enabled = false;
            return;
        }
        HiddenLossCardMoney.Value = selectRow.Cells[3].Text;

        //查询转值信息


        DataTable data = CreateChangeQueryDataSource();

        //hidEndDate.Value = selectRow.Cells[1].Text;
        //hidUsabelTimes.Value = selectRow.Cells[3].Text;

        //btnSubmit.Enabled = !context.hasError() && hidReadCardOK.Value == "ok";

        

        if (data == null || data.Rows.Count == 0)
        {
            UserCardHelper.resetData(lvwTransitQuery, null);
            //AddMessage("N005030001: 查询结果为空");
        }
        else
        {
            UserCardHelper.resetData(lvwTransitQuery, data);
        }

        calTransitMoney();
        if (context.hasError())
        {
            Transit.Enabled = false;
        }
        else
        {
            if (txtCardno.Text != "") Transit.Enabled = true;
        }
    }


    //计算转值金额

    private void calTransitMoney()
    {
        decimal LossMoney;
        decimal TransitMoney;
        try
        {
            LossMoney = decimal.Parse(HiddenLossCardMoney.Value);
        }
        catch (Exception e)
        {
            LossMoney = 0;
        }
        try
        {
            TransitMoney = decimal.Parse(HiddenTransitMoney.Value);
        }
        catch (Exception e)
        {
            TransitMoney = 0;
        }
        decimal m_money = LossMoney + TransitMoney;
        TransitBalance.Text = m_money.ToString("0.00");
    }
    //查询当前挂失卡的转值记录 返回结果
    public DataTable CreateChangeQueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_B_TRADETDO ddoTF_B_TRADEIn = new TF_B_TRADETDO();
        //如果挂失的这张卡已做过转值，则不记台帐

        string strTransit1 = "SELECT CARDNO FROM TF_B_TRADE WHERE OLDCARDNO = '" + newCardNo.Value + "' AND TRADETYPECODE IN ('4L','04') AND CANCELTAG = '0'";
        DataTable dataTransit1 = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strTransit1, 0);
        if (dataTransit1.Rows.Count != 0)
        {
            ChangeRecord.Value = "1";//1代表不记业务台帐
        }
        else
        {
            ChangeRecord.Value = "0";//记业务台帐

        }
        //DataView dataView = null;
        //查询当前挂失卡换卡记录

        string strChange = "SELECT a.TRADEID, a.CARDNO,a.OLDCARDNO,a.OPERATETIME,b.CARDACCMONEY/100.0 CARDACCMONEY,'0' TFLAG ";
        strChange += " FROM TF_B_TRADE a,TF_F_CARDEWALLETACC b WHERE a.CARDNO = '" + newCardNo.Value + "' AND a.TRADETYPECODE " +
                    " IN ('03','73','74','75') AND b.CARDNO = a.OLDCARDNO AND a.CANCELTAG = '0'";
        DataTable dataChange = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strChange, 0);
        //换卡记录不存在

        if (dataChange.Rows.Count == 0)
        {
            //context.AddError("A001006120");
        }
        //换卡记录存在
        else if (dataChange.Rows.Count != 0)
        {
            //查询旧卡是否已做过转值

            string strTransit = "SELECT CARDNO FROM TF_B_TRADE WHERE OLDCARDNO = '" + dataChange.Rows[0][2].ToString() + "' AND TRADETYPECODE  IN ('04','4L') AND CANCELTAG = '0'";
            DataTable dataTransit = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strTransit, 0);

            //旧卡没有做过转值

            if (dataTransit.Rows.Count == 0)
            {

                context.AddMessage("发现未转值记录");

                //挂失时间和当前时间差小于7天

                if (Convert.ToDateTime(dataChange.Rows[0][3].ToString()).AddDays(par_LossSpan) >= DateTime.Now)
                {
                    context.AddError("A001006122");

                    return dataChange;
                }
                //换卡时间和当前时间差大于7天


                else
                {
                    HiddenTransitMoney.Value = (string)(dataChange.Rows[0][4].ToString());
                    //更新卡号
                    newCardNo.Value = dataChange.Rows[0][2].ToString();
                    //查询以往换卡转值

                    Transithistory(dataChange);
                }
            }
            //转值记录存在

            else if (dataTransit.Rows.Count != 0)
            {
                //更新卡号
                newCardNo.Value = dataChange.Rows[0][2].ToString();
                //
                dataChange.Rows.Clear();
                //查询以往换卡转值

                Transithistory(dataChange);
            }
        }

        return dataChange;
    }



    //查询历史转值记录 并返回结果

    public DataTable Transithistory(DataTable dataChange)
    {
        
        Decimal tmpTransitMoney = 0;

        try
        {
            tmpTransitMoney = decimal.Parse(HiddenTransitMoney.Value);
        }
        catch (Exception e)
        {
            tmpTransitMoney = 0;
        }


        TMTableModule tmTMTableModule = new TMTableModule();
        TF_B_TRADETDO ddoTF_B_TRADEIn = new TF_B_TRADETDO();
        DataRow relation;
        int i = 1;

        while (i != 0)
        {
            //查询以往换卡记录
            string strChangeOld = "SELECT a.TRADEID, a.CARDNO,a.OLDCARDNO,a.OPERATETIME,b.CARDACCMONEY/100.0 CARDACCMONEY, '1' TFLAG ";
            strChangeOld += " FROM TF_B_TRADE a,TF_F_CARDEWALLETACC b WHERE a.CARDNO = '" + newCardNo.Value + "' AND " +
                            " a.TRADETYPECODE IN ('03','73','74','75') AND b.CARDNO = a.OLDCARDNO AND a.CANCELTAG = '0' ";
            DataTable dataChangeOld = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strChangeOld, 0);

            if (dataChangeOld.Rows.Count == 0)
                break;

            //查询转值记录

            string strTransitOld = "SELECT CARDNO FROM TF_B_TRADE WHERE OLDCARDNO = '" + dataChangeOld.Rows[0][2].ToString() + "' AND TRADETYPECODE  IN ('04','4L') AND CANCELTAG = '0'";
            DataTable dataTransitOld = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strTransitOld, 0);

            //没有转值记录


            if (dataTransitOld.Rows.Count == 0)
            {
                //换卡时间超过7天


                if (Convert.ToDateTime(dataChangeOld.Rows[0][3].ToString()).AddDays(par_LossSpan) <= DateTime.Now)
                {
                    //更新卡号
                    newCardNo.Value = dataChangeOld.Rows[0][2].ToString();
                    //累加金额
                    tmpTransitMoney = tmpTransitMoney + Convert.ToDecimal(dataChangeOld.Rows[0][4].ToString());
                    relation = dataChange.NewRow();
                    relation = dataChangeOld.Rows[0];
                    dataChange.ImportRow(relation);

                }
                //换卡时间不足7天

                else if (Convert.ToDateTime(dataChangeOld.Rows[0][3].ToString()).AddDays(par_LossSpan) > DateTime.Now)
                {
                    context.AddError("A001005122");
                    tmpTransitMoney = 0;
                    dataChange.Rows.Clear();
                    break;
                }
            }
            else if (dataTransitOld.Rows.Count != 0)
            {
                //更新卡号
                newCardNo.Value = dataChangeOld.Rows[0][2].ToString();
            }
        }

        HiddenTransitMoney.Value = (string)(tmpTransitMoney.ToString());
        return dataChange;
    }





    //前台写卡结果弹出对话框

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")
        {
            Transit.Enabled = false;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            SP_PB_updateCardTradePDO pdo = new SP_PB_updateCardTradePDO();
            pdo.CARDTRADENO = hiddentradeno.Value;
            pdo.TRADEID = hidoutTradeid.Value;

            bool ok = TMStorePModule.Excute(context, pdo);

            if (ok)
            {
                AddMessage("前台写卡成功");
                clearCustInfo(txtCardno);


                string p_BatchId = pdo.TRADEID;

            }
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



    //将需要转值的卡号记入临时表

    private void RecordIntoTmp()
    {

        context.DBOpen("Insert");
        int seq = 0;

        //挂失卡余额

        if (gvLossOldCardInfo.Rows.Count > 1)
        {

            //GridViewRow a = gvLossOldCardInfo.SelectedRow;

            //context.ExecuteNonQuery("insert into TMP_PB_TransitBalance values('" +
            //            Session.SessionID + "'," + (seq++) + ",'" + a.Cells[1].Text + "')");
        }
        //换卡未转值信息记录入临时表

        foreach (GridViewRow gvr in lvwTransitQuery.Rows)
        {
            //if (gvr.Cells[4].Text == "1")
            //{
            context.ExecuteNonQuery("insert into TMP_PB_TransitBalance values('" +
                Session.SessionID + "'," + (seq++) + ",'" + gvr.Cells[5].Text + "')");
            //}
        }
        context.DBCommit();

    }


    //清空转值临时表
    private void clearTempTable()
    {
        //清空临时表


        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_PB_TransitBalance where SESSIONID='" + Session.SessionID + "'");
        context.DBCommit();
    }



    //转值按钮

    protected void Transit_Click(object sender, EventArgs e)
    {
        //库内余额为负时,不能进行转值

        if (Convert.ToDecimal(TransitBalance.Text) < 0)
        {
            context.AddError("A001006123");
            return;
        }



        //清空临时表数据

        clearTempTable();

        //向临时表中插入数据

        RecordIntoTmp();


        //执行存储过程
        string retval = exeSP();
        if (retval == "ok")
        {
            initLoad(sender, e);
        }


    }


    private string exeSP()
    {
        //从IC卡电子钱包账户表中读取数据

        TMTableModule tmTMTableModule = new TMTableModule();
        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = gvLossOldCardInfo.SelectedRow.Cells[1].Text;
        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null, "TF_F_CARDEWALLETACC", null);


        //转值金额应该大于等于挂失卡金额
        if (Convert.ToInt32(Convert.ToDecimal(TransitBalance.Text) * 100) < ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY)
        {
            context.AddError("转值金额应该大于等于挂失卡金额");
            return "error";
        }
        //存储过程赋值


        SP_PB_TransitBalance_LossPDO pdo = new SP_PB_TransitBalance_LossPDO();
        pdo.SESSIONID = Session.SessionID;
        pdo.NEWCARDNO = txtCardno.Text;
        pdo.LOSSCARDNO = gvLossOldCardInfo.SelectedRow.Cells[1].Text;
        pdo.TRADETYPECODE = "4L";
        pdo.NEWCARDACCMONEY = Convert.ToInt32(Convert.ToDecimal(cMoney.Text) * 100);
        pdo.CURRENTMONEY = Convert.ToInt32(Convert.ToDecimal(TransitBalance.Text) * 100);
        pdo.OLDCARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;//挂失的旧卡的卡库内余额

        pdo.PREMONEY = Convert.ToInt32(hiddencMoney.Value);
        pdo.ASN = LabAsn.Text;
        pdo.CARDTRADENO = hiddentradeno.Value;
        pdo.CARDTYPECODE = hiddenLabCardtype.Value;
        pdo.CHANGERECORD = ChangeRecord.Value;
        pdo.TERMNO = "112233445566";
        pdo.OPERCARDNO = context.s_CardID;

        //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据

        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
        ddoTF_F_CUSTOMERRECIn.CARDNO = gvLossOldCardInfo.SelectedRow.Cells[1].Text;

        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

        if (ddoTF_F_CUSTOMERRECOut == null)
        {
            context.AddError("A001107112");
            return "error";
        }
        hidCustname.Value = ddoTF_F_CUSTOMERRECOut.CUSTNAME;
        hidPaperno.Value = ddoTF_F_CUSTOMERRECOut.PAPERNO;

        //从证件类型编码表(TD_M_PAPERTYPE)中读取数据

        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
        ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);

        //证件类型赋值

        if (ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE != "")
        {
            hidPapertype.Value = ddoTD_M_PAPERTYPEOut.PAPERTYPENAME;
        }
        else hidPapertype.Value = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;


        hidSupplyMoney.Value = "" + pdo.CURRENTMONEY;
        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (ok)
        {
            hidoutTradeid.Value = "" + ((SP_PB_TransitBalance_LossPDO)pdoOut).TRADEID;
            AddMessage("M001006001");
            //写卡
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                "chargeCard();", true);
            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, hidCustname.Value, "挂失卡转值", "0.00"
                , "", "", hidPaperno.Value, (Convert.ToDecimal(pdo.CURRENTMONEY + pdo.PREMONEY) / (Convert.ToDecimal(100))).ToString("0.00"),
                "", (Convert.ToDecimal(pdo.CURRENTMONEY) / (Convert.ToDecimal(100))).ToString("0.00"), context.s_UserName, context.s_DepartName,
                hidPapertype.Value, OtherFee.Text, "0.00");

            ChangeRecord.Value = "0";
            //重新初始化


            return "ok";
        }
        return "";
    }

    /// <summary>
    /// 验证是否是补卡售出
    /// </summary>
    /// <returns></returns>
    private bool ISSupplSale(ref string oldcardno)
    {
        string strSql = string.Format("select tr.cardno,tb.oldcardno from tf_f_cardrec tr,tf_b_trade tb"
                                      + " where tr.selltime=tb.operatetime and tr.cardno='{0}'"
                                      + " and tb.tradetypecode='4A'"
                                      + " and tb.canceltag='0'"
                                      + " order by tb.operatetime desc", txtCardno.Text.Trim());
        context.DBOpen("Select");
        DataTable dt = context.ExecuteReader(strSql);
        context.DBCommit();
        if (null == dt || dt.Rows.Count == 0)
            return false;
        oldcardno = dt.Rows[0]["oldcardno"].ToString();
        string strSql1 = string.Format("select t.rsrv1 from tf_f_cardrec t where t.cardno='{0}'", dt.Rows[0]["oldcardno"].ToString());
        context.DBOpen("Select");
        DataTable dt1 = context.ExecuteReader(strSql1);
        context.DBCommit();
        if (null == dt1 || dt1.Rows.Count == 0)
            oldcardno = "";
        if (string.IsNullOrEmpty(dt1.Rows[0]["rsrv1"].ToString()))
            oldcardno = "";
        else if (txtCardno.Text.Trim() != dt1.Rows[0]["rsrv1"].ToString())
            oldcardno = "";
        return true;
    }
}
