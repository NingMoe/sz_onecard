using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // ���ڽ��׼�¼̨������
     public class TF_CARD_RECQUYTDO : DDOBase
     {
          public TF_CARD_RECQUYTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_CARD_RECQUY";

               columns = new String[9][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"CARDNO", "string"};
               columns[2] = new String[]{"AMOUNT", "Int32"};
               columns[3] = new String[]{"OPERATESTAFFNO", "string"};
               columns[4] = new String[]{"CARDMONEY", "Int32"};
               columns[5] = new String[]{"OPERATEDEPARTID", "string"};
               columns[6] = new String[]{"OPERATETIME", "DateTime"};
               columns[7] = new String[]{"RSRV1", "String"};
               columns[8] = new String[]{"RSRV2", "DateTime"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[9];
               hash.Add("TRADEID", 0);
               hash.Add("CARDNO", 1);
               hash.Add("AMOUNT", 2);
               hash.Add("OPERATESTAFFNO", 3);
               hash.Add("CARDMONEY", 4);
               hash.Add("OPERATEDEPARTID", 5);
               hash.Add("OPERATETIME", 6);
               hash.Add("RSRV1", 7);
               hash.Add("RSRV2", 8);
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // ����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // �ܼ�¼��
          public Int32 AMOUNT
          {
              get { return  GetInt32("AMOUNT"); }
              set { SetInt32("AMOUNT",value); }
          }

          // ����Ա������
          public string OPERATESTAFFNO
          {
              get { return  Getstring("OPERATESTAFFNO"); }
              set { Setstring("OPERATESTAFFNO",value); }
          }

          // �������
          public Int32 CARDMONEY
          {
              get { return  GetInt32("CARDMONEY"); }
              set { SetInt32("CARDMONEY",value); }
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
          public DateTime RSRV2
          {
              get { return  GetDateTime("RSRV2"); }
              set { SetDateTime("RSRV2",value); }
          }

     }
}


