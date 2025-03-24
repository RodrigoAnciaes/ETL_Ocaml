# ETL_Ocaml

# Order Data Processing Tool - User Guide

This tool processes order data to calculate total amounts and taxes for orders, filtered by status and origin. The output is saved as both CSV and SQLite database files.

## Prerequisites

- OCaml environment with Dune
- Required packages:
  - csv
  - sqlite3

## Installation

1. Ensure the project is built with Dune:
   ```
   dune build
   ```

2. The executable will be available in the `_build/default` directory.

## Build code documentation

1. Run the following command to generate the documentation:
   ```
   dune build @doc
   ```

2. Open the generated HTML file in your browser:
   ``` 
    open _build/default/_doc/_html/index.html
    ```

## Running the Tool

### Basic Usage

```
dune exec ETL_project -- [OPTIONS]
```

### Command Line Options

| Option | Description | Default Value |
|--------|-------------|---------------|
| `--status` | Filter by order status | "Complete" |
| `--origin` | Filter by order origin | "O" |
| `--output-csv` | Output CSV file path | "data/results.csv" |
| `--output-db` | Output SQLite DB file path | "data/results.db" |
| `--input-order` | Input order CSV file path | "data/order.csv" |
| `--input-order-item` | Input order item CSV file path | "data/order_item.csv" |

### Examples

**Process all completed orders with origin "O":**
```
dune exec ETL_project
```

**Process orders with status "Processing" and origin "W":**
```
dune exec ETL_project -- --status "Pending" --origin "P"
```

**Specify custom input and output files:**
```
dune exec ETL_project -- --input-order "custom_order.csv" --input-order-item "custom_items.csv" --output-csv "results_2025.csv"
```

## Output Format

### CSV Output
The CSV output file contains the following columns:
- `order_id`: Unique identifier for the order
- `total_amount`: Sum of all item revenues (price × quantity) in the order
- `total_tax`: Sum of all taxes paid for items in the order

### SQLite Output
The SQLite database contains a table named `orders` with the same fields as the CSV file.

## Troubleshooting

If you encounter any issues:
1. Ensure all input files exist and are in the correct format
2. Check that you have write permissions for the output locations
3. Verify that all required OCaml packages are installed
 
