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
/***************************************************************
 * 功能名: 资源管理领卡审核
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/07/18    殷华荣			初次开发
 ****************************************************************/
public partial class ASP_ResourceManage_RM_GetCardExam : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            gvResultUseCard.DataKeyNames = new string[] { "getcardorderid", "cardtypecode", "cardtypename", "cardsurfacecode",
            "cardsurfacename","applygetnum","useway","ordertime","orderstaffno","staffname","departno","departname","remark"};

            gvResultChargeCard.DataKeyNames = new string[] { "getcardorderid", "valuecode", "value", "applygetnum", "useway", 
                "ordertime", "orderstaffno", "staffname", "departno", "departname", "remark" };

            showNonDataGridView();

            hidCardType.Value = "usecard";
        }
        ResourceManageHelper.selectTab(this, this.GetType(), hidCardType);
    }

    // 选中gridview当前页所有数据
    protected void CheckAll(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResultUseCard.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }

    // 选中gridview当前页所有数据
    protected void CheckChargeCardAll(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResultChargeCard.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }
    /// <summary>
    /// 查询卡面剩余库存数量
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void submitConfirm_Click(object sender, EventArgs e)
    {
        int count = 0;
        int cardfacecount = 0;
        int valuecount = 0;
        ArrayList cardfacecodeList = new ArrayList();//卡面编码动态数组
        ArrayList cardfacenameList = new ArrayList();//卡面名称动态数组
        ArrayList valuecodeList = new ArrayList();//面值编码动态数组
        ArrayList valuenameList = new ArrayList();//面值名称动态数组
        if (hidCardType.Value == "usecard") //用户卡
        {
            ValidUseCardInput(); //验证用户卡输入
            if (context.hasError())
                return;

            for (int index = 0; index < gvResultUseCard.Rows.Count; index++)
            {
                CheckBox cb = (CheckBox)gvResultUseCard.Rows[index].FindControl("ItemCheckBox");
                if (cb != null && cb.Checked)
                {
                    ++count;
                    cardfacecount = 0;
                    //卡面类型编码
                    string addcardsurfacecode = getDataKeys(gvResultUseCard, index, "cardsurfacecode");
                    //卡面类型名称
                    string addcardsurfacename = getDataKeys(gvResultUseCard, index, "cardsurfacename");
                    foreach (string cardfacecode in cardfacecodeList)
                    {
                        if (cardfacecode == addcardsurfacecode)
                            ++cardfacecount;
                    }
                    if (cardfacecount <= 0)//如果不是重复的卡面类型，则添加
                    {
                        cardfacecodeList.Add(addcardsurfacecode);
                        cardfacenameList.Add(addcardsurfacename);
                    }
                }
            }
            if (count <= 0)
            {
                context.AddError("A004P03R01: 没有选中任何行");
                return;
            }
            //选中卡面条件语句
            string strWhere = "";
            foreach (string cardfacecode in cardfacecodeList)
            {
                strWhere += "'" + cardfacecode.ToString() + "',";
            }
            if (strWhere.EndsWith(","))
            {
                strWhere = strWhere.Remove(strWhere.Length - 1);
            }
            //查询库存剩余
            string sql = "";
            sql +=" select b.cardsurfacename,count(a.cardno) total from TL_R_ICUSER a ,TD_M_CARDSURFACE b  "
                + " where a.RESSTATECODE = '00' and substr(a.cardno,5,4) = b.cardsurfacecode(+)"
                + " and substr(a.cardno,5,4) in (" + strWhere + ")"
                + " group by b.cardsurfacename";
            context.DBOpen("Select");
            DataTable cardfaceNumData = context.ExecuteReader(sql);
            //输出查询结果，提示库存余量
            string allowCardNum = "";
            int leftnum = 0;
            foreach (string cardfacename in cardfacenameList)
            {
                leftnum = 0;
                foreach (DataRow dr in cardfaceNumData.Rows)
                {
                    if (cardfacename == dr[0].ToString())
                    {
                        allowCardNum += cardfacename + "库存剩余" + dr[1].ToString() + "张,<br>";
                        ++leftnum;
                    }
                }
                //未查询出库存余量的表示库存剩余0张
                if (leftnum <= 0)
                    allowCardNum += cardfacename + "库存剩余0张,<br>";
            }
            ScriptManager.RegisterStartupScript(this, this.GetType(), "AdjustScript", "submitConfirm('" + allowCardNum + "');", true);

        }
        else //充值卡
        {
            ValidChargeCardInput();//充值卡输入验证
            if (context.hasError())
            {
                return;
            }
            for (int index = 0; index < gvResultChargeCard.Rows.Count; index++)
            {
                CheckBox cb = (CheckBox)gvResultChargeCard.Rows[index].FindControl("ItemCheckBox");
                if (cb != null && cb.Checked)
                {
                    ++count;
                    valuecount = 0;
                    //面值编码
                    string addvaluecode = getDataKeys(gvResultChargeCard, index, "valuecode");
                    //面值
                    string addvalue = getDataKeys(gvResultChargeCard, index, "value");
                    foreach (string valuecode in valuecodeList)
                    {
                        if (valuecode == addvaluecode)
                            ++valuecount;
                    }
                    if (valuecount <= 0)//如果不是重复的面值，则添加
                    {
                        valuecodeList.Add(addvaluecode);
                        valuenameList.Add(addvalue);
                    }
                }
            }
            if (count <= 0)
            {
                context.AddError("A004P03R01: 没有选中任何行");
                return;
            }
            //选中面值条件语句
            string strWhere = "";
            foreach (string valuecode in valuecodeList)
            {
                //strWhere += "'" + valuecode.ToString() + "',";
                strWhere +=  valuecode.ToString() + ",";
            }
            if (strWhere.EndsWith(","))
            {
                strWhere = strWhere.Remove(strWhere.Length - 1);
            }
            //查询库存剩余
            //string sql = "";
            //sql +=" select b.VALUE,count(a.XFCARDNO) total from TD_XFC_INITCARD a ,TP_XFC_CARDVALUE b  "
            //    + " where a.CARDSTATECODE = '2' and a.VALUECODE = b.VALUECODE(+)"
            //    + " and a.VALUECODE in (" + strWhere + ")"
            //    + " group by b.VALUE";
            //context.DBOpen("Select");
            //DataTable valueNumData = context.ExecuteReader(sql);
            DataTable valueNumData = ResourceManageHelper.callQuery(context, "queryCardValueLeftNum", strWhere);
            
            //输出查询结果，提示库存余量
            string allowCardNum = "";
            int leftnum = 0;
            foreach (string aluename in valuenameList)
            {
                leftnum = 0;
                foreach (DataRow dr in valueNumData.Rows)
                {
                    if (aluename == dr[0].ToString())
                    {
                        allowCardNum += aluename + "充值卡库存剩余" + dr[1].ToString() + "张,<br>";
                        ++leftnum;
                    }
                }
                //未查询出库存余量的表示库存剩余0张
                if (leftnum <= 0)
                    allowCardNum += aluename + "充值卡库存剩余0张,<br>";
            }
            ScriptManager.RegisterStartupScript(this, this.GetType(), "AdjustScript", "submitConfirm('" + allowCardNum + "');", true);
        }
    }
    //审批通过
    protected void btnPass_Click(object sender, EventArgs e)
    {
        string sessionID = Session.SessionID;
       
        if (hidCardType.Value == "usecard") //用户卡
        {
            ResourceManageHelper.fillUseCardNoApprovedList(context, gvResultUseCard, sessionID, "1", context.s_UserID); //插入临时表
            if (context.hasError()) return;
            context.SPOpen();
            context.AddField("p_sessionID").Value = sessionID;
            bool ok = context.ExecuteSP("SP_RM_USECARDAPPLYAPPROVAL");
            if (ok)
            {
                AddMessage("审批通过");
            }
            //清空临时表
            ResourceManageHelper.ClearTempData(context, sessionID);
        }
        else
        {
            ResourceManageHelper.fillChargeCardNoApprovedList(context, gvResultChargeCard, sessionID, "1", context.s_UserID);
            if (context.hasError()) return;
            context.SPOpen();
            context.AddField("p_sessionID").Value = sessionID;
            bool ok = context.ExecuteSP("SP_RM_CHARGECARDAPPLYAPPROVAL");
            if (ok)
            {
                AddMessage("审批通过");
            }
            //清空临时表
            ResourceManageHelper.ClearTempData(context, sessionID);

        }
        showNonDataGridView();
    }
    //审批作废
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        string sessionID = Session.SessionID;
        if (hidCardType.Value == "usecard")
        {
            ResourceManageHelper.fillUseCardNoApprovedList(context, gvResultUseCard, sessionID, "2", context.s_UserID);
            if (context.hasError()) return;
            context.SPOpen();
            context.AddField("p_sessionID").Value = sessionID;
            bool ok = context.ExecuteSP("SP_RM_USECARDAPPLYAPPROVAL");
            if (ok)
            {
                AddMessage("审批作废");
            }
            //清空临时表
            ResourceManageHelper.ClearTempData(context, sessionID);
        }
        else
        {
            ResourceManageHelper.fillChargeCardNoApprovedList(context, gvResultChargeCard, sessionID, "2", context.s_UserID);
            if (context.hasError()) return;
            context.SPOpen();
            context.AddField("p_sessionID").Value = sessionID;
            bool ok = context.ExecuteSP("SP_RM_CHARGECARDAPPLYAPPROVAL");
            if (ok)
            {
                AddMessage("审批作废");
            }
            //清空临时表
            ResourceManageHelper.ClearTempData(context, sessionID);
        }
        showNonDataGridView();
    }

    /// <summary>
    /// 用户卡输入验证
    /// </summary>
    private void ValidUseCardInput()
    {
        for (int index = 0; index < gvResultUseCard.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvResultUseCard.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                TextBox txt = (TextBox)gvResultUseCard.Rows[index].FindControl("txtAgreeGetNum");
                if (txt.Text.Trim().Length < 1)
                {
                    context.AddError("请填写同意领用数量", txt);
                    return;
                }
                if (txt.Text.Trim().Equals("0"))
                {
                    context.AddError("同意领用数量不能为零", txt);
                    return;
                }
                if (!Validation.isNum(txt.Text.Trim()))
                {
                    context.AddError("同意领用数量请输入数字", txt);
                    return;
                }
                //验证同意领用数量不大于申请领用数量
                string applygetnum = gvResultUseCard.DataKeys[index]["applygetnum"].ToString();
                if (Convert.ToInt32(txt.Text.Trim()) > Convert.ToInt32(applygetnum))
                {
                    context.AddError("同意领用数量不能超过申请领用数量", txt);
                    return;
                }
            }
        }
    }

    /// <summary>
    /// 充值卡输入验证
    /// </summary>
    private void ValidChargeCardInput()
    {
        for (int index = 0; index < gvResultChargeCard.Rows.Count; index++)
        {
            CheckBox cb = (CheckBox)gvResultChargeCard.Rows[index].FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                TextBox txt = (TextBox)gvResultChargeCard.Rows[index].FindControl("txtAgreeGetNum");
                if (txt.Text.Trim().Length < 1)
                {
                    context.AddError("请填写同意领用数量", txt);
                    return;
                }
                if (txt.Text.Trim().Equals("0"))
                {
                    context.AddError("同意领用数量不能为零", txt);
                    return;
                }
                if (!Validation.isNum(txt.Text.Trim()))
                {
                    context.AddError("同意领用数量请输入数字", txt);
                    return;
                }
                string applygetnum = gvResultChargeCard.DataKeys[index]["applygetnum"].ToString();
                if (Convert.ToInt32(txt.Text.Trim()) > Convert.ToInt32(applygetnum))
                {
                    context.AddError("同意领用数量不能超过申请领用数量", txt);
                    return;
                }
            }
        }
    }

    /// <summary>
    /// 查询出所有未审核的用户卡、充值卡信息
    /// </summary>
    private void showNonDataGridView()
    {
        DataTable dataUseCard = ResourceManageHelper.callQuery(context, "USECARD_NOAPPROVED");
        DataTable dataChargeCard = ResourceManageHelper.callQuery(context, "CHARGECARD_NOAPPROVED");
        ResourceManageHelper.resetData(gvResultUseCard, dataUseCard);
        ResourceManageHelper.resetData(gvResultChargeCard, dataChargeCard);
    }
    /// <summary>
    /// 获取GridView选中行的Key值
    /// </summary>
    /// <param name="gvResult">GridView</param>
    /// <param name="index">行数</param>
    /// <param name="keysname">key</param>
    /// <returns></returns>
    static public String getDataKeys(GridView gvResult, int index, String keysname)
    {
        return gvResult.DataKeys[index][keysname].ToString();
    }
}