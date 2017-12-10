using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ChargeCard
{
     // ��ֵ����״̬������
     public class TP_XFC_CARDSTATETDO : DDOBase
     {
          public TP_XFC_CARDSTATETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TP_XFC_CARDSTATE";

               columns = new String[5][];
               columns[0] = new String[]{"CARDSTATECODE", "string"};
               columns[1] = new String[]{"CARDSTATE", "String"};
               columns[2] = new String[]{"UPDATETIME", "DateTime"};
               columns[3] = new String[]{"UPDATESTAFFNO", "string"};
               columns[4] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDSTATECODE",
               };


               array = new String[5];
               hash.Add("CARDSTATECODE", 0);
               hash.Add("CARDSTATE", 1);
               hash.Add("UPDATETIME", 2);
               hash.Add("UPDATESTAFFNO", 3);
               hash.Add("REMARK", 4);
          }

          // ��״̬��
          public string CARDSTATECODE
          {
              get { return  Getstring("CARDSTATECODE"); }
              set { Setstring("CARDSTATECODE",value); }
          }

          // ״̬
          public String CARDSTATE
          {
              get { return  GetString("CARDSTATE"); }
              set { SetString("CARDSTATE",value); }
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


