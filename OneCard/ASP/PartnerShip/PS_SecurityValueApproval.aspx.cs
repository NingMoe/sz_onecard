using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Master;
using Common;
using TM;
using TDO.BalanceChannel;
using PDO.PartnerShip;
using TDO.UserManager;
using System.Collections;
using System.Data;

public partial class ASP_PartnerShip_PS_SecurityValueApproval : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            TMTableModule tmTMTableModule = new TMTableModule();
            //从行业编码表(TD_M_CALLINGNO)中读取数据


            TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
            TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), "S008100211", "TD_M_CALLING_ANDNO", null);

            //放入查询输入行业名称下拉列表中

            ControlDeal.SelectBoxFillWithCode(selCalling.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);
            selCorp.Items.Add(new ListItem("---请选择---", ""));
        }
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        ICollection dataView = CropQueryDataSource(); ;
        if (dataView.Count == 0)
        {
            gvComResult.DataSource = new DataTable();
            gvComResult.DataBind();
            gvComResult.SelectedIndex = -1;
            context.AddError("没有查询出任何记录");
            return;
        }
        //显示Gridview
        gvComResult.DataSource = dataView;
        gvComResult.DataBind();
    }
    public ICollection CropQueryDataSource()
    {
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
                    DataTable data = SPHelper.callPSQuery(context, "QueryUnitCorpApprovalInfo", selCalling.SelectedValue, selCorp.SelectedValue, dbalUnitNo);
                    return new DataView(data);
                }
                else if (HasOperPower("201010"))//如果是代理营业厅网点主管
                {
                    //如果是网点主管，能查询本部门的记录

                    DataTable data = SPHelper.callPSQuery(context, "QueryDeptCorpApprovalInfo", selCalling.SelectedValue, selCorp.SelectedValue, context.s_DepartID);
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
                    DataTable data = SPHelper.callPSQuery(context, "QueryStaffCorpApprovalInfo", selCalling.SelectedValue, selCorp.SelectedValue);
                    return new DataView(data);
                }
                else if (HasOperPower("201012")) //如果是部门主管，可以查询本部门的记录
                {
                    DataTable data = SPHelper.callPSQuery(context, "QueryDeptCorpApprovalInfo", selCalling.SelectedValue, selCorp.SelectedValue, context.s_DepartID);
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

            if (HasOperPower("201013")) //如果是公司主管，可以查询全部记录201013
            {
                DataTable data = SPHelper.callPSQuery(context, "QueryStaffCorpApprovalInfo", selCalling.SelectedValue, selCorp.SelectedValue);
                return new DataView(data);
            }
            else if (HasOperPower("201012")) //如果是部门主管，可以查询本部门的记录
            {
                DataTable data = SPHelper.callPSQuery(context, "QueryDeptCorpApprovalInfo", selCalling.SelectedValue, selCorp.SelectedValue, context.s_DepartID);
                return new DataView(data);
            }
            else
            {
                return null;  //既不是公司主管也不是部门主管

            }
        }


    }
    
    protected void gvComResult_Page(object sender, GridViewPageEventArgs e)
    {
        gvComResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
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
        bool ok = context.ExecuteSP("SP_PS_CORPAPPROVALSUBMIT");
        if (ok)
        {
            AddMessage("安全值审核通过成功");
        }
        //清空临时表
        clearTempTable(sessionID);
        btnQuery_Click(sender, e);
    }
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        string sessionID = Session.SessionID;
        ValidSubmit();
        if (context.hasError())
            return;
        FillTempTable(sessionID);
        context.SPOpen();
        context.AddField("p_sessionID").Value = sessionID;
        bool ok = context.ExecuteSP("SP_PS_CORPAPPROVALCANCEL");
        if (ok)
        {
            AddMessage("安全值审核作废成功");
        }
        //清空临时表
        clearTempTable(sessionID);
        btnQuery_Click(sender, e);
    }
    protected void selCalling_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择行业后,设置单位名称下拉列表值

        if (selCalling.SelectedValue == "")
        {
            selCorp.Items.Clear();
        }
        else
        {
            TMTableModule tmTMTableModule = new TMTableModule();
            //从单位编码表(TD_M_CORP)中读取数据，放入下拉列表中


            TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
            tdoTD_M_CORPIn.CALLINGNO = selCalling.SelectedValue;

            TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, "TD_M_CORP", null);
            ControlDeal.SelectBoxFillWithCode(selCorp.Items, tdoTD_M_CORPOutArr, "CORP", "CORPNO", true);
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
    /// <summary>
    /// 验证提交
    /// </summary>
    private void ValidSubmit()
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
    /// <summary>
    /// 数据插入临时表
    /// </summary>
    /// <param name="sessionID"></param>
    private void FillTempTable(string sessionID)
    {
        //记录入临时表
        context.DBOpen("Insert");
        
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