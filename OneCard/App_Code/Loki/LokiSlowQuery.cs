using System.Configuration;
using System.Data;
using Master;
using Newtonsoft.Json;
using PDO.Financial;

namespace Loki
{
    /// <summary>
    ///  慢查询外挂
    /// dongx
    /// 20160701
    /// </summary>
    public class LokiSlowQuery
    {
        /// <summary>
        /// 慢查询数据
        /// </summary>
        /// <param name="context">上下文</param>
        /// <param name="pdo">pdo</param>
        /// <returns></returns>
        public static  DataTable QueryFormLoki(CmnContext context, SP_FI_QueryPDO pdo)
        {
            if (AllowSlowQuery())
            { 
                //TODO：多PDO支撑
                SlowQuery slowQuery = ConvertFiQueryPdoToSlowQuery(pdo, context.s_UserID);
                return QueryFormLoki(context, slowQuery);
            }
            else
            {
                StoreProScene storePro = new StoreProScene();
                return  storePro.Execute(context, pdo);
            }
        }

        /// <summary>
        /// 慢查询数据
        /// </summary>
        /// <param name="context">上下文</param>
        /// <param name="slowQuery">慢查询DTO</param>
        /// <returns></returns>
        public static DataTable QueryFormLoki(CmnContext context, SlowQuery slowQuery)
        { 
            string response = HttpRequestUtility.Post(ConfigurationManager.AppSettings["Loki.URI"] + "/SlowQuery",
                JsonConvert.SerializeObject(slowQuery));
            if (!string.IsNullOrEmpty(response))
            {
                SlowQueryResponse queryResponse = JsonConvert.DeserializeObject<SlowQueryResponse>(response);
                if (queryResponse.ReturnCode == "OK")
                {
                    //Common.Log.Info(response, "AppLog");
                    return JsonHelper.JsonToDataTable(response);
                }
                else
                {
                    context.AddError(queryResponse.Message);
                    return new DataTable();
                }
            }
            context.AddError("查询失败");
            return new DataTable();
        }

        private static bool AllowSlowQuery()
        {
            if (ConfigurationManager.AppSettings["Loki.SlowQuery"].ToString() == "true")
            {
                return true;
            }
            return false;
        }

        private static SlowQuery ConvertFiQueryPdoToSlowQuery(SP_FI_QueryPDO pdo, string staffno)
        {
            SlowQuery slowQuery = new SlowQuery();
            slowQuery.StaffNo = staffno;
            slowQuery.QueryType = pdo.funcCode;
            slowQuery.Var1 = pdo.var1;
            slowQuery.Var2 = pdo.var2;
            slowQuery.Var3 = pdo.var3;
            slowQuery.Var4 = pdo.var4;
            slowQuery.Var5 = pdo.var5;
            slowQuery.Var6 = pdo.var6;
            slowQuery.Var7 = pdo.var7;
            slowQuery.Var8 = pdo.var8;
            slowQuery.Var9 = pdo.var9;
            slowQuery.Var10 = pdo.var10;
            slowQuery.Var11 = pdo.var11;
            return slowQuery;
        }
    }
}