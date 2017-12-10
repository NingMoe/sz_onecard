using System;
using System.Text;
using System.Collections;
using System.Collections.Generic;
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
using System.Globalization;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public partial class ASP_PersonalBusiness_HYDROPOWER_CHARGE : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            HYDROPHelper.InitItemCodes(selItemCode, true);//缴费类别

            setReadOnly(txtCardno, LabAsn, LabCardtype, sDate, eDate, cMoney, RESSTATE, relBalance);
            lvwSupplyQuery.DataSource = initEmptyDataTable();
            lvwSupplyQuery.DataBind();

            ScriptManager2.SetFocus(txtAccountId);

            //查询用户打印方式  add by youyue 20140722
            //string sql = "select PRINTMODE from TD_M_INSIDESTAFFPRINT where STAFFNO = '" + context.s_UserID + "'";
            //context.DBOpen("Select");
            //DataTable dt = context.ExecuteReader(sql);
            //if (dt.Rows.Count == 1 && dt.Rows[0]["PRINTMODE"].ToString().Trim() == "1")
            //{
            //    chkPingzheng.Checked = true;//打印方式是针式打印
            //}
        }
    }

    protected void btnQuery_OnClick(object sender, EventArgs e)
    {
        string itemCode = selItemCode.Text.Trim();
        string accountId = txtAccountId.Text.Trim();
        InitControl();//先清空
        //判断输入是否合法，以及是否存在缴费失败或异常的记录
        CheckExceptionRecord(itemCode, accountId);
        if (context.hasError())
        {
            return;
        }
        //调用接口发起查询
        btnQuery.Enabled = false;//先禁用，防止DoubleClick
        string seqNo = GetSeq();
        hidResponseTradeId.Value = seqNo;
        string currentTime = DateTime.Now.ToString("yyyyMMddHHmmssfff");
        hidORIGDATE.Value = DateTime.Now.ToString("yyyyMMdd");
        Dictionary <string, string> postData = new Dictionary<string, string>();
        postData.Add("SeqNo", seqNo);
        postData.Add("Time", currentTime);
        postData.Add("ItemCode", itemCode);
        postData.Add("AccountId", accountId);
        postData.Add("Timeout", "0");
        string data = HttpHelper.PostRequest(HttpHelper.TradeType.Query, postData);
        if (!checkResponse(data))//检查返回报文是否正确
        {
            context.AddError("返回报文有误，请联系系统管理员！");
            return;
        }
        DataTable griDataTable = fillDataTable(data);//解析并给grid复制
        if (!context.hasError())
        {
            foreach (Control control in feeContent.Controls)
            {
                if (control is RadioButton)
                {
                    ((RadioButton)control).Checked = false;
                    string money = ((RadioButton) control).Text;
                    if (Convert.ToDouble(money)*100 >= Convert.ToDouble(hidOrginTotalPayFee.Value))
                    {
                        ((RadioButton) control).Enabled = true;
                    }
                    else
                    {
                        ((RadioButton)control).Enabled = false;
                    }

                    if (Convert.ToDouble(money) * 100 == Convert.ToDouble(hidOrginTotalPayFee.Value))
                    {
                        ((RadioButton) control).Checked = true;
                    }
                }
            }
        }
        btnQuery.Enabled = true;//再次启用
    }

    private void CheckExceptionRecord(string itemCode, string accountId)
    {
        string nowDateStr = DateTime.Now.ToString("yyyyMMdd");
        if (itemCode == "" || accountId == "")
        {
            context.AddError("缴费类别或用户号为空！");
            return;
        }
        DataTable dt = SPHelper.callQuery("SP_CS_HYDROPPOWER_QUERY", context, "Query_HYDROPPOWER_IsFail", accountId);
        if (dt.Rows.Count > 0)
        {
            context.AddError("该用户号存在缴费失败记录，请先返销");
            return;
        }
        dt = SPHelper.callQuery("SP_CS_HYDROPPOWER_QUERY", context, "Query_HYDROPPOWER_IsException", itemCode,
            accountId);
        if (dt.Rows.Count > 0)
        {
            string queryDateStr = dt.Rows[0]["REQUEST_TIME"].ToString();
            if (queryDateStr == nowDateStr)
            {
                context.AddError("该用户号此缴费类别存在缴费异常记录，当天不可再缴费");
                return;
            }
            else if (String.Compare(queryDateStr, nowDateStr, StringComparison.Ordinal) < 0)
            {
                context.AddError("该用户号此缴费类别存在缴费异常记录，请先返销");
                return;
            }
        }
    }

    private bool checkResponse(string data)
    {
        if (data.IndexOf("Code") > -1 && data.IndexOf("SeqNo") > -1)
        {
            return true;
        }
        return false;
    }

    private DataTable fillDataTable(string data)
    {
        //解析json
        DataTable dt = initEmptyDataTable();
        JObject deserObject = (JObject)JsonConvert.DeserializeObject(data);
        string responseStatus = "";
        string code = "";
        string message = "";
        foreach (JProperty itemProperty in deserObject.Properties())
        {
            string propertyName = itemProperty.Name;
            if (propertyName == "ResponseStatus")
            {
                JObject statuJObject = (JObject) itemProperty.Value;
                foreach (JProperty subItemJProperty in statuJObject.Properties())
                {
                    if (subItemJProperty.Name == "ErrorCode")
                    {
                        responseStatus = subItemJProperty.Value.ToString();
                        hidResponseStatus.Value = responseStatus;
                        break;
                    }
                }
            }
            else if (propertyName == "Code")
            {
                code = itemProperty.Value.ToString();
                hidCode.Value = code;
            }
            else if (propertyName == "Message")
            {
                message = itemProperty.Value.ToString();
                hidMessage.Value = message;
            }
        }

        if (responseStatus == "1") //表示成功
        {
            foreach (JProperty itemProperty in deserObject.Properties())
            {
                string propertyName = itemProperty.Name;
                if (propertyName == "SeqNo")
                {
                    hidSeqNo.Value = itemProperty.Value.ToString();
                }
                else if (propertyName == "Time")
                {
                    hidTime.Value = itemProperty.Value.ToString();
                }
                else if (propertyName == "ItemCode")
                {
                    hidItemCode.Value = itemProperty.Value.ToString();
                }
                else if (propertyName == "AccountId")
                {
                    hidAccountId.Value = itemProperty.Value.ToString();
                }
                else if (propertyName == "TotalNum")
                {
                    hidTotalNum.Value = itemProperty.Value.ToString();
                }
                else if(propertyName == "ResponseDetails")
                {
                    //DataTable赋值
                    JArray detailArray = (JArray)itemProperty.Value;
                    foreach (JObject subItem in detailArray)
                    {
                        DataRow newRow = dt.NewRow();
                        newRow["AccountId"] = hidAccountId.Value;
                        foreach (JProperty subItemJProperty in subItem.Properties())
                        {
                            newRow[subItemJProperty.Name] = subItemJProperty.Value.ToString();
                        }
                        dt.Rows.Add(newRow);
                    }
                }
            }
        }
        else if (responseStatus == "0")//表示失败
        {
            context.AddError(message);
        }
        if (dt.Rows.Count > 0)
        {
            //DataTable按照月份排序
            DataView dv = dt.DefaultView;
            dv.Sort = "AccountMonth Asc";
            dt = dv.ToTable();
            //给隐藏栏位赋值
            DataRow fristDataRow = dt.Rows[0];
            hidUserName.Value = fristDataRow["UserName"].ToString();
            hidTotalAmount.Value = fristDataRow["TotalAmount"].ToString();
            hidAccountMonth.Value = fristDataRow["AccountMonth"].ToString();
            hidBalance.Value = fristDataRow["Balance"].ToString();
            hidDelayCharge.Value = fristDataRow["DelayCharge"].ToString();
            hidContractNo.Value = fristDataRow["ContractNo"].ToString();

            if (Convert.ToDouble(hidTotalAmount.Value) <= 0)//如果查询出来的缴费总金额是0，默认50
            {
                hidTotalAmount.Value = "50";
            }

            hidTotalPayFee.Value = (Convert.ToDouble(hidTotalAmount.Value)*100).ToString();
            hidOrginTotalPayFee.Value = hidTotalPayFee.Value;
            txtTotalPayFee.Text = Convert.ToDouble(hidTotalAmount.Value).ToString("0.00");

            lvwSupplyQuery.DataSource = dt;
            lvwSupplyQuery.DataBind();
            lvwSupplyQuery.SelectedIndex = 0;
        }
        return dt;
    }

    /// <summary>
    /// 初始化页面
    /// </summary>
    private void InitControl()
    {
        context.ErrorMessage.Clear();
        context.NormalMessages.Clear();
        //清空卡片信息和用户信息的TextBox和 HiddenField
        initUserCardInfo();
        way_wallet.Checked = false;
        way_account.Checked = false;
        way_account_OnCheckedChanged(null, null);

        txtTotalPayFee.Text = "0.00";
        hidTotalPayFee.Value = "0";
        hidOrginTotalPayFee.Value = "0";

        hidResponseStatus.Value = "";
        hidCode.Value = "";
        hidMessage.Value = "";
        hidTotalNum.Value = "";
        hidSeqNo.Value = "";
        hidTime.Value = "";
        hidItemCode.Value = "";
        hidAccountId.Value = "";

        hidUserName.Value = "";
        hidTotalAmount.Value = "";
        hidAccountMonth.Value = "";
        hidBalance.Value = "";
        hidDelayCharge.Value = "";
        hidContractNo.Value = "";
        hidResponseTradeId.Value = "";
        hidORIGDATE.Value = "";

        foreach (Control control in feeContent.Controls)
        {
            if (control is RadioButton)
            {
                ((RadioButton)control).Checked = false;
                ((RadioButton)control).Enabled = false;
            }
        }

        lvwSupplyQuery.DataSource = initEmptyDataTable();
        lvwSupplyQuery.DataBind();
    }

    private void initUserCardInfo()
    {
        //清空卡片信息的TextBox和 HiddenField
        foreach (Control control in CardInfoContent.Controls)
        {
            if (control is TextBox)
            {
                ((TextBox)control).Text = "";
            }
            else if (control is HiddenField)
            {
                ((HiddenField)control).Value = "";
            }
        }
        openFunc.List = new ArrayList();
        hiddencMoney.Value = "0";
        hidRelBalance.Value = "0";

        //清空用户信息
        foreach (Control control in UserInfoContent.Controls)
        {
            if (control is Label)
            {
                ((Label)control).Text = "";
            }
        }

        btnSupply.Enabled = false;
        btnPrintPZ.Enabled = false;
    }

    private DataTable initEmptyDataTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("AccountId", typeof (string));//用户号
        dt.Columns.Add("UserName", typeof(string));//用户姓名
        dt.Columns.Add("ContractNo", typeof(string));//合同号
        dt.Columns.Add("Balance", typeof(string));//账户余额
        dt.Columns.Add("AccountMonth", typeof(string));//账单月份
        dt.Columns.Add("TotalAmount", typeof(string));//缴费总金额
        dt.Columns.Add("DelayCharge", typeof(string));//滞纳金

        dt.Columns["AccountId"].MaxLength = 10000;
        dt.Columns["UserName"].MaxLength = 10000;
        dt.Columns["ContractNo"].MaxLength = 10000;
        dt.Columns["Balance"].MaxLength = 10000;
        dt.Columns["AccountMonth"].MaxLength = 10000;
        dt.Columns["TotalAmount"].MaxLength = 10000;
        dt.Columns["DelayCharge"].MaxLength = 10000;

        return dt;
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        btnSupply.Enabled = false;
        btnPrintPZ.Enabled = false;
        //initUserCardInfo();
        CheckExceptionRecord(hidItemCode.Value, hidAccountId.Value);
        if (context.hasError()) return;
        if (hidTotalPayFee.Value == "" || Convert.ToDouble(hidTotalPayFee.Value) <= 0)
        {
            context.AddError("请先查询出欠缴水费");
            return;
        }
        if (!way_wallet.Checked && !way_account.Checked)
        {
            context.AddError("请先选择缴费方式");
            return;
        }
        if (way_account.Checked && account_pass.Text.Trim() == "")
        {
            context.AddError("请输入专有账户密码");
            return;
        }

        //# region for test
        //txtCardno.Text = "00427839505";
        //hiddentxtCardno.Value = "00427839505";
        //hiddentradeno.Value = "2222";
        //hiddenAsn.Value = "0000000427839505";
        //hiddencMoney.Value = "50000";
        //hiddeneDate.Value = "20170331";
        //hiddensDate.Value = "20130331";
        //hiddenLabCardtype.Value = "01";
        //#endregion
        btnReadCardProcess();
        if (context.hasError())
        {
            initUserCardInfo();
            ScriptManager2.SetFocus(btnReadCard);
            return;
        }

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            Paperno.Text = CommonHelper.GetPaperNo(Paperno.Text);
            Custphone.Text = CommonHelper.GetCustPhone(Custphone.Text);
            Custaddr.Text = CommonHelper.GetCustAddress(Custaddr.Text);
        }
        btnSupply.Enabled = true;
        btnPrintPZ.Enabled = false;
    }

    protected void btnReadCardProcess()
    {
        //判断此前是否有写卡失败记录
        DataTable dt = SPHelper.callQuery("SP_CS_HYDROPPOWER_QUERY", context, "Query_HYDROPPOWER_WriteCardFail", hiddentxtCardno.Value);
        if (dt != null && dt.Rows.Count > 0)
        {
            context.AddError("此卡有写卡失败记录，请先进行返销");
            return;
        }

        TMTableModule tmTMTableModule = new TMTableModule();
        //卡账户有效性检验
        //SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        //pdo.CARDNO = txtCardno.Text;
        //PDOBase pdoOut;
        //bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        context.SPOpen();
        context.AddField("p_CARDNO").Value = txtCardno.Text;

        string retCode = "";
        bool ok = context.ExecuteSP("SP_Credit_Check", out retCode);

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


            LabAsn.Text = hiddenAsn.Value.Substring(4, hiddenAsn.Value.Length - 4);
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

            //如果是专有账户，还要读出账户余额（需判断是否有专有账户）
            if (way_account.Checked && account_pass.Text.Trim() != "")
            {
                string currentDateTimeStr = DateTime.Now.ToString("yyyyMMddHHmmss");
                dt = SPHelper.callQuery("SP_CS_HYDROPPOWER_QUERY", context, "QueryAccountIsExistInfo", hiddentxtCardno.Value, currentDateTimeStr);

                relBalance.Text = "";
                hidRelBalance.Value = "0";
                if (dt.Rows.Count == 0)
                {
                    context.AddError("该卡未开通专有账户或专有账户已失效");
                }
                else
                {
                    string CUST_PASSWORD = dt.Rows[0]["CUST_PASSWORD"].ToString().Trim();
                    StringBuilder pwd = new System.Text.StringBuilder(256);
                    CAEncryption.CAEncrypt(account_pass.Text.Trim(), ref pwd);//密码是加密的
                    if (pwd.ToString() != CUST_PASSWORD)
                    {
                        context.AddError("专有账户密码错误，请重新输入！");
                    }
                    else
                    {
                        string REL_BALANCE = dt.Rows[0]["REL_BALANCE"].ToString();
                        REL_BALANCE = REL_BALANCE == "" ? "0" : REL_BALANCE;
                        hidRelBalance.Value = REL_BALANCE;
                        relBalance.Text = (Convert.ToDouble(REL_BALANCE) / 100).ToString("0.00");
                    }
                }
            }
            else if (way_wallet.Checked)
            {
                hidRelBalance.Value = "0";
                relBalance.Text = "";
            }
        }
        else if (retCode == "A001107199")
        {//验证如果是黑名单卡，锁卡
            this.LockBlackCard(txtCardno.Text);
            this.hidLockBlackCardFlag.Value = "yes";
            //hidCardnoForCheck.Value = txtCardno.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致
        }
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "rewriteCard") // 重新写卡，生产新的令牌
        {
            hidCardReaderToken.Value = cardReader.createToken(context);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript", "writeCard();", true);
        }
        else if (hidWarning.Value == "yes")
        {
            btnSupply.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            Deduct(sender, e);
        }
        else if (hidWarning.Value == "writeFail")
        {
            context.AddError("前台写卡失败");
        }
        else if (hidWarning.Value == "HYDROPOWERCardConfirm")
        {
            btnSupply.Enabled = false;
            //记录写卡台账
            context.SPOpen();
            context.AddField("p_TYPE").Value = "INSERT";
            context.AddField("p_TRADEID").Value = hidResponseTradeId.Value;
            context.AddField("p_CARDTRADENO").Value = hiddentradeno.Value;
            context.AddField("p_TRADETYPECODE").Value = "9X";
            context.AddField("p_OPERCARDNO").Value = context.s_CardID;
            context.AddField("p_CARDNO").Value = hiddentxtCardno.Value;
            context.AddField("p_LMONEY").Value = hidTotalPayFee.Value;
            context.AddField("p_LOLDMONEY").Value = hiddencMoney.Value;
            context.AddField("p_TERMNO").Value = "112233445566";
            if (context.ExecuteSP("SP_PB_AddCardTrade"))
            {
                //#region for test
                //Deduct(sender, e);
                //return;
                //#endregion
                hidCardReaderToken.Value = cardReader.createToken(context);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript", "unchargeCardHYDROPOWER();", true);
            }
        }
        else if (hidWarning.Value == "HYDROPOWERAccountConfirm")
        {
            btnSupply.Enabled = false;
            Deduct(sender, e);
        }
    }

    protected void btnSupply_Click(object sender, EventArgs e)
    {
        supply_check();//提交前检查
        CheckExceptionRecord(hidItemCode.Value, hidAccountId.Value);
        if (context.hasError()) return;

        if (way_wallet.Checked)//缴费方式是电子钱包
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCard", "HYDROPOWER_CardPayCheck();", true);
        }
        else if (way_account.Checked)//专有账户付款
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCard", "HYDROPOWER_AccountPayCheck();", true);
        }
    }

    private void Deduct(object sender, EventArgs e)
    {
        bool isSpOk = false;
        string currentTimeStr = DateTime.Now.ToString("yyyyMMddHHmmssfff");

        if (way_wallet.Checked)
        {
            string p_ID = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);//18位
            context.SPOpen();
            context.AddField("p_ID").Value = p_ID;
            context.AddField("p_TRADEID").Value = hidResponseTradeId.Value;
            context.AddField("p_TRADETYPECODE").Value = "9X";
            context.AddField("p_CARDNO").Value = hiddentxtCardno.Value;
            context.AddField("p_ASN").Value = hiddenAsn.Value.Substring(4, 16);
            context.AddField("p_TERMNO").Value = "112233445566";
            context.AddField("p_CARDTYPECODE").Value = hiddenLabCardtype.Value;
            context.AddField("p_CARDMONEY").Value = hiddencMoney.Value;
            context.AddField("p_CARDTRADENO").Value = hiddentradeno.Value;
            context.AddField("p_ORIGSEQNO").Value = hidSeqNo.Value;
            context.AddField("p_ORIGDATE").Value = hidORIGDATE.Value;
            context.AddField("p_CHARGE_ITEM_TYPE").Value = hidItemCode.Value;
            context.AddField("p_CHARGE_TYPE").Value = way_wallet.Checked ? "0" : (way_account.Checked ? "1" : "");
            context.AddField("p_CUSTOMER_NO").Value = hidAccountId.Value;
            context.AddField("p_CUSTOMER_NAME").Value = hidUserName.Value;
            context.AddField("p_BILL_MONTH").Value = hidAccountMonth.Value;
            context.AddField("p_CONTRACT_NO").Value = hidContractNo.Value;
            context.AddField("p_TOTAL_AMOUNT").Value = hidTotalAmount.Value;//单位：元
            context.AddField("p_DELAY_AMOUNT").Value = hidDelayCharge.Value;//单位：元
            context.AddField("p_REAL_AMOUNT").Value = hidTotalPayFee.Value;//单位：分
            context.AddField("p_CHARGE_STATUS").Value = "2";//先传2.异常
            context.AddField("p_REQUEST_TIME").Value = currentTimeStr;
            context.AddField("p_REMARK").Value = "";
            context.AddField("p_TP_TRADE_ID").Value = "112233445566"+ p_ID;
            context.AddField("p_BALUNITNO").Value = HYDROPHelper.GetBALUNITNO(selItemCode.Text);//根据缴费类型确定结算单元
            isSpOk = context.ExecuteSP("SP_CS_HYDROPOWER_CARDPAY");
        }
        else if (way_account.Checked)
        {
            string p_ID = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);//18位
            context.SPOpen();
            context.AddField("p_ID").Value = p_ID;
            context.AddField("p_TRADEID").Value = hidResponseTradeId.Value;
            context.AddField("p_TRADETYPECODE").Value = "9X";
            context.AddField("p_CARDNO").Value = hiddentxtCardno.Value;
            context.AddField("p_ASN").Value = hiddenAsn.Value.Substring(4, 16);
            context.AddField("p_CARDTYPECODE").Value = hiddenLabCardtype.Value;
            context.AddField("p_CARDACCMONEY").Value = hidRelBalance.Value;
            context.AddField("p_CARDTRADENO").Value = hiddentradeno.Value;
            context.AddField("p_ORIGSEQNO").Value = hidSeqNo.Value;
            context.AddField("p_ORIGDATE").Value = hidORIGDATE.Value;
            context.AddField("p_CHARGE_ITEM_TYPE").Value = hidItemCode.Value;
            context.AddField("p_CHARGE_TYPE").Value = way_wallet.Checked ? "0" : (way_account.Checked ? "1" : "");
            context.AddField("p_CUSTOMER_NO").Value = hidAccountId.Value;
            context.AddField("p_CUSTOMER_NAME").Value = hidUserName.Value;
            context.AddField("p_BILL_MONTH").Value = hidAccountMonth.Value;
            context.AddField("p_CONTRACT_NO").Value = hidContractNo.Value;
            context.AddField("p_TOTAL_AMOUNT").Value = hidTotalAmount.Value;//单位：元
            context.AddField("p_DELAY_AMOUNT").Value = hidDelayCharge.Value;//单位：元
            context.AddField("p_REAL_AMOUNT").Value = hidTotalPayFee.Value;//单位：分
            context.AddField("p_CHARGE_STATUS").Value = "2";//先传2.异常
            context.AddField("p_REQUEST_TIME").Value = currentTimeStr;
            context.AddField("p_REMARK").Value = "";
            context.AddField("p_TP_TRADE_ID").Value = "112233445566" + p_ID;
            context.AddField("p_BALUNITNO").Value = HYDROPHelper.GetBALUNITNO(selItemCode.Text);//根据缴费类型确定结算单元
            context.AddField("p_TERMNO").Value = "112233445566";

            isSpOk = context.ExecuteSP("SP_CS_HYDROPOWER_ACCOUNTPay");
        }

        if (isSpOk)
        {
            //开始调用缴费接口
            Dictionary<string, string> postData = new Dictionary<string, string>();
            postData.Add("SeqNo",hidResponseTradeId.Value);
            postData.Add("Time", currentTimeStr);
            postData.Add("Timeout", "0");
            postData.Add("ItemCode", hidItemCode.Value);
            postData.Add("AccountId", hidAccountId.Value);

            postData.Add("UserName", hidUserName.Value);
            postData.Add("TotalAmount", hidTotalPayFee.Value);
            postData.Add("OrigDate", hidORIGDATE.Value);
            postData.Add("OrigSeqNo", hidSeqNo.Value);
            postData.Add("ContractNo", hidContractNo.Value);

            string data = HttpHelper.PostRequest(HttpHelper.TradeType.Pay, postData);
            if (!checkResponse(data))//检查返回报文是否正确
            {
                context.AddError("返回报文有误，请联系系统管理员！");
                return;
            }
            //解析xml报文
            JObject deserObject = (JObject)JsonConvert.DeserializeObject(data);
            string responseStatus = "";
            string errorMsg = ""; 
            foreach (JProperty itemProperty in deserObject.Properties())
            {
                string propertyName = itemProperty.Name;
                if (propertyName == "ResponseStatus")
                {
                    JObject statuJObject = (JObject) itemProperty.Value;
                    foreach (JProperty subItemJProperty in statuJObject.Properties())
                    {
                        if (subItemJProperty.Name == "ErrorCode")
                        {
                            responseStatus = subItemJProperty.Value.ToString();
                            break;
                        }
                    }
                }
                else if (propertyName == "Message")
                {
                    errorMsg = itemProperty.Value.ToString();
                }
            }

            if (responseStatus == "2" || responseStatus == "0")
            {
                context.AddError("缴费失败：" + errorMsg);
                return;
            }
            else if (responseStatus == "1")
            {
                context.AddMessage("缴费成功！");
                //自动打印凭证
                btnPrintPZ.Enabled = true;
                //如果是自动打印凭证，接着打印
                buildPingZhengContent();
                if (chkPingzheng.Checked)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "printWaterPingZheng1", "printInvoice();", true);
                }
                return;
            }
            else
            {
                context.AddError("未识别的状态码！");
                return;
            }
        }
    }

    private void buildPingZhengContent()
    {
        HYDROPHelper.PreparePingZheng(hidResponseTradeId.Value, ptnPingZheng, context);
    }

    private void supply_check()
    {
        if (string.IsNullOrEmpty(hidSeqNo.Value))
        {
            context.AddError("没有查询出记录，请先查询");
            return;
        }
        if (!way_wallet.Checked && !way_account.Checked)
        {
            context.AddError("无缴费方式信息");
            return;
        }
        if (string.IsNullOrEmpty(hiddentxtCardno.Value) || string.IsNullOrEmpty(hiddenAsn.Value))
        {
            context.AddError("没有读卡信息，请先读卡");
            return;
        }
        if (Convert.ToDouble(hidTotalPayFee.Value) < Convert.ToDouble(hidOrginTotalPayFee.Value))
        {
            context.AddError("缴费金额不正确，请重新操作！");
            return;
        }
        if (way_wallet.Checked)
        {
            if (Convert.ToDouble(hiddencMoney.Value) < Convert.ToDouble(hidTotalPayFee.Value))
            {
                context.AddError("卡内余额不足，请确认！");
                return;
            }
        }
        else if (way_account.Checked)
        {
            if (Convert.ToDouble(hidRelBalance.Value) < Convert.ToDouble(hidTotalPayFee.Value))
            {
                context.AddError("账户余额不足，请确认！");
                return;
            }
        }
    }

    protected void way_account_OnCheckedChanged(object sender, EventArgs e)
    {
        if (way_account.Checked)
        {
            account_label.Visible = true;
            account_pass.Visible = true;
            btnPassInputContent.Visible = true;
        }
        else
        {
            account_label.Visible = false;
            account_pass.Visible = false;
            btnPassInputContent.Visible = false;
        }
        initUserCardInfo();//防止切换缴费方式
    }

    private string GetSeq()
    {
        context.SPOpen();
        context.AddField("step").Value = 1;
        context.AddField("seq", "string", "Output", "16");
        context.ExecuteReader("SP_GetSeq");
        context.DBCommit();

        return "" + context.GetFieldValue("seq");
    }

    protected void selItemCode_OnSelectedIndexChanged(object sender, EventArgs e)
    {
        string itemCode = selItemCode.Text.Trim();
        feeContent.Visible = false;
        foreach (Control control in feeContent.Controls)
        {
            if (control is RadioButton)
            {
                ((RadioButton) control).Checked = false;
                ((RadioButton)control).Enabled = false;
            }
        }

        if (itemCode == "021" || itemCode == "101" || itemCode == "141" || itemCode == "121" || itemCode == "151" ||
            itemCode == "131" || itemCode == "161" || itemCode == "201")
        {
            feeContent.Visible = true;
        }
    }

    protected void selectFee_OnCheckedChanged(object sender, EventArgs e)
    {
        RadioButton radioButton = (RadioButton) sender;
        if (radioButton.Checked)
        {
            hidTotalPayFee.Value = (Convert.ToDouble(radioButton.Text)*100).ToString();
            txtTotalPayFee.Text= Convert.ToDouble(radioButton.Text).ToString("0.00");
        }
        else
        {
            hidTotalPayFee.Value = (Convert.ToDouble(hidOrginTotalPayFee.Value) * 100).ToString();
            txtTotalPayFee.Text = Convert.ToDouble(hidOrginTotalPayFee.Value).ToString("0.00");
        }
    }
}
