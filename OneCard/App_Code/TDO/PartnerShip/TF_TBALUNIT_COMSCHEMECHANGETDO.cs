using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PartnerShip
{
     // ���ѽ��㵥Ԫ-Ӷ�𷽰���Ӧ��ϵ�ӱ�
     public class TF_TBALUNIT_COMSCHEMECHANGETDO : DDOBase
     {
          public TF_TBALUNIT_COMSCHEMECHANGETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_TBALUNIT_COMSCHEMECHANGE";

               columns = new String[7][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"ID", "string"};
               columns[2] = new String[]{"COMSCHEMENO", "string"};
               columns[3] = new String[]{"BALUNITNO", "string"};
               columns[4] = new String[]{"BEGINTIME", "DateTime"};
               columns[5] = new String[]{"ENDTIME", "DateTime"};
               columns[6] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[7];
               hash.Add("TRADEID", 0);
               hash.Add("ID", 1);
               hash.Add("COMSCHEMENO", 2);
               hash.Add("BALUNITNO", 3);
               hash.Add("BEGINTIME", 4);
               hash.Add("ENDTIME", 5);
               hash.Add("REMARK", 6);
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // ��ϵ����
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // Ӷ�𷽰�����
          public string COMSCHEMENO
          {
              get { return  Getstring("COMSCHEMENO"); }
              set { Setstring("COMSCHEMENO",value); }
          }

          // ���㵥Ԫ����
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // ��ʼʱ��
          public DateTime BEGINTIME
          {
              get { return  GetDateTime("BEGINTIME"); }
              set { SetDateTime("BEGINTIME",value); }
          }

          // ��ֹʱ��
          public DateTime ENDTIME
          {
              get { return  GetDateTime("ENDTIME"); }
              set { SetDateTime("ENDTIME",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


