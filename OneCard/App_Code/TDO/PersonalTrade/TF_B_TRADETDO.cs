using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // ҵ��̨������
     public class TF_B_TRADETDO : DDOBase
     {
          public TF_B_TRADETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_TRADE";

               columns = new String[28][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"CARDNO", "string"};
               columns[2] = new String[]{"ID", "string"};
               columns[3] = new String[]{"TRADETYPECODE", "string"};
               columns[4] = new String[]{"ASN", "string"};
               columns[5] = new String[]{"CARDTYPECODE", "string"};
               columns[6] = new String[]{"CARDTRADENO", "string"};
               columns[7] = new String[]{"REASONCODE", "string"};
               columns[8] = new String[]{"OLDCARDNO", "string"};
               columns[9] = new String[]{"DEPOSIT", "Int32"};
               columns[10] = new String[]{"OLDCARDMONEY", "Int32"};
               columns[11] = new String[]{"CURRENTMONEY", "Int32"};
               columns[12] = new String[]{"PREMONEY", "Int32"};
               columns[13] = new String[]{"NEXTMONEY", "Int32"};
               columns[14] = new String[]{"CORPNO", "string"};
               columns[15] = new String[]{"OPERATESTAFFNO", "string"};
               columns[16] = new String[]{"OPERATEDEPARTID", "string"};
               columns[17] = new String[]{"OPERATETIME", "DateTime"};
               columns[18] = new String[]{"CHECKSTAFFNO", "string"};
               columns[19] = new String[]{"CHECKDEPARTNO", "string"};
               columns[20] = new String[]{"CHECKTIME", "DateTime"};
               columns[21] = new String[]{"STATECODE", "string"};
               columns[22] = new String[]{"CANCELTAG", "string"};
               columns[23] = new String[]{"CANCELTRADEID", "string"};
               columns[24] = new String[]{"CARDSTATE", "string"};
               columns[25] = new String[]{"SERSTAKETAG", "string"};
               columns[26] = new String[]{"RSRV1", "String"};
               columns[27] = new String[]{"RSRV2", "String"};

               columnKeys = new String[]{
                   "TRADEID",
                   "CARDNO",
               };


               array = new String[28];
               hash.Add("TRADEID", 0);
               hash.Add("CARDNO", 1);
               hash.Add("ID", 2);
               hash.Add("TRADETYPECODE", 3);
               hash.Add("ASN", 4);
               hash.Add("CARDTYPECODE", 5);
               hash.Add("CARDTRADENO", 6);
               hash.Add("REASONCODE", 7);
               hash.Add("OLDCARDNO", 8);
               hash.Add("DEPOSIT", 9);
               hash.Add("OLDCARDMONEY", 10);
               hash.Add("CURRENTMONEY", 11);
               hash.Add("PREMONEY", 12);
               hash.Add("NEXTMONEY", 13);
               hash.Add("CORPNO", 14);
               hash.Add("OPERATESTAFFNO", 15);
               hash.Add("OPERATEDEPARTID", 16);
               hash.Add("OPERATETIME", 17);
               hash.Add("CHECKSTAFFNO", 18);
               hash.Add("CHECKDEPARTNO", 19);
               hash.Add("CHECKTIME", 20);
               hash.Add("STATECODE", 21);
               hash.Add("CANCELTAG", 22);
               hash.Add("CANCELTRADEID", 23);
               hash.Add("CARDSTATE", 24);
               hash.Add("SERSTAKETAG", 25);
               hash.Add("RSRV1", 26);
               hash.Add("RSRV2", 27);
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // IC����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ��¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // ҵ�����ͱ���
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

          // ҵ�����ԭ�����
          public string REASONCODE
          {
              get { return  Getstring("REASONCODE"); }
              set { Setstring("REASONCODE",value); }
          }

          // �ɿ�����
          public string OLDCARDNO
          {
              get { return  Getstring("OLDCARDNO"); }
              set { Setstring("OLDCARDNO",value); }
          }

          // �ɿ�ʣ��Ѻ��
          public Int32 DEPOSIT
          {
              get { return  GetInt32("DEPOSIT"); }
              set { SetInt32("DEPOSIT",value); }
          }

          // �ɿ����
          public Int32 OLDCARDMONEY
          {
              get { return  GetInt32("OLDCARDMONEY"); }
              set { SetInt32("OLDCARDMONEY",value); }
          }

          // �������
          public Int32 CURRENTMONEY
          {
              get { return  GetInt32("CURRENTMONEY"); }
              set { SetInt32("CURRENTMONEY",value); }
          }

          // ����ǰ���
          public Int32 PREMONEY
          {
              get { return  GetInt32("PREMONEY"); }
              set { SetInt32("PREMONEY",value); }
          }

          // ���������
          public Int32 NEXTMONEY
          {
              get { return  GetInt32("NEXTMONEY"); }
              set { SetInt32("NEXTMONEY",value); }
          }

          // ���ſͻ�����
          public string CORPNO
          {
              get { return  Getstring("CORPNO"); }
              set { Setstring("CORPNO",value); }
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

          // ��������Ա
          public string CHECKSTAFFNO
          {
              get { return  Getstring("CHECKSTAFFNO"); }
              set { Setstring("CHECKSTAFFNO",value); }
          }

          // �������ű���
          public string CHECKDEPARTNO
          {
              get { return  Getstring("CHECKDEPARTNO"); }
              set { Setstring("CHECKDEPARTNO",value); }
          }

          // ����ʱ��
          public DateTime CHECKTIME
          {
              get { return  GetDateTime("CHECKTIME"); }
              set { SetDateTime("CHECKTIME",value); }
          }

          // ״̬����
          public string STATECODE
          {
              get { return  Getstring("STATECODE"); }
              set { Setstring("STATECODE",value); }
          }

          // ���˱�־
          public string CANCELTAG
          {
              get { return  Getstring("CANCELTAG"); }
              set { Setstring("CANCELTAG",value); }
          }

          // ����ҵ����ˮ��
          public string CANCELTRADEID
          {
              get { return  Getstring("CANCELTRADEID"); }
              set { Setstring("CANCELTRADEID",value); }
          }

          // ��״̬
          public string CARDSTATE
          {
              get { return  Getstring("CARDSTATE"); }
              set { Setstring("CARDSTATE",value); }
          }

          // �������ȡ��־
          public string SERSTAKETAG
          {
              get { return  Getstring("SERSTAKETAG"); }
              set { Setstring("SERSTAKETAG",value); }
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


