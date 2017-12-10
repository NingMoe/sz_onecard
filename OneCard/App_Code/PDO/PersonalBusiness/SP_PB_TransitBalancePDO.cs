using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // תֵ
     public class SP_PB_TransitBalancePDO : PDOBase
     {
          public SP_PB_TransitBalancePDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_TransitBalance",20);

               AddField("@SESSIONID", "String", "32", "input");
               AddField("@NEWCARDNO", "string", "16", "input");
               AddField("@OLDCARDNO", "string", "16", "input");
               AddField("@TRADETYPECODE", "string", "2", "input");
               AddField("@NEWCARDACCMONEY", "Int32", "", "input");
               AddField("@CURRENTMONEY", "Int32", "", "input");
               AddField("@OLDCARDACCMONEY", "Int32", "", "input");
               AddField("@PREMONEY", "Int32", "", "input");
               AddField("@ASN", "string", "16", "input");
               AddField("@CARDTRADENO", "string", "4", "input");
               AddField("@CARDTYPECODE", "string", "2", "input");
               AddField("@CHANGERECORD", "string", "1", "input");
               AddField("@TERMNO", "string", "12", "input");
               AddField("@OPERCARDNO", "string", "16", "input");
               AddField("@TRADEID", "string", "16", "output");

               InitEnd();
          }

          // �ỰID
          public String SESSIONID
          {
              get { return  GetString("SESSIONID"); }
              set { SetString("SESSIONID",value); }
          }

          // �¿�����
          public string NEWCARDNO
          {
              get { return  Getstring("NEWCARDNO"); }
              set { Setstring("NEWCARDNO",value); }
          }

          // �ɿ�����
          public string OLDCARDNO
          {
              get { return  Getstring("OLDCARDNO"); }
              set { Setstring("OLDCARDNO",value); }
          }
          
          // ��������
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // �¿��ʻ����
          public Int32 NEWCARDACCMONEY
          {
              get { return  GetInt32("NEWCARDACCMONEY"); }
              set { SetInt32("NEWCARDACCMONEY",value); }
          }

          // תֵ���
          public Int32 CURRENTMONEY
          {
              get { return  GetInt32("CURRENTMONEY"); }
              set { SetInt32("CURRENTMONEY",value); }
          }

          // �ɿ��ʻ����
          public Int32 OLDCARDACCMONEY
          {
              get { return  GetInt32("OLDCARDACCMONEY"); }
              set { SetInt32("OLDCARDACCMONEY",value); }
          }

          // �¿��������
          public Int32 PREMONEY
          {
              get { return  GetInt32("PREMONEY"); }
              set { SetInt32("PREMONEY",value); }
          }

          // �¿�Ӧ�����к�
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // �����������
          public string CARDTRADENO
          {
              get { return  Getstring("CARDTRADENO"); }
              set { Setstring("CARDTRADENO",value); }
          }

          // �¿�����
          public string CARDTYPECODE
          {
              get { return  Getstring("CARDTYPECODE"); }
              set { Setstring("CARDTYPECODE",value); }
          }

          // ��ǰתֵ��־
          public string CHANGERECORD
          {
              get { return  Getstring("CHANGERECORD"); }
              set { Setstring("CHANGERECORD",value); }
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


