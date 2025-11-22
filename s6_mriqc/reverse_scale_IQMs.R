# ---- packages ----
library(tidyverse)
library(rrobot)   # GitHub: mandymejia/rrobot
library(ggrain)   # for geom_rain()
library(shadowtext)
library(tidycomm)
library(dplyr)
library(tidyr)
library(readr)

# read in files of IQMs that need to be inverted
df_bold_inv <- readr::read_csv('Desktop/ADNI_paper/group_bold_inverse.csv')
df_t1_inv   <- readr::read_csv('Desktop/ADNI_paper/group_T1w_inverse.csv')

# invert the columns one by one (b/c the package was failing when I passed the whole df idk why...)
df_t1_cnr_inv <- as_tibble(df_t1_inv$cnr_T1w)
df_t1_cnr_inv <- reverse_scale(df_t1_cnr_inv)

df_t1_snr_inv <- as_tibble(df_t1_inv$snr_total_T1w)
df_t1_snr_inv <- reverse_scale(df_t1_snr_inv)

df_t1_tpmcsf_inv <- as_tibble(df_t1_inv$tpm_overlap_csf_T1w)
df_t1_tpmcsf_inv <- reverse_scale(df_t1_tpmcsf_inv)

df_t1_tpmwm_inv <- as_tibble(df_t1_inv$tpm_overlap_wm_T1w)
df_t1_tpmwm_inv <- reverse_scale(df_t1_tpmwm_inv)

df_t1_tpmgm_inv <- as_tibble(df_t1_inv$tpm_overlap_gm_T1w)
df_t1_tpmgm_inv <- reverse_scale(df_t1_tpmgm_inv)

df_t1_cnr_inv <- df_t1_cnr_inv |> rename(cnr_T1w = value_rev)
df_t1_snr_inv <- df_t1_snr_inv |> rename(snr_total_T1w = value_rev)
df_t1_tpmcsf_inv <- df_t1_tpmcsf_inv |> rename(tpm_overlap_csf_T1w = value_rev)
df_t1_tpmwm_inv <- df_t1_tpmwm_inv |> rename(tpm_overlap_wm_T1w = value_rev)
df_t1_tpmgm_inv <- df_t1_tpmgm_inv |> rename(tpm_overlap_gm_T1w = value_rev)

# merge back into a single df (T1w)
df_t1_final <- df_t1_inv |>
  mutate(
    cnr_T1w = df_t1_cnr_inv$cnr_T1w,
    snr_total_T1w = df_t1_snr_inv$snr_total_T1w,
    tpm_overlap_csf_T1w = df_t1_tpmcsf_inv$tpm_overlap_csf_T1w,
    tpm_overlap_wm_T1w = df_t1_tpmwm_inv$tpm_overlap_wm_T1w,
    tpm_overlap_gm_T1w = df_t1_tpmgm_inv$tpm_overlap_gm_T1w
    
  )

# invert the bold IQMs one by one (same reason as above)
df_bold_snr_inv <- as_tibble(df_bold_inv$snr)
df_bold_snr_inv <- reverse_scale(df_bold_snr_inv)

df_bold_tsnr_inv <- as_tibble(df_bold_inv$tsnr)
df_bold_tsnr_inv <- reverse_scale(df_bold_tsnr_inv)

df_bold_snr_inv <- df_bold_snr_inv |> rename(snr = value_rev)
df_bold_tsnr_inv <- df_bold_tsnr_inv |> rename(tsnr = value_rev)

# merge back into a single df (bold)
df_bold_inv_final <- df_bold_inv |>
  mutate(
    snr = df_bold_snr_inv$snr,
    tsnr = df_bold_tsnr_inv$tsnr
    
  )

# compute the threshold in the inverted space
compute_thresh <- function(x) {
  x <- x[is.finite(x)]
  if (length(x) == 0) return(list(val = NA_real_, method = "NA"))
  if (length(unique(x)) < 8 || length(x) < 30) {
    m  <- median(x, na.rm = TRUE)
    md <- mad(x, constant = 1.4826, na.rm = TRUE)
    return(list(val = m + 4*md, method = "MAD"))
  }
  out <- try({
    fit <- SHASH_out(
      x,
      symmetric   = TRUE,
      thr0        = 2.58,
      thr         = 4,
      upper_only  = TRUE,
      use_isotree = FALSE,
      use_isoplus = TRUE,
      thr_isotree = 0.55
    )
    normal_to_SHASH(4, fit$SHASH_coef$mu, fit$SHASH_coef$sigma,
                    fit$SHASH_coef$nu, fit$SHASH_coef$tau)
  }, silent = TRUE)
  if (inherits(out, "try-error") || !is.finite(out)) {
    m  <- median(x, na.rm = TRUE)
    md <- mad(x, constant = 1.4826, na.rm = TRUE)
    return(list(val = m + 4*md, method = "MAD"))
  } else {
    return(list(val = out, method = "SHASH"))
  }
}

get_thresholds <- function(df, metrics = NULL) {
  # if no metrics provided, use all numeric columns
  if (is.null(metrics)) {
    metrics <- df %>% select(where(is.numeric)) %>% names()
  }
  
  purrr::map_dfr(
    metrics,
    \(nm) {
      res <- compute_thresh(df[[nm]])
      tibble(
        metric    = nm,
        thresh_val = res$val,
        method     = res$method
      )
    }
  )
}

t1_metrics <- c(
  "cnr_T1w",
  "snr_total_T1w",
  "tpm_overlap_csf_T1w",
  "tpm_overlap_wm_T1w",
  "tpm_overlap_gm_T1w"
)
t1_thresholds <- get_thresholds(df_t1_final, metrics = t1_metrics)
t1_thresholds

bold_metrics <- c("snr", "tsnr")
bold_thresholds <- get_thresholds(df_bold_inv_final, metrics = bold_metrics)
bold_thresholds

# add the thresholds as a row to the BOLD & T1w dataframes (so we can invert it back into normal space)
df_t1_final <- bind_rows(df_t1_final, tibble(participant_id = "threshold", ses_id = "threshold", cnr_T1w = 1.5844747, snr_total_T1w = 7.7012284, tpm_overlap_csf_T1w = 0.2547304, tpm_overlap_gm_T1w = 0.5593047, tpm_overlap_wm_T1w = 0.5437668))
df_bold_inv_final <- bind_rows(df_bold_inv_final, tibble(participant_id = "threshold", ses_id = "threshold", snr = 6.875582, tsnr = 130.444412))


df_t1_cnr <- as_tibble(df_t1_final$cnr_T1w)
df_t1_cnr <- reverse_scale(df_t1_cnr)

df_t1_snr <- as_tibble(df_t1_final$snr_total_T1w)
df_t1_snr <- reverse_scale(df_t1_snr)

df_t1_tpmcsf <- as_tibble(df_t1_final$tpm_overlap_csf_T1w)
df_t1_tpmcsf <- reverse_scale(df_t1_tpmcsf)

df_t1_tpmwm <- as_tibble(df_t1_final$tpm_overlap_wm_T1w)
df_t1_tpmwm <- reverse_scale(df_t1_tpmwm)

df_t1_tpmgm <- as_tibble(df_t1_final$tpm_overlap_gm_T1w)
df_t1_tpmgm <- reverse_scale(df_t1_tpmgm)

df_t1_cnr <- df_t1_cnr |> rename(cnr_T1w = value_rev)
df_t1_snr <- df_t1_snr |> rename(snr_total_T1w = value_rev)
df_t1_tpmcsf <- df_t1_tpmcsf |> rename(tpm_overlap_csf_T1w = value_rev)
df_t1_tpmwm <- df_t1_tpmwm |> rename(tpm_overlap_wm_T1w = value_rev)
df_t1_tpmgm <- df_t1_tpmgm |> rename(tpm_overlap_gm_T1w = value_rev)

df_t1_orig <- df_t1_final |>
  mutate(
    cnr_T1w = df_t1_cnr$cnr_T1w,
    snr_total_T1w = df_t1_snr$snr_total_T1w,
    tpm_overlap_csf_T1w = df_t1_tpmcsf$tpm_overlap_csf_T1w,
    tpm_overlap_wm_T1w = df_t1_tpmwm$tpm_overlap_wm_T1w,
    tpm_overlap_gm_T1w = df_t1_tpmgm$tpm_overlap_gm_T1w
    
  )

df_bold_snr <- as_tibble(df_bold_inv_final$snr)
df_bold_snr <- reverse_scale(df_bold_snr)

df_bold_tsnr <- as_tibble(df_bold_inv_final$tsnr)
df_bold_tsnr <- reverse_scale(df_bold_tsnr)

df_bold_snr <- df_bold_snr |> rename(snr = value_rev)
df_bold_tsnr <- df_bold_tsnr |> rename(tsnr = value_rev)

df_bold_orig_final <- df_bold_inv_final |>
  mutate(
    snr = df_bold_snr$snr,
    tsnr = df_bold_tsnr$tsnr
    
  )

df_bold_orig_final[df_bold_orig_final$participant_id == "threshold", ]
df_t1_orig[df_t1_orig$participant_id == "threshold", ]

cnr_t1_thresh = 0.676
snr_t1_thresh = 2.39
tpm_csf_thresh = 0.159
tpm_gm_thresh = 0.449
tpm_wm_thresh = 0.443

bold_snr_thresh = 1.44
bold_tsnr_thresh = 0.109
