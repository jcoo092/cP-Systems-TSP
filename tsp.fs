let infty = 10000

let E = // Specification of set of E objects
   [|  [| 0; 1; 3; infty; 2; |];
       [| 1; 0; infty; 6; 4; |];
       [| 3; infty; 0; 8; 5; |];
       [| infty; 6; 8; 0; 7; |];
       [| 2; 4; 5; 7; 0; |];
   |]

type s = { r: int; u: Set<int>; p: list<int>; c: int }
type z = {p: list<int>; c: int}

let N = Array.length E
let R = 0  // could start from random root

let printNode (n:s) = 
     printfn "Node path: %A" (List.rev n.p)
     printfn "Unvisisted nodes: %A" n.u
     printfn "Node cost so far: %i\n" n.c

let create_zs (tree : list<s>) = 
    tree |>
    List.collect (fun n ->
        let W = E.[List.head n.p].[R]
        if W < infty then
            [{p = R :: n.p; c = n.c + W}]
        else
            []
    )
let next (n:s) = // Create each new s object
    [ 
        let F = List.head n.p
        for T in n.u do  // always v <> v'
            let W = E.[F].[T]
            if W < infty then 
                yield { r = R; u = Set.remove T n.u; p = T :: n.p; c = n.c+ W }
    ]        

let rec build (tree : list<s>) = 
    if tree.Head.u.IsEmpty then
        create_zs tree
    else
        //List.iter printNode tree // Optional ability to print all objects at the current step
        let newtree = tree |> List.collect next
        build(newtree)

let Y = set [ for F in 0..N-1 do if F <> R then yield F ]
let start = {r = R; u = Y; p = R :: []; c = 0}
let zs = [start] |> build

let minW = zs |> List.map (fun n -> n.c) |> List.min // Select and output minimum cost and associated path (rule (5))
let minZ = zs |> List.filter (fun n -> n.c = minW)
printfn "Cost: %i" minW
printfn "Path: %A\n" (List.rev minZ.Head.p) // Print arbitrary minimum-cost path
