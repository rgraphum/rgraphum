class ElementManager
  class << self

    def redis
      Redis.current
    end

    def load(rgraphum_id)
      hash = redis.hgetall( rgraphum_id ) || {}
      return_hash = {}
      hash.each do |key,value|
        next if key == "edges_rgraphum_id"
        next if key == "in_edges_rgraphum_id"
        next if key == "out_edges_rgraphum_id"

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
      key = key.to_s
      value = redis.hget( rgraphum_id, key ) 
      value = value.to_i if key == "id" and value
      value
    end

    def redis_dup(rgraphum_id, new_one)
      hash = redis.hgetall( rgraphum_id ) 
      hash ||= {}

      redis.mapped_hmset( new_one, hash)
      new_one
    end

    def delete(rgraphum_id)
      redis.del(rgraphum_id)
    end

  end

end
