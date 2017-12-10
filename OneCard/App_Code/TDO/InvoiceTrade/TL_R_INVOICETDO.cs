using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.InvoiceTrade
{
     // ��Ʊ����
     public class TL_R_INVOICETDO : DDOBase
     {
          public TL_R_INVOICETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TL_R_INVOICE";

               columns = new String[15][];
               columns[0] = new String[]{"INVOICENO", "string"};
               columns[1] = new String[]{"VOLUMENO", "string"};
               columns[2] = new String[]{"USESTATECODE", "string"};
               columns[3] = new String[]{"ALLOTSTATECODE", "string"};
               columns[4] = new String[]{"INSTAFFNO", "string"};
               columns[5] = new String[]{"INTIME", "DateTime"};
               columns[6] = new String[]{"OUTSTAFFNO", "string"};
               columns[7] = new String[]{"ALLOTSTAFFNO", "string"};
               columns[8] = new String[]{"ALLOTDEPARTNO", "string"};
               columns[9] = new String[]{"ALLOTTIME", "DateTime"};
               columns[10] = new String[]{"DELSTAFFNO", "string"};
               columns[11] = new String[]{"DELTIME", "DateTime"};
               columns[12] = new String[]{"RSRV1", "Int32"};
               columns[13] = new String[]{"RSRV2", "String"};
               columns[14] = new String[]{"RSRV3", "String"};

               columnKeys = new String[]{
                   "INVOICENO",
               };


               array = new String[15];
               hash.Add("INVOICENO", 0);
               hash.Add("VOLUMENO", 1);
               hash.Add("USESTATECODE", 2);
               hash.Add("ALLOTSTATECODE", 3);
               hash.Add("INSTAFFNO", 4);
               hash.Add("INTIME", 5);
               hash.Add("OUTSTAFFNO", 6);
               hash.Add("ALLOTSTAFFNO", 7);
               hash.Add("ALLOTDEPARTNO", 8);
               hash.Add("ALLOTTIME", 9);
               hash.Add("DELSTAFFNO", 10);
               hash.Add("DELTIME", 11);
               hash.Add("RSRV1", 12);
               hash.Add("RSRV2", 13);
               hash.Add("RSRV3", 14);
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

          // ��Ʊʹ��״̬
          public string USESTATECODE
          {
              get { return  Getstring("USESTATECODE"); }
              set { Setstring("USESTATECODE",value); }
          }

          // ��Ʊ����״̬
          public string ALLOTSTATECODE
          {
              get { return  Getstring("ALLOTSTATECODE"); }
              set { Setstring("ALLOTSTATECODE",value); }
          }

          // ���Ա��
          public string INSTAFFNO
          {
              get { return  Getstring("INSTAFFNO"); }
              set { Setstring("INSTAFFNO",value); }
          }

          // ���ʱ��
          public DateTime INTIME
          {
              get { return  GetDateTime("INTIME"); }
              set { SetDateTime("INTIME",value); }
          }

          // ����Ա��
          public string OUTSTAFFNO
          {
              get { return  Getstring("OUTSTAFFNO"); }
              set { Setstring("OUTSTAFFNO",value); }
          }

          // ����Ա��
          public string ALLOTSTAFFNO
          {
              get { return  Getstring("ALLOTSTAFFNO"); }
              set { Setstring("ALLOTSTAFFNO",value); }
          }

          // ���ò���
          public string ALLOTDEPARTNO
          {
              get { return  Getstring("ALLOTDEPARTNO"); }
              set { Setstring("ALLOTDEPARTNO",value); }
          }

          // ����ʱ��
          public DateTime ALLOTTIME
          {
              get { return  GetDateTime("ALLOTTIME"); }
              set { SetDateTime("ALLOTTIME",value); }
          }

          // ����Ա��
          public string DELSTAFFNO
          {
              get { return  Getstring("DELSTAFFNO"); }
              set { Setstring("DELSTAFFNO",value); }
          }

          // ����ʱ��
          public DateTime DELTIME
          {
              get { return  GetDateTime("DELTIME"); }
              set { SetDateTime("DELTIME",value); }
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


