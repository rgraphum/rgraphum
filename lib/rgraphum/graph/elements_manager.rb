module ElementsManager

  class ElementsManager

    attr_accessor :rgraphum_id

    def initialize(rgraphum_id_tmp = nil )
      @rgraphum_id = rgraphum_id_tmp || new_rgraphum_id
      @counter_id  = new_rgraphum_id
    end

    def redis
      Redis.current
    end
    
    def new_id(id=nil, rgraphum_id )
      id = id.to_i if id
      id = add_id( id, rgraphum_id ) if id
      id = add_id( redis.incr(@counter_id), rgraphum_id ) unless id
      unless id
        redis.set( @counter_id, self.keys.max )
        id = add_id( redis.incr(@counter_id), rgraphum_id ) 
      end
      id
    end

    def load
      redis.hgetall(@rgraphum_id)
    end

    def keys
      redis.hkeys(@rgraphum_id)
    end

    def replace(id_rgraphum_id_hash)
      redis.multi
      redis.del(@rgraphum_id)
      id_rgraphum_id_hash.each { |id,rgraphum_id| redis.sadd(@rgraphum_id,id,rgraphum_id) }
      redis.exec
      id_rgraphum_id.keys
    end

    def add_id(id,rgraphum_id)
      flg = redis.hsetnx(@rgraphum_id,id,rgraphum_id)
      id if flg
    end

    def del_id(id)
      flg = redis.hdel(@rgraphum_id,id)
      id if flg
    end

    def current_id
      redis.get(@counter_id).to_i
    end
  end
  
end
