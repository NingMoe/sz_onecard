using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TM;
using TDO.BalanceChannel;
using Common;
using System.Data;
using PDO.PartnerShip;
using Master;

public partial class ASP_PartnerShip_PS_ZEROTRADEPOS_COLLECT : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            SPHelper.fillCoding(context, selReason, true, "CATE_FI_ZEROPOS");
            
            //初始化行业名称

            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
            TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), "S008100211", "TD_M_CALLINGNO", null);

            ControlDeal.SelectBoxFill(selCalling.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);

            //指定GridView DataKeyNames
            gvResult.DataKeyNames = new string[] {"BALUNITNO", "BALUNIT", "POSNO" };

            txtTradeDate.Text = DateTime.Now.ToString("yyyyMMdd");
        }
    }

    private void showConGridView()
    {
        //显示交易信息列表
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }

    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        ClearAdjustInfo();
        gvResult.PageIndex = e.NewPageIndex;
        //gvResult.DataSource = QueryResultColl();
        gvResult.DataBind();
    }

    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

    public String getDataKeys(string keysname)
    {
        return gvResult.DataKeys[gvResult.SelectedIndex][keysname].ToString();
    }

    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        labBALUNITNO.Text = getDataKeys("BALUNITNO");
        labBALUNIT.Text = getDataKeys("BALUNIT");
        labPOSNO.Text = getDataKeys("POSNO");

        hiddenBALUNITNO.Value = getDataKeys("BALUNITNO");
        hiddenPOSNO.Value = getDataKeys("POSNO");

        context.DBOpen("Select");
        context.AddField("balunit").Value = hiddenBALUNITNO.Value;
        context.AddField("posno").Value = hiddenPOSNO.Value;
        DataTable data = context.ExecuteReader(
            "SELECT SHOP, ENDDATE, REASON FROM TF_ZEROTRADEPOS_COLLECT WHERE BALUNITNO = :balunit AND POSNO = :posno");
        context.DBCommit();

        if (data.Rows.Count != 0)
        {
            txtShop.Text = data.Rows[0][0].ToString();
            txtEndDate.Text = data.Rows[0][1].ToString();
            selReason.Text = data.Rows[0][2].ToString();
        }
    }

    protected void selCalling_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择行业名称后处理

        if (selCalling.SelectedValue == "")
        {
            selCorp.Items.Clear();
            selDepart.Items.Clear();
            selBalUint.Items.Clear();
            return;
        }
        else
        {
            //初始化该行业下的单位名称
            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
            tdoTD_M_CORPIn.CALLINGNO = selCalling.SelectedValue;

            TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, "TD_M_CORPCALLUSAGE", null);
            ControlDeal.SelectBoxFill(selCorp.Items, tdoTD_M_CORPOutArr, "CORP", "CORPNO", true);

            InitBalUnit("00", selCalling);

        }
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

            //初始化结算单元(属于选择单位)名称下拉列表值

            InitBalUnit("01", selCorp);
        }
    }

    //protected void selDepart_SelectedIndexChanged(object sender, EventArgs e)
    //{
    //    //选择查询的部门名称后,初始化结算单元名称


    //    //选定单位后,设置部门下拉列表数据
    //    if (selDepart.SelectedValue == "")
    //    {
    //        InitBalUnit("01", selCorp);
    //        return;
    //    }

    //    //初始化结算单元(属于选择部门)名称下拉列表值

    //    InitBalUnit("02", selDepart);

    //}

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

    private void ClearAdjustInfo()
    {
    }

    private bool ValidateForPosQuery()
    {
        //POS编号必须为数字、6位

        string strPosNo = txtPosno.Text.Trim();
        if (strPosNo != "")
        {
            if (!Validation.isNum(strPosNo))
                context.AddError("A006400001", txtPosno);

            if (Validation.strLen(strPosNo) > 6)
                context.AddError("A006400002", txtPosno);
        }

        if (context.hasError())
            return false;
        else
            return true;
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (selBalUint.SelectedValue == "" && txtPosno.Text == "")
        {
            context.AddError("结算单元和POS编号不能同时为空");
            return;
        }

        if (selBalUint.SelectedValue == "")
        {
            if (!ValidateForPosQuery())
                return;
        }

        UserCardHelper.resetData(gvResult, null);

        SP_PS_QueryPDO pdo = new SP_PS_QueryPDO();
        pdo.funcCode = "ZEROTRADEPOS";
        pdo.var1 = selBalUint.SelectedValue;
        pdo.var2 = txtPosno.Text;
        pdo.var3 = Convert.ToDateTime(txtTradeDate.Text.Substring(0, 4) + "-" + txtTradeDate.Text.Substring(4, 2) + "-" + txtTradeDate.Text.Substring(6, 2)).AddMonths(-3).ToString("yyyymmdd");
        pdo.var4 = txtTradeDate.Text;
        
        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        UserCardHelper.resetData(gvResult, data);
    }

    protected void btnInput_Click(object sender, EventArgs e)
    {
        if (txtShop.Text == "")
        {
            context.AddError("门店不能为空");
            return;
        }

        if (txtEndDate.Text == "")
        {
            context.AddError("协议到期时间不能为空");
            return;
        }

        if (selReason.SelectedValue == "")
        {
            context.AddError("零交易原因不能为空");
            return;
        }

        context.SPOpen();

        context.AddField("p_BALUNITNO").Value = labBALUNITNO.Text;
        context.AddField("p_BALUNIT").Value = labBALUNIT.Text;
        context.AddField("p_POSNO").Value = labPOSNO.Text;
        context.AddField("p_SHOP").Value = txtShop.Text;
        context.AddField("p_ENDDATE").Value = txtEndDate.Text;
        context.AddField("p_REASON").Value = selReason.Text;

        bool ok = context.ExecuteSP("SP_PS_ZEROTRADEPOS_COLLECT");

        if (ok)
        {
            AddMessage("记录零交易POS分析成功");
        }

    }
}
