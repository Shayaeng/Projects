library(shiny)
library(DBI)
library(odbc)
library(glue)
library(stringr)

source("config.R")

con <- dbConnect(
  odbc::odbc(),
  driver = DB_DRIVER,
  server = DB_SERVER,
  database = DB_DATABASE,
  trusted_connection = DB_TRUSTED_CONNECTION
)

ui <- fluidPage(
  titlePanel("Data Input Form"),
  selectInput("operation", "Select Operation:", c("Update Existing", "Create New")),
  textInput("order_number", "Order Number:"),
  conditionalPanel(
    condition = "input.operation == 'Update Existing'",
    textInput("tracking_number", "Tracking Number:")
  ),
  uiOutput("additional_fields"),
  actionButton("submit", "Submit"),
  textOutput("success")
)

server <- function(input, output) {
  observe({
    output$additional_fields <- renderUI({
      if (input$operation == "Create New") {
        tagList(
          textInput("item_value", "Item:"),
          textInput("buying_group_value", "Buying Group ID:"),
          textInput("retailer_value", "Retailer Code:"),
          textInput("tracking_number_value", "Tracking Number:"),
          textInput("group_price_value", "Group Price:"),
          textInput("retailer_price_value", "Retailer Price:"),
          textInput("payment_method_value", "Payment Method:"),
          textInput("status_value", "Status ID:"),
          textInput("issue_value", "Issue Bit:"),
          textInput("date_value", "Date Bought:")
        )
      } else if (input$operation == "Update Existing") {
        tagList(
          selectInput("field_selection", "Select field to update:", choices = c("item", "buying_group", "retailer", "tracking_number", "group_price", "retailer_price", "payment_method", "status", "issue", "date")),
          textInput("new_value", "New value:")
        )
      }
     })
  })

  observeEvent(input$submit, {
    order_number <- input$order_number
    tracking_number <- input$tracking_number

    if ((!is.null(order_number) && order_number != "") || (!is.null(tracking_number) && tracking_number != "")) {
      if (input$operation == "Update Existing") {
        field <- input$field_selection
        if (!is.null(field)) {
          value <- input$new_value
          value <- ifelse(value == "NULL", "NULL", sprintf("'%s'", value))
          order_number <- ifelse(order_number == "NULL", "NULL", sprintf("'%s'", order_number))
          tracking_number <- ifelse(tracking_number == "NULL", "NULL", sprintf("'%s'", tracking_number))

          query <- glue::glue("UPDATE orders SET {field} = ? WHERE order_number = ? OR tracking_number = ?")
          print(query)
          print(value)
          print(order_number)
          print(tracking_number)
          params <- list(value, order_number, tracking_number)
          dbExecute(con, query, params)
          output$success <- renderText(paste("Data for order number ", order_number, " updated successfully."))
        }
      } else if (input$operation == "Create New") {
        #order_number <- sprintf("'%s'", order_number)
        fields <- c("item", "buying_group", "retailer", "tracking_number", "group_price", "retailer_price", "payment_method", "status", "issue", "date")
        values <- lapply(fields, function(field) {
          value <- input[[paste0(field, "_value")]]
          ifelse(value == "NULL", "NULL", value)
        })
        query <- glue::glue("INSERT INTO orders (order_number, {paste(fields, collapse = ', ')}) VALUES (NULLIF(?, 'NULL'), {str_c(rep(\"NULLIF(?, 'NULL')\", length(fields)), collapse = ', ')})")
        params <- c(order_number, unlist(values))
        dbExecute(con, query, params)
        output$success <- renderText(paste("New record for order number ", order_number, " created successfully."))
      }
    } else {
      output$success <- renderText("Please enter all required fields.")
    }
  })
}

shinyApp(ui, server)