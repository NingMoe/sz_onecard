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
using Master;
using Common;
using TM;
using TDO.PartnerShip;
using PDO.PartnerShip;

public partial class ASP_PartnerShip_PS_PrepayDepositExam : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //指定GridView DataKeyNames
            lvwExamQuery.DataKeyNames =
                new string[]{"ID","TRADETYPECODE","TRADETYPE","DBALUNITNO","DBALUNIT","CURRENTMONEY","CHINESEMONEY","STAFFNAME","OPERATETIME",  
               "REMARK"};
            //显示列表
            //showConGridView();
            initPrepayDepositExam();
        }
    }

    private void initPrepayDepositExam()
    {
        //查询待审批网点结算单元信息
        lvwExamQuery.DataSource = queryPrepayDepositExam();
        lvwExamQuery.DataBind();
        lvwExamQuery.SelectedIndex = -1;
    }
    public ICollection queryPrepayDepositExam()
    {
        //查询待审批的业务
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryPrepayDepositExam");
        return new DataView(data);
    }

    private void showConGridView()
    {
        //显示交易信息列表
        lvwExamQuery.DataSource = new DataTable();
        lvwExamQuery.DataBind();
        lvwExamQuery.SelectedIndex = -1;
    }
    protected void lvwExamQuery_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwExamQuery','Select$" + e.Row.RowIndex + "')");
        }
    }
    protected void lvwExamQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header
            || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[0].Visible = false;
            e.Row.Cells[1].Visible = false;
        }
        //修改日期和金额的格式
        ControlDeal.RowDataBound(e);
    }
    protected void lvwExamQuery_Page(object sender, GridViewPageEventArgs e)
    {
        //分页显示事件
        lvwExamQuery.PageIndex = e.NewPageIndex;
        lvwExamQuery.DataSource = queryPrepayDepositExam();
        lvwExamQuery.DataBind();
    }
    public void lvwExamQuery_SelectedIndexChanged(object sender, EventArgs e)
    {
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryBalUnitInfo", getDataKeys("DBALUNITNO"));
        if (data.Rows.Count != 0)
        {
            labBalUnitNO.Text = data.Rows[0]["DBALUNITNO"].ToString();
            labBalUnit.Text = data.Rows[0]["DBALUNIT"].ToString();
            labCreatTime.Text = Convert.ToDateTime(data.Rows[0]["CREATETIME"]).ToShortDateString();
            labBank.Text = data.Rows[0]["OPENBANK"].ToString();
            labBankAccNo.Text = data.Rows[0]["BANKACCNO"].ToString();
            labDeptType.Text = data.Rows[0]["DEPTTYPE"].ToString();
            labPrepayWarnLine.Text = Convert.ToDecimal(data.Rows[0]["PREPAYWARNLINE"]).ToString("n");
            labPrepayLimitLine.Text = Convert.ToDecimal(data.Rows[0]["PREPAYLIMITLINE"]).ToString("n");
            labBalCyclType.Text = data.Rows[0]["BALCYCLETYPECODE"].ToString();
            labBalInterval.Text = data.Rows[0]["BALINTERVAL"].ToString();
            labFinType.Text = data.Rows[0]["FINTYPECODE"].ToString();
            labFinCyclType.Text = data.Rows[0]["FINCYCLETYPECODE"].ToString();
            labFinCyclInterval.Text = data.Rows[0]["FININTERVAL"].ToString();
            labFinBank.Text = data.Rows[0]["OUTBANK"].ToString();
            labLinkMan.Text = data.Rows[0]["LINKMAN"].ToString();
            labPhone.Text = data.Rows[0]["UNITPHONE"].ToString();
            labAddress.Text = data.Rows[0]["UNITADD"].ToString();
            labEmail.Text = data.Rows[0]["UNITEMAIL"].ToString();
            labReMark.Text = data.Rows[0]["REMARK"].ToString();

            //通过和作废按钮可用
            btnPass.Enabled = true;
            btnCancel.Enabled = true;

            //获取预付款余额
            getPrepayMoney();

            //获取保证金余额
            getDepositMoney();     

        }
    }
    protected void getPrepayMoney()
    {
        //获取预付款余额
        //网点结算单元预付款账户表(TF_F_DEPTBAL_PREPAY)中读取数据 
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_F_DEPTBAL_PREPAYTDO tdoTF_F_DEPTBALUNIT_PREPAYIn = new TF_F_DEPTBAL_PREPAYTDO();
        tdoTF_F_DEPTBALUNIT_PREPAYIn.DBALUNITNO = getDataKeys("DBALUNITNO");
        TF_F_DEPTBAL_PREPAYTDO tdoTF_F_DEPTBALUNIT_PREPAYOut = (TF_F_DEPTBAL_PREPAYTDO)tmTMTableModule.selByPK(context, tdoTF_F_DEPTBALUNIT_PREPAYIn, typeof(TF_F_DEPTBAL_PREPAYTDO), null, "TF_F_DEPTBALUNIT_PREPAY", null);
        if (tdoTF_F_DEPTBALUNIT_PREPAYOut != null)
        {
            labPrepay.Text = ((tdoTF_F_DEPTBALUNIT_PREPAYOut.PREPAY) / 100.0).ToString("n");
        }
        else
        {
            labPrepayWarnLine.Text = "";
            labPrepayLimitLine.Text = "";
            labPrepay.Text = "";
            btnPass.Enabled = false;
            btnCancel.Enabled = false;
            context.AddMessage("未找到预付款账户信息");
        }
    }
    protected void getDepositMoney()
    {
        //获取保证金余额
        //网点结算单元保证金账户表(TF_F_DEPTBAL_DEPOSIT)中读取数据
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_F_DEPTBAL_DEPOSITTDO tdoTF_F_DEPTBAL_DEPOSITIn = new TF_F_DEPTBAL_DEPOSITTDO();
        tdoTF_F_DEPTBAL_DEPOSITIn.DBALUNITNO = getDataKeys("DBALUNITNO");
        TF_F_DEPTBAL_DEPOSITTDO tdoTF_F_DEPTBAL_DEPOSITOut = (TF_F_DEPTBAL_DEPOSITTDO)tmTMTableModule.selByPK(context, tdoTF_F_DEPTBAL_DEPOSITIn, typeof(TF_F_DEPTBAL_DEPOSITTDO), null, "TF_F_DEPTBALUNIT_DEPOSIT", null);
        if (tdoTF_F_DEPTBAL_DEPOSITOut != null)
        {
            labDeposit.Text = ((tdoTF_F_DEPTBAL_DEPOSITOut.DEPOSIT) / 100.0).ToString("n");
            //获取可领卡价值额度，网点剩余卡价值
            DeptBalunitHelper.SetDeposit(context, getDataKeys("DBALUNITNO"), labDeposit, labUsablevalue, labStockvalue);
        }
        else
        {
            labDeposit.Text = "";
            labUsablevalue.Text = "";
            labStockvalue.Text = "";
            btnPass.Enabled = false;
            btnCancel.Enabled = false;
            context.AddMessage("未找到保证金账户信息");
        }
    }
    public String getDataKeys(string keysname)
    {
        return lvwExamQuery.DataKeys[lvwExamQuery.SelectedIndex][keysname].ToString();
    }
    private Boolean isChoiceBal()
    {
        //检查是否选定要审批的结算单元信息
        if (lvwExamQuery.SelectedIndex == -1)
        {
            context.AddError("没有选择待审核的预付款保证金收支业务");
            return false;
        }
        return true;
    }
    protected void btnPass_Click(object sender, EventArgs e)
    {
        //是否选择了待审核信息
        if (!isChoiceBal()) return;

        //调用网点结算单元审批通过的存储过程
        context.SPOpen();
        context.AddField("P_ID").Value = getDataKeys("ID");
        context.AddField("P_TRADETYPECODE").Value = getDataKeys("TRADETYPECODE");
        context.AddField("P_DBALUNITNO").Value = getDataKeys("DBALUNITNO");
        context.AddField("P_MONEY").Value = Convert.ToInt32(Convert.ToDouble( getDataKeys("CURRENTMONEY")) * 100);
        bool ok = context.ExecuteSP("SP_PS_PreDeExam_Pass");

        if (ok)
        {
            AddMessage("审核通过成功");
            //清空
            ClearBalUnit();
            //更新列表
            initPrepayDepositExam();
        }
    }
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        //是否选择了待审核信息
        if (!isChoiceBal()) return;

        //调用网点结算单元审批通过的存储过程
        context.SPOpen();
        context.AddField("P_ID").Value = getDataKeys("ID");
        bool ok = context.ExecuteSP("SP_PS_PreDeExam_Cancel");

        if (ok)
        {
            AddMessage("审核作废成功");
            //清空
            ClearBalUnit();
            //更新列表
            initPrepayDepositExam();
        }
    }
    protected void ClearBalUnit()
    {
        //清空结算单元信息
        labBalUnitNO.Text = "";
        labBalUnit.Text = "";
        labCreatTime.Text = "";
        labBank.Text = "";
        labBankAccNo.Text = "";
        labDeptType.Text = "";
        
        labBalCyclType.Text = "";
        labBalInterval.Text = "";
        labFinType.Text = "";
        labFinCyclType.Text = "";
        labFinCyclInterval.Text = "";
        labFinBank.Text = "";

        labLinkMan.Text = "";
        labPhone.Text = "";
        labAddress.Text = "";
        labEmail.Text = "";
        labReMark.Text = "";

        labPrepay.Text = "";
        labPrepayWarnLine.Text = "";
        labPrepayLimitLine.Text = "";

        labDeposit.Text = "";
        labUsablevalue.Text = "";
        labStockvalue.Text = "";

        //通过和作废按钮可用
        btnPass.Enabled = false;
        btnCancel.Enabled = false;

        //重置选择列表
        lvwExamQuery.SelectedIndex = -1;
    }
}