static int topbar = 1; /* -b  option; if 0, dmenu appears at bottom     */
static const char *fonts[] = {
    "JetBrains Mono:size=12",
    "JoyPixels:pixelsize=12:antialias=true:autohint=true"};
static const unsigned int bgalpha = 0xe0;
static const unsigned int fgalpha = OPAQUE;
static const char *prompt =
    NULL;
static const char *colors[SchemeLast][2] = {
    /*     fg         bg       */
    [SchemeNorm] = {"#bbbbbb", "#222222"},
    [SchemeSel] = {"#eeeeee", "#005577"},
    [SchemeOut] = {"#000000", "#00ffff"},
};
static const unsigned int alphas[SchemeLast][2] = {
    /*		fgalpha		bgalphga	*/
    [SchemeNorm] = {fgalpha, bgalpha},
    [SchemeSel] = {fgalpha, bgalpha},
    [SchemeOut] = {fgalpha, bgalpha},
};
static unsigned int lines = 0;
static const char worddelimiters[] = " ";
