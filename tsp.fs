let infty = 10000

let C = // Specification of set of E objects
   [|  [| 0; 1; 3; infty; 2; |];
       [| 1; 0; infty; 6; 4; |];
       [| 3; infty; 0; 8; 5; |];
       [| infty; 6; 8; 0; 7; |];
       [| 2; 4; 5; 7; 0; |];
   |]

let V = Array.length C // corresponds to v()
let root = 0  // could start from random root | corresponds to r()
let rest = set [ for v in 0..V-1 do if v <> root then yield v ] // Corresponds to u()

type Node = { level: int; path: list<int>; free: Set<int>; cost: int }
let ident (n:Node) = List.head n.path

let next (n:Node) = // Create the new s objects at each level.  Corresponds to rules (2) and (3)
    [ 
        let v = List.head n.path
        for v' in n.free do  // always v <> v'
            let cost = C.[v].[v']
            if cost < infty then 
                yield { level = n.level+1; path = v' :: n.path; free = Set.remove v' n.free; cost = n.cost+ cost }
    ]

let rec build (level:int) (tree:list<Node>) =
    let tree' = 
        tree 
        |> List.filter (fun n -> n.level = level) 
        |> List.collect next 

    if List.isEmpty tree' then 
        tree
    else 
        build (level+1) (tree' @ tree)

let tree = build 0 [ { level = 0; path = [root]; free = rest; cost = 0 } ] // Create l(0)'s s object (rule (1)), and begin calculation

let closed = // Corresponds to the set of s' objects created by rule (4)
    tree 
    |> List.collect (
        fun n -> 
            let closingcost = C.[ident n].[root]
            if Set.isEmpty n.free && closingcost < infty then
                [{n with cost = n.cost + closingcost}]
            else
                []
        )

let mincost = closed |> List.map (fun n -> n.cost) |> List.min // Select and output minimum cost and associated path (rule (5))
let minclosed = closed |> List.filter (fun n -> n.cost = mincost)
printfn "cost: %i" mincost
printfn "Path: %A\n" (List.rev minclosed.Head.path) // Print arbitrary minimum-cost path

let printNode (n:Node) = 
    printfn "Node level: %i" n.level
    printfn "Node path: %A" (List.rev n.path)
    printfn "Unvisisted nodes: %A" n.free
    printfn "Node cost so far: %i\n" n.cost


let print (level:int) (tree:list<Node>) =
    let tree' = 
        tree 
        |> List.filter (fun n -> n.level = level) 

    List.iter printNode tree'

for i in 0..4 do
    print i tree