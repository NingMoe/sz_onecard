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
using PDO.GroupCard;
using Common;
using System.Collections.Generic;
using System.Text;

// 企服卡后台帐户锁定/结束处理
public partial class ASP_GroupCard_GC_AccLock : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
        hidLockType.Value = Request.Params["LockType"];
        labTitle.Text
            = hidLockType.Value == "UnLock" ? "解锁"
            : hidLockType.Value == "Query" ? "查询"
            : "锁定";

        if (hidLockType.Value == "Query")
        {
            chkLock.Visible = false;
            chkUnlock.Visible = false;
            btnSubmit.Visible = false;
        }
        else
        {
            chkLock.Visible = !(hidLockType.Value == "UnLock");
            chkUnlock.Visible = hidLockType.Value == "UnLock";
        }

        UserCardHelper.resetData(gvCardInfo, null);
    }

    //// 输入校验
    //private void QueryValidate()
    //{
    //    Validation valid = new Validation(context);

    //    // 对卡号进行非空、长度、数字检验

    //    bool b = valid.notEmpty(txtCardNo, "A004P09001: 卡号不能为空");
    //    if (b) b = valid.fixedLength(txtCardNo, 16, "A004P09002: 卡号长度必须是16位");
    //    if (b) valid.beNumber(txtCardNo, "A004P09003: 卡号必须全部是数字");
    //}

    // 获取datatable中字段的值，但字段为空时，返回空字符串

    private string getCellValue(Object obj)
    {
        return (obj == DBNull.Value ? "" : (string)obj);
    }

    // 卡信息查询结果gridview行创建事件

    protected void gvCardInfo_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件


            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvCardInfo','Select$" + e.Row.RowIndex + "')");
        }
    }

    //没有客户信息查看权则证件号码加*显示
    protected void gvCardInfo_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (!CommonHelper.HasOperPower(context))
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Cells[2].Text = CommonHelper.GetPaperNo(e.Row.Cells[2].Text);
                e.Row.Cells[3].Text = CommonHelper.GetCustPhone(e.Row.Cells[3].Text);
            }
        }
    }

    // 旧卡信息查询结果行选择事件
    public void gvCardInfo_SelectedIndexChanged(object sender, EventArgs e)
    {
        // 得到选择行

        GridViewRow selectRow = gvCardInfo.SelectedRow;

        // 根据选择行卡号读取用户信息

        labCardNo.Text = selectRow.Cells[0].Text;

        btnSelectLine();
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        foreach (Control con in this.Page.Controls)
        {
            ClearLabelControl(con);
        }

        // （1）查询卡客户资料
        DataTable data = null;

        string strValue = txtCondition.Text;
        if (selQueryType.SelectedValue == "02" || selQueryType.SelectedValue == "03" || selQueryType.SelectedValue == "04")   //证件号码
        {
            StringBuilder strBuilder = new StringBuilder();
            AESHelp.AESEncrypt(strValue, ref strBuilder);
            strValue = strBuilder.ToString();
        }
        data = GroupCardHelper.callQuery(context, "QueryCardInfo", selQueryType.SelectedValue, strValue);

        //add by jiangbb 解密
        CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" }));

        UserCardHelper.resetData(gvCardInfo, data);

        if (data.Rows.Count > 0)
        {
            gvCardInfo.SelectedIndex = 0;
            gvCardInfo_SelectedIndexChanged(sender, e);
        }
    }

    protected void btnSelectLine()
    {


        // （1）查询卡客户资料
        DataTable data = null;

        data = GroupCardHelper.callQuery(context, "QueryCustInfo", labCardNo.Text);

        //add by jiangbb 解密
        CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" }));

        if (data == null || data.Rows.Count == 0) // 无记录
        {
            context.AddError("A004P09004: 查询不到卡片的客户资料");
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;
            //labCardNo.Text = txtCardNo.Text;
            labName.Text = getCellValue(row[0]);
            labSex.Text = getCellValue(row[1]);
            labBirth.Text = getCellValue(row[2]);
            labPaperType.Text = getCellValue(row[3]);
            labPaperNo.Text = getCellValue(row[4]);
            labAddr.Text = getCellValue(row[5]);
            labPost.Text = getCellValue(row[6]);
            labPhone.Text = getCellValue(row[7]);
        }

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            labPaperNo.Text = CommonHelper.GetPaperNo(labPaperNo.Text);
            labPhone.Text = CommonHelper.GetCustPhone(labPhone.Text);
            labAddr.Text = CommonHelper.GetCustAddress(labAddr.Text);
        }

        // 2) 查询卡片可充值账户状态及余额
        data = GroupCardHelper.callQuery(context, "QueryAccInfo", labCardNo.Text);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            context.AddError("A004P09005: 查询不到卡片的企服卡帐户信息");
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;
            String useTag = getCellValue(row[0]);
            if (useTag == "1") // 有效
            {
                labAccState.Text = "1- 有  效";
            }
            else if (useTag == "2") // 已锁定
            {
                labAccState.Text = "2- 已锁定";
            }
            else if (useTag == "0")
            {
                labAccState.Text = "0- 已失效";
            }
            else
            {
                labAccState.Text = "未定义";
                context.AddError("A004P09006: 卡片的企服卡帐户状态未知");
            }
            hidAccState.Value = useTag;

            decimal decBalance = (decimal)row[1];
            labBalance.Text = ((int)decBalance / 100.00).ToString("n");
        }


        // 3) 查询集团客户和卡片状态

        data = GroupCardHelper.callQuery(context, "CardState", labCardNo.Text);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            context.AddError("A004P09007: 查询不到当前卡片的卡片状态");
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;
            labCardState.Text = (string)row[0];
        }

        data = GroupCardHelper.callQuery(context, "CardCorpName", labCardNo.Text);
        if (data == null || data.Rows.Count == 0) // 无记录
        {
            context.AddError("A004P09008: 查询不到当前卡片对应的集团客户编码");
        }
        else
        {
            Object[] row = data.Rows[0].ItemArray;
            labCorp.Text = (string)row[0];
        }


        // 如果存在错误，设置页面控件状态，并返回页面

        if (context.hasError())
        {
            chkLock.Enabled = false;
            chkUnlock.Enabled = false;
            btnSubmit.Enabled = false;
            chkLock.Checked = false;
            chkUnlock.Checked = false;

            return;
        }

        // 设置当前企服卡后台帐户可以锁定或者可以解锁

        if (hidAccState.Value == "1")
        {
            chkLock.Enabled = true;
            chkUnlock.Enabled = false;
        }
        else if (hidAccState.Value == "2")
        {
            chkLock.Enabled = false;
            chkUnlock.Enabled = true;
        }
    }

    // 提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 调用企服卡后台帐户锁定存储过程

        SP_GC_AccLockPDO pdo = new SP_GC_AccLockPDO();
        pdo.cardNo = labCardNo.Text;    // 企服卡卡号

        // -- '0' Unlock '1' Lock
        pdo.lockType = hidAccState.Value == "2" ? "0" : "1";  // 锁定类型：锁定/解锁

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok) AddMessage(hidAccState.Value == "2" ? "D004P09002: 企服卡帐户解锁成功" : "D004P09001: 企服卡帐户锁定成功");

        chkLock.Enabled = false;
        chkUnlock.Enabled = false;
        btnSubmit.Enabled = false;
        chkLock.Checked = false;
        chkUnlock.Checked = false;
    }

    // 锁定/解锁 复选框 改变事件
    protected void chkLock_CheckedChanged(object sender, EventArgs e)
    {
        btnSubmit.Enabled = chkLock.Checked || chkUnlock.Checked;
    }
}

