gruntFunction = (grunt) ->
    gruntConfig =
        pkg:
            grunt.file.readJSON 'package.json'
    grunt.initConfig gruntConfig
    
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    null
    
module.exports = gruntFunction
