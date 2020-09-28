library(tidyverse)
library(forcats)

library(ggplot2)
#theme_set(theme_bw())

setwd("D:/Info Viz/AidData")

df <- read.csv("AidDataCoreThin_ResearchRelease_Level1_v3.1.csv")

# calculate total donations, total receipts, and net donations
donors <- df %>% 
  filter(year == 2013) %>% 
  group_by(donor) %>% 
  summarize(donations = sum(commitment_amount_usd_constant)) %>%
  # arrange(desc(donations)) %>%
  rename(country = donor)

recipients <- df %>%
  filter (year == 2013) %>%
  group_by(recipient) %>%
  summarize(receipts = sum(commitment_amount_usd_constant)) %>%
  # arrange(desc(receipts)) %>% 
  rename(country = recipient)

# merge donations and receipts, calculate net donations for each country
countries <- donors %>%
  full_join(recipients, by = "country") %>%
  replace_na(list(donations = 0, receipts = 0)) %>%
  mutate(net_donations = donations - receipts) %>%
  arrange(desc(net_donations))

# filter out unwanted entities
f_countries <- countries %>% subset(
  country != "European Communities (EC)" &
  country != "World Bank - International Development Association (IDA)" &
  country != "Inter-American Development Bank (IADB)" &
  country != "World Bank - International Bank for Reconstruction and Development (IBRD)" &
  country != "Asian Development Bank (ASDB)" &
  country != "European Bank for Reconstruction & Development (EBRD)" &
  country != "Asian Development Bank (AsDB Special Funds)" &
  country != "Islamic Development Bank (ISDB)" &
  country != "Global Fund to Fight Aids, Tuberculosis and Malaria (GFATM)" &
  country != "Bill & Melinda Gates Foundation" &
  country != "African Development Fund (AFDF)" &
  country != "African Development Bank (AFDB)" &
  country != "Global Alliance for Vaccines & Immunization (GAVI)" &
  country != "OPEC Fund for International Development (OFID)" &
  country != "Arab Fund for Economic & Social Development (AFESD)" &
  country != "Global Environment Facility (GEF)" &
  country != "United Nations Children`s Fund (UNICEF)" &
  country != "International Monetary Fund (IMF)" &
  country != "International Fund for Agricultural Development (IFAD)" &
  country != "United Nations Relief and Works Agency for Palestine Refugees in the Near East (UNRWA)" &
  country != "World Health Organization (WHO)" &
  country != "United Nations Development Programme (UNDP)" &
  country != "United Nations High Commissioner for Refugees (UNHCR)" &
  country != "United Nations Population Fund (UNFPA)" &
  country != "Joint United Nations Programme on HIV/AIDS (UNAIDS)" &
  country != "Arab Bank for Economic Development in Africa (BADEA)" &
  country != "Organization for Security and Co-operation in Europe (OSCE)" &
  country != "United Nations Peacebuilding Fund (UNPBF)" &
  country != "Nordic Development Fund (NDF)" &
  country != "Global Green Growth Institute (GGGI)" &
  country != "United Nations Economic Commission for Europe (UNECE)" &
  country != "South & Central Asia, Regional Programs" &
  !grepl("Regional Programs", country, ignore.case = TRUE) &
  !grepl("unspecified", country, ignore.case = TRUE)
  )
  
# plot donator countries
f_countries %>%
  mutate(donations = donations / 1e9) %>%
  arrange(desc(donations)) %>%
  # filter(donations > 0) %>%
  slice(1:20) %>%
  ggplot( aes(x = fct_reorder(country, donations), y=donations)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_y_reverse(position = "right") +
  xlab("Country") +
  ylab("2013 Donations (in billions USD")

# plot receiver countries
f_countries %>%
  # filter(receipts > 0) %>%
  mutate(receipts = receipts / 1e9) %>%
  arrange(desc(receipts)) %>%
  slice (1:20) %>%
  ggplot( aes(x = fct_reorder(country, -receipts), y=receipts)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_y_continuous(position = "right") +
  xlab("Country") +
  ylab("2013 Receipts (in billions USD)")
  # ylim(0,30)

