using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

public class TD_M_BUYCARDPERINFOTDO : DDOBase
{
	public TD_M_BUYCARDPERINFOTDO()
	{
	}
    protected override void Init()
    {
        tableName = "TD_M_BUYCARDPERINFO";

        columns = new String[9][];
        columns[0] = new String[] { "PAPERTYPE", "string" };
        columns[1] = new String[] { "PAPERNO", "string" };
        columns[2] = new String[] { "NAME", "string" };
        columns[3] = new String[] { "BIRTHDAY", "string" };
        columns[4] = new String[] { "SEX", "string" };
        columns[5] = new String[] { "PHONENO", "string" };
        columns[6] = new String[] { "ADDRESS", "string" };
        columns[7] = new String[] { "EMAIL", "string" };
        columns[8] = new String[] { "REMARK", "string" };

        columnKeys = new String[]{
                   "PAPERTYPE",
                   "PAPERNO",
               };


        array = new String[9];
        hash.Add("PAPERTYPE", 0);
        hash.Add("PAPERNO", 1);
        hash.Add("NAME", 2);
        hash.Add("BIRTHDAY", 3);
        hash.Add("SEX", 4);
        hash.Add("PHONENO", 5);
        hash.Add("ADDRESS", 6);
        hash.Add("EMAIL", 7);
        hash.Add("REMARK", 8);
    }

    // 证件类型
    public string PAPERTYPE
    {
        get { return Getstring("PAPERTYPE"); }
        set { Setstring("PAPERTYPE", value); }
    }
    // 证件号码
    public string PAPERNO
    {
        get { return Getstring("PAPERNO"); }
        set { Setstring("PAPERNO", value); }
    }
    // 姓名
    public string NAME
    {
        get { return Getstring("NAME"); }
        set { Setstring("NAME", value); }
    }
    // 出生日期
    public string BIRTHDAY
    {
        get { return Getstring("BIRTHDAY"); }
        set { Setstring("BIRTHDAY", value); }
    }
    // 性别
    public string SEX
    {
        get { return Getstring("SEX"); }
        set { Setstring("SEX", value); }
    }
    // 联系电话
    public string PHONENO
    {
        get { return Getstring("PHONENO"); }
        set { Setstring("PHONENO", value); }
    }
    // 联系地址
    public string ADDRESS
    {
        get { return Getstring("ADDRESS"); }
        set { Setstring("ADDRESS", value); }
    }
    // 电子邮件
    public string EMAIL
    {
        get { return Getstring("EMAIL"); }
        set { Setstring("EMAIL", value); }
    }
    // 备注
    public string REMARK
    {
        get { return Getstring("REMARK"); }
        set { Setstring("REMARK", value); }
    }
}