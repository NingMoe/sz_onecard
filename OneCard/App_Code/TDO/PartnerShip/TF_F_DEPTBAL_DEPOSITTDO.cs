using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PartnerShip
{
     // ������㵥Ԫ��֤���˻���
     public class TF_F_DEPTBAL_DEPOSITTDO : DDOBase
     {
          public TF_F_DEPTBAL_DEPOSITTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_F_DEPTBAL_DEPOSIT";

               columns = new String[8][];
               columns[0] = new String[]{"DBALUNITNO", "string"};
               columns[1] = new String[]{"DEPOSIT", "Int32"};
               columns[2] = new String[]{"USABLEVALUE", "Int32"};
               columns[3] = new String[]{"STOCKVALUE", "Int32"};
               columns[4] = new String[]{"ACCSTATECODE", "string"};
               columns[5] = new String[]{"UPDATESTAFFNO", "string"};
               columns[6] = new String[]{"UPDATETIME", "DateTime"};
               columns[7] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "DBALUNITNO",
               };


               array = new String[8];
               hash.Add("DBALUNITNO", 0);
               hash.Add("DEPOSIT", 1);
               hash.Add("USABLEVALUE", 2);
               hash.Add("STOCKVALUE", 3);
               hash.Add("ACCSTATECODE", 4);
               hash.Add("UPDATESTAFFNO", 5);
               hash.Add("UPDATETIME", 6);
               hash.Add("REMARK", 7);
          }

          // ���㵥Ԫ����
          public string DBALUNITNO
          {
              get { return  Getstring("DBALUNITNO"); }
              set { Setstring("DBALUNITNO",value); }
          }

          // ��֤�����
          public Int32 DEPOSIT
          {
              get { return  GetInt32("DEPOSIT"); }
              set { SetInt32("DEPOSIT",value); }
          }

          // ���쿨��ֵ���
          public Int32 USABLEVALUE
          {
              get { return  GetInt32("USABLEVALUE"); }
              set { SetInt32("USABLEVALUE",value); }
          }

          // ����ʣ�࿨��ֵ
          public Int32 STOCKVALUE
          {
              get { return  GetInt32("STOCKVALUE"); }
              set { SetInt32("STOCKVALUE",value); }
          }

          // �ʻ�״̬
          public string ACCSTATECODE
          {
              get { return  Getstring("ACCSTATECODE"); }
              set { Setstring("ACCSTATECODE",value); }
          }

          // ����Ա��
          public string UPDATESTAFFNO
          {
              get { return  Getstring("UPDATESTAFFNO"); }
              set { Setstring("UPDATESTAFFNO",value); }
          }

          // ����ʱ��
          public DateTime UPDATETIME
          {
              get { return  GetDateTime("UPDATETIME"); }
              set { SetDateTime("UPDATETIME",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


