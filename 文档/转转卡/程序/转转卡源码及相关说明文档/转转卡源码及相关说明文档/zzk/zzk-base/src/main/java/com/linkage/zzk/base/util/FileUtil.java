package com.linkage.zzk.base.util;

import org.apache.commons.io.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;

/**
 * 文件上传支持
 *
 * @author: John
 */
public class FileUtil {

    private Logger logger = LoggerFactory.getLogger(getClass());

    private String baseDir;

    private String subDir;

    /**
     * @param baseDir 根路径
     * @param subDir  子目录路径
     */
    public FileUtil(String baseDir, String subDir) {
        this.baseDir = baseDir;
        if (subDir.startsWith("/")) {
            this.subDir = subDir;
        } else {
            this.subDir = "/" + subDir;
        }
    }

    public String upload(File file) {
        String dayDir = new SimpleDateFormat("/yyyy/MM/dd").format(new Date());
        String dbDir = subDir + dayDir;
        String fullDir = baseDir + dbDir;
        String fileName = UUID.randomUUID().toString();
        try {
            File fullFileDir = new File(fullDir);
            if (!fullFileDir.exists()) {
                fullFileDir.mkdirs();
            }
            FileUtils.copyFile(file, new File(fullFileDir, fileName));
        } catch (IOException e) {
            logger.error("上传文件异常", e);
            return null;
        }
        return dbDir + "/" + fileName;
    }

    public String upload(MultipartFile file) {
        String dayDir = new SimpleDateFormat("/yyyy/MM/dd").format(new Date());
        String dbDir = subDir + dayDir;
        String fullDir = baseDir + dbDir;
        String fileName = UUID.randomUUID().toString();
        try {
            File fullFileDir = new File(fullDir);
            if (!fullFileDir.exists()) {
                fullFileDir.mkdirs();
            }
            file.transferTo(new File(fullFileDir, fileName));
        } catch (IOException e) {
            logger.error("上传文件异常", e);
            return null;
        }
        return dbDir + "/" + fileName;
    }

}
