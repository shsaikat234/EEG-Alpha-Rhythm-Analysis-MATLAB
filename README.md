# EEG-Alpha-Rhythm-Analysis-MATLAB

### MATLAB-based EEG Alpha Rhythm Analysis

This project analyzes EEG signals to study how **alpha brain wave activity (8–13 Hz)** changes under different mental and sensory conditions.  
It was developed as part of a **Biomedical Signal Processing (EEG II)** course using MATLAB.

---

## Overview

Electroencephalography (EEG) records electrical activity of the brain.  
Alpha rhythms (8–13 Hz) are dominant when a person is relaxed with eyes closed and tend to diminish during mental activity or when eyes are open.

This project focuses on:
- Filtering EEG signals to isolate alpha waves  
- Performing **FFT (Fast Fourier Transform)** analysis  
- Extracting **RMS features** from the alpha band  
- Comparing alpha activity across different conditions

---

## Methodology

1. **Preprocessing**
   - Import raw EEG data and time vector.
   - Apply a band-pass filter (8–13 Hz) using MATLAB’s `filtfilt` function.

2. **Frequency Analysis**
   - Compute single-sided FFT (`singleSidedFFT`) to visualize frequency distribution.
   - Observe alpha peaks during different states.

3. **RMS Envelope Extraction**
   - Compute RMS of alpha-filtered EEG with a 0.5-second moving window.
   - RMS provides a smooth envelope representing alpha power over time.

4. **Feature Extraction**
   - Divide data into segments:
     - Eyes Closed (Control)
     - Mental Arithmetic
     - Recovery (after hyperventilation)
     - Eyes Open
   - Compute for each:
     - Standard deviation of raw EEG (`EEG_std`)
     - Standard deviation of alpha signal (`Alpha_std`)
     - Mean RMS of alpha (`Alpha_RMS_mean`)
   - Compare alpha RMS values relative to control condition.

---

## Results Summary

| Condition | EEG Std | Alpha Std | Alpha RMS Mean | Alpha RMS Diff | Summary |
|------------|----------|------------|----------------|----------------|----------|
| Eyes Closed (Control) | 9.7347 | 7.7084 | 7.3122 | 0 | = |
| Mental Arithmetic | 7.5341 | 5.3481 | 4.8403 | -2.4719 | – |
| Recovery | 9.4343 | 7.5651 | 7.2776 | -0.0345 | – |
| Eyes Open | 4.7246 | 1.3529 | 1.2995 | -6.0126 | – |

**Observations:**
- Alpha activity was **strongest** during **eyes closed** (relaxed state).  
- Alpha power **decreased sharply** during **mental arithmetic** due to cognitive effort.  
- During **recovery**, alpha waves **returned near baseline**.  
- **Eyes open** condition produced the **lowest alpha amplitude** due to visual input.

---

## Visual Outputs

- **Figure 1:** Alpha-band FFT comparison across stages  
- **Figure 2:** Raw vs Alpha vs Alpha-RMS signals  
- **Figure 3:** RMS envelope showing alpha activity trends  
- **Table:** Summary of computed EEG and alpha metrics

---

## Key MATLAB Components

- `filtfilt()` → zero-phase band-pass filtering  
- `fft()` → frequency domain analysis  
- `movmean()` → moving RMS computation  
- Custom helper functions:
  - `sec2idx()` – converts time (s) to sample index  
  - `singleSidedFFT()` – computes normalized single-sided FFT spectrum

---

## Interpretation

- **High alpha amplitude (eyes closed)** → relaxed brain state  
- **Suppressed alpha (mental tasks / eyes open)** → active cortical processing  
- **Recovery phase** → alpha returns as the subject relaxes again  

These results align with well-established neurophysiological findings about alpha rhythm behavior.

---

## Tools Used

- **MATLAB R2023b** (or later)  
- **Signal Processing Toolbox**  
- Platform: Windows/Linux/macOS  

---

## Learning Outcomes

- Implemented practical **EEG signal processing** pipeline in MATLAB  
- Learned to use **FFT**, **filtering**, and **feature extraction**  
- Understood **physiological meaning** of EEG alpha variations  
- Strengthened skills in **data visualization** and **scientific reporting**

---

## Author

**Shahriar Uddin Saikat**  
Biomedical Engineering, CUET  
Date: June 8, 2025  
Project: EEG II (MATLAB Lab)

---

## License

This project is shared for educational and research purposes.  
Feel free to use or adapt with proper credit.

---

> *"EEG reveals the calm and the chaos — one waveform at a time."*
