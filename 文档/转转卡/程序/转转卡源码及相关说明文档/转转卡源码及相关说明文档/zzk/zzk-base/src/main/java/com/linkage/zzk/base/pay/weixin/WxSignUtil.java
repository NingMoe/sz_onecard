package com.linkage.zzk.base.pay.weixin;

import com.linkage.zzk.base.util.DigestUtil;
import com.linkage.zzk.base.util.StringUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * @author: John
 */
public class WxSignUtil {

    private static final Logger logger = LoggerFactory.getLogger(WxSignUtil.class);

    public static String getSign(Map<String, String> params, String signKey) {

        //生成key、value对，去空
        List<String> paramsList = new ArrayList<>();
        for (String key : params.keySet()) {
            String value = params.get(key);
            if (StringUtil.isNotBlank(value)) {
                paramsList.add(key + "=" + value);
            }
        }

        //排序
        Collections.sort(paramsList);

        //生成参数字符串并追加密钥
        StringBuffer sign = new StringBuffer();
        for (int i = 0; i < paramsList.size(); i++) {
            sign.append(i == 0 ? paramsList.get(i) : "&" + paramsList.get(i));
        }
        sign.append("&key=" + signKey);

        logger.info("排序后待签名参数：" + sign.toString());

        return DigestUtil.md5(sign.toString()).toUpperCase();
    }

}
