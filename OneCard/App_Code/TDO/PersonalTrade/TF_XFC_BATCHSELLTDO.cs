using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // ��ֵ��ֱ��̨�ʱ�
     public class TF_XFC_BATCHSELLTDO : DDOBase
     {
          public TF_XFC_BATCHSELLTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_XFC_BATCHSELL";

               columns = new String[17][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"TRADETYPECODE", "string"};
               columns[2] = new String[]{"STARTCARDNO", "string"};
               columns[3] = new String[]{"ENDCARDNO", "string"};
               columns[4] = new String[]{"CARDVALUE", "Int32"};
               columns[5] = new String[]{"AMOUNT", "Int32"};
               columns[6] = new String[]{"TOTALMONEY", "Int32"};
               columns[7] = new String[]{"CUSTNAME", "String"};
               columns[8] = new String[]{"PAYTYPE", "string"};
               columns[9] = new String[]{"PAYTAG", "string"};
               columns[10] = new String[]{"PAYTIME", "DateTime"};
               columns[11] = new String[]{"STAFFNO", "string"};
               columns[12] = new String[]{"OPERATETIME", "DateTime"};
               columns[13] = new String[]{"REMARK", "String"};
               columns[14] = new String[]{"RSRV1", "string"};
               columns[15] = new String[]{"RSRV2", "string"};
               columns[16] = new String[]{"RSRV3", "Int32"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[17];
               hash.Add("TRADEID", 0);
               hash.Add("TRADETYPECODE", 1);
               hash.Add("STARTCARDNO", 2);
               hash.Add("ENDCARDNO", 3);
               hash.Add("CARDVALUE", 4);
               hash.Add("AMOUNT", 5);
               hash.Add("TOTALMONEY", 6);
               hash.Add("CUSTNAME", 7);
               hash.Add("PAYTYPE", 8);
               hash.Add("PAYTAG", 9);
               hash.Add("PAYTIME", 10);
               hash.Add("STAFFNO", 11);
               hash.Add("OPERATETIME", 12);
               hash.Add("REMARK", 13);
               hash.Add("RSRV1", 14);
               hash.Add("RSRV2", 15);
               hash.Add("RSRV3", 16);
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // ҵ�����ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // ��ʼ����
          public string STARTCARDNO
          {
              get { return  Getstring("STARTCARDNO"); }
              set { Setstring("STARTCARDNO",value); }
          }

          // ��������
          public string ENDCARDNO
          {
              get { return  Getstring("ENDCARDNO"); }
              set { Setstring("ENDCARDNO",value); }
          }

          // ��Ƭ����
          public Int32 CARDVALUE
          {
              get { return  GetInt32("CARDVALUE"); }
              set { SetInt32("CARDVALUE",value); }
          }

          // ��Ƭ����
          public Int32 AMOUNT
          {
              get { return  GetInt32("AMOUNT"); }
              set { SetInt32("AMOUNT",value); }
          }

          // �ܽ��
          public Int32 TOTALMONEY
          {
              get { return  GetInt32("TOTALMONEY"); }
              set { SetInt32("TOTALMONEY",value); }
          }

          // �ͻ�����
          public String CUSTNAME
          {
              get { return  GetString("CUSTNAME"); }
              set { SetString("CUSTNAME",value); }
          }

          // ���ʽ
          public string PAYTYPE
          {
              get { return  Getstring("PAYTYPE"); }
              set { Setstring("PAYTYPE",value); }
          }

          // ���ʱ�־
          public string PAYTAG
          {
              get { return  Getstring("PAYTAG"); }
              set { Setstring("PAYTAG",value); }
          }

          // ����ʱ��
          public DateTime PAYTIME
          {
              get { return  GetDateTime("PAYTIME"); }
              set { SetDateTime("PAYTIME",value); }
          }

          // ����Ա������
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // ����ʱ��
          public DateTime OPERATETIME
          {
              get { return  GetDateTime("OPERATETIME"); }
              set { SetDateTime("OPERATETIME",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

          // ����1
          public string RSRV1
          {
              get { return  Getstring("RSRV1"); }
              set { Setstring("RSRV1",value); }
          }

          // ����2
          public string RSRV2
          {
              get { return  Getstring("RSRV2"); }
              set { Setstring("RSRV2",value); }
          }

          // ����3
          public Int32 RSRV3
          {
              get { return  GetInt32("RSRV3"); }
              set { SetInt32("RSRV3",value); }
          }

     }
}


