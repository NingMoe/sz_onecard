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
using Common;
using PDO.AdditionalService;
using Controls.Customer.Asp;

// 附加业务帮助类

public class ASHelper
{
    public static void initPaperTypeList(CmnContext context, DropDownList lst)
    {
        DataTable dt = ASHelper.callQuery(context, "ReadPaperCodeName");
      
        GroupCardHelper.fill(lst, dt, true);
    }

    //读取轨交黑灰名单类型名称
    public static void initBlackListTypeList(CmnContext context, DropDownList lst)
    {
        DataTable dt = ASHelper.callQuery(context, "ReadBlackListCodeName");

        GroupCardHelper.fill(lst, dt, true);
    }

    public static void initPackageTypeList(CmnContext context, DropDownList lst)
    {
        DataTable dt = ASHelper.callQuery(context, "ReadPackageCodeName");
        GroupCardHelper.fill(lst, dt, true);
    }
    public static void initMonthlyCardTypeList(DropDownList lst)
    {
        lst.Items.Add(new ListItem("---请选择---", ""));
        lst.Items.Add(new ListItem("01:学生月票", "01"));
        lst.Items.Add(new ListItem("02:老人月票", "02"));
        lst.Items.Add(new ListItem("03:高龄卡", "03"));
        //2011/9/23 增加残疾人爱心卡
        lst.Items.Add(new ListItem("04:残疾人爱心卡", "04"));
        //2014-03-10增加劳模卡
        lst.Items.Add(new ListItem("05:劳模卡","05"));
        //20140526增加教育卡
        lst.Items.Add(new ListItem("06:教育卡", "06"));
        //20160822增加献血卡
        lst.Items.Add(new ListItem("07:献血卡", "07"));
        //20170904增加优抚卡
        lst.Items.Add(new ListItem("08:优抚卡", "08"));
        //20171206增加公交职工卡
        lst.Items.Add(new ListItem("09:公交职工卡", "09"));
    }

    public static void initSexList(DropDownList lst)
    {
        initSexList(lst, true);
    }

    public static void initSexList(DropDownList lst, bool allowEmpty)
    {
        if (allowEmpty) lst.Items.Add(new ListItem("---请选择---", ""));
        lst.Items.Add(new ListItem("0:男", "0"));
        lst.Items.Add(new ListItem("1:女", "1"));
    }

    // 读取园林年卡可用次数
    public static String readParkTimes(CmnContext context)
    {
        // 从全局参数表中读取园林年卡的次数设置

        DataTable data = callQuery(context, "ParkNum");
        if (data.Rows.Count == 0)
        {
            context.AddError("S00501B002: 缺少系统参数-园林年卡总共次数");
            return "0";
        }
        Object[] row = data.Rows[0].ItemArray;
        return "" + row[0];
    }

    // 读取吴江旅游年卡可用次数 ADD BY JIANGBB 2012-05-02
    public static String readTravelTimes(CmnContext context)
    {
        // 从全局参数表中读取吴江旅游年卡的次数设置

        DataTable data = callQuery(context, "TravelWJTimes");
        if (data.Rows.Count == 0)
        {
            context.AddError("S00601B001: 缺少系统参数-吴江旅游年卡总共次数");
            return "0";
        }
        Object[] row = data.Rows[0].ItemArray;
        return "" + row[0];
    }

    // 读取休闲年卡可用次数
    public static String readXXParkTimes(CmnContext context)
    {
        // 从全局参数表中读取休闲年卡的次数设置

        DataTable data = ASHelper.callQuery(context, "XXParkNum");
        if (data.Rows.Count == 0)
        {
            context.AddError("S00505B002: 缺少系统参数-休闲年卡总共次数");
            return "0";
        }
        Object[] row = data.Rows[0].ItemArray;
        return (string)row[0];
    }

    // 读取亲子卡可用次数
    public static String readAffectParkTimes(CmnContext context)
    {
        // 从全局参数表中读取休闲年卡的次数设置

        DataTable data = ASHelper.callQuery(context, "AffectParkNum");
        if (data.Rows.Count == 0)
        {
            context.AddError("S00505B003: 缺少系统参数-亲子卡总共次数");
            return "0";
        }
        Object[] row = data.Rows[0].ItemArray;
        return (string)row[0];
    }

    // 设置损坏类型
    public static void setChangeReason(DropDownList selReasonType, bool allowEmpty)
    {
        if (allowEmpty) selReasonType.Items.Add(new ListItem("---请选择---", ""));
        selReasonType.Items.Add(new ListItem("13:可读自然损坏卡", "13"));
        selReasonType.Items.Add(new ListItem("12:可读人为损坏卡", "12"));
        selReasonType.Items.Add(new ListItem("14:不可读人为损坏卡", "14"));
        selReasonType.Items.Add(new ListItem("15:不可读自然损坏卡", "15"));
    }

    public static void prepareShouJu(PrintShouJu ptnShouJu, String cardNo, String name, String price)
    {
        //收据
        ptnShouJu.CardNo = cardNo;
        ptnShouJu.StaffName = name;
        ptnShouJu.Price = ConvertNumChn.ConvertSum(price);
        DateTime now = DateTime.Now;
        ptnShouJu.Year = now.ToString("yyyy");
        ptnShouJu.Month = now.ToString("MM");
        ptnShouJu.Day = now.ToString("dd");

    }

    public static void preparePingZheng(PrintPingZheng ptnPZ,
        String cardNo, String custName,
        String tradeTypeName, String tradeMoney,
        String deposit, String custAcc, String custPaperNo,
        String balance, String depreciationFee, String totalFee, String staffName,
        String tradeMode, String paperTypeName, String handlingCharge, String other
        )
    {
        DateTime now = DateTime.Now;
        ptnPZ.Year = now.ToString("yyyy");
        ptnPZ.Month = now.ToString("MM");
        ptnPZ.Day = now.ToString("dd");
        ptnPZ.CardNo = cardNo;
        ptnPZ.UserName = custName;
        ptnPZ.JiaoYiLeiXing = tradeTypeName;
        ptnPZ.JiaoYiJinE = tradeMoney;
        ptnPZ.KaYaJin = deposit;
        ptnPZ.ZhangHao = custAcc;


        ptnPZ.ZhengJianHaoMa = custPaperNo;
        ptnPZ.JiJuHao = "112233445566";
        ptnPZ.ICKaYuE = balance;
        ptnPZ.ZheJiuFei = depreciationFee;

        ptnPZ.ZongJinEChina = ConvertNumChn.ConvertSum(totalFee);
        ptnPZ.ZongJinE = totalFee;
        ptnPZ.StaffName = staffName;

        ptnPZ.JiaoYiFangShi = tradeMode;
        ptnPZ.ZhengJianMingChen = paperTypeName;
        ptnPZ.LiuShuiHao = "";
        ptnPZ.ShouXuFei = handlingCharge;
        ptnPZ.Other = other;
    }

    //增加轨交次数
    public static void preparePingZheng(PrintPingZheng ptnPZ,
     String cardNo, String custName,
     String tradeTypeName, String tradeMoney,
     String deposit, String custAcc, String custPaperNo,
     String balance, String depreciationFee, String totalFee, String staffName,
     String tradeMode, String paperTypeName, String handlingCharge, String other, String railTimes
     )
    {
        DateTime now = DateTime.Now;
        ptnPZ.Year = now.ToString("yyyy");
        ptnPZ.Month = now.ToString("MM");
        ptnPZ.Day = now.ToString("dd");
        ptnPZ.CardNo = cardNo;
        ptnPZ.UserName = custName;
        ptnPZ.JiaoYiLeiXing = tradeTypeName;
        ptnPZ.JiaoYiJinE = tradeMoney;
        ptnPZ.KaYaJin = deposit;
        ptnPZ.ZhangHao = custAcc;


        ptnPZ.ZhengJianHaoMa = custPaperNo;
        ptnPZ.JiJuHao = "112233445566";
        ptnPZ.ICKaYuE = balance;
        ptnPZ.ZheJiuFei = depreciationFee;

        ptnPZ.ZongJinEChina = ConvertNumChn.ConvertSum(totalFee);
        ptnPZ.ZongJinE = totalFee;
        ptnPZ.StaffName = staffName;

        ptnPZ.JiaoYiFangShi = tradeMode;
        ptnPZ.ZhengJianMingChen = paperTypeName;
        ptnPZ.LiuShuiHao = "";
        ptnPZ.ShouXuFei = handlingCharge;
        ptnPZ.Other = other;
        ptnPZ.RailTimes = railTimes;
    }

    public static void preparePingZheng(PrintRMPingZheng ptnPZ,
       String cardNo, String custName,
       String tradeTypeName, String tradeMoney,
       String deposit, String custAcc, String custPaperNo,
       String balance, String depreciationFee, String totalFee, String staffName,
       String tradeMode, String paperTypeName, String handlingCharge, String other
       )
    {
        DateTime now = DateTime.Now;
        ptnPZ.Year = now.ToString("yyyy");
        ptnPZ.Month = now.ToString("MM");
        ptnPZ.Day = now.ToString("dd");
        ptnPZ.CardNo = cardNo;
        ptnPZ.UserName = custName;
        ptnPZ.JiaoYiLeiXing = tradeTypeName;
        ptnPZ.JiaoYiJinE = tradeMoney;
        ptnPZ.KaYaJin = deposit;
        ptnPZ.ZhangHao = custAcc;


        ptnPZ.ZhengJianHaoMa = custPaperNo;
        ptnPZ.JiJuHao = "112233445566";
        ptnPZ.ICKaYuE = balance;
        ptnPZ.ZheJiuFei = depreciationFee;

        ptnPZ.ZongJinEChina = ConvertNumChn.ConvertSum(totalFee);
        ptnPZ.ZongJinE = totalFee;
        ptnPZ.StaffName = staffName;

        ptnPZ.JiaoYiFangShi = tradeMode;
        ptnPZ.ZhengJianMingChen = paperTypeName;
        ptnPZ.LiuShuiHao = "";
        ptnPZ.ShouXuFei = handlingCharge;
        ptnPZ.Other = other;
    }

    public static void preparePingZheng(PrintHMXXPingZheng ptnPZ,
      String wangDian, String staffName, String tradeTypeName,
      String liuShuiHao, String tradeMoney, String shouFei, String cardNo,
      String YouXiaoQi)
    {
        DateTime now = DateTime.Now;
        ptnPZ.Date = now.ToString("yyyy-MM-dd");
        ptnPZ.WangDian = wangDian;
        ptnPZ.StaffName = staffName;
        ptnPZ.LiuShuiHao = liuShuiHao;

        ptnPZ.YeWuLeiXing = tradeTypeName;
        ptnPZ.FaShengJinE = tradeMoney;
        ptnPZ.CardNo = cardNo;
        ptnPZ.ShouFei = shouFei;
        ptnPZ.YouXiaoQi = YouXiaoQi;
    }
    //抽奖换乘打印凭证数据 add by youyue 20140729
    public static void prepareTLPingZheng(PrintTLPingZheng ptnPZ,
      String wangDian, String staffName, String tradeTypeName,
      String cardNo, String awardCardNo, String jiangXiang, String Money, String Tax,
      String custName, String custPaperType, String custPaperNo, String custPhone)
    {
        DateTime now = DateTime.Now;
        ptnPZ.Date = now.ToString("yyyy-MM-dd");
        ptnPZ.WangDian = wangDian;
        ptnPZ.StaffName = staffName;

        ptnPZ.YeWuLeiXing = tradeTypeName; 
        ptnPZ.CardNo = cardNo;
        ptnPZ.AwardCardNo = awardCardNo;
        ptnPZ.JiangXiang = jiangXiang;
        ptnPZ.Money = Money;
        ptnPZ.Tax = Tax;

        ptnPZ.CustName = custName;
        ptnPZ.CustPaperNo = custPaperNo;
        ptnPZ.CustPaperType = custPaperType;
        ptnPZ.CustPhone = custPhone;

    }
    //抽奖换乘热敏打印凭证数据 add by youyue 20140819
    public static void prepareTLRMPingZheng(PrintTLRMPingZheng ptnPZ,
      String wangDian, String staffName, String tradeTypeName,
      String cardNo, String awardCardNo, String jiangXiang, String Money, String Tax,
      String custName, String custPaperType, String custPaperNo, String custPhone)
    {
        DateTime now = DateTime.Now;
        ptnPZ.Year = now.ToString("yyyy");
        ptnPZ.Month = now.ToString("MM");
        ptnPZ.Day = now.ToString("dd");
        ptnPZ.WangDian = wangDian;
        ptnPZ.StaffName = staffName;

        ptnPZ.YeWuLeiXing = tradeTypeName;
        ptnPZ.CardNo = cardNo;
        ptnPZ.AwardCardNo = awardCardNo;
        ptnPZ.JiangXiang = jiangXiang;
        ptnPZ.Money = Money;
        ptnPZ.Tax = Tax;

        ptnPZ.CustName = custName;
        ptnPZ.CustPaperNo = custPaperNo;
        ptnPZ.CustPaperType = custPaperType;
        ptnPZ.CustPhone = custPhone;

    }

    public static void changeCardQueryValidate(CmnContext context, TextBox txtPaperNo, TextBox txtCardNo,
        TextBox txtCustName)
    {
        Validation valid = new Validation(context);
        txtCustName.Text = txtCustName.Text.Trim();
        valid.check(Validation.strLen(txtCustName.Text) <= 50, "A005010001, 客户姓名长度不能超过50");

        bool b = Validation.isEmpty(txtPaperNo);
        if (!b)
        {
            b = valid.check(Validation.strLen(txtPaperNo.Text) <= 20, "A005010006: 证件号码位数必须小于等于20");
            if (b)
            {
                valid.beAlpha(txtPaperNo, "A005010007: 证件号码必须是英文或者数字");
            }
        }

        b = Validation.isEmpty(txtCardNo);
        if (!b)
        {
            b = valid.check(Validation.strLen(txtCardNo.Text) <= 16, "A00502A003: 旧卡卡号位数必须小于等于16");
            if (b)
            {
                valid.beNumber(txtCardNo, "A00502A004: 旧卡卡号必须是数字");
            }
        }
    }

    public static string toDateWithHyphen(string dateString)
    {
        return dateString.Substring(0, 4)
            + "-" + dateString.Substring(4, 2)
            + "-" + dateString.Substring(6, 2);
    }

    public static string toDateWithoutHyphen(string dateString)
    {
        return dateString.Substring(0, 4) +
            dateString.Substring(5, 2) + dateString.Substring(8, 2);
    }

    public static string toTimeWithHyphen(string timeString)
    {
        return timeString.Substring(0, 2)
            + ":" + timeString.Substring(2, 2)
            + ":" + timeString.Substring(4, 2);
    }

    public static string toTimeWithoutHyphen(string timeString)
    {
        return timeString.Substring(0, 2) +
            timeString.Substring(3, 2) + timeString.Substring(6, 2);
    }

    public static string getCellValue(Object obj)
    {
        return (obj == DBNull.Value ? "" : (string)obj);
    }

    public static decimal ToDecimal(object value)
    {
        try
        {
            return Convert.ToDecimal(value);
        }
        catch
        {
            return 0;
        }
    }

    public static DataTable callQuery(CmnContext context, string funcCode, params string[] vars)
    {
        SP_AS_QueryPDO pdo = new SP_AS_QueryPDO();
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

    // 选取行政区域列表
    public static void SelectDistricts(CmnContext context, DropDownList ddl, string appType)
    {
        DataTable data = ASHelper.callQuery(context, "ReadAppArea", appType);
        ddl.Items.Clear();
        GroupCardHelper.fill(ddl, data, true);
    }

    // 读取园林信息
    public static void readGardenInfo(CmnContext context, TextBox txtCardNo,
        Label labDbExpDate, Label labDbUsableTimes, Label labDbOpenTimes)
    {
        DataTable data = callQuery(context, "ReadParkInfo", txtCardNo.Text);
        if (data.Rows.Count != 1)
        {
            context.AddError("A005040001: 当前卡片不是有效的园林年卡");
            return;
        }
        Object[] row = data.Rows[0].ItemArray;
        if (Convert.IsDBNull(row[0]))
        {
            context.AddError("库有效期为空");
            return;
        }
        string endDate = (string)row[0];

        String today = DateTime.Now.ToString("yyyyMMdd");
        if (endDate.CompareTo(today) < 0)
        {
            context.AddError("A005040002: 当前卡片园林年卡功能已经到期");
        }

        labDbExpDate.Text = endDate;
        labDbUsableTimes.Text = "" + row[1];
        labDbOpenTimes.Text = "" + row[2];
    }

    // 读取吴江旅游年卡信息 add by jiangbb 2012-05-02
    public static void readTravelInfo(CmnContext context, TextBox txtCardNo,
        Label labDbExpDate, Label labDbUsableTimes, Label labDbOpenTimes)
    {
        DataTable data = callQuery(context, "ReadTravelInfo", txtCardNo.Text);
        if (data.Rows.Count != 1)
        {
            context.AddError("A006010002: 当前卡片不是有效的吴江旅游年卡");
            return;
        }
        Object[] row = data.Rows[0].ItemArray;
        if (Convert.IsDBNull(row[0]))
        {
            context.AddError("库有效期为空");
            return;
        }
        string endDate = (string)row[0];

        String today = DateTime.Now.ToString("yyyyMMdd");
        if (endDate.CompareTo(today) < 0)
        {
            context.AddError("A006010003: 当前卡片吴江旅游年卡功能已经到期");
        }

        labDbExpDate.Text = endDate;
        labDbUsableTimes.Text = "" + row[1];
        labDbOpenTimes.Text = "" + row[2];
    }

    public static void readGardenInfo(CmnContext context, TextBox txtCardNo,
        Label labDbExpDate, Label labDbUsableTimes, Label labDbOpenTimes, Label labUpdateStaff, Label labUpdateTime)
    {
        DataTable data = callQuery(context, "ReadParkInfo", txtCardNo.Text);
        if (data.Rows.Count != 1)
        {
            context.AddError("A005040001: 当前卡片不是有效的园林年卡");
            return;
        }
        Object[] row = data.Rows[0].ItemArray;
        if (Convert.IsDBNull(row[0]))
        {
            context.AddError("库有效期为空");
            return;
        }
        string endDate = (string)row[0];

        String today = DateTime.Now.ToString("yyyyMMdd");
        if (endDate.CompareTo(today) < 0)
        {
            context.AddError("A005040002: 当前卡片园林年卡功能已经到期");
        }

        labDbExpDate.Text = endDate;
        labDbUsableTimes.Text = "" + row[1];
        labDbOpenTimes.Text = "" + row[2];
        labUpdateStaff.Text = "" + row[3];
        labUpdateTime.Text = "" + row[4];
    }

    // 读取休闲信息
    public static void readRelaxInfo(CmnContext context, TextBox txtCardNo,
        Label labDbExpDate, Label labDbUsableTimes, Label labDbOpenTimes)
    {
        DataTable data = callQuery(context, "ReadXXParkInfo", txtCardNo.Text);
        if (data.Rows.Count != 1)
        {
            context.AddError("A005080001: 当前卡片不是有效的休闲年卡");
            return;
        }
        Object[] row = data.Rows[0].ItemArray;
        if (Convert.IsDBNull(row[0]))
        {
            context.AddError("库有效期为空");
            return;
        }
        string endDate = (string)row[0];

        String today = DateTime.Now.ToString("yyyyMMdd");
        if (endDate.CompareTo(today) < 0)
        {
            context.AddError("A005080002: 当前卡片休闲年卡功能已经到期");
        }

        labDbExpDate.Text = endDate;
        labDbUsableTimes.Text = "" + row[1];
        labDbOpenTimes.Text = "" + row[2];
    }

    public static void readRelaxInfo(CmnContext context, TextBox txtCardNo,
    Label labDbExpDate, Label labDbUsableTimes, Label labDbOpenTimes, Label labUpdateStaff, Label labUpdateTime, Label labAccountType)
    {
        DataTable data = callQuery(context, "ReadXXParkInfo", txtCardNo.Text);
        if (data.Rows.Count != 1)
        {
            context.AddError("A005080001: 当前卡片不是有效的休闲年卡");
            return;
        }
        Object[] row = data.Rows[0].ItemArray;
        if (Convert.IsDBNull(row[0]))
        {
            context.AddError("库有效期为空");
            return;
        }
        string endDate = (string)row[0];

        String today = DateTime.Now.ToString("yyyyMMdd");
        if (endDate.CompareTo(today) < 0)
        {
            context.AddError("A005080002: 当前卡片休闲年卡功能已经到期");
        }

        labDbExpDate.Text = endDate;
        labDbUsableTimes.Text = "" + row[1];
        labDbOpenTimes.Text = "" + row[2];
        labUpdateStaff.Text = "" + row[3];
        labUpdateTime.Text = "" + row[4];
        labAccountType.Text = "" + row[5];
    }

    public static void readRelaxOrGardenInfo(CmnContext context, TextBox txtCardNo,
Label labRelaxEndDate, Label labAccountType, Label labGardenEndDate)
    {
        DataTable dtRelax = callQuery(context, "ReadXXParkInfo", txtCardNo.Text);
        DataTable dtGarden = callQuery(context, "ReadParkInfo", txtCardNo.Text);
        if (dtRelax.Rows.Count == 0&& dtGarden.Rows.Count == 0)
        {
            context.AddError("A005080001: 当前卡片既不是有效的休闲年卡也不是有效的园林年卡");
            return;
        }

        if (dtRelax.Rows.Count > 0 && dtGarden.Rows.Count == 0)
        {
            Object[] rowRelax = dtRelax.Rows[0].ItemArray;
            if (Convert.IsDBNull(rowRelax[0]))
            {
                context.AddError("休闲库有效期为空");
                return;
            }
            string endDateRelax = (string)rowRelax[0];
            String today = DateTime.Now.ToString("yyyyMMdd");
            if (endDateRelax.CompareTo(today) < 0)
            {
                context.AddError("A005080002: 当前卡片休闲年卡已经到期");
            }

            labRelaxEndDate.Text = endDateRelax;
            labAccountType.Text = "" + rowRelax[5];
        }

        if (dtRelax.Rows.Count == 0 && dtGarden.Rows.Count >0)
        {
            Object[] rowGarden = dtGarden.Rows[0].ItemArray;
            if (Convert.IsDBNull(rowGarden[0]))
            {
                context.AddError("园林有效期为空");
                return;
            }
            string endDateGarden = (string)rowGarden[0];
            String today = DateTime.Now.ToString("yyyyMMdd");
            if (endDateGarden.CompareTo(today) < 0)
            {
                context.AddError("A005080002: 当前卡片园林年卡已经到期");
            }

            labGardenEndDate.Text = endDateGarden;
        }
        if (dtRelax.Rows.Count > 0 && dtGarden.Rows.Count > 0)
        {
            Object[] rowRelax = dtRelax.Rows[0].ItemArray;
            Object[] rowGarden = dtGarden.Rows[0].ItemArray;
            if (Convert.IsDBNull(rowRelax[0]) && Convert.IsDBNull(rowGarden[0]))
            {
                context.AddError("休闲库有效期和园林有效期都为空");
                return;
            }

            string endDateRelax = (string)rowRelax[0];
            string endDateGarden = (string)rowGarden[0];

            String today = DateTime.Now.ToString("yyyyMMdd");
            if (endDateRelax.CompareTo(today) < 0 && endDateGarden.CompareTo(today) < 0)
            {
                context.AddError("A005080002: 当前卡片休闲年卡和园林功能都已经到期");
            }

            labRelaxEndDate.Text = endDateRelax;
            labAccountType.Text = "" + rowRelax[5];
            labGardenEndDate.Text = endDateGarden;
        }
    }

    public static void readRelaxInfo(CmnContext context, TextBox txtCardNo,
Label labDbExpDate, Label labDbUsableTimes, Label labDbOpenTimes, Label labUpdateStaff, Label labUpdateTime)
    {
        DataTable data = callQuery(context, "ReadXXParkInfo", txtCardNo.Text);
        if (data.Rows.Count != 1)
        {
            context.AddError("A005080001: 当前卡片不是有效的休闲年卡");
            return;
        }
        Object[] row = data.Rows[0].ItemArray;
        if (Convert.IsDBNull(row[0]))
        {
            context.AddError("库有效期为空");
            return;
        }
        string endDate = (string)row[0];

        String today = DateTime.Now.ToString("yyyyMMdd");
        if (endDate.CompareTo(today) < 0)
        {
            context.AddError("A005080002: 当前卡片休闲年卡功能已经到期");
        }

        labDbExpDate.Text = endDate;
        labDbUsableTimes.Text = "" + row[1];
        labDbOpenTimes.Text = "" + row[2];
        labUpdateStaff.Text = "" + row[3];
        labUpdateTime.Text = "" + row[4];
    }

    public static void readCardState(CmnContext context, String cardNo, TextBox txtCardState)
    {
        DataTable data = callQuery(context, "QueryCardState", cardNo);
        if (data == null || data.Rows.Count <= 0)
        {
            return;
        }
        txtCardState.Text = "" + data.Rows[0].ItemArray[1];
    }

    public static void readAccountType(CmnContext context, String cardNo, Label labAccountType)
    {
        DataTable data = callQuery(context, "QueryAccountType", cardNo);
        if (data == null || data.Rows.Count <= 0)
        {
            return;
        }
        labAccountType.Text = "" + data.Rows[0].ItemArray[0];
    }

    /// <summary>
    /// 获取套餐名称
    /// </summary>
    public static void readPackage(CmnContext context, String cardNo, Label labPackage, HiddenField hidFuncType)
    {
        DataTable data = callQuery(context, "QueryPackage", cardNo);
        if (data == null || data.Rows.Count <= 0)
        {
            return;
        }
        labPackage.Text = "" + data.Rows[0].ItemArray[0];
        hidFuncType.Value = "" + data.Rows[0].ItemArray[1];
    }

    /// <summary>
    /// 获取套餐名称
    /// </summary>
    public static void readAffectPackage(CmnContext context, String cardNo, Label labPackage, HiddenField hidFuncType)
    {
        DataTable data = callQuery(context, "QueryAffectPackageInfo", cardNo);
        if (data == null || data.Rows.Count <= 0)
        {
            return;
        }
        labPackage.Text = "" + data.Rows[0].ItemArray[0];
        hidFuncType.Value = "" + data.Rows[0].ItemArray[1];
    }
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
    /// 初始化学生卡有效年份下拉选框
    /// </summary>
    /// <param name="selDate"></param>
    public static void initStudentVerifyDate(DropDownList selDate)
    {
        //获得当前年份
        string year = System.DateTime.Today.ToString("yyyy");
        //初始化最近10年

        selDate.Items.Add(new ListItem("---请选择---", ""));
        for (int i = 0; i < 13; i++)
        {
            selDate.Items.Add(new ListItem(year + "年", year));

            year = (Convert.ToInt32(year) + 1).ToString();
        }
    }

    /// <summary>
    /// 根据月票类型编码获取月票卡类型编码
    /// </summary>
    /// <param name="MonthlyTypeCode">月票类型编码</param>
    /// <returns>月票卡类型编码</returns>
    public static string getMonthlyCardCode(CmnContext context, string MonthlyTypeCode)
    {
        string monthlyCardCode = "";
        DataTable dt = ASHelper.callQuery(context, "ReadAppArea", MonthlyTypeCode);
        if (dt.Rows.Count > 0)
        {
            monthlyCardCode = dt.Rows[0]["AREACODE"].ToString();
        }

        return monthlyCardCode;
    }
}

