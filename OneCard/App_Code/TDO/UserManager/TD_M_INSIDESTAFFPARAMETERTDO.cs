using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.UserManager
{
     // �ڲ�Ա���������ñ�
     public class TD_M_INSIDESTAFFPARAMETERTDO : DDOBase
     {
          public TD_M_INSIDESTAFFPARAMETERTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_INSIDESTAFFPARAMETER";

               columns = new String[7][];
               columns[0] = new String[]{"STAFFNO", "string"};
               columns[1] = new String[]{"CARDCOSTSTAT", "string"};
               columns[2] = new String[]{"CARDCOST", "Int32"};
               columns[3] = new String[]{"SUPPLEMONEY", "Int32"};
               columns[4] = new String[]{"UPDATESTAFFNO", "string"};
               columns[5] = new String[]{"UPDATETIME", "DateTime"};
               columns[6] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "STAFFNO",
               };


               array = new String[7];
               hash.Add("STAFFNO", 0);
               hash.Add("CARDCOSTSTAT", 1);
               hash.Add("CARDCOST", 2);
               hash.Add("SUPPLEMONEY", 3);
               hash.Add("UPDATESTAFFNO", 4);
               hash.Add("UPDATETIME", 5);
               hash.Add("REMARK", 6);
          }

          // Ա������
          public string STAFFNO
          {
              get { return  Getstring("STAFFNO"); }
              set { Setstring("STAFFNO",value); }
          }

          // ��������
          public string CARDCOSTSTAT
          {
              get { return  Getstring("CARDCOSTSTAT"); }
              set { Setstring("CARDCOSTSTAT",value); }
          }

          // ����Ĭ��ֵ
          public Int32 CARDCOST
          {
              get { return  GetInt32("CARDCOST"); }
              set { SetInt32("CARDCOST",value); }
          }

          // ��ֵĬ��ֵ
          public Int32 SUPPLEMONEY
          {
              get { return  GetInt32("SUPPLEMONEY"); }
              set { SetInt32("SUPPLEMONEY",value); }
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


