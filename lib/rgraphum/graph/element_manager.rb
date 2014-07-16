class ElementManager
  class << self

    def redis
      Redis.current
    end

    def load(rgraphum_id)
      JSON.load( redis.hget( rgraphum_id,"params" ) ) || {}
    end

    def vertex_from_rgraphum_id(rgraphum_id)
      hash = self.load(rgraphum_id)
      vertex = Rgraphum::Vertex(hash)
    end

    def save(rgraphum_id,hash={})
      redis.hset( rgraphum_id, "params", hash.to_json)
    end

    def store(rgraphum_id,key,value) 
      hash = JSON.load( redis.hget( rgraphum_id,"params" ) )
      hash ||= {}

      hash[key.to_s] = value
      redis.hset( rgraphum_id, "params", hash.to_json)
      return value
    end

    def fetch(rgraphum_id,key) 
      tmp = JSON.load( redis.hget( rgraphum_id, "params" ) ) || {}
      tmp[key.to_s]
    end

    def redis_dup(rgraphum_id)
      hash = JSON.load( redis.hget( rgraphum_id,"params" ) )
      hash ||= {}

      new_rgraphum_id = redis.incr( "global:RgraphumId" )

      redis.hset( new_rgraphum_id, "params", hash.to_json)
      new_rgraphum_id
    end

  end

end
