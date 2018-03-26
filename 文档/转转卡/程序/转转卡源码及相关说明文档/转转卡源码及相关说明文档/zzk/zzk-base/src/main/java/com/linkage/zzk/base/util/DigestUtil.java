package com.linkage.zzk.base.util;

import org.apache.commons.codec.digest.DigestUtils;

/**
 * 摘要算法加密
 *
 * @author: John
 */
public class DigestUtil {

    public static String md5(String str) {
        return DigestUtils.md5Hex(str);
    }

    public static String sha1(String str) {
        return DigestUtils.sha1Hex(str);
    }

}
