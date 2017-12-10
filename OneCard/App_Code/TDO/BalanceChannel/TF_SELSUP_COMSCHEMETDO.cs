using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // �۳�Ӷ�𷽰������
     public class TF_SELSUP_COMSCHEMETDO : DDOBase
     {
          public TF_SELSUP_COMSCHEMETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_SELSUP_COMSCHEME";

               columns = new String[9][];
               columns[0] = new String[]{"COMSCHEMENO", "string"};
               columns[1] = new String[]{"NAME", "String"};
               columns[2] = new String[]{"TYPECODE", "string"};
               columns[3] = new String[]{"DATACODE", "string"};
               columns[4] = new String[]{"STATCOLUMN", "string"};
               columns[5] = new String[]{"USETAG", "string"};
               columns[6] = new String[]{"UPDATESTAFFNO", "string"};
               columns[7] = new String[]{"UPDATETIME", "DateTime"};
               columns[8] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "COMSCHEMENO",
               };


               array = new String[9];
               hash.Add("COMSCHEMENO", 0);
               hash.Add("NAME", 1);
               hash.Add("TYPECODE", 2);
               hash.Add("DATACODE", 3);
               hash.Add("STATCOLUMN", 4);
               hash.Add("USETAG", 5);
               hash.Add("UPDATESTAFFNO", 6);
               hash.Add("UPDATETIME", 7);
               hash.Add("REMARK", 8);
          }

          // ��������
          public string COMSCHEMENO
          {
              get { return  Getstring("COMSCHEMENO"); }
              set { Setstring("COMSCHEMENO",value); }
          }

          // ������
          public String NAME
          {
              get { return  GetString("NAME"); }
              set { SetString("NAME",value); }
          }

          // �������ͱ���
          public string TYPECODE
          {
              get { return  Getstring("TYPECODE"); }
              set { Setstring("TYPECODE",value); }
          }

          // �������ͱ���
          public string DATACODE
          {
              get { return  Getstring("DATACODE"); }
              set { Setstring("DATACODE",value); }
          }

          // ͳ���ֶ�
          public string STATCOLUMN
          {
              get { return  Getstring("STATCOLUMN"); }
              set { Setstring("STATCOLUMN",value); }
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


