# ---- packages ----
library(tidyverse)
library(rrobot)   # GitHub: mandymejia/rrobot
library(ggrain)   # for geom_rain()
library(shadowtext)

# ---- data ----
df_bold <- readr::read_tsv('/Users/saigerutherford/Desktop/temp/group_bold.tsv')
df_t1   <- readr::read_tsv('/Users/saigerutherford/Desktop/temp/group_T1w.tsv')

# ---- helper: safe SHASH threshold with fallback ----
compute_thresh <- function(x) {
  x <- x[is.finite(x)]
  if (length(x) == 0) return(list(val = NA_real_, method = "NA"))
  if (length(unique(x)) < 8 || length(x) < 30) {
    m  <- median(x, na.rm = TRUE)
    md <- mad(x, constant = 1.4826, na.rm = TRUE)
    return(list(val = m + 3*md, method = "MAD"))
  }
  out <- try({
    fit <- SHASH_out(
      x,
      symmetric   = TRUE,
      thr0        = 2.58,
      thr         = 3,
      upper_only  = TRUE,
      use_isotree = FALSE,  # keep FALSE on macOS
      use_isoplus = TRUE,
      thr_isotree = 0.55
    )
    normal_to_SHASH(3, fit$SHASH_coef$mu, fit$SHASH_coef$sigma,
                    fit$SHASH_coef$nu, fit$SHASH_coef$tau)
  }, silent = TRUE)
  if (inherits(out, "try-error") || !is.finite(out)) {
    m  <- median(x, na.rm = TRUE)
    md <- mad(x, constant = 1.4826, na.rm = TRUE)
    return(list(val = m + 3*md, method = "MAD"))
  } else {
    return(list(val = out, method = "SHASH"))
  }
}

build_figures <- function(df, title_prefix = "Dataset", facet_cols = 3, hist_bins = 30) {
  num_cols <- df %>% select(where(is.numeric)) %>% names()
  
  # long data
  df_long <- df %>%
    pivot_longer(all_of(num_cols), names_to = "metric", values_to = "value")
  
  # thresholds per metric (safe)
  thresholds <- purrr::map_dfr(
    num_cols,
    \(nm) {
      res <- compute_thresh(df[[nm]])
      tibble(metric = nm, thresh_val = res$val, method = res$method)
    }
  )
  
  # join thresholds
  df_long2 <- df_long %>% left_join(thresholds, by = "metric")
  
  # outlier stats
  outlier_stats <- df_long2 %>%
    group_by(metric) %>%
    summarize(
      n       = sum(is.finite(value)),
      n_out   = sum(value > thresh_val, na.rm = TRUE),
      pct_out = 100 * n_out / n,
      .groups = "drop"
    )
  
  # facet labels with outlier info (create BEFORE annotation data)
  df_long2 <- df_long2 %>%
    left_join(outlier_stats, by = "metric") %>%
    mutate(metric_label = sprintf("%s\noutliers: %d (%.1f%%)", metric, n_out, pct_out))
  
  # --- annotation data (AFTER metric_label exists) ---
  ann <- df_long2 %>%
    group_by(metric_label) %>%
    summarize(thresh_val = first(thresh_val), .groups = "drop")
  
  # compute top-of-histogram per facet to place text safely inside panel
  hist_top <- df_long2 %>%
    group_by(metric_label) %>%
    summarize(
      y_top = {
        v <- value[is.finite(value)]
        if (length(v) == 0) 0 else {
          br <- pretty(range(v), n = hist_bins)
          h  <- hist(v, breaks = br, plot = FALSE)
          if (length(h$counts)) max(h$counts) else 0
        }
      },
      .groups = "drop"
    )
  
  ann_hist <- ann %>%
    left_join(hist_top, by = "metric_label") %>%
    mutate(y_lab = y_top * 1.10)  # label a bit above tallest bar
  
  # --- rainclouds (horizontal threshold) ---
  p_rain <- ggplot(df_long2, aes(x = 1, y = value)) +
    geom_rain(fill = "gray65", alpha = 0.55) +
    geom_hline(aes(yintercept = thresh_val),
               linetype = "dashed", color = "red", linewidth = 1) +
    # numeric label just above the line, near center (x=1)
    shadowtext::geom_shadowtext(
      data = ann,
      aes(x = 1, y = thresh_val, label = sprintf("%.3f", thresh_val)),
      hjust = 0.5, vjust = -0.4,
      color = "red", bg.color = "white",
      size = 4.2, fontface = "bold", bg.r = 0.15
    ) +
    facet_wrap(~ metric_label, scales = "free_y", ncol = facet_cols) +
    # add a bit of vertical headroom so labels don't clip
    scale_y_continuous(expand = expansion(mult = c(0.05, 0.15))) +
    labs(title = paste0(title_prefix, " – Rainclouds"), y = "Value", x = NULL) +
    theme_classic() +
    theme(
      axis.text.x  = element_blank(),
      axis.ticks.x = element_blank(),
      strip.text   = element_text(size = 8)
    )
  
  # --- histograms (vertical threshold) ---
  p_hist <- ggplot(df_long2, aes(x = value)) +
    geom_histogram(bins = hist_bins, fill = "gray75", color = "white") +
    geom_vline(aes(xintercept = thresh_val),
               linetype = "dashed", color = "red") +
    shadowtext::geom_shadowtext(
      data = ann_hist,
      aes(x = thresh_val, y = y_lab, label = sprintf("%.3f", thresh_val)),
      vjust = 0, hjust = 0.5,
      color = "red", bg.color = "white",
      size = 4.2, fontface = "bold", bg.r = 0.15
    ) +
    facet_wrap(~ metric_label, scales = "free_x", ncol = facet_cols) +
    # add top headroom so labels aren't cut
    scale_y_continuous(expand = expansion(mult = c(0.05, 0.30))) +
    labs(title = paste0(title_prefix, " – Histograms"),
         x = "Value", y = "Frequency") +
    theme_minimal() +
    theme(strip.text = element_text(size = 8))
  
  list(
    data = df_long2,
    thresholds = thresholds,
    outlier_stats = outlier_stats,
    p_rain = p_rain,
    p_hist = p_hist,
    facet_cols = facet_cols
  )
}
bold <- build_figures(df_bold, "BOLD", facet_cols = 3, hist_bins = 30)
t1   <- build_figures(df_t1,   "T1w",  facet_cols = 3, hist_bins = 30)

# Just typing the object should display it in most consoles:
bold$p_rain
bold$p_hist
t1$p_rain
t1$p_hist

# Export: same width, height proportional to rows
n_bold <- length(unique(bold$data$metric_label))
n_t1   <- length(unique(t1$data$metric_label))
bold_rows <- ceiling(n_bold / bold$facet_cols)
t1_rows   <- ceiling(n_t1   / t1$facet_cols)

fig_width  <- 10
row_height <- 2.0
bold_height <- max(row_height * bold_rows, row_height)
t1_height   <- max(row_height * t1_rows,   row_height)

ggsave("BOLD_rainclouds.pdf", bold$p_rain,
       width = fig_width, height = bold_height, units = "in",
       device = cairo_pdf, bg = "white", useDingbats = FALSE)
ggsave("BOLD_histograms.pdf", bold$p_hist,
       width = fig_width, height = bold_height, units = "in",
       device = cairo_pdf, bg = "white", useDingbats = FALSE)
ggsave("T1w_rainclouds.pdf", t1$p_rain,
       width = fig_width, height = t1_height, units = "in",
       device = cairo_pdf, bg = "white", useDingbats = FALSE)
ggsave("T1w_histograms.pdf", t1$p_hist,
       width = fig_width, height = t1_height, units = "in",
       device = cairo_pdf, bg = "white", useDingbats = FALSE)



