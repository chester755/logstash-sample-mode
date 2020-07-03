# logstash-sample-mode
logstash-conf-mode recreated version

I took most of the code from https://github.com/inlinechan/qmake-mode.
Added the correct support plugins and indentation for square, round and curly bracket.

So far, it will indent your code correctly, however, it won't spot the incorrect bracket indentation.
For example 

filter{
  grok {
    match =>{
      "message" => [
  
      }
    ]
  }
}
Although it is clear that the square bracket should be before }. It won't correct it.
I have some thoughts of making it work.
Will graduately add support for this.
