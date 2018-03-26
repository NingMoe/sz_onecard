package com.linkage.zzk.base.util;

import org.apache.commons.lang3.StringUtils;

/**
 * @author: John
 */
public class StringUtil {

    /**
     * 判断字符串是否为空
     *
     * @param str
     * @return
     */
    public static boolean isBlank(String str) {
        return StringUtils.isBlank(str);
    }

    public static boolean isNotBlank(String str) {
        return StringUtils.isNotBlank(str);
    }

}
