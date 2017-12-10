using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // ǰ̨��ֵ���ۿ�̨�ʱ�
     public class TF_XFC_SELLTDO : DDOBase
     {
          public TF_XFC_SELLTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_XFC_SELL";

               columns = new String[14][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"TRADETYPECODE", "string"};
               columns[2] = new String[]{"STARTCARDNO", "string"};
               columns[3] = new String[]{"ENDCARDNO", "string"};
               columns[4] = new String[]{"AMOUNT", "Int32"};
               columns[5] = new String[]{"MONEY", "Int32"};
               columns[6] = new String[]{"STAFFNO", "string"};
               columns[7] = new String[]{"OPERATETIME", "DateTime"};
               columns[8] = new String[]{"REMARK", "String"};
               columns[9] = new String[]{"CANCELTAG", "string"};
               columns[10] = new String[]{"CANCELTRADEID", "string"};
               columns[11] = new String[]{"RSRV1", "string"};
               columns[12] = new String[]{"RSRV2", "string"};
               columns[13] = new String[]{"RSRV3", "Int32"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[14];
               hash.Add("TRADEID", 0);
               hash.Add("TRADETYPECODE", 1);
               hash.Add("STARTCARDNO", 2);
               hash.Add("ENDCARDNO", 3);
               hash.Add("AMOUNT", 4);
               hash.Add("MONEY", 5);
               hash.Add("STAFFNO", 6);
               hash.Add("OPERATETIME", 7);
               hash.Add("REMARK", 8);
               hash.Add("CANCELTAG", 9);
               hash.Add("CANCELTRADEID", 10);
               hash.Add("RSRV1", 11);
               hash.Add("RSRV2", 12);
               hash.Add("RSRV3", 13);
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // ҵ�����ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // ��ʼ����
          public string STARTCARDNO
          {
              get { return  Getstring("STARTCARDNO"); }
              set { Setstring("STARTCARDNO",value); }
          }

          // ��������
          public string ENDCARDNO
          {
              get { return  Getstring("ENDCARDNO"); }
              set { Setstring("ENDCARDNO",value); }
          }

          // ������
          public Int32 AMOUNT
          {
              get { return  GetInt32("AMOUNT"); }
              set { SetInt32("AMOUNT",value); }
          }

          // ���
          public Int32 MONEY
          {
              get { return  GetInt32("MONEY"); }
              set { SetInt32("MONEY",value); }
          }

          // ����Ա������
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // ����ʱ��
          public DateTime OPERATETIME
          {
              get { return  GetDateTime("OPERATETIME"); }
              set { SetDateTime("OPERATETIME",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

          // ���˱�־
          public string CANCELTAG
          {
              get { return  Getstring("CANCELTAG"); }
              set { Setstring("CANCELTAG",value); }
          }

          // ����ҵ����ˮ��
          public string CANCELTRADEID
          {
              get { return  Getstring("CANCELTRADEID"); }
              set { Setstring("CANCELTRADEID",value); }
          }

          // ����1
          public string RSRV1
          {
              get { return  Getstring("RSRV1"); }
              set { Setstring("RSRV1",value); }
          }

          // ����2
          public string RSRV2
          {
              get { return  Getstring("RSRV2"); }
              set { Setstring("RSRV2",value); }
          }

          // ����3
          public Int32 RSRV3
          {
              get { return  GetInt32("RSRV3"); }
              set { SetInt32("RSRV3",value); }
          }

     }
}


