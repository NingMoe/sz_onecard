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
using PDO.GroupCard;

public partial class ASP_GroupCard_GC_DepchgFee : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //设置GridView绑定的DataTable
            lvwQuery.DataSource = new DataTable();
            lvwQuery.DataBind();
            lvwQuery.SelectedIndex = -1;

            //指定GridView DataKeyNames
            lvwQuery.DataKeyNames = new string[] { "CARDNO", "ASN", "DEPOSIT", "CARDCOST","SELLTIME", "STAFFNAME" };
        }
    }

    public ICollection CreateQueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从卡资料表中读取数据
        TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
        string strSql = "SELECT a.CARDNO,a.ASN,a.DEPOSIT/100.0 DEPOSIT,a.CARDCOST/100.0 CARDCOST,a.SELLTIME,b.STAFFNAME";
        strSql += " FROM TF_F_CARDREC a,TD_M_INSIDESTAFF b" +
                    " WHERE a.CARDNO BETWEEN '"+txtFromCardNo.Text.Trim()+"' AND '"+txtToCardNo.Text.Trim()+"' AND b.STAFFNO = a.STAFFNO " ;

        ArrayList list = new ArrayList();

        strSql += DealString.ListToWhereStr(list);

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTF_F_CARDRECIn, null, strSql, 0);
        DataView dataView = new DataView(data);
        return dataView;
    }

    public void lvwQuery_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwQuery.PageIndex = e.NewPageIndex;
        lvwQuery.DataSource = CreateQueryDataSource();
        lvwQuery.DataBind();
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

        lvwQuery.DataSource = CreateQueryDataSource();
        lvwQuery.DataBind();

        btnDepChgFee.Enabled = true;
    }

    protected void btnDepChgFee_Click(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //检验卡费是否为0
        //TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
        //string strCost = " Select SUM(CARDCOST) From TF_F_CARDREC Where CARDNO BETWEEN '" + txtFromCardNo.Text.Trim() + "' AND '" + txtToCardNo.Text.Trim() + "'";
        //DataTable dataCost = tmTMTableModule.selByPKDataTable(context, ddoTF_F_CARDRECIn, null, strCost, 0);
        //if (Convert.ToDouble(dataCost.Rows[0][0]) != 0)
        //{
        //    context.AddError("A004112110");
        //    return;
        //}

        //存储过程赋值
        SP_GC_DepchgFeePDO pdo = new SP_GC_DepchgFeePDO();
        pdo.BeginCardNo = txtFromCardNo.Text.Trim();
        pdo.EndCardNo = txtToCardNo.Text.Trim();
        pdo.TRADETYPECODE = "92";

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M004112100");
            foreach (Control con in this.Page.Controls)
            {
                ClearControl(con);
            }
            lvwQuery.DataSource = new DataTable();
            lvwQuery.DataBind();
        }
    }
}
