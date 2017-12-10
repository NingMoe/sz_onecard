using System;
using System.Data;
using Master;
using System.Web.UI.WebControls;
using TM;

namespace Common
{
    public class ControlDeal
    {
        public static void RowDataBound(GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                Object[] cells = null;

                DataRowView db = (DataRowView)e.Row.DataItem;
                cells = db.Row.ItemArray;
                for (int i = 0; i < cells.Length; ++i)
                {
                    if (cells[i] is DateTime)
                    {
                        e.Row.Cells[i].Text = ((DateTime)cells[i]).ToString("yyyy-MM-dd HH:mm:ss");
                    }
                    else if (cells[i] is Decimal)
                    {
                        e.Row.Cells[i].Text = ((Decimal)cells[i]).ToString("n");
                    }
                }
            }
        }
        
        private TMTableModule tmm;
        private CmnContext context;

        public ControlDeal(TMTableModule tm, CmnContext ct)
        {
            tmm = tm;
            context = ct;
        }
        public ControlDeal(CmnContext ct)
        {
            tmm = new TMTableModule();
            context = ct;
        }

        public void Select(DropDownList ddl, String sql, String errCode)
        {
            DataTable dataTable = tmm.selByPKDataTable(context, sql, 0);
            Object[] itemArray; ListItem li;
            for (int i = 0; i < dataTable.Rows.Count; ++i)
            {
                itemArray = dataTable.Rows[i].ItemArray;
                li = new ListItem((String)itemArray[0] + ":" + (String)itemArray[1], (String)itemArray[0]);
                ddl.Items.Add(li);
            }
            if (errCode != null)
            {
                context.AddError(errCode);
            }
        }

        public void Select(DDOBase ddo, DropDownList ddl, String text, String value, String errCode)
        {
            Object ddoArr = tmm.selByPKArr(context, ddo, errCode);

            ControlDeal.SelectBoxFill(ddl.Items, (DDOBase[])ddoArr, text, value, false);
        }
        public void SelectWithEmpty(DDOBase ddo, DropDownList ddl, String text, String value, String errCode)
        {
            Object ddoArr = tmm.selByPKArr(context, ddo, errCode);

            ControlDeal.SelectBoxFill(ddl.Items, (DDOBase[])ddoArr, text, value, true);
        }

        public void Select(Type ddoType, DropDownList ddl, String text, String value, String errCode)
        {
            DDOBase ddo = (DDOBase)Activator.CreateInstance(ddoType);
            Object ddoArr = tmm.selByPKArr(context, ddo, errCode);

            ControlDeal.SelectBoxFill(ddl.Items, (DDOBase[])ddoArr, text, value, false);
        }
        public void SelectWithEmpty(Type ddoType, DropDownList ddl, String text, String value, String errCode)
        {
            DDOBase ddo = (DDOBase)Activator.CreateInstance(ddoType);
            Object ddoArr = tmm.selByPKArr(context, ddo, errCode);

            ControlDeal.SelectBoxFill(ddl.Items, (DDOBase[])ddoArr, text, value, true);
        }

        public static void SelectBoxFill(ListItemCollection Items, DDOBase[] ddoDDOBaseArr, String textName, String valueName,Boolean emptFill)
        {
            SelectBoxFillWithCode(Items, ddoDDOBaseArr, textName, valueName, emptFill);
        }

        public static void SelectBoxFillWithCode(ListItemCollection Items, DDOBase[] ddoDDOBaseArr, String textName, String valueName, Boolean emptFill)
        {
            Items.Clear();

            if (emptFill)
                Items.Add(new ListItem("---请选择---", ""));

            foreach (DDOBase ddoDDOBase in ddoDDOBaseArr)
            {
                Items.Add(new ListItem( ddoDDOBase.GetString(valueName) + ":" + ddoDDOBase.GetString(textName), ddoDDOBase.GetString(valueName)));
            }
        }



    }
}
