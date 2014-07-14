class ElementManager
  class << self

    def redis
      Redis.current
    end

    def load(rgraphum_id)
      JSON.load( redis.get( rgraphum_id ) ) || {}
    end

    def save(rgraphum_id,hash={})
      redis.set( rgraphum_id, hash.to_json)
    end

    def store(rgraphum_id,key,value) 
      hash = JSON.load( redis.get( rgraphum_id ) )
      hash ||= {}

      hash[key.to_s] = value
      redis.set( rgraphum_id, hash.to_json)
      return value
    end

    def fetch(rgraphum_id,key) 
      tmp = JSON.load( redis.get( rgraphum_id ) ) || {}
      tmp[key.to_s] 
    end

    def redis_dup(rgraphum_id)
      hash = JSON.load( redis.get( rgraphum_id ) )
      hash ||= {}

      new_rgraphum_id = redis.incr( "global:RgraphumId" )

      redis.set( new_rgraphum_id, hash.to_json)
      new_rgraphum_id
    end

  end

end
