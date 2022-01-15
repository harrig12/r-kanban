# Kanban board in R

library(tidyverse)

# The Kanban board is card-centric. Each one lives as an entry in a csv file
# These can get moved around by modifying their "status" attribute. 

init_kanban <- function(filename='kanban.csv', overwrite=F){
  cards <- tibble(name = 'example card', project = 'demo',
                  status = 'Not Started', details = '')
  if (file.exists(filename) & overwrite==F){
    stop(paste0('init halted to avoid overwriting "', 
                filename, '" chose a different filename or set overwrite=TRUE'))
  }
  write_csv(cards, filename)
}

read_kanban <- function(filename='kanban.csv', columns = c('Not Started', 'In Progress', 'Done')){
  read_csv(filename, col_types = 'cccc') %>%
    mutate(status = ordered(status, levels = columns)) %>%
    print_kanban(save_kanban=F) %>%
    return()
  
}

write_kanban <- function(cards, filename='kanban.csv'){
  write_csv(cards, filename)
}

print_kanban <- function(cards, save_kanban = T, filename='kanban.csv'){
  p <- cards %>% 
    mutate(height = 1) %>%
    ggplot() +
    aes(x = status, y = height, fill = project, 
        label = str_wrap(paste0(project, ': ', name), 10)) +
    geom_bar(position = "stack", stat = 'identity', color = '#404040') +
    stat_identity(geom = "text", colour = "white", check_overlap = T,
                  size=rel(5), position=position_stack(vjust=0.5)) +
    scale_x_discrete(position = 'top', drop=FALSE) +
    expand_limits(y = 3) +
    theme_void() + 
    theme(plot.margin = margin(2, 2, 2, 2, "cm"),
          legend.position = "none", 
          axis.text.x = element_text(color = 1)) 
  Sys.sleep(0.8)
  print(p)
  if(save_kanban == T){
    write_kanban(cards, filename)
  }
  return(cards)
}

add_card <- function(cards, name, project, status, details = ''){
  stopifnot(status %in% levels(cards$status))
  cards %>%
    add_row(name = name, project = project, 
            status = ordered(status, levels = levels(cards$status)), details = details) %>%
    print_kanban() %>%
    return()
}

get_index <- function(cards, card_name){
  # print the first matching index, or exit if no match found
  idx <- agrep(card_name, cards$name)
  if (length(idx) == 0){stop('no match found')}
  return(idx[1])
}

update_status <- function(cards, card_name, new_status){
  stopifnot(new_status %in% levels(cards$status))
  cards[get_index(cards, card_name),]$status <- new_status
  print_kanban(cards)
  return(cards)
}

delete_card <- function(cards, card_name){
  cards %>%
    filter(name != card_name) %>%
    print_kanban() %>%
    return()
}



