using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.TaxiService
{
     // ˾����Ϣ¼��
     public class SP_Bus_InputPDO : PDOBase
     {
          public SP_Bus_InputPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_Bus_Input",12);

               AddField("@CALLINGSTAFFNO", "string", "6", "input");
               AddField("@CALLINGNO", "string", "2", "input");
               AddField("@CORPNO", "string", "4", "input");
               AddField("@DEPARTNO", "string", "4", "input");
               AddField("@BANKCODE", "string", "4", "input");
               AddField("@BANKACCNO", "String", "20", "input");
               AddField("@SERMANAGERCODE", "string", "6", "input");

               InitEnd();
          }

          // ˾������
          public string CALLINGSTAFFNO
          {
              get { return  Getstring("CALLINGSTAFFNO"); }
              set { Setstring("CALLINGSTAFFNO",value); }
          }

          // ��ҵ����
          public string CALLINGNO
          {
              get { return  Getstring("CALLINGNO"); }
              set { Setstring("CALLINGNO",value); }
          }

          // ��λ����
          public string CORPNO
          {
              get { return  Getstring("CORPNO"); }
              set { Setstring("CORPNO",value); }
          }

          // ���ű���
          public string DEPARTNO
          {
              get { return  Getstring("DEPARTNO"); }
              set { Setstring("DEPARTNO",value); }
          }

          // �������б���
          public string BANKCODE
          {
              get { return  Getstring("BANKCODE"); }
              set { Setstring("BANKCODE",value); }
          }

          // �����ʺ�
          public String BANKACCNO
          {
              get { return  GetString("BANKACCNO"); }
              set { SetString("BANKACCNO",value); }
          }

          // �̻��������
          public string SERMANAGERCODE
          {
              get { return  Getstring("SERMANAGERCODE"); }
              set { Setstring("SERMANAGERCODE",value); }
          }

     }
}


