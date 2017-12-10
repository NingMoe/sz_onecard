using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.AdditionalService
{
     // �����꿨����
     public class SP_AS_RelaxCardNewPDO : PDOBase
     {
          public SP_AS_RelaxCardNewPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_AS_RelaxCardNew",23);

               AddField("@ID", "string", "18", "input");
               AddField("@cardNo", "string", "16", "input");
               AddField("@cardTradeNo", "string", "4", "input");
               AddField("@asn", "string", "16", "input");
               AddField("@tradeFee", "Int32", "", "input");
               AddField("@operCardNo", "string", "16", "input");
               AddField("@terminalNo", "string", "12", "input");
               AddField("@endDateNum", "string", "12", "input");
               AddField("@custSex", "String", "2", "input");
               AddField("@custBirth", "String", "8", "input");
               AddField("@paperType", "String", "2", "input");
               AddField("@paperNo", "String", "20", "input");
               AddField("@custPost", "String", "6", "input");
               AddField("@custEmail", "String", "30", "input");
               AddField("@remark", "String", "100", "input");


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

          // �������ܷ�
          public Int32 tradeFee
          {
              get { return  GetInt32("tradeFee"); }
              set { SetInt32("tradeFee",value); }
          }

          // ����Ա����
          public string operCardNo
          {
              get { return  Getstring("operCardNo"); }
              set { Setstring("operCardNo",value); }
          }

          // �ն˱���
          public string terminalNo
          {
              get { return  Getstring("terminalNo"); }
              set { Setstring("terminalNo",value); }
          }

          // ��Ƭ���ϱ������
          public string endDateNum
          {
              get { return  Getstring("endDateNum"); }
              set { Setstring("endDateNum",value); }
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

     }
}


