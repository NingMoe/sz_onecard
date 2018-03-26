using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using TM;
using Master;
using TDO.CardManager;
using System.Text;
using System.Collections.Generic;
using TDO.UserManager;

/// <summary>
/// CommonHelper 的摘要说明


/// </summary>
public class CommonHelper
{
    //查找是否记名卡


    public static void readCardJiMingState(CmnContext context, String cardNo, HiddenField hidIsJiMing)
    {
        if (cardNo.Substring(0, 6) == "215013" || cardNo.Substring(0, 6) == "215016")//吴江市民卡，张家港市民卡
        {
            hidIsJiMing.Value = "1";
            return;
        }
        string sql = string.Format("select count(*) from tf_f_cust_acct A, TD_GROUP_ACCT B where A.ACCT_ID = B.ACCT_ID and A.ICCARD_NO='{0}' and B.USETAG = '1'", cardNo);
        TMTableModule tmTMTableModule = new TMTableModule();
        DataTable dt = tmTMTableModule.selByPKDataTable(context, sql, 0);
        Object obj = dt.Rows[0].ItemArray[0];
        if (Convert.ToInt32(obj) > 0)//开通专有账户功能的，且专有账户功能有效的
        {
            hidIsJiMing.Value = "1";
            return;
        }
        //姓名、证件号字段两者均为非空


        //从持卡人资料表(TF_F_CUSTOMERREC)中读取数据

        //去掉持卡人资料的判断，2018-02-28 小额需求变更单_20180118-001修改.doc
        //TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECIn = new TF_F_CUSTOMERRECTDO();
        //ddoTF_F_CUSTOMERRECIn.CARDNO = cardNo;

        //DDOBase ddoBase = (DDOBase)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);

        ////UPDATE BY JIANGBB 2012-04-19解密
        //ddoBase = CommonHelper.AESDeEncrypt(ddoBase);
        //TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)ddoBase;
        ////TF_F_CUSTOMERRECTDO ddoTF_F_CUSTOMERRECOut = (TF_F_CUSTOMERRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTOMERRECIn, typeof(TF_F_CUSTOMERRECTDO), null);
        //if (!string.IsNullOrEmpty(ddoTF_F_CUSTOMERRECOut.CUSTNAME) && !string.IsNullOrEmpty(ddoTF_F_CUSTOMERRECOut.PAPERNO))
        //{
        //    hidIsJiMing.Value = "1";
        //    return;
        //}
        hidIsJiMing.Value = "0";
    }

    /// <summary>
    /// 验证余额是否超过上限
    /// </summary>
    /// <param name="context"></param>
    /// <param name="cardMoney">卡片余额</param>
    /// <param name="chargeMoney">充值金额</param>
    /// <param name="hidIsJiMing">是否记名标识 1记名 0不记名</param>
    /// <returns></returns>
    public static bool CheckMaxBalance(CmnContext context,Int32 cardMoney, Int32 chargeMoney, HiddenField hidIsJiMing)
    {
        if (hidIsJiMing.Value == "1")
        {
            if (cardMoney + chargeMoney > 500000)
            {
                context.AddError("苏州通卡余额上限5千元，此次充值不能完成，请您消费后再充值");
                return false;
            }
        }
        else
        {
            if (cardMoney + chargeMoney > 100000)
            {
                context.AddError("苏州通卡余额上限1千元，此次充值不能完成，请您消费后再充值");
                return false;
            }
        }
        return true;
    }

    //是否网点负责人




    public static bool IsDepartLead(Master.CmnContext context)
    {
        string sql = string.Format("select count(*) from TD_M_ROLEPOWER rp where rp.powercode='201007' and rp.powertype='2' and rp.roleno in( select ROLENO from TD_M_INSIDESTAFFROLE ti where ti.Staffno='{0}')", context.s_UserID);
        TMTableModule tmTMTableModule = new TMTableModule();
        DataTable dt = tmTMTableModule.selByPKDataTable(context, sql, 0);
        Object obj = dt.Rows[0].ItemArray[0];
        if (obj == DBNull.Value)
            return false;
        return Convert.ToInt32(obj) > 0;
    }
    //设置当前可打印打票代码和发票号码
    public static void SetInvoiceValues(Master.CmnContext context, Control volumetxt, Control invoicetxt)
    {
        string sql = string.Format("SELECT  VOLUMENO,INVOICENO  FROM TL_R_INVOICE tri where tri.ALLOTSTATECODE='02' and tri.usestatecode='00' and tri.ALLOTSTAFFNO='{0}' "
            + "  and allottime in (select min(allottime)  FROM TL_R_INVOICE tri where tri.ALLOTSTATECODE='02' and tri.usestatecode='00' and tri.ALLOTSTAFFNO='{0}' )  order by volumeno asc,invoiceno asc ", context.s_UserID);
        TMTableModule tmTMTableModule = new TMTableModule();
        DataTable data = tmTMTableModule.selByPKDataTable(context, sql, 0);
        if (data != null && data.Rows.Count > 0)
        {
            if (volumetxt is TextBox)
            {
                ((TextBox)volumetxt).Text = data.Rows[0][0].ToString();
            }
            if (invoicetxt is TextBox)
            {
                ((TextBox)invoicetxt).Text = data.Rows[0][1].ToString();
            }
            if (volumetxt is Label)
            {
                ((Label)volumetxt).Text = data.Rows[0][0].ToString();
            }
            if (invoicetxt is Label)
            {
                ((Label)invoicetxt).Text = data.Rows[0][1].ToString();
            }
        }
        else
        {
            if (volumetxt is TextBox)
            {
                ((TextBox)volumetxt).Text = "";
            }
            if (invoicetxt is TextBox)
            {
                ((TextBox)invoicetxt).Text = "";
            }
            if (volumetxt is Label)
            {
                ((Label)volumetxt).Text = "";
            }
            if (invoicetxt is Label)
            {
                ((Label)invoicetxt).Text = "";
            }
        }
    }

    //设置最近一笔已打印的打票代码和发票号码
    public static void SetInvoicedValues(Master.CmnContext context, Control volumetxt, Control invoicetxt)
    {
        string sql = string.Format("select * from (  SELECT  tri.VOLUMENO,tri.INVOICENO  FROM TL_R_INVOICE tri inner join TF_F_INVOICE f on f.invoiceno=tri.invoiceno and f.volumeno=tri.volumeno where  tri.ALLOTSTATECODE='02' and tri.usestatecode='01' and tri.ALLOTSTAFFNO='{0}'  order by f.operatetime desc) temp where rownum=1", context.s_UserID);
        TMTableModule tmTMTableModule = new TMTableModule();
        DataTable data = tmTMTableModule.selByPKDataTable(context, sql, 0);
        if (data != null && data.Rows.Count > 0)
        {
            if (volumetxt is TextBox)
            {
                ((TextBox)volumetxt).Text = data.Rows[0][0].ToString();
            }
            if (invoicetxt is TextBox)
            {
                ((TextBox)invoicetxt).Text = data.Rows[0][1].ToString();
            }
            if (volumetxt is Label)
            {
                ((Label)volumetxt).Text = data.Rows[0][0].ToString();
            }
            if (invoicetxt is Label)
            {
                ((Label)invoicetxt).Text = data.Rows[0][1].ToString();
            }
        }
        else
        {
            if (volumetxt is TextBox)
            {
                ((TextBox)volumetxt).Text = "";
            }
            if (invoicetxt is TextBox)
            {
                ((TextBox)invoicetxt).Text = "";
            }
            if (volumetxt is Label)
            {
                ((Label)volumetxt).Text = "";
            }
            if (invoicetxt is Label)
            {
                ((Label)invoicetxt).Text = "";
            }
        }
    }

    /// <summary>
    /// dataview中加密的字段解密
    /// </summary>
    /// <param name="dataview">需解密的dataview</param>
    /// <param name="list">需解密的字段</param>
    public static void AESDeEncrypt(DataView dataview, List<string> list)
    {

        StringBuilder strBuilder = new StringBuilder();

        if (list.Count == 0)
        {
            return;
        }

        for (int i = 0; i < dataview.Count; i++)
        {
            for (int s = 0; s < list.Count; s++)
            {
                if (dataview.Table.Columns.Contains(list[s]))
                {
                    strBuilder = new StringBuilder();
                    AESHelp.AESDeEncrypt(dataview[i][list[s]].ToString(), ref strBuilder);
                    dataview[i][list[s]] = strBuilder.ToString();
                }
            }
        }
    }

    /// <summary>
    /// datatable中加密的字段解密
    /// </summary>
    /// <param name="datatable">需解密的datatable</param>
    /// <param name="list">需解密的字段</param>
    public static void AESDeEncrypt(DataTable datatable, List<string> list)
    {

        StringBuilder strBuilder = new StringBuilder();

        if (list.Count == 0)
        {
            return;
        }

        for (int i = 0; i < datatable.Rows.Count; i++)
        {
            for (int s = 0; s < list.Count; s++)
            {
                if (datatable.Columns.Contains(list[s]))
                {
                    strBuilder = new StringBuilder();
                    AESHelp.AESDeEncrypt(datatable.Rows[i][list[s]].ToString(), ref strBuilder);
                    datatable.Rows[i][list[s]] = strBuilder.ToString();
                }
            }
        }
    }

    /// <summary>
    /// datatable中加密的字段解密。对于PAPERNAME字段值为000000000的不解密
    /// </summary>
    /// <param name="datatable">需解密的datatable</param>
    /// <param name="list">需解密的字段</param>
    public static void AESSpeDeEncrypt(DataTable datatable, List<string> list)
    {

        StringBuilder strBuilder = new StringBuilder();

        if (list.Count == 0)
        {
            return;
        }

        for (int i = 0; i < datatable.Rows.Count; i++)
        {
            for (int s = 0; s < list.Count; s++)
            {
                if (datatable.Columns.Contains(list[s]))
                {
                    if (list[s] == "PAPERNAME" && datatable.Rows[i][list[s]].ToString() == "000000000")
                    {
                        continue;
                    }
                    else
                    {
                        strBuilder = new StringBuilder();
                        AESHelp.AESDeEncrypt(datatable.Rows[i][list[s]].ToString(), ref strBuilder);
                        datatable.Rows[i][list[s]] = strBuilder.ToString();
                    }
                }
            }
        }
    }

    /// <summary>
    /// 加密字段解密
    /// </summary>
    /// <param name="ddoBase">数据表基类</param>
    /// <returns>解密之后的数据表</returns>
    public static DDOBase AESDeEncrypt(DDOBase ddoBase)
    {

        if (ddoBase == null)
        {
            return ddoBase;
        }

        StringBuilder strBuilder = new StringBuilder();

        List<string> list = new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" });
        for (int i = 0; i < ddoBase.Columns.Length; i++)
        {
            if (list.Contains(ddoBase.Columns[i][0]))
            {
                strBuilder = new StringBuilder();
                AESHelp.AESDeEncrypt(ddoBase.ArrayList.GetValue(i).ToString(), ref strBuilder);
                ddoBase.ArrayList.SetValue(strBuilder.ToString(), i);
            }
        }

        return ddoBase;

    }

    /// <summary>
    /// 加密字段解密
    /// </summary>
    /// <param name="text">加密内容</param>
    /// <returns>解密内容</returns>
    public static string DeEncrypt(string encryptValue)
    {
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESDeEncrypt(encryptValue, ref strBuilder);
        return strBuilder.ToString();
    }

    /// <summary>
    /// 明文字段加密
    /// </summary>
    /// <param name="text">明文内容</param>
    /// <returns>加密内容</returns>
    public static string Encrypt(string value)
    {
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(value, ref strBuilder);
        return strBuilder.ToString();
    }

    /// <summary>
    /// 取身份证格式
    /// </summary>
    /// <param name="paperNo">身份证号</param>
    /// <returns>加密身份证</returns>
    public static string GetPaperNo(string paperNo)
    {
        if (paperNo.Length == 18)   //第二代身份证
        {
            return paperNo.Substring(0, 12) + string.Empty.PadRight(6, '*');
        }
        else if (paperNo.Length == 15)  //第一代身份证
        {
            return paperNo.Substring(0, 9) + string.Empty.PadRight(6, '*');
        }
        else if (paperNo.Length > 2)    //超过2位的最后两位改*
        {
            return paperNo.Substring(0, paperNo.Length - 2) + string.Empty.PadRight(2, '*');
        }
        else
        {
            return paperNo;
        }
    }

    /// <summary>
    /// 取姓名格式
    /// </summary>
    /// <param name="custName">姓名</param>
    /// <returns>加密姓名</returns>
    public static string GetCustName(string custName)
    {
        if (custName.Length > 1)
        {
            return string.Empty.PadRight(1, '*') + custName.Substring(1, custName.Length-1);
        }
        else
        {
            return custName;
        }
    }

    /// <summary>
    /// 取联系电话
    /// </summary>
    /// <param name="custPhone">联系电话</param>
    /// <returns>加密联系电话</returns>
    public static string GetCustPhone(string custPhone)
    {
        if (custPhone.Length == 11)
        {
            return custPhone.Substring(0, 3) + string.Empty.PadRight(4, '*') + custPhone.Substring(7, 4);
        }
        else if (custPhone.Length > 2)
        {
            return custPhone.Substring(0, custPhone.Length - 2) + string.Empty.PadRight(2, '*');
        }
        else
        {
            return custPhone;
        }
    }

    /// <summary>
    /// 取联系地址
    /// </summary>
    /// <param name="custAddress">联系地址</param>
    /// <returns>取加密联系地址</returns>
    public static string GetCustAddress(string custAddress)
    {
        if (custAddress.Length > 3)
        {
            return custAddress.Substring(0, custAddress.Length - 3) + string.Empty.PadRight(3, '*');
        }
        else
        {
            return custAddress;
        }
    }

    /// <summary>
    /// 检查是否有权限
    /// </summary>
    /// <param name="context">上下文环境</param>
    /// <returns>当前用户是否有权限</returns>
    public static bool HasOperPower(CmnContext context)
    {
        //客户信息查看权限编码201015
        return HasOperPower(context, "201015");
    }

    /// <summary>
    /// 检查是否有权限
    /// </summary>
    /// <param name="context">上下文环境</param>
    /// <param name="powerCode">权限编码</param>
    /// <returns>当前用户是否有权限</returns>
    public static bool HasOperPower(CmnContext context,string powerCode)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
        string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
        DataTable dataSupply = tmTMTableModule.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
        if (dataSupply.Rows.Count > 0)
            return true;
        else
            return false;
    }


    public static bool CheckIDCard(string Id)
    {
        if (Id.Length == 18)
        {
            bool check = CheckIDCard18(Id);
            return check;
        }
        else if (Id.Length == 15)
        {
            bool check = CheckIDCard15(Id);
            return check;
        }
        else
        {
            return false;
        }
    }

    private static bool CheckIDCard18(string Id)
    {
        long n = 0;
        if (long.TryParse(Id.Remove(17), out n) == false || n < Math.Pow(10, 16) || long.TryParse(Id.Replace('x', '0').Replace('X', '0'), out n) == false)
        {
            return false;//数字验证
        }
        string address = "11x22x35x44x53x12x23x36x45x54x13x31x37x46x61x14x32x41x50x62x15x33x42x51x63x21x34x43x52x64x65x71x81x82x91";
        if (address.IndexOf(Id.Remove(2)) == -1)
        {
            return false;//省份验证
        }
        string birth = Id.Substring(6, 8).Insert(6, "-").Insert(4, "-");
        DateTime time = new DateTime();
        if (DateTime.TryParse(birth, out time) == false)
        {
            return false;//生日验证
        }
        string[] arrVarifyCode = ("1,0,x,9,8,7,6,5,4,3,2").Split(',');
        string[] Wi = ("7,9,10,5,8,4,2,1,6,3,7,9,10,5,8,4,2").Split(',');
        char[] Ai = Id.Remove(17).ToCharArray();
        int sum = 0;
        for (int i = 0; i < 17; i++)
        {
            sum += int.Parse(Wi[i]) * int.Parse(Ai[i].ToString());
        }
        int y = -1;
        Math.DivRem(sum, 11, out y);
        if (arrVarifyCode[y] != Id.Substring(17, 1).ToLower())
        {
            return false;//校验码验证
        }
        return true;//符合GB11643-1999标准
    }

    private static bool CheckIDCard15(string Id)
    {
        long n = 0;
        if (long.TryParse(Id, out n) == false || n < Math.Pow(10, 14))
        {
            return false;//数字验证
        }
        string address = "11x22x35x44x53x12x23x36x45x54x13x31x37x46x61x14x32x41x50x62x15x33x42x51x63x21x34x43x52x64x65x71x81x82x91";
        if (address.IndexOf(Id.Remove(2)) == -1)
        {
            return false;//省份验证
        }
        string birth = Id.Substring(6, 6).Insert(4, "-").Insert(2, "-");
        DateTime time = new DateTime();
        if (DateTime.TryParse(birth, out time) == false)
        {
            return false;//生日验证
        }
        return true;//符合15位身份证标准
    }

    public static bool allowCardtype(CmnContext context, string cardno, params string[] cardtypes)
    {
        if (cardno.Length != 16)
        {
            context.AddError("卡号必须是16位");
            return false;
        }
        else if (Common.Validation.isNum(cardno) == false)
        {
            context.AddError("卡号必须是数字");
            return false;
        }

        foreach (string cardtype in cardtypes)
        {
            if (cardtype == "5101")
            {
                if ("5101".Equals(cardno.Substring(4, 4)))
                {
                    context.AddError("不能在该页面办理旅游年卡相关业务!");
                }
            }

            if (cardtype == "5103")
            {
                if ("5103".Equals(cardno.Substring(4, 4)))
                {
                    context.AddError("不能在该页面办理世乒旅游卡相关业务!");
                }
            }
        }

        return !(context.hasError());
    }

}
