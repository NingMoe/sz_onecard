using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // ӪҵԱ�ֽ�̨�ʻ��ܱ�
     public class TF_F_TRADEFEE_COLLECTTDO : DDOBase
     {
          public TF_F_TRADEFEE_COLLECTTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_F_TRADEFEE_COLLECT";

               columns = new String[12][];
               columns[0] = new String[]{"TRADETYPECODE", "string"};
               columns[1] = new String[]{"CARDSERVFEE", "Int32"};
               columns[2] = new String[]{"CARDDEPOSITFEE", "Int32"};
               columns[3] = new String[]{"SUPPLYMONEY", "Int32"};
               columns[4] = new String[]{"TRADEPROCFEE", "Int32"};
               columns[5] = new String[]{"FUNCFEE", "Int32"};
               columns[6] = new String[]{"OTHERFEE", "Int32"};
               columns[7] = new String[]{"OPERATESTAFFNO", "string"};
               columns[8] = new String[]{"OPERATEDATE", "string"};
               columns[9] = new String[]{"RSRV1", "Int32"};
               columns[10] = new String[]{"RSRV2", "String"};
               columns[11] = new String[]{"RSRV3", "String"};

               columnKeys = new String[]{
               };


               array = new String[12];
               hash.Add("TRADETYPECODE", 0);
               hash.Add("CARDSERVFEE", 1);
               hash.Add("CARDDEPOSITFEE", 2);
               hash.Add("SUPPLYMONEY", 3);
               hash.Add("TRADEPROCFEE", 4);
               hash.Add("FUNCFEE", 5);
               hash.Add("OTHERFEE", 6);
               hash.Add("OPERATESTAFFNO", 7);
               hash.Add("OPERATEDATE", 8);
               hash.Add("RSRV1", 9);
               hash.Add("RSRV2", 10);
               hash.Add("RSRV3", 11);
          }

          // ҵ�����ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
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

          // ��������
          public string OPERATEDATE
          {
              get { return  Getstring("OPERATEDATE"); }
              set { Setstring("OPERATEDATE",value); }
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


