using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.AdditionalService
{
     // �����꿨������
     public class SP_AS_RelaxCardChangePDO : PDOBase
     {
          public SP_AS_RelaxCardChangePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_AS_RelaxCardChange",22);

               AddField("@ID", "string", "18", "input");
               AddField("@oldCardNo", "string", "16", "input");
               AddField("@newCardNo", "string", "16", "input");
               AddField("@asn", "string", "16", "input");
               AddField("@operCardNo", "string", "16", "input");
               AddField("@terminalNo", "string", "12", "input");
               AddField("@endDateNum", "string", "12", "input");
               AddField("@packageTypeCode", "string", "02", "input");
               AddField("@custSex", "String", "2", "input");
               AddField("@custBirth", "String", "8", "input");
               AddField("@paperType", "String", "2", "input");
               AddField("@paperNo", "String", "20", "input");
               AddField("@custPost", "String", "6", "input");
               AddField("@custEmail", "String", "30", "input");
               AddField("@remark", "String", "100", "input");
               AddField("@passPaperNo", "String", "20", "input");
               AddField("@passCustName", "String", "200", "input");
               AddField("@serviceFor", "String", "1", "input");
               AddField("@cityCode", "String", "4", "input");

               //UPDATE BY JINAGBB 2012-04-19 �ֶμ��ܳ����޸�
               AddField("@custName", "String", "200", "input");
               AddField("@custAddr", "String", "600", "input");
               AddField("@custPhone", "String", "200", "input");
               //AddField("@CUSTNAME", "String", "50", "input");
               //AddField("@CUSTADDR", "String", "50", "input");
               //AddField("@CUSTPHONE", "String", "40", "input");

               InitEnd();
          }
          // ����֤������
          public string passPaperNo
          {
              get { return Getstring("passPaperNo"); }
              set { Setstring("passPaperNo", value); }
          }
          // ��������
          public string passCustName
          {
              get { return Getstring("passCustName"); }
              set { Setstring("passCustName", value); }
          }
          // �Ƿ�ͬ�����б�ʶλ
          public string serviceFor
          {
              get { return Getstring("serviceFor"); }
              set { Setstring("serviceFor", value); }
          }
          // ���д���
          public string cityCode
          {
              get { return Getstring("cityCode"); }
              set { Setstring("cityCode", value); }
          }

          // ��¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // �ɿ�����
          public string oldCardNo
          {
              get { return  Getstring("oldCardNo"); }
              set { Setstring("oldCardNo",value); }
          }

          // �¿�����
          public string newCardNo
          {
              get { return  Getstring("newCardNo"); }
              set { Setstring("newCardNo",value); }
          }

          // Ӧ�����к�
          public string asn
          {
              get { return  Getstring("asn"); }
              set { Setstring("asn",value); }
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

          // �ײ�����
          public string packageTypeCode
          {
              get { return Getstring("packageTypeCode"); }
              set { Setstring("packageTypeCode", value); }
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


