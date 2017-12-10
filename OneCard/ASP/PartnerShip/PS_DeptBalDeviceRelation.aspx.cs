using System;
using System.Data;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TM;
using TDO.PartnerShip;
using TDO.UserManager;
using System.IO;
using System.Text;
using System.Collections;

/***************************************************************
 * 功能名: 合作伙伴_代理商户结算设备关系
 ****************************************************************/
public partial class ASP_PartnerShip_PS_DeptBalDeviceRelation : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            //设置GridView绑定的DataTable
            lvwRelation.DataSource = new DataTable();
            lvwRelation.DataBind();
            lvwRelation.SelectedIndex = -1;

            context.DBOpen("Select");
            string sql = @"SELECT DBALUNIT, DBALUNITNO	FROM TF_DEPT_BALUNIT WHERE USETAG = '1' AND DEPTTYPE = '2' ORDER BY DBALUNITNO";
            System.Data.DataTable table = context.ExecuteReader(sql);
            GroupCardHelper.fill(ddlBalUnitInp, table, true);
            GroupCardHelper.fill(ddlBalUnit, table, true);
        }
    }

    #region 查询
    /// <summary>
    ///  查询按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        gvResult.Visible = false;
        lvwRelation.Visible = true;
        this.btnDel.Enabled = true;

        List<string> vars = new List<string>();
        vars.Add(this.ddlBalUnit.SelectedValue);
        vars.Add(this.txtBegDeviceNo.Text.Trim());
        vars.Add(this.txtEndDeviceNo.Text.Trim());

        //查询结算单元信息
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryDeptBalDeviceRelation", vars.ToArray());

        UserCardHelper.resetData(lvwRelation, data);

        lvwRelation.SelectedIndex = -1;
        ddlBalUnitInp.SelectedValue = "";
    }
    #endregion

    #region 导入后的提交
    /// <summary>
    /// 导入后的提交
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {

        context.SPOpen();
        context.AddField("p_sessionID").Value = Session.SessionID;
        context.AddField("P_OPTYPE").Value = "ADD";

        bool ok = context.ExecuteSP("SP_PS_DeptBalDeviceRelation");
        if (ok)
        {
            AddMessage("M008104170:代理商户结算设备关系增加成功");
            clearGridViewData();
            clearTempTable();
            gvResult.Visible = false;
            lvwRelation.Visible = true;
            btnQuery_Click(sender, e);
        }
    }
    #endregion

    #region 删除按钮事件
    /// <summary>
    /// 删除按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnDel_Click(object sender, EventArgs e)
    {
        string session = Session.SessionID;

        FillToTmpCommon(session);
        if (context.hasError()) return;

        context.SPOpen();
        context.AddField("p_sessionID").Value = Session.SessionID;
        context.AddField("P_OPTYPE").Value = "DEL";

        bool ok = context.ExecuteSP("SP_PS_DeptBalDeviceRelation");
        if (ok)
        {
            AddMessage("M008104170:代理商户结算设备关系增加成功");
            clearGridViewData();
            clearTempTable();
            this.lvwRelation.Visible = true;
            this.gvResult.Visible = false;
            btnQuery_Click(sender, e);
        }

    }
    /// <summary>
    /// 向临时表添加gv选中行
    /// </summary>
    /// <param name="session">当前会话</param>
    public void FillToTmpCommon(string session)
    {
        // 首先清空临时表
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_BalDeviceRelation_IMP " + " where sessionid = '" + session + "' and optypecode='DEL'");

        // 根据页面数据生成临时表数据
        int count = 0;
        string balUnitno = "";
        string deviceNo = "";
        for (int index = 0; index < lvwRelation.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)lvwRelation.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                balUnitno = lvwRelation.Rows[index].Cells[2].Text.Trim();
                deviceNo = lvwRelation.Rows[index].Cells[4].Text.Trim();
                context.ExecuteNonQuery(@"insert into TMP_BalDeviceRelation_IMP(sessionid, deviceno, balunitno, optypecode) values('" + session + "','" + deviceNo + "','" + balUnitno + "','DEL')");
            }
        }
        context.DBCommit();
        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("A004P03R01: 没有选中任何行");
        }
    }
    #endregion

    #region gv查询结果
    /// <summary>
    /// 查询结果列表翻页事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    public void lvwRelation_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwRelation.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    /// <summary>
    /// 选中gridview当前页所有数据
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void CheckAll(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in lvwRelation.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }
    #endregion

    #region gv导入文件
    /// <summary>
    /// 导入按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnUpload_Click(object sender, EventArgs e)
    {
        if (this.ddlBalUnitInp.SelectedValue.Equals(""))
        {
            context.AddError("A008104961：请选择结算单元", ddlBalUnitInp);
            return;
        }
        clearGridViewData();
        GroupCardHelper.uploadFileValidate(context, FileUpload1);
        if (context.hasError()) return;

        //清空临时表
        clearTempTable();

        context.DBOpen("Insert");
        Stream stream = FileUpload1.FileContent;
        StreamReader reader = new StreamReader(stream, Encoding.GetEncoding("gb2312"));
        string strLine = "";
        int lineCount = 0; int goodLines = 0;
        String[] fields = null;
        Hashtable ht = new Hashtable();

        while (true)
        {
            strLine = reader.ReadLine();
            if (strLine == null)
            {
                break;
            }
            ++lineCount;

            strLine = strLine.Trim();
            if (strLine.Length <= 0)
            {
                continue;
            }

            if (strLine.Length > 32)
            {
                context.AddError("第" + lineCount + "行长度为" + strLine.Length + ", 根据格式定义不能超过32");
                continue;
            }

            fields = strLine.Split(new char[2] { ',', '\t' });
            // 字段数目为2时合法

            if (fields.Length != 1)
            {
                context.AddError("第" + lineCount + "行字段数目为" + fields.Length + ", 根据格式定义必须为1");
                continue;
            }

            dealFileContent(ht, fields, lineCount);
            ++goodLines;
        }

        if (goodLines <= 0)
        {
            context.AddError("A004P01F01: 上传文件为空");
        }

        if (!context.hasError())
        {
            context.DBCommit();
            createGridViewData();
        }
        else
        {
            context.RollBack();
        }

        gvResult.Visible = true;
        lvwRelation.Visible = false;
    }

    private void dealFileContent(Hashtable ht, String[] fields, int lineCount)
    {
        String deviceNo = fields[0].Trim();
        // 卡号
        if (deviceNo.Length > 32)
        {
            context.AddError("第" + lineCount + "行设备序列号长度大于32位");
        }
        else if (!Validation.isCharNum(deviceNo))
        {
            context.AddError("第" + lineCount + "行卡号不全是数字");
        }

        if (!context.hasError())
        {
            context.ExecuteNonQuery("insert into TMP_BalDeviceRelation_IMP(BALUNITNO, DEVICENO, SESSIONID ,OPTYPECODE) values('"
                + ddlBalUnitInp.SelectedValue + "', '" + deviceNo + "', '" + Session.SessionID + "','ADD')");
        }
    }

    private void clearGridViewData()
    {
        UserCardHelper.resetData(gvResult, null);

        btnSubmit.Enabled = false;
        this.btnDel.Enabled = false;
        gvResult.Visible = true;
        lvwRelation.Visible = false;
    }

    private void clearTempTable()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_BalDeviceRelation_IMP where SESSIONID='"
            + Session.SessionID + "'");
        context.DBCommit();
    }
    private void createGridViewData()
    {
        lvwRelation.Visible = false;

        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryInvalidLines", Session.SessionID);

        if (data.Rows.Count > 0)
        {
            context.AddError("共有" + data.Rows.Count + "条记录检查未通过，详见下面列表。请检查上传文件后重试。");

            UserCardHelper.resetData(gvResult, data);
            return;
        }

        data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryDeviceBal", Session.SessionID);
        UserCardHelper.resetData(gvResult, data);

        btnSubmit.Enabled = (data.Rows.Count != 0);
        this.btnDel.Enabled = false;
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
        ddlBalUnit.Items.Clear();

        context.DBOpen("Select");
        System.Text.StringBuilder sql = new System.Text.StringBuilder();

        sql.Append("SELECT DBALUNIT, DBALUNITNO	FROM TF_DEPT_BALUNIT WHERE USETAG = '1' AND DEPTTYPE = '2'");
        //模糊查询单位名称，并在列表中赋值
        string strBalname = txtBalUnitName.Text.Trim().Replace('\'', '\"');
        if (strBalname.Length != 0)
        {
            sql.Append("AND DBALUNIT LIKE '%" + strBalname + "%'");
        }
        sql.Append("ORDER BY DBALUNITNO");

        System.Data.DataTable table = context.ExecuteReader(sql.ToString());
        GroupCardHelper.fill(ddlBalUnit, table, true);
    }
    #endregion
}
