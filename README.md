# ETL_Ocaml

# [Project Report File](ETL_Relatorio.pdf)
# Order Data Processing Tool - User Guide

This tool processes order data to calculate total amounts and taxes for orders, filtered by status and origin. The output is saved as both CSV and SQLite database files.

## Prerequisites

- OCaml environment with Dune
- Required packages:
  - csv
  - sqlite3
- `curl` (ocurl) command-line tool (for GitHub URL functionality)

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
| `--input-order` | Input order CSV file path | "github://RodrigoAnciaes/Data_for_ETL_Ocaml/main/order.csv" |
| `--input-order-item` | Input order item CSV file path | "github://RodrigoAnciaes/Data_for_ETL_Ocaml/main/order_item.csv" |
| `--use-local` | Use local files instead of GitHub | Default is to use GitHub URLs |

### GitHub URL Support

The tool now supports fetching data directly from GitHub repositories using URLs in the format:
```
github://USERNAME/REPOSITORY/BRANCH/PATH/TO/FILE.csv
```

For example:
```
github://RodrigoAnciaes/Data_for_ETL_Ocaml/main/order.csv
```

When a GitHub URL is provided, the tool automatically downloads the file using `curl` before processing.

### Examples

**Process all completed orders with origin "O" using GitHub data:**
```
dune exec ETL_project
```

**Process orders with status "Processing" and origin "W" using GitHub data:**
```
dune exec ETL_project -- --status "Pending" --origin "P"
```

**Use local files instead of GitHub:**
```
dune exec ETL_project -- --use-local
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
4. If using GitHub URLs, ensure you have internet connectivity and `curl` is installed
