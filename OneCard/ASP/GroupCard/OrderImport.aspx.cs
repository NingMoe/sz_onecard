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
using System.IO;
using System.Text;
using Master;
using System.Xml;
using System.Collections.Generic;
/**********************************
 * 订单导入
 * 2013-4-23
 * shil
 * 初次编写
 * ********************************/
public partial class ASP_GroupCard_OrderImport : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
    }
    /// <summary>
    /// 导入
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnUpload_Click(object sender, EventArgs e)
    {
        GroupCardHelper.uploadFileValidate(context, FileUpload1);
        if (context.hasError()) return;

        if (Path.GetExtension(FileUpload1.FileName) == ".xml")
        {
            LoadXmlFile();
            if (context.hasError())
            {
                return;
            }
        }
        else
        {
            context.AddError("请导入格式必须为.xml文件");
        }

    }
    protected void LoadXmlFile()
    {
        if (File.Exists("D:\\xmlfile\\" + FileUpload1.FileName))
        {
            File.Delete("D:\\xmlfile\\" + FileUpload1.FileName);
        }
        byte[] bytes = FileUpload1.FileBytes;
        using (FileStream f = new FileStream("D:\\xmlfile\\" + FileUpload1.FileName, FileMode.OpenOrCreate, FileAccess.ReadWrite))
        {
            f.Write(bytes, 0, bytes.Length);
        }
        try
        {
            XmlDocument xmldoc = new XmlDocument();
            xmldoc.Load("D:\\xmlfile\\" + FileUpload1.FileName + "");

            XmlNode ORDERS = xmldoc.SelectSingleNode("/ORDERS");

            XmlElement INITIATOR = xmldoc.CreateElement("INITIATOR");
            XmlNodeList ordersList = xmldoc.SelectNodes("/ORDERS/ORDER");
            int executeRows = 0;

            foreach (XmlNode Ordersnode in ordersList)
            {
                //清空临时表
                OrderHelper.clearTempInfo(context);

                string xmlInitiator = "";
                string xmlOrder = "";
                string xmlOrdertype = "";
                string xmlOrderState = "";
                string xmlCompanyname = "";
                string xmlCompanyPaperType = "";
                string xmlCompanyPaperNo = "";
                string xmlName = "";
                string xmlBirthDay = "";
                string xmlSex = "";
                string xmlPaperType = "";
                string xmlPaperno = "";
                string xmlPhone = "";
                string xmlAddress = "";
                string xmlEmail = "";
                string xmlOutBank = "";
                string xmlOutAcct = "";
                string xmlTransactor = "";
                string xmlTotalmoney = "";
                string xmlRemark = "";
                string xmlCashGiftMoney = "";
                string xmlChargeCardMoney = "";
                string xmlSZTCardMoney = "";
                string xmlCustomerAccMoeny = "";
                string xmlInvoiceTotalMoney = "";
                string xmlGetDepartMent = "";
                string xmlGetDate = "";
                int CashGiftcount = 0;
                int ChargeCardcount = 0;
                int SZTCardcount = 0;
                List<string> CashGiftValue = new List<string>();
                List<string> ChargeCardValue = new List<string>();
                List<string> SZTCardType = new List<string>();

                XmlNodeList orderList = Ordersnode.ChildNodes;
                foreach (XmlNode Ordernode in orderList)
                {
                    if (Ordernode.Name == "INITIATOR")
                    {
                        xmlInitiator = Ordernode.InnerText.Trim();
                        //对订单发起方进行校验
                        if (string.IsNullOrEmpty(xmlInitiator))
                            context.AddError("订单发起方不能为空");
                        else if (!(Validation.strLen(xmlInitiator) == 1 && Validation.isNum(xmlInitiator)))
                            context.AddError("订单发起方必须是1位数字，1表示CRM，2表示运营系统");
                        else if (xmlInitiator !="1")
                            context.AddError("只允许导入CRM发起的订单");
                    }
                    if (Ordernode.Name == "ORDERNO")
                    {
                        xmlOrder = Ordernode.InnerText.Trim();
                        //对订单号进行校验
                        if (string.IsNullOrEmpty(xmlOrder))
                            context.AddError("订单号不能为空");
                        else if (!(Validation.strLen(xmlOrder) == 16))
                            context.AddError("订单号必须是16位");
                    }
                    if (Ordernode.Name == "ORDERTYPE")
                    {
                        xmlOrdertype = Ordernode.InnerText.Trim();
                        //对订单类型进行校验
                        if (string.IsNullOrEmpty(xmlOrdertype))
                            context.AddError("订单类型不能为空");
                        else if (!(Validation.strLen(xmlOrdertype) == 1 && Validation.isNum(xmlOrdertype)))
                            context.AddError("订单类型必须是1位数字，1表示单位订单，2表示个人订单");
                    }
                    if (Ordernode.Name == "ORDERSTATE")
                    {
                        xmlOrderState = Ordernode.InnerText.Trim();
                        //对订单类型进行校验
                        if (string.IsNullOrEmpty(xmlOrderState))
                            context.AddError("订单状态不能为空");
                        else if (!(Validation.strLen(xmlOrderState) == 2 && Validation.isNum(xmlOrderState)))
                            context.AddError("订单状态必须是2位数字");
                    }
                    if (Ordernode.Name == "COMPANYNAME")
                    {
                        xmlCompanyname = Ordernode.InnerText.Trim();

                        if (xmlOrdertype == "1")
                        {
                            if (xmlCompanyname == "")
                                context.AddError("单位订单单位名称不能为空");
                            else if (Validation.strLen(xmlCompanyname) > 200)
                                context.AddError("单位名称字符长度不能超过200位");
                        }
                        
                    }
                    if (Ordernode.Name == "COMPANYPAPERTYPE")
                    {
                        xmlCompanyPaperType = Ordernode.InnerText.Trim();

                        if (xmlOrdertype == "1")
                        {
                            //对单位证件类型进行非空检验
                            if (xmlCompanyPaperType == "")
                                context.AddError("单位订单单位证件类型不能为空");
                            else if (!(Validation.strLen(xmlCompanyPaperType) == 2 && Validation.isNum(xmlCompanyPaperType)))
                                context.AddError("单位证件类型必须是2位数字");
                        }
                    }
                    if (Ordernode.Name == "COMPANYPAPERNO")
                    {
                        xmlCompanyPaperNo = Ordernode.InnerText.Trim();

                        if (xmlOrdertype == "1")
                        {
                            //对单位证件号码进行非空、长度、英数字检验
                            if (xmlCompanyPaperNo == "")
                                context.AddError("单位订单单位证件号码不能为空");
                            else if (Validation.strLen(xmlCompanyPaperNo) > 30)
                                context.AddError("单位证件号码程度不能超过30位");
                        }
                    }
                    if (Ordernode.Name == "NAME")
                    {
                        xmlName = Ordernode.InnerText.Trim();

                        //对联系人姓名进行非空、长度检验
                        if (xmlName == "")
                            context.AddError("联系人姓名不能为空");
                        else if (Validation.strLen(xmlName) > 50)
                            context.AddError("联系人姓名字符长度不能大于25");
                    }
                    if (Ordernode.Name == "BIRTHDAY")
                    {
                        xmlBirthDay = Ordernode.InnerText.Trim();

                        //对出生日期进行非空、日期格式校验
                        if (xmlBirthDay != "")
                            if (!Validation.isDate(xmlBirthDay, "yyyyMMdd"))
                                context.AddError("出生日期不符合规定格式,必须为yyyyMMdd");
                    }
                    if (Ordernode.Name == "SEX")
                    {
                        xmlSex = Ordernode.InnerText.Trim();

                        //对性别进行校验
                        if (xmlSex != "")
                            if (!(Validation.strLen(xmlSex) == 1 && Validation.isNum(xmlSex)))
                                context.AddError("性别必须是1位数字，1表示男，0表示女");
                    }
                    if (Ordernode.Name == "PAPERTYPE")
                    {
                        xmlPaperType = Ordernode.InnerText.Trim();

                        //对证件类型进行非空检验
                        if (xmlPaperType == "")
                            context.AddError("证件类型不能为空");
                        else if (!(Validation.strLen(xmlPaperType) == 2 && Validation.isNum(xmlPaperType)))
                            context.AddError("证件类型必须为2位数字");
                    }
                    if (Ordernode.Name == "PAPERNO")
                    {
                        xmlPaperno = Ordernode.InnerText.Trim();

                        //对证件号码进行非空、长度、英数字检验
                        if (xmlPaperno == "")
                            context.AddError("证件号码不能为空");
                        else if (!Validation.isCharNum(xmlPaperno))
                            context.AddError("证件号码必须为英数");
                        else if (Validation.strLen(xmlPaperno) > 20)
                            context.AddError("证件号码长度不能超过20位");
                    }
                    if (Ordernode.Name == "PHONENO")
                    {
                        xmlPhone = Ordernode.InnerText.Trim();

                        //对联系电话进行长度检验
                        if (xmlPhone != "")
                            if (Validation.strLen(xmlPhone) > 20)
                                context.AddError("联系电话不能超过20位");
                    }
                    if (Ordernode.Name == "ADDRESS")
                    {
                        xmlAddress = Ordernode.InnerText.Trim();

                        //对联系地址进行长度检验
                        if (xmlAddress != "")
                            if (Validation.strLen(xmlAddress) > 200)
                                context.AddError("联系地址字符长度不能超过100位");
                    }
                    if (Ordernode.Name == "EMAIL")
                    {
                        xmlEmail = Ordernode.InnerText.Trim();

                        //对电子邮件进行格式检验
                        if (xmlEmail != "")
                            new Validation(context).isEMail(xmlEmail);
                    }
                    if (Ordernode.Name == "OUTBANK")
                    {
                        xmlOutBank = Ordernode.InnerText.Trim();

                        //对转出银行进行长度检验
                        if (xmlOutBank != "")
                            if (Validation.strLen(xmlOutBank) > 200)
                                context.AddError("转出银行字符长度不能超过100位");
                    }
                    if (Ordernode.Name == "OUTACCT")
                    {
                        xmlOutAcct = Ordernode.InnerText.Trim();

                        //对转出账户进行长度校验
                        if (xmlOutAcct != "")
                            if (Validation.strLen(xmlOutAcct) > 30)
                                context.AddError("转出账户字符长度不能超过30位");
                    }
                    if (Ordernode.Name == "TRANSACTOR")
                    {
                        xmlTransactor = Ordernode.InnerText.Trim();

                        //对经办人进行校验
                        if (xmlTransactor == "")
                            context.AddError("经办人不能为空");
                        else if (!(Validation.isNum(xmlTransactor) && Validation.strLen(xmlTransactor) == 6))
                            context.AddError("经办人必须为6位数字");
                    }
                    if (Ordernode.Name == "TOTALMONEY")
                    {
                        xmlTotalmoney = Ordernode.InnerText.Trim();

                        //对总金额进行校验
                        if (xmlTotalmoney == "")
                            context.AddError("总金额不能为空");
                        else if (!Validation.isNum(xmlTotalmoney))
                            context.AddError("总金额必须为数字");
                    }
                    if (Ordernode.Name == "REMARK")
                    {
                        xmlRemark = Ordernode.InnerText.Trim();

                        //对备注进行校验
                        if (!string.IsNullOrEmpty(xmlRemark))
                        {
                            if (Validation.strLen(xmlRemark) > 400)
                                context.AddError("备注不能超过200字符长度");
                        }
                    }
                    if (Ordernode.Name == "CASHGIFTMONEY")
                    {
                        xmlCashGiftMoney = Ordernode.InnerText.Trim();

                        //利金卡总金额进行校验
                        if (xmlCashGiftMoney == "")
                            context.AddError("利金卡总金额不能为空");
                        else if (!Validation.isNum(xmlCashGiftMoney))
                            context.AddError("利金卡总金额必须为数字");
                    }
                    if (Ordernode.Name == "CHARGECARDMONEY")
                    {
                        xmlChargeCardMoney = Ordernode.InnerText.Trim();

                        //对充值卡总金额进行校验
                        if (xmlChargeCardMoney == "")
                            context.AddError("充值卡总金额不能为空");
                        else if (!Validation.isNum(xmlChargeCardMoney))
                            context.AddError("充值卡总金额必须为数字");
                    }
                    if (Ordernode.Name == "SZTCARDMONEY")
                    {
                        xmlSZTCardMoney = Ordernode.InnerText.Trim();

                        //对市民卡B卡总金额进行校验
                        if (xmlSZTCardMoney == "")
                            context.AddError("市民卡B卡总金额不能为空");
                        else if (!Validation.isNum(xmlSZTCardMoney))
                            context.AddError("市民卡B卡总金额必须为数字");
                    }
                    if (Ordernode.Name == "CUSTOMERACCMONEY")
                    {
                        xmlCustomerAccMoeny = Ordernode.InnerText.Trim();

                        //对专有账户总金额进行校验
                        if (xmlCustomerAccMoeny == "")
                            context.AddError("专有账户总金额不能为空");
                        else if (!Validation.isNum(xmlCustomerAccMoeny))
                            context.AddError("专有账户总金额必须为数字");
                    }
                    if (Ordernode.Name == "INVOICETOTALMONEY")
                    {
                        xmlInvoiceTotalMoney = Ordernode.InnerText.Trim();

                        //对发票总金额进行校验
                        if (xmlInvoiceTotalMoney == "")
                            context.AddError("发票总金额不能为空");
                        else if (!Validation.isNum(xmlInvoiceTotalMoney))
                            context.AddError("发票总金额必须为数字");
                    }
                    if (Ordernode.Name == "GETDEPARTMENT")
                    {
                        xmlGetDepartMent = Ordernode.InnerText.Trim();

                        //对期望领卡部门进行校验
                        if (xmlGetDepartMent != "")
                        {
                            if (!(Validation.isNum(xmlGetDepartMent) && Validation.strLen(xmlGetDepartMent) == 4))
                                context.AddError("期望领卡部门必须为4位数字");
                        }
                    }
                    if (Ordernode.Name == "GETDATE")
                    {
                        xmlGetDate = Ordernode.InnerText.Trim();

                        //期望领卡日期
                        if (!string.IsNullOrEmpty(xmlGetDate))
                        {
                            if (!Validation.isDate(xmlGetDate, "yyyyMMdd"))
                                context.AddError("期望领卡日期格式必须为yyyyMMdd");
                        }
                    }

                    if (context.hasError())
                    {
                        return;
                    }
                    //利金卡子节点
                    string xmlCashGiftValue = "";
                    string xmlCashGiftCount = "";
                    string xmlCashGiftSum = "";

                    string sessionId = Session.SessionID;
                    if (Ordernode.Name == "CASHGIFTCARD")
                    {
                        XmlNodeList CashGiftCardList = Ordernode.ChildNodes;
                        foreach (XmlNode CashGiftCardnode in CashGiftCardList)
                        {
                            if (CashGiftCardnode.Name == "VALUE")
                            {
                                CashGiftcount++;
                                xmlCashGiftValue = CashGiftCardnode.InnerText;
                            }
                            if (CashGiftCardnode.Name == "COUNT")
                            {
                                xmlCashGiftCount = CashGiftCardnode.InnerText;
                            }
                            if (CashGiftCardnode.Name == "SUM")
                            {
                                xmlCashGiftSum = CashGiftCardnode.InnerText;
                            }
                        }
                        //校验利金卡面额
                        if (string.IsNullOrEmpty(xmlCashGiftValue))
                            context.AddError("利金卡面额不能为空");
                        else if (!Validation.isPrice(xmlCashGiftValue))
                            context.AddError("利金卡面额格式不正确");
                        else if (Convert.ToDecimal(xmlCashGiftValue) <= 0)
                            context.AddError("利金卡面额必须是正数");
                        else if (!CashGiftValue.Contains(xmlCashGiftValue))//判断是否有相同面额利金卡
                            CashGiftValue.Add(xmlCashGiftValue);

                        //校验利金卡购卡数量
                        if (string.IsNullOrEmpty(xmlCashGiftCount))
                            context.AddError("利金卡购卡数量不能为空");
                        else if (!Validation.isNum(xmlCashGiftCount))
                            context.AddError("利金卡购卡数量必须是数字");
                        else if (Convert.ToDecimal(xmlCashGiftValue) <= 0)
                            context.AddError("利金卡购卡数量必须是正数");

                        //校验利金卡总金额
                        if (string.IsNullOrEmpty(xmlCashGiftSum))
                            context.AddError("利金卡总金额不能为空");
                        else if (!Validation.isPrice(xmlCashGiftSum))
                            context.AddError("利金卡总金额格式不正确");
                        else if (Convert.ToDecimal(xmlCashGiftSum) <= 0)
                            context.AddError("利金卡总金额必须是正数");

                        //如果有错误则返回
                        if (context.hasError())
                        {
                            return;
                        }

                        if (xmlCashGiftValue.Length > 0 && xmlCashGiftCount.Length > 0 && xmlCashGiftSum.Length > 0)
                        {
                            context.DBOpen("Insert");
                            context.ExecuteNonQuery("insert into TMP_ORDER(F0, F1, F2, F3, F4) values('"
                                    + sessionId + "', '0','" + xmlCashGiftValue + "','"
                                    + xmlCashGiftCount + "','" + xmlCashGiftSum + "')");
                        }
                    }
                    //充值卡子节点
                    string xmlChargeValueCode = "";
                    string xmlChargeCount = "";
                    string xmlChargeSum = "";
                    if (Ordernode.Name == "CHARGECARD")
                    {
                        XmlNodeList ChargeCardList = Ordernode.ChildNodes;
                        foreach (XmlNode ChargeCardnode in ChargeCardList)
                        {
                            if (ChargeCardnode.Name == "VALUECODE")
                            {
                                ChargeCardcount++;
                                xmlChargeValueCode = ChargeCardnode.InnerText;
                            }
                            if (ChargeCardnode.Name == "COUNT")
                            {
                                xmlChargeCount = ChargeCardnode.InnerText;
                            }
                            if (ChargeCardnode.Name == "SUM")
                            {
                                xmlChargeSum = ChargeCardnode.InnerText;
                            }
                        }
                        //校验充值卡面额
                        if (string.IsNullOrEmpty(xmlChargeValueCode))
                            context.AddError("充值卡面额不能为空");
                        else if (!(Validation.strLen(xmlChargeValueCode) == 1 && Validation.isChar(xmlChargeValueCode)))
                            context.AddError("充值卡面额格式必须为1位字母");
                        else if (!ChargeCardValue.Contains(xmlChargeValueCode))//判断是否有相同面额充值卡
                            ChargeCardValue.Add(xmlChargeValueCode);

                        //校验充值卡购卡数量
                        if (string.IsNullOrEmpty(xmlChargeCount))
                            context.AddError("充值卡购卡数量不能为空");
                        else if (!Validation.isNum(xmlChargeCount))
                            context.AddError("充值卡购卡数量必须是数字");
                        else if (Convert.ToDecimal(xmlChargeCount) <= 0)
                            context.AddError("充值卡购卡数量必须是正数");

                        //校验充值卡总金额
                        if (string.IsNullOrEmpty(xmlChargeSum))
                            context.AddError("充值卡总金额不能为空");
                        else if (!Validation.isPrice(xmlChargeSum))
                            context.AddError("充值卡总金额格式不正确");
                        else if (Convert.ToDecimal(xmlChargeSum) <= 0)
                            context.AddError("充值卡总金额必须是正数");

                        //如果有错误则返回
                        if (context.hasError())
                        {
                            return;
                        }

                        if (xmlChargeValueCode.Length > 0 && xmlChargeCount.Length > 0 && xmlChargeSum.Length > 0)
                        {
                            context.DBOpen("Insert");
                            context.ExecuteNonQuery("insert into TMP_ORDER(F0, F1, F2, F3, F4) values('"
                                    + sessionId + "', '1','" + xmlChargeValueCode
                                    + "','" + xmlChargeCount + "','" + xmlChargeSum + "')");
                        }
                    }
                    //市民卡B卡子节点
                    string xmlSZTCardTypeCode = "";
                    string xmlSZTCount = "";
                    string xmlSZTUnitPrice = "";
                    string xmlSZTTotalChargeMoney = "";
                    string xmlSZTTotalMoney = "";
                    if (Ordernode.Name == "SZTCARD")
                    {
                        XmlNodeList SZTCardList = Ordernode.ChildNodes;
                        foreach (XmlNode SZTCardnode in SZTCardList)
                        {
                            if (SZTCardnode.Name == "CARDTYPECODE")
                            {
                                SZTCardcount++;
                                xmlSZTCardTypeCode = SZTCardnode.InnerText;
                            }
                            if (SZTCardnode.Name == "COUNT")
                            {
                                xmlSZTCount = SZTCardnode.InnerText;
                            }
                            if (SZTCardnode.Name == "UNITPRICE")
                            {
                                xmlSZTUnitPrice = SZTCardnode.InnerText;
                            }
                            if (SZTCardnode.Name == "TOTALCHARGEMONEY")
                            {
                                xmlSZTTotalChargeMoney = SZTCardnode.InnerText;
                            }
                            if (SZTCardnode.Name == "TOTALMONEY")
                            {
                                xmlSZTTotalMoney = SZTCardnode.InnerText;
                            }
                        }
                        //校验市民卡B卡卡类型
                        if (string.IsNullOrEmpty(xmlSZTCardTypeCode))
                            context.AddError("市民卡B卡卡类型不能为空");
                        else if (!(Validation.strLen(xmlSZTCardTypeCode) == 4 && Validation.isNum(xmlSZTCardTypeCode)))
                            context.AddError("市民卡B卡卡面类型格式必须为4位数字");
                        else if (!SZTCardType.Contains(xmlSZTCardTypeCode))//判断是否有相同卡面类型市民卡B卡
                            SZTCardType.Add(xmlChargeValueCode);

                        //校验市民卡B卡购卡数量
                        if (string.IsNullOrEmpty(xmlSZTCount))
                            context.AddError("市民卡B卡购卡数量不能为空");
                        else if (!Validation.isNum(xmlSZTCount))
                            context.AddError("市民卡B卡购卡数量必须是数字");
                        else if (Convert.ToDecimal(xmlSZTCount) <= 0)
                            context.AddError("市民卡B卡购卡数量必须是正数");


                        //校验市民卡B卡卡片单价
                        if (string.IsNullOrEmpty(xmlSZTUnitPrice))
                            context.AddError("市民卡B卡卡片单价不能为空");
                        else if (!Validation.isPrice(xmlSZTUnitPrice))
                            context.AddError("市民卡B卡卡片单价格式不正确");
                        else if (Convert.ToDecimal(xmlSZTUnitPrice) <= 0)
                            context.AddError("市民卡B卡卡片单价必须是正数");


                        //校验市民卡B卡总充值金额
                        if (string.IsNullOrEmpty(xmlSZTTotalChargeMoney))
                            context.AddError("市民卡B卡总充值金额不能为空");
                        else if (!Validation.isPrice(xmlSZTTotalChargeMoney))
                            context.AddError("市民卡B卡总充值金额格式不正确");
                        else if (Convert.ToDecimal(xmlSZTTotalChargeMoney) <= 0)
                            context.AddError("市民卡B卡总充值金额必须是正数");

                        //校验市民卡B卡总金额
                        if (string.IsNullOrEmpty(xmlSZTTotalMoney))
                            context.AddError("市民卡B卡总金额不能为空");
                        else if (!Validation.isPrice(xmlSZTTotalMoney))
                            context.AddError("市民卡B卡总金额格式不正确");
                        else if (Convert.ToDecimal(xmlSZTTotalMoney) <= 0)
                            context.AddError("市民卡B卡总金额必须是正数");

                        //如果有错误则返回
                        if (context.hasError())
                        {
                            return;
                        }

                        if (xmlSZTCardTypeCode.Length > 0 && xmlSZTCount.Length > 0 && xmlSZTUnitPrice.Length > 0
                            && xmlSZTTotalChargeMoney.Length > 0 && xmlSZTTotalMoney.Length > 0)
                        {
                            context.DBOpen("Insert");
                            context.ExecuteNonQuery("insert into TMP_ORDER(F0, F1, F2, F3, F4, F5, F6) values('"
                                    + sessionId + "', '2','" + xmlSZTCardTypeCode + "','"
                                    + xmlSZTCount + "','" + xmlSZTUnitPrice + "','" + xmlSZTTotalChargeMoney + "','"
                                    + xmlSZTTotalMoney + "')");
                        }
                    }
                    //开票子节点
                    string xmlInvoiceTypeCode = "";
                    string xmlInvoiceMoney = "";
                    if (Ordernode.Name == "INVOICE")
                    {
                        XmlNodeList InvoiceList = Ordernode.ChildNodes;
                        foreach (XmlNode Invoicenode in InvoiceList)
                        {
                            if (Invoicenode.Name == "INVOICETYPECODE")
                            {
                                xmlInvoiceTypeCode = Invoicenode.InnerText;
                            }
                            if (Invoicenode.Name == "INVOICEMONEY")
                            {
                                xmlInvoiceMoney = Invoicenode.InnerText;
                            }
                        }

                        //校验开票类型编码
                        if (string.IsNullOrEmpty(xmlInvoiceTypeCode))
                            context.AddError("开票类型编码不能为空");
                        else if (!(Validation.strLen(xmlInvoiceTypeCode) == 1 && Validation.isNum(xmlInvoiceTypeCode)))
                            context.AddError("开票类型编码格式必须为1位数字");

                        //校验开票金额
                        if (string.IsNullOrEmpty(xmlInvoiceMoney))
                            context.AddError("开票金额不能为空");
                        else if (!Validation.isNum(xmlInvoiceMoney))
                            context.AddError("开票金额必须是数字");
                        else if (Convert.ToDecimal(xmlInvoiceMoney) <= 0)
                            context.AddError("开票金额必须是正数");

                        //如果有错误则返回
                        if (context.hasError())
                        {
                            return;
                        }

                        if (xmlInvoiceTypeCode.Length > 0 && xmlInvoiceMoney.Length > 0)
                        {
                            context.DBOpen("Insert");
                            context.ExecuteNonQuery("insert into TMP_ORDER(F0, F1, F2, F3 ) values('"
                                    + sessionId + "', '3','" + xmlInvoiceTypeCode
                                    + "','" + xmlInvoiceMoney + "')");
                        }

                    }
                    //付款方式子节点
                    string xmlCheck = "";
                    string xmlTransfer = "";
                    string xmlCash = "";
                    string xmlSlopCard = "";
                    string xmlApprove = "";
                    if (Ordernode.Name == "PAYTYPE")
                    {
                        XmlNodeList PaytypeList = Ordernode.ChildNodes;
                        foreach (XmlNode Paytypenode in PaytypeList)
                        {
                            if (Paytypenode.Name == "CHECK")
                            {
                                xmlCheck = Paytypenode.InnerText;
                            }
                            if (Paytypenode.Name == "TRANSFER")
                            {
                                xmlTransfer = Paytypenode.InnerText;
                            }
                            if (Paytypenode.Name == "CASH")
                            {
                                xmlCash = Paytypenode.InnerText;
                            }
                            if (Paytypenode.Name == "SLOPCARD")
                            {
                                xmlSlopCard = Paytypenode.InnerText;
                            }
                            if (Paytypenode.Name == "APPROVE")
                            {
                                xmlApprove = Paytypenode.InnerText;
                            }
                        }
                        //校验支/本票付款方式
                        if (string.IsNullOrEmpty(xmlCheck))
                            context.AddError("支/本票付款方式编码不能为空");
                        else if (!(Validation.strLen(xmlCheck) == 1 && Validation.isNum(xmlCheck)))
                            context.AddError("支/本票付款方式编码格式必须为1位数字");

                        //校验转账付款方式
                        if (string.IsNullOrEmpty(xmlTransfer))
                            context.AddError("转账付款方式编码不能为空");
                        else if (!(Validation.strLen(xmlTransfer) == 1 && Validation.isNum(xmlTransfer)))
                            context.AddError("转账付款方式编码格式必须为1位数字");

                        //校验现金付款方式
                        if (string.IsNullOrEmpty(xmlCash))
                            context.AddError("现金付款方式编码不能为空");
                        else if (!(Validation.strLen(xmlCash) == 1 && Validation.isNum(xmlCash)))
                            context.AddError("现金付款方式编码格式必须为1位数字");

                        //校验刷卡付款方式
                        if (string.IsNullOrEmpty(xmlSlopCard))
                            context.AddError("刷卡付款方式编码不能为空");
                        else if (!(Validation.strLen(xmlSlopCard) == 1 && Validation.isNum(xmlSlopCard)))
                            context.AddError("刷卡付款方式编码格式必须为1位数字");

                        //校验呈批单付款方式
                        if (string.IsNullOrEmpty(xmlApprove))
                            context.AddError("呈批单付款方式编码不能为空");
                        else if (!(Validation.strLen(xmlApprove) == 1 && Validation.isNum(xmlApprove)))
                            context.AddError("呈批单付款方式编码格式必须为1位数字");

                        //如果有错误则返回
                        if (context.hasError())
                        {
                            return;
                        }
                        context.DBOpen("Insert");
                        if (xmlCheck == "1")
                        {
                            context.ExecuteNonQuery("insert into TMP_ORDER(F0, F1, F2, F3) values('"
                                                      + sessionId + "', '4','" + "0" + "','支/本票')");
                        }
                        if (xmlTransfer == "1")
                        {
                            context.ExecuteNonQuery("insert into TMP_ORDER(F0, F1, F2, F3) values('"
                                                      + sessionId + "', '4','" + "1" + "','转账')");
                        }
                        if (xmlCash == "1")
                        {
                            context.ExecuteNonQuery("insert into TMP_ORDER(F0, F1, F2, F3) values('"
                                                      + sessionId + "', '4','" + "2" + "','现金')");
                        }
                        if (xmlSlopCard == "1")
                        {
                            context.ExecuteNonQuery("insert into TMP_ORDER(F0, F1, F2, F3) values('"
                                                      + sessionId + "', '4','" + "3" + "','刷卡')");
                        }
                        if (xmlApprove == "1")
                        {
                            context.ExecuteNonQuery("insert into TMP_ORDER(F0, F1, F2, F3) values('"
                                                      + sessionId + "', '4','" + "4" + "','呈批单')");
                        }
                    }
                    
                    if (!context.hasError())
                    {
                        context.DBCommit();
                    }
                    else
                    {
                        context.RollBack();
                        return;
                    }
                }
                if (xmlCustomerAccMoeny == "0" && CashGiftcount == 0 && ChargeCardcount == 0 && SZTCardcount == 0)
                {
                    context.AddError("利金卡、充值卡、市民卡B卡、专有账户至少填写一项订单信息");
                }
                if (CashGiftValue.Count < CashGiftcount)
                {
                    context.AddError("不允许在一个订单中重复录入相同面额的利金卡");
                }
                if (ChargeCardValue.Count < ChargeCardcount)
                {
                    context.AddError("不允许在一个订单中重复录入相同面额的充值卡");
                }
                if (SZTCardType.Count < SZTCardcount)
                {
                    context.AddError("不允许在一个订单中重复录入相同卡类型的市民卡");
                }
                if (context.hasError())
                {
                    return;
                }
                context.SPOpen();
                context.AddField("P_FUNCCODE").Value = "ADD";
                context.AddField("p_ORDERNO").Value = xmlOrder;
                context.AddField("P_SESSIONID").Value = Session.SessionID;
                context.AddField("P_ORDERTYPE").Value = xmlOrdertype; //1单位，2个人
                context.AddField("P_INITIATOR").Value = xmlInitiator; //1CRM，2业务系统
                context.AddField("P_GROUPNAME").Value = xmlCompanyname;
                context.AddField("P_COMPANYPAPERTYPE").Value = xmlCompanyPaperType;
                context.AddField("P_COMPANYPAPERNO").Value = xmlCompanyPaperNo;
                context.AddField("P_NAME").Value = xmlName;
                context.AddField("P_PHONE").Value = xmlPhone;
                context.AddField("P_IDCARDNO").Value = xmlPaperno;
                context.AddField("P_BIRTHDAY").Value = xmlBirthDay;
                context.AddField("P_PAPERTYPE").Value = xmlPaperType;
                context.AddField("P_SEX").Value = xmlSex;
                context.AddField("P_ADDRESS").Value = xmlAddress;
                context.AddField("P_EMAIL").Value = xmlEmail;
                context.AddField("P_OUTBANK").Value = xmlOutBank;
                context.AddField("P_OUTACCT").Value = xmlOutAcct;
                context.AddField("P_TOTALMONEY", "Int32").Value = Convert.ToInt64(xmlTotalmoney);
                context.AddField("P_TRANSACTOR").Value = xmlTransactor;
                context.AddField("P_REMARK").Value = xmlRemark;

                //利金卡总金额
                context.AddField("P_CASHGIFTMONEY", "Int32").Value = xmlCashGiftMoney == "" ? 0 : Convert.ToInt64(xmlCashGiftMoney);
                //充值卡总金额
                context.AddField("P_CHARGECARDMONEY", "Int32").Value = xmlChargeCardMoney == "" ? 0 : Convert.ToInt64(xmlChargeCardMoney);
                //市民卡B卡总金额
                context.AddField("P_SZTCARDMONEY", "Int32").Value = xmlSZTCardMoney == "" ? 0 : Convert.ToInt64(xmlSZTCardMoney);
                //专有账户总充值金额
                context.AddField("P_CUSTOMERACCMONEY", "Int32").Value = xmlCustomerAccMoeny == "" ? 0 : Convert.ToInt64(xmlCustomerAccMoeny);
                //开票总金额
                context.AddField("P_INVOICETOTALMONEY", "Int32").Value = xmlInvoiceTotalMoney == "" ? 0 : Convert.ToInt64(xmlInvoiceTotalMoney);

                //领卡网点，领卡日期
                context.AddField("P_GETDEPARTMENT").Value = xmlGetDepartMent;
                context.AddField("P_GETDATE").Value = xmlGetDate;

                context.AddField("P_ORDERDATE").Value = DateTime.Now.ToString("yyyyMMdd");
                context.AddField("P_ORDERSEQ").Value = "";
                bool ok = context.ExecuteSP("SP_GC_ORDERINPUTSUBMIT");
                if (ok)
                {
                    executeRows++;
                }
                else
                {
                    context.AddError("第"+(executeRows+1).ToString()+"条及后面的订单："+xmlOrder+"没有导入成功");
                }
            }

            if (!context.hasError())
            {
                context.AddMessage("订单导入成功，共导入" + executeRows.ToString() + "条订单");
            }
            else
            {
                return;
            }
            //AddMessage(xmlInitiator + "," + xmlOrder);
            //string path = FileUpload1.FileName;
            //XmlTextReader rd = new XmlTextReader(Server.MapPath(path));
        }
        catch(Exception ex)
        {
            context.AddError(ex.ToString());
        }
    }
}