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

val read_order_data : string -> order list

val read_order_item_data : string -> order_item list