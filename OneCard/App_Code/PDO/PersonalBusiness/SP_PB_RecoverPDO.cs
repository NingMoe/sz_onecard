using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // Ĩ��
     public class SP_PB_RecoverPDO : PDOBase
     {
          public SP_PB_RecoverPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_Recover",18);

               AddField("@ID", "string", "18", "input");
               AddField("@CARDACCMONEY", "Int32", "", "input");
               AddField("@CANCELMONEY", "Int32", "", "input");
               AddField("@CARDTRADENO", "string", "4", "input");
               AddField("@CARDNO", "string", "16", "input");
               AddField("@TRADETYPECODE", "string", "2", "input");
               AddField("@ASN", "string", "16", "input");
               AddField("@CARDTYPECODE", "string", "2", "input");
               AddField("@CARDMONEY", "Int32", "", "input");
               AddField("@SUPPLYID", "string", "18", "input");
               AddField("@TERMNO", "string", "12", "input");
               AddField("@OPERCARDNO", "string", "16", "input");
               AddField("@TRADEID", "string", "16", "output");

               InitEnd();
          }

          // ��¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // �ʻ����
          public Int32 CARDACCMONEY
          {
              get { return  GetInt32("CARDACCMONEY"); }
              set { SetInt32("CARDACCMONEY",value); }
          }

          // Ĩ�ʽ��
          public Int32 CANCELMONEY
          {
              get { return  GetInt32("CANCELMONEY"); }
              set { SetInt32("CANCELMONEY",value); }
          }

          // �����������
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // ����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // �������ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
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

          // �������
          public Int32 CARDMONEY
          {
              get { return  GetInt32("CARDMONEY"); }
              set { SetInt32("CARDMONEY",value); }
          }

          // ��Ӧ��ֵ��¼��ID
          public string SUPPLYID
          {
              get { return  Getstring("SUPPLYID"); }
              set { Setstring("SUPPLYID",value); }
          }

          // �ն˺�
          public string TERMNO
          {
              get { return  Getstring("TERMNO"); }
              set { Setstring("TERMNO",value); }
          }

          // ����Ա����
          public string OPERCARDNO
          {
              get { return  Getstring("OPERCARDNO"); }
              set { Setstring("OPERCARDNO",value); }
          }

          // ���ؽ������к�
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

     }
}


