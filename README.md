# White Noise

A menu bar noise generator for macOS 27, built with SwiftUI and Liquid Glass. All sound is synthesized in real time, so there are no audio files.

```sh
./build-app.sh && open build/WhiteNoise.app
```

## Modes

Each mode is built for one intent. The evidence behind them is modest, so treat these as reasonable defaults, not treatments.

| Mode | Sound | Why |
| --- | --- | --- |
| **Focus** | Steady pink noise | A 2024 meta-analysis (13 studies, 335 participants) found that white/pink noise gave a small boost to task performance in people with ADHD or attention problems, but *hurt* performance in people without them. Use it at a low volume, and turn it off if it distracts you. |
| **Mask** | Pink noise band-limited to ~150 Hz–4 kHz | Masking distracting sound is the best-supported use of noise. Focusing the energy on the speech band covers voices without extra rumble or hiss. |
| **Sleep** | Brown noise with high frequencies rolled off | Masking disruptive sounds is the strongest case for noise at night. Lower frequencies are less harsh. Reviews rate the overall evidence for sleep as low quality, so keep the volume quiet (WHO advises about 30 dBA indoors at night) and use the timer. |
| **Calm** | Pink noise in slow, surf-like 10-second swells | A gentle rhythm to breathe along with, at about 6 breaths a minute. |

The timer fades the sound out gradually over its last stretch, up to 10 minutes, so it doesn't stop abruptly.

Popular claims that pink noise "boosts deep sleep and memory" come from small lab studies. Those studies timed noise bursts to EEG-detected slow waves, which a continuous track can't do.

## Sources

- [White/pink noise and ADHD meta-analysis, JAACAP 2024](https://pubmed.ncbi.nlm.nih.gov/38428577/)
- [Söderlund et al. 2007, noise and cognitive performance in ADHD](https://pubmed.ncbi.nlm.nih.gov/17683456/)
- [Northwestern: timed pink noise and slow-wave sleep](https://news.feinberg.northwestern.edu/2019/07/05/pink-noise-boosts-deep-sleep-in-mild-cognitive-impairment-patients/)
- [Frontiers 2023, open-loop pink noise during sleep](https://www.frontiersin.org/journals/human-neuroscience/articles/10.3389/fnhum.2023.1302836/pdf)
- [WHO noise fact sheet](https://www.who.int/europe/news-room/fact-sheets/item/noise)
- [Hongisto & Oliva, masking sound spectrum preference, Euronoise 2018](https://www.euronoise2018.eu/docs/papers/317_Euronoise2018.pdf)
