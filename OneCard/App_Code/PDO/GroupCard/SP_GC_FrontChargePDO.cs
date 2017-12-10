using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.GroupCard
{
     // �����ǰ̨��ֵ
     public class SP_GC_FrontChargePDO : PDOBase
     {
          public SP_GC_FrontChargePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_GC_FrontCharge",19);

               AddField("@ID", "string", "18", "input");
               AddField("@CARDNO", "string", "16", "input");
               AddField("@CARDTRADENO", "string", "4", "input");
               AddField("@CARDMONEY", "Int32", "", "input");
               AddField("@CARDACCMONEY", "Int32", "", "input");
               AddField("@ASN", "string", "16", "input");
               AddField("@CARDTYPECODE", "string", "2", "input");
               AddField("@SUPPLYMONEY", "Int32", "", "input");
               AddField("@TRADETYPECODE", "string", "2", "input");
               AddField("@CORPNO", "string", "4", "input");
               AddField("@DBMONEY", "Int32", "", "input");
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

          // ����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // �����������
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // �������
          public Int32 CARDMONEY
          {
              get { return  GetInt32("CARDMONEY"); }
              set { SetInt32("CARDMONEY",value); }
          }

          // �ʻ����
          public Int32 CARDACCMONEY
          {
              get { return  GetInt32("CARDACCMONEY"); }
              set { SetInt32("CARDACCMONEY",value); }
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

          // ��ֵ���
          public Int32 SUPPLYMONEY
          {
              get { return  GetInt32("SUPPLYMONEY"); }
              set { SetInt32("SUPPLYMONEY",value); }
          }

          // ҵ�����ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // ���ſͻ�����
          public string CORPNO
          {
              get { return  Getstring("CORPNO"); }
              set { Setstring("CORPNO",value); }
          }

          // �ɳ���
          public Int32 DBMONEY
          {
              get { return  GetInt32("DBMONEY"); }
              set { SetInt32("DBMONEY",value); }
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


