#!/usr/bin/env Rscript
source("/tmp/class-libs.R")

class_name = "PH251B"

class_libs = c(
  "tidyverse",     "2.0.0",
  "formatR",       "1.14",
  "janitor",       "2.2.1",
  "gapminder",     "1.0.0",
  "ggthemes",      "5.1.0",
  "scales",        "1.4.0",
  "RColorBrewer",  "1.1-3",
  "gt",            "0.11.1",
  "gtsummary",     "2.0.3",
  "sf",            "1.0-21",
  "maps",          "3.4.3",
  "tigris",        "2.2.1",
  "leaflet",       "2.2.2",
  "sp",            "2.2-0",
  "viridis",       "0.6.5",
  "plotly",        "4.11.0",
  "lemon",         "0.4.9",
  "DT",            "0.33",
  "reactable",     "0.4.4",
  "patchwork",     "1.2.0",
  "flexdashboard", "0.5.2",
  "rio",           "1.1.0",
  "here",          "1.0.1",
  "shiny",         "1.11.1",
  "tmap",          "4.1"
)

class_libs_install_version(class_name, class_libs)

