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
using Common;
using PDO.Financial;
using Master;
using TM;
using TDO.UserManager;

public partial class ASP_Financial_FI_SELLCHANGE_MONTHLY_REPORT : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化月份

            txtMonth.Text = DateTime.Now.AddMonths(-1).ToString("yyyyMM");

            string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
            if (dBalunitNo != "")//add by liuhe20120214添加对代理的权限处理
            {
                if (HasOperPower("201009"))//代理全网点主管

                {
                    context.DBOpen("Select");
                    string sql = @"SELECT  D.DEPARTNAME,D.DEPARTNO FROM TD_DEPTBAL_RELATION R,TD_M_INSIDEDEPART D 
                            WHERE R.DEPARTNO=D.DEPARTNO AND R.DBALUNITNO='" + dBalunitNo + "' AND R.USETAG='1'";
                    DataTable table = context.ExecuteReader(sql);
                    GroupCardHelper.fill(selDept, table, false);

                    selDept.SelectedValue = context.s_DepartID;
                }
                else
                {
                    selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
                    selDept.SelectedValue = context.s_DepartID;
                    selDept.Enabled = false;
                }
            }
            else
            {
                if (HasOperPower("201008"))//全网点主管，可以查看所有部门

                {
                    TMTableModule tmTMTableModule = new TMTableModule();
                    TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
                    TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
                    ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
                }
                else
                {
                    selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
                    selDept.SelectedValue = context.s_DepartID;
                    selDept.Enabled = false;
                }
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

    private int lastMonthStock = 0;
    private int thisMonthStock = 0;
    private int sellNum = 0;
    private int sellMoney = 0;
    private int changeNum = 0;
    private int changeMoney = 0;
    private int speadJustAcc = 0;
    private int badCard = 0;
    private int surplusStock = 0;

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.DataRow || gvResult.ShowFooter)
        {
            e.Row.Cells[0].Visible = false;
        }
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            lastMonthStock += Convert.ToInt32(GetTableCellValue(e.Row.Cells[2]));
            thisMonthStock += Convert.ToInt32(GetTableCellValue(e.Row.Cells[3]));
            sellNum += Convert.ToInt32(GetTableCellValue(e.Row.Cells[4]));
            sellMoney += Convert.ToInt32(GetTableCellValue(e.Row.Cells[5]));
            changeNum += Convert.ToInt32(GetTableCellValue(e.Row.Cells[6]));
            changeMoney += Convert.ToInt32(GetTableCellValue(e.Row.Cells[7]));
            speadJustAcc += Convert.ToInt32(GetTableCellValue(e.Row.Cells[8]));
            badCard += Convert.ToInt32(GetTableCellValue(e.Row.Cells[9]));
            surplusStock += Convert.ToInt32(GetTableCellValue(e.Row.Cells[10]));

        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[1].Text = "总计";
            e.Row.Cells[2].Text = lastMonthStock.ToString();
            e.Row.Cells[3].Text = thisMonthStock.ToString();
            e.Row.Cells[4].Text = sellNum.ToString();
            e.Row.Cells[5].Text = sellMoney.ToString();
            e.Row.Cells[6].Text = changeNum.ToString();
            e.Row.Cells[7].Text = changeMoney.ToString();
            e.Row.Cells[8].Text = speadJustAcc.ToString();
            e.Row.Cells[9].Text = badCard.ToString();
        }
    }

    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        //string sql = "";
        //sql = "select min(STATDATE), max(STATDATE),count(distinct(STATDATE)) from TF_SELLCHANGEREPORT";
        //DataTable sqldata = context.ExecuteReader(sql);
        //int minstatdate = Convert.ToInt32(sqldata.Rows[0][0].ToString());
        //int maxstatdate =  Convert.ToInt32(sqldata.Rows[0][1].ToString());

        //if (Convert.ToInt32(txtFromDate.Text) < minstatdate || maxstatdate < Convert.ToInt32(txtToDate.Text) )
        //{
        //    context.AddError("当前查询日期范围内存在未汇总完成的售换卡记录，请重新选择日期，如有疑问请联系管理员！");
        //    UserCardHelper.resetData(gvResult, null);
        //    return;
        //}
        //sql = "select count(distinct(STATDATE)) from TF_SELLCHANGEREPORT where STATDATE between '"+txtFromDate.Text+"' and '"+txtToDate.Text+"'";
        //sqldata = context.ExecuteReader(sql);
        //int count = Convert.ToInt32(sqldata.Rows[0][0].ToString());
        //TimeSpan timespan = DateTime.ParseExact(txtToDate.Text, "yyyyMMdd", System.Globalization.CultureInfo.CurrentCulture).Subtract(DateTime.ParseExact(txtFromDate.Text, "yyyyMMdd", System.Globalization.CultureInfo.CurrentCulture));
        //if(count != Convert.ToInt32(timespan.Days.ToString()) + 1)
        //{
        //    context.AddError("当前查询日期范围内存在未汇总完成的售换卡记录，请重新选择日期，如有疑问请联系管理员！");
        //    UserCardHelper.resetData(gvResult, null);
        //    return;
        //}



        SP_FI_CARDSTATPDO pdo = new SP_FI_CARDSTATPDO();
        pdo.funcCode = "SELLCHANGEMONTHLYREPORT";
        pdo.var1 = txtMonth.Text;
        //pdo.var2 = DateTime.ParseExact(txtToDate.Text, "yyyyMMdd", null).AddDays(1).ToString("yyyyMMdd");
        pdo.var2 = selDept.SelectedValue;
        if (chkQueryAll.Checked)
        {
            pdo.var3 = "1";
        }
        else
        {
            pdo.var3 = "0";
        }
        //pdo.var7 = txtBalUnit.Text;

        StoreProScene storePro = new StoreProScene();

        DataTable data = storePro.Execute(context, pdo);
        //hidNo.Value = pdo.var9;

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        UserCardHelper.resetData(gvResult, data);
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

    private void validate()
    {
        Validation valid = new Validation(context);

        if (string.IsNullOrEmpty(txtMonth.Text.Trim()))
            context.AddError("月份不能为空");
        else
        {
            try
            {
                DateTime.ParseExact(txtMonth.Text.Trim(), "yyyyMM", null);
            }
            catch
            {
                context.AddError("月份格式必须为yyyyMM");
            }
        }
        //bool b = Validation.isEmpty(txtFromDate);
        //DateTime? fromDate = null, toDate = null;
        //if (!b)
        //{
        //    fromDate = valid.beDate(txtFromDate, "开始日期范围起始值格式必须为yyyyMMdd");
        //}
        //b = Validation.isEmpty(txtToDate);
        //if (!b)
        //{
        //    toDate = valid.beDate(txtToDate, "结束日期范围终止值格式必须为yyyyMMdd");
        //}

        //if (fromDate != null && toDate != null)
        //{
        //    valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        //}

        //if (txtBalUnit.Text.Trim() == "")
        //{
        //    context.AddError("A006500012", txtBalUnit);
        //}

        string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
        if (dBalunitNo != "" && selDept.SelectedValue == "")//add by liuhe20120214添加对代理的权限处理
        {
            context.AddError("A006500069:请选择部门");
        }

    }
}
