using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // ��ҵԱ�������
     public class TD_M_CALLINGSTAFFTDO : DDOBase
     {
          public TD_M_CALLINGSTAFFTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_CALLINGSTAFF";

               columns = new String[23][];
               columns[0] = new String[]{"STAFFNO", "string"};
               columns[1] = new String[]{"CALLINGNO", "string"};
               columns[2] = new String[]{"STAFFNAME", "String"};
               columns[3] = new String[]{"STAFFPAPERTYPECODE", "string"};
               columns[4] = new String[]{"STAFFPAPERNO", "String"};
               columns[5] = new String[]{"STAFFADDR", "String"};
               columns[6] = new String[]{"STAFFPHONE", "String"};
               columns[7] = new String[]{"STAFFMOBILE", "String"};
               columns[8] = new String[]{"STAFFPOST", "String"};
               columns[9] = new String[]{"STAFFEMAIL", "String"};
               columns[10] = new String[]{"STAFFSEX", "string"};
               columns[11] = new String[]{"OPERCARDNO", "String"};
               columns[12] = new String[]{"OPERCARDPWD", "String"};
               columns[13] = new String[]{"COLLECTCARDNO", "String"};
               columns[14] = new String[]{"COLLECTCARDPWD", "String"};
               columns[15] = new String[]{"POSID", "string"};
               columns[16] = new String[]{"CARNO", "string"};
               columns[17] = new String[]{"DIMISSIONTAG", "string"};
               columns[18] = new String[]{"SERVTAG1", "string"};
               columns[19] = new String[]{"SERVTAG2", "string"};
               columns[20] = new String[]{"UPDATESTAFFNO", "string"};
               columns[21] = new String[]{"UPDATETIME", "DateTime"};
               columns[22] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "STAFFNO",
                   "CALLINGNO",
               };


               array = new String[23];
               hash.Add("STAFFNO", 0);
               hash.Add("CALLINGNO", 1);
               hash.Add("STAFFNAME", 2);
               hash.Add("STAFFPAPERTYPECODE", 3);
               hash.Add("STAFFPAPERNO", 4);
               hash.Add("STAFFADDR", 5);
               hash.Add("STAFFPHONE", 6);
               hash.Add("STAFFMOBILE", 7);
               hash.Add("STAFFPOST", 8);
               hash.Add("STAFFEMAIL", 9);
               hash.Add("STAFFSEX", 10);
               hash.Add("OPERCARDNO", 11);
               hash.Add("OPERCARDPWD", 12);
               hash.Add("COLLECTCARDNO", 13);
               hash.Add("COLLECTCARDPWD", 14);
               hash.Add("POSID", 15);
               hash.Add("CARNO", 16);
               hash.Add("DIMISSIONTAG", 17);
               hash.Add("SERVTAG1", 18);
               hash.Add("SERVTAG2", 19);
               hash.Add("UPDATESTAFFNO", 20);
               hash.Add("UPDATETIME", 21);
               hash.Add("REMARK", 22);
          }

          // Ա������
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // ��ҵ����
          public string CALLINGNO
          {
              get { return  Getstring("CALLINGNO"); }
              set { Setstring("CALLINGNO",value); }
          }

          // Ա������
          public String STAFFNAME
          {
              get { return  GetString("STAFFNAME"); }
              set { SetString("STAFFNAME",value); }
          }

          // Ա��֤������
          public string STAFFPAPERTYPECODE
          {
              get { return  Getstring("STAFFPAPERTYPECODE"); }
              set { Setstring("STAFFPAPERTYPECODE",value); }
          }

          // Ա��֤������
          public String STAFFPAPERNO
          {
              get { return  GetString("STAFFPAPERNO"); }
              set { SetString("STAFFPAPERNO",value); }
          }

          // Ա����ϵ��ַ
          public String STAFFADDR
          {
              get { return  GetString("STAFFADDR"); }
              set { SetString("STAFFADDR",value); }
          }

          // Ա����ϵ�绰
          public String STAFFPHONE
          {
              get { return  GetString("STAFFPHONE"); }
              set { SetString("STAFFPHONE",value); }
          }

          // Ա���ƶ��绰
          public String STAFFMOBILE
          {
              get { return  GetString("STAFFMOBILE"); }
              set { SetString("STAFFMOBILE",value); }
          }

          // �ʱ��ַ
          public String STAFFPOST
          {
              get { return  GetString("STAFFPOST"); }
              set { SetString("STAFFPOST",value); }
          }

          // EMAIL��ַ
          public String STAFFEMAIL
          {
              get { return  GetString("STAFFEMAIL"); }
              set { SetString("STAFFEMAIL",value); }
          }

          // Ա���Ա�
          public string STAFFSEX
          {
              get { return  Getstring("STAFFSEX"); }
              set { Setstring("STAFFSEX",value); }
          }

          // Ա������
          public String OPERCARDNO
          {
              get { return  GetString("OPERCARDNO"); }
              set { SetString("OPERCARDNO",value); }
          }

          // Ա��������
          public String OPERCARDPWD
          {
              get { return  GetString("OPERCARDPWD"); }
              set { SetString("OPERCARDPWD",value); }
          }

          // �ɼ�����
          public String COLLECTCARDNO
          {
              get { return  GetString("COLLECTCARDNO"); }
              set { SetString("COLLECTCARDNO",value); }
          }

          // �ɼ�������
          public String COLLECTCARDPWD
          {
              get { return  GetString("COLLECTCARDPWD"); }
              set { SetString("COLLECTCARDPWD",value); }
          }

          // POS���
          public string POSID
          {
              get { return  Getstring("POSID"); }
              set { Setstring("POSID",value); }
          }

          // ����
          public string CARNO
          {
              get { return  Getstring("CARNO"); }
              set { Setstring("CARNO",value); }
          }

          // ��ְ��־
          public string DIMISSIONTAG
          {
              get { return  Getstring("DIMISSIONTAG"); }
              set { Setstring("DIMISSIONTAG",value); }
          }

          // �����־1
          public string SERVTAG1
          {
              get { return  Getstring("SERVTAG1"); }
              set { Setstring("SERVTAG1",value); }
          }

          // �����־2
          public string SERVTAG2
          {
              get { return  Getstring("SERVTAG2"); }
              set { Setstring("SERVTAG2",value); }
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


