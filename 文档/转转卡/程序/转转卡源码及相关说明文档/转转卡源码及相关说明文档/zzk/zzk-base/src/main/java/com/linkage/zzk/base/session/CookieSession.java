package com.linkage.zzk.base.session;

import org.apache.commons.codec.digest.Md5Crypt;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Session的客户端简单实现，便于集群部署
 * 受Cookie存储大小的限制，不适合存入大量数据
 *
 * 用法：
 *     Sessions session = new Sessions(request);
 *     session.put("uid", 23647820);
 *     session.flush(response);
 *
 *     session.get("uid");
 *
 * @author : John
 */
public class CookieSession {

    private final Logger logger = LoggerFactory.getLogger(getClass());

    private static final String DEFAULT_SESSION_KEY = "JOHN_SESSION";

    private String sessionKey = DEFAULT_SESSION_KEY;

    private static final String SESSION_SECRET = "SM1RkNhJNCHmBDlmSTCUCGBAfBA15uY1uewS9exhS9BmXhv1m80O739fzuBqjZer";

    private static final String SALT = "$1$S0enC4rX";

    private static final String EXPIRATION_KEY = "_expiration";

    private static final long DEFAULT_EXPIRATION = 1800000; //ms（默认30分钟）

    private long expiration = DEFAULT_EXPIRATION;

    private static Pattern sessionParser = Pattern.compile("\u0000([^:]*):([^\u0000]*)\u0000");

    private Map<String, String> data = new HashMap<String, String>();

    public CookieSession(HttpServletRequest request) {
        handle(request);
    }

    public CookieSession(HttpServletRequest request, String sessionKey) {
        if (sessionKey != null) {
            this.sessionKey = sessionKey;
        }
        handle(request);
    }

    public CookieSession(HttpServletRequest request, String sessionKey, long expiration) {
        if (sessionKey != null) {
            this.sessionKey = sessionKey;
        }
        if (expiration > 0) {
            this.expiration = expiration;
        }
        handle(request);
    }

    public void put(String key, String value) {
        if (key.contains(":")) {
            throw new IllegalArgumentException("Character ':' is invalid in a session key.");
        }
        if (value == null) {
            data.remove(key);
        } else {
            data.put(key, value);
        }
    }

    public void remove(String key) {
        data.remove(key);
    }

    public void clear() {
        data.clear();
    }

    public String get(String key) {
        return data.get(key);
    }

    public boolean contains(String key) {
        return data.containsKey(key);
    }

    public void flush(HttpServletResponse response) {
        response.addCookie(getSession());
    }

    private Cookie getSession() {
        try {
            //更新失效时间
            updateExpiration(expiration);
            //计算签名，写入Cookie
            StringBuilder session = new StringBuilder();
            for (String key : data.keySet()) {
                session.append("\u0000");
                session.append(key);
                session.append(":");
                session.append(data.get(key));
                session.append("\u0000");
            }
            String sessionData = URLEncoder.encode(session.toString(), "utf-8");
            String sign = sig(sessionData);

            Cookie cookie = new Cookie(sessionKey, sign + "-" + sessionData);
            cookie.setPath("/");
            cookie.setMaxAge(-1);

            return cookie;
        } catch (Exception e) {
            logger.info("Session exception：" + e.getMessage(), e);
            return null;
        }
    }

    private void handle(HttpServletRequest request) {
        try {
            //获取Cookie中保存的Session信息
            String cookieSessionValue = null;
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if (sessionKey.equals(cookie.getName())) {
                        cookieSessionValue = cookie.getValue();
                        break;
                    }
                }

                //解析、校验Session信息
                if (cookieSessionValue != null) {
                    int firstDashIndex = cookieSessionValue.indexOf("-");
                    if (firstDashIndex > -1) {
                        String sign = cookieSessionValue.substring(0, firstDashIndex);
                        String strData = cookieSessionValue.substring(firstDashIndex + 1);
                        if (sign.equals(sig(strData))) {
                            String sessionData = URLDecoder.decode(strData, "utf-8");
                            Matcher matcher = sessionParser.matcher(sessionData);
                            while (matcher.find()) {
                                this.put(matcher.group(1), matcher.group(2));
                            }
                        }
                    }
                }

                //校验Session失效时间
                if (this.contains(EXPIRATION_KEY)) {
                    if (Long.parseLong(this.get(EXPIRATION_KEY)) < System.currentTimeMillis()) {
                        this.clear();
                    }
                }

            }

        } catch (Exception e) {
            logger.info("Session exception：" + e.getMessage());
        }

    }

    private String sig(String data) {
        return Md5Crypt.md5Crypt((data + SESSION_SECRET).getBytes(), SALT);
    }

    private void updateExpiration(long expiration) {
        data.put(EXPIRATION_KEY, "" + (System.currentTimeMillis() + expiration));
    }

}
