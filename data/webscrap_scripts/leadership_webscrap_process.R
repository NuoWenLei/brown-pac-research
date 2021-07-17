library(tidyverse)
library(rvest)

year_cycles = seq(2000, 2020, by=2)
base_url = "https://www.opensecrets.org/political-action-committees-pacs/industry-detail/Q03/"
csv_data = data.frame(
  pac_name = character(),
  affiliate = character(),
  total = numeric(),
  democrat = numeric(),
  republican = numeric(),
  lean = character(),
  year = numeric()
)
colnames(csv_data) = c("pac_name", "affiliate", "total", "dem", "repub", "lean", "year")
for (year in year_cycles){
  print(year)
  raw_data = read_html(paste0(base_url, year)) %>% 
    html_element("table.DataTable-Partial") %>% 
    html_table() %>% rename(pac = `PAC Name`,
                            aff = Affiliate,
                            total = Total,
                            dems = `To Democrats`,
                            repubs = `To Republicans`) %>% 
    mutate(
           dems = parse_number(gsub("[$,]", "", dems)),
           repubs = parse_number(gsub("[$,]", "", repubs)),
           total = dems + repubs,
           year_number = year) %>% 
    drop_na()
  
  colnames(raw_data) = c("pac_name", "affiliate", "total", "dem", "repub", "lean", "year")
  
  write_csv(raw_data, paste0("data/leadership_pac_data/year_", year, ".csv"))
  
  csv_data <- rbind(csv_data, raw_data)
  
}

write_csv(csv_data, "data/leadership_pac_data/full_data.csv")


