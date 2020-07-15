# logstash-sample-mode
logstash-conf-mode recreated version

I took most of the code from https://github.com/inlinechan/qmake-mode and the ruby-mode. 
As they are very close.

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
v0.0.1 Added basic match and indentation function
v0.0.2 Fixed a lot of bugs when dealing with comment in same line as code. Also fixed the syntax table, so it will ignore braces in comment block.

Feature roadmap:
v0.1.0 Will fix the bracket mismatch, (i.e. only correct indentation for correct brace match)