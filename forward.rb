  
#!/usr/bin/env ruby
=begin
-------------------------------------------------------------------------------------
--  SOURCE FILE:    forward.rb - A multi-threaded echo server
--
--  PROGRAM:        forward
--                ./forward.rb 
--
--  FUNCTIONS:      Ruby Threads, Ruby Sockets
--
--  DATE:           March 3, 2014
--
--  REVISIONS:      See development repo: https://github.com/deuterium/comp8005-final
--
--  DESIGNERS:      Chris Wood - chriswood.ca@gmail.com
--
--  PROGRAMMERS:    Chris Wood - chriswood.ca@gmail.com
--
--  NOTES:
--  
---------------------------------------------------------------------------------------
=end

require 'socket'
require 'thread'


## Variables

CONFIG_FILE = "forward.conf"
## Funtions 

def config_check
  if !Dir[CONFIG_FILE].exists?
end

## Main

if ARGV.count > 1
  puts "Proper usage: ./forward.rb"
  exit
end

