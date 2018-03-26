using System;
using System.Data;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TM;
using Common;
using TDO.PartnerShip;

public partial class ASP_PartnerShip_PS_ProjectManager : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
        UserCardHelper.resetData(lvwBalUnits, null);

        //从活动编码表(TF_BALANCE_PROJECT)中读取数据，放入查询输入活动名称下拉列表中
        InitDropProject();
        
        //指定GridView  lvwBalUnits DataKeyNames
        lvwBalUnits.DataKeyNames = new string[] 
           {
               "PROJECTNO", "PROJECTNAME", "DISCOUNTLIMITLINE","DISCOUNTWARNLINE","DISCOUNTMONEY"
               
           };
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //查询结算单元信息
        DataTable data = SPHelper.callPSQuery(context, "QueryProject", selProject.SelectedValue);
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        UserCardHelper.resetData(lvwBalUnits, data);
    }
    protected void lvwBalUnits_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwBalUnits','Select$" + e.Row.RowIndex + "')");
        }
    }

    public void lvwBalUnits_SelectedIndexChanged(object sender, EventArgs e)
    {
        try
        {
            txtName.Text = getDataKeys("PROJECTNAME").Trim();
            txtTotal.Text = getDataKeys("DISCOUNTLIMITLINE").Trim();
            txtWarm.Text = getDataKeys("DISCOUNTWARNLINE").Trim();
            txtDiscount.Text = getDataKeys("DISCOUNTMONEY").Trim();

        }
        catch (Exception)
        {
            txtName.Text = "";
            txtTotal.Text = "";
            txtWarm.Text = "";
            txtDiscount.Text = "";
        }




    }
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        //调用增加的判断处理

        if (!BalUnitAddValidation()) return;


        //调用增加的存储过程
        context.SPOpen();
        context.AddField("p_projectName").Value = txtName.Text.Trim();
        context.AddField("p_total").Value = Convert.ToDouble(txtTotal.Text.Trim()) * 100.0;
        context.AddField("p_warm").Value = Convert.ToDouble(txtWarm.Text.Trim()) * 100.0;
        context.AddField("p_discount").Value = Convert.ToDouble(txtDiscount.Text.Trim()) * 100.0;
        bool ok = context.ExecuteSP("SP_PS_ProjectAdd");
        if (ok)
        {
            AddMessage("活动新增成功");
            InitDropProject();
            btnQuery_Click(sender, e);
        }
    }

    protected void btnModify_Click(object sender, EventArgs e)
    {
        //调用修改的判断处理
        if (!BalUnitModifyValidation()) return;
        if (!BalUnitAddValidation()) return;
        
        //调用修改的存储过程
        context.SPOpen();
        context.AddField("p_projectNo").Value = getDataKeys("PROJECTNO").Trim();
        context.AddField("p_projectName").Value = txtName.Text.Trim();
        context.AddField("p_total").Value = Convert.ToDouble(txtTotal.Text.Trim()) * 100.0;
        context.AddField("p_warm").Value = Convert.ToDouble(txtWarm.Text.Trim()) * 100.0;
        context.AddField("p_discount").Value = Convert.ToDouble(txtDiscount.Text.Trim()) * 100.0;
        bool ok = context.ExecuteSP("SP_PS_ProjectModify");

        if (ok)
        {
            AddMessage("活动修改成功");
            InitDropProject();
            btnQuery_Click(sender, e);
        }
    }

    private Boolean BalUnitAddValidation()
    {

        //判断活动名称是否为空
        string strProjectName = txtName.Text.Trim();
        if (strProjectName == "")
        {
            context.AddError("请输入活动名称", txtName);
        }
        //判断总优惠金额是否为空
        if (txtTotal.Text.Trim() == "")
            context.AddError("总优惠金额不能为空", txtTotal);
        else if (!Validation.isPosRealNum(txtTotal.Text.Trim()))
            context.AddError("总优惠金额必须为数字", txtTotal);
        //判断优惠阀值是否为空
        if (txtWarm.Text.Trim() == "")
            context.AddError("优惠阀值不能为空", txtWarm);
        else if (!Validation.isPosRealNum(txtWarm.Text.Trim()))
            context.AddError("优惠阀值必须为数字", txtWarm);
        //判断已优惠金额是否为空
        if (txtDiscount.Text.Trim() == "")
            context.AddError("已优惠金额不能为空", txtDiscount);
        else if (!Validation.isPosRealNum(txtDiscount.Text.Trim()))
            context.AddError("已优惠金额必须为数字", txtDiscount);
        //判断优惠阀值是否大于总优惠金额
        if (Convert.ToDouble(txtWarm.Text.Trim()) > Convert.ToDouble(txtTotal.Text.Trim()))
        {
            context.AddError("优惠阀值不可大于总优惠金额", txtWarm);
        }
        //判断已优惠金额是否大于总优惠金额
        if (Convert.ToDouble(txtDiscount.Text.Trim()) > Convert.ToDouble(txtTotal.Text.Trim()))
        {
            context.AddError("已优惠金额不可大于总优惠金额", txtDiscount);
        }
        return !(context.hasError());
    }
    public String getDataKeys(string keysname)
    {
        string value = lvwBalUnits.DataKeys[lvwBalUnits.SelectedIndex][keysname].ToString();

        return value == "" ? "" : value;
    }
    private Boolean BalUnitModifyValidation()
    {
        //判断是否选择了需要修改的活动
        if (lvwBalUnits.SelectedIndex == -1)
        {
            context.AddError("未选择需要修改的活动");
            return false;
        }

        string strName = txtName.Text.Trim();
        string strTotal = txtTotal.Text.Trim();
        string strWarm = txtWarm.Text.Trim();
        string strDiscount = txtDiscount.Text.Trim();
        if (strName == getDataKeys("PROJECTNAME") && strTotal == getDataKeys("DISCOUNTLIMITLINE") && strWarm == getDataKeys("DISCOUNTWARNLINE") && strDiscount == getDataKeys("DISCOUNTMONEY"))
        {
            context.AddError("未修改活动信息,不可提交修改操作");
        }
        return !(context.hasError());
    }
    private void InitDropProject()
    {
        selProject.Items.Clear();
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_BALANCE_PROJECTTDO tdoTF_BALANCE_PROJECTIn = new TF_BALANCE_PROJECTTDO();
        TF_BALANCE_PROJECTTDO[] tdoTF_BALANCE_PROJECTOutArr = (TF_BALANCE_PROJECTTDO[])tmTMTableModule.selByPKArr(context, tdoTF_BALANCE_PROJECTIn, typeof(TF_BALANCE_PROJECTTDO), "S008100215");

        ControlDeal.SelectBoxFillWithCode(selProject.Items, tdoTF_BALANCE_PROJECTOutArr, "PROJECTNAME", "PROJECTNO", true);
    }
}