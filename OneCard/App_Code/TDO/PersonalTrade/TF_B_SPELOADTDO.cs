using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // ����Ȧ��̨�ʱ�
     public class TF_B_SPELOADTDO : DDOBase
     {
          public TF_B_SPELOADTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_SPELOAD";

               columns = new String[16][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"TRADETYPECODE", "string"};
               columns[2] = new String[]{"CARDNO", "string"};
               columns[3] = new String[]{"TRADEMONEY", "Int32"};
               columns[4] = new String[]{"TRADEDATE", "DateTime"};
               columns[5] = new String[]{"TRADETIMES", "Int32"};
               columns[6] = new String[]{"REMARK", "String"};
               columns[7] = new String[]{"STATECODE", "string"};
               columns[8] = new String[]{"INPUTSTAFFNO", "string"};
               columns[9] = new String[]{"INPUTTIME", "DateTime"};
               columns[10] = new String[]{"OPERATESTAFFNO", "string"};
               columns[11] = new String[]{"OPERATETIME", "DateTime"};
               columns[12] = new String[]{"RSRV1", "String"};
               columns[13] = new String[]{"RSRV2", "String"};
               columns[14] = new String[]{"RSRV3", "DateTime"};
               columns[15] = new String[]{"RSRV4", "Int32"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[16];
               hash.Add("TRADEID", 0);
               hash.Add("TRADETYPECODE", 1);
               hash.Add("CARDNO", 2);
               hash.Add("TRADEMONEY", 3);
               hash.Add("TRADEDATE", 4);
               hash.Add("TRADETIMES", 5);
               hash.Add("REMARK", 6);
               hash.Add("STATECODE", 7);
               hash.Add("INPUTSTAFFNO", 8);
               hash.Add("INPUTTIME", 9);
               hash.Add("OPERATESTAFFNO", 10);
               hash.Add("OPERATETIME", 11);
               hash.Add("RSRV1", 12);
               hash.Add("RSRV2", 13);
               hash.Add("RSRV3", 14);
               hash.Add("RSRV4", 15);
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

          // ����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ���׽��
          public Int32 TRADEMONEY
          {
              get { return  GetInt32("TRADEMONEY"); }
              set { SetInt32("TRADEMONEY",value); }
          }

          // ��������
          public DateTime TRADEDATE
          {
              get { return  GetDateTime("TRADEDATE"); }
              set { SetDateTime("TRADEDATE",value); }
          }

          // ���ױ���
          public Int32 TRADETIMES
          {
              get { return  GetInt32("TRADETIMES"); }
              set { SetInt32("TRADETIMES",value); }
          }

          // ��ע˵��
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

          // ״̬����
          public string STATECODE
          {
              get { return  Getstring("STATECODE"); }
              set { Setstring("STATECODE",value); }
          }

          // ¼��Ա������
          public string INPUTSTAFFNO
          {
              get { return  Getstring("INPUTSTAFFNO"); }
              set { Setstring("INPUTSTAFFNO",value); }
          }

          // ¼��ʱ��
          public DateTime INPUTTIME
          {
              get { return  GetDateTime("INPUTTIME"); }
              set { SetDateTime("INPUTTIME",value); }
          }

          // ����Ա������
          public string OPERATESTAFFNO
          {
              get { return  Getstring("OPERATESTAFFNO"); }
              set { Setstring("OPERATESTAFFNO",value); }
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

          // ����3
          public DateTime RSRV3
          {
              get { return  GetDateTime("RSRV3"); }
              set { SetDateTime("RSRV3",value); }
          }

          // ����4
          public Int32 RSRV4
          {
              get { return  GetInt32("RSRV4"); }
              set { SetInt32("RSRV4",value); }
          }

     }
}


