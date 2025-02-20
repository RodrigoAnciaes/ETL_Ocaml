
type order = {
  id: int;
  client_id: int;
  order_date: string;
  status: string;
  origin: string;
}

type order_item = {
  order_id: int;
  product_id: int;
  quantity: int;
  price: float;
  tax: float;
}

let read_order_data file_name =
  let csv = Csv.load file_name in
  let csv = List.tl csv in (*remove the headers before*)
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

let read_order_item_data file_name =
  let csv = Csv.load file_name in
  let csv = List.tl csv in (*remove the headers before*)
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