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
CONFIG_FILE_HEADER = ">> forward.rb Configuration File. first three lines are ignored\n"
CONFIG_FILE_HEADER << ">> Please list external port and ip address to be forwarded. one per line\n"
CONFIG_FILE_HEADER << ">> ie. 80>173.194.33.0:8080"
CONFIG_EDIT = "Please edit #{CONFIG_FILE} and relaunch."
CONFIG_CREATE = "Configuration file created. #{CONFIG_EDIT}"
CONFIG_EMPTY = "Configuration file empty. #{CONFIG_EDIT}"
CONFIG_INVALID = "Error parsing configuration. #{CONFIG_EDIT}"
VALID_LINE_REGEX = Regexp.new('^\d{1,5}(>)(?:[0-9]{1,3}\.){3}[0-9]{1,3}:\d{1,5}$')

## Functions

def config_load
    if File.exists? CONFIG_FILE #file exists
        conf = nil
        File.open(CONFIG_FILE, 'r') do |f|
            conf = f.readlines
        end
        if conf.count <= 3 # config empty
            exit_reason(CONFIG_EMPTY)
        else # config empty, needs validation
            3.times do # strip conf header
                conf.shift
            end
            conf_items = Array.new()
            conf.each do |l|
                if VALID_LINE_REGEX.match(l)
                    items = l.split('>')
                    addr = items[1].split(':')
                    ip = addr[0]
                    port = addr[1].to_i
                    if !valid_port(port) && !IPAddress::valid?(ip)
                        exit_reason("1#{CONFIG_INVALID}")
                    end
                    conf_items.push(items[0], items[1])
                else #regex fails
                    exit_reason("2#{CONFIG_INVALID}")
                end
            end

        end
        #do things with valid config here
        return conf_items
    else #file does not exist
        File.open(CONFIG_FILE, 'a') do |f|
            f.write(CONFIG_FILE_HEADER)
        end
        exit_reason(CONFIG_CREATE)
    end
end

def valid_port(num)
    if num >= 1 && num <= 65535
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

conf = config_load
puts conf