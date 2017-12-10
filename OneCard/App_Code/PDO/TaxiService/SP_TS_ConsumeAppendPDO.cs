using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.TaxiService
{
     // ���⳵���Ѳ�¼
     public class SP_TS_ConsumeAppendPDO : PDOBase
     {
          public SP_TS_ConsumeAppendPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_TS_ConsumeAppend",21);

               AddField("@IDENTIFYNO", "string", "26", "input");
               AddField("@ASN", "string", "16", "input");
               AddField("@CARDTRADENO", "string", "5", "input");
               AddField("@SAMNO", "string", "12", "input");
               AddField("@POSTRADENO", "string", "8", "input");
               AddField("@TRADEDATE", "string", "8", "input");
               AddField("@TRADETIME", "string", "6", "input");
               AddField("@PREMONEY", "Int32", "", "input");
               AddField("@TRADEMONEY", "Int32", "", "input");
               AddField("@BALUNITNO", "string", "8", "input");
               AddField("@CALLINGNO", "string", "2", "input");
               AddField("@CORPNO", "string", "4", "input");
               AddField("@DEPARTNO", "string", "4", "input");
               AddField("@CALLINGSTAFFNO", "string", "6", "input");
               AddField("@TAC", "string", "8", "input");
               AddField("@DEALSTATECODE", "string", "1", "input");

               InitEnd();
          }

          // ��¼��ˮ��
          public string IDENTIFYNO
          {
              get { return  Getstring("IDENTIFYNO"); }
              set { Setstring("IDENTIFYNO",value); }
          }

          // Ӧ�����к�
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // ���������к�
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // PSAM���
          public string SAMNO
          {
              get { return  Getstring("SAMNO"); }
              set { Setstring("SAMNO",value); }
          }

          // POS���׺�
          public string POSTRADENO
          {
              get { return  Getstring("POSTRADENO"); }
              set { Setstring("POSTRADENO",value); }
          }

          // ��������
          public string TRADEDATE
          {
              get { return  Getstring("TRADEDATE"); }
              set { Setstring("TRADEDATE",value); }
          }

          // ����ʱ��
          public string TRADETIME
          {
              get { return  Getstring("TRADETIME"); }
              set { Setstring("TRADETIME",value); }
          }

          // ����ǰ�������
          public Int32 PREMONEY
          {
              get { return  GetInt32("PREMONEY"); }
              set { SetInt32("PREMONEY",value); }
          }

          // ���׽��
          public Int32 TRADEMONEY
          {
              get { return  GetInt32("TRADEMONEY"); }
              set { SetInt32("TRADEMONEY",value); }
          }

          // ���㵥Ԫ����
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // ��ҵ����
          public string CALLINGNO
          {
              get { return  Getstring("CALLINGNO"); }
              set { Setstring("CALLINGNO",value); }
          }

          // ��λ����
          public string CORPNO
          {
              get { return  Getstring("CORPNO"); }
              set { Setstring("CORPNO",value); }
          }

          // ���ű���
          public string DEPARTNO
          {
              get { return  Getstring("DEPARTNO"); }
              set { Setstring("DEPARTNO",value); }
          }

          // ��ҵԱ������
          public string CALLINGSTAFFNO
          {
              get { return  Getstring("CALLINGSTAFFNO"); }
              set { Setstring("CALLINGSTAFFNO",value); }
          }

          // TAC��
          public string TAC
          {
              get { return  Getstring("TAC"); }
              set { Setstring("TAC",value); }
          }

          // �ֽ�֧��
          public string DEALSTATECODE
          {
              get { return  Getstring("DEALSTATECODE"); }
              set { Setstring("DEALSTATECODE",value); }
          }

     }
}


