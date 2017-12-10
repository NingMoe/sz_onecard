using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CountBalance
{
     // �����꿨��������
     public class TF_F_BLACKACC_XXPARKTDO : DDOBase
     {
          public TF_F_BLACKACC_XXPARKTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_F_BLACKACC_XXPARK";

               columns = new String[9][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"INTIME", "DateTime"};
               columns[2] = new String[]{"INSTAFFNO", "string"};
               columns[3] = new String[]{"CAPDATE", "string"};
               columns[4] = new String[]{"REASON", "String"};
               columns[5] = new String[]{"LEVELFLAG", "string"};
               columns[6] = new String[]{"RSRVINT", "Int32"};
               columns[7] = new String[]{"RSRVCHAR", "string"};
               columns[8] = new String[]{"RSRVSTRING", "string"};

               columnKeys = new String[]{
                   "CARDNO",
               };


               array = new String[9];
               hash.Add("CARDNO", 0);
               hash.Add("INTIME", 1);
               hash.Add("INSTAFFNO", 2);
               hash.Add("CAPDATE", 3);
               hash.Add("REASON", 4);
               hash.Add("LEVELFLAG", 5);
               hash.Add("RSRVINT", 6);
               hash.Add("RSRVCHAR", 7);
               hash.Add("RSRVSTRING", 8);
          }

          // ����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ���ʱ��
          public DateTime INTIME
          {
              get { return  GetDateTime("INTIME"); }
              set { SetDateTime("INTIME",value); }
          }

          // ���Ա��
          public string INSTAFFNO
          {
              get { return  Getstring("INSTAFFNO"); }
              set { Setstring("INSTAFFNO",value); }
          }

          // ��������
          public string CAPDATE
          {
              get { return  Getstring("CAPDATE"); }
              set { Setstring("CAPDATE",value); }
          }

          // ����ԭ��
          public String REASON
          {
              get { return  GetString("REASON"); }
              set { SetString("REASON",value); }
          }

          // �ȼ���־
          public string LEVELFLAG
          {
              get { return  Getstring("LEVELFLAG"); }
              set { Setstring("LEVELFLAG",value); }
          }

          // ����1
          public Int32 RSRVINT
          {
              get { return  GetInt32("RSRVINT"); }
              set { SetInt32("RSRVINT",value); }
          }

          // ����2
          public string RSRVCHAR
          {
              get { return  Getstring("RSRVCHAR"); }
              set { Setstring("RSRVCHAR",value); }
          }

          // ����3
          public string RSRVSTRING
          {
              get { return  Getstring("RSRVSTRING"); }
              set { Setstring("RSRVSTRING",value); }
          }

     }
}


