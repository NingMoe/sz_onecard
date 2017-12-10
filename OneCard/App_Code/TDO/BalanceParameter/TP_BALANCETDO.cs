using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceParameter
{
     // ���㹤����
     public class TP_BALANCETDO : DDOBase
     {
          public TP_BALANCETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TP_BALANCE";

               columns = new String[9][];
               columns[0] = new String[]{"ID", "Decimal"};
               columns[1] = new String[]{"CHNLTYPE", "string"};
               columns[2] = new String[]{"BALUNITNO", "string"};
               columns[3] = new String[]{"BALTIMES", "Int32"};
               columns[4] = new String[]{"BEGINTIME", "DateTime"};
               columns[5] = new String[]{"ENDTIME", "DateTime"};
               columns[6] = new String[]{"DEALSTATECODE", "string"};
               columns[7] = new String[]{"FILEBILLTABLE", "String"};
               columns[8] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[9];
               hash.Add("ID", 0);
               hash.Add("CHNLTYPE", 1);
               hash.Add("BALUNITNO", 2);
               hash.Add("BALTIMES", 3);
               hash.Add("BEGINTIME", 4);
               hash.Add("ENDTIME", 5);
               hash.Add("DEALSTATECODE", 6);
               hash.Add("FILEBILLTABLE", 7);
               hash.Add("REMARK", 8);
          }

          // ���
          public Decimal ID
          {
              get { return  GetDecimal("ID"); }
              set { SetDecimal("ID",value); }
          }

          // ͨ������
          public string CHNLTYPE
          {
              get { return  Getstring("CHNLTYPE"); }
              set { Setstring("CHNLTYPE",value); }
          }

          // ���㵥Ԫ����
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // �ʵ����ɱ���
          public Int32 BALTIMES
          {
              get { return  GetInt32("BALTIMES"); }
              set { SetInt32("BALTIMES",value); }
          }

          // ���ڿ�ʼʱ��
          public DateTime BEGINTIME
          {
              get { return  GetDateTime("BEGINTIME"); }
              set { SetDateTime("BEGINTIME",value); }
          }

          // ���ڽ���ʱ��
          public DateTime ENDTIME
          {
              get { return  GetDateTime("ENDTIME"); }
              set { SetDateTime("ENDTIME",value); }
          }

          // ����״̬����
          public string DEALSTATECODE
          {
              get { return  Getstring("DEALSTATECODE"); }
              set { Setstring("DEALSTATECODE",value); }
          }

          // �ļ����˵�����
          public String FILEBILLTABLE
          {
              get { return  GetString("FILEBILLTABLE"); }
              set { SetString("FILEBILLTABLE",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


