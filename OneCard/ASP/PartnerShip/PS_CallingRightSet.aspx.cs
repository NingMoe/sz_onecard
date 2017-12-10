using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Master;
using Common;
using TM;
using PDO.PartnerShip;
using System.Data;
using System.Collections;
using TDO.PartnerShip;
using TDO.BalanceChannel;

public partial class ASP_PartnerShip_PS_CallingRightSet : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            TMTableModule tmTMTableModule = new TMTableModule();
            //从应用行业编码表(TD_M_APPCALLINGCODE)中读取数据  
            TD_M_APPCALLINGCODETDO ddlTD_M_APPCALLINGCODEIn = new TD_M_APPCALLINGCODETDO();
            TD_M_APPCALLINGCODETDO[] ddoTD_M_APPCALLINGCODEOutArr = (TD_M_APPCALLINGCODETDO[])tmTMTableModule.selByPKArr(context, ddlTD_M_APPCALLINGCODEIn, typeof(TD_M_APPCALLINGCODETDO), "S008113033", "TD_M_APPCALLINGUSETAG", null);
            //放入查询输入行业名称下拉列表中
            ControlDeal.SelectBoxFill(selCalling.Items, ddoTD_M_APPCALLINGCODEOutArr, "APPCALLING", "APPCALLINGCODE", true);
            ControlDeal.SelectBoxFill(selCallingExt.Items, ddoTD_M_APPCALLINGCODEOutArr, "APPCALLING", "APPCALLINGCODE", true);
            

            gvCallingList.DataSource = new DataTable();
            gvCallingList.DataBind();
            gvCallingList.SelectedIndex = -1;

            //指定GridView DataKeyNames
            gvCallingList.DataKeyNames = new string[] { "APPCALLINGCODE", "CALLINGRIGHTVALUE", "REMARK", "APPLYTYPE" };
        }

    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        gvCallingList.DataSource = QueryDataSource();
        gvCallingList.DataBind();
        //gvCallingList.SelectedIndex = -1;
        Clear();
        hidCallingNo.Value = "";
        hidType.Value = "";
        
    }
    public ICollection QueryDataSource()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        //从行业权值表表(TD_M_CALLINGRIGHTVALUE)中读取数据
        TD_M_CALLINGRIGHTVALUETDO tdoTD_M_CALLINGRIGHTVALUIn = new TD_M_CALLINGRIGHTVALUETDO();
        string strSql = "Select tcalling.APPCALLINGCODE ,tcalling.APPCALLING,t.CALLINGRIGHTVALUE,t.REMARK,t.applytype";
        strSql += " From TD_M_CALLINGRIGHTVALUE t,td_m_appcallingcode tcalling ";

        ArrayList list = new ArrayList();
        list.Add("t.CALLINGNO = tcalling.APPCALLINGCODE ");
        //list.Add("tcalling.ISOPEN = '1' ");

        if (selCalling.SelectedValue != "")
            list.Add("t.CALLINGNO = '" + selCalling.SelectedValue + "'");


        strSql += DealString.ListToWhereStr(list);
        strSql += " order by t.CALLINGNO ";
        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTD_M_CALLINGRIGHTVALUIn, null, strSql, 0);
        DataView dataView = new DataView(data);
        if (dataView.Count<1)
        {
            AddMessage("查无数据");
        }
        return dataView;
    }
    private bool ValidInput()
    {
        if(selCallingExt.SelectedValue.Equals(""))
        {
            context.AddError("请选择应用行业", selCallingExt);
        }
        //校验权值
        if (txtCallingRightValue.Text.Trim().Length > 0)
        { 
            if (!Validation.isPosRealNum(txtCallingRightValue.Text.Trim()))
            {
                context.AddError("应用行业权值必须是半角正实数（可有1-2位小数）", txtCallingRightValue);
            }
        }
        else
        {
            context.AddError("请填写应用行业权值", txtCallingRightValue);
        }
        if (selType.SelectedValue.Equals(""))
        {
            context.AddError("请选择权值应用类型", selType);
        }
        return !(context.hasError());
    }
    protected void gvCallingList_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvCallingList','Select$" + e.Row.RowIndex + "')");
        }
    }
    
    protected void gvCallingList_SelectedIndexChanged(object sender, EventArgs e)
    {
        string t = getDataKeys("APPCALLINGCODE");
        selCallingExt.SelectedValue = t;
        txtCallingRightValue.Text = getDataKeys("CALLINGRIGHTVALUE");
        txtRemark.Text = getDataKeys("REMARK");
        selType.SelectedValue = getDataKeys("APPLYTYPE");
        hidCallingNo.Value = getDataKeys("APPCALLINGCODE");
        hidType.Value = getDataKeys("APPLYTYPE");
        
    }
  
    public void gvCallingList_Page(Object sender, GridViewPageEventArgs e)
    {
        gvCallingList.PageIndex = e.NewPageIndex;
        gvCallingList.DataSource = QueryDataSource();
        gvCallingList.DataBind();

        gvCallingList.SelectedIndex = -1;

    }
    public string getDataKeys(string keysname)
    {
        return gvCallingList.DataKeys[gvCallingList.SelectedIndex][keysname].ToString();
    }
    //新增事件
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!ValidInput()) return;
        context.SPOpen();
        context.AddField("P_CALLINGNO").Value = selCallingExt.SelectedValue;
        context.AddField("P_CALLINGRIGHTVALUE").Value = txtCallingRightValue.Text.Trim();
        context.AddField("P_APPLYTYPE").Value = selType.SelectedValue;
        context.AddField("P_REMARK").Value = txtRemark.Text.Trim();
        bool ok = context.ExecuteSP("SP_PS_CALLINGRIGHTADD");
        if (ok)
        {
            context.AddMessage("新增应用行业权值成功");
            gvCallingList.DataSource = QueryDataSource();
            gvCallingList.DataBind();
        }
    }
    //修改事件
    protected void btnModify_Click(object sender, EventArgs e)
    {
        if (gvCallingList.SelectedIndex == -1)
        {
            context.AddError("未选中数据行");
            return;
        }
        if (!ValidInput()) return;
        if(hidType.Value!=selType.SelectedValue || hidCallingNo.Value!=selCallingExt.SelectedValue)
        {
            context.AddError("应用行业和权值应用类型不可修改");
            return;
        }
        context.SPOpen();
        context.AddField("P_CALLINGNO").Value = selCallingExt.SelectedValue;
        context.AddField("P_CALLINGRIGHTVALUE").Value = txtCallingRightValue.Text.Trim();
        context.AddField("P_APPLYTYPE").Value = selType.SelectedValue;
        context.AddField("P_REMARK").Value = txtRemark.Text.Trim();
        bool ok = context.ExecuteSP("SP_PS_CALLINGRIGHTEDIT");
        if (ok)
        {
            context.AddMessage("修改应用行业权值成功");
            gvCallingList.DataSource = QueryDataSource();
            gvCallingList.DataBind();
        }
    }
    private void Clear()
    {
        selCallingExt.SelectedValue = "";
        txtCallingRightValue.Text = "";
        selType.SelectedValue= "";
        txtRemark.Text = "";
    }
   
}