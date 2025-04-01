open ETL_project_lib

(* Main Execution *)
let () =
  (* Parse command line arguments *)
  let status = ref "Complete" in
  let origin = ref "O" in
  let output_csv = ref "data/results.csv" in
  let output_db = ref "data/results.db" in
  let input_order = ref "github://RodrigoAnciaes/Data_for_ETL_Ocaml/main/order.csv" in
  let input_order_item = ref "github://RodrigoAnciaes/Data_for_ETL_Ocaml/main/order_item.csv" in
  let use_github = ref true in
 
  (* Define command line arguments *)
  let speclist = [
    ("--status", Arg.Set_string status, "Filter by order status (default: Complete)");
    ("--origin", Arg.Set_string origin, "Filter by order origin (default: O)");
    ("--output-csv", Arg.Set_string output_csv, "Output CSV file path (default: data/results.csv)");
    ("--output-db", Arg.Set_string output_db, "Output SQLite DB file path (default: data/results.db)");
    ("--input-order", Arg.Set_string input_order, "Input order CSV file path (default: github://RodrigoAnciaes/Data_for_ETL_Ocaml/main/order.csv)");
    ("--input-order-item", Arg.Set_string input_order_item, "Input order item CSV file path (default: github://RodrigoAnciaes/Data_for_ETL_Ocaml/main/order_item.csv)");
    ("--use-local", Arg.Clear use_github, "Use local files instead of GitHub (changes defaults to data/order.csv and data/order_item.csv)");
  ] in
 
  (* Parse the command line *)
  let usage_msg = "Usage: " ^ Sys.argv.(0) ^ " [OPTIONS]... \nCalculate order totals and taxes filtered by status and origin." in
  Arg.parse speclist (fun _ -> ()) usage_msg;
  
  (* Reset to local defaults if --use-local is specified *)
  if not !use_github then begin
    if !input_order = "github://RodrigoAnciaes/Data_for_ETL_Ocaml/main/order.csv" then
      input_order := "data/order.csv";
    if !input_order_item = "github://RodrigoAnciaes/Data_for_ETL_Ocaml/main/order_item.csv" then
      input_order_item := "data/order_item.csv";
  end;
 
  (* Process data *)
  Printf.printf "Processing with filters: status=%s, origin=%s\n" !status !origin;
 
  (* Read input data *)
  Printf.printf "Reading data from %s and %s\n" !input_order !input_order_item;
  let orders = Read_data.read_order_data !input_order in
  let order_items = Read_data.read_order_item_data !input_order_item in
 
  (* Transform data with filters *)
  let results = Process_data.transform_to_result_with_filter orders order_items !origin !status in
  let order_count = List.length results in
  Printf.printf "Found %d orders matching criteria\n" order_count;
 
  (* Save results *)
  Printf.printf "Saving results to %s and %s\n" !output_csv !output_db;
  Save_data.save_to_csv results !output_csv;
  Save_data.save_to_sqlite results !output_db;
 
  Printf.printf "Processing completed successfully!\n"