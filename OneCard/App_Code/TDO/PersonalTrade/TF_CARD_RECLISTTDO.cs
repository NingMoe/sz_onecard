using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // ���ڽ��׼�¼̨���ӱ�
     public class TF_CARD_RECLISTTDO : DDOBase
     {
          public TF_CARD_RECLISTTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_CARD_RECLIST";

               columns = new String[8][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"SEQ", "Int32"};
               columns[2] = new String[]{"CARDTRADENO", "string"};
               columns[3] = new String[]{"TRADEMONEY", "String"};
               columns[4] = new String[]{"ICTRADETYPECODE", "string"};
               columns[5] = new String[]{"SAMNO", "string"};
               columns[6] = new String[]{"TRADEDATE", "string"};
               columns[7] = new String[]{"TRADETIME", "string"};

               columnKeys = new String[]{
                   "TRADEID",
                   "SEQ",
               };


               array = new String[8];
               hash.Add("TRADEID", 0);
               hash.Add("SEQ", 1);
               hash.Add("CARDTRADENO", 2);
               hash.Add("TRADEMONEY", 3);
               hash.Add("ICTRADETYPECODE", 4);
               hash.Add("SAMNO", 5);
               hash.Add("TRADEDATE", 6);
               hash.Add("TRADETIME", 7);
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // ���
          public Int32 SEQ
          {
              get { return  GetInt32("SEQ"); }
              set { SetInt32("SEQ",value); }
          }

          // ���������к�
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // ���׽��
          public String TRADEMONEY
          {
              get { return  GetString("TRADEMONEY"); }
              set { SetString("TRADEMONEY",value); }
          }

          // IC�������ͱ���
          public string ICTRADETYPECODE
          {
              get { return  Getstring("ICTRADETYPECODE"); }
              set { Setstring("ICTRADETYPECODE",value); }
          }

          // PSAM���
          public string SAMNO
          {
              get { return  Getstring("SAMNO"); }
              set { Setstring("SAMNO",value); }
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

     }
}


