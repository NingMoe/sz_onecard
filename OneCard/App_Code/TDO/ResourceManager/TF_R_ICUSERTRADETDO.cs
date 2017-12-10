using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ResourceManager
{
     // �û���������̨�˱�
     public class TF_R_ICUSERTRADETDO : DDOBase
     {
          public TF_R_ICUSERTRADETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_R_ICUSERTRADE";

               columns = new String[18][];
               columns[0] = new String[]{"TRADEID", "string"};
               columns[1] = new String[]{"OPETYPECODE", "string"};
               columns[2] = new String[]{"BEGINCARDNO", "string"};
               columns[3] = new String[]{"ENDCARDNO", "string"};
               columns[4] = new String[]{"CARDNUM", "Int32"};
               columns[5] = new String[]{"COSTYPECODE", "string"};
               columns[6] = new String[]{"CARDTYPECODE", "string"};
               columns[7] = new String[]{"MANUTYPECODE", "string"};
               columns[8] = new String[]{"CARDSURFACECODE", "string"};
               columns[9] = new String[]{"CARDCHIPTYPECODE", "string"};
               columns[10] = new String[]{"CARDPRICE", "Int32"};
               columns[11] = new String[]{"CARDAMOUNTPRICE", "Int32"};
               columns[12] = new String[]{"ASSIGNEDSTAFFNO", "string"};
               columns[13] = new String[]{"ASSIGNEDDEPARTID", "string"};
               columns[14] = new String[]{"OPERATESTAFFNO", "string"};
               columns[15] = new String[]{"OPERATEDEPARTID", "string"};
               columns[16] = new String[]{"OPERATETIME", "DateTime"};
               columns[17] = new String[]{"RSRV1", "String"};

               columnKeys = new String[]{
                   "TRADEID",
               };


               array = new String[18];
               hash.Add("TRADEID", 0);
               hash.Add("OPETYPECODE", 1);
               hash.Add("BEGINCARDNO", 2);
               hash.Add("ENDCARDNO", 3);
               hash.Add("CARDNUM", 4);
               hash.Add("COSTYPECODE", 5);
               hash.Add("CARDTYPECODE", 6);
               hash.Add("MANUTYPECODE", 7);
               hash.Add("CARDSURFACECODE", 8);
               hash.Add("CARDCHIPTYPECODE", 9);
               hash.Add("CARDPRICE", 10);
               hash.Add("CARDAMOUNTPRICE", 11);
               hash.Add("ASSIGNEDSTAFFNO", 12);
               hash.Add("ASSIGNEDDEPARTID", 13);
               hash.Add("OPERATESTAFFNO", 14);
               hash.Add("OPERATEDEPARTID", 15);
               hash.Add("OPERATETIME", 16);
               hash.Add("RSRV1", 17);
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // �������ͱ���
          public string OPETYPECODE
          {
              get { return  Getstring("OPETYPECODE"); }
              set { Setstring("OPETYPECODE",value); }
          }

          // ��ʼ����
          public string BEGINCARDNO
          {
              get { return  Getstring("BEGINCARDNO"); }
              set { Setstring("BEGINCARDNO",value); }
          }

          // ��ֹ����
          public string ENDCARDNO
          {
              get { return  Getstring("ENDCARDNO"); }
              set { Setstring("ENDCARDNO",value); }
          }

          // ������
          public Int32 CARDNUM
          {
              get { return  GetInt32("CARDNUM"); }
              set { SetInt32("CARDNUM",value); }
          }

          // COS����
          public string COSTYPECODE
          {
              get { return  Getstring("COSTYPECODE"); }
              set { Setstring("COSTYPECODE",value); }
          }

          // ��Ƭ����
          public string CARDTYPECODE
          {
              get { return  Getstring("CARDTYPECODE"); }
              set { Setstring("CARDTYPECODE",value); }
          }

          // ��Ƭ����
          public string MANUTYPECODE
          {
              get { return  Getstring("MANUTYPECODE"); }
              set { Setstring("MANUTYPECODE",value); }
          }

          // �������
          public string CARDSURFACECODE
          {
              get { return  Getstring("CARDSURFACECODE"); }
              set { Setstring("CARDSURFACECODE",value); }
          }

          // ��оƬ����
          public string CARDCHIPTYPECODE
          {
              get { return  Getstring("CARDCHIPTYPECODE"); }
              set { Setstring("CARDCHIPTYPECODE",value); }
          }

          // ��Ƭ����
          public Int32 CARDPRICE
          {
              get { return  GetInt32("CARDPRICE"); }
              set { SetInt32("CARDPRICE",value); }
          }

          // ��Ƭ�ܽ��
          public Int32 CARDAMOUNTPRICE
          {
              get { return  GetInt32("CARDAMOUNTPRICE"); }
              set { SetInt32("CARDAMOUNTPRICE",value); }
          }

          // ����Ա������
          public string ASSIGNEDSTAFFNO
          {
              get { return  Getstring("ASSIGNEDSTAFFNO"); }
              set { Setstring("ASSIGNEDSTAFFNO",value); }
          }

          // ����Ա������
          public string ASSIGNEDDEPARTID
          {
              get { return  Getstring("ASSIGNEDDEPARTID"); }
              set { Setstring("ASSIGNEDDEPARTID",value); }
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

          // ����1
          public String RSRV1
          {
              get { return  GetString("RSRV1"); }
              set { SetString("RSRV1",value); }
          }

     }
}


