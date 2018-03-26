package com.linkage.zzk.base.util;

import net.coobird.thumbnailator.Thumbnails;

import java.io.File;

/**
 * @author: John
 */
public class ImageUtil {

    /**
     * 旋转角度
     *
     * @param src   原文件路径
     * @param dest  目标路径
     * @param angle 角度
     * @return
     */
    public static boolean rotate(String src, String dest, int angle) {
        try {
            //TODO
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 水印
     *
     * @param src       原文件路径
     * @param dest      目标路径
     * @param watermark 水印文件路径
     * @return
     */
    public static boolean watermark(String src, String dest, String watermark) {
        try {
            //TODO
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 裁剪
     *
     * @param src       原文件路径
     * @param dest      目标路径
     * @param width     宽
     * @param height    高
     * @return
     */
    public static boolean size(String src, String dest, int width, int height) {
        try {
            //TODO
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 裁剪旋转
     *
     * @param src
     * @param dest
     * @param x
     * @param y
     * @param scaleX
     * @param scaleY
     * @param width
     * @param height
     * @param rotate
     * @return
     */
    public static boolean size(String src, String dest, int x, int y, double scaleX, double scaleY,
                               int width, int height, double rotate, String format) {
        try {
            Thumbnails.of(new File(src))
                    .rotate(rotate)
                    .scale(scaleX, scaleY)
                    .sourceRegion(x, y, width, height)
                    .outputFormat(format)
                    .toFile(dest);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 原图比例压缩文件大小
     *
     * @param src       源文件路径
     * @param dest      目标路径
     * @param format    图片输出格式，如：jpg
     * @param scale     缩放比例，如：0.5、1、2
     * @param quality   图片压缩质量，如：0.25
     * @return
     */
    public static boolean quality(String src, String dest, String format, double scale, double quality) {
        try {
            Thumbnails.of(new File(src))
                    .scale(scale)
                    .outputQuality(quality)
                    .outputFormat(format)
                    .toFile(dest);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 原图比例压缩文件大小
     *
     * @param src       源文件路径
     * @param dest      目标路径
     * @param format    图片输出格式，如：jpg
     * @param width
     * @param height
     * @param quality   图片压缩质量，如：0.25
     * @return
     */
    public static boolean quality(String src, String dest, String format, int width, int height, double quality) {
        try {
            Thumbnails.of(new File(src))
                    .size(width, height)
                    .outputQuality(quality)
                    .outputFormat(format)
                    .toFile(dest);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

}
