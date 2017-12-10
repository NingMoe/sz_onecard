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
using TDO.PartnerShip;
using PDO.PartnerShip;

public partial class ASP_PartnerShip_PS_GroupCustApproval : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化待审批的集团客户信息
            lvwGroupCustAppral.DataSource = CreateGroupCustAppDataSource();
            lvwGroupCustAppral.DataBind();
            lvwGroupCustAppral.SelectedIndex = -1;

            //指定GridView DataKeyNames
            lvwGroupCustAppral.DataKeyNames = new string[] { "TRADEID", "TRADETYPECODE", "USETAG_EXT", "SERMANAGERCODE", "OPERATESTAFFNO" };

           // context.DBOpen("Select");
           // context.ExecuteNonQuery("exec SP_PS_GroupCustApprovalTmp");

        }
    }




    public void lvwGroupCustAppral_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwGroupCustAppral.PageIndex = e.NewPageIndex;
        lvwGroupCustAppral.DataSource = CreateGroupCustAppDataSource();
        lvwGroupCustAppral.DataBind();
    }


    public ICollection CreateGroupCustAppDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从集团客户资料表(TD_GROUP_CUSTOMER)中读取数据
        TF_B_GROUP_CUSTOMERCHANGETDO tdoGROUP_CUSIn = new TF_B_GROUP_CUSTOMERCHANGETDO();

        //查询集团客户资料变更台帐信息(操作员工姓名,集团客户经理名)
        string strSql = " SELECT ass.TRADETYPECODE, (case when (ass.TRADETYPECODE  = '50') then '增加' when " +
                        " (ass.TRADETYPECODE  = '51') then '修改' when (ass.TRADETYPECODE = '52') then '取消' end) BIZTYPE," +
                        " (case when (ass.TRADETYPECODE  = '50' OR ass.TRADETYPECODE = '51') then '1' when " +
                        " (ass.TRADETYPECODE  = '52') then '0' end) USETAG_EXT," +
                        " ass.TRADEID, tgroup.CORPCODE, tgroup.CORPNAME, tgroup.CORPEMAIL, " +
                        " tgroup.LINKMAN,tgroup.CORPADD,tgroup.CORPPHONE, tgroup.REMARK," +
                        " tgroup.SERMANAGERCODE,tstuff.STAFFNAME SERMGR,instuff.STAFFNAME STAFF, " +
                        " ass.OPERATETIME,ass.OPERATESTAFFNO ";

        strSql += " FROM TD_M_INSIDESTAFF instuff, TF_B_ASSOCIATETRADE ass, ";
        strSql += " TF_B_GROUP_CUSTOMERCHANGE tgroup left join TD_M_INSIDESTAFF  tstuff ";
        strSql += " on tgroup.SERMANAGERCODE = tstuff.STAFFNO ";

        strSql += " WHERE instuff.STAFFNO = ass.OPERATESTAFFNO AND ass.TRADEID = tgroup.TRADEID AND ";
        strSql += " ass.STATECODE  = '1' ";

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoGROUP_CUSIn, null, strSql, 0);
        DataView dataView = new DataView(data);
        return dataView;

    }


    protected void lvwGroupCustAppral_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[1].Visible = false;
            e.Row.Cells[3].Visible = false;
            e.Row.Cells[4].Visible = false;
            e.Row.Cells[11].Visible = false;
            e.Row.Cells[14].Visible = false;
        }
    }

     
    protected void btnAppPass_Click(object sender, EventArgs e)
    {

        if (lvwGroupCustAppral.Rows.Count == 0)
        {
            context.AddError("A008112002"); 
            return;
        }

        //审批通过
        //首先清空临时表

        clearTempTable("TMP_GROUP_CUSTOMERCHKPAS");

        context.DBOpen("Insert");
        int count = 0;
        foreach (GridViewRow gvr in lvwGroupCustAppral.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkGroupCust");
            if (cb != null && cb.Checked)
            {
                 ++count;
                 string tradeid = gvr.Cells[1].Text.Trim();
                 string tradetypecode = gvr.Cells[3].Text.Trim();
                 string updatestaffno = gvr.Cells[14].Text.Trim();
                 context.ExecuteNonQuery("insert into TMP_GROUP_CUSTOMERCHKPAS "+
                     "(TRADEID, TRADETYPECODE, UPDATESTAFFNO) values('" + tradeid +
                     "','" + tradetypecode + "','" + updatestaffno + "')");
            }
        }
        context.DBCommit();

        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("A008112001");
            return;
        }

        //执行集团客户审批通过的存储过程
        SP_PS_GroupCustApprovalPassPDO pdo = new SP_PS_GroupCustApprovalPassPDO();
        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M008112111");
        }

        clearTempTable("TMP_GROUP_CUSTOMERCHKPAS");

        //刷新待审批的集团客户信息
        lvwGroupCustAppral.DataSource = CreateGroupCustAppDataSource();
        lvwGroupCustAppral.DataBind();


    }
    protected void btnAppCancel_Click(object sender, EventArgs e)
    {
        if (lvwGroupCustAppral.Rows.Count == 0)
        {
            context.AddError("A008112002");
            return;
        }

        //审批作废
        //首先清空临时表

        clearTempTable("TMP_GROUP_CUSTOMERCHKCEL");

        context.DBOpen("Insert");
        int count = 0;
        foreach (GridViewRow gvr in lvwGroupCustAppral.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkGroupCust");
            if (cb != null && cb.Checked)
            {
                ++count;
                String tradeid = gvr.Cells[1].Text;
                context.ExecuteNonQuery("insert into TMP_GROUP_CUSTOMERCHKCEL values('" + tradeid + "')");
            }
        }
        context.DBCommit();

        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("A008112001");
            return;
        }

        //执行集团客户审批作废的存储过程
        SP_PS_GroupCustApprovalCancelPDO pdo = new SP_PS_GroupCustApprovalCancelPDO();

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M008112112");
           
        }

        clearTempTable("TMP_GROUP_CUSTOMERCHKCEL");

        //刷新待审批的集团客户信息
       lvwGroupCustAppral.DataSource = CreateGroupCustAppDataSource();
       lvwGroupCustAppral.DataBind();
    

      


    }

    private void clearTempTable(String tablename)
    {
        //删除临时表数据
        context.DBOpen("Delete");
        context.ExecuteNonQuery(" delete from " + tablename );
        context.DBCommit();
    }




}
