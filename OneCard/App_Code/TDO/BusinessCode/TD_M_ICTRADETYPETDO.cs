using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BusinessCode
{
     // IC�������ͱ����
     public class TD_M_ICTRADETYPETDO : DDOBase
     {
          public TD_M_ICTRADETYPETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_ICTRADETYPE";

               columns = new String[7][];
               columns[0] = new String[]{"ICTRADETYPECODE", "string"};
               columns[1] = new String[]{"ICTRADETYPE", "String"};
               columns[2] = new String[]{"EDOREPTAG", "string"};
               columns[3] = new String[]{"LINEORONLINETAG", "string"};
               columns[4] = new String[]{"ISOPENTAG", "string"};
               columns[5] = new String[]{"UPDATESTAFFNO", "string"};
               columns[6] = new String[]{"UPDATETIME", "DateTime"};

               columnKeys = new String[]{
                   "ICTRADETYPECODE",
               };


               array = new String[7];
               hash.Add("ICTRADETYPECODE", 0);
               hash.Add("ICTRADETYPE", 1);
               hash.Add("EDOREPTAG", 2);
               hash.Add("LINEORONLINETAG", 3);
               hash.Add("ISOPENTAG", 4);
               hash.Add("UPDATESTAFFNO", 5);
               hash.Add("UPDATETIME", 6);
          }

          // IC�������ͱ���
          public string ICTRADETYPECODE
          {
              get { return  Getstring("ICTRADETYPECODE"); }
              set { Setstring("ICTRADETYPECODE",value); }
          }

          // IC��������˵��
          public String ICTRADETYPE
          {
              get { return  GetString("ICTRADETYPE"); }
              set { SetString("ICTRADETYPE",value); }
          }

          // ED/EP��־
          public string EDOREPTAG
          {
              get { return  Getstring("EDOREPTAG"); }
              set { Setstring("EDOREPTAG",value); }
          }

          // ����/�ѻ���־
          public string LINEORONLINETAG
          {
              get { return  Getstring("LINEORONLINETAG"); }
              set { Setstring("LINEORONLINETAG",value); }
          }

          // �Ƿ񿪷�
          public string ISOPENTAG
          {
              get { return  Getstring("ISOPENTAG"); }
              set { Setstring("ISOPENTAG",value); }
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

     }
}


