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
using TDO.UserManager;
using Common;
using TM;
using TDO.PersonalTrade;
using TDO.BalanceChannel;

public partial class ASP_SpecialDeal_SD_SpeAdjustAccQuery : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            TMTableModule tmTMTableModule = new TMTableModule();

            //初始化行业名称


            TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
            TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), "S008100211", "TD_M_CALLINGNO", null);
            ControlDeal.SelectBoxFill(selCalling.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);

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

    protected void selCalling_SelectedIndexChanged(object sender, EventArgs e)
    {

        //选择行业名称后处理

        selCorp.Items.Clear();
        selDepart.Items.Clear();
        selBalUint.Items.Clear();

        //初始化该行业下的单位名称
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
        tdoTD_M_CORPIn.CALLINGNO = selCalling.SelectedValue;
        TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, "TD_M_CORPCALLUSAGE", null);
        ControlDeal.SelectBoxFill(selCorp.Items, tdoTD_M_CORPOutArr, "CORP", "CORPNO", true);

        InitBalUnit("00", selCalling);
    }

    protected void selCorp_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择单位名称后处理


        if (selCorp.SelectedValue == "")
        {
            selDepart.Items.Clear();
            InitBalUnit("00", selCalling);
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

            InitBalUnit("01", selCorp);
        }
    }

    protected void selDepart_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择部门名称后处理


        //选定单位后,设置部门下拉列表数据
        if (selDepart.SelectedValue == "")
        {
            InitBalUnit("01", selCorp);
            return;
        }

        //初始化结算单元(属于选择部门)名称下拉列表值


        InitBalUnit("02", selDepart);
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

    private void InitBalUnit(string balType, DropDownList dwls)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_TRADE_BALUNITTDO tdoTF_TRADE_BALUNITIn = new TF_TRADE_BALUNITTDO();
        TF_TRADE_BALUNITTDO[] tdoTF_TRADE_BALUNITOutArr = null;

        //查询选定行业下的结算单元
        if (balType == "00")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_BYCALLING", null);
        }

        //查询选定单位下的结算单元
        else if (balType == "01")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = selCalling.SelectedValue;
            tdoTF_TRADE_BALUNITIn.CORPNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_BYCORP", null);
        }

        //查询选定部门下的结算单元
        else if (balType == "02")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = selCalling.SelectedValue;
            tdoTF_TRADE_BALUNITIn.CORPNO = selCorp.SelectedValue;
            tdoTF_TRADE_BALUNITIn.DEPARTNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_BYDEPART", null);
        }

        ControlDeal.SelectBoxFill(selBalUint.Items, tdoTF_TRADE_BALUNITOutArr, "BALUNIT", "BALUNITNO", true);
    }


    private void showResult()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }

    private bool QueryValidation()
    {

        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtInStartDate);
        bool b2 = Validation.isEmpty(txtInEndDate);
        DateTime? fromDate = null, toDate = null;
        if (!(b1 && b2))
        {
            if (b1 || b2)
            {
                context.AddError("开始日期和结束日期必须同时填写");
            }
            else
            {
                if (!b1)
                {
                    fromDate = valid.beDate(txtInStartDate, "开始日期范围起始值格式必须为yyyyMMdd");
                }
                if (!b2)
                {
                    toDate = valid.beDate(txtInEndDate, "结束日期范围终止值格式必须为yyyyMMdd");
                }
            }

            if (fromDate != null && toDate != null)
            {
                valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
            }
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

        // 校验结算单元编码格式(8位英数)
        //UserCardHelper.validateBalUnitNo(context, txtBalUnitNo, true);

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
        DataTable data = SPHelper.callSDQuery(context, "SpeAdjustAccQuery",
            selChkState.SelectedValue, selInStaff.SelectedValue, txtInStartDate.Text, txtCardNo.Text, selBalUint.SelectedValue, selCalling.SelectedValue, selCorp.SelectedValue, selDepart.SelectedValue, txtInEndDate.Text);

        return new DataView(data);
    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            ExportGridView(gvResult);
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }
}
