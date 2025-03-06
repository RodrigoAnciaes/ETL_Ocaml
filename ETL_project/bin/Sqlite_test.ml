let read_from_sqlite db_filename =
  let db = Sqlite3.db_open db_filename in
  
  (* Define the query *)
  let select_query = "SELECT order_id, total_amount, total_tax FROM orders;" in

  (* Function to process each row *)
  let callback row =
    match row with
    | [Some order_id; Some total_amount; Some total_tax] ->
        Printf.printf "Order ID: %s, Total Amount: %s, Total Tax: %s\n"
          order_id total_amount total_tax
    | _ -> Printf.printf "Unexpected row format\n"
  in

  (* Execute query and process results *)
  ignore (Sqlite3.exec db select_query ~cb:(fun row _ -> callback row));

  (* Close database connection *)
  ignore (Sqlite3.db_close db);;

(* Test the function *)
read_from_sqlite "data/results.db";;
