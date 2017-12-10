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

using Master;
using Common;
using TM;
using TDO.BalanceChannel;
using PDO.PartnerShip;
using System.Collections.Generic;

public partial class ASP_PartnerShip_PS_DeptInfoChange : Master.Master
{
 
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            TMTableModule tmTMTableModule = new TMTableModule();
            //从行业编码表(TD_M_CALLINGNO)中读取数据，放入查询输入行业名称下拉列表中
            TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
            TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), "S008100211", "TD_M_CALLING_ANDNO", null);

            ControlDeal.SelectBoxFillWithCode(selCalling.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);

            //设置单位信息中行业名称下拉列表值
            ControlDeal.SelectBoxFillWithCode(selCallingExt.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);

            //设置有效标志下拉列表值
            TSHelper.initUseTag(selUseTag);
            
            //设置GridView绑定的DataTable
            lvwDepartQuery.DataSource = new DataTable();
            lvwDepartQuery.DataBind();
            lvwDepartQuery.SelectedIndex = -1;


            //指定GridView DataKeyNames
            lvwDepartQuery.DataKeyNames = new string[] { "DEPARTNO", "DEPART", "LINKMAN", "DEPARTPHONE", "DPARTMARK", "CALLINGNO", "CORPNO", "REMARK", "USETAG" };

           
        }
    }

    public void lvwDepartQuery_Page(Object sender, GridViewPageEventArgs e)
    {

        lvwDepartQuery.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
        ClearDepart();
    }

    //public ICollection CreateDepartQueryDataSource()
    //{
    //    TMTableModule tmTMTableModule = new TMTableModule();

    //    //从部门信息资料表(TD_M_DEPART)中读取数据


    //    TD_M_DEPARTTDO tdoTD_M_DEPARTIn = new TD_M_DEPARTTDO();

    //    string strSql = "SELECT	distinct tdept.USETAG,tdept.DEPARTNO,tdept.DEPART,tcorp.CORP," +
    //                    "tcalling.CALLING,tdept.LINKMAN,tdept.DEPARTPHONE,tdept.DPARTMARK,tdept.CORPNO,tcorp.CALLINGNO,tdept.REMARK ";
    //    strSql += " FROM TD_M_DEPART tdept,	TD_M_CORP tcorp,TD_M_CALLINGNO tcalling,td_m_insidedepart tmid,td_m_insidestaff  tmis,(select regioncode from td_m_insidedepart where departno = '" + context.s_DepartID + "') m,td_m_regioncode r1,td_m_regioncode r2";

    //    ArrayList list = new ArrayList();
    //    list.Add("tcorp.CALLINGNO  = tcalling.CALLINGNO(+)");
    //    list.Add("tdept.CORPNO = tcorp.CORPNO(+)");
    //    //list.Add("tcalling.ISOPEN = '1' ");
    //    //list.Add("tcorp.USETAG = '1'");

    //    if (selCalling.SelectedValue != "")
    //        list.Add("tcalling.CALLINGNO = '" + selCalling.SelectedValue + "'");

    //    if (selCorp.SelectedValue != "")
    //        list.Add("tcorp.CORPNO = '" + selCorp.SelectedValue + "'");

    //    if (selDepart.SelectedValue != "")
    //        list.Add("tdept.DEPARTNO = '" + selDepart.SelectedValue + "'");

    //    list.Add("tdept.updatestaffno = tmis.staffno");
    //    list.Add("tmis.departno = tmid.departno");
    //    list.Add("(tmid.regioncode = r1.regioncode and r1.regionname = r2.regionname and r2.regioncode = m.regioncode)or m.regioncode is null");
    //    strSql += DealString.ListToWhereStr(list);

    //    strSql += " order by tdept.DEPARTNO ";

    //    DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTD_M_DEPARTIn, null, strSql, 0);
    //    DataView dataView = new DataView(data);

    //    return dataView;

    //}


    protected void btnQuery_Click(object sender, EventArgs e)
    {

        //查询部门信息 
        List<string> vars = new List<string>();
        vars.Add(selCalling.SelectedValue);//行业
        vars.Add(selCorp.SelectedValue);//单位
        vars.Add(selDepart.SelectedValue);//部门
        vars.Add(context.s_DepartID);//当前营业员部门
        DataTable data = SPHelper.callQuery("SP_PS_Query", context, "QueryDeptInfo", vars.ToArray());
        if (data == null || data.Rows.Count < 1)
        {            
            context.AddError("未查出部门信息");
            UserCardHelper.resetData(lvwDepartQuery, data);
            return;
        }
        UserCardHelper.resetData(lvwDepartQuery, data);
        //设置单位名称下拉列表值
        ClearDepart();
        

   

    }


    private void DepartInputValidation()
    {
        //对部门编码非空,长度,数字的判断
        string strDepartNo = txtDepartNo.Text.Trim();
        if(strDepartNo == "")
            context.AddError("A008103103", txtDepartNo);
        else if(Validation.strLen(strDepartNo)!= 4)
            context.AddError("A008103104", txtDepartNo);
        else if(!Validation.isCharNum(strDepartNo))
            context.AddError("A008103105", txtDepartNo);

        //对部门名称进行非空,长度校验
        string strDepart = txtDepart.Text.Trim();
        if (strDepart == "")
            context.AddError("A008103002", txtDepart);
        else if (Validation.strLen(strDepart) > 40)
            context.AddError("A008103003", txtDepart);

        //对单位进行非空的检验
        string strCorpExt = selCorpExt.SelectedValue;
        if (strCorpExt == "")
            context.AddError("A008100002", selCorpExt);

        //对联系人进行非空,长度校验
        string strLinkMan = txtLinkMan.Text.Trim();
        if (strLinkMan == "")
            context.AddError("A008100004", txtLinkMan);
        else if (Validation.strLen(strLinkMan) > 10)
            context.AddError("A008100005", txtLinkMan);

        //对联系电话进行非空,长度校验
        string strPhone = txtPhone.Text.Trim();
        if (strPhone == "")
            context.AddError("A008100006", txtPhone);
        else if (Validation.strLen(strPhone) > 40)
            context.AddError("A008100007", txtPhone);

        //对部门说明进行长度校验
        string strDtRemrk = txtDeptRemark.Text.Trim();
        if (strDtRemrk != "")
        {
            if (Validation.strLen(strDtRemrk) > 50)
                context.AddError("A008103108", txtDeptRemark);
        }

        //对备注进行长度校验
        string strRemrk = txtRemark.Text.Trim();
        if (strRemrk != "")
        {
            if (Validation.strLen(strRemrk) > 100)
                context.AddError("A008100011", txtRemark);
        }

        //对有效标志进行非空检验
        string strUseTag = selUseTag.SelectedValue;
        if (strUseTag == "")
            context.AddError("A008100014", selUseTag);
    }


    private Boolean DepartAddValidation()
    {
        //对输入的单位信息检验
        DepartInputValidation();


        //对有效是否为有效的判断
        string strUseTag = selUseTag.SelectedValue;
        if ( strUseTag != "" && strUseTag != "1")
            context.AddError("A008103017", selUseTag);

        return CheckContext();
    }

    private Boolean DepartModifyValidation()
    {
        //检查是否选定了部门的信息
        if (lvwDepartQuery.SelectedIndex == -1)
        {
            context.AddError("A008103001");
            return false;
        }

        //对输入的单位信息检验
        DepartInputValidation();

        //检查部门编码是否修改
        
        if(txtDepartNo.Text.Trim() != getDataKeys("DEPARTNO") )
        {
            context.AddError("A008103106",txtDepartNo);
            return false;
        }

        //检查是否修改了选定部门的单位名称
        if (selCorpExt.SelectedValue != getDataKeys("CORPNO"))
        {
            context.AddError("A008103015", selCorpExt);
            return false;
        }

        //当部门名称修改后,检测库中是否已存在该部门
        else if (txtDepart.Text.Trim() != getDataKeys("DEPART"))
        {
           return isNotDepartName();
        }

        return CheckContext();
    }


    private Boolean isNotDepartName()
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //从部门编码表(TD_M_CDEPART)中读取数据

        TD_M_DEPARTTDO tdoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
        tdoTD_M_DEPARTIn.CORPNO = selCorpExt.SelectedValue;
        tdoTD_M_DEPARTIn.DEPART = txtDepart.Text.Trim();

        TD_M_DEPARTTDO[] tdoTD_M_DEPARTOutArr = (TD_M_DEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null, "TD_M_DEPARTNAME", null);

        if (tdoTD_M_DEPARTOutArr.Length != 0)
        {
            context.AddError("A008103004", txtDepart);
            return false;
        }

        return true;
    }



    private Boolean CheckContext()
    {
        //对context的error检测 
        if (context.hasError())
            return false;
        else
            return true;
    }


    private bool isExistDepartNo()
    { 
        //是否已存在当前部门编码
        TMTableModule tmTMTableModule = new TMTableModule();
        //从部门编码表(TD_M_CDEPART)中读取数据

        TD_M_DEPARTTDO tdoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
        tdoTD_M_DEPARTIn.DEPARTNO = txtDepartNo.Text.Trim();

        TD_M_DEPARTTDO[] tdoTD_M_DEPARTOutArr = (TD_M_DEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null, "TD_M_DEPART_BYNO", null);

        if (tdoTD_M_DEPARTOutArr.Length != 0)
        {
            context.AddError("A008103107", txtDepartNo);
        }

        isNotDepartName();

        return context.hasError();
    }


    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!DepartAddValidation()) return;

        //检查部门编码是否已存在
        if (isExistDepartNo()) return;

        //执行部门信息增加的存储过程
        SP_PS_DeptInfoChangeAddPDO ddoSP_PS_DeptInfoChangeAddPDOIn = new SP_PS_DeptInfoChangeAddPDO();

        ddoSP_PS_DeptInfoChangeAddPDOIn.departNo = txtDepartNo.Text.Trim();
        ddoSP_PS_DeptInfoChangeAddPDOIn.depart = txtDepart.Text.Trim();
        ddoSP_PS_DeptInfoChangeAddPDOIn.corpNo = selCorpExt.SelectedValue;

        ddoSP_PS_DeptInfoChangeAddPDOIn.dpartMark  = txtDeptRemark.Text.Trim();
        ddoSP_PS_DeptInfoChangeAddPDOIn.dpartPhone = txtPhone.Text.Trim();
        ddoSP_PS_DeptInfoChangeAddPDOIn.linkMan    = txtLinkMan.Text.Trim();
        ddoSP_PS_DeptInfoChangeAddPDOIn.remark     = txtRemark.Text.Trim();

        bool ok = TMStorePModule.Excute(context, ddoSP_PS_DeptInfoChangeAddPDOIn);

        if (ok)
        {
            AddMessage("M008103113");
          
            //清除输入的部门信息
            // ClearDepart();

            btnQuery_Click(sender, e);

        }
    }
    protected void btnModify_Click(object sender, EventArgs e)
    {
        if (!DepartModifyValidation()) return;
        //修改部门信息

        //执行部门信息修改的存储过程
        SP_PS_DeptInfoChangeModifyPDO ddoSP_PS_DeptInfoChangeModifyPDOIn = new SP_PS_DeptInfoChangeModifyPDO();

        ddoSP_PS_DeptInfoChangeModifyPDOIn.depart   = txtDepart.Text.Trim();
        ddoSP_PS_DeptInfoChangeModifyPDOIn.departNo = getDataKeys("DEPARTNO"); 
        ddoSP_PS_DeptInfoChangeModifyPDOIn.corpNo   = selCorpExt.SelectedValue;

        ddoSP_PS_DeptInfoChangeModifyPDOIn.dpartMark  = txtDeptRemark.Text.Trim();
        ddoSP_PS_DeptInfoChangeModifyPDOIn.dpartPhone = txtPhone.Text.Trim();
        ddoSP_PS_DeptInfoChangeModifyPDOIn.linkMan    = txtLinkMan.Text.Trim();
        ddoSP_PS_DeptInfoChangeModifyPDOIn.remark     = txtRemark.Text.Trim();
        ddoSP_PS_DeptInfoChangeModifyPDOIn.useTag     = selUseTag.SelectedValue;

        bool ok = TMStorePModule.Excute(context, ddoSP_PS_DeptInfoChangeModifyPDOIn);

        if (ok)
        {
            AddMessage("M008103111");

            
            //清除输入的部门信息
            //ClearDepart();

            btnQuery_Click(sender, e);
        }

        

                 
    }

   private void ClearDepart()
   {
       txtDepartNo.Text = "";
       txtDepart.Text    ="";
       txtDeptRemark.Text="";
       txtLinkMan.Text   ="";
       txtPhone.Text     = "";
       txtRemark.Text    ="";
       selUseTag.SelectedValue="";
      // selCorpExt.SelectedValue ="";
       selCallingExt.SelectedValue ="";
       selCorpExt.Items.Clear();

   }


    protected void selCalling_SelectedIndexChanged(object sender, EventArgs e)
    {
        //查询选择行业后,设置单位名称下拉列表值
        selCorp.Items.Clear();
        selDepart.Items.Clear();
       
        if (selCalling.SelectedValue != "")
            InitCorp(selCalling, selCorp, "TD_M_CORPCALLUSAGE");

    }
    protected void selCorp_SelectedIndexChanged(object sender, EventArgs e)
    {
        //查询选择单位后,设置部门名称下拉列表值
        if (selCorp.SelectedValue == "")
        {
            selDepart.Items.Clear();
        }
        else
        {
            TMTableModule tmTMTableModule = new TMTableModule();
            //从部门编码表(TD_M_CDEPART)中读取数据，放入下拉列表中

            TD_M_DEPARTTDO tdoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
            tdoTD_M_DEPARTIn.CORPNO = selCorp.SelectedValue;

            TD_M_DEPARTTDO[] tdoTD_M_DEPARTOutArr = (TD_M_DEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null, "TD_M_DEPART_USE", null);
            ControlDeal.SelectBoxFillWithCode(selDepart.Items, tdoTD_M_DEPARTOutArr, "DEPART", "DEPARTNO", true);
            			
        }
    }
    protected void selCallingExt_SelectedIndexChanged(object sender, EventArgs e)
    {
        //增加或者修改部门信息时,选择行业名称后,设置单位名称下拉列表值
        if (selCallingExt.SelectedValue == "")
        {
            selCorpExt.Items.Clear();
            return;
        }
        InitCorp(selCallingExt, selCorpExt, "TD_M_CORPCALLUSAGE");
    }


    protected void InitCorp(DropDownList origindwls, DropDownList extdwls, String sqlCondition)
    {
        // 从单位编码表(TD_M_CORP)中读取数据，放入增加,修改区域中单位信息下拉列表中
        
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
        tdoTD_M_CORPIn.CALLINGNO = origindwls.SelectedValue;

        TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, sqlCondition, null);
        ControlDeal.SelectBoxFillWithCode(extdwls.Items, tdoTD_M_CORPOutArr, "CORP", "CORPNO", true);
    }


    protected void lvwDepartQuery_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwDepartQuery','Select$" + e.Row.RowIndex + "')");
        }
    }

    public void lvwDepartQuery_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择列表框一行记录后,设置部门信息增加,修改区域中数据
        txtDepartNo.Text   = getDataKeys("DEPARTNO");
        txtDepart.Text     = getDataKeys("DEPART");
        txtDeptRemark.Text = getDataKeys("DPARTMARK");
        txtLinkMan.Text    = getDataKeys("LINKMAN");
        txtPhone.Text      = getDataKeys("DEPARTPHONE");
        txtRemark.Text     = getDataKeys("REMARK");
        selUseTag.SelectedValue = getDataKeys("USETAG");
       

        //选择一条记录后,显示该行业名称
        try
        {
            selCallingExt.SelectedValue = getDataKeys("CALLINGNO");

            //初始化该行业下的单位信息
            InitCorp(selCallingExt, selCorpExt, "TD_M_CORP");

            //设置选择当前的部门的单位信息
            string corpno = getDataKeys("CORPNO");

            selCorpExt.SelectedValue = corpno;
        }
        catch (Exception)
        {
            selCallingExt.SelectedValue = "";
            selCorpExt.SelectedValue = "";
        }
    }

    //private string GetCorpCode(string strCorpCode)
    //{
    //    TD_M_CORPTDO ddoTD_M_CORPIn = new TD_M_CORPTDO();
    //    ddoTD_M_CORPIn.CORPNO = strCorpCode;

    //    TMTableModule tmTMTableModule = new TMTableModule();

    //    TD_M_CORPTDO ddoTD_M_CORPOut = (TD_M_CORPTDO)tmTMTableModule.selByPK(context, ddoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, "TD_M_CORP_BYNO", null);

    //    if (ddoTD_M_CORPOut == null || ddoTD_M_CORPOut.USETAG == "0")
    //        return "";
    //    else
    //        return strCorpCode;

    //}


    public String getDataKeys(string keysname)
    {
        return lvwDepartQuery.DataKeys[lvwDepartQuery.SelectedIndex][keysname].ToString().Trim();
    }

}
