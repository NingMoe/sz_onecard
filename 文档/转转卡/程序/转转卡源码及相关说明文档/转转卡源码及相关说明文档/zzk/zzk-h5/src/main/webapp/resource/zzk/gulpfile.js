var gulp = require('gulp');
var postcss = require('gulp-postcss');
var px2rem = require('postcss-px2rem');
var connect = require('gulp-connect');
// var cssnano = require('gulp-cssnano');
let cleanCSS = require('gulp-clean-css');
// var cssBase64 = require('gulp-css-base64');

var base64 = require('gulp-base64');
var concat = require('gulp-concat');

//创建watch任务去检测html文件,其定义了当html改动之后，去调用一个Gulp的Task
gulp.task('watch', function () {
  gulp.watch(['./css/base.css'], ['css']);
});
//使用postcss px2rem 得到rem
gulp.task('css', function() {
    var processors = [px2rem({remUnit: 75})];
    return gulp.src(['./css/normalize.css', './css/base.css'])
				.pipe(postcss(processors))
        // .pipe(cssnano())
        .pipe(cleanCSS({compatibility: 'ie8'}))
				.pipe(base64())	
				.pipe(concat('base.css'))			
        .pipe(gulp.dest('./dest'));
});
//使用connect启动一个Web服务器
// gulp.task('connect',function(){
// 	connect.server({
// 		root:'public',
// 		port:'8000',
// 		livereload: true
// 	})
// });
//html任务
// gulp.task('html',function(){
// 	gulp.src('./public/html/*.html')
// 	.pipe(connect.reload());
// });
//运行gulp 默认的Task
// 
gulp.task('default',['css'])