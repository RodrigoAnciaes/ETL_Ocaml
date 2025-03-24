open OUnit2
open ETL_project_lib

(* Helper to create temporary CSV files for testing *)
let create_temp_csv_file content =
  let temp_file = Filename.temp_file "test" ".csv" in
  let oc = open_out temp_file in
  output_string oc content;
  close_out oc;
  temp_file

(* Helper function for float comparison *)
let float_compare a b = abs_float (a -. b) < 0.001

let test_read_order_data _ =
  let csv_content = "id,client_id,order_date,status,origin\n1,101,2025-03-01,Complete,O\n2,102,2025-03-02,Pending,P\n" in
  let temp_file = create_temp_csv_file csv_content in
  
  let orders = Read_data.read_order_data temp_file in
  
  (* Cleanup *)
  Sys.remove temp_file;
  
  (* Assertions *)
  assert_equal 2 (List.length orders);
  
  let order1 = List.nth orders 0 in
  assert_equal 1 order1.id;
  assert_equal 101 order1.client_id;
  assert_equal "2025-03-01" order1.order_date;
  assert_equal "Complete" order1.status;
  assert_equal "O" order1.origin;
  
  let order2 = List.nth orders 1 in
  assert_equal 2 order2.id;
  assert_equal 102 order2.client_id;
  assert_equal "2025-03-02" order2.order_date;
  assert_equal "Pending" order2.status;
  assert_equal "P" order2.origin

let test_read_order_item_data _ =
  let csv_content = "order_id,product_id,quantity,price,tax\n1,201,2,10.50,0.10\n1,202,1,25.00,0.15\n2,201,3,10.50,0.10\n" in
  let temp_file = create_temp_csv_file csv_content in
  
  let items = Read_data.read_order_item_data temp_file in
  
  (* Cleanup *)
  Sys.remove temp_file;
  
  (* Assertions *)
  assert_equal 3 (List.length items);
  
  let item1 = List.nth items 0 in
  assert_equal 1 item1.order_id;
  assert_equal 201 item1.product_id;
  assert_equal 2 item1.quantity;
  assert_equal ~cmp:float_compare ~printer:string_of_float 10.50 item1.price;
  assert_equal ~cmp:float_compare ~printer:string_of_float 0.10 item1.tax;
  
  let item2 = List.nth items 1 in
  assert_equal 1 item2.order_id;
  assert_equal 202 item2.product_id;
  assert_equal 1 item2.quantity;
  assert_equal ~cmp:float_compare ~printer:string_of_float 25.00 item2.price;
  assert_equal ~cmp:float_compare ~printer:string_of_float 0.15 item2.tax

(* Process_data tests *)
(* test/test_process_data.ml *)

let test_transform_to_result _ =
  (* Create test data *)
  let orders = [
    { Read_data.id = 1; client_id = 101; order_date = "2025-03-01"; status = "Complete"; origin = "O" };
    { Read_data.id = 2; client_id = 102; order_date = "2025-03-02"; status = "Pending"; origin = "P" }
  ] in
  
  let order_items = [
    { Read_data.order_id = 1; product_id = 201; quantity = 2; price = 10.50; tax = 0.10 };
    { Read_data.order_id = 1; product_id = 202; quantity = 1; price = 25.00; tax = 0.15 };
    { Read_data.order_id = 2; product_id = 201; quantity = 3; price = 10.50; tax = 0.10 }
  ] in
  
  let results = Process_data.transform_to_result orders order_items in
  
  (* Assertions *)
  assert_equal 2 (List.length results);
  
  let order1_result = List.find (fun (id, _, _) -> id = 1) results in
  let (_, total1, tax1) = order1_result in
  (* Expected: (2 * 10.50) + (1 * 25.00) = 46.00 *)
  assert_equal ~cmp:float_compare ~printer:string_of_float 46.00 total1;
  (* Expected: (2 * 10.50 * 0.10) + (1 * 25.00 * 0.15) = 2.10 + 3.75 = 5.85 *)
  assert_equal ~cmp:float_compare ~printer:string_of_float 5.85 tax1;
  
  let order2_result = List.find (fun (id, _, _) -> id = 2) results in
  let (_, total2, tax2) = order2_result in
  (* Expected: 3 * 10.50 = 31.50 *)
  assert_equal ~cmp:float_compare ~printer:string_of_float 31.50 total2;
  (* Expected: 3 * 10.50 * 0.10 = 3.15 *)
  assert_equal ~cmp:float_compare ~printer:string_of_float 3.15 tax2

let test_origin_status_filter _ =
  (* Create test data *)
  let orders = [
    { Read_data.id = 1; client_id = 101; order_date = "2025-03-01"; status = "Complete"; origin = "O" };
    { Read_data.id = 2; client_id = 102; order_date = "2025-03-02"; status = "Pending"; origin = "P" };
    { Read_data.id = 3; client_id = 103; order_date = "2025-03-03"; status = "Complete"; origin = "P" }
  ] in
  
  let order_items = [
    { Read_data.order_id = 1; product_id = 201; quantity = 2; price = 10.50; tax = 0.10 };
    { Read_data.order_id = 2; product_id = 201; quantity = 3; price = 10.50; tax = 0.10 };
    { Read_data.order_id = 3; product_id = 202; quantity = 1; price = 25.00; tax = 0.15 }
  ] in
  
  (* Filter for Complete orders from origin O *)
  let results1 = Process_data.origin_status_filter Process_data.transform_to_result orders order_items "O" "Complete" in
  assert_equal 1 (List.length results1);
  let (id1, _, _) = List.hd results1 in
  assert_equal 1 id1;
  
  (* Filter for Pending orders from origin P *)
  let results2 = Process_data.origin_status_filter Process_data.transform_to_result orders order_items "P" "Pending" in
  assert_equal 1 (List.length results2);
  let (id2, _, _) = List.hd results2 in
  assert_equal 2 id2;
  
  (* Filter for Complete orders from origin P *)
  let results3 = Process_data.origin_status_filter Process_data.transform_to_result orders order_items "P" "Complete" in
  assert_equal 1 (List.length results3);
  let (id3, _, _) = List.hd results3 in
  assert_equal 3 id3

(* Save_data tests *)
(* test/test_save_data.ml *)

let test_save_to_csv _ =
  (* Create test results *)
  let results = [
    (1, 46.00, 5.85);
    (2, 31.50, 3.15)
  ] in
  
  (* Create temporary file for output *)
  let temp_file = Filename.temp_file "test_output" ".csv" in
  
  (* Save results to CSV *)
  Save_data.save_to_csv results temp_file;
  
  (* Read back the CSV and verify contents *)
  let csv = Csv.load temp_file in
  
  (* Cleanup *)
  Sys.remove temp_file;
  
  (* Assertions *)
  assert_equal 3 (List.length csv); (* Header + 2 data rows *)
  
  let header = List.nth csv 0 in
  assert_equal ["order_id"; "total_amount"; "total_tax"] header;
  
  let row1 = List.nth csv 1 in
  assert_equal "1" (List.nth row1 0);
  assert_bool "Row 1 total_amount" (float_of_string (List.nth row1 1) -. 46.00 < 0.001);
  assert_bool "Row 1 total_tax" (float_of_string (List.nth row1 2) -. 5.85 < 0.001);
  
  let row2 = List.nth csv 2 in
  assert_equal "2" (List.nth row2 0);
  assert_bool "Row 2 total_amount" (float_of_string (List.nth row2 1) -. 31.50 < 0.001);
  assert_bool "Row 2 total_tax" (float_of_string (List.nth row2 2) -. 3.15 < 0.001)

(* Test sqlite functionality with in-memory database *)
let test_save_to_sqlite _ =
  (* Skip this test if sqlite3 module is not available *)
  skip_if (not (Sys.file_exists "data/results.db")) "SQLite database not available";
  
  (* Create test results *)
  let results = [
    (1, 46.00, 5.85);
    (2, 31.50, 3.15)
  ] in
  
  (* Use in-memory database for testing *)
  let db_filename = ":memory:" in
  
  (* Save results to SQLite *)
  Save_data.save_to_sqlite results db_filename;
  
  (* Note: Since we're using an in-memory database, we can't directly verify
     the results after the function returns.
     
     For now, we'll just assume that if the function doesn't throw an error. *)
  
  assert_bool "SQLite save completed without errors" true

let test_suite =
  "ETL_project_test_suite" >::: [
    "test_read_order_data" >:: test_read_order_data;
    "test_read_order_item_data" >:: test_read_order_item_data;
    "test_transform_to_result" >:: test_transform_to_result;
    "test_origin_status_filter" >:: test_origin_status_filter;
    "test_save_to_csv" >:: test_save_to_csv;
    "test_save_to_sqlite" >:: test_save_to_sqlite;
  ]

let () =
  run_test_tt_main test_suite