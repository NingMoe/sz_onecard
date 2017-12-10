using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.Financial
{
     // ��ֵ���ܲ�ֱ��ƾ֤��ϸ��
     public class TF_XFC_SERIALNO_DETAILTDO : DDOBase
     {
          public TF_XFC_SERIALNO_DETAILTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_XFC_SERIALNO_DETAIL";

               columns = new String[7][];
               columns[0] = new String[]{"FIANCE_SERIALNO", "string"};
               columns[1] = new String[]{"CUSTNAME", "String"};
               columns[2] = new String[]{"CARDVALUE", "Int32"};
               columns[3] = new String[]{"TOTALMONEY", "Int32"};
               columns[4] = new String[]{"BUYTIME", "string"};
               columns[5] = new String[]{"PAYTIME", "string"};
               columns[6] = new String[]{"PAYTAG", "string"};

               columnKeys = new String[]{
               };


               array = new String[7];
               hash.Add("FIANCE_SERIALNO", 0);
               hash.Add("CUSTNAME", 1);
               hash.Add("CARDVALUE", 2);
               hash.Add("TOTALMONEY", 3);
               hash.Add("BUYTIME", 4);
               hash.Add("PAYTIME", 5);
               hash.Add("PAYTAG", 6);
          }

          // ����ƾ֤��
          public string FIANCE_SERIALNO
          {
              get { return  Getstring("FIANCE_SERIALNO"); }
              set { Setstring("FIANCE_SERIALNO",value); }
          }

          // �ͻ�����
          public String CUSTNAME
          {
              get { return  GetString("CUSTNAME"); }
              set { SetString("CUSTNAME",value); }
          }

          // ��Ƭ����
          public Int32 CARDVALUE
          {
              get { return  GetInt32("CARDVALUE"); }
              set { SetInt32("CARDVALUE",value); }
          }

          // �ܽ��
          public Int32 TOTALMONEY
          {
              get { return  GetInt32("TOTALMONEY"); }
              set { SetInt32("TOTALMONEY",value); }
          }

          // ��������
          public string BUYTIME
          {
              get { return  Getstring("BUYTIME"); }
              set { Setstring("BUYTIME",value); }
          }

          // ��������
          public string PAYTIME
          {
              get { return  Getstring("PAYTIME"); }
              set { Setstring("PAYTIME",value); }
          }

          // ����״̬
          public string PAYTAG
          {
              get { return  Getstring("PAYTAG"); }
              set { Setstring("PAYTAG",value); }
          }

     }
}


