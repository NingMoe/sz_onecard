using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ChargeCard
{
     // ��ֵ���������̲�����
     public class TP_XFC_CORPTDO : DDOBase
     {
          public TP_XFC_CORPTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TP_XFC_CORP";

               columns = new String[5][];
               columns[0] = new String[]{"CORPCODE", "string"};
               columns[1] = new String[]{"CORPNAME", "String"};
               columns[2] = new String[]{"UPDATETIME", "DateTime"};
               columns[3] = new String[]{"UPDATESTAFFNO", "string"};
               columns[4] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CORPCODE",
               };


               array = new String[5];
               hash.Add("CORPCODE", 0);
               hash.Add("CORPNAME", 1);
               hash.Add("UPDATETIME", 2);
               hash.Add("UPDATESTAFFNO", 3);
               hash.Add("REMARK", 4);
          }

          // ���̱���
          public string CORPCODE
          {
              get { return  Getstring("CORPCODE"); }
              set { Setstring("CORPCODE",value); }
          }

          // ����
          public String CORPNAME
          {
              get { return  GetString("CORPNAME"); }
              set { SetString("CORPNAME",value); }
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


