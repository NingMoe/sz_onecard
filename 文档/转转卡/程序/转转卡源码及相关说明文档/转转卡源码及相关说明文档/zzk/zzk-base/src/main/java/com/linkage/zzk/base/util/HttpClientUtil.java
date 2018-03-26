package com.linkage.zzk.base.util;

import org.apache.http.Consts;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.entity.EntityBuilder;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * HttpClient支持类
 *
 * @author : John
 */
public class HttpClientUtil {

    private final Logger logger = LoggerFactory.getLogger(getClass());

    public String post(String url) {
        return post(url, "");
    }

    public String post(String url, Map<String, Object> params) {

        CloseableHttpClient httpclient = HttpClients.createDefault();
        try {

            HttpPost httppost = new HttpPost(url);
            httppost.setConfig(requestConfig());

            //请求参数处理
            if (params != null && !params.isEmpty()) {
                logger.info("请求参数：" + new JsonUtil().toJson(params));
                List<NameValuePair> formParams = new ArrayList<NameValuePair>();
                for (String key : params.keySet()) {
                    Object value = params.get(key);
                    formParams.add(new BasicNameValuePair(key, value == null ? "" : value.toString()));
                }
                UrlEncodedFormEntity formEntity = new UrlEncodedFormEntity(formParams, Consts.UTF_8);
                httppost.setEntity(formEntity);
            }

            logger.info("请求地址：" + httppost.getRequestLine());

            return httpclient.execute(httppost, responseHandler());
        } catch (Exception e) {
            logger.error("请求异常", e);
        } finally {
            try {
                httpclient.close();
            } catch (IOException e) {
                logger.error("请求异常", e);
            }
        }
        return null;
    }

    public String post(String url, String jsonEntity) {

        logger.info("请求参数：" + jsonEntity);
        CloseableHttpClient httpclient = HttpClients.createDefault();
        try {
            HttpPost httppost = new HttpPost(url);
            httppost.setConfig(requestConfig());
            //请求体编码设置
            if (jsonEntity != null && !"".equals(jsonEntity.trim())) {
                httppost.setHeader("Content-Type", "application/json; charset=UTF-8");
                StringEntity strEntity = new StringEntity(jsonEntity, Consts.UTF_8);
                httppost.setEntity(strEntity);
            }
            logger.info("请求地址：" + httppost.getRequestLine());
            return httpclient.execute(httppost, responseHandler());
        } catch (Exception e) {
            logger.error("请求异常", e);
        } finally {
            try {
                httpclient.close();
            } catch (IOException e) {
                logger.error("请求异常", e);
            }
        }
        return null;
    }

    public String get(String url) {
        return get(url, null);
    }

    public String get(String url, Map<String, String> params) {

        CloseableHttpClient httpclient = HttpClients.createDefault();
        try {
            //URL追加请求参数
            StringBuffer sb = new StringBuffer(url);
            if (params != null && !params.isEmpty()) {
                if (sb.indexOf("?") == -1) {
                    sb.append("?");
                }
                for (String key : params.keySet()) {
                    String value = URLEncoder.encode(params.get(key), "UTF-8");
                    if (sb.toString().endsWith("?")) {
                        sb.append(key + "=" + value);
                    } else {
                        sb.append("&" + key + "=" + value);
                    }
                }
            }

            HttpGet httpget = new HttpGet(sb.toString());
            httpget.setConfig(requestConfig());

            logger.info("请求地址：" + httpget.getRequestLine());

            return httpclient.execute(httpget, responseHandler());

        } catch (Exception e) {
            logger.error("请求异常", e);
        } finally {
            try {
                httpclient.close();
            } catch (IOException e) {
                logger.error("请求异常", e);
            }
        }

        return null;

    }

    private RequestConfig requestConfig() {
        return RequestConfig.custom()
                .setConnectTimeout(5000)
                .setConnectionRequestTimeout(1000)
                .setSocketTimeout(5000)
                .build();
    }

    private ResponseHandler<String> responseHandler() {
        return new ResponseHandler<String>() {
            @Override
            public String handleResponse(final HttpResponse response) throws IOException {

                int status = response.getStatusLine().getStatusCode();
                if (status == 200) {
                    HttpEntity entity = response.getEntity();

                    String result = entity != null ? EntityUtils.toString(entity) : null;

                    logger.info("响应内容：" + result + "\n");

                    return result;
                }

                logger.info("响应内容：" + status + ", " + response.toString() + "\n");
                return null;
            }
        };
    }

}
