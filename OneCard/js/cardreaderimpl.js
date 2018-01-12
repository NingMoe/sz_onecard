

document.body.insertAdjacentHTML("beforeEnd", " \
    <object id=\"SX_CARDOCX1\" classid=\"clsid:0362744E-0794-4020-B5B0-355ED58A736D\" width=\"0\" height=\"0\"> \
    </object>");



function readLogonTestCardNo(ctrlId) {
    var txtOperCardNo = document.getElementById(ctrlId);
    if (txtOperCardNo.value != "") return true;

    var errRet = SX_CARDOCX1.ReadOperCardNo();
    if (errRet != 0) {
        alert('ErrInfo:' + SX_CARDOCX1.ErrInfo + ', ErrCode:' + errRet);
        return false;
    }

    txtOperCardNo.value = SX_CARDOCX1.OperCardNo;
    return true;
}

function readLogonCardNo(ctrlId) {
    var txtOperCardNo = document.getElementById(ctrlId);

    var errRet = SX_CARDOCX1.ReadOperCardNo();
    if (errRet != 0) {
        alert('ErrInfo:' + SX_CARDOCX1.ErrInfo + ', ErrCode:' + errRet);
        return false;
    }

    txtOperCardNo.value = SX_CARDOCX1.OperCardNo;
    return true;
}

function CardRecord(tradeNo, tradeMoney, tradeType, tradeTerm, tradeDate, tradeTime) {
    this.tradeNo = tradeNo;
    this.tradeMoney = tradeMoney;
    this.tradeType = tradeType;
    this.tradeTerm = tradeTerm;
    this.tradeDate = tradeDate;
    this.tradeTime = tradeTime;
}

function CardInfo(cardNo, appType, appVersion, appSn,
    appStartDate, appEndDate, FCI, cardType, tradeNo, balance, staffTag, wallet2) {
    this.cardNo = cardNo;
    this.appType = appType;
    this.appVersion = appVersion;
    this.appSn = appSn;
    this.appStartDate = appStartDate;
    this.appEndDate = appEndDate;
    this.FCI = FCI;
    this.cardType = cardType;
    this.tradeNo = tradeNo;
    this.balance = balance;
    this.staffTag = staffTag;

    this.wallet2 = wallet2;
}

function DriverCardInfo(driverBaseInfo, driverSpecialInfo, driverBlackInfo) {
    this.baseInfo = driverBaseInfo;
    this.specialInfo = driverSpecialInfo;
    this.blackInfo = driverBlackInfo;
}

function IDCardInfo(name, sex, birth, addr, paperno, pic) {
    this.name = name;
    this.sex = sex;
    this.birth = birth;
    this.addr = addr;
    this.paperno = paperno;
    this.pic = pic
}

function CardReader() {
    this.OperateCardNo = null;

    this.readCardFunc = null;

    this.readCard = function(targetWindow, showErr) {
        var ret = this.readCardImpl();

        if (this.ErrRet != 0) {
            targetWindow.showReadCardErr(this.ErrInfo, this.ErrRet, showErr == null ? true : showErr);
        }

        return ret;
    }

    this.readCardImpl = function() {
        var ret = null;
        if (this.readCardFunc == null) return null;

        try {
            //this.setToken();

            if (this.readCardFunc.length == null || this.readCardFunc.length == 0) {
                ret = this.readCardFunc();
            }
            else {
                var func;
                for (var i = 0; i < this.readCardFunc.length; ++i) {
                    func = this.readCardFunc[i];
                    ret = func.call(this);

                    if (this.ErrRet != 0) break;
                }
            }
        }
        catch (ex)//catch the ex 
        {
            // alert(ex.number+"\n"+ex.description); 
            this.ErrRet = ex.number;
            this.ErrInfo = ex.description;
        }

        return ret;
    }

    this.Telcard = null;

    this.getTelcard = function() {
        this.ErrRet = SX_CARDOCX1.ReadTelcard(this.OperateCardNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            this.Telcard = null;
        }
        else {
            this.Telcard = SX_CARDOCX1.Telcard;
        }

        return this.Telcard;
    }

    this.IDInfo = null;
    this.getIDCardInfo = function() {
        this.ErrRet = SX_CARDOCX1.ReadIdentifyCard();
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            this.IDInfo = null;
        }
        else {
            this.IDInfo = new IDCardInfo(SX_CARDOCX1.Name,
                SX_CARDOCX1.Gender, SX_CARDOCX1.Birth, SX_CARDOCX1.Addr, SX_CARDOCX1.Paperno, SX_CARDOCX1.Photo);
        }
        return this.IDInfo;
    }

    this.DriverRecord = null;

    this.getDriverRecord = function() {
        this.ErrRet = SX_CARDOCX1.ReadDriverRecord(this.OperateCardNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            this.DriverRecord = null;
        }
        else {
            this.DriverRecord = SX_CARDOCX1.DriverRecord;
        }
        return this.DriverRecord;
    }
    this.getDriverRecordYL = function () {
        this.ErrRet = SX_CARDOCX1.ReadDriverRecordYL(this.OperateCardNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            this.DriverRecordYL = null;
        }
        else {
            this.DriverRecordYL = SX_CARDOCX1.DriverRecordYL;
        }
        return this.DriverRecordYL;
    }
    this.getDriverRecordSMK = function () {
        this.ErrRet = SX_CARDOCX1.ReadDriverRecordSMK(this.OperateCardNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            this.DriverRecordSMK = null;
        }
        else {
            this.DriverRecordSMK = SX_CARDOCX1.DriverRecordSMK;
        }
        return this.DriverRecordSMK;
    }

    this.getDriverRecordJT = function () {
        this.ErrRet = SX_CARDOCX1.ReadDriverRecordJT(this.OperateCardNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            this.DriverRecordJT = null;
        }
        else {
            this.DriverRecordJT = SX_CARDOCX1.DriverRecordJT;
        }
        return this.DriverRecordJT;
    }


    this.getCardNo = function() {
        this.ErrRet = SX_CARDOCX1.ReadCardNo();
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            this.CardNo = null;
        }
        else {
            this.CardNo = SX_CARDOCX1.CardNo;
        }
        return this.CardNo;
    }

    this.DriverInfo = null;
    this.getDriverInfo = function() {
        this.ErrRet = SX_CARDOCX1.ReadDriverInfo(this.OperateCardNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            this.DriverInfo = null;
        }
        else {
            this.DriverInfo = new DriverCardInfo(SX_CARDOCX1.DriverBaseInfo,
                SX_CARDOCX1.DriverSpecialInfo,
                SX_CARDOCX1.DriverBlackInfo);
        }

        return this.DriverInfo;
    }

    this.getParkInfo = function() {
        this.ErrRet = SX_CARDOCX1.ReadParkInfoEx(this.OperateCardNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            this.ParkInfo = null;
        }
        else {
            this.ParkInfo = SX_CARDOCX1.ParkEndDate;
        }
        return this.ParkInfo;
    }
    //add by liuhe 20120504
    this.getWjLvyouInfo = function() {
        try {
            this.WjLvyouTag = null;

            this.ErrRet = SX_CARDOCX1.ReadWjLvyou(this.OperateCardNo);
            if (this.ErrRet != 0) {
                this.ErrInfo = SX_CARDOCX1.ErrInfo;
                this.ParkInfo = null;
            }
            else {
                this.WjLvyouTag = SX_CARDOCX1.WjLvyouTag;
            }
            return this.WjLvyouTag;
        }
        catch (e) {
            return null;
        }
    }
    this.writeWjLvyouInfo = function() {
    this.ErrRet = SX_CARDOCX1.WriteWjLvyou(this.OperateCardNo, this.CardNo, this.WjLvyouTag);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        return true;
    }
    
    //add by liuhe 20120710
    function YuepiaoFlagInfo(YPFlag, YPFlagEx) {
        this.YPFlag = YPFlag;
        this.YPFlagEx = YPFlagEx;
    }
    
    //add by liuhe 20120710
    this.getYuepiaoFlag = function() {
        try {
            this.YuepiaoFlagInfo = null;

            this.ErrRet = SX_CARDOCX1.ReadYuepiao(this.OperateCardNo);
            if (this.ErrRet != 0) {
                this.ErrInfo = SX_CARDOCX1.ErrInfo;
                this.ParkInfo = null;
            }
            else {
                this.YuepiaoFlagInfo = new YuepiaoFlagInfo(SX_CARDOCX1.YPFlag, SX_CARDOCX1.YPFlagEx);
            }

            return this.YuepiaoFlagInfo;
        }
        catch (e) {
            return null;
        }
    }

    //add by youyue 20170210
    function YuepiaoIndexInfo(YPFlag, Privilege, AppRange, YearInfo, PriIndex1, PriIndex2, PriIndex3, PriIndex4, PriIndex5, PriIndex6, CRCCheck) {
        this.YPFlag = YPFlag;
        this.Privilege = Privilege;
        this.AppRange = AppRange;
        this.YearInfo = YearInfo;
        this.PriIndex1 = PriIndex1;
        this.PriIndex2 = PriIndex2;
        this.PriIndex3 = PriIndex3;
        this.PriIndex4 = PriIndex4;
        this.PriIndex5 = PriIndex5;
        this.PriIndex6 = PriIndex6;
        this.CRCCheck = CRCCheck;

    }
    //add by youyue 20170210
    this.getYuepiaoIndex = function () {
        try {
            var gettok = this.TokenGET;
            SX_CARDOCX1.Token = gettok;

            this.YuepiaoIndexInfo = null;
            this.ErrRet = SX_CARDOCX1.GetYuepiaoIndex(this.OperateCardNo);
            if (this.ErrRet != 0) {
                this.ErrInfo = SX_CARDOCX1.ErrInfo;
                this.ParkInfo = null;
            }
            else {
                this.YuepiaoIndexInfo = new YuepiaoIndexInfo(SX_CARDOCX1.YPFlag, SX_CARDOCX1.Privilege, SX_CARDOCX1.AppRange, SX_CARDOCX1.YearInfo, SX_CARDOCX1.PriIndex1, SX_CARDOCX1.PriIndex2, SX_CARDOCX1.PriIndex3, SX_CARDOCX1.PriIndex4, SX_CARDOCX1.PriIndex5, SX_CARDOCX1.PriIndex6, SX_CARDOCX1.CRCCheck);
            }

            return this.YuepiaoIndexInfo;
        }
        catch (e) {
            return null;
        }
    }

    this.getXXParkInfo = function() {
        this.ErrRet = SX_CARDOCX1.ReadXiuXianInfo(this.OperateCardNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            this.XXParkInfo = null;
        }
        else {
            this.XXParkInfo = SX_CARDOCX1.XXParkEndDate;
        }
        return this.XXParkInfo;
    }

    this.getMonthlyInfo = function() {
        var cardinfo = getCardInfo();

        this.MonthlyInfo = null;
        if (cardinfo == null) return null;

        this.MonthlyInfo = cardinfo.appType + cardinfo.staffTag;

        return this.MonthlyInfo;
    }
    //wdx 20111117
    this.ZJGMonthlyInfo = null;
    this.getZJGMonthlyInfo = function() {
        try {
            this.ZJGMonthlyInfo = null;
            this.ErrRet = SX_CARDOCX1.ReadZjgYPInfo(this.OperateCardNo);
            if (this.ErrRet != 0) {
                this.ErrInfo = SX_CARDOCX1.ErrInfo;
                return null;
            }
            else {
                this.ZJGMonthlyInfo = SX_CARDOCX1.ZjgYuepiaoTag;
            }
            return this.ZJGMonthlyInfo;
        }
        catch (e) {
            return null;
        }
    }

    this.getOperCardNo = function() {
        this.ErrRet = SX_CARDOCX1.ReadOperCardNo();
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            this.OperCardNo = null;
        }
        else {
            this.OperCardNo = SX_CARDOCX1.OperCardNo;
        }
        return this.OperCardNo;
    }

    this.getRecords = function() {
        this.ErrRet = SX_CARDOCX1.ReadRecord(this.OperateCardNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            this.CardRecord = null;
        }
        else {
            this.CardRecord = new CardRecord(SX_CARDOCX1.TradenoRec, SX_CARDOCX1.TradeMoneyRec, SX_CARDOCX1.TradeTypeRec,
	            SX_CARDOCX1.TradeTermRec, SX_CARDOCX1.TradeDateRec, SX_CARDOCX1.TradeTimeRec);
        }

        return this.CardRecord;
    }

    this.getCardInfoEx = function() {
        return this.getCardInfoImpl(true);
    }

    this.getCardInfo = function() {
        return this.getCardInfoImpl(false);
    }

    this.CardInfo = null;

    this.getCardInfoImpl = function (ex) {
        this.ErrRet = ex
            ? SX_CARDOCX1.ReadInfoEx(this.OperateCardNo)
            : SX_CARDOCX1.ReadInfo(this.OperateCardNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            this.CardInfo = null;
        }
        else {
            this.CardInfo = new CardInfo(SX_CARDOCX1.CARDNO, SX_CARDOCX1.AppType, SX_CARDOCX1.AppVersion,
                SX_CARDOCX1.AppSn, SX_CARDOCX1.AppStartDate, SX_CARDOCX1.AppEndDate, SX_CARDOCX1.FCI,
                SX_CARDOCX1.CardType, SX_CARDOCX1.Tradeno, SX_CARDOCX1.Balance, SX_CARDOCX1.StaffTag);
            this.CardNo = SX_CARDOCX1.CARDNO;
        }

        return this.CardInfo;
    }

    this.startCard = function() {
        this.ErrRet = SX_CARDOCX1.StartCard(this.OperateCardNo, this.CardNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        return true;
    }

    this.endCard = function() {
        this.ErrRet = SX_CARDOCX1.EndCard(this.OperateCardNo, this.CardNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        return true;
    }

    this.writeParkInfo = function() {
        this.ErrRet = SX_CARDOCX1.WriteParkInfoEx(this.OperateCardNo, this.ParkInfo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        return true;
    }

    this.writeXXParkInfo = function() {
        this.ErrRet = SX_CARDOCX1.WriteXiuXianInfo(this.OperateCardNo, this.XXParkInfo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        return true;
    }

    this.writeMonthlyInfo = function() {
        var apptype = this.MonthlyInfo.substr(0, 2);
        this.ErrRet = SX_CARDOCX1.StartYuepiao(this.OperateCardNo, this.CardNo, apptype);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }
        var stafftag = this.MonthlyInfo.substr(2, 2);
        this.ErrRet = SX_CARDOCX1.ModifyStaffTag(this.OperateCardNo, this.CardNo, stafftag);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        var pritype = this.MonthlyInfo.substr(4, 2);
        this.ErrRet = SX_CARDOCX1.ActYuepiaoIndex(this.OperateCardNo, this.CardNo, apptype, pritype, '00');
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }
        

        return true;
    }
    this.writeMonthlyInfoForLove = function () {
        var apptype = this.MonthlyInfo.substr(0, 2);
        this.ErrRet = SX_CARDOCX1.StartYuepiao(this.OperateCardNo, this.CardNo, apptype);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }
        var stafftag = this.MonthlyInfo.substr(2, 2);
        this.ErrRet = SX_CARDOCX1.ModifyStaffTag(this.OperateCardNo, this.CardNo, stafftag);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }
        return true;
    }
    //chenchu
    this.writeMonthlyInfoNew = function () {
        var apptype = this.MonthlyInfo.substr(0, 2);
        this.ErrRet = SX_CARDOCX1.StartYuepiao(this.OperateCardNo, this.CardNo, apptype);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }
        var stafftag = this.MonthlyInfo.substr(2, 2);
        this.ErrRet = SX_CARDOCX1.ModifyStaffTag(this.OperateCardNo, this.CardNo, stafftag);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        var pritype = this.MonthlyInfo.substr(4, 2);
        this.ErrRet = SX_CARDOCX1.ActYuepiaoIndex(this.OperateCardNo, this.CardNo, apptype, pritype, '00');
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }
        if (pritype == "A9") {
            var NewYearInfo = "00000000";
            var NewIndex1 = "00000000";
            this.ErrRet = SX_CARDOCX1.ExaYuepiaoIndex(this.OperateCardNo, this.CardNo, NewYearInfo, NewIndex1);
            if (this.ErrRet != 0) {
                this.ErrInfo = SX_CARDOCX1.ErrInfo;
                return false;
            }
            var NewIndex = "000000000000000000000000000000000000000000000000";
            this.ErrRet = SX_CARDOCX1.LoadYuepiaoIndex(this.OperateCardNo, this.CardNo, NewIndex);
            if (this.ErrRet != 0) {
                this.ErrInfo = SX_CARDOCX1.ErrInfo;
                return false;
            }
        }
        if (this.MonthlyIsF == "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF") {
            var NewYearInfo = "00000000";
            var NewIndex1 = "00000000";
            this.ErrRet = SX_CARDOCX1.ExaYuepiaoIndex(this.OperateCardNo, this.CardNo, NewYearInfo, NewIndex1);
            if (this.ErrRet != 0) {
                this.ErrInfo = SX_CARDOCX1.ErrInfo;
                return false;
            }
            var NewIndex = "000000000000000000000000000000000000000000000000";
            this.ErrRet = SX_CARDOCX1.LoadYuepiaoIndex(this.OperateCardNo, this.CardNo, NewIndex);
            if (this.ErrRet != 0) {
                this.ErrInfo = SX_CARDOCX1.ErrInfo;
                return false;
            }
        }

        return true;
    }
    //add by chenchu  20170216
    this.writeMonthlyYearCheck = function () {
        var YearInfo = this.MonthlyInfo.substr(0, 8);
        var Index1 = this.MonthlyInfo.substr(8, 8);
        this.ErrRet = SX_CARDOCX1.ExaYuepiaoIndex(this.OperateCardNo, this.CardNo, YearInfo, Index1);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }
        return true;
    }
    this.writeMonthlyYearCheckForMakeUp = function () {
        var YearInfo = this.MonthlyInfoYearCheck.substr(0, 8);
        var Index1 = this.MonthlyInfoYearCheck.substr(8, 8);
        this.ErrRet = SX_CARDOCX1.ExaYuepiaoIndex(this.OperateCardNo, this.CardNo, YearInfo, Index1);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }
        return true;
    }
    //add by chenchu
    this.writeMonthlyChange = function () {
        var YearInfo = this.MonthlyInfoYearCheck.substr(0, 8);
        var Index1 = this.MonthlyInfoYearCheck.substr(8, 8);
        this.ErrRet = SX_CARDOCX1.ExaYuepiaoIndex(this.OperateCardNo, this.CardNo, YearInfo, Index1);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }
        var Index = this.MonthlyInfoCharge;
        this.ErrRet = SX_CARDOCX1.LoadYuepiaoIndex(this.OperateCardNo, this.CardNo, Index);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        return true;
    }

    //add by chenchu
    this.writeMonthlyCharge = function () {
        var Index = this.MonthlyInfo;
        this.ErrRet = SX_CARDOCX1.LoadYuepiaoIndex(this.OperateCardNo, this.CardNo, Index);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }
        return true;
    }
    //add by youyue 20170217 月票升级到高龄卡
    this.writeMonthlyUpgrade= function () {
        var apptype = this.MonthlyUpgrade.substr(0, 2);
        var pritype = this.MonthlyUpgrade.substr(2, 2);
        var range = this.MonthlyUpgrade.substr(4, 2);
        this.ErrRet = SX_CARDOCX1.ActYuepiaoIndex(this.OperateCardNo, this.CardNo, apptype, pritype, range);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        var yearcheck = this.YearCheck.substr(0, 8);
        var index1 = this.YearCheck.substr(8, 8);

        this.ErrRet = SX_CARDOCX1.ExaYuepiaoIndex(this.OperateCardNo, this.CardNo, yearcheck, index1);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }
        return true;
    }
    //add by chenchu 20171127 月票卡关闭
    this.writeMonthlyInfoEnd = function () {
        var apptype = this.MonthlyInfo.substr(0, 2);
        this.ErrRet = SX_CARDOCX1.StartYuepiao(this.OperateCardNo, this.CardNo, apptype);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }
        var stafftag = this.MonthlyInfo.substr(2, 2);
        this.ErrRet = SX_CARDOCX1.ModifyStaffTag(this.OperateCardNo, this.CardNo, stafftag);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        this.ErrRet = SX_CARDOCX1.ActYuepiaoIndex(this.OperateCardNo, this.CardNo, 'FF', 'FF', 'FF');
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        this.ErrRet = SX_CARDOCX1.ExaYuepiaoIndex(this.OperateCardNo, this.CardNo, 'FFFFFFFF', 'FFFFFFFF');
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        this.ErrRet = SX_CARDOCX1.LoadYuepiaoIndex(this.OperateCardNo, this.CardNo, 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }
        return true;
    }
    //wdx 20111117
    this.writeZJGMonthlyInfo = function() {
        this.ErrRet = SX_CARDOCX1.WriteZjgYPInfo(this.OperateCardNo, this.CardNo, this.ZJGMonthlyInfo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }
        return true;
    }

    this.StaffTag = null;
    this.WirteStaffTag = function() {
        this.ErrRet = SX_CARDOCX1.ModifyStaffTag(this.OperateCardNo, this.CardNo, this.StaffTag);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        return true;
    }

    this.lockCard = function() {
        this.ErrRet = SX_CARDOCX1.Lock(this.OperateCardNo, this.CardNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        return true;
    }

    this.unlockCard = function() {
        this.ErrRet = SX_CARDOCX1.UnLock(this.OperateCardNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        return true;
    }

    this.initDriverCard = function() {
        this.ErrRet = SX_CARDOCX1.InitDriverCard(this.OperateCardNo, this.CardNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        return true;
    }

    this.DriverNo = null;
    this.CarNo = null;
    this.writeDriverCard = function() {
        this.ErrRet = SX_CARDOCX1.WriteDriverInfo(this.OperateCardNo, this.CardNo,
            this.DriverNo, this.CarNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        return true;
    }

    this.DriverState = null;
    this.modifyDriverState = function() {
        this.ErrRet = SX_CARDOCX1.ModifyDriverState(this.OperateCardNo, this.CardNo,
            this.DriverState);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        return true;
    }

    this.writeTelcard = function() {
        this.ErrRet = SX_CARDOCX1.WriteTelcard(this.OperateCardNo, this.CardNo,
            this.Telcard);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        return true;
    }


    this.preMoney = 0;
    this.chargeMoney = 0;
    this.terminalNo = '112233445566';

    this.chargeCard = function() {
        //alert(this.OperateCardNo + "," +  this.CardNo + "," +  
        //    this.preMoney + "," +  this.chargeMoney + "," +  SX_CARDOCX1.Token);
        try {
            this.ErrRet = SX_CARDOCX1.Load(this.OperateCardNo, this.CardNo,
            this.preMoney, this.chargeMoney, this.terminalNo);
            if (this.ErrRet != 0) {
                this.ErrInfo = SX_CARDOCX1.ErrInfo;
                return false;
            }

            return true;
        }
        catch (e) {
            this.ErrRet = "写卡不成功，请检查";
            return false;
        }
    }

    this.unchargeCardEx = function() { return this.unchargeCardImpl(true); }
    this.unchargeCard = function() { return this.unchargeCardImpl(false); }

    this.unchargeCardImpl = function(ex) {
        //            alert(this.OperateCardNo + "," + this.CardNo + "," + 
        //                this.preMoney  + "," +  this.chargeMoney);
        this.ErrRet = ex
            ? SX_CARDOCX1.UnLoadEx(this.OperateCardNo, this.CardNo,
            this.preMoney, this.chargeMoney, this.terminalNo)
            : SX_CARDOCX1.UnLoad(this.OperateCardNo, this.CardNo,
            this.preMoney, this.chargeMoney, this.terminalNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        return true;
    }

    this.writeCardFunc = null;
    this.targetWin = null;

    this.writeCard = function(targetWindow) {
        this.targetWin = targetWindow;
        $get('hidWarning').value = "generateToken";
        $get('btnConfirm').click();
    }

    this.writeCardImpl = function() {
        var ret = null;
        if (this.writeCardFunc == null) return null;

        try {
            this.setToken();

            if (this.writeCardFunc.length == null || this.writeCardFunc.length == 0) {
                ret = this.writeCardFunc();
            }
            else {
                var func;
                for (var i = 0; i < this.writeCardFunc.length; ++i) {
                    func = this.writeCardFunc[i];
                    ret = func.call(this);

                    if (this.ErrRet != 0) break;
                }
            }
        }
        catch (ex)//catch the ex 
        {
            // alert(ex.number+"\n"+ex.description); 
            this.ErrRet = ex.number;
            this.ErrInfo = ex.description;
        }

        this.targetWin.writeCompleteCallBack();
        this.targetWin = null;

        return ret;
    }


    this.testingMode = false;

    this.setToken = function() {
        var token = $get('hidCardReaderToken');
        SX_CARDOCX1.Token = token.value;

        //if (token != null && token.value != "")
        //{
        //    alert(token.value);
        //}
        // todo: call the activex's token set function
    }

    // read callback function
    this.readCallback = null;

    this.endDate = null;

    // ModifyEndDate
    this.modifyEndDate = function() {
        this.ErrRet = SX_CARDOCX1.ModifyEndDate(this.OperateCardNo, this.CardNo,
            this.endDate);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        return true;
    }

    this.wallet2 = 0;
    // ReadDeposit
    this.readwallet2 = function() {
        this.ErrRet = SX_CARDOCX1.ReadDeposit();
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            this.wallet2 = 0;
        }
        else {
            this.wallet2 = SX_CARDOCX1.Deposit;
            if (this.CardInfo != null) {
                this.CardInfo.wallet2 = this.wallet2;
            }
        }

        return this.wallet2;
    }

    this.chargeWallet2 = null;

    // LoadDeposit
    this.loadWallet2 = function() {
        this.ErrRet = SX_CARDOCX1.LoadDeposit(this.OperateCardNo, this.CardNo,
            this.wallet2, this.chargeWallet2, this.terminalNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        return true;
    }

    //add by gl 2015-04-09
    this.getShiPingTag = function () {
        this.ErrRet = SX_CARDOCX1.ReadShiping(this.OperateCardNo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            this.ShiPingTagInfo = null;
        }
        else {
            this.ShiPingTagInfo = SX_CARDOCX1.ShiPingTag;
        }
        return this.ShiPingTagInfo;
    }

    this.writeShiPingTag = function () {
        this.ErrRet = SX_CARDOCX1.WriteShiPing(this.OperateCardNo, this.ShiPingTagInfo);
        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }
        return true;
    }

    this.writeGjTrade = function () {
        try {
            this.ErrRet = SX_CARDOCX1.WriteGjTrade(this.OperateCardNo, this.tradeNum);
            if (this.ErrRet != 0) {
                this.ErrInfo = SX_CARDOCX1.ErrInfo;
                return false;
            }
            else {
                this.ErrInfo = '';
            }
            return true
        }
        catch (e) {
            this.ErrRet = 0;
            this.ErrInfo = 'Error';
            return true;
        }
    }


    //增加消费功能
    this.purchaseCard = function() {
         this.purchaseCardImpl(false);
    }

    this.purchaseCardImpl = function (ex) {
        //this.ErrRet = ex
        //    ? SX_CARDOCX1.PurchaseEx(this.OperateCardNo, this.CardNo,
        //    this.preMoney, this.chargeMoney, this.terminalNo)
        //    : SX_CARDOCX1.Purchase(this.OperateCardNo, this.CardNo,
        //    this.preMoney, this.chargeMoney, this.terminalNo);

        this.ErrRet = SX_CARDOCX1.Purchase(this.OperateCardNo, this.CardNo,
            this.preMoney, this.chargeMoney, this.terminalNo);

        if (this.ErrRet != 0) {
            this.ErrInfo = SX_CARDOCX1.ErrInfo;
            return false;
        }

        return true;
    }
}

var cardReader = new CardReader();


function writeCardImpl() {
    setTimeout(writeCardImplDelay, 50);
}


function writeCardImplDelay() {
    cardReader.writeCardImpl();
}

