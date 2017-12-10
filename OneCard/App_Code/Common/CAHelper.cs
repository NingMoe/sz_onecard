using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web.UI.WebControls;
using Master;
using TDO.BusinessCode;
using TDO.CardManager;
using TDO.CustomerAcc;
using TDO.PersonalTrade;
using TDO.ResourceManager;
using TDO.UserManager;
using TM;
using PDO.CustomerAcc;
namespace Common
{
    /// <summary>
    /// 专有账户
    /// </summary> 
    public class CAHelper
    {
        public CAHelper()
        {
            // 
            // TODO: 在此处添加构造函数逻辑
            //
        }

        /// <summary>
        /// 返回MD5加密串

        /// </summary>
        /// <param name="s"></param>
        /// <returns></returns>
        public static string Md5Encrypt(string str)
        {
            return System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(str, "MD5");
        }


        /// <summary>
        /// 获取账户状态
        /// </summary>
        /// <param name="code"></param>
        /// <returns></returns>
        public static string GetAccStateByCode(string code)
        {
            string returnValue;
            switch (code)
            {
                case "A": returnValue = "有效";
                    break;
                case "B": returnValue = "冻结";
                    break;
                case "F": returnValue = "挂失";
                    break;
                case "X": returnValue = "注销";
                    break;
                default: returnValue = code;
                    break;
            }
            return returnValue;
        }

        public static void clearTempCustInfoTable(CmnContext context)
        {
            context.DBOpen("Delete");
            context.ExecuteNonQuery("delete from TMP_COMMON where F0 ='" + System.Web.HttpContext.Current.Session.SessionID + "'");
            context.DBCommit();
        }

        public static void clearTempCustInfoTable2(CmnContext context)
        {
            context.DBOpen("Delete");
            context.ExecuteNonQuery("delete from TMP_COMMON where F13 ='" + System.Web.HttpContext.Current.Session.SessionID + "'");
            context.DBCommit();
        }

        /// <summary>
        /// 批量修改密码将账户ID批量插入到临时表中
        /// </summary>
        /// <param name="context"></param>
        /// <param name="gvResult"></param>
        /// <param name="sessId"></param>
        public static void FillAccIDList(CmnContext context, GridView gvResult, string sessId)
        {
            // 首先清空临时表

            context.DBOpen("Delete");
            context.ExecuteNonQuery("delete from TMP_COMMON " + " where F0 = '" + sessId + "'");

            // 根据页面数据生成临时表数据

            int count = 0;
            for (int i = 0; i < gvResult.Rows.Count; i++)
            {

                ++count;
                context.ExecuteNonQuery("insert into TMP_COMMON (F0,F1) values('"
                    + sessId + "','" + gvResult.DataKeys[i]["ACCT_ID"].ToString() + "')");
            }
            context.DBCommit();

            // 没有选中任何行，则返回错误

            if (count <= 0)
            {
                context.AddError("A004P03R01: 没有要修改密码的账户");
            }
        }

        //验证批量上传文件
        public static void UploadCustInfoFile(CmnContext context, FileUpload FileUpload1, bool batchUpdateInfo,string acctype)
        {
            GroupCardHelper.uploadFileValidate(context, FileUpload1);
            if (context.hasError()) return;

            // 读取“证件类型编码表”（以便后面校验文件内容中的“证件类型编码”时使用）

            ArrayList al = GroupCardHelper.readPaperTypeList(context);

            // 首先清空临时表

            clearTempCustInfoTable2(context);

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

                if (Validation.strLen(strLine) > 300 + 10)
                {
                    context.AddError("第" + lineCount + "行长度为" + Validation.strLen(strLine)
                        + ", 根据格式定义不能超过300");
                    continue;
                }
                fields = strLine.Split(new char[2] { ',', '\t' });

                // 字段数目为6-12时合法

                if (fields.Length < 6 || fields.Length > 11)
                {
                    context.AddError("第" + lineCount + "行字段数目为"
                        + fields.Length + ", 根据格式定义必须为6-11");
                    continue;
                }

                dealFileContent(ht, context, fields, lineCount, al, batchUpdateInfo, acctype);
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


        public static void dealFileContent(Hashtable ht, CmnContext context,
    String[] fields, int lineCount, ArrayList al, bool batchUpdateInfo, string acctype)
        {
            String cardNo = fields[0].Trim();
            // 卡号
            if (!batchUpdateInfo && cardNo.Length <= 0)
            {
                context.AddError("第" + lineCount + "行卡号为空");
            }
            else if (Validation.strLen(cardNo) != 16)
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
            else if ("51".Equals(cardNo.Substring(4, 2)))
            {
                context.AddError("第" + lineCount + "行卡是旅游年卡,不允许开通专有账户");
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
            // 证件号码
            string paperNo = fields[5].Trim();
            if (!batchUpdateInfo && paperNo.Length <= 0)
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
            if (paperType == "")
                paperType = "00";
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
            }

            string postCode = "";
            if (fields.Length > 7)
            {
                // 邮政编码
                postCode = fields[7].Trim();
                if (postCode.Length > 0 && (Validation.strLen(postCode) != 6 || !Validation.isNum(postCode)))
                {
                    context.AddError("第" + lineCount + "行邮政编码格式不对，必须是6位数字");
                }
            }
            string custPhone = "";
            if (fields.Length > 8)
            {
                // 手机
                custPhone = fields[8].Trim();
                if (Validation.strLen(custPhone) > 20)
                {
                    context.AddError("第" + lineCount + "行手机长度超过20位");
                }
            }
            string custTel = "";
            if (fields.Length > 9)
            {
                // 固话
                custTel = fields[9].Trim();
                if (Validation.strLen(custTel) > 20)
                {
                    context.AddError("第" + lineCount + "行固话长度超过20位");
                }
            }
            //if (string.IsNullOrEmpty(custPhone) && string.IsNullOrEmpty(custTel))
            //{
            //    context.AddError("第" + lineCount + "行手机号码和固定电话最少填一个");
            //}
            string custEmail = "";
            if (fields.Length > 10)
            {
                // 电子邮件
                custEmail = fields[10].Trim();
                string errMsg = new Validation(context).isEMail(custEmail);
                if (errMsg.Length > 0)
                {
                    context.AddError("第" + lineCount + errMsg);
                }
            }
            //个人资料部分信息加密
            StringBuilder strBuilder = new StringBuilder();
            AESHelp.AESEncrypt(custName, ref strBuilder);
            custName = strBuilder.ToString();

            AESHelp.AESEncrypt(paperNo, ref strBuilder);
            paperNo = strBuilder.ToString();

            AESHelp.AESEncrypt(custAddr, ref strBuilder);
            custAddr = strBuilder.ToString();

            AESHelp.AESEncrypt(custPhone, ref strBuilder);
            custPhone = strBuilder.ToString();

            AESHelp.AESEncrypt(custTel, ref strBuilder);
            custTel = strBuilder.ToString();

            // F13: SessionID
            // F1:  卡号 
            // F2:  姓名 
            // F3:  性别  
            // F4:  出生日期 
            // F5:  证件类型 
            // F6:  证件号码 
            // F7:  地址 
            // F8:  邮编 
            // F9:  手机号码 
            // F10: 固定电话
            // F11: 邮箱 
            // F12: 空
            // F14: 账户类型
            if (!context.hasError())
            {
               int a = context.ExecuteNonQuery("insert into TMP_COMMON(f13, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11,f12,f14) values('"
                    + System.Web.HttpContext.Current.Session.SessionID + "','"
                    + cardNo + "', '" + custName + "','" + custSex + "','" + custBirth
                    + "','" + paperType + "','" + paperNo + "','" + custAddr + "','"
                    + postCode + "','" + custPhone + "','" + custTel + "','" + custEmail + "','','" + acctype + "')");
            }
        }

        /// <summary>
        /// 校验专有账户密码
        /// </summary>
        /// <param name="context">context</param>
        /// <param name="cardNo">卡号</param>
        /// <param name="PassWD">加密前密码</param>
        /// <param name="checkState">是否校验账户状态</param>
        /// <returns></returns>
        public static bool CheckPWD(CmnContext context, string cardNo, string PassWD, bool checkState)
        {
            return CheckPWD(context, cardNo, PassWD, checkState, false, false);
        }

        /// <summary>
        /// 创建人:殷华荣 2012-8-24
        /// 验证多账户密码
        /// </summary>
        /// <param name="context"></param>
        /// <param name="acctid"></param>
        /// <param name="PassWD"></param>
        /// <param name="checkState"></param>
        /// <returns></returns>
        public static bool CheckMultipleAccPWD(CmnContext context, string acctid, string PassWD, bool checkState)
        {
            return CheckMultipleAccPWD(context, acctid, PassWD, checkState, false, false);
        }

        /// <summary>
        /// 创建人:殷华荣 2012-8-24
        /// 验证多账户密码
        /// </summary>
        /// <param name="context"></param>
        /// <param name="accid"></param>
        /// <param name="PassWD"></param>
        /// <param name="checkState"></param>
        /// <param name="lockAcc"></param>
        /// <param name="mustChangePass"></param>
        /// <returns></returns>
        public static bool CheckMultipleAccPWD(CmnContext context, string accid, string PassWD, bool checkState, bool lockAcc, bool mustChangePass)
        {
            //对密码长度和是否为数字进行校验

            if (Validation.strLen(PassWD) != 6)
            {
                context.AddError("A001090105:输入的密码不等于6位");
                return false;
            }
            else if (!Validation.isNum(PassWD))
            {
                context.AddError("A001090106：输入的密码不为数字");
                return false;
            }
            //客户账户
            TMTableModule tmTMTableModule = new TMTableModule();
            TF_F_CUST_ACCTTDO ddoTF_F_CUST_ACCTIn = new TF_F_CUST_ACCTTDO();
            ddoTF_F_CUST_ACCTIn.ACCT_ID = accid;

            TF_F_CUST_ACCTTDO ddoTF_F_CUST_ACCTOut = (TF_F_CUST_ACCTTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUST_ACCTIn, typeof(TF_F_CUST_ACCTTDO), null, "TF_F_CUST_ACCT_ID", null);

            if (ddoTF_F_CUST_ACCTOut == null)
            {
                context.AddError("A001090102:未查出客户账户信息");
                return false;
            }
            if (checkState && !ddoTF_F_CUST_ACCTOut.STATE.Equals("A"))
            {
                context.AddError("A001090103:客户账户状态无效");
                return false;
            }
            if (ddoTF_F_CUST_ACCTOut.CODEERRORTIMES >= 3)
            {
                context.AddError("A001090104:客户账户被锁定,次日解锁");
                return false;
            }

            StringBuilder szOutput = new System.Text.StringBuilder(256);
            CAEncryption.CAEncrypt(PassWD, ref szOutput);

            string encryptPwd = szOutput.ToString(); //CAHelper.Md5Encrypt(PassWD);


            if (encryptPwd.Equals(ddoTF_F_CUST_ACCTOut.CUST_PASSWARD) == false)
            {
                if (lockAcc)
                {
                    context.SPOpen();
                    context.AddField("P_ACCT_ID").Value = ddoTF_F_CUST_ACCTOut.ACCT_ID;
                    context.AddField("P_CODEERRORTIMES").Value = ddoTF_F_CUST_ACCTOut.CODEERRORTIMES;
                    context.ExecuteSP("SP_CA_PWDERRORTIMES");
                }
                context.AddError("A001090203:账户密码错误");
                return false;
            }

            //未修改过密码,提示修改密码
            else if (mustChangePass)
            {
                //E10ADC3949BA59ABBE56E057F20F883E:123456
                //0.0-000*0/0. :111111

                //获取初始密码
                StringBuilder pwd = new System.Text.StringBuilder(256);
                CAEncryption.CAEncrypt("111111", ref pwd);

                if (pwd.ToString().Trim().Equals(encryptPwd))
                {
                    context.AddError("A001090401:该卡未修改过账户初始密码,请协助用户修改密码");
                    return false;
                }
            }

            else if (lockAcc)
            {
                context.SPOpen();
                context.AddField("P_ACCT_ID").Value = ddoTF_F_CUST_ACCTOut.ACCT_ID;
                context.AddField("P_CODEERRORTIMES").Value = -1;
                context.ExecuteSP("SP_CA_PWDERRORTIMES");
            }
            return true;
        }

        /// <param name="lockAcc">密码输入错是否锁定账户</param>
        /// <param name="mustChangePass">是否必须修改初始密码才能办业务</param>
        public static bool CheckPWD(CmnContext context, string cardNo, string PassWD, bool checkState, bool lockAcc, bool mustChangePass)
        {
            //对密码长度和是否为数字进行校验

            if (Validation.strLen(PassWD) != 6)
            {
                context.AddError("A001090105:输入的密码不等于6位");
                return false;
            }
            else if (!Validation.isNum(PassWD))
            {
                context.AddError("A001090106：输入的密码不为数字");
                return false;
            }
            //客户账户
            TMTableModule tmTMTableModule = new TMTableModule();
            TF_F_CUST_ACCTTDO ddoTF_F_CUST_ACCTIn = new TF_F_CUST_ACCTTDO();
            ddoTF_F_CUST_ACCTIn.ICCARD_NO = cardNo;

            TF_F_CUST_ACCTTDO ddoTF_F_CUST_ACCTOut = (TF_F_CUST_ACCTTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUST_ACCTIn, typeof(TF_F_CUST_ACCTTDO), null, "TF_F_CUST_ACCT", null);

            if (ddoTF_F_CUST_ACCTOut == null)
            {
                context.AddError("A001090102:未查出客户账户信息");
                return false;
            }
            if (checkState && !ddoTF_F_CUST_ACCTOut.STATE.Equals("A"))
            {
                context.AddError("A001090103:客户账户状态无效");
                return false;
            }
            if (ddoTF_F_CUST_ACCTOut.CODEERRORTIMES >= 3)
            {
                context.AddError("A001090104:客户账户被锁定,次日解锁");
                return false;
            }

            StringBuilder szOutput = new System.Text.StringBuilder(256);
            CAEncryption.CAEncrypt(PassWD, ref szOutput);

            string encryptPwd = szOutput.ToString();  // CAHelper.Md5Encrypt(PassWD);


            if (encryptPwd.Equals(ddoTF_F_CUST_ACCTOut.CUST_PASSWARD) == false)
            {
                if (lockAcc)
                {
                    context.SPOpen();
                    context.AddField("P_ACCT_ID").Value = ddoTF_F_CUST_ACCTOut.ACCT_ID;
                    context.AddField("P_CODEERRORTIMES").Value = ddoTF_F_CUST_ACCTOut.CODEERRORTIMES;
                    context.ExecuteSP("SP_CA_PWDERRORTIMES");
                }
                context.AddError("A001090203:账户密码错误");
                return false;
            }

            //未修改过密码,提示修改密码
            else if (mustChangePass)
            {
                //E10ADC3949BA59ABBE56E057F20F883E:123456

                //获取初始密码
                StringBuilder pwd = new System.Text.StringBuilder(256);
                CAEncryption.CAEncrypt("111111", ref pwd);

                if (pwd.ToString().Trim().Equals(encryptPwd))
                {
                    context.AddError("A001090401:该卡未修改过账户初始密码,请协助用户修改密码");
                    return false;
                }
            }

            else if (lockAcc)
            {
                context.SPOpen();
                context.AddField("P_ACCT_ID").Value = ddoTF_F_CUST_ACCTOut.ACCT_ID;
                context.AddField("P_CODEERRORTIMES").Value = -1;
                context.ExecuteSP("SP_CA_PWDERRORTIMES");
            }
            return true;
        }


        /// <summary>
        /// 获取卡内信息（卡类型，电子钱包表，IC卡资料）
        /// </summary>
        /// <param name="context">上下文</param>
        /// <param name="cardno">卡号</param>
        /// <param name="listDDO">DDO列表</param>
        /// <returns>是否有异常</returns>
        public static bool GetCardInfo(CmnContext context, string cardno, out  Dictionary<String, DDOBase> listDDO)
        {
            listDDO = new Dictionary<String, DDOBase>();
            TMTableModule tmTMTableModule = new TMTableModule();

            #region lblResState库存状态

            //从用户卡库存表(TL_R_ICUSER)中读取数据

            TL_R_ICUSERTDO ddoTL_R_ICUSERIn = new TL_R_ICUSERTDO();
            ddoTL_R_ICUSERIn.CARDNO = cardno;

            TL_R_ICUSERTDO ddoTL_R_ICUSEROut = (TL_R_ICUSERTDO)tmTMTableModule.selByPK(context, ddoTL_R_ICUSERIn, typeof(TL_R_ICUSERTDO), null, "TL_R_ICUSER", null);
            if (ddoTL_R_ICUSEROut == null)
            {
                context.AddError("A001001101");
                return false;
            }
            else
            {
                //用户卡库存表(TL_R_ICUSER)
                listDDO.Add("TL_R_ICUSER", ddoTL_R_ICUSEROut);
            }

            //从资源状态编码表中读取数据

            TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEIn = new TD_M_RESOURCESTATETDO();
            ddoTD_M_RESOURCESTATEIn.RESSTATECODE = ddoTL_R_ICUSEROut.RESSTATECODE;

            TD_M_RESOURCESTATETDO ddoTD_M_RESOURCESTATEOut = (TD_M_RESOURCESTATETDO)tmTMTableModule.selByPK(context, ddoTD_M_RESOURCESTATEIn, typeof(TD_M_RESOURCESTATETDO), null, "TD_M_RESOURCESTATE", null);

            //资源状态编码表
            listDDO.Add("TD_M_RESOURCESTATE", ddoTD_M_RESOURCESTATEOut);

            #endregion

            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEIn = new TD_M_CARDTYPETDO();
            ddoTD_M_CARDTYPEIn.CARDTYPECODE = ddoTL_R_ICUSEROut.CARDTYPECODE;
            TD_M_CARDTYPETDO ddoTD_M_CARDTYPEOut = (TD_M_CARDTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_CARDTYPEIn, typeof(TD_M_CARDTYPETDO), null, "TD_M_CARDTYPE_CHUSER", null);

            //卡类型表
            listDDO.Add("TD_M_CARDTYPE", ddoTD_M_CARDTYPEOut);

            //从IC卡电子钱包账户表中读取数据

            TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCIn = new TF_F_CARDEWALLETACCTDO();
            ddoTF_F_CARDEWALLETACCIn.CARDNO = cardno;
            TF_F_CARDEWALLETACCTDO ddoTF_F_CARDEWALLETACCOut = (TF_F_CARDEWALLETACCTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDEWALLETACCIn, typeof(TF_F_CARDEWALLETACCTDO), null);

            //电子钱包表

            if (ddoTF_F_CARDEWALLETACCOut == null)
            {
                context.AddError("A001022103");
                return false;
            }
            listDDO.Add("TF_F_CARDEWALLETACC", ddoTF_F_CARDEWALLETACCOut);


            //从IC卡资料表中读取数据

            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();
            ddoTF_F_CARDRECIn.CARDNO = cardno;

            TF_F_CARDRECTDO ddoTF_F_CARDRECOut = (TF_F_CARDRECTDO)tmTMTableModule.selByPK(context, ddoTF_F_CARDRECIn, typeof(TF_F_CARDRECTDO), null);

            if (ddoTF_F_CARDRECOut == null)
            {
                context.AddError("A001022103");
                return false;
            }
            listDDO.Add("TF_F_CARDREC", ddoTF_F_CARDRECOut);

            return true;
        }

        /// <summary>
        /// 获取帐户信息（客户账户表，余额账本）
        /// </summary>
        /// <param name="context">上下文</param>
        /// <param name="cardno">卡号</param>
        /// <param name="checkState">是否检查状态</param>
        /// <param name="listDDO">DDO列表</param>
        /// <returns>是否有异常</returns>
        public static bool GetCustAcctInfo(CmnContext context, string cardno, bool checkState, out  Dictionary<String, DDOBase> listDDO)
        {
            listDDO = new Dictionary<String, DDOBase>();
            TMTableModule tmTMTableModule = new TMTableModule();

            //客户账户
            TF_F_CUST_ACCTTDO ddoTF_F_CUST_ACCTIn = new TF_F_CUST_ACCTTDO();
            ddoTF_F_CUST_ACCTIn.ICCARD_NO = cardno;

            TF_F_CUST_ACCTTDO ddoTF_F_CUST_ACCTOut = (TF_F_CUST_ACCTTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUST_ACCTIn, typeof(TF_F_CUST_ACCTTDO), null, "TF_F_CUST_ACCT", null);

            if (ddoTF_F_CUST_ACCTOut == null)
            {
                context.AddError("A001090102:未查出客户账户信息");
                return false;
            }
            else if (ddoTF_F_CUST_ACCTOut.STATE.Equals("A") == false)
            {
                if (checkState)
                {
                    context.AddError("A001090103:客户账户状态无效");
                    return false;
                }
            }
            //客户账户表

            listDDO.Add("TF_F_CUST_ACCT", ddoTF_F_CUST_ACCTOut);


            //余额账本
            TF_F_ACCT_BALANCETDO ddoTF_F_ACCT_BALANCEIn = new TF_F_ACCT_BALANCETDO();
            ddoTF_F_ACCT_BALANCEIn.ICCARD_NO = cardno;
            ddoTF_F_ACCT_BALANCEIn.ACCT_ID = ddoTF_F_CUST_ACCTOut.ACCT_ID;

            TF_F_ACCT_BALANCETDO ddoTF_F_ACCT_BALANCEOut = (TF_F_ACCT_BALANCETDO)tmTMTableModule.selByPK(context, ddoTF_F_ACCT_BALANCEIn, typeof(TF_F_ACCT_BALANCETDO), null, "TF_F_ACCT_BALANCE", null);

            if (ddoTF_F_ACCT_BALANCEOut == null)
            {
                context.AddError("A001090104:未查出余额账本信息");
                return false;
            }
            else if (ddoTF_F_ACCT_BALANCEOut.STATE.Equals("A") == false)
            {
                if (checkState)
                {
                    context.AddError("A001090105:余额账本状态无效");
                    return false;
                }
            }
            //余额账本表

            listDDO.Add("TF_F_ACCT_BALANCE", ddoTF_F_ACCT_BALANCEOut);
            return true;

        }

        /// <summary>
        /// 充值账户状态校验 主要验证挂失卡是否可以充值
        /// </summary>
        /// <param name="context"></param>
        /// <param name="cardno"></param>
        /// <param name="acctid"></param>
        /// <param name="checkState"></param>
        /// <param name="BlockCanCharge">挂失卡是否允许充值：  true允许、 false不允许</param>
        /// <returns></returns>
        public static bool GetCustAcctInfo(CmnContext context, string cardno, string acctid, bool checkState, bool blockCanCharge)
        {
            TMTableModule tmTMTableModule = new TMTableModule();
            //客户账户
            TF_F_CUST_ACCTTDO ddoTF_F_CUST_ACCTIn = new TF_F_CUST_ACCTTDO();
            ddoTF_F_CUST_ACCTIn.ACCT_ID = acctid;
            TF_F_CUST_ACCTTDO ddoTF_F_CUST_ACCTOut = (TF_F_CUST_ACCTTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUST_ACCTIn, typeof(TF_F_CUST_ACCTTDO), null, "TF_F_CUST_ACCT_ID", null);
            if (ddoTF_F_CUST_ACCTOut == null)
            {
                context.AddError("A001090102:未查出客户账户信息");
                return false;
            }
            else if (!ddoTF_F_CUST_ACCTOut.STATE.Equals("A"))
            {
                if (checkState)
                {
                    if (!ddoTF_F_CUST_ACCTOut.STATE.Equals("F")) //非挂失卡不允许充值
                    {
                        context.AddError("A001090103:客户账户状态无效");
                        return false;
                    }
                    else if (ddoTF_F_CUST_ACCTOut.STATE.Equals("F") && !blockCanCharge)
                    {
                        context.AddError("A001090103:客户账户状态无效");
                        return false;
                    }
                }
            }
            //余额账本
            TF_F_ACCT_BALANCETDO ddoTF_F_ACCT_BALANCEIn = new TF_F_ACCT_BALANCETDO();
            ddoTF_F_ACCT_BALANCEIn.ICCARD_NO = cardno;
            ddoTF_F_ACCT_BALANCEIn.ACCT_ID = ddoTF_F_CUST_ACCTOut.ACCT_ID;
            TF_F_ACCT_BALANCETDO ddoTF_F_ACCT_BALANCEOut = (TF_F_ACCT_BALANCETDO)tmTMTableModule.selByPK(context, ddoTF_F_ACCT_BALANCEIn, typeof(TF_F_ACCT_BALANCETDO), null, "TF_F_ACCT_BALANCE", null);
            if (ddoTF_F_ACCT_BALANCEOut == null)
            {
                context.AddError("A001090104:未查出余额账本信息");
                return false;
            }
            else if (!ddoTF_F_ACCT_BALANCEOut.STATE.Equals("A"))
            {
                if (checkState)
                {
                    if (!ddoTF_F_CUST_ACCTOut.STATE.Equals("F")) //非挂失卡不允许充值
                    {
                        context.AddError("A001090105:余额账本状态无效");
                        return false;
                    }
                    else if (ddoTF_F_CUST_ACCTOut.STATE.Equals("F") && !blockCanCharge)
                    {
                        context.AddError("A001090105:余额账本状态无效");
                        return false;
                    }
                }
            }
            return true;
        }

        /// <summary>
        /// 创建人：殷华荣 2012-8-24
        /// 根据账号ID获取账户信息
        /// </summary>
        /// <param name="context"></param>
        /// <param name="cardno"></param>
        /// <param name="acctid"></param>
        /// <param name="checkState"></param>
        /// <returns></returns>
        public static bool GetCustAcctInfo(CmnContext context, string cardno, string acctid, bool checkState)
        {
            TMTableModule tmTMTableModule = new TMTableModule();
            //客户账户
            TF_F_CUST_ACCTTDO ddoTF_F_CUST_ACCTIn = new TF_F_CUST_ACCTTDO();
            ddoTF_F_CUST_ACCTIn.ACCT_ID = acctid;
            TF_F_CUST_ACCTTDO ddoTF_F_CUST_ACCTOut = (TF_F_CUST_ACCTTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUST_ACCTIn, typeof(TF_F_CUST_ACCTTDO), null, "TF_F_CUST_ACCT_ID", null);
            if (ddoTF_F_CUST_ACCTOut == null)
            {
                context.AddError("A001090102:未查出客户账户信息");
                return false;
            }
            else if (!ddoTF_F_CUST_ACCTOut.STATE.Equals("A"))
            {
                if (checkState)
                {
                    context.AddError("A001090103:客户账户状态无效");
                    return false;
                }
            }
            //余额账本
            TF_F_ACCT_BALANCETDO ddoTF_F_ACCT_BALANCEIn = new TF_F_ACCT_BALANCETDO();
            ddoTF_F_ACCT_BALANCEIn.ICCARD_NO = cardno;
            ddoTF_F_ACCT_BALANCEIn.ACCT_ID = ddoTF_F_CUST_ACCTOut.ACCT_ID;
            TF_F_ACCT_BALANCETDO ddoTF_F_ACCT_BALANCEOut = (TF_F_ACCT_BALANCETDO)tmTMTableModule.selByPK(context, ddoTF_F_ACCT_BALANCEIn, typeof(TF_F_ACCT_BALANCETDO), null, "TF_F_ACCT_BALANCE", null);
            if (ddoTF_F_ACCT_BALANCEOut == null)
            {
                context.AddError("A001090104:未查出余额账本信息");
                return false;
            }
            else if (!ddoTF_F_ACCT_BALANCEOut.STATE.Equals("A"))
            {
                if (checkState)
                {
                    context.AddError("A001090105:余额账本状态无效");
                    return false;
                }
            }
            return true;
        }

        /// <summary>
        /// 获取帐户信息
        /// </summary>
        /// <param name="context">上下文</param>
        /// <param name="cardno">卡号</param>
        /// <param name="cust_id">帐号</param>
        /// <param name="listDDO">DDO列表</param>
        /// <returns></returns>
        public static bool GetCustInfo(CmnContext context, string cardno, string cust_id, out  Dictionary<String, DDOBase> listDDO)
        {
            listDDO = new Dictionary<String, DDOBase>();
            TMTableModule tmTMTableModule = new TMTableModule();

            //从客户资料表(TF_F_CUSTOMERREC)中读取数据

            TF_F_CUSTTDO ddoTF_F_CUSTIn = new TF_F_CUSTTDO();
            ddoTF_F_CUSTIn.CUST_ID = cust_id;

            TF_F_CUSTTDO ddoTF_F_CUSTOut = (TF_F_CUSTTDO)tmTMTableModule.selByPK(context, ddoTF_F_CUSTIn, typeof(TF_F_CUSTTDO), null, "TF_F_CUST_BYID", null);

            if (ddoTF_F_CUSTOut == null)
            {
                context.AddError("A001107112");
                return false;
            }

            //客户账户表

            listDDO.Add("TF_F_CUST", ddoTF_F_CUSTOut);

            //从证件类型编码表(TD_M_PAPERTYPE)中读取数据

            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEIn = new TD_M_PAPERTYPETDO();
            ddoTD_M_PAPERTYPEIn.PAPERTYPECODE = ddoTF_F_CUSTOut.PAPER_TYPE_CODE;
            TD_M_PAPERTYPETDO ddoTD_M_PAPERTYPEOut = (TD_M_PAPERTYPETDO)tmTMTableModule.selByPK(context, ddoTD_M_PAPERTYPEIn, typeof(TD_M_PAPERTYPETDO), null, "TD_M_PAPERTYPE_DESTROY", null);

            //证件类型编码表(TD_M_PAPERTYPE)
            listDDO.Add("TD_M_PAPERTYPE", ddoTD_M_PAPERTYPEOut);
            return true;

        }

        /// <summary>
        /// 校验是否可以返销并显示返销信息
        /// </summary>
        /// <param name="context">上下文</param>
        /// <param name="cardno">卡号</param>
        /// <param name="tradeType">台帐类型</param>
        /// <param name="tradeStr">台帐字符串</param>
        /// <param name="trade">台帐MODEL</param>
        /// <returns></returns>
        public static bool GetRollbackInfo(CmnContext context, string accid, string tradeType, string tradeStr, out TF_B_TRADE_ACCOUNTTDO trade)
        {
            return GetRollbackInfo(context, accid, "", tradeType, tradeStr, out trade);
        }

        /// <summary>
        /// 校验是否可以返销并显示返销信息
        /// </summary>
        /// <param name="context">上下文</param>
        /// <param name="cardno">卡号</param>
        /// <param name="cardno2">卡号2</param>
        /// <param name="tradeType">台帐类型</param>
        /// <param name="tradeStr">台帐字符串/param>
        /// <param name="trade">台帐MODEL</param>
        /// <returns></returns>
        public static bool GetRollbackInfo(CmnContext context, string accid, string accid2, string tradeType, string tradeStr, out TF_B_TRADE_ACCOUNTTDO trade)
        {
            trade = new TF_B_TRADE_ACCOUNTTDO();
            TMTableModule tmTMTableModule = new TMTableModule();

            //查询是否当天当操作员进行
            TF_F_CARDRECTDO ddoTF_F_CARDRECIn = new TF_F_CARDRECTDO();

            string str = " Select 1 From TF_B_TRADE_ACCOUNT WHERE ACCTID = '" + accid + "' " +
                         " And OPERATETIME BETWEEN Trunc(sysdate,'dd') AND sysdate" +
                         " And OPERATESTAFFNO = '" + context.s_UserID + "' ";
            DataTable data = tmTMTableModule.selByPKDataTable(context, ddoTF_F_CARDRECIn, null, str, 0);
            if (data.Rows.Count == 0)
            {
                context.AddError("A006015100:不是当天当操作员" + tradeStr);
                return false;
            }

            //查询操作是否最新的一次业务操作

            TF_B_TRADE_ACCOUNTTDO ddoTF_B_TRADEIn = new TF_B_TRADE_ACCOUNTTDO();
            string strSale = @"Select TRADETYPECODE From TF_B_TRADE_ACCOUNT WHERE ACCTID = '" + accid + @"' 
                            And OPERATETIME > (SELECT OPERATETIME FROM 
                                 ( SELECT OPERATETIME FROM TF_B_TRADE_ACCOUNT WHERE CANCELTAG = '0' AND ACCTID = '" + accid + @"' AND TRADETYPECODE = '" + tradeType + @"' ORDER BY OPERATETIME DESC) 
                            WHERE ROWNUM<=1) 
                             AND CANCELTAG = '0'  AND (ASCII(TRADETYPECODE) < 65 AND TRADETYPECODE NOT IN ('3A','3B'))";
            DataTable dataSale = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strSale, 0);
            if (dataSale.Rows.Count > 0)
            {
                context.AddError("A006015101:" + tradeStr + "操作不是最近一次业务操作");
                return false;
            }

            if (accid2 != "")
            {
                ddoTF_B_TRADEIn = new TF_B_TRADE_ACCOUNTTDO();
                strSale = @"Select TRADETYPECODE From TF_B_TRADE_ACCOUNT WHERE ACCTID = '" + accid2 + @"' 
                            And OPERATETIME > (SELECT OPERATETIME FROM 
                                 ( SELECT OPERATETIME FROM TF_B_TRADE_ACCOUNT WHERE CANCELTAG = '0' AND ACCTID = '" + accid2 + @"' AND TRADETYPECODE = '" + tradeType + @"' ORDER BY OPERATETIME DESC) 
                            WHERE ROWNUM<=1) 
                            AND CANCELTAG = '0' AND (ASCII(TRADETYPECODE) < 65 AND TRADETYPECODE NOT IN ('3A','3B'))";
                dataSale = tmTMTableModule.selByPKDataTable(context, ddoTF_B_TRADEIn, null, strSale, 0);
                if (dataSale.Rows.Count > 0)
                {
                    context.AddError("A006015101:" + tradeStr + "操作不是最近一次业务操作");
                    return false;
                }
            }

            string strTradeid = @"SELECT *
                              FROM (SELECT *
                                      FROM TF_B_TRADE_ACCOUNT
                                     WHERE ACCTID = '" + accid + @"'
                                       AND TRADETYPECODE = '" + tradeType + @"'
                                       AND CANCELTAG = '0'
                                     ORDER BY OPERATETIME DESC)
                             WHERE ROWNUM <= 1";

            trade = (TF_B_TRADE_ACCOUNTTDO)tmTMTableModule.selByPK(context, ddoTF_B_TRADEIn, typeof(TF_B_TRADE_ACCOUNTTDO), null, strTradeid);
            return true;
        }

        public static DataTable callQuery(CmnContext context, string funcCode, params string[] vars)
        {
            SP_CA_QueryPDO pdo = new SP_CA_QueryPDO();
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

        static public void FillAcctType(CmnContext context, DropDownList ddl)
        {
            DataTable data = CAHelper.callQuery(context, "QRYACCTOUNTTYPE");
            ddl.Items.Clear();
            GroupCardHelper.fill(ddl, data, true);
            if (ddl.Items.Count > 1)
            {
                ddl.SelectedIndex = 1;
            }
        }

        //验证是否有免输密码的权限
        static public bool HasNoPasswordPower(CmnContext context)
        {
            string powerCode = "201212";//是否有免输密码的权限
            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
            string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
            DataTable dataSupply = tmTMTableModule.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
            if (dataSupply.Rows.Count > 0)
                return true;
            else
                return false;
        }

        //根据value确定dropdownlist选中项
     public   static void SelectDDLByNo(DropDownList ddl, string value)
        {
            if (ddl != null && ddl.Items.Count > 0)
            {
                for (int i = 0; i < ddl.Items.Count; i++)
                {
                    if (ddl.Items[i].Value.Trim() == value.Trim())
                    {
                        ddl.SelectedIndex = i;
                        break;
                    }
                }
            }
        }

    }
}