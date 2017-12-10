using System;
using System.Data;
using System.Collections;
using System.Web.UI;
using System.Web.UI.WebControls;
using PDO.PersonalBusiness;
using Common;
using TM;
using TDO.BusinessCode;
using TDO.UserManager;

public partial class ASP_PersonalBusiness_PB_ComBuyCardReg : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            //指定GridView DataKeyNames
            gvResult.DataKeyNames = new string[] { "ID", "COMPANYNAME", "COMPANYPAPERTYPE", "COMPANYPAPERNO", "NAME", "PAPERTYPE", 
                                                   "PAPERNO", "PHONENO", "ADDRESS", "EMAIL", "OUTBANK", "OUTACCT", "STARTCARDNO", 
                                                   "ENDCARDNO", "BUYCARDDATE", "BUYCARDNUM", "BUYCARDMONEY", "CHARGEMONEY", "REMARK" };

            initLoad(sender, e);
            showConGridView();
        }
    }

    protected void initLoad(object sender, EventArgs e)
    {
        //从证件类型编码表(TD_M_PAPERTYPE)中读取数据，放入下拉列表中


        ASHelper.initPaperTypeList(context, selPapertype);
        ASHelper.initPaperTypeList(context, selActerPapertype);

        selComPapertype.Items.Add(new ListItem("---请选择---", ""));
        selComPapertype.Items.Add(new ListItem("01:组织机构代码证", "01"));
        selComPapertype.Items.Add(new ListItem("02:企业营业执照", "02"));

    }

    private void showConGridView()
    {
        //显示交易信息列表
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;

    }
    //查询单位名称
    protected void queryCompanyName(object sender, EventArgs e)
    {
        queryCompany(txtCompanyname, selCompanyname);
    }
    //查询单位名称
    protected void queryCompany(object sender, EventArgs e)
    {
        queryCompany(txtCompany, selCompany);
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
            txtComPaperno.Text = tdoTD_M_BUYCARDCOMINFOOutArr.COMPANYPAPERNO;
        }
        else
        {
            selComPapertype.SelectedValue = "";
            txtComPaperno.Text = "";
        }
        clearBuyCardInfo(false);
    }
    protected void selCompanyname_Change(object sender, EventArgs e)
    {
        //单位名称反向赋值

        txtCompanyname.Text = selCompanyname.SelectedValue;
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //验证输入有效性

        if (!checkQueryValidation())
            return;

        //查询单位购卡记录
        ICollection dataView = queryComBuyCardReg();

        //没有查询出记录时,显示错误
        if (dataView.Count == 0)
        {
            showConGridView();
            context.AddError("没有查询出任何记录");
            return;
        }

        //显示Gridview
        gvResult.DataSource = dataView;
        gvResult.DataBind();
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
                    DataTable data = SPHelper.callPBQuery(context, "QueryUnitComBuyCardReg", txtActername.Text, selActerPapertype.SelectedValue,
                                          txtActerPaperno.Text, txtCompanyname.Text, dbalUnitNo);
                    return new DataView(data);
                }
                else if (HasOperPower("201010"))//如果是代理营业厅网点主管
                {
                    //如果是网点主管，能查询本部门的记录
                    DataTable data = SPHelper.callPBQuery(context, "QueryDeptComBuyCardReg", txtActername.Text, selActerPapertype.SelectedValue,
                                         txtActerPaperno.Text, txtCompanyname.Text, context.s_DepartID);
                    return new DataView(data);
                }
                //既不是全网点主管也不是网点主管，只能查询到本人的记录，uodate by shil,20120604
                DataTable data1 = SPHelper.callPBQuery(context, "QueryStaffComBuyCardReg", txtActername.Text, selActerPapertype.SelectedValue,
                                             txtActerPaperno.Text, txtCompanyname.Text, context.s_UserID);
                return new DataView(data1);
            }
            else if (deptType == "0") //自营营业厅员工
            {
                if (HasOperPower("201013")) //如果是公司主管，可以查询全部记录，add by shil,20120604
                {
                    DataTable data = SPHelper.callPBQuery(context, "QueryStaffComBuyCardReg", txtActername.Text, selActerPapertype.SelectedValue,
                                                      txtActerPaperno.Text, txtCompanyname.Text);   
                    return new DataView(data);
                }
                else if (HasOperPower("201012")) //如果是部门主管，可以查询本部门的记录，add by shil,20120604
                {
                    DataTable data = SPHelper.callPBQuery(context, "QueryDeptComBuyCardReg", txtActername.Text, selActerPapertype.SelectedValue,
                                     txtActerPaperno.Text, txtCompanyname.Text, context.s_DepartID);
                    return new DataView(data);
                }
                //既不是公司主管也不是部门主管，只能查询到本人的记录
                DataTable data1 = SPHelper.callPBQuery(context, "QueryStaffComBuyCardReg", txtActername.Text, selActerPapertype.SelectedValue,
                                             txtActerPaperno.Text, txtCompanyname.Text, context.s_UserID);
                return new DataView(data1);
            }
            return null;
        }
        else
        {
            //如果没有记录，说明是自营营业厅
            if (HasOperPower("201013")) //如果是公司主管，可以查询全部记录，add by shil,20120604
            {
                DataTable data = SPHelper.callPBQuery(context, "QueryStaffComBuyCardReg", txtActername.Text, selActerPapertype.SelectedValue,
                                                  txtActerPaperno.Text, txtCompanyname.Text);
                return new DataView(data);
            }
            else if (HasOperPower("201012")) //如果是部门主管，可以查询本部门的记录，add by shil,20120604
            {
                DataTable data = SPHelper.callPBQuery(context, "QueryDeptComBuyCardReg", txtActername.Text, selActerPapertype.SelectedValue,
                                 txtActerPaperno.Text, txtCompanyname.Text, context.s_DepartID);
                return new DataView(data);
            }
            //既不是公司主管也不是部门主管，只能查询到本人的记录
            DataTable data1 = SPHelper.callPBQuery(context, "QueryStaffComBuyCardReg", txtActername.Text, selActerPapertype.SelectedValue,
                                         txtActerPaperno.Text, txtCompanyname.Text, context.s_UserID);
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

    protected void btnBuyCardReg_Click(object sender, EventArgs e)
    {
        //购卡登记
        operateBuyCardReg("ADD");
    }
    protected void btnRegModify_Click(object sender, EventArgs e)
    {
        //修改
        operateBuyCardReg("MODIFY");
    }
    protected void btnRegDelete_Click(object sender, EventArgs e)
    {
        //删除
        operateBuyCardReg("DELETE");
    }

    protected void operateBuyCardReg(string funccode)
    {
        //验证有效性

        if (!checkInfoValidation())
            return;
        context.SPOpen();
        context.AddField("P_FUNCCODE").Value = funccode;
        context.AddField("P_ID").Value = hiddenID.Value;
        context.AddField("P_COMPANYNAME").Value = txtCompany.Text.Trim();
        context.AddField("P_COMPANYPAPERTYPE").Value = selComPapertype.SelectedValue;
        context.AddField("P_COMPANYPAPERNO").Value = txtComPaperno.Text.Trim();
        context.AddField("P_NAME").Value = txtCusname.Text.Trim();
        context.AddField("P_PAPERTYPE").Value = selPapertype.SelectedValue;
        context.AddField("P_PAPERNO").Value = txtCustpaperno.Text.Trim();
        context.AddField("P_PHONENO").Value = txtCustphone.Text.Trim();
        context.AddField("P_ADDRESS").Value = txtCustaddr.Text.Trim();
        context.AddField("P_EMAIL").Value = txtEmail.Text.Trim();
        context.AddField("P_OUTBANK").Value = txtOutbank.Text.Trim();
        context.AddField("P_OUTACCT").Value = txtOutacct.Text.Trim();
        context.AddField("P_STARTCARDNO").Value = txtStartcard.Text.Trim();
        context.AddField("P_ENDCARDNO").Value = txtEndcard.Text.Trim();
        if (txtBuyCardDate.Text.Trim() != "")
        {
            String[] arr = (txtBuyCardDate.Text.Trim()).Split('-');

            String cDate = arr[0] + arr[1] + arr[2];

            context.AddField("P_BUYCARDDATE").Value = cDate;
        }
        else
        {
            context.AddField("P_BUYCARDDATE").Value = txtBuyCardDate.Text.Trim();
        }
        context.AddField("P_BUYCARDNUM").Value = Convert.ToInt32(txtBuycardno.Text.Trim());
        context.AddField("P_BUYCARDMONEY").Value = Convert.ToInt32(Convert.ToDecimal(txtBuycardmoney.Text.Trim()) * 100);
        context.AddField("P_CHARGEMONEY").Value = Convert.ToInt32(Convert.ToDecimal(txtchargemoney.Text.Trim()) * 100);
        context.AddField("P_REMARK").Value = selChargeSource.SelectedValue;

        bool ok = context.ExecuteSP("SP_PB_ComBuyCardReg_Commit");
        if (ok)
        {
            //刷新列表
            gvResult.DataSource = queryComBuyCardReg();
            gvResult.DataBind();
            string function = "";
            switch (funccode)
            {
                case "ADD":
                    function = "登记";
                    break;
                case "MODIFY":
                    function = "修改";
                    break;
                case "DELETE":
                    function = "删除";
                    break;
                default:
                    break;
            }
            //显示对应操作成功
            context.AddMessage(function + "操作成功");
            //清空录入项

            clearBuyCardInfo(true);
        }
    }
    //录入输入校验
    private Boolean checkInfoValidation()
    {
        //对单位名称进行长度校验

        if (txtCusname.Text.Trim() == "")
            context.AddError("单位名称不能为空", txtCompany);
        else if (Validation.strLen(txtCompany.Text.Trim()) > 200)
            context.AddError("单位名称字符长度不能超过200位", txtCompany);

        //对单位证件类型进行非空检验

        if (selComPapertype.SelectedValue == "")
            context.AddError("单位证件类型不能为空", selComPapertype);

        //对单位证件号码进行非空、长度、英数字检验

        if (txtComPaperno.Text.Trim() == "")
            context.AddError("单位证件号码不能为空", txtComPaperno);
        //else if (!Validation.isCharNum(txtComPaperno.Text.Trim()))
        //    context.AddError("单位证件号码必须为英数", txtComPaperno);
        else if (Validation.strLen(txtComPaperno.Text.Trim()) > 30)
            context.AddError("单位证件号码程度不能超过30位", txtComPaperno);

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
        else if (selPapertype.SelectedValue == "00" && !Validation.isPaperNo(txtCustpaperno.Text.Trim()))
            context.AddError("经办人证件号码验证不通过", txtCustpaperno);

        //对联系电话进行长度检验

        if (txtCustphone.Text.Trim() != "")
            if (Validation.strLen(txtCustphone.Text.Trim()) > 20)
                context.AddError("联系电话超过20位", txtCustphone);

        //对联系地址进行长度检验

        if (txtCustaddr.Text.Trim() != "")
            if (Validation.strLen(txtCustaddr.Text.Trim()) > 200)
                context.AddError("转出银行字符长度不能超过200位", txtCustaddr);

        //对转出银行进行长度检验

        if (txtOutbank.Text.Trim() != "")
            if (Validation.strLen(txtOutbank.Text.Trim()) > 200)
                context.AddError("联系地址字符长度不能超过200位", txtOutbank);

        //对转出账户进行长度、英数校验

        if (txtOutacct.Text.Trim() != "")
            //if (!Validation.isCharNum(txtOutacct.Text.Trim()))
            //    context.AddError("转出账户必须为英数", txtOutacct);
            if (Validation.strLen(txtOutacct.Text.Trim()) > 30)
                context.AddError("转出账户字符长度不能超过30位", txtOutacct);

        //对电子邮件进行格式检验

        if (txtEmail.Text.Trim() != "")
            new Validation(context).isEMail(txtEmail);

        //对起始卡号进行非空、长度、数字检验

        if (txtStartcard.Text.Trim() != "")
        {
            if (Validation.strLen(txtStartcard.Text.Trim()) != 16)
                context.AddError("起始卡号必须为16位", txtStartcard);
            else if (!Validation.isNum(txtStartcard.Text.Trim()))
                context.AddError("起始卡号必须为数字", txtStartcard);
        }


        //对结束卡号进行非空、长度、数字检验

        if (txtEndcard.Text.Trim() != "")
        {
            if (Validation.strLen(txtEndcard.Text.Trim()) != 16)
                context.AddError("结束卡号必须为16位", txtEndcard);
            else if (!Validation.isNum(txtEndcard.Text.Trim()))
                context.AddError("结束卡号必须为数字", txtEndcard);
        }
        //对起始卡号不能大于结束卡号的检验

        if (txtStartcard.Text.Trim() != "" && txtEndcard.Text.Trim() != "" && !(context.hasError()))
            if (Convert.ToDecimal(txtStartcard.Text.Trim()) > Convert.ToDecimal(txtEndcard.Text.Trim()))
                context.AddError("结束卡号不能小于起始卡号", txtEndcard);

        //对购卡日期进行非空、日期格式校验

        String cDate = txtBuyCardDate.Text.Trim();
        if (cDate == "")
            context.AddError("购卡日期不能为空", txtBuyCardDate);
        else if (!Validation.isDate(txtBuyCardDate.Text.Trim()))
            context.AddError("购卡日期不符合规定格式", txtBuyCardDate);

        //对购卡数量进行非空、数字检验

        if (txtBuycardno.Text.Trim() == "")
            context.AddError("购卡数量不能为空", txtBuycardno);
        else if (!Validation.isNum(txtBuycardno.Text.Trim()))
            context.AddError("购卡数量必须是数字", txtBuycardno);

        //对购卡金额进行非空、数字检验

        if (txtBuycardmoney.Text.Trim() == "")
            context.AddError("购卡金额不能为空", txtBuycardmoney);
        else if (!Validation.isNum(txtBuycardmoney.Text.Trim()))
            context.AddError("购卡金额必须是数字", txtBuycardmoney);

        //对充值金额进行非空、数字检验

        if (txtchargemoney.Text.Trim() == "")
            context.AddError("充值金额不能为空", txtchargemoney);
        else if (!Validation.isNum(txtchargemoney.Text.Trim()))
            context.AddError("充值金额必须是数字", txtchargemoney);

        //对备注进行长度检验


        if (selChargeSource.SelectedValue == "")
        {
            context.AddError("充值来源不能为空", selChargeSource);
        }

        return !(context.hasError());

    }
    //查询输入校验
    private Boolean checkQueryValidation()
    {
        //对经办人姓名进行长度检验

        if (txtActername.Text.Trim() != "")
            if (Validation.strLen(txtActername.Text.Trim()) > 50)
                context.AddError("经办人姓名字符长度不能大于50", txtActername);

        //对证件号码进行长度、英数字检验

        if (txtActerPaperno.Text.Trim() != "")
            if (!Validation.isCharNum(txtActerPaperno.Text.Trim()))
                context.AddError("经办人证件号码必须为英数", txtActerPaperno);
            else if (Validation.strLen(txtActerPaperno.Text.Trim()) > 20)
                context.AddError("经办人证件号码长度不能超过20位", txtActerPaperno);

        return !(context.hasError());
    }

    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        gvResult.DataSource = queryComBuyCardReg();
        gvResult.DataBind();
    }

    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件


            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");

        }
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header
            || e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[0].Visible = false;
        }
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            string papertype = e.Row.Cells[5].Text.Trim();
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
                default:
                    break;
            }
            e.Row.Cells[5].Text = papertypename;
            string compapertype = e.Row.Cells[2].Text.Trim();
            string compapertypename = "";
            switch (compapertype)
            {
                case "01":
                    compapertypename = "01:组织机构代码证";
                    break;
                case "02":
                    compapertypename = "02:企业营业执照";
                    break;
                default:
                    break;
            }
            e.Row.Cells[2].Text = compapertypename;
        }
    }

    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择列表框一行记录

        hiddenID.Value = getDataKeys("ID");
        txtCompany.Text = getDataKeys("COMPANYNAME");
        selComPapertype.SelectedValue = getDataKeys("COMPANYPAPERTYPE");
        txtComPaperno.Text = getDataKeys("COMPANYPAPERNO");
        txtCusname.Text = getDataKeys("NAME");
        selPapertype.SelectedValue = getDataKeys("PAPERTYPE");
        txtCustpaperno.Text = getDataKeys("PAPERNO");
        txtCustphone.Text = getDataKeys("PHONENO");
        txtCustaddr.Text = getDataKeys("ADDRESS");
        txtEmail.Text = getDataKeys("EMAIL");
        txtOutbank.Text = getDataKeys("OUTBANK");
        txtOutacct.Text = getDataKeys("OUTACCT");
        txtStartcard.Text = getDataKeys("STARTCARDNO");
        txtEndcard.Text = getDataKeys("ENDCARDNO");
        string buyCardDate = getDataKeys("BUYCARDDATE");
        //更改日期格式
        if (Validation.isDate(buyCardDate, "yyyyMMdd"))
        {
            txtBuyCardDate.Text = buyCardDate.Substring(0, 4) + "-" + buyCardDate.Substring(4, 2) + "-" + buyCardDate.Substring(6, 2);

        }
        txtBuycardno.Text = getDataKeys("BUYCARDNUM");
        txtBuycardmoney.Text = getDataKeys("BUYCARDMONEY");
        txtchargemoney.Text = getDataKeys("CHARGEMONEY");
        selChargeSource.SelectedValue = getDataKeys("REMARK");

        selCompany.Items.Clear();
        selCompany.Items.Add(new ListItem(txtCompany.Text));

        btnRegModify.Enabled = true;
        btnRegDelete.Enabled = true;
    }

    public String getDataKeys(String keysname)
    {
        return gvResult.DataKeys[gvResult.SelectedIndex][keysname].ToString();
    }
    //清空输入项

    protected void clearBuyCardInfo(Boolean isClean)
    {
        hiddenID.Value = "";
        txtCusname.Text = "";
        txtCustpaperno.Text = "";
        txtCustphone.Text = "";
        txtCustaddr.Text = "";
        txtEmail.Text = "";
        txtOutbank.Text = "";
        txtOutacct.Text = "";
        txtStartcard.Text = "";
        txtEndcard.Text = "";
        txtBuyCardDate.Text = "";
        txtBuycardno.Text = "";
        txtBuycardmoney.Text = "";
        txtchargemoney.Text = "";
        selChargeSource.Text = "";

        if (isClean == true)
        {
            txtCompany.Text = "";
            txtComPaperno.Text = "";
            selCompany.Items.Clear();
            selComPapertype.Items.Clear();
        }
        selActerPapertype.Items.Clear();        

        ASHelper.initPaperTypeList(context, selPapertype);
        ASHelper.initPaperTypeList(context, selActerPapertype);
        selComPapertype.Items.Add(new ListItem("---请选择---", ""));
        selComPapertype.Items.Add(new ListItem("01:组织机构代码证", "01"));
        selComPapertype.Items.Add(new ListItem("02:企业营业执照", "02"));

        btnRegModify.Enabled = false;
        btnRegDelete.Enabled = false;
    }
}