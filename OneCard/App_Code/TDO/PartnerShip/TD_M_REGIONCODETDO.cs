using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

/// <summary>
///地区编码表
/// </summary>
public class TD_M_REGIONCODETDO : DDOBase
{
	public TD_M_REGIONCODETDO()
	{
		//
		//TODO: 在此处添加构造函数逻辑
		//
	}

    protected override void Init()
    {
        tableName = "TD_M_REGIONCODE";

        columns = new String[5][];
        columns[0] = new String[] { "REGIONCODE", "string" };
        columns[1] = new String[] { "REGIONNAME", "String" };
        columns[2] = new String[] { "ISUSETAG", "string" };
        columns[3] = new String[] { "UPDATESTAFFNO", "string" };
        columns[4] = new String[] { "UPDATETIME", "DateTime" };

        columnKeys = new String[]{
                   "REGIONCODE",
               };


        array = new String[5];
        hash.Add("REGIONCODE", 0);
        hash.Add("REGIONNAME", 1);
        hash.Add("ISUSETAG", 2);
        hash.Add("UPDATESTAFFNO", 3);
        hash.Add("UPDATETIME", 4);
    }

    // 地区编码
    public string REGIONCODE
    {
        get { return Getstring("REGIONCODE"); }
        set { Setstring("REGIONCODE", value); }
    }

    // 地区名称
    public String REGIONNAME
    {
        get { return GetString("REGIONNAME"); }
        set { SetString("REGIONNAME", value); }
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