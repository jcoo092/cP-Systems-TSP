type e = {f: int; t: int; c: int} // e(f, t, w)
type s = int * Set<int> * list<int> * int // (r, u, p, c)
type z = list<int> * int // (p, c)

let E = [|
    {f = 1; t = 2; c = 1};
    {f = 1; t = 3; c = 3};
    {f = 1; t = 5; c = 2};
    {f = 2; t = 1; c = 1};
    {f = 2; t = 4; c = 6};
    {f = 2; t = 5; c = 4};
    {f = 3; t = 1; c = 3};
    {f = 3; t = 4; c = 8};
    {f = 3; t = 5; c = 5};
    {f = 4; t = 2; c = 6};
    {f = 4; t = 3; c = 8};
    {f = 4; t = 5; c = 7};
    {f = 5; t = 1; c = 2};
    {f = 5; t = 2; c = 4};
    {f = 5; t = 3; c = 5};
    {f = 5; t = 4; c = 7}
|]

let snd4 (_, b, _, _) = b

let visit (si:s) (u:Set<int>): list<s> =
    let r, _, fx::p, c = si
    [for tx in u do
        let edge = Array.choose (fun x -> match x with
                                          | {f = f'; t = t'; c = W} when f' = fx && t' = tx -> Some(x)
                                          | _ -> None) E
        if Array.length edge > 0 then
            yield (r, Set.remove tx u, tx :: fx :: p, c + edge.[0].c) ]

let rec sgoal (slist: list<s>): list<s> =
    let r, u, _, _ = List.head slist
    if Set.isEmpty u then List.collect (fun si -> visit si (set [r])) slist
    else sgoal (List.collect (fun si -> visit si (snd4 si)) slist)    

let hgoal (r:int) (y:Set<int>): list<z> =
    [(r, y, [r], 0)] |> sgoal |> List.map (fun (r, u, p, c) -> (p, c))
    
let minh (h: list<z>): z =
    h |> List.minBy (fun (p, c) -> c)
    
let go () = 
    let r = 1
    let v = set [1..5] |> Set.remove r
    hgoal r v |> (fun s -> printfn "%A" s; s) |> minh |> printfn "%A"

go ()
