using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

 // ��ѯ
 public class SP_QueryPDO : PDOBase
 {
     public SP_QueryPDO(String pdoName)
         : base(pdoName)
      {
      }

     protected override void Init(String pdoName)
      {
            InitBegin(pdoName,12);

           AddField("@funcCode", "String", "16", "input");
           AddField("@var1", "String", "32", "input");
           AddField("@var2", "String", "16", "input");
           AddField("@var3", "String", "16", "input");
           AddField("@var4", "String", "16", "input");
           AddField("@var5", "String", "16", "input");
           AddField("@var6", "String", "16", "input");
           AddField("@var7", "String", "16", "input");
           AddField("@var8", "String", "16", "InputOutput");
           AddField("@var9", "String", "16", "InputOutput");
           AddField("@cursor", "Cursor", "", "output");

      }

      // ���ܱ���
      public String funcCode
      {
          get { return  GetString("funcCode"); }
          set { SetString("funcCode",value); }
      }

      // ����1
      public String var1
      {
          get { return  GetString("var1"); }
          set { SetString("var1",value); }
      }

      // ����2
      public String var2
      {
          get { return  GetString("var2"); }
          set { SetString("var2",value); }
      }

      // ����3
      public String var3
      {
          get { return  GetString("var3"); }
          set { SetString("var3",value); }
      }

      // ����4
      public String var4
      {
          get { return  GetString("var4"); }
          set { SetString("var4",value); }
      }

      // ����5
      public String var5
      {
          get { return  GetString("var5"); }
          set { SetString("var5",value); }
      }

      // ����6
      public String var6
      {
          get { return  GetString("var6"); }
          set { SetString("var6",value); }
      }

      // ����7
      public String var7
      {
          get { return  GetString("var7"); }
          set { SetString("var7",value); }
      }

      // ����8
      public String var8
      {
          get { return  GetString("var8"); }
          set { SetString("var8",value); }
      }

      // ����9
      public String var9
      {
          get { return  GetString("var9"); }
          set { SetString("var9",value); }
      }

 }



