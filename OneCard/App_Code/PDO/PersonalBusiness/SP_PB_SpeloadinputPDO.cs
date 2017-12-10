using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // ����Ȧ��¼��
     public class SP_PB_SpeloadinputPDO : PDOBase
     {
          public SP_PB_SpeloadinputPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_Speloadinput",12);

               AddField("@CARDNO", "string", "16", "input");
               AddField("@TRADEMONEY", "Int32", "", "input");
               AddField("@TRADETYPECODE", "string", "2", "input");
               AddField("@TRADEDATE", "DateTime", "", "input");
               AddField("@TRADETIMES", "Int32", "", "input");
               AddField("@REMARK", "String", "100", "input");
               AddField("@TRADEID", "string", "16", "output");

               InitEnd();
          }

          // ����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ���׽��
          public Int32 TRADEMONEY
          {
              get { return  GetInt32("TRADEMONEY"); }
              set { SetInt32("TRADEMONEY",value); }
          }

          // �������ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // ��������
          public DateTime TRADEDATE
          {
              get { return  GetDateTime("TRADEDATE"); }
              set { SetDateTime("TRADEDATE",value); }
          }

          // ���ױ���
          public Int32 TRADETIMES
          {
              get { return  GetInt32("TRADETIMES"); }
              set { SetInt32("TRADETIMES",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

          // ���ؽ������к�
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

     }
}


