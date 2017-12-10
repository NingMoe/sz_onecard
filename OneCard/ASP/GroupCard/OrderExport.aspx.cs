using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using TDO.UserManager;
using Common;
using TDO.BusinessCode;
using System.Collections;
using TM;
using System.Xml;
using System.IO;
/**********************************
 * 订单导出
 * 2013-4-23
 * shil
 * 初次编写
 * ********************************/
public partial class ASP_GroupCard_OrderExport : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化审核状态

            OrderHelper.selOrderState(context, selApprovalStatus, true);
            //初始化部门

            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
            TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
            ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
            //selDept.SelectedValue = context.s_DepartID;
            InitStaffList(selStaff, context.s_DepartID);//初始化录入员工

            //selStaff.SelectedValue = context.s_UserID;
            gvOrderList.DataKeyNames = new string[] { "ORDERNO", "GROUPNAME", "NAME", "PHONE", "IDCARDNO", "TOTALMONEY","cashgiftmoney",
            "TRANSACTOR", "INPUTTIME","REMARK","financeremark","financeapproverno","customeraccmoney","getdepartment","getdate" };
            InitStaffList(ddlApprover, "0001");//初始化审核员工

            //初始化日期

            DateTime date = new DateTime();
            date = DateTime.Today.AddDays(-1);
            txtFromDate.Text = date.ToString("yyyyMMdd");
            txtToDate.Text = date.ToString("yyyyMMdd");
            ShowNonDataGridView();

        }
    }
    /// <summary>
    /// 初始化列表

    /// </summary>
    private void ShowNonDataGridView()
    {
        gvOrderList.DataSource = new DataTable();
        gvOrderList.DataBind();
    }
    /// <summary>
    /// 初始化下拉选框
    /// </summary>
    /// <param name="ddl">控件名称</param>
    /// <param name="deptNo">部门编码</param>
    private void InitStaffList(DropDownList ddl, string deptNo)
    {
        if (deptNo == "")
        {
            string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
            if (dBalunitNo != "")//add by liuhe20120214添加对代理的权限处理
            {
                context.DBOpen("Select");
                string sql = @"SELECT STAFFNAME,STAFFNO FROM TD_M_INSIDESTAFF 
                             WHERE DIMISSIONTAG ='1' AND  DEPARTNO IN 
                            (SELECT DEPARTNO FROM TD_DEPTBAL_RELATION WHERE DBALUNITNO='" + dBalunitNo + "' AND USETAG='1')";
                DataTable table = context.ExecuteReader(sql);
                GroupCardHelper.fill(ddl, table, true);
                return;
            }
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";
            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "");
            ControlDeal.SelectBoxFill(ddl.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
            //ddl.SelectedValue = context.s_UserID;
        }
        else
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";
            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
            ControlDeal.SelectBoxFill(ddl.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
    }

    //部门选择事件
    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selStaff, selDept.SelectedValue);
    }
    /// <summary>
    /// 查询
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!ValidInput()) return;
        gvOrderList.DataSource = query();
        gvOrderList.DataBind();
        gvOrderList.SelectedIndex = -1;
    }
    /// <summary>
    /// 查询
    /// </summary>
    /// <returns></returns>
    private ICollection query()
    {
        string groupName = txtGroupName.Text.Trim();
        string name = txtName.Text.Trim();//联系人

        string staff = "";
        if (selStaff.SelectedIndex > 0)
        {
            staff = selStaff.SelectedValue;
        }
        string dept = "";
        if (selDept.SelectedIndex > 0)
        {
            dept = selDept.SelectedValue;
        }
        string money = "";
        if (txtTotalMoney.Text.Trim().Length > 0)
        {
            money = (Convert.ToDecimal(txtTotalMoney.Text.Trim()) * 100).ToString();
        }
        string fromDate = txtFromDate.Text.Trim();
        string endDate = txtToDate.Text.Trim();
        DataTable data = GroupCardHelper.callOrderQuery(context, "AllOrderInfoForExport", groupName, name, staff, money, fromDate, endDate, selApprovalStatus.SelectedValue, ddlApprover.SelectedValue, dept);

        if (data == null || data.Rows.Count < 1)
        {
            gvOrderList.DataSource = new DataTable();
            gvOrderList.DataBind();
            context.AddError("未查出订单记录");
        }
        return new DataView(data);
    }
    /// <summary>
    /// 查询单位名称
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void queryGroupName(object sender, EventArgs e)
    {
        queryCompany(txtGroupName, selCompany);
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
    /// <summary>
    /// 单位名称全称下拉选框选择事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void selCompany_Changed(object sender, EventArgs e)
    {
        txtGroupName.Text = selCompany.SelectedItem.ToString();
    }
    /// <summary>
    /// 查询验证
    /// </summary>
    /// <returns></returns>
    private bool ValidInput()
    {
        //校验单位名称长度
        if (!string.IsNullOrEmpty(txtGroupName.Text.Trim()))
        {
            if (txtGroupName.Text.Trim().Length > 50)
            {
                context.AddError("单位名称长度不能超过50个字符长度");
            }
        }
        //校验联系人长度

        if (!string.IsNullOrEmpty(txtName.Text.Trim()))
        {
            if (txtName.Text.Trim().Length > 8)
            {
                context.AddError("联系人长度不能超过25个字符长度");
            }
        }

        if (txtTotalMoney.Text.Trim().Length > 0) //金额不为空时
        {
            if (!Validation.isPrice(txtTotalMoney.Text.Trim()))
            {
                context.AddError("金额输入不正确", txtTotalMoney);
            }
            else if (Convert.ToDecimal(txtTotalMoney.Text.Trim()) <= 0)
            {
                context.AddError("金额必须是正数", txtTotalMoney);
            }
        }
        //对开始日期和结束日期的判断

        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, false);
        return !(context.hasError());
    }
    protected void btnDetail_Click(object sender, EventArgs e)
    {
        Button btnCreate = sender as Button;
        int index = int.Parse(btnCreate.CommandArgument);//获取行号
        //选择员工GRIDVIEW中的一行记录

        string orderno = getDataKeys(index, "ORDERNO");
        ViewState["orderno"] = orderno;
        string groupName = getDataKeys(index, "GROUPNAME");
        string name = getDataKeys(index, "NAME");
        string phone = getDataKeys(index, "PHONE");
        string idCardNo = getDataKeys(index, "IDCARDNO");
        string totalMoney = getDataKeys(index, "TOTALMONEY");
        string transactor = getDataKeys(index, "TRANSACTOR");
        string remark = getDataKeys(index, "REMARK");
        string totalCashGiftChargeMoney = getDataKeys(index, "cashgiftmoney");
        string customeraccmoney = getDataKeys(index, "customeraccmoney");
        string approver = getDataKeys(index, "financeapproverno");
        string financeRemark = getDataKeys(index, "financeremark");
        divInfo.InnerHtml = OrderHelper.GetOrderHtmlString(context, orderno, groupName,
            name, phone, idCardNo, totalMoney, transactor,
            remark, "0", financeRemark, totalCashGiftChargeMoney, approver, customeraccmoney, "", "", false, false);
    }

    public String getDataKeys(int index, String keysname)
    {
        return gvOrderList.DataKeys[index][keysname].ToString();
    }

    /// <summary>
    /// 导出
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnExport_Click(object sender, EventArgs e)
    {
        ExportXml();
    }
    /// <summary>
    /// 数据插入临时表

    /// </summary>
    /// <param name="sessionID"></param>
    private void ExportXml()
    {
        int count = 0;
        XmlDocument xmldoc = new XmlDocument();

        XmlDeclaration xmldecl;
        xmldecl = xmldoc.CreateXmlDeclaration("1.0", "GB2312", null);
        xmldoc.AppendChild(xmldecl);

        //加入一个根元素
        XmlElement ROOT = xmldoc.CreateElement("", "ORDERS", "");
        xmldoc.AppendChild(ROOT);

        XmlNode ORDERS = xmldoc.SelectSingleNode("ORDERS");

        foreach (GridViewRow gvr in gvOrderList.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;

                addOrderNode(xmldoc, ORDERS, gvr.Cells[2].Text, count.ToString());
            }
        }
        // 没有选中任何行，则返回错误

        if (count <= 0)
        {
            context.AddError("A004P03R01: 没有选中任何行");
        }

        //保存创建好的XML文档 
        ExportXml(xmldoc);
    }
    /// <summary>
    /// 导出xml文件
    /// </summary>
    /// <param name="xmldoc"></param>
    protected void ExportXml(XmlDocument xmldoc)
    {
        string fileName = "";
        string sql = "SELECT SERIALNO FROM TD_M_EXPORTSERIAL WHERE EXPORTDATE = '" + DateTime.Today.ToString("yyyyMMdd") + "'";
        context.DBOpen("Select");
        DataTable data = context.ExecuteReader(sql);
        if (data.Rows.Count > 0)
        {
            context.SPOpen();
            context.AddField("P_FUNCCODE").Value = "MODIFY";
            context.AddField("p_EXPORTDATE").Value = DateTime.Today.ToString("yyyyMMdd");

            bool ok = context.ExecuteSP("SP_GC_SETEXPORTSERIAL");
            if(ok)
            {
                string serial = "0000" + (Convert.ToInt32(data.Rows[0]["SERIALNO"].ToString()) + 1).ToString();
                string newserial = serial.Substring(serial.Length - 4, 4);
                fileName = "SZT_" + DateTime.Today.ToString("yyyyMMdd") + "_" + newserial + ".xml";
            }
        }
        else
        {
            context.SPOpen();
            context.AddField("P_FUNCCODE").Value = "ADD"; 
            context.AddField("p_EXPORTDATE").Value = DateTime.Today.ToString("yyyyMMdd");

            bool ok = context.ExecuteSP("SP_GC_SETEXPORTSERIAL");
            if (ok)
            {
                fileName = "SZT_" + DateTime.Today.ToString("yyyyMMdd") + "_0001.xml";
            }
        }

        if (context.hasError())
        {
            return;
        }
        Response.Clear();
        Response.Buffer = true;
        Response.Charset = "GB2312";
        Response.AppendHeader("Content-Disposition", "attachment;filename=" + fileName + "");

        Response.ContentEncoding = System.Text.Encoding.GetEncoding("GB2312");
        Response.ContentType = "text/xml";//设置输出文件类型为xml文件。 
        Response.Output.Write(XmlToString(xmldoc));
        Response.Flush();
        Response.End();
    }
    /// <summary>
    /// 将xml文件转化为字符串
    /// </summary>
    /// <param name="xmldoc"></param>
    /// <returns></returns>
    protected string XmlToString(XmlDocument xmldoc)
    {
        //将XmlDocument存入内存
        MemoryStream stream = new MemoryStream();
        XmlTextWriter writer = new XmlTextWriter(stream, System.Text.Encoding.GetEncoding("GB2312"));
        writer.Formatting = Formatting.Indented;
        xmldoc.Save(writer);

        //读取内存
        StreamReader sr = new StreamReader(stream, System.Text.Encoding.GetEncoding("GB2312"));
        stream.Position = 0;
        string XMLString = sr.ReadToEnd();
        sr.Close();
        stream.Close();

        return XMLString;
    }

    protected void addOrderNode(XmlDocument xmldoc, XmlNode ORDERS, string orderno, string rownum)
    {
        //获取订单基本信息
        DataTable data = GroupCardHelper.callOrderQuery(context, "OrderInfoForExport", orderno);
        XmlNode ORDER;
        if (data != null && data.Rows.Count > 0)
        {

            ORDER = xmldoc.CreateElement("ORDER");
            ORDERS.AppendChild(ORDER);

            XmlElement INITIATOR = xmldoc.CreateElement("INITIATOR");
            INITIATOR.InnerText = "2";
            ORDER.AppendChild(INITIATOR);

            XmlElement ORDERNO = xmldoc.CreateElement("ORDERNO");
            ORDERNO.InnerText = orderno;
            ORDER.AppendChild(ORDERNO);

            XmlElement ORDERTYPE = xmldoc.CreateElement("ORDERTYPE");
            ORDERTYPE.InnerText = data.Rows[0]["ORDERTYPE"].ToString();
            ORDER.AppendChild(ORDERTYPE);

            XmlElement ORDERSTATE = xmldoc.CreateElement("ORDERSTATE");
            ORDERSTATE.InnerText = data.Rows[0]["ORDERSTATE"].ToString().Substring(0,2);
            ORDER.AppendChild(ORDERSTATE);

            XmlElement COMPANYNAME = xmldoc.CreateElement("COMPANYNAME");
            COMPANYNAME.InnerText = data.Rows[0]["GROUPNAME"].ToString();
            ORDER.AppendChild(COMPANYNAME);

            string queryCustInfo = "";
            if (data.Rows[0]["ORDERTYPE"].ToString() == "1")
            {
                queryCustInfo = @"Select a.COMPANYPAPERTYPE,a.COMPANYPAPERNO,b.PAPERTYPE,b.ADDRESS,b.EMAIL,b.OUTBANK,b.OUTACCT
                              From TD_M_BUYCARDCOMINFO a,TF_F_COMBUYCARDREG b
                              Where a.COMPANYNO=b.COMPANYNO And b.REMARK = '" + orderno + "'";

                context.DBOpen("Select");
                DataTable queryCustInfodata = context.ExecuteReader(queryCustInfo);
                if (queryCustInfodata.Rows.Count > 0)
                {
                    XmlElement COMPANYPAPERTYPE = xmldoc.CreateElement("COMPANYPAPERTYPE");
                    COMPANYPAPERTYPE.InnerText = queryCustInfodata.Rows[0]["COMPANYPAPERTYPE"].ToString();
                    ORDER.AppendChild(COMPANYPAPERTYPE);

                    XmlElement COMPANYPAPERNO = xmldoc.CreateElement("COMPANYPAPERNO");
                    COMPANYPAPERNO.InnerText = queryCustInfodata.Rows[0]["COMPANYPAPERNO"].ToString();
                    ORDER.AppendChild(COMPANYPAPERNO);

                    XmlElement NAME = xmldoc.CreateElement("NAME");
                    NAME.InnerText = data.Rows[0]["NAME"].ToString();
                    ORDER.AppendChild(NAME);

                    XmlElement BIRTHDAY = xmldoc.CreateElement("BIRTHDAY");
                    BIRTHDAY.InnerText = "";
                    ORDER.AppendChild(BIRTHDAY);

                    XmlElement SEX = xmldoc.CreateElement("SEX");
                    SEX.InnerText = "";
                    ORDER.AppendChild(SEX);

                    XmlElement PAPERTYPE = xmldoc.CreateElement("PAPERTYPE");
                    PAPERTYPE.InnerText = queryCustInfodata.Rows[0]["PAPERTYPE"].ToString();
                    ORDER.AppendChild(PAPERTYPE);

                    XmlElement PAPERNO = xmldoc.CreateElement("PAPERNO");
                    PAPERNO.InnerText = data.Rows[0]["IDCARDNO"].ToString();
                    ORDER.AppendChild(PAPERNO);

                    XmlElement PHONENO = xmldoc.CreateElement("PHONENO");
                    PHONENO.InnerText = data.Rows[0]["PHONE"].ToString();
                    ORDER.AppendChild(PHONENO);

                    XmlElement ADDRESS = xmldoc.CreateElement("ADDRESS");
                    ADDRESS.InnerText = queryCustInfodata.Rows[0]["ADDRESS"].ToString();
                    ORDER.AppendChild(ADDRESS);

                    XmlElement EMAIL = xmldoc.CreateElement("EMAIL");
                    EMAIL.InnerText = queryCustInfodata.Rows[0]["EMAIL"].ToString();
                    ORDER.AppendChild(EMAIL);

                    XmlElement OUTBANK = xmldoc.CreateElement("OUTBANK");
                    OUTBANK.InnerText = queryCustInfodata.Rows[0]["OUTBANK"].ToString();
                    ORDER.AppendChild(OUTBANK);

                    XmlElement OUTACCT = xmldoc.CreateElement("OUTACCT");
                    OUTACCT.InnerText = queryCustInfodata.Rows[0]["OUTACCT"].ToString();
                    ORDER.AppendChild(OUTACCT);
                }
            }
            else
            {
                queryCustInfo = @"Select a.PAPERTYPE,a.BIRTHDAY,a.SEX,a.PHONENO,a.ADDRESS, a.EMAIL
                                  From TD_M_BUYCARDPERINFO a,tf_f_perbuycardreg b
                                  Where a.PAPERTYPE = b.PAPERTYPE
                                  And a.PAPERNO = b.PAPERNO
                                  And b.REMARK = '" + orderno + "'";

                context.DBOpen("Select");
                DataTable queryCustInfodata = context.ExecuteReader(queryCustInfo);
                if (queryCustInfodata.Rows.Count > 0)
                {
                    XmlElement COMPANYPAPERTYPE = xmldoc.CreateElement("COMPANYPAPERTYPE");
                    COMPANYPAPERTYPE.InnerText = "";
                    ORDER.AppendChild(COMPANYPAPERTYPE);

                    XmlElement COMPANYPAPERNO = xmldoc.CreateElement("COMPANYPAPERNO");
                    COMPANYPAPERNO.InnerText = "";
                    ORDER.AppendChild(COMPANYPAPERNO);

                    XmlElement NAME = xmldoc.CreateElement("NAME");
                    NAME.InnerText = data.Rows[0]["NAME"].ToString();
                    ORDER.AppendChild(NAME);

                    XmlElement BIRTHDAY = xmldoc.CreateElement("BIRTHDAY");
                    BIRTHDAY.InnerText = queryCustInfodata.Rows[0]["BIRTHDAY"].ToString();
                    ORDER.AppendChild(BIRTHDAY);

                    XmlElement SEX = xmldoc.CreateElement("SEX");
                    SEX.InnerText = queryCustInfodata.Rows[0]["SEX"].ToString();
                    ORDER.AppendChild(SEX);

                    XmlElement PAPERTYPE = xmldoc.CreateElement("PAPERTYPE");
                    PAPERTYPE.InnerText = queryCustInfodata.Rows[0]["PAPERTYPE"].ToString();
                    ORDER.AppendChild(PAPERTYPE);

                    XmlElement PAPERNO = xmldoc.CreateElement("PAPERNO");
                    PAPERNO.InnerText = data.Rows[0]["IDCARDNO"].ToString();
                    ORDER.AppendChild(PAPERNO);

                    XmlElement PHONENO = xmldoc.CreateElement("PHONENO");
                    PHONENO.InnerText = data.Rows[0]["PHONE"].ToString();
                    ORDER.AppendChild(PHONENO);

                    XmlElement ADDRESS = xmldoc.CreateElement("ADDRESS");
                    ADDRESS.InnerText = queryCustInfodata.Rows[0]["ADDRESS"].ToString();
                    ORDER.AppendChild(ADDRESS);

                    XmlElement EMAIL = xmldoc.CreateElement("EMAIL");
                    EMAIL.InnerText = queryCustInfodata.Rows[0]["EMAIL"].ToString();
                    ORDER.AppendChild(EMAIL);

                    XmlElement OUTBANK = xmldoc.CreateElement("OUTBANK");
                    OUTBANK.InnerText = "";
                    ORDER.AppendChild(OUTBANK);

                    XmlElement OUTACCT = xmldoc.CreateElement("OUTACCT");
                    OUTACCT.InnerText = "";
                    ORDER.AppendChild(OUTACCT);
                }
            }

            XmlElement TRANSACTOR = xmldoc.CreateElement("TRANSACTOR");
            TRANSACTOR.InnerText = "090001";
            ORDER.AppendChild(TRANSACTOR);

            XmlElement TOTALMONEY = xmldoc.CreateElement("TOTALMONEY");
            TOTALMONEY.InnerText = data.Rows[0]["TOTALMONEY"].ToString();
            ORDER.AppendChild(TOTALMONEY);

            XmlElement REMARK = xmldoc.CreateElement("REMARK");
            REMARK.InnerText = data.Rows[0]["REMARK"].ToString();
            ORDER.AppendChild(REMARK);

            XmlElement CASHGIFTMONEY = xmldoc.CreateElement("CASHGIFTMONEY");
            CASHGIFTMONEY.InnerText = data.Rows[0]["CASHGIFTMONEY"].ToString();
            ORDER.AppendChild(CASHGIFTMONEY);

            XmlElement CHARGECARDMONEY = xmldoc.CreateElement("CHARGECARDMONEY");
            CHARGECARDMONEY.InnerText = data.Rows[0]["CHARGECARDMONEY"].ToString();
            ORDER.AppendChild(CHARGECARDMONEY);

            XmlElement SZTCARDMONEY = xmldoc.CreateElement("SZTCARDMONEY");
            SZTCARDMONEY.InnerText = data.Rows[0]["SZTCARDMONEY"].ToString();
            ORDER.AppendChild(SZTCARDMONEY);

            XmlElement CUSTOMERACCMONEY = xmldoc.CreateElement("CUSTOMERACCMONEY");
            CUSTOMERACCMONEY.InnerText = data.Rows[0]["CUSTOMERACCMONEY"].ToString();
            ORDER.AppendChild(CUSTOMERACCMONEY);

            XmlElement INVOICETOTALMONEY = xmldoc.CreateElement("INVOICETOTALMONEY");
            INVOICETOTALMONEY.InnerText = data.Rows[0]["INVOICETOTALMONEY"].ToString();
            ORDER.AppendChild(INVOICETOTALMONEY);

            XmlElement GETDEPARTMENT = xmldoc.CreateElement("GETDEPARTMENT");
            GETDEPARTMENT.InnerText = data.Rows[0]["GETDEPARTMENT"].ToString();
            ORDER.AppendChild(GETDEPARTMENT);

            XmlElement GETDATE = xmldoc.CreateElement("GETDATE");
            GETDATE.InnerText = data.Rows[0]["GETDATE"].ToString();
            ORDER.AppendChild(GETDATE);
        }
        else
        {
            context.AddError("未找到第" + rownum + "行订单");
            return;
        }

        //获取利金卡信息

        data = GroupCardHelper.callOrderQuery(context, "CashOrderInfo", orderno);
        if (data != null && data.Rows.Count > 0)
        {
            for (int i = 0; i < data.Rows.Count; i++)
            {
                XmlNode CASHGIFTCARD = xmldoc.CreateElement("CASHGIFTCARD");
                ORDER.AppendChild(CASHGIFTCARD);

                XmlElement CASHGIFTCARDVALUE = xmldoc.CreateElement("VALUE");
                CASHGIFTCARDVALUE.InnerText = data.Rows[i]["VALUE"].ToString();
                CASHGIFTCARD.AppendChild(CASHGIFTCARDVALUE);

                XmlElement CASHGIFTCARDCOUNT = xmldoc.CreateElement("COUNT");
                CASHGIFTCARDCOUNT.InnerText = data.Rows[i]["COUNT"].ToString();
                CASHGIFTCARD.AppendChild(CASHGIFTCARDCOUNT);

                XmlElement CASHGIFTCARDSUM = xmldoc.CreateElement("SUM");
                CASHGIFTCARDSUM.InnerText = data.Rows[i]["SUM"].ToString();
                CASHGIFTCARD.AppendChild(CASHGIFTCARDSUM);
            }
        }
        //获取充值卡信息
        data = GroupCardHelper.callOrderQuery(context, "ChargeCardOrderInfo", orderno);
        if (data != null && data.Rows.Count > 0)
        {
            for (int i = 0; i < data.Rows.Count; i++)
            {
                XmlNode CHARGECARD = xmldoc.CreateElement("CHARGECARD");
                ORDER.AppendChild(CHARGECARD);

                XmlElement VALUECODE = xmldoc.CreateElement("VALUECODE");
                VALUECODE.InnerText = data.Rows[i]["VALUECODE"].ToString();
                CHARGECARD.AppendChild(VALUECODE);

                XmlElement CHARGECARDCOUNT = xmldoc.CreateElement("COUNT");
                CHARGECARDCOUNT.InnerText = data.Rows[i]["COUNT"].ToString();
                CHARGECARD.AppendChild(CHARGECARDCOUNT);

                XmlElement CHARGECARDSUM = xmldoc.CreateElement("SUM");
                CHARGECARDSUM.InnerText = data.Rows[i]["SUM"].ToString();
                CHARGECARD.AppendChild(CHARGECARDSUM);
            }
        }
        //获取苏州通卡信息
        data = GroupCardHelper.callOrderQuery(context, "SZTCardOrderInfo", orderno);
        if (data != null && data.Rows.Count > 0)
        {
            for (int i = 0; i < data.Rows.Count; i++)
            {

                XmlNode SZTCARD = xmldoc.CreateElement("SZTCARD");
                ORDER.AppendChild(SZTCARD);

                XmlElement CARDTYPECODE = xmldoc.CreateElement("CARDTYPECODE");
                CARDTYPECODE.InnerText = data.Rows[i]["CARDTYPECODE"].ToString();
                SZTCARD.AppendChild(CARDTYPECODE);

                XmlElement SZTCARDCOUNT = xmldoc.CreateElement("COUNT");
                SZTCARDCOUNT.InnerText = data.Rows[i]["COUNT"].ToString();
                SZTCARD.AppendChild(SZTCARDCOUNT);

                XmlElement UNITPRICE = xmldoc.CreateElement("UNITPRICE");
                UNITPRICE.InnerText = data.Rows[i]["UNITPRICE"].ToString();
                SZTCARD.AppendChild(UNITPRICE);

                XmlElement TOTALCHARGEMONEY = xmldoc.CreateElement("TOTALCHARGEMONEY");
                TOTALCHARGEMONEY.InnerText = data.Rows[i]["TOTALCHARGEMONEY"].ToString();
                SZTCARD.AppendChild(TOTALCHARGEMONEY);

                XmlElement SZTCARDTOTALMONEY = xmldoc.CreateElement("TOTALMONEY");
                SZTCARDTOTALMONEY.InnerText = data.Rows[i]["TOTALMONEY"].ToString();
                SZTCARD.AppendChild(SZTCARDTOTALMONEY);
            }
        }
        //获取开票信息

        data = GroupCardHelper.callOrderQuery(context, "InvoiceOrderInfo", orderno);
        if (data != null && data.Rows.Count > 0)
        {
            for (int i = 0; i < data.Rows.Count; i++)
            {
                XmlNode INVOICE = xmldoc.CreateElement("INVOICE");
                ORDER.AppendChild(INVOICE);

                XmlElement INVOICETYPECODE = xmldoc.CreateElement("INVOICETYPECODE");
                INVOICETYPECODE.InnerText = data.Rows[i]["INVOICETYPECODE"].ToString();
                INVOICE.AppendChild(INVOICETYPECODE);

                XmlElement INVOICEMONEY = xmldoc.CreateElement("INVOICEMONEY");
                INVOICEMONEY.InnerText = (Convert.ToDecimal(data.Rows[i]["INVOICEMONEY"].ToString()) * 100).ToString();
                INVOICE.AppendChild(INVOICEMONEY);
            }
        }
        //获取支付方式信息
        data = GroupCardHelper.callOrderQuery(context, "PayTypeOrderInfo", orderno);
        if (data != null && data.Rows.Count > 0)
        {
            string strCheck = "0";
            string strTransfer = "0";
            string strCash = "0";
            string strSlopcard = "0";
            string strApprove = "0";

            for (int i = 0; i < data.Rows.Count; i++)
            {
                if (data.Rows[i]["PAYTYPECODE"].ToString() == "0")
                {
                    strCheck = "1";
                }
                if (data.Rows[i]["PAYTYPECODE"].ToString() == "1")
                {
                    strTransfer = "1";
                }
                if (data.Rows[i]["PAYTYPECODE"].ToString() == "2")
                {
                    strCash = "1";
                }
                if (data.Rows[i]["PAYTYPECODE"].ToString() == "3")
                {
                    strSlopcard = "1";
                }
                if (data.Rows[i]["PAYTYPECODE"].ToString() == "4")
                {
                    strApprove = "1";
                }
            }

            XmlNode PAYTYPE = xmldoc.CreateElement("PAYTYPE");
            ORDER.AppendChild(PAYTYPE);

            XmlElement CHECK = xmldoc.CreateElement("CHECK");
            CHECK.InnerText = strCheck;
            PAYTYPE.AppendChild(CHECK);

            XmlElement TRANSFER = xmldoc.CreateElement("TRANSFER");
            TRANSFER.InnerText = strTransfer;
            PAYTYPE.AppendChild(TRANSFER);

            XmlElement CASH = xmldoc.CreateElement("CASH");
            CASH.InnerText = strCash;
            PAYTYPE.AppendChild(CASH);

            XmlElement SLOPCARD = xmldoc.CreateElement("SLOPCARD");
            SLOPCARD.InnerText = strSlopcard;
            PAYTYPE.AppendChild(SLOPCARD);

            XmlElement APPROVE = xmldoc.CreateElement("APPROVE");
            APPROVE.InnerText = strApprove;
            PAYTYPE.AppendChild(APPROVE);
        }
    }
}