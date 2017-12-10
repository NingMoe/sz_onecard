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
using TM.EquipmentManagement;
using Common;
using TDO.ResourceManager;

public partial class ASP_EquipmentManagement_EM_PosManu : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化有效标志
            TSHelper.initUseTag(selUseTag);

            //初始化POS厂商列表
            PosManuQuery();
        }
    }

    //查询POS厂商，并初始化列表
    private void PosManuQuery()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_POSMANUTDO tdoPosManu = new TD_M_POSMANUTDO();

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoPosManu, null, "", 0);
        DataView dataView = new DataView(data);

        lvwPosManu.DataKeyNames = new string[] { "POSMANUCODE", "POSMANUNAME", "PHONE","FAX","ZIPCODE","EMAIL","ADDRESS", "USETAG" };
        lvwPosManu.DataSource = dataView;
        lvwPosManu.DataBind();

    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        //输入验证
        if (!ValidateInputData())
            return;

        //判断厂商编码是否已存在
        TD_M_POSMANUTDO ddoTD_M_POSMANUTDO = new TD_M_POSMANUTDO();
        TD_M_POSMANUTM tmTD_M_POSMANUTM = new TD_M_POSMANUTM();
        ddoTD_M_POSMANUTDO.POSMANUCODE = txtCode.Text.Trim();
        if (!tmTD_M_POSMANUTM.chkPosManu(context, ddoTD_M_POSMANUTDO))
        {
            context.AddError("A006105020", txtCode);
            return;
        }

        //插入新记录
        ddoTD_M_POSMANUTDO.POSMANUNAME = txtName.Text.Trim();
        ddoTD_M_POSMANUTDO.PHONE = txtPhone.Text.Trim();
        ddoTD_M_POSMANUTDO.FAX = txtFax.Text.Trim();
        ddoTD_M_POSMANUTDO.ZIPCODE = txtZip.Text.Trim();
        ddoTD_M_POSMANUTDO.EMAIL = txtMail.Text.Trim();
        ddoTD_M_POSMANUTDO.ADDRESS = txtAddress.Text.Trim();
        ddoTD_M_POSMANUTDO.USETAG = selUseTag.SelectedValue;
        ddoTD_M_POSMANUTDO.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_POSMANUTDO.UPDATETIME = DateTime.Now;

        int AddSum = tmTD_M_POSMANUTM.insAdd(context, ddoTD_M_POSMANUTDO);
        if (AddSum == 0)
            context.AppException("S006105030");

        context.DBCommit();

        PosManuQuery();
        lvwPosManu.SelectedIndex = -1;

        clearInput();
    }


    protected void btnModify_Click(object sender, EventArgs e)
    {
        //当没有选择要修改的POS厂商信息时
        if (lvwPosManu.SelectedIndex == -1)
        {
            context.AddError("A006105025");
            return;
        }

        //当POS厂商编码被修改时
        if (txtCode.Text.Trim() != getDataKeys("POSMANUCODE"))
        {
            context.AddError("A006105026", txtCode);
            return;
        }

        if (!ValidateInputData())
            return;

        TD_M_POSMANUTDO ddoTD_M_POSMANUTDO = new TD_M_POSMANUTDO();
        TD_M_POSMANUTM tmTD_M_POSMANUTM = new TD_M_POSMANUTM();
        ddoTD_M_POSMANUTDO.POSMANUCODE = txtCode.Text.Trim();
        ddoTD_M_POSMANUTDO.POSMANUNAME = txtName.Text.Trim();
        ddoTD_M_POSMANUTDO.PHONE = txtPhone.Text.Trim();
        ddoTD_M_POSMANUTDO.FAX = txtFax.Text.Trim();
        ddoTD_M_POSMANUTDO.ZIPCODE = txtZip.Text.Trim();
        ddoTD_M_POSMANUTDO.EMAIL = txtMail.Text.Trim();
        ddoTD_M_POSMANUTDO.ADDRESS = txtAddress.Text.Trim();
        ddoTD_M_POSMANUTDO.USETAG = selUseTag.SelectedValue;
        ddoTD_M_POSMANUTDO.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_POSMANUTDO.UPDATETIME = DateTime.Now;

        int UpdSum = tmTD_M_POSMANUTM.updRecord(context, ddoTD_M_POSMANUTDO);
        if (UpdSum == 0)
            context.AppException("S006105031");

        context.DBCommit();

        PosManuQuery();
        //clearInput();

    }
    public void lvwPosManu_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtCode.Text = getDataKeys("POSMANUCODE");
        txtName.Text = getDataKeys("POSMANUNAME");
        txtPhone.Text = getDataKeys("PHONE");
        txtFax.Text = getDataKeys("FAX");
        txtZip.Text = getDataKeys("ZIPCODE");
        txtMail.Text = getDataKeys("EMAIL");
        txtAddress.Text = getDataKeys("ADDRESS");
        selUseTag.SelectedValue = getDataKeys("USETAG");
    }
    protected void lvwPosManu_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwPosManu','Select$" + e.Row.RowIndex + "')");
        }
    }

    public void lvwPosManu_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwPosManu.PageIndex = e.NewPageIndex;
        PosManuQuery();

        lvwPosManu.SelectedIndex = -1;
        clearInput();
    }

    private string getDataKeys(string keysname)
    {
        return lvwPosManu.DataKeys[lvwPosManu.SelectedIndex][keysname].ToString();
    }

    private void clearInput()
    {
        txtCode.Text = "";
        txtName.Text = "";
        txtPhone.Text = "";
        txtFax.Text = "";
        txtZip.Text = "";
        txtMail.Text = "";
        txtAddress.Text = "";
        selUseTag.SelectedValue = "";
    }

    //输入判断处理
    private bool ValidateInputData()
    {
        //厂商编码非空、数字、长度判断
        string strCode = txtCode.Text.Trim();
        if (strCode == "")
        {
            context.AddError("A006105001", txtCode);
        }
        else
        {
            if (!Validation.isNum(strCode))
            {
                context.AddError("A006105002", txtCode);
            }
            if (Validation.strLen(strCode) != 2)
            {
                context.AddError("A006105003", txtCode);
            }

        }

        //厂商名称非空、长度判断
        string strName = txtName.Text.Trim();
        if (strName == "")
        {
            context.AddError("A006105004", txtName);
        }
        else if (Validation.strLen(strName) > 50)
        {
            context.AddError("A006105006", txtName);
        }

        //当电话不为空时，数字、长度判断
        string strPhone = txtPhone.Text.Trim();
        if(strPhone != ""){
            if (!Validation.isNum(strPhone))
            {
                context.AddError("A006105008", txtPhone);
            }
            if (Validation.strLen(strPhone) > 20)
            {
                context.AddError("A006105009", txtPhone);
            }
        }

        //当传真不为空时，数字、长度判断
        string strFax = txtFax.Text.Trim();
        if (strFax != "")
        {
            if (!Validation.isNum(strFax))
            {
                context.AddError("A006105010", txtFax);
            }
            if(Validation.strLen(strFax) > 20){
                context.AddError("A006105011",txtFax);
            }
        }

        //当邮编不为空时，数字、长度判断
        string strZip = txtZip.Text.Trim();
        if (strZip != "")
        {
            if (!Validation.isNum(strZip))
            {
                context.AddError("A006105012", txtZip);
            }
            if (Validation.strLen(strZip) != 6)
            {
                context.AddError("A006105013", txtZip);
            }
        }

        //邮件地址格式判断
        string strMail = txtMail.Text.Trim();
        if (strMail != "")
        {
            if (!isMail(strMail))
                context.AddError("A006105014", txtMail);

            if (Validation.strLen(strMail) > 30)
                context.AddError("A006105017", txtMail);

        }

        //厂商地址长度判断
        string strAddress = txtAddress.Text.Trim();
        if(strAddress != "" && Validation.strLen(strAddress) > 50)
        {
            context.AddError("A006105015",txtAddress);
        }

        //有效标志非空判断
        string strUseTag = selUseTag.SelectedValue;
        if (strUseTag == "")
        {
            context.AddError("A006111008", selUseTag);
        }

        if (context.hasError())
            return false;
        else
            return true;
    }

    private bool isMail(string mail){
        System.Text.RegularExpressions.Regex reg1
                       = new System.Text.RegularExpressions.Regex(@"^[0-9a-zA-Z]+([-.0-9a-zA-Z]+)*@[0-9a-zA-Z]+([-.][0-9a-zA-Z]+)*\.[0-9a-zA-Z]+([-.0-9a-zA-Z]+)*$");
        return reg1.IsMatch(mail);
    }

}
