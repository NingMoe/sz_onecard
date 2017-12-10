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
using TDO.ResourceManager;
using PDO.EquipmentManagement;

using Common;
using TM.EquipmentManagement;

public partial class ASP_EquipmentManagement_EM_CardCosType : Master.Master
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

        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_COSTYPETDO tdoCosTypeIn = new TD_M_COSTYPETDO();

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoCosTypeIn, null, "", 0);
        DataView dataView = new DataView(data);

        lvwCosType.DataKeyNames = new string[] { "COSTYPECODE", "COSTYPE", "COSTYPENOTE", "USETAG" };
        lvwCosType.DataSource = dataView;
        lvwCosType.DataBind();

    }

    //增加
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        //输入处理判断
        if (!ValidateInputData()) return;

        //判断COS类型编码是否已存在
        TD_M_COSTYPETDO ddoTD_M_COSTYPETDOIn = new TD_M_COSTYPETDO();
        TD_M_COSTYPETM tmTD_M_COSTYPE = new TD_M_COSTYPETM();
        ddoTD_M_COSTYPETDOIn.COSTYPECODE = txtCode.Text.Trim();

        if (!tmTD_M_COSTYPE.chkCosType(context, ddoTD_M_COSTYPETDOIn))
            return;

        //插入新COS类型
        ddoTD_M_COSTYPETDOIn.COSTYPE = txtName.Text.Trim();
        ddoTD_M_COSTYPETDOIn.COSTYPENOTE = txtNote.Text.Trim();
        ddoTD_M_COSTYPETDOIn.USETAG = selUseTag.SelectedValue;
        ddoTD_M_COSTYPETDOIn.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_COSTYPETDOIn.UPDATETIME = DateTime.Now;

        int AddSum = tmTD_M_COSTYPE.insAdd(context, ddoTD_M_COSTYPETDOIn);
        //插入数据不成功显示错误信息
        if (AddSum == 0)
        {
            context.AppException("S006111051");
        }

        context.DBCommit();

        //更新COS类型列表
        CosTypeQuery();
        lvwCosType.SelectedIndex = -1;

        //清空输入框
        clearInput();
    }

    //修改
    protected void btnModify_Click(object sender, EventArgs e)
    {
        //当没有选择要修改的COS类型信息时
        if (lvwCosType.SelectedIndex == -1)
        {
            context.AddError("A006111055");
            return;
        }

        //当COS类型编码被修改时
        if (txtCode.Text.Trim() != getDataKeys("COSTYPECODE"))
        {
            context.AddError("A006111056", txtCode);
        }

        if (context.hasError())
            return;

        //调用输入判断
        if (!ValidateInputData()) return;

        //更新表记录
        TD_M_COSTYPETDO ddoTD_M_COSTYPETDOIn = new TD_M_COSTYPETDO();
        TD_M_COSTYPETM tmTD_M_COSTYPE = new TD_M_COSTYPETM();

        ddoTD_M_COSTYPETDOIn.COSTYPECODE = txtCode.Text.Trim();
        ddoTD_M_COSTYPETDOIn.COSTYPE = txtName.Text.Trim();
        ddoTD_M_COSTYPETDOIn.COSTYPENOTE = txtNote.Text.Trim();
        ddoTD_M_COSTYPETDOIn.USETAG = selUseTag.SelectedValue;
        ddoTD_M_COSTYPETDOIn.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_COSTYPETDOIn.UPDATETIME = DateTime.Now;

        int RecordSum = tmTD_M_COSTYPE.updRecord(context, ddoTD_M_COSTYPETDOIn);
        //修改数据不成功显示错误信息
        if (RecordSum == 0)
        {
            context.AppException("S010002016");
        }

        context.DBCommit();

        //更新COS类型列表
        CosTypeQuery();

    }
    public void lvwCosType_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtCode.Text = getDataKeys("COSTYPECODE");
        txtName.Text = getDataKeys("COSTYPE");
        txtNote.Text = getDataKeys("COSTYPENOTE");
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
        txtCode.Text = "";
        txtName.Text = "";
        txtNote.Text = "";
        selUseTag.SelectedValue = "";
    }

    //输入判断处理
    private bool ValidateInputData(){
        //COS类型编码非空、数字、长度判断
        string strCode = txtCode.Text.Trim();
        if(strCode == ""){
            context.AddError("A006111001", txtCode);
        }else {
            if (!Validation.isNum(strCode)){
                context.AddError("A006111002", txtCode);
            }
            if(Validation.strLen(strCode) != 2){
                context.AddError("A006111003", txtCode);
            }
            
        }
       
        //COS类型名称非空、长度判断
        string strName = txtName.Text.Trim();
        if(strName == ""){
            context.AddError("A006111004", txtName);
        }else if (Validation.strLen(strName) > 20){
            context.AddError("A006111006", txtName);
        }

        //当COS类型说明不为空时，进行长度判断
        string strNote = txtNote.Text.Trim();
        if(strNote != ""){
            if(Validation.strLen(strNote) > 120){
                context.AddError("A006111007", txtNote);
            }
        }
        //有效标志非空判断
        string strUseTag = selUseTag.SelectedValue;
        if(strUseTag == ""){
            context.AddError("A006111008", selUseTag);
        }

        if (context.hasError())
            return false;
        else
            return true;
    }

}
