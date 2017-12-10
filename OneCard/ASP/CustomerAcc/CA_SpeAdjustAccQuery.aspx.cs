using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TDO.BalanceChannel;
using TDO.ConsumeBalance;
using TM;
using TDO.PersonalTrade;
using TDO.BalanceChannel;
using TDO.UserManager;

public partial class ASP_CustomerAcc_CA_SpeAdjustAccQuery : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            TMTableModule tmTMTableModule = new TMTableModule();

            //录入员工所在部门

            TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTTDOIn = new TD_M_INSIDEDEPARTTDO();
            TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTTDOOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTTDOIn, typeof(TD_M_INSIDEDEPARTTDO), null, null,  " WHERE USETAG = '1' ORDER BY DEPARTNO");
            ControlDeal.SelectBoxFill(selInSideDept.Items, tdoTD_M_INSIDEDEPARTTDOOutArr, "DEPARTNAME", "DEPARTNO", true);

            //初始化审核状态


            selChkState.Items.Add(new ListItem("---请选择---", ""));
            selChkState.Items.Add(new ListItem("0:录入待审核", "0"));
            selChkState.Items.Add(new ListItem("1:审核通过", "1"));
            selChkState.Items.Add(new ListItem("2:已调帐充值", "2"));
            selChkState.Items.Add(new ListItem("3:确认作废", "3"));

            //初始化录入员工


            //从内部员工编码表(TD_M_INSIDESTAFF)中读取数据，放入录入员工下拉列表中


            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), "S008111111", "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);

            ControlDeal.SelectBoxFill(selInStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);


            //显示调账列表信息
            showResult();
        }
    }

    protected void selDept_Changed(object sender, EventArgs e)
    {
        selInStaff.Items.Clear();

        if (selInSideDept.SelectedValue == "")
            return;

        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();

        tdoTD_M_INSIDESTAFFIn.DEPARTNO = selInSideDept.SelectedValue;
        TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDEDEPART", null);
        ControlDeal.SelectBoxFill(selInStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);

    }


    private void showResult()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }

    private bool QueryValidation()
    {

        //对非空录入日期格式检验


        txtInDate.Text = txtInDate.Text.Trim();
        string strInDate = txtInDate.Text;
        if (strInDate != "" && !Validation.isDate(strInDate, "yyyyMMdd"))
        {
            context.AddError("A009112005", txtInDate);
        }

        //对非空卡号长度数字的判断
        txtCardNo.Text = txtCardNo.Text.Trim();
        string strCardNo = txtCardNo.Text;
        if (strCardNo != "")
        {
            if (Validation.strLen(strCardNo) != 16)
                context.AddError("A009100109", txtCardNo);
            else if (!Validation.isNum(strCardNo))
                context.AddError("A009100110", txtCardNo);
        }

        return context.hasError();

    }




    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //调用输入条件的判断


        if (QueryValidation()) return;

        //取得查询结果
        ICollection dataView = QueryResultColl();

        //没有查询出交易记录时,显示错误
        if (dataView.Count == 0)
        {

            showResult();
            context.AddError("A009112001");
            return;
        }

        //显示查询结果信息
        gvResult.DataSource = dataView;
        gvResult.DataBind();


    }

    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        //分页处理 
        gvResult.PageIndex = e.NewPageIndex;

        btnQuery_Click(sender, e);

    }



    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
    }

    public ICollection QueryResultColl()
    {
        List<string> vars = new List<string>();
        vars.Add(selChkState.SelectedValue);
        vars.Add(selInStaff.SelectedValue);
        vars.Add(txtInDate.Text);
        vars.Add(txtCardNo.Text);
        DataTable data = SPHelper.callQuery("SP_CA_Query", context, "SpeAdjustAccQuery", vars.ToArray());

        return new DataView(data);
    }
}