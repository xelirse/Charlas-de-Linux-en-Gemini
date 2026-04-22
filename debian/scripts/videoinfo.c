#include <tk.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <locale.h>
#include <time.h>
#include <ctype.h>

// ANSI Terminal Colors
#define C_ORANGE  "\033[01;38;5;208m" 
#define C_TEAL    "\033[01;36m"        
#define C_YELLOW  "\033[01;33m"        
#define C_GREEN   "\033[01;32m"        
#define C_WHITE   "\033[01;37m"        
#define C_RESET   "\033[0m"

// GUI Color Palette
#define G_BG_GRAY  "#DCDAD5"
#define COLOR_1    "#008080"
#define COLOR_2    "#0000FF"
#define COLOR_3    "#008000"
#define COLOR_4    "#00008B"
#define COLOR_5    "#FF8C00"

// Translation structure for distinct Terminal and GUI strings
typedef struct {
    const char *chip_desc;
    const char *x_server;
    const char *driver_used;
    const char *xorg_ver;
    const char *dimensions;
    const char *depth;
    const char *term_saved_in;
    const char *term_archived_with;
    const char *gui_saved_in;
    const char *gui_archived_with;
    const char *as;
    const char *btn_reports;
    const char *btn_close;
    const char *pixels;
    const char *millimeters;
    const char *planes;
} Lang;

// Get current date and time with forced locale handling
void get_current_datetime(char *buffer, size_t size, int is_english) {
    if (is_english) {
        setlocale(LC_TIME, "C");
    } else {
        if (!setlocale(LC_TIME, "es_AR.UTF-8")) {
            setlocale(LC_TIME, "es_ES.UTF-8");
        }
    }

    time_t t = time(NULL);
    struct tm *tm_info = localtime(&t);
    strftime(buffer, size, "%A %d %b %Y %T", tm_info);
    
    if (size > 0 && buffer[0] != '\0') {
        buffer[0] = toupper((unsigned char)buffer[0]);
    }
}

// Write report to file
void save_report(const char *path, const char *content) {
    FILE *f = fopen(path, "w");
    if (f) {
        fprintf(f, "%s", content);
        fclose(f);
    }
}

int main(int argc, char *argv[]) {
    setlocale(LC_ALL, "");

    const char *lang_env = getenv("LC_ALL");
    if (!lang_env) lang_env = getenv("LANG");
    
    int is_english = 0;
    int is_argentina = 0;

    if (lang_env) {
        if (strncmp(lang_env, "en", 2) == 0) {
            is_english = 1;
        } else if (strstr(lang_env, "es_AR") != NULL) {
            is_argentina = 1;
        }
    }

    // Translation definitions
    Lang en = {
        "Chip description", "X Server", "Driver used", "X.Org version", 
        "dimensions", "root window depth", 
        "the above was also saved in", "and archived with",
        "The report below was saved in", "and archived with",
        "as", " Reports ", " Close ", "pixels", "millimeters", "planes"
    };
    Lang es = {
        "Descripción del chip", "Servidor X", "Controlador usado", "Versión de X.Org", 
        "dimensiones", "profundidad de la ventana raíz", 
        "lo anterior también se guardó en", "y se archivó con",
        "El reporte de abajo se guardó en", "y se archivó con",
        "como", " Reportes ", " Cerrar ", 
        is_argentina ? "pixeles" : "píxeles", "milímetros", "planos"
    };
    
    Lang *l = is_english ? &en : &es;

    char datetime[128];
    get_current_datetime(datetime, sizeof(datetime), is_english);

    // Hardware data
    char chip1_lbl[] = " 5.0 VGA compatible controller:  ";
    char chip1_val[] = "Advanced Micro Devices, Inc. [AMD/ATI] RS780C [Radeon 3100]";
    char chip2_lbl[] = " 0.0 VGA compatible controller:  ";
    char chip2_val[] = "Advanced Micro Devices, Inc. [AMD/ATI] Turks XT [Radeon HD 6670/7670]";
    char driver[] = "radeon";
    char xorg_ver[] = "21.1.22"; 
    
    char dims_val[128];
    snprintf(dims_val, sizeof(dims_val), "1280x1024 %s (338x270 %s)", l->pixels, l->millimeters);
    char depth_val[64];
    snprintf(depth_val, sizeof(depth_val), "24 %s", l->planes);

    const char *p_txt = "/tmp/root/video-info";
    const char *p_dir_term = "/tmp/root/";
    const char *p_conf_term = is_english ? "xorg.conf and Xorg.0.log" : "xorg.conf y Xorg.0.log";
    const char *p_conf_gui = "/etc/X11/xorg.conf, /var/log/Xorg.0.log";
    const char *prep = is_english ? "on" : "en";

    // Build file content
    char file_content[2048];
    snprintf(file_content, sizeof(file_content), 
             "Video-Info 1.5.1 - %s\n\n%s:\n%s%s\n%s%s\n\n%s: Xorg  %s: %s\n%s: %s\n%s: %s\n%s: %s\n",
             datetime, l->chip_desc, chip1_lbl, chip1_val, chip2_lbl, chip2_val, 
             l->x_server, l->driver_used, driver, l->xorg_ver, xorg_ver, l->dimensions, dims_val, l->depth, depth_val);

    save_report(p_txt, file_content);
    system("tar -czf /tmp/root/video-info-full.gz /etc/X11/xorg.conf /var/log/Xorg.0.log /tmp/root/video-info 2>/dev/null");

    // --- TERMINAL OUTPUT ---
    printf("%sVideo-Info 1.5.1%s - %s%s%s %s %sLxPupSc64 23.01%s - %sLinux 6.19.8-1-MANJARO x86_64%s\n\n", 
           C_ORANGE, C_WHITE, C_ORANGE, datetime, C_WHITE, prep, C_ORANGE, C_WHITE, C_ORANGE, C_RESET);
    
    printf("%s%s:  %s\n", C_TEAL, l->chip_desc, C_RESET);
    printf("%s%s%s%s\n", C_GREEN, chip1_lbl, C_WHITE, chip1_val);
    printf("%s%s%s%s\n\n", C_GREEN, chip2_lbl, C_WHITE, chip2_val);
    
    printf("%s%s:  %sXorg  %s%s:  %s%s%s\n", C_TEAL, l->x_server, C_WHITE, C_TEAL, l->driver_used, C_WHITE, driver, C_RESET);
    printf("%s%s:  %s%s%s\n", C_TEAL, l->xorg_ver, C_WHITE, xorg_ver, C_RESET);
    printf("%s  %s:  %s%s%s\n", C_YELLOW, l->dimensions, C_WHITE, dims_val, C_RESET);
    printf("%s  %s:  %s%s%s\n\n", C_YELLOW, l->depth, C_WHITE, depth_val, C_RESET);
    
    // Exactly 3 spaces at start of the first line, 0 at the second
    printf("   %s...%s %s%s%s %s %svideo-info%s,\n", C_TEAL, l->term_saved_in, C_GREEN, p_dir_term, C_TEAL, l->as, C_GREEN, C_TEAL);
    printf("%s%s %s%s%s %s %svideo-info-full.gz%s\n", C_TEAL, l->term_archived_with, C_GREEN, p_conf_term, C_TEAL, l->as, C_GREEN, C_RESET);

    // --- GUI INTERFACE (Tcl/Tk) ---
    Tcl_Interp *interp = Tcl_CreateInterp();
    Tcl_Init(interp); Tk_Init(interp);
    Tcl_Eval(interp, "wm withdraw .; wm title . \"Información de Video\"; . configure -bg {" G_BG_GRAY "}");
    
    Tcl_Eval(interp, "catch {image create photo img_main -file {/usr/share/icons/video-info.png}; wm iconphoto . -default img_main}");
    Tcl_Eval(interp, "set ic_rep [image create photo]; catch {$ic_rep read /usr/share/icons/gnome/16x16/places/folder.png}");
    Tcl_Eval(interp, "set ic_cls [image create photo]; catch {$ic_cls read /usr/share/icons/gnome/16x16/actions/exit.png}");
    Tcl_Eval(interp, "set ic_cpy [image create photo]; catch {$ic_cpy read /usr/share/icons/gnome/16x16/actions/edit-copy.png}");
    Tcl_Eval(interp, "set ic_all [image create photo]; catch {$ic_all read /usr/share/icons/gnome/16x16/actions/edit-select-all.png}");
    Tcl_Eval(interp, "bind . <Control-a> {set w [focus]; if {$w ne \"\"} {$w tag add sel 1.0 end}}");

    Tcl_SetVar(interp, "m_copy", is_english ? "Copy" : "Copiar", 0);
    Tcl_SetVar(interp, "m_all", is_english ? "Select all" : "Seleccionar todo", 0);
    Tcl_Eval(interp, "menu .popup -tearoff 0 -cursor left_ptr");
    Tcl_Eval(interp, ".popup add command -label $m_copy -image $ic_cpy -compound left -command {event generate [focus] <<Copy>>}");
    Tcl_Eval(interp, ".popup add command -label $m_all -image $ic_all -compound left -command {set w [focus]; if {$w ne \"\"} {$w tag add sel 1.0 end}}");

    Tcl_Eval(interp, "frame .h -bg {" G_BG_GRAY "} -padx 10 -pady 10; pack .h -side top -fill x");
    Tcl_Eval(interp, "label .h.i -image img_main -bg {" G_BG_GRAY "}; pack .h.i -side left");
    Tcl_Eval(interp, "text .h.m -bg {" G_BG_GRAY "} -font {Helvetica 10} -height 3 -relief flat -highlightthickness 0 -padx 10 -cursor left_ptr");
    Tcl_Eval(interp, "pack .h.m -side left -fill x -expand 1");
    Tcl_Eval(interp, "bind .h.m <Button-3> {focus %W; tk_popup .popup %X %Y}");
    Tcl_Eval(interp, ".h.m tag configure path -font {Helvetica 10 bold} -foreground \"" COLOR_4 "\"");

    Tcl_SetVar(interp, "hp1", p_txt, 0);
    Tcl_SetVar(interp, "hp2", p_conf_gui, 0);
    Tcl_SetVar(interp, "hp3", "video-info-full.gz", 0);
    Tcl_SetVar(interp, "txt_saved", l->gui_saved_in, 0);
    Tcl_SetVar(interp, "txt_arch", l->gui_archived_with, 0);
    Tcl_SetVar(interp, "txt_as", l->as, 0);

    Tcl_Eval(interp, ".h.m insert end \"$txt_saved \"; .h.m insert end $hp1 path; "
                     ".h.m insert end \"\\n$txt_arch \"; .h.m insert end $hp2 path; "
                     ".h.m insert end \"\\n$txt_as \"; .h.m insert end $hp3 path");

    Tcl_Eval(interp, "frame .bf -bg {" G_BG_GRAY "} -pady 10; pack .bf -side bottom -fill x");
    Tcl_SetVar(interp, "btn_r", l->btn_reports, 0);
    Tcl_SetVar(interp, "btn_c", l->btn_close, 0);
    Tcl_Eval(interp, "button .bf.r -text $btn_r -image $ic_rep -compound left -padx 10 -command {exec rox /tmp/root &}");
    Tcl_Eval(interp, "button .bf.c -text $btn_c -image $ic_cls -compound left -padx 10 -command exit");
    Tcl_Eval(interp, "pack .bf.r -side left -padx 20; pack .bf.c -side right -padx 20");

    Tcl_Eval(interp, "frame .f_txt -bg white -bd 1 -relief sunken; pack .f_txt -side top -fill both -expand 1 -padx 10 -pady 5");
    Tcl_Eval(interp, "text .f_txt.t -font {Monospace 9} -bg white -relief flat -wrap none -cursor left_ptr -highlightthickness 0 -padx 5 -pady 5");
    Tcl_Eval(interp, "pack .f_txt.t -side top -fill both -expand 1");
    Tcl_Eval(interp, "bind .f_txt.t <Button-3> {focus %W; tk_popup .popup %X %Y}");

    Tcl_Eval(interp, ".f_txt.t tag configure c1 -foreground \"" COLOR_1 "\"");
    Tcl_Eval(interp, ".f_txt.t tag configure c2 -foreground \"" COLOR_2 "\"");
    Tcl_Eval(interp, ".f_txt.t tag configure c3 -foreground \"" COLOR_3 "\"");
    Tcl_Eval(interp, ".f_txt.t tag configure c4 -foreground \"" COLOR_4 "\" -font {Monospace 9 bold}");
    Tcl_Eval(interp, ".f_txt.t tag configure c5 -foreground \"" COLOR_5 "\" -font {Monospace 9 bold}");

    Tcl_SetVar(interp, "dt", datetime, 0);
    Tcl_SetVar(interp, "prep", prep, 0);
    Tcl_SetVar(interp, "chip_desc", l->chip_desc, 0);
    Tcl_SetVar(interp, "c1l", chip1_lbl, 0); Tcl_SetVar(interp, "c1v", chip1_val, 0);
    Tcl_SetVar(interp, "c2l", chip2_lbl, 0); Tcl_SetVar(interp, "c2v", chip2_val, 0);
    Tcl_SetVar(interp, "x_serv", l->x_server, 0);
    Tcl_SetVar(interp, "drv_u", l->driver_used, 0); Tcl_SetVar(interp, "drv", driver, 0);
    Tcl_SetVar(interp, "xv_l", l->xorg_ver, 0); Tcl_SetVar(interp, "xv", xorg_ver, 0);
    Tcl_SetVar(interp, "dm_l", l->dimensions, 0); Tcl_SetVar(interp, "dm", dims_val, 0);
    Tcl_SetVar(interp, "dp_l", l->depth, 0); Tcl_SetVar(interp, "dp", depth_val, 0);

    Tcl_Eval(interp, 
        ".f_txt.t insert end \"Video-Info 1.5.1\" c5; .f_txt.t insert end \"  -  \" c4\n"
        ".f_txt.t insert end \"$dt\" c5; .f_txt.t insert end \" $prep \" c4\n"
        ".f_txt.t insert end \"LxPupSc64 23.01\" c5; .f_txt.t insert end \" - \" c4\n"
        ".f_txt.t insert end \"Linux 6.19.8-1-MANJARO x86_64\\n\\n\" c5\n"

        ".f_txt.t insert end \"$chip_desc:  \\n\" c1\n"
        ".f_txt.t insert end \"$c1l\" c3; .f_txt.t insert end \"$c1v\\n\" c4\n"
        ".f_txt.t insert end \"$c2l\" c3; .f_txt.t insert end \"$c2v\\n\\n\" c4\n"

        ".f_txt.t insert end \"$x_serv:  \" c1; .f_txt.t insert end \"Xorg  \" c4\n"
        ".f_txt.t insert end \"$drv_u:  \" c1; .f_txt.t insert end \"$drv\\n\" c4\n"

        ".f_txt.t insert end \"$xv_l:  \" c1; .f_txt.t insert end \"$xv\\n\" c4\n"
        ".f_txt.t insert end \"  $dm_l:  \" c2; .f_txt.t insert end \"$dm\\n\" c4\n"
        ".f_txt.t insert end \"  $dp_l:  \" c2; .f_txt.t insert end \"$dp\\n\" c4\n"
    );

    Tcl_Eval(interp, 
        "set nl [expr {int([.f_txt.t index end-1c])}]\n"
        ".f_txt.t configure -height $nl\n"
        "update idletasks\n"
        "set w [expr {[winfo reqwidth .] + 20}]\n"
        "set h [winfo reqheight .]\n"
        "set x [expr {([winfo screenwidth .] - $w) / 2}]\n"
        "set y [expr {([winfo screenheight .] - $h) / 2}]\n"
        "wm geometry . ${w}x${h}+${x}+${y}\n"
        "wm deiconify .\n"
    );

    Tk_MainLoop();
    return 0;
}
