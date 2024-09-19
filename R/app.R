library(shiny)
library(shinythemes)
library(limma)
library(edgeR)
library(pheatmap)
library(ggplot2)
library(ggrepel)
library(reshape2)
library(data.table)
library(dplyr)
library(tidyr)
library(DBI)
library(RMariaDB)

options(shiny.maxRequestSize = 500 * 1024^2)

ui <- fluidPage(
    theme = shinytheme("cerulean"),
    tags$head(
        tags$style(HTML("
            body {
                background-color: white; 
            }
            /* Painel seletor CSV/SQL usa a classe .well por padrão */
            .well {
                background-color: #e4b94b;
                border: 1px solid bdc3ggc7;
                padding: 15px;
                border-radius: 10px;
            }
        "))
    ),
    titlePanel(div("Análise de RNA-seq com limma", style = "color: #2c3e50; font-weight: bold; font-size: 28px; text-align: center;")),
    sidebarLayout(
        sidebarPanel(
            h4("Carregar CSV", style = "color: #00796b; font-weight: bold;"),
            fileInput("file1", "Escolha arquivo .CSV para análise Control/Treatment",
                    accept = c(
                          "text/csv",
                          "text/comma-separated-values,text/plain",
                          ".csv"),
                    buttonLabel = "Procurar",
                    placeholder = "Nenhum arquivo selecionado"
            ),
            checkboxInput("header1", "Cabeçalho?", TRUE),
            radioButtons("sep1", "Separator",
                         choices = c(Vírgula = ",",
                                     `Ponto e vírgula` = ";",
                                     Tab = "\t"),
                         selected = ","),
            tags$hr(),
            h4("Carregar SQL de RNAseq", style = "color: #00796b; font-weight: bold;"),
            actionButton("load_rna", "Carregar Dados de RNA-seq",
                                     style = "color: #00796b; background-color: #3498db; border-color: #2980b9; padding: 10px 20px;"),
        ),
        mainPanel(
            tabsetPanel(
                tabPanel("CSV Data",
                         fluidRow(
                             column(6, plotOutput("plot", height = "300px")),
                             column(6, plotOutput("heatmap", height = "300px"))
                         ),
                         fluidRow(
                             column(12, plotOutput("pca", height = "300px"))
                         )
                ),
                tabPanel("SQL Data",
                         fluidRow(
                             column(6, plotOutput("rnaPlot", height = "300px")),
                             column(6, plotOutput("rnaHeatmap", height = "300px"))
                         ),
                         fluidRow(
                             column(12, plotOutput("rnaPCA", height = "300px"))
                         )
                )
            )
    ))
)

# Server
server <- function(input, output) {

    db_connect <- function() {
        con <- dbConnect(
            MariaDB(),
            user = "XXXXX",
            password = "XXXXX",
            dbname = "XXXXX",
            host = "XXXXX",
            port = XXXXX
        )
        return(con)
    }

    rna_data <- reactiveVal(NULL)
    
    observeEvent(input$load_rna, {
        con <- db_connect()
        rna_query <- "SELECT * FROM sample"
        rna_data(dbGetQuery(con, rna_query))
        dbDisconnect(con)
    })

    output$contents <- renderTable({
        req(input$file1)
        df <- read.csv(input$file1$datapath, header = input$header1, sep = input$sep1)
        df
    })

    # Plot
    output$plot <- renderPlot({
        req(input$file1)
        df <- read.csv(input$file1$datapath, header = input$header1, sep = input$sep1)
        
        num_samples <- ncol(df)
        half_samples <- num_samples / 2
        group <- factor(rep(c("Control", "Treatment"), each = half_samples))
        
        dge <- DGEList(counts = df, group = group)
        
        keep <- filterByExpr(dge)
        dge <- dge[keep, , keep.lib.sizes = FALSE]
        dge <- calcNormFactors(dge)
        
        design <- model.matrix(~ group)
        
        v <- voom(dge, design)
        
        fit <- lmFit(v, design)
        fit <- eBayes(fit)
        
        topTable <- topTable(fit, adjust.method = "BH", number = Inf, sort.by = "none")
        topTable$Gene <- df$Gene[keep]
        
        # Resultado
        ggplot(topTable, aes(x = AveExpr, y = logFC, label = Gene)) +
            geom_point() +
            #geom_text_repel() + (desnecessário, adiciona label para cada ponto)
            theme_minimal() +
            labs(x = "Average Expression (log2)", y = "Log Fold Change / Control-Treatment Expression Change", title = "Mean-Difference Plot") +
            theme(plot.title = element_text(hjust = 0.5))
    })

    # Heatmap
    output$heatmap <- renderPlot({
        req(input$file1)
        df <- read.csv(input$file1$datapath, header = input$header1, sep = input$sep1)

        num_samples <- ncol(df)
        half_samples <- num_samples / 2
        group <- factor(rep(c("Control", "Treatment"), each = half_samples))
        dge <- DGEList(counts = df, group = group)

        keep <- filterByExpr(dge)
        dge <- dge[keep, , keep.lib.sizes = FALSE]
        dge <- calcNormFactors(dge)

        design <- model.matrix(~ group)
        
        v <- voom(dge, design)
        
        fit <- lmFit(v, design)
        fit <- eBayes(fit)
        topGenes <- rownames(topTable(fit, adjust.method = "BH", number = 50))

        # Resultado
        pheatmap(v$E[topGenes, ])
    })

    # PCA
    output$pca <- renderPlot({
        req(input$file1)
        df <- read.csv(input$file1$datapath, header = input$header1, sep = input$sep1)

        num_samples <- ncol(df)
        half_samples <- num_samples / 2
        group <- factor(rep(c("Control", "Treatment"), each = half_samples))
        dge <- DGEList(counts = df, group = group)

        keep <- filterByExpr(dge)
        dge <- dge[keep, , keep.lib.sizes = FALSE]
        dge <- calcNormFactors(dge)

        design <- model.matrix(~ group)
        
        v <- voom(dge, design)
        
        fit <- lmFit(v, design)
        fit <- eBayes(fit)

        # Resultado
        pca <- prcomp(t(v$E))
        pcaData <- data.frame(Sample = colnames(df[, -1]), 
                            PC1 = pca$x[,1], 
                            PC2 = pca$x[,2], 
                            Group = group)
        
        ggplot(pcaData, aes(x = PC1, y = PC2, color = Group)) +
            geom_point(size = 4) +
            #geom_text_repel(size = 3) + (desnecessário, adiciona texto para cada ponto)
            theme_minimal() +
            labs(title = "PCA Plot", x = "PC1", y = "PC2")
    })

        output$newContents <- renderTable({
        req(input$file2)
        df <- read.csv(input$file2$datapath, header = input$header2, sep = input$sep2)
        df
    })

output$rnaPlot <- renderPlot({
        req(rna_data())
        df <- rna_data()

    analysis_type <- "type-speed"  # Mude conforme necessário (falta desenvolver uma automação para isso de forma inputável)

    # Diferentes tipos de analysis_type
    if (analysis_type == "sample-type") {
        df$Condition <- paste(df$sample, df$type, sep = "_")
        group_var <- "type"
    } else if (analysis_type == "sample-speed") {
        df$Condition <- paste(df$sample, df$speed, sep = "_")
        group_var <- "speed"
    } else if (analysis_type == "speed-type") {
        df$Condition <- paste(df$type, df$speed, sep = "_")
        group_var <- "type" 
    } else if (analysis_type == "type-speed") {
        df$Condition <- paste(df$type, df$speed, sep = "_")
        group_var <- "speed"
    }

    df_grouped <- df %>%
        group_by(gene_id, Condition) %>%
        summarise(rpkm = mean(rpkm), .groups = "drop")

    df_wide <- df_grouped %>%
        pivot_wider(names_from = Condition, values_from = rpkm, values_fill = 0)

    gene_ids <- df_wide$gene_id
    df_wide <- df_wide %>% select(-gene_id)
    rownames(df_wide) <- gene_ids

    dge <- DGEList(counts = df_wide)
    conditions <- colnames(df_wide)
    group <- factor(df[[group_var]][match(conditions, df$Condition)])
    group <- factor(make.names(as.character(group)))

    design <- model.matrix(~ 0 + group)
    print(levels(group))
    print(colnames(design))

    keep <- filterByExpr(dge, group=group)
    dge <- dge[keep, , keep.lib.sizes = FALSE]
    dge <- calcNormFactors(dge)

    v <- voom(dge, design)
    fit <- lmFit(v, design)

    # Seletor de matriz de constraste (com base em grupos de velocidade X tipo)
    if (analysis_type == "sample-type" || analysis_type == "speed-type") {
        contrast.matrix <- makeContrasts(groupX.blastocyst. - groupX.embryo., levels=design)
    } else if (analysis_type == "sample-Sspeed" || analysis_type == "type-speed") {
        #contrast.matrix <- makeContrasts(groupfast - groupslow, levels=design)
        #contrast.matrix <- makeContrasts(groupfast - groupin.vivo, levels=design)
        contrast.matrix <- makeContrasts(groupslow - groupin.vivo, levels=design)
    }

    fit <- contrasts.fit(fit, contrast.matrix)
    fit <- eBayes(fit)

    topTable <- topTable(fit, adjust.method = "BH", number = Inf, sort.by = "none")
    topTable$Gene <- rownames(topTable)

    ggplot(topTable, aes(x = AveExpr, y = logFC, label = Gene)) +
        geom_point() +
        theme_minimal() +
        labs(x = "Average Expression (log2)", y = "Log Fold Change", title = "Mean-Difference Plot") +
        theme(plot.title = element_text(hjust = 0.5))
    })

output$rnaHeatmap <- renderPlot({
        req(rna_data())
        df <- rna_data()

    analysis_type <- "type-speed"

    if (analysis_type == "sample-type") {
        df$Condition <- paste(df$sample, df$type, sep = "_")
        group_var <- "type"
    } else if (analysis_type == "sample-speed") {
        df$Condition <- paste(df$sample, df$speed, sep = "_")
        group_var <- "speed"
    } else if (analysis_type == "speed-type") {
        df$Condition <- paste(df$type, df$speed, sep = "_")
        group_var <- "type" 
    } else if (analysis_type == "type-speed") {
        df$Condition <- paste(df$type, df$speed, sep = "_")
        group_var <- "speed"
    }

    df_grouped <- df %>%
        group_by(gene_id, Condition) %>%
        summarise(rpkm = mean(rpkm), .groups = "drop")

    df_wide <- df_grouped %>%
        pivot_wider(names_from = Condition, values_from = rpkm, values_fill = 0)

    gene_ids <- df_wide$gene_id
    df_wide <- df_wide %>% select(-gene_id)
    rownames(df_wide) <- gene_ids

    dge <- DGEList(counts = df_wide)
    conditions <- colnames(df_wide)
    group <- factor(df[[group_var]][match(conditions, df$Condition)])
    group <- factor(make.names(as.character(group)))

    design <- model.matrix(~ 0 + group)

    keep <- filterByExpr(dge, group=group)
    dge <- dge[keep, , keep.lib.sizes = FALSE]
    dge <- calcNormFactors(dge)

    v <- voom(dge, design)
    fit <- lmFit(v, design)
    fit <- eBayes(fit)

    topGenes <- rownames(topTable(fit, adjust.method = "BH", number = 50))

    pheatmap(v$E[topGenes, ])
})

output$rnaPCA <- renderPlot({
        req(rna_data())
        df <- rna_data()

    analysis_type <- "type-speed"

    if (analysis_type == "sample-type") {
        df$Condition <- paste(df$sample, df$type, sep = "_")
        group_var <- "type"
    } else if (analysis_type == "sample-speed") {
        df$Condition <- paste(df$sample, df$speed, sep = "_")
        group_var <- "speed"
    } else if (analysis_type == "speed-type") {
        df$Condition <- paste(df$type, df$speed, sep = "_")
        group_var <- "type" 
    } else if (analysis_type == "type-speed") {
        df$Condition <- paste(df$type, df$speed, sep = "_")
        group_var <- "speed"
    }

    df_grouped <- df %>%
        group_by(gene_id, Condition) %>%
        summarise(rpkm = mean(rpkm), .groups = "drop")

    df_wide <- df_grouped %>%
        pivot_wider(names_from = Condition, values_from = rpkm, values_fill = 0)

    gene_ids <- df_wide$gene_id
    df_wide <- df_wide %>% select(-gene_id)
    rownames(df_wide) <- gene_ids

    dge <- DGEList(counts = df_wide)
    conditions <- colnames(df_wide)
    group <- factor(df[[group_var]][match(conditions, df$Condition)])
    group <- factor(make.names(as.character(group)))

    design <- model.matrix(~ 0 + group)
    print(levels(group))
    print(colnames(design))

    keep <- filterByExpr(dge, group=group)
    dge <- dge[keep, , keep.lib.sizes = FALSE]
    dge <- calcNormFactors(dge)

    v <- voom(dge, design)

    pca <- prcomp(t(v$E))

    pcaData <- data.frame(
        Sample = colnames(df_wide), 
        PC1 = pca$x[, 1], 
        PC2 = pca$x[, 2], 
        Group = group
    )
    
    ggplot(pcaData, aes(x = PC1, y = PC2, color = Group)) +
        geom_point(size = 4) +
        theme_minimal() +
        labs(title = "PCA Plot", x = "PC1", y = "PC2")
})
}

# Integração UI-Server
shinyApp(ui = ui, server = server)