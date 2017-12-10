using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.Financial
{
     // 团购标记
    public class SP_FI_GroupBuyPDO : PDOBase
    {
        public SP_FI_GroupBuyPDO()
        {
        }

        protected override void Init()
        {
            InitBegin("SP_FI_GroupBuy", 14);

            AddField("@msgTradeIds", "String", "1024", "input");
            AddField("@msgGroupCode", "String", "1024", "input");
            AddField("@msgShopNo", "String", "1024", "input");
            AddField("@msgRemark", "String", "1024", "input");
            InitEnd();
        }

        // 业务流水号
        public String msgTradeIds
        {
            get { return GetString("msgTradeIds"); }
            set { SetString("msgTradeIds", value); }
        }

        // 团购劵
        public String msgGroupCode
        {
            get { return GetString("msgGroupCode"); }
            set { SetString("msgGroupCode", value); }
        }

        // 商家编号
        public String msgShopNo
        {
            get { return GetString("msgShopNo"); }
            set { SetString("msgShopNo", value); }
        }

        // 备注
        public String msgRemark
        {
            get { return GetString("msgRemark"); }
            set { SetString("msgRemark", value); }
        }

       
    }
}


