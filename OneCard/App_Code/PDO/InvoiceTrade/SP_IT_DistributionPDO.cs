using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;


namespace PDO.InvoiceTrade
{
    // 分配
    public class SP_IT_DistributionPDO : PDOBase
    {
        public SP_IT_DistributionPDO()
        {
        }

        protected override void Init()
        {
            InitBegin("SP_IT_Distribution", 10);

            AddField("@beginNo", "string", "8", "input");
            AddField("@endNo", "string", "8", "input");
            AddField("@allotDept", "string", "4", "input");
            AddField("@allotStaff", "string", "6", "input");
            AddField("@volumeno", "string", "12", "input");

            InitEnd();
        }

        // 起始卡号
        public string beginNo
        {
            get { return Getstring("beginNo"); }
            set { Setstring("beginNo", value); }
        }

        // 终止卡号
        public string endNo
        {
            get { return Getstring("endNo"); }
            set { Setstring("endNo", value); }
        }

        // 领用部门
        public string allotDept
        {
            get { return Getstring("allotDept"); }
            set { Setstring("allotDept", value); }
        }

        // 领用人
        public string allotStaff
        {
            get { return Getstring("allotStaff"); }
            set { Setstring("allotStaff", value); }
        }

        // 发票代码
        public string volumeno
        {
            get { return Getstring("volumeno"); }
            set { Setstring("volumeno", value); }
        }

    }
}


