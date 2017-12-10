using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PartnerShip
{
    //行业权值表
    public class TD_M_CALLINGRIGHTVALUETDO : DDOBase
    {
        public TD_M_CALLINGRIGHTVALUETDO()
        {

        }
        protected override void Init()
        {
            tableName = "TD_M_CALLINGRIGHTVALUE";

            columns = new String[5][];
            columns[0] = new String[] { "CALLINGNO", "string" };
            columns[1] = new String[] { "CALLINGRIGHTVALUE", "FLOAT" };
            columns[2] = new String[] { "UPDATESTAFFNO", "string" };
            columns[3] = new String[] { "UPDATETIME", "DateTime" };
            columns[4] = new String[] { "REMARK", "String" };

            columnKeys = new String[]{
                   "CALLINGNO",
               };


            array = new String[5];
            hash.Add("CALLINGNO", 0);
            hash.Add("CALLINGRIGHTVALUE", 1);
            hash.Add("UPDATESTAFFNO", 2);
            hash.Add("UPDATETIME", 3);
            hash.Add("CREATETIME", 4);
            hash.Add("REMARK", 5);
            
        }

        // 行业编码
        public string CALLINGNO
        {
            get { return Getstring("CALLINGNO"); }
            set { Setstring("CALLINGNO", value); }
        }
        // 行业权值
        public Decimal CALLINGRIGHTVALUE
        {
            get { return GetDecimal("CALLINGRIGHTVALUE"); }
            set { SetDecimal("CALLINGRIGHTVALUE", value); }
        }
        // 更新员工
        public string UPDATESTAFFNO
        {
            get { return Getstring("UPDATESTAFFNO"); }
            set { Setstring("UPDATESTAFFNO", value); }
        }

        // 更新时间
        public DateTime UPDATETIME
        {
            get { return GetDateTime("UPDATETIME"); }
            set { SetDateTime("UPDATETIME", value); }
        }

        // 备注
        public String REMARK
        {
            get { return GetString("REMARK"); }
            set { SetString("REMARK", value); }
        }
    }
}