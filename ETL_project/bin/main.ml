

(*import and use read_order_data from read_data.ml*)

let () =
  let orders = Read_data.read_order_data "data/order.csv" in
  List.iter (fun order ->
    Printf.printf "Order id: %d\n" order.Read_data.id
  ) orders;;

(*import and use read_order_item_data from read_data.ml*)





