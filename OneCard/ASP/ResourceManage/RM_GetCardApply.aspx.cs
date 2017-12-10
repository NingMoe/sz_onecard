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
using Master;
using Common;
using TDO.UserManager;
using TM;
/***************************************************************
 * 功能名: 资源管理领卡申请
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/07/18    殷华荣			初次开发
 ****************************************************************/
public partial class ASP_ResourceManage_RM_GetCardApply : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //判断是否有用户卡分配权限
            if (!HasOperPower("201001"))
            {
                context.AddError("用户没有操作权限,请联系管理员");
                btnQuery.Enabled = false;
                btnBlackAdd.Enabled = false;
                //btnPrint.Enabled = false;
                return;
            }
            if (!HasOperPower("201014")) //有库管理员权限
            {
                selDept.Enabled = false;
                selStaff.Enabled = false;
            }

            //初始化日期
            txtFromDate.Text = DateTime.Now.AddMonths(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Now.ToString("yyyyMMdd");

            if (HasOperPower("201008"))//全部网点主管
            {
                //初始化部门
                TMTableModule tmTMTableModule = new TMTableModule();
                TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
                TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
                ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
                selDept.SelectedValue = context.s_DepartID;
                InitStaffList(context.s_DepartID);
                selStaff.SelectedValue = context.s_UserID;
            }
            else if (HasOperPower("201007"))//网点主管
            {
                selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
                selDept.SelectedValue = context.s_DepartID;
                selDept.Enabled = false;

                InitStaffList(context.s_DepartID);
                selStaff.SelectedValue = context.s_UserID;
            }
            else if (HasOperPower("201009"))//代理全网点主管 add by liuhe20120214添加对代理的权限处理
            {
                context.DBOpen("Select");
                string dBalunitNo = DeptBalunitHelper.GetDbalunitNo(context);
                string sql = @"SELECT  D.DEPARTNAME,D.DEPARTNO FROM TD_DEPTBAL_RELATION R,TD_M_INSIDEDEPART D 
                            WHERE R.DEPARTNO=D.DEPARTNO AND R.DBALUNITNO='" + dBalunitNo + "' AND R.USETAG='1'";
                DataTable table = context.ExecuteReader(sql);
                GroupCardHelper.fill(selDept, table, true);

                selDept.SelectedValue = context.s_DepartID;
                InitStaffList(context.s_DepartID);
                selStaff.SelectedValue = context.s_UserID;
            }
            else if (HasOperPower("201010"))//代理网点主管
            {
                selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
                selDept.SelectedValue = context.s_DepartID;
                selDept.Enabled = false;

                InitStaffList(context.s_DepartID);
                selStaff.SelectedValue = context.s_UserID;
            }
            else//网点营业员
            {
                selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
                selDept.SelectedValue = context.s_DepartID;
                selDept.Enabled = false;

                selStaff.Items.Add(new ListItem(context.s_UserID + ":" + context.s_UserName, context.s_UserID));
                selStaff.SelectedValue = context.s_UserID;
                selStaff.Enabled = false;
            }

            //初始化审核状态
            initddlApprovalState(ddlApprovalState);

            hidCardType.Value = "usecard";

            //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据，放入下拉列表中
            UserCardHelper.selectCardType(context, selCardType, true);

            //从IC卡卡面编码表(TD_M_CARDSURFACE)中读取数据，放入下拉列表中
            ResourceManageHelper.selectCardFace(context, selFaceType, true, selCardType.SelectedValue);

            //初始化充值卡面额
            ResourceManageHelper.selCardMoney(context, ddlChargeCardValue, true);
        }

        ResourceManageHelper.selectTab(this, this.GetType(), hidCardType);
    }
    //初始化审核状态
    public static void initddlApprovalState(DropDownList lst)
    {
        lst.Items.Add(new ListItem("0:待审核", "0"));
        lst.Items.Add(new ListItem("1:审核通过", "1"));
        lst.Items.Add(new ListItem("2:审核作废", "2"));
        lst.Items.Add(new ListItem("3:部分领卡", "3"));
        lst.Items.Add(new ListItem("4:完成领卡", "4"));
    }

    //判断是否有指定权限
    private bool HasOperPower(string powerCode)
    {
        //TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
        string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
        DataTable dataSupply = tm.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
        if (dataSupply.Rows.Count > 0)
            return true;
        else
            return false;
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //验证日期
        ResourceManageHelper.checkDate(context, txtFromDate, txtToDate, "开始日期范围起始值格式必须为yyyyMMdd",
            "结束日期范围终止值格式必须为yyyyMMdd", "开始日期不能大于结束日期");
        if (context.hasError())
        {
            return;
        }
        DataTable data;
        string dept = "";
        if (selDept.SelectedIndex > 0)
        {
            dept = selDept.SelectedValue;
        }
        string staff = "";
        if (selStaff.SelectedIndex > 0)
        {
            staff = selStaff.SelectedValue;
        }
        if (hidCardType.Value == "usecard")
        {
            data = ResourceManageHelper.callQuery(context, "USECARD_ORDER", ddlApprovalState.SelectedValue,
                txtFromDate.Text, txtToDate.Text, staff, dept);

            UserCardHelper.resetData(gvResultUseCard, data);
        }
        else
        {
            data = ResourceManageHelper.callQuery(context, "CHARGECARD_ORDER", ddlApprovalState.SelectedValue,
                txtFromDate.Text, txtToDate.Text, staff, dept);
            UserCardHelper.resetData(gvResultChargeCard, data);
        }
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        
    }

    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selDept.SelectedValue);
        
    }

    /// <summary>
    /// 查询条件卡片类型变更事件，更新卡片类型对应的卡面类型
    /// </summary>
    protected void selCardType_change(object sender, EventArgs e)
    {
        //卡面类型
        selFaceType.Items.Clear();
        ResourceManageHelper.selectCardFace(context, selFaceType, true, selCardType.SelectedValue);
    }

    //初始化员工列表
    private void InitStaffList(string deptNo)
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
                GroupCardHelper.fill(selStaff, table, true);

                return;
            }

            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);
            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
            selStaff.SelectedValue = context.s_UserID;
        }
        else
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
    }
    //提交
    protected void btnApply_Click(object sender, EventArgs e)
    {
        ValidInput();
        if (context.hasError())
        {
            return;
        }
        //用户卡
        if (hidCardType.Value == "usecard")
        {
            context.SPOpen();
            context.AddField("p_USEWAY").Value = txtUseWay.Text.Trim();
            context.AddField("p_CARDTYPECODE").Value = selCardType.SelectedValue;
            context.AddField("p_CARDSURFACECODE").Value = selFaceType.SelectedValue;
            context.AddField("p_APPLYGETNUM", "Int32").Value = Convert.ToInt32(txtApplyNum.Text.Trim());
            context.AddField("P_REMARK").Value = txtRemark.Text;
            context.AddField("p_getCardOrderID", "String", "output", "18", null);
            bool ok = context.ExecuteSP("SP_RM_USECARDAPPLYSUBMIT");
            if (ok)
            {
                AddMessage("提交成功");
            }
        }
        else //充值卡
        {
            context.SPOpen();
            context.AddField("p_USEWAY").Value = txtUseWay.Text.Trim();
            context.AddField("p_CARDVALUECODE").Value = ddlChargeCardValue.SelectedValue;
            context.AddField("p_APPLYGETNUM", "Int32").Value = Convert.ToInt32(txtApplyNum.Text.Trim());
            context.AddField("P_REMARK").Value = txtRemark.Text;
            context.AddField("p_getCardOrderID", "String", "output", "18", null);
            bool ok = context.ExecuteSP("SP_RM_CHARGECARDAPPLYSUBMIT");
            if (ok)
            {
                AddMessage("提交成功");
            }
        }
        
    }

    //验证输入
    private void ValidInput()
    {
        if (hidCardType.Value == "usecard")
        {
            if (selCardType.SelectedIndex < 1) //卡片类型必选
            {
                context.AddError("请选择卡片类型", selCardType);
            }
            if (selFaceType.SelectedIndex < 1) //卡面类型必选
            {
                context.AddError("请选择卡面类型", selFaceType);
            }
        }
        else
        {
            if (ddlChargeCardValue.SelectedIndex < 1) //面额必选
            {
                context.AddError("请选择面额", ddlChargeCardValue);
            }
        }
        if (txtApplyNum.Text.Trim().Length < 1) //领用数量必选
        {
            context.AddError("请填写领用数量", txtApplyNum);
        }
        else
        {
            if (txtApplyNum.Text.Trim().Equals("0"))
            {
                context.AddError("领用数量不能为零",txtApplyNum);
            }
            else if(!Validation.isNum(txtApplyNum.Text.Trim())) 
            {
                context.AddError("领用数量必须是数字", txtApplyNum);
            }
        }
        if (txtUseWay.Text.Trim().Length < 1)
        {
            context.AddError("请填写用途", txtUseWay);
        }
        else
        {
            if (txtUseWay.Text.Trim().Length > 50) //用途不超过50个汉字
            {
                context.AddError("用途长度不能超过50个汉字", txtUseWay);
            }
        }
        if (txtRemark.Text.Trim().Length > 50)
        {
            context.AddError("备注长度不能超过50个汉字", txtRemark);
        }
    }
    

    private void showNonDataGridView()
    {
        gvResultUseCard.DataSource = new DataTable();
        gvResultUseCard.DataBind();
        gvResultChargeCard.DataSource = new DataTable();
        gvResultChargeCard.DataBind();
    }

    protected void gvResultUseCard_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResultUseCard.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    protected void gvResultChargeCard_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResultChargeCard.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    protected void selFaceType_change(object sender, EventArgs e)
    {
        string sql = "";
        sql += "select nvl(count(a.cardno),0) total from TL_R_ICUSER a "
            + " where a.RESSTATECODE = '00' "
            + " and substr(a.cardno,5,4) = '" + selFaceType.SelectedValue + "'";
        context.DBOpen("Select");
        DataTable cardfaceNumData = context.ExecuteReader(sql);

        int stockleft = Convert.ToInt32(cardfaceNumData.Rows[0]["total"].ToString());

        if (stockleft <= 0)
        {
            context.AddMessage("此卡面的卡暂无库存！");
        }
    }
    protected void ddlChargeCardValue_change(object sender, EventArgs e)
    {
        //string sql = "";
        //sql += " select count(a.XFCARDNO) total from TD_XFC_INITCARD a "
        //    + " where a.CARDSTATECODE = '2' "
        //    + " and a.VALUECODE = '" + ddlChargeCardValue.SelectedValue + "'";
        //context.DBOpen("Select");
        //DataTable valueNumData = context.ExecuteReader(sql);

        DataTable valueNumData = ResourceManageHelper.callQuery(context, "queryCardValueNum", ddlChargeCardValue.SelectedValue);
        int stockleft = Convert.ToInt32(valueNumData.Rows[0]["total"].ToString());

        if (stockleft <= 0)
        {
            context.AddMessage("此面值的充值卡暂无库存！");
        }
    }
}