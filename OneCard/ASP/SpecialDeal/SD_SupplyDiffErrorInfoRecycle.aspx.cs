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
using TDO.BalanceChannel;
using Common;
using TDO.SupplyBalance;

public partial class ASP_SpecialDeal_SD_SupplyDiffErrorInfoRecycle : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //显示充值异常信息空列表表头
            UserCardHelper.resetData(gvResult, null);

            //初始化行业名称
            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
            TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), "S008100211", "TD_M_CALLINGNO", null);

            ControlDeal.SelectBoxFill(selCalling.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);

            //初始化比对结果
            selCompState.Items.Add(new ListItem("---请选择---", ""));
            selCompState.Items.Add(new ListItem("0:脱机无", "0"));
            selCompState.Items.Add(new ListItem("1:联机无", "1"));
            selCompState.Items.Add(new ListItem("2:金额不符", "2"));
        }
    }

    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        //分页处理 
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    protected void CheckAll(object sender, EventArgs e)
    {
        //全选异常信息记录
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            if (!gvr.Cells[0].Enabled) continue;
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }


    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[1].Visible = false;
        }
    }

    protected void selCalling_SelectedIndexChanged(object sender, EventArgs e)
    {
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


    private void QueryValidation()
    {
        //对非空交易起始和终止日期有效性的检测
        UserCardHelper.validateDateRange(context, txtStartDate, txtEndDate, false);

        //对非空PSAM编号长度英数字的判断
        UserCardHelper.validatePSAM(context, txtPasmNo, true);


        //对非空卡号长度数字的判断
        UserCardHelper.validateCardNo(context, txtCardNo, true);

        //对非空POS编号长度数字类型的校验
        UserCardHelper.validatePosNo(context, txtPosNo, true);
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //调用查询输入的判处理
        QueryValidation();
        if(context.hasError())
        {
            UserCardHelper.resetData(gvResult, null);
            return;
        }

        //取得查询结果
        SP_12QueryPDO pdo = new SP_12QueryPDO("SP_SD_Query");
        DataTable data = SPHelper.call12Query(pdo, context, "QrySupplyDiff",
            txtStartDate.Text, txtEndDate.Text, txtCardNo.Text,
            selCalling.SelectedValue, selCorp.SelectedValue, selDepart.SelectedValue,
            txtPasmNo.Text, selCompState.SelectedValue, txtPosNo.Text);

        //没有查询出充值记录时,显示错误
        if (data.Rows.Count == 0)
        {
            context.AddError("A009106011");
        }

        //显示查询结果信息
        UserCardHelper.resetData(gvResult, data);
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

    protected void btnRecycle_Click(object sender, EventArgs e)
    {
        //调用充值比对回收的存储过程
        context.SPOpen();
        context.AddField("p_remark").Value = txtRenewRemark.Text.Trim();
        bool ok = context.ExecuteSP("SP_SD_SupplyDiffRec");
        if (ok)
        {
            AddMessage("M009106110");
            UserCardHelper.resetData(gvResult, null);
        }

        txtRenewRemark.Text = "";
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        context.SPOpen();
        context.AddField("p_remark").Value = txtRenewRemark.Text.Trim();
        bool ok = context.ExecuteSP("SP_SD_SupplyDiffCancel");
        if (ok)
        {
            AddMessage("M009106111");
            UserCardHelper.resetData(gvResult, null);
        }

        txtRenewRemark.Text = "";
    }
}
