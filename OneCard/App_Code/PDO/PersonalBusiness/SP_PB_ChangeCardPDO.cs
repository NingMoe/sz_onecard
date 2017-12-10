using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
     // ����
     public class SP_PB_ChangeCardPDO : PDOBase
     {
          public SP_PB_ChangeCardPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PB_ChangeCard",35);

               AddField("@ID", "string", "18", "input");
               AddField("@CUSTRECTYPECODE", "string", "2", "input");
               AddField("@CARDCOST", "Int32", "", "input");
               AddField("@NEWCARDNO", "string", "16", "input");
               AddField("@OLDCARDNO", "string", "16", "input");
               AddField("@ONLINECARDTRADENO", "string", "4", "input");
               AddField("@CHECKSTAFFNO", "string", "6", "input");
               AddField("@CHECKDEPARTNO", "string", "4", "input");
               AddField("@CHANGECODE", "string", "2", "input");
               AddField("@ASN", "string", "16", "input");
               AddField("@CARDTYPECODE", "string", "2", "input");
               AddField("@SELLCHANNELCODE", "string", "2", "input");
               AddField("@TRADETYPECODE", "string", "2", "input");
               AddField("@DEPOSIT", "Int32", "", "input");
               AddField("@SERSTARTTIME", "DateTime", "", "input");
               AddField("@SERVICEMONE", "Int32", "", "input");
               AddField("@CARDACCMONEY", "Int32", "", "input");
               AddField("@NEWSERSTAKETAG", "string", "1", "input");
               AddField("@SUPPLYREALMONEY", "Int32", "", "input");
               AddField("@TOTALSUPPLYMONEY", "Int32", "", "input");
               AddField("@OLDDEPOSIT", "Int32", "", "input");
               AddField("@SERSTAKETAG", "string", "1", "input");
               AddField("@PREMONEY", "Int32", "", "input");
               AddField("@NEXTMONEY", "Int32", "", "input");
               AddField("@CURRENTMONEY", "Int32", "", "input");
               AddField("@TERMNO", "string", "12", "input");
               AddField("@OPERCARDNO", "string", "16", "input");
               AddField("@CURRENTTIME", "DateTime", "", "output");
               AddField("@TRADEID", "string", "16", "output");
               AddField("@TRADEID2", "string", "16", "output");

               InitEnd();
          }

          // ��¼��ˮ��
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // �ֿ�����������
          public string CUSTRECTYPECODE
          {
              get { return  Getstring("CUSTRECTYPECODE"); }
              set { Setstring("CUSTRECTYPECODE",value); }
          }

          // �¿�����
          public Int32 CARDCOST
          {
              get { return  GetInt32("CARDCOST"); }
              set { SetInt32("CARDCOST",value); }
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

          // �����������
          public string ONLINECARDTRADENO
          {
              get { return  Getstring("ONLINECARDTRADENO"); }
              set { Setstring("ONLINECARDTRADENO",value); }
          }

          // ����Ա������
          public string CHECKSTAFFNO
          {
              get { return  Getstring("CHECKSTAFFNO"); }
              set { Setstring("CHECKSTAFFNO",value); }
          }

          // �������ű���
          public string CHECKDEPARTNO
          {
              get { return  Getstring("CHECKDEPARTNO"); }
              set { Setstring("CHECKDEPARTNO",value); }
          }

          // ��������
          public string CHANGECODE
          {
              get { return  Getstring("CHANGECODE"); }
              set { Setstring("CHANGECODE",value); }
          }

          // �¿�Ӧ�����к�
          public string ASN
          {
              get { return  Getstring("ASN"); }
              set { Setstring("ASN",value); }
          }

          // �����ͱ���
          public string CARDTYPECODE
          {
              get { return  Getstring("CARDTYPECODE"); }
              set { Setstring("CARDTYPECODE",value); }
          }

          // �ۿ���������
          public string SELLCHANNELCODE
          {
              get { return  Getstring("SELLCHANNELCODE"); }
              set { Setstring("SELLCHANNELCODE",value); }
          }

          // �������ͱ���
          public string TRADETYPECODE
          {
              get { return  Getstring("TRADETYPECODE"); }
              set { Setstring("TRADETYPECODE",value); }
          }

          // �¿�Ѻ��
          public Int32 DEPOSIT
          {
              get { return  GetInt32("DEPOSIT"); }
              set { SetInt32("DEPOSIT",value); }
          }

          // �¿�����ʼ����
          public DateTime SERSTARTTIME
          {
              get { return  GetDateTime("SERSTARTTIME"); }
              set { SetDateTime("SERSTARTTIME",value); }
          }

          // �¿�ʵ�տ������
          public Int32 SERVICEMONE
          {
              get { return  GetInt32("SERVICEMONE"); }
              set { SetInt32("SERVICEMONE",value); }
          }

          // �¿��������
          public Int32 CARDACCMONEY
          {
              get { return  GetInt32("CARDACCMONEY"); }
              set { SetInt32("CARDACCMONEY",value); }
          }

          // �¿��������ȡ��־
          public string NEWSERSTAKETAG
          {
              get { return  Getstring("NEWSERSTAKETAG"); }
              set { Setstring("NEWSERSTAKETAG",value); }
          }

          // �ɿ����
          public Int32 SUPPLYREALMONEY
          {
              get { return  GetInt32("SUPPLYREALMONEY"); }
              set { SetInt32("SUPPLYREALMONEY",value); }
          }

          // �ܳ�ֵ���
          public Int32 TOTALSUPPLYMONEY
          {
              get { return  GetInt32("TOTALSUPPLYMONEY"); }
              set { SetInt32("TOTALSUPPLYMONEY",value); }
          }

          // �ɿ�ʣ��Ѻ��
          public Int32 OLDDEPOSIT
          {
              get { return  GetInt32("OLDDEPOSIT"); }
              set { SetInt32("OLDDEPOSIT",value); }
          }

          // �ɿ��������ȡ��־
          public string SERSTAKETAG
          {
              get { return  Getstring("SERSTAKETAG"); }
              set { Setstring("SERSTAKETAG",value); }
          }

          // �¿�����ǰ���
          public Int32 PREMONEY
          {
              get { return  GetInt32("PREMONEY"); }
              set { SetInt32("PREMONEY",value); }
          }

          // �¿����������
          public Int32 NEXTMONEY
          {
              get { return  GetInt32("NEXTMONEY"); }
              set { SetInt32("NEXTMONEY",value); }
          }

          // �¿��������
          public Int32 CURRENTMONEY
          {
              get { return  GetInt32("CURRENTMONEY"); }
              set { SetInt32("CURRENTMONEY",value); }
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

          // ����ϵͳʱ��
          public DateTime CURRENTTIME
          {
              get { return  GetDateTime("CURRENTTIME"); }
              set { SetDateTime("CURRENTTIME",value); }
          }

          // ���ؽ������к�
          public string TRADEID
          {
              get { return  Getstring("TRADEID"); }
              set { Setstring("TRADEID",value); }
          }
          
          // ���ؽ������к�
          public string TRADEID2
          {
              get { return  Getstring("TRADEID2"); }
              set { Setstring("TRADEID2",value); }
          }

     }
}


