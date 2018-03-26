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
using Master;
using Common;
using TDO.CardManager;
using TDO.BusinessCode;
using TDO.ResourceManager;
using PDO.PersonalBusiness;
using TDO.UserManager;

public partial class ASP_PersonalBusiness_PB_CardToCardIn : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            cMoney.Attributes["readonly"] = "true";

            lvwloadInQuery.DataKeyNames =
                new string[] { "TRADEID", "OUTCARDNO", "MONEY", "OUTTIME", "OUTSTAFFNO", "OUTDEPTNO", "REMARK" };

            //设置GridView绑定的DataTable
            lvwloadInQuery.DataSource = new DataTable();
            lvwloadInQuery.DataBind();
            lvwloadInQuery.SelectedIndex = -1;
        }
    }

    protected void readInfo(string cardno, Label CustName, Label CustBirthday, Label Papertype, Label Paperno, Label Custsex,
                            Label Custphone, Label Custpost, Label Custaddr, Label txtEmail, Label Remark)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据


        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
        ddoTF_F_CUSTOMERRECIn.CARDNO = cardno;

        //UPDATE BY JIANGBB 2012-06-07解密
        DDOBase ddoBase = (DDOBase)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

        ddoBase = CommonHelper.AESDeEncrypt(ddoBase);
        TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)ddoBase;
        //TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

        if (ddoTF_F_CUSTOMERRECOut == null)
        {
            context.AddError("A001107112");
            return;
        }

        //从证件类型编码表(TD_M_PAPERTYPE)中读取数据


        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
        ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOMERRECOut.PAPERTYPECODE;

        TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);

        //给页面显示项赋值


        CustName.Text = ddoTF_F_CUSTOMERRECOut.CUSTNAME;

        if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "0")
            Custsex.Text = "男";
        else if (ddoTF_F_CUSTOMERRECOut.CUSTSEX == "1")
            Custsex.Text = "女";
        else Custsex.Text = "";
        //出生日期赋值


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
        //证件类型赋值


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

    }
    //读圈提卡
    protected void btnReadCardNO_Click(object sender, EventArgs e)
    {
        //记录读数据库标识
        hidisReadDBCard.Value = "0";

        hiddenOutCardno.Value = txtOutCardno.Text.Trim();
        //初始化卡卡转账圈提信息

        initCardToCardOutInfo();

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            OutPaperno.Text = CommonHelper.GetPaperNo(OutPaperno.Text);
            OutCustphone.Text = CommonHelper.GetCustPhone(OutCustphone.Text);
            OutCustaddr.Text = CommonHelper.GetCustAddress(OutCustaddr.Text);
        }
        //打印按钮不可用

        btnPrintPZ.Enabled = false;
    }
    //读数据库
    protected void btnReadDBCard_Click(object sender, EventArgs e)
    {
        //记录读数据库标识
        hidisReadDBCard.Value = "1";

        hiddenOutCardno.Value = txtOutCardno.Text.Trim();
        //初始化卡卡转账圈提信息

        initCardToCardOutInfo();

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            OutPaperno.Text = CommonHelper.GetPaperNo(OutPaperno.Text);
            OutCustphone.Text = CommonHelper.GetCustPhone(OutCustphone.Text);
            OutCustaddr.Text = CommonHelper.GetCustAddress(OutCustaddr.Text);
        }
        //打印按钮不可用

        btnPrintPZ.Enabled = false;
    }

    //初始化卡卡转账圈提信息

    protected void initCardToCardOutInfo()
    {
        //有效性校验

        if (!queryValidation()) return;

        //读取个人信息
        readInfo(hiddenOutCardno.Value, OutCustName, OutCustBirthday, OutPapertype, OutPaperno,
                  OutCustsex, OutCustphone, OutCustpost, OutCustaddr, txtOutEmail, OutRemark);
        //查询圈提记录
        queryCardToCardOutReg();

        btnLoadIn.Enabled = false;
    }

    protected Boolean queryValidation()
    {
        //校验圈提卡号
        if (txtOutCardno.Text.Trim() == "")
            context.AddError("A094570005：圈提卡号不能为空", txtOutCardno);
        else if (Validation.strLen(txtOutCardno.Text.Trim()) != 16)
            context.AddError("A094570006：圈提卡号必须为16位", txtOutCardno);
        else if (!Validation.isNum(txtOutCardno.Text.Trim()))
            context.AddError("A094570007：圈提卡号必须为数字", txtOutCardno);
        return !(context.hasError());

    }

    protected void queryCardToCardOutReg()
    {
        lvwloadInQuery.DataSource = CreateCardToCardOutDataSource();
        lvwloadInQuery.DataBind();
        lvwloadInQuery.SelectedIndex = -1;
    }

    public ICollection CreateCardToCardOutDataSource()
    {
        //查询待审批的业务
        DataTable data = SPHelper.callQuery("SP_PB_Query", context, "QueryCardToCardOutReg", hiddenOutCardno.Value);
        return new DataView(data);

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
            cMoney.Text = ((Convert.ToDouble(hiddencMoney.Value)) / 100).ToString("0.00");

            hidCardnoForCheck.Value = txtCardno.Text;
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

            hiddenState.Value = ddoTL_R_ICUSEROut.RESSTATECODE;
            TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEOut = (TD_M_RESOURCESTATETDO)tmTMTableModule.selByPK(context, ddoTD_M_RESOURCESTATEIn, typeof(TD_M_RESOURCESTATETDO), null, "TD_M_RESOURCESTATE", null);

            if (ddoTD_M_RESOURCESTATEOut == null)
                RESSTATE.Text = ddoTL_R_ICUSEROut.RESSTATECODE;
            else
                RESSTATE.Text = ddoTD_M_RESOURCESTATEOut.RESSTATE;

            //判断是否记名卡

            CommonHelper.readCardJiMingState(context, txtCardno.Text, hidIsJiMing);

            //圈存按钮可用
            btnLoadIn.Enabled = true;
            //读取客户资料
            readInfo(txtCardno.Text.Trim(), InCustName, InCustBirthday, InPapertype, InPaperno,
                     InCustsex, InCustphone, InCustpost, InCustaddr, txtInEmail, InRemark);
        }

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            InPaperno.Text = CommonHelper.GetPaperNo(InPaperno.Text);
            InCustphone.Text = CommonHelper.GetCustPhone(InCustphone.Text);
            InCustaddr.Text = CommonHelper.GetCustAddress(InCustaddr.Text);
        }

        //打印按钮不可用

        btnPrintPZ.Enabled = false;
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")
        {
            btnLoadIn.Enabled = true;
        }
        else if (hidWarning.Value == "CashChargeConfirm")
        {
            btnLoad_Click(sender, e);
            hidWarning.Value = "";
            return;
        }
        else if (hidWarning.Value == "writeSuccess")
        {
            SP_PB_updateCardTradePDO pdo = new SP_PB_updateCardTradePDO();
            pdo.CARDTRADENO = hiddentradeno.Value;
            pdo.TRADEID = hidoutTradeid.Value;
            bool ok = TMStorePModule.Excute(context, pdo);

            if (ok)
            {
                hidCardnoForCheck.Value = "";
                AddMessage("前台写卡成功");
            }
        }
        else if (hidWarning.Value == "writeFail")
        {
            context.AddError("前台写卡失败");
        }
        else if (hidWarning.Value == "submit")
        {
            btnReadDBCard_Click(sender, e);
        }
        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            //ScriptManager.RegisterStartupScript(
            //    this, this.GetType(), "writeCardScript",
            //    "printInvoice();", true);
            btnPrintPZ_Click(sender, e);
        }
        hidWarning.Value = "";
    }

    protected void btnLoad_Click(object sender, EventArgs e)
    {
        if (!loadinValidation()) return;

        //验证卡片是否是吴江B卡，如果是吴江B卡则不允许圈存
        bool outCardTypeOK = CommonHelper.allowCardtype(context, labOutCardNo.Text, "07");
        if (outCardTypeOK == false)
        {
            return;
        }
        //圈存提交时增加判断条件，原卡余额+本次圈存金额 <= 5000元。如超过5000元则提示：超过5000元限额无法圈存 add by youyue20171023
        if (Convert.ToDouble(cMoney.Text.ToString()) + Convert.ToDouble(SupplyFee.Text.ToString()) > 5000)
        {
            context.AddError("A001019113:超过5000元限额无法圈存");
            return;

        }
        //调用圈存存储过程
        SP_PB_CardToCardInPDO pdo = new SP_PB_CardToCardInPDO();
        if (hidisReadDBCard.Value.Equals("1"))
        {
            //如果是读数据库查询圈提记录

            TMTableModule tmTMTableModule = new TMTableModule();

            //读取审核员工信息
            TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            ddoTD_M_INSIDESTAFFIn.OPERCARDNO = hiddenCheck.Value;

            TD_M_INSIDESTAFFTDO[] ddoTD_M_INSIDESTAFFOut = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_CHECK", null);

            if (ddoTD_M_INSIDESTAFFOut == null || ddoTD_M_INSIDESTAFFOut.Length == 0)
            {
                context.AddError("A001010108");
                return;
            }
            pdo.CHECKSTAFFNO = ddoTD_M_INSIDESTAFFOut[0].STAFFNO;
            pdo.CHECKDEPARTNO = ddoTD_M_INSIDESTAFFOut[0].DEPARTNO;
        }
        else
        {
            pdo.CHECKSTAFFNO = context.s_UserID;
            pdo.CHECKDEPARTNO = context.s_DepartID;
        }
        pdo.ID = DealString.GetRecordID(hiddentradeno.Value, hiddenAsn.Value);
        pdo.OUTTRADEID = getDataKeys("TRADEID");
        pdo.INCARDNO = txtCardno.Text;
        pdo.OUTCARDNO = labOutCardNo.Text;
        pdo.TRADETYPECODE = "5B";
        pdo.CARDTRADENO = hiddentradeno.Value;
        pdo.SUPPLYMONEY = Convert.ToInt32(Convert.ToDecimal(SupplyFee.Text.Trim()) * 100);
        hidSupplyMoney.Value = "" + pdo.SUPPLYMONEY;
        pdo.CARDMONEY = Convert.ToInt32(Convert.ToDecimal(cMoney.Text.Trim()) * 100);
        pdo.OPERCARDNO = context.s_CardID;
        pdo.TERMNO = "112233445566";
        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (ok)
        {
            hidoutTradeid.Value = "" + ((SP_PB_CardToCardInPDO)pdoOut).TRADEID;
            hidSupplyMoney.Value = "" + ((SP_PB_CardToCardInPDO)pdoOut).SUPPLYMONEY;
            hiddenSupply.Value = (Convert.ToDecimal(hidSupplyMoney.Value) / (Convert.ToDecimal(100))).ToString("0.00");
            //AddMessage("M001002001");
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                "writeCardScript", "chargeCard();", true);

            btnPrintPZ.Enabled = true;

            //ASHelper.preparePingZheng(ptnPingZheng, txtCardno.Text, InCustName.Text, "卡卡转账圈存",
            //hiddenSupply.Value, "", "", InPaperno.Text,
            //Convert.ToString((pdo.CARDMONEY + pdo.SUPPLYMONEY) / 100.0), "", hiddenSupply.Value, context.s_UserID,
            //context.s_DepartName, InPapertype.Text, "0.00", "");

            context.DBOpen("Select");
            string sql = "select PREMONEY from tf_b_trade where TRADEID = '" + getDataKeys("TRADEID") + "'";
            DataTable dt = context.ExecuteReader(sql);
            hidOutCardMoney.Value = (Convert.ToDecimal(dt.Rows[0][0].ToString()) / 100).ToString("0.00");
            hidInCardMoney.Value = cMoney.Text.Trim();
            hidOutCardno.Value = labOutCardNo.Text;
            hidInCardno.Value = txtCardno.Text;

            btnLoadIn.Enabled = false;
            clearInfo();
        }
    }
    protected void btnPrintPZ_Click(object sender, EventArgs e)
    {
        string printhtml = PrintHelper.PrintCardToCardIn(context, hidoutTradeid.Value, context.s_DepartName, context.s_UserID, hidOutCardno.Value, hidInCardno.Value,
                                      hiddenSupply.Value, hidOutCardMoney.Value, hidInCardMoney.Value);

        printarea.InnerHtml = printhtml;
        //执行打印脚本
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", "printdiv('printarea');", true);
    }
    protected void clearInfo()
    {
        txtCardno.Text = "";
        labOutCardNo.Text = "";
        SupplyFee.Text = "";
        labOutTime.Text = "";
        labremark.Text = "";
        hidIsJiMing.Value = "";

        //重新初始化卡卡转账圈提信息

        initCardToCardOutInfo();
        lvwloadInQuery.SelectedIndex = -1;
    }
    protected Boolean loadinValidation()
    {
        if (labOutCardNo.Text == "" || labOutCardNo.Text == null)
            context.AddError("未选择圈提记录");

        return !(context.hasError());
    }
    protected void lvwloadInQuery_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件


            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwloadInQuery','Select$" + e.Row.RowIndex + "')");
        }
    }
    public void lvwloadInQuery_SelectedIndexChanged(object sender, EventArgs e)
    {
        labOutCardNo.Text = getDataKeys("OUTCARDNO");
        SupplyFee.Text = getDataKeys("MONEY");
        labOutTime.Text = getDataKeys("OUTTIME");
        labremark.Text = getDataKeys("REMARK");
    }
    public String getDataKeys(string keysname)
    {
        return lvwloadInQuery.DataKeys[lvwloadInQuery.SelectedIndex][keysname].ToString();
    }
    protected void lvwloadInQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header
            || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[0].Visible = false;
        }
    }
    protected void lvwloadInQuery_Page(object sender, GridViewPageEventArgs e)
    {
        lvwloadInQuery.PageIndex = e.NewPageIndex;
        queryCardToCardOutReg();
    }

}