using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // ҵ��д��̨�ʱ�
     public class TF_CARD_TRADETDO : DDOBase
     {
          public TF_CARD_TRADETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_CARD_TRADE";

               columns = new String[21][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"TRADETYPECODE", "string"};
               columns[2] = new String[]{"strOperCardNo", "string"};
               columns[3] = new String[]{"strCardNo", "string"};
               columns[4] = new String[]{"lMoney", "Int32"};
               columns[5] = new String[]{"lOldMoney", "Int32"};
               columns[6] = new String[]{"strTermno", "string"};
               columns[7] = new String[]{"strEndDateNum", "string"};
               columns[8] = new String[]{"strFlag", "string"};
               columns[9] = new String[]{"strStaffno", "string"};
               columns[10] = new String[]{"strTaxino", "string"};
               columns[11] = new String[]{"strState", "string"};
               columns[12] = new String[]{"Cardtradeno", "string"};
               columns[13] = new String[]{"NextCardtradeno", "string"};
               columns[14] = new String[]{"OPERATETIME", "DateTime"};
               columns[15] = new String[]{"SUCTAG", "string"};
               columns[16] = new String[]{"strErrInfo", "String"};
               columns[17] = new String[]{"RSRV1", "String"};
               columns[18] = new String[]{"RSRV2", "String"};
               columns[19] = new String[]{"RSRV3", "DateTime"};
               columns[20] = new String[] { "writeCardScript", "String" };

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[21];
               hash.Add("TRADEID", 0);
               hash.Add("TRADETYPECODE", 1);
               hash.Add("strOperCardNo", 2);
               hash.Add("strCardNo", 3);
               hash.Add("lMoney", 4);
               hash.Add("lOldMoney", 5);
               hash.Add("strTermno", 6);
               hash.Add("strEndDateNum", 7);
               hash.Add("strFlag", 8);
               hash.Add("strStaffno", 9);
               hash.Add("strTaxino", 10);
               hash.Add("strState", 11);
               hash.Add("Cardtradeno", 12);
               hash.Add("NextCardtradeno", 13);
               hash.Add("OPERATETIME", 14);
               hash.Add("SUCTAG", 15);
               hash.Add("strErrInfo", 16);
               hash.Add("RSRV1", 17);
               hash.Add("RSRV2", 18);
               hash.Add("RSRV3", 19);
               hash.Add("writeCardScript", 20);
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

          // ����Ա����
          public string strOperCardNo
          {
              get { return  Getstring("strOperCardNo"); }
              set { Setstring("strOperCardNo",value); }
          }

          // ����
          public string strCardNo
          {
              get { return  Getstring("strCardNo"); }
              set { Setstring("strCardNo",value); }
          }

          // �������
          public Int32 lMoney
          {
              get { return  GetInt32("lMoney"); }
              set { SetInt32("lMoney",value); }
          }

          // ��Ƭ��ԭ���
          public Int32 lOldMoney
          {
              get { return  GetInt32("lOldMoney"); }
              set { SetInt32("lOldMoney",value); }
          }

          // �ն˺�
          public string strTermno
          {
              get { return  Getstring("strTermno"); }
              set { Setstring("strTermno",value); }
          }

          // �꿨��ֹ���ڴ���
          public string strEndDateNum
          {
              get { return  Getstring("strEndDateNum"); }
              set { Setstring("strEndDateNum",value); }
          }

          // ��Ʊ������
          public string strFlag
          {
              get { return  Getstring("strFlag"); }
              set { Setstring("strFlag",value); }
          }

          // ����˾������
          public string strStaffno
          {
              get { return  Getstring("strStaffno"); }
              set { Setstring("strStaffno",value); }
          }

          // ����˾������
          public string strTaxino
          {
              get { return  Getstring("strTaxino"); }
              set { Setstring("strTaxino",value); }
          }

          // ����˾��״̬����
          public string strState
          {
              get { return  Getstring("strState"); }
              set { Setstring("strState",value); }
          }

          // ��ֵǰ�����������
          public string Cardtradeno
          {
              get { return  Getstring("Cardtradeno"); }
              set { Setstring("Cardtradeno",value); }
          }

          // ��ֵ�������������
          public string NextCardtradeno
          {
              get { return  Getstring("NextCardtradeno"); }
              set { Setstring("NextCardtradeno",value); }
          }

          // ����ʱ��
          public DateTime OPERATETIME
          {
              get { return  GetDateTime("OPERATETIME"); }
              set { SetDateTime("OPERATETIME",value); }
          }

          // д���ɹ���־
          public string SUCTAG
          {
              get { return  Getstring("SUCTAG"); }
              set { Setstring("SUCTAG",value); }
          }

          // ������Ϣ
          public String strErrInfo
          {
              get { return  GetString("strErrInfo"); }
              set { SetString("strErrInfo",value); }
          }

          // ����1
          public String RSRV1
          {
              get { return  GetString("RSRV1"); }
              set { SetString("RSRV1",value); }
          }

          // ����2
          public String RSRV2
          {
              get { return  GetString("RSRV2"); }
              set { SetString("RSRV2",value); }
          }

          // ����3
          public DateTime RSRV3
          {
              get { return  GetDateTime("RSRV3"); }
              set { SetDateTime("RSRV3",value); }
          }

          public DateTime writeCardScript
          {
              get { return GetDateTime("writeCardScript"); }
              set { SetDateTime("writeCardScript", value); }
          }

     }
}


