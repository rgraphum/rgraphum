class ElementManager
  class << self

    def redis
      Redis.current
    end

    def load(rgraphum_id)
      hash = redis.hgetall( rgraphum_id ) || {}
      return_hash = {}
      hash.each do |key,value|
        if key == "id" or key == "source" or key == "target"
          value = value.to_i
        end
        if key == "weight"
          value = value.to_f
        end
        return_hash[key.to_sym] = value        
      end
      return_hash
    end

    def vertex_from_rgraphum_id(rgraphum_id)
      hash = self.load(rgraphum_id)
      vertex = Rgraphum::Vertex(hash)
    end

    def store(rgraphum_id,key,value) 
      begin
        redis.hset( rgraphum_id, key, value)
      rescue
        p key
        p value
      end
      value
    end

    def fetch(rgraphum_id,key) 
       redis.hget( rgraphum_id, key.to_s ) 
    end

    def redis_dup(rgraphum_id)
      hash = redis.hgetall( rgraphum_id ) 
      hash ||= {}

      redis.mapped_hmset( rgraphum_id = new_rgraphum_id, hash)
      rgraphum_id
    end

    def delete(rgraphum_id)
      redis.del(rgraphum_id)
    end

  end

end
