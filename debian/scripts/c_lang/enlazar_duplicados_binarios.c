#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>
#include <libgen.h>

#define HASH_SIZE 1024

typedef struct FileNode {
    char *path;
    char *name;
    off_t size;
    struct FileNode *next;
} FileNode;

FileNode *hash_table[HASH_SIZE];

unsigned int hash_size(off_t size) {
    return size % HASH_SIZE;
}

int are_files_identical(const char *p1, const char *p2, off_t size) {
    int f1 = open(p1, O_RDONLY);
    int f2 = open(p2, O_RDONLY);
    int result = 0;
    if (f1 < 0 || f2 < 0) goto cleanup;

    void *m1 = mmap(NULL, size, PROT_READ, MAP_PRIVATE, f1, 0);
    void *m2 = mmap(NULL, size, PROT_READ, MAP_PRIVATE, f2, 0);

    if (m1 != MAP_FAILED && m2 != MAP_FAILED) {
        result = (memcmp(m1, m2, size) == 0);
    }

    if (m1 != MAP_FAILED) munmap(m1, size);
    if (m2 != MAP_FAILED) munmap(m2, size);
cleanup:
    if (f1 >= 0) close(f1);
    if (f2 >= 0) close(f2);
    return result;
}

void index_base_directory(const char *dir_path) {
    struct dirent *entry;
    struct stat st;
    DIR *dir = opendir(dir_path);
    if (!dir) return;

    while ((entry = readdir(dir)) != NULL) {
        char full_path[PATH_MAX];
        snprintf(full_path, sizeof(full_path), "%s/%s", dir_path, entry->d_name);
        if (lstat(full_path, &st) == 0 && S_ISREG(st.st_mode)) {
            unsigned int h = hash_size(st.st_size);
            FileNode *node = malloc(sizeof(FileNode));
            node->path = strdup(full_path);
            node->name = strdup(entry->d_name);
            node->size = st.st_size;
            node->next = hash_table[h];
            hash_table[h] = node;
        }
    }
    closedir(dir);
}

long count_files(const char *dir_path) {
    long count = 0;
    struct dirent *entry;
    struct stat st;
    DIR *dir = opendir(dir_path);
    if (!dir) return 0;
    while ((entry = readdir(dir)) != NULL) {
        char full_path[PATH_MAX];
        snprintf(full_path, sizeof(full_path), "%s/%s", dir_path, entry->d_name);
        if (lstat(full_path, &st) == 0 && S_ISREG(st.st_mode)) count++;
    }
    closedir(dir);
    return count;
}

void process_secondary_directory(const char *dir_path, int dry_run) {
    struct dirent *entry;
    struct stat st;
    long total = count_files(dir_path);
    long actual = 0;
    time_t inicio = time(NULL);
    DIR *dir = opendir(dir_path);

    if (!dir || total == 0) return;

    char linea_progreso[128];

    while ((entry = readdir(dir)) != NULL) {
        char full_path[PATH_MAX];
        snprintf(full_path, sizeof(full_path), "%s/%s", dir_path, entry->d_name);

        if (lstat(full_path, &st) == 0 && S_ISREG(st.st_mode)) {
            actual++;
            time_t ahora = time(NULL);
            
            char fecha_fin[64] = "calculando...";
            if (actual > 1) {
                double transcurrido = difftime(ahora, inicio);
                double segundos_restantes = (transcurrido / actual) * (total - actual);
                time_t t_fin = ahora + (time_t)segundos_restantes;
                struct tm *info_fin = localtime(&t_fin);
                strftime(fecha_fin, sizeof(fecha_fin), "%H:%M:%S", info_fin);
            }

            int porcentaje = (int)((actual * 100) / total);
            sprintf(linea_progreso, "\r\e[Kprocesando: [%3d%%] (%ld/%ld) - fin estimado: %s", 
                   porcentaje, actual, total, fecha_fin);
            printf("%s", linea_progreso);
            fflush(stdout);

            unsigned int h = hash_size(st.st_size);
            FileNode *current = hash_table[h];
            while (current) {
                if (current->size == st.st_size) {
                    if (are_files_identical(current->path, full_path, st.st_size)) {
                        printf("\r\e[K");
                        
                        // Construcción de la ruta relativa: de /usr/sbin/ a /usr/bin/ es ../bin/
                        char relative_target[PATH_MAX];
                        snprintf(relative_target, sizeof(relative_target), "../bin/%s", current->name);

                        if (dry_run) {
                            printf("ln -svfr %s %s\n", current->path, full_path);
                        } else {
                            if (unlink(full_path) == 0) {
                                if (symlink(relative_target, full_path) == 0) {
                                    printf("ln -svfr %s %s\n", current->path, full_path);
                                }
                            }
                        }
                        printf("%s", linea_progreso);
                        fflush(stdout);
                        break; 
                    }
                }
                current = current->next;
            }
        }
    }
    closedir(dir);
}

int main() {
    if (geteuid() != 0) {
        fprintf(stderr, "Error: Se requieren privilegios de root.\n");
        return 1;
    }

    int dry_run = 1; // 1 para simulación, 0 para ejecución real
    
    if (dry_run) printf("--- modo simulación activo ---\n");

    index_base_directory("/usr/bin");
    process_secondary_directory("/usr/sbin", dry_run);

    time_t ahora = time(NULL);
    struct tm *t = localtime(&ahora);
    char s[64];
    strftime(s, sizeof(s), "%d/%m %H:%M:%S", t);
    printf("\n--- proceso finalizado a las %s ---\n", s);

    return 0;
}
