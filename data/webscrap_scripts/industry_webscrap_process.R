library(tidyverse)
library(rvest)

year_cycles = seq(2000, 2020, by=2)
base_url = "https://www.opensecrets.org/political-action-committees-pacs/industry-breakdown/"
csv_data = data.frame(
  industry_name = character(),
  total = character(),
  democrat = numeric(),
  republican = numeric(),
  year = numeric()
)
colnames(csv_data) = c("industry_name", "total", "dem", "repub", "year")
for (year in year_cycles){
  print(year)
  raw_data = read_html(paste0(base_url, year)) %>% 
    html_element("table.DataTable-Partial") %>% 
    html_table() %>% rename(industry = `Name`,
                            total = Total,
                            dems = `Total to Democrats`,
                            repubs = `Total to Republicans`) %>% 
    select(-Classification) %>% 
    mutate(
      dems = parse_number(gsub("[$,]", "", dems)),
      repubs = parse_number(gsub("[$,]", "", repubs)),
      total = dems + repubs,
      year_number = year) %>% 
    drop_na()
  
  colnames(raw_data) = c("industry_name", "total", "dem", "repub", "year")
  
  write_csv(raw_data, paste0("data/industry_donation_data/year_", year, ".csv"))
  
  csv_data <- rbind(csv_data, raw_data)
  
}

write_csv(csv_data, "data/industry_donation_data/full_data.csv")

clean_data = csv_data %>% drop_na()

write_csv(clean_data, "data/industry_donation_data/clean_data.csv")


