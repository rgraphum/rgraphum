module IDs



  def new_id(id=nil)
    ids_manager.new_id(id,@rgraphum_id)
  end

  def current_id
    ids_manager.current_id
  end

  def ids
    ids_manager.load_keys.freeze
  end

  def ids=(source=[])
    ids_manager.replace(source).freeze
  end  

  def add_ids(id)
    ids_manager.add_ids(id)
  end

  def del_ids
    ids_manager.del_ids(id)
  end

  def id_element_hash
    hash = {}
    id_rgraphum_hash.each do |id,rgraphum_id|
      hash[id.to_i] = ElemetManager.load(rgraphum_id)
    end
    hash
  end

  def id_rgraphum_id_hash
    @ids_manager.load
  end

  def ids_manager
    @ids_manager ||= IDsManager.new
  end

  class IDsManager

    def initialize
      @rgraphum_id = new_rgraphum_id
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
        redis.set( @counter_id, self.load_keys.max )
        id = add_id( redis.incr(@counter_id), rgraphum_id ) 
      end
      id
    end

    def load
      redis.hgetall(@rgraphum_id)
    end

    def load_keys
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
    end

    def current_id
      redis.get(@counter_id).to_i
    end
  end
  
end
