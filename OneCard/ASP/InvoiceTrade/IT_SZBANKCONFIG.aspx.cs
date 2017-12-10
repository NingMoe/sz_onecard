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
using PDO.InvoiceTrade;
using TDO.InvoiceTrade;

public partial class ASP_InvoiceTrade_IT_SZBANKCONFIG : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化有效标志
            TSHelper.initUseTag(selUseTag);

            //初始化COS类型列表
            CosTypeQuery();      
        }
        
    }

    //初始化COS类型列表
    private void CosTypeQuery(){

        TMTableModule tm = new TMTableModule();
        string sqlSZBank = "select * from TD_M_SZBANK";
        DataTable data = tm.selByPKDataTable(context, sqlSZBank, 0);
        DataView dataView = new DataView(data);
        lvwCosType.DataKeyNames = new string[] { "BANKNAME", "BANKCODE", "PayeeName", "ISDEFAULT", "USETAG" };
        lvwCosType.DataSource = dataView;
        lvwCosType.DataBind();
        lvwCosType.SelectedIndex = -1;

    }

    //增加
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        //输入处理判断
        if (!ValidateInputData()) return;

        //发票出库存储过程
        context.SPOpen();
        context.AddField("p_BankName").Value = txtBankName.Text.Trim();
        context.AddField("p_BankCode").Value = txtBankCode.Text.Trim();
        context.AddField("p_PayeeName").Value = txtPayeeName.Text.Trim();
        context.AddField("p_isDefault").Value = cbxIsDefault.Checked ? "1" : "0";
        context.AddField("p_usetag").Value = selUseTag.SelectedValue;
        bool ok = context.ExecuteSP("SP_IT_SZBANKADD");

        if (ok)
        {
            AddMessage("修改开户行配置信息成功");
            //更新开户行列表
            CosTypeQuery();
        }
        clearInput();
    }
    //修改
    protected void btnModify_Click(object sender, EventArgs e)
    {

        //当没有选择记录时

        if (lvwCosType.SelectedIndex == -1)
        {
            context.AddError("没有记录被选中");
            return;
        }
        //输入处理判断
        if (!ValidateInputData()) return;
        if (txtBankName.Text.Trim() != getDataKeys("BANKNAME"))
        {
            context.AddError("选中的记录的开户行名称和要修改的不符");
            return;
        }
        context.SPOpen();
        context.AddField("p_BankName").Value = getDataKeys("BANKNAME");
        context.AddField("p_BankCode").Value = txtBankCode.Text.Trim();
        context.AddField("p_PayeeName").Value = txtPayeeName.Text.Trim();
        context.AddField("p_isDefault").Value = cbxIsDefault.Checked ? "1" : "0";
        context.AddField("p_usetag").Value = selUseTag.SelectedValue;
        bool ok = context.ExecuteSP("SP_IT_SZBANKMODIFY");

        if (ok)
        {
            AddMessage("修改开户行配置信息成功");
            //更新开户行列表
            CosTypeQuery();
        }
        clearInput();

    }
    //删除
    protected void btnDelete_Click(object sender, EventArgs e)
    {
        //当没有选择记录时
        if (lvwCosType.SelectedIndex == -1)
        {
            context.AddError("没有记录被选中");
            return;
        }
        if (txtBankName.Text.Trim() != getDataKeys("BANKNAME"))
        {
            context.AddError("选中的记录的开户行名称和要修改的不符");
            return;
        }
        context.SPOpen();
        context.AddField("p_BankName").Value = getDataKeys("BANKNAME");
       
        bool ok = context.ExecuteSP("SP_IT_SZBANKDELETE");

        if (ok)
        {
            AddMessage("删除开户行配置信息成功");
            //更新开户行列表
            CosTypeQuery();
        }
        clearInput();
        

    }
    public void lvwCosType_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtBankName.Text = getDataKeys("BANKNAME");
        txtBankCode.Text = getDataKeys("BANKCODE");
        txtPayeeName.Text = getDataKeys("PayeeName");
        cbxIsDefault.Checked = getDataKeys("ISDEFAULT")=="1"?true:false;
        selUseTag.SelectedValue = getDataKeys("USETAG");
    }
    protected void lvwCosType_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwCosType','Select$" + e.Row.RowIndex + "')");
        }
    }

    public void lvwCosType_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwCosType.PageIndex = e.NewPageIndex;
        CosTypeQuery();

        lvwCosType.SelectedIndex = -1;
        clearInput();
    }

    private string getDataKeys(string keysname)
    {
        return lvwCosType.DataKeys[lvwCosType.SelectedIndex][keysname].ToString();
    }

    private void clearInput(){
        txtBankName.Text = "";
        txtBankCode.Text = "";
        txtPayeeName.Text = "";
        cbxIsDefault.Checked = false;
        selUseTag.SelectedValue = "";
    }

    //输入判断处理
    private bool ValidateInputData(){
        //开户行名称不能为空

        string strBankName = txtBankName.Text.Trim();
        if (strBankName == "")
        {
            context.AddError("开户行名称不能为空", txtBankName);
        }
       
        //开户行账户不能为空

        string strBankCode = txtBankCode.Text.Trim();
        if (strBankCode == "")
        {
            context.AddError("开户行帐号不能为空", txtBankCode);
        }
        string strPayeeName = txtPayeeName.Text.Trim();
        if (strPayeeName == "")
        {
            context.AddError("收款方名称不能为空", txtPayeeName);
        }
        //有效标志非空判断
        string strUseTag = selUseTag.SelectedValue;
        if(strUseTag == ""){
            context.AddError("有效标志位不能为空", selUseTag);
        }

        if (context.hasError())
            return false;
        else
            return true;
    }

}
