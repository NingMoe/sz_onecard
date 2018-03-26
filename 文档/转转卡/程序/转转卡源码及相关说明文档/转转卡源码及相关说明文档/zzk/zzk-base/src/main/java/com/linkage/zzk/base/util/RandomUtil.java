package com.linkage.zzk.base.util;

/**
 * 随机数支持
 *
 * @author: John
 */
public class RandomUtil {

    private static final char[] numbers = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};

    private static final char[] chars = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
            'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};

    /**
     * 随机数值
     *
     * @param length
     * @return
     */
    public static String random(int length) {
        StringBuffer random = new StringBuffer();
        for (int i = 0; i < length; i++) {
            random.append(numbers[((int)(1000 * Math.random())) % numbers.length]);
        }
        return random.toString();
    }

    /**
     * 随机字符
     *
     * @param length
     * @return
     */
    public static String randomChars(int length) {
        StringBuffer random = new StringBuffer();
        for (int i = 0; i < length; i++) {
            random.append(chars[((int)(1000 * Math.random())) % chars.length]);

        }
        return random.toString();
    }

}
