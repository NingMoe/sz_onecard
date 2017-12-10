using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.InvoiceTrade
{
     // ���ſ��������ñ�
     public class TD_M_SZBANKTDO : DDOBase
     {
          public TD_M_SZBANKTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_SZBANK";

               columns = new String[9][];
               columns[0] = new String[]{"BANKNAME", "String"};
               columns[1] = new String[]{"BANKCODE", "String"};
               columns[2] = new String[]{"PayeeName", "String"};
               columns[3] = new String[]{"IsDefault", "String"};
               columns[4] = new String[]{"USETAG", "String"};
               columns[5] = new String[]{"UPDATEDEPARTNO", "String"};
               columns[6] = new String[]{"UPDATESTAFFNO", "String"};
               columns[7] = new String[]{"UPDATETIME", "DateTime"};
               columns[8] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "DEPARTNO",
               };


               array = new String[9];
               hash.Add("BANKNAME", 0);
               hash.Add("BANKCODE", 1);
               hash.Add("PayeeName", 2);
               hash.Add("IsDefault", 3);
               hash.Add("USETAG", 4);
               hash.Add("UPDATEDEPARTNO", 5);
               hash.Add("UPDATESTAFFNO", 6);
               hash.Add("UPDATETIME", 7);
               hash.Add("REMARK", 8);
          }

          // ������������
          public String BANKNAME
          {
              get { return  GetString("BANKNAME"); }
              set { SetString("BANKNAME",value); }
          }

          // �����ʺ�
          public String BANKCODE
          {
              get { return  GetString("BANKCODE"); }
              set { SetString("BANKCODE",value); }
          }

          // �տ����
          public String PayeeName
          {
              get { return  GetString("PayeeName"); }
              set { SetString("PayeeName",value); }
          }

          // ��ΪĬ��ֵ
          public String IsDefault
          {
              get { return  GetString("IsDefault"); }
              set { SetString("IsDefault",value); }
          }

          // ��Ч��ʶ
          public String USETAG
          {
              get { return  GetString("USETAG"); }
              set { SetString("USETAG",value); }
          }

          // ���²���
          public String UPDATEDEPARTNO
          {
              get { return  GetString("UPDATEDEPARTNO"); }
              set { SetString("UPDATEDEPARTNO",value); }
          }

          // ����Ա��
          public String UPDATESTAFFNO
          {
              get { return  GetString("UPDATESTAFFNO"); }
              set { SetString("UPDATESTAFFNO",value); }
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


