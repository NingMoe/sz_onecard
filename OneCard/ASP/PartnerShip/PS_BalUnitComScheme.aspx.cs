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
using TDO.PartnerShip;
using TDO.BalanceChannel;
using PDO.PartnerShip;
using Common;


public partial class ASP_PartnerShip_PS_BalUnitComScheme : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        TMTableModule tmTMTableModule = new TMTableModule();
        //从行业编码表(TD_M_CALLINGNO)中读取数据，放入查询输入行业名称下拉列表中

        TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
        TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tmTMTableModule.selByPKArr(context, 
            tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), null, "TD_M_CALLINGNO_NO_TAXI_BUS", null);

        ControlDeal.SelectBoxFillWithCode(selCalling.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);

        //设置结算单元佣金规则对应关系列表表头
        UserCardHelper.resetData(lvwBalComSQuery, null);

        InitBalAndScheme();

        //指定GridView DataKeyNames
        lvwBalComSQuery.DataKeyNames =
            new string[] { "ID", "BALUNITNO", "BALUNIT", "CALLINGNO", "NAME", "COMSCHEMENO", "CALLINGNAME", 
                "CORPNAME", "DEPARTNAME", "BEGINTIME", "ENDTIME" };
    
        // 生成到期下拉列表
        selExpiration.Items.Add(new ListItem("---请选择---", ""));
        selExpiration.Items.Add(new ListItem("1:一个月后过期", "1"));
        selExpiration.Items.Add(new ListItem("2:两个月后过期", "2"));
        selExpiration.Items.Add(new ListItem("3:三个月后过期", "3"));
        selExpiration.Items.Add(new ListItem("4:四个月后过期", "4"));
        selExpiration.Items.Add(new ListItem("5:五个月后过期", "5"));
        selExpiration.Items.Add(new ListItem("6:六个月后过期", "6"));
    }


    public void lvwBalComSQuery_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwBalComSQuery.PageIndex = e.NewPageIndex;
        lvwBalComSQuery.DataSource = CreateBalComSQueryDataSource();
        lvwBalComSQuery.DataBind();

        selBalUnit.SelectedValue = "";
        ClearText();
    }


    private void InitBalAndScheme()
    {
        //从消费佣金方案编码表(TF_TRADE_COMSCHEME)中读取数据,放入佣金规则下拉列表中
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_TRADE_COMSCHEMETDO tdoTrComs = new TF_TRADE_COMSCHEMETDO();
        TF_TRADE_COMSCHEMETDO[] tdoTrComsArr = (TF_TRADE_COMSCHEMETDO[])tmTMTableModule.selByPKArr(context,
            tdoTrComs, typeof(TF_TRADE_COMSCHEMETDO), null, "TF_TRADE_COMSCHEMEUSAGE", null);
        ControlDeal.SelectBoxFillWithCode(selComScheme.Items, tdoTrComsArr, "NAME", "COMSCHEMENO", true);


        //从结算单元编码表(TF_TRADE_BALUNIT)中读取数据,放入结算单元下拉列表中
        TF_TRADE_BALUNITTDO tdoTF_TRADE_BALUNITIn = new TF_TRADE_BALUNITTDO();
        TF_TRADE_BALUNITTDO[] tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context,
            tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNIT_NO_TAXI_BUS", null);

        ControlDeal.SelectBoxFillWithCode(selBalUnit.Items, tdoTF_TRADE_BALUNITOutArr, "BALUNIT", "BALUNITNO", true);

    }


    protected void selCalling_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选定行业后,设置单位下拉列表数据
        //查询选择行业后,设置单位名称下拉列表值
        selCorp.Items.Clear();
        selDepart.Items.Clear();

        if (selCalling.SelectedValue != "")
            InitCorp(selCalling, selCorp, "TD_M_CORPCALLUSAGE");

        
    }
    protected void selCorp_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选定单位后,设置部门下拉列表数据
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

            TD_M_DEPARTTDO[] tdoTD_M_DEPARTOutArr = (TD_M_DEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null, "TD_M_DEPARTUSAGE", null);
            ControlDeal.SelectBoxFillWithCode(selDepart.Items, tdoTD_M_DEPARTOutArr, "DEPART", "DEPARTNO", true);

        }
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



    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //查询结算单元对应佣金规则信息

        txtEndTime.Enabled = true;
        
        lvwBalComSQuery.DataSource = CreateBalComSQueryDataSource();
        lvwBalComSQuery.DataBind();
        lvwBalComSQuery.SelectedIndex = -1;

        ClearText();
        selBalUnit.SelectedValue = "";

    }


    public DataTable CreateBalComSQueryDataSource()
    {
        return SPHelper.callPSQuery(context, "QueryComScheme", selCalling.SelectedValue,
            selCorp.SelectedValue, selDepart.SelectedValue, selExpiration.SelectedValue,context.s_DepartID);
    }


    protected void lvwBalComSQuery_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwBalComSQuery','Select$"
                + e.Row.RowIndex + "')");
        }
    }

    public void lvwBalComSQuery_SelectedIndexChanged(object sender, EventArgs e)
    {

        //选择列表框一行记录后,设置结算单元佣金规则信息增加,修改,删除区域中数据

        //ListItem selItem = new ListItem(getDataKeys("BALUNIT"),getDataKeys("BALUNITNO"));
        //if (!selBalUnit.Items.Contains(selItem))
        //{
        //    selBalUnit.Items.Add(selItem);
        //}

        txtEndTime.Enabled = true;

        selBalUnit.SelectedValue = getDataKeys("BALUNITNO").Trim();

        labCalling.Text = getDataKeys("CALLINGNAME");

        hidCallingNo.Value = getDataKeys("CALLINGNO");

        labCorp.Text = getDataKeys("CORPNAME");
        labDepart.Text = getDataKeys("DEPARTNAME");

        try
        {
            txtBeginTime.Text = DateTime.Parse(getDataKeys("BEGINTIME")).ToString("yyyy-MM", null);
            txtEndTime.Text = DateTime.Parse(getDataKeys("ENDTIME")).ToString("yyyy-MM", null);
        }
        catch (Exception)
        {
            txtBeginTime.Text = "";
            txtEndTime.Text = "";
        }

        selComScheme.SelectedValue = getDataKeys("COMSCHEMENO");

    }

    public string getDataKeys(string keysname)
    {
        return lvwBalComSQuery.DataKeys[lvwBalComSQuery.SelectedIndex][keysname].ToString().Trim();
    }


    private Boolean BalComsDelValidation()
    {
        if (lvwBalComSQuery.SelectedIndex == -1)
        {
            context.AddError("A008104004");
            return false;
        }

        //选定的结算单元名称修改,不能执行删除操作
     
        if (selBalUnit.SelectedValue != getDataKeys("BALUNITNO").Trim())
        {
            context.AddError("A008104005", selBalUnit);
            return false;

        }

        //选定的结算单元对应的佣金规则名称修改后,不能执行删除操作

        if (selComScheme.SelectedValue != getDataKeys("COMSCHEMENO").Trim())
        {
            context.AddError("A008104040", selComScheme);
            return false;
        }

        //出租行业不能在此增删改佣金规则
        if (!chkCalling())
        {
            return false;
        }
        
        //不是选定的结算单元对应的起始和终止年月时,不能执行删除操作

        if (txtBeginTime.Text.Trim() != DateTime.Parse(getDataKeys("BEGINTIME")).ToString("yyyy-MM", null))
        {
             context.AddError("A008104041", txtBeginTime);
        }

        if (txtEndTime.Text.Trim() != DateTime.Parse(getDataKeys("ENDTIME")).ToString("yyyy-MM", null))
        {
            context.AddError("A008104042", txtEndTime);
        }

       

        if (context.hasError())
            return false;
        else
            return true;

    }


    private Boolean BalComsAddValidation()
    {

        //选中一个结算单元时
        if (lvwBalComSQuery.SelectedIndex != -1)
        {
            //当所有的信息都没有修改时不能增加该结算单元佣金规则
            if(
                selBalUnit.SelectedValue == getDataKeys("BALUNITNO") &&
                selComScheme.SelectedValue == getDataKeys("COMSCHEMENO") &&
                txtBeginTime.Text == DateTime.Parse(getDataKeys("BEGINTIME")).ToString("yyyy-MM", null) &&
                txtEndTime.Text == DateTime.Parse(getDataKeys("ENDTIME")).ToString("yyyy-MM", null) 
            )
            {
                context.AddError("A008104039");
                return false;
            }

        }


        //结算单元是否为空
        if (selBalUnit.SelectedValue == "")
        {
            context.AddError("A008104006", selBalUnit);
            return false;
        }

        //出租行业不能在此增删改佣金规则
        if (!chkCalling())
        {
            return false;
        }


        //佣金规则是否为空
        string strComScheme = selComScheme.SelectedValue;
        if (strComScheme == "")
        {
            context.AddError("A008104007", selComScheme);
        }

        //佣金起始终止日期有效性检查
        CheckComsDate();

        if (context.hasError())
            return false;
        else
            return true;

    }

    private Boolean BalComsModifyValidation()
    {
        //当没有选择结算单元时,不能执行修改处理
        if (lvwBalComSQuery.SelectedIndex == -1)
        {
            context.AddError("A008104004");
            return false;
        }

        //选定的结算单元名称修改后,不能执行修改操作
        if (selBalUnit.SelectedValue != getDataKeys("BALUNITNO").Trim())
        {
            context.AddError("A008104005", selBalUnit);
            return false;
        }

        //检查结算单元的行业是否为出租
        if (!chkCalling())
        {
            return false;
        }

        //选定的结算单元对应的佣金规则修改后,不能执行修改操作

        if (selComScheme.SelectedValue != getDataKeys("COMSCHEMENO"))
        {
            context.AddError("A008104001", selComScheme);
            return false;
        }

        //佣金起始日期有效性检查
        CheckComsDate();

        string strBeginTime = DateTime.Parse(getDataKeys("BEGINTIME")).ToString("yyyy-MM", null);
        string strEndTime = DateTime.Parse(getDataKeys("ENDTIME")).ToString("yyyy-MM", null);

        //修改佣金的起始和终止时间
        if (txtEndTime.Text.Trim() == strEndTime && txtBeginTime.Text.Trim() == strBeginTime)
        {
            context.AddError("A008104038");
        }

        if (context.hasError())
            return false;
        else
            return true;

    }


    private void CheckComsDate()
    {
        //佣金起始日期有效性检查
        string strBeginTime = txtBeginTime.Text.Trim();
        DateTime? beginTime = null;

        if (strBeginTime == "")
        {
            context.AddError("A008104008", txtBeginTime);
        }

        else if (!Validation.isDate(strBeginTime, "yyyy-MM"))
        {
            context.AddError("A008104035", txtBeginTime);
        }
        else
        {
            beginTime = DateTime.ParseExact(strBeginTime, "yyyy-MM", null);
        }

        //检查是否选择了无效期
        string strEndTime = txtEndTime.Text.Trim();

        if (!chkEndDate.Checked)
        {
            if (strEndTime == "")
            {
                context.AddError("A008104009", txtEndTime);
            }
            else if (!Validation.isDate(strEndTime, "yyyy-MM"))
            {
                context.AddError("A008104036", txtEndTime);
            }
            else if ( beginTime != null )
            {
                CompareComsDate(strBeginTime, strEndTime, txtEndTime);
            }
        }

        if (chkEndDate.Checked && beginTime != null)
        {
            CompareComsDate(strBeginTime, "2050-12", txtBeginTime);
        }
    }


    private void CompareComsDate(string datest,string dateend, TextBox txtBox)
    {
        DateTime begin = DateTime.ParseExact(datest, "yyyy-MM",null);
        DateTime end = DateTime.ParseExact(dateend, "yyyy-MM",null);

        if (DateTime.Compare(begin,end) >0 )
        {
            context.AddError("A008104037", txtBox);
        }
 
    }

  
    protected void btnAdd_Click(object sender, EventArgs e)
    {  
        //增加结算单元对应佣金规则信息
        if (!BalComsAddValidation()) return;

        //检测佣金方案终止时间是否小于当前时间
        if (CompareEndTimeAndNow()) return;


        //调用增加的存储过程
        SP_PS_BalUnitComSchemeAddPDO pdo = new SP_PS_BalUnitComSchemeAddPDO();

        pdo.balUnitNo = selBalUnit.SelectedValue.Trim();
        pdo.beginTime = txtBeginTime.Text.Trim() + "-01 00:00:00";

        pdo.endTime = GetEndTime();
        pdo.comSchemeNo = selComScheme.SelectedValue.Trim();

        //调用增加结算单元对应佣金规则信息的存储过程

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M008104112");

            //清除输入的信息
            ClearText();

            InitBalAndScheme();
            btnQuery_Click(sender, e);

        }
     
    }




    protected void btnDel_Click(object sender, EventArgs e)
    {
        //删除结算单元对应佣金规则信息
        if (!BalComsDelValidation()) return;
        
        //设置存储过程参数值
        SP_PS_BalUnitComSchemeDeletePDO pdo = new SP_PS_BalUnitComSchemeDeletePDO();
        pdo.balUnitNo = selBalUnit.SelectedValue;

        pdo.comSchemeNo = selComScheme.SelectedValue;
        pdo.beginTime = txtBeginTime.Text.Trim() + "-01 00:00:00";
        pdo.endTime = GetEndTime();

        pdo.balComsId = getDataKeys("ID");

        //调用删除结算单元对应佣金规则信息的存储过程

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M008104113");

            //清除输入的信息
            ClearText();

            InitBalAndScheme();
            btnQuery_Click(sender, e);

        }
    }

    protected void btnModify_Click(object sender, EventArgs e)
    {
        //修改结算单元对应佣金规则信息

        if (!BalComsModifyValidation()) return;

        //设置存储过程参数值
        SP_PS_BalUnitComSchemeModifyPDO pdo = new SP_PS_BalUnitComSchemeModifyPDO();
      
        pdo.balUnitNo = selBalUnit.SelectedValue;
        pdo.comSchemeNo = selComScheme.SelectedValue;
       
        pdo.balComsId = getDataKeys("ID");
        pdo.endTime = GetEndTime();
        pdo.beginTime = txtBeginTime.Text.Trim() + "-01 00:00:00";

        //调用删除结算单元对应佣金规则信息的存储过程

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M008104111");

            //清除输入的信息
            ClearText();

            InitBalAndScheme();
            btnQuery_Click(sender, e);
        }
    }
    private string GetEndTime()
    {
        string endtime = "";
        if (chkEndDate.Checked)
        {
            endtime = "2050-12-31 23:59:59";
        }
        else
        {
            DateTime end = DateTime.ParseExact(txtEndTime.Text.Trim(), "yyyy-MM", null);
            DateTime enddate = end.AddMonths(1).AddDays(-1);

            string mon = enddate.Month >= 10 ? enddate.Month.ToString() : "0" + enddate.Month;
            string day = enddate.Day >= 10 ? enddate.Day.ToString() : "0" + enddate.Day;

            endtime = enddate.Year + "-" + mon + "-" + day + " 23:59:59";
        }

        return endtime;
    }


    private Boolean CompareEndTimeAndNow()
    {
        //检查佣金方案的终止时间是否小于当期时间 
        string strEndTime = GetEndTime().Replace("-", "").Replace(":", "");

        DateTime end = DateTime.ParseExact(strEndTime, "yyyyMMdd HHmmss", null);
        DateTime nowd = DateTime.Now;

        if (DateTime.Compare(nowd, end) > 0)
        {
            context.AddError("A008107125", txtEndTime);
            return true;
        }
        return false;
    }



    protected void chkEndDate_CheckedChanged(object sender, EventArgs e)
    {
        if (chkEndDate.Checked)
        {
            txtEndTime.Enabled = false;
            txtEndTime.Text = "2050-12";
        }
        else
        {
            txtEndTime.Enabled = true;
            txtEndTime.Text = "";
        }

    }
    protected void selBalUnit_SelectedIndexChanged(object sender, EventArgs e)
    {

        //选择结算单元后,清除结算单元佣金规则信息
        ClearText();

        if (selBalUnit.SelectedValue == "") return;
       
        //显示结算单元对应的行业,单位,部门名称

        TMTableModule tmTMTableModule = new TMTableModule();
        TF_TRADE_BALUNITTDO tdoTF_TRADE_BALUNITIn = new TF_TRADE_BALUNITTDO();
        tdoTF_TRADE_BALUNITIn.BALUNITNO = selBalUnit.SelectedValue;

        TF_TRADE_BALUNITTDO tdoTF_TRADE_BALUNITOut = (TF_TRADE_BALUNITTDO)tmTMTableModule.selByPK(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_BYNO", null);

        if (tdoTF_TRADE_BALUNITOut.CALLINGNO != null && tdoTF_TRADE_BALUNITOut.CALLINGNO.Trim()!="")
        {
            //查询行业名称
            TD_M_CALLINGNOTDO ddoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
            ddoTD_M_CALLINGNOIn.CALLINGNO = tdoTF_TRADE_BALUNITOut.CALLINGNO;
            TD_M_CALLINGNOTDO ddoTD_M_CALLINGNOOut = (TD_M_CALLINGNOTDO)tmTMTableModule.selByPK(context, ddoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), null, "TD_M_CALLINGNO_BYNO", null);
            labCalling.Text = ddoTD_M_CALLINGNOOut.CALLING;
            hidCallingNo.Value = ddoTD_M_CALLINGNOOut.CALLINGNO;

        }

        if (tdoTF_TRADE_BALUNITOut.CORPNO != null && tdoTF_TRADE_BALUNITOut.CORPNO.Trim() != "")
        {
            //查询单位名称

            TD_M_CORPTDO ddoTD_M_CORPIn = new TD_M_CORPTDO();
            ddoTD_M_CORPIn.CORPNO = tdoTF_TRADE_BALUNITOut.CORPNO;
            TD_M_CORPTDO ddoTD_M_CORPOut = (TD_M_CORPTDO)tmTMTableModule.selByPK(context, ddoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, "TD_M_CORP_BYNO", null);
            labCorp.Text = ddoTD_M_CORPOut.CORP;
         
        }

        if (tdoTF_TRADE_BALUNITOut.DEPARTNO != null && tdoTF_TRADE_BALUNITOut.DEPARTNO.Trim() != "")
        {
            //查询部门名称

            TD_M_DEPARTTDO ddoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
            ddoTD_M_DEPARTIn.DEPARTNO = tdoTF_TRADE_BALUNITOut.DEPARTNO;
            TD_M_DEPARTTDO dataDddoTD_M_DEPARTOut = (TD_M_DEPARTTDO)tmTMTableModule.selByPK(context, ddoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null, "TD_M_DEPART_BYNO", null);
            labDepart.Text = dataDddoTD_M_DEPARTOut.DEPART;

        }

    }


    private void ClearText()
    {
        lvwBalComSQuery.SelectedIndex = -1;
        labCalling.Text = "";
        labCorp.Text = "";
        labDepart.Text = "";
        selComScheme.SelectedValue = "";
        txtBeginTime.Text = "";
        txtEndTime.Text = "";

        txtEndTime.Enabled = true;
        txtEndTime.Text = "";
      
        chkEndDate.Checked = false;

    }



    private Boolean chkCalling()
    {
        //结算单元类型是否为出租行业
        if (hidCallingNo.Value == "02")
        {
            context.AddError("A008104044");
            return false;

        }
        return true;
    }

}
