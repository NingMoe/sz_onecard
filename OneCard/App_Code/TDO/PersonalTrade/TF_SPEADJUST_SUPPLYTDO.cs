using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // ������ʽ�������Ǯ����ֵ̨�ʱ�
     public class TF_SPEADJUST_SUPPLYTDO : DDOBase
     {
          public TF_SPEADJUST_SUPPLYTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_SPEADJUST_SUPPLY";

               columns = new String[14][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"ID", "string"};
               columns[2] = new String[]{"CARDNO", "string"};
               columns[3] = new String[]{"ASN", "string"};
               columns[4] = new String[]{"CARDTYPECODE", "string"};
               columns[5] = new String[]{"CARDTRADENO", "string"};
               columns[6] = new String[]{"TRADEMONEY", "Int32"};
               columns[7] = new String[]{"PREMONEY", "Int32"};
               columns[8] = new String[]{"TERMNO", "string"};
               columns[9] = new String[]{"OPERATESTAFFNO", "string"};
               columns[10] = new String[]{"OPERATEDEPARTID", "string"};
               columns[11] = new String[]{"OPERATETIME", "DateTime"};
               columns[12] = new String[]{"RSRV1", "String"};
               columns[13] = new String[]{"RSRV2", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[14];
               hash.Add("TRADEID", 0);
               hash.Add("ID", 1);
               hash.Add("CARDNO", 2);
               hash.Add("ASN", 3);
               hash.Add("CARDTYPECODE", 4);
               hash.Add("CARDTRADENO", 5);
               hash.Add("TRADEMONEY", 6);
               hash.Add("PREMONEY", 7);
               hash.Add("TERMNO", 8);
               hash.Add("OPERATESTAFFNO", 9);
               hash.Add("OPERATEDEPARTID", 10);
               hash.Add("OPERATETIME", 11);
               hash.Add("RSRV1", 12);
               hash.Add("RSRV2", 13);
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // ��¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // IC����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // �����к�
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // ������
          public string CARDTYPECODE
          {
              get { return  Getstring("CARDTYPECODE"); }
              set { Setstring("CARDTYPECODE",value); }
          }

          // �����������
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // ���׽��
          public Int32 TRADEMONEY
          {
              get { return  GetInt32("TRADEMONEY"); }
              set { SetInt32("TRADEMONEY",value); }
          }

          // ��ֵǰ�������
          public Int32 PREMONEY
          {
              get { return  GetInt32("PREMONEY"); }
              set { SetInt32("PREMONEY",value); }
          }

          // �ն˻����
          public string TERMNO
          {
              get { return  Getstring("TERMNO"); }
              set { Setstring("TERMNO",value); }
          }

          // ����Ա������
          public string OPERATESTAFFNO
          {
              get { return  Getstring("OPERATESTAFFNO"); }
              set { Setstring("OPERATESTAFFNO",value); }
          }

          // ���ű���
          public string OPERATEDEPARTID
          {
              get { return  Getstring("OPERATEDEPARTID"); }
              set { Setstring("OPERATEDEPARTID",value); }
          }

          // ����ʱ��
          public DateTime OPERATETIME
          {
              get { return  GetDateTime("OPERATETIME"); }
              set { SetDateTime("OPERATETIME",value); }
          }

          // ����1
          public String RSRV1
          {
              get { return  GetString("RSRV1"); }
              set { SetString("RSRV1",value); }
          }

          // ����2
          public String RSRV2
          {
              get { return  GetString("RSRV2"); }
              set { SetString("RSRV2",value); }
          }

     }
}


