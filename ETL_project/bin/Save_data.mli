val helper : string list list -> string -> unit
(** [helper results filename] writes the given CSV-formatted data to a file with the specified filename. *)

val add_header_to_csv :
  (string list list -> string -> unit) -> (int * float * float) list -> string -> unit
(** [add_header_to_csv helper results filename] converts result records into a CSV format,
    prepends a header row, and saves the data using the provided helper function. *)

val save_to_csv : (int * float * float) list -> string -> unit
(** [save_to_csv results filename] saves the results to a CSV file, including a header row. *)

val save_to_sqlite : (int * float * float) list -> string -> unit
(** [save_to_sqlite results db_filename] saves the results to a SQLite database file. *)