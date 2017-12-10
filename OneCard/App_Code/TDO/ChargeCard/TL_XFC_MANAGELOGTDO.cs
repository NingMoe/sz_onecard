using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ChargeCard
{
     // ��ֵ��������־��
     public class TL_XFC_MANAGELOGTDO : DDOBase
     {
          public TL_XFC_MANAGELOGTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TL_XFC_MANAGELOG";

               columns = new String[7][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"STAFFNO", "string"};
               columns[2] = new String[]{"OPERTIME", "DateTime"};
               columns[3] = new String[]{"OPERTYPECODE", "string"};
               columns[4] = new String[]{"STARTCARDNO", "string"};
               columns[5] = new String[]{"ENDCARDNO", "string"};
               columns[6] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[7];
               hash.Add("ID", 0);
               hash.Add("STAFFNO", 1);
               hash.Add("OPERTIME", 2);
               hash.Add("OPERTYPECODE", 3);
               hash.Add("STARTCARDNO", 4);
               hash.Add("ENDCARDNO", 5);
               hash.Add("REMARK", 6);
          }

          // ���
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // ����Ա
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // ����ʱ��
          public DateTime OPERTIME
          {
              get { return  GetDateTime("OPERTIME"); }
              set { SetDateTime("OPERTIME",value); }
          }

          // �������ͱ���
          public string OPERTYPECODE
          {
              get { return  Getstring("OPERTYPECODE"); }
              set { Setstring("OPERTYPECODE",value); }
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

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


