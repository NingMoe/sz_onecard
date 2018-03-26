using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using PDO.PartnerShip;
using TDO.BalanceChannel;
using TDO.UserManager;
using TM;
public partial class ASP_PartnerShip_PS_TransferDiscountApproval : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            //指定GridView DataKeyNames
            lvwBalUnitsFiAppral.DataKeyNames =
                new string[] { "TRADEID", "BALUNITNO", "TRADETYPECODE", "PREFERENTIALCODE",
                "CALLINGNO","CORPNO","DEPARTNO","BEGINDATE","ENDDATE","PREFERENTIALUPPER","APPLYSTAFFNO","APPLYDEPARTNO","APPLYDATE","ISSPECIAL","balunittypename","comschemeno"};
            btnQuery_Click(sender, e);
  

           

        }
    }

    public void lvwBalUnitsFiAppral_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwBalUnitsFiAppral.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {

        //查询结算单元信息
        DataTable data = SPHelper.callPSQuery(context, "QueryUnitDiscountApproval");

        UserCardHelper.resetData(lvwBalUnitsFiAppral, data);


    }

    public String getDataKeys(string keysname)
    {
        string value = lvwBalUnitsFiAppral.DataKeys[lvwBalUnitsFiAppral.SelectedIndex][keysname].ToString();

        return value == "" ? "" : value;
    }
    protected void lvwBalUnitsFiAppral_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwBalUnitsFiAppral','Select$" + e.Row.RowIndex + "')");
        }
    }
    public void lvwBalUnitsFiAppral_SelectedIndexChanged(object sender, EventArgs e)
    {

    }
    private Boolean BalValidation()
    {
        //判断是否选择了需要修改的结算单元
        if (lvwBalUnitsFiAppral.SelectedIndex == -1)
        {
            context.AddError("A008107052");
            return false;
        }
        return !(context.hasError());
    }

    protected void btnPass_Click(object sender, EventArgs e)
    {
        if (!BalValidation()) return;
        //当业务类型为修改时,
        //当结算单元类型修改后,判断当前修改后的结算单元是否存在
        

        //当业务类型为增加时,判断结算单元是否存在
       
        //调用审核通过的存储过程
        context.SPOpen();
        
        context.AddField("p_TRADEID").Value = getDataKeys("TRADEID").Trim();
        context.AddField("p_BALUNITNO").Value = getDataKeys("BALUNITNO").Trim();
        context.AddField("p_DISCOUNT").Value = getDataKeys("PREFERENTIALCODE").Trim();
        context.AddField("p_TRADETYPECODE").Value = getDataKeys("TRADETYPECODE").Trim();
        context.AddField("p_MAX").Value = Convert.ToDouble(getDataKeys("PREFERENTIALUPPER").Trim()) * 100.0;
        context.AddField("p_CALLINGNO").Value = getDataKeys("CALLINGNO").Trim();
        context.AddField("p_CORPNO").Value = getDataKeys("CORPNO").Trim();
        context.AddField("p_DEPARTNO").Value = getDataKeys("DEPARTNO").Trim();
        context.AddField("p_APPLYSTAFFNO").Value = getDataKeys("APPLYSTAFFNO").Trim();
        context.AddField("p_APPLYDEPARTNO").Value = getDataKeys("APPLYDEPARTNO").Trim();
        context.AddField("p_isspecial").Value = getDataKeys("ISSPECIAL").Trim();
        context.AddField("p_comScheme").Value = getDataKeys("comschemeno").Trim();
        bool ok = context.ExecuteSP("SP_PS_UnitDiscountPass");
        if (ok)
        {
            AddMessage("审核通过");
            btnQuery_Click(sender, e);
        }

        

       
    }
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        if (!BalValidation()) return;
        //调用审核作废的存储过程
        context.SPOpen();
        context.AddField("p_TRADEID").Value = getDataKeys("TRADEID").Trim();
        context.AddField("p_BALUNITNO").Value = getDataKeys("BALUNITNO").Trim();
        context.AddField("p_DISCOUNT").Value = getDataKeys("PREFERENTIALCODE").Trim();
        bool ok = context.ExecuteSP("SP_PS_UnitDiscountCancel");
        if (ok)
        {
            AddMessage("审核作废");
            btnQuery_Click(sender, e);
        }

        
    }
}