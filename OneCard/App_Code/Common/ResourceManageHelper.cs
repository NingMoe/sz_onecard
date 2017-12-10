using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using PDO.ResourceManage;
using System.IO;
using Master;
using Common;
using System.Drawing;

/// <summary>
///卡片下单管理帮助类
/// </summary>
public class ResourceManageHelper : Master.Master
{
    public ResourceManageHelper()
    {
        //
        //TODO: 在此处添加构造函数逻辑
        //
    }

    //选择选项卡
    public static void selectTab(Page page, Type type, HiddenField hidCardType)
    {
        if (hidCardType.Value.Equals("usecard"))
            ScriptManager.RegisterStartupScript(page, type, "selectTabScript", "SelectUseCard();", true);
        else
            ScriptManager.RegisterStartupScript(page, type, "selectTabScript", "SelectChargeCard();", true);
    }
    /// <summary>
    /// 创建注释
    /// 创建标识：石磊 2012-07-20
    /// 方法描述：清除列表中未查出结果但是显示的“：”
    /// 使用的表：
    /// 使用的视图：
    /// 使用的存储过程：
    /// </summary>
    /// <param name="e">GridView行事件</param>
    /// <returns></returns>
    public static void ClearRowDataBound(GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            for (int i = 0; i < e.Row.Cells.Count; ++i)
            {
                if (e.Row.Cells[i].Text.Trim().Equals(":"))
                {
                    e.Row.Cells[i].Text = "";
                }
            }
        }
    }

    //从金额参数表（TP_XFC_CARDVALUE）中读取数据，放入下拉框中
    public static void selCardMoney(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "TP_XFC_CARDVALUE");
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S094780001: 初始化金额参数列表失败");
        }
    }

    //从IC卡卡面编码表(TD_M_CARDSURFACE)中读取数据，放入下拉列表中

    public static void selectCardFace(CmnContext context, DropDownList ddl, bool empty, params string[] vars)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "TD_M_CARDSURFACE", vars);
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S002P01I04: 初始化IC卡卡面类型列表失败");
        }
    }

    //从金额参数表（TP_XFC_CARDVALUE）中读取过滤数据，放入下拉框中
    public static void selCardMoneySelect(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "TP_XFC_CARDVALUESELECT");
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S094780001: 初始化金额参数列表失败");
        }
    }

    //从制卡文件名表(TF_SYN_CARDFILE) 中读取数据放入下拉框
    public static void selFileNameSelect(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", "99"));

        DataTable dataTable = callQuery(context, "GETFILENAME");

        if (dataTable.Rows.Count == 0)
        {
            return;
        }

        Object[] itemArray;
        ListItem li;
        for (int i = 0; i < dataTable.Rows.Count; ++i)
        {
            itemArray = dataTable.Rows[i].ItemArray;
            li = new ListItem(itemArray[0].ToString(), itemArray[1].ToString());
            ddl.Items.Add(li);
        }

        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S094780001: 初始化金额参数列表失败");
        }
    }

    /// <summary>
    /// 创建注释
    /// 创建标识：石磊 2012-08-13
    /// 方法描述：校验用户卡起始卡号和结束卡号
    /// 使用的表：
    /// 使用的视图：
    /// 使用的存储过程：
    /// </summary>
    /// <param name="context">上下文环境</param>
    /// <param name="txtFromCardNo">起始卡号</param>
    /// <param name="txtToCardNo">结束卡号</param>
    /// <param name="required">是否做为空校验</param>
    /// <param name="checkRange">是否做数量校验</param>
    /// <returns></returns>
    public static void validateUseCardNoRange(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo,
        bool required, bool checkRange)
    {
        Validation valid = new Validation(context);
        long fromCard = -1, toCard = -1;
        long quantity = 0;

        //对起始卡号进行非空、长度、数字检验
        bool b1 = required
            ? valid.notEmpty(txtFromCardNo, "A095470150: 起始卡号不能为空")                // 起始卡号不能为空
            : !Validation.isEmpty(txtFromCardNo);
        if (b1) b1 = valid.fixedLength(txtFromCardNo, 16, "A0954701051: 起始卡号长度必须是16位"); // 起始卡号长度必须是16位

        if (b1) fromCard = valid.beNumber(txtFromCardNo, "A0954701052: 起始卡号必须是数字");  // 起始卡号必须是数

        //对终止卡号进行非空、长度、数字检验

        txtToCardNo.Text = txtToCardNo.Text.Trim();
        if (txtToCardNo.Text.Length == 0 && !context.hasError())
        {
            txtToCardNo.Text = txtFromCardNo.Text;
        }

        bool b2 = required
           ? valid.notEmpty(txtToCardNo, "A095470153: 终止卡号不能为空")                 // 终止卡号不能为空
           : !Validation.isEmpty(txtToCardNo);
        if (b2) b2 = valid.fixedLength(txtToCardNo, 16, "A0954701054: 终止卡号必须是16位"); // 终止卡号长度必须是16位

        if (b2) toCard = valid.beNumber(txtToCardNo, "A0954701055: 终止卡号必须是数字");    // 终止卡号必须是数

        if (fromCard >= 0 && toCard >= 0)
        {
            quantity = toCard - fromCard + 1;
            b2 = valid.check(quantity > 0, "A094570156: 起始卡号不能大于终止卡号");               // 终止卡号不能小于起始卡号

            if (checkRange)
            {
                if (b2) valid.check(quantity <= 500000, "A095470120: 终止卡号不能超过起始卡号500000");        // 终止卡号不能超过起始卡号500000以上
            }
        }
    }
    /// <summary>
    /// 创建注释
    /// 创建标识：石磊 2012-08-13
    /// 方法描述：校验充值卡起始卡号和结束卡号的输入有效性(是否为空，非空时是否长度14与英数）
    /// 使用的表：
    /// 使用的视图：
    /// 使用的存储过程：
    /// </summary>
    /// <param name="context">上下文环境</param>
    /// <param name="txtFromCardNo">起始卡号</param>
    /// <param name="txtToCardNo">结束卡号</param>
    /// <param name="required">是否做为空校验</param>
    /// <returns></returns>
    public static void validateChargeCardNoRange(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo,
        bool required)
    {
        Validation valid = new Validation(context);
        long fromCard = -1, toCard = -1;

        //对起始卡号进行非空、长度、英数检验


        bool b1 = required
            ? valid.notEmpty(txtFromCardNo, "A095470157: 起始卡号不能为空")
            : !Validation.isEmpty(txtFromCardNo);
        if (b1) b1 = valid.fixedLength(txtFromCardNo, 14, "A095470158: 起始卡号长度必须是14位");
        if (b1) ChargeCardHelper.validateCardNo(context, txtFromCardNo, "A095470159: 起始卡号格式不正确");

        //对终止卡号进行非空、长度、英数检验

        txtToCardNo.Text = txtToCardNo.Text.Trim();
        if (txtToCardNo.Text.Length == 0 && !context.hasError())
        {
            txtToCardNo.Text = txtFromCardNo.Text;
        }

        bool b2 = required
            ? valid.notEmpty(txtToCardNo, "A095470160: 终止卡号不能为空")
             : !Validation.isEmpty(txtToCardNo);
        if (b2) b2 = valid.fixedLength(txtToCardNo, 14, "A095470161: 终止卡号长度必须是14位");
        if (b2) ChargeCardHelper.validateCardNo(context, txtToCardNo, "A095470162: 终止卡号格式不正确");

        if (context.hasError())
        {
            return;
        }

        if (b1)
            fromCard = Convert.ToInt64(txtFromCardNo.Text.Substring(6, 8));

        if (b2)
            toCard = Convert.ToInt64(txtToCardNo.Text.Substring(6, 8));
        long quantity = 0;
        // 0 <= 终止卡号-起始卡号 <= 500000
        if (fromCard >= 0 && toCard >= 0)
        {
            quantity = toCard - fromCard + 1;
            b1 = valid.check(quantity > 0, "A094570163: 终止卡号不能小于起始卡号");
            if (b1) valid.check(quantity <= 500000, "A095470121: 终止卡号不能超过起始卡号500000以上");
        }

    }
    /// <summary>
    /// 创建注释
    /// 创建标识：石磊 2012-07-20
    /// 方法描述：从通用编码表中初始化卡面确认方式
    /// 使用的表：
    /// 使用的视图：
    /// 使用的存储过程：SP_RM_Query
    /// </summary>
    /// <param name="context">上下文环境</param>
    /// <param name="ddl">下拉选框</param>
    /// <param name="empty">是否附加空选项---请选择---，true附加，false不附加</param>
    /// <returns></returns>
    public static void selCardFaceAffirmWay(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "InitCardFaceAffirmWay");
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("初始化卡面确认方式失败");
        }
    }
    /// <summary>
    /// 创建注释
    /// 创建标识：石磊 2012-07-20
    /// 方法描述：通过卡类型查询卡面类型
    /// 使用的表：
    /// 使用的视图：
    /// 使用的存储过程：SP_RM_Query
    /// </summary>
    /// <param name="context">上下文环境</param>
    /// <param name="ddl">下拉选框</param>
    /// <param name="empty">是否附加空选项---请选择---，true附加，false不附加</param>
    /// <param name="vars">查询条件的输入参数</param>
    /// <returns></returns>
    public static void selFaceType(CmnContext context, DropDownList ddl, bool empty, params string[] vars)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "queryCardFaceByCardType", vars);
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("未找到对应的卡面类型");
        }
    }
    /// <summary>
    /// 创建注释
    /// 创建标识：石磊 2012-07-20
    /// 方法描述：校验日期有效性
    /// 使用的表：
    /// 使用的视图：
    /// 使用的存储过程：
    /// </summary>
    /// <param name="context">上下文环境</param>
    /// <param name="StartDate">开始日期</param>
    /// <param name="EndDate">结束日期</param>
    /// <param name="errorcode">错误编码</param>
    /// <returns></returns>
    public static void checkDate(CmnContext context, TextBox StartDate, TextBox EndDate, params string[] errorcode)
    {
        Validation valid = new Validation(context);

        //校验交易开始日期，交易结束日期
        bool b1 = Validation.isEmpty(StartDate);
        bool b2 = Validation.isEmpty(EndDate);
        DateTime? fromDate = null, toDate = null;

        if (!b1)
        {
            //开始日期是否符合日期格式
            fromDate = valid.beDate(StartDate, errorcode[0]);
        }
        if (!b2)
        {
            //结束日期是否符合日期格式
            toDate = valid.beDate(EndDate, errorcode[1]);
        }

        if (fromDate != null && toDate != null)
        {
            //结束日期不能小于开始日期
            if (!(fromDate.Value.CompareTo(toDate.Value) <= 0))
            {
                context.AddError(errorcode[2]);

                context.AddErrorControl(StartDate);
                context.AddErrorControl(EndDate);
            }
        }

    }
    /// <summary>
    /// 创建注释
    /// 创建标识：石磊 2012-07-20
    /// 方法描述：查询并为下拉选框赋值
    /// 使用的表：
    /// 使用的视图：
    /// 使用的存储过程：SP_RM_Query
    /// </summary>
    /// <param name="context">上下文环境</param>
    /// <param name="ddl">待赋值的下拉选框</param>
    /// <param name="funcCode">存储过程功能编码</param>
    /// <param name="vars">存储过程参数</param>
    /// <returns></returns>
    public static void select(CmnContext context, DropDownList ddl, string funcCode, params string[] vars)
    {
        SP_RM_QueryPDO pdo = new SP_RM_QueryPDO();
        pdo.funcCode = funcCode;
        int varNum = 0;
        foreach (string var in vars)
        {
            switch (++varNum)
            {
                case 1:
                    pdo.var1 = var;
                    break;
                case 2:
                    pdo.var2 = var;
                    break;
                case 3:
                    pdo.var3 = var;
                    break;
                case 4:
                    pdo.var4 = var;
                    break;
                case 5:
                    pdo.var5 = var;
                    break;
                case 6:
                    pdo.var6 = var;
                    break;
                case 7:
                    pdo.var7 = var;
                    break;
                case 8:
                    pdo.var8 = var;
                    break;
                case 9:
                    pdo.var9 = var;
                    break;
                case 10:
                    pdo.var10 = var;
                    break;
                case 11:
                    pdo.var11 = var;
                    break;
            }
        }

        StoreProScene storePro = new StoreProScene();

        DataTable dataTable = storePro.Execute(context, pdo);
        if (dataTable.Rows.Count == 0)
        {
            return;
        }

        Object[] itemArray;
        ListItem li;
        for (int i = 0; i < dataTable.Rows.Count; ++i)
        {
            itemArray = dataTable.Rows[i].ItemArray;
            li = new ListItem("" + itemArray[1] + ":" + itemArray[0], itemArray[1].ToString());
            ddl.Items.Add(li);
        }
    }
    /// <summary>
    /// 创建注释
    /// 创建标识：石磊 2012-07-20
    /// 方法描述：调用通用查询存储过程SP_RM_Query，查询资源管理相关信息
    /// 使用的表：
    /// 使用的视图：
    /// 使用的存储过程：SP_RM_Query
    /// </summary>
    /// <param name="context">上下文环境</param>
    /// <param name="funcCode">存储过程功能编码</param>
    /// <param name="vars">存储过程参数</param>
    /// <returns>DataTable,从数据库中查询出的结果</returns>
    public static DataTable callQuery(CmnContext context, string funcCode, params string[] vars)
    {
        SP_RM_QueryPDO pdo = new SP_RM_QueryPDO();
        pdo.funcCode = funcCode;
        int varNum = 0;
        foreach (string var in vars)
        {
            switch (++varNum)
            {
                case 1:
                    pdo.var1 = var;
                    break;
                case 2:
                    pdo.var2 = var;
                    break;
                case 3:
                    pdo.var3 = var;
                    break;
                case 4:
                    pdo.var4 = var;
                    break;
                case 5:
                    pdo.var5 = var;
                    break;
                case 6:
                    pdo.var6 = var;
                    break;
                case 7:
                    pdo.var7 = var;
                    break;
                case 8:
                    pdo.var8 = var;
                    break;
                case 9:
                    pdo.var9 = var;
                    break;
                case 10:
                    pdo.var10 = var;
                    break;
                case 11:
                    pdo.var11 = var;
                    break;
            }
        }

        StoreProScene storePro = new StoreProScene();

        return storePro.Execute(context, pdo);
    }

    // 清除gridview数据
    public static void resetData(GridView gv, DataTable dt)
    {
        gv.DataSource = dt == null ? new DataTable() : dt;
        gv.DataBind();

        if (dt == null)
        {
            gv.SelectedIndex = -1;
        }
    }
    /// <summary>
    /// 创建标识：殷华荣 2012-07-20
    /// 将所有审批过的用户卡领用单插入到临时表中
    /// </summary>
    /// <param name="context">上下文</param>
    /// <param name="gvResult">GridView控件</param>
    /// <param name="sessId">会话</param>
    /// <param name="getcardorderstate">审批结果 1 审批通过  2 审批作废</param>
    /// <param name="approvalStaffNo">审批人</param>
    public static void fillUseCardNoApprovedList(CmnContext context, GridView gvResult, string sessId,
        string getcardorderstate, string approvalStaffNo)
    {
        // 首先清空临时表
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON " + " where F0 = '" + sessId + "'");

        // 根据页面数据生成临时表数据
        int count = 0;
        for (int index = 0; index < gvResult.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvResult.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                string getcardorderid = getDataKeys2(gvResult, index, "getcardorderid");
                string cardtypecode = getDataKeys2(gvResult, index, "cardtypecode");
                string cardsurfacecode = getDataKeys2(gvResult, index, "cardsurfacecode");
                string applygetnum = getDataKeys2(gvResult, index, "applygetnum");
                string agreegetnum = "0";
                if (getcardorderstate == "1")
                {
                    TextBox txt = (TextBox)gvResult.Rows[index].FindControl("txtAgreeGetNum");
                    agreegetnum = txt.Text.Trim();
                }
                string useway = getDataKeys2(gvResult, index, "useway");
                string ordertime = getDataKeys2(gvResult, index, "ordertime");
                string orderstaffno = getDataKeys2(gvResult, index, "orderstaffno");
                string departno = getDataKeys2(gvResult, index, "departno");
                string remark = getDataKeys2(gvResult, index, "remark");
                //F0:SessionID，F1:领用单号，F2:领用类型，F3:领用单状态，F4:用途，F5:卡类型编码，
                //F6:卡面编码，F7:充值卡面值，F8:申请领用数量，F9:同意领用数量，F10:已领用数量，
                //F11:最近领用时间，F12:下单时间，F13:下单员工，F14:审核时间，F15:审核员工，F16:备注
                context.ExecuteNonQuery(@"insert into tmp_common (F0,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12,F13,F14,F15,F16)
                                values('" + sessId + "','" + getcardorderid + "','01','" + getcardorderstate + "','" + useway + "','" +
                         cardtypecode + "','" + cardsurfacecode + "',null,'" + applygetnum + "','" + agreegetnum + "',0,null,'" +
                        ordertime + "','" + orderstaffno + "','" + departno + "', '" + approvalStaffNo + "','" + remark + "')");
            }
        }
        context.DBCommit();
        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("A004P03R01: 没有选中任何行");
        }
    }

    /// <summary>
    /// 创建标识：殷华荣 2012-07-20
    /// 将所有审批过的充值卡领用单插入到临时表中 
    /// </summary>
    /// <param name="context">上下文</param>
    /// <param name="gvResult">GridView控件</param>
    /// <param name="sessId">会话</param>
    /// <param name="getcardorderstate">审批结果 1审核通过, 2审核作废</param>
    /// <param name="approvalStaffNo">审批人</param>
    public static void fillChargeCardNoApprovedList(CmnContext context, GridView gvResult, string sessId,
        string getcardorderstate, string approvalStaffNo)
    {
        // 首先清空临时表
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON " + " where F0 = '" + sessId + "'");

        // 根据页面数据生成临时表数据
        int count = 0;
        for (int index = 0; index < gvResult.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvResult.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                string getcardorderid = getDataKeys2(gvResult, index, "getcardorderid");
                string valuecode = getDataKeys2(gvResult, index, "valuecode");
                string applygetnum = getDataKeys2(gvResult, index, "applygetnum");
                string agreegetnum = "0";
                if (getcardorderstate == "1")
                {
                    TextBox txt = (TextBox)gvResult.Rows[index].FindControl("txtAgreeGetNum");
                    agreegetnum = txt.Text.Trim();
                }
                string useway = getDataKeys2(gvResult, index, "useway");
                string ordertime = getDataKeys2(gvResult, index, "ordertime");
                string orderstaffno = getDataKeys2(gvResult, index, "orderstaffno");
                string departno = getDataKeys2(gvResult, index, "departno");
                string remark = getDataKeys2(gvResult, index, "remark");
                //F0:SessionID，F1:领用单号，F2:领用类型，F3:领用单状态，F4:用途，F5:卡类型编码，
                //F6:卡面编码，F7:充值卡面值，F8:申请领用数量，F9:同意领用数量，F10:已领用数量，
                //F11:最近领用时间，F12:下单时间，F13:下单员工，F14:审核时间，F15:审核员工，F16:备注
                context.ExecuteNonQuery(@"insert into tmp_common (F0,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12,F13,F14,F15,F16)
                                values('" + sessId + "','" + getcardorderid + "','02','" + getcardorderstate + "','" + useway + "',null,null,'"
                                          + valuecode + "','" + applygetnum + "','" + agreegetnum + "',0,null,'" +
                        ordertime + "','" + orderstaffno + "','" + departno + "', '" + approvalStaffNo + "','" + remark + "')");
            }
        }
        context.DBCommit();
        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("A004P03R01: 没有选中任何行");
        }
    }
    /// <summary>
    /// 将要打印的领用单号插入到临时表中
    /// </summary>
    /// <param name="context"></param>
    /// <param name="gvResult"></param>
    /// <param name="sessId"></param>
    /// <param name="getcardorderNo"></param>
    public static void fillGetCardNoList(CmnContext context, GridView gvResult, string sessId)
    {
        // 首先清空临时表
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON " + " where F0 = '" + sessId + "'");
        // 根据页面数据生成临时表数据
        int count = 0;
        for (int index = 0; index < gvResult.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvResult.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                string getcardorderid = getDataKeys2(gvResult, index, "getcardorderid");
                context.ExecuteNonQuery(@"insert into tmp_common (F0,F1)
                                values('" + sessId + "','" + getcardorderid + "')");
            }
        }
        context.DBCommit();
    }

    //获取GridView选中行的Key值 创建人：殷华荣
    static public String getDataKeys2(GridView gvResult, int index, String keysname)
    {
        return gvResult.DataKeys[index][keysname].ToString();
    }

    //清空临时表 创建人：殷华荣
    static public void ClearTempData(CmnContext context, string sessionID)
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON " + " where F0 = '" + sessionID + "'");
        context.DBCommit();
    }

    public static void RespondPicture(byte[] pic, HttpResponse res)
    {
        if (pic != null)
        {
            res.ContentType = "application/octet-stream";
            res.AddHeader("Content-Disposition", "attachment;FileName= picture.JPG");
            res.BinaryWrite(pic);
        }
    }

    public static byte[] ReadPicture(CmnContext context, string CardSampleCode)
    {
        string selectSql = "Select CARDSAMPLE From TD_M_CARDSAMPLE Where CARDSAMPLECODE=:CardSampleCode";
        context.DBOpen("Select");
        context.AddField(":CardSampleCode").Value = CardSampleCode;
        DataTable dt = context.ExecuteReader(selectSql);
        context.DBCommit();
        if (dt != null && dt.Rows.Count > 0 && dt.DefaultView[0]["CARDSAMPLE"].ToString() != "")
        {
            return (byte[])dt.Rows[0].ItemArray[0];
        }

        return null;
    }

    /// <summary>
    /// 获取图片二进制流文件
    /// </summary>
    /// <param name="FileUpload1">upload控件</param>
    /// <returns>二进制流</returns>
    public static byte[] GetPicture(CmnContext context, FileUpload FileUpload1)
    {
        string[] strPics = { ".jpg", ".bmp", ".gif", ".jpeg", ".png" };
        int index = Array.IndexOf(strPics, Path.GetExtension(FileUpload1.FileName).ToLower());
        if (index == -1)
        {
            context.AddError("A094780002:上传文件格式必须为jpg|bmp|jpeg|png|gif");
            return null;
        }
        System.IO.Stream fileDataStream = FileUpload1.PostedFile.InputStream;

        int fileLength = FileUpload1.PostedFile.ContentLength;

        byte[] fileData = new byte[fileLength];

        fileDataStream.Read(fileData, 0, fileLength);
        fileDataStream.Close();

        return fileData;
    }

    /// <summary>
    /// 更新图片
    /// </summary>
    /// <param name="p_outcardsamplecode">卡样编码</param>
    /// <param name="buff">图片二进制流文件</param>
    public static void UpdateCardSample(CmnContext context, string p_outcardsamplecode, byte[] buff)
    {
        context.DBOpen("BatchDML");
        context.AddField(":cardsamplecode", "String").Value = p_outcardsamplecode;
        context.AddField(":BLOB", "BLOB").Value = buff;
        string sql = "UPDATE TD_M_CARDSAMPLE SET CARDSAMPLE = :BLOB WHERE CARDSAMPLECODE = :cardsamplecode";
        context.ExecuteNonQuery(sql);
        context.DBCommit();
    }


    public static void selectManuWithCoding(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", "99"));

        selectCoding(context, ddl, "TD_M_MANUWITHCODING");
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S002P01I03: 初始化厂商列表失败");
        }
    }

    public static void selectCoding(CmnContext context, DropDownList ddl, string funcCode, params string[] vars)
    {
        SP_RM_QueryPDO pdo = new SP_RM_QueryPDO();
        pdo.funcCode = funcCode;
        int varNum = 0;
        foreach (string var in vars)
        {
            switch (++varNum)
            {
                case 1:
                    pdo.var1 = var;
                    break;
                case 2:
                    pdo.var2 = var;
                    break;
                case 3:
                    pdo.var3 = var;
                    break;
                case 4:
                    pdo.var4 = var;
                    break;
                case 5:
                    pdo.var5 = var;
                    break;
                case 6:
                    pdo.var6 = var;
                    break;
                case 7:
                    pdo.var7 = var;
                    break;
                case 8:
                    pdo.var8 = var;
                    break;
                case 9:
                    pdo.var9 = var;
                    break;
            }
        }

        StoreProScene storePro = new StoreProScene();

        DataTable dataTable = storePro.Execute(context, pdo);
        if (dataTable.Rows.Count == 0)
        {
            return;
        }

        Object[] itemArray;
        ListItem li;
        for (int i = 0; i < dataTable.Rows.Count; ++i)
        {
            itemArray = dataTable.Rows[i].ItemArray;
            li = new ListItem("" + itemArray[1] + ":" + itemArray[0], (String)itemArray[2]);
            ddl.Items.Add(li);
        }
    }
}
