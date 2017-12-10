using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

/// <summary>
/// GridViewMergeHelper 的摘要说明
/// </summary>
public class GridViewMergeHelper
{

    public static void DataBoundWithEmptyRows(GridView gv)
    {
        for (int i = gv.Rows.Count + 1; i <= gv.PageSize; i++)
        {
            GridViewRow row = new GridViewRow(
                0,
                0,
                DataControlRowType.DataRow,
                (i % 2 > 0) ? DataControlRowState.Normal : DataControlRowState.Alternate);

            foreach (DataControlField field in gv.Columns)
            {
                TableCell cell = new TableCell();
                cell.Text = "&nbsp;";
                row.Cells.Add(cell);
            }

            if (gv.Controls.Count > 0)
            {
                gv.Controls[0].Controls.AddAt(i, row);
            }
        }
    }

    /// <summary>
    /// GridView合并
    /// </summary>
    /// <param name="gdv">GridView</param>
    /// <param name="startColumnIndex">起始列Index</param>
    /// <param name="endColumnIndex">结束列Index</param>
    public static void MergeGridViewRows(GridView gdv, int startColumnIndex, int endColumnIndex)
    {
        if (gdv == null || endColumnIndex < startColumnIndex || gdv.Rows.Count < 2)
            return;
        if (startColumnIndex < 0 || endColumnIndex > gdv.Columns.Count - 1)
            throw new ArgumentOutOfRangeException("列Index超出GridView可用列的范围。");
        EndColumnIndex = endColumnIndex;
        MergeCellWithSubColumn(gdv, 0, 0, gdv.Rows.Count - 1);
    }
    private static int EndColumnIndex = 0;

    /// <summary>
    /// 合并当前列和后续列
    /// </summary>
    /// <param name="currentColumnIndex">当前列</param>
    /// <param name="startRowIndex">起始行</param>
    /// <param name="endRowIndex">结束行</param>
    /// <summary>
    private static void MergeCellWithSubColumn(GridView gdv, int currentColumnIndex, int startRowIndex, int endRowIndex)
    {
        if (currentColumnIndex > EndColumnIndex)//结束递归
            return;
        string preValue = GetCellValue(gdv, startRowIndex, currentColumnIndex);
        string curValue = string.Empty;
        int endIndex = startRowIndex;
        for (int i = startRowIndex + 1; i <= endRowIndex + 1; i++)
        {
            if (i == endRowIndex + 1)
                curValue = null;//完成最后一次合并
            else
                curValue = GetCellValue(gdv, i, currentColumnIndex);
            if (curValue != preValue)
            {
                //合并当前列
                MergeColumnCell(gdv, currentColumnIndex, endIndex, i - 1);
                //合并后续列
                MergeCellWithSubColumn(gdv, currentColumnIndex + 1, endIndex, i - 1);
                endIndex = i;
                preValue = curValue;
            }
        }
    }

    /// <summary>
    /// 取得GridView中单个Cell的值
    /// </summary>
    /// <param name="gdv">GridView</param>
    /// <param name="rowIndex">行Index</param>
    /// <param name="columnIndex">列Index</param>
    /// <returns></returns>
    private static string GetCellValue(GridView gdv, int rowIndex, int columnIndex)
    {
        return gdv.Rows[rowIndex].Cells[columnIndex].Text;
    }

    /// <summary>
    /// 合并同列中连续的N个单元格
    /// 注意：这里只是隐藏后续的单元格，而没有删除单元格
    /// 主要考虑到删除后会如下两种情况：
    /// 1. PostBack后找不回来；
    /// 2.通过rowIndex和columnIndex来定位单元格的过程会更复杂
    /// </summary>
    /// <param name="gdv">GridView</param>
    /// <param name="columnIndex">列Index</param>
    /// <param name="startRowIndex">起始行Index</param>
    /// <param name="endRowIndex">结束行Index</param>
    private static void MergeColumnCell(GridView gdv, int columnIndex, int startRowIndex, int endRowIndex)
    {
        gdv.Rows[startRowIndex].Cells[columnIndex].RowSpan = endRowIndex - startRowIndex + 1;
        for (int i = startRowIndex + 1; i <= endRowIndex; i++)
            gdv.Rows[i].Cells[columnIndex].Visible = false;
    }
}
