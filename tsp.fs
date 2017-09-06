type e = int * int * int // (f, t, w)
type s = int * Set<int> * list<int> * int // (r, u, p, c)
type z = list<int> * int // (p, c)

let E = [|
    (1, 2, 1);
    (1, 3, 3);
    (1, 5, 2);
    (2, 1, 1);
    (2, 4, 6);
    (2, 5, 4);
    (3, 1, 3);
    (3, 4, 8);
    (3, 5, 5);
    (4, 2, 6);
    (4, 3, 8);
    (4, 5, 7);
    (5, 1, 2);
    (5, 2, 4);
    (5, 3, 5);
    (5, 4, 7)
|]

let snd4 (_, b, _, _) = b
let thd3 (_, _, c) = c

let visit (si:s) (u:Set<int>): list<s> =
    let r, _, f::p, c = si
    [for t in u do
        let edge = Array.choose (fun x -> match x with
                                          | (f', t', _) when f' = f && t' = t -> Some(x)
                                          | _ -> None) E
        if Array.length edge > 0 then
            yield (r, Set.remove t u, t :: f :: p, c + thd3 edge.[0]) ]

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
