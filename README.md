# logstash-sample-mode
This is a basic emacs mode which is recreated version of logstash-conf-mode, for logstash filter.
I call it logstash-sample-mode so people won't get confused.

I took majority of the code from https://github.com/inlinechan/qmake-mode and the ruby-mode with some modification to make it work.

The latest version support most of the brackets matches. 
So far, it will indent your code correctly, however, it won't spot the incorrect bracket indentation.
As shown in the example blow: 

    filter{
      grok {
        match =>{
          "message" => [
          ]
          }
        ]
      }
    }

Version notes:

v0.0.1 Added basic match and indentation function.

v0.0.2 Fixed a lot of bugs when dealing with comment in same line as code. Also fixed the syntax table, so it will ignore braces in comment block.

Feature roadmap:

v0.1.0 Will hopefully fix the bracket mismatch (i.e. only correct indentation for correct brace match). and performance issue with large file (which is the whole point of creating this project), I think the key is replacing looking-back function.
