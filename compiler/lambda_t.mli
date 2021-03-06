open Core

type t =
  | Nop
  | Event of event
  | Module of module_
  | Let of binding list * t
  | Seq of t * t (* exp1, exp2 *)
  | Fun of string option * Id.t list * t (* name, params, body *)
  | Fun_body
  | If of t * t * t (* cond, true, false *)
  | Switch of case list
  | Catch of t * (int * t) list (* catch, with *)
  | Exit of int (* num *)
  | Try of t * Id.t * t (* try, exn var, action *)
  | Match of t (* TODO: used? *)
  | No_match
  | For of for_
  | Apply of t * t list (* fun, args *)
  | Get_global of t (* key *)
  | Get_prop of t * t (* load, key *)
  | Get_field of t * int (* load, index *)
  | Get_rec of t option * string * string (* load, record, field *)
  | Get_bitstr of t * Bitstr.spec * t (* value, spec, pos *)
  | Set_global of t * t (* key, value *)
  | Set_field of t * int * t (* load, index, store *)
  | Set_prop of t * t * t (* load, key, store *)
  | Update_rec of update
  | Get_module
  | Not of t
  | And of t * t
  | Or of t * t
  | Eq of t * t
  | Ne of t * t
  | Add of t * t
  | Sub of t * t
  | Mul of t * t
  | Div of t * t
  | Rem of t * t
  | Quo of t * t
  | Block_size of t
  | Block_first of t
  | Block_drop of t * int
  | List_cons of t * t
  | List_concat of t * t
  | List_sub of t * t
  | List_compr of list_compr
  | Local of Id.t
  | Atom of string
  | Undef
  | Bool of bool
  | String of string
  | Int of string
  | Float of string
  | Block of Block_tag.t * t list (* tag, exps *)
  | Make_block of Block_tag.t * t list (* tag, exps *)
  | Temp_block of Block_tag.t * t list (* tag, exps *)
  | Bitstr of (t, t) Bitstr.t
  | Make_bitstr of (t, t) Bitstr.t
  | Temp_bitstr of (t, t) Bitstr.t
  | Ok0
  | Ok of t list
  | Error0
  | Error of t list
  | Test_atom of t
  | Test_binary of t
  | Test_bitstr of t
  | Test_bool of t
  | Test_float of t
  | Test_fun1 of t
  | Test_fun2 of t * t
  | Test_int of t
  | Test_list of t
  | Test_number of t
  | Test_pid of t
  | Test_port of t
  | Test_record2 of t * t
  | Test_record3 of t * t * t
  | Test_ref of t
  | Test_tuple of t
  | Self

and event = {
  ev_loc : Location.t;
  ev_exp : t;
  ev_kind : event_kind;
  ev_repr : int ref option;
}

and event_kind =
  | Ev_before
  | Ev_after of Ast_t.t
  | Ev_fun

and module_ = {
  mod_attrs : attr list;
  mod_code : t;
}

and attr =
  | Modname of string
  | Authors of string list
  | Exports of (string * int) list

and binding = Id.t * t

and case = {
  case_ptn : t;
  case_then : t;
}

and for_ = {
  for_var : string;
  for_list : t;
  for_body : t;
}

and update = {
  up_exp : t option;
  up_name : string;
  up_assocs : (string * t) list;
}

and bitstr = (t, t) Bitstr.t

and list_compr = {
  lcompr_gens : (Id.t * Id.t * t) list; (* list, element, exp *)
  lcompr_filter : t;
  lcompr_body : t;
}

