using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;


 // 查询
 public class SP_12QueryPDO : PDOBase
 {
     public SP_12QueryPDO(String pdoName):base(pdoName)
      {
      }

     protected override void Init(String pdoName)
      {
            InitBegin(pdoName,15);

           AddField("@funcCode", "String", "16", "input");
           AddField("@var1", "String", "32", "InputOutput");
           AddField("@var2", "String", "32", "InputOutput");
           AddField("@var3", "String", "32", "InputOutput");
           AddField("@var4", "String", "32", "InputOutput");
           AddField("@var5", "String", "32", "InputOutput");
           AddField("@var6", "String", "32", "InputOutput");
           AddField("@var7", "String", "32", "InputOutput");
           AddField("@var8", "String", "32", "InputOutput");
           AddField("@var9", "String", "32", "InputOutput");
           AddField("@var10", "String", "32", "InputOutput");
           AddField("@var11", "String", "32", "InputOutput");
           AddField("@var12", "String", "32", "InputOutput");
           AddField("@cursor", "Cursor", "", "output");

      }

      // 功能编码
      public String funcCode
      {
          get { return  GetString("funcCode"); }
          set { SetString("funcCode",value); }
      }

      // 参数1
      public String var1
      {
          get { return  GetString("var1"); }
          set { SetString("var1",value); }
      }

      // 参数2
      public String var2
      {
          get { return  GetString("var2"); }
          set { SetString("var2",value); }
      }

      // 参数3
      public String var3
      {
          get { return  GetString("var3"); }
          set { SetString("var3",value); }
      }

      // 参数4
      public String var4
      {
          get { return  GetString("var4"); }
          set { SetString("var4",value); }
      }

      // 参数5
      public String var5
      {
          get { return  GetString("var5"); }
          set { SetString("var5",value); }
      }

      // 参数6
      public String var6
      {
          get { return  GetString("var6"); }
          set { SetString("var6",value); }
      }

      // 参数7
      public String var7
      {
          get { return  GetString("var7"); }
          set { SetString("var7",value); }
      }

      // 参数8
      public String var8
      {
          get { return  GetString("var8"); }
          set { SetString("var8",value); }
      }

      // 参数9
      public String var9
      {
          get { return  GetString("var9"); }
          set { SetString("var9",value); }
      }

      // 参数10
      public String var10
      {
          get { return GetString("var10"); }
          set { SetString("var10", value); }
      }

      // 参数11
      public String var11
      {
          get { return GetString("var11"); }
          set { SetString("var11", value); }
      }

      // 参数12
      public String var12
      {
          get { return GetString("var12"); }
          set { SetString("var12", value); }
      }
 }


