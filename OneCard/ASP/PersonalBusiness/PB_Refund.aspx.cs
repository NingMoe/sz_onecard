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
using TDO.BalanceChannel;
using TM;
using TDO.PersonalTrade;
using TDO.SupplyBalance;
using PDO.PersonalBusiness;
using TDO.PartnerShip;

public partial class ASP_PersonalBusiness_PB_Refund : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            initLoad(sender, e);
        }
    }

    protected void initLoad(object sender, EventArgs e)
    {
        //初始化网点结算单元

        TMTableModule tmTMTableModule = new TMTableModule();

        //从网点结算单元编码表(TF_DEPT_BALUNIT)中读取数据，放入下拉列表中


        TF_DEPT_BALUNITTDO tdoTF_DEPT_BALUNITIn = new TF_DEPT_BALUNITTDO();
        TF_DEPT_BALUNITTDO[] tdoTF_DEPT_BALUNITOutArr = (TF_DEPT_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_DEPT_BALUNITIn, typeof(TF_DEPT_BALUNITTDO), null, "TF_DEPT_BALUNIT_NAME", null);

        ControlDeal.SelectBoxFill(selDeptBalunit.Items, tdoTF_DEPT_BALUNITOutArr, "DBALUNIT", "DBALUNITNO", true);

        btnRefund.Enabled = false;
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

        //页面赋值
        txtCardno.Text = ddoTQ_SUPPLY_RIGHTOut.CARDNO;
        BackMoney.Text = ((Convert.ToDouble(ddoTQ_SUPPLY_RIGHTOut.TRADEMONEY)) / 100).ToString("0.00");
        chargeID.Text = SupplyId.Text;

        btnRefund.Enabled = true;
        hidBalunitno.Value = ddoTQ_SUPPLY_RIGHTOut.BALUNITNO;//充值记录所对应的结算单元 add by youyue20160701
    }
    
    private Boolean RefundValidation()
    {
        //对代理商户做非空校验
        if (selDeptBalunit.SelectedValue == "")
        {
            context.AddError("A009477001:请选择代理商户",selDeptBalunit);   
        }
        if (selDeptBalunit.SelectedValue != hidBalunitno.Value)
        {
            context.AddError("A009477002:退款所选代理商户结算单元需与充值记录所对应的结算单元匹配", selDeptBalunit);
        }

        return !(context.hasError());
    }

    protected void btnRefund_Click(object sender, EventArgs e)
    {
        //对银行,银行账户和用户姓名进行检验

        if (!RefundValidation())
        {
            return;
        }

        TMTableModule tmTMTableModule = new TMTableModule();

        context.SPOpen();
        context.AddField("p_ID").Value = chargeID.Text.Trim();
        context.AddField("p_CARDNO").Value = txtCardno.Text;
        context.AddField("p_TRADETYPECODE").Value = "91";
        context.AddField("p_BACKMONEY").Value = Convert.ToInt32(Convert.ToDouble(BackMoney.Text) * 100);
        context.AddField("p_DBalunitNo").Value = selDeptBalunit.SelectedValue;
        context.AddField("p_TRADEID", "string", "output", "16");

        bool ok = context.ExecuteSP("SP_PB_Refund_Dept");

        if (ok)
        {
            AddMessage("M001016100");
            foreach (Control con in this.Page.Controls)
            {
                ClearControl(con);
            }
            initLoad(sender, e);
        }
    }
}
