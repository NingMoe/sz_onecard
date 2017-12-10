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
using PDO.Warn;
using System.Text;
using TDO.BalanceChannel;
using Common;

/***************************************************************
 *
 * 系统名  : 城市一卡通系统
 * 子系统名: 异常处理 - 自动回收结算单元配置 页面
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2011/7/8    王定喜           初次开发 
 * 2011/7/8    王定喜           对需要自动回收的结算单元进行配置
 ***************************************************************
 */
public partial class ASP_SpecialDeal_SD_AutoBalUnitRecycle : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
        lvwTypeList.DataKeyNames = new string[] { "BALUNITNO", "STATE", "EFFECTIVEDATE"};
        UserCardHelper.resetData(lvwTypeList, SPHelper.callSDQuery(context, "QryAutoBalUnit", txtSBalUnitNo.Text.Trim()));
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        UserCardHelper.resetData(lvwTypeList, SPHelper.callSDQuery(context, "QryAutoBalUnit",txtSBalUnitNo.Text.Trim()));
    }


    protected void lvwStaff_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwTypeList','Select$" + e.Row.RowIndex + "')");
        }
    }


    protected void lvwStaff_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtInputBalUnitNo.Text = getDataKeys2("BALUNITNO");
        txtEffectDate.Text = getDataKeys2("EFFECTIVEDATE");
        chkIsState.Checked = getDataKeys2("STATE")=="1"?true:false;
        //txtSort.Text = getDataKeys2("SORTNO");
        //txtTypecode.Text = getDataKeys2("TYPECODE");
        //txtTypeName.Text = getDataKeys2("TYPENAME");
        //chkIsshow.Checked = getDataKeys2("ISSHOW") == "0" ? false : true;
        //chkIsFlow.Checked = getDataKeys2("ISFLOW") == "1" ? true : false;
    }

    public String getDataKeys2(String keysname)
    {
        try {

            return lvwTypeList.DataKeys[lvwTypeList.SelectedIndex][keysname].ToString();
        }
        catch 
        {
            return "";
        }
        
    }

    public void validate()
    {
        if (!Common.Validation.isDate(txtEffectDate.Text, "yyyy-MM-dd"))
        {
            context.AddError("日期格式输入有误，应为：yyyy-MM-dd", txtEffectDate);
        }
        if (Common.Validation.strLen(txtInputBalUnitNo.Text.Trim()) != 8 || !Common.Validation.isCharNum(txtInputBalUnitNo.Text.Trim()))
        {
            context.AddError("结算单元编码应为8位数字或字母", txtInputBalUnitNo);
        }
        //if (txtSort.Text != "")
        //{
        //    if (!Common.Validation.isNum(txtSort.Text))
        //    {
        //        context.AddError("排序号应为数字",txtSort);
        //    }
        //}
        //if (string.IsNullOrEmpty(txtTypecode.Text))
        //{
        //    context.AddError("类型编码不能为空",txtTypecode);
        //}
        //else if (!Common.Validation.isNum(txtTypecode.Text)|| txtTypecode.Text.Length > 4 || txtTypecode.Text.Length % 2 != 0)
        //{
        //    context.AddError("类型编码应为2位或4位数字", txtTypecode);
        //}
        //if (string.IsNullOrEmpty(txtTypeName.Text))
        //{
        //    context.AddError("类型名称不能为空", txtTypeName);
        //}
    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        try
        {
            validate();
            

            //判断是否苏州公交或出租行业的结算单元
            if (txtInputBalUnitNo.Text.Trim() == "01000001")
            {
                context.AddError("苏州公交的结算单元01000001不能配置", txtInputBalUnitNo);
            }
            else if (txtInputBalUnitNo.Text.Trim().Substring(0, 2) == "02")
            {
                context.AddError("出租行业的结算单元不能配置", txtInputBalUnitNo);
            }
            else
            {
                DataTable dt = tm.selByPKDataTable(context, string.Format("select count(*) from tf_trade_balunit where balunitno='{0}'", txtInputBalUnitNo.Text.Trim()), 0);
                Object obj = dt.Rows[0].ItemArray[0];
                if (Convert.ToInt32(obj) < 1)
                {
                    context.AddError("结算单元编码不存在，请检查", txtInputBalUnitNo);
                }
            }
            if (context.hasError())
                return;
            context.DBOpen("Insert");
            context.ExecuteNonQuery(string.Format("insert into TD_BALUNIT_AUTORENEW (BALUNITNO, STATE, UPDATESTAFFNO, UPDATETIME, USETAG, EFFECTIVEDATE) values('{0}','{1}','{2}',to_date('{3}','yyyy-mm-dd hh24:mi:ss'),'{4}',to_date('{5}','yyyy-mm-dd hh24:mi:ss'))", txtInputBalUnitNo.Text.Trim(), chkIsState.Checked ? "1" : "0", context.s_UserID, DateTime.Now.ToString(), chkUseTag.Checked ? "1" : "0", txtEffectDate.Text.Trim()));
            context.DBCommit();
            AddMessage("结算单元配置添加成功");
            UserCardHelper.resetData(lvwTypeList, SPHelper.callSDQuery(context, "QryAutoBalUnit", txtSBalUnitNo.Text.Trim()));
            ClearType();
        }
        catch (Exception ex)
        {
            context.AddError(ex.Message.Contains("ORA-00001")?"结算单元编码不能重复添加":ex.Message);
        }
    }
    protected void btnModify_Click(object sender, EventArgs e)
    {
        try
        {
           
            if (string.IsNullOrEmpty(getDataKeys2("BALUNITNO")))
            {
                context.AddError("请选择一条记录");
                return;
            }
            validate();
            
            if (txtInputBalUnitNo.Text.Trim() != getDataKeys2("BALUNITNO"))
            {
                context.AddError("结算单元编码不能修改，请检查");
            }
            if (context.hasError())
                return;
            context.DBOpen("Update");
            context.ExecuteNonQuery(string.Format("update  TD_BALUNIT_AUTORENEW set BALUNITNO='{0}', STATE='{1}', UPDATESTAFFNO='{2}', UPDATETIME=to_date('{3}','yyyy-mm-dd hh24:mi:ss'), USETAG='{4}', EFFECTIVEDATE=to_date('{5}','yyyy-mm-dd hh24:mi:ss') where BALUNITNO='{0}'", getDataKeys2("BALUNITNO"), chkIsState.Checked ? "1" : "0", context.s_UserID, DateTime.Now.ToString("yyyy-MM-dd "), chkUseTag.Checked ? "1" : "0", txtEffectDate.Text.Trim()));
            context.DBCommit();
            AddMessage("结算单元配置修改成功");
           
            UserCardHelper.resetData(lvwTypeList, SPHelper.callSDQuery(context, "QryAutoBalUnit", txtSBalUnitNo.Text.Trim()));
            ClearType();

        }
        catch (Exception ex)
        {
            context.AddError(ex.Message.Contains("ORA-00001") ? "结算单元编码不能重复添加" : ex.Message);
        }
    }
    protected void btnDelete_Click(object sender, EventArgs e)
    {
        try
        {
            if (string.IsNullOrEmpty(getDataKeys2("BALUNITNO")))
            {
                context.AddError("请选择一条记录");
                return;
            }
            validate();
            if (txtInputBalUnitNo.Text.Trim() != getDataKeys2("BALUNITNO"))
            {
                context.AddError("结算单元编码不能修改，请检查");
            }
            if (context.hasError())
                return;
            context.DBOpen("Delete");
            context.ExecuteNonQuery(string.Format("delete from  TD_BALUNIT_AUTORENEW where BALUNITNO='{0}'", getDataKeys2("BALUNITNO")));
            context.DBCommit();
            AddMessage("结算单元配置删除成功");
            UserCardHelper.resetData(lvwTypeList, SPHelper.callSDQuery(context, "QryAutoBalUnit", txtSBalUnitNo.Text.Trim()));
            ClearType();
        }
        catch (Exception ex)
        {
            context.AddError(ex.Message.Contains("ORA-00001") ? "结算单元编码不能重复添加" : ex.Message);
        }
    }

    private void ClearType()
    {
        //清除输入的员工信息
        txtInputBalUnitNo.Text = "";
        txtEffectDate.Text = "";
        chkIsState.Checked = false;
    }
}
