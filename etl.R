library(tidyverse)
library(fs)

download_and_unzip <- function(url, dir) {
  zipfile <- path_file(url)
  download.file(url, zipfile)
  unzip(zipfile, exdir = dir)
  file_delete(zipfile)
  dir
}

read_yob_txt <- function(file) {
  read_csv(
    file,
    col_names = c("name", "sex", "n"),
    col_types = list(sex = col_character())
  ) %>%
  mutate(year = parse_number(file))
}

read_state_txt <- function(file) {
  read_csv(
    file,
    col_names = c("state", "sex", "year", "name", "n"),
    col_types = list(sex = col_character())
  )
}


# National

"https://www.ssa.gov/oact/babynames/names.zip" %>%
  download_and_unzip(dir = "names") %>%
  dir_ls(glob = "*.txt") %>%
  map_dfr(read_yob_txt) %>%
  select(year, name, sex, n) %>%
  arrange(desc(year), desc(n)) %>%
  write_csv("us-baby-names.csv")

dir_delete("names")


"https://www.ssa.gov/oact/babynames/state/namesbystate.zip" %>%
  download_and_unzip(dir = "namesbystate") %>%
  dir_ls(glob = "*.TXT") %>%
  map_dfr(read_state_txt) %>%
  select(year, state, name, sex, n) %>%
  arrange(desc(year), state, desc(n)) %>%
  write_csv("state-baby-names.csv")

dir_delete("namesbystate")


"https://www.ssa.gov/oact/babynames/territory/namesbyterritory.zip" %>%
  download_and_unzip(dir = "namesbyterritory") %>%
  dir_ls(glob = "*.TXT") %>%
  map_dfr(read_state_txt) %>%
  rename(territory = state) %>%
  select(year, territory, name, sex, n) %>%
  arrange(desc(year), territory, desc(n)) %>%
  write_csv("territory-baby-names.csv")

dir_delete("namesbyterritory")
