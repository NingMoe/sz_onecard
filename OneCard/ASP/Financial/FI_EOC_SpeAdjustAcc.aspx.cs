using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TM;
using Master;
using TDO.UserManager;
using PDO.Financial;
/**********************************
 * 沉淀资金特殊调账
 * 2013-12-17
 * shil
 * 初次编写
 * 2014-9-13
 * jiangbb
 * 修改 增加备付金类型
 * ********************************/

public partial class ASP_Financial_FI_EOC_SpeAdjustAcc : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            //指定GridView DataKeyNames
            gvResult.DataKeyNames =
                new string[] { "ID", "STATTIME", "CATEGORY", "MONEY", "REMARK" };

            //设置GridView绑定的DataTable
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
            gvResult.SelectedIndex = -1;

            txtFromDate.Text = DateTime.Today.AddYears(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");

            txtStatDate.Text = DateTime.Today.ToString("yyyyMMdd");

            //初始化系统业务交易类型表
            PNHelper.initPaperTypeList(context, selTradeType, "QUERYPNTRADETYPE", "");

            selCallType_SelectedIndexChanged(sender, e);
        }
    }

    protected void selCallType_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (selCallType.SelectedValue == "1")
        {
            btBFGList.Visible = false;
            hidType.Value = "1";
        }
        else
        {
            btBFGList.Visible = true;
            hidType.Value = "2";
        }
    }

    private void queryEOCSpeAdjustAcc()
    {
        queryValidate();
        if (context.hasError()) return;

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        if (hidType.Value == "1")
        {
            pdo.funcCode = "queryEOCSpeAdjustAcc";
        }
        else if (hidType.Value == "2")
        {
            pdo.funcCode = "queryBFJTradeRecord";
        }
        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;
        pdo.var3 = ddlCategory.SelectedValue;

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        UserCardHelper.resetData(gvResult, data);

        gvResult.SelectedIndex = -1;
    }
    /// <summary>
    /// 查询按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        queryEOCSpeAdjustAcc();
    }

    // 查询输入校验处理
    private void queryValidate()
    {
        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtFromDate);
        bool b2 = Validation.isEmpty(txtToDate);
        DateTime? fromDate = null, toDate = null;
        if (b1 || b2)
        {
            context.AddError("开始日期和结束日期必须填写");
        }
        else
        {
            if (!b1)
            {
                fromDate = valid.beDate(txtFromDate, "开始日期范围起始值格式必须为yyyyMMdd");
            }
            if (!b2)
            {
                toDate = valid.beDate(txtToDate, "结束日期范围终止值格式必须为yyyyMMdd");
            }
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        }
    }

    // 查询输入校验处理
    private void addValidate()
    {
        //备付金业务 需要校验交易类型，支付类型编码，是否现金
        if (hidType.Value == "2")
        {
            //交易类型
            if (selTradeType.SelectedValue == "")
            {
                context.AddError("A094782300:交易类型不能为空", selTradeType);
            }

            //支付类型编码
            if (selBFJTradeTypeCode.SelectedValue == "")
            {
                context.AddError("A094782301:支付类型编码不能为空", selBFJTradeTypeCode);
            }

            //是否现金
            if (selISCash.SelectedValue == "")
            {
                context.AddError("A094782302:是否现金项不能为空", selISCash);
            }

            //备注
            if (txtRemark.Text == "")
            {
                context.AddError("A094782303:备注不能为空", txtRemark);
            }
        }

        //对日期校验

        if (string.IsNullOrEmpty(txtStatDate.Text))
        {
            context.AddError("A094570300:日期不能为空！", txtStatDate);
        }
        else
        {
            if (!Validation.isDate(txtStatDate.Text, "yyyyMMdd"))
            {
                context.AddError("A094570301:日期格式必须为yyyyMMdd！");
            }
        }

        //对收支类别校验

        if (selCategory.SelectedValue == "")
        {
            context.AddError("A094570302:收支类别不能为空！", selCategory);
        }

        //对金额进行校验

        if (string.IsNullOrEmpty(txtMoney.Text.Trim()))
        {
            context.AddError("A094570304：金额不能为空", txtMoney);
        }
        else
        {
            if (!Validation.isPriceEx(txtMoney.Text.Trim()))
            {
                context.AddError("A094570305：金额必须为数字,可保留两位小数", txtMoney);
            }
        }

        //备注
        if (!string.IsNullOrEmpty(txtRemark.Text.Trim()))
            if (Validation.strLen(txtRemark.Text.Trim()) > 50)
                context.AddError("A094570308:备注长度不能超过50位", txtRemark);
        if (context.hasError())
        {
            return;
        }
    }
    /// <summary>
    /// 增加按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        addValidate();
        if (context.hasError()) return;

        context.SPOpen();
        context.AddField("P_FUNCTION").Value = "ADD";
        context.AddField("p_DATE").Value = txtStatDate.Text.Trim();
        context.AddField("p_CateGory").Value = selCategory.SelectedValue;
        context.AddField("p_money").Value = Convert.ToInt64(Convert.ToDecimal(txtMoney.Text.Trim()) * 100);
        context.AddField("p_remark").Value = txtRemark.Text.Trim();
        context.AddField("p_ID").Value = "";
        context.AddField("p_TYPE").Value = hidType.Value;
        context.AddField("p_TRADETYPE").Value = selTradeType.SelectedValue;
        context.AddField("p_BFJTRADETYPECODE").Value = selBFJTradeTypeCode.SelectedValue;
        context.AddField("p_ISCASH").Value = selISCash.SelectedValue;
        context.AddField("p_ACCOUNT").Value = selISCash.SelectedValue;
        bool ok = context.ExecuteSP("SP_FI_EOCSpeAdjustAcc");
        if (ok)
        {
            context.AddMessage("增加" + hidType.Value == "1" ? "沉淀资金调账" : "备付金" + "记录成功！");

            queryEOCSpeAdjustAcc();

            txtStatDate.Text = DateTime.Today.ToString("yyyyMMdd");
            selCategory.SelectedValue = "";
            txtMoney.Text = "";
            txtRemark.Text = "";

            gvResult.SelectedIndex = -1;

            btnDel.Enabled = false;
        }
    }

    /// <summary>
    /// 删除按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDel_Click(object sender, EventArgs e)
    {
        //删除校验
        if (gvResult.SelectedIndex < 0)
        {
            context.AddError(":A094570256:未选中任何行");
        }

        if (context.hasError())
        {
            return;
        }

        context.SPOpen();
        context.AddField("P_FUNCTION").Value = "DELETE";
        context.AddField("p_DATE").Value = "";
        context.AddField("p_CateGory").Value = "";
        context.AddField("p_money").Value = 0;
        context.AddField("p_remark").Value = "";
        context.AddField("p_ID").Value = getDataKeys("ID");
        context.AddField("p_TYPE").Value = hidType.Value;
        context.AddField("p_TRADETYPE").Value = "";
        context.AddField("p_BFJTRADETYPECODE").Value = "";
        context.AddField("p_ISCASH").Value = "";
        context.AddField("p_ACCOUNT").Value = "";
        bool ok = context.ExecuteSP("SP_FI_EOCSpeAdjustAcc");
        if (ok)
        {
            context.AddMessage("删除" + hidType.Value == "1" ? "沉淀资金调账" : "备付金" + "记录成功！");

            queryEOCSpeAdjustAcc();

            txtStatDate.Text = DateTime.Today.ToString("yyyyMMdd");
            selCategory.SelectedValue = "";
            txtMoney.Text = "";
            txtRemark.Text = "";

            gvResult.SelectedIndex = -1;
            btnDel.Enabled = false;
        }
    }

    /// <summary>
    /// 注册行单击事件

    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    /// <summary>
    /// 选择数据行

    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        btnDel.Enabled = true;
    }
    public String getDataKeys(string keysname)
    {
        return gvResult.DataKeys[gvResult.SelectedIndex][keysname].ToString();
    }

    //private decimal totalmoney = 0;
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        //if (e.Row.RowType == DataControlRowType.DataRow && gvResult.ShowFooter)
        //{
        //    totalmoney += Convert.ToDecimal(GetTableCellValue(e.Row.Cells[3]));
        //}
        //else if (e.Row.RowType == DataControlRowType.Footer)
        //{
        //    e.Row.Cells[1].Text = "合计";
        //    e.Row.Cells[3].Text = totalmoney.ToString("n");

        //    e.Row.Cells[1].Attributes.Add("Style", "font-weight: bold;");
        //}

        ControlDeal.RowDataBound(e);
    }

    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }
}