using System;
using System.Data;
using TDO;
using DAO;
using TDO.ResourceManager;
using Master;

namespace TM.ResourceManager
{
    public class TD_M_RESOURCESTATETM
    {
        public TD_M_RESOURCESTATETM()
        {
        }

        public DataTable selByPK()
        {
            CmnContext context = new CmnContext();
            TD_M_RESOURCESTATETDO a_ddoTD_M_RESOURCESTATEIn = new TD_M_RESOURCESTATETDO();
            SelectDAO daoSelect = new SelectDAO();
            DataTable dTable = daoSelect.selDataTable(context, a_ddoTD_M_RESOURCESTATEIn, "TD_M_RESOURCESTATE");

            return dTable;
        }
    }
}
