library ("data.table")
library ("igraph")

analyse.simulation.results <- function (
  number.nodes,
  index.graph,
  interactive = FALSE
) {
  ## read simulation results ####
  data <- fread (
    input = sprintf (
      "results-graph_%d.csv",
      index.graph
    ),
    header = FALSE
  )
  ## compute solutions ####
  graph.solution <- data [
    ,
    lapply (
      X = .SD,
      FUN = function (x) return (ifelse (x > 35, 1, 0))
    ),
    .SDcols = 8:(7 + number.nodes)
  ]
  print (graph.solution)
  columns <- sprintf (
        "V%d",
        c (8 : (7 + number.nodes))
      )
  columns <- paste (columns, collapse = ",")
  intermediate <- graph.solution [
    ,
    .N,
    by = columns
  ]
  print (intermediate)
  ## compute how many times each node appears ####
  node.appearance <- data.table (t (graph.solution))
  node.appearance [
    ,
    node := .I
    ]
  node.appearance <- node.appearance [
    ,
    .(
      count = base::sum (.SD)
    ),
    by = .(node)
  ]
  node.appearance <- node.appearance [, count]
  print (node.appearance)
  ## read graph topology ####
  graph.data <- fread (
    input = sprintf (
      "graph_%d.csv",
      index.graph
    ),
    header = FALSE
  )
  graph.data <- data.matrix (graph.data)
  graph.data <- graph_from_adjacency_matrix (
    adjmatrix = graph.data,
    mode = "undirected"
  )
  # compute the layout to use in all graphs, igraph tends to compute different node placement...
  graph.layout <- layout_with_kk (graph.data)
  print (graph.layout)
  if (!interactive) {
    number.plots <- nrow (intermediate) + 1
    dimx <- ceiling (sqrt (number.plots))
    dimy <- dimx - (dimx * dimx - number.plots) %/% dimx 
    png (
      filename = sprintf (
        "graph-%d-stats.png",
        index.graph
      ),
      width = 300 * dimx,
      height = 225 * dimy
    )
    par (
      mfrow = c (dimx, dimy),
      mar = c (0, 0, 2, 0)
    )
  }
  
  plot.solution <- function (
    nodes.id,
    number.repeats
  ) {
    nodes.id <- data.table (t (nodes.id))
    nodes.id <- nodes.id [, V1 := .I * V1]
    nodes.id <- nodes.id [V1 > 0, V1]
    nodes.id <- as.list (nodes.id)
    plot.igraph (
      x = graph.data,
      vertex.label = NA,
      mark.groups = nodes.id,
      mark.col = "blue",
      layout = graph.layout,
      main = sprintf (
        "This solution was found %d time(s)",
        number.repeats
      )
    )
    if (interactive)
      readline ("Press ENTER to continue")
    return (0)
  }
  intermediate [
    ,
      plot.solution (.SD, N),
    by = columns,
    .SDcols = 1:number.nodes
  ]
  plot.igraph (
    x = graph.data,
    layout = graph.layout,
    vertex.label = node.appearance,
    main = "Number of times each node was in a solution"
  )
  if (!interactive) {
    dev.off ()
  }
  return (0)
}
