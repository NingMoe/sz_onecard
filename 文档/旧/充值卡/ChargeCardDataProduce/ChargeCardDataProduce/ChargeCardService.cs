using System;
using System.Configuration;
using System.Data;
using System.Data.OracleClient;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.ServiceProcess;
using System.Text;
using System.IO;



namespace ChargeCardDataProduce
{
    public partial class ChargeCardService : ServiceBase
    {
        public ChargeCardService()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            Log.Init();

            int polltime = Convert.ToInt32(ConfigurationManager.AppSettings["PollTime"]);

            timer1 = new System.Timers.Timer();

            //1 载入参数表，获取轮询时间
            DataTable dtServiceParam = LoadServiceParams();

            if (null != dtServiceParam && dtServiceParam.Rows.Count > 0)
            {
                polltime = Convert.ToInt32(dtServiceParam.Rows[0]["RECYCELTIME"]);
            }

            timer1.Elapsed += new System.Timers.ElapsedEventHandler(timer1_Elapsed);

            timer1.Interval = polltime * 1000;  //设置计时器事件间隔执行事件
            timer1.Enabled = true;
        }

        protected override void OnStop()
        {
            this.timer1.Enabled = false;
        }

        private void timer1_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            //单线程运行。
            this.timer1.Stop();
            ProduceChargeCard();
            this.timer1.Start();
        }

        private void ProduceChargeCard()
        {
            try {
                ConfigurationManager.RefreshSection("appSettings");

                publicKeyTaskFile = CommonHelper.ReturnExistSingleFile(ConfigurationManager.AppSettings["PublicKeyTaskFile"]);
                //publicKeyPwdIndex = ConfigurationManager.AppSettings["PublicKeyPwdIndex"];
                path = CommonHelper.ReturnExistMultiplyPath(ConfigurationManager.AppSettings["Catalog"]);
                tempPath = CommonHelper.ReturnExistSinglePath(ConfigurationManager.AppSettings["TempCatalog"]);
                downloadpath = ConfigurationManager.AppSettings["DownLoadPath"]; //CommonHelper.ReturnExistMultiplyPath(ConfigurationManager.AppSettings["DownLoadPath"]);
                //fileNameFormat = ConfigurationManager.AppSettings["FileNameFormat"];

                UpdateTask("服务心跳，时间:" + DateTime.Now.ToString());
                //1 载入参数表，获取启停标志
                Log.Debug("载入参数", "DebugLog");
                DataTable dtServiceParam = LoadServiceParams();

                if (null != dtServiceParam && dtServiceParam.Rows.Count > 0)
                {
                    isstart = Convert.ToString(dtServiceParam.Rows[0]["ISSTART"]);
                }

                if (isstart == "0")
                {
                    Log.Debug("参数信息:服务未启动", "DebugLog");
                    return;
                }
                Log.Debug("载入参数成功", "DebugLog");

                //判断验证任务公钥文件、密码加密公钥索引是否存在
                //if (publicKeyTaskFile == "" || publicKeyPwdIndex == "")
                //{
                //    Log.Error("验证任务公钥文件或密码加密公钥索引不存在", null, "ExpLog");
                //    return;
                //}

                if (publicKeyTaskFile == "")
                {
                    Log.Error("验证任务公钥文件不存在", null, "ExpLog");
                    return;
                }


                //2 获取任务表中最早待处理任务，此时任务表中应无处理中任务
                Log.Debug("开始获取最早一笔待处理任务", "DebugLog");
     
                DataTable dtTask = GetEarliestTaskDataTable();

                if (null == dtTask || dtTask.Rows.Count == 0)
                {
                    Log.Debug("当前不存在待处理任务", "DebugLog");
                    return;
                }
                
                string taskstate = Convert.ToString(dtTask.Rows[0]["taskstate"]);     //任务状态
                string taskid = Convert.ToString(dtTask.Rows[0]["taskid"]);     //任务ID
                string corpcode = Convert.ToString(dtTask.Rows[0]["corpcode"]);   //厂家编码
                string year = Convert.ToString(dtTask.Rows[0]["year"]);       //制作年份
                string batchno = Convert.ToString(dtTask.Rows[0]["batchno"]);    //批次号
                string valuecode = Convert.ToString(dtTask.Rows[0]["valuecode"]);  //金额代码
                int valuemoney = Convert.ToInt32(dtTask.Rows[0]["MONEY"]);         //金额
                string validtime = Convert.ToString(dtTask.Rows[0]["validtime"]);  //有效期 -字符串类型
                //DateTime enddate = DateTime.ParseExact(Convert.ToString(dtTask.Rows[0]["validtime"]), "yyyyMMdd", null);  //有效期 -日期类型
                string startcardno = Convert.ToString(dtTask.Rows[0]["startcardno"]);  //起始卡号
                string endcardno = Convert.ToString(dtTask.Rows[0]["endcardno"]);  //结束卡号
                int cardnum = Convert.ToInt32(dtTask.Rows[0]["cardnum"]);        //数量
                string sign = Convert.ToString(dtTask.Rows[0]["sign"]);       //签名
                string producefilepath = Convert.ToString(dtTask.Rows[0]["FILEPATH"]);       //文件路径

                //3 任务执行开始
    
                Log.Info("任务开始执行", "AppLog");
                Log.Debug("任务开始执行", "DebugLog");
                //string publicKey = "";
                //string privateKey = "";


                //(1) 产生公钥和私钥文件
                //RSAHelper.GeneratePublicAndPrivateKey(publicKeyFile, privateKeyFile, out publicKey, out privateKey);

                //验证签名 -数据是否合法(数量、年份、批次号、金额、厂家、起始卡号、结束卡号)
                string content = cardnum + year + batchno + valuecode + corpcode + startcardno + endcardno;
                Log.Debug("任务签名验证执行", "DebugLog");
             
                if (!RSAHelper.SignVerify(content, sign, publicKeyTaskFile))
                {
                    LogTaskFail(taskid, "任务数据不合法");
                    Log.Error("任务签名验证不通过", null, "ExpLog");
                    return;
                }
             
                Log.Debug("任务签名验证通过", "DebugLog");
                //4 更新任务状态及开始时间
                Log.Debug("更新任务状态为处理中", "DebugLog");
                
                bool ok = DoBeginChargeCardTask(Convert.ToString(dtTask.Rows[0]["taskid"]));
         
                if (!ok)
                {
              
                    LogTaskFail(taskid, "更新任务状态不成功");
                    Log.Error("更新任务状态不成功", null, "ExpLog");
                    return;
                }
                Log.Debug("更新任务状态为处理中成功", "DebugLog");
          

              
                //未处理
                if (taskstate == "0")
                {
                    try
                    {
            
                        Log.Debug("充值卡密码生成开始", "DebugLog");
                        //清除临时表
                        clearTempChargeCard();

                        int count = 0;
                        int trynum = 0;
                        string filecontent = "";

                        while (count < cardnum)
                        {
                           
                            Log.Debug("充值卡密码明文随机数生成", "DebugLog");
                            //充值卡密码生成
                            string chargePW = RSAHelper.RandomPwd();

                            //公钥加密后密码
                            string EnchargePW;
                            string retMsg;
                            //Log.Error("充值卡密码加密", null, "AppLog");
                            int ret = RSAHelperNew.RSAEncodeStringNew(chargePW, out EnchargePW, out retMsg);
                            //string EnchargePW = RSAHelper.RSAEncrypt(chargePW, publicKeyPwdFile);
                            if (ret != 0)
                            {
                                LogTaskFail(taskid, retMsg);
                                Log.Error(retMsg, null, "ExpLog");
                                return;
                            }
       
                            Log.Debug("验证充值卡密码是否存在", "DebugLog");
                            //验证充值卡密码是否存在
                            if (!isExistChargePwd(EnchargePW))
                            {

                                string chargeCardFix = startcardno.Substring(0, 6);
                                string chargeCard = chargeCardFix + Convert.ToString(Convert.ToInt64(startcardno.Substring(6, 8)) + count).PadLeft(8, '0');

                               // 根据valuecode查找卡片类型

                           
                                string cardtype = GetCardType(valuecode);

                                trynum = 0;
                                count++;
                     
                                Log.Debug("插入临时表TMP_XFC_INITCARD，充值卡卡号：" + chargeCard, "DebugLog");
                                //插入临时表
                                string sql = "INSERT INTO TMP_XFC_INITCARD(TASKID, XFCARDNO,NEW_PASSWD,YEAR, BATCHNO, VALUECODE, CORPCODE, ENDDATE, CARDSTATECODE, PRODUCETIME, PRODUCESTAFFNO,CARDTYPE) ";
                                sql += " VALUES('" + taskid + "','" + chargeCard + "', '" + EnchargePW + "', '" + year + "', '" + batchno + "', '" + valuecode + "','"
                                     + corpcode + "',to_date('" + validtime + "','yyyy-MM-dd'),'C', sysdate, null,'" + cardtype + "') ";
                                int rowcount = OracleHelper.ExecuteNonQuery(OracleHelper.CONNECTION_STRING, CommandType.Text, sql);

                                if (rowcount < 1)
                                {
             
                                    LogTaskFail(taskid, "插入临时表失败");
                                    Log.Error("插入临时表失败", null, "ExpLog");
                                    return;
                                }

                                filecontent += chargeCard + "," + chargePW + "\r\n";
                            }
                            else
                            {
                             
                                Log.Debug("充值卡密码已存在", "DebugLog");
                                trynum++;
                                if (trynum > 5)
                                {
                                    //尝试5次，密码已存在
                                    LogTaskFail(taskid, "尝试5次，密码已存在");
                                    Log.Error("尝试5次，密码已存在", null, "ExpLog");
                                    return;
                                }
                            }
                        }

                        //5 生成制卡文件并入库
                        string filepath = "";
                        string downloadfilepath = "";
                        //string tempfilename = fileNameFormat.Replace("{valuemoney}", valuemoney.ToString()).Replace("{startcardno}", startcardno).Replace("{endcardno}", endcardno).Replace("{cardnum}", cardnum.ToString());
                        if (tempPath == "" || path == "" || downloadpath == "")
                        {
                            Log.Error("明文或密文文件存放路径或下载不存在", null, "ExpLog");
                        }
                        else
                        {
                            foreach (string p in path.Split(';'))
                            {
                                //判断制卡文件夹是否存在
                                if (!System.IO.Directory.Exists(p))
                                {
                                    throw new Exception("制卡文件夹不存在");
                                }

                                filepath += p;
                                filepath += "\\";
 								filepath += startcardno;
                            	filepath += "-";
                            	filepath += endcardno;
                            	filepath += ".txt";
                                filepath += ";";
                            }

                            if (filepath != "")
                            {
                                filepath = filepath.Substring(0, filepath.Length - 1);
                            }

                            foreach (string d in downloadpath.Split(';'))
                            {
                                downloadfilepath += d;
                                downloadfilepath += "\\";                                 
								downloadfilepath += startcardno;                            
								downloadfilepath += "-";
                            	downloadfilepath += endcardno;
                            	downloadfilepath += ".txt";
 								downloadfilepath += ";";
                            }

                            if (downloadfilepath != "")
                            {
                                downloadfilepath = downloadfilepath.Substring(0, downloadfilepath.Length - 1);
                            }
                        }
                   
                        Log.Debug("制卡文件生成开始，文件路径：" + filepath, "DebugLog");
                        if (ProduceCardFile(taskid, cardnum, corpcode, valuemoney, startcardno, endcardno, filecontent, filepath)) //生成制卡文件
                        {
                           
                            Log.Debug("当前执行任务" + taskid + "生成制卡文件完成", "DebugLog");
                            UpdateTask("当前执行任务" + taskid + "生成制卡文件完成");
                            Log.Debug("充值卡数据入库开始", "DebugLog");
                            bool isSuccess = RecordToChargeCard(taskid, downloadfilepath);   //入库

                            if (!isSuccess)
                            {
                                Log.Debug("充值卡数据入库失败", "DebugLog");
                                return;
                            }
                            else
                            {
                                UpdateTask("当前执行任务" + taskid + "处理完成");
                                Log.Debug("当前执行任务" + taskid + "处理完成", "DebugLog");
                            }
                        }
                        else
                        {
                            UpdateTask("当前执行任务" + taskid + "处理失败");
                            Log.Debug("生成制卡文件失败", "DebugLog");
                        }

                    }
                    catch (Exception err)
                    {
                        LogTaskFail(taskid, err.Message);
                        Log.Error(err.Message, err, "ExpLog");
                    }
                }
                //已下载 --清除文件
                else if (taskstate == "6")
                {
                    try
                    {
                        UpdateTask("当前开始执行任务" + taskid + "清理下载文件");
                        Log.Debug("当前开始执行任务" + taskid + "清理下载文件", "DebugLog");
                        try
                        {
                            foreach (string d in downloadpath.Split(';'))
                            {
                                string tmpnamee = startcardno+"-"+endcardno+".txt";
                                if (File.Exists(d + "\\" + tmpnamee))
                                {
                                    CommonHelper.DeleteFile(d + "\\" + tmpnamee);
                                }
                                else
                                {
                                    Log.Info("文件:" + d + "\\" + tmpnamee + "不存在，当前执行任务" + taskid + "删除文件失败", "AppLog");
                                    Log.Debug("文件:" + d + "\\" + tmpnamee + "不存在，当前执行任务" + taskid + "删除文件失败", "DebugLog");
                                }

                            }
                        }
                        catch (Exception err)
                        {
                            Log.Error(err.Message, err, "ExpLog");
                            return;
                        }

                        if (UpdateTaskState(taskid, "7"))
                        {
                            UpdateTask("当前执行任务" + taskid + "清理下载文件完成");
                            Log.Info("当前执行任务" + taskid + "清理下载文件完成", "AppLog");
                            Log.Debug("当前执行任务" + taskid + "清理下载文件完成", "DebugLog");
                        }
                    }
                    catch (Exception err)
                    {
                        Log.Error(err.Message, err, "ExpLog");
                    }
                }
            }
            catch (Exception err)
            {
                Log.Error(err.Message, err, "ExpLog");
            }
        }

        private bool ProduceCardFile(string taskid, int cardnum,string corpcode,int valuemoney, string startcardno, string endcardno, string filecontent, string filepath)
        {
            try
            {
                if (tempPath == "" || path == "")
                {
                    Log.Error("明文或密文文件存放路径不存在", null, "ExpLog");
                    return false;
                }
                //判断临时文件夹是否存在
                if (!System.IO.Directory.Exists(tempPath))
                {
                    Log.Error("临时文件夹路径不存在", null, "ExpLog");
                    return false;
                }

                UpdateTask("当前执行任务" + taskid + "开始生成制卡文件");
                Log.Debug("当前执行任务" + taskid + "开始生成制卡文件", "DebugLog");
                //生成制卡文件
                DataTable dtCorpKey = GetCorpKeyDataTable(corpcode);

                if (null != dtCorpKey && dtCorpKey.Rows.Count > 0)
                {
                    string corpPublicKey = Convert.ToString(dtCorpKey.Rows[0]["PUBLICKEY"]).Replace("\\n", "\n");

                    string tempPathFile = tempPath + "\\" + startcardno + "-" + endcardno + ".txt";
					Log.Debug("生成临时明文文件,文件路径：" + tempPathFile, "DebugLog");
                    //生成临时明文文件
                    if (CommonHelper.SaveToTxtFile(filecontent, tempPathFile))
                    {
                        Log.Debug("临时明文文件生成成功", "DebugLog");
                        Log.Debug("加密并生成文件", "DebugLog");

                        //加密并生成文件
                        try {
                            RSAHelper.RSAEncryptFile(corpPublicKey, tempPathFile, filepath);
                        }
                        catch (Exception ex)
                        {
                            Log.Error("生成加密文件失败。"+ex.Message, null, "ExpLog");
                            return false;
                        }
                        Log.Debug("加密文件生成成功", "DebugLog");
                    }
                    else
                    {

                        Log.Error("生成临时明文文件失败",null, "ExpLog");

                        return false;
                    }
                    Log.Debug("删除临时明文文件", "DebugLog");
                    //删除临时明文文件
                    CommonHelper.DeleteFile(tempPathFile);

                }
            }
            catch (Exception err)
            {
                Log.Error("生成制卡文件失败" + err.Message, null, "ExpLog");
                return false;
            }

            return true;
        }

        /// <summary>
        /// 载入参数表
        /// </summary>
        /// <returns></returns>
        private DataTable LoadServiceParams()
        {
            string sql = "SELECT RECYCELTIME, ISSTART FROM TD_M_SERVICESET";
            return OracleHelper.ExecuteDataset(OracleHelper.CONNECTION_STRING, CommandType.Text, sql).Tables[0];
        }

        /// <summary>
        /// 任务表最早待处理任务(包括未处理、生成文件失败、已下载)
        /// </summary>
        /// <returns></returns>
        private DataTable GetEarliestTaskDataTable()
        {
            string sql = "select A.taskid, A.cardorderid, A.taskstate, A.corpcode, A.year, A.batchno, A.valuecode, A.validtime, ";
            sql += " A.startcardno, A.endcardno, A.cardnum, A.operator, A.datetime, A.sign, A.FILEPATH, B.MONEY ";
            sql += " from tf_f_makecardtask A,TP_XFC_CARDVALUE B ";
            sql += " WHERE A.VALUECODE = B.VALUECODE(+)";
            sql += " AND A.taskstate in ('0','6') ";
            sql += " and (select count(*) from tf_f_makecardtask C where C.taskstate = '1') = 0 ";

            return OracleHelper.ExecuteDataset(OracleHelper.CONNECTION_STRING, CommandType.Text, sql).Tables[0];
        }

        /// <summary>
        /// 根据金额编码获取充值卡类型
        /// </summary>
        /// <returns>CARDTYPE</returns>
        private string GetCardType(string valuecode)
        {
            string sql = "SELECT CARDTYPE FROM  TP_XFC_CARDVALUE WHERE VALUECODE='" + valuecode + "'";
            DataTable dt = OracleHelper.ExecuteDataset(OracleHelper.CONNECTION_STRING, CommandType.Text, sql).Tables[0];
            return dt.Rows[0]["CARDTYPE"].ToString();
        }

        /// <summary>
        /// 任务开始执行
        /// </summary>
        /// <param name="taskid"></param>
        /// <returns></returns>
        private bool DoBeginChargeCardTask(string taskid)
        {
            OracleParameter[] parameters = {
                                               new OracleParameter("p_TASKID", OracleType.Char, 16),
                                               new OracleParameter("p_retCode", OracleType.Char, 10),
                                               new OracleParameter("p_retMsg", OracleType.VarChar, 127)
                                           };

            parameters[0].Value = taskid;
            parameters[2].Value = "";
            parameters[1].Direction = ParameterDirection.Output;
            parameters[2].Direction = ParameterDirection.Output;

            int count = OracleHelper.RunExecuteNonQueryStoredProcedure(OracleHelper.CONNECTION_STRING, "SP_CCS_BEGINTASK", parameters);

            string returnCode = Convert.ToString(parameters[1].Value);

            string returnMessage = Convert.ToString(parameters[2].Value);

            if (returnCode != "0000000000")
            {
                LogTaskFail(taskid, returnMessage);
                return false;
            }

            return true;
        }

        private DataTable GetCorpKeyDataTable(string corpCode)
        {
            string sql = "SELECT PUBLICKEY, PRIVATEKEY FROM TD_M_PUBLICANDPRIVATEKEY WHERE CORPCODE = '" + corpCode + "'";
            return OracleHelper.ExecuteDataset(OracleHelper.CONNECTION_STRING, CommandType.Text, sql).Tables[0];
        }

        /// <summary>
        /// 是否已存在该密码
        /// </summary>
        /// <param name="pwd"></param>
        /// <returns></returns>
        private bool isExistChargePwd(string pwd)
        {
            OracleParameter pRetCode = new OracleParameter("p_CURSOR", OracleType.Cursor);
            pRetCode.Direction = ParameterDirection.Output;

            OracleParameter[] parameters = {
                                               new OracleParameter("p_funcCode", OracleType.VarChar, 16),
                                               new OracleParameter("p_var1", OracleType.VarChar, 4000),
                                               new OracleParameter("p_var2", OracleType.VarChar, 16),
                                               new OracleParameter("p_var3", OracleType.VarChar, 16),
                                               new OracleParameter("p_var4", OracleType.VarChar, 16),
                                               new OracleParameter("p_var5", OracleType.VarChar, 16),
                                               new OracleParameter("p_var6", OracleType.VarChar, 16),
                                               new OracleParameter("p_var7", OracleType.VarChar, 16),
                                               new OracleParameter("p_var8", OracleType.VarChar, 16),
                                               new OracleParameter("p_var9", OracleType.VarChar, 16),
                                               new OracleParameter("p_var10", OracleType.VarChar, 16),
                                               new OracleParameter("p_var11", OracleType.VarChar, 16),
                                               pRetCode
                                           };

            parameters[0].Value = "QryHasExistPwd";
            parameters[1].Value = pwd;
            parameters[2].Value = "";
            parameters[3].Value = "";
            parameters[4].Value = "";
            parameters[5].Value = "";
            parameters[6].Value = "";
            parameters[7].Value = "";
            parameters[8].Value = "";
            parameters[9].Value = "";
            parameters[10].Value = "";
            parameters[11].Value = "";

            DataSet ds = OracleHelper.ExecuteDataset(OracleHelper.CONNECTION_STRING, "SP_RM_Query", parameters);

            if (ds == null || ds.Tables[0].Rows.Count == 0)
            {
                return false;
            }

            return true;
        }

        /// <summary>
        /// 清除临时表
        /// </summary>
        private void clearTempChargeCard()
        {
            string sql = "delete from TMP_XFC_INITCARD";
            OracleHelper.ExecuteNonQuery(OracleHelper.CONNECTION_STRING, CommandType.Text, sql);
        }

        /// <summary>
        /// 记录到充值卡账户表
        /// </summary>
        /// <returns></returns>
        private bool RecordToChargeCard(string taskid, string filepath)
        {
            OracleParameter[] parameters = {
                                               new OracleParameter("p_TASKID", OracleType.Char, 16),
                                               new OracleParameter("p_FILEPATH", OracleType.VarChar, 4000),
                                               new OracleParameter("p_retCode", OracleType.Char, 10),
                                               new OracleParameter("p_retMsg", OracleType.VarChar, 127)
                                           };

            parameters[0].Value = taskid;
            parameters[1].Value = filepath;
            parameters[2].Direction = ParameterDirection.Output;
            parameters[3].Direction = ParameterDirection.Output;

            int count = OracleHelper.RunExecuteNonQueryStoredProcedure(OracleHelper.CONNECTION_STRING, "SP_CCS_INDATA", parameters);

            string returnCode = Convert.ToString(parameters[2].Value);

            string returnMessage = Convert.ToString(parameters[3].Value);

            if (returnCode != "0000000000")
            {
                LogTaskFail(taskid, returnMessage);
                Log.Error(returnMessage, null, "ExpLog");
                return false;
            }

            return true;
        }

        private bool UpdateTask(string message)
        {
            string sql = "UPDATE TD_M_SERVICESET SET TASKDESC = '" + message + "'";
            int rowcount = OracleHelper.ExecuteNonQuery(OracleHelper.CONNECTION_STRING, CommandType.Text, sql);

            return rowcount > 0;
        }

        private bool UpdateTaskState(string taskid, string statuscode)
        {
            string sql = "UPDATE TF_F_MAKECARDTASK SET TASKSTATE = '" + statuscode + "' where TASKID = '" + taskid + "'";
            int rowcount = OracleHelper.ExecuteNonQuery(OracleHelper.CONNECTION_STRING, CommandType.Text, sql);

            return rowcount > 0;
        }

        /// <summary>
        /// 记录失败原因
        /// </summary>
        /// <param name="taskid"></param>
        /// <param name="msg"></param>
        /// <returns></returns>
        private bool LogTaskFail(string taskid, string msg)
        {
            OracleParameter[] parameters = {
                                               new OracleParameter("p_TASKID", OracleType.Char, 16),
                                               new OracleParameter("p_REASON", OracleType.VarChar, 200),
                                               new OracleParameter("p_retCode", OracleType.Char, 10),
                                               new OracleParameter("p_retMsg", OracleType.VarChar, 127)
                                           };

            parameters[0].Value = taskid;
            parameters[1].Value = msg;
            parameters[2].Direction = ParameterDirection.Output;
            parameters[3].Direction = ParameterDirection.Output;

            int count = OracleHelper.RunExecuteNonQueryStoredProcedure(OracleHelper.CONNECTION_STRING, "SP_CCS_LOGTASKFAIL", parameters);

            string returnCode = Convert.ToString(parameters[2].Value);

            string returnMessage = Convert.ToString(parameters[3].Value);

            if (returnCode != "0000000000")
            {
                return false;
            }

            return true;
        }

        public System.Timers.Timer timer1; //计时器
        public string isstart = "1";

        string publicKeyTaskFile = "";
        //string publicKeyPwdIndex = "";
        string path = "";
        string tempPath = "";
        string downloadpath = "";
        //string fileNameFormat = "";

    }
}
