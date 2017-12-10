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
using Common;
using TM;
using PDO.GroupCard;
using TDO.UserManager;

//充值卡批量激活直销
public partial class ASP_ChargeCard_CC_ActivateDirectSale : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
        InitUnActiveOrder();
    }

    /// <summary>
    /// 初始化未激活的订单
    /// </summary>
    private void InitUnActiveOrder()
    {
        DataTable dt = GroupCardHelper.callOrderQuery(context, "UnActivateChargeCardSelect", Session.SessionID);

        UserCardHelper.resetData(gvOrderList, dt);
        if (dt == null)
        {
            context.AddMessage("没有未激活的订单");
        }
        clearTemp();
    }

    // 选中gridview当前页所有数据
    protected void CheckAll(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvOrderList.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }
   
    // "支付方式"与"到账标记"下拉列表选择更改事件处理
    protected void selPayMode_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (selPayMode.SelectedValue == "1") // 现金
        {
            selRecvTag.Enabled = false;
            txtAccRecvDate.Enabled = false;
        }
        else if (selPayMode.SelectedValue == "0" || selPayMode.SelectedValue == "2") // 转账或报销
        {
            selRecvTag.Enabled = true;
            if (selRecvTag.SelectedValue == "0") // 未到账
            {
                txtAccRecvDate.Enabled = false;
                txtAccRecvDate.Text = "";
            }
            else if (selRecvTag.SelectedValue == "1") // 已到账
            {
                txtAccRecvDate.Enabled = true;
            }
        }
    }

    // 提交前校验处理
    private void submitValidate()
    {
        Validation valid = new Validation(context);
        valid.notEmpty(selPayMode, "A007P02014: 付款方式必须设置");
        // 转账情况下的到账标记、到账日期校验（已到帐时检查到帐日期）
        if (selPayMode.SelectedValue == "0" || selPayMode.SelectedValue == "2")  // 转账
        {
            valid.notEmpty(selRecvTag, "A007P02015: 到帐标记必须设置");

            if (selRecvTag.SelectedValue == "1")
            {
                bool b = valid.notEmpty(txtAccRecvDate, "A007P02016: 到帐日期不能为空");
                DateTime? dt = null;
                if (b) dt = valid.beDate(txtAccRecvDate, "A007P02017: 到帐日期必须格式为yyyyMMdd");
                if (dt != null)
                {
                    valid.check(dt.Value.CompareTo(DateTime.Today) <= 0, "A007P02018: 到帐日期不能超过当前日期");
                }
            }
        }
        valid.check(Validation.strLen(txtRemark.Text) <= 200, "A007P02019: 备注长度不能超过200");
    }

    protected void btnSubmit_OnClick(object sender, EventArgs e)
    {
        submitValidate();
        if (context.hasError())
        {
            return;
        }
        clearTempCustInfoTable();
        //插入临时表
        int count = 0;
        context.DBOpen("Insert");
        foreach (GridViewRow gvr in gvOrderList.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked && cb.Visible)
            {
                ++count;
                string orderno = gvr.Cells[2].Text.Trim();
                if (orderno.Length == 12)
                {
                    orderno = orderno.PadRight(16, ' ');
                }
                string fromCardNo = gvr.Cells[3].Text.Trim();
                string toCardNo = gvr.Cells[4].Text.Trim();
                string custName = gvr.Cells[8].Text.Trim();
                string accRecv = selRecvTag.SelectedValue;               // 到账标记
                string payMode = selPayMode.SelectedValue;               // 支付方式
                string recvDate = "";
                string transactor = gvr.Cells[9].Text.Trim().Split(':')[0].Trim();
                if (selPayMode.SelectedValue == "1") // 现金
                {
                    recvDate = DateTime.Today.ToString("yyyyMMdd"); // 到账日期
                }
                else
                {
                    recvDate = txtAccRecvDate.Text;                 // 到账日期
                }
                string remark = txtRemark.Text.Trim();
                context.ExecuteNonQuery("insert into TMP_UnActivateChargeCard " +
                    "(F0,F1,F2,F3,F4,F5,F6,F7,F8,F9) values('"
                    + fromCardNo + "','" + toCardNo + "','"
                    + custName + "','" + accRecv + "','"
                    + payMode + "','" + recvDate + "','"
                    + remark + "','" + Session.SessionID + "','" + orderno + "','" + transactor + "')");
            }
        }
        context.DBCommit();
        if (count <= 0)
        {
            context.AddError("A004P03R01: 没有选中任何行");
            return;
        }
        //执行存储过程
        context.SPOpen();
        context.AddField("p_sessionID").Value = Session.SessionID;
        bool ok = context.ExecuteSP("SP_CC_ActivateDirectSale");
        if (ok)
        {
            context.AddMessage("激活直销成功");
        }
        clearTempCustInfoTable();
        InitUnActiveOrder();
    }

    private  void clearTempCustInfoTable()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_UnActivateChargeCard where F7 = '" + Session.SessionID + "'");
        context.DBCommit();
    }

    private void clearTemp()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_UnActivateChargeCard where F11 = '" + Session.SessionID + "'");
        context.DBCommit();
    }

    protected void gvOrderList_DataBound(object sender, EventArgs e)
    {
        if (gvOrderList.Rows.Count > 0)
        {
            for (int i = 0; i < gvOrderList.Rows.Count; i++)
            {
                string txtCell = gvOrderList.Rows[i].Cells[1].Text;
                if (txtCell == "0")
                {
                    gvOrderList.Rows[i].Cells[1].Text = "有卡号不是出库状态";
                    gvOrderList.Rows[i].Cells[1].CssClass = "error";
                    CheckBox cb = (CheckBox)gvOrderList.Rows[i].Cells[0].FindControl("ItemCheckBox");
                    cb.Visible = false;
                }
                else
                {
                    gvOrderList.Rows[i].Cells[1].Text = "OK";
                }
            }
        }
    }
}
