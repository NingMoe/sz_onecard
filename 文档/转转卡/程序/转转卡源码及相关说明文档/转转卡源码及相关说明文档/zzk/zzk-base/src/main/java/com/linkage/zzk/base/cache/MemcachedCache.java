package com.linkage.zzk.base.cache;

import net.spy.memcached.MemcachedClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Memcached支持
 *
 * @author: John
 */
public class MemcachedCache {

    private final Logger log = LoggerFactory.getLogger(getClass());

    private MemcachedClient memcachedClient;

    public MemcachedCache(MemcachedClient memcachedClient) {
        this.memcachedClient = memcachedClient;
    }

    public MemcachedClient getMemcachedClient() {
        return memcachedClient;
    }

    public void set(String key, Object value) {
        this.memcachedClient.set(key, 0, value);
    }

    public void set(String key, Object value, String expiration) {
        this.memcachedClient.set(key, CacheTime.parseDuration(expiration), value);
    }

    public Object get(String key) {
        return this.memcachedClient.get(key);
    }

    public long incr(String key, int by) {
        return this.memcachedClient.incr(key, by);
    }

    public long decr(String key, int by) {
        return this.memcachedClient.decr(key, by);
    }

    public void delete(String key) {
        this.memcachedClient.delete(key);
    }

}
