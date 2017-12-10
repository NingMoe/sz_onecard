using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using TM;
using TDO.UserManager;
using PDO.CashGift;
using Master;
/**********************************
 * 调配网点
 * 2013-2-26
 * shil
 * 初次编写
 * ********************************/

public partial class ASP_CashGift_CG_AssignedChange : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack == false)
        {
            //设置GridView绑定的DataTable
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
            gvResult.SelectedIndex = -1;

            //初始化日期

            txtStartDate.Text = DateTime.Today.AddMonths(-1).ToString("yyyyMMdd");
            txtEndDate.Text = DateTime.Today.ToString("yyyyMMdd");

            //初始化部门

            //TMTableModule tmTMTableModule = new TMTableModule();
            //TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
            //TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
            //ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
            //ControlDeal.SelectBoxFill(ddlDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);

            FIHelper.selectDeptHasArea(context, selDept, true);
            FIHelper.selectDeptHasArea(context, ddlDept, true);

            //初始化员工

            InitStaffList(ddlStaff, context.s_DepartID);
            InitStaffList(selStaff, "");
            //默认选中当前员工
            ddlDept.SelectedValue = context.s_DepartID;
            //ddlStaff.SelectedValue = context.s_UserID;
            //初始化礼金卡类型  add by youyue 2013/3/13
            InitCashCardSurfaceName();
        }
    }
    /// <summary>
    /// 初始化员工下拉选框
    /// </summary>
    /// <param name="ddl">控件名称</param>
    /// <param name="deptNo">部门编码</param>
    private void InitStaffList(DropDownList ddl, string deptNo)
    {
        if (deptNo == "")
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);
            ControlDeal.SelectBoxFill(ddl.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);

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
    /// <summary>
    /// 初始化礼金卡下拉选框  add by youyue 2013/3/13
    /// </summary>
    private void InitCashCardSurfaceName()
    {
        context.DBOpen("Select");
        string sql = @"SELECT  D.CARDSURFACENAME,D.CARDSURFACECODE FROM TD_M_CARDSURFACE D 
                            WHERE SUBSTR(D.CARDSURFACECODE,0,2)='05' AND D.USETAG='1'";
        DataTable table = context.ExecuteReader(sql);
        GroupCardHelper.fill(ddlCashType, table, true);
    }


    //部门选择事件
    protected void ddlDept_Change(object sender, EventArgs e)
    {
        InitStaffList(ddlStaff, ddlDept.SelectedValue);
    }
    //所属部门选择事件
    protected void selDept_Change(object sender, EventArgs e)
    {
        InitStaffList(selStaff, selDept.SelectedValue);
    }
    
    //gridview赋值

    private void queryRecycleGiftCard()
    {
        gvResult.DataSource = query();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }
    /// <summary>
    /// 查询
    /// </summary>
    /// <returns></returns>
    private ICollection query()
    {
        DataTable data = SPHelper.callQuery("SP_CG_Query", context, "AssignedChange", ddlDept.SelectedValue, ddlStaff.SelectedValue, 
            txtStartDate.Text.Trim(), txtEndDate.Text.Trim(), txtCardNum.Text.Trim(),ddlCashType.SelectedValue,context.s_DepartID);
        int num = data.Rows.Count;
        if(num>0)
        {
        lblNum.Text = data.Rows.Count.ToString(); //给页面上的数量赋值

        lblFirst.Text = data.Rows[0][0].ToString();//显示查询出的第一张数据卡号

        lblLast.Text = data.Rows[num - 1][0].ToString();//显示查询出的最后一张数据卡号

        }
        return new DataView(data);
    }
    /// <summary>
    /// 查询按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //查询输入校验
        if (!queryValidation()) return;

        queryRecycleGiftCard();
    }
    /// <summary>
    /// 查询有效性校验

    /// </summary>
    /// <returns></returns>
    protected bool queryValidation()
    {
        //对开始日期和结束日期的判断

        UserCardHelper.validateDateRange(context, txtStartDate, txtEndDate, false);

        return !(context.hasError());
    }
    /// <summary>
    /// 提交有效性校验

    /// </summary>
    /// <returns></returns>
    protected bool summitValidation()
    {
        //归属部门
        if (selDept.SelectedValue == "")
            context.AddError("A094570265:归属部门不能为空");

        //归属员工
        if (selStaff.SelectedValue == "")
            context.AddError("A094570265:归属部门不能为空");

        return !(context.hasError());
    }
    /// <summary>
    /// 提交按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSummit_Click(object sender, EventArgs e)
    {
        //提交有效性校验

        if (!summitValidation()) return;

        int checkednum = 0;
        ArrayList cardtypelist = new ArrayList();
        int type1 = 0,type2 = 0,type3 = 0,type4 = 0,type6 = 0, type9 = 0;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            HiddenField hf = (HiddenField)gvr.FindControl("hideCardType");//获取礼金卡类型

            if (cb != null && cb.Checked)
            {
                switch (gvResult.Rows[checkednum].Cells[2].Text.Substring(0,4))
                {
                    case "0501":
                        ++type1;
                        break;
                    case "0502":
                        ++type2;
                        break;
                    case "0503":
                        ++type3;
                        break;
                    case "0504":
                        ++type4;
                        break;
                    case "0506":
                        ++type6;
                        break;
                    case "0599":
                        ++type9;
                        break;
                }
                ++checkednum;
            }
        }
        ArrayList typeNum = new ArrayList();//统计确认提交的各种礼金卡的数量

        typeNum.Add(type1);
        typeNum.Add(type2);
        typeNum.Add(type3);
        typeNum.Add(type4);
        typeNum.Add(type6);
        typeNum.Add(type9);
        if (checkednum <= 0)
        {
            context.AddError("未选中任何行");
        }
        else
        {
            string cashcardtypeinfo = GetSubmitInfo(typeNum);//获取确认提交的礼金卡信息
            ScriptManager.RegisterStartupScript(this, this.GetType(), "AdjustScript", "submitConfirm('" + cashcardtypeinfo + "','" + selStaff.SelectedItem + "','" + selDept.SelectedItem + "');", true);
        }
    }
    /// <summary>
    /// 获取确认提交的礼金卡信息  add by youyue 2013/3/14
    /// </summary>
    /// <param name="arrayNum">各个种类的礼金卡数量</param>
    /// <returns>礼金卡信息</returns>
    private string GetSubmitInfo(ArrayList arrayNum)
    {
        string getSubmitInfo = string.Empty;
        ArrayList typeName = new ArrayList();
        typeName.Add("0501：利金卡");
        typeName.Add("0502：利金卡500面值");
        typeName.Add("0503：利金卡1000面值");
        typeName.Add("0504：利金卡不分面值");
        typeName.Add("0506：利金卡未启用");
        typeName.Add("0599：账户测试卡");
        for (int i = 0; i < 6;i++ )
        {
            if(arrayNum[i].ToString()!="0")
            {
                getSubmitInfo += typeName[i].ToString() + arrayNum[i].ToString()+"张" + "，";
            }
        }
        return getSubmitInfo;
    }
    
    /// <summary>
    /// 提交处理
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        //清空临时表信息

        clearTempTable();

        //选择回收的记录入临时表

        if (!RecordIntoTmp()) return;

        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        context.AddField("P_ASSIGNEDSTAFFNO").Value = selStaff.SelectedValue;
        context.AddField("P_ASSIGNEDDEPARTID").Value = selDept.SelectedValue;
        bool ok = context.ExecuteSP("SP_PB_GIFTASSIGNEDCHANGE");
        if (ok)
        {
            context.AddMessage("调配网点成功!");

            //刷新列表
            queryRecycleGiftCard();

        }

    }

    private void clearTempTable()//清空临时表

    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_ASSIGNEDCHANGE");
        context.DBCommit();
    }
    private bool RecordIntoTmp()
    {
        //选中记录入临时表
        context.DBOpen("Insert");

        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                //++count;
                context.ExecuteNonQuery("insert into TMP_ASSIGNEDCHANGE (CARDNO,OLDASSIGNEDSTAFFNO) values('" +
                     gvr.Cells[1].Text + "', '" + gvr.Cells[3].Text.Substring(0, 6) + "')");
            }
        }

        context.DBCommit();

        return true;
    }    
}