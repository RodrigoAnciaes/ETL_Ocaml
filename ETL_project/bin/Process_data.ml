type result_record = {
  total_amount: float; (* quantity * price *)
  total_tax: float;   (* total_amount * tax *)
};;

let transform_to_result orders order_items =
  (* First filter order_items to only include those that belong to orders in the list *)
  let relevant_order_ids = List.map (fun order -> order.Read_data.id) orders in
  let filtered_items = List.filter (fun item -> 
    List.mem item.Read_data.order_id relevant_order_ids
  ) order_items in
  
  (* Compute a list of (order_id, total_amount, total_tax) records from filtered order_items *)
  let item_results = List.map (fun order_item ->
    let order_id = order_item.Read_data.order_id in
    let total_amount = order_item.Read_data.price *. (float_of_int order_item.Read_data.quantity) in
    let total_tax = total_amount *. order_item.Read_data.tax in
    (order_id, { total_amount; total_tax })
  ) filtered_items in
  
  (* Group by order_id and accumulate total amounts and taxes *)
  let grouped_results = List.fold_left (fun acc (order_id, record) ->
    let updated_list =
      match List.assoc_opt order_id acc with
      | Some existing_list -> (record :: existing_list)
      | None -> [record]
    in
    (order_id, updated_list) :: (List.remove_assoc order_id acc)
  ) [] item_results in
  
  (* Merge grouped results to compute final totals *)
  List.map (fun order ->
    let order_id = order.Read_data.id in
    let result_records = match List.assoc_opt order_id grouped_results with
      | Some records -> records
      | None -> [] in
    let total_amount = List.fold_left (fun acc record -> acc +. record.total_amount) 0.0 result_records in
    let total_tax = List.fold_left (fun acc record -> acc +. record.total_tax) 0.0 result_records in
    (order_id, total_amount, total_tax)
  ) orders


let origin_status_filter transformer orders order_items origin status =
  let filtered_orders = List.filter (fun order ->
    order.Read_data.origin = origin && order.Read_data.status = status
  ) orders in
  transformer filtered_orders order_items;;

let transform_to_result_with_filter = origin_status_filter transform_to_result;;