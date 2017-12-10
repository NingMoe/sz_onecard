using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

// ��ѯ
public class SP_IT_QueryByIDPDO : PDOBase
{
    public SP_IT_QueryByIDPDO(String pdoName)
        : base(pdoName)
    {
    }

    protected override void Init(String pdoName)
    {
        InitBegin(pdoName, 12);

        AddField("@ID", "String", "18", "input");
        AddField("@cursor", "Cursor", "", "output");

    }

    // ���ܱ���
    public String ID
    {
        get { return GetString("ID"); }
        set { SetString("ID", value); }
    }

 
}



