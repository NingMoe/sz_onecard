//document.body.insertAdjacentHTML("beforeEnd", " \
//    <iframe name=\"idFrame\" width=\"0\" height=\"0\" src=\"Tools\\print\\printArea.html\"> \
//    </iframe>");
//
//document.body.insertAdjacentHTML("beforeEnd", " \
//    <object id=\"factory\" style=\"display:none\"  \
//     classid=\"clsid:1663ED61-23EB-11D2-B92F-008048FDD814\"> \
//    </object>");

document.body.insertAdjacentHTML("beforeEnd", " \
    <object id=\"SX_CARDOCX1\" classid=\"clsid:0362744E-0794-4020-B5B0-355ED58A736D\" width=\"0\" height=\"0\"> \
    </object>");
	
//function setupPrintEnv()
//{
//	if (factory.object) { 
//		factory.printing.header = "";
//		factory.printing.footer = "";
//		factory.printing.portrait = true;
//		factory.printing.leftMargin = 3.25;
//		factory.printing.topMargin = 8.47;
//		factory.printing.rightMargin = 3.1;
//		factory.printing.bottomMargin = 14.11;
//	}
//}
//
//function printTest()
//{
//	setupPrintEnv();
//	idFrame.document.body.innerHTML = PrintArea.innerHTML;
//	if (!factory.object) {
//	  // no install printx object
//		idFrame.focus();  idFrame.print();
//	}
//	else {
//		factory.printing.Print(false, idFrame);
//	}
//}


function readLogonTestCardNo(ctrlId) {
    try {
        var txtOperCardNo = document.getElementById(ctrlId);
        if (txtOperCardNo.value != "") return true;

        var errRet = SX_CARDOCX1.ReadOperCardNo();
        if (errRet != 0) {
            alert('ErrInfo:' + SX_CARDOCX1.ErrInfo + ', ErrCode:' + errRet);
            return false;
        }

        txtOperCardNo.value = SX_CARDOCX1.OperCardNo;
        return true;
    }
    catch (e) {
        return true;
    }
    
}

function readLogonCardNo(ctrlId) {
    try {
        var txtOperCardNo = document.getElementById(ctrlId);

        var errRet = SX_CARDOCX1.ReadOperCardNo();
        if (errRet != 0) {
            alert('ErrInfo:' + SX_CARDOCX1.ErrInfo + ', ErrCode:' + errRet);
            return false;
        }
        txtOperCardNo.value = SX_CARDOCX1.OperCardNo;
        return true;
    }
    catch (e) {
        return true;
    }
    
}
