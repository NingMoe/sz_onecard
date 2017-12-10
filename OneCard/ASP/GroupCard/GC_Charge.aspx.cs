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
using PDO.GroupCard;
using TM;
using Common;
using TDO.CardManager;
using System.IO;
using System.Text;
using Master;

public partial class ASP_GroupCard_GC_Charge : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        GroupCardHelper.createTempTable(context);
        clearTempTable();

        // 初始化集团客户
        GroupCardHelper.initGroupCustomer(context, selCorp);

        clearGridViewData();
    }

    private void SubmitValidate()
    {
        Validation valid = new Validation(context);
        valid.notEmpty(selCorp, "A004P01I02: 集团客户必须选择");
    }

    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        createGridViewData();
    }

    private void clearGridViewData()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();

        btnSubmit.Enabled = false;
        labAmount.Text = "0";
        labChargeTotal.Text = "0";
    }

    private void createGridViewData()
    {
        DataTable data = GroupCardHelper.callQuery(context, "InvalidGroupCards", Session.SessionID);
        if (data.Rows.Count > 0)
        {
            context.AddError("共有" + data.Rows.Count + "张卡片不存在对应的企服卡帐户，详见下面列表。请检查充值文件后重试。");
            gvResult.DataSource = data;
            gvResult.DataBind();
            return;
        }

        data = GroupCardHelper.callQuery(context, "ChargeItems", Session.SessionID);
        gvResult.DataSource = data;
        gvResult.DataBind();

        Decimal chargeTotal = 0;

        Object[] itemArray;
        for (int i = 0; i < data.Rows.Count; ++i)
        {
            itemArray = data.Rows[i].ItemArray;
            chargeTotal += (Decimal)(itemArray[1]);
        }

        labAmount.Text = "" + data.Rows.Count;
        labChargeTotal.Text = chargeTotal.ToString("n");

        btnSubmit.Enabled = (data.Rows.Count != 0);
    }
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        SubmitValidate();
        if (context.hasError()) return;

        SP_GC_ChargePDO pdo = new SP_GC_ChargePDO();
        pdo.groupCode = selCorp.SelectedValue;
        pdo.sessionId = Session.SessionID;
        PDOBase ddoOut;
        bool ok = TMStorePModule.Excute(context, pdo, out ddoOut);
        if (ok)
        {
            AddMessage("D004P04001: 企服卡批量充值成功，请等待审批");
        }
         
        clearGridViewData();
        clearTempTable();
    }
    private void clearTempTable()
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_GC_BatchChargeFile where SessionId='" + Session.SessionID + "'");
        context.DBCommit();

    }
    protected void btnUpload_Click(object sender, EventArgs e)
    {
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

            if (strLine.Length > 28)
            {
                context.AddError("第" + lineCount + "行长度为" + strLine.Length + ", 根据格式定义不能超过28");
                continue;
            }
            fields = strLine.Split(new char[2] { ',', '\t' });
            // 字段数目为2时合法
            if (fields.Length != 2)
            {
                context.AddError("第" + lineCount + "行字段数目为" + fields.Length + ", 根据格式定义必须为2");
                continue;
            }

            dealFileContent(ht, fields, lineCount);
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

    private void dealFileContent(Hashtable ht, String[] fields, int lineCount)
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

        // 充值金额
        string chargeAmount = fields[1].Trim();
        if (chargeAmount.Length > 10)
        {
            context.AddError("第" + lineCount + "行充值金额长度超过10位");          
        }
        else if (!Validation.isPriceEx(chargeAmount))
        {
            context.AddError("第" + lineCount + "行充值金额不是有效金额");
        }

        if (!context.hasError())
        {
            context.ExecuteNonQuery("insert into TMP_GC_BatchChargeFile values('"
                + Session.SessionID + "', '" + cardNo + "', " + chargeAmount + " * 100)");
        }
    }
}
