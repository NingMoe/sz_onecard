using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

public class SP_PB_CardToCardOutPDO : PDOBase
{
	public SP_PB_CardToCardOutPDO()
	{
	}

    protected override void Init()
    {
        InitBegin("SP_PB_CardToCardOut", 15);

        AddField("@ID", "string", "18", "input");
        AddField("@OUTCARDNO", "string", "16", "input");
        AddField("@TRADETYPECODE", "string", "2", "input");
        AddField("@CARDTRADENO", "string", "4", "input");
        AddField("@SUPPLYMONEY", "Int32", "", "input");
        AddField("@CARDMONEY", "Int32", "", "input");
        AddField("@REMARK", "string", "100", "input");
        AddField("@OPERCARDNO", "string", "16", "input");
        AddField("@TERMNO", "string", "12", "input");
        AddField("@TRADEID", "string", "16", "output");

        InitEnd();
    }
    // 记录流水号
    public string ID
    {
        get { return Getstring("ID"); }
        set { Setstring("ID", value); }
    }

    // 圈提卡号
    public string OUTCARDNO
    {
        get { return Getstring("OUTCARDNO"); }
        set { Setstring("OUTCARDNO", value); }
    }

    // 业务类型编码
    public string TRADETYPECODE
    {
        get { return Getstring("TRADETYPECODE"); }
        set { Setstring("TRADETYPECODE", value); }
    }

    // 联机交易序号
    public string CARDTRADENO
    {
        get { return Getstring("CARDTRADENO"); }
        set { Setstring("CARDTRADENO", value); }
    }

    // 圈提金额
    public Int32 SUPPLYMONEY
    {
        get { return GetInt32("SUPPLYMONEY"); }
        set { SetInt32("SUPPLYMONEY", value); }
    }

    // 账户余额
    public Int32 CARDMONEY
    {
        get { return GetInt32("CARDMONEY"); }
        set { SetInt32("CARDMONEY", value); }
    }

    // 备注
    public string REMARK
    {
        get { return Getstring("REMARK"); }
        set { Setstring("REMARK", value); }
    }

    // 操作员卡号
    public string OPERCARDNO
    {
        get { return Getstring("OPERCARDNO"); }
        set { Setstring("OPERCARDNO", value); }
    }

    // 终端号
    public string TERMNO
    {
        get { return Getstring("TERMNO"); }
        set { Setstring("TERMNO", value); }
    }

    // 返回交易序列号
    public string TRADEID
    {
        get { return Getstring("TRADEID"); }
        set { Setstring("TRADEID", value); }
    }
}