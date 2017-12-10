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
using TDO.BalanceChannel;
using Common;
using TDO.ConsumeBalance;
using Master;
using TM;

public partial class ASP_SpecialDeal_SD_ConsumeErrorInfoRecycle : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        hidGardenRec.Value = Request.Params["GardenRec"];

        //显示异常消费信息空列表表头
        showNonDataGridView(); 

        //初始化行业名称
        if (hidGardenRec.Value == "RelaxRec") // 休闲回收
        {
            labTitle.Text = "异常休闲回收";
            gvResult.Width = 1500;

            selCalling.Enabled = false;
            selCorp.Enabled = false;
            ddlTradeType.Enabled = false;

            labUnitName.Text = "结算单元";
            SPHelper.fill12DDL(context, selDepart, true, "SP_SD_Query", "XXBalUnitList");

            //初始化错误原因
            //SPHelper.fill12DDL(context, selErrorReasonCode, true, "SP_SD_Query", "XXErrReasonCode");
            SPHelper.fillCoding(context, selErrorReasonCode, true, "CATE_SD_XXERR");
        }
        else
        {
            labTitle.Text = "异常消费回收";
            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
            TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), "S008100211", "TD_M_CALLINGNO", null);

            ControlDeal.SelectBoxFillWithCode(selCalling.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);

            ddlTradeType.Items.Add(new ListItem("---请选择---", ""));
            ddlTradeType.Items.Add(new ListItem("05:普通消费", "05"));
            ddlTradeType.Items.Add(new ListItem("06:押金消费", "06"));
  
            //初始化错误原因
            //SPHelper.fill12DDL(context, selErrorReasonCode, true, "SP_SD_Query", "ErrReasonCode");
            SPHelper.fillCoding(context, selErrorReasonCode, true, "CATE_SD_ERR");
        }

        // 人工处理状态
        selRecyState.Items.Add(new ListItem("0:未处理", "0"));
        selRecyState.Items.Add(new ListItem("2:已回收", "2"));
        selRecyState.Items.Add(new ListItem("3:已作废", "3"));

        txtDealDate.Text = DateTime.Today.ToString("yyyy-MM");
    }

    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        //分页事件 
        gvResult.PageIndex = e.NewPageIndex;

        btnQuery_Click(sender, e);
    }

    protected void CheckAll(object sender, EventArgs e)
    {
        //全选异常信息记录        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            if (!gvr.Cells[0].Enabled) continue;
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }

    private void RecordIntoTmp()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON");
        context.DBCommit();

        //回收记录入临时表
        context.DBOpen("Insert");
        int count = 0;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                context.ExecuteNonQuery("insert into TMP_COMMON(f0) values('"
                  + gvr.Cells[1].Text.Trim() + "')");
                ++count;
            }
        }
        context.DBCommit();

        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("A009103131");
        }
    }

    protected void RecycleClick()
    {
        // 回收校验 
        if (RecycleValidationFalse()) return;

        bool ok = false;
        
        //调用回收处理的存储过程
        context.SPOpen();
        context.AddField("p_renewRemark").Value = txtRenewRemark.Text.Trim();
        context.AddField("p_billMonth").Value = hidDealDate.Value.Substring(5, 2);

        if (hidGardenRec.Value == "RelaxRec") // 休闲回收
        {
            ok = context.ExecuteSP("SP_SD_XXPARKErrRec");
        }
        else
        {
            ok = context.ExecuteSP("SP_SD_ConsumeErrRec");
        }

        if (ok)
        {
            AddMessage("成功回收" + context.GetFieldValue("p_retMsg") + "条记录");         
        }
    }


    private bool RecycleValidationFalse()
    {
        // 对非空回收说明的长度校验
        txtRenewRemark.Text = txtRenewRemark.Text.Trim();
        if (txtRenewRemark.Text != "" && Validation.strLen(txtRenewRemark.Text) > 150)
        {
            context.AddError("A009103023", txtRenewRemark);
            return true;
        }

        return false;
    }

    protected void CancelClick()
    {
        if (hidGardenRec.Value == "RelaxRec") // 休闲回收不支持作废
        {
            return; 
        }

        //作废校验 
        if (RecycleValidationFalse()) return;

        //调用作废处理的存储过程
        context.SPOpen();
        context.AddField("p_renewRemark").Value = txtRenewRemark.Text.Trim();
        context.AddField("p_billMonth").Value = hidDealDate.Value.Substring(5, 2);
        bool ok = context.ExecuteSP("SP_SD_ConsumeErrCancel");

        if (ok)
        {
            AddMessage("成功作废" + context.GetFieldValue("p_retMsg") + "条记录");
        }
    }

    private bool QueryValidation()
    {
        //对处理日期非空,格式的判断
        txtDealDate.Text = txtDealDate.Text.Trim();
        if (txtDealDate.Text == "")
            context.AddError("A009103107", txtDealDate);
        else if (!Validation.isDate(txtDealDate.Text, "yyyy-MM"))
            context.AddError("A009103108", txtDealDate);

        UserCardHelper.validateDate(context, txtDealDateExt, false, "A003104411", "");

        //对非空交易起始和终止日期有效性的检测
        UserCardHelper.validateDateRange(context, txtStartDate, txtEndDate, false);

        //对非空PSAM编号长度英数字的判断
        UserCardHelper.validatePSAM(context, txtPasmNo, true);

        //对非空POS编号长度数字类型的校验
        UserCardHelper.validatePosNo(context, txtPosNo, true);

        //对非空卡号长度数字的判断
        UserCardHelper.validateCardNo(context, txtCardNo, true);

        // 校验结算单元编码格式(8位英数)
        UserCardHelper.validateBalUnitNo(context, txtBalUnitNo, true);
        
        return context.hasError();
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (btnQuery.Text == "返回")
        {
            panCond.Visible = true;
            showNonDataGridView();
            btnQuery.Text = "查询";
            return;
        }


        //调用查询输入的判处理
        if (QueryValidation())
        {
            return;
        }
            
        hidDealDate.Value = txtDealDate.Text.Trim();

        //取得查询结果
        DataTable dataView = QueryResultColl();

        //没有查询出交易记录时,显示错误
        if (dataView.Rows.Count == 0)
        {
            AddMessage("N007P00001: 查询结果为空");
        }

        // 公交只允许查询，不允许回收等处理
        bool allowRecycle = selCalling.SelectedValue != "01" 
            && selRecyState.SelectedValue == "0"
            && dataView.Rows.Count > 0;

        panel1.Visible = allowRecycle;

        //显示查询结果信息
        UserCardHelper.resetData(gvResult, dataView);
    }

    public DataTable QueryResultColl()
    {
        bool enabled = selRecyState.SelectedValue == "0";
        txtRenewRemark.Enabled = enabled;
        DataTable data = null;

        SP_12QueryPDO pdo = new SP_12QueryPDO("SP_SD_Query");
        if (hidGardenRec.Value == "RelaxRec") // 休闲回收
        {
            data = SPHelper.call12Query(pdo, context, "XXPARKErrorInfo",
               txtDealDate.Text,
               txtStartDate.Text, txtEndDate.Text, txtCardNo.Text, txtDealDateExt.Text,
               selDepart.SelectedValue, null, null, txtPasmNo.Text, 
               selErrorReasonCode.SelectedValue, txtPosNo.Text,
               selRecyState.SelectedValue + "," + txtBalUnitNo.Text);
        }
        else
        {
            //从消费异常清单表表(TF_TRADE_ERROR_01(…12))中读取数据
            data = SPHelper.call12Query(pdo, context, "ConsumeErrorInfo",
                txtDealDate.Text + "," + ddlTradeType.SelectedValue, // 处理年月后面附着交易类型
                txtStartDate.Text, txtEndDate.Text, txtCardNo.Text, txtDealDateExt.Text,
                selCalling.SelectedValue, selCorp.SelectedValue, selDepart.SelectedValue,
                txtPasmNo.Text, selErrorReasonCode.SelectedValue, txtPosNo.Text,
                selRecyState.SelectedValue + "," + txtBalUnitNo.Text);
            
            labCount.Text = "总交易笔数:" + pdo.var11;
            labSum.Text = "总交易金额:" + pdo.var12;
       }


        return data;
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Footer)
        {
            if (btnQuery.Text == "返回")
            {
                e.Row.Cells[0].Visible = false;
            }

            e.Row.Cells[1].Visible = false;
            e.Row.Cells[2].Visible = false;

            if (hidGardenRec.Value == "RelaxRec") // 休闲回收
            {
                e.Row.Cells[4].Visible = false;
                e.Row.Cells[11].Visible = false;
                e.Row.Cells[12].Visible = false;
                e.Row.Cells[17].Visible = false;
                e.Row.Cells[18].Visible = false;
                e.Row.Cells[19].Visible = false;
                e.Row.Cells[20].Visible = false;
            }

            if (e.Row.RowType == DataControlRowType.DataRow 
                && btnQuery.Text == "返回")
            {
                if (e.Row.Cells[2].Text.Substring(0, 1) == "2") // 已回收
                {
                    e.Row.Cells[3].CssClass = "recycled";
                }
                else if (e.Row.Cells[2].Text.Substring(0, 1) == "3") // 已作废
                {
                    e.Row.Cells[3].CssClass = "cancelled";
                }
            }
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 选择的异常消费记录入临时表
        if (selActionType.SelectedValue == "")
        {
            context.AddError("请选择处理方式后再按提交按钮", selActionType);
            return;
        }

        RecordIntoTmp();
        if (context.hasError()) return;

        string renewStateCode = "0";

        if (selActionType.SelectedValue == "AutoFillBalUnit")
        {
            FillBalUnitNo();
            renewStateCode = "3";
        }
        else if (selActionType.SelectedValue == "ManuFillBalUnit")
        {
            FillBalUnitNo();
            renewStateCode = "4";
        }
        else if (selActionType.SelectedValue == "Recycle")
        {
            RecycleClick();
            renewStateCode = "1";
        }
        else if (selActionType.SelectedValue == "Cancel")
        {
            CancelClick();
            renewStateCode = "2";
        }

        txtBalUnit.Text = "";

        showSubmitResultDisplay(renewStateCode);
    }

    private void showSubmitResultDisplay(string renewStateCode)
    {
        btnQuery.Text = "返回";
        panCond.Visible = false;
        panel1.Visible = false;
        labCount.Text = "";
        labSum.Text = "";

        SP_12QueryPDO pdo = new SP_12QueryPDO("SP_SD_Query");
        DataTable data = SPHelper.call12Query(pdo, context,
            (hidGardenRec.Value == "RelaxRec" ? "XXResultDisplay" : "SubmitResultDisplay"),
            txtDealDate.Text, renewStateCode);
        UserCardHelper.resetData(gvResult, data);
    }

    protected void selCalling_SelectedIndexChanged(object sender, EventArgs e)
    {
        showNonDataGridView();

        //选择行业名称后处理        if (selCalling.SelectedValue == "")
        {
            selCorp.Items.Clear();
            selDepart.Items.Clear();
        }
        else
        {
            //初始化该行业下的单位名称
            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
            tdoTD_M_CORPIn.CALLINGNO = selCalling.SelectedValue;

            TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, "TD_M_CORPCALLUSAGE", null);
            ControlDeal.SelectBoxFill(selCorp.Items, tdoTD_M_CORPOutArr, "CORP", "CORPNO", true);
        }
    }

    protected void selCorp_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择单位名称后处理
        if (selCorp.SelectedValue == "")
        {
            selDepart.Items.Clear();
            return;
        }
        else
        {
            //初始化该单位下的部门名称
            TMTableModule tmTMTableModule = new TMTableModule();

            TD_M_DEPARTTDO tdoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
            tdoTD_M_DEPARTIn.CORPNO = selCorp.SelectedValue;

            TD_M_DEPARTTDO[] tdoTD_M_DEPARTOutArr = (TD_M_DEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null, "TD_M_DEPARTUSAGE", null);
            ControlDeal.SelectBoxFill(selDepart.Items, tdoTD_M_DEPARTOutArr, "DEPART", "DEPARTNO", true);
        }
    }

    private void showNonDataGridView()
    {
        //显示异常消费信息列表
        UserCardHelper.resetData(gvResult, null);

        labCount.Text = "";
        labSum.Text = "";
    }

    protected void FillBalUnitNo()
    {
        if (selActionType.SelectedValue == "ManuFillBalUnit" 
            && selBalUint.SelectedValue == "")
        {
            context.AddError("请先选择结算单元", selBalUint);
        }

        //在清单表中补结算单元信息
        context.SPOpen();
        
        if (hidGardenRec.Value == "RelaxRec") // 休闲回收
        {
            context.AddField("p_errtablename").Value = "TF_XXPARK_ERROR_"
                + hidDealDate.Value.Substring(5, 2);
        }
        else
        {
            context.AddField("p_errtablename").Value = "tf_trade_error_"
                + hidDealDate.Value.Substring(5, 2);
        }
        context.AddField("p_balUnitNo").Value = selBalUint.SelectedValue;

        bool ok = false;
        if (hidGardenRec.Value == "RelaxRec") // 休闲回收
        {
            ok = context.ExecuteSP("SP_SD_XXFillBalUnit");
        }
        else
        {
            ok = context.ExecuteSP("SP_SD_FillBalUnit");
        }

        if (ok)
        {
            AddMessage("自动补全结算单元编码成功记录数:" + context.GetFieldValue("p_retMsg"));
        }    
    }


    protected void txtBalUnit_TextChanged(object sender, EventArgs e)
    {
        txtBalUnit.Text = txtBalUnit.Text.Trim();
        if (txtBalUnit.Text.Length <= 0)
        {
            context.AddError("请先输入结算单元部分名称", txtBalUnit);
            return;
        }

        DataTable dt = null;
        if (hidGardenRec.Value == "RelaxRec") // 休闲回收
        {
            dt = SPHelper.callSDQuery(context, "QueryXXBalUnit", txtBalUnit.Text);
        }
        else
        {
            dt = SPHelper.callSDQuery(context, "QueryBalUnit", txtBalUnit.Text);
        }
        GroupCardHelper.fill(selBalUint, dt, true);
    }
}
