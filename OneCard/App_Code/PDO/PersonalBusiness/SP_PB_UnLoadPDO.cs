using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // Ȧ��
     public class SP_PB_UnLoadPDO : PDOBase
     {
          public SP_PB_UnLoadPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_UnLoad",11);

               AddField("@CARDNO", "string", "16", "input");
               AddField("@TRADETYPECODE", "string", "2", "input");
               AddField("@CARDMONEY", "Int32", "", "input");
               AddField("@OPERCARDNO", "string", "16", "input");
               AddField("@TERMNO", "string", "12", "input");
               AddField("@TRADEID", "string", "16", "output");

               InitEnd();
          }

          // ����
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // ҵ�����ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // �������
          public Int32 CARDMONEY
          {
              get { return  GetInt32("CARDMONEY"); }
              set { SetInt32("CARDMONEY",value); }
          }

          // ����Ա����
          public string OPERCARDNO
          {
              get { return  Getstring("OPERCARDNO"); }
              set { Setstring("OPERCARDNO",value); }
          }

          // �ն˺�
          public string TERMNO
          {
              get { return  Getstring("TERMNO"); }
              set { Setstring("TERMNO",value); }
          }

          // ���ؽ������к�
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }

     }
}


