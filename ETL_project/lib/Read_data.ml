(** 
 * Fetches a CSV file from a GitHub repository using HTTP GET.
 *
 * @param repo_owner GitHub username or organization
 * @param repo_name Name of the repository
 * @param branch Branch name (e.g., "main" or "master")
 * @param file_path Path to the CSV file within the repository
 * @return CSV content as a string
 *)
 let fetch_csv_from_github repo_owner repo_name branch file_path =
  let url = Printf.sprintf "https://raw.githubusercontent.com/%s/%s/%s/%s" 
              repo_owner repo_name branch file_path in
  try
    let channel = Curl.init () in
    Curl.set_url channel url;
    Curl.set_writefunction channel (fun data -> Buffer.add_string (Curl.get_userdata channel) data; String.length data);
    let buffer = Buffer.create 16384 in
    Curl.set_userdata channel buffer;
    Curl.perform channel;
    let status_code = Curl.get_httpcode channel in
    Curl.cleanup channel;
    if status_code = 200 then
      Buffer.contents buffer
    else
      failwith (Printf.sprintf "Failed to fetch CSV: HTTP status %d" status_code)
  with
  | Curl.CurlException (_, _, error) -> 
      failwith (Printf.sprintf "Curl error: %s" error)
  | Failure msg -> 
      failwith (Printf.sprintf "Error: %s" msg)

(** 
 * Reads order data from a CSV file hosted on GitHub.
 *
 * @param repo_owner GitHub username or organization
 * @param repo_name Name of the repository
 * @param branch Branch name (e.g., "main" or "master")
 * @param file_path Path to the CSV file within the repository
 * @return List of order records
 *)
let read_order_data_from_github repo_owner repo_name branch file_path =
  let csv_content = fetch_csv_from_github repo_owner repo_name branch file_path in
  let csv = Csv.of_string csv_content in
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
 * Reads order item data from a CSV file hosted on GitHub.
 *
 * @param repo_owner GitHub username or organization
 * @param repo_name Name of the repository
 * @param branch Branch name (e.g., "main" or "master")
 * @param file_path Path to the CSV file within the repository
 * @return List of order item records
 *)
let read_order_item_data_from_github repo_owner repo_name branch file_path =
  let csv_content = fetch_csv_from_github repo_owner repo_name branch file_path in
  let csv = Csv.of_string csv_content in
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

(** 
 * Enhanced version of read_order_data that can handle both local files and GitHub URLs.
 * If the path starts with "github://", it parses it as a GitHub URL.
 * Format: github://owner/repo/branch/path/to/file.csv
 *
 * @param source Path to local file or GitHub URL
 * @return List of order records
 *)
let read_order_data source =
  if String.length source > 9 && String.sub source 0 9 = "github://" then
    let github_path = String.sub source 9 (String.length source - 9) in
    let parts = String.split_on_char '/' github_path in
    if List.length parts < 4 then
      failwith "Invalid GitHub URL format. Use: github://owner/repo/branch/path/to/file.csv"
    else
      let owner = List.nth parts 0 in
      let repo = List.nth parts 1 in
      let branch = List.nth parts 2 in
      let file_path = String.concat "/" (List.filteri (fun i _ -> i > 2) parts) in
      read_order_data_from_github owner repo branch file_path
  else
    (* Original function for local files *)
    let csv = Csv.load source in
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
 * Enhanced version of read_order_item_data that can handle both local files and GitHub URLs.
 * If the path starts with "github://", it parses it as a GitHub URL.
 * Format: github://owner/repo/branch/path/to/file.csv
 *
 * @param source Path to local file or GitHub URL
 * @return List of order item records
 *)
let read_order_item_data source =
  if String.length source > 9 && String.sub source 0 9 = "github://" then
    let github_path = String.sub source 9 (String.length source - 9) in
    let parts = String.split_on_char '/' github_path in
    if List.length parts < 4 then
      failwith "Invalid GitHub URL format. Use: github://owner/repo/branch/path/to/file.csv"
    else
      let owner = List.nth parts 0 in
      let repo = List.nth parts 1 in
      let branch = List.nth parts 2 in
      let file_path = String.concat "/" (List.filteri (fun i _ -> i > 2) parts) in
      read_order_item_data_from_github owner repo branch file_path
  else
    (* Original function for local files *)
    let csv = Csv.load source in
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