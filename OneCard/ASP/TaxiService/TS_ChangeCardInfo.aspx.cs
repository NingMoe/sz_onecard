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
using PDO.TaxiService;
using TM;

public partial class ASP_TaxiService_TS_ChangeCardInfo : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化状态
            TSHelper.initInitState(selInitState);

            //正式综合测试时,设置生效
            if (!context.s_Debugging)
              txtCardNo.Attributes.Add("readonly", "true");

            //销毁或者启用
            TSHelper.initUseState(selUseState, false);

            if (!context.s_Debugging)
            {

                txtCardNoExt.Attributes.Add("readonly", "true");
                txtTaxiDriverNoExt.Attributes.Add("readonly", "true");
            }

        }

    }

 


    protected void btnWriteCard_Click(object sender, EventArgs e)
    {
        if (!WriteCardValidate()) return;

        hidCardNo.Value = txtCardNo.Text.Trim();
        hidCarNo.Value = txtCarNo.Text.Trim();
        hidStaffNo.Value = txtTaxiDriverNo.Text.Trim();
        hidState.Value = selInitState.SelectedValue;

        hidCarNo.Value = OperdStr("E" + txtCarNo.Text.Trim());
        //调用写卡的存储过程
        SP_TS_ChangeCardInfoPDO pdo = new SP_TS_ChangeCardInfoPDO();
        pdo.CALLINGSTAFFNO = txtTaxiDriverNo.Text.Trim();
        pdo.CARDNO = txtCardNo.Text.Trim();
        pdo.CARNO = txtCarNo.Text.Trim();
        pdo.strState = selInitState.SelectedValue;
        pdo.operCardNo = context.s_CardID;


        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            //写卡片信息
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardScript",
                       "newDriverCard();", true);
            //ClearTaxiInfo();
        }

    }
    // 确认对话框确认处理

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "writeSuccess")   // 写卡成功
        {
            AddMessage("M003107111");
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("A003100114");
        }

        hidWarning.Value = ""; // 清除警告信息
    }


    private Boolean WriteCardValidate()
    {
        //检查是否读取卡号
        if (txtCardNo.Text == "")
        {
            context.AddError("A003100032", txtCardNo);
            return false;
        }

        Validation valid = new Validation(context);
        //对司机工号进行非空、长度、数字检验

        bool b = valid.notEmpty(txtTaxiDriverNo, "A003100001");

        if (b && !Validation.isNum(txtTaxiDriverNo.Text.Trim()))
            context.AddError("A003100002", txtTaxiDriverNo);

        else if (b && Validation.strLen(txtTaxiDriverNo.Text.Trim()) != 6)
            context.AddError( "A003100003", txtTaxiDriverNo);

        // 车牌号
        b = valid.notEmpty(txtCarNo, "A003100006");

        if (b && !Validation.isCharNum(txtCarNo.Text.Trim()))
            context.AddError("A003100049", txtCarNo);

        else if ( b && Validation.strLen(txtCarNo.Text.Trim()) > 5)
        {
            context.AddError("A003100037", txtCarNo);
        }

        if(selInitState.SelectedValue == "")
            context.AddError("A003107001",selInitState);

        if (context.hasError())
            return false;
        else 
            return true;

    }


    private void ClearTaxiInfo()
    {
        txtTaxiDriverNo.Text = "";
        txtCardNo.Text = "";
        txtCarNo.Text = "";
        selInitState.SelectedValue = "";
    }


    private void ClearTaxiInfoExt()
    {
        txtCardNoExt.Text = "";
        txtTaxiDriverNoExt.Text = "";
        // selUseState.SelectedValue = "";
    }



    protected void btnWriteCardExt_Click(object sender, EventArgs e)
    {
        //对卡号,工号的校验
        if (txtTaxiDriverNoExt.Text.Trim() == "")
        {
            context.AddError("A003100032", txtTaxiDriverNoExt);
            return;
        }
        else if (txtCardNoExt.Text.Trim() == "")
        {
            context.AddError("A003100032", txtCardNoExt);
            return;
        }

        if (selUseState.SelectedValue == "")
        {
            context.AddError("A003107001", selUseState);
            return; 
        }

        hidUseStateExt.Value = selUseState.SelectedValue;

        hidCarNo.Value = OperdStr("E" + hidCarNoExt.Value);

        //写卡的启用(09)和销毁标志(FF)
        SP_TS_CardStartOrDestoryPDO pdo = new SP_TS_CardStartOrDestoryPDO();
        pdo.CALLINGSTAFFNO = txtTaxiDriverNoExt.Text.Trim();
        pdo.CARDNO = txtCardNoExt.Text.Trim();
        pdo.operCardNo = context.s_CardID;
        pdo.strUseState = selUseState.SelectedValue;

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            //写卡片信息
            ScriptManager.RegisterStartupScript(this, this.GetType(), "writeCardExtScript",
                       "endDriverCard();", true);
            //ClearTaxiInfoExt();
        }
    }

    private string OperdStr(string strOper)
    {
        //先把司机卡号转换为ASCII,再把ASCII转换为16进制,才能写卡
        string tmpCardNo = "";
        foreach (char c in strOper)
        {
            int tmp = c;
            //69 52 53 54 55 56
            tmpCardNo += String.Format("{0:x}", tmp);
        }
        return tmpCardNo;
    }




}
