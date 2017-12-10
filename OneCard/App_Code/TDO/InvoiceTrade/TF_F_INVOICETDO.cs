using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.InvoiceTrade
{
     // ��Ʊ���ϱ�
     public class TF_F_INVOICETDO : DDOBase
     {
          public TF_F_INVOICETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_F_INVOICE";

               columns = new String[27][];
               columns[0] = new String[]{"INVOICENO", "string"};
               columns[1] = new String[]{"VOLUMENO", "string"};
               columns[2] = new String[]{"ID", "string"};
               columns[3] = new String[]{"CARDNO", "string"};
               columns[4] = new String[]{"PROJ1", "String"};
               columns[5] = new String[]{"FEE1", "Int32"};
               columns[6] = new String[]{"PROJ2", "String"};
               columns[7] = new String[]{"FEE2", "Int32"};
               columns[8] = new String[]{"PROJ3", "String"};
               columns[9] = new String[]{"FEE3", "Int32"};
               columns[10] = new String[]{"PROJ4", "String"};
               columns[11] = new String[]{"FEE4", "Int32"};
               columns[12] = new String[]{"PROJ5", "String"};
               columns[13] = new String[]{"FEE5", "Int32"};
               columns[14] = new String[]{"TRADEFEE", "Int32"};
               columns[15] = new String[]{"PAYMAN", "String"};
               columns[16] = new String[]{"TRADESTAFF", "String"};
               columns[17] = new String[]{"TRADETIME", "DateTime"};
               columns[18] = new String[]{"TAXNO", "String"};
               columns[19] = new String[]{"OLDINVOICENO", "string"};
               columns[20] = new String[]{"OPERATESTAFFNO", "string"};
               columns[21] = new String[]{"OPERATEDEPARTID", "string"};
               columns[22] = new String[]{"OPERATETIME", "DateTime"};
               columns[23] = new String[]{"REMARK", "String"};
               columns[24] = new String[]{"RSRV1", "Int32"};
               columns[25] = new String[]{"RSRV2", "String"};
               columns[26] = new String[]{"RSRV3", "String"};

               columnKeys = new String[]{
                   "INVOICENO",
               };


               array = new String[27];
               hash.Add("INVOICENO", 0);
               hash.Add("VOLUMENO", 1);
               hash.Add("ID", 2);
               hash.Add("CARDNO", 3);
               hash.Add("PROJ1", 4);
               hash.Add("FEE1", 5);
               hash.Add("PROJ2", 6);
               hash.Add("FEE2", 7);
               hash.Add("PROJ3", 8);
               hash.Add("FEE3", 9);
               hash.Add("PROJ4", 10);
               hash.Add("FEE4", 11);
               hash.Add("PROJ5", 12);
               hash.Add("FEE5", 13);
               hash.Add("TRADEFEE", 14);
               hash.Add("PAYMAN", 15);
               hash.Add("TRADESTAFF", 16);
               hash.Add("TRADETIME", 17);
               hash.Add("TAXNO", 18);
               hash.Add("OLDINVOICENO", 19);
               hash.Add("OPERATESTAFFNO", 20);
               hash.Add("OPERATEDEPARTID", 21);
               hash.Add("OPERATETIME", 22);
               hash.Add("REMARK", 23);
               hash.Add("RSRV1", 24);
               hash.Add("RSRV2", 25);
               hash.Add("RSRV3", 26);
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


