# Project 2: Identifying Undervalued MLB Hitters
# 2026 MLB Regular Season

library(tidyverse)

# Import Baseball Savant data
expected <- read_csv("data/expected_statistics.csv")

contact <- read_csv("data/exit_velocity_barrels.csv")

# Check the number of players and columns
dim(expected)
dim(contact)

# See the column names
names(expected)
names(contact)

# Preview the datasets
head(expected)
head(contact)

dim(expected)
dim(contact)
names(expected)
names(contact)

# STEP 5: Combine and clean datasets

hitters <- expected %>%
  inner_join(
    contact,
    by = "player_id",
    suffix = c("", "_contact")
  ) %>%
  filter(bip >= 100) %>%
  mutate(
    ba_difference = est_ba - ba,
    slg_difference = est_slg - slg,
    woba_difference = est_woba - woba
  )

# Check the combined dataset
dim(hitters)

# Preview the results
head(hitters)

# Top 15 hitters by expected vs actual batting average

top_undervalued <- hitters %>%
  arrange(desc(ba_difference)) %>%
  select(
    `last_name, first_name`,
    ba,
    est_ba,
    ba_difference,
    slg,
    est_slg,
    slg_difference,
    bip
  ) %>%
  head(15)

print(top_undervalued, n = 15)

dim(hitters)
print(top_undervalued, n = 15)

# STEP 6: Actual vs Expected Batting Average

library(ggplot2)

ba_plot <- ggplot(
  hitters,
  aes(x = ba, y = est_ba)
) +
  geom_point(
    color = "#1F77B4",
    alpha = 0.65,
    size = 2.5
  ) +
  geom_abline(
    slope = 1,
    intercept = 0,
    linetype = "dashed",
    color = "red"
  ) +
  labs(
    title = "Actual vs Expected Batting Average",
    subtitle = "2026 MLB Hitters | Minimum 100 Balls in Play",
    x = "Actual Batting Average",
    y = "Expected Batting Average",
    caption = "Source: Baseball Savant / Statcast"
  ) +
  coord_equal() +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    plot.subtitle = element_text(color = "gray40")
  )

print(ba_plot)

# Create a folder for visualizations
dir.create("visualizations", showWarnings = FALSE)

# Save Chart 1
ggsave(
  "visualizations/MLB_2026_Actual_vs_Expected_BA.png",
  plot = ba_plot,
  width = 10,
  height = 7,
  dpi = 300
)

# STEP 7: Highlight the top 5 xBA gaps

library(ggplot2)

# Identify the five largest positive differences
top_5_hitters <- hitters %>%
  filter(!is.na(ba_difference)) %>%
  arrange(desc(ba_difference)) %>%
  slice_head(n = 5)

# Create the improved visualization
ba_plot_highlighted <- ggplot(
  hitters,
  aes(x = ba, y = est_ba)
) +
  geom_point(
    color = "#1F77B4",
    alpha = 0.45,
    size = 2.5
  ) +
  geom_abline(
    slope = 1,
    intercept = 0,
    linetype = "dashed",
    color = "red"
  ) +
  geom_point(
    data = top_5_hitters,
    color = "#FF8C00",
    size = 3.5
  ) +
  geom_text(
    data = top_5_hitters,
    aes(label = `last_name, first_name`),
    hjust = -0.1,
    vjust = -0.5,
    size = 3,
    check_overlap = TRUE
  ) +
  labs(
    title = "Actual vs Expected Batting Average",
    subtitle = "2026 MLB Hitters | Top 5 Positive xBA Gaps Highlighted",
    x = "Actual Batting Average",
    y = "Expected Batting Average",
    caption = "Source: Baseball Savant / Statcast"
  ) +
  coord_equal() +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold")
  )

print(ba_plot_highlighted)

# Save highlighted visualization

ggsave(
  "visualizations/MLB_2026_BA_Gap_Highlighted.png",
  plot = ba_plot_highlighted,
  width = 12,
  height = 8,
  dpi = 300
)

# STEP 8: Top 15 Positive xBA Gaps

library(ggplot2)
library(dplyr)

# Prepare the top 15 hitters
top_15_ba <- hitters %>%
  filter(!is.na(ba_difference)) %>%
  arrange(desc(ba_difference)) %>%
  slice_head(n = 15)

# Create the horizontal bar chart
ba_gap_plot <- ggplot(
  top_15_ba,
  aes(
    x = reorder(`last_name, first_name`, ba_difference),
    y = ba_difference
  )
) +
  geom_col(
    fill = "#1F77B4",
    width = 0.7
  ) +
  geom_text(
    aes(label = sprintf("+%.3f", ba_difference)),
    hjust = -0.15,
    size = 3.5
  ) +
  coord_flip() +
  scale_y_continuous(
    limits = c(0, max(top_15_ba$ba_difference) * 1.2)
  ) +
  labs(
    title = "Top 15 Positive Expected Batting Average Gaps",
    subtitle = "2026 MLB Hitters | Minimum 100 Balls in Play",
    x = NULL,
    y = "Expected BA Minus Actual BA",
    caption = "Source: Baseball Savant / Statcast"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.major.y = element_blank()
  )

# Display chart
print(ba_gap_plot)

ggsave(
  "visualizations/MLB_2026_Top_15_xBA_Gaps.png",
  plot = ba_gap_plot,
  width = 11,
  height = 8,
  dpi = 300
)

# STEP 9: Top 15 Positive Expected Slugging Gaps

# Identify the top 15 hitters
top_15_slg <- hitters %>%
  filter(!is.na(slg_difference)) %>%
  arrange(desc(slg_difference)) %>%
  slice_head(n = 15)

# Create horizontal bar chart
slg_gap_plot <- ggplot(
  top_15_slg,
  aes(
    x = reorder(`last_name, first_name`, slg_difference),
    y = slg_difference
  )
) +
  geom_col(
    fill = "#2CA58D",
    width = 0.7
  ) +
  geom_text(
    aes(label = sprintf("+%.3f", slg_difference)),
    hjust = -0.15,
    size = 3.5
  ) +
  coord_flip() +
  scale_y_continuous(
    limits = c(0, max(top_15_slg$slg_difference) * 1.2)
  ) +
  labs(
    title = "Top 15 Positive Expected Slugging Gaps",
    subtitle = "2026 MLB Hitters | Minimum 100 Balls in Play",
    x = NULL,
    y = "Expected SLG Minus Actual SLG",
    caption = "Source: Baseball Savant / Statcast"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.major.y = element_blank()
  )

# Display chart
print(slg_gap_plot)

# Save Chart 3

ggsave(
  "visualizations/MLB_2026_Top_15_xSLG_Gaps.png",
  plot = slg_gap_plot,
  width = 11,
  height = 8,
  dpi = 300
)

# STEP 10: Hard-Hit Rate vs Barrel Rate

library(ggplot2)
library(dplyr)

# Identify five hitters for further evaluation
candidates <- hitters %>%
  filter(
    `last_name, first_name` %in% c(
      "Hayes, Ke'Bryan",
      "Arroyo, Edwin",
      "Jiménez, Leo",
      "Julien, Edouard",
      "Bailey, Patrick"
    )
  )

# Create scatterplot
contact_plot <- ggplot(
  hitters,
  aes(x = brl_percent, y = `ev95percent`)
) +
  geom_point(
    color = "#1F77B4",
    alpha = 0.5,
    size = 2.5
  ) +
  geom_point(
    data = candidates,
    color = "#FF8C00",
    size = 4
  ) +
  geom_text(
    data = candidates,
    aes(label = `last_name, first_name`),
    hjust = -0.1,
    vjust = -0.5,
    size = 3,
    check_overlap = TRUE
  ) +
  labs(
    title = "Hard-Hit Rate vs Barrel Rate",
    subtitle = "2026 MLB Hitters | Five xBA and xSLG Gap Candidates Highlighted",
    x = "Barrel Rate (%)",
    y = "Hard-Hit Rate (%)",
    caption = "Source: Baseball Savant / Statcast"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold")
  )

# Display chart
print(contact_plot)

summary(hitters$brl_percent)
summary(hitters$ev95percent)

# Save Chart 4

ggsave(
  "visualizations/MLB_2026_Hard_Hit_vs_Barrel_Rate.png",
  plot = contact_plot,
  width = 12,
  height = 8,
  dpi = 300
)

# STEP 11: Top 15 Positive xwOBA Gaps

top_15_woba <- hitters %>%
  filter(!is.na(woba_difference)) %>%
  arrange(desc(woba_difference)) %>%
  slice_head(n = 15)

# Create horizontal bar chart
woba_gap_plot <- ggplot(
  top_15_woba,
  aes(
    x = reorder(`last_name, first_name`, woba_difference),
    y = woba_difference
  )
) +
  geom_col(
    fill = "#9467BD",
    width = 0.7
  ) +
  geom_text(
    aes(label = sprintf("+%.3f", woba_difference)),
    hjust = -0.15,
    size = 3.5
  ) +
  coord_flip() +
  scale_y_continuous(
    limits = c(0, max(top_15_woba$woba_difference) * 1.2)
  ) +
  labs(
    title = "Top 15 Positive Expected wOBA Gaps",
    subtitle = "2026 MLB Hitters | Minimum 100 Balls in Play",
    x = NULL,
    y = "Expected wOBA Minus Actual wOBA",
    caption = "Source: Baseball Savant / Statcast"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.major.y = element_blank()
  )

# Display chart
print(woba_gap_plot)

# Save Chart 5

ggsave(
  "visualizations/MLB_2026_Top_15_xwOBA_Gaps.png",
  plot = woba_gap_plot,
  width = 11,
  height = 8,
  dpi = 300
)

# STEP 12: Compare Top 5 Candidates

library(tidyr)
library(dplyr)
library(ggplot2)

# Select our five candidates
comparison_data <- hitters %>%
  filter(
    `last_name, first_name` %in% c(
      "Hayes, Ke'Bryan",
      "Julien, Edouard",
      "Arroyo, Edwin",
      "Jiménez, Leo",
      "Bailey, Patrick"
    )
  ) %>%
  select(
    `last_name, first_name`,
    ba_difference,
    slg_difference,
    woba_difference
  ) %>%
  pivot_longer(
    cols = c(
      ba_difference,
      slg_difference,
      woba_difference
    ),
    names_to = "Metric",
    values_to = "Difference"
  ) %>%
  mutate(
    Metric = recode(
      Metric,
      ba_difference = "xBA - BA",
      slg_difference = "xSLG - SLG",
      woba_difference = "xwOBA - wOBA"
    )
  )

# Create comparison chart
comparison_plot <- ggplot(
  comparison_data,
  aes(
    x = `last_name, first_name`,
    y = Difference,
    fill = Metric
  )
) +
  geom_col(
    position = "dodge",
    width = 0.7
  ) +
  scale_fill_manual(
    values = c(
      "xBA - BA" = "#1F77B4",
      "xSLG - SLG" = "#2CA58D",
      "xwOBA - wOBA" = "#9467BD"
    )
  ) +
  labs(
    title = "Comparing Expected vs Actual Performance",
    subtitle = "Five Potentially Undervalued MLB Hitters | 2026",
    x = NULL,
    y = "Expected Minus Actual",
    fill = "Metric",
    caption = "Source: Baseball Savant / Statcast"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    axis.text.x = element_text(
      angle = 25,
      hjust = 1
    ),
    legend.position = "bottom"
  )

# Display chart
print(comparison_plot)

# Save Chart 6

ggsave(
  "visualizations/MLB_2026_Candidate_Comparison.png",
  plot = comparison_plot,
  width = 12,
  height = 8,
  dpi = 300
)

# STEP 13: Hitter Evaluation Dashboard

library(dplyr)
library(tidyr)
library(ggplot2)

# Calculate percentile ranks for all hitters
ranked_hitters <- hitters %>%
  mutate(
    xBA_percentile = percent_rank(est_ba) * 100,
    xSLG_percentile = percent_rank(est_slg) * 100,
    Barrel_percentile = percent_rank(brl_percent) * 100,
    HardHit_percentile = percent_rank(ev95percent) * 100
  )

# Select our five candidates
dashboard_data <- ranked_hitters %>%
  filter(
    `last_name, first_name` %in% c(
      "Hayes, Ke'Bryan",
      "Julien, Edouard",
      "Arroyo, Edwin",
      "Jiménez, Leo",
      "Bailey, Patrick"
    )
  ) %>%
  select(
    `last_name, first_name`,
    xBA_percentile,
    xSLG_percentile,
    Barrel_percentile,
    HardHit_percentile
  ) %>%
  pivot_longer(
    cols = -`last_name, first_name`,
    names_to = "Metric",
    values_to = "Percentile"
  ) %>%
  mutate(
    Metric = recode(
      Metric,
      xBA_percentile = "Expected BA",
      xSLG_percentile = "Expected SLG",
      Barrel_percentile = "Barrel Rate",
      HardHit_percentile = "Hard-Hit Rate"
    )
  )

# Create dashboard
dashboard_plot <- ggplot(
  dashboard_data,
  aes(
    x = Metric,
    y = `last_name, first_name`,
    fill = Percentile
  )
) +
  geom_tile(
    color = "white",
    linewidth = 1
  ) +
  geom_text(
    aes(label = round(Percentile, 0)),
    size = 4,
    fontface = "bold"
  ) +
  scale_fill_gradient(
    low = "#DCEAF7",
    high = "#1F4E79",
    limits = c(0, 100)
  ) +
  labs(
    title = "2026 MLB Hitter Evaluation Dashboard",
    subtitle = "Percentile Rankings Among Hitters With 100+ Balls in Play",
    x = NULL,
    y = NULL,
    fill = "Percentile",
    caption = "Source: Baseball Savant / Statcast"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid = element_blank(),
    axis.text.x = element_text(
      angle = 20,
      hjust = 1
    )
  )

# Display dashboard
print(dashboard_plot)

# Save Chart 7

ggsave(
  "visualizations/MLB_2026_Hitter_Evaluation_Dashboard.png",
  plot = dashboard_plot,
  width = 12,
  height = 7,
  dpi = 300
)

# STEP 14: Final Candidate Statistics

final_candidates <- hitters %>%
  filter(
    `last_name, first_name` %in% c(
      "Hayes, Ke'Bryan",
      "Julien, Edouard",
      "Arroyo, Edwin",
      "Jiménez, Leo",
      "Bailey, Patrick"
    )
  ) %>%
  select(
    `last_name, first_name`,
    pa,
    bip,
    ba,
    est_ba,
    ba_difference,
    slg,
    est_slg,
    slg_difference,
    woba,
    est_woba,
    woba_difference,
    brl_percent,
    ev95percent
  ) %>%
  arrange(desc(woba_difference))

# Display the table
print(final_candidates, width = Inf)

# Save the results
write_csv(
  final_candidates,
  "data/MLB_2026_Final_Candidates.csv"
)