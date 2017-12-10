using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.UserCard
{
    // 卡出库
    public class SP_UC_StockOut_COMMITPDO : PDOBase
    {
        public SP_UC_StockOut_COMMITPDO()
        {
        }

        protected override void Init()
        {
            InitBegin("SP_UC_StockOut_COMMIT", 11);

            AddField("@fromCardNo", "String", "16", "input");
            AddField("@toCardNo", "String", "16", "input");
            AddField("@assignedStaff", "string", "6", "input");
            AddField("@serviceCycle", "string", "2", "input");
            AddField("@serviceFee", "Int32", "", "input");
            AddField("@retValMode", "string", "1", "input");

            //售卡方式
            AddField("@saleType", "string", "2", "input");
            InitEnd();
        }

        //add by jiangbb 2012-05-10
        //售卡方式
        public String saleType
        {
            get { return Getstring("saleType"); }
            set { SetString("saleType", value); }
        }

        // 开始卡号
        public String fromCardNo
        {
            get { return GetString("fromCardNo"); }
            set { SetString("fromCardNo", value); }
        }

        // 结束卡号
        public String toCardNo
        {
            get { return GetString("toCardNo"); }
            set { SetString("toCardNo", value); }
        }

        // 领用员工
        public string assignedStaff
        {
            get { return Getstring("assignedStaff"); }
            set { Setstring("assignedStaff", value); }
        }

        // 服务周期
        public string serviceCycle
        {
            get { return Getstring("serviceCycle"); }
            set { Setstring("serviceCycle", value); }
        }

        // 每期服务费
        public Int32 serviceFee
        {
            get { return GetInt32("serviceFee"); }
            set { SetInt32("serviceFee", value); }
        }

        // 退值模式
        public string retValMode
        {
            get { return Getstring("retValMode"); }
            set { Setstring("retValMode", value); }
        }
    }
}


