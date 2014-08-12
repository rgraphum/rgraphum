
    def from_hash(fields)
      tmp = new

      unless fields[:source] && fields[:target]
        raise ArgumentError, "Edge.new: :source and :target options are required"
      end

      tmp.rgraphum_id = new_rgraphum_id
      if fields[:source].is_a?(Hash)
        fields[:source] = fields[:source].id
      end
      @source = fields[:source]
    
      if fields[:target].is_a?(Hash)
        fields[:target] = fields[:target].id
      end
      @target = fields[:target]

      if fields[:start].class == Fixnum
        fields[:start] = Time.at(fields[:start])
      end

      fields[:weight] ||= 1

      fields.each do |key,value|
        tmp.store(key,value)
      end
      ElementManager.save(tmp.rgraphum_id,tmp)

      tmp
    end

    def from_hash(fields={})
      tmp = new
      tmp.rgraphum_id = new_rgraphum_id

      tmp.object_init
      fields[:words] = fields[:words].to_json if !fields.instance_of?(Rgraphum::Vertex) and fields[:words]
      fields[:twits] = fields[:twits].to_json if !fields.instance_of?(Rgraphum::Vertex) and fields[:twits]
      fields.each do |key,value|
        tmp.store(key,value)
      end
      tmp
    end
