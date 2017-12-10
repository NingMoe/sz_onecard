using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.AdditionalService
{
     // ��Ʊ���ۿ�
     public class SP_AS_MonthlyCardNewPDO : PDOBase
     {
          public SP_AS_MonthlyCardNewPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_AS_MonthlyCardNew",31);

               AddField("@ID", "string", "18", "input");
               AddField("@cardNo", "string", "16", "input");
               AddField("@deposit", "Int32", "", "input");
               AddField("@cardCost", "Int32", "", "input");
               AddField("@otherFee", "Int32", "", "input");
               AddField("@cardTradeNo", "string", "4", "input");
               AddField("@asn", "string", "16", "input");
               AddField("@cardMoney", "Int32", "", "input");
               AddField("@sellChannelCode", "string", "2", "input");
               AddField("@serTakeTag", "string", "1", "input");
               AddField("@tradeTypeCode", "string", "2", "input");
               AddField("@terminalNo", "string", "12", "input");
               AddField("@custSex", "String", "2", "input");
               AddField("@custBirth", "String", "8", "input");
               AddField("@paperType", "String", "2", "input");
               AddField("@paperNo", "String", "20", "input");
               AddField("@custPost", "String", "6", "input");
               AddField("@custEmail", "String", "30", "input");
               AddField("@remark", "String", "100", "input");
               AddField("@custRecTypeCode", "string", "1", "input");
               AddField("@appType", "string", "2", "input");
               AddField("@assignedArea", "string", "2", "input");
               AddField("@currCardNo", "string", "16", "input");

               //UPDATE BY JINAGBB 2012-04-19 �ֶμ��ܳ����޸�
               AddField("@custName", "String", "200", "input");
               AddField("@custAddr", "String", "600", "input");
               AddField("@custPhone", "String", "200", "input");
               //AddField("@CUSTNAME", "String", "50", "input");
               //AddField("@CUSTADDR", "String", "50", "input");
               //AddField("@CUSTPHONE", "String", "40", "input");

               InitEnd();
          }

          // ��¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // ����
          public string cardNo
          {
              get { return  Getstring("cardNo"); }
              set { Setstring("cardNo",value); }
          }

          // ��Ѻ��
          public Int32 deposit
          {
              get { return  GetInt32("deposit"); }
              set { SetInt32("deposit",value); }
          }

          // ����
          public Int32 cardCost
          {
              get { return  GetInt32("cardCost"); }
              set { SetInt32("cardCost",value); }
          }

          // ��������
          public Int32 otherFee
          {
              get { return  GetInt32("otherFee"); }
              set { SetInt32("otherFee",value); }
          }

          // �����������
          public string cardTradeNo
          {
              get { return  Getstring("cardTradeNo"); }
              set { Setstring("cardTradeNo",value); }
          }

          // Ӧ�����к�
          public string asn
          {
              get { return  Getstring("asn"); }
              set { Setstring("asn",value); }
          }

          // �������
          public Int32 cardMoney
          {
              get { return  GetInt32("cardMoney"); }
              set { SetInt32("cardMoney",value); }
          }

          // �ۿ���������
          public string sellChannelCode
          {
              get { return  Getstring("sellChannelCode"); }
              set { Setstring("sellChannelCode",value); }
          }

          // �������ȡ��־
          public string serTakeTag
          {
              get { return  Getstring("serTakeTag"); }
              set { Setstring("serTakeTag",value); }
          }

          // �������ͱ���
          public string tradeTypeCode
          {
              get { return  Getstring("tradeTypeCode"); }
              set { Setstring("tradeTypeCode",value); }
          }

          // ��Ƭ���ϱ������
          public string terminalNo
          {
              get { return  Getstring("terminalNo"); }
              set { Setstring("terminalNo",value); }
          }

          // ����
          public String custName
          {
              get { return  GetString("custName"); }
              set { SetString("custName",value); }
          }

          // �Ա�
          public String custSex
          {
              get { return  GetString("custSex"); }
              set { SetString("custSex",value); }
          }

          // ��������
          public String custBirth
          {
              get { return  GetString("custBirth"); }
              set { SetString("custBirth",value); }
          }

          // ֤�����ͱ���
          public String paperType
          {
              get { return  GetString("paperType"); }
              set { SetString("paperType",value); }
          }

          // ֤������
          public String paperNo
          {
              get { return  GetString("paperNo"); }
              set { SetString("paperNo",value); }
          }

          // ��ϵ��ַ
          public String custAddr
          {
              get { return  GetString("custAddr"); }
              set { SetString("custAddr",value); }
          }

          // ��������
          public String custPost
          {
              get { return  GetString("custPost"); }
              set { SetString("custPost",value); }
          }

          // ��ϵ�绰
          public String custPhone
          {
              get { return  GetString("custPhone"); }
              set { SetString("custPhone",value); }
          }

          // �����ʼ�
          public String custEmail
          {
              get { return  GetString("custEmail"); }
              set { SetString("custEmail",value); }
          }

          // ��ע
          public String remark
          {
              get { return  GetString("remark"); }
              set { SetString("remark",value); }
          }

          // �ֿ�����������
          public string custRecTypeCode
          {
              get { return  Getstring("custRecTypeCode"); }
              set { Setstring("custRecTypeCode",value); }
          }

          // ��Ʊ����
          public string appType
          {
              get { return  Getstring("appType"); }
              set { Setstring("appType",value); }
          }

          // ������������
          public string assignedArea
          {
              get { return  Getstring("assignedArea"); }
              set { Setstring("assignedArea",value); }
          }

          // ����Ա��
          public string currCardNo
          {
              get { return  Getstring("currCardNo"); }
              set { Setstring("currCardNo",value); }
          }

     }
}


