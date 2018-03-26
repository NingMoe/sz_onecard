package com.linkage.zzk.base.util;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JavaType;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.List;

/**
 * @author: John
 */
public class JsonUtil {

    private static Logger logger = LoggerFactory.getLogger(JsonUtil.class);

    public static String toJson(Object obj) {
        try {
            return new ObjectMapper().writeValueAsString(obj);
        } catch (JsonProcessingException e) {
            logger.error("Json转换异常", e);
            return null;
        }
    }

    public static <T> T fromJson(String jsonContent, Class<T> valueType) {
        try {
            return new ObjectMapper().readValue(jsonContent, valueType);
        } catch (IOException e) {
            logger.error("Json转换异常", e);
            return null;
        }
    }

    public static <T> List<T> fromJsonForList(String jsonContent, Class<T> valueType) {
        ObjectMapper mapper = new ObjectMapper();
        JavaType javaType = mapper.getTypeFactory().constructParametricType(List.class, valueType);
        try {
            return (List<T>)mapper.readValue(jsonContent, javaType);
        } catch (IOException e) {
            logger.error("Json转换异常", e);
            return null;
        }
    }



}
