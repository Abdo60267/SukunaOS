/*
 * king_of_curses_lsm.c - Proof-of-concept LSM for SukunaOS
 * POC: when encountering unknown binaries, broadcast a Netlink message to
 * userspace (sukuna-securityd) containing the path. Userspace can analyze
 * the binary and update its cache. This module does not wait for reply;
 * it denies execution by default on unknown binaries to be conservative.
 *
 * NOTE: This is a minimal POC and intended for development only.
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/security.h>
#include <linux/binfmts.h>
#include <linux/cred.h>
#include <linux/slab.h>
#include <linux/uaccess.h>
#include <linux/netlink.h>
#include <net/sock.h>
#include <net/netlink.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("SukunaOS Team");
MODULE_DESCRIPTION("King of Curses LSM (POC with netlink broadcast)");

static struct sock *koc_nl_sock = NULL;

/* Simple in-kernel allowlist: for POC we store a list of filenames (not secure)
 * Real implementation should use hashes and userspace-signed DB + netlink sync.
 */
static const char *allowlist[] = {
    "/usr/bin/safe_example",
    "/usr/bin/sukuna-shell",
    NULL,
};

/* Broadcast an advisory message to userspace via netlink; payload is a
 * small JSON-like string with path and pid.
 */
static void koc_netlink_broadcast(const char *path)
{
    struct sk_buff *skb;
    struct nlmsghdr *nlh;
    size_t payload_len;
    char *payload;

    if (!koc_nl_sock || !path)
        return;

    payload_len = strlen(path) + 128;
    skb = nlmsg_new(payload_len, GFP_KERNEL);
    if (!skb) {
        pr_warn("koc: failed to allocate nl skb\n");
        return;
    }

    nlh = nlmsg_put(skb, 0, 0, NLMSG_DONE, payload_len, 0);
    if (!nlh) {
        pr_warn("koc: nlmsg_put failed\n");
        kfree_skb(skb);
        return;
    }

    payload = nlmsg_data(nlh);
    snprintf(payload, payload_len, "{\"event\":\"exec_check\",\"path\":\"%s\"}", path);

    /* broadcast to userspace group 0 */
    netlink_broadcast(koc_nl_sock, skb, 0, 0, GFP_KERNEL);
    pr_debug("koc: broadcasted exec_check for %s\n", path);
}

static int koc_bprm_check(struct linux_binprm *bprm)
{
    const char **p = allowlist;
    char *filename = NULL;

    if (!bprm || !bprm->filename)
        return 0; /* allow by default to avoid lockouts in POC */

    filename = kstrdup(bprm->filename, GFP_KERNEL);
    if (!filename)
        return 0;

    for (p = allowlist; *p; ++p) {
        if (strcmp(filename, *p) == 0) {
            kfree(filename);
            pr_debug("koc: allowlist matched %s\n", *p);
            return 0; /* allow */
        }
    }

    /* Not in allowlist: notify userspace and deny execution (POC conservative)
     * Real implementation could wait for reply or use in-kernel cache.
     */
    koc_netlink_broadcast(bprm->filename);
    pr_warn("koc: execution denied for %s (not in allowlist)\n", bprm->filename);
    kfree(filename);
    return -EPERM; /* deny execution */
}

static struct security_hook_list koc_hooks[] __lsm_ro_after_init = {
    LSM_HOOK_INIT(bprm_check_security, koc_bprm_check),
};

/* Netlink receive handler (kernel) - optional: we accept responses but do nothing
 * in this POC. Userspace may send back advisories for future enhancement.
 */
static void koc_nl_recv(struct sk_buff *skb)
{
    struct nlmsghdr *nlh = nlmsg_hdr(skb);
    char *data = (char *)nlmsg_data(nlh);
    pr_info("koc: netlink recv: %s\n", data ? data : "(null)");
}

static int __init koc_init(void)
{
    struct netlink_kernel_cfg cfg = {
        .input = koc_nl_recv,
    };

    pr_info("king_of_curses: init POC LSM\n");
    koc_nl_sock = netlink_kernel_create(&init_net, NETLINK_USERSOCK, &cfg);
    if (!koc_nl_sock) {
        pr_warn("koc: failed to create netlink socket\n");
    }
    security_add_hooks(koc_hooks, ARRAY_SIZE(koc_hooks), "king_of_curses");
    return 0;
}

static void __exit koc_exit(void)
{
    pr_info("king_of_curses: exit POC LSM\n");
    if (koc_nl_sock) {
        sock_release(koc_nl_sock->sk_socket);
        koc_nl_sock = NULL;
    }
}

module_init(koc_init);
module_exit(koc_exit);
