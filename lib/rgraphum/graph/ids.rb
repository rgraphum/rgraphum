module IDs

  def new_id(id=nil)
    ids_manager.new_id(id)
  end

  def current_id
    ids_manager.current_id
  end

  def ids
    ids_manager.load.freeze
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
    
    def new_id(id=nil)
      id = add_id(id) if id
      id = add_id( redis.incr(@counter_id) ) unless id
      unless id
        redis.set( @counter_id, self.load.max )
        id = add_id( redis.incr(@counter_id) ) 
      end
      id
    end

    def load
      redis.smembers(@rgraphum_id)
    end

    def replace(ids)
      redis.multi
      redis.del(@rgraphum_id)
      ids.each { |id| redis.sadd(@rgraphum_id,id) }
      redis.exec
      ids
    end

    def add_id(id)
      flg = redis.sadd(@rgraphum_id,id)
      id if flg
    end

    def del_id(id)
    end

    def current_id
      redis.get(@counter_id).to_i
    end
  end
  
end
