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
using TDO.CardManager;
using TM;
using Common;
using System.IO;
using System.Text;
using Master;
using TDO.BalanceChannel;
using TDO.SupplyBalance;
using TDO.PersonalTrade;

// 退款记录批量录入


public partial class ASP_PersonalBusiness_PB_RefundInput : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            BackSlope.Items.Add(new ListItem("---请选择---", ""));
            BackSlope.Items.Add(new ListItem("100%", "0"));
            BackSlope.Items.Add(new ListItem("99.3%", "1"));

            //add by jiangbb 收款人账户类型

            selPurPoseType.Items.Add(new ListItem("---请选择---", ""));
            selPurPoseType.Items.Add(new ListItem("对公", "1"));
            selPurPoseType.Items.Add(new ListItem("对私", "2"));

            //initLoad(sender, e);
        }
    }


    protected void initLoad(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //初始化银行

        TD_M_BANKTDO ddoTD_M_BANKIn = new TD_M_BANKTDO();
        TD_M_BANKTDO[] ddoTD_M_BANKOutArr = (TD_M_BANKTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_BANKIn, typeof(TD_M_BANKTDO), "S008107211", "", null);

        ControlDeal.SelectBoxFill(selBank.Items, ddoTD_M_BANKOutArr, "BANK", "BANKCODE", true);

    }

    private Boolean QueryValidation()
    {
        //对充值ID进行非空,长度,数字检验

        if (SupplyId.Text == "")
            context.AddError("A001016102", SupplyId);
        else if (SupplyId.Text.Length != 18)
            context.AddError("A001016103", SupplyId);
        else if (!Validation.isCharNum(SupplyId.Text))
            context.AddError("A001016104", SupplyId);

        return !(context.hasError());
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {

        TMTableModule tmTMTableModule = new TMTableModule();

        //对充值ID进行非空,长度,数字检验

        if (!QueryValidation())
            return;

        //查询是否已做过退款

        TF_B_REFUNDTDO ddoTF_B_REFUNDIn = new TF_B_REFUNDTDO();
        string strID = " Select ID From TF_B_REFUND Where ID = '" + SupplyId.Text + "'";
        DataTable dataID = tmTMTableModule.selByPKDataTable(context, ddoTF_B_REFUNDIn, null, strID, 0);

        if (dataID.Rows.Count != 0)
        {
            context.AddError("A001016101");
            return;
        }

        //查询卡号,交易金额
        TQ_SUPPLY_RIGHTTDO ddoTQ_SUPPLY_RIGHTIn = new TQ_SUPPLY_RIGHTTDO();
        ddoTQ_SUPPLY_RIGHTIn.ID = SupplyId.Text;
        TQ_SUPPLY_RIGHTTDO ddoTQ_SUPPLY_RIGHTOut = (TQ_SUPPLY_RIGHTTDO)tmTMTableModule.selByPK(context, ddoTQ_SUPPLY_RIGHTIn, typeof(TQ_SUPPLY_RIGHTTDO), null, "TQ_SUPPLY_RIGHT", null);

        if (ddoTQ_SUPPLY_RIGHTOut == null)
        {
            context.AddError("A001016100");
            return;
        }

        txtCardno.Text = ddoTQ_SUPPLY_RIGHTOut.CARDNO;
        BackMoney.Text = ((Convert.ToDouble(ddoTQ_SUPPLY_RIGHTOut.TRADEMONEY)) / 100).ToString("0.00");
        chargeID.Text = SupplyId.Text;
        labSuppyDate.Text = ddoTQ_SUPPLY_RIGHTOut.TRADEDATE;

    }

    // 输入校验
    private void SubmitValidate()
    {
        Validation valid = new Validation(context);

        if (BackSlope.SelectedValue == "")
        {
            context.AddError("A008120121:请选择返还比例", BackSlope);
        }

        //对收款人账户类型做非空校验

        if (selPurPoseType.SelectedValue == "")
        {
            context.AddError("A008100020", selPurPoseType);
        }

        //对银行做非空检验

        if (selBank.SelectedValue == "")
            context.AddError("A001016108", selBank);

        //对用户姓名进行非空、长度检验

        if (txtCusname.Text.Trim() == "")
            context.AddError("A001001111", txtCusname);
        else if (Validation.strLen(txtCusname.Text.Trim()) > 50)
            context.AddError("A001001113", txtCusname);

        //对银行账户做非空,长度,数字检验

        if (BankAccNo.Text == "")
        {
            context.AddError("A001016105", BankAccNo);
        }
        else if (Validation.strLen(BankAccNo.Text) > 30)
        {
            context.AddError("A001016106", BankAccNo);
        }
        else if (!Validation.isNum(BankAccNo.Text))
        {
            context.AddError("A001016107", BankAccNo);
        }
    }

    // 提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 输入校验
        SubmitValidate();
        if (context.hasError()) return;

        // 调用批量退款存储过程
        context.SPOpen();
        context.AddField("p_ID").Value = chargeID.Text;
        context.AddField("p_CARDNO").Value = txtCardno.Text;
        context.AddField("p_TRADETYPECODE").Value = "91";
        context.AddField("p_TRADEDATE").Value = labSuppyDate.Text;
        context.AddField("p_PURPOSETYPE").Value = selPurPoseType.SelectedValue;
        context.AddField("p_BACKMONEY").Value = Convert.ToInt32(Convert.ToDouble(BackMoney.Text) * 100);
        context.AddField("P_BACKSLOPE").Value = BackSlope.SelectedValue;
        context.AddField("p_BANKCODE").Value = selBank.SelectedValue;
        context.AddField("p_BANKACCNO").Value = BankAccNo.Text.Trim();
        context.AddField("p_CUSTNAME").Value = txtCusname.Text.Trim();
        context.AddField("p_STATE").Value = chkApprove.Checked ? "0" : "1";
        context.AddField("p_TRADEID", "String", "output", "16", null);
        //return;
        bool ok = context.ExecuteSP("SP_PB_RefundInput");
        if (ok)
        {
            btnSubmit.Enabled = false;
            AddMessage("D004PR1001: 退款记录录入成功");
            foreach (Control con in this.Page.Controls)
            {
                ClearControl(con);
            }
        }

        GroupCardHelper.clearTempCustInfoTable(context);
    }

    // 可退 复选框 改变事件
    protected void chkApprove_CheckedChanged(object sender, EventArgs e)
    {
        if (chkApprove.Checked)
        {
            chkReject.Checked = false;
        }

        btnSubmit.Enabled = (chkApprove.Checked || chkReject.Checked);
    }

    // 待查 复选框 改变事件
    protected void chkReject_CheckedChanged(object sender, EventArgs e)
    {
        if (chkReject.Checked)
        {
            chkApprove.Checked = false;
        }
        btnSubmit.Enabled = (chkApprove.Checked || chkReject.Checked);
    }

    protected void ClearControl(Control control)
    {
        foreach (Control c in control.Controls)
        {
            if (c is Label)
            {
                ((Label)c).Text = "";
            }
            else if (c is TextBox)
            {
                ((TextBox)c).Text = "";
            }
            else if (c is CheckBox)
            {
                ((CheckBox)c).Checked = false;
            }
            else if (c is RadioButton)
            {
                ((RadioButton)c).Checked = false;
            }
            else if (c is DropDownList)
            {
                ((DropDownList)c).SelectedValue = "";
            }

            if (c.Controls.Count > 0)
            {
                ClearControl(c);
            }
        }
    }

    /// <summary>
    /// 根据输入的银行初始化银行下拉列表
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void txtBank_Changed(object sender, EventArgs e)
    {

        if (string.IsNullOrEmpty(txtBank.Text.Trim()))
        {
            return;
        }

        selBank.Items.Clear();

        context.DBOpen("Select");
        System.Text.StringBuilder sql = new System.Text.StringBuilder();

        sql.Append("SELECT BANK, BANKCODE FROM TD_M_BANK WHERE BANKNUMBER IS NOT NULL AND ");
        //模糊查询银行名称，并在列表中赋值
        string strBalname = txtBank.Text.Trim().Replace('\'', '\"');
        if (strBalname.Length != 0)
        {
            sql.Append(" BANK LIKE '%" + strBalname + "%'");
        }
        sql.Append("ORDER BY BANKCODE");

        System.Data.DataTable table = context.ExecuteReader(sql.ToString());
        GroupCardHelper.fill(selBank, table, true);
    }
}
