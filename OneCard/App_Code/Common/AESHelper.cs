using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Runtime.InteropServices;


    /// <summary>
	/// AesHelper 的摘要说明
	/// </summary>
	public class AesDll
	{
		private IntPtr hLib;

		[DllImport("kernel32.dll")]
		private extern static IntPtr LoadLibrary(String path);
		[DllImport("kernel32.dll")]
		private extern static IntPtr GetProcAddress(IntPtr lib, String funcName);
		[DllImport("kernel32.dll")]
		private extern static bool FreeLibrary(IntPtr lib);

		public AesDll(string dllPath)
		{
			hLib = LoadLibrary(dllPath);
		}

        ~AesDll()
		{
			FreeLibrary(hLib);
		}


		/// <summary>
		/// 将要执行的函数转换为委托
		/// </summary>
		/// <param name="apiName">接口函数名称</param>
		/// <param name="t">接口函数类型（委托）</param>
		/// <returns>接口函数的委托</returns>
 
		public Delegate Invoke(String apiName, Type t)
		{
			IntPtr apiFunction = GetProcAddress(hLib, apiName);
			//若为找到对应的函数地址则返回
			if (apiFunction.ToInt32() == 0)
			{	
				//获取错误原因
				int i = Marshal.GetLastWin32Error();
				throw new Exception("未能找到函数地址，错误原因为:"+i.ToString());
			}
			return (Delegate)Marshal.GetDelegateForFunctionPointer(apiFunction, t);
		}

		/// <summary>
		/// 调用AES解密函数
		/// </summary>
		/// <param name="type">加解密类型 0：加密，1：解密</param>
		/// <param name="szInput">输入参数：明文或者密文</param>
		/// <param name="key">密钥：不设置采用默认</param>
		/// <param name="szOutput">输出参数：密文或者明文</param>
		/// <returns>是否成功加密或者解密</returns>
		public delegate int AES(int type, string szInput, string key, System.Text.StringBuilder szOutput);


        public delegate int GetEncryptSize(int size);

    }

    public static class AESHelp
    {
        /// <summary>
        /// 加密
        /// </summary>
        /// <param name="szInput">输入参数：明文</param>
        /// <param name="szOutput">输出参数：密文</param>
        /// <returns>是否成功加密</returns>
        public static int AESEncrypt(string szInput,ref System.Text.StringBuilder szOutput)
        {
            //szOutput.Append(szInput);
            //return 0;
            AesDll ah = new AesDll(HttpContext.Current.Server.MapPath("~/bin/AESmt.dll"));
            AesDll.GetEncryptSize GetSize = ah.Invoke("GetEncryptSize", typeof(AesDll.GetEncryptSize)) as AesDll.GetEncryptSize;
            szOutput = new System.Text.StringBuilder(GetSize(szInput.Trim().Length));
            AesDll.AES AES = ah.Invoke("AES", typeof(AesDll.AES)) as AesDll.AES;
            return AES(0, szInput, "11111111111111111111111111111111", szOutput);
        }

        /// <summary>
        /// 解密
        /// </summary>
        /// <param name="szInput">输入参数：密文</param>
        /// <param name="szOutput">输出参数：明文</param>
        /// <returns>是否成功解密</returns>
        public static int AESDeEncrypt(string szInput, ref System.Text.StringBuilder szOutput)
        {
            //szOutput.Append(szInput);
            //return 0;
            AesDll ah = new AesDll(HttpContext.Current.Server.MapPath("~/bin/AESmt.dll"));
            szOutput = new System.Text.StringBuilder(szInput.Trim().Length);
            AesDll.AES AES = ah.Invoke("AES", typeof(AesDll.AES)) as AesDll.AES;
            return AES(1, szInput, "11111111111111111111111111111111", szOutput);
        }
    }