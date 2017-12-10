using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using Newtonsoft.Json;

/// <summary>
/// JsonHelper 的摘要说明
/// </summary>
public class JsonHelper
{
    /// <summary>
    /// 处理Json的时间格式为正常格式
    /// </summary>
    public static string JsonDateTimeFormat(string json)
    { 
        json = Regex.Replace(json,
            @"\\/Date\((\d+)-*(\d*)\)\\/", new MatchEvaluator(MatchDateTime));
        return json;
    }

    private static string MatchDateTime(Match match)
    {
        DateTime dt = new DateTime(1970, 1, 1);
        dt = dt.AddMilliseconds(long.Parse(match.Groups[1].Value));
        dt = dt.ToLocalTime();
        return dt.ToString("yyyy-MM-dd HH:mm:ss.fff");
    }

 
    /// <summary>
    /// 将json转换为DataTable
    /// </summary>
    /// <param name="strJson">得到的json</param>
    /// <returns></returns>
    public static DataTable JsonToDataTable(string strJson)
    {
        strJson = JsonDateTimeFormat(strJson);
        //转换json格式
        strJson = strJson.Replace(",\"", "$\"").Replace("\":", "\"#").ToString();
        DataTable tb = null;
        //去除表名  

        strJson = strJson.Substring(strJson.IndexOf("[") + 1);
        strJson = strJson.Substring(0, strJson.IndexOf("]"));

        //获取数据   
        Regex rg = new Regex(@"(?<={)[^}]+(?=})");
        MatchCollection mc = rg.Matches(strJson);
        for (int i = 0; i < mc.Count; i++)
        {
            string strRow = mc[i].Value;
            string[] strRows = strRow.Split('$');

            //创建表   
            if (tb == null)
            {
                tb = new DataTable();
                tb.TableName = "";
                foreach (string str in strRows)
                {
                    DataColumn dc = new DataColumn();
                    string[] strCell = str.Split('#');

                    if (strCell[0].Substring(0, 1) == "\"")
                    {
                        int a = strCell[0].Length;
                        dc.ColumnName = strCell[0].Substring(1, a - 2);
                    }
                    else
                    {
                        dc.ColumnName = strCell[0];
                    }
                    tb.Columns.Add(dc);
                }
                tb.AcceptChanges();
            }

            //增加内容   
            DataRow dr = tb.NewRow();
            for (int r = 0; r < strRows.Length; r++)
            {
                dr[r] = strRows[r].Split('#')[1].Trim().Replace("，", ",").Replace("：", ":").Replace("\"", "");
            }
            tb.Rows.Add(dr);
            tb.AcceptChanges();
        }

        return tb;
    }

    /// <summary>
    /// 将json转换为哈希集合
    /// </summary>
    /// <param name="strJson">得到的json</param>
    /// <returns></returns>
    public static List<Hashtable> JsonToHashList(string strJson)
    {
        List<Hashtable> list = new List<Hashtable>();
        //转换json格式
        strJson = strJson.Replace(",\"", "$\"").Replace("\":", "\"#").ToString();
        DataTable tb = null;
        //去除表名  

        strJson = strJson.Substring(strJson.IndexOf("[") + 1);
        strJson = strJson.Substring(0, strJson.IndexOf("]"));

        //获取数据   
        Regex rg = new Regex(@"(?<={)[^}]+(?=})");
        MatchCollection mc = rg.Matches(strJson);
        for (int i = 0; i < mc.Count; i++)
        {
            Hashtable hashtable = new Hashtable();
            string strRow = mc[i].Value;
            string[] strRows = strRow.Split('$');
            foreach (string str in strRows)
            {
                string key = "";
                string value = "";

                string[] strCell = str.Split('#');

                if (strCell[0].Substring(0, 1) == "\"")
                {
                    int a = strCell[0].Length;
                    key = strCell[0].Substring(1, a - 2);
                    value = strCell[1].Trim().Replace("，", ",").Replace("：", ":").Replace("\"", "");
                }
                else
                {
                    key = strCell[0];
                    value = strCell[1];
                }
                hashtable.Add(key, value);
            }
            list.Add(hashtable);
        }
        return list;
    }


    /// <summary>
    /// Msdn
    /// </summary>
    /// <param name="jsonName"></param>
    /// <param name="dt"></param>
    /// <returns></returns>
    public static string DataTableToJson(string jsonName, DataTable dt)
    {
        StringBuilder Json = new StringBuilder();
        Json.Append("{\"" + jsonName + "\":[");
        if (dt.Rows.Count > 0)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                Json.Append("{");
                for (int j = 0; j < dt.Columns.Count; j++)
                {
                    Json.Append("\"" + dt.Columns[j].ColumnName.ToString() + "\":\"" + dt.Rows[i][j].ToString() + "\"");
                    if (j < dt.Columns.Count - 1)
                    {
                        Json.Append(",");
                    }
                }
                Json.Append("}");
                if (i < dt.Rows.Count - 1)
                {
                    Json.Append(",");
                }
            }
        }
        Json.Append("]}");

        string strJson = Json.ToString();
        strJson = strJson.Substring(strJson.IndexOf("[") + 1);
        strJson = strJson.Substring(0, strJson.IndexOf("]"));
        return strJson;
    }




}