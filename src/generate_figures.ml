(*---------------------------------------------------------------------------
  Copyright (c) 2026 The SYMO authors. All rights reserved.
  SPDX-License-Identifier: ISC
  ---------------------------------------------------------------------------*)

(* Hugin figure suite and numerical verification examples for symo-forest.

   Generates nine figures in [-d <out-dir>] (default: [../figures]):
   1. [running_example_3x4.png]      — 3x4 leaf under {e}, S_3, B_3, and S_3 x S_4
   2. [pi_perp_blocks_3x4.png]       — Pi/Pi_perp basis and row mean-covariance identity
   3. [orbit_convergence_r1_r2.png]  — exact projection R2 vs Monte Carlo orbit sampling
   4. [mlp_tree_mosaic.png]          — two-hidden-layer MLP mosaic (S_6 x S_5)
   5. [rnn_mlp_mosaic.png]           — 7-leaf MLP-step RNN mosaic (G_h x G_z = S_8 x S_6)
   6. [vanilla_rnn_15_patterns.png]  — vanilla RNN (k = 2): B_4 = 15 patterns & 11 values
   7. [gru_mosaic.png]               — 8-leaf GRU mosaic and 15-value cross-gate tile
   8. [test_vectors_and_blocks_k2.png] — the 7 canonical k=2 test vectors & block spectrum
   9. [transport_vs_naive_surrogate.png] — exact width transport vs naive fixed factors *)

open Base
open Nx
open Symo

let out_dir =
  match Cmdargs.get_string "-d" with
  | Some d -> d
  | None -> "../figures"

let out file = Stdlib.Filename.concat out_dir file

(* ------------------------------------------------------------------------
   Shared utilities & Hugin matrix plotting primitives
   ------------------------------------------------------------------------ *)

let scalar x = Nx.scalar float32 x

let uniformise_diag m =
  let open Infix in
  let d = recip (sqrt (abs (diag m) +$ 1e-12)) in
  reshape [| -1; 1 |] d * m * reshape [| 1; -1 |] d

let color hex =
  match Hugin.Color.of_hex hex with
  | Ok c -> c
  | Error e -> failwith e

let grey = Hugin.Color.v 0.32 0.33 0.37
let lin () = Hugin.Scale.linear ~nice:false ()
let linr () = Hugin.Scale.linear ~nice:false ~reverse:true ()

(* [cells_2d rows cols fill] draws an [rows x cols] matrix on quantitative
   [0..cols] x [0..rows] coordinates (y reversed so row 0 is at the top). *)
let cells_2d ?(x_name = "x") ?(y_name = "y") rows cols fill =
  let xs d =
    Nx.create Nx.float32 [| 1; cols |]
      (Array.init cols ~f:(fun j -> Float.of_int j +. d))
  in
  let ys d =
    Nx.create Nx.float32 [| rows; 1 |]
      (Array.init rows ~f:(fun i -> Float.of_int i +. d))
  in
  let xscale = Hugin.Scale.linear ~name:x_name ~nice:false () in
  let yscale = Hugin.Scale.linear ~name:y_name ~nice:false ~reverse:true () in
  Hugin.rect
    ~x:(Hugin.num ~scale:xscale (xs 0.))
    ~x2:(Hugin.num ~scale:xscale (xs 1.))
    ~y:(Hugin.num ~scale:yscale (ys 0.))
    ~y2:(Hugin.num ~scale:yscale (ys 1.))
    ~fill
    ()

let cells n fill = cells_2d n n fill

let heatmap_2d ?(scale_name = "color") ?(domain = (-0.35, 0.35)) m =
  let shape = Nx.shape m in
  let rows = shape.(0) and cols = shape.(1) in
  let scale =
    Hugin.Scale.linear
      ~name:scale_name
      ~domain
      ~clamp:true
      ~scheme:(Hugin.Scheme.reverse Hugin.Scheme.rdbu)
      ()
  in
  cells_2d rows cols (Hugin.num ~scale m)

let heatmap ?scale_name ?(domain = (-0.35, 0.35)) m =
  heatmap_2d ?scale_name ~domain m

let grid_rules ?(width = 0.45) ?(stroke = grey) positions =
  let v_rules =
    List.map positions ~f:(fun p ->
      Hugin.rule
        ~x:(Hugin.num ~scale:(lin ()) (scalar (Float.of_int p)))
        ~stroke:(Hugin.const stroke)
        ~width:(Hugin.const width)
        ())
  in
  let h_rules =
    List.map positions ~f:(fun p ->
      Hugin.rule
        ~y:(Hugin.num ~scale:(linr ()) (scalar (Float.of_int p)))
        ~stroke:(Hugin.const stroke)
        ~width:(Hugin.const width)
        ())
  in
  v_rules @ h_rules

let bare_matrix ?(rules = []) ?(labels = []) fig_cell =
  Hugin.layer
    ([ fig_cell ]
    @ rules
    @ labels
    @ [ Hugin.axis ~show:false "x"
      ; Hugin.axis ~show:false "y"
      ; Hugin.frame ()
      ])
  |> Hugin.coord (Hugin.Coord.cartesian ~aspect:1. ())

let mosaic ?(domain = (-0.35, 0.35)) ?(min_label_size = 12) m leaves =
  let offsets =
    List.folding_map leaves ~init:0 ~f:(fun acc (_, n) -> acc + n, acc)
  in
  let boundaries = List.tl_exn offsets in
  let rules = grid_rules ~width:0.4 boundaries in
  let labels =
    List.filter (List.map2_exn leaves offsets ~f:(fun (name, n) o -> name, n, o))
      ~f:(fun (_, n, _) -> n >= min_label_size)
    |> List.map ~f:(fun (name, n, o) ->
      let c = Float.of_int (o + (n / 2)) in
      Hugin.text
        ~x:(Hugin.num ~scale:(lin ()) (scalar c))
        ~y:(Hugin.num ~scale:(linr ()) (scalar c))
        ~fill:(Hugin.const (Hugin.Color.v 0.12 0.12 0.15))
        ~text:(Hugin.const (Hugin.Text.v name))
        ())
  in
  bare_matrix ~rules ~labels (heatmap ~domain m)

(* Count distinct entries in a 2D tensor up to 1e-4 precision. *)
let distinct m =
  let s = Nx.shape m in
  let r = s.(0) and c = s.(1) in
  let seen = Hashtbl.create (module Int) in
  for i = 0 to r - 1 do
    for j = 0 to c - 1 do
      let x = item [ i; j ] m in
      let q = Float.to_int (Float.round (x *. 1e4)) in
      Hashtbl.set seen ~key:q ~data:()
    done
  done;
  Hashtbl.length seen

let fig_theme =
  Hugin.Theme.v
    ~size:11.
    ~paper:Hugin.Color.transparent
    ~ink:Hugin.Color.black
    ()

let postprocess_svg path =
  let raw = Stdlib.In_channel.with_open_bin path Stdlib.In_channel.input_all in
  (* Strip data-rows="0 1 2 ..." attributes and rewrite black ink to currentColor *)
  let buf = Buffer.create (String.length raw) in
  let n = String.length raw in
  let starts_at i prefix =
    let lp = String.length prefix in
    i + lp <= n && String.equal (String.sub raw ~pos:i ~len:lp) prefix
  in
  let rec loop i =
    if i >= n
    then ()
    else if starts_at i " data-rows=\""
    then (
      match String.index_from raw (i + 12) '"' with
      | Some close -> loop (close + 1)
      | None ->
        Buffer.add_char buf raw.[i];
        loop (i + 1))
    else if starts_at i "fill=\"#000000\""
    then (
      Buffer.add_string buf "fill=\"currentColor\"";
      loop (i + 14))
    else if starts_at i "stroke=\"#000000\""
    then (
      Buffer.add_string buf "stroke=\"currentColor\"";
      loop (i + 16))
    else (
      Buffer.add_char buf raw.[i];
      loop (i + 1))
  in
  loop 0;
  Stdlib.Out_channel.with_open_bin path (fun oc ->
    Stdlib.Out_channel.output_string oc (Buffer.contents buf))

let save_fig ~w ~h file fig =
  let path = out file in
  Hugin.save
    ~theme:fig_theme
    ~size:(Hugin.Size.figure w h)
    ~warn:(fun _ -> ())
    path
    fig;
  if String.is_suffix file ~suffix:".svg" then postprocess_svg path;
  Stdio.printf "wrote %s\n%!" path

(* ------------------------------------------------------------------------
   Figure 1 & 2: The 3x4 running example under {e}, S_3, B_3, S_3 x S_4,
                 and the Pi / Pi_perp block decomposition
   ------------------------------------------------------------------------ *)

module Leaf_id = struct
  type ('a, _) t = { c : 'a } [@@deriving ptree]
  let dims = { c = [ 3; 4 ] }
  let symmetries = { c = [ Symmetry.Id; Symmetry.Id ] }
end

module Leaf_s3 = struct
  type ('a, _) t = { c : 'a } [@@deriving ptree]
  let dims = { c = [ 3; 4 ] }
  let symmetries = { c = [ Symmetry.Perm 0; Symmetry.Id ] }
end

module Leaf_s3x4 = struct
  type ('a, _) t = { c : 'a } [@@deriving ptree]
  let dims = { c = [ 3; 4 ] }
  let symmetries = { c = [ Symmetry.Perm 0; Symmetry.Perm 1 ] }
end

module O_id = Orbit.Make (Leaf_id)
module O_s3 = Orbit.Make (Leaf_s3)
module O_s3x4 = Orbit.Make (Leaf_s3x4)

let c_3x4 =
  Nx.create float32 [| 3; 4 |]
    [|  1.10; -0.65;  0.40; -0.95
     ; -0.50;  1.25; -0.80;  0.30
     ;  0.75;  0.20;  1.05; -0.55
    |]

let r2_dense_s3 c =
  let leaf = { Leaf_s3.c } in
  O_s3.Second_order.factors_of_pair ~symmetric:true leaf leaf
  |> O_s3.Second_order.dense_of_factors ~symmetric:true

let () =
  (* 1. Running example under 4 symmetry groups *)
  let s_id =
    let leaf = { Leaf_id.c = c_3x4 } in
    O_id.Second_order.factors_of_pair ~symmetric:true leaf leaf
    |> O_id.Second_order.dense_of_factors ~symmetric:true
  in
  let s_s3 = r2_dense_s3 c_3x4 in
  (* Under signed permutations B_3, G = 0 and F = (1/n) C^T C, so S = I_3 (x) F. *)
  let f_signed = Infix.((transpose c_3x4 *@ c_3x4) *$ (1. /. 3.)) in
  let s_b3 = kron (eye float32 3) f_signed in
  let s_s3x4 =
    let leaf = { Leaf_s3x4.c = c_3x4 } in
    O_s3x4.Second_order.factors_of_pair ~symmetric:true leaf leaf
    |> O_s3x4.Second_order.dense_of_factors ~symmetric:true
  in
  Stdio.printf
    "3x4 running example (12x12 operator, 144 entries): distinct values: {e}=%d, S_3=%d, B_3=%d, S_3xS_4=%d\n%!"
    (distinct s_id)
    (distinct s_s3)
    (distinct s_b3)
    (distinct s_s3x4);
  let block_rules = grid_rules ~width:0.55 [ 4; 8 ] in
  let panel title_str m =
    bare_matrix ~rules:block_rules (heatmap ~domain:(-0.9, 0.9) m)
    |> Hugin.title title_str
  in
  let fig1 =
    Hugin.grid
      [ [ panel "(a) Trivial {e} (78 entries)" s_id
        ; panel "(b) Row perm. S3 (20 values)" s_s3
        ]
      ; [ panel "(c) Signed perm. B3 (10 values)" s_b3
        ; panel "(d) Product S3 × S4 (4 values)" s_s3x4
        ]
      ]
  in
  save_fig ~w:520. ~h:510. "running_example_3x4.svg" fig1;

  (* 2. Pi / Pi_perp basis & row mean-covariance identity *)
  (* Build orthogonal Helmert matrix Q in O(3): col 0 = 1/sqrt(3), cols 1,2 span 1^perp *)
  let s3 = Float.sqrt 3. and s2 = Float.sqrt 2. and s6 = Float.sqrt 6. in
  let q3 =
    Nx.create float32 [| 3; 3 |]
      [| 1. /. s3;  1. /. s2;  1. /. s6
       ; 1. /. s3; -1. /. s2;  1. /. s6
       ; 1. /. s3;  0.0;      -2. /. s6
      |]
  in
  let q12 = kron q3 (eye float32 4) in
  let s_block_diag = Infix.(transpose q12 *@ s_s3 *@ q12) in
  (* Verify mean-covariance blocks against Second_order.blocks_of_factors *)
  let blocks =
    let leaf = { Leaf_s3.c = c_3x4 } in
    O_s3.Second_order.factors_of_pair ~symmetric:true leaf leaf
    |> O_s3.Second_order.blocks_of_factors ~symmetric:true
  in
  let b_empty = List.nth_exn blocks 0 in
  let b_std = List.nth_exn blocks 1 in
  let c_mean = mean ~axes:[ 0 ] ~keepdims:true c_3x4 in
  let b_empty_stat = Infix.((transpose c_mean *@ c_mean) *$ 3.) in
  let c_centered = Infix.(c_3x4 - c_mean) in
  let b_std_stat = Infix.((transpose c_centered *@ c_centered) *$ 0.5) in
  let err_empty = item [] (max (abs Infix.(b_empty - b_empty_stat))) in
  let err_std = item [] (max (abs Infix.(b_std - b_std_stat))) in
  Stdio.printf
    "3x4 mean-covariance check: max |B_empty - 3 c_bar c_bar^T| = %.2e, max |B_[1] - Cov(C)| = %.2e\n%!"
    err_empty
    err_std;
  let fig2 =
    Hugin.grid
      [ [ bare_matrix ~rules:block_rules (heatmap ~domain:(-0.9, 0.9) s_s3)
          |> Hugin.title "(a) S in unit basis (12×12)"
        ; bare_matrix ~rules:block_rules (heatmap ~domain:(-0.9, 0.9) s_block_diag)
          |> Hugin.title "(b) Block-diagonal B_0 + B_[1] + B_[1]"
        ]
      ; [ bare_matrix ~rules:(grid_rules ~width:0.35 [ 1; 2; 3 ])
            (heatmap ~domain:(-0.9, 0.9) b_empty)
          |> Hugin.title "(c) B_0 = 3 c_bar c_bar^T (4×4)"
        ; bare_matrix ~rules:(grid_rules ~width:0.35 [ 1; 2; 3 ])
            (heatmap ~domain:(-0.9, 0.9) b_std)
          |> Hugin.title "(d) B_[1] = Cov(C) (4×4)"
        ]
      ]
  in
  save_fig ~w:520. ~h:570. "pi_perp_blocks_3x4.svg" fig2

(* ------------------------------------------------------------------------
   Figure 3: Exact closed-form projection R2 vs Monte Carlo orbit sampling
   ------------------------------------------------------------------------ *)

module Layer_s8 = struct
  type ('a, _) t = { w : 'a } [@@deriving ptree]
  let dims = { w = [ 8; 4 ] }
  let symmetries = { w = [ Symmetry.Perm 0; Symmetry.Id ] }
end

module O_s8 = Orbit.Make (Layer_s8)

let () =
  let w0 =
    { Layer_s8.w = Rng.normal ~key:(Rng.key 17) float32 [| 8; 4 |] }
  in
  let exact =
    O_s8.Second_order.factors_of_pair ~symmetric:true w0 w0
    |> O_s8.Second_order.dense_of_factors ~symmetric:true
  in
  let norm_exact = Float.sqrt (item [] (sum (square exact))) in
  let max_m = 512 in
  let key_base = Rng.key 99 in
  let running = ref (zeros float32 [| 32; 32 |]) in
  let sample_3 = ref (zeros float32 [| 32; 32 |]) in
  let sample_pts = [| 1; 2; 3; 4; 6; 8; 12; 16; 24; 32; 48; 64; 96; 128; 192; 256; 384; 512 |] in
  let n_pts = Array.length sample_pts in
  let errs = Array.create ~len:n_pts 0.0 in
  let pt_idx = ref 0 in
  for m = 1 to max_m do
    let wm = O_s8.random_transform ~key:(Rng.fold_in key_base m) w0 in
    let flat = reshape [| 32; 1 |] wm.w in
    let outer = Infix.(flat *@ transpose flat) in
    running := Infix.(!running + outer);
    let avg = Infix.(!running *$ (1. /. Float.of_int m)) in
    if Int.equal m 3 then sample_3 := avg;
    if !pt_idx < n_pts && Int.equal m sample_pts.(!pt_idx)
    then (
      let diff = Infix.(avg - exact) in
      let rel = Float.sqrt (item [] (sum (square diff))) /. norm_exact in
      errs.(!pt_idx) <- rel;
      Int.incr pt_idx)
  done;
  let m_floats = Nx.create float32 [| n_pts |] (Array.map sample_pts ~f:Float.of_int) in
  let err_tensor = Nx.create float32 [| n_pts |] errs in
  let theory_tensor =
    Nx.create float32 [| n_pts |]
      (Array.map sample_pts ~f:(fun m -> errs.(0) /. Float.sqrt (Float.of_int m)))
  in
  let curves = stack ~axis:0 [ err_tensor; theory_tensor ] in
  let labels = [| "Monte Carlo sample average (M draws)"; "M^(-1/2) reference slope" |] in
  let p_left =
    bare_matrix ~rules:(grid_rules ~width:0.35 [ 4; 8; 12; 16; 20; 24; 28 ])
      (heatmap ~domain:(-1.2, 1.2) !sample_3)
    |> Hugin.title "(a) Sample average (M = 3)"
  in
  let p_mid =
    bare_matrix ~rules:(grid_rules ~width:0.35 [ 4; 8; 12; 16; 20; 24; 28 ])
      (heatmap ~domain:(-1.2, 1.2) exact)
    |> Hugin.title "(b) Exact R2 (8! = 40,320)"
  in
  let p_right =
    Hugin.layer
      [ Hugin.line
          ~x:(Hugin.num ~scale:(Hugin.Scale.log ~name:"mx" ()) ~title:"Monte Carlo samples M" m_floats)
          ~y:(Hugin.num ~scale:(Hugin.Scale.log ~name:"my" ()) ~title:"relative error" curves)
          ~stroke:(Hugin.dim ~scale:(Hugin.Scale.band ~name:"mc_cat" ()) ~labels 0)
          ~width:(Hugin.const 1.6)
          ()
      ; Hugin.dot
          ~x:(Hugin.num ~scale:(Hugin.Scale.log ~name:"mx" ()) m_floats)
          ~y:(Hugin.num ~scale:(Hugin.Scale.log ~name:"my" ()) err_tensor)
          ~fill:(Hugin.const (color "#1f77b4"))
          ()
      ; Hugin.axis ~grid:true "mx"
      ; Hugin.axis ~grid:true "my"
      ; Hugin.legend ~side:(`Inside `Top_right) "mc_cat"
      ]
    |> Hugin.title "(c) Monte Carlo convergence vs exact R2"
  in
  let fig3 =
    Hugin.grid
      ~heights:[ 1.15; 1.0 ]
      [ [ p_left; p_mid ]
      ; [ Hugin.span ~cols:2 p_right ]
      ]
  in
  save_fig ~w:520. ~h:570. "orbit_convergence_r1_r2.svg" fig3

(* ------------------------------------------------------------------------
   Figure 4: Two-hidden-layer MLP parameter-tree mosaic (S_6 x S_5)
   ------------------------------------------------------------------------ *)

module Mlp2 = struct
  type ('a, _) t =
    { w1 : 'a (* h1 x in:  6 x 3 = 18 *)
    ; b1 : 'a (* h1:       6          *)
    ; w2 : 'a (* h2 x h1:  5 x 6 = 30 *)
    ; b2 : 'a (* h2:       5          *)
    ; w3 : 'a (* out x h2: 2 x 5 = 10 *)
    }
  [@@deriving ptree, sexp]

  let h1 = 6
  let h2 = 5
  let d_in = 3
  let d_out = 2
  let batch = 48

  let dims =
    { w1 = [ h1; d_in ]
    ; b1 = [ h1 ]
    ; w2 = [ h2; h1 ]
    ; b2 = [ h2 ]
    ; w3 = [ d_out; h2 ]
    }

  (* Group 0 (S_6) permutes layer 1 hidden units; Group 1 (S_5) permutes
     layer 2 hidden units. They meet on [w2]. *)
  let symmetries : (Symmetry.spec list, _) t =
    { w1 = [ Symmetry.Perm 0; Symmetry.Id ]
    ; b1 = [ Symmetry.Perm 0 ]
    ; w2 = [ Symmetry.Perm 1; Symmetry.Perm 0 ]
    ; b2 = [ Symmetry.Perm 1 ]
    ; w3 = [ Symmetry.Id; Symmetry.Perm 1 ]
    }

  let normal key scale shape = Infix.(Rng.normal ~key float32 shape *$ scale)

  let init key =
    { w1 = normal (Rng.fold_in key 0) 0.6 [| h1; d_in |]
    ; b1 = normal (Rng.fold_in key 1) 0.25 [| h1 |]
    ; w2 = normal (Rng.fold_in key 2) 0.5 [| h2; h1 |]
    ; b2 = normal (Rng.fold_in key 3) 0.25 [| h2 |]
    ; w3 = normal (Rng.fold_in key 4) 0.6 [| d_out; h2 |]
    }

  let forward (p : (Nx.host Nx.float32_t, Nx.host) t) ~x =
    let a1 = tanh Infix.((x *@ transpose p.w1) + p.b1) in
    let a2 = tanh Infix.((a1 *@ transpose p.w2) + p.b2) in
    Infix.(a2 *@ transpose p.w3)

  let leaves =
    [ "W1", h1 * d_in
    ; "b1", h1
    ; "W2", h2 * h1
    ; "b2", h2
    ; "W3", d_out * h2
    ]
end

module O_mlp2 = Orbit.Make (Mlp2)

let () =
  let x = Rng.normal ~key:(Rng.key 31) float32 [| Mlp2.batch; Mlp2.d_in |] in
  let y_target = Mlp2.forward (Mlp2.init (Rng.key 32)) ~x in
  let loss p = mean (square Infix.(Mlp2.forward p ~x - y_target)) in
  let ptree = Ptree.instantiate (module Mlp2) in
  let p0 = Mlp2.init (Rng.key 33) in
  let g0 = snd (Rune.value_and_grad ptree loss p0) in
  let r2_corr a =
    O_mlp2.Second_order.factors_of_pair ~symmetric:true a a
    |> O_mlp2.Second_order.dense_of_factors ~symmetric:true
    |> uniformise_diag
  in
  let m_params = r2_corr p0 in
  let m_grads = r2_corr g0 in
  let fig4 =
    Hugin.grid
      [ [ mosaic ~min_label_size:10 m_params Mlp2.leaves
          |> Hugin.title "(a) Parameters R2(w, w)"
        ; mosaic ~min_label_size:10 m_grads Mlp2.leaves
          |> Hugin.title "(b) Gradients R2(g, g)"
        ]
      ]
  in
  save_fig ~w:530. ~h:340. "mlp_tree_mosaic.svg" fig4

(* ------------------------------------------------------------------------
   Figure 5: 7-leaf MLP-step RNN mosaic (G_h x G_z = S_8 x S_6)
   ------------------------------------------------------------------------ *)

module Rnn_mlp = struct
  type ('a, _) t =
    { w1 : 'a (* hidden x state:  8 x 6 = 48 *)
    ; w2 : 'a (* state x hidden:  6 x 8 = 48 *)
    ; b1 : 'a (* hidden:          8          *)
    ; b2 : 'a (* state:           6          *)
    ; wi : 'a (* state x input:   6 x 3 = 18 *)
    ; w3 : 'a (* output x state:  2 x 6 = 12 *)
    ; b3 : 'a (* output:          2          *)
    }
  [@@deriving ptree, sexp]

  let hidden = 8
  let state = 6
  let input_dim = 3
  let output_dim = 2
  let steps = 10
  let batch = 64

  let dims =
    { w1 = [ hidden; state ]
    ; w2 = [ state; hidden ]
    ; b1 = [ hidden ]
    ; b2 = [ state ]
    ; wi = [ state; input_dim ]
    ; w3 = [ output_dim; state ]
    ; b3 = [ output_dim ]
    }

  let symmetries : (Symmetry.spec list, _) t =
    { w1 = [ Symmetry.Perm 0; Symmetry.Perm 1 ]
    ; w2 = [ Symmetry.Perm 1; Symmetry.Perm 0 ]
    ; b1 = [ Symmetry.Perm 0 ]
    ; b2 = [ Symmetry.Perm 1 ]
    ; wi = [ Symmetry.Perm 1; Symmetry.Id ]
    ; w3 = [ Symmetry.Id; Symmetry.Perm 1 ]
    ; b3 = [ Symmetry.Id ]
    }

  let normal key scale shape = Infix.(Rng.normal ~key float32 shape *$ scale)

  let init key =
    let f = Float.of_int in
    { w1 = normal (Rng.fold_in key 0) (1. /. Float.sqrt (f state)) [| hidden; state |]
    ; w2 = normal (Rng.fold_in key 1) (1.5 /. Float.sqrt (f hidden)) [| state; hidden |]
    ; b1 = normal (Rng.fold_in key 4) 0.2 [| hidden |]
    ; b2 = normal (Rng.fold_in key 5) 0.2 [| state |]
    ; wi = normal (Rng.fold_in key 2) (1. /. Float.sqrt (f input_dim)) [| state; input_dim |]
    ; w3 = normal (Rng.fold_in key 3) (1. /. Float.sqrt (f state)) [| output_dim; state |]
    ; b3 = normal (Rng.fold_in key 6) 0.2 [| output_dim |]
    }

  let forward (p : (Nx.host Nx.float32_t, Nx.host) t) ~input =
    let rec go t z =
      if Int.equal t steps
      then z
      else (
        let u = slice [ I t ] input in
        let h = tanh Infix.((z *@ transpose p.w1) + p.b1) in
        let z = Infix.((h *@ transpose p.w2) + p.b2 + (u *@ transpose p.wi)) in
        go (t + 1) z)
    in
    let z = go 0 (zeros float32 [| batch; state |]) in
    Infix.((z *@ transpose p.w3) + p.b3)

  let leaves =
    [ "W1", hidden * state
    ; "W2", state * hidden
    ; "b1", hidden
    ; "b2", state
    ; "B", state * input_dim
    ; "W3", output_dim * state
    ; "b3", output_dim
    ]
end

module O_rnn = Orbit.Make (Rnn_mlp)

let () =
  let input =
    Rng.normal ~key:(Rng.key 11) float32 [| Rnn_mlp.steps; Rnn_mlp.batch; Rnn_mlp.input_dim |]
  in
  let targets = Rnn_mlp.forward (Rnn_mlp.init (Rng.key 1)) ~input in
  let loss p = mean (square Infix.(Rnn_mlp.forward p ~input - targets)) in
  let ptree = Ptree.instantiate (module Rnn_mlp) in
  let p0 = Rnn_mlp.init (Rng.key 2) in
  let g0 = snd (Rune.value_and_grad ptree loss p0) in
  let r2_corr a =
    O_rnn.Second_order.factors_of_pair ~symmetric:true a a
    |> O_rnn.Second_order.dense_of_factors ~symmetric:true
    |> uniformise_diag
  in
  let m_params = r2_corr p0 in
  let m_grads = r2_corr g0 in
  let w1_tile = slice [ R (0, 48); R (0, 48) ] m_grads in
  let w12_cross = slice [ R (0, 48); R (48, 96) ] m_grads in
  let b1_tile = slice [ R (96, 104); R (96, 104) ] m_grads in
  Stdio.printf
    "MLP-step RNN (D=142): distinct values in W1=%d, cross (W1,W2)=%d, b1=%d\n%!"
    (distinct w1_tile)
    (distinct w12_cross)
    (distinct b1_tile);
  let fig5 =
    Hugin.grid
      [ [ mosaic ~min_label_size:18 m_params Rnn_mlp.leaves
          |> Hugin.title "(a) RNN parameters R2(w, w)"
        ; mosaic ~min_label_size:18 m_grads Rnn_mlp.leaves
          |> Hugin.title "(b) RNN gradients R2(g, g)"
        ]
      ]
  in
  save_fig ~w:530. ~h:340. "rnn_mlp_mosaic.svg" fig5

(* ------------------------------------------------------------------------
   Figure 6: Vanilla RNN (k = 2): Bell(4) = 15 patterns & 11 symmetric values
   ------------------------------------------------------------------------ *)

module Vrnn = struct
  type ('a, _) t =
    { w : 'a (* state x state *)
    ; u : 'a (* state x input *)
    ; b : 'a (* state *)
    ; v : 'a (* output x state *)
    }
  [@@deriving ptree, sexp]

  let state = 8
  let input_dim = 3
  let output_dim = 2
  let steps = 15
  let batch = 64

  let dims =
    { w = [ state; state ]
    ; u = [ state; input_dim ]
    ; b = [ state ]
    ; v = [ output_dim; state ]
    }

  let symmetries : (Symmetry.spec list, _) t =
    { w = [ Symmetry.Perm 0; Symmetry.Perm 0 ]
    ; u = [ Symmetry.Perm 0; Symmetry.Id ]
    ; b = [ Symmetry.Perm 0 ]
    ; v = [ Symmetry.Id; Symmetry.Perm 0 ]
    }

  let normal key scale shape = Infix.(Rng.normal ~key float32 shape *$ scale)

  let init key =
    let f = Float.of_int in
    { w = normal (Rng.fold_in key 0) (1.2 /. Float.sqrt (f state)) [| state; state |]
    ; u = normal (Rng.fold_in key 1) (1. /. Float.sqrt (f input_dim)) [| state; input_dim |]
    ; b = zeros float32 [| state |]
    ; v = normal (Rng.fold_in key 2) (1. /. Float.sqrt (f state)) [| output_dim; state |]
    }

  let forward (p : (Nx.host Nx.float32_t, Nx.host) t) ~input =
    let rec go t z =
      if Int.equal t steps
      then z
      else (
        let x = slice [ I t ] input in
        let z = tanh Infix.((z *@ transpose p.w) + (x *@ transpose p.u) + p.b) in
        go (t + 1) z)
    in
    let z = go 0 (zeros float32 [| batch; state |]) in
    Infix.(z *@ transpose p.v)
end

module O_vrnn = Orbit.Make (Vrnn)

let codes n =
  let size = n * n in
  let names = Hashtbl.create (module String) in
  let count = ref 0 in
  let arr = Array.create ~len:(size * size) 0 in
  for i = 0 to size - 1 do
    for j = 0 to size - 1 do
      let m, nn = i / n, Int.rem i n in
      let o, p = j / n, Int.rem j n in
      let seen = Hashtbl.create (module Int) in
      let next = ref 0 in
      let id x =
        match Hashtbl.find seen x with
        | Some k -> k
        | None ->
          let k = !next in
          Int.incr next;
          Hashtbl.set seen ~key:x ~data:k;
          k
      in
      let key = Printf.sprintf "%d%d%d%d" (id m) (id nn) (id o) (id p) in
      let k =
        match Hashtbl.find names key with
        | Some k -> k
        | None ->
          let k = !count in
          Int.incr count;
          Hashtbl.set names ~key ~data:k;
          k
      in
      arr.((i * size) + j) <- k
    done
  done;
  !count, arr, Nx.create Nx.int32 [| size; size |] (Array.map arr ~f:Int32.of_int_exn)

let palette_15 =
  [| "#3b6fb6"; "#e06c1f"; "#c9353c"; "#2f9d8f"; "#5aa02c"; "#d8b02a";
     "#8b5cb0"; "#e8739c"; "#6b4b3a"; "#4fa3d9"; "#a34b8a"; "#7a8b1f";
     "#c25b3a"; "#2c6e5b"; "#9aa7b4" |]
  |> Array.map ~f:color

let check_patterns count codes m =
  let size = (Nx.shape m).(0) in
  let lo = Array.create ~len:count Float.infinity in
  let hi = Array.create ~len:count Float.neg_infinity in
  for i = 0 to size - 1 do
    for j = 0 to size - 1 do
      let k = codes.((i * size) + j) in
      let x = item [ i; j ] m in
      lo.(k) <- Float.min lo.(k) x;
      hi.(k) <- Float.max hi.(k) x
    done
  done;
  Array.fold2_exn lo hi ~init:0. ~f:(fun acc a b ->
    if Float.is_finite a then Float.max acc (b -. a) else acc)

let () =
  let vinput =
    Rng.normal ~key:(Rng.key 21) float32 [| Vrnn.steps; Vrnn.batch; Vrnn.input_dim |]
  in
  let vtargets = Vrnn.forward (Vrnn.init (Rng.key 3)) ~input:vinput in
  let vloss p = mean (square Infix.(Vrnn.forward p ~input:vinput - vtargets)) in
  let ptree = Ptree.instantiate (module Vrnn) in
  let g = snd (Rune.value_and_grad ptree vloss (Vrnn.init (Rng.key 4))) in
  let vgrad =
    O_vrnn.Second_order.factors_of_pair ~symmetric:true g g
    |> O_vrnn.Second_order.dense_of_factors ~symmetric:true
    |> uniformise_diag
  in
  let n2 = Vrnn.state * Vrnn.state in
  let block = slice [ R (0, n2); R (0, n2) ] vgrad in
  let count, code_arr, code_tensor = codes Vrnn.state in
  let dev = check_patterns count code_arr block in
  Stdio.printf
    "Vanilla RNN k=2 block (64x64): %d pattern classes, %d distinct symmetric values, max within-class deviation = %.3e\n%!"
    count
    (distinct block)
    dev;
  let labels = Array.init count ~f:(fun i -> Printf.sprintf "P%d" (i + 1)) in
  let band =
    Hugin.Scale.band ~name:"pat15" ~scheme:(Hugin.Scheme.palette palette_15) ()
  in
  let sub_rules =
    grid_rules ~width:0.25 (List.init (Vrnn.state - 1) ~f:(fun i -> (i + 1) * Vrnn.state))
  in
  let p_patterns =
    bare_matrix
      ~rules:sub_rules
      ~labels:[ Hugin.legend ~side:`Bottom ~ncol:5 "pat15" ]
      (cells n2 (Hugin.cat ~labels ~scale:band code_tensor))
    |> Hugin.title "(a) B4 = 15 partition classes"
  in
  let p_values =
    bare_matrix ~rules:sub_rules (heatmap ~scale_name:"val15" ~domain:(-0.3, 0.3) block)
    |> Hugin.title "(b) Gradient average (11 levels)"
  in
  let fig6 =
    Hugin.grid [ [ p_patterns; p_values ] ]
  in
  save_fig ~w:530. ~h:390. "vanilla_rnn_15_patterns.svg" fig6

(* ------------------------------------------------------------------------
   Figure 7: Gated Recurrent Unit (GRU) mosaic & 15-value cross-gate tile
   ------------------------------------------------------------------------ *)

module Gru = struct
  type ('a, _) t =
    { wr : 'a (* reset gate state x state:     6 x 6 = 36 *)
    ; wz : 'a (* update gate state x state:    6 x 6 = 36 *)
    ; wh : 'a (* candidate gate state x state: 6 x 6 = 36 *)
    ; ur : 'a (* reset input x in:             6 x 2 = 12 *)
    ; uz : 'a (* update input x in:            6 x 2 = 12 *)
    ; uh : 'a (* candidate input x in:         6 x 2 = 12 *)
    ; br : 'a (* reset bias:                   6          *)
    ; bz : 'a (* update bias:                  6          *)
    ; bh : 'a (* candidate bias:               6          *)
    ; v  : 'a (* readout out x state:          2 x 6 = 12 *)
    }
  [@@deriving ptree, sexp]

  let state = 6
  let d_in = 2
  let d_out = 2
  let steps = 8
  let batch = 32

  let dims =
    { wr = [ state; state ]
    ; wz = [ state; state ]
    ; wh = [ state; state ]
    ; ur = [ state; d_in ]
    ; uz = [ state; d_in ]
    ; uh = [ state; d_in ]
    ; br = [ state ]
    ; bz = [ state ]
    ; bh = [ state ]
    ; v  = [ d_out; state ]
    }

  (* Every gate matrix Wr, Wz, Wh transforms by Q W Q^T under the single state
     permutation group Perm 0 (k = 2). *)
  let symmetries : (Symmetry.spec list, _) t =
    { wr = [ Symmetry.Perm 0; Symmetry.Perm 0 ]
    ; wz = [ Symmetry.Perm 0; Symmetry.Perm 0 ]
    ; wh = [ Symmetry.Perm 0; Symmetry.Perm 0 ]
    ; ur = [ Symmetry.Perm 0; Symmetry.Id ]
    ; uz = [ Symmetry.Perm 0; Symmetry.Id ]
    ; uh = [ Symmetry.Perm 0; Symmetry.Id ]
    ; br = [ Symmetry.Perm 0 ]
    ; bz = [ Symmetry.Perm 0 ]
    ; bh = [ Symmetry.Perm 0 ]
    ; v  = [ Symmetry.Id; Symmetry.Perm 0 ]
    }

  let normal key scale shape = Infix.(Rng.normal ~key float32 shape *$ scale)

  let init key =
    let s = 1. /. Float.sqrt (Float.of_int state) in
    { wr = normal (Rng.fold_in key 0) s [| state; state |]
    ; wz = normal (Rng.fold_in key 1) s [| state; state |]
    ; wh = normal (Rng.fold_in key 2) s [| state; state |]
    ; ur = normal (Rng.fold_in key 3) 0.6 [| state; d_in |]
    ; uz = normal (Rng.fold_in key 4) 0.6 [| state; d_in |]
    ; uh = normal (Rng.fold_in key 5) 0.6 [| state; d_in |]
    ; br = normal (Rng.fold_in key 6) 0.2 [| state |]
    ; bz = normal (Rng.fold_in key 7) 0.2 [| state |]
    ; bh = normal (Rng.fold_in key 8) 0.2 [| state |]
    ; v  = normal (Rng.fold_in key 9) s [| d_out; state |]
    }

  let sigmoid x = Infix.(scalar 1. / (scalar 1. + exp (neg x)))

  let forward (p : (Nx.host Nx.float32_t, Nx.host) t) ~input =
    let rec go t z =
      if Int.equal t steps
      then z
      else (
        let x = slice [ I t ] input in
        let r = sigmoid Infix.((z *@ transpose p.wr) + (x *@ transpose p.ur) + p.br) in
        let u = sigmoid Infix.((z *@ transpose p.wz) + (x *@ transpose p.uz) + p.bz) in
        let h_tilde =
          tanh Infix.(((r * z) *@ transpose p.wh) + (x *@ transpose p.uh) + p.bh)
        in
        let z_next = Infix.(((scalar 1. - u) * z) + (u * h_tilde)) in
        go (t + 1) z_next)
    in
    let z = go 0 (zeros float32 [| batch; state |]) in
    Infix.(z *@ transpose p.v)

  let leaves =
    [ "Wr", state * state
    ; "Wz", state * state
    ; "Wh", state * state
    ; "Ur", state * d_in
    ; "Uz", state * d_in
    ; "Uh", state * d_in
    ; "br", state
    ; "bz", state
    ; "bh", state
    ; "V",  d_out * state
    ]
end

module O_gru = Orbit.Make (Gru)

let () =
  let input =
    Rng.normal ~key:(Rng.key 41) float32 [| Gru.steps; Gru.batch; Gru.d_in |]
  in
  let targets = Gru.forward (Gru.init (Rng.key 42)) ~input in
  let loss p = mean (square Infix.(Gru.forward p ~input - targets)) in
  let ptree = Ptree.instantiate (module Gru) in
  let g = snd (Rune.value_and_grad ptree loss (Gru.init (Rng.key 43))) in
  let m_gru =
    O_gru.Second_order.factors_of_pair ~symmetric:true g g
    |> O_gru.Second_order.dense_of_factors ~symmetric:true
    |> uniformise_diag
  in
  let wr_diag = slice [ R (0, 36); R (0, 36) ] m_gru in
  let wr_wh_cross = slice [ R (0, 36); R (72, 108) ] m_gru in
  Stdio.printf
    "GRU mosaic (D=174): diagonal gate tile Wr has %d symmetric values; cross-gate tile (Wr,Wh) has %d asymmetric values\n%!"
    (distinct wr_diag)
    (distinct wr_wh_cross);
  let cross_rules = grid_rules ~width:0.3 [ 6; 12; 18; 24; 30 ] in
  let fig7 =
    Hugin.grid
      ~widths:[ 1.1; 1.0 ]
      [ [ mosaic ~domain:(-0.3, 0.3) ~min_label_size:12 m_gru Gru.leaves
          |> Hugin.title "(a) 10-leaf GRU mosaic (174×174)"
        ; bare_matrix ~rules:cross_rules (heatmap ~domain:(-0.3, 0.3) wr_wh_cross)
          |> Hugin.title "(b) Cross-gate R2(Wr, Wh)"
        ]
      ]
  in
  save_fig ~w:540. ~h:340. "gru_mosaic.svg" fig7

(* ------------------------------------------------------------------------
   Figure 8: The 7 canonical test vectors for k = 2 (n = 6) & block spectrum
   ------------------------------------------------------------------------ *)

let () =
  let n = 6 in
  let tvs = Kind.test_vectors ~k:2 ~n in
  let tv_names =
    [| "z_{0,0} (Π)"
     ; "z_{0,1} (Π_perp)"
     ; "z_{[1],0} (h1^T)"
     ; "z_{[1],1} (1h^T)"
     ; "z_{[1],2} (Diag)"
     ; "z_{[2],0} (4-cycle)"
     ; "z_{[1,1],0} (skew)"
    |]
  in
  let r6 = grid_rules ~width:0.25 [ 1; 2; 3; 4; 5 ] in
  let tv_panels =
    List.mapi tvs ~f:(fun idx (_, _, v) ->
      bare_matrix ~rules:r6 (heatmap ~domain:(-0.6, 0.6) v)
      |> Hugin.title tv_names.(idx))
  in
  (* Verify mutual orthonormality of the 7 test vectors *)
  let max_off_gram = ref 0.0 in
  List.iteri tvs ~f:(fun i (_, _, vi) ->
    List.iteri tvs ~f:(fun j (_, _, vj) ->
      let ip = item [] (sum Infix.(vi * vj)) in
      let target = if Int.equal i j then 1.0 else 0.0 in
      max_off_gram := Float.max !max_off_gram (Float.abs (ip -. target))));
  Stdio.printf
    "k=2 canonical test vectors (n=6): max |<z_i, z_j> - delta_ij| = %.2e\n%!"
    !max_off_gram;
  let fig8 =
    Hugin.grid
      [ List.sub tv_panels ~pos:0 ~len:3
      ; List.sub tv_panels ~pos:3 ~len:3
      ; List.sub tv_panels ~pos:6 ~len:1 @ [ Hugin.layer []; Hugin.layer [] ]
      ]
  in
  save_fig ~w:530. ~h:570. "test_vectors_and_blocks_k2.svg" fig8

(* ------------------------------------------------------------------------
   Figure 9: Exact width transport vs naive fixed-coordinate surrogate (k = 2)
   ------------------------------------------------------------------------ *)

module Square_k2 (Dim : sig val n : int end) = struct
  type ('a, _) t = { w : 'a } [@@deriving ptree]
  let dims = { w = [ Dim.n; Dim.n ] }
  let symmetries = { w = [ Symmetry.Perm 0; Symmetry.Perm 0 ] }
end

let block_eigs_with_mult ~n ~kinds ~blocks =
  let d_of_kind = function
    | [ [] ] -> 1.0
    | [ [ 1 ] ] -> Float.of_int (n - 1)
    | [ [ 2 ] ] -> Float.of_int (n * (n - 3) / 2)
    | [ [ 1; 1 ] ] -> Float.of_int ((n - 1) * (n - 2) / 2)
    | _ -> 1.0
  in
  List.map2_exn kinds blocks ~f:(fun kind b ->
    let mult = d_of_kind kind in
    let w, _ = eigh float64 (cast float64 b) in
    let arr = to_array (cast float32 w) in
    Array.sort arr ~compare:Float.compare;
    Array.to_list (Array.map arr ~f:(fun ev -> ev, mult)))
  |> List.concat
  |> Array.of_list

let () =
  let module M5 = Square_k2 (struct let n = 5 end) in
  let module O5 = Orbit.Make (M5) in
  (* Draw a fixed symmetric k=2 operator at n = 5 from 11 standard normal factors *)
  let key = Rng.key 123 in
  let c5_flat = Rng.normal ~key float32 [| O5.Second_order.factors_size |] in
  let c5 = O5.Second_order.unpack c5_flat in
  let widths = [| 4; 5; 6; 8; 10; 12 |] in
  let n_w = Array.length widths in
  let eigs_transport = Array.make_matrix ~dimx:7 ~dimy:n_w 0.0 in
  let eigs_naive = Array.make_matrix ~dimx:7 ~dimy:n_w 0.0 in
  let mults_by_eig = Array.make_matrix ~dimx:7 ~dimy:n_w 0.0 in
  Array.iteri widths ~f:(fun wi w_n ->
    let module Mn = Square_k2 (struct let n = w_n end) in
    let module On = Orbit.Make (Mn) in
    (* 1. Exact width transport from n = 5 to n = w_n *)
    let cn_trans_ on_c5 =
      O5.Second_order.transport ~symmetric:true ~dims:{ M5.w = [ w_n; w_n ] } on_c5
    in
    let cn_packed = O5.Second_order.pack (cn_trans_ c5) in
    let cn_trans = On.Second_order.unpack cn_packed in
    let et =
      block_eigs_with_mult
        ~n:w_n
        ~kinds:On.Second_order.kinds
        ~blocks:(On.Second_order.blocks_of_factors ~symmetric:true cn_trans)
    in
    (* 2. Naive fixed coordinates: reuse c5_flat directly at width w_n *)
    let cn_naive = On.Second_order.unpack c5_flat in
    let en =
      block_eigs_with_mult
        ~n:w_n
        ~kinds:On.Second_order.kinds
        ~blocks:(On.Second_order.blocks_of_factors ~symmetric:true cn_naive)
    in
    for k = 0 to 6 do
      eigs_transport.(k).(wi) <- fst et.(k);
      eigs_naive.(k).(wi) <- fst en.(k);
      mults_by_eig.(k).(wi) <- snd et.(k)
    done);
  let max_trans_drift =
    Array.fold eigs_transport ~init:0.0 ~f:(fun acc row ->
      Float.max acc (Float.abs (row.(n_w - 1) -. row.(0))))
  in
  let max_naive_drift =
    Array.fold eigs_naive ~init:0.0 ~f:(fun acc row ->
      Float.max acc (Float.abs (row.(n_w - 1) -. row.(0))))
  in
  Stdio.printf
    "k=2 width sweep n in {4..12}: max eigenvalue drift under transport = %.2e; under naive fixed factors = %.3f\n%!"
    max_trans_drift
    max_naive_drift;
  let w_tensor = Nx.create float32 [| n_w |] (Array.map widths ~f:Float.of_int) in
  let flat_2d m =
    Nx.create float32 [| 7; n_w |] (Array.concat (Array.to_list m))
  in
  let t_trans = flat_2d eigs_transport in
  let t_naive = flat_2d eigs_naive in
  let t_mults = flat_2d mults_by_eig in
  let eig_labels =
    [| "B_[1,1] (1×1)"
     ; "B_[2] (1×1)"
     ; "B_0 eig 1 (2×2)"
     ; "B_0 eig 2 (2×2)"
     ; "B_[1] eig 1 (3×3)"
     ; "B_[1] eig 2 (3×3)"
     ; "B_[1] eig 3 (3×3)"
    |]
  in
  let y_scale name = Hugin.Scale.linear ~name ~domain:(-5.2, 6.2) () in
  let sz_scale = Hugin.Scale.linear ~name:"mult_sz" ~domain:(1., 55.) ~areas:(20., 220.) () in
  let panel_lines ~with_legend y_name title_str y_tensor =
    Hugin.layer
      ([ Hugin.line
           ~x:(Hugin.num ~title:"permuted width n" w_tensor)
           ~y:(Hugin.num ~scale:(y_scale y_name) ~title:"block eigenvalue" y_tensor)
           ~stroke:(Hugin.dim ~title:"block eigenvalue" ~labels:eig_labels 0)
           ~width:(Hugin.const 1.6)
           ()
       ; Hugin.dot
           ~x:(Hugin.num w_tensor)
           ~y:(Hugin.num ~scale:(y_scale y_name) y_tensor)
           ~fill:(Hugin.dim ~labels:eig_labels 0)
           ~size:(Hugin.num ~scale:sz_scale ~title:"d_λ(n)" t_mults)
           ~opacity:(Hugin.const 0.85)
           ()
       ; Hugin.axis ~grid:true "x"
       ; Hugin.axis ~grid:true y_name
       ]
       @ if with_legend then [ Hugin.legend ~side:`Bottom ~ncol:3 "color" ] else [])
    |> Hugin.title title_str
  in
  let fig9 =
    Hugin.grid
      [ [ panel_lines ~with_legend:false "yt" "(a) Exact transport τ_{5->n}(c5): spectrum flat" t_trans ]
      ; [ panel_lines ~with_legend:true "yn" "(b) Naive fixed coordinates c_n = c5: spectrum drifts" t_naive ]
      ]
  in
  save_fig ~w:520. ~h:590. "transport_vs_naive_surrogate.svg" fig9

(* ------------------------------------------------------------------------
   Figure 10: Eigenvalue spectra & carrier multiplicities (symbol area = d_lambda)
              across Vanilla RNN (k=2), MLP-step RNN (S_8 x S_6), and GRU (S_6)
   ------------------------------------------------------------------------ *)

type eig_item =
  { ev : float
  ; mult : int
  ; kind_idx : int
  }

let spectrum_panel
      ~panel_title
      ~y_name
      ~cat_name
      ~sz_name
      ~kind_labels
      ~max_mult
      dense_mat
      (items : eig_item list)
  =
  let d = (Nx.shape dense_mat).(0) in
  let w_dense, _ = eigh float64 (cast float64 dense_mat) in
  let dense_arr = to_array (cast float32 w_dense) in
  Array.sort dense_arr ~compare:Float.compare;
  (* Positive clamping for log-scale spectrum display of positive semidefinite R2(g,g) *)
  let eps = 1e-7 in
  let dense_pos = Array.map dense_arr ~f:(fun x -> Float.max eps x) in
  let idx_dense = Nx.create float32 [| d |] (Array.init d ~f:(fun i -> Float.of_int (i + 1))) in
  let val_dense = Nx.create float32 [| d |] dense_pos in
  (* Sort block eigenvalues ascending and place each bubble at the midpoint index
     of its carrier-multiplicity plateau [cum + 1 .. cum + mult]. *)
  let sorted =
    List.sort items ~compare:(fun a b -> Float.compare a.ev b.ev)
  in
  let n_b = List.length sorted in
  let bx = Array.create ~len:n_b 0.0 in
  let by = Array.create ~len:n_b 0.0 in
  let bmult = Array.create ~len:n_b 0.0 in
  let bkind = Array.create ~len:n_b 0l in
  let cum = ref 0 in
  List.iteri sorted ~f:(fun i it ->
    let mid = Float.of_int !cum +. (0.5 *. Float.of_int it.mult) +. 0.5 in
    bx.(i) <- mid;
    by.(i) <- Float.max eps it.ev;
    bmult.(i) <- Float.of_int it.mult;
    bkind.(i) <- Int32.of_int_exn it.kind_idx;
    cum := !cum + it.mult);
  let y_sc = Hugin.Scale.log ~name:y_name () in
  let sz_sc =
    Hugin.Scale.linear ~name:sz_name ~domain:(1., Float.of_int max_mult) ~areas:(22., 260.) ()
  in
  let cat_sc = Hugin.Scale.band ~name:cat_name () in
  Hugin.layer
    [ Hugin.line
        ~x:(Hugin.num ~title:"eigenvalue index (1..D)" idx_dense)
        ~y:(Hugin.num ~scale:y_sc ~title:"eigenvalue of R2(g, g)" val_dense)
        ~curve:Hugin.Curve.step_after
        ~stroke:(Hugin.const (Hugin.Color.v 0.55 0.57 0.62))
        ~width:(Hugin.const 1.1)
        ()
    ; Hugin.dot
        ~x:(Hugin.num (Nx.create float32 [| n_b |] bx))
        ~y:(Hugin.num ~scale:y_sc (Nx.create float32 [| n_b |] by))
        ~size:(Hugin.num ~scale:sz_sc ~title:"multiplicity d_λ" (Nx.create float32 [| n_b |] bmult))
        ~fill:(Hugin.cat ~scale:cat_sc ~title:"isotypic kind λ" ~labels:kind_labels (Nx.create int32 [| n_b |] bkind))
        ~opacity:(Hugin.const 0.85)
        ()
    ; Hugin.axis ~grid:true "x"
    ; Hugin.axis ~grid:true y_name
    ; Hugin.legend ~side:`Bottom ~ncol:2 cat_name
    ]
  |> Hugin.title panel_title

let () =
  (* Average R2(g_b, g_b) over a mini-batch of M=12 probes so every Wedderburn
     block is full-rank positive definite and every eigenvalue plateau is
     strictly positive. *)
  let avg_factors ~factors_of_pair ~pack ~unpack samples =
    let packed =
      List.map samples ~f:(fun g ->
        factors_of_pair g g |> pack)
    in
    let n_s = Float.of_int (List.length packed) in
    let sum_p = List.reduce_exn packed ~f:(fun a b -> Infix.(a + b)) in
    unpack Infix.(sum_p *$ (1. /. n_s))
  in

  (* (a) Vanilla RNN recurrent block (n = 8, k = 2, D = 64) *)
  let module W_only = Square_k2 (struct let n = Vrnn.state end) in
  let module O_w = Orbit.Make (W_only) in
  let ptree_v = Ptree.instantiate (module Vrnn) in
  let v_samples =
    List.init 12 ~f:(fun s ->
      let vinput =
        Rng.normal ~key:(Rng.key (200 + s)) float32 [| Vrnn.steps; Vrnn.batch; Vrnn.input_dim |]
      in
      let vtargets = Vrnn.forward (Vrnn.init (Rng.key 3)) ~input:vinput in
      let vloss p = mean (square Infix.(Vrnn.forward p ~input:vinput - vtargets)) in
      let gv = snd (Rune.value_and_grad ptree_v vloss (Vrnn.init (Rng.key (300 + s)))) in
      { W_only.w = gv.w })
  in
  let fw =
    avg_factors
      ~factors_of_pair:(fun a b -> O_w.Second_order.factors_of_pair ~symmetric:true a b)
      ~pack:O_w.Second_order.pack
      ~unpack:O_w.Second_order.unpack
      v_samples
  in
  let dw = O_w.Second_order.dense_of_factors ~symmetric:true fw in
  let bw = O_w.Second_order.blocks_of_factors ~symmetric:true fw in
  let k2_labels =
    [| "0 (d=1)"; "[1] (d=n−1)"; "[2] (d=n(n−3)/2)"; "[1,1] (d=(n−1)(n−2)/2)" |]
  in
  let k2_info n = function
    | [ [] ] -> 0, 1
    | [ [ 1 ] ] -> 1, n - 1
    | [ [ 2 ] ] -> 2, n * (n - 3) / 2
    | [ [ 1; 1 ] ] -> 3, (n - 1) * (n - 2) / 2
    | _ -> 0, 1
  in
  let items_w =
    List.map2_exn O_w.Second_order.kinds bw ~f:(fun kind b ->
      let kind_idx, mult = k2_info Vrnn.state kind in
      let w, _ = eigh float64 (cast float64 b) in
      Array.to_list (to_array (cast float32 w))
      |> List.map ~f:(fun ev -> { ev; mult; kind_idx }))
    |> List.concat
  in

  (* (b) MLP-step RNN full tree (S_8 x S_6, D = 142) *)
  let ptree_r = Ptree.instantiate (module Rnn_mlp) in
  let r_samples =
    List.init 16 ~f:(fun s ->
      let rinput =
        Rng.normal ~key:(Rng.key (400 + s)) float32 [| Rnn_mlp.steps; Rnn_mlp.batch; Rnn_mlp.input_dim |]
      in
      let rtargets = Rnn_mlp.forward (Rnn_mlp.init (Rng.key 1)) ~input:rinput in
      let rloss p = mean (square Infix.(Rnn_mlp.forward p ~input:rinput - rtargets)) in
      snd (Rune.value_and_grad ptree_r rloss (Rnn_mlp.init (Rng.key (500 + s)))))
  in
  let fr =
    avg_factors
      ~factors_of_pair:(fun a b -> O_rnn.Second_order.factors_of_pair ~symmetric:true a b)
      ~pack:O_rnn.Second_order.pack
      ~unpack:O_rnn.Second_order.unpack
      r_samples
  in
  let dr = O_rnn.Second_order.dense_of_factors ~symmetric:true fr in
  let br = O_rnn.Second_order.blocks_of_factors ~symmetric:true fr in
  let rnn_labels =
    [| "(0,0) (d=1)"; "([1],0) (d=7)"; "(0,[1]) (d=5)"; "([1],[1]) (d=35)" |]
  in
  let rnn_info = function
    | [ []; [] ] -> 0, 1
    | [ [ 1 ]; [] ] -> 1, Rnn_mlp.hidden - 1
    | [ []; [ 1 ] ] -> 2, Rnn_mlp.state - 1
    | [ [ 1 ]; [ 1 ] ] -> 3, (Rnn_mlp.hidden - 1) * (Rnn_mlp.state - 1)
    | _ -> 0, 1
  in
  let items_r =
    List.map2_exn O_rnn.Second_order.kinds br ~f:(fun kind b ->
      let kind_idx, mult = rnn_info kind in
      let w, _ = eigh float64 (cast float64 b) in
      Array.to_list (to_array (cast float32 w))
      |> List.map ~f:(fun ev -> { ev; mult; kind_idx }))
    |> List.concat
  in

  (* (c) GRU full tree (10 leaves, S_6, D = 174) *)
  let ptree_g = Ptree.instantiate (module Gru) in
  let g_samples =
    List.init 20 ~f:(fun s ->
      let ginput =
        Rng.normal ~key:(Rng.key (600 + s)) float32 [| Gru.steps; Gru.batch; Gru.d_in |]
      in
      let gtargets = Gru.forward (Gru.init (Rng.key 42)) ~input:ginput in
      let gloss p = mean (square Infix.(Gru.forward p ~input:ginput - gtargets)) in
      snd (Rune.value_and_grad ptree_g gloss (Gru.init (Rng.key (700 + s)))))
  in
  let fg =
    avg_factors
      ~factors_of_pair:(fun a b -> O_gru.Second_order.factors_of_pair ~symmetric:true a b)
      ~pack:O_gru.Second_order.pack
      ~unpack:O_gru.Second_order.unpack
      g_samples
  in
  let dg = O_gru.Second_order.dense_of_factors ~symmetric:true fg in
  let bg = O_gru.Second_order.blocks_of_factors ~symmetric:true fg in
  let gru_labels =
    [| "0 (d=1, 17×17)"; "[1] (d=5, 20×20)"; "[2] (d=9, 3×3)"; "[1,1] (d=10, 3×3)" |]
  in
  let items_g =
    List.map2_exn O_gru.Second_order.kinds bg ~f:(fun kind b ->
      let kind_idx, mult = k2_info Gru.state kind in
      let w, _ = eigh float64 (cast float64 b) in
      Array.to_list (to_array (cast float32 w))
      |> List.map ~f:(fun ev -> { ev; mult; kind_idx }))
    |> List.concat
  in
  Stdio.printf
    "Spectrum multiplicity sum checks: Vanilla RNN W = %d (D=64), MLP-step RNN = %d (D=142), GRU = %d (D=174)\n%!"
    (List.fold items_w ~init:0 ~f:(fun acc x -> acc + x.mult))
    (List.fold items_r ~init:0 ~f:(fun acc x -> acc + x.mult))
    (List.fold items_g ~init:0 ~f:(fun acc x -> acc + x.mult));

  let p_spec_w =
    spectrum_panel
      ~panel_title:"(a) Vanilla RNN W (D=64, 7 block eigenvalues)"
      ~y_name:"yw"
      ~cat_name:"cw"
      ~sz_name:"mult_size"
      ~kind_labels:k2_labels
      ~max_mult:35
      dw
      items_w
  in
  let p_spec_r =
    spectrum_panel
      ~panel_title:"(b) 7-leaf MLP-step RNN tree (D=142, 24 block eigenvalues)"
      ~y_name:"yr"
      ~cat_name:"cr"
      ~sz_name:"mult_size"
      ~kind_labels:rnn_labels
      ~max_mult:35
      dr
      items_r
  in
  let p_spec_g =
    spectrum_panel
      ~panel_title:"(c) 10-leaf GRU tree (D=174, 43 block eigenvalues)"
      ~y_name:"yg"
      ~cat_name:"cg"
      ~sz_name:"mult_size"
      ~kind_labels:gru_labels
      ~max_mult:35
      dg
      items_g
  in
  let fig10 =
    Hugin.grid
      [ [ p_spec_w ]
      ; [ p_spec_r ]
      ; [ p_spec_g ]
      ]
  in
  save_fig ~w:540. ~h:860. "wedderburn_spectra_multiplicity.svg" fig10
