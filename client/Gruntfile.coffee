module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig(
    packagekg: grunt.file.readJSON('package.json')
    bower:
      install: {}

    connect:
      server:
        options:
          port: 4506
          base: '.'
          keepalive: true
    
    clean: ["js"]

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

  # tasks
  grunt.registerTask('default', ['bower:install', 'clean', 'coffee:compile'])
  grunt.registerTask('dev', ['default', 'concurrent:target'])
