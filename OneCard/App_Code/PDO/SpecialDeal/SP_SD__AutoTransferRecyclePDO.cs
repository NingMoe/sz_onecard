using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.SpecialDeal
{
    // 出租消费信息作废
    public class SP_SD_AutoTransferRecyclePDO : PDOBase
    {
        public SP_SD_AutoTransferRecyclePDO()
        {
        }

        protected override void Init()
        {
            InitBegin("SP_SD_AutoTransferRecycle", 7);

            AddField("@sessionID", "String", "32", "input");

            InitEnd();
        }


        // 会话ID
        public String sessionID
        {
            get { return GetString("sessionID"); }
            set { SetString("sessionID", value); }
        }

    }
}


