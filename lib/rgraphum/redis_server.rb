# -*- coding: utf-8 -*-
require "tempfile"

class Rgraphum::RedisServer

  def initialize(options_tmp = {})
    @options = options.merge(options_tmp)
  end

  def self.start(option_tmp = {})
    server = new(option_tmp)
    server.start
    server
  end

  def start
    return p "server already stand" if File.exists?( @options["pidfile"] )

    o, e, s = Open3.capture3("redis-server #{config_file.path}")
    p o
    p e
    p s
  end

  def end
#    o, e, s = Open3.capture3(". #{config_file.path}")
  end

  def config_file
    @temp_file ||= Tempfile.new(Time.now.to_i.to_s)
    File.open(@temp_file,"w") do |io|
      @options.each do |key,value|
        io.puts( key.to_s + " " + value.to_s )
      end
    end
    @temp_file
  end

  def options
    dirs = {
      home: Dir.home + "/.rgraphum",
      tmp: Dir.home + "/.rgraphum/tmp",
      redis: Dir.home + "/.rgraphum/redis",
    }
    
    dirs.each do |key,path|
      unless Dir.exist?(path)
        Dir.mkdir(path)
      end
    end

    tmpdir = dirs[:tmp]
    database_dir = dirs[:redis]
    @options ||= {
      "daemonize" => "yes",
      
      "pidfile" => tmpdir + "/rgraphum_redis.pid",
      # port 6379
      "port" => "0",
      # tcp-backlog 511
      #bind 127.0.0.1
    
      # unixsocket /tmp/redis.sock
      "unixsocket" => tmpdir + "/rgraphum_redis.sock",
      "unixsocketperm" => "755",
    
      "timeout" => "0",
    
      # tcp-keepalive 0
    
      "loglevel" => "notice",
    
      # logfile /var/log/redis/redis-server.log
      "logfile" => tmpdir + "/rgraphum_redis_server.log",
    
      "databases" => "16",
    
      "save 900" => "1",
      "save 300" => "10",
      "save 60"  => "10000",
      
      "stop-writes-on-bgsave-error" => "yes",
      "rdbcompression" => "yes",
      
      "rdbchecksum" => "yes",
      
      "dbfilename" => "dump.rdb",
      
      "dir" => database_dir,
      
      "slave-serve-stale-data" => "yes",
      
      "slave-read-only" => "yes",
      
      "repl-disable-tcp-nodelay" => "no",
      
      "slave-priority" => "100",
      
      "appendonly" => "no",
      
      "appendfilename" => "appendonly.aof",
      
      "appendfsync" => "everysec",
      
      "no-appendfsync-on-rewrite" => "no",
      
      "auto-aof-rewrite-percentage" => "100",
      "auto-aof-rewrite-min-size" => "64mb",
      
      "lua-time-limit" => "5000",
      
      "slowlog-log-slower-than" => "10000",
      
      "slowlog-max-len" => "128",
      
      "latency-monitor-threshold" => "0",
      
      "notify-keyspace-events" => "\"\"",
      
      "hash-max-ziplist-entries" => "512",
      "hash-max-ziplist-value" => "64",
      
      "list-max-ziplist-entries" => "512",
      "list-max-ziplist-value" => "64",
      
      "set-max-intset-entries" => "512",
      
      "zset-max-ziplist-entries" => "128",
      "zset-max-ziplist-value" => "64",
      
      "hll-sparse-max-bytes"   => "3000",
      
      "activerehashing" => "yes",
      
      "client-output-buffer-limit normal" => "0 0 0",
      "client-output-buffer-limit slave"  => "256mb 64mb 60",
      "client-output-buffer-limit pubsub" => "32mb 8mb 60",
      
      "hz" => "10",
      
      "aof-rewrite-incremental-fsync" => "yes"
    }
  end
end
