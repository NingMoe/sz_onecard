using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
    // 卡账户有效性检验
    public class SP_PB_SimNoInputPDO : PDOBase
    {
        public SP_PB_SimNoInputPDO()
        {
        }

        protected override void Init()
        {
            InitBegin("SP_PB_SimNoInput", 6);
            AddField("@sessionId", "String", "32", "input");
            InitEnd();
        }

        // 记录流水号
        public string SESSIONID
        {
            get { return Getstring("sessionId"); }
            set { Setstring("sessionId", value); }
        }
    }
}


