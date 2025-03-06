(* Main Execution *)
let () =
  Printf.printf "Hello, world!\n";
  let orders = Read_data.read_order_data "data/order.csv" in
  let order_items = Read_data.read_order_item_data "data/order_item.csv" in
  let results = Process_data.transform_to_result_with_filter orders order_items "O" "Complete" in
  Save_data.save_to_csv results "data/results.csv";
  Save_data.save_to_sqlite results "data/results.db";
  (*Sqlite_test.read_from_sqlite "data/results.db";*)
  Printf.printf "Goodbye, world!\n";;
