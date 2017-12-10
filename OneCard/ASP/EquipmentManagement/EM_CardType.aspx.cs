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
using Common;
using TDO.CardManager;
using TM.EquipmentManagement;

public partial class ASP_EquipmentManagement_EM_CardType : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化有效标志
            TSHelper.initUseTag(selUseTag);

            //初始化卡类型列表
            CardTypeQuery(); 
        }
    }
    private void CardTypeQuery()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_CARDTYPETDO tdoCardType = new TD_M_CARDTYPETDO();

        string strSql = "SELECT	CARDTYPECODE,CARDTYPENAME,CARDTYPENOTE,CARDRETURN,USETAG FROM TD_M_CARDTYPE";

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoCardType, null, strSql, 0);
        DataView dataView = new DataView(data);

        lvwCardType.DataKeyNames = new string[] { "CARDTYPECODE", "CARDTYPENAME", "CARDTYPENOTE","CARDRETURN", "USETAG" };
        lvwCardType.DataSource = dataView;
        lvwCardType.DataBind();

    }
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!ValidateInputData())
            return;

        //判断CARD类型编码是否已存在
        TD_M_CARDTYPETM tmTD_M_CARDTYPETM = new TD_M_CARDTYPETM();
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPETDOIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPETDOIn.CARDTYPECODE = txtCode.Text.Trim();

        if (!tmTD_M_CARDTYPETM.chkCardType(context, ddoTD_M_CARDTYPETDOIn))
        {
            context.AddError("A006113010", txtCode);
            return;
        }

        ddoTD_M_CARDTYPETDOIn.CARDTYPENAME = txtName.Text.Trim();
        ddoTD_M_CARDTYPETDOIn.CARDTYPENOTE = txtNote.Text.Trim();
        ddoTD_M_CARDTYPETDOIn.CARDRETURN = cbReturn.Checked ? "1" : "0";
        ddoTD_M_CARDTYPETDOIn.USETAG = selUseTag.SelectedValue;
        ddoTD_M_CARDTYPETDOIn.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_CARDTYPETDOIn.UPDATETIME = DateTime.Now;

        int AddSum = tmTD_M_CARDTYPETM.insAdd(context, ddoTD_M_CARDTYPETDOIn);
        if (AddSum == 0)
        {
            context.AppException("S006113020");
            return;
        }

        context.DBCommit();

        CardTypeQuery();
        lvwCardType.SelectedIndex = -1;

    }
    protected void btnModify_Click(object sender, EventArgs e)
    {
        //当没有选择要修改的卡类型信息时
        if (lvwCardType.SelectedIndex == -1)
        {
            context.AddError("A006113030");
            return;
        }
        //当卡类型编码被修改时
        if (txtCode.Text.Trim() != getDataKeys("CARDTYPECODE"))
            context.AddError("A006113031", txtCode);

        if (!ValidateInputData())
            return;

        TD_M_CARDTYPETM tmTD_M_CARDTYPETM = new TD_M_CARDTYPETM();
        TD_M_CARDTYPETDO ddoTD_M_CARDTYPETDOIn = new TD_M_CARDTYPETDO();
        ddoTD_M_CARDTYPETDOIn.CARDTYPECODE = txtCode.Text.Trim();
        ddoTD_M_CARDTYPETDOIn.CARDTYPENAME = txtName.Text.Trim();
        ddoTD_M_CARDTYPETDOIn.CARDTYPENOTE = txtNote.Text.Trim();
        ddoTD_M_CARDTYPETDOIn.CARDRETURN = cbReturn.Checked ? "1" : "0";
        ddoTD_M_CARDTYPETDOIn.USETAG = selUseTag.SelectedValue;
        ddoTD_M_CARDTYPETDOIn.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_CARDTYPETDOIn.UPDATETIME = DateTime.Now;

        int UpdSum = tmTD_M_CARDTYPETM.updRecord(context, ddoTD_M_CARDTYPETDOIn);
        if (UpdSum == 0)
        {
            context.AppException("A006113040");
            return;
        }

        context.DBCommit();

        CardTypeQuery();
    }

    public void lvwCardType_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtCode.Text = getDataKeys("CARDTYPECODE");
        txtName.Text = getDataKeys("CARDTYPENAME");
        txtNote.Text = getDataKeys("CARDTYPENOTE");
        string strReturn = getDataKeys("CARDRETURN");
        cbReturn.Checked = strReturn == "1" ? true : false;
        selUseTag.SelectedValue = getDataKeys("USETAG");
    }
    protected void lvwCardType_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwCardType','Select$" + e.Row.RowIndex + "')");
        }
    }

    public void lvwCardType_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwCardType.PageIndex = e.NewPageIndex;
        CardTypeQuery();

        lvwCardType.SelectedIndex = -1;
        clearInput();
    }

    private string getDataKeys(string keysname)
    {
        return lvwCardType.DataKeys[lvwCardType.SelectedIndex][keysname].ToString();
    }

    private void clearInput()
    {
        txtCode.Text = "";
        txtName.Text = "";
        txtNote.Text = "";
        cbReturn.Checked = false;
        selUseTag.SelectedValue = "";
    }
    private bool ValidateInputData()
    {
        //卡类型编码非空、数字、长度判断
        string strCode = txtCode.Text.Trim();
        if (strCode == "")
        {
            context.AddError("A006113001", txtCode);
        }
        else
        {
            if (!Validation.isNum(strCode))
            {
                context.AddError("A006113002", txtCode);
            }
            if (Validation.strLen(strCode) != 2)
            {
                context.AddError("A006113003", txtCode);
            }
        }

        //卡类型名称非空、长度判断
        string strName = txtName.Text.Trim();
        if (strName == "")
        {
            context.AddError("A006113004", txtName);
        }
        else if (Validation.strLen(strName) > 20)
        {
            context.AddError("A006113005", txtName);
        }

        //卡类型说明非空时长度判断
        string strNote = txtNote.Text.Trim();
        if (strNote != "" && Validation.strLen(strNote) > 150)
        {
            context.AddError("A006113006", txtNote);
        }

        //有效标志非空判断
        string strUseTag = selUseTag.SelectedValue;
        if (strUseTag == "")
        {
            context.AddError("A006113007", selUseTag);
        }

        if (context.hasError())
            return false;
        else
            return true;
    }
}
