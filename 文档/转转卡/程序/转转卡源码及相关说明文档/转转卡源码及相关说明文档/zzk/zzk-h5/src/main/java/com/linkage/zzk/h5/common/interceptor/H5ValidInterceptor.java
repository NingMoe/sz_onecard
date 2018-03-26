package com.linkage.zzk.h5.common.interceptor;

import com.linkage.zzk.base.session.CookieSession;
import com.linkage.zzk.base.util.StringUtil;
import com.linkage.zzk.h5.common.conf.AppConfig;
import com.linkage.zzk.h5.domain.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Map;

/**
 * 登录用户拦截处理
 *
 * @author : John
 */
public class H5ValidInterceptor implements HandlerInterceptor {

    private static Logger logger = LoggerFactory.getLogger(H5ValidInterceptor.class);

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response,
                             Object handler) throws Exception {

        Map<String, String[]> paramsMap = request.getParameterMap();
        for (String key : paramsMap.keySet()) {
            request.setAttribute(key, paramsMap.get(key)[0]);
        }

        CookieSession session = new CookieSession(request, AppConfig.SESSION_KEY);
        String userId = session.get("userId");
        if (StringUtil.isNotBlank(userId)) {
            request.setAttribute("loginUser", new User(userId, session.get("openId")));
            session.flush(response);
        }
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response,
                           Object handler, ModelAndView modelAndView) throws Exception {


    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response,
                                Object handler, Exception ex) throws Exception {

    }
}
