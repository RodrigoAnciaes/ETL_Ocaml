(** Represents an order in the system *)
type order = {
  id: int;               (** Unique identifier for the order *)
  client_id: int;        (** Identifier of the client who placed the order *)
  order_date: string;    (** Date when the order was placed *)
  status: string;        (** Current status of the order (e.g., "Complete", "Processing") *)
  origin: string;        (** Origin of the order (e.g., "O", "W") *)
}

(** Represents an item within an order *)
type order_item = {
  order_id: int;         (** Identifier of the order this item belongs to *)
  product_id: int;       (** Identifier of the product *)
  quantity: int;         (** Quantity of the product ordered *)
  price: float;          (** Unit price of the product *)
  tax: float;            (** Tax rate applied to this item (as a decimal) *)
}

(** 
 * Fetch content from a URL using curl or read from a local file
 * 
 * This function handles both local file paths and GitHub URLs in the format
 * "github://USERNAME/REPOSITORY/BRANCH/PATH/TO/FILE". For GitHub URLs, 
 * it uses curl to download the file to a temporary location.
 *
 * @param file_path The path or URL to the file
 * @return The path to the actual file (either original path or downloaded temp file)
 * @raise Failure if the download fails
 *)
let get_file_content file_path =
  if String.starts_with ~prefix:"github://" file_path then
    (* Convert GitHub URL format to raw content URL *)
    let url_parts = String.split_on_char '/' (String.sub file_path 9 (String.length file_path - 9)) in
    let username = List.nth url_parts 0 in
    let repo = List.nth url_parts 1 in
    let branch = List.nth url_parts 2 in
    let file = String.concat "/" (List.tl (List.tl (List.tl url_parts))) in
    let raw_url = Printf.sprintf "https://raw.githubusercontent.com/%s/%s/%s/%s" username repo branch file in
    
    (* Create a temporary file to store the downloaded content *)
    let temp_file = Filename.temp_file "ocaml_etl_" ".csv" in
    
    (* Download the file using curl *)
    let curl_cmd = Printf.sprintf "curl -s -L '%s' -o %s" raw_url temp_file in
    let status = Sys.command curl_cmd in
    
    if status <> 0 then
      failwith (Printf.sprintf "Failed to download file from %s (curl exit code: %d)" raw_url status);
    
    (* Return the path to the downloaded file *)
    temp_file
  else
    (* Local file, return as is *)
    file_path

(**
 * Reads order data from a CSV file.
 *
 * This function reads order records from a CSV file, which can be either
 * a local file or a GitHub URL. The CSV file should have headers and the
 * following columns (in order): id, client_id, order_date, status, origin.
 *
 * @param file_name Path to the CSV file containing order data
 * @return List of order records
 * @raise Failure if the file doesn't exist or has an invalid format
 *)
let read_order_data file_name =
  let actual_file = get_file_content file_name in
  let csv = Csv.load actual_file in
  (* If we downloaded to a temporary file, clean it up *)
  if actual_file <> file_name then Sys.remove actual_file;
  
  let csv = List.tl csv in (* remove the headers *)
  let orders = List.map (fun row ->
    let row = Array.of_list row in  (* Convert list to array *)
    {
      id = int_of_string row.(0);
      client_id = int_of_string row.(1);
      order_date = row.(2);
      status = row.(3);
      origin = row.(4);
    }
  ) csv in
  orders

(**
 * Reads order item data from a CSV file.
 *
 * This function reads order item records from a CSV file, which can be either
 * a local file or a GitHub URL. The CSV file should have headers and the
 * following columns (in order): order_id, product_id, quantity, price, tax.
 *
 * @param file_name Path to the CSV file containing order item data
 * @return List of order item records
 * @raise Failure if the file doesn't exist or has an invalid format
 *)
let read_order_item_data file_name =
  let actual_file = get_file_content file_name in
  let csv = Csv.load actual_file in
  (* If we downloaded to a temporary file, clean it up *)
  if actual_file <> file_name then Sys.remove actual_file;
  
  let csv = List.tl csv in (* remove the headers *)
  let order_items = List.map (fun row ->
    let row = Array.of_list row in  (* Convert list to array *)
    {
      order_id = int_of_string row.(0);
      product_id = int_of_string row.(1);
      quantity = int_of_string row.(2);
      price = float_of_string row.(3);
      tax = float_of_string row.(4);
    }
  ) csv in
  order_items