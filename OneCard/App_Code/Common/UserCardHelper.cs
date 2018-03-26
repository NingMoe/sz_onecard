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
using Common;
using TM;
using PDO.UserCard;
using System.Collections;
using System.IO;
using System.Text;

// 用户卡帮助类
public class UserCardHelper
{
    public static void validatePosNo(CmnContext context, TextBox txtBox, bool allowEmpty)
    {
        Validation valid = new Validation(context);
        txtBox.Text = txtBox.Text.Trim();
        bool isEmpty = true;
        if (allowEmpty)
        {
            isEmpty = Validation.isEmpty(txtBox);
        }
        else
        {
            isEmpty = !valid.notEmpty(txtBox, "PSAM不能为空");
        }

        if (!isEmpty)
        {
            bool b = valid.maxLength(txtBox, 6, "PSAM长度不能超过6位");
            if (b) valid.beNumber(txtBox, "PSAM必须为数字");
        }
    }

    public static void validateBalUnitNo(CmnContext context, TextBox txtBox, bool allowEmpty)
    {
        Validation valid = new Validation(context);
        txtBox.Text = txtBox.Text.Trim();
        bool isEmpty = true;
        if (allowEmpty)
        {
            isEmpty = Validation.isEmpty(txtBox);
        }
        else
        {
            isEmpty = !valid.notEmpty(txtBox, "结算单元编码不能为空");
        }

        if (!isEmpty)
        {
            bool b = valid.fixedLength(txtBox, 8, "结算单元编码长度必须是8位");
            if (b) valid.beAlpha(txtBox, "结算单元编码必须为字母或数字");
        }
    }

    public static void validatePSAM(CmnContext context, TextBox txtBox, bool allowEmpty)
    {
        Validation valid = new Validation(context);
        txtBox.Text = txtBox.Text.Trim();
        bool isEmpty = true;
        if (allowEmpty)
        {
            isEmpty = Validation.isEmpty(txtBox);
        }
        else
        {
            isEmpty = !valid.notEmpty(txtBox, "PSAM不能为空");
        }

        if (!isEmpty)
        {
            bool b = valid.fixedLength(txtBox, 12, "PSAM长度必须是12位");
            if (b) valid.beAlpha(txtBox, "PSAM必须为字母或数字");
        }
    }
    public static void validateSimNo(CmnContext context, TextBox txtBox, bool allowEmpty)
    {
        Validation valid = new Validation(context);
        txtBox.Text = txtBox.Text.Trim();
        bool isEmpty = true;
        if (allowEmpty)
        {
            isEmpty = Validation.isEmpty(txtBox);
        }
        else
        {
            isEmpty = !valid.notEmpty(txtBox, "SIM串号不能为空");
        }

        if (!isEmpty)
        {
            bool b = valid.fixedLength(txtBox, 20, "SIM串号长度必须是20位");
            if (b) valid.beAlpha(txtBox, "SIM串号必须为英数字");
        }
    }

    public static void validateCardNo(CmnContext context, TextBox txtBox, bool allowEmpty)
    {
        Validation valid = new Validation(context);
        txtBox.Text = txtBox.Text.Trim();
        bool isEmpty = true;
        if (allowEmpty)
        {
            isEmpty = Validation.isEmpty(txtBox);
        }
        else
        {
            isEmpty = !valid.notEmpty(txtBox, "A860P02001: 卡号不能为空");
        }

        if (!isEmpty)
        {
            bool b = valid.fixedLength(txtBox, 16, "A860P02002: 卡号长度必须是16位");
            if (b) valid.beNumber(txtBox, "A860P02003: 卡号必须为数字");
        }
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

    // 调用用户卡临时表创建存储过程来创建临时表
    public static void createTempTable(CmnContext context)
    {
        // context.DBOpen("Select");
        // context.ExecuteNonQuery("begin SP_UC_CreateTmp;end;");
    }

     // 选取拥有领用权限的员工，生成列表
    public static void selectAssignableStaffs(CmnContext context, DropDownList ddl,bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "AssignableStaffs");
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S002P02I01: 初始化领用员工列表失败");
        }
    }

    public static void selectAllStaffs(CmnContext context, DropDownList ddlStaffs, DropDownList ddlDepts, bool empty)
    {
        ddlStaffs.Items.Clear();

        if (empty)
            ddlStaffs.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddlStaffs, "AllStaffs", ddlDepts.SelectedValue);
    }

    public static void selectStaffs(CmnContext context, DropDownList ddlStaffs, DropDownList ddlDepts, bool empty)
    {
        ddlStaffs.Items.Clear();

        if (empty)
            ddlStaffs.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddlStaffs, "OnlineStaffs", ddlDepts.SelectedValue);
    }

    public static void selectDepts(CmnContext context, DropDownList ddlDepts, bool empty)
    {
        ddlDepts.Items.Clear();

        if (empty)
            ddlDepts.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddlDepts, "OnlineDepts");
    }

    //从资源状态编码表(TD_M_RESOURCESTATE)中读取数据，放入下拉列表中
    public static void selectResState(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "TD_M_RESOURCESTATE");
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S002P05I01: 初始化资源状态列表失败");
        }
    }


    // 初始化银行列表
    public static void selectBank(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "TD_M_BANK");
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S002P04I02: 初始化银行列表失败");
        }
    }


    // 初始化分配员工
    public static void selectDistStaff(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "DistributableStaffs", context.s_DepartID);
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S002P04I01: 初始化分配员工列表失败");
        }
    }

    //从IC卡芯片类型编码表(TD_M_CARDCHIPTYPE)中读取数据，放入下拉列表中
    public static void selectChipType(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "TD_M_CARDCHIPTYPE");
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S002P01I05: 初始化IC卡芯片类型列表失败");
        }
    }

    //从IC卡卡面编码表(TD_M_CARDSURFACE)中读取数据，放入下拉列表中
    public static void selectCardFace(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "TD_M_CARDSURFACE");
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S002P01I04: 初始化IC卡卡面类型列表失败");
        }
    }

    //从厂商编码表(TD_M_MANU)中读取数据，放入下拉列表中
    public static void selectManu(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "TD_M_MANU");
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S002P01I03: 初始化厂商列表失败");
        }
    }

    //从IC卡类型编码表(TD_M_CARDTYPE)中读取数据，放入下拉列表中
    public static void selectCardType(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "TD_M_CARDTYPE");
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S002P01I02: 初始化IC卡卡片类型列表失败");
        }
    }

    //从COS类型编码表(TD_M_COSTYPE)中读取数据，放入下拉列表中
    public static void selectCosType(CmnContext context, DropDownList ddl, bool empty)
    {
        if(empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "TD_M_COSTYPE");
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S002P01I01: 初始化COS类型列表失败");
        }
    }

    public static void select(CmnContext context, DropDownList ddl, string funcCode, params string[] vars)
    {
        SP_UC_QueryPDO pdo = new SP_UC_QueryPDO();
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
            li = new ListItem("" + itemArray[1] + ":" + itemArray[0], (String)itemArray[1]);
            ddl.Items.Add(li);
        }
    }

    // 校验日期
    public static void validateDate(CmnContext context, TextBox txt, bool required, string nullMsg, string fmtMsg)
    {
        Validation valid = new Validation(context);
        bool b = required ? valid.notEmpty(txt, nullMsg) : !Validation.isEmpty(txt);
        if (b) valid.beDate(txt, fmtMsg);
    }

    // 检验非空与英数
    public static void validateAlpha(CmnContext context, TextBox txt, string nullMsg, string fmtMsg)
    {
        Validation valid = new Validation(context);
        bool b = valid.notEmpty(txt, nullMsg);
        if (b) valid.beAlpha(txt, fmtMsg);
    }

    // 校验价格定义
    public static void validatePrice(CmnContext context, TextBox txtPrice, string nullMsg, string fmtMsg)
    {
        Validation valid = new Validation(context);
        //对卡片单价进行非空、数字检验
        bool b = valid.notEmpty(txtPrice, nullMsg);
        if (b) valid.bePrice(txtPrice, fmtMsg);
    }

    //检验超时金额
    public static void validatePrice(CmnContext context, string strPrice, string fmtMsg)
    {
        Validation valid = new Validation(context);
        //对超时金额进行数字检验
        valid.bePrice(strPrice, fmtMsg);
    }

    // 校验起始日期和结束日期
    public static void validateDateRange(CmnContext context, 
        TextBox txtEffDate, TextBox txtExpDate)
    {
        validateDateRange(context, txtEffDate, txtExpDate, true);
    }

    public static void validateDateRange(CmnContext context, 
        TextBox txtEffDate, TextBox txtExpDate, bool required)
    {
        Validation valid = new Validation(context);
        DateTime? dateEff = null, dateExp = null;
        //对起始日期进行非空和日期格式检验
        bool b = required ? valid.notEmpty(txtEffDate, "A002P01013: 起始日期不能为空")
                          : !Validation.isEmpty(txtEffDate);
        if (b) dateEff = valid.beDate(txtEffDate, "A002P01014: 起始日期格式不是yyyyMMdd");

        //对终止日期进行非空和日期格式检验
        b = required ? valid.notEmpty(txtExpDate, "A002P01015: 结束日期不能为空")
                     : !Validation.isEmpty(txtExpDate);
        if (b) dateExp = valid.beDate(txtExpDate, "A002P01016: 结束日期格式不是yyyyMMdd");

        //起始日期不能大于终止日期
        if (dateEff != null && dateExp != null)
        {
            valid.check(dateEff.Value.CompareTo(dateExp.Value) <= 0, "A002P01017: 起始日期不能大于结束日期");
        }
    }

    // 校验起始卡号和结束卡号的输入有效性(非空，长度16，数字）
    public static long validateCardNoRange(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo)
    {
        return validateCardNoRange(context, txtFromCardNo, txtToCardNo, true);
    }

    // 校验起始卡号和结束卡号的输入有效性(是否为空，非空时是否长度16与数字）
    public static long validateCardNoRange(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo,
        bool required)
    {
        return validateCardNoRange(context, txtFromCardNo, txtToCardNo, required, true);
    }

    public static long validateCardNoRange(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo,
        bool required, bool checkRange)
    {
        Validation valid = new Validation(context);
        long fromCard = -1, toCard = -1;
        long quantity = 0;

        //对起始卡号进行非空、长度、数字检验        bool b1 = required
            ? valid.notEmpty(txtFromCardNo, "A002P01001: 起始卡号不能为空")                // 起始卡号不能为空
            : !Validation.isEmpty(txtFromCardNo);
        if (b1) b1 = valid.fixedLength(txtFromCardNo, 16, "A002P01002: 起始卡号长度必须是16位"); // 起始卡号长度必须是16位
        if (b1) fromCard = valid.beNumber(txtFromCardNo, "A002P01003: 起始卡号必须是数字");  // 起始卡号必须是数
    
        //对终止卡号进行非空、长度、数字检验
        txtToCardNo.Text = txtToCardNo.Text.Trim();
        if (txtToCardNo.Text.Length == 0 && !context.hasError())
        {
            txtToCardNo.Text = txtFromCardNo.Text;
        }

        bool b2 = required
           ? valid.notEmpty(txtToCardNo, "A002P01004: 终止卡号不能为空")                 // 终止卡号不能为空
           : !Validation.isEmpty(txtToCardNo);
        if (b2) b2 = valid.fixedLength(txtToCardNo, 16, "A002P01005: 终止卡号必须是16位"); // 终止卡号长度必须是16位
        if (b2) toCard = valid.beNumber(txtToCardNo, "A002P01006: 终止卡号必须是数字");    // 终止卡号必须是数

        if (fromCard >= 0 && toCard >= 0)
        {
            quantity = toCard - fromCard + 1;

            if (checkRange)
            {
                b2 = valid.check(quantity > 0, "A002P01007: 起始卡号不能大于终止卡号");               // 终止卡号不能小于起始卡号
                if (b2) valid.check(quantity <= 10000, "A002P01008: 终止卡号不能超过起始卡号10000");        // 终止卡号不能超过起始卡号10000以上
            }
        }
        return quantity;
    }

    public static void UploadFile(CmnContext context, FileUpload FileUpload1, string sessionID)
    {
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
            fields = strLine.Split(new char[] { ',', '\t','-' });

            // 字段数目为2时合法

            if (fields.Length > 2)
            {
                context.AddError("第" + lineCount + "行字段数目为"
                    + fields.Length + ", 根据格式定义必须不超过2");
                continue;
            }

            dealFile(ht, context, sessionID, fields, lineCount);
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

    public static void dealFile(Hashtable ht, CmnContext context, string sessionID,
        String[] fields, int lineCount)
    {
        String BegincardNo = fields[0].Trim();
        // 卡号
        if (Validation.strLen(BegincardNo) != 16)
        {
            context.AddError("第" + lineCount + "行卡号长度不是16位");
        }
        else if (!Validation.isNum(BegincardNo))
        {
            context.AddError("第" + lineCount + "行卡号不全是数字");
        }
        else if (ht.ContainsKey(BegincardNo))
        {
            context.AddError("第" + lineCount + "行卡号重复");
            return;
        }
        ht.Add(BegincardNo, "");

        if (fields.Length > 1)
        {
            String EndcardNo = fields[1].Trim();
            // 卡号
            if (Validation.strLen(EndcardNo) != 16)
            {
                context.AddError("第" + lineCount + "行卡号长度不是16位");
            }
            else if (!Validation.isNum(EndcardNo))
            {
                context.AddError("第" + lineCount + "行卡号不全是数字");
            }
            else if (ht.ContainsKey(EndcardNo))
            {
                context.AddError("第" + lineCount + "行卡号重复");
                return;
            }
            ht.Add(EndcardNo, "");

            if (!context.hasError())
            {
                context.ExecuteNonQuery("insert into TMP_COMMON(f0, f1) values('"
                    + BegincardNo + "', '" + EndcardNo + "')");
            }
        }

        else
        {
            if (!context.hasError())
            {
                context.ExecuteNonQuery("insert into TMP_COMMON(f0) values('"
                    + BegincardNo + "')");
            }
        }

        
    }


    public static void selectCardTax(CmnContext context, DropDownList ddl, bool empty)
    {
        if (empty)
            ddl.Items.Add(new ListItem("---请选择---", ""));

        select(context, ddl, "TD_M_CARDTAX");
        if (!empty && ddl.Items.Count == 0)
        {
            context.AddError("S002P01I02: 初始化卡片税率列表失败");
        }
    }
}
