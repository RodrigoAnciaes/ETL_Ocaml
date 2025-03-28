(*save the results records to a file using the csv library*)

 (** 
  * Helper function for writing to CSV.
  *
  * @param results List of data rows to write
  * @param filename Path to the output CSV file
  *)
let helper results filename =
   let oc = open_out filename in
   let csv_out = Csv.to_channel oc in  (* Convert to Csv.out_channel *)
   Csv.output_all csv_out results;     (* Now it matches the expected type *)
   close_out oc;;

(** 
 * Adds a header row to CSV data and saves it to a file.
 *
 * @param helper Helper function to perform the actual CSV writing
 * @param results List of result tuples to convert and write
 * @param filename Path to the output CSV file
 *)
let add_header_to_csv helper results filename =
  let results = List.map (fun (order_id, total_amount, total_tax) ->
    [string_of_int order_id; string_of_float total_amount; string_of_float total_tax]
  ) results in
  let header = ["order_id"; "total_amount"; "total_tax"] in
  helper (header :: results) filename;;

(** 
 * Saves results to a CSV file with appropriate headers.
 *
 * @param results List of result tuples (order_id, total_amount, total_tax)
 * @param filename Path to the output CSV file
 *)
let save_to_csv = add_header_to_csv helper


(** 
 * Saves results to a SQLite database.
 * Creates a table if it doesn't exist and inserts the data.
 *
 * @param results List of result tuples (order_id, total_amount, total_tax)
 * @param db_filename Path to the SQLite database file
 *)
 let save_to_sqlite results db_filename =
  let db = Sqlite3.db_open db_filename in
  (* Create table if it doesn't exist *)
  let create_table_query =
    "CREATE TABLE IF NOT EXISTS orders (
       order_id INTEGER PRIMARY KEY,
       total_amount REAL,
       total_tax REAL
     );" in
  ignore (Sqlite3.exec db create_table_query);
  (* Prepare the insert statement *)
  let insert_query =
    "INSERT INTO orders (order_id, total_amount, total_tax) VALUES (?, ?, ?);" in
  let stmt = Sqlite3.prepare db insert_query in
  (* Insert each row into the database *)
  List.iter (fun (order_id, total_amount, total_tax) ->
    ignore (Sqlite3.reset stmt);
    ignore (Sqlite3.bind stmt 1 (Sqlite3.Data.INT (Int64.of_int order_id)));
    ignore (Sqlite3.bind stmt 2 (Sqlite3.Data.FLOAT total_amount));
    ignore (Sqlite3.bind stmt 3 (Sqlite3.Data.FLOAT total_tax));
    ignore (Sqlite3.step stmt);
  ) results;
  (* Finalize statement and close the database *)
  ignore (Sqlite3.finalize stmt);
  ignore (Sqlite3.db_close db)
