using System;
using System.Text;
using System.Collections;
using System.Web.UI;
using TM;
using TDO.CardManager;
using TDO.BusinessCode;
using Common;
using PDO.PersonalBusiness;
using TDO.ResourceManager;
using Master;
using TDO.UserManager;
using System.Data;
using System.Web.UI.WebControls;
using System.Diagnostics;

public partial class ASP_PersonalBusiness_PB_Charge : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            setReadOnly(LabAsn, LabCardtype, sDate, eDate, cMoney, RESSTATE);

            Money.Attributes["onfocus"] = "this.select();";
            Money.Attributes["onkeyup"] = "changemoney(this);";

            if (!context.s_Debugging) setReadOnly(txtCardno);

            initLoad();

            ScriptManager2.SetFocus(btnReadCard);

            selectChargeType(context, selChargeType, true);
            //查询用户打印方式  add by youyue 20140722
            string sql = "select PRINTMODE from TD_M_INSIDESTAFFPRINT where STAFFNO = '" + context.s_UserID + "'";
            context.DBOpen("Select");
            DataTable dt = context.ExecuteReader(sql);
            if (dt.Rows.Count == 1 && dt.Rows[0]["PRINTMODE"].ToString().Trim() == "1")
            {
                chkPingzheng.Checked = true;//打印方式是针式打印
            }
            else if (dt.Rows.Count == 1 && dt.Rows[0]["PRINTMODE"].ToString().Trim() == "2")
            {
                chkPingzhengRemin.Checked = true;//打印方式是热敏打印
            }
            else
            {
                chkPingzheng.Checked = true;//如果没有设置则默认是针式打印
            }
        }
    }

    public static void selectChargeType(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---普通---", ""));

        SPHelper.selectCoding(context, ddl, "DEPTHASCHARGETYPE", context.s_DepartID);
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S094570250: 充值营销模式失败");
        }
    }

    protected void initLoad()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从前台业务交易费用表中读取数据


        TD_M_TRADEFEETDO ddoTD_M_TRADEFEETDOIn = new TD_M_TRADEFEETDO();
        ddoTD_M_TRADEFEETDOIn.TRADETYPECODE = "02";

        TD_M_TRADEFEETDO[] ddoTD_M_TRADEFEEOutArr = (TD_M_TRADEFEETDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_TRADEFEETDOIn, typeof(TD_M_TRADEFEETDO), "S001002125", "TD_M_TRADEFEE", null);

        for (int i = 0; i < ddoTD_M_TRADEFEEOutArr.Length; i++)
        {
            //费用类型为充值


            if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "01")
                hidSupplyFee.Value = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
            //费用类型为其他费用


            else if (ddoTD_M_TRADEFEEOutArr[i].FEETYPECODE == "99")
                OtherFee.Text = ((Convert.ToDecimal(ddoTD_M_TRADEFEEOutArr[i].BASEFEE)) / 100).ToString("0.00");
        }
        SupplyFee.Text = hidSupplyFee.Value;
        Total.Text = (Convert.ToDecimal(SupplyFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");

        //查询当前操作员充值默认值



        TD_M_INSIDESTAFFPARAMETERTDO tdoTD_M_INSIDESTAFFPARAMETERIn = new TD_M_INSIDESTAFFPARAMETERTDO();
        tdoTD_M_INSIDESTAFFPARAMETERIn.STAFFNO = context.s_UserID;

        TD_M_INSIDESTAFFPARAMETERTDO tdoTD_M_INSIDESTAFFPARAMETEROut = (TD_M_INSIDESTAFFPARAMETERTDO)tmTMTableModule.selByPK(context, tdoTD_M_INSIDESTAFFPARAMETERIn, typeof(TD_M_INSIDESTAFFPARAMETERTDO), null, "TD_M_INSIDESTAFFPARAMETER", null);
        //当前操作员没有充值默认值



        if (tdoTD_M_INSIDESTAFFPARAMETEROut == null)
        {
            Money.Text = "0";
        }
        //当前操作员有充值默认值



        else if (tdoTD_M_INSIDESTAFFPARAMETEROut.SUPPLEMONEY != -1)
        {
            Money.Text = Convert.ToString((Convert.ToDecimal(tdoTD_M_INSIDESTAFFPARAMETEROut.SUPPLEMONEY)) / (Convert.ToDecimal(100)));
            SupplyFee.Text = (Convert.ToDecimal(SupplyFee.Text) + (Convert.ToDecimal(tdoTD_M_INSIDESTAFFPARAMETEROut.SUPPLEMONEY)) / (Convert.ToDecimal(100))).ToString("0.00");
            Total.Text = (Convert.ToDecimal(SupplyFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");
        }

        //Cash.Checked = true;
        //XFCard.Checked = false;
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        #region add by liuhe 20111231 添加对代理营业厅预付款的验证
        if (DeptBalunitHelper.ValdatePrepay(context) == false)
        {
            return;
        }
        #endregion

        btnReadCardProcess();
        if (context.hasError()) return;

        initLoad();

        if (context.hasError())
        {
            ScriptManager2.SetFocus(btnReadCard);
            return;
        }
        else
        {
            ScriptManager2.SetFocus(Money);
        }

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
            Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
            Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
        }
        //add by youyue 2014-10-10 提示卡号是否有效换乘中奖信息
        string winnerInfo = TLHelper.queryWinnerInfo(context, txtCardno.Text);
        if (winnerInfo != string.Empty)
        {
            context.AddError(winnerInfo);
        }




    }

    protected void btnReadCardProcess()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //卡账户有效性检验


        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardno.Text;
        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (ok)
        {
            //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据



            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
            ddoTD_M_CARDTYPEIn.CARDTYPECODE = hiddenLabCardtype.Value;

            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

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

            //从证件类型编码表(TD_M_PAPERTYPE)中读取数据


            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
            ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);

            //给页面显示项赋值


            LabAsn.Text = hiddenAsn.Value.Substring(4, 16);
            LabCardtype.Text = ddoTD_M_CARDTYPEOut.CARDTYPENAME;
            sDate.Text = ASHelper.toDateWithHyphen(hiddensDate.Value);
            eDate.Text = ASHelper.toDateWithHyphen(hiddeneDate.Value);
            cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / (Convert.ToDecimal(100))).ToString("0.00");
            CustName.Text = ddoTF_F_CUSTOMERRECOut.CUSTNAME;

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

            Paperno.Text = ddoTF_F_CUSTOMERRECOut.PAPERNO;
            Custaddr.Text = ddoTF_F_CUSTOMERRECOut.CUSTADDR;
            Custpost.Text = ddoTF_F_CUSTOMERRECOut.CUSTPOST;
            Custphone.Text = ddoTF_F_CUSTOMERRECOut.CUSTPHONE;
            txtEmail.Text = ddoTF_F_CUSTOMERRECOut.CUSTEMAIL;
            Remark.Text = ddoTF_F_CUSTOMERRECOut.REMARK;

            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = txtCardno.Text;

            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);
            sellTime.Text = ddoTF_F_CARDRECOut.SELLTIME.ToString("yyyy-MM-dd");
            CommonHelper.readCardJiMingState(context, txtCardno.Text, hidIsJiMing);
            //查询卡片开通功能并显示
            PBHelper.openFunc(context, openFunc, txtCardno.Text);

            bool IsOpenMonth = false;
            string openFuncStr = "本卡为";
            foreach (object list in openFunc.List)
            {
                if (list.ToString() == "学生月票")
                {
                    openFuncStr += "学生月票、";
                    IsOpenMonth = true;
                }
                if (list.ToString() == "老人月票")
                {
                    openFuncStr += "老人月票、";
                    IsOpenMonth = true;
                }
                if (list.ToString() == "高龄卡")
                {
                    openFuncStr += "高龄卡、";
                    IsOpenMonth = true;
                }
                if (list.ToString() == "残疾人月票")
                {
                    openFuncStr += "残疾人月票、";
                    IsOpenMonth = true;
                }
                if (list.ToString() == "张家港残疾人月票")
                {
                    openFuncStr += "张家港残疾人月票、";
                    IsOpenMonth = true;
                }
                if (list.ToString() == "张家港老年人月票")
                {
                    openFuncStr += "张家港老年人月票、";
                    IsOpenMonth = true;
                }
                if (list.ToString() == "张家港公交员工卡")
                {
                    openFuncStr += "张家港公交员工卡、";
                    IsOpenMonth = true;
                }
            }
            if (IsOpenMonth == true)
            {
                openFuncStr = openFuncStr.TrimEnd(new char[] { '、' });

                ScriptManager.RegisterStartupScript(this, this.GetType(), "AdjustScript", "submitConfirm('" + openFuncStr + "');", true);
            }


            btnSupply.Enabled = true;
            btnPrintPZ.Enabled = false;
        }
        else if (pdoOut.retCode == "A001107199")
        {//验证如果是黑名单卡，锁卡
            this.LockBlackCard(txtCardno.Text);
            this.hidLockBlackCardFlag.Value = "yes";
            hidCardnoForCheck.Value = txtCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致
        }
    }

    //充值类型改变时清空费用信息
    protected void Cash_CheckedChanged(object sender, EventArgs e)
    {
        Money.Text = "";
        SupplyFee.Text = "0.00";
        Total.Text = (Convert.ToDecimal(SupplyFee.Text) + Convert.ToDecimal(OtherFee.Text)).ToString("0.00");

        if (Cash.Checked)
        {
            Money.MaxLength = 7;
            labPrompt.Text = "请输入充值金额:";
            charge50.Visible = true;
            charge60.Visible = true;
            charge100.Visible = true;
            charge82.Visible = true;
            charge64.Visible = true;

            selChargeType.Enabled = true;
        }
        else
        {
            Money.MaxLength = 16;
            labPrompt.Text = "请输入16位充值卡密码:";
            charge50.Visible = false;
            charge60.Visible = false;
            charge100.Visible = false;
            charge82.Visible = false;
            charge64.Visible = false;

            selChargeType.SelectedValue = "";
            selChargeType.Enabled = false;
        }
        ScriptManager2.SetFocus(Money);
    }

    //输入内容有效性检查


    private Boolean inportValidation()
    {
        //对输入金额进行非空、非零、数字、金额格式判断


        if (Cash.Checked == true)
        {
            if (!Validation.isNum(Money.Text.Trim()))
                context.AddError("A001002100");
            else if (Money.Text.Trim() == "" || Convert.ToDecimal(Money.Text.Trim()) == 0)
                context.AddError("A001002126");
            else if (!Validation.isPosRealNum(Money.Text.Trim()))
                context.AddError("A001002127");
        }

        //对输入的充值卡密码进行非空、长度、字符数字判断


        else if (XFCard.Checked == true)
        {
            if (Money.Text.Trim() == "")
                context.AddError("A001002128");
            else if (Validation.strLen(Money.Text.Trim()) != 16)
                context.AddError("A001002129");
            else if (!Validation.isNum(Money.Text.Trim()))
                context.AddError("A001002130");
        }

        return !(context.hasError());
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        Stopwatch sw = new Stopwatch();
        sw.Start();
        if (hidWarning.Value == "CashChargeConfirm")
        {
            btnSupply_Click(sender, e);
            hidWarning.Value = "";
            return;
        }

        if (Cash.Checked)
        {
            if (hidWarning.Value == "yes")
            {
                btnSupply.Enabled = true;
            }
            else if (hidWarning.Value == "writeSuccess")
            {
                #region 如果是前台黑名单锁卡
                //前台锁卡没有写写卡台账

                if (this.hidLockBlackCardFlag.Value == "yes")
                {
                    AddMessage("黑名单卡已锁");
                    clearCustInfo(txtCardno);
                    this.hidLockBlackCardFlag.Value = "";
                    return;
                }
                #endregion

                SP_PB_updateCardTradePDO pdo = new SP_PB_updateCardTradePDO();
                pdo.CARDTRADENO = hiddentradeno.Value;
                pdo.TRADEID = hidoutTradeid.Value;

                bool ok = TMStorePModule.Excute(context, pdo);

                if (ok)
                {
                    AddMessage("前台写卡成功");

                    #region add by liuhe 20111231 添加对代理营业厅预付款的验证,扣费后如果超过预警额度则提示
                    if (Cash.Checked == true)
                    {
                        int opMoney = Convert.ToInt32(Convert.ToDecimal(Money.Text) * 100) + Convert.ToInt32(Convert.ToDecimal(OtherFee.Text) * 100);
                        DeptBalunitHelper.ValdatePrepay(context, opMoney, "1");
                    }
                    #endregion

                    clearCustInfo(txtCardno);
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
            if (chkPingzhengRemin.Checked && btnPrintPZ.Enabled) //add by youyue  增加热敏打印方式
            {
                ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "printRMInvoice();", true);
            }
            Money.Text = "";
        }
        else if (XFCard.Checked)
        {
            if (hidWarning.Value == "QueryChargeCardValue")
            {
                QueryChargeCardValue();
                ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "ChargeCardChargeCheck();", true);
                hidWarning.Value = "";
                return;
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
            if (chkPingzhengRemin.Checked && btnPrintPZ.Enabled) //add by youyue  增加热敏打印方式
            {
                ScriptManager.RegisterStartupScript(
                    this, this.GetType(), "writeCardScript",
                    "printRMInvoice();", true);
            }
        }
        sw.Stop();
        Common.Log.Info(hidCardnoForCheck.Value + "充值写卡时间为：" + sw.ElapsedMilliseconds.ToString() + "毫秒", "AppLog");
        sw.Reset();
        initLoad();
        hidWarning.Value = "";
        hidCardnoForCheck.Value = "";//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致
    }

    protected void btnSupply_Click(object sender, EventArgs e)
    {
        //对输入金额或充值卡密码有效性进行检验


        if (!inportValidation())
            return;

        #region add by liuhe 20111231 添加对代理营业厅预付款的验证,提交前如果扣费后不足最低额度则返回
        if (Cash.Checked == true)
        {
            int opMoney = Convert.ToInt32(Convert.ToDecimal(Money.Text) * 100) + Convert.ToInt32(Convert.ToDecimal(OtherFee.Text) * 100);
            if (DeptBalunitHelper.ValdatePrepay(context, opMoney, "2") == false)
            {
                return;
            }
        }
        #endregion

        TMTableModule tmTMTableModule = new TMTableModule();

        //从IC卡电子钱包账户表中读取数据


        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
        ddoTF_F_CARDEWALLETACCIn.CARDNO = txtCardno.Text;

        TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null, "TF_F_CARDEWALLETACC", null);

        hidCardnoForCheck.Value = txtCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致

        //充值类型为现金
        if (Cash.Checked == true)
        {
            Stopwatch sw = new Stopwatch();
            sw.Start();
            SP_PB_ChargePDO pdo = new SP_PB_ChargePDO();

            pdo.ID = DealString.GetRecordID(hiddentradeno.Value, LabAsn.Text);
            //pdo.ID = hiddentradeno.Value + DateTime.Now.ToString("MMddhhmmss") + LabAsn.Text.Substring(12, 4);
            pdo.CARDNO = txtCardno.Text;
            pdo.CARDTRADENO = hiddentradeno.Value;
            pdo.CARDMONEY = Convert.ToInt32(Convert.ToDecimal(cMoney.Text) * 100);
            pdo.CARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;
            pdo.ASN = LabAsn.Text;
            pdo.CARDTYPECODE = hiddenLabCardtype.Value;
            pdo.TRADETYPECODE = "02";
            pdo.SUPPLYMONEY = Convert.ToInt32((Convert.ToDecimal(Money.Text)) * 100);
            hidSupplyMoney.Value = "" + pdo.SUPPLYMONEY;
            hiddenSupply.Value = Money.Text;
            pdo.OPERCARDNO = context.s_CardID;
            pdo.TERMNO = "112233445566";
            pdo.OTHERFEE = (Convert.ToInt32(Convert.ToDecimal(OtherFee.Text)) * 100);
            pdo.CHARGETYPE = selChargeType.SelectedValue;
            PDOBase pdoOut;
            bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);
            sw.Stop();
            Common.Log.Info(hidCardnoForCheck.Value + "充值存储过程时间为：" + sw.ElapsedMilliseconds.ToString() + "毫秒", "AppLog");
            if (ok)
            {
                hidoutTradeid.Value = "" + ((SP_PB_ChargePDO)pdoOut).TRADEID;
                //AddMessage("M001002001");
                ScriptManager.RegisterStartupScript(this, this.GetType(),
                    "writeCardScript", "chargeCard();", true);

                btnPrintPZ.Enabled = true;

                ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, CustName.Text, "充值",
                hiddenSupply.Value, "", "", ASHelper.GetPaperNo(Paperno.Text),
                Convert.ToString((pdo.CARDMONEY + pdo.SUPPLYMONEY) / 100.0), "", hiddenSupply.Value, context.s_UserID,
                context.s_DepartName, Papertype.Text, "0.00", "");
                ASHelper.preparePingZheng(PrintRMPingZheng, txtCardno.Text, CustName.Text, "充值",
                hiddenSupply.Value, "", "", ASHelper.GetPaperNo(Paperno.Text),
                Convert.ToString((pdo.CARDMONEY + pdo.SUPPLYMONEY) / 100.0), "", hiddenSupply.Value, context.s_UserID,
                context.s_DepartName, Papertype.Text, "0.00", "");

                //foreach (Control con in this.Page.Controls)
                //{
                //    ClearControl(con);
                //}

                btnSupply.Enabled = false;
            }

        }
        //充值类型为充值卡充值


        else if (XFCard.Checked == true)
        {
            //string publicKeyPwdIndex = System.Configuration.ConfigurationManager.AppSettings["PwdIndex"];

            //StringBuilder strCliper = new StringBuilder(1024);//目前看到16位字符串加密后密文达到512位，没有做大规模测试，所以保险起见暂分配1024位


            //RMEncryptionHelper.EncodeString(Convert.ToInt32(publicKeyPwdIndex), Money.Text.Trim(), strCliper);
            //充值卡密码加密
            int ret = -1;
            int ret2 = -1;
            string token;
            int epochSeconds;
            string plain = Money.Text.Trim();//明文
            StringBuilder cliper = new StringBuilder(512 + 1);//密文可以确定为512位


            string strCliper = "";
            // 打开服务
            ret = RMEncryptionHelper.Open();
            if (ret != 0)
            {
                context.AddError("打开服务失败！");
                return;
            }
            else
            {
                context.AddError("打开服务成功");
            }

            // 获得TOKEN值



            string sql = "SELECT SYSDATE FROM DUAL";

            TMTableModule tm = new TMTableModule();
            DataTable data = tm.selByPKDataTable(context, sql, 1);
            DateTime now = (DateTime)data.Rows[0].ItemArray[0];
            TimeSpan epochTime = (now.ToUniversalTime() - new DateTime(1970, 1, 1));
            token = Token.createToken(context.s_CardID, (uint)epochTime.TotalSeconds);
            epochSeconds = (int)epochTime.TotalSeconds;

            // 加密
            ret2 = RMEncryptionHelper.EncodeString(context.s_CardID, token, epochSeconds, 0, plain, cliper);
            if (ret2 != 0)
            {
                context.AddError("加密失败!");
                RMEncryptionHelper.Close();
                return;
            }
            else
            {
                strCliper = cliper.ToString();
            }
            RMEncryptionHelper.Close();

            SP_PB_XFChargePDO pdo = new SP_PB_XFChargePDO();

            pdo.PASSWD = strCliper.ToString();
            pdo.ID = DealString.GetRecordID(hiddentradeno.Value, LabAsn.Text);
            //pdo.ID = hiddentradeno.Value + DateTime.Now.ToString("MMddhhmmss") + LabAsn.Text.Substring(12, 4);
            pdo.CARDNO = txtCardno.Text;
            pdo.CARDTRADENO = hiddentradeno.Value;
            pdo.CARDMONEY = Convert.ToInt32(Convert.ToDecimal(cMoney.Text) * 100);
            pdo.CARDACCMONEY = ddoTF_F_CARDEWALLETACCOut.CARDACCMONEY;
            pdo.ASN = LabAsn.Text;
            pdo.CARDTYPECODE = hiddenLabCardtype.Value;
            pdo.TRADETYPECODE = "14";
            pdo.TERMNO = "112233445566";
            PDOBase pdoOut;
            bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

            if (ok)
            {
                hidSupplyMoney.Value = "" + ((SP_PB_XFChargePDO)pdoOut).SUPPLYMONEY;
                hiddenSupply.Value = (Convert.ToDecimal(hidSupplyMoney.Value) / (Convert.ToDecimal(100))).ToString("0.00");
                AddMessage("M001002001");

                ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                    "chargeCard();", true);

                ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, CustName.Text, "充值卡充值",
                hiddenSupply.Value, "", "", ASHelper.GetPaperNo(Paperno.Text),
                Convert.ToString(Convert.ToDecimal(pdo.CARDMONEY + Convert.ToInt32(hidSupplyMoney.Value)) / (Convert.ToDecimal(100))), "",
                hiddenSupply.Value, context.s_UserID, context.s_DepartName,
                Papertype.Text, "0.00", "");

                //add by youyue 20140718 充值卡充值热敏打印凭证数据准备
                ASHelper.preparePingZheng(PrintRMPingZheng, txtCardno.Text, CustName.Text, "充值卡充值",
                hiddenSupply.Value, "", "", ASHelper.GetPaperNo(Paperno.Text),
                Convert.ToString(Convert.ToDecimal(pdo.CARDMONEY + Convert.ToInt32(hidSupplyMoney.Value)) / (Convert.ToDecimal(100))), "",
                hiddenSupply.Value, context.s_UserID, context.s_DepartName,
                Papertype.Text, "0.00", "");
                btnPrintPZ.Enabled = true;

                //foreach (Control con in this.Page.Controls)
                //{
                //    ClearControl(con);
                //}

                btnSupply.Enabled = false;
            }
        }

    }

    protected void QueryChargeCardValue()
    {
        Money.Text = Money.Text.Trim();



        //充值卡密码加密
        int ret = -1;
        int ret2 = -1;
        string token;
        int epochSeconds;
        string plain = Money.Text.Trim();//明文
        StringBuilder cliper = new StringBuilder(512 + 1);//密文可以确定为512位


        string strCliper = "";
        // 打开服务
        ret = RMEncryptionHelper.Open();
        if (ret != 0)
        {
            context.AddError("打开服务失败！");
            return;
        }
        else
        {
            context.AddError("打开服务成功");
        }

        // 获得TOKEN值



        string sql = "SELECT SYSDATE FROM DUAL";

        TMTableModule tm = new TMTableModule();
        DataTable data = tm.selByPKDataTable(context, sql, 1);
        DateTime now = (DateTime)data.Rows[0].ItemArray[0];
        TimeSpan epochTime = (now.ToUniversalTime() - new DateTime(1970, 1, 1));
        token = Token.createToken(context.s_CardID, (uint)epochTime.TotalSeconds);
        epochSeconds = (int)epochTime.TotalSeconds;

        // 加密
        ret2 = RMEncryptionHelper.EncodeString(context.s_CardID, token, epochSeconds, 0, plain, cliper);
        if (ret2 != 0)
        {
            context.AddError("加密失败!");
            RMEncryptionHelper.Close();
            return;
        }
        else
        {
            strCliper = cliper.ToString();
        }
        RMEncryptionHelper.Close();



        if (!Cash.Checked)//充值卡查询金额
        {
            DataTable data1 = SPHelper.callPBQuery(context,
                "QueryChargeCardValue", strCliper);
            if (data1 == null || data1.Rows.Count == 0)
            {
                context.AddError("充值卡密码无效");
                return;
            }

            SupplyFee.Text = ((Decimal)data1.Rows[0].ItemArray[0]).ToString("0.00");
        }
    }
}
