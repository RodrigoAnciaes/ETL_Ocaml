type result_record = {
  total_amount: float; (* quantity * price *)
  total_tax: float;   (* total_amount * tax *)
}

val transform_to_result : Read_data.order list -> Read_data.order_item list -> (int * float * float) list
(** [transform_to_result orders order_items] computes a list of tuples containing 
    (order_id, total_amount, total_tax) based on the provided order_items. *)

val origin_status_filter :
  (Read_data.order list -> Read_data.order_item list -> 'a) ->
  Read_data.order list -> Read_data.order_item list ->
  string -> string -> 'a
(** [origin_status_filter transformer orders order_items origin status] filters orders 
    based on the given origin and status, then applies the transformer function. *)

val transform_to_result_with_filter :
  Read_data.order list -> Read_data.order_item list -> string -> string -> (int * float * float) list
(** [transform_to_result_with_filter orders order_items origin status] filters orders by 
    origin and status, then computes the transformed results. *)
