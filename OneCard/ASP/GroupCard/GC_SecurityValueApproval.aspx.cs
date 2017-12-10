using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using System.Data;
using Common;
using TDO.BusinessCode;
using TM;
using TDO.UserManager;

public partial class ASP_GroupCard_GC_SecurityValueApproval : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            hidCardType.Value = "combuycard";
            initLoad();
        }
        selectTab(this, this.GetType(), hidCardType);
    }
    //选择选项卡
    private void selectTab(Page page, Type type, HiddenField hidCardType)
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
        ASHelper.initPaperTypeList(context, selActerPapertype2);//从证件类型编码表(TD_M_PAPERTYPE)中读取数据，放入下拉列表中
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (hidCardType.Value.Equals("combuycard"))//查询单位购卡安全值待审核记录
        {
            //验证输入有效性

            
            if (!checkQueryValidation())
                return;
            ICollection dataView = queryComBuyCardReg();;
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

        }
        else  //查询个人购卡
        {
            //验证输入有效性

            if (!checkQueryValidation())
                return;

            //查询个人购卡安全值待审核记录
            ICollection dataView = queryPerBuyCardReg(); 
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
        }

    }
    protected ICollection queryComBuyCardReg()
    {
        //按权限查询单位购卡安全值提交记录

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
                    DataTable data = GroupCardHelper.callOrderQuery(context, "QueryUnitComBuyCardApprovalInfo", txtActername.Text.Trim(), selActerPapertype1.SelectedValue, txtActerPaperno.Text.Trim(), txtCompanyname.Text.Trim(), txtCompaperno.Text.Trim(), dbalUnitNo);
                    return new DataView(data);
                }
                else if (HasOperPower("201010"))//如果是代理营业厅网点主管
                {
                    //如果是网点主管，能查询本部门的记录

                    DataTable data = GroupCardHelper.callOrderQuery(context, "QueryDeptComBuyCardApprovalInfo", txtActername.Text.Trim(), selActerPapertype1.SelectedValue, txtActerPaperno.Text.Trim(), txtCompanyname.Text.Trim(), txtCompaperno.Text.Trim(), context.s_DepartID);
                    return new DataView(data);
                }
                else
                {
                    return null;  //既不是公司主管也不是部门主管

                }
            }
            else if (deptType == "0") //自营营业厅员工
            {
                if (HasOperPower("201013")) //如果是公司主管，可以查询全部记录
                {
                    DataTable data = GroupCardHelper.callOrderQuery(context, "QueryStaffComBuyCardApprovalInfo", txtActername.Text.Trim(), selActerPapertype1.SelectedValue, txtActerPaperno.Text.Trim(), txtCompanyname.Text.Trim(), txtCompaperno.Text.Trim());
                    return new DataView(data);
                }
                else if (HasOperPower("201012")) //如果是部门主管，可以查询本部门的记录
                {
                    DataTable data = GroupCardHelper.callOrderQuery(context, "QueryDeptComBuyCardApprovalInfo", txtActername.Text.Trim(), selActerPapertype1.SelectedValue, txtActerPaperno.Text.Trim(), txtCompanyname.Text.Trim(), txtCompaperno.Text.Trim(), context.s_DepartID);
                    return new DataView(data);
                }
                else
                {
                    return null;  //既不是公司主管也不是部门主管

                }
            }
            return null;
        }
        else
        {
            //如果没有记录，说明是自营营业厅

            if (HasOperPower("201013")) //如果是公司主管，可以查询全部记录
            {
                DataTable data = GroupCardHelper.callOrderQuery(context, "QueryStaffComBuyCardApprovalInfo", txtActername.Text.Trim(), selActerPapertype1.SelectedValue, txtActerPaperno.Text.Trim(), txtCompanyname.Text.Trim(), txtCompaperno.Text.Trim());
                return new DataView(data);
            }
            else if (HasOperPower("201012")) //如果是部门主管，可以查询本部门的记录
            {
                DataTable data = GroupCardHelper.callOrderQuery(context, "QueryDeptComBuyCardApprovalInfo", txtActername.Text.Trim(), selActerPapertype1.SelectedValue, txtActerPaperno.Text.Trim(), txtCompanyname.Text.Trim(), txtCompaperno.Text.Trim(), context.s_DepartID);
                return new DataView(data);
            }
            else   
            {
                return null;  //既不是公司主管也不是部门主管

            }
        }

    }
    private ICollection queryPerBuyCardReg()
    {
        //按权限查询个人购卡安全值提交记录

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
                    DataTable data = GroupCardHelper.callOrderQuery(context, "QueryUnitPerBuyCardApprovalInfo", txtActername2.Text.Trim(), selActerPapertype2.SelectedValue, txtActerPaperno2.Text.Trim(), dbalUnitNo);
                    return new DataView(data);
                }
                else if (HasOperPower("201010"))//如果是代理营业厅网点主管
                {
                    //如果是网点主管，能查询本部门的记录

                    DataTable data = GroupCardHelper.callOrderQuery(context, "QueryDeptPerBuyCardApprovalInfo", txtActername2.Text.Trim(), selActerPapertype2.SelectedValue, txtActerPaperno2.Text.Trim(), context.s_DepartID);
                    return new DataView(data);
                }
                else
                {
                    return null;

                }
            }
            else if (deptType == "0") //自营营业厅员工
            {
                if (HasOperPower("201013")) //如果是公司主管
                {
                    DataTable data = GroupCardHelper.callOrderQuery(context, "QueryStaffPerBuyCardApprovalInfo", txtActername2.Text.Trim(), selActerPapertype2.SelectedValue, txtActerPaperno2.Text.Trim());
                    return new DataView(data);
                }
                else if (HasOperPower("201012")) //如果是部门主管
                {
                    DataTable data = GroupCardHelper.callOrderQuery(context, "QueryDeptPerBuyCardApprovalInfo", txtActername2.Text.Trim(), selActerPapertype2.SelectedValue, txtActerPaperno2.Text.Trim(), context.s_DepartID);
                    return new DataView(data);
                }
                else  //既不是公司主管也不是部门主管
                {
                    return null;

                }
            }
            return null;
        }
        else
        {
            //如果没有记录，说明是自营营业厅

            if (HasOperPower("201013")) //如果是公司主管，可以查询全部记录
            {
                DataTable data = GroupCardHelper.callOrderQuery(context, "QueryStaffPerBuyCardApprovalInfo", txtActername2.Text.Trim(), selActerPapertype2.SelectedValue, txtActerPaperno2.Text.Trim());
                return new DataView(data);
            }
            else if (HasOperPower("201012")) //如果是部门主管，可以查询本部门的记录
            {
                DataTable data = GroupCardHelper.callOrderQuery(context, "QueryDeptPerBuyCardApprovalInfo", txtActername2.Text.Trim(), selActerPapertype2.SelectedValue, txtActerPaperno2.Text.Trim(), context.s_DepartID);
                return new DataView(data);
            }
            else  //既不是公司主管也不是部门主管
            {
                return null;

            }
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
            if (txtCompaperno.Text.Trim() != "")
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
    protected void gvPerResult_Page(object sender, GridViewPageEventArgs e)
    {
        gvPerResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
  
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

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        string sessionID = Session.SessionID;
        ValidSubmit();
        if (context.hasError())
            return;
        FillTempTable(sessionID);
        context.SPOpen();
        context.AddField("p_sessionID").Value = sessionID;
        if (hidCardType.Value.Equals("combuycard"))
        {
            context.AddField("p_type").Value = "1";//单位
        }
        else
        {
            context.AddField("p_type").Value = "2";//个人
        }
        
        bool ok = context.ExecuteSP("SP_GC_BuyCardApprovalSubmit");
        if (ok)
        {
            AddMessage("安全值审核通过成功");
        }
        //清空临时表
        clearTempTable(sessionID);
        btnQuery_Click(sender, e);
    }
    /// <summary>
    /// 验证提交
    /// </summary>
    private void ValidSubmit()
    {
        if (hidCardType.Value.Equals("combuycard"))//单位购卡
        {
            int count1 = 0;
            for (int index = 0; index < gvComResult.Rows.Count; index++)
            {
                CheckBox cb = (CheckBox)gvComResult.Rows[index].FindControl("chkCheck");
                if (cb != null && cb.Checked)
                {
                    ++count1;
                }

            }
            // 没有选中任何行，则返回错误
            if (count1 <= 0)
            {
                context.AddError("A004P03R01: 没有选中任何行");
            }
        }
        else
        {
            int count2 = 0;
            for (int index = 0; index < gvPerResult.Rows.Count; index++)
            {
                CheckBox cb = (CheckBox)gvPerResult.Rows[index].FindControl("chkCheck");
                if (cb != null && cb.Checked)
                {
                    ++count2;
                }

            }
            // 没有选中任何行，则返回错误
            if (count2 <= 0)
            {
                context.AddError("A004P03R02: 没有选中任何行");
            }
        }
    }
    //作废
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        string sessionID = Session.SessionID;
        ValidSubmit();
        if (context.hasError())
            return;
        FillTempTable(sessionID);
        context.SPOpen();
        context.AddField("p_sessionID").Value = sessionID;
        if (hidCardType.Value.Equals("combuycard"))
        {
            context.AddField("p_type").Value = "1";//单位
        }
        else
        {
            context.AddField("p_type").Value = "2";//个人
        }
        bool ok = context.ExecuteSP("SP_GC_BuyCardApprovalCancel");
        if (ok)
        {
            AddMessage("安全值审核作废成功");
        }
        //清空临时表
        clearTempTable(sessionID);
        btnQuery_Click(sender, e);
    }
    /// <summary>
    /// 数据插入临时表
    /// </summary>
    /// <param name="sessionID"></param>
    private void FillTempTable(string sessionID)
    {
        //记录入临时表
        context.DBOpen("Insert");
        if (hidCardType.Value.Equals("combuycard")) //单位购卡
        {
            for (int index = 0; index < gvComResult.Rows.Count; index++)
            {
                CheckBox cb = (CheckBox)gvComResult.Rows[index].FindControl("chkCheck");
                if (cb != null && cb.Checked)
                {
                    string id = gvComResult.Rows[index].Cells[1].Text.Trim();
                    //F0:ID，F1:SessionID
                    context.ExecuteNonQuery(@"insert into TMP_SECURITYVALUEAPPROVAL (f0,f1)
                                values('" + id + "','" + sessionID + "')");
                }
            }
        }
        else   //个人购卡
        {
            for (int index = 0; index < gvPerResult.Rows.Count; index++)
            {
                CheckBox cb = (CheckBox)gvPerResult.Rows[index].FindControl("chkCheck");
                if (cb != null && cb.Checked)
                {
                    string id = gvPerResult.Rows[index].Cells[1].Text.Trim();
                    //F0:ID，F1:SessionID
                    context.ExecuteNonQuery(@"insert into TMP_SECURITYVALUEAPPROVAL (f0,f1)
                                values('" + id + "','" + sessionID + "')");
                }
            }
        }
        
        context.DBCommit();


    }
    /// <summary>
    /// 清空临时表
    /// </summary>
    private void clearTempTable(string sessionID)
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_SECURITYVALUEAPPROVAL where f1='" + sessionID + "'");
        context.DBCommit();
    }
}