using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Master;
using System.Collections;
using Common;
using TM;
using System.Text;
using System.IO;
using PDO.GroupCard;
using Controls.Customer.Asp;

// 企服卡帮助类
public class GroupCardHelper
{
    public static void fillBatchNoList(CmnContext context, GridView gvResult, string sessId)
    {
        // 首先清空临时表


        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_GC_BatchNoList " +
            " where SessionId = '" + sessId + "'");

        // 根据页面数据生成临时表数据


        int count = 0;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                ++count;
                context.ExecuteNonQuery("insert into TMP_GC_BatchNoList values('"
                    + sessId + "','" + gvr.Cells[1].Text + "')");
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
    /// 加载物流公司列表
    /// </summary>
    /// <param name="context"></param>
    /// <param name="ddl"></param>
    /// <param name="empty"></param>
    public static void fillInTrackingCop(CmnContext context, DropDownList ddl, bool empty)
    {
        DataTable dt = callQuery(context, "QueryTrackingCop", "");

        fill(ddl, dt, empty);
    }

    public static void fill(DropDownList ddl, DataTable dt, bool empty)
    {
        ddl.Items.Clear();

        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        Object[] itemArray;
        ListItem li;
        for (int i = 0; i < dt.Rows.Count; ++i)
        {
            itemArray = dt.Rows[i].ItemArray;
            li = new ListItem("" + itemArray[1] + ":" + itemArray[0], (String)itemArray[1]);
            ddl.Items.Add(li);
        }
    }

    public static void fillWoCode(DropDownList ddl, DataTable dt, bool empty)
    {
        ddl.Items.Clear();

        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        Object[] itemArray;
        ListItem li;
        for (int i = 0; i < dt.Rows.Count; ++i)
        {
            itemArray = dt.Rows[i].ItemArray;
            li = new ListItem("" + itemArray[0], (String)itemArray[1]);
            ddl.Items.Add(li);
        }
    }

    public static DataTable callQuery(CmnContext context, string funcCode, params string[] vars)
    {
        SP_GC_QueryPDO pdo = new SP_GC_QueryPDO();
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

        return storePro.Execute(context, pdo);
    }

    public static DataTable callOrderQuery(CmnContext context, string funcCode, params string[] vars)
    {
        SP_GC_OrderQueryPDO pdo = new SP_GC_OrderQueryPDO();
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
                case 12:
                    pdo.var12 = var;
                    break;
                case 13:
                    pdo.var13 = var;
                    break;
                case 14:
                    pdo.var14 = var;
                    break;
                case 15:
                    pdo.var15 = var;
                    break;
            }
        }

        StoreProScene storePro = new StoreProScene();

        return storePro.Execute(context, pdo);
    }

    public static void clearTempCustInfoTable(CmnContext context, string sessionId)
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON T WHERE T.F10='"+sessionId+"'");
        context.DBCommit();
    }
    public static void clearTempCustInfoTable(CmnContext context)
    {
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON");
        context.DBCommit();
    }

    public static ArrayList readPaperTypeList(CmnContext context)
    {
        string sql = "SELECT PAPERTYPECODE FROM TD_M_PAPERTYPE";
        TMTableModule tm = new TMTableModule();
        DataTable dt = tm.selByPKDataTable(context, sql, 0);

        ArrayList arr = new ArrayList(dt.Rows.Count);
        for (int i = 0; i < dt.Rows.Count; ++i)
        {
            arr.Add(dt.Rows[i].ItemArray[0]);
        }
        return arr;
    }

    public static ArrayList readBankNameList(CmnContext context)
    {
        string sql = "select bank from td_m_bank";
        TMTableModule tm = new TMTableModule();
        DataTable dt = tm.selByPKDataTable(context, sql, 0);

        ArrayList arr = new ArrayList(dt.Rows.Count);
        for (int i = 0; i < dt.Rows.Count; ++i)
        {
            arr.Add(dt.Rows[i].ItemArray[0]);
        }
        return arr;
    }


    public static void uploadFileValidate(CmnContext context, FileUpload FileUpload1)
    {
        if (!FileUpload1.HasFile)
        {
            context.AddError("A004P01F00: 没有上传任何文件");
            return;
        }

        int len = FileUpload1.FileBytes.Length;

        if (len > 5 * 1024 * 1024) // 5M
        {
            context.AddError("A004P01F02: 上传文件大小不能超过5M");
            return;
        }
    }


    public static void UploadRefundFile(CmnContext context, FileUpload FileUpload1, bool batchUpdateInfo)
    {
        uploadFileValidate(context, FileUpload1);
        if (context.hasError()) return;


        // 读取开户银行信息




        ArrayList al = readBankNameList(context);

        // 首先清空临时表



        clearTempCustInfoTable(context);

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
            strLine = strLine.Trim();
            ++lineCount;

            if (strLine.Length <= 0)
            {
                continue;
            }

            if (Validation.strLen(strLine) > 224 + 10 + 2)
            {
                context.AddError("第" + lineCount + "行长度为" + Validation.strLen(strLine)
                    + ", 根据格式定义不能超过236");
                continue;
            }
            fields = strLine.Split(new char[2] { ',', '\t' });

            // 字段数目为6-9时合法



            if (fields.Length < 7 || fields.Length > 8)
            {
                context.AddError("第" + lineCount + "行字段数目为"
                    + fields.Length + ", 根据格式定义必须为7-8");
                continue;
            }

            dealRefundFileContent(ht, context, fields, lineCount, al, batchUpdateInfo);
            ++goodLines;
        }

        if (goodLines <= 0)
        {
            context.AddError("A004P01F01: 上传文件为空");
        }

        if (!context.hasError())
        {
            context.DBCommit();
        }
        else
        {
            context.RollBack();
        }
    }




    public static void UploadCustInfoFile(CmnContext context, FileUpload FileUpload1, bool batchUpdateInfo)
    {
        uploadFileValidate(context, FileUpload1);
        if (context.hasError()) return;


        // 读取“证件类型编码表”（以便后面校验文件内容中的“证件类型编码”时使用）


        ArrayList al = readPaperTypeList(context);

        // 首先清空临时表



        clearTempCustInfoTable(context);

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
            strLine = strLine.Trim();
            ++lineCount;

            if (strLine.Length <= 0)
            {
                continue;
            }

            if (Validation.strLen(strLine) > 224 + 10)
            {
                context.AddError("第" + lineCount + "行长度为" + Validation.strLen(strLine)
                    + ", 根据格式定义不能超过234");
                continue;
            }
            fields = strLine.Split(new char[2] { ',', '\t' });

            // 字段数目为6-9时合法



            if (fields.Length < 6 || fields.Length > 10)
            {
                context.AddError("第" + lineCount + "行字段数目为"
                    + fields.Length + ", 根据格式定义必须为6-10");
                continue;
            }

            dealFileContent(ht, context, fields, lineCount, al, batchUpdateInfo);
            ++goodLines;
        }

        if (goodLines <= 0)
        {
            context.AddError("A004P01F01: 上传文件为空");
        }

        if (!context.hasError())
        {
            context.DBCommit();
        }
        else
        {
            context.RollBack();
        }
    }

    public static void createTempTable(CmnContext context)
    {
        // context.DBOpen("Select");
        // context.ExecuteNonQuery("begin SP_GC_CreateTmp; end;");
    }

    public static void initGroupCustomer(CmnContext context, DropDownList ddl)
    {
        DataTable dt = callQuery(context, "TD_GROUP_CUSTOMER");
        fill(ddl, dt, true);
    }

    public static void dealFileContent(Hashtable ht, CmnContext context,
        String[] fields, int lineCount, ArrayList al, bool batchUpdateInfo)
    {
        String cardNo = fields[0].Trim();
        // 卡号
        if (Validation.strLen(cardNo) != 16)
        {
            context.AddError("第" + lineCount + "行卡号长度不是16位");
        }
        else if (!Validation.isNum(cardNo))
        {
            context.AddError("第" + lineCount + "行卡号不全是数字");
        }
        else if (ht.ContainsKey(cardNo))
        {
            context.AddError("第" + lineCount + "行卡号重复");
            return;
        }
        ht.Add(cardNo, "");

        // 姓名
        string custName = fields[1].Trim();
        if (!batchUpdateInfo && custName.Length <= 0)
        {
            context.AddError("第" + lineCount + "行姓名为空");
        }
        else if (Validation.strLen(custName) > 50)
        {
            context.AddError("第" + lineCount + "行姓名长度超过50位");
        }

        //add by jiangbb 加密
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(custName, ref strBuilder);
        custName = strBuilder.ToString();

        // 证件号码
        string paperNo = fields[5].Trim();
        if (!batchUpdateInfo && paperNo.Length <= 0)
        {
            context.AddError("第" + lineCount + "行证件号码为空");
        }
        else if (Validation.strLen(paperNo) > 20)
        {
            context.AddError("第" + lineCount + "行证件号码长度超过20位");
        }
        //add by jiangbb 加密
        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(paperNo, ref strBuilder);
        paperNo = strBuilder.ToString();

        // 性别
        string custSex = fields[2].Trim();
        if (Validation.strLen(custSex) > 2)
        {
            context.AddError("第" + lineCount + "行性别长度超过2位");
        }
        else
        {
            if (custSex == "男")
            {
                custSex = "0";
            }
            else if (custSex == "女")
            {
                custSex = "1";
            }
            else if (custSex != "")
            {
                context.AddError("第" + lineCount + "行性别非法");
            }
        }

        // 生日
        String custBirth = fields[3].Trim();
        if (custBirth.Length > 0 && !Validation.isDate(custBirth, "yyyyMMdd"))
        {
            context.AddError("第" + lineCount + "行生日格式不正确，应为yyyyMMdd格式");
        }
        // 证件类型
        String paperType = fields[4].Trim();
        if (Validation.strLen(paperType) > 2)
        {
            context.AddError("第" + lineCount + "行证件类型长度超过2位");
        }
        else if (paperType.Length > 0 && !al.Contains(paperType))
        {
            context.AddError("第" + lineCount + "行证件类型没有定义");
        }


        string custAddr = "";
        if (fields.Length > 6)
        {
            // 联系地址
            custAddr = fields[6].Trim();
            if (Validation.strLen(custAddr) > 50)
            {
                context.AddError("第" + lineCount + "行联系地址长度超过50位");
            }
            //add by jiangbb 加密
            strBuilder = new StringBuilder();
            AESHelp.AESEncrypt(custAddr, ref strBuilder);
            custAddr = strBuilder.ToString();
        }

        string postCode = "";
        if (fields.Length > 7)
        {
            // 邮政编码
            postCode = fields[7].Trim();
            if (postCode.Length > 0 && (Validation.strLen(postCode) != 6 || !Validation.isNum(postCode)))
            {
                context.AddError("第" + lineCount + "邮政编码格式不对，必须是6位数字");
            }
        }
        string custPhone = "";
        if (fields.Length > 8)
        {
            // 电话号码
            custPhone = fields[8].Trim();
            if (Validation.strLen(custPhone) > 40)
            {
                context.AddError("第" + lineCount + "电话号码长度超过40位");
            }
            //add by jiangbb 加密
            strBuilder = new StringBuilder();
            AESHelp.AESEncrypt(custPhone, ref strBuilder);
            custPhone = strBuilder.ToString();
        }

        string custEmail = "";
        if (fields.Length > 9)
        {
            // 电子邮件
            custEmail = fields[9].Trim();
            string errMsg = new Validation(context).isEMail(custEmail);
            if (errMsg.Length > 0)
            {
                context.AddError("第" + lineCount + errMsg);
            }
        }

        if (!context.hasError())
        {
            context.ExecuteNonQuery("insert into TMP_COMMON(f1, f2, f3, f4, f5, f6, f7, f8, f9, f10) values('"
                + cardNo + "', '" + custName + "','" + custSex + "','" + custBirth
                + "','" + paperType + "','" + paperNo + "','" + custAddr + "','"
                + postCode + "','" + custPhone + "','" + custEmail + "')");
        }
    }



    public static void dealRefundFileContent(Hashtable ht, CmnContext context,
       String[] fields, int lineCount, ArrayList al, bool batchUpdateInfo)
    {
        String cardNo = fields[0].Trim();
        // 卡号
        if (Validation.strLen(cardNo) != 16)
        {
            context.AddError("第" + lineCount + "行卡号长度不是16位");
        }
        else if (!Validation.isNum(cardNo))
        {
            context.AddError("第" + lineCount + "行卡号不全是数字");
        }

        if (!ht.Contains(cardNo))
        {
            ht.Add(cardNo, "");
        }
        else
        {
            context.AddError("第" + lineCount + "行卡号已重复");
        }

        //日期
        string tradedate = fields[1].Trim();
        if (!Validation.isDate(tradedate, "yyyyMMdd"))
        {
            context.AddError("第" + lineCount + "行日期格式不为yyyyMMdd");
        }
        // 充值金额


        string trademoney = fields[2].Trim();
        if (!Validation.isNum(trademoney) || Convert.ToInt32(trademoney) > 100000)
        {
            context.AddError("第" + lineCount + "行金额必须为数字且不能大于100000");
        }
        //退款账户的开户行，


        string bankname = fields[3].Trim();
        if (!al.Contains(bankname))
        {
            context.AddError("第" + lineCount + "行账户的开户行不存在");
        }

        //退款账户的银行账户，


        string bankAcc = fields[4].Trim();
        if (Validation.strLen(bankAcc) > 30 || !Validation.isNum(bankAcc))
        {
            context.AddError("第" + lineCount + "行账户的开户行帐号长度不能大于30且都为数字");
        }
        //退款账户的开户名，



        string cusname = fields[5].Trim();
        if (Validation.strLen(cusname) > 50)
        {
            context.AddError("第" + lineCount + "行账户的开户开户名长度不能大于50");
        }

        //add by jiangbb 2012-05-21 收款人账户类型

        string purPoseType = fields[6].Trim();

        if (purPoseType != "1" && purPoseType != "2")
        {
            context.AddError("第" + lineCount + "行收款人账户类型不正确");
        }

        //备注
        string remark = fields.Length > 7 ? fields[7].Trim() : string.Empty;

        if (Validation.strLen(remark) > 20)
        {
            context.AddError("第" + lineCount + "行备注不能大于20");
        }



        if (!context.hasError())
        {
            string sqlt = string.Format("select ID from tq_supply_right t where t.cardno='{0}' and t.tradedate='{1}' and t.trademoney={2} and rownum=1", cardNo, tradedate, trademoney);
            TMTableModule tm = new TMTableModule();
            DataTable dt = context.ExecuteReader(sqlt);
            if (dt != null && dt.Rows.Count > 0)
            {

            }
            else
            {
                context.AddError("第" + lineCount + "行充值记录不存在，请检查");
                return;
            }
            string sqlt1 = string.Format("Select ID From TF_B_REFUND Where ID = '{0}'", dt.Rows[0][0].ToString());
            DataTable dt1 = context.ExecuteReader(sqlt1);
            if (dt1 != null && dt1.Rows.Count > 0)
            {
                context.AddError("第" + lineCount + "行充值记录已做过退款，请检查");
            }
            else
            {
                if (dt != null && dt.Rows.Count > 0)
                {
                    string sql = string.Format("insert into TMP_COMMON(f1, f2, f3, f4, f5, f6, f7,f8,f9) values('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", dt.Rows[0][0].ToString(), cardNo, tradedate, trademoney, bankname, bankAcc, cusname, remark, purPoseType);
                    context.ExecuteNonQuery(sql);
                }
                else
                {
                    context.AddError("第" + lineCount + "行充值记录不存在，请检查");
                }
            }

        }
    }

    public static void prepareExpress(PrintExpress ptnEx,
    String senderPhone, String senderCompany, String senderAddr, String labTag,
    String custName, String custPhone, String custAddr, String custTag, String custTagReserved
    )
    {
        ptnEx.SenderPhone = senderPhone;
        ptnEx.SenderCompany = senderCompany;
        ptnEx.SenderAddr = senderAddr;
        ptnEx.LabTag = labTag;
        ptnEx.CustName = custName;
        ptnEx.CustPhone = custPhone;
        ptnEx.CustAddr = custAddr;
        ptnEx.CustTag = custTag;
        ptnEx.CustTagReserved = custTagReserved;
    }
}
