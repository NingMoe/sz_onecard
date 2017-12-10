using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TDO.Financial;
using Master;
using System.Data;
using TDO.UserManager;
using Common;
using PDO.PrivilegePR;
using TM;
using PDO.Financial;

/******************************
 * 团购业务录入
 * 2014-11-25
 * gl
 *****************************/
public partial class ASP_PersonalBusiness_FI_GroupBusinessMark : Master.Master
{

    #region Initialization
    /// <summary>
    /// 初始化界面
    /// </summary>
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化业务
            InitDropDownList(context, selTradeType, "QUERYTRADETYPE", "");

            //初始化商家
            InitDropDownList(context, selShop, "QUERYTRADETYPESHOP", "");

         
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
        }
    }
    #endregion

    #region Private
    /// <summary>
    /// 初始化DropDownList
    /// </summary>
    /// <param name="context">全局帮助类</param>
    /// <param name="lst">需要绑定的下拉框</param>
    /// <param name="funcCode">存储过程对应方法</param>
    /// <param name="vars">参数</param>
    /// <returns></returns>
    public static void InitDropDownList(CmnContext context, DropDownList lst, string funcCode, params string[] vars)
    {
        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = funcCode;

        StoreProScene storePro = new StoreProScene();
        DataTable dt = storePro.Execute(context, pdo);

        FillDropDownList(lst, dt, true);
    }
    /// <summary>
    /// 填充DropDownList
    /// </summary>
    /// <param name="ddl">填充的下拉框</param>
    /// <param name="dt">填充表</param>
    /// <param name="empty">是否有全选项</param>
    public static void FillDropDownList(DropDownList ddl, DataTable dt, bool empty)
    {
        ddl.Items.Clear();

        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        Object[] itemArray;
        ListItem li;
        for (int i = 0; i < dt.Rows.Count; ++i)
        {
            itemArray = dt.Rows[i].ItemArray;
            li = new ListItem("" + (String)itemArray[1] + ":" + itemArray[0], (String)itemArray[1]);
            ddl.Items.Add(li);
        }
    }

   
    /// <summary>
    /// 标记时输入性验证
    /// </summary>
    /// <returns>返回true时可以录入</returns>
    private Boolean IsEntriedValidate()
    {
        //对团购劵号进行验证
        String strGroupBuyNo = txtGroupBuyNO.Text.Trim();

        if (strGroupBuyNo == "")
            context.AddError("团购劵号不能为空");

        //对员工姓名进行非空、长度检验
        String strShop = selShop.SelectedValue;

        if (strShop == "")
            context.AddError("团购商城不能为空");

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "QUERYGROUPBUYEXIST";

        pdo.var1 = txtGroupBuyNO.Text;
        pdo.var2 = selShop.SelectedValue;

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);


        if (data != null && data.Rows.Count > 0)
        {
            context.AddError("该商城团购劵号已经存在");
        }

        if (context.hasError())
            return false;
        else
            return true;
    }

    /// <summary>
    /// 查询
    /// </summary>
    /// <returns>返回查询到的DataTable</returns>
    private DataTable QueryData()
    {
        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "QUERYGROUPBUYMARK";

        pdo.var1 = DateTime.Now.ToString("yyyyMMdd");
        pdo.var2 = DateTime.Now.ToString("yyyyMMdd");
        pdo.var3 = context.s_UserID;
        pdo.var5 = context.s_DepartID;
        pdo.var6 = selTradeType.SelectedValue;
        pdo.var7 = txtCardno.Text.Trim();//add by youyue2015-12-25

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        UserCardHelper.resetData(gvResult, data);

        return data;
    }
    /// <summary>
    /// 返回cell
    /// </summary>
    /// <param name="cell">变量Cell</param>
    /// <returns>返回指定Cell的text值</returns>
    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }
    #endregion

    #region Event Handler
    /// <summary>
    /// 查询事件
    /// </summary>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (context.hasError()) return;

        DataTable data = QueryData();
      
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
    }

    /// <summary>
    /// 录入事件
    /// </summary>
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!IsEntriedValidate())
            return;

        string msg = "";

        double money = 0.0;//统计关联业务的金额
        int count = 0;

        //将勾选的业务存入msg字符串中
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkTradeList");
            if (cb != null && cb.Checked)
            {
                count++;
                if (count == 1)
                {
                    msg += gvr.Cells[1].Text;
    
                }
                else
                {
                    msg += "," + gvr.Cells[1].Text;
         
                }
                    
                money += Convert.ToDouble(GetTableCellValue(gvr.Cells[4]));
                money += Convert.ToDouble(GetTableCellValue(gvr.Cells[5]));
                money += Convert.ToDouble(GetTableCellValue(gvr.Cells[6]));
                money += Convert.ToDouble(GetTableCellValue(gvr.Cells[7]));
                money += Convert.ToDouble(GetTableCellValue(gvr.Cells[8]));
                money += Convert.ToDouble(GetTableCellValue(gvr.Cells[9]));
            }
        }

        //至少选择一条业务
        if (count == 0)
        {
            context.AddError("请至少选中一条业务信息！");
            return;
        }
       
     
        SP_FI_GroupBuyPDO pdo = new SP_FI_GroupBuyPDO();
        pdo.msgTradeIds = msg;
        pdo.msgGroupCode = txtGroupBuyNO.Text;
        pdo.msgRemark = txtComment.Text; ;
        pdo.msgShopNo = selShop.SelectedValue;
        PDOBase pdoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out pdoOut);

        if (!ok)
        {
            AddMessage(pdoOut.retMsg);
        }
        else
        {
            QueryData();
            AddMessage(string.Format("录入成功,已匹配{0}笔业务,金额共计{1}元",count,money));
        }
    }
    /// <summary>
    /// RowDataBound
    /// </summary>
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.Footer
            )
        {
            e.Row.Cells[1].Visible = false;    //TRADEID隐藏
        }
    }

    /// <summary>
    /// 分页事件
    /// </summary>
    protected void gvResult_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    #endregion
}