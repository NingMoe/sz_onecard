using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.Warn
{
    public class SP_WA_TaskCreatePDO : PDOBase
    {
        public SP_WA_TaskCreatePDO()
        {
        }

        protected override void Init()
        {
            InitBegin("SP_WA_TaskCreate", 2 + 5);

            AddField("@beginDate", "String", "8", "input");
            AddField("@endDate", "string", "8", "input");

            InitEnd();
        }

        public String beginDate
        {
            get { return GetString("beginDate"); }
            set { SetString("beginDate", value); }
        }

        public String endDate
        {
            get { return GetString("endDate"); }
            set { SetString("endDate", value); }
        }
    }
}


