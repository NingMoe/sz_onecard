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
using PDO.UserCard;
using TM;

public partial class ASP_UserCard_UC_DepositChange : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        //设置GridView绑定的DataTable
        UserCardHelper.resetData(lvwQuery, null);
    }
    private bool SubmitValidate()
    {
        Validation valid = new Validation(context);
        long fromCard = 0, toCard = 0;

        //对起始卡号进行非空、长度、数字检验

        bool b = valid.notEmpty(txtFromCardNo, "A004112100");
        if (b) b = valid.fixedLength(txtFromCardNo, 16, "A004112101");
        if (b) fromCard = valid.beNumber(txtFromCardNo, "A004112102");

        //对终止卡号进行非空、长度、数字检验

        b = valid.notEmpty(txtToCardNo, "A004112103");
        if (b) b = valid.fixedLength(txtToCardNo, 16, "A004112104");
        if (b) toCard = valid.beNumber(txtToCardNo, "A004112105");

        // 0 <= 终止卡号-起始卡号 <= 10000
        if (fromCard > 0 && toCard > 0)
        {
            long quantity = toCard - fromCard;
            b = valid.check(quantity >= 0, "A004112106");
            if (b) valid.check(quantity <= 10000, "A004112107");
        }
        return !context.hasError();
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //对起讫卡号进行检验

        if (!SubmitValidate())
            return;

        UserCardHelper.resetData(lvwQuery, null);
        btnQueryImpl();

        btnChange.Enabled = true;
    }
    
    public void lvwQuery_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwQuery.PageIndex = e.NewPageIndex;
        btnQueryImpl();
       
    }

    protected void btnQueryImpl()
    {
        DataTable data = SPHelper.callPBQuery(context, "QueryDepositChange",
                txtFromCardNo.Text, txtToCardNo.Text);
        UserCardHelper.resetData(lvwQuery, data);
    }

    protected void lvwQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
    }
    private bool PriceValidate()
    {
        UserCardHelper.validatePrice(context, txtCardprice, "A002P01009: 卡片单价不能为空", "A002P01010: 卡片单价必须是10.2的格式");

        return !context.hasError();
    }
    protected void btnChange_Click(object sender, EventArgs e)
    {
        //对卡片单价进行检验
        if (!PriceValidate())
            return;

        TMTableModule tmTMTableModule = new TMTableModule();

        SP_UC_DepositChangePDO pdo = new SP_UC_DepositChangePDO();
        pdo.fromCardNo = txtFromCardNo.Text;
        pdo.toCardNo = txtToCardNo.Text;
        pdo.unitPrice = Convert.ToInt32(Convert.ToDecimal(txtCardprice.Text) * 100);

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M002P03B00");
            foreach (Control con in this.Page.Controls)
            {
                ClearControl(con);
            }
            lvwQuery.DataSource = new DataTable();
            lvwQuery.DataBind();
        }
    }
}
