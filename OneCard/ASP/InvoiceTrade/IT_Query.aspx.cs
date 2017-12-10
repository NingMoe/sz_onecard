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
using TDO.InvoiceTrade;
using PDO.UserCard;
using Master;
using TDO.UserManager;

public partial class ASP_InvoiceTrade_IT_Query : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            //初始化状态
            selState.Items.Add(new ListItem("---请选择---", ""));
            selState.Items.Add(new ListItem("5:分配未领用", "5"));
            selState.Items.Add(new ListItem("0:领用未开票", "0"));
            if (CommonHelper.IsDepartLead(context))
            {
                selState.Items.Add(new ListItem("1:出库未分配", "1"));
            }
            else
            {
                txtDrawer.ReadOnly = true;
            }
            selState.Items.Add(new ListItem("2:有效开票", "2"));
            selState.Items.Add(new ListItem("3:作废已开票", "3"));
            selState.Items.Add(new ListItem("4:作废未开票", "4"));
            selState.SelectedValue = "0";
            txtDrawer.Text = context.s_UserName;
            //string today = DateTime.Today.ToString("yyyy-MM-dd");
            //txtBeginDate.Text = today;
            //txtEndDate.Text = today;

            //初始化表头
            initTable();
            CommonHelper.SetInvoiceValues(context, labVolumnNo, null);
            //labVolumnNo.Text = InvoiceHelper.queryVolumne(context);
            txtVolumnNo.Text = labVolumnNo.Text;


            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTTDOIn = new TD_M_INSIDEDEPARTTDO();
            TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTTDOOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTTDOIn, typeof(TD_M_INSIDEDEPARTTDO), null, null,  " WHERE USETAG = '1' ORDER BY DEPARTNO");
            ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTTDOOutArr, "DEPARTNAME", "DEPARTNO", true);


            selDept.SelectedValue = context.s_DepartID;
            selDept.Enabled = false;

            selDept_Changed(sender, e);
        }
    }
    //初始化表头
    public void initTable()
    {
        lvwInvoice.DataSource = new DataTable();
        lvwInvoice.DataBind();
        lvwInvoice.SelectedIndex = -1;
        lvwInvoice.DataKeyNames = new string[] { "INVOICENO", "PROJ1", "FEE1", "PROJ2", "FEE2", "PROJ3", "FEE3", "PROJ4", "FEE4", "PROJ5", "FEE5", "AMOUNT", "PAYER", "DRAWER", "DRAWDATE", "TAXNO", "NOTE", "STATE", "ALLOTSTAFF", "ALLOTDEPT", "ALLOTDATE", "VOIDSTAFF", "VOIDDATE","RSRV3" };
    }


    private string getInvoiceTotal(TMTableModule tm)
    {
        string strSql = "SELECT count(*) FROM TL_R_INVOICE l left join TF_F_INVOICE f on (f.INVOICENO = l.INVOICENO and f.volumeno = l.volumeno) "
                + "left join TD_M_INSIDEDEPART d on l.ALLOTDEPARTNO = d.DEPARTNO "
                + "left join TD_M_INSIDESTAFF e on e.STAFFNO = l.ALLOTSTAFFNO "
                + "left join TD_M_INSIDESTAFF e2 on e2.STAFFNO = l.DELSTAFFNO ";

        ArrayList list = getCondition();

        string where = DealString.ListToWhereStr(list);
        strSql = strSql + where;
        DataTable dt = tm.selByPKDataTable(context, strSql, 0);
        Object obj = dt.Rows[0].ItemArray[0];
        if (obj == DBNull.Value)
            return "0";

        return Convert.ToInt32(obj).ToString();
    }

    //查询
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!InputValidate())
            return;

        TMTableModule tmTMTableModule = new TMTableModule();
        TL_R_INVOICETDO tdoTL_R_INVOICETDO = new TL_R_INVOICETDO();

        string strSql = "SELECT  l.INVOICENO INVOICENO, l.VOLUMENO VOLUMENO, f.PROJ1 PROJ1,f.FEE1 FEE1,f.PROJ2 PROJ2,f.FEE2 FEE2,f.PROJ3 PROJ3,f.FEE3 FEE3,f.PROJ4 PROJ4,f.FEE4 FEE4,f.PROJ5 PROJ5,f.FEE5 FEE5,f.TRADEFEE AMOUNT, "
            + "f.PAYMAN PAYER,f.TRADESTAFF DRAWER,to_char(f.TRADETIME,'yyyy-MM-dd') DRAWDATE,f.TAXNO TAXNO,f.REMARK NOTE,f.OLDINVOICENO OLDNO,"
            + "l.USESTATECODE STATE,decode(l.ALLOTSTATECODE,'00','入库','01','出库','02','领用','05','分配','03','作废') ALLOTSTATE,e.STAFFNAME ALLOTSTAFF,d.DEPARTNAME ALLOTDEPT,l.ALLOTTIME ALLOTDATE,e2.STAFFNAME VOIDSTAFF,l.DELTIME VOIDDATE ,f.ID TRADEID ,f.RSRV3,f.bankname,f.bankaccount "
            + "FROM TL_R_INVOICE l left join TF_F_INVOICE f on (f.INVOICENO = l.INVOICENO and f.volumeno = l.volumeno)"
            + "left join TD_M_INSIDEDEPART d on l.ALLOTDEPARTNO = d.DEPARTNO "
            + "left join TD_M_INSIDESTAFF e on e.STAFFNO = l.ALLOTSTAFFNO "
            + "left join TD_M_INSIDESTAFF e2 on e2.STAFFNO = l.DELSTAFFNO ";

        ArrayList list = getCondition();
        list.Add("rownum < 501");

        string where = DealString.ListToWhereStr(list);
        strSql = strSql + where + "order by l.INVOICENO";

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTL_R_INVOICETDO, null, strSql, 0);
        DataView dataView = new DataView(data);

        lvwInvoice.DataKeyNames = new string[] { "INVOICENO", "PROJ1", "FEE1", "PROJ2", "FEE2", "PROJ3", "FEE3", "PROJ4", "FEE4", "PROJ5", "FEE5", "AMOUNT", "PAYER", "DRAWER", "DRAWDATE", "TAXNO", "NOTE", "OLDNO", "STATE", "ALLOTSTATE", "ALLOTSTAFF", "ALLOTDEPT", "ALLOTDATE", "VOIDSTAFF", "VOIDDATE", "VOLUMENO", "TRADEID", "RSRV3", "BANKNAME", "BANKACCOUNT" };
        lvwInvoice.DataSource = dataView;
        lvwInvoice.DataBind();

        lvwInvoice.SelectedIndex = -1;


        //有效开票数
        labValidCnt.Text = getValidDrawedCnt(tmTMTableModule);

        //有效开票金额

        labAmount.Text = getAmount(tmTMTableModule);

        //作废数

        labVoidedCnt.Text = getVoidedCnt(tmTMTableModule);

        //被红冲数
        labReversedCnt.Text = getReversedCnt(tmTMTableModule);

        //红冲数

        labReverseCnt.Text = getReverseCnt(tmTMTableModule);

        //发票总数
        labInvoiceTotal.Text = getInvoiceTotal(tmTMTableModule);

        ClearDetail();
    }

    //红冲数

    //初始化领用人
    protected void selDept_Changed(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
        tdoTD_M_INSIDESTAFFIn.DEPARTNO = selDept.SelectedValue;
        TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
        ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
           
        if (CommonHelper.IsDepartLead(context))
        {
             selStaff.SelectedValue = context.s_UserID;
        }
        else
        {
            selStaff.SelectedValue = context.s_UserID;
            selStaff.Enabled = false;
        }
        
    }


    private string getReverseCnt(TMTableModule tm)
    {
        string strSql6 = "SELECT count(*) FROM TL_R_INVOICE l join TF_F_INVOICE f on f.INVOICENO = l.INVOICENO ";
        ArrayList list6 = getCondition();
        list6.Add("l.USESTATECODE='01'");
        list6.Add("f.OLDINVOICENO is not null");
        //list6.Add("l.INVOICENO in (SELECT b.INVOICENO FROM TF_B_INVOICE b　WHERE b.FUNCTIONTYPECODE = 'L1')");
        strSql6 = strSql6 + DealString.ListToWhereStr(list6);

        DataTable dt = tm.selByPKDataTable(context, strSql6, 0);
        Object obj = dt.Rows[0].ItemArray[0];
        if (obj == DBNull.Value)
            return "0";

        return Convert.ToInt32(obj).ToString();
    }

    //被红冲数
    private string getReversedCnt(TMTableModule tm)
    {
        string strSql5 = "SELECT count(*) FROM TL_R_INVOICE l join TF_F_INVOICE f on f.INVOICENO = l.INVOICENO ";
        ArrayList list5 = getCondition();
        list5.Add("l.USESTATECODE='02'");
        strSql5 = strSql5 + DealString.ListToWhereStr(list5);

        DataTable dt = tm.selByPKDataTable(context, strSql5, 0);
        Object obj = dt.Rows[0].ItemArray[0];
        if (obj == DBNull.Value)
            return "0";

        return Convert.ToInt32(obj).ToString();
    }

    //作废数
    private string getVoidedCnt(TMTableModule tm)
    {
        string strSql4 = "SELECT count(*) FROM TL_R_INVOICE l left join TF_F_INVOICE f on f.INVOICENO = l.INVOICENO ";
        ArrayList list4 = getCondition();
        list4.Add("l.ALLOTSTATECODE='03'");
        strSql4 = strSql4 + DealString.ListToWhereStr(list4);

        DataTable dt = tm.selByPKDataTable(context, strSql4, 0);
        Object obj = dt.Rows[0].ItemArray[0];
        if (obj == DBNull.Value)
            return "0";

        return Convert.ToInt32(obj).ToString();
    }

    //有效开票数
    private string getValidDrawedCnt(TMTableModule tm)
    {
        string strSql2 = "SELECT count(*) FROM TL_R_INVOICE l join TF_F_INVOICE f on f.INVOICENO = l.INVOICENO ";
        ArrayList list2 = getCondition();
        list2.Add("(l.USESTATECODE='01' or l.USESTATECODE='02') and l.ALLOTSTATECODE<>'03'");
        strSql2 = strSql2 + DealString.ListToWhereStr(list2);

        DataTable dt = tm.selByPKDataTable(context, strSql2, 0);
        Object obj = dt.Rows[0].ItemArray[0];
        if (obj == DBNull.Value)
            return "0";

        return Convert.ToInt32(obj).ToString();
    }

    //有效开票金额
    private string getAmount(TMTableModule tm)
    {
        string strSql3 = "SELECT sum(f.TRADEFEE) FROM TL_R_INVOICE l join TF_F_INVOICE f on f.INVOICENO = l.INVOICENO ";
        ArrayList list3 = getCondition();
        list3.Add("(l.USESTATECODE='01' or l.USESTATECODE='02') and l.ALLOTSTATECODE<>'03'");
        strSql3 = strSql3 + DealString.ListToWhereStr(list3);

        DataTable dt = tm.selByPKDataTable(context, strSql3, 0);
        Object obj = dt.Rows[0].ItemArray[0];
        if (obj == DBNull.Value)
            return "0.00";

        return (Convert.ToDouble(obj) / 100).ToString("0.00");
    }

    private string getCellValue(Object obj)
    {
        return (obj == DBNull.Value ? "" : ((string)obj).Trim());
    }

    //SQL条件语句
    private ArrayList getCondition()
    {
        ArrayList list = new ArrayList();
        if (txtVolumnNo.Text != "")
        {
            list.Add("l.VOLUMENO = '" + txtVolumnNo.Text + "'");
        }

        getConditionFromState(list);
        getConditionFromTime(list);
        getConditionFromId(list);
        getConditionFromDrawer(list);
        getConditionFromDepart(list);
        getConditionFromStaff(list);

        return list;
    }

    private ArrayList getConditionFromDrawer(ArrayList list)
    {
        string drawer = txtDrawer.Text.Trim();
        if (drawer != "")
        {
            list.Add("f.TRADESTAFF= '" + drawer + "'");
        }
        return list;
    }


    private ArrayList getConditionFromDepart(ArrayList list)
    {
        string drawer = selDept.SelectedValue;
        if (drawer != "")
        {
            list.Add("l.ALLOTDEPARTNO = '" + drawer + "'");
        }
        return list;
    }


    private ArrayList getConditionFromStaff(ArrayList list)
    {
        string drawer = selStaff.SelectedValue;
        if (drawer != "")
        {
            list.Add("l.ALLOTSTAFFNO = '" + drawer + "'");
        }
        return list;
    }

    private ArrayList getConditionFromState(ArrayList list)
    {
        string state = selState.SelectedValue;
        if (state == "0")//领用未使用
        {
            list.Add("l.USESTATECODE='00' and l.ALLOTSTATECODE='02'");
        }
        else if (state == "1")//出库未分配
        {
            list.Add("l.USESTATECODE='00'  and l.ALLOTSTATECODE='01'");
        }
        else if (state == "3")//作废已开票
        {
            list.Add("l.USESTATECODE='01' and l.ALLOTSTATECODE='03'");
        }
        else if (state == "4")//作废未开票
        {
            list.Add("l.USESTATECODE='00'  and l.ALLOTSTATECODE='03'");
        }
        else if (state == "2") //有效开票
        {
            list.Add("(l.USESTATECODE='01' or l.USESTATECODE='02') and l.ALLOTSTATECODE='02'");
        }
        else if (state == "5") //分配未领用
        {
            list.Add("l.ALLOTSTATECODE='05'");
         
        }
        return list;
    }
    private ArrayList getConditionFromId(ArrayList list)
    {
        string strBeginNo = txtBeginNo.Text.Trim();
        string strEndNo = txtEndNo.Text.Trim();

        if (strBeginNo != "" && strEndNo != "")
        {
            list.Add("l.INVOICENO between '" + strBeginNo + "' and '" + strEndNo + "'");
        }
        else if (strBeginNo != "")
        {
            list.Add("l.INVOICENO= '" + strBeginNo + "'");
        }
        else if (strEndNo != "")
        {
            list.Add("l.INVOICENO= '" + strEndNo + "'");
        }

        return list;
    }

    private ArrayList getConditionFromTime(ArrayList list)
    {
        string strBeginDate = txtBeginDate.Text.Trim();
        string strEndDate = txtEndDate.Text.Trim();

        if (strBeginDate != "" && strEndDate != "")
        {
            DateTime endDate = DateTime.ParseExact(strEndDate, "yyyy-MM-dd", null);
            endDate = endDate.AddDays(1);
            list.Add("f.TRADETIME >= to_date('" + strBeginDate + "','yyyy-mm-dd') and f.TRADETIME < to_date('" + endDate + "','yyyy-mm-dd hh24:mi:ss')");
        }
        else if (strBeginDate != "")
        {
            list.Add("f.TRADETIME>= to_date('" + strBeginDate + "','yyyy-mm-dd')");
        }
        else if (strEndDate != "")
        {
            DateTime endDate = DateTime.ParseExact(strEndDate, "yyyy-MM-dd", null);
            endDate = endDate.AddDays(1);
            list.Add("f.TRADETIME<to_date('" + endDate + "','yyyy-mm-dd hh24:mi:ss')");
        }

        return list;
    }

    public void lvwInvoice_Page(Object sender, GridViewPageEventArgs e)
    {
        lvwInvoice.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);

        lvwInvoice.SelectedIndex = -1;
    }

    public void lvwInvoice_SelectedIndexChanged(object sender, EventArgs e)
    {
        labNo2.Text = " 发票号:" + getDataKeys("INVOICENO");
        labDrawer.Text = " 开票人:" + getDataKeys("DRAWER");
        //labState.Text = getState(getDataKeys("STATE"));
        labAllotState.Text = getDataKeys("ALLOTSTATE");
        labAllotDate.Text = getDateDataKeys("ALLOTDATE");
        labDept.Text = getDataKeys("ALLOTDEPT");
        labAllotStaff.Text = getDataKeys("ALLOTSTAFF");
        labVoidStaff.Text = getDataKeys("VOIDSTAFF");
        labVoidDate.Text = getDateDataKeys("VOIDDATE");

        labProj1.Text = getDataKeys("PROJ1");
        labFee1.Text = getMoneyString(getDataKeys("FEE1"));
        labProj2.Text = getDataKeys("PROJ2");
        labFee2.Text = getMoneyString(getDataKeys("FEE2"));
        labProj3.Text = getDataKeys("PROJ3");
        labFee3.Text = getMoneyString(getDataKeys("FEE3"));
        labProj4.Text = getDataKeys("PROJ4");
        labFee4.Text = getMoneyString(getDataKeys("FEE4"));
        labProj5.Text = getDataKeys("PROJ5");
        labFee5.Text = getMoneyString(getDataKeys("FEE5"));
        labNote.Text = getDataKeys("NOTE");
        labVolumnNo.Text = getDataKeys("VOLUMENO");
    }

    private void ClearDetail()
    {
        labNo2.Text = "";
        labDrawer.Text = "";
        labAllotState.Text = "";
        labAllotDate.Text = "";
        labDept.Text = "";
        labAllotStaff.Text = "";
        labVoidStaff.Text = "";
        labVoidDate.Text = "";

        labProj1.Text = "";
        labFee1.Text = "";
        labProj2.Text = "";
        labFee2.Text = "";
        labProj3.Text = "";
        labFee3.Text = "";
        labProj4.Text = "";
        labFee4.Text = "";
        labProj5.Text = "";
        labFee5.Text = "";
        labNote.Text = "";
    }

    public void lvwInvoice_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('lvwInvoice','Select$" + e.Row.RowIndex + "')");
        }
    }
    private string getDataKeys(string keysname)
    {
        return lvwInvoice.DataKeys[lvwInvoice.SelectedIndex][keysname].ToString();
    }
    private string getDateDataKeys(string keysname)
    {
        try
        {
            DateTime date = (DateTime)lvwInvoice.DataKeys[lvwInvoice.SelectedIndex][keysname];
            return date.ToShortDateString();
        }
        catch (Exception)
        {
            return "";
        }
    }

    private bool InputValidate()
    {

        txtVolumnNo.Text = txtVolumnNo.Text.Trim();
        int volLen = Validation.strLen(txtVolumnNo.Text);
        if (!string.IsNullOrEmpty(txtVolumnNo.Text))
        {
            if (volLen != 12 || (!Validation.isNum(txtVolumnNo.Text)))
            {
                context.AddError("发票代码长度必须是12位,且是数字", txtVolumnNo);
            }
        }
       
       

        InvoiceValidator iv = new InvoiceValidator(context);
        iv.validateIdRangeAllowNull(txtBeginNo, txtEndNo);

        DateTime? dateEff = null, dateExp = null;

        string strBeginDate = txtBeginDate.Text.Trim();
        string strEndDate = txtEndDate.Text.Trim();
        //起始日期非空时格式判断

        if (strBeginDate != "")
            dateEff = beDate(txtBeginDate, "A200007030");

        //终止日期非空时格式判断

        if (strEndDate != "")
            dateExp = beDate(txtEndDate, "A200007031");

        //起始日期不能大于终止日期
        if (dateEff != null && dateExp != null && dateEff.Value.CompareTo(dateExp.Value) > 0)
            context.AddError("A200007032");

        if (context.hasError())
            return false;
        else
            return true;

    }

    public DateTime? beDate(TextBox tb, String errCode)
    {
        tb.Text = tb.Text.Trim();

        if (!Validation.isDate(tb.Text))
        {
            context.AddError(errCode, tb);
            return null;
        }

        return DateTime.ParseExact(tb.Text, "yyyy-MM-dd", null); ;
    }

    protected void lvwInvoice_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string v = e.Row.Cells[3].Text.Trim();
            if (v == "&nbsp;" || v == "")
                e.Row.Cells[3].Text = "";
            else
                e.Row.Cells[3].Text = (Convert.ToDouble(v) / 100).ToString("0.00");
            string state = e.Row.Cells[8].Text;
            e.Row.Cells[8].Text = getState(state);
        }
    }

    private string getMoneyString(string str)
    {
        if (str == null || str == "")
            return "";
        return (Convert.ToDouble(str) / 100).ToString("0.00");
    }

    private string getState(string code)
    {
        if (code == "00")
            return "未开票";
        if (code == "01")
            return "已开票";
        if (code == "02")
            return "已红冲";
        if (code == "03")
            return "已作废";
        if (code == "04")
            return "已冻结";
        return "";
    }
    private string getAllotState(string code)
    {
        if (code == "00")
            return "入库";
        if (code == "01")
            return "出库";
        if (code == "02")
            return "领用";
        if (code == "05")
            return "分配";
        return "";
    }


    protected void Print_Click(object sender, EventArgs e)
    {
        try
        {
            if (getDataKeys("STATE") == "01")
            {
                if (getDataKeys("DRAWER") == context.s_UserName)
                {
                    string validatecode = getDataKeys("RSRV3");
                    if (validatecode == "&nbsp;" || validatecode == "")
                    {
                        context.AddError("验证码不存在，不能打印");
                        return;
                    }
                    //设置发票数据，调用打印JS
                    InitInvoicePrintControl();

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "printPaPiaoScript", "printFaPiao();", true);
                }
                else
                {
                    context.AddError("您无权打印别人的发票");
                }
               
            }
            else
            {
                context.AddError("不是有效开票，请检查");
            }

        }
        catch 
        {
         //   context.AddError();
        }
    }


    //设置发票数据
    private void InitInvoicePrintControl()
    {
        
        string[] dates = getDataKeys("DRAWDATE").Split('-');
        ptnFaPiao.Year = dates[0];
        ptnFaPiao.Month = dates[1];
        ptnFaPiao.Day = dates[2];
       
        ptnFaPiao.FuKuanFang = getDataKeys("PAYER");
        ptnFaPiao.ShouKuanFang = "苏州市民卡有限公司客户备付金";
        ptnFaPiao.NaShuiRen = "9132050874558352XW";
        ptnFaPiao.PiaoHao = getDataKeys("INVOICENO");
        ptnFaPiao.FuKuanFangCode = "";
        ptnFaPiao.JuanHao = getDataKeys("VOLUMENO");
        ptnFaPiao.BankName = getDataKeys("BANKNAME");
        ptnFaPiao.BankAccount = getDataKeys("BANKACCOUNT");
        //Decimal i = Convert.ToDecimal(Total.Text.Trim());
        ptnFaPiao.JinE =(Convert.ToDecimal(getDataKeys("AMOUNT"))/100).ToString("0.00");
        //ptnFaPiao.JinE = (i).ToString("0.00");

        ptnFaPiao.JinEChina = ConvertNumChn.ConvertSum((Convert.ToDecimal(getDataKeys("AMOUNT")) / 100).ToString("0.00"));
        ptnFaPiao.KaiPiaoRen = getDataKeys("DRAWER");
       
        ArrayList projs = new ArrayList();
        if (!string.IsNullOrEmpty( labProj1.Text))
        {
            string[] proj1 = new string[4] {labProj1.Text,labFee1.Text,"1", labFee1.Text };
            projs.Add(proj1);
        }
        if (!string.IsNullOrEmpty(labProj2.Text))
        {
            string[] proj1 = new string[4] { labProj2.Text,labFee2.Text,"1", labFee2.Text };
            projs.Add(proj1);
        }
        if (!string.IsNullOrEmpty(labProj3.Text))
        {
            string[] proj1 = new string[4] { labProj3.Text,labFee3.Text,"1", labFee3.Text };
            projs.Add(proj1);
        }
        if (!string.IsNullOrEmpty(labProj4.Text))
        {
            string[] proj1 = new string[4] { labProj4.Text,labFee4.Text,"1", labFee4.Text };
            projs.Add(proj1);
        }
        if (!string.IsNullOrEmpty(labProj5.Text))
        {
            string[] proj1 = new string[4] { labProj5.Text,labFee5.Text,"1", labFee5.Text };
            projs.Add(proj1);
        }

        ptnFaPiao.ProjectList = projs;

        ArrayList note = new ArrayList();
        string strNote = labNote.Text.Trim();
        string[] notes = strNote.Split(new char[] { '\n' });
        for (int k = 0; k < notes.Length; k++)
        {
            note.Add(notes[k]);
        }
        ptnFaPiao.RemarkList = note;
        ptnFaPiao.ValidateCode = getDataKeys("RSRV3");
        
    }
}
