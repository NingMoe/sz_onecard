using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;
/// <summary>
///POS投放模式编码表
/// </summary>
public class TD_M_DELIVERYMODECODETDO : DDOBase
{
    public TD_M_DELIVERYMODECODETDO()
	{
		//
		//TODO: 在此处添加构造函数逻辑
		//
	}

    protected override void Init()
    {
        tableName = "TD_M_DELIVERYMODECODE";

        columns = new String[5][];
        columns[0] = new String[] { "DELIVERYMODECODE", "string" };
        columns[1] = new String[] { "DELIVERYMODE", "String" };
        columns[2] = new String[] { "ISUSETAG", "string" };
        columns[3] = new String[] { "UPDATESTAFFNO", "string" };
        columns[4] = new String[] { "UPDATETIME", "DateTime" };

        columnKeys = new String[]{
                   "DELIVERYMODECODE",
               };


        array = new String[5];
        hash.Add("DELIVERYMODECODE", 0);
        hash.Add("DELIVERYMODE", 1);
        hash.Add("ISUSETAG", 2);
        hash.Add("UPDATESTAFFNO", 3);
        hash.Add("UPDATETIME", 4);
    }

    // POS投放模式编码
    public string DELIVERYMODECODE
    {
        get { return Getstring("DELIVERYMODECODE"); }
        set { Setstring("DELIVERYMODECODE", value); }
    }

    // POS投放模式名称
    public String DELIVERYMODE
    {
        get { return GetString("DELIVERYMODE"); }
        set { SetString("DELIVERYMODE", value); }
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