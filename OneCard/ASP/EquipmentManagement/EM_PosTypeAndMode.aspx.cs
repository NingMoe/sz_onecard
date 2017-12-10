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
using TDO.ResourceManager;

public partial class ASP_EquipmentManagement_EM_PosTypeAndMode : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化查询对象

            selTable.Items.Add(new ListItem("---请选择---", ""));
            selTable.Items.Add(new ListItem("00:POS型号", "00"));
            selTable.Items.Add(new ListItem("01:接触类型", "01"));
            selTable.Items.Add(new ListItem("02:放置类型", "02"));
            selTable.Items.Add(new ListItem("03:通信类型", "03"));

            //初始化有效标志
            TSHelper.initUseTag(selUseTag);

            //初始化表头
            DataTable data = new DataTable();
            DataView dataView = new DataView(data);

            lvwEquipTypeAndMode.DataKeyNames = new string[] { "CODE", "TYPE", "NOTE", "USETAG" };
            lvwEquipTypeAndMode.DataSource = dataView;
            lvwEquipTypeAndMode.DataBind();
            
        }

    }

    //查询
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        string table = selTable.SelectedValue;
        hidTable.Value = table;

        Query(table);
        lvwEquipTypeAndMode.SelectedIndex = -1;

        ClearInput();
    }

    //根据查询对象查询数据，并填充列表
    private void Query(string table)
    {
        DataTable data = null;
        switch (table)
        {
            case "00":
                data = PosModeQuery();
                break;
            case "01":
                data = TouchTypeQuery();
                break;
            case "02":
                data = LayTypeQuery();
                break;
            case "03":
                data = CommTypeQuery();
                break;
            default:
                context.AddError("A006200001", selTable);
                break;
        }

        DataView dataView = new DataView(data);

        lvwEquipTypeAndMode.DataKeyNames = new string[] { "CODE", "NAME", "NOTE", "USETAG" };
        lvwEquipTypeAndMode.DataSource = dataView;
        lvwEquipTypeAndMode.DataBind();
    }

    //查询POS型号
    private DataTable PosModeQuery()
    {     
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_POSMODETDO ddoTD_M_POSMODETDOIn = new TD_M_POSMODETDO();

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTD_M_POSMODETDOIn, null, "TD_M_POSMODE_ALL", null, 0);

        return data;
    }

    //查询POS接触类型
    private DataTable TouchTypeQuery()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_POSTOUCHTYPETDO ddoTD_M_POSTOUCHTYPETDOIn = new TD_M_POSTOUCHTYPETDO();

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTD_M_POSTOUCHTYPETDOIn, null, "TD_M_POSTOUCHTYPE_ALL", null, 0);

        return data;
    }

    //查询POS放置类型
    private DataTable LayTypeQuery()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_POSLAYTYPETDO ddoTD_M_POSLAYTYPETDOIn = new TD_M_POSLAYTYPETDO();

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTD_M_POSLAYTYPETDOIn, null, "TD_M_POSLAYTYPE_ALL", null, 0);

        return data;
    }

    //查询POS通信类型
    private DataTable CommTypeQuery()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_POSCOMMTYPETDO ddoTD_M_POSCOMMTYPETDOIn = new TD_M_POSCOMMTYPETDO();

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTD_M_POSCOMMTYPETDOIn, null, "TD_M_POSCOMMTYPE_ALL", null, 0);

        return data;
    }

    //增加
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        //输入验证
        if (!ValidateInputData())
            return;

        //根据查询对象，增加对应记录
        string table = selTable.SelectedValue;
        switch (table)
        {
            case "00":
                AddPosMode();
                break;
            case "01":
                AddTouchType();
                break;
            case "02":
                AddLayType();
                break;
            case "03":
                AddCommType();
                break;
        }

        if (context.hasError())
            return;

        //刷新列表
        Query(table);
        lvwEquipTypeAndMode.SelectedIndex = -1;

        ClearInput();

    }

    //修改
    protected void btnModify_Click(object sender, EventArgs e)
    {
        //必须已选择一条记录
        if (lvwEquipTypeAndMode.SelectedIndex == -1)
        {
            context.AddError("A006200010");
            return;
        }

        //编码不能修改
        if (txtCode.Text.Trim() != getDataKeys("CODE"))
        {
            context.AddError("A006200011", txtCode);
            return;
        }

        //输入验证
        if (!ValidateInputData())
            return;

        //根据查询对象，修改对应记录
        string table = selTable.SelectedValue;
        switch (table)
        {
            case "00":
                ModifyPosMode();
                break;
            case "01":
                ModifyTouchType();
                break;
            case "02":
                ModifyLayType();
                break;
            case "03":
                ModifyCommType();
                break;
        }

        if (context.hasError())
            return;

        Query(table);

    }

    //增加POS型号
    private void AddPosMode()
    {
        //判断POS型号是否已存在
        TD_M_POSMODETDO ddoTD_M_POSMODETDOIn = new TD_M_POSMODETDO();
        TD_M_POSMODETM tmTD_M_POSMODE = new TD_M_POSMODETM();
        ddoTD_M_POSMODETDOIn.POSMODECODE = txtCode.Text.Trim();

        if (!tmTD_M_POSMODE.chkPosMode(context, ddoTD_M_POSMODETDOIn))
        {
            context.AddError("A006200030", txtCode);
            return;
        }

        //插入新POS型号
        ddoTD_M_POSMODETDOIn.POSMODE = txtName.Text.Trim();
        ddoTD_M_POSMODETDOIn.MODEMARK = txtNote.Text.Trim();
        ddoTD_M_POSMODETDOIn.USETAG = selUseTag.SelectedValue;
        ddoTD_M_POSMODETDOIn.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_POSMODETDOIn.UPDATETIME = DateTime.Now;

        int AddSum = tmTD_M_POSMODE.insAdd(context, ddoTD_M_POSMODETDOIn);
        //插入数据不成功显示错误信息
        if (AddSum == 0)
        {
            context.AppException("S006200031");
        }

        context.DBCommit();
    }

    //增加POS接触类型
    private void AddTouchType()
    {
        //判断接触类型是否已存在
        TD_M_POSTOUCHTYPETDO ddoTD_M_POSTOUCHTYPETDOIn = new TD_M_POSTOUCHTYPETDO();
        TD_M_POSTOUCHTYPETM tmTD_M_POSTOUCHTYPE = new TD_M_POSTOUCHTYPETM();
        ddoTD_M_POSTOUCHTYPETDOIn.TOUCHTYPECODE = txtCode.Text.Trim();

        if (!tmTD_M_POSTOUCHTYPE.chkTouchType(context,ddoTD_M_POSTOUCHTYPETDOIn))
        {
            context.AddError("A006200032", txtCode);
            return;
        }

        //插入新接触类型
        ddoTD_M_POSTOUCHTYPETDOIn.TOUCHTYPE = txtName.Text.Trim();
        ddoTD_M_POSTOUCHTYPETDOIn.TOUCHTYPENOTE = txtNote.Text.Trim();
        ddoTD_M_POSTOUCHTYPETDOIn.USETAG = selUseTag.SelectedValue;
        ddoTD_M_POSTOUCHTYPETDOIn.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_POSTOUCHTYPETDOIn.UPDATETIME = DateTime.Now;

        int AddSum = tmTD_M_POSTOUCHTYPE.insAdd(context, ddoTD_M_POSTOUCHTYPETDOIn);
        //插入数据不成功显示错误信息
        if (AddSum == 0)
        {
            context.AppException("S006200033");
        }

        context.DBCommit();
    }

    //增加POS放置类型
    private void AddLayType()
    {
        //判断放置类型是否已存在
        TD_M_POSLAYTYPETDO ddoTD_M_POSLAYTYPETDOIn = new TD_M_POSLAYTYPETDO();
        TD_M_POSLAYTYPETM tmTD_M_POSLAYTYPE = new TD_M_POSLAYTYPETM();
        ddoTD_M_POSLAYTYPETDOIn.LAYTYPECODE = txtCode.Text.Trim();

        if (!tmTD_M_POSLAYTYPE.chkLayType(context, ddoTD_M_POSLAYTYPETDOIn))
        {
            context.AddError("A006200034", txtCode);
            return;
        }

        //插入新放置类型
        ddoTD_M_POSLAYTYPETDOIn.LAYTYPE = txtName.Text.Trim();
        ddoTD_M_POSLAYTYPETDOIn.LAYTYPENOTE = txtNote.Text.Trim();
        ddoTD_M_POSLAYTYPETDOIn.USETAG = selUseTag.SelectedValue;
        ddoTD_M_POSLAYTYPETDOIn.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_POSLAYTYPETDOIn.UPDATETIME = DateTime.Now;

        int AddSum = tmTD_M_POSLAYTYPE.insAdd(context, ddoTD_M_POSLAYTYPETDOIn);
        //插入数据不成功显示错误信息
        if (AddSum == 0)
        {
            context.AppException("S006200035");
        }

        context.DBCommit();
    }

    //增加POS通信类型
    private void AddCommType()
    {
        //判断通信类型是否已存在
        TD_M_POSCOMMTYPETDO ddoTD_M_POSCOMMTYPETDOIn = new TD_M_POSCOMMTYPETDO();
        TD_M_POSCOMMTYPETM tmPOSCOMMTYPE = new TD_M_POSCOMMTYPETM();
        ddoTD_M_POSCOMMTYPETDOIn.COMMTYPECODE = txtCode.Text.Trim();

        if (!tmPOSCOMMTYPE.chkCommType(context, ddoTD_M_POSCOMMTYPETDOIn))
        {
            context.AddError("A006200036", txtCode);
            return;
        }

        //插入新通信类型
        ddoTD_M_POSCOMMTYPETDOIn.COMMTYPE = txtName.Text.Trim();
        ddoTD_M_POSCOMMTYPETDOIn.COMMTYPENOTE = txtNote.Text.Trim();
        ddoTD_M_POSCOMMTYPETDOIn.USETAG = selUseTag.SelectedValue;
        ddoTD_M_POSCOMMTYPETDOIn.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_POSCOMMTYPETDOIn.UPDATETIME = DateTime.Now;

        int AddSum = tmPOSCOMMTYPE.insAdd(context, ddoTD_M_POSCOMMTYPETDOIn);
        //插入数据不成功显示错误信息
        if (AddSum == 0)
        {
            context.AppException("S006200037");
        }

        context.DBCommit();
    }

    //修改POS型号
    private void ModifyPosMode()
    {
        //更新表记录
        TD_M_POSMODETDO ddoTD_M_POSMODETDOIn = new TD_M_POSMODETDO();
        TD_M_POSMODETM tmTD_M_POSMODE = new TD_M_POSMODETM();
        ddoTD_M_POSMODETDOIn.POSMODECODE = txtCode.Text.Trim();
        ddoTD_M_POSMODETDOIn.POSMODE = txtName.Text.Trim();
        ddoTD_M_POSMODETDOIn.MODEMARK = txtNote.Text.Trim();
        ddoTD_M_POSMODETDOIn.USETAG = selUseTag.SelectedValue;
        ddoTD_M_POSMODETDOIn.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_POSMODETDOIn.UPDATETIME = DateTime.Now;

        int RecordSum = tmTD_M_POSMODE.updRecord(context, ddoTD_M_POSMODETDOIn);
        //修改数据不成功显示错误信息
        if (RecordSum == 0)
        {
            context.AppException("S006200020");
        }

        context.DBCommit();
    }

    //修改POS接触类型
    private void ModifyTouchType()
    {
        //更新表记录
        TD_M_POSTOUCHTYPETDO ddoTD_M_POSTOUCHTYPETDOIn = new TD_M_POSTOUCHTYPETDO();
        TD_M_POSTOUCHTYPETM tmTD_M_POSTOUCHTYPE = new TD_M_POSTOUCHTYPETM();
        ddoTD_M_POSTOUCHTYPETDOIn.TOUCHTYPECODE = txtCode.Text.Trim();
        ddoTD_M_POSTOUCHTYPETDOIn.TOUCHTYPE = txtName.Text.Trim();
        ddoTD_M_POSTOUCHTYPETDOIn.TOUCHTYPENOTE = txtNote.Text.Trim();
        ddoTD_M_POSTOUCHTYPETDOIn.USETAG = selUseTag.SelectedValue;
        ddoTD_M_POSTOUCHTYPETDOIn.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_POSTOUCHTYPETDOIn.UPDATETIME = DateTime.Now;
        int RecordSum = tmTD_M_POSTOUCHTYPE.updRecord(context, ddoTD_M_POSTOUCHTYPETDOIn);
        //修改数据不成功显示错误信息
        if (RecordSum == 0)
        {
            context.AppException("S006200021");
        }

        context.DBCommit();
    }

    //修改POS放置类型
    private void ModifyLayType()
    {
        //更新表记录
        TD_M_POSLAYTYPETDO ddoTD_M_POSLAYTYPETDOIn = new TD_M_POSLAYTYPETDO();
        TD_M_POSLAYTYPETM tmTD_M_POSLAYTYPE = new TD_M_POSLAYTYPETM();
        ddoTD_M_POSLAYTYPETDOIn.LAYTYPECODE = txtCode.Text.Trim();
        ddoTD_M_POSLAYTYPETDOIn.LAYTYPE = txtName.Text.Trim();
        ddoTD_M_POSLAYTYPETDOIn.LAYTYPENOTE = txtNote.Text.Trim();
        ddoTD_M_POSLAYTYPETDOIn.USETAG = selUseTag.SelectedValue;
        ddoTD_M_POSLAYTYPETDOIn.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_POSLAYTYPETDOIn.UPDATETIME = DateTime.Now;

        int RecordSum = tmTD_M_POSLAYTYPE.updRecord(context, ddoTD_M_POSLAYTYPETDOIn);
        //修改数据不成功显示错误信息
        if (RecordSum == 0)
        {
            context.AppException("S006200022");
        }

        context.DBCommit();
    }

    //修改POS通信类型
    private void ModifyCommType()
    {
        //更新表记录
        TD_M_POSCOMMTYPETDO ddoTD_M_POSCOMMTYPETDOIn = new TD_M_POSCOMMTYPETDO();
        TD_M_POSCOMMTYPETM tmPOSCOMMTYPE = new TD_M_POSCOMMTYPETM();
        ddoTD_M_POSCOMMTYPETDOIn.COMMTYPECODE = txtCode.Text.Trim();
        ddoTD_M_POSCOMMTYPETDOIn.COMMTYPE = txtName.Text.Trim();
        ddoTD_M_POSCOMMTYPETDOIn.COMMTYPENOTE = txtNote.Text.Trim();
        ddoTD_M_POSCOMMTYPETDOIn.USETAG = selUseTag.SelectedValue;
        ddoTD_M_POSCOMMTYPETDOIn.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_POSCOMMTYPETDOIn.UPDATETIME = DateTime.Now;
        int RecordSum = tmPOSCOMMTYPE.updRecord(context, ddoTD_M_POSCOMMTYPETDOIn);
        //修改数据不成功显示错误信息
        if (RecordSum == 0)
        {
            context.AppException("S006200023");
        }

        context.DBCommit();
    }

    public void lvwEquipTypeAndMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtCode.Text = getDataKeys("CODE");
        txtName.Text = getDataKeys("NAME");
        txtNote.Text = getDataKeys("NOTE");
        selUseTag.SelectedValue = getDataKeys("USETAG");

        selTable.SelectedValue = hidTable.Value;
    }
    protected void lvwEquipTypeAndMode_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwEquipTypeAndMode','Select$" + e.Row.RowIndex + "')");
        }
    }

    public void lvwEquipTypeAndMode_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwEquipTypeAndMode.PageIndex = e.NewPageIndex;

        selTable.SelectedValue = hidTable.Value;
        Query(hidTable.Value);

        lvwEquipTypeAndMode.SelectedIndex = -1;
        ClearInput();
    }

    private string getDataKeys(string keysname)
    {
        return lvwEquipTypeAndMode.DataKeys[lvwEquipTypeAndMode.SelectedIndex][keysname].ToString();
    }


    private bool ValidateInputData()
    {
        //查询对象不能为空、不能改变
        if(selTable.SelectedValue == "")
            context.AddError("A006200013", selTable);
        else if (selTable.SelectedValue != hidTable.Value)
            context.AddError("A006200012", selTable);

        //编号非空、数字、长度判断
        string strCode = txtCode.Text.Trim();
        if (strCode == "")
            context.AddError("A006200002", txtCode);
        else
        {
            if (!Validation.isNum(strCode))
                context.AddError("A006200003", txtCode);
            if (Validation.strLen(strCode) != 2)
                context.AddError("A006200004", txtCode);
        }

        //名称非空、长度判断
        string strName = txtName.Text.Trim();
        if (strName == "")
            context.AddError("A006200005", txtName);
        else if (Validation.strLen(strName) > 20)
            context.AddError("A006200006", txtName);

        //说明长度判断
        string strNote = txtNote.Text.Trim();
        if (strNote != "" && Validation.strLen(strNote) > 150)
            context.AddError("A006200007", txtNote);

        //有效标志非空判断
        string strUseTag = selUseTag.SelectedValue;
        if (strUseTag == "")
            context.AddError("A006200008", selUseTag);

        if (context.hasError())
            return false;
        else
            return true;

    }
    private void ClearInput()
    {
        txtCode.Text = "";
        txtName.Text = "";
        txtNote.Text = "";
        selUseTag.SelectedValue = "";
    }

}
