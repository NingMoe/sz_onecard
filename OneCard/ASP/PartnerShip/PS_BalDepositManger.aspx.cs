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

public partial class ASP_PartnerShip_PS_BalDepositManger : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            initLoad();
            //显示列表
            showConGridView();
        }
    }
    protected void initLoad()
    {
        //初始化网点结算单元
        TMTableModule tmTMTableModule = new TMTableModule();

        //从网点结算单元编码表(TF_DEPT_BALUNIT)中读取数据，放入下拉列表中

        TF_DEPT_BALUNITTDO tdoTF_DEPT_BALUNITIn = new TF_DEPT_BALUNITTDO();
        TF_DEPT_BALUNITTDO[] tdoTF_DEPT_BALUNITOutArr = (TF_DEPT_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_DEPT_BALUNITIn, typeof(TF_DEPT_BALUNITTDO), null, "TF_DEPT_BALUNIT_NAME_DEPOSIT", null);

        ControlDeal.SelectBoxFill(selCalling.Items, tdoTF_DEPT_BALUNITOutArr, "DBALUNIT", "DBALUNITNO", true);
    }
    private void showConGridView()
    {
        //显示交易信息列表
        lvwPrepayQuery.DataSource = new DataTable();
        lvwPrepayQuery.DataBind();
        lvwPrepayQuery.SelectedIndex = -1;
    }
    protected void selCalling_Change(object sender, EventArgs e)
    {
        //查询结算单元信息
        if (selCalling.SelectedValue.Equals(""))
        {
            clearInfo();
        }
        else
        {
            //查询网点结算单元信息
            DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryBalUnitInfo", selCalling.SelectedValue);
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

                //提交按钮可用
                btnSupply.Enabled = true;

                //获取保证金余额
                getDepositMoney();                

                showConGridView();
            }
        }
    }
    protected void getDepositMoney()
    {
        //获取保证金余额
        //网点结算单元保证金账户表(TF_F_DEPTBAL_DEPOSIT)中读取数据
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_F_DEPTBAL_DEPOSITTDO tdoTF_F_DEPTBAL_DEPOSITIn = new TF_F_DEPTBAL_DEPOSITTDO();
        tdoTF_F_DEPTBAL_DEPOSITIn.DBALUNITNO = selCalling.SelectedValue;
        TF_F_DEPTBAL_DEPOSITTDO tdoTF_F_DEPTBAL_DEPOSITOut = (TF_F_DEPTBAL_DEPOSITTDO)tmTMTableModule.selByPK(context, tdoTF_F_DEPTBAL_DEPOSITIn, typeof(TF_F_DEPTBAL_DEPOSITTDO), null, "TF_F_DEPTBALUNIT_DEPOSIT", null);
        if (tdoTF_F_DEPTBAL_DEPOSITOut != null)
        {
            labDeposit.Text = ((tdoTF_F_DEPTBAL_DEPOSITOut.DEPOSIT) / 100.0).ToString("n");
            //获取可领卡价值额度，网点剩余卡价值
            DeptBalunitHelper.SetDeposit(context, selCalling.SelectedValue, labDeposit, labUsablevalue, labStockvalue);
            //labUsablevalue.Text = ((tdoTF_F_DEPTBAL_DEPOSITOut.USABLEVALUE) / 100.0).ToString("n");
            //labStockvalue.Text = ((tdoTF_F_DEPTBAL_DEPOSITOut.STOCKVALUE) / 100.0).ToString("n");
        }
        else
        {
            labDeposit.Text = "";
            labUsablevalue.Text = "";
            labStockvalue.Text = "";
            btnSupply.Enabled = false;
            context.AddMessage("未找到保证金账户信息");
        }
    }
    protected void clearInfo()
    {
        //清空结算单元信息
        labBalUnitNO.Text = "";
        labBalUnit.Text = "";
        labCreatTime.Text = "";
        labBank.Text = "";
        labBankAccNo.Text = "";
        labDeptType.Text = "";
        labPrepayWarnLine.Text = "";
        labPrepayLimitLine.Text = "";
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
        labDeposit.Text = "";
        labUsablevalue.Text = "";
        labStockvalue.Text = "";

        Income.Checked = true;
        txtDealMoney.Text = "";
        txtReMark.Text = "";

        //提交按钮不可用
        btnSupply.Enabled = false;

        //重置查询列表
        showConGridView();
    }
    protected void btnSupply_Click(object sender, EventArgs e)
    {
        if (!supplyValidation()) return;

        SP_PS_BalDepositMangerPDO pdo = new SP_PS_BalDepositMangerPDO();
        string funccode = "";
        if (Income.Checked == true)
            funccode = "INCOME";
        else if (Pay.Checked == true)        
            funccode = "PAY";        

        pdo.FUNCCODE = funccode;
        pdo.MONEY = Convert.ToInt32(Convert.ToDouble(txtDealMoney.Text.Trim()) * 100);
        pdo.CHMONEY = hidChineseNum.Value;
        pdo.REMARK = txtReMark.Text.Trim();
        pdo.DBALUNITNO = selCalling.SelectedValue;

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            //刷新列表
            selExamState.SelectedValue = "0";
            lvwPrepayQuery.DataSource = queryDepositWaitEaxm();
            lvwPrepayQuery.DataBind();
            string function = "";
            switch (funccode)
            {
                case "INCOME":
                    function = "收入";
                    break;
                case "PAY":
                    function = "支出";
                    break;
                default:
                    break;
            }
            //显示对应操作成功
            context.AddMessage(function + "操作成功");

            txtDealMoney.Text = "";
            txtReMark.Text = "";

            getDepositMoney();
        }
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!queryValidation()) return;

        ICollection dataView;

        switch (selExamState.SelectedValue)
        {
            case "0":
                //查询待审核保证金收支记录
                dataView = queryDepositWaitEaxm();
                break;
            case "1":
                //查询审核通过保证金收支记录
                dataView = queryDepositReg();
                break;
            case "2":
                //查询审核作废保证金收支记录
                dataView = queryDepositEaxmCancel();
                break;
            default:
                dataView = new DataView();//空
                break;
        }
        //没有查询出记录时,显示错误
        if (dataView.Count == 0)
        {
            showConGridView();
            context.AddError("没有查询出任何记录");
            return;
        }
        lvwPrepayQuery.DataSource = dataView;
        lvwPrepayQuery.DataBind();
    }
    //查询保证金收支记录
    private ICollection queryDepositReg()
    {
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryBalUnitDepositInfo", selCalling.SelectedValue);
        return new DataView(data);
    }
    //查询待审核保证金收支记录
    private ICollection queryDepositWaitEaxm()
    {
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryBalUnitDepositExamInfo", selCalling.SelectedValue);
        return new DataView(data);
    }
    //查询审核作废保证金收支记录
    private ICollection queryDepositEaxmCancel()
    {
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryBalUnitDepositCancelInfo", selCalling.SelectedValue);
        return new DataView(data);
    }
    //查询校验
    protected Boolean queryValidation()
    {
        if (selCalling.SelectedValue.Equals(""))
            context.AddError("A008905001：请选择网点结算单元", selCalling);
        return !(context.hasError());
    }
    //提交校验
    protected Boolean supplyValidation()
    {
        //校验是否选择了结算单元
        if (selCalling.SelectedValue.Equals(""))
            context.AddError("A008905001：请选择网点结算单元", selCalling);
        //对交易金额的校验
        if (txtDealMoney.Text.Trim() == "" || txtDealMoney.Text.Trim() == "0")
            context.AddError("A008905002：交易金额不能为0或空", txtDealMoney);
        else if (!Validation.isPosRealNum(txtDealMoney.Text.Trim()))
            context.AddError("A008905003:交易金额必须为正数", txtDealMoney);

        //对备注的校验
        if (txtReMark.Text.Trim() != "")
            if (Validation.strLen(txtReMark.Text.Trim()) > 50)
                context.AddError("A008905004：备注长度不能超过50位", txtReMark);

        return !(context.hasError());
    }
    protected void lvwPrepayQuery_Page(object sender, GridViewPageEventArgs e)
    {
        //分页显示事件
        lvwPrepayQuery.PageIndex = e.NewPageIndex;
        switch (selExamState.SelectedValue)
        {
            case "0":
                //查询待审核保证金收支记录
                lvwPrepayQuery.DataSource = queryDepositWaitEaxm();
                break;
            case "1":
                //查询审核通过保证金收支记录
                lvwPrepayQuery.DataSource = queryDepositReg();
                break;
            case "2":
                //查询审核作废保证金收支记录
                lvwPrepayQuery.DataSource = queryDepositEaxmCancel();
                break;
            default:
                break;
        }       
        lvwPrepayQuery.DataBind();
    }
}