using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

/// <summary>
///应用行业编码表
/// </summary>
public class TD_M_APPCALLINGCODETDO : DDOBase
{
	public TD_M_APPCALLINGCODETDO()
	{
		//
		//TODO: 在此处添加构造函数逻辑
		//
	}

    protected override void Init()
    {
        tableName = "TD_M_APPCALLINGCODE";

        columns = new String[5][];
        columns[0] = new String[] { "APPCALLINGCODE", "string" };
        columns[1] = new String[] { "APPCALLING", "String" };
        columns[2] = new String[] { "ISUSETAG", "string" };
        columns[3] = new String[] { "UPDATESTAFFNO", "string" };
        columns[4] = new String[] { "UPDATETIME", "DateTime" };

        columnKeys = new String[]{
                   "APPCALLINGCODE",
               };


        array = new String[5];
        hash.Add("APPCALLINGCODE", 0);
        hash.Add("APPCALLING", 1);
        hash.Add("ISUSETAG", 2);
        hash.Add("UPDATESTAFFNO", 3);
        hash.Add("UPDATETIME", 4);
    }

    // 应用行业编码
    public string APPCALLINGCODE
    {
        get { return Getstring("APPCALLINGCODE"); }
        set { Setstring("APPCALLINGCODE", value); }
    }

    // 应用行业名称
    public String APPCALLING
    {
        get { return GetString("APPCALLING"); }
        set { SetString("APPCALLING", value); }
    }

    // 是否开通
    public string ISUSETAG
    {
        get { return Getstring("ISUSETAG"); }
        set { Setstring("ISUSETAG", value); }
    }

    // 更新员工
    public string UPDATESTAFFNO
    {
        get { return Getstring("UPDATESTAFFNO"); }
        set { Setstring("UPDATESTAFFNO", value); }
    }

    // 更新时间
    public DateTime UPDATETIME
    {
        get { return GetDateTime("UPDATETIME"); }
        set { SetDateTime("UPDATETIME", value); }
    }
}