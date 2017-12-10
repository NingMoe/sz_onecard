using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.InvoiceTrade
{
     // ��Ʊ̨�ʱ�
     public class TF_B_INVOICETDO : DDOBase
     {
          public TF_B_INVOICETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_INVOICE";

               columns = new String[29][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"INVOICENO", "string"};
               columns[2] = new String[]{"VOLUMENO", "string"};
               columns[3] = new String[]{"FUNCTIONTYPECODE", "string"};
               columns[4] = new String[]{"ID", "string"};
               columns[5] = new String[]{"CARDNO", "string"};
               columns[6] = new String[]{"PROJ1", "String"};
               columns[7] = new String[]{"FEE1", "Int32"};
               columns[8] = new String[]{"PROJ2", "String"};
               columns[9] = new String[]{"FEE2", "Int32"};
               columns[10] = new String[]{"PROJ3", "String"};
               columns[11] = new String[]{"FEE3", "Int32"};
               columns[12] = new String[]{"PROJ4", "String"};
               columns[13] = new String[]{"FEE4", "Int32"};
               columns[14] = new String[]{"PROJ5", "String"};
               columns[15] = new String[]{"FEE5", "Int32"};
               columns[16] = new String[]{"TRADEFEE", "Int32"};
               columns[17] = new String[]{"PAYMAN", "String"};
               columns[18] = new String[]{"TRADESTAFF", "String"};
               columns[19] = new String[]{"TRADETIME", "DateTime"};
               columns[20] = new String[]{"TAXNO", "String"};
               columns[21] = new String[]{"OLDINVOICENO", "string"};
               columns[22] = new String[]{"OPERATESTAFFNO", "string"};
               columns[23] = new String[]{"OPERATEDEPARTID", "string"};
               columns[24] = new String[]{"OPERATETIME", "DateTime"};
               columns[25] = new String[]{"REMARK", "String"};
               columns[26] = new String[]{"RSRV1", "Int32"};
               columns[27] = new String[]{"RSRV2", "String"};
               columns[28] = new String[]{"RSRV3", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[29];
               hash.Add("TRADEID", 0);
               hash.Add("INVOICENO", 1);
               hash.Add("VOLUMENO", 2);
               hash.Add("FUNCTIONTYPECODE", 3);
               hash.Add("ID", 4);
               hash.Add("CARDNO", 5);
               hash.Add("PROJ1", 6);
               hash.Add("FEE1", 7);
               hash.Add("PROJ2", 8);
               hash.Add("FEE2", 9);
               hash.Add("PROJ3", 10);
               hash.Add("FEE3", 11);
               hash.Add("PROJ4", 12);
               hash.Add("FEE4", 13);
               hash.Add("PROJ5", 14);
               hash.Add("FEE5", 15);
               hash.Add("TRADEFEE", 16);
               hash.Add("PAYMAN", 17);
               hash.Add("TRADESTAFF", 18);
               hash.Add("TRADETIME", 19);
               hash.Add("TAXNO", 20);
               hash.Add("OLDINVOICENO", 21);
               hash.Add("OPERATESTAFFNO", 22);
               hash.Add("OPERATEDEPARTID", 23);
               hash.Add("OPERATETIME", 24);
               hash.Add("REMARK", 25);
               hash.Add("RSRV1", 26);
               hash.Add("RSRV2", 27);
               hash.Add("RSRV3", 28);
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // ��Ʊ��
          public string INVOICENO
          {
              get { return  Getstring("INVOICENO"); }
              set { Setstring("INVOICENO",value); }
          }

          // ��Ʊ���
          public string VOLUMENO
          {
              get { return  Getstring("VOLUMENO"); }
              set { Setstring("VOLUMENO",value); }
          }

          // �������ͱ���
          public string FUNCTIONTYPECODE
          {
              get { return  Getstring("FUNCTIONTYPECODE"); }
              set { Setstring("FUNCTIONTYPECODE",value); }
          }

          // �ֽ�̨�ʼ�¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // IC����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ��Ŀһ
          public String PROJ1
          {
              get { return  GetString("PROJ1"); }
              set { SetString("PROJ1",value); }
          }

          // ���һ
          public Int32 FEE1
          {
              get { return  GetInt32("FEE1"); }
              set { SetInt32("FEE1",value); }
          }

          // ��Ŀ��
          public String PROJ2
          {
              get { return  GetString("PROJ2"); }
              set { SetString("PROJ2",value); }
          }

          // ����
          public Int32 FEE2
          {
              get { return  GetInt32("FEE2"); }
              set { SetInt32("FEE2",value); }
          }

          // ��Ŀ��
          public String PROJ3
          {
              get { return  GetString("PROJ3"); }
              set { SetString("PROJ3",value); }
          }

          // �����
          public Int32 FEE3
          {
              get { return  GetInt32("FEE3"); }
              set { SetInt32("FEE3",value); }
          }

          // ��Ŀ��
          public String PROJ4
          {
              get { return  GetString("PROJ4"); }
              set { SetString("PROJ4",value); }
          }

          // �����
          public Int32 FEE4
          {
              get { return  GetInt32("FEE4"); }
              set { SetInt32("FEE4",value); }
          }

          // ��Ŀ��
          public String PROJ5
          {
              get { return  GetString("PROJ5"); }
              set { SetString("PROJ5",value); }
          }

          // �����
          public Int32 FEE5
          {
              get { return  GetInt32("FEE5"); }
              set { SetInt32("FEE5",value); }
          }

          // ��Ʊ�ܽ��
          public Int32 TRADEFEE
          {
              get { return  GetInt32("TRADEFEE"); }
              set { SetInt32("TRADEFEE",value); }
          }

          // ���
          public String PAYMAN
          {
              get { return  GetString("PAYMAN"); }
              set { SetString("PAYMAN",value); }
          }

          // ��Ʊ��
          public String TRADESTAFF
          {
              get { return  GetString("TRADESTAFF"); }
              set { SetString("TRADESTAFF",value); }
          }

          // ��Ʊʱ��
          public DateTime TRADETIME
          {
              get { return  GetDateTime("TRADETIME"); }
              set { SetDateTime("TRADETIME",value); }
          }

          // ��˰��ʶ���
          public String TAXNO
          {
              get { return  GetString("TAXNO"); }
              set { SetString("TAXNO",value); }
          }

          // ��巢Ʊ��
          public string OLDINVOICENO
          {
              get { return  Getstring("OLDINVOICENO"); }
              set { Setstring("OLDINVOICENO",value); }
          }

          // ����Ա������
          public string OPERATESTAFFNO
          {
              get { return  Getstring("OPERATESTAFFNO"); }
              set { Setstring("OPERATESTAFFNO",value); }
          }

          // ���ű���
          public string OPERATEDEPARTID
          {
              get { return  Getstring("OPERATEDEPARTID"); }
              set { Setstring("OPERATEDEPARTID",value); }
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

          // ����1
          public Int32 RSRV1
          {
              get { return  GetInt32("RSRV1"); }
              set { SetInt32("RSRV1",value); }
          }

          // ����2
          public String RSRV2
          {
              get { return  GetString("RSRV2"); }
              set { SetString("RSRV2",value); }
          }

          // ����3
          public String RSRV3
          {
              get { return  GetString("RSRV3"); }
              set { SetString("RSRV3",value); }
          }

     }
}


