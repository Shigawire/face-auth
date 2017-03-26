// get the dependencies
var gulp        = require('gulp'), 
  childProcess  = require('child_process'), 
  electron      = require('electron');

var coffee = require('gulp-coffee'),
  concat = require('gulp-concat'),
  gutil = require('gulp-util'),
  changed = require('gulp-changed'),
  livereload = require('gulp-livereload'),
  lr = require('tiny-lr'),
  server = lr();

var options = {
    COFFEE_SOURCE   : "app/scripts/**/*.coffee",
    COFFEE_DEST     : "app/assets/js/",
};

// create the gulp task
gulp.task('run', function () { 
  childProcess.spawn(electron, ['--debug=5858','./app'], { stdio: 'inherit' }); 
});

// Transpile coffee to JavaScript
gulp.task('coffee', function () {
  gulp.src( options.COFFEE_SOURCE )
    .pipe(changed (options.COFFEE_SOURCE))
    .pipe(coffee())
    .pipe(gulp.dest(options.COFFEE_DEST))
    .on('error', gutil.log)
    .pipe(livereload(server));
});

// move bower_components files into the app
gulp.task('copy', function() {
  gulp.src([
    'bower_components/angular/angular.js',
    'bower_components/angular-ui-router/release/angular-ui-router.js',
    'bower_components/angular-resource/angular-resource.js',
    'bower_components/angular-animate/angular-animate.js',
    'bower_components/angular-aria/angular-aria.js',
    'bower_components/angular-material/angular-material.js',
    'bower_components/ngstorage/ngStorage.js',
    'bower_components/webcam/dist/webcam.min.js',
    'bower_components/angular-material/angular-material.css'
    ])
    .pipe(gulp.dest( options.COFFEE_DEST + 'libs' ));
});

gulp.task('watch', function () {
  server.listen( options.LIVE_RELOAD_PORT , function (err) {
    if (err) {
        return console.log(err)
    };
    gulp.watch(options.COFFEE_SOURCE , ['coffee']);
  });
});

gulp.task('build', ['coffee', 'copy']);