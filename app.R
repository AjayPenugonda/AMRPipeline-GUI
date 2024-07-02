library(shiny)
library(tidyverse)
library(DT)
library(bslib)
library(pheatmap)
df <- readRDS("/Users/ajaypenugonda/Documents/AMR/ajay_df.rds")
df1 <- read.delim("/Users/ajaypenugonda/Documents/AMR/all_results_plasmidfinder.csv")
ui <- page_navbar(
    title = "AMR Tool", # change name of app here
    bg = "#2D89C8",
    inverse = TRUE,

    # add any text you'd like here
    nav_panel(title = "Info", p(
      "The data presented in this app were obtained from",
      tags$a("NCBI", href = "https://www.ncbi.nlm.nih.gov")), "These data represents 20 genomes from ESKAPE pathogens"),
      
    nav_panel(
      title = "AMR genomic context",
      page_sidebar(
        title = "AMR genomic context",
        # Sidebar panel for inputs ----
        sidebar = sidebar(
        selectizeInput(
          inputId = "ARG",
          label = "Filter by AMR gene name",
          choices = c("ALL", unique(df$Gene.symbol)),
          selected = "ALL", 
          multiple = TRUE
        ),
        # Input: Select sites
        selectizeInput(
          inputId = "mlst",
          label = "Filter ST types",
          choices = c("ALL", unique(df$ST)),
          selected = "ALL",
          multiple = TRUE
        ),
      ),
      navset_card_underline(
        title = "Visualizations",
        nav_panel(
          "Tile plot",
          plotOutput("tile_amr")
        ),
        nav_panel(
          "Data table",
          dataTableOutput("datatable_amr")
        )
      )
    )
),

# populate this chunk with next visualization, you will need to change titles, inputIds, choices, plotOutput and dataTableOutput to reflect new plots to be generated
nav_panel(
  title = "Treatment Options",
  page_sidebar(
    title = "Treatment Options",
    # Sidebar panel for inputs ----
    sidebar = sidebar(
      # Input: Select sites
      selectizeInput(
        inputId = "Type",
        label = "Filter by resistance to antibiotic treatment",
        choices = c("ALL", unique(df$Class)), # add unique(df$[var]) like above
        selected = "ALL",
        multiple = TRUE
      ),
    ),
    navset_card_underline(
      title = "Visualizations",
      nav_panel(
        "Tile plot",
        plotOutput("tile_abr")
      ),
      nav_panel(
        "Data Table",
        dataTableOutput("datatable_abr")
      )
    )
  )
),

nav_panel(
  title = "Similarity",
  page_sidebar(
    title = "Similarity between isolates",
    # Sidebar panel for inputs ----
    sidebar = sidebar(
      # Input: Select sites
      selectizeInput(
        inputId = "Similarity",
        label = "Filter by similarity to gene",
        choices = c("ALL", unique(df$filename)), # add unique(df$[var]) like above
        selected = "ALL",
        multiple = TRUE
      ),
    ),
    navset_card_underline(
      title = "Visualizations",
      nav_panel(
        "Tile plot",
        plotOutput("tile_s")
      ),
      nav_panel(
        "Data Table",
        dataTableOutput("datatable_s")
      )
    )
  )
),

nav_panel(
  title = "PlasmidFinder",
  page_sidebar(
    title = "PlasmidFinder Results",
    # Sidebar panel for inputs ----
    sidebar = sidebar(
      selectizeInput(
        inputId = "ARG",
        label = "Filter by AMR gene name",
        choices = c("ALL", unique(df$Gene.symbol)), # add unique(df$[var]) like above
        selected = "ALL", 
        multiple = TRUE
      ),
      # Input: Select sites
      selectizeInput(
        inputId = "Plasmid",
        label = "Filter by Plasmid",
        choices = c("ALL", unique(df1$GENE)), # add unique(df$[var]) like above
        selected = "ALL",
        multiple = TRUE
      ),
    ),
    navset_card_underline(
      title = "Visualizations",
      nav_panel(
        "Tile plot",
        plotOutput("tile_plasmid")
      ),
      nav_panel(
        "Data Table",
        dataTableOutput("datatable_plasmid")
      )
    )
  )
)
)





server <- function(input, output, session) {
  # Function for filtering data based on ui selections - add new filters for the next visualization
  FilterData <- reactive({
    filtered_data <- df 
    if (!"ALL" %in% input$ARG) {
      filtered_data <- filtered_data %>% filter(Gene.symbol %in% input$ARG)
    }
    # site filter
    if (!"ALL" %in% input$mlst) {
      filtered_data <- filtered_data %>% filter(ST %in% input$mlst)
    }
    if (!"ALL" %in% input$Type) {
      filtered_data <- filtered_data %>% filter(Class %in% input$Type)
    }
    if (!"ALL" %in% input$Similarity) {
      filtered_data <- filtered_data %>% filter(filename %in% input$Similarity)
    }
    return(filtered_data)
  })
  
  FilterDataPlasmid <- reactive({
    filtered_data1 <- df1
    if (!"ALL" %in% input$Plasmid) {
      filtered_data1 <- filtered_data1 %>% filter(GENE %in% input$Plasmid)
    }
    return(filtered_data1)
  })
  
  # Outputs - this is where you put the r code for plots using the FilterData() function defined above instead of the dataframe
  output$tile_amr <- renderPlot({
    p <- ggplot(FilterData(), aes(x = filename, y = Gene.symbol, fill = ST)) +
      geom_tile(width = 0.75, height = 0.75) +
      facet_grid(location ~ ST, scales = "free", space = "free") +
      theme(axis.text.x = element_blank())
    print(p)
  })
  
  output$datatable_amr <- renderDataTable({
    FilterData()
  })
  df_amr_subclass_m  <- reactive({
    df_amr_subclass <- FilterData() %>% select(filename, Gene.symbol, Subclass) %>% distinct() %>% mutate(value = 1) %>% group_by(filename, Subclass) %>% summarise(value = sum(value)) %>% pivot_wider(names_from = filename, values_from = value, values_fill = 0) 
    df_amr_subclass <- column_to_rownames(df_amr_subclass, var="Subclass")
    df_amr_subclass_m <- as.matrix(df_amr_subclass)   
    return(df_amr_subclass_m)})
  
  output$tile_abr <- renderPlot({
    mat <- df_amr_subclass_m()
    pheatmap(mat, cluster_rows = F, legend = T, show_colnames = F)
  })
  
  output$datatable_abr <- renderDataTable({
    FilterData()
  })
  #df_sourmash <- read.csv("/Users/ajaypenugonda/Documents/python_wrapper_results/results/sourmash/sourmash.csv")
  #colnames(df_sourmash) <- gsub("X.mnt.workspace.ajay.ncbi_batch_1.ncbi_dataset.data.zips.unzipped.ncbi_dataset.data.all_batch1_fna.","",colnames(df_sourmash))
  
  # Label the rows
  #rownames(df_sourmash) <- colnames(df_sourmash)
  
  # Transform for plotting
 # df_sourmash_m <- as.matrix(df_sourmash)
  
  df_sourmash <- reactive({
    data <- read.csv("/Users/ajaypenugonda/Documents/AMR/sourmash.csv")
    colnames(data) <- gsub("X.mnt.workspace.ajay.ncbi_batch_1.ncbi_dataset.data.zips.unzipped.ncbi_dataset.data.all_batch1_fna.","",colnames(data))
    rownames(data) <- colnames(data)
    data
  })
  
  output$tile_s <- renderPlot({
    pheatmap(as.matrix(df_sourmash()), show_colnames = F)
  })

  output$datatable_s <- renderDataTable({
    FilterData()
  })

  df1 <- df1 %>%
    filter(GENE != "GENE")
  df2 <- df1 %>%
    select(X.FILE, SEQUENCE, GENE, PRODUCT, X.COVERAGE, X.IDENTITY)
  output$tile_plasmid <- renderPlot({
    ggplot(FilterDataPlasmid(), aes(X.FILE, fill=GENE)) + geom_bar(stat = "count") + xlab("Plasmid") + ylab("Plasmidfinder Hits") + theme(axis.text.x = element_text(angle=90, vjust=0.5, size=2))
  })
  
  output$datatable_plasmid <- renderPlot({
    FilterData()
  })
}

# replicate lines 107-118 with a new plot for the second vis

shinyApp(ui = ui, server = server)
