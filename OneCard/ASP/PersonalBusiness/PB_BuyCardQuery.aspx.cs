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
using TDO.UserManager;

public partial class ASP_PersonalBusiness_PB_BuyCardQuery : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {            
            gvResult.DataSource = new DataView();
            gvResult.DataBind();
            gvResultindiInfo.DataSource = new DataView();
            gvResultindiInfo.DataBind();
        }
    }    

    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        if (ddlSO.SelectedIndex == 0)
        {
            //单位购卡信息
            gvResult.PageIndex = e.NewPageIndex;
            gvResult.DataSource = CreateRoleQueryDataSource(ddlSO.SelectedIndex);
            gvResult.DataBind();            
        }
        else
        {
            //个人购卡信息
            gvResultindiInfo.PageIndex = e.NewPageIndex;
            gvResultindiInfo.DataSource = CreateRoleQueryDataSource(ddlSO.SelectedIndex);
            gvResultindiInfo.DataBind();
        }
    }

    private bool QueryValidation()
    {
        
        DateTime StartDate = new DateTime();
        DateTime EndDate = new DateTime();
        if (txtStartDate.Text.Trim() != "")
        {
            StartDate = Convert.ToDateTime(txtStartDate.Text.Trim().Substring(0, 4) + "-" + txtStartDate.Text.Trim().Substring(4, 2) + "-" + txtStartDate.Text.Trim().Substring(6, 2));
        }
        if (txtEndDate.Text.Trim() != "")
        {
            EndDate = Convert.ToDateTime(txtEndDate.Text.Trim().Substring(0, 4) + "-" + txtEndDate.Text.Trim().Substring(4, 2) + "-" + txtEndDate.Text.Trim().Substring(6, 2));
        }

        //验证"交易起始日期"是否小于"交易终止日期"
        if (txtStartDate.Text.Trim() != "" && txtEndDate.Text.Trim() != "" && StartDate >= EndDate)
        {
            context.AddError("A001003116");
        }
        return !(context.hasError());
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {        
        //验证输入框
        if (!QueryValidation())
        {
            return;
        }
        if (ddlSO.SelectedIndex == 0)
        {
            //单位购卡信息            
            gvResult.DataSource = CreateRoleQueryDataSource(ddlSO.SelectedIndex);
            gvResult.DataBind();

            gvResultindiInfo.DataSource = new DataView();
            gvResultindiInfo.DataBind();
        }
        else
        {
            //个人购卡信息            
            gvResultindiInfo.DataSource = CreateRoleQueryDataSource(ddlSO.SelectedIndex);
            gvResultindiInfo.DataBind();

            gvResult.DataSource = new DataView();
            gvResult.DataBind();
        }        
    }

    public ICollection CreateRoleQueryDataSource(int index)
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
                if (HasOperPower("201009"))
                {
                    //如果是全网点主管，则可以查询结算单元下所有部门的记录情况
                    if (index == 0)
                    {
                        //单位购卡信息查询
                        DataTable data = SPHelper.callPBQuery(context, "QureyUnitCOMBUYCARD", txtDeptName.Text.Trim(), txtDeptID.Text.Trim(), txtManaName.Text.Trim(), txtManaID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), dbalUnitNo);
                        gvResult.Visible = true;
                        gvResultindiInfo.Visible = false;
                        return new DataView(data);
                    }

                    //个人购卡信息查询
                    DataTable data2 = SPHelper.callPBQuery(context, "QureyUnitPERBUYCARD", txtName.Text.Trim(), txtID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), dbalUnitNo);
                    gvResult.Visible = false;
                    gvResultindiInfo.Visible = true;
                    return new DataView(data2);
                }
                else if (HasOperPower("201010"))//如果是代理营业厅网点主管,能查询本部门的记录
                {
                    if (index == 0)
                    {
                        //单位购卡信息查询
                        DataTable data = SPHelper.callPBQuery(context, "QureyDeptCOMBUYCARD", txtDeptName.Text.Trim(), txtDeptID.Text.Trim(), txtManaName.Text.Trim(), txtManaID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), context.s_DepartID);
                        gvResult.Visible = true;
                        gvResultindiInfo.Visible = false;
                        return new DataView(data);
                    }

                    //个人购卡信息查询
                    DataTable data2 = SPHelper.callPBQuery(context, "QureyDeptPERBUYCARD", txtName.Text.Trim(), txtID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), context.s_DepartID);
                    gvResult.Visible = false;
                    gvResultindiInfo.Visible = true;
                    return new DataView(data2);
                }
                //既不是全网点主管也不是网点主管，只能查询到本人的记录，uodate by shil,20120604
                if (index == 0)
                {
                    //单位购卡信息查询
                    DataTable data = SPHelper.callPBQuery(context, "QureyStaffCOMBUYCARD", txtDeptName.Text.Trim(), txtDeptID.Text.Trim(), txtManaName.Text.Trim(), txtManaID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), context.s_UserID);
                    gvResult.Visible = true;
                    gvResultindiInfo.Visible = false;
                    return new DataView(data);
                }

                //个人购卡信息查询
                DataTable data1 = SPHelper.callPBQuery(context, "QureyStaffPERBUYCARD", txtName.Text.Trim(), txtID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), context.s_UserID);
                gvResult.Visible = false;
                gvResultindiInfo.Visible = true;
                return new DataView(data1);
            }
            else if (deptType == "0") //自营营业厅员工
            {
                if (HasOperPower("201013")) //如果是公司主管，可以查询全部记录，add by shil,20120604
                {
                    if (index == 0)
                    {
                        //单位购卡信息查询
                        DataTable data = SPHelper.callPBQuery(context, "QureyStaffCOMBUYCARD", txtDeptName.Text.Trim(), txtDeptID.Text.Trim(), txtManaName.Text.Trim(), txtManaID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim());
                        gvResult.Visible = true;
                        gvResultindiInfo.Visible = false;
                        return new DataView(data);
                    }

                    //个人购卡信息查询
                    DataTable data2 = SPHelper.callPBQuery(context, "QureyStaffPERBUYCARD", txtName.Text.Trim(), txtID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim());
                    gvResult.Visible = false;
                    gvResultindiInfo.Visible = true;
                    return new DataView(data2);
                }
                else if (HasOperPower("201012")) //如果是部门主管，可以查询本部门的记录，add by shil,20120604
                {
                    if (index == 0)
                    {
                        //单位购卡信息查询
                        DataTable data = SPHelper.callPBQuery(context, "QureyDeptCOMBUYCARD", txtDeptName.Text.Trim(), txtDeptID.Text.Trim(), txtManaName.Text.Trim(), txtManaID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), context.s_DepartID);
                        gvResult.Visible = true;
                        gvResultindiInfo.Visible = false;
                        return new DataView(data);
                    }

                    //个人购卡信息查询
                    DataTable data2 = SPHelper.callPBQuery(context, "QureyDeptPERBUYCARD", txtName.Text.Trim(), txtID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), context.s_DepartID);
                    gvResult.Visible = false;
                    gvResultindiInfo.Visible = true;
                    return new DataView(data2);
                }
                //既不是公司主管也不是部门主管，只能查询到本人的记录
                if (index == 0)
                {
                    //单位购卡信息查询
                    DataTable data = SPHelper.callPBQuery(context, "QureyStaffCOMBUYCARD", txtDeptName.Text.Trim(), txtDeptID.Text.Trim(), txtManaName.Text.Trim(), txtManaID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), context.s_UserID);
                    gvResult.Visible = true;
                    gvResultindiInfo.Visible = false;
                    return new DataView(data);
                }

                //个人购卡信息查询
                DataTable data1 = SPHelper.callPBQuery(context, "QureyStaffPERBUYCARD", txtName.Text.Trim(), txtID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), context.s_UserID);
                gvResult.Visible = false;
                gvResultindiInfo.Visible = true;
                return new DataView(data1);
            }
            return null;
        }
        else
        {
            //如果没有记录，说明是自营营业厅

            if (HasOperPower("201013")) //如果是公司主管，可以查询全部记录，add by shil,20120604
            {
                if (index == 0)
                {
                    //单位购卡信息查询
                    DataTable data = SPHelper.callPBQuery(context, "QureyStaffCOMBUYCARD", txtDeptName.Text.Trim(), txtDeptID.Text.Trim(), txtManaName.Text.Trim(), txtManaID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim());
                    gvResult.Visible = true;
                    gvResultindiInfo.Visible = false;
                    return new DataView(data);
                }

                //个人购卡信息查询
                DataTable data2 = SPHelper.callPBQuery(context, "QureyStaffPERBUYCARD", txtName.Text.Trim(), txtID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim());
                gvResult.Visible = false;
                gvResultindiInfo.Visible = true;
                return new DataView(data2);
            }
            else if (HasOperPower("201012")) //如果是部门主管，可以查询本部门的记录，add by shil,20120604
            {
                if (index == 0)
                {
                    //单位购卡信息查询
                    DataTable data = SPHelper.callPBQuery(context, "QureyDeptCOMBUYCARD", txtDeptName.Text.Trim(), txtDeptID.Text.Trim(), txtManaName.Text.Trim(), txtManaID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), context.s_DepartID);
                    gvResult.Visible = true;
                    gvResultindiInfo.Visible = false;
                    return new DataView(data);
                }

                //个人购卡信息查询
                DataTable data2 = SPHelper.callPBQuery(context, "QureyDeptPERBUYCARD", txtName.Text.Trim(), txtID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), context.s_DepartID);
                gvResult.Visible = false;
                gvResultindiInfo.Visible = true;
                return new DataView(data2);
            }
            //既不是公司主管也不是部门主管，只能查询到本人的记录
            if (index == 0)
            {
                //单位购卡信息查询
                DataTable data = SPHelper.callPBQuery(context, "QureyStaffCOMBUYCARD", txtDeptName.Text.Trim(), txtDeptID.Text.Trim(), txtManaName.Text.Trim(), txtManaID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), context.s_UserID);
                gvResult.Visible = true;
                gvResultindiInfo.Visible = false;
                return new DataView(data);
            }

            //个人购卡信息查询
            DataTable data1 = SPHelper.callPBQuery(context, "QureyStaffPERBUYCARD", txtName.Text.Trim(), txtID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), context.s_UserID);
            gvResult.Visible = false;
            gvResultindiInfo.Visible = true;
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

    //public ICollection CreateRoleQueryDataSource(int index)
    //{        
    //    DataTable data = new DataTable();
    //    if (index == 0)
    //    {
    //        //单位购卡信息查询
    //        data = SPHelper.callPBQuery(context, "QureyCOMBUYCARD", txtDeptName.Text.Trim(), txtDeptID.Text.Trim(), txtManaName.Text.Trim(), txtManaID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim());
    //        gvResult.Visible = true;
    //        gvResultindiInfo.Visible = false;
    //    }
    //    else
    //    {
    //        //个人购卡信息查询
    //        data = SPHelper.callPBQuery(context, "QureyPERBUYCARD", txtName.Text.Trim(), txtID.Text.Trim(), txtStartDate.Text.Trim(), txtEndDate.Text.Trim());
    //        gvResult.Visible = false;
    //        gvResultindiInfo.Visible = true;
    //    }

    //    DataView dataView = new DataView(data);
    //    return dataView;
    //}

    protected void ddlSO_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (ddlSO.SelectedIndex == 0)
        {
            //单位购卡信息查询
            gvResult.Visible = true;
            gvResultindiInfo.Visible = false;
            indiInfo.Visible=false;
            deptInfo1.Visible=true;
            deptInfo2.Visible=true;
        }
        else
        {
            //个人购卡信息查询
            gvResult.Visible = false;
            gvResultindiInfo.Visible = true;
            indiInfo.Visible=true;
            deptInfo1.Visible = false;
            deptInfo2.Visible = false;            
        }        
    }
}
