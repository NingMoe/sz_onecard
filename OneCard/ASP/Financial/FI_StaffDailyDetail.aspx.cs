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
using PDO.Financial;
using Master;
using Common;
using TM;
using TDO.UserManager;
using TDO.Financial;
using TDO.BusinessCode;
using System.Collections.Generic;
using Loki;

public partial class ASP_Financial_FI_StaffDailyDetail : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化业务



            TD_TRADETYPE_SHOWTDO tdoTD_TRADETYPE_SHOWIn = new TD_TRADETYPE_SHOWTDO();
            TD_TRADETYPE_SHOWTDO[] tdoTD_TRADETYPE_SHOWOutArr = (TD_TRADETYPE_SHOWTDO[])tm.selByPKArr(context, tdoTD_TRADETYPE_SHOWIn, typeof(TD_TRADETYPE_SHOWTDO), null, "TRADETYPE_SHOW", null);
            selTradeType.Items.Add(new ListItem("0000:全部业务", ""));
            foreach (DDOBase ddoDDOBase in tdoTD_TRADETYPE_SHOWOutArr)
            {
                selTradeType.Items.Add(new ListItem(ddoDDOBase.GetString("SHOWNO") + ":" + ddoDDOBase.GetString("SHOWNAME"), ddoDDOBase.GetString("SHOWNO")));
            }
            //新增业务类型园林补换卡明细，add by shil 2012-12-28
            selTradeType.Items.Add(new ListItem("0030:园林补换卡明细", "0030"));
            //市民卡A卡，add by shil 2013-01-11
            selTradeType.Items.Add(new ListItem("0031:售卡(A卡)", "0031"));
            selTradeType.Items.Add(new ListItem("0032:换卡(A卡)", "0032"));
            //增加读卡器销售报表查询, add by youyue 2013-3-11
            selTradeType.Items.Add(new ListItem("0040:读卡器销售", "0040"));

           
            //初始化日期



            txtFromDate.Text = DateTime.Today.ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");

            if (HasOperPower("201008"))//全部网点主管
            {
                //初始化部门



                //TMTableModule tmTMTableModule = new TMTableModule();
                //TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
                //TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
                //ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
                FIHelper.selectDept(context, selDept, true);
                selDept.SelectedValue = context.s_DepartID;
                InitStaffList(context.s_DepartID);
                selStaff.SelectedValue = context.s_UserID;
            }
            else if (HasOperPower("201007"))//网点主管
            {
                selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
                selDept.SelectedValue = context.s_DepartID;
                selDept.Enabled = false;

                InitStaffList(context.s_DepartID);
                selStaff.SelectedValue = context.s_UserID;
            }
            else if (HasOperPower("201009"))//代理全网点主管 add by liuhe20120214添加对代理的权限处理
            {
                context.DBOpen("Select");
                string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
                string sql = @"SELECT  D.DEPARTNAME,D.DEPARTNO FROM TD_DEPTBAL_RELATION R,TD_M_INSIDEDEPART D 
                            WHERE R.DEPARTNO=D.DEPARTNO AND R.DBALUNITNO='" + dBalunitNo + "' AND R.USETAG='1'";
                DataTable table = context.ExecuteReader(sql);
                GroupCardHelper.fill(selDept, table, true);

                selDept.SelectedValue = context.s_DepartID;
                InitStaffList(context.s_DepartID);
                selStaff.SelectedValue = context.s_UserID;
            }
            else if (HasOperPower("201010"))//代理网点主管
            {
                selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
                selDept.SelectedValue = context.s_DepartID;
                selDept.Enabled = false;

                InitStaffList(context.s_DepartID);
                selStaff.SelectedValue = context.s_UserID;
            }
            else//网点营业员


            {
                selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
                selDept.SelectedValue = context.s_DepartID;
                selDept.Enabled = false;

                selStaff.Items.Add(new ListItem(context.s_UserID + ":" + context.s_UserName, context.s_UserID));
                selStaff.SelectedValue = context.s_UserID;
                selStaff.Enabled = false;
            }
        }
    }

    private bool HasOperPower(string powerCode)
    {
        //TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
        string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
        DataTable dataSupply = tm.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
        if (dataSupply.Rows.Count > 0)
            return true;
        else
            return false;
    }

    private void InitStaffList(string deptNo)
    {
        if (deptNo == "")
        {
            string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
            if (dBalunitNo != "")//add by liuhe20120214添加对代理的权限处理
            {
                context.DBOpen("Select");

                string sql = @"SELECT STAFFNAME,STAFFNO FROM TD_M_INSIDESTAFF 
                             WHERE DIMISSIONTAG ='1' AND  DEPARTNO IN 
                            (SELECT DEPARTNO FROM TD_DEPTBAL_RELATION WHERE DBALUNITNO='" + dBalunitNo + "' AND USETAG='1')";
                DataTable table = context.ExecuteReader(sql);
                GroupCardHelper.fill(selStaff, table, true);

                return;
            }

            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);
            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
            selStaff.SelectedValue = context.s_UserID;

        }
        else
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
    }

    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selDept.SelectedValue);
    }
    //选择业务类型后验证是否选择换卡
    protected void selTradeType_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (selTradeType.SelectedValue.Equals("0003"))
        {
            selReasonType.Enabled = true;
            selReasonType.Items.Clear();
            ASHelper.setChangeReason(selReasonType, true);
        }
        else if (selTradeType.SelectedValue.Equals("0005"))
        {
            selReasonType.Enabled = true;
            selReasonType.Items.Clear();
            TMTableModule tmTMTableModule = new TMTableModule();

            //从退换卡原因编码表(TD_M_REASONTYPE)中读取数据，放入下拉列表中



            TD_M_REASONTYPETDO tdoTD_M_REASONTYPEIn = new TD_M_REASONTYPETDO();
            TD_M_REASONTYPETDO[] tdoTD_M_REASONTYPEOutArr = (TD_M_REASONTYPETDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_REASONTYPEIn, typeof(TD_M_REASONTYPETDO), "S001007122");

            ControlDeal.SelectBoxFill(selReasonType.Items, tdoTD_M_REASONTYPEOutArr, "REASON", "REASONCODE", true);
        }
        else
        {
            selReasonType.Items.Clear();
            selReasonType.Enabled = false;
        }
    }
    private double serviceCharge = 0;
    private double cardDeposit = 0;
    private double cardCharge = 0;
    private double handingFee = 0;
    private double functionCharge = 0;
    private double otherCharge = 0;

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (!selTradeType.SelectedValue.Equals("0030"))//如果不是园林补换卡明细则计算总和
        {
            if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
            {
                serviceCharge += Convert.ToDouble(GetTableCellValue(e.Row.Cells[4]));
                cardDeposit += Convert.ToDouble(GetTableCellValue(e.Row.Cells[5]));
                cardCharge += Convert.ToDouble(GetTableCellValue(e.Row.Cells[6]));
                handingFee += Convert.ToDouble(GetTableCellValue(e.Row.Cells[7]));
                functionCharge += Convert.ToDouble(GetTableCellValue(e.Row.Cells[8]));
                otherCharge += Convert.ToDouble(GetTableCellValue(e.Row.Cells[9]));
            }
            else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
            {
                e.Row.Cells[0].Text = "总计";
                e.Row.Cells[4].Text = serviceCharge.ToString("n");
                e.Row.Cells[5].Text = cardDeposit.ToString("n");
                e.Row.Cells[6].Text = cardCharge.ToString("n");
                e.Row.Cells[7].Text = handingFee.ToString("n");
                e.Row.Cells[8].Text = functionCharge.ToString("n");
                e.Row.Cells[9].Text = otherCharge.ToString("n");
            }
        }
    }

    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }

    // 查询输入校验处理
    private void validate()
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

        //if (selStaff.SelectedValue == "")
        //    context.AddError("请选择员工");

    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        if (selTradeType.SelectedValue.Equals("0030"))
        {
            //业务类型选择园林补换卡明细，则查询园林补换卡明细记录，add by shil 2012-12-28
            pdo.funcCode = "ParkCardChangDetail";
        }
        else
        {
            pdo.funcCode = "TRADE_LOG_LIST";
        }
        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;
        pdo.var3 = selStaff.SelectedValue;
        pdo.var5 = selDept.SelectedValue;
        pdo.var6 = selTradeType.SelectedValue;
        pdo.var10 = selDept.SelectedValue;
        pdo.var11 = context.s_DepartID;
        pdo.var7 = selMoney.SelectedValue;//增加是否含无金额业务 add by youyue 

        if (selReasonType.SelectedValue != "")
        {
            pdo.var4 = selReasonType.SelectedValue;//增加退换卡原因 条件 by 殷华荣


        }
         
        DataTable data = LokiSlowQuery.QueryFormLoki(context, pdo);

        if (selTradeType.SelectedValue.Equals("0030"))
        {
            StoreProScene storePro = new StoreProScene();
            data = storePro.Execute(context, pdo);
            //解密
            CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "姓名", "身份证号" }));
        }

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        serviceCharge = 0;
        cardDeposit = 0;
        cardCharge = 0;
        handingFee = 0;
        functionCharge = 0;
        otherCharge = 0;

        UserCardHelper.resetData(gvResult, data);
        //MergeRows(gvResult, 3);

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

    public void MergeRows(GridView gv, int columnIndex)
    {
        TableCell preCell = null;

        if (gv.Rows.Count > 0)
            preCell = gv.Rows[0].Cells[columnIndex];

        if (preCell != null)
        {
            for (int r = 1; r < gv.Rows.Count; r++)
            {
                TableCell cell = gv.Rows[r].Cells[columnIndex];
                if (preCell.Text == cell.Text)
                {
                    cell.Visible = false;
                    preCell.RowSpan = (preCell.RowSpan == 0 ? 1 : preCell.RowSpan) + 1;
                }
                else
                {
                    preCell = cell;
                    preCell.BackColor = System.Drawing.Color.White;
                }
            }
        }
    }    
}