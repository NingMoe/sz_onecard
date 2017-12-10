using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // ����Ȧ��
     public class SP_PB_SpeloadPDO : PDOBase
     {
          public SP_PB_SpeloadPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_Speload",13);

               AddField("@TRADEID", "string", "16", "input");
               AddField("@CARDNO", "string", "16", "input");
               AddField("@TRADETYPECODE", "string", "2", "input");
               AddField("@CARDTRADENO", "string", "4", "input");
               AddField("@CURRENTMONEY", "Int32", "", "input");
               AddField("@CARDMONEY", "Int32", "", "input");
               AddField("@TERMNO", "string", "12", "input");
               AddField("@OPERCARDNO", "string", "16", "input");

               InitEnd();
          }

          // �������к�
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

          // ����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // �������ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // ���������
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // �������
          public Int32 CURRENTMONEY
          {
              get { return  GetInt32("CURRENTMONEY"); }
              set { SetInt32("CURRENTMONEY",value); }
          }

          // �������
          public Int32 CARDMONEY
          {
              get { return  GetInt32("CARDMONEY"); }
              set { SetInt32("CARDMONEY",value); }
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

     }
}


