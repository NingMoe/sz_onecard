using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CardManager
{
     // ���̱����
     public class TD_M_MANUTDO : DDOBase
     {
          public TD_M_MANUTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_MANU";

               columns = new String[7][];
               columns[0] = new String[]{"MANUCODE", "string"};
               columns[1] = new String[]{"MANUNAME", "String"};
               columns[2] = new String[]{"MANUNOTE", "String"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};
               columns[6] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "MANUCODE",
               };


               array = new String[7];
               hash.Add("MANUCODE", 0);
               hash.Add("MANUNAME", 1);
               hash.Add("MANUNOTE", 2);
               hash.Add("USETAG", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
               hash.Add("REMARK", 6);
          }

          // ���̱���
          public string MANUCODE
          {
              get { return  Getstring("MANUCODE"); }
              set { Setstring("MANUCODE",value); }
          }

          // ��������
          public String MANUNAME
          {
              get { return  GetString("MANUNAME"); }
              set { SetString("MANUNAME",value); }
          }

          // ����˵��
          public String MANUNOTE
          {
              get { return  GetString("MANUNOTE"); }
              set { SetString("MANUNOTE",value); }
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

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


