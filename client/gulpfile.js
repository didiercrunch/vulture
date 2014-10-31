var bower = require('gulp-bower');
var gulp = require('gulp');
var coffee = require('gulp-coffee');
var help = require('gulp-task-listing');
var clean = require('gulp-clean');



gulp.task('help', help);

gulp.task('bower', function() {
   return bower()
        .pipe(gulp.dest('bower_components/'))
});

gulp.task('coffee', function() {
    gulp.src('coffee/**/*.coffee')
        .pipe(coffee({bare: true}))
        .pipe(gulp.dest('./js/'))
});

gulp.task('clean', function(){
    return gulp.src(["js/", "bower_components/"], {read: false})
        .pipe(clean())
});


gulp.task('default', ['bower', 'coffee']);



gulp.task('dev', ['bower', 'coffee'], function(){
    gulp.watch('coffee/**/*.coffee', ['coffee']);
});


