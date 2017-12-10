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
 * 功能名: 读卡器出库
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/08/20    shil			初次开发
 ****************************************************************/
public partial class ASP_EquipmentManagement_EM_ReaderStockOut : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //绑定JS，起始序列号，结束序列号失去焦点事件
            txtFromReaderNo.Attributes["OnBlur"] = "javascript:return Change();";
            txtToReaderNo.Attributes["OnBlur"] = "javascript:return Change();";
            //从厂商编码表(TD_M_MANU)中读取数据，放入下拉列表中

            //设置只读控件
            setReadOnly(txtReaderNum);

            // 选取拥有领用权限的员工，生成列表
            UserCardHelper.selectAssignableStaffs(context, selAssignedStaff, false);
        }
    }
    /// <summary>
    /// 提交存处理
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        context.SPOpen();
        context.AddField("P_FROMREADERNO").Value = txtFromReaderNo.Text.Trim();
        context.AddField("P_TOREADERNO").Value = txtToReaderNo.Text.Trim();
        context.AddField("P_READERNUMBER").Value = txtReaderNum.Text.Trim();
        context.AddField("p_ASSIGNEDSTAFF").Value = selAssignedStaff.SelectedValue;
        context.AddField("p_MONEY").Value = (Convert.ToInt32(txtSaleMoney.Text.Trim()) * 100).ToString();
        context.AddField("P_REMARK").Value = txtRemark.Text.Trim();

        bool ok = context.ExecuteSP("SP_EM_READERSTOCKOUT");
        if (ok)
        {
            AddMessage("出库成功");
            txtFromReaderNo.Text = "";
            txtToReaderNo.Text = "";
            txtReaderNum.Text = "";
            txtSaleMoney.Text = "";
            txtRemark.Text = "";
        }
    }
    /// <summary>
    /// 出库按钮点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnStockIn_Click(object sender, EventArgs e)
    {
        //输入校验
        if (!stockOutValidation()) return;

        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Check", "submitConfirm();", true);
    }
    /// <summary>
    /// 输入校验
    /// </summary>
    /// <returns>没有错误时返回true，有错误时返回false</returns>
    protected Boolean stockOutValidation()
    {
        //起始序列号
        if (string.IsNullOrEmpty(txtFromReaderNo.Text.Trim()))
            context.AddError("A094570200:读卡器起始序列号不能为空", txtFromReaderNo);
        else if (Validation.strLen(txtFromReaderNo.Text.Trim()) != 16)
            context.AddError("A094570201:读卡器起始序列号长度必须为16位", txtFromReaderNo);
        else if (!Validation.isNum(txtFromReaderNo.Text.Trim()))
            context.AddError("A094570202:读卡器起始序列号必须为数字", txtFromReaderNo);
        //结束序列号
        if (string.IsNullOrEmpty(txtToReaderNo.Text.Trim()))
            context.AddError("A094570203:读卡器结束序列号不能为空", txtToReaderNo);
        else if (Validation.strLen(txtToReaderNo.Text.Trim()) != 16)
            context.AddError("A094570204:读卡器结束序列号长度必须为16位", txtToReaderNo);
        else if (!Validation.isNum(txtToReaderNo.Text.Trim()))
            context.AddError("A094570205:读卡器结束序列号必须为数字", txtToReaderNo);

        if (txtFromReaderNo.Text.Trim().CompareTo(txtToReaderNo.Text.Trim()) > 0)
            context.AddError("A094570206:读卡器起始序列号不能大于结束序列号", txtFromReaderNo);

        //销售金额
        if (string.IsNullOrEmpty(txtSaleMoney.Text.Trim()))
            context.AddError("A094570208:销售金额不能为空", txtSaleMoney);
        else if (!Validation.isNum(txtSaleMoney.Text.Trim()))
            context.AddError("A094570209:销售金额不为数字", txtSaleMoney);

        //备注
        if (!string.IsNullOrEmpty(txtRemark.Text.Trim()))
            if (Validation.strLen(txtRemark.Text.Trim()) > 50)
                context.AddError("A094570207:备注长度不能超过50位", txtRemark);

        return !context.hasError();
    }
    protected void selAssignedStaff_Change(object sender, EventArgs e)
    {
        //查询保证金账户
        queryDepositAcc();
    }
    protected void queryDepositAcc()
    {
        DataTable data = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryStaffIsDeptBal", selAssignedStaff.SelectedValue);
        //如果查询结果存在并且员工所属网点结算单元为代理营业厅
        if (data.Rows.Count != 0 && data.Rows[0]["DEPTTYPE"].ToString().Equals("1"))
        {
            //查询保证金账户
            DataTable dataDeposit = SPHelper.callQuery("SP_PS_Query_DeptBal", context, "QueryDeptBalUnitDeposit", data.Rows[0]["DBALUNITNO"].ToString());
            if (dataDeposit.Rows.Count == 0)
            {
                //查询结果为空
                context.AddError("代理营业厅网点结算单元没有保证金账户！");
                return;
            }
            else
            {
                labDeposit.Text = dataDeposit.Rows[0]["DEPOSIT"].ToString();
                //获取可领卡价值额度，网点剩余卡价值
                DeptBalunitHelper.SetDeposit(context, data.Rows[0]["DBALUNITNO"].ToString(), labDeposit, labUsablevalue, labStockvalue);
                //labUsablevalue.Text = dataDeposit.Rows[0]["USABLEVALUE"].ToString();
                //labStockvalue.Text = dataDeposit.Rows[0]["STOCKVALUE"].ToString();
                //获取价值
                string sql = "SELECT TAGVALUE/100.0 TAGVALUE FROM TD_M_TAG WHERE TAGCODE='READER_PRICE'";
                context.DBOpen("Select");
                DataTable priceData = context.ExecuteReader(sql);

                if (priceData.Rows.Count > 0)
                {
                    double cardValue = Convert.ToDouble(priceData.Rows[0]["TAGVALUE"].ToString());

                    labMaxAvailaCard.Text = ((int)(Convert.ToDouble(labUsablevalue.Text) / cardValue)).ToString();
                }
                else
                {
                    context.AddError("未查询到读卡器单价！");
                    return;
                }
            }
        }
        else
        {
            //清空
            labDeposit.Text = "";
            labUsablevalue.Text = "";
            labStockvalue.Text = "";
            labMaxAvailaCard.Text = "";
        }
    }
}