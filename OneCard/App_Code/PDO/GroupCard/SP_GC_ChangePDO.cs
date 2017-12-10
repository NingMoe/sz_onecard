using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.GroupCard
{
     // ���������
     public class SP_GC_ChangePDO : PDOBase
     {
          public SP_GC_ChangePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_GC_Change",18);

               AddField("@oldCardNo", "String", "16", "input");
               AddField("@newCardNo", "String", "16", "input");

               AddField("@replaceInfo", "String", "1", "input");
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

          // �Ͽ���
         public String oldCardNo
          {
              get { return GetString("oldCardNo"); }
              set { SetString("oldCardNo", value); }
          }

         public String replaceInfo
          {
              get { return GetString("replaceInfo"); }
              set { SetString("replaceInfo", value); }
          }

          // �¿���
          public String newCardNo
          {
              get { return  GetString("newCardNo"); }
              set { SetString("newCardNo",value); }
          }
          // ����
          public String custName
          {
              get { return GetString("custName"); }
              set { SetString("custName", value); }
          }

          // �Ա�
          public String custSex
          {
              get { return GetString("custSex"); }
              set { SetString("custSex", value); }
          }

          // ��������
          public String custBirth
          {
              get { return GetString("custBirth"); }
              set { SetString("custBirth", value); }
          }

          // ֤�����ͱ���
          public String paperType
          {
              get { return GetString("paperType"); }
              set { SetString("paperType", value); }
          }

          // ֤������
          public String paperNo
          {
              get { return GetString("paperNo"); }
              set { SetString("paperNo", value); }
          }

          // ��ϵ��ַ
          public String custAddr
          {
              get { return GetString("custAddr"); }
              set { SetString("custAddr", value); }
          }

          // ��������
          public String custPost
          {
              get { return GetString("custPost"); }
              set { SetString("custPost", value); }
          }

          // ��ϵ�绰
          public String custPhone
          {
              get { return GetString("custPhone"); }
              set { SetString("custPhone", value); }
          }

          // �����ʼ�
          public String custEmail
          {
              get { return GetString("custEmail"); }
              set { SetString("custEmail", value); }
          }

          // ��ע
          public String remark
          {
              get { return GetString("remark"); }
              set { SetString("remark", value); }
          }

     }
}


