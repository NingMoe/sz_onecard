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

public partial class ASP_EquipmentManagement_EM_CardManu : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            //初始化有效标志
            TSHelper.initUseTag(selUseTag);

            //初始化卡厂商列表
            CardManuQuery();
        }
    }

    //初始化卡厂商列表
    private void CardManuQuery()
    {

        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_MANUTDO tdoCardManu = new TD_M_MANUTDO();

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoCardManu, null, "", 0);
        DataView dataView = new DataView(data);

        lvwCardManu.DataKeyNames = new string[] { "MANUCODE", "MANUNAME", "MANUNOTE", "USETAG" };
        lvwCardManu.DataSource = dataView;
        lvwCardManu.DataBind();

    }

    //增加
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        //判断处理
        if (!ValidateInputData())
            return;

        //判断卡厂商编码是否已存在
        TD_M_MANUTDO ddoTD_M_MANUTDOIn = new TD_M_MANUTDO();
        TD_M_MANUTM tmTD_M_MANUTM = new TD_M_MANUTM();
        ddoTD_M_MANUTDOIn.MANUCODE = txtCardManuCode.Text.Trim();

        if (!tmTD_M_MANUTM.chkCardManu(context, ddoTD_M_MANUTDOIn))
            return;

        //插入新记录
        ddoTD_M_MANUTDOIn.MANUNAME = txtCardManuName.Text.Trim();
        ddoTD_M_MANUTDOIn.MANUNOTE = txtCardManuNote.Text.Trim();
        ddoTD_M_MANUTDOIn.USETAG = selUseTag.SelectedValue;
        ddoTD_M_MANUTDOIn.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_MANUTDOIn.UPDATETIME = DateTime.Now;

        int AddSum = tmTD_M_MANUTM.insAdd(context, ddoTD_M_MANUTDOIn);
        //插入数据不成功显示错误信息
        if (AddSum == 0)
            context.AppException("S006112021");

        context.DBCommit();

        //更新卡厂商列表
        CardManuQuery();
        lvwCardManu.SelectedIndex = -1;

        //清除输入框
        clearInput();
    }

    //修改
    protected void btnModify_Click(object sender, EventArgs e)
    {
        //当没有选择要修改的卡厂商信息时
        if (lvwCardManu.SelectedIndex == -1)
        {
            context.AddError("A006112030");
            return;
        }

        //当卡厂商编码被修改时
        if (txtCardManuCode.Text.Trim() != getDataKeys("MANUCODE"))
        {
            context.AddError("A006112031", txtCardManuCode);
            return;
        }

        //输入判断处理
        if (!ValidateInputData())
            return;

        TD_M_MANUTDO ddoTD_M_MANUTDOIn = new TD_M_MANUTDO();
        TD_M_MANUTM tmTD_M_MANUTM = new TD_M_MANUTM();
        ddoTD_M_MANUTDOIn.MANUCODE = txtCardManuCode.Text.Trim();
        ddoTD_M_MANUTDOIn.MANUNAME = txtCardManuName.Text.Trim();
        ddoTD_M_MANUTDOIn.MANUNOTE = txtCardManuNote.Text.Trim();
        ddoTD_M_MANUTDOIn.USETAG = selUseTag.SelectedValue;
        ddoTD_M_MANUTDOIn.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_MANUTDOIn.UPDATETIME = DateTime.Now;

        int AddSum = tmTD_M_MANUTM.updRecord(context, ddoTD_M_MANUTDOIn);
        //更新数据不成功显示错误信息
        if (AddSum == 0)
            context.AppException("S006112023");

        context.DBCommit();

        //更新卡厂商列表
        CardManuQuery();

    }
    public void lvwCardManu_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtCardManuCode.Text = getDataKeys("MANUCODE");
        txtCardManuName.Text = getDataKeys("MANUNAME");
        txtCardManuNote.Text = getDataKeys("MANUNOTE");
        selUseTag.SelectedValue = getDataKeys("USETAG");
    }
    protected void lvwCardManu_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwCardManu','Select$" + e.Row.RowIndex + "')");
        }
    }

    public void lvwCardManu_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwCardManu.PageIndex = e.NewPageIndex;
        CardManuQuery();

        lvwCardManu.SelectedIndex = -1;
        clearInput();
    }

    private string getDataKeys(string keysname)
    {
        return lvwCardManu.DataKeys[lvwCardManu.SelectedIndex][keysname].ToString();
    }

    private void clearInput()
    {
        txtCardManuCode.Text = "";
        txtCardManuName.Text = "";
        txtCardManuNote.Text = "";
        selUseTag.SelectedValue = "";
    }

    private bool ValidateInputData()
    {
        //厂商编码非空、数字、长度判断
        string strCardManuCode = txtCardManuCode.Text.Trim();
        if (strCardManuCode == "")
            context.AddError("A006112001", txtCardManuCode);
        else
        {
            if (!Validation.isNum(strCardManuCode))
                context.AddError("A006112002", txtCardManuCode);

            if (Validation.strLen(strCardManuCode) != 2)
                context.AddError("A006112003", txtCardManuCode);

        }

        //厂商名称非空、长度判断
        string strCardManuName = txtCardManuName.Text.Trim();
        if (strCardManuName == "")
            context.AddError("A006112004", txtCardManuName);
        else if (Validation.strLen(strCardManuName) > 50)
            context.AddError("A006112006", txtCardManuName);

        //厂商说明长度判断
        string strCardManuNote = txtCardManuNote.Text.Trim();
        if (strCardManuNote != "")
            if (Validation.strLen(strCardManuNote) > 150)
                context.AddError("A006112008", txtCardManuNote);

        //有效标志非空判断
        string strUseTag = selUseTag.SelectedValue;
        if (strUseTag == "")
            context.AddError("A006112009", selUseTag);

        if (context.hasError())
            return false;
        else
            return true;
    }
}
