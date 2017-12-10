    // Constants:
    var MAXIMUM_NUMBER = 99999999999.99;
    // Predefine the radix characters and currency symbols for output:
    var CN_ZERO = "零";
    var CN_ONE = "壹";
    var CN_TWO = "贰";
    var CN_THREE = "叁";
    var CN_FOUR = "肆";
    var CN_FIVE = "伍";
    var CN_SIX = "陆";
    var CN_SEVEN = "柒";
    var CN_EIGHT = "捌";
    var CN_NINE = "玖";
    var CN_TEN = "拾";
    var CN_HUNDRED = "佰";
    var CN_THOUSAND = "仟";
    var CN_TEN_THOUSAND = "万";
    var CN_HUNDRED_MILLION = "亿";
    var CN_SYMBOL = "";
    var CN_DOLLAR = "圆";
    var CN_TEN_CENT = "角";
    var CN_CENT = "分";
    var CN_INTEGER = "整";

function sumCurrency(txtAmount1,txtAmount2,txtAmount3,txtAmount4,txtAmount5,txtTotal1,txtTotal2){
    var sum = 0.0;
    var el1 = document.getElementById(txtAmount1);
    if(el1.value)
        sum = sum + Number(el1.value);
        
    var el2 = document.getElementById(txtAmount2);
    if(el2.value)
        sum = sum + Number(el2.value);
        
    var el3 = document.getElementById(txtAmount3);
    if(el3.value)
        sum = sum + Number(el3.value);
        
    var el4 = document.getElementById(txtAmount4);
    if(el4.value)
        sum = sum + Number(el4.value);
        
    var el5 = document.getElementById(txtAmount5);
    if(el5.value)
        sum = sum + Number(el5.value);
        
    sum = Math.floor(sum*100)/100;
        
    var eltotal2 = document.getElementById(txtTotal2);
    eltotal2.value = sum;
    
    var cn_sum = convertCurrency(sum);
    var eltotal1 = document.getElementById(txtTotal1);
    eltotal1.value = cn_sum;
}


function sumCurrency(txtAmount1, txtAmount2, txtAmount3, txtTotal1, txtTotal2) {
    var sum = 0.0;
    var el1 = document.getElementById(txtAmount1);
    if (el1.value)
        sum = sum + Number(el1.value);

    var el2 = document.getElementById(txtAmount2);
    if (el2.value)
        sum = sum + Number(el2.value);

    var el3 = document.getElementById(txtAmount3);
    if (el3.value)
        sum = sum + Number(el3.value);

    

    sum = Math.floor(sum * 100) / 100;

    var eltotal2 = document.getElementById(txtTotal2);
    eltotal2.value = sum;

    var cn_sum = convertCurrency(sum);
    var eltotal1 = document.getElementById(txtTotal1);
    eltotal1.value = cn_sum;
}

function sumCurrency2(txtPrice1, txtPrice2, txtPrice3, txtNum1, txtNum2, txtNum3, txtAmount1, txtAmount2, txtAmount3, txtTotal1, txtTotal2) {
    var sum = 0.0;
    var price1 = document.getElementById(txtPrice1);
    var price2 = document.getElementById(txtPrice2);
    var price3 = document.getElementById(txtPrice3);
    var num1 = document.getElementById(txtNum1);
    var num2 = document.getElementById(txtNum2);
    var num3 = document.getElementById(txtNum3);
    var el1 = document.getElementById(txtAmount1);

    if (price1.value && num1.value)
        el1.value = Number(price1.value) * Number(num1.value);

    var el2 = document.getElementById(txtAmount2);
    if (price2.value && num2.value)
        el2.value = Number(price2.value) * Number(num2.value);

    var el3 = document.getElementById(txtAmount3);
    if (price3.value && num3.value)
        el3.value = Number(price3.value) * Number(num3.value);

    if (el1.value)
        sum = sum + Number(el1.value);
    if (el2.value)
        sum = sum + Number(el2.value);
    if (el3.value)
        sum = sum + Number(el3.value);
    sum = Math.floor(sum * 100) / 100;

    var eltotal2 = document.getElementById(txtTotal2);
    eltotal2.value = sum;

    var cn_sum = convertCurrency(sum);
    var eltotal1 = document.getElementById(txtTotal1);
    eltotal1.value = cn_sum;



}

    
function convertCurrency(currencyDigits) {

    // Variables:
    var integral; // Represent integral part of digit number.
    var decimal; // Represent decimal part of digit number.
    var outputCharacters; // The output result.
    var parts;
    var digits, radices, bigRadices, decimals;
    var zeroCount;
    var i, p, d;
    var quotient, modulus;

    // Validate input string:
    currencyDigits = currencyDigits.toString();
    if (currencyDigits == "") {
        alert("Empty input!");
        return "";
    }
    if (currencyDigits.match(/[^,.\d]/) != null) {
        alert("无效字符!");
        return "";
    }
    if ((currencyDigits).match(/^((\d{1,3}(,\d{3})*(.((\d{3},)*\d{1,3}))?)|(\d+(.\d+)?))$/) == null) {
        alert("格式错误");
        return "";
    }

    // Normalize the format of input digits:
    currencyDigits = currencyDigits.replace(/,/g, ""); // Remove comma delimiters.
    currencyDigits = currencyDigits.replace(/^0+/, ""); // Trim zeros at the beginning.
    // Assert the number is not greater than the maximum number.
    if (Number(currencyDigits) > MAXIMUM_NUMBER) {
        alert("金额太大");
        return "";
    }

    // Process the coversion from currency digits to characters:
    // Separate integral and decimal parts before processing coversion:
    parts = currencyDigits.split(".");
    if (parts.length > 1) {
        integral = parts[0];
        decimal = parts[1];
        // Cut down redundant decimal digits that are after the second.
        decimal = decimal.substr(0, 2);
    }
    else {
        integral = parts[0];
        decimal = "";
    }

    // Prepare the characters corresponding to the digits:
    digits = new Array(CN_ZERO, CN_ONE, CN_TWO, CN_THREE, CN_FOUR, CN_FIVE, CN_SIX, CN_SEVEN, CN_EIGHT, CN_NINE);
    radices = new Array("", CN_TEN, CN_HUNDRED, CN_THOUSAND);
    bigRadices = new Array("", CN_TEN_THOUSAND, CN_HUNDRED_MILLION);
    decimals = new Array(CN_TEN_CENT, CN_CENT);
    // Start processing:
    outputCharacters = "";
    // Process integral part if it is larger than 0:
    if (Number(integral) > 0) {
        zeroCount = 0;
        for (i = 0; i < integral.length; i++) {
            p = integral.length - i - 1;
            d = integral.substr(i, 1);
            quotient = p / 4;
            modulus = p % 4;
            if (d == "0") {
                zeroCount++;
            }
            else {
                if (zeroCount > 0)
                {
                    outputCharacters += digits[0];
                }
                zeroCount = 0;
                outputCharacters += digits[Number(d)] + radices[modulus];
            }
            if (modulus == 0 && zeroCount < 4) {
                outputCharacters += bigRadices[quotient];
            }
        }
        outputCharacters += CN_DOLLAR;
    }
    // Process decimal part if there is:
    if (decimal != "") {
        for (i = 0; i < decimal.length; i++) {
            d = decimal.substr(i, 1);
            if (d != "0") {
                outputCharacters += digits[Number(d)] + decimals[i];
            }
        }
    }

    // Confirm and return the final output string:
    if (outputCharacters == "") {
        outputCharacters = CN_ZERO + CN_DOLLAR;
    }
    if (decimal == "") {
        outputCharacters += CN_INTEGER;
    }
    outputCharacters = CN_SYMBOL + outputCharacters;
    
    return outputCharacters;
}