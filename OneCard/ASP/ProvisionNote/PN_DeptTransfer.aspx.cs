using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Master;
using PDO.ProvisionNote;
using TDO.UserManager;

/**********************************
 * 网点解款确认
 * 2014-08-17
 * jiangbb
 * 初次编写
 * ********************************/

public partial class ASP_ProvisionNote_PN_DeptTransfer : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack)
        {
            if (hidShowCheckQuery.Value == "1")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showCheckQuery", "showCheckQuery();", true);
            }
            return;
        }
        //初始化订单表格

        gvBank.DataSource = new DataTable();
        gvBank.DataBind();
        //初始化账单表格

        gvTrade.DataSource = query();
        gvTrade.DataBind();

        //初始化部门数据
        FIHelper.selectDept(context, selDept, true);

        selTradeType_Changed(sender, e);

        //验证是否有全网点解款的操作权限
        if (!HasOperPower("201401"))
        {
            selDept.SelectedValue = context.s_DepartID;
            selDept.Enabled = false;
        }
    }

    /// <summary>
    /// 验证是否有操作权限
    /// </summary>
    /// <param name="powerCode">权限编码</param>
    /// <returns></returns>
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

    protected void selTradeType_Changed(object sender, EventArgs e)
    {
        if (selTradeType.SelectedValue == "0")
        {
            lbWh.Visible = true;
            txtToDate.Visible = true;
        }
        else if (selTradeType.SelectedValue == "1")
        {
            lbWh.Visible = false;
            txtToDate.Visible = false;
        }
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (selTradeType.SelectedValue != "0")
        {
            if (string.IsNullOrEmpty(txtFromDate.Text.Trim()))
            { 
                context.AddError("请选择解款日期",txtFromDate);
                return;
            }
        }

        SP_PN_QueryPDO pdo = new SP_PN_QueryPDO();
        SP_PN_QueryPDO pdo1 = new SP_PN_QueryPDO();

        if (selTradeType.SelectedValue == "0")
        {
            pdo.funcCode = "QUERYBANKOCAB";
            pdo.var1 = selDept.SelectedValue;

            pdo1.funcCode = "QUERYTRADECODE";
            pdo1.var1 = txtFromDate.Text.Trim();
            pdo1.var2 = txtToDate.Text.Trim();
            pdo1.var3 = txtFromMoney.Text;
            pdo1.var4 = txtToMoney.Text;
            pdo1.var5 = selDept.SelectedValue;
        }
        else
        {
            pdo.funcCode = "QUERYBANKOCAB_RE";
            pdo.var1 = txtFromDate.Text.Trim();
            pdo.var2 = selDept.SelectedValue;
            pdo.var3 = txtFromMoney.Text;
            pdo.var4 = txtToMoney.Text;

            pdo1.funcCode = "QUERYTRADECODE_RE";
            pdo1.var1 = txtFromDate.Text.Trim();
            pdo1.var3 = txtFromMoney.Text;
            pdo1.var4 = txtToMoney.Text;
            pdo1.var5 = selDept.SelectedValue;
        }

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        StoreProScene storePro1 = new StoreProScene();
        DataTable data1 = storePro.Execute(context, pdo1);

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("银行查询结果为空");
        }
        if (data1 == null || data1.Rows.Count == 0)
        {
            AddMessage("业务查询结果为空");
        }

        UserCardHelper.resetData(gvBank, data);
        UserCardHelper.resetData(gvTrade, data1);

    }

    protected void gvBank_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[8].Visible = false;    //TRADEID隐藏
        }
    }

    protected void gvTrade_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header || e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[7].Visible = false;    //TRADEID隐藏
        }
    }

    protected void chkAllBank_CheckedChanged(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        if (cbx.ID == "chkAllBank")
        {
            foreach (GridViewRow gvr in gvBank.Rows)
            {

                CheckBox ch = (CheckBox)gvr.FindControl("chkBankList");
                ch.Checked = cbx.Checked;
            }
        }
    }

    protected void chkAllTrade_CheckedChanged(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        if (cbx.ID == "chkAllTrade")
        {
            foreach (GridViewRow gvr in gvTrade.Rows)
            {

                CheckBox ch = (CheckBox)gvr.FindControl("chkTradeList");
                ch.Checked = cbx.Checked;
            }
        }
    }

    // 提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        //清空临时表信息

        clearTempTable();

        //选择审核的订单和账单入临时表
        if (!RecordIntoTmp()) return;

        //解款
        if (selTradeType.SelectedValue == "0")
        {
            context.SPOpen();
            context.AddField("P_SESSIONID").Value = Session.SessionID;
            context.AddField("P_DEPTID").Value = selDept.SelectedValue;
            bool ok = context.ExecuteSP("SP_PN_DEPTTRANSFERADD");

            if (ok)
            {
                context.AddMessage("解款成功");
                hidTypeValue.Value = "";
                btnQuery_Click(sender, e);
            }
        }
        //取消解款
        else
        {
            context.SPOpen();
            context.AddField("P_SESSIONID").Value = Session.SessionID;
            context.AddField("P_DATE").Value = txtFromDate.Text;
            context.AddField("P_DEPTID").Value = selDept.SelectedValue;
            bool ok = context.ExecuteSP("SP_PN_DEPTTRANSFERCANCEL");

            if (ok)
            {
                context.AddMessage("取消解款成功");
                hidTypeValue.Value = "";
                btnQuery_Click(sender, e);
            }
        }

    }

    private void clearTempTable()//清空临时表
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON");
        context.DBCommit();
    }

    private bool RecordIntoTmp()
    {
        //选中记录入临时表
        context.DBOpen("Insert");
        int bankCount = 0;
        int tradeCount = 0;
        int banksummoney = 0;
        int tradesummoney = 0;

        List<string> company = new List<string>();
        foreach (GridViewRow gvr in gvBank.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkBankList");
            if (cb != null && cb.Checked)
            {
                bankCount++;
                //银行帐务录入临时表
                context.ExecuteNonQuery("insert into TMP_COMMON (F0,F1,F2,F3) values('" +
                     Session.SessionID + "', '0','" + Convert.ToInt32(Convert.ToDecimal(gvr.Cells[2].Text) * 100) + "','" + gvr.Cells[8].Text + "')");

                banksummoney += Convert.ToInt32(Convert.ToDecimal(gvr.Cells[2].Text) * 100);
            }
        }
        //校验是否选择了银行帐务

        if (bankCount <= 0)
        {
            context.AddError("请选择银行帐务信息！");
            return false;
        }


        foreach (GridViewRow gvr in gvTrade.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("chkTradeList");
            if (cb != null && cb.Checked)
            {
                tradeCount++;
                //业务帐务记录入临时表
                context.ExecuteNonQuery("insert into TMP_COMMON (F0,F1,F2,F3,F4) values('" +
                     Session.SessionID + "', '1','" + Convert.ToInt32(Convert.ToDecimal(gvr.Cells[2].Text) * 100) + "','" + gvr.Cells[7].Text + "','"+gvr.Cells[1].Text+"')");

                tradesummoney += Convert.ToInt32(Convert.ToDecimal(gvr.Cells[2].Text) * 100);
            }
        }

        //校验是否选择了业务帐务

        if (tradeCount <= 0)
        {
            context.AddError("请选择业务帐务信息！");
            return false;
        }

        #region 注释
        //if (bankCount != 1 && tradeCount != 1)
        //{
        //    context.AddError("银行帐务与业务帐务对应关系错误！");
        //    return false;
        //}

        ////记录对应关系 0：银行业务多对一业务业务 1：银行业务一对多业务业务 
        //hidTypeValue.Value = bankCount == 1 ? "1" : "0";
        #endregion
        //校验选择的银行帐务金额是否等于业务帐务金额
        if (banksummoney != tradesummoney)
        {
            context.AddError("银行帐务金额与业务帐务金额不匹配，请重新选择！");
            return false;
        }

        if (context.hasError())
        {
            return false;
        }
        else
        {
            context.DBCommit();
            return true;
        }
    }



    protected void gvOrderList_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvOrderList','Select$" + e.Row.RowIndex + "')");
        }
    }

    /// <summary>
    /// 查询账单
    /// </summary>
    /// <returns></returns>
    private ICollection query()
    {

        return new DataView();
    }
}
