package com.linkage.zzk.h5.common.interceptor;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.StopWatch;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 所有请求执行时间拦截器
 *
 * @author : John
 */
public class RequestExecuteTimeInterceptor implements HandlerInterceptor {

    private static Logger logger = LoggerFactory.getLogger(RequestExecuteTimeInterceptor.class);

    private ThreadLocal<StopWatch> stopWatchLocal = new ThreadLocal<StopWatch>();

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response,
                             Object handler) throws Exception {

        StopWatch stopWatch = new StopWatch();
        stopWatch.start();
        stopWatchLocal.set(stopWatch);

        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response,
                           Object handler, ModelAndView modelAndView) throws Exception {

    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response,
                                Object handler, Exception ex) throws Exception {

        //计算请求处理时间（毫秒)
        StopWatch stopWatch = stopWatchLocal.get();
        stopWatch.stop();
        Long totalTime = stopWatch.getTotalTimeMillis();

        logger.info("###请求地址:" + request.getRequestURI() +
                (request.getQueryString() == null ? "" : "?" + request.getQueryString()) +
                ", 执行时间总计:" + totalTime + "ms\n");

    }

}
