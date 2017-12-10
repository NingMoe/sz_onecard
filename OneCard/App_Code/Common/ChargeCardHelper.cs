using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Common;
using Master;
using TM;
using PDO.ChargeCard;

// 充值卡公共处理函数
public class ChargeCardHelper
{
    // 创建充值卡临时表
    public static void createTempTable(CmnContext context)
    {
        // context.DBOpen("Select");
        // context.ExecuteNonQuery("begin SP_CC_CreateTmp; end;");
    }

    public static DataTable callQuery(CmnContext context, string funcCode, params string[] vars)
    {
        SP_CC_QueryPDO pdo = new SP_CC_QueryPDO();
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

            }
        }

        StoreProScene storePro = new StoreProScene();

        return storePro.Execute(context, pdo);
    }

    // 检查起始卡号和结束卡号中间的差片是否有相同面值
    public static bool hasSameFaceValue(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo)
    {
        DataTable data = callQuery(context, "F1", txtFromCardNo.Text, txtToCardNo.Text);
        if (data.Rows.Count != 1)
        {
            context.AddError("A007P01211: 位于起始卡号和终止卡号之间的充值卡不具有相同面值，请重新选择起讫卡号");
            return false;
        }
        return true;
    }

    // 检查起始卡号和结束卡号中间的差片是否有相同类型

    public static bool hasSameTypeValue(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo)
    {
        DataTable data = callQuery(context, "hasSameTypeValue", txtFromCardNo.Text, txtToCardNo.Text);
        if (data.Rows.Count != 1)
        {
            context.AddError("A007P01211: 位于起始卡号和终止卡号之间的充值卡不具有相同类型，请重新选择起讫卡号");
            return false;
        }
        return true;
    }

    // 检查卡片类型

    public static string  CardTypeValue(CmnContext context, TextBox txtFromCardNo)
    {
        DataTable data = callQuery(context, "cardTypeValue", txtFromCardNo.Text);
        string cardType = (string)(data.Rows[0].ItemArray[0]);

        return cardType;
    }

    //检查起始卡号和结束卡号中间的差片是否有相同面值、订单面额和出库卡号面额是否相同
    public static bool hasSameFaceValue(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo,string valuecode)
    {
        DataTable data = callQuery(context, "F1", txtFromCardNo.Text, txtToCardNo.Text);
        if (data.Rows.Count != 1)
        {
            context.AddError("A007P01211: 位于起始卡号和终止卡号之间的充值卡不具有相同面值，请重新选择起讫卡号");
            return false;
        }
        else
        {
            if (valuecode.ToLower() != data.Rows[0][0].ToString().ToLower())
            {
                context.AddError("领用单中的面额和出库的卡片面额不相同");
                return false;
            }
        }
        return true;
    }

    // 查询卡号范围内是否有卡片售出
    public static int validateCardSold(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo)
    {
        DataTable data = callQuery(context, "F0", txtFromCardNo.Text, txtToCardNo.Text);

        decimal num = (decimal)(data.Rows[0].ItemArray[0]);

        if (num > 0)
        {
            context.AddError("A007P01212: 位于起始卡号和终止卡号之间的充值卡已有卡片售出，请重新选择起讫卡号");
        }

        return (int)num;
    }
    
    // 查询可售状态卡片的数量
    public static int queryCountOfSalable(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo)
    {
        DataTable data = callQuery(context, "F21", txtFromCardNo.Text, txtToCardNo.Text);

        decimal num = (decimal)(data.Rows[0].ItemArray[0]);

        return (int)num;
    }

    // 查询入库状态卡片的数量
    public static int queryCountOfStockOut(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo)
    {
        DataTable data = callQuery(context, "F20", txtFromCardNo.Text, txtToCardNo.Text);

        decimal num = (decimal)(data.Rows[0].ItemArray[0]);

        return (int)num;
    }

    // 查询当前员工所属部门下卡片的数量
    public static int queryCountOfAssignDepart(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo)
    {
        DataTable data = callQuery(context, "F24", txtFromCardNo.Text, txtToCardNo.Text,context.s_DepartID);

        decimal num = (decimal)(data.Rows[0].ItemArray[0]);

        return (int)num;
    }
    

    // 查询可批量直销状态卡片的数量
    public static int queryCountOfBatchSalable(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo)
    {
        DataTable data = callQuery(context, "F22", txtFromCardNo.Text, txtToCardNo.Text);

        decimal num = (decimal)(data.Rows[0].ItemArray[0]);

        return (int)num;
    }
    
    // 根据状态来查询起始卡号和结束卡号之间的卡片数量
    public static int queryCountByState(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo, string state)
    {
        DataTable data = callQuery(context, "F2", txtFromCardNo.Text, txtToCardNo.Text, state);

        decimal num = (decimal)(data.Rows[0].ItemArray[0]);

        return (int)num;
    }

    // 查询起始卡号和结束卡号之间的总面值
    public static decimal queryTotalValue(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo)
    {
        DataTable data = callQuery(context, "F3", txtFromCardNo.Text, txtToCardNo.Text);
        Object obj = data.Rows[0].ItemArray[0];

        decimal count = 0;
        if (!Convert.IsDBNull(obj))
        {
            count = (decimal)obj;
        }

        return count;
    }

    // 查询单张卡号的面值
    public static decimal queryUnitValue(CmnContext context, TextBox txtFromCardNo)
    {
        DataTable data = callQuery(context, "F4", txtFromCardNo.Text);

        Object obj = data.Rows[0].ItemArray[0];

        decimal count = 0;
        if (!Convert.IsDBNull(obj))
        {
            count = (decimal)obj;
        }

        return count;
    }

    // 校验起始卡号和结束卡号的输入有效性(非空，长度14，英数）
    public static long validateCardNoRange(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo)
    {
        return validateCardNoRange(context, txtFromCardNo, txtToCardNo, true);
    }

    public static void validateCardNo(CmnContext context, TextBox cardNo, string errCode)
    {
        if (!validateCardNo(cardNo.Text))
        {
            context.AddError(errCode);
        }
    }

    public static bool validateCardNo(string cardNo)
    {
        // 充值卡号,第1,2位表示年份,数字;第3,4位表示批次号,数字;
        // 第5位表示面值,字母;第6位表示厂商,字母;后8位是递增的序号.
        for (int i = 0; i < 4; ++i)
        {
            if (cardNo[i] > '9' || cardNo[i] < '0')
            {
                return false;
            }
        }
        for (int i = 4; i < 6; ++i )
        {
            if ( !(cardNo[i] >= 'a' && cardNo[i] <= 'z' 
                || cardNo[i] >= 'A' && cardNo[i] <= 'Z'))
                return false;
        }

        for (int i = 6; i < 14; ++i)
        {
            if (cardNo[i] > '9' || cardNo[i] < '0')
            {
                return false;
            }
        }

        return true;
    }



    // 校验起始卡号和结束卡号的输入有效性(是否为空，非空时是否长度14与英数）
    public static long validateCardNoRange(CmnContext context, TextBox txtFromCardNo, TextBox txtToCardNo,
        bool required)
    {
        Validation valid = new Validation(context);
        long fromCard = -1, toCard = -1;

        //对起始卡号进行非空、长度、英数检验

        bool b1 = required
            ? valid.notEmpty(txtFromCardNo, "A007P01001: 起始卡号不能为空")
            : !Validation.isEmpty(txtFromCardNo);
        if (b1) b1 = valid.fixedLength(txtFromCardNo, 14, "A007P01002: 起始卡号长度必须是14位");
        if (b1) validateCardNo(context, txtFromCardNo, "A007P01003: 起始卡号格式不正确");

        //对终止卡号进行非空、长度、英数检验
        txtToCardNo.Text = txtToCardNo.Text.Trim();
        if (txtToCardNo.Text.Length == 0 && !context.hasError())
        {
            txtToCardNo.Text = txtFromCardNo.Text;
        }

        bool b2 = required
            ? valid.notEmpty(txtToCardNo, "A007P01004: 终止卡号不能为空")
             : !Validation.isEmpty(txtToCardNo);
        if (b2) b2 = valid.fixedLength(txtToCardNo, 14, "A007P01005: 终止卡号长度必须是14位");
        if (b2) validateCardNo(context, txtToCardNo, "A007P01006: 终止卡号格式不正确");

        if (context.hasError())
        {
            return 0;
        }

        if (b1)
            fromCard = Convert.ToInt64(txtFromCardNo.Text.Substring(6, 8));

        if (b2)
            toCard = Convert.ToInt64(txtToCardNo.Text.Substring(6, 8));
        long quantity = 0;
        // 0 <= 终止卡号-起始卡号 <= 100000
        if (fromCard >= 0 && toCard >= 0)
        {
            quantity = toCard - fromCard + 1;
            b1 = valid.check(quantity > 0, "A007P01007: 终止卡号不能小于起始卡号");
            if (b1) valid.check(quantity <= 10000, "A007P01008: 终止卡号不能超过起始卡号10000以上");
        }

        return quantity;
    }
}
