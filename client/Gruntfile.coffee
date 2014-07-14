module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig(
    packagekg: grunt.file.readJSON('package.json')
    bower:
      install:{}
    shell:
        bower:
            command: "node_modules/.bin/bower install"
    connect:
      server:
        options:
          port: 4506
          base: '.'
          keepalive: true

    clean:
        compiledFiles: ["js"]
        prod: [
               "node_modules",
               "bower_components/fontawesome/src",
               ]

    coffee:
      compile:
        expand: true
        cwd: 'coffee'
        src: ['**/*.coffee']
        dest: 'js'
        ext: '.js'

    watch: 
      coffee: 
        files: ['**/*.coffee']
        tasks: ['coffee']
        options:
          spawn: false
  
    concurrent:
        target: ['watch', 'connect'],

  )

  # Plugins
  grunt.loadNpmTasks('grunt-bower-task')
  grunt.loadNpmTasks('grunt-contrib-connect')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-concurrent')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-shell')

  # tasks
  grunt.registerTask('default', ['bower', 'clean:compiledFiles', 'coffee:compile'])
  grunt.registerTask('prod', ['shell:bower', 'clean:compiledFiles', 'coffee:compile', 'clean:prod'])
  grunt.registerTask('dev', ['default', 'concurrent:target'])
