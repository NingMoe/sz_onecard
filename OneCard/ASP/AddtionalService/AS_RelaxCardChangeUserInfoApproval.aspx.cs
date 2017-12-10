using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using Common;
using DataExchange;
using System.Text;
using TDO.UserManager;
using PDO.Financial;
using Master;
using System.IO;

/**********************************
 * 休闲卡修改资料审核
 * 2015-4-24
 * gl
 * 初次编写
 * ********************************/
public partial class ASP_AddtionalService_AS_RelaxCardChangeUserInfoApproval : Master.FrontMaster
{
    #region Page Load
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;


        Session["PicData"] = null;
        Session["PicDataOther"] = null;

        gvResult.DataSource = new DataTable();
        gvResult.DataBind();

        //初始化证件类型
        ASHelper.initPaperTypeList(context, selPaperType);

        //初始化部门和员工
        InitializaDeptAndStaff();

        txtFromDate.Text = DateTime.Now.AddDays(-30).ToString("yyyyMMdd");
        txtToDate.Text = DateTime.Now.ToString("yyyyMMdd");

    }

    #endregion

    #region Event Handler
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtPaperNo.Text, ref strBuilder);
        DataTable data = ASHelper.callQuery(context, "QueryRelaxCardChangeUserInfo",
            txtFromDate.Text,
            txtToDate.Text,
            selDept.SelectedValue,
            selStaff.SelectedValue,
            txtCardno.Text,
            selPaperType.SelectedValue,
            strBuilder.ToString());

        CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" }));
        UserCardHelper.resetData(gvResult, data);
    }


    // 通过 复选框 改变事件
    protected void chkApprove_CheckedChanged(object sender, EventArgs e)
    {
        if (chkApprove.Checked)
        {
            chkReject.Checked = false;
        }

        btnSubmit.Enabled = (chkApprove.Checked || chkReject.Checked);
    }

    // 作废 复选框 改变事件
    protected void chkReject_CheckedChanged(object sender, EventArgs e)
    {
        if (chkReject.Checked)
        {
            chkApprove.Checked = false;
        }

        btnSubmit.Enabled = (chkApprove.Checked || chkReject.Checked);
    }


    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 首先清空临时表


        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_AS_CARDPARKCHANGEINFO where SESSIONID='" + Session.SessionID + "'");

        Validation val = new Validation(context);
        // 根据页面数据生成临时表数据

        int count = 0;
        int seq = 0;
        foreach (GridViewRow gvr in gvResult.Rows)
        {

            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");

            if (cb != null && cb.Checked)
            {
                ++count;
                context.ExecuteNonQuery("insert into TMP_AS_CARDPARKCHANGEINFO(SESSIONID,ID,CARDNO,PAPERNO,PAPERTYPECODE,CUSTNAME)" +
                "values('" + Session.SessionID + "'," + (seq++) + ",'" + gvr.Cells[2].Text + "','" + gvr.Cells[5].Text + "','" + ConvertPaperNameToCode(gvr.Cells[4].Text) + "','" + gvr.Cells[3].Text + "')");
            }
        }
        if (context.hasError()) return;
        context.DBCommit();
        // 没有选中任何行，则返回错误

        if (count <= 0)
        {
            context.AddError("A004P03R01: 没有选中任何行");
        }
        if (context.hasError()) return;

        context.SPOpen();
        context.AddField("p_SESSIONID").Value = Session.SessionID;
        context.AddField("p_stateCode").Value = chkApprove.Checked ? "1" : "2";
        context.AddField("p_TRADEIDs", "String", "Output", "2000");
        context.AddField("p_CARDNOs", "String", "Output", "2000");
        bool ok = context.ExecuteSP("SP_AS_RelaxCardUserInfoApprove");
        if (ok)
        {
            context.AddMessage(chkApprove.Checked
                ? "审核通过" : "作废成功");

            string tradeids = context.GetFieldValue("p_TRADEIDs").ToString();
            string cardnos = context.GetFieldValue("p_CARDNOs").ToString();

            if (!string.IsNullOrEmpty(tradeids.Trim()) && !string.IsNullOrEmpty(tradeids.Trim()))
            {
                string[] tradeid = tradeids.Substring(1, tradeids.Length - 1).Split(',');
                string[] cardno = cardnos.Substring(1, cardnos.Length - 1).Split(',');

                int syncCount = 0;
                for (int i = 0; i < cardno.Length; i++)
                {
                    if (Sync(cardno[i], tradeid[i], ref syncCount) == false)
                        break;
                }
                if (syncCount > 0)
                {
                    context.AddMessage("共成功同步张家港市民卡B卡" + syncCount + "条数据");
                }
            }
        }


        btnQuery_Click(null, null);
        chkApprove.Checked = chkReject.Checked = false;
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Image tmp_Image = (Image)e.Row.Cells[1].FindControl("Image1");
            string cardNo = (string)DataBinder.Eval(e.Row.DataItem, "CARDNO");

            //changecode 0:原始  3:都修改
            string changeCode = (string)DataBinder.Eval(e.Row.DataItem, "CHANGECODE");
            if (!System.Convert.IsDBNull(DataBinder.Eval(e.Row.DataItem, "PICTURE")))
            {

                byte[] pic = (byte[])DataBinder.Eval(e.Row.DataItem, "PICTURE");
                tmp_Image.ImageUrl = "AS_RelaxCardChangeUserInfoGetPic.aspx?Cardno=" + cardNo + "&ChangeCode=" + changeCode + "&id=" + DateTime.Now.ToString();

            }
            else
            {
                tmp_Image.ImageUrl = "~/Images/nom.jpg";
            }
            CheckBox chk = (CheckBox)e.Row.Cells[0].FindControl("ItemCheckBox");
            Label lbOld = (Label)e.Row.Cells[0].FindControl("lbOld");
            if (!System.Convert.IsDBNull(DataBinder.Eval(e.Row.DataItem, "CHANGECODE")))
            {
                if (DataBinder.Eval(e.Row.DataItem, "CHANGECODE").ToString() == "0")
                {
                    chk.Visible = false;
                    lbOld.Visible = true;
                }
            }
        }
    }

    //分页
    protected void gvResult_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
    /// <summary>
    /// 选择部门事件
    /// </summary>
    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selDept.SelectedValue);
    }
    #endregion

    #region Private
    /// <summary>
    /// 初始化部门
    /// </summary>
    /// <returns></returns>
    private void InitializaDeptAndStaff()
    {
        if (HasOperPower("201008"))//全部网点主管
        {
            //初始化部门
            FIHelper.selectDept(context, selDept, true);
            //selDept.SelectedValue = context.s_DepartID;
            InitStaffList("");
            //selStaff.SelectedValue = context.s_UserID;
        }
        else if (HasOperPower("201007"))//网点主管
        {
            selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
            selDept.SelectedValue = context.s_DepartID;
            selDept.Enabled = false;

            InitStaffList(context.s_DepartID);
            //selStaff.SelectedValue = context.s_UserID;
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
            //selStaff.SelectedValue = context.s_UserID;
        }
        else if (HasOperPower("201010"))//代理网点主管
        {
            selDept.Items.Add(new ListItem(context.s_DepartID + ":" + context.s_DepartName, context.s_DepartID));
            selDept.SelectedValue = context.s_DepartID;
            selDept.Enabled = false;

            InitStaffList(context.s_DepartID);
            //selStaff.SelectedValue = context.s_UserID;
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
    }
    /// <summary>
    /// 权限验证
    /// </summary>
    /// <returns></returns>
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
    /// <summary>
    /// 刷新员工
    /// </summary>
    /// <returns></returns>
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
            //selStaff.SelectedValue = context.s_UserID;

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
    /// <summary>
    /// 初始化DropDownList
    /// </summary>
    /// <param name="context">全局帮助类</param>
    /// <param name="lst">需要绑定的下拉框</param>
    /// <param name="funcCode">存储过程对应方法</param>
    /// <param name="vars">参数</param>
    /// <returns></returns>
    public static void InitDropDownList(CmnContext context, DropDownList lst, string funcCode, params string[] vars)
    {
        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = funcCode;

        StoreProScene storePro = new StoreProScene();
        DataTable dt = storePro.Execute(context, pdo);

        FillDropDownList(lst, dt, true);
    }
    /// <summary>
    /// 填充DropDownList
    /// </summary>
    /// <param name="ddl">填充的下拉框</param>
    /// <param name="dt">填充表</param>
    /// <param name="empty">是否有全选项</param>
    public static void FillDropDownList(DropDownList ddl, DataTable dt, bool empty)
    {
        ddl.Items.Clear();

        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        Object[] itemArray;
        ListItem li;
        for (int i = 0; i < dt.Rows.Count; ++i)
        {
            itemArray = dt.Rows[i].ItemArray;
            li = new ListItem("" + (String)itemArray[1] + ":" + itemArray[0], (String)itemArray[1]);
            ddl.Items.Add(li);
        }
    }
    //同步张家港市民卡B卡
    private bool Sync(string cardno, string tradeID, ref int syncCount)
    {
        if (cardno.Substring(0, 6) == "215061")
        {
            string syncCardID = cardno;
            string[] parm = new string[2];
            parm[0] = tradeID;
            parm[1] = syncCardID;
            DataTable syncData = SPHelper.callQuery("SP_RC_QUERY", context, "QureyUserInfoChangeSync", parm);

            //姓名，证件号码解密

            CommonHelper.AESDeEncrypt(syncData, new List<string>(new string[] { "NAME", "PAPER_NO", "OLD_NAME", "OLD_PAPER_NO" }));
            //新证件类型转换

            string npaperType = syncData.Rows[0]["PAPER_TYPE"].ToString();
            switch (npaperType)
            {
                case "00": syncData.Rows[0]["PAPER_TYPE"] = "0"; break;//身份证

                case "01": syncData.Rows[0]["PAPER_TYPE"] = "8"; break;//学生证（其它）

                case "02": syncData.Rows[0]["PAPER_TYPE"] = "6"; break;//军官证

                case "05": syncData.Rows[0]["PAPER_TYPE"] = "2"; break;//护照
                case "06": syncData.Rows[0]["PAPER_TYPE"] = "3"; break;//港澳居民来往内地通行证

                case "07": syncData.Rows[0]["PAPER_TYPE"] = "1"; break;//户口簿

                case "08": syncData.Rows[0]["PAPER_TYPE"] = "8"; break;//武警证（其它）

                case "09": syncData.Rows[0]["PAPER_TYPE"] = "4"; break;//台湾同胞来往内地通行证

                case "99": syncData.Rows[0]["PAPER_TYPE"] = "8"; break;//其它类型证件
                default: break;
            }
            //旧证件类型转换

            string opaperType = syncData.Rows[0]["OLD_PAPER_TYPE"].ToString();
            switch (opaperType)
            {
                case "00": syncData.Rows[0]["OLD_PAPER_TYPE"] = "0"; break;
                case "01": syncData.Rows[0]["OLD_PAPER_TYPE"] = "8"; break;
                case "02": syncData.Rows[0]["OLD_PAPER_TYPE"] = "6"; break;
                case "05": syncData.Rows[0]["OLD_PAPER_TYPE"] = "2"; break;
                case "06": syncData.Rows[0]["OLD_PAPER_TYPE"] = "3"; break;
                case "07": syncData.Rows[0]["OLD_PAPER_TYPE"] = "1"; break;
                case "08": syncData.Rows[0]["OLD_PAPER_TYPE"] = "8"; break;
                case "09": syncData.Rows[0]["OLD_PAPER_TYPE"] = "4"; break;
                case "99": syncData.Rows[0]["OLD_PAPER_TYPE"] = "8"; break;
                default: break;
            }

            //调用后台接口
            SyncRequest syncRequest;
            bool sync = DataExchangeHelp.ParseFormDataTable(syncData, tradeID, out syncRequest);
            if (sync == true)
            {
                SyncRequest syncResponse;
                string msg;
                bool succ = DataExchangeHelp.Sync(syncRequest, out syncResponse, out msg);
                if (!succ)
                {
                    context.AddError("调用接口失败:" + msg);
                    return false;
                }
                else
                {
                    syncCount++;
                    //context.AddMessage("调用接口成功!");
                }
            }
            else
            {
                context.AddError("调用接口转换错误!");
                return false;
            }
        }
        return true;
    }


    private string ConvertPaperNameToCode(string paperName)
    {
        if(paperName=="身份证")
        {
            return "00";
        }
        else if (paperName == "军官证")
        {
            return "01";
        }
        else if (paperName == "护照")
        {
            return "05";
        }
        else if (paperName == "港澳台通行证")
        {
            return "06";
        }
        else if (paperName == "户口簿")
        {
            return "07";
        }
        else if (paperName == "武警证")
        {
            return "08";
        }
        else if (paperName == "台胞证")
        {
            return "09";
        }
        else if (paperName == "其他")
        {
            return "99";
        }
        return "00";
    }
    #endregion
}