package com.linkage.zzk.base.cache;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 时间转换工具
 *
 * @author: John
 */
public class CacheTime {

    private static final Pattern days = Pattern.compile("^([0-9]+)d$");
    private static final Pattern hours = Pattern.compile("^([0-9]+)h$");
    private static final Pattern minutes = Pattern.compile("^([0-9]+)mi?n$");
    private static final Pattern seconds = Pattern.compile("^([0-9]+)s$");

    public static final int MINUTE_SECONDS= 60; //一分钟
    public static final int HOUR_SECONDS= MINUTE_SECONDS * 60; //一小时
    public static final int DAY_SECONDS= HOUR_SECONDS * 24; //一天
    private static final int DEFAULT_SECONDS = DAY_SECONDS;  //缓存默认时间24小时

    /**
     * 字符串转成秒
     *
     * @param cacheTimeStr
     * @return
     */
    public static int parseDuration(String cacheTimeStr) {

        if (cacheTimeStr == null) {
            return DEFAULT_SECONDS;
        }

        if (days.matcher(cacheTimeStr).matches()) {
            Matcher matcher = days.matcher(cacheTimeStr);
            matcher.matches();
            return Integer.parseInt(matcher.group(1)) * DAY_SECONDS;
        }

        if (hours.matcher(cacheTimeStr).matches()) {
            Matcher matcher = hours.matcher(cacheTimeStr);
            matcher.matches();
            return Integer.parseInt(matcher.group(1)) * HOUR_SECONDS;
        }

        if (minutes.matcher(cacheTimeStr).matches()) {
            Matcher matcher = minutes.matcher(cacheTimeStr);
            matcher.matches();
            return Integer.parseInt(matcher.group(1)) * MINUTE_SECONDS;
        }

        if (seconds.matcher(cacheTimeStr).matches()) {
            Matcher matcher = seconds.matcher(cacheTimeStr);
            matcher.matches();
            return Integer.parseInt(matcher.group(1));
        }

        throw new IllegalArgumentException("时间格式异常: " + cacheTimeStr);

    }

}
