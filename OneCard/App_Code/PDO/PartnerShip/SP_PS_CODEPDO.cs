using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;


public class SP_PS_CODEPDO : PDOBase
{
    //编码维护
	public SP_PS_CODEPDO()
	{
		//
		//TODO: 在此处添加构造函数逻辑
		//
	}

    protected override void Init()
    {
        InitBegin("SP_PS_CODE", 10);

        AddField("@funcCode", "String", "16", "input");
        AddField("@var1", "String", "16", "input");
        AddField("@var2", "String", "40", "input");
        AddField("@var3", "String", "20", "input");
        AddField("@var4", "String", "20", "input");
        AddField("@var5", "String", "20", "input");

        InitEnd();
    }

    // 功能编码
    public String funcCode
    {
        get { return GetString("funcCode"); }
        set { SetString("funcCode", value); }
    }

    // 参数1
    public String var1
    {
        get { return GetString("var1"); }
        set { SetString("var1", value); }
    }

    // 参数2
    public String var2
    {
        get { return GetString("var2"); }
        set { SetString("var2", value); }
    }

    // 参数3
    public String var3
    {
        get { return GetString("var3"); }
        set { SetString("var3", value); }
    }

    // 参数4
    public String var4
    {
        get { return GetString("var4"); }
        set { SetString("var4", value); }
    }

    // 参数5
    public String var5
    {
        get { return GetString("var5"); }
        set { SetString("var5", value); }
    }
}