using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // ����Ǯ�����������ˮ��
     public class TF_B_EWALLETCHANGETDO : DDOBase
     {
          public TF_B_EWALLETCHANGETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_EWALLETCHANGE";

               columns = new String[13][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"ID", "string"};
               columns[2] = new String[]{"CARDNO", "string"};
               columns[3] = new String[]{"ASN", "string"};
               columns[4] = new String[]{"TRADETYPECODE", "string"};
               columns[5] = new String[]{"REASONCODE", "string"};
               columns[6] = new String[]{"PSAMNO", "string"};
               columns[7] = new String[]{"OPERATESTAFFNO", "string"};
               columns[8] = new String[]{"OPERATEDEPARTID", "string"};
               columns[9] = new String[]{"OPERATETIME", "DateTime"};
               columns[10] = new String[]{"CANCELTAG", "string"};
               columns[11] = new String[]{"RSRV1", "String"};
               columns[12] = new String[]{"RSRV2", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[13];
               hash.Add("TRADEID", 0);
               hash.Add("ID", 1);
               hash.Add("CARDNO", 2);
               hash.Add("ASN", 3);
               hash.Add("TRADETYPECODE", 4);
               hash.Add("REASONCODE", 5);
               hash.Add("PSAMNO", 6);
               hash.Add("OPERATESTAFFNO", 7);
               hash.Add("OPERATEDEPARTID", 8);
               hash.Add("OPERATETIME", 9);
               hash.Add("CANCELTAG", 10);
               hash.Add("RSRV1", 11);
               hash.Add("RSRV2", 12);
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

          // Ӧ�����к�
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // ҵ�����ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // ԭ�����
          public string REASONCODE
          {
              get { return  Getstring("REASONCODE"); }
              set { Setstring("REASONCODE",value); }
          }

          // PSAM���
          public string PSAMNO
          {
              get { return  Getstring("PSAMNO"); }
              set { Setstring("PSAMNO",value); }
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

          // ���˱�־
          public string CANCELTAG
          {
              get { return  Getstring("CANCELTAG"); }
              set { Setstring("CANCELTAG",value); }
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


