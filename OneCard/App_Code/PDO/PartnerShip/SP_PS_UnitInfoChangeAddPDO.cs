using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
     // 单位信息增加
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


          // 单位编码
          public string corpNo
          {
              get { return  Getstring("corpNo"); }
              set { Setstring("corpNo",value); }
          }

          // 单位名称
          public String corp
          {
              get { return  GetString("corp"); }
              set { SetString("corp",value); }
          }

          // 行业编码
          public string callingNo
          {
              get { return  Getstring("callingNo"); }
              set { Setstring("callingNo",value); }
          }

          // 单位地址
          public String corpAdd
          {
              get { return  GetString("corpAdd"); }
              set { SetString("corpAdd",value); }
          }

          // 单位说明
          public String corpMark
          {
              get { return  GetString("corpMark"); }
              set { SetString("corpMark",value); }
          }

          // 联系人
          public String linkMan
          {
              get { return  GetString("linkMan"); }
              set { SetString("linkMan",value); }
          }

          // 联系电话
          public String corpPhone
          {
              get { return  GetString("corpPhone"); }
              set { SetString("corpPhone",value); }
          }

          // 备注
          public String remark
          {
              get { return  GetString("remark"); }
              set { SetString("remark",value); }
          }

          // 地区编码
          public String regionCode
          {
              get { return GetString("regionCode"); }
              set { SetString("regionCode", value); }
          }

          //单位证件类型
          public string companyPaperType
          {
              get { return Getstring("companyPaperType"); }
              set { Setstring("companyPaperType", value); }
          }
          //单位证件号码
          public string companyPaperNo
          {
              get { return Getstring("companyPaperNo"); }
              set { Setstring("companyPaperNo", value); }
          }


        //单位法人姓名
        public string corporation
        {
            get { return Getstring("corporation"); }
            set { Setstring("corporation", value); }
        }
        //单位证件有效期
        public string companyEndTime
          {
              get { return Getstring("companyEndTime"); }
              set { Setstring("companyEndTime", value); }
          }
          //联系人证件类型
          public string paperType
          {
              get { return Getstring("paperType"); }
              set { Setstring("paperType", value); }
          }
          //联系人证件号码
          public string paperNo
          {
              get { return Getstring("paperNo"); }
              set { Setstring("paperNo", value); }
          }
          //联系人证件有效期限
          public string paperEndDate
          {
              get { return Getstring("paperEndDate"); }
              set { Setstring("paperEndDate", value); }
          }
          //注册资金
          public Int32 registeredCapital
          {
              get { return GetInt32("registeredCapital"); }
              set { SetInt32("registeredCapital", value); }
          }
          ////安全值
          //public Int32 securityValue
          //{
          //    get { return GetInt32("securityValue"); }
          //    set { SetInt32("securityValue", value); }
          //}
         //经营范围
          public string managearea
          {
              get { return Getstring("managearea"); }
              set { Setstring("managearea", value); }
          }
         //法人证件类型
          public string companymanagerpapertype
          {
              get { return Getstring("companymanagerpapertype"); }
              set { Setstring("companymanagerpapertype", value); }
          }
         //法人证件号码
          public string companymanagerno
          {
              get { return Getstring("companymanagerno"); }
              set { Setstring("companymanagerno", value); }
          }
         //应用行业
          public string appcallingno
          {
              get { return Getstring("appcallingno"); }
              set { Setstring("appcallingno", value); }
          }

          // 单位地址加密
          public String corpAddAes
          {
              get { return GetString("corpAddAes"); }
              set { SetString("corpAddAes", value); }
          }
          // 联系人加密
          public String linkManAes
          {
              get { return GetString("linkManAes"); }
              set { SetString("linkManAes", value); }
          }
          // 联系电话加密
          public String corpPhoneAes
          {
              get { return GetString("corpPhoneAes"); }
              set { SetString("corpPhoneAes", value); }
          }
          //单位证件号码加密
          public string companyPaperNoAes
          {
              get { return Getstring("companyPaperNoAes"); }
              set { Setstring("companyPaperNoAes", value); }
          }
          //联系人证件号码加密
          public string paperNoAes
          {
              get { return Getstring("paperNoAes"); }
              set { Setstring("paperNoAes", value); }
          }
          //法人证件号码加密
          public string companymanagernoAes
          {
              get { return Getstring("companymanagernoAes"); }
              set { Setstring("companymanagernoAes", value); }
          }
     }
}


