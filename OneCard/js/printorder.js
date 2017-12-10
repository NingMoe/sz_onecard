function printdiv(printpage)
{
    var headstr = "<html><head><title></title> \
    <style>                         \
        .juedui {                   \
    	margin-left: 0px;            \
        margin-top: 0px;             \
    	margin-right: 0px;           \
    	margin-bottom: 0px;          \
    	background-repeat: no-repeat;\
    	font-size: 14px;             \
    	position: absolute;          \
        }                               \
         .juedui_fapiao {                   \
    	margin-left: 0px;            \
        margin-top: 0px;             \
    	margin-right: 0px;           \
    	margin-bottom: 0px;          \
    	background-repeat: no-repeat;\
    	font-size: 11px;             \
    	position: absolute;          \
        }                               \
    </style>                        \
    </head><body>   ";

    var footstr = "</body></html>";
    var newstr = document.all(printpage).innerHTML;

    var printWin = open('', 'printWindow', 'left=10000,top=10000,width=0,height=0');

    printWin.document.write(headstr + newstr + footstr);
    printWin.document.close();
   
    printWin.document.body.insertAdjacentHTML("beforeEnd", " \
        <object id=\"printFactory\" style=\"display:none\"   \
         classid=\"clsid:1663ED61-23EB-11D2-B92F-008048FDD814\"> \
        </object>" + script);

    printWin.focus();
    if (printWin.printFactory.object) {
        printWin.printFactory.printing.Print(false);
    }
    else {
        printWin.print();
    }
    printWin.close();

    return false;
};


function printGridView(printpage) {
    var headstr = "<html><head><title>打印</title>  \
            <style>     \
                *{      \
                  font-size: 12px; \
                }\
                body{ \
                   padding:50 0 50 50px; \
                }   \
            </style>  \
            </head><body>";
    var footstr = "</body><ml>";
    var newstr = document.all(printpage).innerHTML;

    var printWin = open('', 'printWindow', 'left=50000,top=50000,width=0,height=0');

    printWin.document.write(headstr + newstr + footstr);
    printWin.document.close();
    printWin.document.body.insertAdjacentHTML("beforeEnd", " \
        <object id=\"printFactory\" style=\"\"   \
         classid=\"clsid:1663ED61-23EB-11D2-B92F-008048FDD814\"> \
        </object>");
    printWin.focus();
    if (printWin.printFactory.object) {
        printWin.printFactory.printing.Print(false);
    }
    else {
        printWin.print();
    }
    printWin.close();
    return false;
}

function printOrderdiv(printpage)
{
    var headstr = "<html><head><title></title> \
    <style>                         \
        .juedui {                   \
    	margin-left: 0px;            \
        margin-top: 0px;             \
    	margin-right: 0px;           \
    	margin-bottom: 0px;          \
    	background-repeat: no-repeat;\
    	font-size: 14px;             \
    	position: absolute;          \
        }                               \
         .juedui_fapiao {                   \
    	margin-left: 0px;            \
        margin-top: 0px;             \
    	margin-right: 0px;           \
    	margin-bottom: 0px;          \
    	background-repeat: no-repeat;\
    	font-size: 11px;             \
    	position: absolute;          \
        }                               \
        table.data {font-size: 90%; border-collapse: collapse; border: 0px solid black;}  \
        table.data th {background: #bddeff; width: 25em; text-align: left; padding-right: 8px; font-weight: normal; border: 1px solid black;}\
        table.data td {background: #ffffff; vertical-align:middle;padding: 0px 2px 0px 2px; border: 1px solid black;}\
    </style>                        \
    </head><body>   ";

    var footstr = "</body></html>";
    var newstr = document.all(printpage).innerHTML;

    var printWin = open('', 'printWindow', 'left=50000,top=50000,width=0,height=0');

    printWin.document.write(headstr + "<div class=juedui>" + newstr + "</div>" + footstr);
    printWin.document.close();
 var script ="<script>printFactory.printing.leftMargin = 0.1;printFactory.printing.topMargin = 0.1;printFactory.printing.rightMargin = 0.1;printFactory.printing.bottomMargin = 0.1;</script>";
    printWin.document.body.insertAdjacentHTML("beforeEnd", " \
        <object id=\"printFactory\" style=\"display:none\"   \
         classid=\"clsid:1663ED61-23EB-11D2-B92F-008048FDD814\"> \
        </object>");

    printWin.focus();
    if (printWin.printFactory.object) {
        printWin.printFactory.printing.Print(false);
    }
    else {
        printWin.print();
    }
    printWin.close();

    return false;
};