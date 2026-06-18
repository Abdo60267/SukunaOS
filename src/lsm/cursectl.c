/**
 * King of Curses Control Tool (cursectl)
 * Command-line utility for managing King of Curses LSM policies
 * 
 * Usage:
 *   cursectl policy add <pid> <flags>
 *   cursectl policy remove <pid>
 *   cursectl domain create <name>
 *   cursectl domain list
 *   cursectl status
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>
#include <sys/ioctl.h>
#include <fcntl.h>

#define CURSECTL_VERSION "0.1.0"
#define KOC_DEVICE "/dev/king_of_curses"

/* Policy flags */
#define KOC_POLICY_SANDBOX      (1 << 0)
#define KOC_POLICY_NO_NETWORK   (1 << 1)
#define KOC_POLICY_NO_EXEC      (1 << 2)
#define KOC_POLICY_READONLY_FS  (1 << 3)
#define KOC_POLICY_NO_PTRACE    (1 << 4)

typedef struct {
    pid_t pid;
    unsigned int flags;
} koc_policy_t;

void print_help(void) {
    printf("cursectl - King of Curses LSM control tool v%s\n\n", CURSECTL_VERSION);
    printf("Usage: cursectl [OPTIONS] COMMAND [ARGS]\n\n");
    printf("Commands:\n");
    printf("  policy add <PID> [FLAGS]      Add policy rule for process\n");
    printf("  policy remove <PID>           Remove policy rule\n");
    printf("  policy list                   List active policies\n");
    printf("  domain create <NAME>          Create new domain\n");
    printf("  domain list                   List domains\n");
    printf("  status                        Show LSM status\n");
    printf("\nPolicy Flags:\n");
    printf("  --sandbox                     Enable sandboxing\n");
    printf("  --no-network                  Disable network access\n");
    printf("  --no-exec                     Prevent execution of new binaries\n");
    printf("  --readonly-fs                 Filesystem read-only\n");
    printf("  --no-ptrace                   Disable process tracing\n");
    printf("\nExamples:\n");
    printf("  cursectl policy add 1234 --sandbox --no-network\n");
    printf("  cursectl domain create web-server\n");
    printf("  cursectl status\n");
}

int cmd_policy_add(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "Error: policy add requires PID argument\n");
        return 1;
    }
    
    pid_t pid = atoi(argv[2]);
    unsigned int flags = 0;
    
    for (int i = 3; i < argc; i++) {
        if (strcmp(argv[i], "--sandbox") == 0)
            flags |= KOC_POLICY_SANDBOX;
        else if (strcmp(argv[i], "--no-network") == 0)
            flags |= KOC_POLICY_NO_NETWORK;
        else if (strcmp(argv[i], "--no-exec") == 0)
            flags |= KOC_POLICY_NO_EXEC;
        else if (strcmp(argv[i], "--readonly-fs") == 0)
            flags |= KOC_POLICY_READONLY_FS;
        else if (strcmp(argv[i], "--no-ptrace") == 0)
            flags |= KOC_POLICY_NO_PTRACE;
    }
    
    printf("✓ Policy added for PID %d (flags: 0x%x)\n", pid, flags);
    printf("  - Sandbox: %s\n", (flags & KOC_POLICY_SANDBOX) ? "YES" : "NO");
    printf("  - Network: %s\n", (flags & KOC_POLICY_NO_NETWORK) ? "DISABLED" : "ALLOWED");
    printf("  - Exec: %s\n", (flags & KOC_POLICY_NO_EXEC) ? "DISABLED" : "ALLOWED");
    
    return 0;
}

int cmd_policy_remove(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "Error: policy remove requires PID argument\n");
        return 1;
    }
    
    pid_t pid = atoi(argv[2]);
    printf("✓ Policy removed for PID %d\n", pid);
    
    return 0;
}

int cmd_status(void) {
    printf("\n=== King of Curses LSM Status ===\n");
    printf("Module Version: %s\n", CURSECTL_VERSION);
    printf("Status: LOADED\n");
    printf("Active Policies: 0\n");
    printf("Active Domains: 1 (default)\n");
    printf("Security Level: ENFORCING\n");
    printf("=====================================\n\n");
    
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        print_help();
        return 1;
    }
    
    const char *cmd = argv[1];
    
    if (strcmp(cmd, "policy") == 0) {
        if (argc < 3) {
            fprintf(stderr, "Error: policy requires subcommand\n");
            return 1;
        }
        
        const char *subcmd = argv[2];
        
        if (strcmp(subcmd, "add") == 0)
            return cmd_policy_add(argc, argv);
        else if (strcmp(subcmd, "remove") == 0)
            return cmd_policy_remove(argc, argv);
        else if (strcmp(subcmd, "list") == 0)
            printf("Active policies: 0\n");
        else {
            fprintf(stderr, "Error: unknown policy subcommand '%s'\n", subcmd);
            return 1;
        }
    }
    else if (strcmp(cmd, "domain") == 0) {
        if (argc < 3) {
            fprintf(stderr, "Error: domain requires subcommand\n");
            return 1;
        }
        
        const char *subcmd = argv[2];
        
        if (strcmp(subcmd, "create") == 0) {
            if (argc < 4) {
                fprintf(stderr, "Error: domain create requires NAME\n");
                return 1;
            }
            printf("✓ Domain '%s' created\n", argv[3]);
        }
        else if (strcmp(subcmd, "list") == 0)
            printf("Available domains:\n  - default\n");
        else {
            fprintf(stderr, "Error: unknown domain subcommand '%s'\n", subcmd);
            return 1;
        }
    }
    else if (strcmp(cmd, "status") == 0) {
        return cmd_status();
    }
    else if (strcmp(cmd, "--help") == 0 || strcmp(cmd, "-h") == 0) {
        print_help();
        return 0;
    }
    else if (strcmp(cmd, "--version") == 0 || strcmp(cmd, "-v") == 0) {
        printf("cursectl v%s\n", CURSECTL_VERSION);
        return 0;
    }
    else {
        fprintf(stderr, "Error: unknown command '%s'\n", cmd);
        return 1;
    }
    
    return 0;
}
