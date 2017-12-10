using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.TaxiService
{
     // ˾����Ϣ���
     public class SP_Bus_ChangeInfoPDO : PDOBase
     {
          public SP_Bus_ChangeInfoPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_Bus_ChangeInfo",19);

               AddField("@CALLINGSTAFFNO", "string", "6", "input");
               AddField("@CARDNO", "String", "16", "input");
               AddField("@CARNO", "string", "8", "input");
               AddField("@STAFFNAME", "String", "20", "input");
               AddField("@STAFFSEX", "string", "1", "input");
               AddField("@STAFFPHONE", "String", "20", "input");
               AddField("@STAFFMOBILE", "String", "15", "input");
               AddField("@STAFFPAPERTYPECODE", "string", "2", "input");
               AddField("@STAFFPAPERNO", "String", "20", "input");
               AddField("@STAFFPOST", "String", "6", "input");
               AddField("@STAFFADDR", "String", "50", "input");
               AddField("@STAFFEMAIL", "String", "30", "input");
               AddField("@POSID", "string", "8", "input");
               AddField("@DIMISSIONTAG", "string", "1", "input");

               InitEnd();
          }

          // ��ҵԱ������
          public string CALLINGSTAFFNO
          {
              get { return  Getstring("CALLINGSTAFFNO"); }
              set { Setstring("CALLINGSTAFFNO",value); }
          }

          // Ա������
          public String CARDNO
          {
              get { return  GetString("CARDNO"); }
              set { SetString("CARDNO",value); }
          }

          // ����
          public string CARNO
          {
              get { return  Getstring("CARNO"); }
              set { Setstring("CARNO",value); }
          }

          // Ա������
          public String STAFFNAME
          {
              get { return  GetString("STAFFNAME"); }
              set { SetString("STAFFNAME",value); }
          }

          // Ա���Ա�
          public string STAFFSEX
          {
              get { return  Getstring("STAFFSEX"); }
              set { Setstring("STAFFSEX",value); }
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

          // �ʱ��ַ
          public String STAFFPOST
          {
              get { return  GetString("STAFFPOST"); }
              set { SetString("STAFFPOST",value); }
          }

          // Ա����ϵ��ַ
          public String STAFFADDR
          {
              get { return  GetString("STAFFADDR"); }
              set { SetString("STAFFADDR",value); }
          }

          // EMAIL��ַ
          public String STAFFEMAIL
          {
              get { return  GetString("STAFFEMAIL"); }
              set { SetString("STAFFEMAIL",value); }
          }

          // POSID
          public string POSID
          {
              get { return  Getstring("POSID"); }
              set { Setstring("POSID",value); }
          }

          // ��ְ��־
          public string DIMISSIONTAG
          {
              get { return  Getstring("DIMISSIONTAG"); }
              set { Setstring("DIMISSIONTAG",value); }
          }

     }
}


