using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ChargeCard
{
     // ��ֵ����������
     public class TP_XFC_CARDVALUETDO : DDOBase
     {
          public TP_XFC_CARDVALUETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TP_XFC_CARDVALUE";

               columns = new String[6][];
               columns[0] = new String[]{"VALUECODE", "string"};
               columns[1] = new String[]{"VALUE", "String"};
               columns[2] = new String[]{"MONEY", "Int32"};
               columns[3] = new String[]{"UPDATETIME", "DateTime"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "VALUECODE",
               };


               array = new String[6];
               hash.Add("VALUECODE", 0);
               hash.Add("VALUE", 1);
               hash.Add("MONEY", 2);
               hash.Add("UPDATETIME", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("REMARK", 5);
          }

          // ������
          public string VALUECODE
          {
              get { return  Getstring("VALUECODE"); }
              set { Setstring("VALUECODE",value); }
          }

          // ˵��
          public String VALUE
          {
              get { return  GetString("VALUE"); }
              set { SetString("VALUE",value); }
          }

          // ���
          public Int32 MONEY
          {
              get { return  GetInt32("MONEY"); }
              set { SetInt32("MONEY",value); }
          }

          // ����ʱ��
          public DateTime UPDATETIME
          {
              get { return  GetDateTime("UPDATETIME"); }
              set { SetDateTime("UPDATETIME",value); }
          }

          // ����Ա��
          public string UPDATESTAFFNO
          {
              get { return  Getstring("UPDATESTAFFNO"); }
              set { Setstring("UPDATESTAFFNO",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


