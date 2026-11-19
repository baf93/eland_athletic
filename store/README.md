# Google Play material

Everything is rendered from `src/store.html` (one page, the fragment picks the image) with WebKit, no browser needed:

    tools/render-all.sh          # every graphic below
    swift tools/render.swift src/store.html graphics/en/1.png 1080 1920 "#shot-en-1"   # a single one

Screenshots are real captures from a phone (`shots/<lang>/`, 1080×2400) running the demo data in `demo/`
(import `demo/eland-demo.json` or `demo/eland-demo-it.json` from Settings → Your data). The page crops out the
status and navigation bars.

| Play Console                       | File                                        |
|------------------------------------|---------------------------------------------|
| App name, descriptions, what's new | `listing/en.md`, `listing/it.md`            |
| App icon (512×512)                 | `graphics/icon-512.png`                     |
| Feature graphic (1024×500)         | `graphics/<lang>/feature-1024x500.png`      |
| Phone screenshots (1080×1920)      | `graphics/<lang>/1.png` … `8.png`           |

Default listing language: **English (en-US)**. Italian (it-IT) has its own listing and graphics.

Screenshot order: 1 Run · 2 Workout detail · 3 History · 4 Live notification · 5 Timers · 6 Workouts and reminders · 7 Phases · 8 Privacy.
