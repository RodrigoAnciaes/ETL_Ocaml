(** Types for order processing **)

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
 * Reads order data from a CSV file.
 *
 * @param file_name Path to the CSV file containing order data
 * @return List of order records
 *)
 let read_order_data file_name =
  let csv = Csv.load file_name in
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
 * @param file_name Path to the CSV file containing order item data
 * @return List of order item records
 *)
 let read_order_item_data file_name =
  let csv = Csv.load file_name in
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