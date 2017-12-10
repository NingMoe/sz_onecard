using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ChargeCard
{
     // ��ֵ�������������
     public class TP_XFC_MERCHANTTDO : DDOBase
     {
          public TP_XFC_MERCHANTTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TP_XFC_MERCHANT";

               columns = new String[5][];
               columns[0] = new String[]{"MERCHANTCODE", "string"};
               columns[1] = new String[]{"MERCHANT", "String"};
               columns[2] = new String[]{"UPDATETIME", "DateTime"};
               columns[3] = new String[]{"UPDATESTAFFNO", "string"};
               columns[4] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "MERCHANTCODE",
               };


               array = new String[5];
               hash.Add("MERCHANTCODE", 0);
               hash.Add("MERCHANT", 1);
               hash.Add("UPDATETIME", 2);
               hash.Add("UPDATESTAFFNO", 3);
               hash.Add("REMARK", 4);
          }

          // ���������
          public string MERCHANTCODE
          {
              get { return  Getstring("MERCHANTCODE"); }
              set { Setstring("MERCHANTCODE",value); }
          }

          // ������
          public String MERCHANT
          {
              get { return  GetString("MERCHANT"); }
              set { SetString("MERCHANT",value); }
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


