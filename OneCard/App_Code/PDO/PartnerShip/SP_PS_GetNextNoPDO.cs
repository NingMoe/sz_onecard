using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

/// <summary>
///获取自增编码
/// </summary>
public class SP_PS_GetNextNoPDO : PDOBase
{
	public SP_PS_GetNextNoPDO()
	{
		//
		//TODO: 在此处添加构造函数逻辑
		//
	}

    protected override void Init()
    {
        InitBegin("SP_PS_GetNextNo", 3);

        AddField("@funcCode", "String", "16", "input");
        AddField("@prefix", "String", "16", "input");

        AddField("@output", "String", "50", "output");
    }

    // 功能编码
    public String funcCode
    {
        get { return GetString("funcCode"); }
        set { SetString("funcCode", value); }
    }

    // 用户选择固定编码
    public String prefix
    {
        get { return GetString("prefix"); }
        set { SetString("prefix", value); }
    }

    // 过程返回编码
    public String output
    {
        get { return GetString("output"); }
        set { SetString("output", value); }
    }
}