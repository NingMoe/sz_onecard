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

public partial class ASP_Financial_FI_SaleChangeDailyReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期

            txtFromDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");

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
                    cblDept.DataSource = table;//绑定多选框值
                    cblDept.DataTextField = "DEPARTNAME";
                    cblDept.DataValueField = "DEPARTNO";
                    cblDept.DataBind();

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
                    
                    context.DBOpen("Select");
                    string sql = @"SELECT  D.DEPARTNAME,D.DEPARTNO FROM TD_M_INSIDEDEPART D 
                            WHERE   D.USETAG = '1' ORDER BY DEPARTNO";
                    DataTable table = context.ExecuteReader(sql);
                    GroupCardHelper.fill(selDept, table, true);
                    cblDept.DataSource = table;//绑定多选框值
                    cblDept.DataTextField = "DEPARTNAME";
                    cblDept.DataValueField = "DEPARTNO";
                    cblDept.DataBind();
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
            if (GetTableCellValue(e.Row.Cells[1]) == "0")
            {
                e.Row.Cells[1].Text = "读卡器";
            }

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
        string cblStirng = GetCblString(cblDept);
        if (cblStirng == "")//不勾选多选框
        {
            SP_FI_CARDSTATPDO pdo = new SP_FI_CARDSTATPDO();
            pdo.funcCode = "SELLCHANGEDAILYREPORT";
            pdo.var1 = txtFromDate.Text.Trim();
            pdo.var2 = txtToDate.Text.Trim();
            pdo.var3 = selDept.SelectedValue;
            StoreProScene storePro = new StoreProScene();
            DataTable data = storePro.Execute(context, pdo);
            if (data == null || data.Rows.Count == 0)
            {
                AddMessage("N005030001: 查询结果为空");
            }

            UserCardHelper.resetData(gvResult, data);
        }
        else
        {
            context.DBOpen("Select");
            string sql = @"select 卡面编码,卡片名称,sum(上期结余) 上期结余,sum(本期领卡) 本期领卡,sum(售卡数量) 售卡数量,sum(售卡金额) 售卡金额,sum(换卡数量) 换卡数量,sum(换卡金额) 换卡金额,sum(特殊调账) 特殊调账,sum(坏卡) 坏卡,sum(期末库存) 期末库存
                         from(select a.CARDSURFACECODE 卡面编码 ,b.CARDSURFACENAME 卡片名称 ,0 上期结余 ,sum(a.thisdaystock ) 本期领卡 ,sum(a.SELLNUM) 售卡数量 ,sum(a.SELLMONEY/100.0 ) 售卡金额 ,sum(a.CHANGENUM ) 换卡数量 , sum(a.CHANGEMONEY/100.0) 换卡金额 ,
                         sum(a.SPEADJUSTACC) 特殊调账 ,sum(a.BADCARD ) 坏卡,0 期末库存 from tf_sellchangedailyreport a , td_m_cardsurface b
                        where a.CARDSURFACECODE = b.CARDSURFACECODE(+)
                        and   a.STATDATE >= '" + txtFromDate.Text + "' and   a.STATDATE <= '" + txtToDate.Text + "'and a.DEPTNO  in (" + cblStirng + ")  and a.cardtype is null group by a.CARDSURFACECODE,b.CARDSURFACENAME  " +
                       "union  select a.CARDSURFACECODE 卡面编码 ,b.CARDSURFACENAME 卡片名称 ,a.lastdaystock  上期结余 ,0 本期领卡 ,0 售卡数量 ,0 售卡金额 ,0 换卡数量 ,0 换卡金额 ,0 特殊调账 ,0 坏卡,a.surplusstock 期末库存 from tf_sellchangedailyreport a,td_m_cardsurface b" +
                      " where a.CARDSURFACECODE = b.CARDSURFACECODE(+) and   a.STATDATE = '" + txtToDate.Text + "' and  a.DEPTNO in (" + cblStirng + ") and   a.cardtype is null " +
                      " union  select a.cardtype 卡面编码 ,b.cardtypename 卡片名称,0  上期结余 ,sum(a.thisdaystock ) 本期领卡 , sum(a.SELLNUM) 售卡数量 , sum(a.SELLMONEY/100.0 ) 售卡金额 ,sum(a.CHANGENUM ) 换卡数量,sum(a.CHANGEMONEY/100.0) 换卡金额,sum(a.SPEADJUSTACC) 特殊调账,sum(a.BADCARD ) 坏卡,0 期末库存 " +
                      " from tf_sellchangedailyreport a ,td_m_cardsurfacetype b where  a.cardtype=b.cardtypecode and a.STATDATE >= '" + txtFromDate.Text + "' and a.STATDATE <= '" + txtToDate.Text + "' and a.DEPTNO in (" + cblStirng + ") and   a.cardtype is not null group by  a.cardtype ,b.cardtypename " +
                      " union select a.cardtype 卡面编码 ,b.cardtypename 卡片名称, a.lastdaystock   上期结余 ,0 本期领卡 ,0 售卡数量 ,0 售卡金额 ,0 换卡数量,0 换卡金额,0 特殊调账,0 坏卡,a.surplusstock  期末库存 " +
                      "from tf_sellchangedailyreport a , td_m_cardsurfacetype b where a.cardtype = b.cardtypecode  and   a.STATDATE = '" + txtToDate.Text + "' and   a.DEPTNO in (" + cblStirng + ") and   a.cardtype is not null ) group by 卡面编码,卡片名称 order by 卡面编码,卡片名称 ";
            DataTable table = context.ExecuteReader(sql);
            if (table == null || table.Rows.Count == 0)
            {
                AddMessage("N005030001: 查询结果为空");
            }

            UserCardHelper.resetData(gvResult, table);
        }
             

        //if (chkQueryAll.Checked)
        //{
        //    pdo.var4 = "1";
        //}
        //else
        //{
        //    pdo.var4 = "0";
        //}
        
    }
    private string GetCblString(CheckBoxList cblDept)
    {
        string cblSting = "";
        foreach (ListItem li in cblDept.Items)
        {  
            if(li.Selected)
            {
                cblSting +="'"+li.Value+"'"+',';

            }            
        }
        if (cblSting.Length>0)
        {
            cblSting = cblSting.Substring(0, cblSting.Length  -1);
        }
        return cblSting;
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


        bool b = Validation.isEmpty(txtFromDate);
        DateTime? fromDate = null, toDate = null;
        if (!b)
        {
            fromDate = valid.beDate(txtFromDate, "开始日期范围起始值格式必须为yyyyMMdd");
        }
        b = Validation.isEmpty(txtToDate);
        if (!b)
        {
            toDate = valid.beDate(txtToDate, "结束日期范围终止值格式必须为yyyyMMdd");
        }
        if (txtFromDate.Text.Equals(string.Empty) || txtToDate.Text.Equals(string.Empty))
        {
            context.AddError("A006500068:请填写开始日期和结束日期");
        }
        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        }

        string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
        if (dBalunitNo != "" && selDept.SelectedValue == "")//add by liuhe20120214添加对代理的权限处理
        {
            context.AddError("A006500069:请选择部门");
        }

    }
}