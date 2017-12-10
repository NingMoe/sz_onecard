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

using Common;
using TM;
using TM.EquipmentManagement;
using TDO.CardManager;

public partial class ASP_EquipmentManagement_EM_CardChipType : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化有效标志
            TSHelper.initUseTag(selUseTag);

            //初始化卡类型列表
            CardChipTypeQuery();
        }
    }

    //初始化卡类型列表
    private void CardChipTypeQuery()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_CARDCHIPTYPETDO tdoCardChipType = new TD_M_CARDCHIPTYPETDO();

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoCardChipType, null, "", 0);
        DataView dataView = new DataView(data);

        lvwCardChipType.DataKeyNames = new string[] { "CARDCHIPTYPECODE", "CARDCHIPTYPENAME", "CARDCHIPTYPENOTE", "USETAG" };
        lvwCardChipType.DataSource = dataView;
        lvwCardChipType.DataBind();

    }

    //增加
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        //输入判断处理
        if (!ValidateInputData())
            return;

        //判断COS类型编码是否已存在 
        TD_M_CARDCHIPTYPETDO ddoTD_M_CARDCHIPTYPETDOIn = new TD_M_CARDCHIPTYPETDO();
        TD_M_CARDCHIPTYPETM tmTD_M_CARDCHIPTYPETM = new TD_M_CARDCHIPTYPETM();
        ddoTD_M_CARDCHIPTYPETDOIn.CARDCHIPTYPECODE = txtCode.Text.Trim();

        if (!tmTD_M_CARDCHIPTYPETM.chkCardChipType(context, ddoTD_M_CARDCHIPTYPETDOIn))
        {
            context.AddError("A006115010", txtCode);
            return;
        }

        //插入新记录
        ddoTD_M_CARDCHIPTYPETDOIn.CARDCHIPTYPENAME = txtName.Text.Trim();
        ddoTD_M_CARDCHIPTYPETDOIn.CARDCHIPTYPENOTE = txtNote.Text.Trim();
        ddoTD_M_CARDCHIPTYPETDOIn.USETAG = selUseTag.SelectedValue;
        ddoTD_M_CARDCHIPTYPETDOIn.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_CARDCHIPTYPETDOIn.UPDATETIME = DateTime.Now;

        int AddSum = tmTD_M_CARDCHIPTYPETM.insAdd(context, ddoTD_M_CARDCHIPTYPETDOIn);
        if (AddSum == 0)
            context.AppException("S006115011");

        context.DBCommit();

        //更新列表
        CardChipTypeQuery();
        lvwCardChipType.SelectedIndex = -1;

        //清除输入框 
        clearInput();
    }

    //修改
    protected void btnModify_Click(object sender, EventArgs e)
    {
        //当没有选择要修改的卡芯片类型信息时
        if (lvwCardChipType.SelectedIndex == -1)
        {
            context.AddError("A006115021");
            return;
        }

        //当卡芯片类型编码被修改时
        if (txtCode.Text.Trim() != getDataKeys("CARDCHIPTYPECODE"))
        {
            context.AddError("A006115022", txtCode);
        }

        if (!ValidateInputData())
            return;

        //更新记录
        TD_M_CARDCHIPTYPETDO ddoTD_M_CARDCHIPTYPETDOIn = new TD_M_CARDCHIPTYPETDO();
        TD_M_CARDCHIPTYPETM tmTD_M_CARDCHIPTYPETM = new TD_M_CARDCHIPTYPETM();
        ddoTD_M_CARDCHIPTYPETDOIn.CARDCHIPTYPECODE = txtCode.Text.Trim();
        ddoTD_M_CARDCHIPTYPETDOIn.CARDCHIPTYPENAME = txtName.Text.Trim();
        ddoTD_M_CARDCHIPTYPETDOIn.CARDCHIPTYPENOTE = txtNote.Text.Trim();
        ddoTD_M_CARDCHIPTYPETDOIn.USETAG = selUseTag.SelectedValue;
        ddoTD_M_CARDCHIPTYPETDOIn.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_CARDCHIPTYPETDOIn.UPDATETIME = DateTime.Now;

        int UpdSum = tmTD_M_CARDCHIPTYPETM.updRecord(context, ddoTD_M_CARDCHIPTYPETDOIn);
        if(UpdSum == 0)
            context.AddError("S006115020");

        context.DBCommit();

        //更新列表
        CardChipTypeQuery();

    }
    public void lvwCardChipType_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtCode.Text = getDataKeys("CARDCHIPTYPECODE");
        txtName.Text = getDataKeys("CARDCHIPTYPENAME");
        txtNote.Text = getDataKeys("CARDCHIPTYPENOTE");
        selUseTag.SelectedValue = getDataKeys("USETAG");
    }
    protected void lvwCardChipType_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwCardChipType','Select$" + e.Row.RowIndex + "')");
        }
    }

    public void lvwCardChipType_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwCardChipType.PageIndex = e.NewPageIndex;
        CardChipTypeQuery();

        lvwCardChipType.SelectedIndex = -1;
        clearInput();
    }

    private string getDataKeys(string keysname)
    {
        return lvwCardChipType.DataKeys[lvwCardChipType.SelectedIndex][keysname].ToString();
    }

    private void clearInput()
    {
        txtCode.Text = "";
        txtName.Text = "";
        txtNote.Text = "";
        selUseTag.SelectedValue = "";
    }

    //输入判断处理
    private bool ValidateInputData()
    {
        //卡芯片类型编码非空、数字、长度判断
        string strCode = txtCode.Text.Trim();
        if (strCode == "")
        {
            context.AddError("A006115001", txtCode);
        }
        else
        {
            if (!Validation.isNum(strCode))
            {
                context.AddError("A006115002", txtCode);
            }
            if (Validation.strLen(strCode) != 2)
            {
                context.AddError("A006115003", txtCode);
            }

        }

        //卡芯片类型名称非空、长度判断
        string strName = txtName.Text.Trim();
        if (strName == "")
        {
            context.AddError("A006115004", txtName);
        }
        else if (Validation.strLen(strName) > 20)
        {
            context.AddError("A006115005", txtName);
        }

        //当卡芯片类型说明不为空时的长度判断
        string strNote = txtNote.Text.Trim();
        if (strNote != "")
        {
            if (Validation.strLen(strNote) > 120)
            {
                context.AddError("A006115006", txtNote);
            }
        }

        //有效标志非空判断
        string strUseTag = selUseTag.SelectedValue;
        if (strUseTag == "")
        {
            context.AddError("A006115007", selUseTag);
        }

        if(context.hasError())
            return false;
        else
            return true;

    }
}
