using System;
using System.Data;
using System.Collections;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using System.IO;
using System.Text;

public partial class ASP_CustomerAcc_CA_BatchCharge : Master.Master
{
    //初始化

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        //clearTempTable();

        //clearGridViewData();

        //初始化账户类型
        CAHelper.FillAcctType(context, ddlAcctType);
        // 初始化集团客户
        GroupCardHelper.initGroupCustomer(context, selCorp);

    }

    //分页
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        createGridViewData();
    }

    // 选中gridview当前页所有数据
    protected void CheckAll(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (ch.Enabled)
            {
                ch.Checked = cbx.Checked;
            }
        }
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (!ch.Checked)
            {
                btnSubmit.Enabled = false;
                return;
            }
        }
        btnSubmit.Enabled = true;
    }

    protected void Check(object sender, EventArgs e)
    {
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (!ch.Checked)
            {
                btnSubmit.Enabled = false;
                return;
            }
        }
        btnSubmit.Enabled = true;
    }

    //清空GRIDVIEW
    private void clearGridViewData()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();

        btnSubmit.Enabled = false;
        labAmount.Text = "0";
        labChargeTotal.Text = "0";
    }

    //
    private void createGridViewData()
    {
        string[] pvars = new string[1];
        pvars[0] = Session.SessionID;

        DataTable data = SPHelper.callQuery("SP_CA_Query", context, "ShowBatchCharge", pvars);
        gvResult.DataSource = data;
        gvResult.DataBind();

        Decimal chargeTotal = 0;

        Object[] itemArray;
        for (int i = 0; i < data.Rows.Count; ++i)
        {
            itemArray = data.Rows[i].ItemArray;
            chargeTotal += (Decimal)(itemArray[6]);
        }

        labAmount.Text = "" + data.Rows.Count;
        labChargeTotal.Text = chargeTotal.ToString("n");

        DataTable errordata = SPHelper.callQuery("SP_CA_Query", context, "InvalidBatchCharge", pvars);

        if (errordata.Rows.Count > 0)
        {
            context.AddError("共有" + errordata.Rows.Count + "张卡片的帐户没有开通或状态不正常，详见下面列表。请操作员确认。");
            btnSubmit.Enabled = false;
            return;
        }
        else
        {
            btnSubmit.Enabled = true;
        }
    }

    //提交
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (selCorp == null || selCorp.SelectedValue.Trim().Length < 1)
        {
            context.AddError("A006012015:请选择集团客户");
        }
        if (context.hasError()) return;

        clearTempTable();
        //将卡号 账户ID 充值金额再次入临时表
        if (gvResult != null && gvResult.Rows.Count > 0)
        {
            context.DBOpen("Insert");
            foreach (GridViewRow gvr in gvResult.Rows)
            {
                string cardNo = gvr.Cells[1].Text.Trim(); //卡号
                string accType = gvr.Cells[4].Text.Trim().Split(':')[0].Trim();//账户类型编码
                string chargeAmount = gvr.Cells[5].Text.Trim(); //充值金额

                context.ExecuteNonQuery(@"insert into TMP_CA_BatchChargeFile(SESSIONID,CARDNO,ACCT_ID,CUSTNAME,PAPER_NO,CHARGEAMOUNT) 
            values('" + Session.SessionID + "', '" + cardNo + "', '" + accType + "', '',''," + chargeAmount + " * 100)");
            }
            context.DBCommit();
        }

        context.SPOpen();
        context.AddField("P_SESSIONID").Value = Session.SessionID;
        context.AddField("P_GroupCode").Value = selCorp.SelectedValue.Trim();
        if (context.ExecuteSP("SP_CA_BATCHCHARGE"))
        {
            AddMessage("D006012015: 批量充值成功，请等待审批");
        }
        //context.DBClose();

        clearGridViewData();
        clearTempTable();
    }

    //清空临时表

    private void clearTempTable()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_CA_BatchChargeFile where SessionId='" + Session.SessionID + "'");
        context.DBCommit();
    }

    //上传文件
    protected void btnUpload_Click(object sender, EventArgs e)
    {
        //验证账户类型必选
        if (ddlAcctType.SelectedValue.Trim().Length < 1)
        {
            context.AddError("A006012015:请选择账户类型");
            return;
        }

        clearGridViewData();
        GroupCardHelper.uploadFileValidate(context, FileUpload1);
        if (context.hasError()) return;

        // 首先清空临时表

        clearTempTable();

        context.DBOpen("Insert");

        Stream stream = FileUpload1.FileContent;
        StreamReader reader = new StreamReader(stream, Encoding.GetEncoding("gb2312"));
        string strLine = "";
        int lineCount = 0; int goodLines = 0;
        String[] fields = null;
        Hashtable ht = new Hashtable();

        while (true)
        {
            strLine = reader.ReadLine();
            if (strLine == null)
            {
                break;
            }
            ++lineCount;

            strLine = strLine.Trim();
            if (strLine.Length <= 0)
            {
                continue;
            }

            if (strLine.Length > 66)
            {
                context.AddError("第" + lineCount + "行长度为" + strLine.Length + ", 根据格式定义不能超过66");
                continue;
            }
            fields = strLine.Split(new char[2] { ',', '\t' });
            // 字段数目为4时合法

            if (fields.Length != 4)
            {
                context.AddError("第" + lineCount + "行字段数目为" + fields.Length + ", 根据格式定义必须为4");
                continue;
            }

            dealFileContent(ht, fields, lineCount, ddlAcctType.SelectedValue);
            ++goodLines;
        }

        if (goodLines <= 0)
        {
            context.AddError("A004P01F01: 上传文件为空");
        }

        if (!context.hasError())
        {
            
            context.DBCommit();

            createGridViewData();
        }
        else
        {
            context.RollBack();
        }
    }
    //解密
    private string DeEncrypt(string value)
    {
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESDeEncrypt(value, ref strBuilder);
        return strBuilder.ToString();
    }
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Label lbl = (Label)e.Row.Cells[0].FindControl("Label");
            CheckBox ch = (CheckBox)e.Row.FindControl("ItemCheckBox");
            string result = gvResult.DataKeys[e.Row.RowIndex]["F2"].ToString();
            if (lbl.Text == "OK")
            {
                ch.Checked = true;
                ch.Enabled = false;
            }
            else if (result == "0")
            {
                ch.Checked = false;
                ch.Enabled = false;
                btnSubmit.Enabled = false;
                e.Row.Cells[0].CssClass = "error";
            }
            else if (result == "1")
            {
                ch.Checked = false;
                ch.Enabled = true;
                btnSubmit.Enabled = false;
                e.Row.Cells[0].CssClass = "error";
            }
            if (e.Row.Cells[2].Text.Trim() == "&nbsp;")
                e.Row.Cells[2].Text = "";
            e.Row.Cells[2].Text = DeEncrypt(e.Row.Cells[2].Text);
            if (e.Row.Cells[3].Text.Trim() == "&nbsp;")
                e.Row.Cells[3].Text = "";
            e.Row.Cells[3].Text = DeEncrypt(e.Row.Cells[3].Text);
        }
    }

    //读取上传文件,并插入数据库临时表中
    private void dealFileContent(Hashtable ht, String[] fields, int lineCount, string accType)
    {
        String cardNo = fields[0].Trim();
        // 卡号
        if (cardNo.Length != 16)
        {
            context.AddError("第" + lineCount + "行卡号长度不是16位");
        }
        else if (!Validation.isNum(cardNo))
        {
            context.AddError("第" + lineCount + "行卡号不全是数字");
        }
        //else if (ht.ContainsKey(cardNo))
        //{
        //    context.AddError("第" + lineCount + "行卡号重复");
        //    return;
        //}
        //ht.Add(cardNo, "");

        // 姓名
        string custName = fields[1].Trim();
        if (custName.Length <= 0)
        {
            context.AddError("第" + lineCount + "行姓名为空");
        }
        else if (Validation.strLen(custName) > 50)
        {
            context.AddError("第" + lineCount + "行姓名长度超过50位");
        }
        // 证件号码
        string paperNo = fields[2].Trim();
        if (paperNo.Length <= 0)
        {
            context.AddError("第" + lineCount + "行证件号码为空");
        }
        else if (!Validation.isCharNum(paperNo))
        {
            context.AddError("第" + lineCount + "行证件号码不为英数");
        }
        else if (Validation.strLen(paperNo) > 20)
        {
            context.AddError("第" + lineCount + "行证件号码长度超过20位");
        }
        
       
        // 充值金额
        string chargeAmount = fields[3].Trim();
        if (chargeAmount.Length > 10)
        {
            context.AddError("第" + lineCount + "行充值金额长度超过10位");
        }
        else if (!Validation.isPriceEx(chargeAmount))
        {
            context.AddError("第" + lineCount + "行充值金额不是有效金额");
        }
        else if (chargeAmount == "0")
        {
            context.AddError("第" + lineCount + "行充值金额为0");
        }

        if (!context.hasError())
        {
            StringBuilder strBuilder = new StringBuilder();
            AESHelp.AESEncrypt(custName, ref strBuilder);
            custName = strBuilder.ToString();
            AESHelp.AESEncrypt(paperNo, ref strBuilder);
            paperNo = strBuilder.ToString();
            context.ExecuteNonQuery(@"insert into TMP_CA_BatchChargeFile(SESSIONID,CARDNO,ACCT_ID,CUSTNAME,PAPER_NO,CHARGEAMOUNT) 
            values('"+ Session.SessionID + "', '" + cardNo + "', '" + accType + "', '" 
                     + custName + "','" + paperNo + "'," + chargeAmount + " * 100)");
        }
    }
}
