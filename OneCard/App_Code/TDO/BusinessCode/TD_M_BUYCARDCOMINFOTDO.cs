using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BusinessCode
{
    public class TD_M_BUYCARDCOMINFOTDO : DDOBase
    {
        public TD_M_BUYCARDCOMINFOTDO()
        {
        }

        protected override void Init()
        {
            tableName = "TD_M_BUYCARDCOMINFO";

            columns = new String[5][];
            columns[0] = new String[] { "COMPANYNO", "string" };
            columns[1] = new String[] { "COMPANYNAME", "string" };
            columns[2] = new String[] { "COMPANYPAPERTYPE", "string" };
            columns[3] = new String[] { "COMPANYPAPERNO", "string" };
            columns[4] = new String[] { "REMARK", "string" };

            columnKeys = new String[]{
                   "COMPANYNO",
               };


            array = new String[5];
            hash.Add("COMPANYNO", 0);
            hash.Add("COMPANYNAME", 1);
            hash.Add("COMPANYPAPERTYPE", 2);
            hash.Add("COMPANYPAPERNO", 3);
            hash.Add("REMARK", 4);
        }

        // 单位编码
        public string COMPANYNO
        {
            get { return Getstring("COMPANYNO"); }
            set { Setstring("COMPANYNO", value); }
        }

        // 单位名称
        public string COMPANYNAME
        {
            get { return Getstring("COMPANYNAME"); }
            set { Setstring("COMPANYNAME", value); }
        }

        // 单位证件类型
        public string COMPANYPAPERTYPE
        {
            get { return Getstring("COMPANYPAPERTYPE"); }
            set { Setstring("COMPANYPAPERTYPE", value); }
        }

        // 单位证件号码
        public string COMPANYPAPERNO
        {
            get { return Getstring("COMPANYPAPERNO"); }
            set { Setstring("COMPANYPAPERNO", value); }
        }

        // 备注
        public string REMARK
        {
            get { return Getstring("REMARK"); }
            set { Setstring("REMARK", value); }
        }

    }
}