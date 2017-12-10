using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Data;
using Common;
using TM;
using TDO.UserManager;
using TDO.BusinessCode;
using System.IO;
using TDO.BalanceChannel;

public partial class ASP_GroupCard_GC_BuyCardReg : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            hidCardType.Value = "combuycard";
            gvComResult.DataKeyNames = new string[] { "COMPANYNO", "COMPANYNAME", "COMPANYPAPERTYPE", "COMPANYPAPERNO","COMPANYENDTIME","COMPANYMANAGERNO", "NAME", "PAPERTYPE", 
                                                   "PAPERNO"  ,"PAPERENDDATE", "PHONENO", "ADDRESS", "EMAIL" ,"appcalling","registeredcapital","securityvalue"};
            gvPerResult.DataKeyNames = new string[] { "PAPERTYPE", "PAPERNO", "PAPERENDDATE", "NAME", "BIRTHDAY", 
                                                   "SEX"  ,"NATIONALITY", "JOB","PHONENO", "ADDRESS", "EMAIL","appcalling","registeredcapital","securityvalue" };
            initLoad();
            tdFileUpload.Attributes.Add("colspan", "3");
            tdShowPicture.Visible = false;//隐藏上传证件信息图片
            tdMsg.Visible = false;
            //从行业编码表(TD_M_APPCALLINGCODE)中读取数据

            TMTableModule tmTMTableModule = new TMTableModule();
            //TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
            //TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), "S008100211", "TD_M_CALLING_ANDNO", null);
            //ControlDeal.SelectBoxFillWithCode(selCallingExt.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);
            TD_M_APPCALLINGCODETDO ddlTD_M_APPCALLINGCODEIn = new TD_M_APPCALLINGCODETDO();
            TD_M_APPCALLINGCODETDO[] ddoTD_M_APPCALLINGCODEOutArr = (TD_M_APPCALLINGCODETDO[])tmTMTableModule.selByPKArr(context, ddlTD_M_APPCALLINGCODEIn, typeof(TD_M_APPCALLINGCODETDO), "S008113033", "TD_M_APPCALLINGUSETAG", null);
            ControlDeal.SelectBoxFill(selCallingExt.Items, ddoTD_M_APPCALLINGCODEOutArr, "APPCALLING", "APPCALLINGCODE", true);

            selPerCalling.SelectedValue = "7";//个人的购卡应用行业默认为个人行业
        }
       selectTab(this, this.GetType(), hidCardType);
   
       
    }
    //选择选项卡
    private  void selectTab(Page page, Type type, HiddenField hidCardType)
    {
        if (hidCardType.Value.Equals("combuycard"))
            ScriptManager.RegisterStartupScript(page, type, "selectTabScript", "SelectComBuyCard();", true);
        else
            ScriptManager.RegisterStartupScript(page, type, "selectTabScript", "SelectPerBuyCard();", true);
    }
    private void initLoad()
    {
        selActerPapertype1.Items.Add(new ListItem("---请选择---", ""));
        selActerPapertype1.Items.Add(new ListItem("01:组织机构代码证", "01"));
        selActerPapertype1.Items.Add(new ListItem("02:企业营业执照", "02"));
        selActerPapertype1.Items.Add(new ListItem("03:税务登记证", "03"));
        selComPapertype.Items.Add(new ListItem("---请选择---", ""));
        selComPapertype.Items.Add(new ListItem("01:组织机构代码证", "01"));
        selComPapertype.Items.Add(new ListItem("02:企业营业执照", "02"));
        selComPapertype.Items.Add(new ListItem("03:税务登记证", "03"));

        ASHelper.initPaperTypeList(context, selActerPapertype2);//从证件类型编码表(TD_M_PAPERTYPE)中读取数据，放入下拉列表中
        ASHelper.initPaperTypeList(context, selPapertype);
        ASHelper.initPaperTypeList(context, selPerPaperType);

        selCustsex.Items.Add(new ListItem("---请选择---", ""));
        selCustsex.Items.Add(new ListItem("0:男", "0"));
        selCustsex.Items.Add(new ListItem("1:女", "1"));
        
    }
#region 查询
    protected void queryCompanyName(object sender, EventArgs e)
    {
        queryCompany(txtCompanyname, selCompanyname);
    }
    private void queryCompany(TextBox txtCompanyPar, DropDownList selCompanyPar)
    {
        //模糊查询单位名称，并在列表中赋值


        string name = txtCompanyPar.Text.Trim();
        if (name == "")
        {
            selCompanyPar.Items.Clear();
            return;
        }

        TD_M_BUYCARDCOMINFOTDO tdoTD_M_BUYCARDCOMINFOIn = new TD_M_BUYCARDCOMINFOTDO();
        TD_M_BUYCARDCOMINFOTDO[] tdoTD_M_BUYCARDCOMINFOOutArr = null;
        tdoTD_M_BUYCARDCOMINFOIn.COMPANYNAME = "%" + name + "%";
        tdoTD_M_BUYCARDCOMINFOOutArr = (TD_M_BUYCARDCOMINFOTDO[])tm.selByPKArr(context, tdoTD_M_BUYCARDCOMINFOIn, typeof(TD_M_BUYCARDCOMINFOTDO), null, "TD_M_BUYCARDCOMINFO_NAME", null);

        selCompanyPar.Items.Clear();
        if (tdoTD_M_BUYCARDCOMINFOOutArr.Length > 0)
        {
            selCompanyPar.Items.Add(new ListItem("---请选择---", ""));
        }
        foreach (TD_M_BUYCARDCOMINFOTDO ddoComInfo in tdoTD_M_BUYCARDCOMINFOOutArr)
        {
            selCompanyPar.Items.Add(new ListItem(ddoComInfo.COMPANYNAME));
        }
    }
    //查询单位名称
    protected void queryCompany(object sender, EventArgs e)
    {
        queryCompany(txtCompany, selCompany);
    }
    protected void selCompany_Change(object sender, EventArgs e)
    {
        //选择单位时，单位证件类型，单位证件号码赋值


        string comrealname = selCompany.SelectedValue;
        txtCompany.Text = comrealname;
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_BUYCARDCOMINFOTDO tdoTD_M_BUYCARDCOMINFOIn = new TD_M_BUYCARDCOMINFOTDO();
        TD_M_BUYCARDCOMINFOTDO tdoTD_M_BUYCARDCOMINFOOutArr = null;
        tdoTD_M_BUYCARDCOMINFOIn.COMPANYNAME = comrealname;
        tdoTD_M_BUYCARDCOMINFOOutArr = (TD_M_BUYCARDCOMINFOTDO)tmTMTableModule.selByPK(context, tdoTD_M_BUYCARDCOMINFOIn, typeof(TD_M_BUYCARDCOMINFOTDO), null, "TD_M_BUYCARDCOMINFO_NAME", null);
        if (tdoTD_M_BUYCARDCOMINFOOutArr != null)
        {
            selComPapertype.SelectedValue = tdoTD_M_BUYCARDCOMINFOOutArr.COMPANYPAPERTYPE;
            //txtComPaperno.Text = tdoTD_M_BUYCARDCOMINFOOutArr.COMPANYPAPERNO;
        }
        else
        {
            selComPapertype.SelectedValue = "";
            //txtComPaperno.Text = "";
        }
       // clearBuyCardInfo(false);
    }
    protected void selCompanyname_Change(object sender, EventArgs e)
    {
        //单位名称反向赋值


        txtCompanyname.Text = selCompanyname.SelectedValue;
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (hidCardType.Value.Equals("combuycard"))//查询单位购卡
        {
            //验证输入有效性

            
            if (!checkQueryValidation())
                return;

            //查询单位购卡记录
            ICollection dataView = queryComBuyCardReg();
            //DataTable dt = GroupCardHelper.callOrderQuery(context, "QueryComBuyCardInfo", txtActername.Text.Trim(), selActerPapertype1.SelectedValue, txtActerPaperno.Text.Trim(), txtCompanyname.Text.Trim(), txtCompaperno.Text.Trim());
            //没有查询出记录时,显示错误
            if (dataView.Count == 0)
            {
                gvComResult.DataSource = new DataTable();
                gvComResult.DataBind();
                gvComResult.SelectedIndex = -1;
                context.AddError("没有查询出任何记录");
                return;
            }
            combuycardgv.Visible = true;
            //显示Gridview
            gvComResult.DataSource = dataView;
            gvComResult.DataBind();
            hidCompanySecurityValue.Value = "";

        }
        else  //查询个人购卡
        {
            //验证输入有效性

            if (!checkQueryValidation())
                return;

            //查询个人购卡记录
            ICollection dataView = queryPerBuyCardReg();
            //DataTable dt = GroupCardHelper.callOrderQuery(context, "QueryPerBuyCardInfo", txtActername.Text.Trim(), selActerPapertype2.SelectedValue, txtActerPaperno.Text.Trim());
            //没有查询出记录时,显示错误
            if (dataView.Count == 0)
            {
                gvPerResult.DataSource = new DataTable();
                gvPerResult.DataBind();
                gvPerResult.SelectedIndex = -1;
                context.AddError("没有查询出任何记录");
                return;
            }
            perbuycardgv.Visible = true;
            //显示Gridview
            gvPerResult.DataSource = dataView;
            gvPerResult.DataBind();
            hidPersonalSecurityValue.Value = "";
        }

    }
    protected ICollection queryComBuyCardReg()
    {
        //按权限查询单位购卡记录

        //查询网点类型和结算单元编码

        context.DBOpen("Select");
        context.AddField("DEPARTNO").Value = context.s_DepartID;
        string sql = @"SELECT A.DEPTTYPE,A.DBALUNITNO 
                        FROM TF_DEPT_BALUNIT A,TD_DEPTBAL_RELATION B 
                        WHERE  B.DBALUNITNO = A.DBALUNITNO 
                        AND A.USETAG = '1' AND B.USETAG = '1' 
                        AND B.DEPARTNO = :DEPARTNO";
        DataTable table = context.ExecuteReader(sql);
        if (table != null && table.Rows.Count > 0)
        {
            string deptType = table.Rows[0]["DEPTTYPE"].ToString(); //营业厅类型

            string dbalUnitNo = table.Rows[0]["DBALUNITNO"].ToString(); //结算单元编码
            //如果是代理营业厅员工
            if (deptType == "1")
            {
                if (HasOperPower("201009"))//如果是代理营业厅全网点主管
                {
                    //如果是全网点主管，则可以查询结算单元下所有部门的记录情况
                    DataTable data =  GroupCardHelper.callOrderQuery(context, "QueryUnitComBuyCardInfo", txtActername.Text.Trim(), selActerPapertype1.SelectedValue, txtActerPaperno.Text.Trim(), txtCompanyname.Text.Trim(), txtCompaperno.Text.Trim(), dbalUnitNo);
                    return new DataView(data);
                }
                else if (HasOperPower("201010"))//如果是代理营业厅网点主管
                {
                    //如果是网点主管，能查询本部门的记录

                    DataTable data = GroupCardHelper.callOrderQuery(context, "QueryDeptComBuyCardInfo", txtActername.Text.Trim(), selActerPapertype1.SelectedValue, txtActerPaperno.Text.Trim(), txtCompanyname.Text.Trim(), txtCompaperno.Text.Trim(), context.s_DepartID);
                    return new DataView(data);
                }
                //既不是全网点主管也不是网点主管，只能查询到本人的记录，uodate by shil,20120604
                DataTable data1 = GroupCardHelper.callOrderQuery(context, "QueryStaffComBuyCardInfo", txtActername.Text.Trim(), selActerPapertype1.SelectedValue, txtActerPaperno.Text.Trim(), txtCompanyname.Text.Trim(), txtCompaperno.Text.Trim(), context.s_UserID);
                return new DataView(data1);
            }
            else if (deptType == "0") //自营营业厅员工
            {
                if (HasOperPower("201013")) //如果是公司主管，可以查询全部记录，add by shil,20120604
                {
                    DataTable data = GroupCardHelper.callOrderQuery(context, "QueryStaffComBuyCardInfo", txtActername.Text.Trim(), selActerPapertype1.SelectedValue, txtActerPaperno.Text.Trim(), txtCompanyname.Text.Trim(), txtCompaperno.Text.Trim());
                    return new DataView(data);
                }
                else if (HasOperPower("201012")) //如果是部门主管，可以查询本部门的记录，add by shil,20120604
                {
                    DataTable data = GroupCardHelper.callOrderQuery(context, "QueryDeptComBuyCardInfo", txtActername.Text.Trim(), selActerPapertype1.SelectedValue, txtActerPaperno.Text.Trim(), txtCompanyname.Text.Trim(), txtCompaperno.Text.Trim(), context.s_DepartID);
                    return new DataView(data);
                }
                //既不是公司主管也不是部门主管，只能查询到本人的记录

                DataTable data1 = GroupCardHelper.callOrderQuery(context, "QueryStaffComBuyCardInfo", txtActername.Text.Trim(), selActerPapertype1.SelectedValue, txtActerPaperno.Text.Trim(), txtCompanyname.Text.Trim(), txtCompaperno.Text.Trim(), context.s_UserID);
                return new DataView(data1);
            }
            return null;
        }
        else
        {
            //如果没有记录，说明是自营营业厅

            if (HasOperPower("201013")) //如果是公司主管，可以查询全部记录，add by shil,20120604
            {
                DataTable data = GroupCardHelper.callOrderQuery(context, "QueryStaffComBuyCardInfo", txtActername.Text.Trim(), selActerPapertype1.SelectedValue, txtActerPaperno.Text.Trim(), txtCompanyname.Text.Trim(), txtCompaperno.Text.Trim());
                return new DataView(data);
            }
            else if (HasOperPower("201012")) //如果是部门主管，可以查询本部门的记录，add by shil,20120604
            {
                DataTable data = GroupCardHelper.callOrderQuery(context, "QueryDeptComBuyCardInfo", txtActername.Text.Trim(), selActerPapertype1.SelectedValue, txtActerPaperno.Text.Trim(), txtCompanyname.Text.Trim(), txtCompaperno.Text.Trim(), context.s_DepartID);
                return new DataView(data);
            }
            //既不是公司主管也不是部门主管，只能查询到本人的记录

            DataTable data1 = GroupCardHelper.callOrderQuery(context, "QueryStaffComBuyCardInfo", txtActername.Text.Trim(), selActerPapertype1.SelectedValue, txtActerPaperno.Text.Trim(), txtCompanyname.Text.Trim(), txtCompaperno.Text.Trim(), context.s_UserID);
            return new DataView(data1);
        }

    }
    private ICollection queryPerBuyCardReg()
    {
        //按权限查询个人购卡记录

        //查询网点类型和结算单元编码

        context.DBOpen("Select");
        context.AddField("DEPARTNO").Value = context.s_DepartID;
        string sql = @"SELECT A.DEPTTYPE,A.DBALUNITNO 
                        FROM TF_DEPT_BALUNIT A,TD_DEPTBAL_RELATION B 
                        WHERE  B.DBALUNITNO = A.DBALUNITNO 
                        AND A.USETAG = '1' AND B.USETAG = '1' 
                        AND B.DEPARTNO = :DEPARTNO";
        DataTable table = context.ExecuteReader(sql);
        if (table != null && table.Rows.Count > 0)
        {
            string deptType = table.Rows[0]["DEPTTYPE"].ToString(); //营业厅类型

            string dbalUnitNo = table.Rows[0]["DBALUNITNO"].ToString(); //结算单元编码
            //如果是代理营业厅员工
            if (deptType == "1")
            {
                if (HasOperPower("201009"))//如果是代理营业厅全网点主管
                {
                    //如果是全网点主管，则可以查询结算单元下所有部门的记录情况
                    DataTable data = GroupCardHelper.callOrderQuery(context, "QueryUnitPerBuyCardInfo", txtActername2.Text.Trim(), selActerPapertype2.SelectedValue, txtActerPaperno2.Text.Trim(), dbalUnitNo);
                    return new DataView(data);
                }
                else if (HasOperPower("201010"))//如果是代理营业厅网点主管
                {
                    //如果是网点主管，能查询本部门的记录

                    DataTable data = GroupCardHelper.callOrderQuery(context, "QueryDeptPerBuyCardInfo", txtActername2.Text.Trim(), selActerPapertype2.SelectedValue, txtActerPaperno2.Text.Trim(), context.s_DepartID);
                    return new DataView(data);
                }
                //既不是全网点主管也不是网点主管，只能查询到本人的记录
                DataTable data1 = GroupCardHelper.callOrderQuery(context, "QueryStaffPerBuyCardInfo", txtActername2.Text.Trim(), selActerPapertype2.SelectedValue, txtActerPaperno2.Text.Trim(), context.s_UserID);
                return new DataView(data1);
            }
            else if (deptType == "0") //自营营业厅员工
            {
                if (HasOperPower("201013")) //如果是公司主管
                {
                    DataTable data = GroupCardHelper.callOrderQuery(context, "QueryStaffPerBuyCardInfo", txtActername2.Text.Trim(), selActerPapertype2.SelectedValue, txtActerPaperno2.Text.Trim());
                    return new DataView(data);
                }
                else if (HasOperPower("201012")) //如果是部门主管
                {
                    DataTable data = GroupCardHelper.callOrderQuery(context, "QueryDeptPerBuyCardInfo", txtActername2.Text.Trim(), selActerPapertype2.SelectedValue, txtActerPaperno2.Text.Trim(), context.s_DepartID);
                    return new DataView(data);
                }
                //既不是公司主管也不是部门主管，只能查询到本人的记录

                DataTable data1 = GroupCardHelper.callOrderQuery(context, "QueryStaffPerBuyCardInfo", txtActername2.Text.Trim(), selActerPapertype2.SelectedValue, txtActerPaperno2.Text.Trim(), context.s_UserID);
                return new DataView(data1);
            }
            return null;
        }
        else
        {
            //如果没有记录，说明是自营营业厅

            if (HasOperPower("201013")) //如果是公司主管，可以查询全部记录
            {
                DataTable data = GroupCardHelper.callOrderQuery(context, "QueryStaffPerBuyCardInfo", txtActername2.Text.Trim(), selActerPapertype2.SelectedValue, txtActerPaperno2.Text.Trim());
                return new DataView(data);
            }
            else if (HasOperPower("201012")) //如果是部门主管，可以查询本部门的记录
            {
                DataTable data = GroupCardHelper.callOrderQuery(context, "QueryDeptPerBuyCardInfo", txtActername2.Text.Trim(), selActerPapertype2.SelectedValue, txtActerPaperno2.Text.Trim(), context.s_DepartID);
                return new DataView(data);
            }
            //既不是公司主管也不是部门主管，只能查询到本人的记录

            DataTable data1 = GroupCardHelper.callOrderQuery(context, "QueryStaffPerBuyCardInfo", txtActername2.Text.Trim(), selActerPapertype2.SelectedValue, txtActerPaperno2.Text.Trim(), context.s_UserID);
            return new DataView(data1);
        }
    }
    private bool HasOperPower(string powerCode)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
        string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
        DataTable dataSupply = tmTMTableModule.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
        if (dataSupply.Rows.Count > 0)
            return true;
        else
            return false;
    }
   
#endregion
    
    private Boolean checkQueryValidation()
    {
        //对姓名进行长度检验

        if (txtActername.Text.Trim() != "")
            if (Validation.strLen(txtActername.Text.Trim()) > 50)
                context.AddError("姓名字符长度不能大于50", txtActername);

        //对证件号码进行长度、英数字检验

        if (txtActerPaperno.Text.Trim() != "")
            if (!Validation.isCharNum(txtActerPaperno.Text.Trim()))
                context.AddError("证件号码必须为英数", txtActerPaperno);
            else if (Validation.strLen(txtActerPaperno.Text.Trim()) > 20)
                context.AddError("证件号码长度不能超过20位", txtActerPaperno);
           

        //如果是单位购卡还需要对单位证件号码进行英数字检验
        if (hidCardType.Value.Equals("combuycard"))
        {
            if (txtCompaperno.Text.Trim()!="")
            {
                if (!Validation.isCharNum(txtCompaperno.Text.Trim()))
                    context.AddError("单位证件号码必须为英数", txtCompaperno);
            }
        }
        return !(context.hasError());
    }

    protected void gvComResult_Page(object sender, GridViewPageEventArgs e)
    {
        gvComResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    protected void gvComResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvComResult','Select$" + e.Row.RowIndex + "')");

        }
    }
    protected void gvComResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header
           || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[0].Visible = false;
            e.Row.Cells[1].Visible = false;
        }
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string papertype = e.Row.Cells[6].Text.Trim();
            string papertypename = "";
            switch (papertype)
            {
                case "00":
                    papertypename = "00:身份证";
                    break;
                case "01":
                    papertypename = "01:学生证";
                    break;
                case "02":
                    papertypename = "02:军官证";
                    break;
                case "03":
                    papertypename = "03:驾驶证";
                    break;
                case "04":
                    papertypename = "04:教师证";
                    break;
                case "05":
                    papertypename = "05:护照";
                    break;
                case "06":
                    papertypename = "06:港澳台通行证";
                    break;
                case "07":
                    papertypename = "07:户口簿";
                    break;
                case "08":
                    papertypename = "08:武警证";
                    break;
                case "09":
                    papertypename = "09:台胞证";
                    break;
                case "99":
                    papertypename = "99:其他";
                    break;
                default:
                    break;
            }
            e.Row.Cells[6].Text = papertypename;
            string compapertype = e.Row.Cells[3].Text.Trim();
            string compapertypename = "";
            switch (compapertype)
            {
                case "01":
                    compapertypename = "01:组织机构代码证";
                    break;
                case "02":
                    compapertypename = "02:企业营业执照";
                    break;
                case "03":
                    compapertypename = "03:税务登记证";
                    break;
                default:
                    break;
            }
            e.Row.Cells[3].Text = compapertypename;
        }
    }

   
   
    protected void gvPerResult_Page(object sender, GridViewPageEventArgs e)
    {
        gvPerResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    protected void gvPerResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvPerResult','Select$" + e.Row.RowIndex + "')");

        }
    }
    protected void gvPerResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header
            || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[0].Visible = false;
        }
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string papertype = e.Row.Cells[2].Text.Trim();
            string papertypename = "";
            switch (papertype)
            {
                case "00":
                    papertypename = "00:身份证";
                    break;
                case "01":
                    papertypename = "01:学生证";
                    break;
                case "02":
                    papertypename = "02:军官证";
                    break;
                case "03":
                    papertypename = "03:驾驶证";
                    break;
                case "04":
                    papertypename = "04:教师证";
                    break;
                case "05":
                    papertypename = "05:护照";
                    break;
                case "06":
                    papertypename = "06:港澳台通行证";
                    break;
                case "07":
                    papertypename = "07:户口簿";
                    break;
                case "08":
                    papertypename = "08:武警证";
                    break;
                case "09":
                    papertypename = "09:台胞证";
                    break;
                case "99":
                    papertypename = "99:其他";
                    break;
                default:
                    break;
            }
            e.Row.Cells[2].Text = papertypename;
            string sex = e.Row.Cells[4].Text.Trim();
            string sexname = "";
            switch (sex)
            {
                case "0":
                    sexname = "0:男";
                    break;
                case "1":
                    sexname = "1:女";
                    break;
                default:
                    break;
            }
            e.Row.Cells[4].Text = sexname;
        }
    }
    protected void gvComResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        hidCompanyNo.Value = gvComResult.SelectedRow.Cells[1].Text;
        selComPapertype.Enabled = true;
        txtComPaperNo2.Enabled = true;
        HiddenField num = gvComResult.SelectedRow.Cells[0].FindControl("num") as HiddenField;
        int index = 0;
        if (gvComResult.PageIndex > 0)
        {
            index = int.Parse(num.Value) - 20 * gvComResult.PageIndex;
        }
        else
        {
            index = int.Parse(num.Value);
        }
        txtCompany.Text = getDataKeys1("COMPANYNAME", index);
        selComPapertype.SelectedValue = getDataKeys1("COMPANYPAPERTYPE", index);
        txtComPaperNo2.Text = getDataKeys1("COMPANYPAPERNO", index);
        txtEndDate.Text = getDataKeys1("COMPANYENDTIME",index);
        txtHoldNo.Text = getDataKeys1("COMPANYMANAGERNO", index);
        txtCusname.Text = getDataKeys1("NAME", index);
        selPapertype.SelectedValue = getDataKeys1("PAPERTYPE", index);
        txtCustpaperno.Text = getDataKeys1("PAPERNO", index);
        txtAccEndDate.Text = getDataKeys1("PAPERENDDATE", index);
        txtCustphone.Text = getDataKeys1("PHONENO", index);
        txtEmail.Text = getDataKeys1("EMAIL", index);
        txtCustaddr.Text = getDataKeys1("ADDRESS", index);
        selCallingExt.SelectedValue = getDataKeys1("appcalling", index)==""?"":getDataKeys1("appcalling", index).Substring(0,1);
        txtCompanyMoney.Text = getDataKeys1("registeredcapital", index);
        txtCompanySecurityValue.Text = getDataKeys1("securityvalue", index);
        hidCompanySecurityValue.Value = getDataKeys1("securityvalue", index);
        btnRegModify.Enabled = true;
        selCompany.Items.Clear();
        selCompany.Items.Add(new ListItem(txtCompany.Text));
        if (!string.IsNullOrEmpty(txtEndDate.Text))
        {
            if (DateTime.ParseExact(txtEndDate.Text.ToString(), "yyyyMMdd", null) < DateTime.Now.AddDays(60))
            {
                context.AddMessage("证件有效期不足60天，请尽快更换单位证件信息");
            }
        }
        string queryCustInfo = "";
        queryCustInfo = @"Select nvl2(a.COMPANYPAPERMSG,'1','0') COMPANYPAPERMSG From TD_M_BUYCARDCOMINFO a
                              Where a.COMPANYNO= '" + hidCompanyNo.Value + "'";

        context.DBOpen("Select");
        DataTable queryCustInfodata = context.ExecuteReader(queryCustInfo);   //查找公司上传证件信息
        if (queryCustInfodata.Rows.Count > 0)
        {
            if (queryCustInfodata.DefaultView[0]["COMPANYPAPERMSG"].ToString() == "1")
            {
                DateTime d = new DateTime();
                preview.Src = "GC_GetPicture.aspx?CompanyNo=" + hidCompanyNo.Value + "&d=" + d.ToString();
                tdShowPicture.Visible = true;
                tdMsg.Visible = false;
                tdFileUpload.Attributes.Add("colspan", "2");
            }
            else
            {
                tdShowPicture.Visible = false;
                tdMsg.Visible = true;
                tdFileUpload.Attributes.Add("colspan","2");
            }
        }
    }
    protected void gvPerResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        hidPAPERTYPE.Value = gvPerResult.SelectedRow.Cells[2].Text.Substring(0,2);
        hidPAPERNO.Value = gvPerResult.SelectedRow.Cells[3].Text;
        selPerPaperType.Enabled = true;
        txtPerPaperNo.Enabled = true;
        HiddenField num = gvPerResult.SelectedRow.Cells[0].FindControl("num") as HiddenField;
        int index = 0;
        if (gvPerResult.PageIndex > 0)
        {
            index = int.Parse(num.Value) - 20 * gvPerResult.PageIndex;
        }
        else
        {
            index = int.Parse(num.Value);
        }
        txtName.Text = getDataKeys2("NAME", index);
        selCustsex.Text = getDataKeys2("SEX", index);
        txtNationality.Text = getDataKeys2("NATIONALITY", index);
        txtJob.Text = getDataKeys2("JOB", index);
        selPerPaperType.Text = getDataKeys2("PAPERTYPE", index);
        txtPerPaperNo.Text = getDataKeys2("PAPERNO", index);
        txtPerEndDate.Text = getDataKeys2("PAPERENDDATE", index);
        txtPerBirth.Text = getDataKeys2("BIRTHDAY", index);
        txtPhoneNo.Text = getDataKeys2("PHONENO", index);
        txtPerAddress.Text = getDataKeys2("ADDRESS", index);
        txtPerEmail.Text = getDataKeys2("EMAIL", index);
        txtPersonalMoney.Text = getDataKeys2("registeredcapital", index);
        txtPersonalSecurityValue.Text = getDataKeys2("securityvalue", index);
        hidPersonalSecurityValue.Value = getDataKeys2("securityvalue", index);
        selPerCalling.SelectedValue = getDataKeys2("appcalling", index) == "" ? "" : getDataKeys2("appcalling", index).Substring(0, 1);
        Button3.Enabled = true;
    }
    public String getDataKeys1(String keysname, int selectindex)
    {
        return gvComResult.DataKeys[selectindex][keysname].ToString();
    }
    public String getDataKeys2(String keysname, int selectindex)
    {
        return gvPerResult.DataKeys[selectindex][keysname].ToString();
    }
    /// <summary>
    /// 新增
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnBuyCardReg_Click(object sender, EventArgs e)
    {
        if (hidCardType.Value.Equals("combuycard")) //新增购卡单位信息
        {
            if (!checkComInfoValidation())
                return;
            context.SPOpen();
            context.AddField("P_FUNCCODE").Value = "ADD";
            context.AddField("P_COMPANYNO").Value = "";
            context.AddField("P_COMPANYNAME").Value = txtCompany.Text.Trim();
            context.AddField("P_COMPANYPAPERTYPE").Value = selComPapertype.SelectedValue;
            context.AddField("P_COMPANYPAPERNO").Value = txtComPaperNo2.Text.Trim();
            context.AddField("P_COMPANYMANAGERNO").Value = txtHoldNo.Text.Trim();
            context.AddField("P_COMPANYENDTIME").Value = txtEndDate.Text.Trim();
            context.AddField("P_NAME").Value = txtCusname.Text.Trim();
            context.AddField("P_PAPERTYPE").Value = selPapertype.SelectedValue;
            context.AddField("P_PAPERNO").Value = txtCustpaperno.Text.Trim();
            context.AddField("P_PAPERENDDATE").Value = txtAccEndDate.Text.Trim();
            context.AddField("P_PHONENO").Value = txtCustphone.Text.Trim();
            context.AddField("P_ADDRESS").Value = txtCustaddr.Text.Trim();
            context.AddField("P_EMAIL").Value = txtEmail.Text.Trim();

            context.AddField("P_CALLINGNO").Value = selCallingExt.SelectedValue;//行业编码 add by youyue
            context.AddField("P_REGISTEREDCAPITAL").Value = txtCompanyMoney.Text.Trim() == "" ? "" : (Convert.ToDecimal(txtCompanyMoney.Text.Trim()) * 100).ToString();//注册资金规模
            //context.AddField("P_SECURITYVALUE").Value = txtCompanySecurityValue.Text.Trim() == "" ? "" : (Convert.ToDecimal(txtCompanySecurityValue.Text.Trim()) * 100).ToString();//安全值
            context.AddField("P_OUTCOMPANYNO", "String", "output", "6", null);
            bool ok = context.ExecuteSP("SP_GC_ComBuyCardInfo");
            if (ok)
            {
                string outCompanyno = context.GetFieldValue("P_OUTCOMPANYNO").ToString();
                if (FileUpload2.FileName != "")     //上传文件不为空
                {
                    UpdateCompanyMsg(outCompanyno, GetPicture(FileUpload2));
                }
                context.AddMessage("购卡单位资料新增成功");
                
                if (txtCompanySecurityValue.Text.Trim() != "")//如果填写了安全值
                {
                    if( hidCompanySecurityValue.Value=="")
                    {
                        context.SPOpen();
                        context.AddField("P_FUNCCODE").Value = "ADD";
                        context.AddField("P_COMPANYNO").Value = outCompanyno;
                        context.AddField("P_COMPANYPAPERTYPE").Value = selComPapertype.SelectedValue;
                        context.AddField("P_COMPANYPAPERNO").Value = txtComPaperNo2.Text.Trim();
                        context.AddField("P_CALLINGNO").Value = selCallingExt.SelectedValue;//行业编码 add by youyue
                        context.AddField("P_REGISTEREDCAPITAL").Value = txtCompanyMoney.Text.Trim() == "" ? "" : (Convert.ToDecimal(txtCompanyMoney.Text.Trim()) * 100).ToString();//注册资金规模
                        context.AddField("P_SECURITYVALUE").Value = (Convert.ToDecimal(txtCompanySecurityValue.Text.Trim()) * 100).ToString();
                        bool ok2 = context.ExecuteSP("SP_GC_COMBUYCARDAPPROVAL");// 提交至安全值审核
                        if (ok2)
                        {
                            context.AddMessage("购卡单位安全值提交至审核界面成功");
                        }
                    }
                }
                btnQuery_Click(sender, e);
            }
            
        }
        else    //个人购卡新增
        {
            if (!checkPerInfoValidation())
                return;
            context.SPOpen();
            context.AddField("P_FUNCCODE").Value = "ADD";
            context.AddField("P_NAME").Value = txtName.Text.Trim();
            context.AddField("P_BIRTHDAY").Value = txtPerBirth.Text.Trim();
            context.AddField("P_PAPERTYPE").Value = selPerPaperType.SelectedValue;
            context.AddField("P_PAPERNO").Value = txtPerPaperNo.Text.Trim();
            context.AddField("P_PAPERENDDATE").Value = txtPerEndDate.Text.Trim();
            context.AddField("P_SEX").Value = selCustsex.SelectedValue;
            context.AddField("P_NATIONALITY").Value = txtNationality.Text.Trim();
            context.AddField("P_JOB").Value = txtJob.Text.Trim();
            context.AddField("P_PHONENO").Value = txtPhoneNo.Text.Trim();
            context.AddField("P_ADDRESS").Value = txtPerAddress.Text.Trim();
            context.AddField("P_EMAIL").Value = txtPerEmail.Text.Trim();

            context.AddField("P_CALLINGNO").Value = selPerCalling.SelectedValue;//应用行业编码 add by youyue
            context.AddField("P_REGISTEREDCAPITAL").Value = txtPersonalMoney.Text.Trim() == "" ? "" : (Convert.ToDecimal(txtPersonalMoney.Text.Trim()) * 100).ToString();//注册资金规模
            //context.AddField("P_SECURITYVALUE").Value = txtPersonalSecurityValue.Text.Trim() == "" ? "" : (Convert.ToDecimal(txtPersonalSecurityValue.Text.Trim()) * 100).ToString();//安全值
            bool ok = context.ExecuteSP("SP_GC_PerBuyCardInfo");
            if (ok)
            {
                context.AddMessage("购卡个人资料新增成功");

                if (txtPersonalSecurityValue.Text.Trim() != "")//如果填写了安全值
                {
                    if (hidPersonalSecurityValue.Value == "")
                    {
                        context.SPOpen();
                        context.AddField("P_FUNCCODE").Value = "ADD";
                        context.AddField("P_PAPERTYPE").Value = selPerPaperType.SelectedValue;
                        context.AddField("P_PAPERNO").Value = txtPerPaperNo.Text.Trim();
                        context.AddField("P_CALLINGNO").Value = selPerCalling.SelectedValue;//应用行业编码 add by youyue
                        context.AddField("P_REGISTEREDCAPITAL").Value = txtPersonalMoney.Text.Trim() == "" ? "" : (Convert.ToDecimal(txtPersonalMoney.Text.Trim()) * 100).ToString();//注册资金规模
                        context.AddField("P_SECURITYVALUE").Value = (Convert.ToDecimal(txtPersonalSecurityValue.Text.Trim()) * 100).ToString();
                        bool ok2 = context.ExecuteSP("SP_GC_PERBUYCARDAPPROVAL");// 提交至安全值审核
                        if (ok2)
                        {
                            context.AddMessage("购卡个人安全值提交至审核界面成功");
                        }
                    }
                }

                btnQuery_Click(sender, e);
                ClearPerInput();
            }
        }
    }
    /// <summary>
    /// 修改
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnRegModify_Click(object sender, EventArgs e)
    {
        if (hidCardType.Value.Equals("combuycard")) //修改购卡单位信息
        {
            
            if (!checkComInfoValidation())
                return;
            context.SPOpen();
            context.AddField("P_FUNCCODE").Value = "MODIFY";
            context.AddField("P_COMPANYNO").Value = hidCompanyNo.Value;
            context.AddField("P_COMPANYNAME").Value = txtCompany.Text.Trim();
            context.AddField("P_COMPANYPAPERTYPE").Value = selComPapertype.SelectedValue;
            context.AddField("P_COMPANYPAPERNO").Value = txtComPaperNo2.Text.Trim();
            context.AddField("P_COMPANYMANAGERNO").Value = txtHoldNo.Text.Trim();
            context.AddField("P_COMPANYENDTIME").Value = txtEndDate.Text.Trim();
            context.AddField("P_NAME").Value = txtCusname.Text.Trim();
            context.AddField("P_PAPERTYPE").Value = selPapertype.SelectedValue;
            context.AddField("P_PAPERNO").Value = txtCustpaperno.Text.Trim();
            context.AddField("P_PAPERENDDATE").Value = txtAccEndDate.Text.Trim();
            context.AddField("P_PHONENO").Value = txtCustphone.Text.Trim();
            context.AddField("P_ADDRESS").Value = txtCustaddr.Text.Trim();
            context.AddField("P_EMAIL").Value = txtEmail.Text.Trim();

            context.AddField("P_CALLINGNO").Value = selCallingExt.SelectedValue;//行业编码 add by youyue
            context.AddField("P_REGISTEREDCAPITAL").Value = txtCompanyMoney.Text.Trim() == "" ? "" : (Convert.ToDecimal(txtCompanyMoney.Text.Trim()) * 100).ToString();//注册资金规模
            //context.AddField("P_SECURITYVALUE").Value = txtCompanySecurityValue.Text.Trim() == "" ? "" : (Convert.ToDecimal(txtCompanySecurityValue.Text.Trim()) * 100).ToString(); //安全值
            context.AddField("P_OUTCOMPANYNO", "String", "output", "6", null);
            bool ok = context.ExecuteSP("SP_GC_ComBuyCardInfo");
            if (ok)
            {
                string outCompanyno = context.GetFieldValue("P_OUTCOMPANYNO").ToString();
                if (FileUpload2.FileName != "")     //上传文件不为空
                {
                    UpdateCompanyMsg(outCompanyno, GetPicture(FileUpload2));
                }
                context.AddMessage("购卡单位资料修改成功");
               
                if (txtCompanySecurityValue.Text.Trim() != "" &&txtCompanySecurityValue.Text.Trim() !=hidCompanySecurityValue.Value )//如果修改了安全值
                {
                    context.SPOpen();
                    context.AddField("P_FUNCCODE").Value = "MODIFY";
                    context.AddField("P_COMPANYNO").Value = outCompanyno;
                    context.AddField("P_COMPANYPAPERTYPE").Value = selComPapertype.SelectedValue;
                    context.AddField("P_COMPANYPAPERNO").Value = txtComPaperNo2.Text.Trim();
                    context.AddField("P_CALLINGNO").Value = selCallingExt.SelectedValue;//行业编码 add by youyue
                    context.AddField("P_REGISTEREDCAPITAL").Value = txtCompanyMoney.Text.Trim() == "" ? "" : (Convert.ToDecimal(txtCompanyMoney.Text.Trim()) * 100).ToString();//注册资金规模
                    context.AddField("P_SECURITYVALUE").Value = (Convert.ToDecimal(txtCompanySecurityValue.Text.Trim()) * 100).ToString();
                    bool ok2 = context.ExecuteSP("SP_GC_COMBUYCARDAPPROVAL");// 提交至安全值审核
                    if (ok2)
                    {
                        context.AddMessage("购卡单位安全值已经提交至审核界面");
                    }
                }
                btnQuery_Click(sender, e);
            }
            
        }
        else
        {
            //selPerPaperType.Enabled = false;
            //txtPerPaperNo.Enabled = false;

            if (!checkPerInfoValidation())
                return;
            context.SPOpen();
            context.AddField("P_FUNCCODE").Value = "MODIFY";
            context.AddField("P_NAME").Value = txtName.Text.Trim();
            context.AddField("P_BIRTHDAY").Value = txtPerBirth.Text.Trim();
            context.AddField("P_PAPERTYPE").Value = selPerPaperType.SelectedValue;
            context.AddField("P_PAPERNO").Value = txtPerPaperNo.Text.Trim();
            context.AddField("P_PAPERENDDATE").Value = txtPerEndDate.Text.Trim();
            context.AddField("P_SEX").Value = selCustsex.SelectedValue;
            context.AddField("P_NATIONALITY").Value = txtNationality.Text.Trim();
            context.AddField("P_JOB").Value = txtJob.Text.Trim();
            context.AddField("P_PHONENO").Value = txtPhoneNo.Text.Trim();
            context.AddField("P_ADDRESS").Value = txtPerAddress.Text.Trim();
            context.AddField("P_EMAIL").Value = txtPerEmail.Text.Trim();

            context.AddField("P_CALLINGNO").Value = selPerCalling.SelectedValue;//应用行业编码 add by youyue
            context.AddField("P_REGISTEREDCAPITAL").Value = txtPersonalMoney.Text.Trim() == "" ? "" : (Convert.ToDecimal(txtPersonalMoney.Text.Trim()) * 100).ToString();//注册资金规模
            //context.AddField("P_SECURITYVALUE").Value = txtPersonalSecurityValue.Text.Trim() == "" ? "" : (Convert.ToDecimal(txtPersonalSecurityValue.Text.Trim()) * 100).ToString();//安全值
            bool ok = context.ExecuteSP("SP_GC_PerBuyCardInfo");
            if (ok)
            {
                context.AddMessage("购卡个人资料修改成功");

                if (txtPersonalSecurityValue.Text.Trim() != "" && txtPersonalSecurityValue.Text.Trim() != hidPersonalSecurityValue.Value)//如果填写了安全值
                {
                    context.SPOpen();
                    context.AddField("P_FUNCCODE").Value = "MODIFY";
                    context.AddField("P_PAPERTYPE").Value = selPerPaperType.SelectedValue;
                    context.AddField("P_PAPERNO").Value = txtPerPaperNo.Text.Trim();
                    context.AddField("P_CALLINGNO").Value = selPerCalling.SelectedValue;//应用行业编码 add by youyue
                    context.AddField("P_REGISTEREDCAPITAL").Value = txtPersonalMoney.Text.Trim() == "" ? "" : (Convert.ToDecimal(txtPersonalMoney.Text.Trim()) * 100).ToString();//注册资金规模
                    context.AddField("P_SECURITYVALUE").Value = (Convert.ToDecimal(txtPersonalSecurityValue.Text.Trim()) * 100).ToString();
                    bool ok2 = context.ExecuteSP("SP_GC_PERBUYCARDAPPROVAL");// 提交至安全值审核
                    if (ok2)
                    {
                        context.AddMessage("购卡个人安全值提交至审核界面成功");
                    }
                   
                }
                btnQuery_Click(sender, e);
            }
        }
    }
    private Boolean checkPerInfoValidation()
    {
        //对姓名进行非空、长度检验

        if (txtName.Text.Trim() == "")
            context.AddError("姓名不能为空", txtName);
        else if (Validation.strLen(txtName.Text.Trim()) > 50)
            context.AddError("姓名字符长度不能大于50", txtName);
        //对出生日期进行非空、日期格式校验

        if (txtPerBirth.Text.Trim() != "")
            if (!Validation.isDate(txtPerBirth.Text.Trim(), "yyyyMMdd"))
                context.AddError("出生日期格式必须为yyyyMMdd", txtPerBirth);
        //对证件类型进行非空检验

        if (selPerPaperType.SelectedValue == "")
            context.AddError("证件类型不能为空", selPerPaperType);

        //对证件号码进行非空、长度、英数字检验
        if (txtPerPaperNo.Text.Trim() == "")
            context.AddError("证件号码不能为空", txtPerPaperNo);
        else if (!Validation.isCharNum(txtPerPaperNo.Text.Trim()))
            context.AddError("证件号码必须为英数", txtPerPaperNo);
        else if (Validation.strLen(txtPerPaperNo.Text.Trim()) > 20)
            context.AddError("证件号码长度不能超过20位", txtPerPaperNo);
        else if (selPerPaperType.SelectedValue == "00" && !Validation.isPaperNo(txtPerPaperNo.Text.Trim()))
            context.AddError("证件号码验证不通过", txtPerPaperNo);
       

        //证件有效期检验
        if (txtPerEndDate.Text.Trim()!="")
          if (!Validation.isDate(txtPerEndDate.Text.Trim(), "yyyyMMdd"))
               context.AddError("证件有效期格式必须为yyyyMMdd", txtPerEndDate);

        //对联系电话进行长度检验
        if (txtPhoneNo.Text.Trim() != "")
            if (Validation.strLen(txtPhoneNo.Text.Trim()) > 20)
                context.AddError("联系电话超过20位", txtPhoneNo);

        //对国籍进行长度检验
        if (txtNationality.Text.Trim() != "")
            if (Validation.strLen(txtNationality.Text.Trim()) > 40)
                context.AddError("国籍超过40位", txtNationality);

        //对职业进行长度检验
        if (txtJob.Text.Trim() != "")
            if (Validation.strLen(txtJob.Text.Trim()) > 40)
                context.AddError("职业超过40位", txtJob);

        //对联系电话进行长度检验
        if (txtPhoneNo.Text.Trim() != "")
            if (Validation.strLen(txtPhoneNo.Text.Trim()) > 20)
                context.AddError("联系电话超过20位", txtPhoneNo);
           

        //对联系地址进行长度检验
        if (txtPerAddress.Text.Trim() != "")
            if (Validation.strLen(txtPerAddress.Text.Trim()) > 200)
                context.AddError("联系地址长度不能超过200位", txtPerAddress);


        //对电子邮件进行格式检验
        if (txtPerEmail.Text.Trim() != "")
            new Validation(context).isEMail(txtPerEmail);

        //对注册资金进行验证
        if (txtPersonalMoney.Text.Trim() != "")
        {
            if (!Validation.isNum(txtPersonalMoney.Text))
            {
                context.AddError("注册资金输入不正确", txtPersonalMoney);
            }
            else if (Convert.ToDecimal(txtPersonalMoney.Text.Trim()) <= 0)
            {
                context.AddError("注册资金必须是正数", txtPersonalMoney);
            }
        }
        //对安全值进行验证
        if (txtPersonalSecurityValue.Text.Trim() != "")
        {
            if (!Validation.isNum(txtPersonalSecurityValue.Text))
            {
                context.AddError("安全值输入不正确", txtPersonalSecurityValue);
            }
            else if (Convert.ToDecimal(txtPersonalSecurityValue.Text.Trim()) <= 0)
            {
                context.AddError("安全值必须是正数,且不可为0", txtPersonalSecurityValue);
            }
            
        }
        //对应用行业进行验证
        if (selPerCalling.SelectedValue == "")
        {
            context.AddError("请选择应用行业名称", selPerCalling);
        }
        return !(context.hasError());

    }

    //录入输入校验
    private Boolean checkComInfoValidation()
    {
        //对单位名称进行长度校验
        if (txtCompany.Text.Trim() == "")
            context.AddError("单位名称不能为空", txtCompany);
        else if (Validation.strLen(txtCompany.Text.Trim()) > 200)
            context.AddError("单位名称字符长度不能超过200位", txtCompany);

        //对单位证件类型进行非空检验
        if (selComPapertype.SelectedValue == "")
            context.AddError("单位证件类型不能为空", selComPapertype);

        //对单位证件号码进行非空、长度、英数字检验
        if (txtComPaperNo2.Text.Trim() == "")
            context.AddError("单位证件号码不能为空", txtComPaperNo2);
        //else if (!Validation.isCharNum(txtComPaperno.Text.Trim()))
        //    context.AddError("单位证件号码必须为英数", txtComPaperno);
        else if (Validation.strLen(txtComPaperNo2.Text.Trim()) > 30)
            context.AddError("单位证件号码程度不能超过30位", txtComPaperNo2);


        //对证件有效期进行非空、日期格式校验
        String endDate = txtEndDate.Text.Trim();
        if (endDate == "")
            context.AddError("证件有效期不能为空", txtEndDate);
        else if (!Validation.isDate(txtEndDate.Text.Trim(), "yyyyMMdd"))
            context.AddError("证件有效期格式必须为yyyyMMdd", txtEndDate);

        //对经办人姓名进行非空、长度检验
        if (txtCusname.Text.Trim() == "")
            context.AddError("经办人姓名不能为空", txtCusname);
        else if (Validation.strLen(txtCusname.Text.Trim()) > 50)
            context.AddError("经办人姓名字符长度不能大于50", txtCusname);

        //对证件类型进行非空检验
        if (selPapertype.SelectedValue == "")
            context.AddError("经办人证件类型不能为空", selPapertype);

        //对证件号码进行非空、长度、英数字检验
        if (txtCustpaperno.Text.Trim() == "")
            context.AddError("经办人证件号码不能为空", txtCustpaperno);
        else if (!Validation.isCharNum(txtCustpaperno.Text.Trim()))
            context.AddError("经办人证件号码必须为英数", txtCustpaperno);
        else if (Validation.strLen(txtCustpaperno.Text.Trim()) > 20)
            context.AddError("经办人证件号码长度不能超过20位", txtCustpaperno);
        else if (selPapertype.SelectedValue=="00" && !Validation.isPaperNo(txtCustpaperno.Text.Trim()))
            context.AddError("经办人证件号码验证不通过", txtCustpaperno);
       

        //经办人证件有效期检验
        if (txtAccEndDate.Text.Trim() != "")
            if (!Validation.isDate(txtAccEndDate.Text.Trim(), "yyyyMMdd"))
                context.AddError("经办人证件有效期格式必须为yyyyMMdd", txtAccEndDate);

        //对联系电话进行长度检验
        if (txtCustphone.Text.Trim() != "")
            if (Validation.strLen(txtCustphone.Text.Trim()) > 20)
                context.AddError("联系电话超过20位", txtCustphone);

        //对联系地址进行长度检验
        if (txtCustaddr.Text.Trim() != "")
            if (Validation.strLen(txtCustaddr.Text.Trim()) > 200)
                context.AddError("转出银行字符长度不能超过200位", txtCustaddr);

        //对电子邮件进行格式检验
        if (txtEmail.Text.Trim() != "")
            new Validation(context).isEMail(txtEmail);
        //对注册资金进行验证
        if (txtCompanyMoney.Text.Trim() == "")
            context.AddError("注册资金不能为空", txtCompanyMoney);
        else
        {
            if (!Validation.isNum(txtCompanyMoney.Text))
            {
                context.AddError("注册资金输入不正确", txtCompanyMoney);
            }
            else if (Convert.ToDecimal(txtCompanyMoney.Text.Trim()) <= 0)
            {
                context.AddError("注册资金必须是正数", txtCompanyMoney);
            }
        }
        //对安全值进行验证
        if (txtCompanySecurityValue.Text.Trim() != "")
        {
            if (!Validation.isNum(txtCompanySecurityValue.Text))
            {
                context.AddError("安全值输入不正确", txtCompanySecurityValue);
            }
            else if (Convert.ToDecimal(txtCompanySecurityValue.Text.Trim()) <= 0)
            {
                context.AddError("安全值必须是正数,且不可为0", txtCompanySecurityValue);
            }
        }
        //对应用行业进行验证
        if(selCallingExt.SelectedValue=="")
        {
            context.AddError("请选择应用行业名称", selCallingExt);
        }
        //对上传文件的检验
        if (!string.IsNullOrEmpty(FileUpload2.FileName))
        {
            int len = FileUpload2.FileBytes.Length;
            if (len > 1024 * 1024 * 5)
            {
                context.AddError("上传文件不可大于5M", FileUpload2);
            }
            string[] strPics = { ".jpg", ".bmp", ".gif", ".jpeg", ".png" };
            int index = Array.IndexOf(strPics, Path.GetExtension(FileUpload2.FileName).ToLower());
            if (index == -1)
            {
                context.AddError("上传文件格式必须为图片格式jpg|bmp|jpeg|png|gif", FileUpload2);
            }
        }
        return !(context.hasError());

    }

    /// <summary>
    /// 获取图片二进制流文件
    /// </summary>
    /// <param name="FileUpload1">upload控件</param>
    /// <returns>二进制流</returns>
    private byte[] GetPicture(FileUpload FileUpload1)
    {
        int len = FileUpload2.FileBytes.Length;
        if (len > 1024 * 1024 * 5)
        {
            context.AddError("A094780014：上传文件大于5M");
            return null;
        }

        System.IO.Stream fileDataStream = FileUpload2.PostedFile.InputStream;

        int fileLength = FileUpload2.PostedFile.ContentLength;

        byte[] fileData = new byte[fileLength];

        fileDataStream.Read(fileData, 0, fileLength);
        fileDataStream.Close();

        return fileData;
    }

    /// <summary>
    /// 更新单位证件信息
    /// </summary>
    /// <param name="p_companyno">单位编码</param>
    /// <param name="buff">图片二进制流文件</param>
    private void UpdateCompanyMsg(string p_companyno, byte[] buff)
    {
        context.DBOpen("BatchDML");
        context.AddField(":companyno", "String").Value = p_companyno;
        context.AddField(":BLOB", "BLOB").Value = buff;
        string sql = "UPDATE TD_M_BUYCARDCOMINFO SET COMPANYPAPERMSG = :BLOB WHERE COMPANYNO = :companyno";
        context.ExecuteNonQuery(sql);
        context.DBCommit();
    }
    /// <summary>
    /// 清空单位信息
    /// </summary>
    private void ClearComInut()
    {
        txtCompany.Text = string.Empty;
        selComPapertype.SelectedValue = "";
        txtComPaperNo2.Text = string.Empty;
        txtEndDate.Text = string.Empty;
        txtHoldNo.Text = string.Empty;
        txtCusname.Text = string.Empty;
        selPapertype.SelectedValue = "";
        txtCustpaperno.Text = string.Empty;
        txtAccEndDate.Text = string.Empty;
        txtCustphone.Text = string.Empty;
        txtCustaddr.Text = string.Empty;
        txtEmail.Text = string.Empty;
        selCallingExt.SelectedValue = "";
        txtCompanyMoney.Text = string.Empty;
        txtCompanySecurityValue.Text = string.Empty;


    }
    private void ClearPerInput()
    {
        txtName.Text = string.Empty;
        selCustsex.SelectedValue = "";
        txtNationality.Text = string.Empty;
        txtJob.Text = string.Empty;
        selPerPaperType.SelectedValue = "";
        txtPerPaperNo.Text = string.Empty;
        txtPerEndDate.Text = string.Empty;
        txtPerBirth.Text = string.Empty;
        txtPhoneNo.Text = string.Empty;
        txtPerAddress.Text = string.Empty;
        txtPerEmail.Text = string.Empty;
        txtPersonalMoney.Text = string.Empty;
        txtPersonalSecurityValue.Text = string.Empty;
    }
}