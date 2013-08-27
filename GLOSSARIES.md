Rgraphum Glossaries / Rgraphum 用語集
==================================

* Vertex   頂点
* Vertices 頂点(変則系複数形)
* Edge     枝、頂点と頂点を結ぶ線
* Graph    グラフ、頂点と枝の集合体
* Cluster  クラスター、Graph の部分 Graph、Graph の中の小さな集り
* Start root vertex
* End   root vertex
* Community分割
* Cluster係数

## Graph : グラフ

    (1)---->(4)--->(7)
     |       |
     v       v
    (2)---->(5)--->(8)
               \____
                    |
                    v
    (3)---->(6)--->(9)
                    ^
                    |
                  (10)

## Cluster : クラスター

この場合 Cluster が 3つある

    (1)---->(4)--->(7)
    
    (2)---->(5)--->(8)
    
    (3)---->(6)--->(9)
                    ^
                    |
                  (10)

## Vertex / Vertices : 頂点

    (1)     (4)    (7)
    
    
    (2)     (5)    (8)
    
    
    
    (3)     (6)    (9)
    
    
                  (10)

## Edge / Edges : 枝

       ---->   --->
     |       |
     v       v
       ---->   --->
               \____
                    |
                    v
       ---->   --->
                    ^
                    |

## Start root vertex

    (1)
    
    (2)
    
    (3)
    
                  (10)

## End root vertex

                   (7)
    
                   (8)
    
                   (9)

## Cluster と Community

Cluster には 2つ意味があって、その1つが Community

### Community分割(Cluster分割)の話しをしているとき

分割された Edge でつながった Vertex の集りを Community または Cluster と呼ぶ

    (1) --- (2) (4) -- (5)
      \     /
       \   /    (6) -- (7) -- (8)
        (3)
        
        (9)

### Cluster係数の話しをしているとき

3つのEdgeでつながった、3つのVertex、下図の三角形を Cluster と呼ぶ

    (1) ---- (2)
      \     /
       \   /
        (3)
