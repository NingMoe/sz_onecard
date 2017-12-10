using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PartnerShip
{
     // ������㵥ԪԤ�����˻���
     public class TF_F_DEPTBAL_PREPAYTDO : DDOBase
     {
          public TF_F_DEPTBAL_PREPAYTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_F_DEPTBAL_PREPAY";

               columns = new String[6][];
               columns[0] = new String[]{"DBALUNITNO", "string"};
               columns[1] = new String[]{"PREPAY", "Int32"};
               columns[2] = new String[]{"ACCSTATECODE", "string"};
               columns[3] = new String[]{"UPDATESTAFFNO", "string"};
               columns[4] = new String[]{"UPDATETIME", "DateTime"};
               columns[5] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "DBALUNITNO",
               };


               array = new String[6];
               hash.Add("DBALUNITNO", 0);
               hash.Add("PREPAY", 1);
               hash.Add("ACCSTATECODE", 2);
               hash.Add("UPDATESTAFFNO", 3);
               hash.Add("UPDATETIME", 4);
               hash.Add("REMARK", 5);
          }

          // ���㵥Ԫ����
          public string DBALUNITNO
          {
              get { return  Getstring("DBALUNITNO"); }
              set { Setstring("DBALUNITNO",value); }
          }

          // Ԥ�������
          public Int32 PREPAY
          {
              get { return  GetInt32("PREPAY"); }
              set { SetInt32("PREPAY",value); }
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


