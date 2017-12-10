using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;

namespace ChargeCardDataProduce
{
    public class RSAHelperNew
    {
        /// <summary>
        /// 打开
        /// </summary>
        /// <returns>0：成功 其他：失败</returns>
        [DllImport("libSecAccess.dll", EntryPoint = "Open")]
        public extern static int Open();

        /// <summary>
        /// 关闭
        /// </summary>
        /// <returns>0：成功 其他：失败</returns>
        [DllImport("libSecAccess.dll", EntryPoint = "Close")]
        public extern static int Close();

        /// <summary>
        /// 加密
        /// </summary>
        /// <param name="operCardNo">操作员号</param>
        /// <param name="token">令牌</param>
        /// <param name="epochTime">从1970至现在间隔的秒数</param>
        /// <param name="type">密钥类型</param>
        /// <param name="plain">明文</param>
        /// <param name="cliper">密文</param>
        /// <returns>0：成功 其他：失败</returns>
        [DllImport("libSecAccess.dll", EntryPoint = "EncodeString")]
        public extern static int EncodeString(string operCardNo, string token, int epochTime,
        int type, string plain, StringBuilder cliper);

        /// <summary>
        /// 解密
        /// </summary>
        /// <param name="operCardNo">操作员号</param>
        /// <param name="token">令牌</param>
        /// <param name="epochTime">从1970至现在间隔的秒数</param>
        /// <param name="type">密钥类型</param>
        /// <param name="cliper">密文</param>
        /// <param name="plain">明文</param>
        /// <returns>0：成功 其他：失败</returns>
        [DllImport("libSecAccess.dll", EntryPoint = "DecodeString")]
        public extern static int DecodeString(string operCardNo, string token, int epochTime,
        int type, string cliper, StringBuilder plain);


        /// <summary>
        /// 加密字符串
        /// </summary>
        /// <param name="type"></param>
        /// <param name="str"></param>
        /// <returns></returns>
        public static int RSAEncodeStringNew(string strplain, out string strcliper, out string retMsg)
        {
            int ret = -1;
            strcliper = "";
            retMsg = "";
            string operCardNo, token;
            int epochSeconds;
            StringBuilder cliper = new StringBuilder(512 + 1);//密文可以确定为512位

            try
            {
                //1 打开服务
                ret = Open();
                if (ret != 0)
                {
                    retMsg = "打开服务失败";
                    return ret;
                }

                //2 计算令牌
                GetTokenString(out operCardNo, out token, out epochSeconds);

                //3 加密
                ret = EncodeString(operCardNo, token, epochSeconds, 0, strplain, cliper);
                if (ret != 0)
                {
                    retMsg = "加密失败";
                    Close();
                    return ret;
                }
                else
                {
                    strcliper = cliper.ToString();
                }
            }
            catch (Exception err)
            {
                Log.Error(err.Message, null, "ExpLog");
            }

            return ret;
            
        }

        /// <summary>
        /// 计算令牌
        /// </summary>
        /// <returns></returns>
        static void GetTokenString(out string operCardNo, out string token, out int epochSeconds)
        {
            operCardNo = "2150010112345678";
            DateTime now = DateTime.Now;
            TimeSpan epochTime = (now.ToUniversalTime() - new DateTime(1970, 1, 1));
            epochSeconds = (int)epochTime.TotalSeconds;
            token = Token.createToken(operCardNo, (uint)epochSeconds);
        }
    }
}
