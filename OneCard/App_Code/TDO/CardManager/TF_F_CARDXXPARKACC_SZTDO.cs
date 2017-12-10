using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // ���������꿨�˻���
     public class TF_F_CARDXXPARKACC_SZTDO : DDOBase
     {
          public TF_F_CARDXXPARKACC_SZTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_F_CARDXXPARKACC_SZ";

               columns = new String[15][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"CURRENTOPENYEAR", "string"};
               columns[2] = new String[]{"CARDTIMES", "Int32"};
               columns[3] = new String[]{"ENDDATE", "string"};
               columns[4] = new String[]{"CURRENTPAYTIME", "DateTime"};
               columns[5] = new String[]{"CURRENTPAYFEE", "Int32"};
               columns[6] = new String[]{"TOTALTIMES", "Int32"};
               columns[7] = new String[]{"SPARETIMES", "Int32"};
               columns[8] = new String[]{"USETAG", "string"};
               columns[9] = new String[]{"UPDATESTAFFNO", "string"};
               columns[10] = new String[]{"UPDATETIME", "DateTime"};
               columns[11] = new String[]{"RERVINT", "Int32"};
               columns[12] = new String[]{"RERVCHAR", "String"};
               columns[13] = new String[]{"RERVSTRING", "DateTime"};
               columns[14] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDNO",
               };


               array = new String[15];
               hash.Add("CARDNO", 0);
               hash.Add("CURRENTOPENYEAR", 1);
               hash.Add("CARDTIMES", 2);
               hash.Add("ENDDATE", 3);
               hash.Add("CURRENTPAYTIME", 4);
               hash.Add("CURRENTPAYFEE", 5);
               hash.Add("TOTALTIMES", 6);
               hash.Add("SPARETIMES", 7);
               hash.Add("USETAG", 8);
               hash.Add("UPDATESTAFFNO", 9);
               hash.Add("UPDATETIME", 10);
               hash.Add("RERVINT", 11);
               hash.Add("RERVCHAR", 12);
               hash.Add("RERVSTRING", 13);
               hash.Add("REMARK", 14);
          }

          // IC����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ��ǰ��ͨ���
          public string CURRENTOPENYEAR
          {
              get { return  Getstring("CURRENTOPENYEAR"); }
              set { Setstring("CURRENTOPENYEAR",value); }
          }

          // ��������
          public Int32 CARDTIMES
          {
              get { return  GetInt32("CARDTIMES"); }
              set { SetInt32("CARDTIMES",value); }
          }

          // �����������
          public string ENDDATE
          {
              get { return  Getstring("ENDDATE"); }
              set { Setstring("ENDDATE",value); }
          }

          // ����ɷ�ʱ��
          public DateTime CURRENTPAYTIME
          {
              get { return  GetDateTime("CURRENTPAYTIME"); }
              set { SetDateTime("CURRENTPAYTIME",value); }
          }

          // ����ɷѽ��
          public Int32 CURRENTPAYFEE
          {
              get { return  GetInt32("CURRENTPAYFEE"); }
              set { SetInt32("CURRENTPAYFEE",value); }
          }

          // �����ܿ��ô���
          public Int32 TOTALTIMES
          {
              get { return  GetInt32("TOTALTIMES"); }
              set { SetInt32("TOTALTIMES",value); }
          }

          // ����ʣ����ô���
          public Int32 SPARETIMES
          {
              get { return  GetInt32("SPARETIMES"); }
              set { SetInt32("SPARETIMES",value); }
          }

          // ��Ч��־
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
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

          // ����1
          public Int32 RERVINT
          {
              get { return  GetInt32("RERVINT"); }
              set { SetInt32("RERVINT",value); }
          }

          // ����2
          public String RERVCHAR
          {
              get { return  GetString("RERVCHAR"); }
              set { SetString("RERVCHAR",value); }
          }

          // ����3
          public DateTime RERVSTRING
          {
              get { return  GetDateTime("RERVSTRING"); }
              set { SetDateTime("RERVSTRING",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


