using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // ��������
     public class SP_PB_ChangeCardRollbackPDO : PDOBase
     {
          public SP_PB_ChangeCardRollbackPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_ChangeCardRollback",19);

               AddField("@ID", "string", "18", "input");
               AddField("@OLDCARDNO", "string", "16", "input");
               AddField("@NEWCARDNO", "string", "16", "input");
               AddField("@TRADETYPECODE", "string", "2", "input");
               AddField("@CANCELTRADEID", "string", "16", "input");
               AddField("@REASONCODE", "string", "2", "input");
               AddField("@CARDTRADENO", "string", "4", "input");
               AddField("@TRADEPROCFEE", "Int32", "", "input");
               AddField("@OTHERFEE", "Int32", "", "input");
               AddField("@CARDSTATE", "string", "2", "input");
               AddField("@SERSTAKETAG", "string", "1", "input");
               AddField("@TERMNO", "string", "12", "input");
               AddField("@OPERCARDNO", "string", "16", "input");
               AddField("@TRADEID", "string", "16", "output");

               InitEnd();
          }

          // ��¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // �ɿ�����
          public string OLDCARDNO
          {
              get { return  Getstring("OLDCARDNO"); }
              set { Setstring("OLDCARDNO",value); }
          }

          // �¿�����
          public string NEWCARDNO
          {
              get { return  Getstring("NEWCARDNO"); }
              set { Setstring("NEWCARDNO",value); }
          }

          // תֵҵ�����ͱ���
          public string TRADETYPECODE
          {
              get { return Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE", value); }
          }

          // ����ҵ����ˮ��
          public string CANCELTRADEID
          {
              get { return  Getstring("CANCELTRADEID"); }
              set { Setstring("CANCELTRADEID",value); }
          }

          // �������ͱ���
          public string REASONCODE
          {
              get { return  Getstring("REASONCODE"); }
              set { Setstring("REASONCODE",value); }
          }

          // �����������
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // ������
          public Int32 TRADEPROCFEE
          {
              get { return  GetInt32("TRADEPROCFEE"); }
              set { SetInt32("TRADEPROCFEE",value); }
          }

          // ��������
          public Int32 OTHERFEE
          {
              get { return  GetInt32("OTHERFEE"); }
              set { SetInt32("OTHERFEE",value); }
          }

          // ��״̬
          public string CARDSTATE
          {
              get { return  Getstring("CARDSTATE"); }
              set { Setstring("CARDSTATE",value); }
          }

          // �������ȡ��־
          public string SERSTAKETAG
          {
              get { return  Getstring("SERSTAKETAG"); }
              set { Setstring("SERSTAKETAG",value); }
          }

          // �ն˺�
          public string TERMNO
          {
              get { return  Getstring("TERMNO"); }
              set { Setstring("TERMNO",value); }
          }

          // ����Ա����
          public string OPERCARDNO
          {
              get { return  Getstring("OPERCARDNO"); }
              set { Setstring("OPERCARDNO",value); }
          }

          // ���ؽ������к�
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

     }
}


