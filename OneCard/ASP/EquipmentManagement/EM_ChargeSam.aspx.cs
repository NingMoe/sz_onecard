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
using Master;
using TDO.ResourceManager;
using TDO.BalanceChannel;
using TM.EquipmentManagement;
using TM;

public partial class ASP_EquipmentManagement_EM_ChargeSam : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化有效标志
            TSHelper.initUseTag(selUseTag);

            //从行业编码表(TD_M_CALLINGNO)中读取数据
            TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
            TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tm.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), null);
            ControlDeal.SelectBoxFillWithCode(selCalling.Items, tdoTD_M_CALLINGNOOutArr,
                "CALLING", "CALLINGNO", true);

            #region 注释 modify by jiangbb 2014-06-08 邮件注释
            //selCalling.Items.Add(new ListItem("---请选择---", ""));
            //selCalling.Items.Add(new ListItem("0B:中石油", "0B"));
            //selCalling.Items.Add(new ListItem("0C:信息亭缴费", "0C"));
            //selCalling.Items.Add(new ListItem("0D:中国电信充值终端", "0D"));
            //selCalling.Items.Add(new ListItem("08:江苏银行充值", "08"));
            //selCalling.Items.Add(new ListItem("07:卡付易充值设备", "07"));
            //selCalling.Items.Add(new ListItem("16:张家港农商行自助设备", "16"));
            //selCalling.Items.Add(new ListItem("21:全民付", "21"));
            //selCorp.Items.Add(new ListItem("", ""));
            #endregion

            ChargeSamQuery();
        }
    }
    private void ChargeSamQuery()
    {
        TD_M_SAMTDO ddoTD_M_SAMTDO = new TD_M_SAMTDO();

        string strSql = "SELECT	s.SAMNO SAMNO,s.VERNO VERSION,s.CALLINGNO CALLINGNO,c.CALLING CALLING,s.USETAG USETAG, "
                    + "s.DEPARTNO CORPNO,d.CORP CORP,s.RSRV3 NOTE,s.UPDATESTAFFNO UPDATESTAFFNO,e.STAFFNAME UPDATESTAFF,s.UPDATETIME UPDATETIME "
                    + "from TD_M_SAM s left join TD_M_CALLINGNO c on upper(s.CALLINGNO)=c.CALLINGNO "
                    + "left join TD_M_INSIDESTAFF e on s.UPDATESTAFFNO=e.STAFFNO "
                    + "left join TD_M_CORP d on s.DEPARTNO = d.CORPNO ";

        DataTable data = tm.selByPKDataTable(context, ddoTD_M_SAMTDO, null, strSql, 0);
        DataView dataView = new DataView(data);

        lvwChargeSam.DataKeyNames = new string[] { "SAMNO", "VERSION", "CALLINGNO", "CALLING", "USETAG", "CORPNO", "CORP", "NOTE", "UPDATESTAFF", "UPDATETIME" };
        lvwChargeSam.DataSource = dataView;
        lvwChargeSam.DataBind();

    }

    //初始化部门
    protected void selCalling_Change(object sender, EventArgs e)
    {
        selCorp.Items.Clear();
        if (selCalling.SelectedValue != "")
        {
            TD_M_CORPTDO tdoTD_M_CORPTDOIn = new TD_M_CORPTDO();
            tdoTD_M_CORPTDOIn.CALLINGNO = selCalling.SelectedValue;
            TD_M_CORPTDO[] tdoTD_M_CORPTDOOutAttr = (TD_M_CORPTDO[])tm.selByPKArr(context, tdoTD_M_CORPTDOIn, typeof(TD_M_CORPTDO), null, "TD_M_CORP", null);
            ControlDeal.SelectBoxFillWithCode(selCorp.Items, tdoTD_M_CORPTDOOutAttr,
               "CORP", "CORPNO", true);
        }
        #region 注释 modify by jiangbb 2014-06-08 邮件注释
        //if (selCalling.SelectedValue == "0C")
        //{
        //    selCorp.Items.Add(new ListItem("0008:信息亭缴费", "0008"));
        //    selCorp.Items.Add(new ListItem("0A00:集团充值", "0A00"));
        //}
        //else if (selCalling.SelectedValue == "0D")
        //{
        //    selCorp.Items.Add(new ListItem("D100:中国电信", "D100"));
        //    selCorp.Items.Add(new ListItem("D101:张家港电信代理充值", "D101"));
        //}
        //else if (selCalling.SelectedValue == "0B")
        //{
        //    selCorp.Items.Add(new ListItem("BA00:中石油", "BA00"));
        //}
        //else if (selCalling.SelectedValue == "08")
        //{
        //    selCorp.Items.Add(new ListItem("8100:江苏银行", "8100"));
        //}
        //else if (selCalling.SelectedValue == "07")
        //{
        //    selCorp.Items.Add(new ListItem("K701:可的代理充值", "K701"));
        //    selCorp.Items.Add(new ListItem("K702:移动代理充值", "K702"));
        //    selCorp.Items.Add(new ListItem("K703:吴江可的代理充值", "K703"));
        //    selCorp.Items.Add(new ListItem("K704:张家港可的代理充值", "K704"));
        //}
        //else if (selCalling.SelectedValue == "16")
        //{
        //    selCorp.Items.Add(new ListItem("Z016:张家港农商行自助终端", "Z016"));
        //}
        //else if (selCalling.SelectedValue == "21")
        //{
        //    selCorp.Items.Add(new ListItem("2101:全民付", "2101"));
        //}
        //else if (selCalling.SelectedValue == "14")
        //{
        //    selCorp.Items.Add(new ListItem("1401:在线充付", "1401"));
        //}
        #endregion
    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!DataValidate())
            return;

        TD_M_SAMTM tmTD_M_SAMTM = new TD_M_SAMTM();
        TD_M_SAMTDO ddoTD_M_SAMTDOIn = new TD_M_SAMTDO();
        ddoTD_M_SAMTDOIn.SAMNO = txtSamNo.Text.Trim();

        if (!tmTD_M_SAMTM.chkSam(context, ddoTD_M_SAMTDOIn))
        {
            context.AddError("A006600001", txtSamNo);
            return;
        }

        ddoTD_M_SAMTDOIn.VERNO = txtVersion.Text.Trim();
        ddoTD_M_SAMTDOIn.CALLINGNO = selCalling.SelectedValue;
        ddoTD_M_SAMTDOIn.USETAG = selUseTag.SelectedValue;
        ddoTD_M_SAMTDOIn.DEPARTNO = selCorp.SelectedValue;
        ddoTD_M_SAMTDOIn.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_SAMTDOIn.UPDATETIME = DateTime.Now;
        ddoTD_M_SAMTDOIn.RSRV3 = txtNote.Text.Trim();

        int AddSum = tmTD_M_SAMTM.insAdd(context, ddoTD_M_SAMTDOIn);
        if (AddSum == 0)
        {
            context.AppException("S006600002");
            return;
        }

        context.DBCommit();

        ChargeSamQuery();
        lvwChargeSam.SelectedIndex = -1;
    }

    protected void btnModify_Click(object sender, EventArgs e)
    {
        //当没有选择要修改信息时
        if (lvwChargeSam.SelectedIndex == -1)
        {
            context.AddError("A006600003");
            return;
        }
        //当编码修改时
        if (txtSamNo.Text.Trim() != getDataKeys("SAMNO"))
            context.AddError("A006600004", txtSamNo);

        if (!DataValidate())
            return;

        TD_M_SAMTM tmTD_M_SAMTM = new TD_M_SAMTM();
        TD_M_SAMTDO ddoTD_M_SAMTDOIn = new TD_M_SAMTDO();
        ddoTD_M_SAMTDOIn.SAMNO = txtSamNo.Text.Trim();
        ddoTD_M_SAMTDOIn.VERNO = txtVersion.Text.Trim();
        ddoTD_M_SAMTDOIn.CALLINGNO = selCalling.SelectedValue;
        ddoTD_M_SAMTDOIn.USETAG = selUseTag.SelectedValue;
        ddoTD_M_SAMTDOIn.DEPARTNO = selCorp.SelectedValue;
        ddoTD_M_SAMTDOIn.UPDATESTAFFNO = context.s_UserID;
        ddoTD_M_SAMTDOIn.UPDATETIME = DateTime.Now;
        ddoTD_M_SAMTDOIn.RSRV3 = txtNote.Text.Trim();

        int UpdSum = tmTD_M_SAMTM.updRecord(context, ddoTD_M_SAMTDOIn);
        if (UpdSum == 0)
        {
            context.AppException("S006600005");
            return;
        }

        context.DBCommit();

        ChargeSamQuery();
    }

    public void lvwChargeSam_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtSamNo.Text = getDataKeys("SAMNO");
        txtVersion.Text = getDataKeys("VERSION");
        string s = getDataKeys("CALLINGNO").Trim().ToUpper();
        selCalling.SelectedValue = s;
        selUseTag.SelectedValue = getDataKeys("USETAG");

        string corpNo = getDataKeys("CORPNO");
        string corpName = getDataKeys("CORP");
        selCalling_Change(sender, e);
        //selCorp.Items.Add(new ListItem(corpNo + ":" + corpName, corpNo));
        selCorp.SelectedValue = corpNo;

        txtNote.Text = getDataKeys("NOTE");

    }
    protected void lvwChargeSam_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件

            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwChargeSam','Select$" + e.Row.RowIndex + "')");
        }
    }

    public void lvwChargeSam_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwChargeSam.PageIndex = e.NewPageIndex;
        ChargeSamQuery();

        lvwChargeSam.SelectedIndex = -1;
        clearInput();
    }

    private string getDataKeys(string keysname)
    {
        return lvwChargeSam.DataKeys[lvwChargeSam.SelectedIndex][keysname].ToString();
    }

    private void clearInput()
    {
        txtSamNo.Text = "";
        txtVersion.Text = "";
        selCalling.SelectedValue = "";
        selUseTag.SelectedValue = "";
        selCorp.Items.Clear();
        txtNote.Text = "";
    }

    private bool DataValidate()
    {
        bool result = SamValidate(context, txtSamNo);

        string strVer = txtVersion.Text.Trim();
        if (!Validation.isNum(strVer))
        {
            context.AddError("A006600007", txtVersion);
            result = false;
        }
        /*
        if (selCalling.SelectedValue == "")
        {
            context.AddError("A006600008", selCalling);
            result = false;
        }
        */
        if (selUseTag.SelectedValue == "")
        {
            context.AddError("A006600009", selUseTag);
            result = false;
        }

        if (selCorp.SelectedValue == "")
        {
            context.AddError("A006600010", selCorp);
            result = false;
        }

        string strNote = txtNote.Text.Trim();
        if (strNote != "" && Validation.strLen(strNote) > 20)
        {
            context.AddError("A006600011", txtNote);
            result = false;
        }

        return result;
    }

    private bool SamValidate(CmnContext context, TextBox txtSamNo)
    {
        string samno = txtSamNo.Text.Trim();
        bool result = true;
        string msg = "A000000001: SAM卡号";
        if (samno == "")
        {
            msg = msg + "不能为空";
            result = false;
        }
        else
        {
            if (Validation.strLen(samno) != 12)
            {
                msg = msg + "不是12位 ";
                result = false;
            }
            else
            {
                string prefix = samno.Substring(0, 2);
                if (!Validation.isCharNum(prefix))
                {
                    msg = msg + "前两位必须为英数 ";
                    result = false;
                }

                string suffix = samno.Substring(2);
                if (!Validation.isNum(suffix))
                {
                    msg = msg + "后10位必须为数字";
                    result = false;
                }
            }
        }

        if (!result)
            context.AddError(msg, txtSamNo);

        return result;
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!ValidatePsam())
            return;

        ChargeSamNoQuery();
    }
    private void ChargeSamNoQuery()
    {
        TD_M_SAMTDO ddoTD_M_SAMTDO = new TD_M_SAMTDO();

        string strSql = "SELECT	s.SAMNO SAMNO,s.VERNO VERSION,s.CALLINGNO CALLINGNO,c.CALLING CALLING,s.USETAG USETAG, "
                    + "s.DEPARTNO CORPNO,d.CORP CORP,s.RSRV3 NOTE,s.UPDATESTAFFNO UPDATESTAFFNO,e.STAFFNAME UPDATESTAFF,s.UPDATETIME UPDATETIME "
                    + "from TD_M_SAM s left join TD_M_CALLINGNO c on upper(s.CALLINGNO)=c.CALLINGNO "
                    + "left join TD_M_INSIDESTAFF e on s.UPDATESTAFFNO=e.STAFFNO "
                    + "left join TD_M_CORP d on s.DEPARTNO = d.CORPNO "
                    + "Where s.Samno = '"+txtSam.Text+"' ";

        DataTable data = tm.selByPKDataTable(context, ddoTD_M_SAMTDO, null, strSql, 0);
        DataView dataView = new DataView(data);

        lvwChargeSam.DataKeyNames = new string[] { "SAMNO", "VERSION", "CALLINGNO", "CALLING", "USETAG", "CORPNO", "CORP", "NOTE", "UPDATESTAFF", "UPDATETIME" };
        lvwChargeSam.DataSource = dataView;
        lvwChargeSam.DataBind();

    }
    private bool ValidatePsam()
    {
        string samno = txtSam.Text.Trim();
        bool result = true;
        string msg = "A000000001: SAM卡号";
        if (samno == "")
        {
            msg = msg + "不能为空";
            result = false;
        }
        else
        {
            if (Validation.strLen(samno) != 12)
            {
                msg = msg + "不是12位 ";
                result = false;
            }
            else
            {
                string prefix = samno.Substring(0, 2);
                if (!Validation.isCharNum(prefix))
                {
                    msg = msg + "前两位必须为英数 ";
                    result = false;
                }

                string suffix = samno.Substring(2);
                if (!Validation.isNum(suffix))
                {
                    msg = msg + "后10位必须为数字";
                    result = false;
                }
            }
        }

        if (!result)
            context.AddError(msg, txtSam);

        return result;
    }
}
