using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // IC�����ͱ����
     public class TD_M_CARDTYPETDO : DDOBase
     {
          public TD_M_CARDTYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_CARDTYPE";

               columns = new String[8][];
               columns[0] = new String[]{"CARDTYPECODE", "string"};
               columns[1] = new String[]{"CARDTYPENAME", "String"};
               columns[2] = new String[]{"CARDTYPENOTE", "String"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"CARDRETURN", "string"};
               columns[5] = new String[]{"UPDATESTAFFNO", "string"};
               columns[6] = new String[]{"UPDATETIME", "DateTime"};
               columns[7] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDTYPECODE",
               };


               array = new String[8];
               hash.Add("CARDTYPECODE", 0);
               hash.Add("CARDTYPENAME", 1);
               hash.Add("CARDTYPENOTE", 2);
               hash.Add("USETAG", 3);
               hash.Add("CARDRETURN", 4);
               hash.Add("UPDATESTAFFNO", 5);
               hash.Add("UPDATETIME", 6);
               hash.Add("REMARK", 7);
          }

          // �����ͱ���
          public string CARDTYPECODE
          {
              get { return  Getstring("CARDTYPECODE"); }
              set { Setstring("CARDTYPECODE",value); }
          }

          // ����������
          public String CARDTYPENAME
          {
              get { return  GetString("CARDTYPENAME"); }
              set { SetString("CARDTYPENAME",value); }
          }

          // ������˵��
          public String CARDTYPENOTE
          {
              get { return  GetString("CARDTYPENOTE"); }
              set { SetString("CARDTYPENOTE",value); }
          }

          // ��Ч��־
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // �Ƿ������˿�
          public string CARDRETURN
          {
              get { return  Getstring("CARDRETURN"); }
              set { Setstring("CARDRETURN",value); }
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


