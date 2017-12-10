using System;
using System.Collections.Generic;
using System.Collections;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Master;
using Common;
using TM;
using TDO.PartnerShip;
using PDO.PartnerShip;

/***************************************************************
 * 功能名: 代理营业厅_代理点预付款录入
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/07/13    liuhe			初次开发
 * 
 ****************************************************************/
public partial class ASP_PartnerShip_PS_PrepayBalManger : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            #region 初始化营业厅ddl
            context.DBOpen("Select");
            context.AddField("DEPARTNO").Value = context.s_DepartID;
            string sql = @"SELECT A.DEPTTYPE,A.DBALUNITNO 
                        FROM TF_DEPT_BALUNIT A,TD_DEPTBAL_RELATION B 
                        WHERE  B.DBALUNITNO = A.DBALUNITNO 
                        AND A.USETAG = '1' AND B.USETAG = '1' 
                        AND B.DEPARTNO = :DEPARTNO";
            DataTable table = context.ExecuteReader(sql);
            if (table != null && table.Rows.Count > 0)
            {
                string deptType = table.Rows[0]["DEPTTYPE"].ToString(); //营业厅类型

                string dbalUnitNo = table.Rows[0]["DBALUNITNO"].ToString(); //结算单元编码

                if (deptType == "1") //如果是代理营业厅员工
                {
                    context.DBOpen("Select");
                    context.AddField("DBALUNITNO").Value = dbalUnitNo;
                    sql = @"SELECT DBALUNIT, DBALUNITNO  FROM   TF_DEPT_BALUNIT WHERE  USETAG = '1' AND DBALUNITNO = :DBALUNITNO";
                    table = context.ExecuteReader(sql);
                    GroupCardHelper.fill(selDept, table, false);
                }
            }
            else
            {
                context.AddMessage("非代理员工不能使用本功能");
            }
            #endregion 

            //根据ddl初始化结算单元信息
            selDept_Change(sender, e);

            //显示列表 
            showConGridView();
        }
    }

    #region 页面控件事件
    /// <summary>
    /// 查询按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!queryValidation()) return;

        ICollection dataView;

        switch (selExamState.SelectedValue)
        {
            case "0":
                //查询待审核预付款收支记录
                dataView = queryPrepayWaitEaxm();
                break;
            case "1":
                //查询审核通过预付款收支记录

                dataView = queryPrepayReg();
                break;
            case "2":
                //查询审核作废预付款收支记录

                dataView = queryPrepayEaxmCancel();
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
        ViewState["selectedValue"] = selExamState.SelectedValue;
        lvwPrepayQuery.DataSource = dataView;
        lvwPrepayQuery.DataBind();
    }

    /// <summary>
    /// 结算单元dropdownlist变更事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void selDept_Change(object sender, EventArgs e)
    {
        //查询结算单元信息
        if (selDept.SelectedValue.Equals(""))
        {
            clearInfo();
        }
        else
        {
            //查询网点结算单元信息
            DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryBalUnitInfo", selDept.SelectedValue);
            if (data.Rows.Count != 0)
            {
                labBalUnitNO.Text = data.Rows[0]["DBALUNITNO"].ToString();
                labBalUnit.Text = data.Rows[0]["DBALUNIT"].ToString();
                labCreatTime.Text = Convert.ToDateTime(data.Rows[0]["CREATETIME"]).ToShortDateString();
                labPrepayWarnLine.Text = Convert.ToDecimal(data.Rows[0]["PREPAYWARNLINE"]).ToString("n");
                labPrepayLimitLine.Text = Convert.ToDecimal(data.Rows[0]["PREPAYLIMITLINE"]).ToString("n");

                //提交按钮可用
                btnSupply.Enabled = true;

                getPrepayMoney();

                showConGridView();
            }
        }
    }

    /// <summary>
    /// 修改日期和金额的格式
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void lvwPrepayQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
    }

    /// <summary>
    /// gridview翻页事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void lvwPrepayQuery_Page(object sender, GridViewPageEventArgs e)
    {
        //分页显示事件
        lvwPrepayQuery.PageIndex = e.NewPageIndex;
        switch (selExamState.SelectedValue)
        {
            case "0":
                //查询待审核预付款收支记录
                lvwPrepayQuery.DataSource = queryPrepayWaitEaxm();
                break;
            case "1":
                //查询审核通过预付款收支记录

                lvwPrepayQuery.DataSource = queryPrepayReg();
                break;
            case "2":
                //查询审核作废预付款收支记录

                lvwPrepayQuery.DataSource = queryPrepayEaxmCancel();
                break;
            default:
                break;
        }
        lvwPrepayQuery.DataBind();
    }

    /// <summary>
    /// 导出excel
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (lvwPrepayQuery.Rows.Count > 0)
        {
            GridView gridView = new GridView();
            switch ((string)ViewState["selectedValue"])
            {
                case "0":
                    //查询待审核预付款收支记录
                    gridView.DataSource = queryPrepayWaitEaxm();
                    break;
                case "1":
                    //查询审核通过预付款收支记录

                    gridView.DataSource = queryPrepayReg();
                    break;
                case "2":
                    //查询审核作废预付款收支记录

                    gridView.DataSource = queryPrepayEaxmCancel();
                    break;
                default:
                    break;
            }
            gridView.DataBind();
            ExportGridView(gridView);
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }

    /// <summary>
    /// 提交按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSupply_Click(object sender, EventArgs e)
    {
        if (!supplyValidation()) return;

        string funccode = "";
        if (Income.Checked == true)
            funccode = "INCOME";
        else if (Pay.Checked == true)
        {
            //if(!checkPrepayMoney()) return;
            funccode = "PAY";
        }

        context.SPOpen();
        context.AddField("P_FUNCCODE").Value = funccode;
        context.AddField("P_MONEY", "Int32").Value = Convert.ToInt32(Convert.ToDouble(txtDealMoney.Text.Trim()) * 100);
        context.AddField("P_CHMONEY").Value = hidChineseNum.Value;
        context.AddField("P_REMARK").Value = txtReMark.Text.Trim();
        context.AddField("P_DBALUNITNO").Value = selDept.SelectedValue;
        context.AddField("P_FINDATE").Value = txtFindate.Text;
        context.AddField("P_FINTRADENO").Value = txtFinTradeno.Text.Trim();
        context.AddField("P_FINBANK").Value = txtFinBank.Text.Trim();
        context.AddField("P_USEWAY").Value = txtUseway.Text.Trim();

        bool ok = context.ExecuteSP("SP_PS_PrepayBalManger");

        if (ok)
        {
            //刷新列表
            selExamState.SelectedValue = "0";
            lvwPrepayQuery.DataSource = queryPrepayWaitEaxm();
            lvwPrepayQuery.DataBind();
            string function = "";
            switch (funccode)
            {
                case "INCOME":
                    function = "存入";
                    break;
                case "PAY":
                    function = "请求支出";
                    break;
                default:
                    break;
            }
            //显示对应操作成功
            context.AddMessage(function + "操作成功");

            txtDealMoney.Text = "";
            txtReMark.Text = "";
        }
    }

    #endregion

    #region 查询预付款记录
    //查询预付款收支记录
    private ICollection queryPrepayReg()
    {
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryBalUnitPrepayInfo", selDept.SelectedValue);
        return new DataView(data);
    }

    //查询待审核预付款收支记录
    private ICollection queryPrepayWaitEaxm()
    {
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryBalUnitPrepayExamInfo", selDept.SelectedValue);
        return new DataView(data);
    }

    //查询审核作废预付款收支记录
    private ICollection queryPrepayEaxmCancel()
    {
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryBalUnitPrepayCancelInfo", selDept.SelectedValue);
        return new DataView(data);
    }
    #endregion

    #region 校验
    //查询校验
    protected Boolean queryValidation()
    {
        if (selDept.SelectedValue.Equals(""))
            context.AddError("A008905001：请选择网点结算单元", selDept);
        return !(context.hasError());
    }

    //提交校验
    protected Boolean supplyValidation()
    {
        //校验是否选择了结算单元

        if (selDept.SelectedValue.Equals(""))
            context.AddError("A008909001：请选择网点结算单元", selDept);
        //对交易金额的校验
        if (txtDealMoney.Text.Trim() == "" || txtDealMoney.Text.Trim() == "0")
            context.AddError("A008909002：交易金额不能为0或空", txtDealMoney);
        else if (!Validation.isPosRealNum(txtDealMoney.Text.Trim()))
            context.AddError("A008909003:交易金额必须为正数", txtDealMoney);

        if (txtFindate.Text.Trim().Length == 0)
            context.AddError("A008909004：划款日期不能为空", txtFindate);

        if (txtFinBank.Text.Trim().Length == 0)
            context.AddError("A008909005：划款银行不能为空", txtFinBank);

        //对备注的校验
        if (txtReMark.Text.Trim() != "")
            if (Validation.strLen(txtReMark.Text.Trim()) > 100)
                context.AddError("A008909006：备注长度不能超过100个字符", txtReMark);

        if (txtUseway.Text.Trim() != "")
            if (Validation.strLen(txtUseway.Text.Trim()) > 100)
                context.AddError("A008909007：用途长度不能超过100个字符", txtUseway);

        return !(context.hasError());
    }
    #endregion

    /// <summary>
    /// 初始化GridView
    /// </summary>
    private void showConGridView()
    {
        //显示交易信息列表
        lvwPrepayQuery.DataSource = new DataTable();
        lvwPrepayQuery.DataBind();
        lvwPrepayQuery.SelectedIndex = -1;
    }

    /// <summary>
    /// 获取预付款余额
    /// </summary>
    protected void getPrepayMoney()
    {
        //网点结算单元预付款账户表(TF_F_DEPTBAL_PREPAY)中读取数据 
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_F_DEPTBAL_PREPAYTDO tdoTF_F_DEPTBALUNIT_PREPAYIn = new TF_F_DEPTBAL_PREPAYTDO();
        tdoTF_F_DEPTBALUNIT_PREPAYIn.DBALUNITNO = selDept.SelectedValue;
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
            btnSupply.Enabled = false;
            context.AddMessage("未找到预付款账户信息");
        }
    }

    /// <summary>
    /// 重置页面控件
    /// </summary>
    protected void clearInfo()
    {
        //清空结算单元信息
        labBalUnitNO.Text = "";
        labBalUnit.Text = "";
        labCreatTime.Text = "";
        labPrepayWarnLine.Text = "";
        labPrepayLimitLine.Text = "";
        labPrepay.Text = "";

        Income.Checked = true;
        txtDealMoney.Text = "";
        txtReMark.Text = "";

        //提交按钮不可用

        btnSupply.Enabled = false;

        //重置查询列表
        showConGridView();
    }
}