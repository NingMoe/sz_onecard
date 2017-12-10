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
using TDO.ResourceManager;
using TDO.BalanceChannel;
using Common;

public partial class ASP_PersonalBusiness_PB_RefundQuery : Master.Master
{
 
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            //POS库存查询表头
            initPosList();
        }
    }

    //表头
    private void initPosList()
    {
        DataTable posData = new DataTable();
        DataView posDataView = new DataView(posData);

        gvResult.DataKeyNames = new string[] { "ID", "CardNo", "TradeDate", "backmoney", "bank", "bankaccno", "custname", "remark", "slope", "state", "purposetype" };
        gvResult.DataSource = posDataView;
        gvResult.DataBind();
    }




    protected void lvwPos_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwPos','Select$" + e.Row.RowIndex + "')");
        }
    }

    public void lvwPos_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnPosQuery_Click(sender, e);
    }

    protected void btnPosQuery_Click(object sender, EventArgs e)
    {
        //输入判断
        if (!ValidateForPosQuery())
            return;

        TMTableModule tmTMTableModule = new TMTableModule();
        TL_R_EQUATDO ddoTL_R_EQUATDOIn = new TL_R_EQUATDO();


        string strSql = "select t.ID,t.tradeid,CardNo,t.tradedate,b.bank,t.bankaccno, backmoney/100.0 backmoney,t.custname,t.remark ,t.backslope slope,t.purposetype," +
               " decode(t.state ,'1','待审核','2','审核通过','3','作废') state, " +
               " decode(t.purposetype ,'1','对公','2','对私') purpose " +
               " from  TF_B_REFUNDPL  t   inner join td_m_bank b on t.bankcode=b.bankcode ";

        ArrayList list = new ArrayList();
        if (txtCardNo.Text.Trim() != "")
            list.Add("t.CardNo = '" + txtCardNo.Text.Trim()+ "'");

        if (txtID.Text.Trim() != "")
            list.Add("t.ID = '" +txtID.Text.Trim() + "'");
        if (ddlState.SelectedValue != "")
        {
            list.Add("t.state = '" + ddlState.SelectedValue + "'");
        }
      

        list.Add("rownum<200");

        strSql += DealString.ListToWhereStr(list);

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTL_R_EQUATDOIn, null, strSql, 0);
        DataView dataView = new DataView(data);

        gvResult.DataSource = dataView;
        gvResult.DataBind();
    }


    //输入验证
    private bool ValidateForPosQuery()
    {
        //POS编号必须为数字、6位

        string strCardNo = txtCardNo.Text.Trim();
        if (strCardNo != "")
        {
            if (!Validation.isNum(strCardNo))
                context.AddError("卡号应为16位数字",txtCardNo);

            if (Validation.strLen(strCardNo) > 16)
                context.AddError("卡号应为16位数字", txtCardNo);
        }


        string strID = txtID.Text.Trim();
        if (strID != "")
        {
            if (!Validation.isNum(strID))
                context.AddError("充值ID应为18位数字", txtID);

            if (Validation.strLen(strID) > 18)
                context.AddError("充值ID应为18位数字", txtID);
        }


        if (context.hasError())
            return false;
        else
            return true;
    }

    protected void lvwPos_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string s = e.Row.Cells[15].Text;
            if (Validation.isPrice(s))
                e.Row.Cells[15].Text = (Convert.ToDouble(s) / 100).ToString("0.00");
            else
                e.Row.Cells[15].Text = "";
            
        }
    }

    private string GetSearchString(string str)
    {
        return str.Trim() + "%";
    }

}
