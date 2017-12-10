using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // ����
     public class SP_PB_DestroyPDO : PDOBase
     {
          public SP_PB_DestroyPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_Destroy",12);

               AddField("@ID", "string", "18", "input");
               AddField("@CARDNO", "string", "16", "input");
               AddField("@ASN", "string", "16", "input");
               AddField("@CARDTYPECODE", "string", "2", "input");
               AddField("@CARDACCMONEY", "Int32", "", "input");
               AddField("@RDFUNDMONEY", "Int32", "", "input");
               AddField("@TRADEID", "string", "16", "output");

               InitEnd();
          }

          // ��¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // ����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // Ӧ�����к�
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // �����ͱ���
          public string CARDTYPECODE
          {
              get { return  Getstring("CARDTYPECODE"); }
              set { Setstring("CARDTYPECODE",value); }
          }

          // �ʻ����
          public Int32 CARDACCMONEY
          {
              get { return  GetInt32("CARDACCMONEY"); }
              set { SetInt32("CARDACCMONEY",value); }
          }

          // �˳�ֵ
          public Int32 RDFUNDMONEY
          {
              get { return  GetInt32("RDFUNDMONEY"); }
              set { SetInt32("RDFUNDMONEY",value); }
          }

          // ���ؽ������к�
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

     }
}


