#!/usr/bin/env ruby
=begin
-------------------------------------------------------------------------------------
--  SOURCE FILE:    forward.rb - A multi-threaded simple port forwarding application
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
require 'ipaddress'
require_relative 'forwardpair'


## Variables
lock = Mutex.new
CONFIG_FILE = "forward.conf"

# String constants
USAGE = "Proper usage: ./forward.rb"
CONFIG_FILE_HEADER = ">> foward.rb Configuration File. first three lines are ignored\n"
CONFIG_FILE_HEADER << ">> Please list external port and ip address to be forwarded. one per line\n"
CONFIG_FILE_HEADER << ">> ie. 80>173.194.33.0"
CONFIG_EDIT = "Please edit #{CONFIG_FILE} and relaunch."
CONFIG_CREATE = "Configuration file created. #{CONFIG_EDIT}"
CONFIG_EMPTY = "Configuration file empty. #{CONFIG_EDIT}"
CONFIG_INVALID = "Error parsing configuration. #{CONFIG_EDIT}"

## Funtions 

def config_check
    # check if config file exists
    if !File.exists? CONFIG_FILE
        File.open(CONFIG_FILE, 'a') { |f|
            f.write(CONFIG_FILE_HEADER)
        }
        exit_reason(CONFIG_CREATE)
    else # check if config file empty & valid
        conf = nil
        File.open(CONFIG_FILE, 'r') { |f|
            conf = f.readlines
        }
        if conf.count <= 3 # empty config
            exit_reason(CONFIG_EMPTY)
        else # check configuration valid
            3.times do # strip conf header
                conf.shift
            end
            conf.each do |l|
                if !l.include? '>' # check each line for proper form
                    exit_reason(CONFIG_INVALID)
                else # check first of pair valid port and second valid ip
                    pair = l.split('>') 
                    port = pair[0].to_i
                    ip = pair[1]
                    if port < 1 || port > 65535 || !IPAddress::valid?(ip)
                        exit_reason(CONFIG_INVALID)
                    end
                end
            end
            puts conf
        end 
    end
end

def exit_reason(reason)
    puts reason
    exit
end

## Main

if ARGV.count > 1
    exit_reason(USAGE)
end

# clear for STDIN, if applicable
ARGV.clear

config_check
