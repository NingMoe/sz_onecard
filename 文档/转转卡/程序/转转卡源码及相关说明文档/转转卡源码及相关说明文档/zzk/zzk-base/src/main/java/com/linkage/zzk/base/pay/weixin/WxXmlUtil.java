package com.linkage.zzk.base.pay.weixin;

import java.util.Map;

/**
 * @author: John
 */
public class WxXmlUtil {

    public static String getXml(Map<String, String> params) {
        StringBuffer xml = new StringBuffer("<xml>");
        for (String key : params.keySet()) {
            if ("sign".equals(key)) {
                xml.append("<" + key + ">" + params.get(key) + "</" + key + ">");
            } else {
                xml.append("<" + key + "><![CDATA[" + params.get(key) + "]]></" + key + ">");
            }
        }
        xml.append("</xml>");
        return xml.toString();
    }

}
