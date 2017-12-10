using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // ��λ��Ϣ����
     public class SP_PS_UnitInfoChangeAddPDO : PDOBase
     {
          public SP_PS_UnitInfoChangeAddPDO()
          {
          }

          protected override void Init()
          {
                InitBegin("SP_PS_UnitInfoChangeAdd",28);

               AddField("@corpNo", "string", "4", "input");
               AddField("@corp", "String", "100", "input");
               AddField("@callingNo", "string", "2", "input");
               AddField("@corpAdd", "String", "50", "input");
               AddField("@corpMark", "String", "50", "input");
               AddField("@linkMan", "String", "10", "input");
               AddField("@corpPhone", "String", "40", "input");
               AddField("@remark", "String", "100", "input");               
               AddField("@regionCode", "String", "1", "input");

               AddField("@companyPaperType", "String", "2", "input");
               AddField("@companyPaperNo", "String", "30", "input");
            AddField("@corporation", "String", "100", "input");
            AddField("@companyEndTime", "String", "8", "input");
               AddField("@paperType", "String", "2", "input");
               AddField("@paperNo", "String", "20", "input");
               AddField("@paperEndDate", "String", "8", "input");
               AddField("@registeredCapital", "Int32", "", "input");
               //AddField("@securityValue", "Int32", "", "input");

               AddField("@companymanagerpapertype", "String", "2", "input");
               AddField("@companymanagerno", "String", "30", "input");
               AddField("@appcallingno", "String", "2", "input");
               AddField("@managearea", "String", "50", "input");

               AddField("@corpAddAes", "String", "600", "input");
               AddField("@linkManAes", "String", "200", "input");
               AddField("@corpPhoneAes", "String", "200", "input");
               AddField("@companyPaperNoAes", "String", "200", "input");
               AddField("@paperNoAes", "String", "200", "input");
               AddField("@companymanagernoAes", "String", "200", "input");

               InitEnd();
          }


          // ��λ����
          public string corpNo
          {
              get { return  Getstring("corpNo"); }
              set { Setstring("corpNo",value); }
          }

          // ��λ����
          public String corp
          {
              get { return  GetString("corp"); }
              set { SetString("corp",value); }
          }

          // ��ҵ����
          public string callingNo
          {
              get { return  Getstring("callingNo"); }
              set { Setstring("callingNo",value); }
          }

          // ��λ��ַ
          public String corpAdd
          {
              get { return  GetString("corpAdd"); }
              set { SetString("corpAdd",value); }
          }

          // ��λ˵��
          public String corpMark
          {
              get { return  GetString("corpMark"); }
              set { SetString("corpMark",value); }
          }

          // ��ϵ��
          public String linkMan
          {
              get { return  GetString("linkMan"); }
              set { SetString("linkMan",value); }
          }

          // ��ϵ�绰
          public String corpPhone
          {
              get { return  GetString("corpPhone"); }
              set { SetString("corpPhone",value); }
          }

          // ��ע
          public String remark
          {
              get { return  GetString("remark"); }
              set { SetString("remark",value); }
          }

          // ��������
          public String regionCode
          {
              get { return GetString("regionCode"); }
              set { SetString("regionCode", value); }
          }

          //��λ֤������
          public string companyPaperType
          {
              get { return Getstring("companyPaperType"); }
              set { Setstring("companyPaperType", value); }
          }
          //��λ֤������
          public string companyPaperNo
          {
              get { return Getstring("companyPaperNo"); }
              set { Setstring("companyPaperNo", value); }
          }


        //��λ��������
        public string corporation
        {
            get { return Getstring("corporation"); }
            set { Setstring("corporation", value); }
        }
        //��λ֤����Ч��
        public string companyEndTime
          {
              get { return Getstring("companyEndTime"); }
              set { Setstring("companyEndTime", value); }
          }
          //��ϵ��֤������
          public string paperType
          {
              get { return Getstring("paperType"); }
              set { Setstring("paperType", value); }
          }
          //��ϵ��֤������
          public string paperNo
          {
              get { return Getstring("paperNo"); }
              set { Setstring("paperNo", value); }
          }
          //��ϵ��֤����Ч����
          public string paperEndDate
          {
              get { return Getstring("paperEndDate"); }
              set { Setstring("paperEndDate", value); }
          }
          //ע���ʽ�
          public Int32 registeredCapital
          {
              get { return GetInt32("registeredCapital"); }
              set { SetInt32("registeredCapital", value); }
          }
          ////��ȫֵ
          //public Int32 securityValue
          //{
          //    get { return GetInt32("securityValue"); }
          //    set { SetInt32("securityValue", value); }
          //}
         //��Ӫ��Χ
          public string managearea
          {
              get { return Getstring("managearea"); }
              set { Setstring("managearea", value); }
          }
         //����֤������
          public string companymanagerpapertype
          {
              get { return Getstring("companymanagerpapertype"); }
              set { Setstring("companymanagerpapertype", value); }
          }
         //����֤������
          public string companymanagerno
          {
              get { return Getstring("companymanagerno"); }
              set { Setstring("companymanagerno", value); }
          }
         //Ӧ����ҵ
          public string appcallingno
          {
              get { return Getstring("appcallingno"); }
              set { Setstring("appcallingno", value); }
          }

          // ��λ��ַ����
          public String corpAddAes
          {
              get { return GetString("corpAddAes"); }
              set { SetString("corpAddAes", value); }
          }
          // ��ϵ�˼���
          public String linkManAes
          {
              get { return GetString("linkManAes"); }
              set { SetString("linkManAes", value); }
          }
          // ��ϵ�绰����
          public String corpPhoneAes
          {
              get { return GetString("corpPhoneAes"); }
              set { SetString("corpPhoneAes", value); }
          }
          //��λ֤���������
          public string companyPaperNoAes
          {
              get { return Getstring("companyPaperNoAes"); }
              set { Setstring("companyPaperNoAes", value); }
          }
          //��ϵ��֤���������
          public string paperNoAes
          {
              get { return Getstring("paperNoAes"); }
              set { Setstring("paperNoAes", value); }
          }
          //����֤���������
          public string companymanagernoAes
          {
              get { return Getstring("companymanagernoAes"); }
              set { Setstring("companymanagernoAes", value); }
          }
     }
}


