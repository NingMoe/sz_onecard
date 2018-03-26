package com.linkage.zzk.base.dao;

/**
 * @author : John
 */
public class BaseDaoException extends RuntimeException {
	
	private static final long serialVersionUID = 6833040430665466384L;
	
	public BaseDaoException() {

	}

	public BaseDaoException(String arg0) {
		super(arg0);
	}

	public BaseDaoException(Throwable arg0) {
		super(arg0);
	}

	public BaseDaoException(String arg0, Throwable arg1) {
		super(arg0, arg1);
	}

}
