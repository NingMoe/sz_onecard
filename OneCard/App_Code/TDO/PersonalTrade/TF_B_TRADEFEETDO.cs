using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
     // �ֽ�̨������
     public class TF_B_TRADEFEETDO : DDOBase
     {
          public TF_B_TRADEFEETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_B_TRADEFEE";

               columns = new String[20][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"TRADEID", "string"};
               columns[2] = new String[]{"TRADETYPECODE", "string"};
               columns[3] = new String[]{"CARDNO", "string"};
               columns[4] = new String[]{"CARDTRADENO", "string"};
               columns[5] = new String[]{"PREMONEY", "Int32"};
               columns[6] = new String[]{"CARDSERVFEE", "Int32"};
               columns[7] = new String[]{"CARDDEPOSITFEE", "Int32"};
               columns[8] = new String[]{"SUPPLYMONEY", "Int32"};
               columns[9] = new String[]{"TRADEPROCFEE", "Int32"};
               columns[10] = new String[]{"FUNCFEE", "Int32"};
               columns[11] = new String[]{"OTHERFEE", "Int32"};
               columns[12] = new String[]{"OPERATESTAFFNO", "string"};
               columns[13] = new String[]{"OPERATEDEPARTID", "string"};
               columns[14] = new String[]{"OPERATETIME", "DateTime"};
               columns[15] = new String[]{"CANCELTAG", "string"};
               columns[16] = new String[]{"COLLECTTAG", "string"};
               columns[17] = new String[]{"RSRV1", "Int32"};
               columns[18] = new String[]{"RSRV2", "String"};
               columns[19] = new String[]{"RSRV3", "String"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[20];
               hash.Add("ID", 0);
               hash.Add("TRADEID", 1);
               hash.Add("TRADETYPECODE", 2);
               hash.Add("CARDNO", 3);
               hash.Add("CARDTRADENO", 4);
               hash.Add("PREMONEY", 5);
               hash.Add("CARDSERVFEE", 6);
               hash.Add("CARDDEPOSITFEE", 7);
               hash.Add("SUPPLYMONEY", 8);
               hash.Add("TRADEPROCFEE", 9);
               hash.Add("FUNCFEE", 10);
               hash.Add("OTHERFEE", 11);
               hash.Add("OPERATESTAFFNO", 12);
               hash.Add("OPERATEDEPARTID", 13);
               hash.Add("OPERATETIME", 14);
               hash.Add("CANCELTAG", 15);
               hash.Add("COLLECTTAG", 16);
               hash.Add("RSRV1", 17);
               hash.Add("RSRV2", 18);
               hash.Add("RSRV3", 19);
          }

          // ��¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // ҵ����ˮ��
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // ҵ�����ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // IC����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // �����������
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // ��ֵǰ�������
          public Int32 PREMONEY
          {
              get { return  GetInt32("PREMONEY"); }
              set { SetInt32("PREMONEY",value); }
          }

          // �������
          public Int32 CARDSERVFEE
          {
              get { return  GetInt32("CARDSERVFEE"); }
              set { SetInt32("CARDSERVFEE",value); }
          }

          // ��Ѻ��
          public Int32 CARDDEPOSITFEE
          {
              get { return  GetInt32("CARDDEPOSITFEE"); }
              set { SetInt32("CARDDEPOSITFEE",value); }
          }

          // ��ֵ���
          public Int32 SUPPLYMONEY
          {
              get { return  GetInt32("SUPPLYMONEY"); }
              set { SetInt32("SUPPLYMONEY",value); }
          }

          // ҵ��������
          public Int32 TRADEPROCFEE
          {
              get { return  GetInt32("TRADEPROCFEE"); }
              set { SetInt32("TRADEPROCFEE",value); }
          }

          // ���չ��ܿ�ͨ��
          public Int32 FUNCFEE
          {
              get { return  GetInt32("FUNCFEE"); }
              set { SetInt32("FUNCFEE",value); }
          }

          // ��������
          public Int32 OTHERFEE
          {
              get { return  GetInt32("OTHERFEE"); }
              set { SetInt32("OTHERFEE",value); }
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

          // ���˱�־
          public string CANCELTAG
          {
              get { return  Getstring("CANCELTAG"); }
              set { Setstring("CANCELTAG",value); }
          }

          // ���ܱ�־
          public string COLLECTTAG
          {
              get { return  Getstring("COLLECTTAG"); }
              set { Setstring("COLLECTTAG",value); }
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


