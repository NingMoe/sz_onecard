using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceParameter
{
     // ���ɼ�¼�жϹ������ñ�
     public class TD_M_SUSPICIOUSRULETDO : DDOBase
     {
          public TD_M_SUSPICIOUSRULETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_SUSPICIOUSRULE";

               columns = new String[5][];
               columns[0] = new String[]{"RULENO", "string"};
               columns[1] = new String[]{"RULENAME", "String"};
               columns[2] = new String[]{"RULEEXP", "String"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "RULENO",
               };


               array = new String[5];
               hash.Add("RULENO", 0);
               hash.Add("RULENAME", 1);
               hash.Add("RULEEXP", 2);
               hash.Add("USETAG", 3);
               hash.Add("REMARK", 4);
          }

          // �������
          public string RULENO
          {
              get { return  Getstring("RULENO"); }
              set { Setstring("RULENO",value); }
          }

          // ��������
          public String RULENAME
          {
              get { return  GetString("RULENAME"); }
              set { SetString("RULENAME",value); }
          }

          // ������ʽ
          public String RULEEXP
          {
              get { return  GetString("RULEEXP"); }
              set { SetString("RULEEXP",value); }
          }

          // ��Ч��־
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // ��ע
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}


