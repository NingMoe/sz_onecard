using System;
using System.Collections.Generic;
using System.Web;

/// <summary>
/// SlowQuery 的摘要说明
/// </summary>
public class SlowQuery
{
    public string StaffNo;
    public string QueryType;
    public string Var1;
    public string Var2;
    public string Var3;
    public string Var4;
    public string Var5;
    public string Var6;
    public string Var7;
    public string Var8;
    public string Var9;
    public string Var10;
    public string Var11;
}

public class SlowQueryResponse
{
    public string ReturnCode;
    public string Message;
    public IEnumerable<Object> Result;
}