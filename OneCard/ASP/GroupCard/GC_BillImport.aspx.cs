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

public partial class ASP_GroupCard_GC_BillImport : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        GroupCardHelper.clearTempCustInfoTable(context,Session.SessionID);

        clearGridViewData();
    }

    private void SubmitValidate()
    {
        Validation valid = new Validation(context);
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
    }

    private void createGridViewData()
    {
        DataTable data = GroupCardHelper.callOrderQuery(context, "QueryBillImport", Session.SessionID);
        gvResult.DataSource = data;
        gvResult.DataBind();

    }
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (context.hasError()) return;
        OrderHelper.fillAccountList(context, gvResult, Session.SessionID);
        if (context.hasError()) return;
        context.SPOpen();
        context.AddField("p_sessionID").Value = Session.SessionID;
        context.AddField("P_OUTRETMSG", "String", "output", "30000", null);
        bool ok = context.ExecuteSP("SP_GC_IMPORTACCOUNT");
        if (ok)
        {
            context.AddMessage("A008P02021:导入成功");
            string msg = context.GetFieldValue("P_OUTRETMSG").ToString();
            if (msg!="")
            {
                string s1 = msg.Remove(msg.LastIndexOf(";"), 1);
                string[] showmsg = s1.Split(';');
                for (int i = 0; i < showmsg.Length;i++ )
                {
                    context.AddMessage(showmsg[i]);//提示已完成自动审核的账单信息
                }
                
            }
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
        }
    }
    
    protected void btnUpload_Click(object sender, EventArgs e)
    {
        clearGridViewData();
        GroupCardHelper.uploadFileValidate(context, FileUpload1);
        if (context.hasError()) return;

        // 首先清空临时表

        GroupCardHelper.clearTempCustInfoTable(context,Session.SessionID);

        context.DBOpen("Insert");

        if (Path.GetExtension(FileUpload1.FileName) == ".xls" || Path.GetExtension(FileUpload1.FileName) == ".xlsx")
        {
            LoadExcelFile();
            if (context.hasError())
            {
                return;
            }
            createGridViewData();
        }
        else
        {
            context.AddError("请导入格式为.xls或.xlsx文件");
        }
    }

    /// <summary>
    /// 导入Excel格式的制卡文件
    /// </summary>
    private void LoadExcelFile()
    {
        if (File.Exists("D:\\excelfile\\" + FileUpload1.FileName))
        {
            File.Delete("D:\\excelfile\\" + FileUpload1.FileName);
        }
        byte[] bytes = FileUpload1.FileBytes;
        using (FileStream f = new FileStream("D:\\excelfile\\" + FileUpload1.FileName, FileMode.OpenOrCreate, FileAccess.ReadWrite))
        {
            f.Write(bytes, 0, bytes.Length);
        }
        DataTable data = OrderHelper.getExcel_info("D:\\excelfile\\" + FileUpload1.FileName);
        if (data != null && data.Rows.Count > 0)
        {
            //if (data.Columns.Count != 10)
            //{
            //    context.AddError("字段数目根据制卡格式定义必须为10");
            //    return;
            //}
            Hashtable ht = new Hashtable();
            for (int i = 0; i < data.Rows.Count; i++)
            {
                if (   data.Rows[i][0].ToString().Trim().Length > 0 || data.Rows[i][1].ToString().Trim().Length > 0
                    && data.Rows[i][2].ToString().Trim().Length > 0 || data.Rows[i][3].ToString().Trim().Length > 0
                    && data.Rows[i][4].ToString().Trim().Length > 0 || data.Rows[i][5].ToString().Trim().Length > 0
                    && data.Rows[i][6].ToString().Trim().Length > 0 || data.Rows[i][7].ToString().Trim().Length > 0
                    && data.Rows[i][8].ToString().Trim().Length > 0 || data.Rows[i][9].ToString().Trim().Length > 0
                    )
                {
                    String[] fields = new String[10];
                    fields[0] = data.Rows[i][0].ToString();
                    fields[1] = data.Rows[i][1].ToString();
                    fields[2] = data.Rows[i][2].ToString();
                    fields[3] = data.Rows[i][3].ToString();
                    fields[4] = data.Rows[i][4].ToString();
                    fields[5] = data.Rows[i][5].ToString();
                    fields[6] = data.Rows[i][6].ToString();
                    fields[7] = data.Rows[i][7].ToString();
                    fields[8] = data.Rows[i][8].ToString();
                    fields[9] = data.Rows[i][9].ToString();
                    dealFileContent(ht, fields, i + 1,i);
                }
            }
        }
        else
        {
            context.AddError("A004P01F01: 上传文件为空");
        }
        if (!context.hasError())
        {
            context.DBCommit();
        }
        try
        {
            if (FileUpload1.HasFile && File.Exists("D:\\excelfile\\" + FileUpload1.FileName))
            {
                File.Delete("D:\\excelfile\\" + FileUpload1.FileName);
            }
        }
        catch
        { }
    }

    private void dealFileContent(Hashtable ht, String[] fields, int lineCount,int rownum)
    {

        Bill bill = new Bill();
        bill.setCmnContext(context);
        bill.setLineCount(lineCount);

        bill.TradeDate = fields[0].Trim();          //1.	√	交易日期
        bill.IncomeAmount = fields[1].Trim();       //2.	√	收入金额
        bill.BankOfOther = fields[2].Trim();        //3.	√	对方开户行	   
        bill.NameOfOther = fields[3].Trim();        //4.	√	对方户名
        bill.AccountOfOther = fields[4].Trim();     //5.	√	对方帐号  
        bill.TradeShows = fields[5].Trim();         //6.	√	交易说明   
        bill.TradeIn = fields[6].Trim();            //7.	√	交易摘要        
        bill.PostScript = fields[7].Trim();         //8.	√	交易附言
        bill.BankAccount = fields[8].Trim();        //9.	√	到账银行
        bill.Account = fields[9].Trim();            //10.	√	到账帐号

        insertToTmp(bill, rownum);
    }

    private void insertToTmp(Bill bill,int rownum)
    {
        if (!context.hasError())
        {
            string insertToTmp = "insert into TMP_COMMON(f0, f1, f2, f3, f4, f5, f6, f7, f8 ,f9, f10, f11) values('"
                                    + bill.TradeDate.Trim() + "', '"
                                    + bill.IncomeAmount.Trim() + "', '"
                                    + bill.BankOfOther.Trim() + "', '"
                                    + bill.NameOfOther.Trim() + "', '"
                                    + bill.AccountOfOther.Trim() + "', '"
                                    + bill.TradeShows.Trim() + "', '"
                                    + bill.TradeIn.Trim() + "','"
                                    + bill.PostScript.Trim() + "','"
                                    + bill.BankAccount.Trim() + "', '"
                                    + bill.Account.Trim() + "', '"
                                    + Session.SessionID + "', '"
                                    + rownum.ToString() + "')";

            context.ExecuteNonQuery(insertToTmp);

        }
    }

    public class Bill
    {

        private CmnContext context;
        private int lineCount;

        private string tradeDate; //交易日期
        /// <summary>
        /// 交易日期
        /// </summary>
        public string TradeDate
        {
            get { return tradeDate; }
            set
            {
                tradeDate = value;
                if (tradeDate.Trim().Length < 1)
                {
                    context.AddError("第" + lineCount + "行交易日期未填写");
                }
                else
                {
                    if (!Validation.isDate(tradeDate, "yyyyMMdd"))
                    {
                        context.AddError("第" + lineCount + "行交易日期格式必须为yyyyMMdd");
                    }
                    else
                    {
                        tradeDate = tradeDate.Substring(0, 8);
                    }
                }
            }
        }

        private string incomeAmount; //收入金额
        /// <summary>
        /// 收入金额
        /// </summary>
        public string IncomeAmount
        {
            get 
            {
                return (Convert.ToDecimal(incomeAmount) * 100).ToString();
            }
            set
            {
                incomeAmount = value;
                if (incomeAmount.Trim().Length < 1)
                {
                    context.AddError("第" + lineCount + "行收入金额未填写");
                }
                else if (!Validation.isPrice(incomeAmount))
                {
                    context.AddError("第" + lineCount + "行收入金额不正确");
                }
            }
        }

        private string bankOfOther;//对方开户行
        /// <summary>
        /// 对方开户行
        /// </summary>
        public string BankOfOther
        {
            get { return bankOfOther; }
            set 
            { 
                bankOfOther = value;
            }
        }

        private string nameOfOther;//对方户名
        /// <summary>
        /// 对方户名
        /// </summary>
        public string NameOfOther
        {
            get { return nameOfOther; }
            set 
            { 
                nameOfOther = value;
            }
        }

        private string accountOfOther;//对方账号
        /// <summary>
        /// 对方账号
        /// </summary>
        public string AccountOfOther
        {
            get { return accountOfOther; }
            set
            {
                accountOfOther = value;
                if (accountOfOther.Trim().Length > 30)
                {
                    context.AddError("第" + lineCount + "行对方账号长度超过30位");
                }
            }
        }

        private string tradeShows;//交易说明
        /// <summary>
        /// 交易说明
        /// </summary>
        public string TradeShows
        {
            get { return tradeShows; }
            set { tradeShows = value; }
        }

        private string tradeIn;//交易摘要
        /// <summary>
        /// 交易摘要
        /// </summary>
        public string TradeIn
        {
            get { return tradeIn; }
            set { tradeIn = value; }
        }

        private string postScript;//交易附言
        /// <summary>
        /// 交易附言
        /// </summary>
        public string PostScript
        {
            get { return postScript; }
            set { postScript = value; }
        }

        private string bankAccount;//到账银行
        /// <summary>
        /// 到账银行
        /// </summary>
        public string BankAccount
        {
            get { return bankAccount; }
            set { bankAccount = value; }
        }

        private string account;//到账账号
        /// <summary>
        /// 到账账号
        /// </summary>
        public string Account
        {
            get { return account; }
            set 
            { 
                account = value;
                if (account.Trim().Length < 1)
                {
                    context.AddError("第" + lineCount + "行到账账号未填写");
                }
                else if (account.Trim().Length > 30)
                {
                    context.AddError("第" + lineCount + "行到账账号长度超过30位");
                }
            }
        }

        public void setCmnContext(CmnContext context)
        {
            this.context = context;
        }

        public void setLineCount(int lineCount)
        {
            this.lineCount = lineCount;
        }
        
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Label lbl = (Label)e.Row.Cells[0].FindControl("Label");
            CheckBox ch = (CheckBox)e.Row.FindControl("ItemCheckBox");

            if (lbl.Text == "OK")
            {
                e.Row.Cells[0].CssClass = null;
            }
            else
            {
                e.Row.Cells[0].CssClass = "error";
            }
        }
    }

}
