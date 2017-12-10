using System;
using System.Data;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TM;
using Common;
using TDO.PartnerShip;
using TDO.BusinessCode;
using PDO.ProvisionNote;
using Master;


/***************************************************************
 * 功能名: 网点结算单元佣金维护
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2011/12/28    liuh			初次开发
 ****************************************************************/
public partial class ASP_PartnerShip_PS_PNDeptComScheme : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            //设置GridView绑定的DataTable
            lvwBalComSQuery.DataSource = new DataTable();
            lvwBalComSQuery.DataBind();
            lvwBalComSQuery.SelectedIndex = -1;

            InitControls();
        }
    }

    /// <summary>
    /// 页面控件初始化
    /// </summary>
    private void InitControls()
    {
        //初始化手续费
        PNHelper.initPaperTypeList(context, ddlComScheme, "QUERYFEE", "");
        PNHelper.initPaperTypeList(context, selComScheme, "QUERYFEE", "");

        //初始化代理网点
        PNHelper.initPaperTypeList(context, ddlBalUnit, "QUERYSELSUPBALUNIT", "");
        PNHelper.initPaperTypeList(context, selBalUnit, "QUERYSELSUPBALUNIT", "");

        lvwBalComSQuery.DataKeyNames =
          new string[] { "ID", "BALUNITNO", "BALUNIT", "COMSCHEMENO", "SLOPE", "BEGINTIME", "ENDTIME", "REMARK" };

        ClearText();
    }

    /// <summary>
    /// 编辑框内的控件初始化
    /// </summary>
    private void ClearText()
    {
        lvwBalComSQuery.SelectedIndex = -1;
        selBalUnit.SelectedValue = "";
        selComScheme.SelectedValue = "";
        txtBeginTime.Text = DateTime.Now.ToString("yyyy-MM");

        txtEndTime.Enabled = false;
        txtEndTime.Text = "2050-12";
        chkEndDate.Checked = true;

    }

    #region 页面控件事件
    protected void btnQuery_Click(object sender, EventArgs e)
    {

        //查询结算单元信息
        SP_PN_QueryPDO pdo = new SP_PN_QueryPDO();
        pdo.funcCode = "QUERYSCHEME";
        pdo.var1 = ddlBalUnit.SelectedValue;
        pdo.var2 = ddlComScheme.SelectedValue;

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        UserCardHelper.resetData(lvwBalComSQuery, data);

        ClearText();
    }

    public void lvwBalComSQuery_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwBalComSQuery.PageIndex = e.NewPageIndex;
        SP_PN_QueryPDO pdo = new SP_PN_QueryPDO();
        pdo.funcCode = "QUERYSCHEME";
        pdo.var1 = ddlBalUnit.SelectedValue;
        pdo.var2 = ddlComScheme.SelectedValue;

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        UserCardHelper.resetData(lvwBalComSQuery, data);
        lvwBalComSQuery.DataBind();

        selBalUnit.SelectedValue = "";
        ClearText();
    }

    protected void lvwBalComSQuery_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwBalComSQuery','Select$"
                + e.Row.RowIndex + "')");
        }
    }

    public void lvwBalComSQuery_SelectedIndexChanged(object sender, EventArgs e)
    {
        selBalUnit.Items.Clear();
        PNHelper.initPaperTypeList(context, selBalUnit, "QUERYSELSUPBALUNIT", "");

        //选择列表框一行记录后,设置结算单元佣金规则信息增加,修改,删除区域中数据
        txtEndTime.Enabled = true;

        selBalUnit.SelectedValue = getDataKeys("BALUNITNO").Trim();

        try
        {
            txtBeginTime.Text = DateTime.Parse(getDataKeys("BEGINTIME")).ToString("yyyy-MM", null);
            txtEndTime.Text = DateTime.Parse(getDataKeys("ENDTIME")).ToString("yyyy-MM", null);
        }
        catch (Exception)
        {
            txtBeginTime.Text = "";
            txtEndTime.Text = "";
        }

        selComScheme.SelectedValue = getDataKeys("COMSCHEMENO");

    }

    protected void chkEndDate_CheckedChanged(object sender, EventArgs e)
    {
        if (chkEndDate.Checked)
        {
            txtEndTime.Enabled = false;
            txtEndTime.Text = "2050-12";
        }
        else
        {
            txtEndTime.Enabled = true;
            txtEndTime.Text = "";
        }
    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        //增加结算单元对应佣金规则信息
        if (!BalComsAddValidation()) return;

        //检测佣金方案终止时间是否小于当前时间

        if (CompareEndTimeAndNow()) return;

        context.SPOpen();
        context.AddField("P_BALUNITNO").Value = this.selBalUnit.SelectedValue;
        context.AddField("P_COMSCHEMENO").Value = this.selComScheme.SelectedValue;
        context.AddField("P_BEGINTIME").Value = this.txtBeginTime.Text.Trim() + "-01 00:00:00";
        context.AddField("P_ENDTIME").Value = GetEndTime();
        context.AddField("P_BALCOMSID").Value = "";
        context.AddField("P_OPTYPE").Value = "ADD";


        bool ok = context.ExecuteSP("SP_PS_DEPTBALCOMSCHEME");

        if (ok)
        {
            AddMessage("M008104112");
            btnQuery_Click(sender, e);
        }
    }

    protected void btnModify_Click(object sender, EventArgs e)
    {
        //修改结算单元对应佣金规则信息

        if (!BalComsModifyDelValidation("MODIFY")) return;


        context.SPOpen();
        context.AddField("P_BALUNITNO").Value = this.selBalUnit.SelectedValue;
        context.AddField("P_COMSCHEMENO").Value = this.selComScheme.SelectedValue;
        context.AddField("P_BEGINTIME").Value = this.txtBeginTime.Text.Trim() + "-01 00:00:00";
        context.AddField("P_ENDTIME").Value = GetEndTime();
        context.AddField("P_BALCOMSID").Value = getDataKeys("ID");
        context.AddField("P_OPTYPE").Value = "MODIFY";

        bool ok = context.ExecuteSP("SP_PS_DEPTBALCOMSCHEME");

        if (ok)
        {
            AddMessage("M008104111");
            btnQuery_Click(sender, e);
        }

    }

    protected void btnDel_Click(object sender, EventArgs e)
    {
        //删除结算单元对应佣金规则信息
        if (!BalComsModifyDelValidation("DEL")) return;

        context.SPOpen();
        context.AddField("P_BALUNITNO").Value = this.selBalUnit.SelectedValue;
        context.AddField("P_COMSCHEMENO").Value = this.selComScheme.SelectedValue;
        context.AddField("P_BEGINTIME").Value = this.txtBeginTime.Text.Trim() + "-01 00:00:00";
        context.AddField("P_ENDTIME").Value = GetEndTime();
        context.AddField("P_BALCOMSID").Value = getDataKeys("ID");
        context.AddField("P_OPTYPE").Value = "DELETE";

        bool ok = context.ExecuteSP("SP_PS_DEPTBALCOMSCHEME");

        if (ok)
        {
            AddMessage("M008104113");
            btnQuery_Click(sender, e);
        }
    }

    #endregion

    /// <summary>
    /// 修改删除前的验证
    /// </summary>
    /// <param name="type"></param>
    /// <returns></returns>
    private Boolean BalComsModifyDelValidation(string type)
    {
        //当没有选择结算单元时,不能执行修改处理
        if (lvwBalComSQuery.SelectedIndex == -1)
        {
            context.AddError("A008104004");
            return false;
        }

        //选定的结算单元名称修改后,不能执行修改操作
        if (selBalUnit.SelectedValue != getDataKeys("DBALUNITNO"))
        {
            context.AddError("A008104005", selBalUnit);
            return false;
        }

        //选定的结算单元对应的佣金规则修改后,不能执行修改操作
        if (selComScheme.SelectedValue != getDataKeys("DCOMSCHEMENO"))
        {
            context.AddError("A008104001", selComScheme);
            return false;
        }

        if (type.Equals("DEL"))
        {
            //不是选定的结算单元对应的起始和终止年月时,不能执行删除操作
            if (txtBeginTime.Text.Trim() != DateTime.Parse(getDataKeys("BEGINTIME")).ToString("yyyy-MM", null))
            {
                context.AddError("A008104041", txtBeginTime);
            }
            if (txtEndTime.Text.Trim() != DateTime.Parse(getDataKeys("ENDTIME")).ToString("yyyy-MM", null))
            {
                context.AddError("A008104042", txtEndTime);
            }
        }
        else
        {
            //佣金起始日期有效性检查
            CheckComsDate();

            string strBeginTime = DateTime.Parse(getDataKeys("BEGINTIME")).ToString("yyyy-MM", null);
            string strEndTime = DateTime.Parse(getDataKeys("ENDTIME")).ToString("yyyy-MM", null);

            //修改佣金的起始和终止时间
            if (txtEndTime.Text.Trim() == strEndTime && txtBeginTime.Text.Trim() == strBeginTime)
            {
                context.AddError("A008104038");
            }
        }

        if (context.hasError())
            return false;
        else
            return true;

    }


    /// <summary>
    /// 添加前的验证
    /// </summary>
    /// <returns></returns>
    private Boolean BalComsAddValidation()
    {

        //选中一个结算单元时
        if (lvwBalComSQuery.SelectedIndex != -1)
        {
            //当所有的信息都没有修改时不能增加该结算单元佣金规则
            if (
                selBalUnit.SelectedValue == getDataKeys("DBALUNITNO") &&
                selComScheme.SelectedValue == getDataKeys("DCOMSCHEMENO") &&
                txtBeginTime.Text == DateTime.Parse(getDataKeys("BEGINTIME")).ToString("yyyy-MM", null) &&
                txtEndTime.Text == DateTime.Parse(getDataKeys("ENDTIME")).ToString("yyyy-MM", null)
            )
            {
                context.AddError("A008104039");
                return false;
            }
        }

        //结算单元是否为空
        if (selBalUnit.SelectedValue == "")
        {
            context.AddError("A008104006", selBalUnit);
            return false;
        }


        //佣金规则是否为空
        string strComScheme = selComScheme.SelectedValue;
        if (strComScheme == "")
        {
            context.AddError("A008104007", selComScheme);
        }

        //佣金起始终止日期有效性检查

        CheckComsDate();

        if (context.hasError())
            return false;
        else
            return true;

    }

    public String getDataKeys(string keysname)
    {
        try
        {
            string value = lvwBalComSQuery.DataKeys[lvwBalComSQuery.SelectedIndex][keysname].ToString();

            return value.Trim();
        }
        catch
        {
            return "";
        }
    }

    #region 开始日期结束日期相关
    /// <summary>
    /// 检查佣金方案的终止时间是否小于当期时间 
    /// </summary>
    /// <returns></returns>
    private Boolean CompareEndTimeAndNow()
    {
        string strEndTime = GetEndTime().Replace("-", "").Replace(":", "");

        DateTime end = DateTime.ParseExact(strEndTime, "yyyyMMdd HHmmss", null);
        DateTime nowd = DateTime.Now;

        if (DateTime.Compare(nowd, end) > 0)
        {
            context.AddError("A008107125", txtEndTime);
            return true;
        }
        return false;
    }

    /// <summary>
    /// 拼接结束时间
    /// </summary>
    /// <returns></returns>
    private string GetEndTime()
    {
        string endtime = "";
        if (chkEndDate.Checked)
        {
            endtime = "2050-12-31 23:59:59";
        }
        else
        {
            DateTime end = DateTime.ParseExact(txtEndTime.Text.Trim(), "yyyy-MM", null);
            DateTime enddate = end.AddMonths(1).AddDays(-1);

            string mon = enddate.Month >= 10 ? enddate.Month.ToString() : "0" + enddate.Month;
            string day = enddate.Day >= 10 ? enddate.Day.ToString() : "0" + enddate.Day;

            endtime = enddate.Year + "-" + mon + "-" + day + " 23:59:59";
        }

        return endtime;
    }

    /// <summary>
    /// 检查日期有效性
    /// </summary>
    private void CheckComsDate()
    {
        string strBeginTime = txtBeginTime.Text.Trim();
        DateTime? beginTime = null;

        if (strBeginTime == "")
        {
            context.AddError("A008104008", txtBeginTime);
        }

        else if (!Validation.isDate(strBeginTime, "yyyy-MM"))
        {
            context.AddError("A008104035", txtBeginTime);
        }
        else
        {
            beginTime = DateTime.ParseExact(strBeginTime, "yyyy-MM", null);
        }

        //检查是否选择了无效期
        string strEndTime = txtEndTime.Text.Trim();

        if (!chkEndDate.Checked)
        {
            if (strEndTime == "")
            {
                context.AddError("A008104009", txtEndTime);
            }
            else if (!Validation.isDate(strEndTime, "yyyy-MM"))
            {
                context.AddError("A008104036", txtEndTime);
            }
            else if (beginTime != null)
            {
                CompareComsDate(strBeginTime, strEndTime, txtEndTime);
            }
        }

        if (chkEndDate.Checked && beginTime != null)
        {
            CompareComsDate(strBeginTime, "2050-12", txtBeginTime);
        }
    }

    /// <summary>
    /// 判断开始日期要早于结束日期
    /// </summary>
    /// <param name="datest"></param>
    /// <param name="dateend"></param>
    /// <param name="txtBox"></param>
    private void CompareComsDate(string datest, string dateend, TextBox txtBox)
    {
        DateTime begin = DateTime.ParseExact(datest, "yyyy-MM", null);
        DateTime end = DateTime.ParseExact(dateend, "yyyy-MM", null);

        if (DateTime.Compare(begin, end) > 0)
        {
            context.AddError("A008104037", txtBox);
        }
    }
    #endregion

    #region 根据输入结算单元名称初始化下拉选项
    /// <summary>
    /// 根据输入结算单元名称初始化下拉选项
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void txtBalUnitName_Changed(object sender, EventArgs e)
    {
        selBalUnit.Items.Clear();

        context.DBOpen("Select");
        System.Text.StringBuilder sql = new System.Text.StringBuilder();

        sql.Append("SELECT BALUNIT, BALUNITNO	FROM TF_SELSUP_BALUNIT WHERE ");
        //模糊查询单位名称，并在列表中赋值
        string strBalname = txtBalUnitName.Text.Trim().Replace('\'', '\"');
        if (strBalname.Length != 0)
        {
            sql.Append(" BALUNIT LIKE '%" + strBalname + "%'");
        }
        sql.Append("ORDER BY BALUNITNO");

        System.Data.DataTable table = context.ExecuteReader(sql.ToString());
        GroupCardHelper.fill(selBalUnit, table, true);
    }
    #endregion
}
