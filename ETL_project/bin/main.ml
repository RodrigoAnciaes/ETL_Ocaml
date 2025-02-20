

type result_record = {
  total_amount: float; (* quantity * price *)
  total_tax: float;   (* total_amount * tax *)
};;

let transform_to_result orders order_items =
  let order_item_map = Hashtbl.create 100 in
  List.iter (fun order_item ->
    let order_id = order_item.Read_data.order_id in
    let total_amount = order_item.Read_data.price *. (float_of_int order_item.Read_data.quantity) in
    let total_tax = total_amount *. order_item.Read_data.tax in
    let result_record = { total_amount; total_tax } in
    let result_records =
      try Hashtbl.find order_item_map order_id
      with Not_found -> [] in
    Hashtbl.replace order_item_map order_id (result_record :: result_records)
  ) order_items;

  List.map (fun order ->
    let order_id = order.Read_data.id in
    let result_records =
      try Hashtbl.find order_item_map order_id
      with Not_found -> [] in
    let total_amount = List.fold_left (fun acc record -> acc +. record.total_amount) 0.0 result_records in
    let total_tax = List.fold_left (fun acc record -> acc +. record.total_tax) 0.0 result_records in
    (order_id, total_amount, total_tax)
  ) orders;;

  






let () =
  Printf.printf "Hello, world!\n";;
  let orders = Read_data.read_order_data "data/order.csv" in
  let order_items = Read_data.read_order_item_data "data/order_item.csv" in
  let results = transform_to_result orders order_items in
  List.iter (fun (order_id, total_amount, total_tax) ->
    Printf.printf "order_id: %d, total_amount: %f, total_tax: %f\n" order_id total_amount total_tax
  ) results;;
  Printf.printf "Goodbye, world!\n";;





