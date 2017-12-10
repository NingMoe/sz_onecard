using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.UserManager
{
     // �ڲ����ű����
     public class TD_M_INSIDEDEPARTTDO : DDOBase
     {
          public TD_M_INSIDEDEPARTTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_INSIDEDEPART";

               columns = new String[7][];
               columns[0] = new String[]{"DEPARTNO", "string"};
               columns[1] = new String[]{"DEPARTNAME", "String"};
               columns[2] = new String[]{"UPDATESTAFFNO", "string"};
               columns[3] = new String[]{"UPDATETIME", "DateTime"};
               columns[4] = new String[]{"REMARK", "String"};
               columns[5] = new String[]{"REGIONCODE", "String" };
               columns[6] = new String[] { "USETAG", "String" };
               columnKeys = new String[]{
                   "DEPARTNO",
               };


               array = new String[7];
               hash.Add("DEPARTNO", 0);
               hash.Add("DEPARTNAME", 1);
               hash.Add("UPDATESTAFFNO", 2);
               hash.Add("UPDATETIME", 3);
               hash.Add("REMARK", 4);
               hash.Add("REGIONCODE", 5);
               hash.Add("USETAG", 6);
          }

          // ���ű���
          public string DEPARTNO
          {
              get { return  Getstring("DEPARTNO"); }
              set { Setstring("DEPARTNO",value); }
          }

          // ��������
          public String DEPARTNAME
          {
              get { return  GetString("DEPARTNAME"); }
              set { SetString("DEPARTNAME",value); }
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

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }
          // ��������
          public String REGIONCODE
          {
              get { return GetString("REGIONCODE"); }
              set { SetString("REGIONCODE", value); }
          }

         //��Ч��ʶ
          public String USETAG
          {
              get { return GetString("USETAG"); }
              set { SetString("USETAG", value); }
          }

     }
}


