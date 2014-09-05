
class Rgraphum::Edge

  # Gremlin: outV
  #
  # Get both outgoing tail vertex of the edge.
  #
  #     gremlin> e = g.e(12)
  #     ==>e[12][6-created->3]
  #     gremlin> e.outV
  #     ==>v[6]
  #     gremlin> e.inV
  #     ==>v[3]
  #     gremlin> e.bothV
  #     ==>v[6]
  #     ==>v[3]
  #
  def outV
    self.source
  end
  alias :out_v :outV

  # Gremlin: inV
  #
  # Get both incoming head vertex of the edge.
  #
  #     gremlin> e = g.e(12)
  #     ==>e[12][6-created->3]
  #     gremlin> e.outV
  #     ==>v[6]
  #     gremlin> e.inV
  #     ==>v[3]
  #     gremlin> e.bothV
  #     ==>v[6]
  #     ==>v[3]
  #
  def inV
    self.target
  end
  alias :in_v :inV

  # Gremlin: bothV
  #
  # Get both incoming and outgoing vertices of the edge.
  #
  #     gremlin> e = g.e(12)
  #     ==>e[12][6-created->3]
  #     gremlin> e.outV
  #     ==>v[6]
  #     gremlin> e.inV
  #     ==>v[3]
  #     gremlin> e.bothV
  #     ==>v[6]
  #     ==>v[3]
  #
  def bothV
    [outV, inV]
  end
  alias :both_v :bothV

end

class Rgraphum::Edges

  # Gremlin: outV
  #
  # Get both outgoing tail vertex of the edge.
  #
  #     gremlin> e = g.e(12)
  #     ==>e[12][6-created->3]
  #     gremlin> e.outV
  #     ==>v[6]
  #     gremlin> e.inV
  #     ==>v[3]
  #     gremlin> e.bothV
  #     ==>v[6]
  #     ==>v[3]
  #
  def outV
    self.map{ |edge| edge.source }
  end
  alias :out_v :outV

  # Gremlin: inV
  #
  # Get both incoming head vertex of the edge.
  #
  #     gremlin> e = g.e(12)
  #     ==>e[12][6-created->3]
  #     gremlin> e.outV
  #     ==>v[6]
  #     gremlin> e.inV
  #     ==>v[3]
  #     gremlin> e.bothV
  #     ==>v[6]
  #     ==>v[3]
  #
  def inV
    self.map{ |edge| edge.target }
  end
  alias :in_v :inV

end

class Rgraphum::Graph

  # Gremlin: Graph.v
  #
  # Get a vertex or set of vertices by providing one or more vertex identifiers.
  # The identifiers must be the identifiers assigned by the underlying graph implementation.
  #
  #     gremlin> g.v(1)
  #     ==>v[1]
  #     gremlin> g.v(1,2,3)
  #     ==>v[1]
  #     ==>v[2]
  #     ==>v[3]
  #     gremlin> ids = [1,2,3]
  #     ==>1
  #     ==>2
  #     ==>3
  #     gremlin> g.v(ids.toArray())
  #     ==>v[1]
  #     ==>v[2]
  #     ==>v[3]
  #  
  # @param [Array] ids 
  def v(*ids)
    ids = ids.flatten

    return @vertices.find_by_id(ids[0]) if ids.size == 1

    new_vertices = Rgraphum::Vertices.new
    ids.each do |id|
      new_vertices << @vertices.find_by_id(id)
    end

    new_vertices
  end

  # Gremlin: Graph.e
  #
  # Get an edge or set of edges by providing one or more edge identifiers.
  # The identifiers must be the identifiers assigned by the underlying graph implementation.
  #
  #     gremlin> g.e(10)
  #     ==>e[10][4-created->5]
  #     gremlin> g.e(10,11,12)
  #     ==>e[10][4-created->5]
  #     ==>e[11][4-created->3]
  #     ==>e[12][6-created->3]
  #     gremlin> ids = [10,11,12]
  #     ==>10
  #     ==>11
  #     ==>12
  #     gremlin> g.e(ids.toArray())
  #     ==>e[10][4-created->5]
  #     ==>e[11][4-created->3]
  #     ==>e[12][6-created->3]
  #
  # @param [Array] ids 
  def e(*ids)
    ids = ids.flatten

    return @edges.find_by_id(ids[0]) if ids.size == 1

    new_edges = Rgraphum::Edges.new
    ids.each do |id|
      new_edges << @edges.find_by_id(id)
    end

    new_edges
  end

  # Gremlin: V
  #
  # The vertex iterator for the graph.
  # Utilize this to iterate through all the vertices in the graph.
  # Use with care on large graphs unless used in combination with a key index lookup.
  #
  #     gremlin> g.V
  #     ==>v[3]
  #     ==>v[2]
  #     ==>v[1]
  #     ==>v[6]
  #     ==>v[5]
  #     ==>v[4]
  #     gremlin> g.V("name", "marko")
  #     ==>v[1]
  #     gremlin> g.V("name", "marko").name
  #     ==>marko
  # 
  # @param [String] key
  # @param [String] value
  def V(key=nil,value=nil)
    if key
      @vertices.where( { key => value } ).all
    else
      @vertices
    end
  end


  # Gremlin: E
  #
  # The edge iterator for the graph.
  # Utilize this to iterate through all the edges in the graph.
  # Use with care on large graphs.
  #
  #     gremlin> g.E
  #     ==>e[10][4-created->5]
  #     ==>e[7][1-knows->2]
  #     ==>e[9][1-created->3]
  #     ==>e[8][1-knows->4]
  #     ==>e[11][4-created->3]
  #     ==>e[12][6-created->3]
  #     gremlin> g.E.weight
  #     ==>1.0
  #     ==>0.5
  #     ==>0.4
  #     ==>1.0
  #     ==>0.4
  #     ==>0.2
  #
  def E(key=nil,value=nil)
    if key
      @edges.find_all {|edge| vertex.send(key) == value }
    else
      @edges
    end
  end

  # Gremlin: Graph.addVertex
  #
  # Adds a vertex to the graph.
  # Note that most graph implementations ignore the identifier supplied to addVertex.
  #
  #     gremlin> g = new TinkerGraph()
  #     ==>tinkergraph[vertices:0 edges:0]
  #     gremlin> g.addVertex()
  #     ==>v[0]
  #     gremlin> g.addVertex(100)
  #     ==>v[100]
  #     gremlin> g.addVertex(null,[name:"stephen"])
  #     ==>v[1]
  #
  def addVertex(id=nil, vertex=nil)
    if id
      vertex ||= Rgraphum::Vertex(id: id)
    else
      vertex ||= Rgraphum::Vertex()
    end
    vertex = Rgraphum::Vertex(vertex) unless vertex.is_a?(Rgraphum::Vertex) # FIXME
    @vertices << vertex
    @vertices[-1]
  end
  alias :add_vertex :addVertex

  # Gremlin: Graph.addEdge
  #
  # Adds an edge to the graph.
  # Note that most graph implementations ignore the identifier supplied to addEdge.
  #
  #     gremlin> g = new TinkerGraph()
  #     ==>tinkergraph[vertices:0 edges:0]
  #     gremlin> v1 = g.addVertex(100)
  #     ==>v[100]
  #     gremlin> v2 = g.addVertex(200)
  #     ==>v[200]
  #     gremlin> g.addEdge(v1,v2,'friend')
  #     ==>e[0][100-friend->200]
  #     gremlin> g.addEdge(1000,v1,v2,'buddy')
  #     ==>e[1000][100-buddy->200]
  #     gremlin> g.addEdge(null,v1,v2,'pal',[weight:0.75f])
  #     ==>e[1][100-pal->200]
  #
  def addEdge( *params )
    if params.size == 3
      source = params[0]; target = params[1]; label = params[2]
      @edges << Rgraphum::Edge(source: source, target: target, label: label)
      @edges[-1]
    elsif params.size == 4
      params_tmp = {}
      params_tmp[:id]     = params[0] if params[0]
      params_tmp[:source] = params[1] if params[1]
      params_tmp[:target] = params[2] if params[2]
      params_tmp[:label]  = params[3] if params[3]
      @edges.build( params_tmp )
    elsif params.size == 5
      edge_hash = {}
      edge_hash[:id] = params[0] if params[0];
      edge_hash[:source] = params[1] if params[1];
      edge_hash[:target] = params[2] if params[2];
      edge_hash[:label]  = params[3] if params[3];
      edge_hash.merge!(params[4])
      @edges.build(edge_hash)
    end
  end
  alias :add_edge :addEdge

end

class Rgraphum::Elements

  # gremlin methods

  # has
  # Allows an element if it has a particular property. Utilizes several options for comparisons through T:
  #   T.gt - greater than
  #   T.gte - greater than or equal to
  #   T.eq - equal to
  #   T.neq - not equal to
  #   T.lte - less than or equal to
  #   T.lt - less than
  # It is worth noting that the syntax of has is similar to g.V("name", "marko"), which has the difference of being a key index lookup and as such will perform faster. In contrast, this line, g.V.has("name", "marko"), will iterate over all vertices checking the name property of each vertex for a match and will be significantly slower than the key index approach.
  #   gremlin> g.V.has("name", "marko").name
  #   ==>marko
  #   gremlin> g.v(1).outE.has("weight", T.gte, 0.5f).weight
  #   ==>0.5
  #   ==>1.0
  #   gremlin> g.V.has("age", null).name
  #   ==>lop
  #   ==>ripple
  def has(*conditions)
    if conditions.size == 1
      self.class.new( where( conditions[0], :!=, nil ) )
    elsif conditions.size == 2
      self.class.new( where( { conditions[0] => conditions[1] } ) )
    elsif conditions.size == 3
      self.class.new( where( *conditions ) )
    end
  end

  # hasNot
  # Allows an element if it does not have a particular property. Utilizes several options for comparisons on through T:
  #   T.gt - greater than
  #   T.gte - greater than or equal to
  #   T.eq - equal to
  #   T.neq - not equal to
  #   T.lte - less than or equal to
  #   T.lt - less than
  #   gremlin> g.v(1).outE.hasNot("weight", T.eq, 0.5f).weight
  #   ==>1.0
  #   ==>0.4
  #   gremlin> g.V.hasNot("age", null).name
  #   ==>vadas
  #   ==>marko
  #   ==>peter
  #   ==>josh
  def hasNot(*conditions)
    nor_hash = {
      :== => :!=,
      :!= => :==,
      :<  => :>=,
      :<= => :> ,
      :>= => :<,
      :>  => :<=,
    }

    if conditions.size == 1
      self.class.new( where( conditions[0], :==, nil ) )
    elsif conditions.size == 2
      where( conditions[0], :!=, conditions[1] )
    elsif conditions.size == 3
      where( conditions[0], nor_hash[conditions[1]], conditions[2] )
    end
  end

end

class Rgraphum::Edges

  # gremlin methods

  # has
  # Allows an element if it has a particular property. Utilizes several options for comparisons through T:
  #   T.gt - greater than
  #   T.gte - greater than or equal to
  #   T.eq - equal to
  #   T.neq - not equal to
  #   T.lte - less than or equal to
  #   T.lt - less than
  # It is worth noting that the syntax of has is similar to g.V("name", "marko"), which has the difference of being a key index lookup and as such will perform faster. In contrast, this line, g.V.has("name", "marko"), will iterate over all vertices checking the name property of each vertex for a match and will be significantly slower than the key index approach.
  #   gremlin> g.V.has("name", "marko").name
  #   ==>marko
  #   gremlin> g.v(1).outE.has("weight", T.gte, 0.5f).weight
  #   ==>0.5
  #   ==>1.0
  #   gremlin> g.V.has("age", null).name
  #   ==>lop
  #   ==>ripple
  def has(*conditions)
    if conditions.size == 1
      self.class.new( where( conditions[0], :!=, nil ) )
    elsif conditions.size == 2
      self.class.new( where( { conditions[0] => conditions[1] } ) )
    elsif conditions.size == 3
      self.class.new( where( *conditions ) )
    end
  end

  # hasNot
  # Allows an element if it does not have a particular property. Utilizes several options for comparisons on through T:
  #   T.gt - greater than
  #   T.gte - greater than or equal to
  #   T.eq - equal to
  #   T.neq - not equal to
  #   T.lte - less than or equal to
  #   T.lt - less than
  #   gremlin> g.v(1).outE.hasNot("weight", T.eq, 0.5f).weight
  #   ==>1.0
  #   ==>0.4
  #   gremlin> g.V.hasNot("age", null).name
  #   ==>vadas
  #   ==>marko
  #   ==>peter
  #   ==>josh
  def hasNot(*conditions)
    nor_hash = {
      :== => :!=,
      :!= => :==,
      :<  => :>=,
      :<= => :> ,
      :>= => :<,
      :>  => :<=,
    }

    if conditions.size == 1
      self.class.new( where( conditions[0], :==, nil ) )
    elsif conditions.size == 2
      where( conditions[0], :!=, conditions[1] )
    elsif conditions.size == 3
      where( conditions[0], nor_hash[conditions[1]], conditions[2] )
    end
  end

end
