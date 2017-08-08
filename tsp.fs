let infty = 10000

let E = // Specification of set of E objects
   [|  [| 0; 1; 3; infty; 2; |];
       [| 1; 0; infty; 6; 4; |];
       [| 3; infty; 0; 8; 5; |];
       [| infty; 6; 8; 0; 7; |];
       [| 2; 4; 5; 7; 0; |];
   |]

type s = int * Set<int> * list<int> * int // (r, u, p, c)
type z = list<int> * int // (p, c)

let visit (si:s) (u:Set<int>): list<s> =
    let r, _, f::p, c = si
    [for t in u do
        let w = E.[f].[t]
        if w < infty then
            yield (r, Set.remove t u, t :: f :: p, c + w) ]

let rec sgoal (slist: list<s>): list<s> =
    slist |> List.collect (fun si ->
        let r, u, _, _ = si
        if Set.isEmpty u 
        then visit si (set [r])
        else sgoal (visit si u))

let hgoal (r:int) (y:Set<int>): list<z> =
    [(r, y, [r], 0)] |> sgoal |> List.map (fun (r, u, p, c) -> (p, c))
    
let minh (h: list<z>): z =
    h |> List.minBy (fun (p, c) -> c)
    
let go () = 
    let r = 0
    let y = set [0..(Array.length E - 1)] |> Set.remove r
    hgoal r y |> minh |> printfn "%A"

go ()
