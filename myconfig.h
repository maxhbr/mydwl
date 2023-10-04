/* appearance */
static const int sloppyfocus               = 1;  /* focus follows mouse */
static const int bypass_surface_visibility = 0;  /* 1 means idle inhibitors will disable idle tracking even if it's surface isn't visible  */
static const int smartgaps                 = 0;  /* 1 means no outer gap when there is only one window */
static const int monoclegaps               = 0;  /* 1 means outer gaps in monocle layout */
static const unsigned int borderpx         = 4;  /* border pixel of windows */
static const unsigned int gappih           = 10; /* horiz inner gap between windows */
static const unsigned int gappiv           = 10; /* vert inner gap between windows */
static const unsigned int gappoh           = 10; /* horiz outer gap between windows and screen edge */
static const unsigned int gappov           = 10; /* vert outer gap between windows and screen edge */
static const float bordercolor[]           = {0.5, 0.5, 0.5, 1.0};
static const float floatcolor[]            = {1.0, 0.0, 0.0, 0.0};
static const float focuscolor[]            = {0.933, 0.604, 0.0, 1.0};
/* To conform the xdg-protocol, set the alpha to zero to restore the old behavior */
static const float fullscreen_bg[]         = {0.1, 0.1, 0.1, 1.0};
static const float unfocussedalpha  = 0.75;
static const float focussedalpha    = 1;

/* cursor warping */
static const bool cursor_warp = true;

/* Autostart */
static const char *const autostart[] = {
	"mydwl-autostart", NULL,
	NULL
};

/* tagging - tagcount must be no greater than 31 */
#define TAGCOUNT (9)
static const int tagcount = TAGCOUNT;

/* use lswt to identify names */
static const Rule rules[] = {
	/* app_id     title       tags mask     isfloating   monitor */
	// { "firefox",  NULL,       1 << 8,       0,          -1 },
	{ "foot",     NULL,       0,            0,          -1 },
	{ "Gimp",     NULL,       0,            1,          -1 },
	{ NULL,       "New Layer", 0,           1,          -1 },
	{ "zoom",     NULL,       0,            1,          -1 },
	{ NULL,     "zoom",       0,            1,          -1 },
	{ "wdisplays", NULL       0,            1,          -1 },
	{ "foot-bluetuith", NULL  0,            1,          -1 },
	{ "pavucontrol", NULL     0,            1,          -1 },
};

static const Layout tileLayout =  { "[]=", tile };
static const Layout monocleLayout =  { "[M]", monocle };
static const Layout centeredmasterLayout =  { "|M|", centeredmaster };
static const Layout floatingLayout =  { "><>", NULL };

/* layout(s) */
static const Layout layouts[] = {
	/* symbol     arrange function */
	tileLayout,
	monocleLayout,
	centeredmasterLayout,
	{NULL, NULL},
};

/* monitors */
static const MonitorRule monrules[] = {
	/* name       mfact nmaster scale layout       rotate/reflect                x    y */
	{ "eDP-1",    0.5,  1,      1,    &tileLayout, WL_OUTPUT_TRANSFORM_NORMAL,   0,  0 },
	{ "DP-6",    0.5,  1,      1,    &centeredmasterLayout, WL_OUTPUT_TRANSFORM_NORMAL,   1,  0 },
	{ "DP-1",    0.5,  1,      1,    &tileLayout, WL_OUTPUT_TRANSFORM_NORMAL,   1,  -1 },
	/* defaults */
	{ NULL,       0.55, 1,      1,    &tileLayout, WL_OUTPUT_TRANSFORM_NORMAL,   -1,  -1 },
};

/* keyboard */
static const struct xkb_rule_names xkb_rules = {
	/* can specify fields: rules, model, layout, variant, options */
	/* example:
	.options = "ctrl:nocaps",
	*/
	.options = NULL,
};

static const int repeat_rate = 25;
static const int repeat_delay = 600;

/* Trackpad */
static const int tap_to_click = 1;
static const int tap_and_drag = 1;
static const int drag_lock = 1;
static const int natural_scrolling = 0;
static const int disable_while_typing = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 0;
/* You can choose between:
LIBINPUT_CONFIG_SCROLL_NO_SCROLL
LIBINPUT_CONFIG_SCROLL_2FG
LIBINPUT_CONFIG_SCROLL_EDGE
LIBINPUT_CONFIG_SCROLL_ON_BUTTON_DOWN
*/
static const enum libinput_config_scroll_method scroll_method = LIBINPUT_CONFIG_SCROLL_2FG;

/* You can choose between:
LIBINPUT_CONFIG_CLICK_METHOD_NONE
LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS
LIBINPUT_CONFIG_CLICK_METHOD_CLICKFINGER
*/
static const enum libinput_config_click_method click_method = LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;

/* You can choose between:
LIBINPUT_CONFIG_SEND_EVENTS_ENABLED
LIBINPUT_CONFIG_SEND_EVENTS_DISABLED
LIBINPUT_CONFIG_SEND_EVENTS_DISABLED_ON_EXTERNAL_MOUSE
*/
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;

/* You can choose between:
LIBINPUT_CONFIG_ACCEL_PROFILE_FLAT
LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE
*/
static const enum libinput_config_accel_profile accel_profile = LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 0.0;
/* You can choose between:
LIBINPUT_CONFIG_TAP_MAP_LRM -- 1/2/3 finger tap maps to left/right/middle
LIBINPUT_CONFIG_TAP_MAP_LMR -- 1/2/3 finger tap maps to left/middle/right
*/
static const enum libinput_config_tap_button_map button_map = LIBINPUT_CONFIG_TAP_MAP_LRM;

/* If you want to use the windows key for MODKEY, use WLR_MODIFIER_LOGO */
#define MODKEY WLR_MODIFIER_LOGO

#define TAGKEYS(KEY,SKEY,TAG) \
	{ MODKEY,                    KEY,            view,            {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL,  KEY,            toggleview,      {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_SHIFT, SKEY,           tag,             {.ui = 1 << TAG} }, \
	{ MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT,SKEY,toggletag, {.ui = 1 << TAG} }

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static const char *termcmd[] = { "tfoot", NULL };
static const char *screenshotcmd[] = { "grim-region", NULL };
static const char *screenlockcmd[] = { "swaylock", "-f", "-c", "000000", NULL };
static const char *menucmd[] = { "wofi", "--show", "run", NULL };


static const Key keys[] = {
	/* Note that Shift changes certain key codes: c -> C, 2 -> at, etc. */
	/* modifier                  key                 function        argument */
	{ MODKEY,                    XKB_KEY_p,          spawn,          {.v = menucmd} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Return,     spawn,          {.v = termcmd} },
	{ MODKEY,                    XKB_KEY_Return,     spawn,          {.v = termcmd} },
	{ MODKEY,                    XKB_KEY_w,     spawn,          {.v = screenshotcmd} },
	{ MODKEY,                    XKB_KEY_x,     spawn,          {.v = screenlockcmd} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Y,     spawn,          {.v = screenlockcmd} },
	{ MODKEY,                    XKB_KEY_j,          focusstack,     {.i = +1} },
	{ MODKEY,                    XKB_KEY_k,          focusstack,     {.i = -1} },
    { MODKEY,                    XKB_KEY_Left,      	 rotatetags,     {.i = -1} },
    { MODKEY,                    XKB_KEY_Right,      	 rotatetags,     {.i =  1} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Left,      	 clientshift,    {.i = -1} },
    { MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Right,      	 clientshift,    {.i =  1} },
	{ MODKEY,                    XKB_KEY_h,          setmfact,       {.f = -0.05} },
	{ MODKEY,                    XKB_KEY_l,          setmfact,       {.f = +0.05} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_H,          incnmaster,     {.i = +1} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_L,          incnmaster,     {.i = -1} },
	{ MODKEY,                    XKB_KEY_Tab,        focusstack,     {.i = +1} },
	{ MODKEY,                    XKB_KEY_z,          zoom,           {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Tab,        zoom,           {0} },
	{ MODKEY,                    XKB_KEY_y,          view,           {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_C,          killclient,     {0} },
	{ MODKEY,                    XKB_KEY_space,      cyclelayout,    {.i = +1 } },
	{ MODKEY,                    XKB_KEY_f,          setlayout,      {.v = &monocleLayout} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_F,          togglefullscreen, {0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_space,      setlayout,      {0} },
	{ MODKEY,                    XKB_KEY_d,          view,           {.ui = ~0} },
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_D,          tag,            {.ui = ~0} },
	{ MODKEY,                    XKB_KEY_comma,      focusmon,       {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY,                    XKB_KEY_period,     focusmon,       {.i = WLR_DIRECTION_RIGHT} },
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_comma,      tagmon,         {.i = WLR_DIRECTION_LEFT} },
	{ MODKEY|WLR_MODIFIER_CTRL,  XKB_KEY_period,     tagmon,         {.i = WLR_DIRECTION_RIGHT} },
	TAGKEYS(          XKB_KEY_u, XKB_KEY_U,                          0),
	TAGKEYS(          XKB_KEY_i, XKB_KEY_I,                          1),
	TAGKEYS(          XKB_KEY_a, XKB_KEY_A,                          2),
	TAGKEYS(          XKB_KEY_e, XKB_KEY_E,                          3),
	TAGKEYS(          XKB_KEY_o, XKB_KEY_O,                          4),
	TAGKEYS(          XKB_KEY_s, XKB_KEY_S,                          5),
	TAGKEYS(          XKB_KEY_n, XKB_KEY_N,                          6),
	TAGKEYS(          XKB_KEY_r, XKB_KEY_R,                          7),
	TAGKEYS(          XKB_KEY_t, XKB_KEY_T,                          8),
	{ MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Q,          quit,           {0} },

	/* Ctrl-Alt-Backspace and Ctrl-Alt-Fx used to be handled by X server */
	{ WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_Terminate_Server, quit, {0} },
#define CHVT(n) { WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT,XKB_KEY_XF86Switch_VT_##n, chvt, {.ui = (n)} }
	CHVT(1), CHVT(2), CHVT(3), CHVT(4), CHVT(5), CHVT(6),
	CHVT(7), CHVT(8), CHVT(9), CHVT(10), CHVT(11), CHVT(12),
};

static const Button buttons[] = {
	{ MODKEY, BTN_LEFT,   moveresize,     {.ui = CurMove} },
	{ MODKEY, BTN_MIDDLE, setnofloating,   {0} },
	{ MODKEY, BTN_RIGHT,  moveresize,     {.ui = CurResize} },
};
