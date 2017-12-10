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
using PDO.PersonalBusiness;
using TDO.CardManager;
using TDO.PersonalTrade;
using TDO.BalanceChannel;
using TDO.UserManager;
using PDO.SpecialDeal;
using Common;
using TDO.ResourceManager;
using Master;

public partial class ASP_SpecialDeal_SD_SpeAdjustAcc : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //卡内余额,调账总额不可更改
            txtCurrMoney.Attributes.Add("readonly", "true");
            txtAdjustMoney.Attributes.Add("readonly", "true");

            //显示调账明细信息列表
            showAdjustAcc();

            //初始化打印凭证不可用
            btnPrintPZ.Enabled = false;

            //初始化调帐按钮不可用
            btnAdjustAcc.Enabled = false;

            //测试模式下卡号可输入
            if (!context.s_Debugging) txtCardno.Attributes["readonly"] = "true";
        }

    }

    private void showAdjustAcc()
    {
        //显示调账明细信息列表
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }


    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //卡账户有效性检验


        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //卡有效时
            //若调账卡曾换卡，获取旧卡卡号
            string cardNO = "";
            ArrayList list = new ArrayList();
            cardNO = txtCardno.Text;
            list.Add(cardNO);
            while (true)
            {
                TF_B_TRADETDO tdoTF_B_TRADEIn = new TF_B_TRADETDO();
                tdoTF_B_TRADEIn.CARDNO = cardNO;
                TF_B_TRADETDO tdoTF_B_TRADEOut = (TF_B_TRADETDO)tmTMTableModule.selByPK(context, tdoTF_B_TRADEIn, typeof(TF_B_TRADETDO), null, "TF_B_TRADE_QUERYOLDCARDNOBYCARDNO", null);

                if (tdoTF_B_TRADEOut != null && tdoTF_B_TRADEOut.OLDCARDNO != null)
                {
                    // 不可读换卡调账要七天后,把不能调账的旧卡过滤掉
                    //if ((tdoTF_B_TRADEOut.REASONCODE=="14"||tdoTF_B_TRADEOut.REASONCODE=="15")&& tdoTF_B_TRADEOut.OPERATETIME.AddDays(7) >= DateTime.Now)
                    //{
                    //    context.AddMessage("卡号：" + tdoTF_B_TRADEOut.OLDCARDNO + "换卡后7天才能调账！");
                    //    cardNO = tdoTF_B_TRADEOut.OLDCARDNO;
                    //    continue;
                    //}
                    cardNO = tdoTF_B_TRADEOut.OLDCARDNO;
                    list.Add(cardNO);
                }
                else
                {
                    break;
                }
            }

            //读取特殊调帐可充值账户表(TF_SPEADJUSTOFFERACC)中卡的调账信息
            int totalAdjustMoney = 0;
            for (int i = 0; i < list.Count; i++)
            {
                TF_SPEADJUSTOFFERACCTDO tdoAdjAccIn = new TF_SPEADJUSTOFFERACCTDO();
                tdoAdjAccIn.CARDNO = list[i].ToString();

                TF_SPEADJUSTOFFERACCTDO tdoAdjAccOut = (TF_SPEADJUSTOFFERACCTDO)tmTMTableModule.selByPK(context, tdoAdjAccIn, typeof(TF_SPEADJUSTOFFERACCTDO), null, "TF_SPEADJUSTOFFERACC_BYCARDNO", null);

                //没有调帐信息时

                if (tdoAdjAccOut == null || tdoAdjAccOut.OFFERMONEY <= 0)
                {
                    continue;
                }
                totalAdjustMoney += tdoAdjAccOut.OFFERMONEY;
            }

            if (totalAdjustMoney <= 0)
            {
                ClearAdjustInfo();
                context.AddError("A009113102");
                return;
            }
            //显示卡内余额
            txtCurrMoney.Text = (Convert.ToDecimal(hiddencMoney.Value) / 100).ToString("0.00");

            //显示调账总额
            hidAdjustMoney.Value = totalAdjustMoney.ToString();

            txtAdjustMoney.Text = (Convert.ToDecimal(totalAdjustMoney) / 100).ToString("0.00");

            //查询调账明细并显示信息

            //gvResult.DataSource = QueryResultColl();
            gvResult.DataSource = QueryResultColl(list);
            gvResult.DataBind();

            //卡片资料类型判断
            TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
            ddoTF_F_CUSTOMERRECIn.CARDNO = txtCardno.Text;
            DDOBase ddoBase = (DDOBase)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);
            ddoBase = CommonHelper.AESDeEncrypt(ddoBase);
            TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)ddoBase;
            if (!string.IsNullOrEmpty(ddoTF_F_CUSTOMERRECOut.CUSTNAME) && !string.IsNullOrEmpty(ddoTF_F_CUSTOMERRECOut.PAPERNO))
            {
                hidIsJiMing.Value = "1";                
            }
            else
            {
                string cardNo = txtCardno.Text;
                string sql = string.Format("select count(*) from tf_f_cust_acct A where A.state!='X' and A.ICCARD_NO='{0}'", cardNo);
                TMTableModule tmTMTableModule1 = new TMTableModule();
                DataTable dt = tmTMTableModule1.selByPKDataTable(context, sql, 0);
                Object obj = dt.Rows[0].ItemArray[0];
                if (Convert.ToInt32(obj) > 0) //开通专有账户功能的，且专有账户功能有效的
                {
                    hidIsJiMing.Value = "1";
                }
                else
                {
                    hidIsJiMing.Value = "0";
                }
            }
            //启用调帐处理按钮
            btnAdjustAcc.Enabled = true;
            btnAdjustSale.Enabled = false;
        }

        else
        {
            //清空界面信息
            ClearAdjustInfo();
        }

    }


    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        //分页处理 
        gvResult.PageIndex = e.NewPageIndex;

        btnReadCard_Click(sender, e);

    }



    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
    }


    //public ICollection QueryResultColl()
    //{
    //    //从特殊调帐台帐表(TF_B_SPEADJUSTACC)中读取数据

    //    DataTable data = SPHelper.callSDQuery(context, "SpeAdjustAcc", txtCardno.Text);
    //    return new DataView(data);
    //}

    public ICollection QueryResultColl(ArrayList list)
    {
        //从特殊调帐台帐表(TF_B_SPEADJUSTACC)中读取数据

        TMTableModule tmTMTableModule = new TMTableModule();
        TF_B_SPEADJUSTACCTDO tdoTF_B_SPEADJUSTACCIn = new TF_B_SPEADJUSTACCTDO();
        string strSql = "select " +
                         " tf.CARDNO 卡号,tf.CALLINGNO || ':' || tno.CALLING 行业,tf.CORPNO || ':' || tp.CORP 单位,tf.DEPARTNO || ':' || tt.DEPART 部门," +
                         " tf.TRADEDATE 交易日期, tf.TRADEMONEY/100.0 交易￥,tf.REFUNDMENT/100.0 调账￥,tf.CHECKSTAFFNO || ':' || ti.STAFFNAME 审核人," +
                         " tf.CHECKTIME 审核时间," +
                         " (case when (tf.REASONCODE = '1') then '隔日退货' " +
                         " when (tf.REASONCODE = '2') then '交易成功,签购单未打印'" +
                         " when (tf.REASONCODE = '3') then '交易不成功,扣款'" +
                         " when (tf.REASONCODE = '4') then '多刷金额'" +
                         " when (tf.REASONCODE = '5') then '其他' end) 调账原因" +
                         " FROM  TF_B_SPEADJUSTACC tf, TD_M_CALLINGNO tno, TD_M_CORP tp,TD_M_DEPART tt, TD_M_INSIDESTAFF ti";
        ArrayList wherelist = new ArrayList();
        wherelist.Add("tf.TRADETYPECODE = '97'");
        wherelist.Add("tf.STATECODE = '1'");
        wherelist.Add("tf.CALLINGNO = tno.CALLINGNO(+)");
        wherelist.Add("tf.CORPNO = tp.CORPNO(+)");
        wherelist.Add("tf.DEPARTNO = tt.DEPARTNO(+)");
        wherelist.Add("tf.CHECKSTAFFNO = ti.STAFFNO(+)");
        string whereCardNo = "tf.CARDNO IN (";
        for (int i = 0; i < list.Count; i++)
        {
            whereCardNo += "'" + list[i].ToString() + "',";
        }
        whereCardNo = whereCardNo.TrimEnd(',');
        whereCardNo += ")";
        wherelist.Add(whereCardNo);
        strSql += DealString.ListToWhereStr(wherelist);

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTF_B_SPEADJUSTACCIn, null, strSql, 0);

        return new DataView(data);
    }

    private bool AdjustAccValidation()
    {
        //对卡号非空的校验
        txtCardno.Text = txtCardno.Text.Trim();
        if (txtCardno.Text == "")
            context.AddError("A009113001", txtCardno);

        //对调帐总额非空的校验

        else if (txtAdjustMoney.Text.Trim() == "")
            context.AddError("A009113002", txtAdjustMoney);

        //检测卡内余额加调账总额是否超过上限
        else if (Convert.ToChar(hidIsJiMing.Value) == '0' && Convert.ToDecimal(txtCurrMoney.Text)+ Convert.ToDecimal(txtAdjustMoney.Text) > 1000)
            context.AddError("卡内余额加上调账总额不能超过1千元,调账失败。");
        else if (Convert.ToChar(hidIsJiMing.Value) == '1' && Convert.ToDecimal(txtCurrMoney.Text) + Convert.ToDecimal(txtAdjustMoney.Text) > 5000)
            context.AddError("卡内余额加上调账总额不能超过5千元,调账失败。");

        return context.hasError();

    }

    private bool RecordIntoTmp(ArrayList list)
    {
        //回收记录入临时表
        context.DBOpen("Insert");

        int count = 0;
        int tradeid = 100001;
        int iRefundMoney = 0;
        for (int i = 0; i < list.Count; i++)
        {
            ++count;
            context.ExecuteNonQuery("insert into TMP_ADJUSTACC_IMP values('" + tradeid.ToString() + "','" + list[i].ToString() + "'," + iRefundMoney + ",'" + Session.SessionID + "')");
            tradeid++;
        }

        context.DBCommit();

        // 没有插入任何卡号记录则返回错误

        if (count <= 0)
        {
            context.AddError("A009113104:没有卡号记录");
            return false;
        }

        return true;
    }

    private void clearTempTable()//清空临时表
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_ADJUSTACC_IMP where SESSIONID='"
            + Session.SessionID + "'");
        context.ExecuteNonQuery("delete from TMP_ADJUSTACC_IMP where SESSIONID='"
                    + Session.SessionID + "'");
        context.DBCommit();
    }

    protected void btnAdjustAcc_Click(object sender, EventArgs e)
    {
        //调用调账的判断处理

        if (AdjustAccValidation()) return;

        TMTableModule tmTMTableModule = new TMTableModule();

        //检验读卡到调账期间有无变更操作
        string cardNO = "";
        ArrayList list = new ArrayList();
        cardNO = txtCardno.Text;
        while (true)
        {
            list.Add(cardNO);
            TF_B_TRADETDO tdoTF_B_TRADEIn = new TF_B_TRADETDO();
            tdoTF_B_TRADEIn.CARDNO = cardNO;
            TF_B_TRADETDO tdoTF_B_TRADEOut = (TF_B_TRADETDO)tmTMTableModule.selByPK(context, tdoTF_B_TRADEIn, typeof(TF_B_TRADETDO), null, "TF_B_TRADE_QUERYOLDCARDNOBYCARDNO", null);
            if (tdoTF_B_TRADEOut != null && tdoTF_B_TRADEOut.OLDCARDNO != null)
            {
                cardNO = tdoTF_B_TRADEOut.OLDCARDNO;
            }
            else
            {
                break;
            }
        }

        //读取特殊调帐可充值账户表(TF_SPEADJUSTOFFERACC)中卡的调账信息
        int totalAdjustMoney = 0;
        for (int i = 0; i < list.Count; i++)
        {
            TF_SPEADJUSTOFFERACCTDO tdoAdjAccIn = new TF_SPEADJUSTOFFERACCTDO();
            tdoAdjAccIn.CARDNO = list[i].ToString();

            TF_SPEADJUSTOFFERACCTDO tdoAdjAccOut = (TF_SPEADJUSTOFFERACCTDO)tmTMTableModule.selByPK(context, tdoAdjAccIn, typeof(TF_SPEADJUSTOFFERACCTDO), null, "TF_SPEADJUSTOFFERACC_BYCARDNO", null);

            //没有调帐信息时

            if (tdoAdjAccOut == null || tdoAdjAccOut.OFFERMONEY <= 0)
            {
                continue;
            }
            totalAdjustMoney += tdoAdjAccOut.OFFERMONEY;
        }

        if (totalAdjustMoney <= 0 || totalAdjustMoney != Convert.ToInt32(hidAdjustMoney.Value))
        {
            ClearAdjustInfo();
            context.AddError("A009113103:调账总额发生变更");
            return;
        }

        //清空临时表
        clearTempTable();

        //卡号入临时表
        if (!RecordIntoTmp(list)) return;

        //从IC卡电子钱包账户表中读取数据

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text;
        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null, "TF_F_CARDEWALLETACC", null);

        //调用调账的判断处理

        SP_SD_SpeAdjustAccPDO pdo = new SP_SD_SpeAdjustAccPDO();

        //生成记录流水号

        pdo.ID = hiddentradeno.Value + DateTime.Now.ToString("MMddhhmmss") + hiddenAsn.Value.Substring(12, 4);
        pdo.CARDNO = txtCardno.Text;
        pdo.CARDTRADENO = hiddentradeno.Value;

        pdo.CARDMONEY = Convert.ToInt32(hiddencMoney.Value);

        pdo.CARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;

        pdo.ASN = hiddenAsn.Value.Substring(4, 16);
        pdo.CARDTYPECODE = hiddenLabCardtype.Value;
        pdo.TRADETYPECODE = "98";    //特殊调帐充值

        pdo.TERMNO = "112233445566"; //终端号固定为112233445566

        pdo.ADJUSTMONEY = Convert.ToInt32(hidAdjustMoney.Value); //调帐总额

        string strAdjustMoney = (Convert.ToDecimal(pdo.ADJUSTMONEY) / 100).ToString("0.00");

        pdo.OPERCARDNO = context.s_CardID; //操作员卡号
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            hidSupplyMoney.Value = "" + pdo.ADJUSTMONEY;

            string strIcBalance = (Convert.ToDecimal(pdo.CARDMONEY + pdo.ADJUSTMONEY) / 100).ToString("0.00");

            hidCardnoForCheck.Value = txtCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致

            //充值写卡片信息
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                 "writeCardScript", "chargeCard();", true);

            btnPrintPZ.Enabled = true;

            //获取IC用户的姓名, 证件类型, 证件号码
            GetCustInfo();

            ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, hidCustName.Value, "充值", strAdjustMoney
                , "", "", hidPaperNo.Value, strIcBalance, "",
                strAdjustMoney, context.s_UserID, context.s_DepartName, hidPaperType.Value, "0.00", "");

            //打印按钮启用
            //btnPrintPZ.Enabled = true;

            //调帐按钮不可用
            btnAdjustAcc.Enabled = false;
        }

        //清空信息
        //ClearAdjustInfo();
    }

    private void ClearAdjustInfo()
    {
        txtCardno.Text = "";
        //卡内余额
        txtCurrMoney.Text = "";

        //清空调帐总额
        txtAdjustMoney.Text = "";

        //显示调账明细信息列表
        showAdjustAcc();
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")
        {
            btnAdjustAcc.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            AddMessage("M009113201");
        }
        else if (hidWarning.Value == "writeFail")
        {
            context.AddError("A009113202");
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

    private void GetCustInfo()
    {
        //取得IC卡用户的姓名,证件类型,证件号码
        TF_F_CUSTOMERRECTDO ddoIn = new TF_F_CUSTOMERRECTDO();
        ddoIn.CARDNO = txtCardno.Text;
        TMTableModule tmTMTableModule = new TMTableModule();

        //TF_F_CUSTOMERRECTDO ddoOut = (TF_F_CUSTOMERRECTDO)tmTMTableModule.selByPK(context, ddoIn,
        //    typeof(TF_F_CUSTOMERRECTDO), null, "TF_F_CUSTOMERREC_QUERY_BYCARDNO", null);

        //add by jiangbb 解密
        DDOBase ddoBase = (DDOBase)tmTMTableModule.selByPK(context, ddoIn, typeof(TF_F_CUSTOMERRECTDO), null, "TF_F_CUSTOMERREC_QUERY_BYCARDNO", null);
        ddoBase = CommonHelper.AESDeEncrypt(ddoBase);
        TF_F_CUSTOMERRECTDO ddoOut = (TF_F_CUSTOMERRECTDO)ddoBase;
        hidPaperNo.Value = ddoOut.PAPERNO;
        hidCustName.Value = ddoOut.CUSTNAME;

        //查询证件类型代码对应的证件类型名称

        string paperTypeSql = "select PAPERTYPENAME from TD_M_PAPERTYPE where PAPERTYPECODE ='" + ddoOut.PAPERNO + "'";

        DataTable data = tm.selByPKDataTable(context, paperTypeSql, 0);
        if (data != null && data.Rows.Count != 0)
        {
            Object[] row = data.Rows[0].ItemArray;
            hidPaperType.Value = getCellValue(row[0]);
        }
    }

    private string getCellValue(Object obj)
    {
        return (obj == DBNull.Value ? "" : ((string)obj).Trim());
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //对输入卡号进行检验
        if (!DBreadValidation())
            return;

        TMTableModule tmTMTableModule = new TMTableModule();
        //读取特殊调帐可充值账户表(TF_SPEADJUSTOFFERACC)中卡的调账信息

        TF_SPEADJUSTOFFERACCTDO tdoAdjAccIn = new TF_SPEADJUSTOFFERACCTDO();
        tdoAdjAccIn.CARDNO = txtCashGiftCardno.Text;

        TF_SPEADJUSTOFFERACCTDO tdoAdjAccOut = (TF_SPEADJUSTOFFERACCTDO)tmTMTableModule.selByPK(context, tdoAdjAccIn, typeof(TF_SPEADJUSTOFFERACCTDO), null, "TF_SPEADJUSTOFFERACC_BYCARDNO", null);

        //没有调帐信息时

        if (tdoAdjAccOut == null || tdoAdjAccOut.OFFERMONEY <= 0)
        {
            ClearAdjustInfo();
            context.AddError("A009113102");
            return;
        }

        //显示调账总额
        hidAdjustMoney.Value = tdoAdjAccOut.OFFERMONEY.ToString();

        txtAdjustMoney.Text = (Convert.ToDecimal(tdoAdjAccOut.OFFERMONEY) / 100).ToString("0.00");

        //查询调账明细并显示信息

        gvResult.DataSource = Query();
        gvResult.DataBind();

        btnAdjustSale.Enabled = true;
        btnAdjustAcc.Enabled = false;
    }

    private Boolean DBreadValidation()
    {
        //对卡号进行非空、长度、数字检验
        if (txtCashGiftCardno.Text.Trim() == "")
            context.AddError("A001004113", txtCashGiftCardno);
        else
        {
            if ((txtCashGiftCardno.Text.Trim()).Length != 16)
                context.AddError("A001004114", txtCashGiftCardno);
            else if (!Validation.isNum(txtCashGiftCardno.Text.Trim()))
                context.AddError("A001004115", txtCashGiftCardno);
        }

        return !(context.hasError());
    }

    public ICollection Query()
    {
        //从特殊调帐台帐表(TF_B_SPEADJUSTACC)中读取数据

        DataTable data = SPHelper.callSDQuery(context, "SpeAdjustAcc", txtCashGiftCardno.Text);
        return new DataView(data);
    }
    //调账售卡
    protected void btnAdjustSale_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从IC卡资料表中读取老卡数据
        TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
        ddoTF_F_CARDRECIn.CARDNO = txtCashGiftCardno.Text;

        TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

        //从用户卡库存表(TL_R_ICUSER)中读取新卡数据
        TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
        ddoTL_R_ICUSERIn.CARDNO = hiddenCardno.Value;

        TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

        if (ddoTL_R_ICUSEROut == null)
        {
            context.AddError("A001004128");
            return;
        }

        if (ddoTL_R_ICUSEROut.RESSTATECODE != "01" && ddoTL_R_ICUSEROut.RESSTATECODE != "05")
        {
            context.AddError("A001004132");
            return;
        }

        if (Convert.ToDecimal(hiddenWallet2.Value) * 100 != ddoTL_R_ICUSEROut.CARDPRICE)
        {
            context.AddError("电子钱包2不为10元,不能转值");
            return;
        }

        if ((Convert.ToDecimal(txtAdjustMoney.Text) * 100) < ddoTL_R_ICUSEROut.CARDPRICE)
        {
            context.AddError("余额过小，不能进行调账售卡");
            return;
        }

        SP_SD_AdjustSalePDO pdo = new SP_SD_AdjustSalePDO();

        pdo.ID = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
        pdo.OLDCARDNO = txtCashGiftCardno.Text;
        //pdo.VALIDENDDATE = DateTime.Now.AddMonths(4).AddDays(1 - DateTime.Now.AddMonths(4).Day).AddDays(-1).ToString("yyyyMMdd");
        pdo.VALIDENDDATE = "20500101";
        pdo.CARDNO = hiddenCardno.Value;
        pdo.DEPOSIT = ddoTL_R_ICUSEROut.CARDPRICE;
        pdo.CARDMONEY = Convert.ToInt32(hiddencMoney.Value);
        pdo.ADJUSTMONEY = Convert.ToInt32(Convert.ToDecimal(txtAdjustMoney.Text) * 100);
        pdo.OTHERFEE = 0;
        pdo.CARDTRADENO = hiddentradeno.Value;
        pdo.CARDTYPECODE = txtCashGiftCardno.Text.Substring(4, 2);
        pdo.SELLCHANNELCODE = "01";
        pdo.SERSTAKETAG = "5";
        pdo.TRADETYPECODE = "56";
        pdo.TERMNO = "112233445566";
        pdo.OPERCARDNO = context.s_CardID;
        pdo.currDept = context.s_DepartID;
        pdo.currOper = context.s_UserID;

        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (ok)
        {
            hidCardReaderToken.Value = cardReader.createToken(context);

            hidCardnoForCheck.Value = hiddenCardno.Value;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致 modify by wdx 20111213,写卡提示卡号不对

            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "startCashGiftCard('" + DateTime.Now.ToString("yyyyMMdd")
                + "', '" + pdo.VALIDENDDATE
                + "', " + ((Convert.ToDecimal(txtAdjustMoney.Text) * 100) - ddoTL_R_ICUSEROut.CARDPRICE)
                + ");", true);

            btnPrintPZ.Enabled = true;

            btnAdjustSale.Enabled = false;

        }
    }
}
