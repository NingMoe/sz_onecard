using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ChargeCard
{
     // ��ֵ���������Ͳ�����
     public class TP_XFC_OPERTYPETDO : DDOBase
     {
          public TP_XFC_OPERTYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TP_XFC_OPERTYPE";

               columns = new String[5][];
               columns[0] = new String[]{"OPERTYPECODE", "string"};
               columns[1] = new String[]{"OPERTYPE", "String"};
               columns[2] = new String[]{"UPDATETIME", "DateTime"};
               columns[3] = new String[]{"UPDATESTAFFNO", "string"};
               columns[4] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "OPERTYPECODE",
               };


               array = new String[5];
               hash.Add("OPERTYPECODE", 0);
               hash.Add("OPERTYPE", 1);
               hash.Add("UPDATETIME", 2);
               hash.Add("UPDATESTAFFNO", 3);
               hash.Add("REMARK", 4);
          }

          // �������ͱ���
          public string OPERTYPECODE
          {
              get { return  Getstring("OPERTYPECODE"); }
              set { Setstring("OPERTYPECODE",value); }
          }

          // ��������
          public String OPERTYPE
          {
              get { return  GetString("OPERTYPE"); }
              set { SetString("OPERTYPE",value); }
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


