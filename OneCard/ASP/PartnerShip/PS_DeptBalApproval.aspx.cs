using System;
using System.Collections.Generic;
using System.Data;
using System.Collections;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TM;
using Common;
using TDO.PartnerShip;
using TDO.BalanceChannel;
using TDO.UserManager;
using PDO.PartnerShip;
using TDO.BalanceParameter;


public partial class ASP_PartnerShip_PS_DeptBalApproval : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            //指定GridView DataKeyNames
            lvwBalUnitsAppral.DataKeyNames =
                new string[]{"DTRADETYPECODE","TRADEID","REMARK","BIZTYPE","DBALUNITNO","DBALUNIT",  
               "DEPTTYPE","CREATETIME","OPENBANK","BANKACCNO","BALCYCLETYPE", "BALINTERVAL", "FINCYCLETYPE",
               "FININTERVAL","FINTYPE", "PREPAYWARNLINE", "PREPAYLIMITLINE", "FINBANK", "LINKMAN","UNITPHONE","UNITADD",
               "UNITEMAIL","STAFFNAME","OPERATETIME"};

            //查询待审批的结算单元信息
            InitBalUnitApral();           

            //设置当前处理佣金规则信息列表表头
            lvwBalComScheme.DataSource = new DataTable();
            lvwBalComScheme.DataBind();
            //lvwBalComScheme.SelectedIndex = -1;


            //设置已存在佣金规则信息列表表头

            lvwExistedComScheme.DataSource = new DataTable();
            lvwExistedComScheme.DataBind();
        }
    }


    public void lvwBalUnitsAppral_Page(Object sender, GridViewPageEventArgs e)
    {
        //分页
        lvwBalUnitsAppral.PageIndex = e.NewPageIndex;
        InitBalUnitApral();
        ClearBalUnit();

    }


    private void InitBalUnitApral()
    {
        //查询待审批网点结算单元信息
        lvwBalUnitsAppral.DataSource = CreateBalUnitAppDataSource();
        lvwBalUnitsAppral.DataBind();
        lvwBalUnitsAppral.SelectedIndex = -1;
    }


    public ICollection CreateBalUnitAppDataSource()
    {
        //查询待审批的业务
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryDeptBalApprovalInfo");
        return new DataView(data);

    }


    protected void lvwBalUnitsAppral_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwBalUnitsAppral','Select$" + e.Row.RowIndex + "')");
        }
    }

    public void lvwBalUnitsAppral_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择列表框一行记录后,显示结算单元信息

        //第一段
        labBalUnitNO.Text = getDataKeys("DBALUNITNO");
        labBalUnit.Text = getDataKeys("DBALUNIT");
        labBalType.Text = getDataKeys("DEPTTYPE");
        labCreateTime.Text = DateTime.Parse(getDataKeys("CREATETIME")).ToString("yyyy-MM-dd", null);
        labOpeStuff.Text = getDataKeys("STAFFNAME");
        labBank.Text = getDataKeys("OPENBANK");
        labBankAccNo.Text = getDataKeys("BANKACCNO");
        labFinBank.Text = getDataKeys("FINBANK");

        //第二段
        labFinType.Text = getDataKeys("FINTYPE");
        labBalCyclType.Text = getDataKeys("BALCYCLETYPE");
        labBalInterval.Text = getDataKeys("BALINTERVAL");
        labFinCyclType.Text = getDataKeys("FINCYCLETYPE");
        labFinCyclInterval.Text = getDataKeys("FININTERVAL");
        labPrepayWarnLine.Text = getDataKeys("PREPAYWARNLINE");
        labPrepayLimitLine.Text = getDataKeys("PREPAYLIMITLINE");
        labReMark.Text = getDataKeys("REMARK");

        //第三段
        labLinkMan.Text = getDataKeys("LINKMAN");
        labPhone.Text = getDataKeys("UNITPHONE");
        labAddress.Text = getDataKeys("UNITADD");
        labEmail.Text = getDataKeys("UNITEMAIL");

        //隐藏域
        hidTradeID.Value = getDataKeys("TRADEID");
        hidTradeTypeCode.Value = getDataKeys("DTRADETYPECODE");

        string tradeType = hidTradeTypeCode.Value;
        if (tradeType.Equals("01") || tradeType.Equals("02") || tradeType.Equals("03") ||
            tradeType.Equals("21") || tradeType.Equals("22") || tradeType.Equals("23"))
        {
            labBal.Text = "佣金方案[当前处理]";
            labBalExist.Text = "佣金方案[已有方案]";
            //查询当前佣金方案
            lvwBalComScheme.Visible = true;
            lvwBalRelationScheme.Visible = false;
            lvwBalComScheme.DataSource = CreateBalComSchemeDataSource();
            lvwBalComScheme.DataBind();

            //查询已有佣金方案
            lvwExistedComScheme.Visible = true;
            lvwExistedRelationScheme.Visible = false;
            lvwExistedComScheme.DataSource = ExistedBalComSchemeDataSource();
            lvwExistedComScheme.DataBind();

            //按钮可用
            btnPass.Enabled = true;
            btnCancel.Enabled = true;
        }
        else if (tradeType.Equals("11") || tradeType.Equals("12") || tradeType.Equals("13"))
        {
            labBal.Text = "结算单元网点关系[当前处理]";
            labBalExist.Text = "结算单元网点关系[已有方案]";
            //查询当前结算单元网点关系
            lvwBalComScheme.Visible = false;
            lvwBalRelationScheme.Visible = true;
            lvwBalRelationScheme.DataSource = CreateBalRelationSchemeDataSource();
            lvwBalRelationScheme.DataBind();

            //查询已有结算单元网点关系
            lvwExistedComScheme.Visible = false;
            lvwExistedRelationScheme.Visible = true;
            lvwExistedRelationScheme.DataSource = ExistedBalRelationSchemeDataSource();
            lvwExistedRelationScheme.DataBind();

            //按钮可用
            btnPass.Enabled = true;
            btnCancel.Enabled = true;
        }
    }


    public String getDataKeys(string keysname)
    {
        return lvwBalUnitsAppral.DataKeys[lvwBalUnitsAppral.SelectedIndex][keysname].ToString();
    }
    protected void lvwBalUnitsAppral_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header
            || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[0].Visible = false;
            e.Row.Cells[1].Visible = false;
            e.Row.Cells[2].Visible = false;
        }
    }

    public ICollection CreateBalComSchemeDataSource()
    {
        //查询该结算单元处理台帐中的佣金方案的信息
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryCurrentCom",hidTradeID.Value);

        DataView dataView = new DataView(data);
        return dataView;
    }
    public ICollection ExistedBalComSchemeDataSource()
    {
        //查询该结算单元已有的有效的佣金方案的信息
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryAlreadyCom", labBalUnitNO.Text.Trim());

        DataView dataView = new DataView(data);
        return dataView;
    }
    public ICollection CreateBalRelationSchemeDataSource()
    {
        //查询当前结算单元网点关系
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryCurrentRelation", hidTradeID.Value);

        DataView dataView = new DataView(data);
        return dataView;
    }
    public ICollection ExistedBalRelationSchemeDataSource()
    {
        //查询已有结算单元网点关系
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryAlreadyRelation", labBalUnitNO.Text.Trim());

        DataView dataView = new DataView(data);
        return dataView;
    }

    private Boolean isChoiceBal()
    {
        //检查是否选定要审批的结算单元信息
        if (lvwBalUnitsAppral.SelectedIndex == -1)
        {
            context.AddError("A008108001");
            return false;
        }
        return true;
    }


    protected void btnPass_Click(object sender, EventArgs e)
    {
        if (!isChoiceBal()) return;

        //调用网点结算单元审批通过的存储过程
        context.SPOpen();
        context.AddField("P_TRADEID").Value = hidTradeID.Value;
        context.AddField("P_TRADETYPECODE").Value = hidTradeTypeCode.Value;
        context.AddField("P_DBALUNITNO").Value = labBalUnitNO.Text.Trim();
        bool ok = context.ExecuteSP("SP_PS_DeptBalApp_Pass");

        if (ok)
        {
            AddMessage("M008108111");
            //清空
            ClearBalUnit();
            //更新列表
            InitBalUnitApral();
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        if (!isChoiceBal()) return;
        //调用结算单元作废的存储过程

        //调用网点结算单元审批作废的存储过程
        context.SPOpen();
        context.AddField("P_TRADEID").Value = hidTradeID.Value;
        bool ok = context.ExecuteSP("SP_PS_DeptBalApp_Cancel");

        if (ok)
        {
            AddMessage("M008108112");
            //清空
            ClearBalUnit();
            //更新列表
            InitBalUnitApral();
        }
    }

    private void ClearBalUnit()
    {
        //第一段
        labBalUnitNO.Text = "";
        labBalUnit.Text = "";
        labBalType.Text = "";
        labCreateTime.Text = "";
        labOpeStuff.Text = "";
        labBank.Text = "";
        labBankAccNo.Text = "";
        labFinBank.Text = "";

        //第二段
        labFinType.Text = "";
        labBalCyclType.Text = "";
        labBalInterval.Text = "";
        labFinCyclType.Text = "";
        labFinCyclInterval.Text = "";
        labPrepayWarnLine.Text = "";
        labPrepayLimitLine.Text = "";
        labReMark.Text = "";

        //第三段
        labLinkMan.Text = "";
        labPhone.Text = "";
        labAddress.Text = "";
        labEmail.Text = "";

        //隐藏域
        hidTradeID.Value = "";
        hidTradeTypeCode.Value = "";

        //还原标题
        labBal.Text = "佣金方案[当前处理]";
        labBalExist.Text = "佣金方案[已有方案]";
        
        lvwBalComScheme.Visible = true;
        lvwBalRelationScheme.Visible = false;
        lvwExistedComScheme.Visible = true;
        lvwExistedRelationScheme.Visible = false;
            
        lvwBalComScheme.DataSource = new DataTable();
        lvwBalComScheme.DataBind();
        
        lvwExistedComScheme.DataSource = new DataTable();
        lvwExistedComScheme.DataBind();

        lvwBalRelationScheme.DataSource = new DataTable();
        lvwBalRelationScheme.DataBind();
        
        lvwExistedRelationScheme.DataSource = new DataTable();
        lvwExistedRelationScheme.DataBind();

        //按钮可用
        btnPass.Enabled = false;
        btnCancel.Enabled = false;

        //重置选择列表
        lvwBalUnitsAppral.SelectedIndex = -1;
    }

    /// <summary>
    /// 已有佣金方案列表分页事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void lvwExistedComScheme_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwExistedComScheme.PageIndex = e.NewPageIndex;

        //查询已有佣金方案
        lvwExistedComScheme.DataSource = ExistedBalComSchemeDataSource();
        lvwExistedComScheme.DataBind();
    }
     /// <summary>
    /// 已有结算单元网点关系列表分页事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void lvwExistedRelationScheme_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwExistedRelationScheme.PageIndex = e.NewPageIndex;

        //查询已有佣金方案
        lvwExistedRelationScheme.DataSource = ExistedBalRelationSchemeDataSource();
        lvwExistedRelationScheme.DataBind();
    }

}
