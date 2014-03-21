#!/usr/bin/env ruby
=begin
-------------------------------------------------------------------------------------
--  SOURCE FILE:    forward.rb - A multi-threaded simple port forwarding application
--                  Reads from configuration file and forwards traffic between
--                  specified ports and servers.
--                  Run program to get started, it will create config file,
--                  check for valid configuration and not start unless valid config.
--
--  PROGRAM:        forward
--                ./forward.rb 
--
--  FUNCTIONS:      Ruby Threads, Ruby Sockets, UNIX Processes, IPAddress gem
--
--  DATE:           March 3, 2014
--
--  REVISIONS:      See development repo: https://github.com/deuterium/comp8005-final
--
--  DESIGNERS:      Chris Wood - chriswood.ca@gmail.com
--
--  PROGRAMMERS:    Chris Wood - chriswood.ca@gmail.com
--
--  NOTES:          load_config and start_listen could use some major refactoring
--  
---------------------------------------------------------------------------------------
=end

require 'socket'
require 'thread'
require 'ipaddress'


## Variables
# regex format: digit_length_1_to_5>IP_ADDRESS:digit_length_1_to_5
VALID_LINE_REGEX = Regexp.new('^\d{1,5}(>)(?:[0-9]{1,3}\.){3}[0-9]{1,3}:\d{1,5}$')
CONFIG_FILE = 'forward.conf'

# String constants
USAGE = "Proper usage: ./forward.rb"
CONFIG_FILE_HEADER = ">> forward.rb Configuration File. first three lines are ignored\n"
CONFIG_FILE_HEADER << ">> Please list external port and ip address to be forwarded. one per line\n"
CONFIG_FILE_HEADER << '>> ie. 80>173.194.33.0:8080'
CONFIG_EDIT = "Please edit #{CONFIG_FILE} and relaunch."
CONFIG_CREATE = "Configuration file created. #{CONFIG_EDIT}"
CONFIG_EMPTY = "Configuration file empty. #{CONFIG_EDIT}"
CONFIG_INVALID = "Error parsing configuration. #{CONFIG_EDIT}"


## Functions

# Loads configuration for the port forwarding program.
# Checks if configuration file exists, if not, creates
# Checks if config file has been appended to, if not, prompts
# Checks for valid config lines, if not, prompts
#
# @return [Array]
# - Array of configuration items, format ['listening_port', 'forward_ip:forward_port']
def config_load
    conf_items = Array.new
    if File.exists? CONFIG_FILE #file exists
        conf = nil
        File.open(CONFIG_FILE, 'r') do |f|
            conf = f.readlines
        end
        if conf.count <= 3 # config empty
            exit_reason(CONFIG_EMPTY)
        else # config empty, needs validation
            # strip conf header
            3.times { conf.shift }

            conf.each do |l|
                if VALID_LINE_REGEX.match(l)
                    items = l.split('>')
                    addr = items[1].split(':')
                    ip = addr[0]
                    port = addr[1].to_i
                    if !valid_port(port) && !IPAddress::valid?(ip)
                        exit_reason("1#{CONFIG_INVALID}")
                    end
                    conf_items.push("#{items[0]},#{addr[0]},#{addr[1]}")
                else #regex fails
                    exit_reason("2#{CONFIG_INVALID}")
                end
            end
        end
        return conf_items # this return IS needed
    else #file does not exist
        File.open(CONFIG_FILE, 'a') do |f|
            f.write(CONFIG_FILE_HEADER)
        end
        exit_reason(CONFIG_CREATE)
    end
end

# Checks port range validity (1-65535)
#
# @param [Integer] num
# - port to check
# @return [bool]
# - true if valid, false if not
def valid_port(num)
    if num >= 1 && num <= 65535
    end
end

# Displays message and then exits program
#
# @param [String] reason
# - message to display before exiting
def exit_reason(reason)
    puts reason
    exit
end

# Starts configuration item listening servers
# Listens on configured port, creates forward/backward ports for forwarding data to
#   specified address
#
# @param [Integer] listen_port
# - port for the program to forward requests FROM
# @param [String] forward_addr
# - IP address for the program to forward requests TO
# @param [Integer] forward_port
# - port for the program to forward requests TO
def start_listen(listen_port, forward_addr, forward_port)
    begin
        server = TCPServer.new(listen_port)
    rescue => e
        puts 'problem binding listening server'
        puts e
        exit!
    end
    puts "Server: Incoming port #{listen_port} bound to forward to #{forward_addr}:#{forward_port}"
    begin
        loop {
            Thread.start(server.accept) { |c|
                _, remote_port,
                        _, remote_ip = c.peeraddr
                puts "#{listen_port}>#{forward_addr}:#{forward_port}=+ connection accepted: #{remote_ip}:#{remote_port}"
                # forward and receive data to client
                remote = TCPSocket.new(forward_addr, forward_port)
                loop {
                    max_i = 262140

=begin      THIS IS OLD, non-select, blocking method
                    data_remote_in = c.recv(max_i)
                    if !data_remote_in.empty?
                        puts "TO FORWARD: #{data_remote_in.to_s.bytesize} =+ #{data_remote_in}"
                        remote.puts(data_remote_in)
                        data_remote_in = Array.new()
                    end
                    data_forward_in = remote.recv(max_i)
                    if !data_forward_in.empty?
                        puts "FROM FORWARD: #{data_forward_in.to_s.bytesize} =+ #{data_forward_in}"
                        c.puts(data_forward_in)
                        data_forward_in = Array.new()
                    end
=end
                    Thread.new() do
                        loop {
                            begin
                                data_remote_in = c.recv_nonblock(max_i)
                            rescue IO::WaitReadable, Errno::EWOULDBLOCK, Errno::EAGAIN
                                IO.select([c])
                                retry
                            end
                            if data_remote_in.empty? then
                                nil
                            else
                                puts data_remote_in
                                remote.puts(data_remote_in)
                            end
                            data_remote_in.flush
                        }
                    end
                    Thread.new() do
                        loop {
                            begin
                                data_forward_in = remote.recv_nonblock(max_i)
                            rescue IO::WaitReadable, Errno::EWOULDBLOCK, Errno::EAGAIN
                                IO.select([remote])
                                retry
                            end
                            if data_forward_in.empty? then
                                nil
                            else
                                puts data_forward_in
                                c.puts(data_forward_in)
                            end
                            data_forward_in.flush
                        }
                    end
                }
            }
        }
    rescue Interrupt # child process
        exit!
    #rescue => e
     #   puts "other error: #{e}"
    end
end

## Main
if ARGV.count > 1
    exit_reason(USAGE)
end

ARGV.clear # clear for STDIN, if applicable

conf = config_load
# keep track of listening servers
listening_processes = (0..conf.count-1).map do |p|
    Process.fork do
        forward_item = conf[p].split(',')
        start_listen(forward_item[0], forward_item[1], forward_item[2].chomp)
    end
end

# main program will not end until listening processes are finished
begin
    listening_processes.each {|p| Process.wait p}
rescue Interrupt #parent process
    puts "server shutdown received...."
    listening_processes.each {|p| Process.kill "KILL", p} #kill children
    exit!
end