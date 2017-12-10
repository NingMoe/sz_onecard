using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using TM;
using TDO.BalanceChannel;
using Common;
using System.Collections;

public partial class ASP_PartnerShip_PS_TransferDetail : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //设置单位信息列表表头字段名

            lvwCorpQuery.DataSource = new DataTable();
            lvwCorpQuery.DataBind();
            lvwCorpQuery.SelectedIndex = -1;

            //指定GridView DataKeyNames
            lvwCorpQuery.DataKeyNames = 
                new string[] { "CORPNO", "CORP", "CALLING", "CORPNAME", "BALUNITNO", "BALUNIT", "BANKACCNO", "LINKMAN", "UNITPHONE" };

            TMTableModule tmTMTableModule = new TMTableModule();

            //从结算单元编码表(TD_M_CALLINGNO)中读取数据

            TF_TRADE_BALUNITTDO tdoTF_TRADE_BALUNITIn = new TF_TRADE_BALUNITTDO();
            TF_TRADE_BALUNITTDO[] tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), "S008100212", "TF_BALUNITNO_DETAIL", null);

            //放入查询输入合帐结算单元下拉列表中

            ControlDeal.SelectBoxFillWithCode(selCalling.Items, tdoTF_TRADE_BALUNITOutArr, "BALUNIT", "BALUNITNO", true);

            ControlDeal.SelectBoxFillWithCode(txtBALUNITNO.Items, tdoTF_TRADE_BALUNITOutArr, "BALUNIT", "BALUNITNO", true);

            //查询单位编码表
            TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();

            TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, "TD_M_CORPUSAGE", null);

            //放入单位名称下拉列表中
            ControlDeal.SelectBoxFillWithCode(selCorp.Items, tdoTD_M_CORPOutArr, "CORP", "CORPNO", true);

        }
    }

    public void lvwCorpQuery_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwCorpQuery.PageIndex = e.NewPageIndex;
        if (hiddenShow.Value == "0")
        {
        		lvwCorpQuery.DataSource = CreateCorpQueryDataSource();
        }
        else if (hiddenShow.Value == "1")
        {
        		lvwCorpQuery.DataSource = CreateBalQueryDataSource();
        }
        lvwCorpQuery.DataBind();

        lvwCorpQuery.SelectedIndex = -1;
    }

    //protected void lvwCorpQuery_RowCreated(object sender, GridViewRowEventArgs e)
    //{
    //    if (e.Row.RowType == DataControlRowType.DataRow)
    //    {
    //        //注册行单击事件

    //        e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwCorpQuery','Select$" + e.Row.RowIndex + "')");
    //    }
    //}

    protected void lvwCorpQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (hiddenShow.Value == "0")
        {
            lvwCorpQuery.Columns[10].Visible = false;
        }
        else if (hiddenShow.Value == "1")
        {
            lvwCorpQuery.Columns[10].Visible = true;
        }
    }

    protected void CheckAll(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in lvwCorpQuery.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }

    //public string getDataKeys(string keysname)
    //{
    //    return lvwCorpQuery.DataKeys[lvwCorpQuery.SelectedIndex][keysname].ToString();
    //}

    protected void btnBalQuery_Click(object sender, EventArgs e)
    {
        if (selCalling.SelectedValue == "")
        {
            context.AddError("合帐结算单元不能为空");
            return;
        }

        hiddenShow.Value = "1";
        lvwCorpQuery.DataSource = CreateBalQueryDataSource();
        lvwCorpQuery.DataBind();
        lvwCorpQuery.SelectedIndex = -1;

        if (lvwCorpQuery.Rows.Count == 0)
        {
            AddMessage("查询结果为空");
            return;
        }

        btnAdd.Enabled = false;
    }

    protected void btnCorpQuery_Click(object sender, EventArgs e)
    {
        if (selCorp.SelectedValue == "")
        {
            context.AddError("单位不能为空");
            return;
        }

        hiddenShow.Value = "0";
        lvwCorpQuery.DataSource = CreateCorpQueryDataSource();
        lvwCorpQuery.DataBind();
        lvwCorpQuery.SelectedIndex = -1;

        if (lvwCorpQuery.Rows.Count == 0)
        {
            AddMessage("查询结果为空");
            return;
        }

        btnAdd.Enabled = true;
    }

    public ICollection CreateCorpQueryDataSource()
    {
        DataTable data = SPHelper.callPSQuery(context, "CORPDETAIL", selCorp.SelectedValue);

        DataView dataView = new DataView(data);
        return dataView;
    }

    public ICollection CreateBalQueryDataSource()
    {
        DataTable data = SPHelper.callPSQuery(context, "BALDETAIL", selCalling.SelectedValue);

        DataView dataView = new DataView(data);
        return dataView;
    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (txtBALUNITNO.SelectedValue == "")
        {
            context.AddError("合帐结算单元不能为空");
            return;
        }

        GroupCardHelper.clearTempCustInfoTable(context);

        context.DBOpen("Insert");

        int count = 0;
        foreach (GridViewRow gvr in lvwCorpQuery.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                context.ExecuteNonQuery("insert into TMP_COMMON(f0) values('"
                    + gvr.Cells[5].Text + "')");
            }
        }
        context.DBCommit();

        // 没有选中任何行，则返回错误

        if (count <= 0)
        {
            context.AddError("A004P03R01: 没有选中任何行");
            return;
        }

        context.SPOpen();
        context.AddField("p_BALUNITNO").Value = txtBALUNITNO.SelectedValue;

        bool ok = context.ExecuteSP("SP_PS_BALUNITDETAILADD");

        if (ok)
        {
            AddMessage("建立结算对应关系成功");

            clearData();

            btnAdd.Enabled = false;
        }

    }
    // 清除数据
    private void clearData()
    {
        lvwCorpQuery.DataSource = new DataTable();
        lvwCorpQuery.DataBind();

        txtBALUNITNO.SelectedValue = "";
        selCorp.SelectedValue = "";
        selCalling.SelectedValue = "";

    }

    protected void lvwCorpQuery_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        
        context.SPOpen();
        context.AddField("p_UNITNO").Value = lvwCorpQuery.Rows[e.RowIndex].Cells[1].Text.Trim();
        context.AddField("p_BALUNITNO").Value = lvwCorpQuery.Rows[e.RowIndex].Cells[5].Text.Trim();

        bool ok = context.ExecuteSP("SP_PS_BALUNITDETAILCANCEL");

        if (ok)
        {
            AddMessage("删除结算对应关系成功");

            lvwCorpQuery.DataSource = CreateBalQueryDataSource();
            lvwCorpQuery.DataBind();
            lvwCorpQuery.SelectedIndex = -1;

        }
    }

}
