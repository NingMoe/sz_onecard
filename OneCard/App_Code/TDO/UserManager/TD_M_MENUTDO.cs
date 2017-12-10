using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.UserManager
{
     // �˵�������
     public class TD_M_MENUTDO : DDOBase
     {
          public TD_M_MENUTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_MENU";

               columns = new String[13][];
               columns[0] = new String[]{"MENUNO", "string"};
               columns[1] = new String[]{"MENUNAME", "String"};
               columns[2] = new String[]{"PMENUNO", "string"};
               columns[3] = new String[]{"URL", "String"};
               columns[4] = new String[]{"TARGET", "String"};
               columns[5] = new String[]{"TIPS", "String"};
               columns[6] = new String[]{"CLICKFUC", "String"};
               columns[7] = new String[]{"DEFAULFLAG", "string"};
               columns[8] = new String[]{"MENULEVEL", "string"};
               columns[9] = new String[]{"UPDATESTAFFNO", "string"};
               columns[10] = new String[]{"UPDATETIME", "DateTime"};
               columns[11] = new String[]{"REMARK", "String"};
               columns[12] = new String[] { "ISNEW", "String" };
               columnKeys = new String[]{
                   "MENUNO",
               };


               array = new String[13];
               hash.Add("MENUNO", 0);
               hash.Add("MENUNAME", 1);
               hash.Add("PMENUNO", 2);
               hash.Add("URL", 3);
               hash.Add("TARGET", 4);
               hash.Add("TIPS", 5);
               hash.Add("CLICKFUC", 6);
               hash.Add("DEFAULFLAG", 7);
               hash.Add("MENULEVEL", 8);
               hash.Add("UPDATESTAFFNO", 9);
               hash.Add("UPDATETIME", 10);
               hash.Add("REMARK", 11);
               hash.Add("ISNEW", 12);
          }

          // �˵������
          public string MENUNO
          {
              get { return  Getstring("MENUNO"); }
              set { Setstring("MENUNO",value); }
          }

          // �˵�����
          public String MENUNAME
          {
              get { return  GetString("MENUNAME"); }
              set { SetString("MENUNAME",value); }
          }

          // �ϼ��˵�����
          public string PMENUNO
          {
              get { return  Getstring("PMENUNO"); }
              set { Setstring("PMENUNO",value); }
          }

          // URL
          public String URL
          {
              get { return  GetString("URL"); }
              set { SetString("URL",value); }
          }

          // TARGET
          public String TARGET
          {
              get { return  GetString("TARGET"); }
              set { SetString("TARGET",value); }
          }

          // ��ʾ
          public String TIPS
          {
              get { return  GetString("TIPS"); }
              set { SetString("TIPS",value); }
          }

          // �������
          public String CLICKFUC
          {
              get { return  GetString("CLICKFUC"); }
              set { SetString("CLICKFUC",value); }
          }

          // Ĭ��FLAG
          public string DEFAULFLAG
          {
              get { return  Getstring("DEFAULFLAG"); }
              set { Setstring("DEFAULFLAG",value); }
          }

          // �˵�����
          public string MENULEVEL
          {
              get { return  Getstring("MENULEVEL"); }
              set { Setstring("MENULEVEL",value); }
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

          public String ISNEW
          {
              get { return GetString("ISNEW"); }
              set { SetString("ISNEW", value); }
          }

     }
}


