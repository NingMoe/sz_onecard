using System;
using System.Collections.Generic;
using System.Text;

using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using NPOI.HSSF.UserModel;
using NPOI.HPSF;
using NPOI.HSSF.Util;

public class ExcelHelper
{


    //public static DataTable GetReportTypeByDepartment()
    //{
    //    return GetDataTable(" Select * from TradeReport ", CommandType.Text, null);

    //}


    /// <summary>
    /// 根据参数返回DataTable
    /// </summary>
    /// <param name="Sql"></param>
    /// <param name="cmdType"></param>
    /// <param name="paras"></param>
    /// <returns></returns>
    //private static DataTable GetDataTable(string Sql, CommandType cmdType, SqlParameter[] paras)
    //{
    //    if (cmdType == CommandType.Text)
    //    {
    //        return SqlHelper.ExecuteDataTable(Globals.DatabaseConnectionString, CommandType.Text, Sql);
    //    }
    //    else //if (cmdType == CommandType.StoredProcedure)
    //    {
    //        return SqlHelper.ExecuteDataTable(Globals.DatabaseConnectionString, CommandType.StoredProcedure, Sql, paras);
    //    }
    //}


    /// <summary>
    /// 利用模板，DataTable导出到Excel1
    /// </summary>
    /// <param name="dtSource">DataTable</param>
    /// <param name="strFileName">生成的文件路径、名称</param>
    /// <param name="strTemplateFileName">模板的文件路径、名称</param>
    /// <param name="sheetName">sheet名</param>
    /// <param name="titleName">表头名称</param>
    /// <param name="rowIndex">起始行</param>
    public static void ExportExcelForDtByNPOI(DataTable dtSource, string strFileName, string strTemplateFileName, string sheetName, string titleName, int rowIndex)
    {
        // 利用模板，DataTable导出到Excel（单个类别）
        using (MemoryStream ms = ExportExcelForDtByNPOI(dtSource, strTemplateFileName, sheetName, titleName, rowIndex))
        {
            ////using (FileStream fs = new FileStream(strFileName, FileMode.Create, FileAccess.Write))
            ////{
            byte[] data = ms.ToArray();
            //fs.Write(data, 0, data.Length);

            #region 客户端保存
            HttpResponse response = System.Web.HttpContext.Current.Response;
            response.Clear();
            //Encoding pageEncode = Encoding.GetEncoding(PageEncode);
            response.Charset = "UTF-8";
            response.ContentType = "application/vnd-excel";//"application/vnd.ms-excel";
            System.Web.HttpContext.Current.Response.AddHeader("Content-Disposition", string.Format("attachment; filename=" + strFileName));
            System.Web.HttpContext.Current.Response.BinaryWrite(data);
            #endregion
            string destFileName = @"D:\test.xls";
            try
            {
                System.IO.File.WriteAllBytes(destFileName, data);
            }
            catch
            {
            }
            ////    fs.Flush();
            ////}
        }
    }

    public static void SaveExcel(MemoryStream ms)
    {
        using (ms)
        {
            ////using (FileStream fs = new FileStream(strFileName, FileMode.Create, FileAccess.Write))
            ////{
            byte[] data = ms.ToArray();
            //fs.Write(data, 0, data.Length);

            #region 客户端保存
            HttpResponse response = System.Web.HttpContext.Current.Response;
            response.Clear();
            //Encoding pageEncode = Encoding.GetEncoding(PageEncode);
            response.Charset = "UTF-8";
            response.ContentType = "application/vnd-excel";//"application/vnd.ms-excel";
            System.Web.HttpContext.Current.Response.AddHeader("Content-Disposition", string.Format("attachment; filename=ttttt.xls"));
            System.Web.HttpContext.Current.Response.BinaryWrite(data);
            #endregion
        }
    }

    public static MemoryStream NPOI(MemoryStream ms, FileStream file, DataTable dt, string sheetName, string titleName, int rowIndex)
    {
        //MemoryStream ms = new MemoryStream();

        #region 处理DataTable,处理明细表中没有而需要额外读取汇总值的两列

        #endregion
        int totalIndex = 50;                        // 每个类别的总行数
        rowIndex = rowIndex - 1;                    // 起始行 索引0开始，减1
        int dtRowIndex = dt.Rows.Count;       // DataTable的数据行数

        HSSFWorkbook workbook = new HSSFWorkbook(file);
        HSSFSheet sheet = workbook.GetSheet(sheetName);


        #region 表头
        HSSFRow headerRow = sheet.GetRow(0);
        HSSFCell headerCell = headerRow.GetCell(0);
        //headerCell.SetCellValue(titleName);
        #endregion

        foreach (DataRow row in dt.Rows)
        {
            #region 填充内容
            HSSFRow dataRow = sheet.GetRow(rowIndex);

            int columnIndex = 1;        // 开始列（0为标题列，从1开始）
            foreach (DataColumn column in dt.Columns)
            {
                // 列序号赋值
                if (columnIndex > dt.Columns.Count)
                    break;

                HSSFCell newCell = dataRow.GetCell(columnIndex);
                if (newCell == null)
                    newCell = dataRow.CreateCell(columnIndex);

                string drValue = row[column].ToString();

                switch (column.DataType.ToString())
                {
                    case "System.String"://字符串类型
                        newCell.SetCellValue(drValue);
                        break;
                    case "System.DateTime"://日期类型
                        DateTime dateV;
                        DateTime.TryParse(drValue, out dateV);
                        newCell.SetCellValue(dateV);

                        break;
                    case "System.Boolean"://布尔型
                        bool boolV = false;
                        bool.TryParse(drValue, out boolV);
                        newCell.SetCellValue(boolV);
                        break;
                    case "System.Int16"://整型
                    case "System.Int32":
                    case "System.Int64":
                    case "System.Byte":
                        int intV = 0;
                        int.TryParse(drValue, out intV);
                        newCell.SetCellValue(intV);
                        break;
                    case "System.Decimal"://浮点型
                    case "System.Double":
                        double doubV = 0;
                        double.TryParse(drValue, out doubV);
                        newCell.SetCellValue(doubV);
                        break;
                    case "System.DBNull"://空值处理
                        newCell.SetCellValue("");
                        break;
                    default:
                        newCell.SetCellValue("");
                        break;
                }
                columnIndex++;
            }
            #endregion

            rowIndex++;
        }


        // 格式化当前sheet，用于数据total计算
        sheet.ForceFormulaRecalculation = true;

        #region Clear "0"
        System.Collections.IEnumerator rows = sheet.GetRowEnumerator();

        int cellCount = headerRow.LastCellNum;

        for (int i = (sheet.FirstRowNum + 1); i <= sheet.LastRowNum; i++)
        {
            HSSFRow row = sheet.GetRow(i);
            if (row != null)
            {
                for (int j = row.FirstCellNum; j < cellCount; j++)
                {
                    HSSFCell c = row.GetCell(j);
                    if (c != null)
                    {
                        switch (c.CellType)
                        {
                            case HSSFCellType.NUMERIC:
                                if (c.NumericCellValue == 0)
                                {
                                    c.SetCellType(HSSFCellType.STRING);
                                    c.SetCellValue(string.Empty);
                                }
                                break;
                            case HSSFCellType.BLANK:

                            case HSSFCellType.STRING:
                                if (c.StringCellValue == "0")
                                { c.SetCellValue(string.Empty); }
                                break;

                        }
                    }
                }

            }

        }
        #endregion

        using (ms)
        {
            workbook.Write(ms);
            //ms.Flush();
            //ms.Position = 0;
            sheet = null;
            workbook = null;


            //sheet.Dispose();
            //workbook.Dispose();//一般只用写这一个就OK了，他会遍历并释放所有资源，但当前版本有问题所以只释放sheet
        }

        return ms;
    }

    /// <summary>
    /// 利用模板，DataTable导出到Excel2
    /// </summary>
    /// <param name="dtSource">DataTable</param>
    /// <param name="strTemplateFileName">模板的文件路径、名称</param>
    /// <param name="sheetName">sheet名</param>
    /// <param name="titleName">表头名称</param>
    /// <param name="rowIndex">起始行</param>
    /// <returns></returns>
    public static MemoryStream ExportExcelForDtByNPOI(DataTable dtSource, string strTemplateFileName, string sheetName, string titleName, int rowIndex)
    {
        
        MemoryStream ms = new MemoryStream();
        //string filePath = @"D:\test.xls";
        //if (System.IO.File.Exists(@"D:\test.xls"))
        //{
        //    strTemplateFileName = filePath;
        //    FileStream file1 = new FileStream(filePath, FileMode.Open, FileAccess.Read);//读入excel

        //}
        //#region 处理DataTable,处理明细表中没有而需要额外读取汇总值的两列

        //#endregion
        //int totalIndex = 50;                        // 每个类别的总行数
        //rowIndex = rowIndex - 1;                    // 起始行 索引0开始，减1
        //int dtRowIndex = dtSource.Rows.Count;       // DataTable的数据行数

        FileStream file = new FileStream(strTemplateFileName, FileMode.Open, FileAccess.Read);//读入excel模板

        ms = NPOI(ms, file, dtSource, sheetName, titleName, rowIndex);
        //HSSFWorkbook workbook = new HSSFWorkbook(file);
        //HSSFSheet sheet = workbook.GetSheet(sheetName);

        #region 右击文件 属性信息
        //{
        //    DocumentSummaryInformation dsi = PropertySetFactory.CreateDocumentSummaryInformation();
        //    dsi.Company = "农发集团";
        //    workbook.DocumentSummaryInformation = dsi;

        //    SummaryInformation si = PropertySetFactory.CreateSummaryInformation();
        //    si.Author = "农发集团"; //填加xls文件作者信息
        //    si.ApplicationName = "瞬时达"; //填加xls文件创建程序信息
        //    si.LastAuthor = "瞬时达"; //填加xls文件最后保存者信息
        //    si.Comments = "瞬时达"; //填加xls文件作者信息
        //    si.Title = "农发集团报表"; //填加xls文件标题信息
        //    si.Subject = "农发集团报表";//填加文件主题信息
        //    si.CreateDateTime = DateTime.Now;
        //    workbook.SummaryInformation = si;
        //}
        #endregion

        #region 表头
        //HSSFRow headerRow = sheet.GetRow(0);
        //HSSFCell headerCell = headerRow.GetCell(0);
        //headerCell.SetCellValue(titleName);
        #endregion

        // 隐藏多余行
        //for (int i = rowIndex + dtRowIndex; i < rowIndex + totalIndex; i++)
        //{
        //    HSSFRow dataRowD = sheet.GetRow(i);
        //    dataRowD.Height = 0;
        //    dataRowD.ZeroHeight = true;
        //    //sheet.RemoveRow(dataRowD);
        //}

        //foreach (DataRow row in dtSource.Rows)
        //{
        //    #region 填充内容
        //    HSSFRow dataRow = sheet.GetRow(rowIndex);

        //    int columnIndex = 1;        // 开始列（0为标题列，从1开始）
        //    foreach (DataColumn column in dtSource.Columns)
        //    {
        //        // 列序号赋值
        //        if (columnIndex > dtSource.Columns.Count)
        //            break;

        //        HSSFCell newCell = dataRow.GetCell(columnIndex);
        //        if (newCell == null)
        //            newCell = dataRow.CreateCell(columnIndex);

        //        string drValue = row[column].ToString();

        //        switch (column.DataType.ToString())
        //        {
        //            case "System.String"://字符串类型
        //                newCell.SetCellValue(drValue);
        //                break;
        //            case "System.DateTime"://日期类型
        //                DateTime dateV;
        //                DateTime.TryParse(drValue, out dateV);
        //                newCell.SetCellValue(dateV);

        //                break;
        //            case "System.Boolean"://布尔型
        //                bool boolV = false;
        //                bool.TryParse(drValue, out boolV);
        //                newCell.SetCellValue(boolV);
        //                break;
        //            case "System.Int16"://整型
        //            case "System.Int32":
        //            case "System.Int64":
        //            case "System.Byte":
        //                int intV = 0;
        //                int.TryParse(drValue, out intV);
        //                newCell.SetCellValue(intV);
        //                break;
        //            case "System.Decimal"://浮点型
        //            case "System.Double":
        //                double doubV = 0;
        //                double.TryParse(drValue, out doubV);
        //                newCell.SetCellValue(doubV);
        //                break;
        //            case "System.DBNull"://空值处理
        //                newCell.SetCellValue("");
        //                break;
        //            default:
        //                newCell.SetCellValue("");
        //                break;
        //        }
        //        columnIndex++;
        //    }
        //    #endregion

        //    rowIndex++;
        //}


        //// 格式化当前sheet，用于数据total计算
        //sheet.ForceFormulaRecalculation = true;

        //#region Clear "0"
        //System.Collections.IEnumerator rows = sheet.GetRowEnumerator();

        //int cellCount = headerRow.LastCellNum;

        //for (int i = (sheet.FirstRowNum + 1); i <= sheet.LastRowNum; i++)
        //{
        //    HSSFRow row = sheet.GetRow(i);
        //    if (row != null)
        //    {
        //        for (int j = row.FirstCellNum; j < cellCount; j++)
        //        {
        //            HSSFCell c = row.GetCell(j);
        //            if (c != null)
        //            {
        //                switch (c.CellType)
        //                {
        //                    case HSSFCellType.NUMERIC:
        //                        if (c.NumericCellValue == 0)
        //                        {
        //                            c.SetCellType(HSSFCellType.STRING);
        //                            c.SetCellValue(string.Empty);
        //                        }
        //                        break;
        //                    case HSSFCellType.BLANK:

        //                    case HSSFCellType.STRING:
        //                        if (c.StringCellValue == "0")
        //                        { c.SetCellValue(string.Empty); }
        //                        break;

        //                }
        //            }
        //        }

        //    }

        //}
        //#endregion
        //using (ms)
        //{
        //    workbook.Write(ms);
        //    ms.Flush();
        //    ms.Position = 0;
        //    sheet = null;
        //    workbook = null;


        //    //sheet.Dispose();
        //    //workbook.Dispose();//一般只用写这一个就OK了，他会遍历并释放所有资源，但当前版本有问题所以只释放sheet
        //}
        return ms;
    }





}



