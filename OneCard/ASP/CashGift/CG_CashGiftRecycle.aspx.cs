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
using TDO.ResourceManager;
using TDO.UserManager;

public partial class ASP_CashGift_CG_CashGiftRecycle : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 测试模式下卡号可以输入
        if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

        // 设置可读属性
        setReadOnly(txtCardBalance, txtStartDate, txtEndDate, txtCardState, txtWallet2);
    }
    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        // 读取卡片类型
        readCardType(txtCardNo.Text, labCardType);

        // 读取卡片状态
        ASHelper.readCardState(context, txtCardNo.Text, txtCardState);

        // 读取客户信息
        readCustInfo(txtCardNo.Text,
            txtCustName, txtCustBirth,
            selPaperType, txtPaperNo,
            selCustSex, txtCustPhone,
            txtCustPost, txtCustAddr, txtEmail, txtRemark, true);

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtPaperNo.Text = CommonHelper.GetPaperNo(txtPaperNo.Text);
            txtCustPhone.Text = CommonHelper.GetCustPhone(txtCustPhone.Text);
            txtCustAddr.Text = CommonHelper.GetCustAddress(txtCustAddr.Text);
        }

        // checkCashGiftAccountInfo(txtCardNo.Text);

        // 读取其他信息
        DataTable data = SPHelper.callQuery("SP_CG_Query", context, "QryGashInfo", txtCardNo.Text);
        if (data != null && data.Rows.Count > 0)
        {
            labDbStartDAte.Text = "" + data.Rows[0].ItemArray[0];
            labDbEndDate.Text = "" + data.Rows[0].ItemArray[1];
            labDbMoney.Text = ((Decimal)data.Rows[0].ItemArray[2]).ToString("n");
            labDbSaleMoney.Text = ((Decimal)data.Rows[0].ItemArray[3]).ToString("n");
        }
        else
        {
            labDbStartDAte.Text = "";
            labDbEndDate.Text = "";
            labDbMoney.Text = "";
            labDbSaleMoney.Text = "";
        }

        data = SPHelper.callQuery("SP_CG_Query", context, "QryStateType", txtCardNo.Text);
        if (data != null && data.Rows.Count > 0)
        {
            //if ((string)data.Rows[0].ItemArray[0] == "04")
            //{
            //    context.AddError("卡片已经处于回收状态");
            //}
            if ((string)data.Rows[0].ItemArray[1] != "05")
            {
                context.AddError("卡片不是利金卡");
            }
        }


        btnSubmit.Enabled = !context.hasError();
    }


    // 确认对话框确认处理
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")    // 是否继续
        {
            btnSubmit.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess") // 写卡成功
        {
            recycleCashGiftCard();

            clearCustInfo(txtCardNo, txtCustName, txtCustBirth, selPaperType, txtPaperNo,
              selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("前台写卡失败");
        }


        hidWarning.Value = ""; // 清除警告信息
    }

    private void recycleCashGiftCard()
    {
        context.DBOpen("StorePro");

        context.AddField("p_cardNo").Value = txtCardNo.Text;
        context.AddField("p_wallet1").Value = (int)(Convert.ToDecimal(txtCardBalance.Text) * 100);
        context.AddField("p_wallet2").Value = (int)(Convert.ToDecimal(txtWallet2.Text == "NaN" ? "0.00" : txtWallet2.Text) * 100);
        context.AddField("p_startDate").Value = txtStartDate.Text;
        context.AddField("p_endDate").Value = txtEndDate.Text;

        context.AddField("p_ID").Value = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        context.AddField("p_cardTradeNo").Value = hidTradeNo.Value;
        context.AddField("p_asn").Value = hidAsn.Value.Substring(4, 16);

        bool ok = context.ExecuteSP("SP_CG_Recycle");

        if (ok)
        {
            AddMessage("利金卡回收成功");
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        TM.TMTableModule tmTMTableModule = new TM.TMTableModule();
        TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
        ddoTL_R_ICUSERIn.CARDNO = txtCardNo.Text;

        TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);

        if (ddoTL_R_ICUSEROut == null)
        {
            context.AddError("A001001101");
            return;
        }

        if (ddoTL_R_ICUSEROut.RESSTATECODE == "04")
        {
            TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            ddoTD_M_INSIDESTAFFIn.STAFFNO = ddoTL_R_ICUSEROut.ASSIGNEDSTAFFNO;
            TD_M_INSIDESTAFFTDO ddoTD_M_INSIDESTAFFOut = (TD_M_INSIDESTAFFTDO)tmTMTableModule.selByPK(context, ddoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_BY_STAFFNO", null);

            TD_M_INSIDEDEPARTTDO ddoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
            ddoTD_M_INSIDEDEPARTIn.DEPARTNO = ddoTL_R_ICUSEROut.ASSIGNEDDEPARTID;
            TD_M_INSIDEDEPARTTDO ddoTD_M_INSIDEDEPARTOut = (TD_M_INSIDEDEPARTTDO)tmTMTableModule.selByPK(context, ddoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, "TD_M_INSIDEDEPARTNO", null);


            context.AddError("卡片已经处于回收状态,回收部门:" + ddoTD_M_INSIDEDEPARTOut.DEPARTNAME + ",回收员工：" + ddoTD_M_INSIDESTAFFOut.STAFFNAME);
            return;
        }

        if (ddoTL_R_ICUSEROut.RESSTATECODE != "06")
        {
            context.AddError("不是售出状态的卡不能回收");
            return;
        }

        if (Convert.ToDecimal(this.labDbMoney.Text) - Convert.ToDecimal(this.txtCardBalance.Text) - Convert.ToDecimal(this.txtWallet2.Text) != 0)
        {
            context.AddError("账户不平或回收间隔时间未到");
            return;
        }



        string writeCardScript = "endCashGiftCard('"
                + DateTime.Now.AddDays(-1).ToString("yyyyMMdd")
                + "', " + (decimal)(ddoTL_R_ICUSEROut.CARDPRICE)
                + ");";

        btnSubmit.Enabled = false;
        ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",writeCardScript, true);
    }
}
