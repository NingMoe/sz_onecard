package com.onecard.tourcard.util.security;

import org.junit.Test;

import java.util.Map;
import java.util.Map.Entry;
import java.util.TreeMap;

public class SignUtil {

    /**
     * 创建签名
     *
     * @param map
     * @return
     */
    public static String createSign(Map<String, String> map, String key) {
        StringBuilder signsb = new StringBuilder();
        for (Entry<String, String> e : map.entrySet()) {
            String value = e.getValue();
            if (StringUtil.isNullOrEmpty(value)) {
                continue;
            }
            if ("token".equals(e.getKey())) {
                continue;
            }
            signsb.append(e.getKey());
            signsb.append("=");
            signsb.append(value);
            signsb.append("&");
        }
        signsb.append("key=" + key);
        System.out.println(signsb);
        return signsb.toString();
    }
    /**
     * add by dzq
     *
     * 生成签名
     * @param map
     * @param key 即token 其中英文要全部转为大写
     * @return
     */
    public static String generateSign(Map<String, String> map, String key) {
        String sign = createSign(map,key.toUpperCase());
        String signature = Md5Util.md5Hash(sign).toUpperCase();
        return signature;
    }

    /**
     *
     * token认证
     * @param beanmap
     * @return
     */
    public static boolean checkSignature(String apikeyDB,TreeMap<String, String> beanmap){

        String token = beanmap.get("token");
        //token验证
        String retSign = Md5Util.md5Hash(SignUtil.createSign(beanmap, apikeyDB.toUpperCase())).toUpperCase();
        System.out.println("加密转换后的秘钥(token)： "+ retSign);
        if (!retSign.equals(token)) {
            return false;
        }
        return true;
    }

    @Test
    public void test(){
        TreeMap<String, String> map = new TreeMap<String, String>();
        map.put("channelId", "000001");
        map.put("deviceId", "string");
        map.put("nonce", "string");
        map.put("openId", "1B01D1D1-7683-45AC-A1CC-B8DA6B75F495");
        map.put("pageNumber", "0");
        map.put("pageSize", "10");
        map.put("timestamp", "string");
        map.put("tradeType", "1");
        String key = "6210EBCB-CCB6-4DF0-BF48-493874DE6999";
        System.out.println(generateSign(map,key));//74E34F0683231D1532DB06341B0E4784

    }
}
