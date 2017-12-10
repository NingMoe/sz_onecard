using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // �۳�Ӷ�𷽰�-Ӷ������Ӧ��ϵ��
     public class TD_SSCOMSCHEME_COMRULETDO : DDOBase
     {
          public TD_SSCOMSCHEME_COMRULETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_SSCOMSCHEME_COMRULE";

               columns = new String[6][];
               columns[0] = new String[]{"COMSCHEMENO", "string"};
               columns[1] = new String[]{"COMRULENO", "string"};
               columns[2] = new String[]{"USETAG", "string"};
               columns[3] = new String[]{"UPDATESTAFFNO", "string"};
               columns[4] = new String[]{"UPDATETIME", "DateTime"};
               columns[5] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "COMSCHEMENO",
                   "COMRULENO",
               };


               array = new String[6];
               hash.Add("COMSCHEMENO", 0);
               hash.Add("COMRULENO", 1);
               hash.Add("USETAG", 2);
               hash.Add("UPDATESTAFFNO", 3);
               hash.Add("UPDATETIME", 4);
               hash.Add("REMARK", 5);
          }

          // Ӷ�𷽰�����
          public string COMSCHEMENO
          {
              get { return  Getstring("COMSCHEMENO"); }
              set { Setstring("COMSCHEMENO",value); }
          }

          // Ӷ��������
          public string COMRULENO
          {
              get { return  Getstring("COMRULENO"); }
              set { Setstring("COMRULENO",value); }
          }

          // ��Ч��־
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
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


